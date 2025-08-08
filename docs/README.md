# DeepSeek-app-2.1 智能考试系统部署指南

## 系统要求
- CentOS 7.9
- Python 3.8+
- Node.js 16+
- MySQL 8.0

## 部署步骤
1. 搭建系统所需环境
2. 初始化数据库：`mysql -u root -p < scripts/init_db.sql`
3. 启动服务：`./scripts/start.sh`
4. 关闭服务：`./scripts/stop.sh`

## 访问地址
- 前端：http://服务器IP:3000
- 后端API：http://服务器IP:5001/api/subjects

## 系统架构
- 前端：React
- 后端：Flask
- 数据库：MySQL
- 大模型：DeepSeek-R1:1.5B

## 前端依赖
1. 目录：frontend
- 命令：`npm install sonner`
- 命令：`npm install lucide-react`
- 命令：`npm install tailwind-merge`


## 后端依赖
1. 目录：backend
- 命令1：`pip install -r requirements.txt`
- 命令2：`npm install react-svg`
- 命令3：`npm install gojs`

## 网络拓扑图绘制API
1. API接口地址：`POST /api/ai/generate-topology`
- 你可以通过调用后端API接口实现网络拓扑图的AI自动生成。
2. 请求参数：
- 字段：`description`           
- 类型：`string`
3. 示例请求体（JSON）：
   `json
   {
   "description": "最上方是防火墙，防火墙下方连接路由器，路由器下方连接交换机，交换机连接两个主机和一个无线AP"
   }
   `
4. 返回结果格式:
  `json
   {
   "devices": [
   {
   "id": "router_1",
   "label": "路由器_1",
   "type": "router",
   "position": { "x": 150, "y": 80 }
   },
   {
   "id": "switch_1",
   "label": "交换机_1",
   "type": "switch",
   "position": { "x": 150, "y": 200 }
   },
   {
   "id": "host_1",
   "label": "主机_1",
   "type": "host",
   "position": { "x": 100, "y": 350 }
   },
   {
   "id": "ap_1",
   "label": "无线AP_1",
   "type": "ap",
   "position": { "x": 220, "y": 350 }
   }
   ],
   "connections": [
   {
   "id": "conn_1",
   "source": "router_1",
   "target": "switch_1",
   "type": "ethernet"
   },
   {
   "id": "conn_2",
   "source": "switch_1",
   "target": "host_1",
   "type": "ethernet"
   },
   {
   "id": "conn_3",
   "source": "switch_1",
   "target": "ap_1",
   "type": "ethernet"
   }
   ]
   }
  `
5. 示例前端代码调用（fetch）
`
   async function fetchTopology(description) {
   const response = await fetch('http://localhost:5001/api/ai/generate-topology', {
   method: 'POST',
   headers: { 'Content-Type': 'application/json' },
   body: JSON.stringify({ description })
   });
   const data = await response.json();
   return data;
   }
`js
6. 用 Postman/cURL 测试
`
   curl -X POST http://localhost:5001/api/ai/generate-topology \
   -H "Content-Type: application/json" \
   -d '{"description": "一个防火墙连接一个路由器，路由器连接三个主机"}'

`
## 项目目录
- /opt/deepseek-app-2.1
- ├── backend/       # Flask后端服务
- ├── frontend/      # React前端应用
- ├── scripts/       # 系统脚本
- ├── logs/          # 日志目录
- └── docs/          # 文档

## 详细目录
- /opt/deepseek-app-2.1
- ├── backend/
- │   ├── static/                  # 静态文件
- │   │   └── favicon.ico          # 网站图标
- │   ├── app.py                   # 主应用（试卷生成/判卷/路由）
- │   ├── requirements.txt         # Python依赖
- │   ├── .env                     # 环境变量配置
- │   ├── ai_router.py             # AI对话和拓扑图API
- │   └── topology_generator.py    # 拓扑图生成逻辑
- ├── frontend/
- │   ├── public/                  # 公共资源
- │   │   ├── index.html           # HTML入口
- │   │   └── favicon.ico          # 图标
- │   ├── src/
- │   │   ├── App.js               # 主应用组件
- │   │   ├── App.css              # 全局样式
- │   │   ├── index.js             # React入口
- │   │   ├── pages/               # 页面组件
- │   │   │   ├── AIChatPage.js        # AI聊天页
- │   │   │   └── TopologyEditorPage.js # 拓扑图编辑页
- │   │   ├── styles/              # 页面样式
- │   │   │   ├── AIChatPage.css       # AI聊天样式
- │   │   │   └── TopologyEditorPage.css # 拓扑图样式
- │   │   ├── components/          # 可复用组件
- │   │   │   ├── ExamPanel.js         # 考试面板
- │   │   │   ├── ExamPanel.css         # 考试面板样式
- │   │   │   ├── TopologyEditor.js    # 拓扑编辑器
- │   │   │   ├── TopologyEditor.css    # 拓扑编辑器样式
- │   │   │   └── GoJSTopology.js      # GoJS拓扑组件
- │   │   │   └── GoJSTopology.css      # GoJS拓扑组件样式
- │   │   └── utils/
- │   │       └── topologyElements.js  # 拓扑元素配置
- │   ├── package.json             # 前端依赖
- │   ├── .env                     # 开发环境变量
- │   └── .env.production          # 生产环境变量
- ├── scripts/
- │   ├── start.sh                 # 启动脚本
- │   ├── stop.sh                  # 停止脚本
- │   └── init_db.sql              # 数据库初始化脚本
- ├── logs/                        # 日志文件
- └── docs/
-     └── README.md                # 项目文档

