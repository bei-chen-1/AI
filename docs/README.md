# DeepSeek-app-1.0 学习助手部署指南

## 系统要求
- CentOS 7.9
- Python 3.8+
- Node.js 16+
- MySQL 8.0

## 部署步骤
- 1. 运行初始化脚本：`./scripts/setup.sh`
- 2. 初始化数据库：`mysql -u root -p < scripts/init_db.sql`
- 3. 启动服务：`./scripts/start.sh`

## 访问地址
- 前端：http://服务器IP:3000
- 后端API：http://服务器IP:5001/api/subjects

## 系统架构
- 前端：React
- 后端：Flask
- 数据库：MySQL
- 大模型：DeepSeek-R1:1.5B

## 项目目录
- /opt/deepseek-app-1.0
- ├── backend/      # Flask 后端
- ├── docs/         # 文档
- ├── frontend/     # React 前端
- ├── scripts/      # 系统脚本
- ├── logs/         # 日志目录

## 详细目录
- /opt/deepseek-app-1.0
- ├── backend/                   # Flask 后端服务
- │   ├── app.py                # 后端主应用（Flask）
- │   └── requirements.txt      # Python 依赖列表
- │   └── database.py           # 数据库操作
- ├── frontend/                  # React 前端应用
- │   ├── public/               # 公共资源目录
- │   │   └── index.html       # HTML 入口文件
- │   ├── src/                  # 源代码目录
- │   │   ├── App.js           # 主应用组件
- │   │   ├── App.css          # 主样式文件
- │   │   └── index.js         # React 入口文件
- │   │   └── components/
- │   │    └── HistoryPanel.js #历史记录面板文件
- │   └── package.json          # Node.js 项目配置
- │   └── package-lock.json     # Node.js 项目配置
- ├── scripts/                   # 系统脚本
- │   ├── start.sh              # 服务启动脚本
- │   ├── stop.sh              # 服务关闭脚本
- │   └── init_db.sql           # 数据库初始化脚本
- ├── logs/                      # 日志目录（运行时自动生成）
- └── docs/                      # 文档目录
-     └── README.md              # 项目说明文档

## 核心文件
- 后端主文件	/opt/deepseek-app/backend/app.py	Flask应用入口，包含API路由
- 前端入口	/opt/deepseek-app/frontend/src/App.js	React应用主组件
- 组件目录	/opt/deepseek-app/frontend/src/components/	包含所有React组件
- 启动脚本	/opt/deepseek-app/scripts/start.sh	应用启动脚本
- 构建目录	/opt/deepseek-app/frontend/build/	前端构建输出目录

## 项目架构
- 用户浏览器
-     ↓
- HTTP 请求 (端口:5001)
-     ↓
- Flask 后端 (app.py)
- ├─ 静态文件服务 → 前端构建 (frontend/build)
- ├─ API 路由:
- │   ├─ /api/subjects → 获取学科列表
- │   ├─ /api/generate → 生成题目
- │   └─ /api/judge → 判题
-     ↓
- 后端服务
- ├─ 数据库操作 → MySQL (knowledge_db)
- └─ 模型调用   → Ollama (DeepSeek-R1:1.5B)

## 关键功能流程
- 1.	学科加载：
- o	前端请求 /api/subjects
- o	后端从 MySQL 获取学科数据
- o	返回学科列表给前端
- 2.	题目生成：
- o	用户选择学科并点击"生成新题目"
- o	前端发送 POST 到 /api/generate
- o	后端从知识库随机选题或调用模型生成
- o	返回题目内容
- 3.	判题：
- o	用户输入答案并提交
- o	前端发送题目和答案到 /api/judge
- o	后端从知识库获取正确答案或调用模型判题
- o	返回批改结果

## 流程图
- <img width="865" height="982" alt="image" src="https://github.com/user-attachments/assets/a89485e8-a4b1-458b-a45c-bc1a59bd3cfc" />
- Web 前端(React) ——> Flask 后端(Python) ——> Ollama 模型(DeepSeek)
- MySQL 知识库(题目/答案) <——> Flask 后端(Python)

## 完整数据流路径（用户请求 → 判题结果）
- （1）用户发起请求
-   用户操作：在浏览器界面输入问题/题目
-   触发文件：frontend/src/App.js（主应用组件）
- （2）API请求转发（后端入口）
-   接收文件：backend/app.py（Flask主应用）
- （3）数据库操作（z知识库交互）
-   执行文件：backend/database.py
- （4）模型服务调用（ollama集成）
-   调用ollama模型，出题
- (5)用户提交答案(判题开始)
-   前端文件：frontend/src/components/HistoryPanel.js
- (6)判题处理（后端逻辑）
-   执行文件：backend/app.py
- (7)结果返回与展示
-   前端文件：frontend/src/App.js
