#!/bin/bash

# DeepSeek 应用停止脚本

echo "停止前端服务..."
# 查找并停止前端服务（使用 serve 运行）
pkill -f "serve -s build -l 3000"
sleep 2  # 等待进程结束

echo "停止后端服务..."
# 查找并停止 Gunicorn 进程
pkill -f "gunicorn -w 4 -b 0.0.0.0:5001 app:app"
sleep 3  # 等待进程结束

echo "停止MySQL服务..."
sudo systemctl stop mysqld

echo "停止Ollama服务..."
sudo systemctl stop ollama

echo "清理残留进程..."
# 确保所有相关进程都已停止
pkill -f "node.*react"
pkill -f "gunicorn"
pkill -f "flask"

echo "验证服务状态..."
echo -e "\n服务状态检查:"
echo "Ollama: $(sudo systemctl is-active ollama)"
echo "MySQL: $(sudo systemctl is-active mysqld)"
echo "后端: $(pgrep -f 'gunicorn' >/dev/null && echo '运行中' || echo '已停止')"
echo "前端: $(pgrep -f 'serve -s build' >/dev/null && echo '运行中' || echo '已停止')"

echo -e "\nDeepSeek应用已完全停止！"