## 核心文件
- 1.	后端核心:
- o	backend/app.py: 处理所有API请求（试卷生成、判卷）
- o	scripts/init_db.sql: 数据库结构和初始数据
- o	app.py：主逻辑（试卷生成/判卷/路由）
- o	ai_router.py：AI对话和拓扑图API
- o	topology_generator.py：拓扑图生成逻辑
- o	init_db.sql：数据库初始化
- 2.	前端核心:
- o	frontend/src/components/ExamPanel.js: 考试界面组件
- o	frontend/src/App.js: 应用主入口
- o	AIChatPage.js：AI聊天界面
- o	TopologyEditorPage.js：拓扑图编辑器
- o	GoJSTopology.js：GoJS拓扑渲染组件
- 3.	系统脚本:
- o	scripts/start.sh: 启动所有服务
- o	scripts/stop.sh: 停止所有服务

## 项目架构
- <img width="865" height="500" alt="image" src="https://github.com/user-attachments/assets/b647ed34-7bde-4403-a12e-41351272c3d2" />

## 架构说明
- 1.	前端层: React + GoJS + TailwindCSS
- 2.	API层: Flask处理业务逻辑和路由
- 3.	数据层: MySQL存储题目和答案
- 4.	AI层: OLLAMA服务提供DeepSeek模型
- 5.	脚本层: Shell脚本管理服务生命周期

## 关键功能流程
- 试卷生成流程:
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
- <img width="764" height="330" alt="image" src="https://github.com/user-attachments/assets/a488079a-3f83-4cea-9558-ecc33ddc06c0" />

## 用户提交答案 → 判卷流程
- 路径：用户浏览器 → 前端组件 → 后端API → 数据库/AI模型 → 返回判卷结果
- <img width="765" height="194" alt="image" src="https://github.com/user-attachments/assets/329e42f5-220f-41c4-852b-5ab75a3e1176" />
- <img width="767" height="308" alt="image" src="https://github.com/user-attachments/assets/746bc763-04ef-4ea3-8285-bc9842d28271" />

## 流程图
- 1、自动组卷判卷
- <img width="865" height="807" alt="image" src="https://github.com/user-attachments/assets/36a10057-f9e9-48ce-ae54-e890721a880f" />
- 2、AI对话生成拓扑图
- <img width="865" height="315" alt="image" src="https://github.com/user-attachments/assets/23bdc3fc-14ea-40ad-9a35-59141940fa2b" />
- <img width="865" height="416" alt="image" src="https://github.com/user-attachments/assets/71dc5ab6-41d1-4045-aa56-59a1a1a3a96e" />

## 详细数据流（精确到文件级）
- 	阶段1：用户发起请求 (浏览器 → 前端)
- 1.	用户操作：
- o	在聊天界面(frontend/src/pages/AIChatPage.js)输入消息
- o	或在拓扑界面(frontend/src/pages/TopologyEditorPage.js)输入描述
- 2.	前端处理：
- o	AIChatPage.js 中 handleSendMessage() 处理聊天请求
- o	TopologyEditorPage.js 中 handleGenerate() 处理拓扑请求
- o	构建请求体，包含用户输入和历史上下文
- 	阶段2：前端调用API (前端 → 后端)
- 3.	API调用：
- // AIChatPage.js
- fetch(`${API_BASE}/api/ai/chat`, {
-   method: 'POST',
-   body: JSON.stringify({ message: input, history })
- });
- // TopologyEditorPage.js
- fetch(`${API_BASE}/api/ai/generate-topology`, {
-   method: 'POST',
-   body: JSON.stringify({ description })
- });
- 	阶段3：后端处理请求 (后端 → AI服务)
- 4.	路由分发：
- o	请求到达 backend/app.py 主应用
- o	路由到 backend/ai_router.py (蓝图注册的路由)
- 5.	AI处理：
- o	聊天请求(/api/ai/chat):
- # ai_router.py
- response = ollama.generate(model='deepseek-r1:1.5b', prompt=full_prompt)
- o	拓扑请求(/api/ai/generate-topology):
- # ai_router.py
- topology_data = generate_topology(description)  # 调用topology_generator.py
- 6.	拓扑生成 (backend/topology_generator.py):
- o	构造AI提示词：要求返回JSON格式的拓扑数据
- o	解析AI响应，提取设备和连接关系
- o	返回结构化拓扑数据：
- {
-   "devices": [
-     {"id": "r1", "type": "router", "label": "核心路由器", "position": {"x": 100, "y": 100}},
-     {"id": "s1", "type": "switch", "label": "接入交换机", "position": {"x": 300, "y": 200}}
-   ],
-   "connections": [
-     {"source": "r1", "target": "s1", "type": "ethernet"}
-   ]
- }
- 	阶段4：响应返回 (后端 → 前端)
- 7.	数据返回：
- o	聊天响应：
- {
-   "response": "网络拓扑建议...",
-   "topology_data": {...}  // 当检测到拓扑关键词时
- }
- o	拓扑响应：直接返回拓扑数据结构
- 	阶段5：前端渲染 (前端 → GoJS)
- 8.	数据处理：
- o	TopologyEditorPage.js 接收拓扑数据，更新状态：
- setTopologyData(result);
- 9.	GoJS渲染 (frontend/src/components/GoJSTopology.js):
- o	在 useEffect 钩子中处理拓扑数据变化：
- useEffect(() => {
-   if (topologyData) {
-     // 转换数据为GoJS模型
-     model.nodeDataArray = topologyData.devices.map(...);
-     model.linkDataArray = topologyData.connections.map(...);
-     diagram.model = model;
-   }
- }, [topologyData]);
- o	使用GoJS API渲染交互式拓扑图
- 	阶段6：用户交互 (GoJS → 浏览器)
- 10.	最终展示：
- o	GoJS在 <div className="gojs-diagram"> 中渲染SVG图形
- o	支持用户拖拽设备、查看连接关系
- o	可通过导出按钮保存为PNG/JSON

