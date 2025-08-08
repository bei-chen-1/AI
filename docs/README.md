# DeepSeek 学习助手部署指南

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

## 系统架构
- 前端：React
- 后端：Flask
- 数据库：MySQL
- 大模型：DeepSeek-R1:1.5B

- <img width="865" height="982" alt="image" src="https://github.com/user-attachments/assets/a89485e8-a4b1-458b-a45c-bc1a59bd3cfc" />
