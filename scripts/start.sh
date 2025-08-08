#!/bin/bash

# 启动Ollama服务
sudo systemctl start ollama
sudo systemctl enable ollama

# 等待Ollama启动
sleep 5

# 启动mysql服务
sudo systemctl start mysqld
sudo systemctl enable mysqld

# 等待mysql启动
sleep 5

# 启动Flask应用
cd /opt/deepseek-app/backend
nohup gunicorn -w 4 -b 0.0.0.0:5001 app:app > ../logs/backend.log 2>&1 &

# 启动前端服务
cd /opt/deepseek-app/frontend
nohup serve -s build -l 3000 > ../logs/frontend.log 2>&1 &

echo "DeepSeek应用已启动！"
echo "后端服务: http://localhost:5001"
echo "前端服务: http://localhost:3000"