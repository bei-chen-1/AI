# /opt/deepseek-app/backend/database.py
"""
数据库操作模块
包含所有与 MySQL 数据库交互的核心功能
"""

import mysql.connector
from mysql.connector import Error
import logging
import traceback
from typing import List, Dict, Optional

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 数据库配置
DB_CONFIG = {
    'host': 'localhost',
    'user': 'deepseek_app',
    'password': 'AppPassword123!',
    'database': 'knowledge_db',
    'raise_on_warnings': True,
    'pool_name': 'deepseek_pool',
    'pool_size': 5
}

class DatabaseManager:
    """数据库管理类，封装所有数据库操作"""

    def __init__(self, config=None):
        self.config = config or DB_CONFIG
        self.connection_pool = None
        self.create_connection_pool()

    def create_connection_pool(self):
        """创建数据库连接池"""
        try:
            self.connection_pool = mysql.connector.pooling.MySQLConnectionPool(
                pool_name=self.config['pool_name'],
                pool_size=self.config['pool_size'],
                **{k: v for k, v in self.config.items() if k not in ['pool_name', 'pool_size']}
            )
            logger.info("数据库连接池创建成功")
        except Error as e:
            logger.error(f"创建数据库连接池失败: {str(e)}")
            logger.error(traceback.format_exc())
            self.connection_pool = None

    def get_connection(self):
        """从连接池获取数据库连接"""
        if not self.connection_pool:
            self.create_connection_pool()

        try:
            conn = self.connection_pool.get_connection()
            logger.debug("成功获取数据库连接")
            return conn
        except Error as e:
            logger.error(f"获取数据库连接失败: {str(e)}")
            logger.error(traceback.format_exc())
            return None

    def execute_query(self, query: str, params: tuple = None, fetch_all: bool = True):
        """执行查询操作

        Args:
            query: SQL 查询语句
            params: 查询参数
            fetch_all: 是否获取所有结果

        Returns:
            查询结果列表（字典形式）或 None（出错时）
        """
        conn = None
        cursor = None
        try:
            conn = self.get_connection()
            if not conn:
                return None

            cursor = conn.cursor(dictionary=True)

            logger.debug(f"执行查询: {query} | 参数: {params}")
            cursor.execute(query, params or ())

            if fetch_all:
                result = cursor.fetchall()
            else:
                result = cursor.fetchone()

            logger.debug(f"查询结果: {result}")
            return result
        except Error as e:
            logger.error(f"查询执行失败: {str(e)}")
            logger.error(f"SQL: {query}")
            logger.error(f"参数: {params}")
            logger.error(traceback.format_exc())
            return None
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def execute_command(self, query: str, params: tuple = None):
        """执行写操作（INSERT/UPDATE/DELETE）

        Args:
            query: SQL 命令
            params: 命令参数

        Returns:
            受影响的行数，或 -1（出错时）
        """
        conn = None
        cursor = None
        try:
            conn = self.get_connection()
            if not conn:
                return -1

            cursor = conn.cursor()

            logger.debug(f"执行命令: {query} | 参数: {params}")
            cursor.execute(query, params or ())
            affected_rows = cursor.rowcount

            conn.commit()
            logger.debug(f"命令执行成功，受影响行数: {affected_rows}")
            return affected_rows
        except Error as e:
            logger.error(f"命令执行失败: {str(e)}")
            logger.error(f"SQL: {query}")
            logger.error(f"参数: {params}")
            logger.error(traceback.format_exc())
            if conn:
                conn.rollback()
            return -1
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def batch_execute(self, query: str, params_list: list):
        """批量执行SQL命令

        Args:
            query: SQL 命令模板
            params_list: 参数列表

        Returns:
            总受影响行数，或 -1（出错时）
        """
        conn = None
        cursor = None
        try:
            conn = self.get_connection()
            if not conn:
                return -1

            cursor = conn.cursor()
            total_rows = 0

            logger.debug(f"批量执行: {query} | 共 {len(params_list)} 组参数")
            for params in params_list:
                cursor.execute(query, params)
                total_rows += cursor.rowcount

            conn.commit()
            logger.debug(f"批量执行成功，总受影响行数: {total_rows}")
            return total_rows
        except Error as e:
            logger.error(f"批量执行失败: {str(e)}")
            logger.error(f"SQL: {query}")
            logger.error(traceback.format_exc())
            if conn:
                conn.rollback()
            return -1
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    # ===== 学科相关操作 =====
    def get_all_subjects(self) -> List[Dict]:
        """获取所有学科"""
        query = "SELECT id, name, description FROM subjects"
        return self.execute_query(query)

    def get_subject_by_id(self, subject_id: int) -> Optional[Dict]:
        """通过ID获取学科"""
        query = "SELECT id, name, description FROM subjects WHERE id = %s"
        return self.execute_query(query, (subject_id,), fetch_all=False)

    def get_subject_by_name(self, name: str) -> Optional[Dict]:
        """通过名称获取学科"""
        query = "SELECT id, name, description FROM subjects WHERE name = %s"
        return self.execute_query(query, (name,), fetch_all=False)

    def add_subject(self, name: str, description: str = "") -> int:
        """添加新学科"""
        query = "INSERT INTO subjects (name, description) VALUES (%s, %s)"
        result = self.execute_command(query, (name, description))
        return result

    # ===== 题目相关操作 =====
    def get_question_by_id(self, question_id: int) -> Optional[Dict]:
        """通过ID获取题目"""
        query = """
        SELECT q.id, q.subject_id, q.question, q.difficulty, q.created_at,
               s.name AS subject_name
        FROM questions q
        JOIN subjects s ON q.subject_id = s.id
        WHERE q.id = %s
        """
        return self.execute_query(query, (question_id,), fetch_all=False)

    def get_random_question_by_subject(self, subject_id: int) -> Optional[Dict]:
        """随机获取指定学科的题目"""
        query = """
        SELECT id, question
        FROM questions
        WHERE subject_id = %s
        ORDER BY RAND()
        LIMIT 1
        """
        return self.execute_query(query, (subject_id,), fetch_all=False)

    def add_question(self, subject_id: int, question: str, difficulty: str = "medium") -> int:
        """添加新题目"""
        query = """
        INSERT INTO questions (subject_id, question, difficulty)
        VALUES (%s, %s, %s)
        """
        return self.execute_command(query, (subject_id, question, difficulty))

    # ===== 答案相关操作 =====
    def get_answer_by_question_id(self, question_id: int) -> Optional[Dict]:
        """通过题目ID获取答案"""
        query = """
        SELECT a.id, a.answer, a.explanation, a.created_at
        FROM answers a
        WHERE a.question_id = %s
        """
        return self.execute_query(query, (question_id,), fetch_all=False)

    def add_answer(self, question_id: int, answer: str, explanation: str = "") -> int:
        """添加答案"""
        query = """
        INSERT INTO answers (question_id, answer, explanation)
        VALUES (%s, %s, %s)
        """
        return self.execute_command(query, (question_id, answer, explanation))

    # ===== 知识库统计 =====
    def get_statistics(self) -> Dict:
        """获取知识库统计信息"""
        stats = {}

        # 学科数量
        subject_query = "SELECT COUNT(*) AS count FROM subjects"
        subject_result = self.execute_query(subject_query, fetch_all=False)
        stats['subjects'] = subject_result['count'] if subject_result else 0

        # 题目数量
        question_query = "SELECT COUNT(*) AS count FROM questions"
        question_result = self.execute_query(question_query, fetch_all=False)
        stats['questions'] = question_result['count'] if question_result else 0

        # 答案数量
        answer_query = "SELECT COUNT(*) AS count FROM answers"
        answer_result = self.execute_query(answer_query, fetch_all=False)
        stats['answers'] = answer_result['count'] if answer_result else 0

        # 按学科统计题目数量
        subject_question_query = """
        SELECT s.name, COUNT(q.id) AS question_count
        FROM subjects s
        LEFT JOIN questions q ON s.id = q.subject_id
        GROUP BY s.id
        """
        subject_question_result = self.execute_query(subject_question_query)
        stats['questions_by_subject'] = subject_question_result or []

        return stats

    # ===== 初始化数据库 =====
    def initialize_database(self, sql_file: str = None) -> bool:
        """初始化数据库结构

        Args:
            sql_file: SQL初始化文件路径

        Returns:
            是否初始化成功
        """
        # 如果没有提供SQL文件，使用默认的初始化SQL
        if not sql_file:
            return self.execute_default_initialization()

        try:
            with open(sql_file, 'r') as file:
                sql_commands = file.read().split(';')

            conn = self.get_connection()
            if not conn:
                return False

            cursor = conn.cursor()

            for command in sql_commands:
                if command.strip():
                    logger.debug(f"执行初始化命令: {command.strip()}")
                    cursor.execute(command)

            conn.commit()
            logger.info("数据库初始化成功")
            return True
        except Error as e:
            logger.error(f"数据库初始化失败: {str(e)}")
            logger.error(traceback.format_exc())
            return False
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def execute_default_initialization(self) -> bool:
        """执行默认的数据库初始化"""
        try:
            conn = self.get_connection()
            if not conn:
                return False

            cursor = conn.cursor()

            # 创建学科表
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS subjects (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(50) NOT NULL,
                description TEXT
            )
            """)

            # 创建题目表
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS questions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                subject_id INT NOT NULL,
                question TEXT NOT NULL,
                difficulty ENUM('easy', 'medium', 'hard') DEFAULT 'medium',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (subject_id) REFERENCES subjects(id)
            )
            """)

            # 创建答案表
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS answers (
                id INT AUTO_INCREMENT PRIMARY KEY,
                question_id INT NOT NULL,
                answer TEXT NOT NULL,
                explanation TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (question_id) REFERENCES questions(id)
            )
            """)

            # 插入示例数据
            # 检查学科表是否为空
            cursor.execute("SELECT COUNT(*) FROM subjects")
            if cursor.fetchone()[0] == 0:
                # 插入学科
                subjects = [
                    ('数学', '涵盖代数、几何、微积分等数学问题'),
                    ('物理', '力学、电磁学、热力学等物理学问题'),
                    ('化学', '无机化学、有机化学、物理化学问题'),
                    ('生物', '细胞生物学、遗传学、生态学问题')
                ]
                cursor.executemany(
                    "INSERT INTO subjects (name, description) VALUES (%s, %s)",
                    subjects
                )

                # 插入题目和答案
                questions_answers = [
                    (1, '解一元二次方程: x² - 5x + 6 = 0', 'x=2 或 x=3', '因式分解得 (x-2)(x-3)=0'),
                    (2, '牛顿第二定律的公式是什么？', 'F=ma', 'F代表力，m代表质量，a代表加速度'),
                    (3, '水的分子式是什么？', 'H₂O', '水分子由两个氢原子和一个氧原子组成'),
                    (4, '光合作用的化学方程式是什么？', '6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂', '二氧化碳和水在光照下转化为葡萄糖和氧气')
                ]

                for subject_id, question, answer, explanation in questions_answers:
                    cursor.execute(
                        "INSERT INTO questions (subject_id, question) VALUES (%s, %s)",
                        (subject_id, question)
                    )
                    question_id = cursor.lastrowid
                    cursor.execute(
                        "INSERT INTO answers (question_id, answer, explanation) VALUES (%s, %s, %s)",
                        (question_id, answer, explanation)
                    )

            conn.commit()
            logger.info("数据库默认初始化成功")
            return True
        except Error as e:
            logger.error(f"数据库默认初始化失败: {str(e)}")
            logger.error(traceback.format_exc())
            return False
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

# 全局数据库管理器实例
db_manager = DatabaseManager()

# ===== 测试代码 =====
if __name__ == '__main__':
    # 配置详细日志
    logging.basicConfig(level=logging.DEBUG)

    # 测试数据库连接
    print("===== 测试数据库连接 =====")
    conn = db_manager.get_connection()
    print("连接状态:", "成功" if conn else "失败")
    if conn:
        conn.close()

    # 测试初始化数据库
    print("\n===== 测试数据库初始化 =====")
    success = db_manager.initialize_database()
    print("初始化结果:", "成功" if success else "失败")

    # 测试获取学科
    print("\n===== 测试获取学科 =====")
    subjects = db_manager.get_all_subjects()
    print("学科列表:")
    for subject in subjects:
        print(f"ID: {subject['id']}, 名称: {subject['name']}, 描述: {subject['description']}")

    # 测试添加题目
    print("\n===== 测试添加题目 =====")
    subject_id = 1  # 数学
    question = "计算圆的面积公式是什么？"
    result = db_manager.add_question(subject_id, question)
    print(f"添加题目结果: 影响行数={result}")

    # 测试获取随机题目
    print("\n===== 测试获取随机题目 =====")
    random_question = db_manager.get_random_question_by_subject(subject_id)
    print("随机题目:", random_question)

    # 测试添加答案
    if random_question:
        print("\n===== 测试添加答案 =====")
        question_id = random_question['id']
        answer = "S = πr²"
        explanation = "S 表示面积，r 表示半径，π 是圆周率"
        result = db_manager.add_answer(question_id, answer, explanation)
        print(f"添加答案结果: 影响行数={result}")

    # 测试获取答案
    if random_question:
        print("\n===== 测试获取答案 =====")
        answer = db_manager.get_answer_by_question_id(question_id)
        print("题目答案:", answer)

    # 测试统计信息
    print("\n===== 测试统计信息 =====")
    stats = db_manager.get_statistics()
    print("知识库统计:")
    print(f"学科数量: {stats['subjects']}")
    print(f"题目数量: {stats['questions']}")
    print(f"答案数量: {stats['answers']}")
    print("\n按学科题目统计:")
    for item in stats['questions_by_subject']:
        print(f"{item['name']}: {item['question_count']}题")