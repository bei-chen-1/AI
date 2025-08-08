from flask import Blueprint, request, jsonify
import ollama
import logging
import json
import re
import os
from topology_generator import generate_topology

ai_bp = Blueprint('ai', __name__, url_prefix='/api/ai')
logger = logging.getLogger(__name__)

@ai_bp.route('/chat', methods=['POST'])
def ai_chat():
    try:
        data = request.json
        user_message = data.get('message', '')
        conversation_history = data.get('history', [])

        full_prompt = ""
        for msg in conversation_history:
            full_prompt += f"{msg['role']}: {msg['content']}\n"
        full_prompt += f"user: {user_message}\nassistant:"

        logger.info(f"发送给AI的完整提示: {full_prompt}")

        response = ollama.generate(
            model='deepseek-r1:1.5b',
            prompt=full_prompt,
            stream=False
        )

        ai_response = response['response'].strip()
        logger.info(f"AI响应: {ai_response}")

        topology_data = None
        if "拓扑图" in user_message or "网络图" in user_message:
            logger.info("检测到拓扑图请求，生成拓扑数据")
            topology_data = generate_topology(ai_response)

        return jsonify({
            'response': ai_response,
            'topology_data': topology_data
        })

    except Exception as e:
        logger.error(f"AI聊天失败: {str(e)}", exc_info=True)
        return jsonify({"error": f"AI聊天失败: {str(e)}"}), 500

@ai_bp.route('/generate-topology', methods=['POST'])
def generate_topology_api():
    try:
        data = request.json
        description = data.get('description', '')
        logger.info(f"收到拓扑图生成请求: {description}")

        topology_data = generate_topology(description)
        logger.info(f"生成的拓扑数据: {json.dumps(topology_data, indent=2)}")

        return jsonify(topology_data)

    except Exception as e:
        logger.error(f"拓扑图生成失败: {str(e)}", exc_info=True)
        return jsonify({"error": f"拓扑图生成失败: {str(e)}"}), 500
