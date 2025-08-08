from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import logging
from logging.handlers import RotatingFileHandler
import sys
import traceback
from datetime import datetime
import ollama
import mysql.connector
import os
import json
import re  # 添加正则表达式支持

# 使用绝对导入
from ai_router import ai_bp
from topology_generator import generate_topology

# 设置环境变量
os.environ["OLLAMA_HOST"] = "localhost:11434"

# 获取前端构建路径
FRONTEND_BUILD_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), '../frontend/build')

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": [
    "http://localhost:3000"
]}})

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('../logs/backend.log')
    ]
)
log_formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
log_handler = RotatingFileHandler('../logs/backend.log', maxBytes=10*1024*1024, backupCount=5)
log_handler.setFormatter(log_formatter)
log_handler.setLevel(logging.DEBUG)

app.logger.addHandler(log_handler)
app.logger.setLevel(logging.DEBUG)

logger = logging.getLogger(__name__)

# 打印路径信息
print(f"前端构建路径: {FRONTEND_BUILD_PATH}")
print(f"路径是否存在: {os.path.exists(FRONTEND_BUILD_PATH)}")
if os.path.exists(FRONTEND_BUILD_PATH):
    print(f"index.html 是否存在: {os.path.exists(os.path.join(FRONTEND_BUILD_PATH, 'index.html'))}")

# MySQL 配置
MYSQL_CONFIG = {
    'host': 'localhost',
    'user': 'deepseek_app',
    'password': 'DeepSeek123!',
    'database': 'knowledge_db',
    'raise_on_warnings': True,
    'auth_plugin': 'mysql_native_password'
}

# 获取数据库连接
def get_db_connection():
    try:
        conn = mysql.connector.connect(**MYSQL_CONFIG)
        logger.info("成功连接到 MySQL 数据库")
        return conn
    except Exception as e:
        logger.error(f"数据库连接失败: {str(e)}")
        logger.error(f"连接参数: host={MYSQL_CONFIG['host']}, user={MYSQL_CONFIG['user']}, db={MYSQL_CONFIG['database']}")
        logger.error(traceback.format_exc())
        raise

# 添加主页路由
@app.route('/')
def home():
    return """
    <h1>DeepSeek 考试系统后端</h1>
    <p>可用API端点:</p>
    <ul>
        <li>GET /api/subjects - 获取学科列表</li>
        <li>POST /api/generate_exam - 生成试卷</li>
        <li>POST /api/judge_exam - 判卷</li>
        <li>GET /health - 健康检查</li>
        <li>GET /api/test_db - 测试数据库连接</li>
        <li>POST /api/ai/chat - AI对话接口</li>
        <li>POST /api/ai/generate-topology - 生成拓扑图</li>
    </ul>
    """

# 添加健康检查端点
@app.route('/health')
def health_check():
    return jsonify({"status": "ok", "time": datetime.now().isoformat()}), 200

# 添加数据库测试端点
@app.route('/api/test_db')
def test_db():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        return jsonify({"status": "success", "result": result[0]}), 200
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e),
            "config": MYSQL_CONFIG
        }), 500


# 新增：添加拓扑图路由
@app.route('/api/topology', methods=['POST'])
def handle_topology():
    try:
        data = request.json
        description = data.get('description', '')
        logger.info(f"收到拓扑图生成请求: {description}")

        # 调用拓扑图生成逻辑
        topology_data = generate_topology(description)

        logger.info(f"生成的拓扑数据: {json.dumps(topology_data, indent=2)}")
        return jsonify(topology_data), 200
    except Exception as e:
        logger.error(f"拓扑图生成失败: {str(e)}")
        logger.error(traceback.format_exc())
        return jsonify({"error": f"拓扑图生成失败: {str(e)}"}), 500

