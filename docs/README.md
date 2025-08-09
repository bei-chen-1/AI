# DeepSeek-app-2.0 智能考试系统部署指南

## 系统要求
- CentOS 7.9
- Python 3.8+
- Node.js 16+
- MySQL 8.0

## 部署步骤
1. 运行初始化脚本：`./scripts/setup.sh`
2. 初始化数据库：`mysql -u root -p < scripts/init_db.sql`
3. 启动服务：`./scripts/start.sh`

## 访问地址
- 前端：http://服务器IP:3000
- 后端API：http://服务器IP:5001/api/subjects

## 项目网盘
- 主链接：https://www.123684.com/s/kPEvTd-0K7d3提取码:podL
- 备用链接：https://www.123912.com/s/kPEvTd-0K7d3提取码:podL
- 二维码：<img width="102" height="102" alt="edde2f79be024236e80c6cb3525a2c5" src="https://github.com/user-attachments/assets/593f7d51-d1a0-449d-9013-209e2b08be80" />

## 系统架构
- 前端：React
- 后端：Flask
- 数据库：MySQL
- 大模型：DeepSeek-R1:1.5B

## 项目目录
- /opt/deepseek-app-2.0
- ├── backend/      # Flask 后端服务
- ├── frontend/     # React 前端应用
- ├── scripts/      # 系统脚本
- ├── logs/         # 日志目录
- └── docs/         # 文档

## 详细目录
- /opt/deepseek-app-2.0
- ├── backend/
- │   ├── static				  # 后端静态文件
- │   │   ├──favicon.ico       # 后端图标
- │   ├── app.py                # 后端主应用（核心逻辑）
- │   ├── requirements.txt      # Python 依赖
- │   └── .env                  # 环境变量配置
- ├── frontend/
- │   ├── public/
- │   │   └── index.html        # HTML 入口
- │   │   └── favicon.ico       #图标
- │   ├── src/
- │   │   ├── App.js            # 主应用组件
- │   │   ├── App.css           # 全局样式
- │   │   ├── index.js          # React 入口
- │   │   └── components/
- │   │       └── ExamPanel.js  # 考试面板组件（核心UI）
- │   │       └── ExamPanel.css  # 考试面板样式
- │   ├── package.json          # 前端依赖
- │   └── .env                  # 前端环境变量
- │   └── .env.production       # 前端生产环境变量
- ├── scripts/
- │   ├── start.sh              # 启动脚本
- │   ├── stop.sh               # 停止脚本
- │   └── init_db.sql           # 数据库初始化脚本（核心数据）
- ├── logs/                     # 日志目录
- └── docs/
-     └── README.md             # 项目文档

## 核心文件
- 1.	后端核心:
- o	backend/app.py: 处理所有API请求（试卷生成、判卷）
- o	scripts/init_db.sql: 数据库结构和初始数据
- 2.	前端核心:
- o	frontend/src/components/ExamPanel.js: 考试界面组件
- o	frontend/src/App.js: 应用主入口
- 3.	系统脚本:
- o	scripts/start.sh: 启动所有服务
- o	scripts/stop.sh: 停止所有服务

## 项目架构
- React 前端(localhost:3000)——>Flask 后端 (localhost:5001)——> MySQL 数据库(knowledge_db)
- 用户浏览器(UI交互)——>React 前端(localhost:3000)
- OLLAMA 服务(DeepSeek模型)——>Flask 后端 (localhost:5001)

## 架构说明
- 1.	前端层: React应用提供用户界面
- 2.	API层: Flask处理业务逻辑和路由
- 3.	数据层: MySQL存储题目和答案
- 4.	AI层: OLLAMA服务提供DeepSeek模型
- 5.	脚本层: Shell脚本管理服务生命周期

## 关键功能流程
- 1、 试卷生成流程:
- (1)	用户选择学科
- (2)	前端调用/api/generate_exam
- (3)	后端按题型比例随机选题
- (4)	返回试卷结构
- 2、 智能判卷流程:
- (1)	用户提交答案
- (2)	前端调用/api/judge_exam
- (3)后端处理每道题:
- o	客观题: 直接比对答案
- o	主观题: 调用DeepSeek模型评分
- (4)计算总分并返回结果
- 3、 主观题评分流程:
- (1)	构造包含题目、答案、评分点的提示词
- (2)	调用DeepSeek模型获取评分
- (3)	解析模型返回的评分结果
- (4)	按比例计算实际得分

## 用户发起请求：选择学科 → 生成试卷
- 路径：用户浏览器 → 前端组件 → 后端API → 数据库 → 返回试卷
- <img width="765" height="331" alt="image" src="https://github.com/user-attachments/assets/91881fdd-e0b1-4712-af5d-2916152442d3" />

## 用户提交答案 → 判卷流程
- 路径：用户浏览器 → 前端组件 → 后端API → 数据库/AI模型 → 返回判卷结果
- <img width="763" height="497" alt="image" src="https://github.com/user-attachments/assets/97f6ef1d-6a45-4785-9d54-f3b6b4f5c9a0" />

## 流程图
- <img width="865" height="807" alt="image" src="https://github.com/user-attachments/assets/6412b13a-af13-4219-a5f6-822f48391a01" />

## 项目效果图
- 1、前端头部
- <img width="865" height="138" alt="image" src="https://github.com/user-attachments/assets/5187fa2b-5663-405b-8b10-da4de14adf63" />
- 2、前端欢迎
- <img width="865" height="502" alt="image" src="https://github.com/user-attachments/assets/729d7d05-4499-4409-9766-d00ad9cce7cd" />
- 3、前端尾部
- <img width="865" height="315" alt="image" src="https://github.com/user-attachments/assets/3f895239-1846-46af-a9bb-99bcbffd25b8" />
- 4、前端全貌
- <img width="865" height="956" alt="image" src="https://github.com/user-attachments/assets/5bfc1752-71bd-42ca-a628-a00484eadef2" />
- 5、试卷界面
- <img width="865" height="768" alt="image" src="https://github.com/user-attachments/assets/0e7de417-3bc4-42a1-b8f7-67620fc5cd6b" />
- 6、多选题界面
- <img width="865" height="755" alt="image" src="https://github.com/user-attachments/assets/40f458ac-31ce-4718-ae8d-1c280143d11e" />
- 7、判断题界面
- <img width="865" height="716" alt="image" src="https://github.com/user-attachments/assets/7e7c792b-b899-490b-b25a-e1d5a4c0c181" />
- 8、填空题和简答题界面
- <img width="865" height="446" alt="image" src="https://github.com/user-attachments/assets/9fb62009-6876-43f4-b248-b1818699f901" />
- 9、综合应用题界面
- <img width="865" height="597" alt="image" src="https://github.com/user-attachments/assets/b84bca76-bca9-4b20-a3c8-d615f72f0105" />
- 10、得分界面
- <img width="865" height="407" alt="image" src="https://github.com/user-attachments/assets/115b34a6-4b7c-4c1f-9931-49f3d447c118" />
- <img width="865" height="358" alt="image" src="https://github.com/user-attachments/assets/2fc090f0-316c-47a6-82de-dcf81ee73839" />
- 11、历史考试记录界面
- <img width="865" height="486" alt="image" src="https://github.com/user-attachments/assets/5b2e0943-c551-494a-9689-ae24614699b1" />
