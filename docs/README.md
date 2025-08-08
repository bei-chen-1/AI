# DeepSeek 智能考试系统部署指南

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

  