@app.route('/api/subjects', methods=['GET'])
def get_subjects():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT id, name, description FROM subjects")
        subjects = cursor.fetchall()
        cursor.close()
        conn.close()

        # 确保返回的是JSON数组
        if not subjects:
            subjects = []

        return jsonify(subjects), 200
    except Exception as e:
        logger.error(f"获取学科失败: {str(e)}")
        # 返回硬编码的学科数据作为后备
        return jsonify([
            {"id": 1, "name": "IPv6", "description": "IPv6协议原理、地址配置、过渡技术等"},
            {"id": 2, "name": "SDN", "description": "软件定义网络架构、OpenFlow协议、控制器技术等"},
            {"id": 3, "name": "HCIA", "description": "华为认证网络工程师基础：路由协议、子网划分、设备配置等"}
        ]), 200

# 生成试卷
@app.route('/api/generate_exam', methods=['POST'])
def generate_exam():
    try:
        logger.info("收到生成试卷请求")
        data = request.json
        subject = data.get('subject', 'IPv6')
        logger.info(f"请求学科: {subject}")

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # 获取学科ID
        cursor.execute("SELECT id FROM subjects WHERE name = %s", (subject,))
        subject_data = cursor.fetchone()
        if not subject_data:
            logger.warning(f"未找到学科: {subject}")
            return jsonify({"error": f"未找到学科: {subject}"}), 404

        subject_id = subject_data['id']
        logger.info(f"学科ID: {subject_id}")

        # 试卷结构
        exam_structure = [
            {'type': 'single_choice', 'count': 20, 'score': 1},
            {'type': 'multiple_choice', 'count': 10, 'score': 2},
            {'type': 'true_false', 'count': 10, 'score': 1},
            {'type': 'fill_in_blank', 'count': 10, 'score': 1},
            {'type': 'short_answer', 'count': 4, 'score': 5},
            {'type': 'comprehensive', 'count': 2, 'score': 10}
        ]

        exam = []
        total_score = 0
        question_count = 0

        # 为每种题型生成题目
        for section in exam_structure:
            logger.info(f"获取题型: {section['type']}, 数量: {section['count']}")
            cursor.execute(
                "SELECT id, question, question_type, score, options "
                "FROM questions "
                "WHERE subject_id = %s AND question_type = %s "
                "ORDER BY RAND() LIMIT %s",
                (subject_id, section['type'], section['count'])
            )
            questions = cursor.fetchall()
            logger.info(f"获取到 {len(questions)} 道题目")

            for q in questions:
                # 解析选项字段
                try:
                    options = json.loads(q['options']) if q['options'] else []
                except Exception as e:
                    logger.error(f"解析选项失败: {str(e)}")
                    options = []
                exam.append({
                    'id': q['id'],
                    'question': q['question'],
                    'type': q['question_type'],
                    'score': section['score'],
                    'options': options  # 使用解析后的数组
                })
                total_score += section['score']
                question_count += 1

        cursor.close()
        conn.close()

        logger.info(f"成功生成试卷: {subject}, 题目数量: {question_count}, 总分: {total_score}")
        return jsonify({
            'subject': subject,
            'questions': exam,
            'total_score': total_score
        }), 200

    except Exception as e:
        logger.error(f"生成试卷失败: {str(e)}")
        logger.error(traceback.format_exc())
        return jsonify({"error": f"生成试卷失败: {str(e)}"}), 500

