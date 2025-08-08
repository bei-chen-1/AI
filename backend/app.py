from flask_cors import CORS
import logging
import sys
import traceback
from datetime import datetime
import ollama
import mysql.connector
from flask import Flask, request, jsonify, send_from_directory
import os
os.environ["OLLAMA_HOST"] = "localhost:11434"

# 获取前端构建路径
FRONTEND_BUILD_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), '../frontend/build')

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": [
    "http://localhost:3000",
]}})

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 打印路径信息（调试用）
print(f"前端构建路径: {FRONTEND_BUILD_PATH}")
print(f"路径是否存在: {os.path.exists(FRONTEND_BUILD_PATH)}")
if os.path.exists(FRONTEND_BUILD_PATH):
    print(f"index.html 是否存在: {os.path.exists(os.path.join(FRONTEND_BUILD_PATH, 'index.html'))}")

# MySQL 配置
MYSQL_CONFIG = {
    'host': 'localhost',
    'user': 'deepseek_app',
    'password': 'AppPassword123!',
    'database': 'knowledge_db',
    'raise_on_warnings': True
}

# 获取数据库连接
def get_db_connection():
    try:
        conn = mysql.connector.connect(**MYSQL_CONFIG)
        logger.info("成功连接到 MySQL 数据库")
        return conn
    except Exception as e:
        logger.error(f"数据库连接失败: {str(e)}")
        logger.error(traceback.format_exc())
        raise

# 生成题目函数
def generate_question_content(subject):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT id FROM subjects WHERE name = %s", (subject,))
        subject_data = cursor.fetchone()

        if not subject_data:
            return f"未找到学科: {subject}"

        subject_id = subject_data['id']

        cursor.execute(
            "SELECT q.id, q.question FROM questions q "
            "WHERE q.subject_id = %s ORDER BY RAND() LIMIT 1",
            (subject_id,)
        )
        question_data = cursor.fetchone()

        cursor.close()
        conn.close()

        if not question_data:
            # 使用 deepseek-r1:1.5b 模型
            prompt = f"请生成一道{subject}学科的题目（只输出题目，不要包含答案和解析）"
            response = ollama.generate(model='deepseek-r1:1.5b', prompt=prompt)
            return response['response'].strip()

        return question_data['question']
    except Exception as e:
        logger.error(f"生成题目失败: {str(e)}")
        logger.error(traceback.format_exc())
        return f"题目生成错误: {str(e)}"

# 判题
def judge_answer(question, user_answer):
    try:
        logger.info(f"开始判题: 问题={question}, 答案={user_answer}")
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # 添加详细的SQL日志
        logger.info(
            f"执行SQL查询: SELECT a.answer, a.explanation FROM answers a JOIN questions q ON a.question_id = q.id WHERE q.question = '{question}'")

        cursor.execute(
            "SELECT a.answer, a.explanation FROM answers a "
            "JOIN questions q ON a.question_id = q.id "
            "WHERE q.question = %s",
            (question,)
        )
        answer_data = cursor.fetchone()

        cursor.close()
        conn.close()

        if answer_data:
            correct_answer = answer_data['answer']
            explanation = answer_data['explanation'] or "无详细解释"

            if user_answer.strip().lower() == correct_answer.strip().lower():
                return f"✅ 答案正确！\n\n正确答案: {correct_answer}\n\n解析: {explanation}"
            else:
                return f"❌ 答案不正确！\n\n你的答案: {user_answer}\n\n正确答案: {correct_answer}\n\n解析: {explanation}"

        # 使用 deepseek-r1:1.5b 模型
        prompt = (
            f"题目：{question}\n学生答案：{user_answer}\n"
            "请判断答案是否正确，并给出解析（不要重复题目）"
        )
        response = ollama.generate(model='deepseek-r1:1.5b', prompt=prompt)
        return response['response'].strip()
        response.headers['Content-Type'] = 'application/json; charset=utf-8'
        return response
    except Exception as e:
        logger.error(f"判题失败: {str(e)}")
        logger.error(traceback.format_exc())
        return f"判题错误: {str(e)}"

# 获取所有学科
@app.route('/')
def home():
    return "DeepSeek 应用后端服务已运行", 200

