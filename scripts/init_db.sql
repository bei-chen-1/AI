CREATE DATABASE IF NOT EXISTS knowledge_db;
USE knowledge_db;

-- 创建学科表
CREATE TABLE subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);

-- 创建题目表
CREATE TABLE questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subject_id INT NOT NULL,
    question TEXT NOT NULL,
    difficulty ENUM('easy', 'medium', 'hard') DEFAULT 'medium',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(id)
);

-- 创建答案表
CREATE TABLE answers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT NOT NULL,
    answer TEXT NOT NULL,
    explanation TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

-- 插入示例学科
INSERT INTO subjects (name, description) VALUES 
('数学', '涵盖代数、几何、微积分等数学问题'),
('物理', '力学、电磁学、热力学等物理学问题'),
('化学', '无机化学、有机化学、物理化学问题'),
('生物', '细胞生物学、遗传学、生态学问题');

-- 插入示例题目
INSERT INTO questions (subject_id, question, difficulty) VALUES 
(1, '解一元二次方程: x² - 5x + 6 = 0', 'easy'),
(1, '计算定积分: ∫(0 to π) sin(x) dx', 'medium'),
(2, '牛顿第二定律的公式是什么？', 'easy'),
(2, '一个质量为2kg的物体在10N的力作用下，加速度是多少？', 'medium'),
(3, '水的分子式是什么？', 'easy'),
(3, '写出盐酸(HCl)和氢氧化钠(NaOH)的中和反应方程式', 'medium'),
(4, '光合作用的化学方程式是什么？', 'medium'),
(4, 'DNA的双螺旋结构是由谁发现的？', 'hard');

-- 插入答案
INSERT INTO answers (question_id, answer, explanation) VALUES 
(1, 'x=2 或 x=3', '因式分解得 (x-2)(x-3)=0'),
(2, '2', '∫sin(x) dx = -cos(x), 从0到π: [-cos(π)] - [-cos(0)] = [1] - [-1] = 2'),
(3, 'F=ma', 'F代表力，m代表质量，a代表加速度'),
(4, '5 m/s²', '根据牛顿第二定律 F=ma, a=F/m=10N/2kg=5m/s²'),
(5, 'H₂O', '水分子由两个氢原子和一个氧原子组成'),
(6, 'HCl + NaOH → NaCl + H₂O', '酸和碱反应生成盐和水'),
(7, '6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂', '二氧化碳和水在光照下转化为葡萄糖和氧气'),
(8, '沃森和克里克', '1953年，詹姆斯·沃森和弗朗西斯·克里克提出了DNA双螺旋结构模型');

-- 创建应用用户
CREATE USER 'deepseek_app'@'localhost' IDENTIFIED BY 'AppPassword123!';
GRANT ALL PRIVILEGES ON knowledge_db.* TO 'deepseek_app'@'localhost';
FLUSH PRIVILEGES;