# 判卷
@app.route('/api/judge_exam', methods=['POST'])
def judge_exam():
    try:
        # 添加详细的日志记录
        logger.info("收到判卷请求")

        # 确保正确解析 JSON 数据
        try:
            data = request.json
            if not data:
                logger.error("请求体为空")
                return jsonify({"error": "请求体为空"}), 400
        except Exception as json_error:
            logger.error(f"JSON解析失败: {str(json_error)}")
            return jsonify({"error": "无效的JSON格式"}), 400

        # 确保 answers 是列表
        if 'answers' not in data:
            logger.error("缺少 'answers' 字段")
            return jsonify({"error": "缺少 'answers' 字段"}), 400

        user_answers = data['answers']
        if not isinstance(user_answers, list):
            logger.error(f"'answers' 应该是数组，实际是 {type(user_answers)}")
            return jsonify({"error": "'answers' 应该是数组"}), 400

        # 添加更多调试信息
        logger.info(f"收到 {len(user_answers)} 个答案")
        logger.debug(f"前5个答案: {user_answers[:5]}")  # 调试日志

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # 获取所有题目ID
        question_ids = [str(a['question_id']) for a in user_answers]
        question_ids_str = ','.join(question_ids)

        # 批量获取正确答案
        cursor.execute(
            f"SELECT a.question_id, a.correct_key, a.answer, a.explanation "
            f"FROM answers a "
            f"WHERE a.question_id IN ({question_ids_str})"
        )
        correct_answers = {row['question_id']: row for row in cursor.fetchall()}

        results = []
        total_score = 0

        for answer in user_answers:
            if 'question_id' not in answer:
                logger.error(f"答案缺少 question_id 字段")
                results.append({
                    'status': 'error',
                    'message': '缺少 question_id 字段'
                })
                continue

            question_id = answer['question_id']
            question_type = answer.get('type', 'unknown')
            logger.info(f"处理问题ID: {question_id}, 题型: {question_type}")

            # 获取正确答案信息
            correct_data = correct_answers.get(question_id)
            if not correct_data:
                logger.warning(f"未找到问题 {question_id} 的答案")
                results.append({
                    'question_id': question_id,
                    'status': 'error',
                    'message': '未找到题目答案'
                })
                continue

            correct_key = correct_data['correct_key']
            correct_answer = correct_data['answer']
            explanation = correct_data['explanation'] or "无详细解释"
            user_answer = answer.get('answer', '')
            max_score = answer.get('score', 0)
            question_text = answer.get('question_text', '')

            logger.info(f"用户答案: '{user_answer}' | 正确答案key: '{correct_key}'")

            # 初始化结果详情
            result_details = {
                'question_id': question_id,
                'user_answer': user_answer,
                'correct_key': correct_key,
                'correct_answer': correct_answer,
                'max_score': max_score,
                'explanation': explanation
            }

            # 根据题型判分
            score = 0
            is_correct = False

            if question_type == 'single_choice':
                # 单选题直接比较key
                is_correct = user_answer == correct_key
                score = max_score if is_correct else 0
                result_details['is_correct'] = is_correct
                result_details['score'] = score

            elif question_type == 'multiple_choice':
                # 多选题比较答案集合
                user_sorted = sorted(user_answer.split(',')) if isinstance(user_answer, str) else sorted(user_answer)
                correct_sorted = sorted(correct_key.split(','))
                is_correct = user_sorted == correct_sorted
                score = max_score if is_correct else 0
                result_details['is_correct'] = is_correct
                result_details['score'] = score

            elif question_type == 'true_false':
                # 判断题直接比较key
                is_correct = user_answer == correct_key
                score = max_score if is_correct else 0
                result_details['is_correct'] = is_correct
                result_details['score'] = score

            elif question_type == 'fill_in_blank':
                # 填空题比较答案文本
                user_clean = user_answer.strip().lower()
                correct_clean = correct_answer.strip().lower()
                is_correct = user_clean == correct_clean
                score = max_score if is_correct else 0
                result_details['is_correct'] = is_correct
                result_details['score'] = score

            else:
                # 主观题使用DeepSeek判分
                # 优化后的提示词
                prompt = (
                    f"题目：{question_text}\n\n"
                    f"参考答案：{correct_answer}\极简\n"
                    f"学生答案：{user_answer}\n\n"
                    "请根据以下规则严格评分：\n"
                    "1. 如果学生的答案与题目完全无关或毫无正确内容，评0分\n"
                    "2. 如果答案部分正确，明确列出正确部分和错误部分\n"
                    "3. 根据正确部分的比例给出分数（满分10分）\n"
                    "4. 输出格式：评分：X分\n理由：<简明评语>"
                )

                logger.debug(f"发送给AI的提示词: {prompt[:200]}...")

                try:
                    response = ollama.generate(model='deepseek-r1:1.5b', prompt=prompt)
                    ai_response = response['response'].strip()
                    logger.debug(f"AI响应: {ai_response[:200]}...")

                    # 清理AI响应，移除思考过程
                    if '<think>' in ai_response:
                        # 移除思考过程
                        ai_response = ai_response.split('</think>')[-1].strip()

                    # 初始化变量
                    ai_score = 0
                    found_score = False

                    # 尝试从固定格式解析
                    if '评分：' in ai_response:
                        try:
                            # 提取评分部分
                            score_part = ai_response.split('评分：')[1]
                            score_text = score_part.split('分')[0].strip()

                            # 处理百分比分数
                            if '%' in score_text:
                                percent = float(score_text.replace('%', '').strip())
                                ai_score = percent / 10.0  # 转换为0-10分制
                            else:
                                ai_score = float(score_text)

                            found_score = True

                            # 提取理由部分
                            if '理由：' in ai_response:
                                reason_part = ai_response.split('理由：')[1]
                                # 只保留理由部分
                                ai_response = reason_part.split('\n')[0].strip()
                        except Exception:
                            pass

                    # 使用正则表达式提取所有数字
                    if not found_score:
                        numbers = re.findall(r'\d+\.?\d*', ai_response)
                        if numbers:
                            try:
                                # 取第一个合理范围内的数字
                                num = float(numbers[0])

                                # 处理百分比分数
                                if num > 100:  # 如果数字大于100，可能是百分比
                                    ai_score = num / 10.0
                                else:
                                    ai极简 = min(10, max(0, num))

                                found_score = True
                            except Exception:
                                pass

                    # 当答案与问题无关时强制0分
                    irrelevant_keywords = ["无关", "完全错误", "未提及", "未提供", "未回答", "空白"]
                    if any(keyword in ai_response for keyword in irrelevant_keywords):
                        ai_score = 0
                        found_score = True

                    # 基于答案长度的保底评分
                    if not found_score:
                        if len(user_answer) < 10:  # 极短答案
                            ai_score = 0
                        elif len(user_answer) > 40:  # 有一定内容的答案
                            ai_score = 5
                        else:
                            ai_score = 3
                        logger.warning(f"无法解析AI评分，使用保底分数: {ai_score}")

                    # 计算实际得分
                    score = round((ai_score / 10) * max_score, 1)

                    # 确保分数不超过最大值
                    score = min(score, max_score)

                    # 确保只保留最终评语
                    result_details['ai_response'] = ai_response
                    result_details['score'] = score

                except Exception as ai_error:
                    logger.error(f"调用AI评分失败: {str(ai_error)}")
                    result_details['score'] = 0
                    result_details['ai_error'] = str(ai_error)

            total_score += score
            results.append(result_details)
            logger.info(f"问题 {question_id} 评分完成，得分: {score}/{max_score}")

        cursor.close()
        conn.close()

        logger.info(f"判卷完成，总得分: {total_score}, 题目数量: {len(user_answers)}")

        # 生成详细报告
        return jsonify({
            'total_score': total_score,
            'results': results
        }), 200

    except Exception as e:
        logger.error(f"判卷失败: {str(e)}")
        logger.error(traceback.format_exc())
        return jsonify({"error": f"判卷失败: {str(e)}"}), 500

# 注册AI蓝图
app.register_blueprint(ai_bp)

# 前端服务 - 优化后的路由处理
@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def serve_frontend(path):
    # 处理静态文件请求
    if path and '.' in path:
        # 尝试直接返回文件
        full_path = os.path.join(FRONTEND_BUILD_PATH, path)
        if os.path.isfile(full_path):
            return send_from_directory(FRONTEND_BUILD_PATH, path)
    
    # 对于所有其他路径，返回 index.html
    return send_from_directory(FRONTEND_BUILD_PATH, 'index.html')

if __name__ == '__main__':
    # 打印所有注册的路由
    print("\n=== 注册的路由 ===")
    for rule in app.url_map.iter_rules():
        print(f"{', '.join(rule.methods)}: {rule.rule}")
    print("=================\n")

    app.run(host='0.0.0.0', port=5001, debug=True)