@app.route('/favicon.ico')
def favicon():
    return app.send_static_file('favicon.ico')

@app.route('/api/subjects', methods=['GET'])
def get_subjects():
    try:
        logger.info("开始获取学科数据...")
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        logger.info("执行 SQL 查询...")
        cursor.execute("SELECT id, name, description FROM subjects")
        subjects = cursor.fetchall()
        logger.info(f"成功获取 {len(subjects)} 个学科")

        # 记录前3条学科
        for i, subject in enumerate(subjects[:3]):
            logger.info(f"学科 {i+1}: {subject['name']}")
        
        cursor.close()
        conn.close()

        return jsonify(subjects), 200, {'Content-Type': 'application/json; charset=utf-8'}
    except Exception as e:
        logger.error(f"获取学科失败: {str(e)}")
        logger.error(traceback.format_exc())
        # 返回硬编码学科作为后备
        return jsonify([
            {"id": 1, "name": "数学", "description": "数学相关题目"},
            {"id": 2, "name": "物理", "description": "物理相关题目"},
            {"id": 3, "name": "化学", "description": "化学相关题目"},
            {"id": 4, "name": "生物", "description": "生物相关题目"}
        ]), 500, {'Content-Type': 'application/json; charset=utf-8'}

# 生成题目API
@app.route('/api/generate', methods=['POST'])
def api_generate():
    data = request.json
    subject = data.get('subject', '数学')
    question = generate_question_content(subject)
    return jsonify({"question": question, "subject": subject}), 200, {
        'Content-Type': 'application/json; charset=utf-8'}

# 判题API
@app.route('/api/judge', methods=['POST'])
def api_judge():
    data = request.json
    question = data.get('question', '')
    answer = data.get('answer', '')

    if not question or not answer:
        return jsonify({"error": "缺少题目或答案"}), 400

    result = judge_answer(question, answer)
    return jsonify({"result": result}), 200, {
        'Content-Type': 'application/json; charset=utf-8'}

# 添加健康检查端点
@app.route('/health')
def health_check():
    return jsonify({"status": "ok", "time": datetime.now().isoformat()}), 200

# 前端服务
@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def serve_frontend(path):
    # 确保路径安全
    safe_path = path.lstrip('/')
    full_path = os.path.join(FRONTEND_BUILD_PATH, safe_path)
    
    # 调试信息
    logger.debug(f"请求路径: {path} -> {full_path}")
    
    # 如果请求的是文件且存在
    if safe_path and os.path.isfile(full_path):
        logger.debug(f"返回文件: {safe_path}")
        return send_from_directory(FRONTEND_BUILD_PATH, safe_path)
    
    # 如果请求的是目录，尝试返回 index.html
    if os.path.isdir(full_path):
        index_path = os.path.join(full_path, 'index.html')
        if os.path.exists(index_path):
            logger.debug(f"返回目录的index.html: {safe_path}/index.html")
            return send_from_directory(FRONTEND_BUILD_PATH, os.path.join(safe_path, 'index.html'))
    
    # 默认返回 index.html
    logger.debug("返回 index.html")
    return send_from_directory(FRONTEND_BUILD_PATH, 'index.html')

if __name__ == '__main__':
    # 打印所有注册的路由
    print("\n=== 注册的路由 ===")
    for rule in app.url_map.iter_rules():
        print(f"{', '.join(rule.methods)}: {rule.rule}")
    print("=================\n")

    # 初始化时测试关键组件
    try:
        logger.info("测试数据库连接...")
        test_conn = get_db_connection()
        test_conn.close()

        logger.info("测试模型访问...")
        test_response = ollama.generate(model='deepseek-r1:1.5b', prompt="测试")
        logger.info(f"模型测试响应: {test_response['response'][:50]}...")

        logger.info("所有组件测试通过，启动应用...")
        app.run(host='0.0.0.0', port=5001, debug=True)
    except Exception as e:
        logger.error(f"应用启动失败: {str(e)}")
        logger.error(traceback.format_exc())
        # 即使失败也启动应用
        app.run(host='0.0.0.0', port=5001, debug=True)