## 	关键文件交互图
- <img width="859" height="1253" alt="image" src="https://github.com/user-attachments/assets/d5307447-ba9c-419d-865e-fc0cf850e90c" />

## 项目效果图
- 1、前端头部
- <img width="865" height="138" alt="image" src="https://github.com/user-attachments/assets/b7764960-da03-4e08-8003-847900a5703f" />
- 2、前端欢迎
- <img width="865" height="502" alt="image" src="https://github.com/user-attachments/assets/48eb90f1-3159-45f5-ac13-10aa16ff3327" />
- 3、前端尾部
- <img width="865" height="321" alt="image" src="https://github.com/user-attachments/assets/e4893f6a-e388-4ae2-b791-b4a523500ce7" />
- 4、前端全貌
- <img width="865" height="980" alt="image" src="https://github.com/user-attachments/assets/935b1376-7347-4ae4-aa2c-547757fd1ab3" />
- 5、试卷界面
- <img width="865" height="768" alt="image" src="https://github.com/user-attachments/assets/46a05a32-90c8-42cb-81a1-ea7166e6886e" />
- 6、多选题界面
- <img width="865" height="755" alt="image" src="https://github.com/user-attachments/assets/71d02c87-48db-4e4b-bba4-7ccd695c2327" />
- 7、判断题界面
- <img width="865" height="716" alt="image" src="https://github.com/user-attachments/assets/b34c2454-323b-42cd-ad34-39d8b495c1aa" />
- 8、填空题和简答题界面
- <img width="865" height="446" alt="image" src="https://github.com/user-attachments/assets/1e67a0cd-a771-475c-b4f6-6e55fb216157" />
- 9、综合应用题界面
- <img width="865" height="597" alt="image" src="https://github.com/user-attachments/assets/43cba725-4dfc-4521-9d3b-d84be35b37ec" />
- 10、得分界面
- <img width="865" height="407" alt="image" src="https://github.com/user-attachments/assets/4ae03f35-f3b2-4ca9-bc20-acb445d2b8c1" />
- <img width="865" height="358" alt="image" src="https://github.com/user-attachments/assets/73848102-8eb8-43e2-b410-14fb2975e148" />
- 11、历史考试记录界面
- <img width="865" height="486" alt="image" src="https://github.com/user-attachments/assets/33ac5323-5023-4787-ad1a-3c4217c534f6" />
- 12、AI对话页面
- <img width="865" height="518" alt="image" src="https://github.com/user-attachments/assets/2060f1b1-4193-461b-a893-5fb9943edf98" />
- <img width="865" height="521" alt="image" src="https://github.com/user-attachments/assets/4ac25378-bf19-4bf0-b6b9-597274198300" />
- 13、AI绘制拓扑图界面
- <img width="865" height="510" alt="image" src="https://github.com/user-attachments/assets/e112edcc-5b52-48c5-b589-42aad7916406" />
- <img width="865" height="503" alt="image" src="https://github.com/user-attachments/assets/dd8a12c2-43cb-478f-976e-e8360c4477da" />
- 左侧边栏：
- （1）当鼠标变成小手形状，可以拖动边栏网络设备到右侧网格中
- （2）点击网络设备或连接线，按dalete键删除
- <img width="865" height="507" alt="image" src="https://github.com/user-attachments/assets/a4c45d9e-1ebd-4444-8f9a-73f3b39eafa3" />
- <img width="865" height="508" alt="image" src="https://github.com/user-attachments/assets/36e92cc9-a5b6-4a78-b589-fa495f717043" />

