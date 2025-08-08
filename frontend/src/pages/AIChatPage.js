import React, { useState, useRef, useEffect } from 'react';
import { Link } from 'react-router-dom';
import '../styles/AIChatPage.css';

const API_BASE = "http://localhost:5001";

const AIChatPage = () => {
    const [messages, setMessages] = useState([]);
    const [inputMessage, setInputMessage] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const messagesEndRef = useRef(null);

    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    const handleSendMessage = async () => {
        if (!inputMessage.trim() || isLoading) return;

        const userMessage = {
            role: 'user',
            content: inputMessage,
            timestamp: new Date().toLocaleTimeString()
        };

        // 添加到消息列表
        setMessages(prev => [...prev, userMessage]);
        setInputMessage('');
        setIsLoading(true);

        try {
            const response = await fetch(`${API_BASE}/api/ai/chat`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    message: inputMessage,
                    history: messages.filter(m => m.role === 'user' || m.role === 'assistant')
                })
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || '网络响应异常');
            }

            const data = await response.json();

            const aiMessage = {
                role: 'assistant',
                content: data.response,
                timestamp: new Date().toLocaleTimeString()
            };

            setMessages(prev => [...prev, aiMessage]);

        } catch (error) {
            const errorMessage = {
                role: 'assistant',
                content: `抱歉，处理您的请求时出错: ${error.message}`,
                timestamp: new Date().toLocaleTimeString(),
                isError: true
            };
            setMessages(prev => [...prev, errorMessage]);
        } finally {
            setIsLoading(false);
        }
    };

    // 处理聊天输入框的按键事件
    const handleChatKeyDown = (e) => {
        // Ctrl+Enter 换行
        if (e.key === 'Enter' && e.ctrlKey) {
            setInputMessage(prev => prev + '\n');
        }
        // 单独按 Enter 发送消息
        else if (e.key === 'Enter' && !e.shiftKey && !e.ctrlKey) {
            e.preventDefault();
            handleSendMessage();
        }
    };

    return (
        <div className="ai-chat-app">
            {/* 顶部标题区域 */}
            <div className="ai-chat-header">
                <h1>DeepSeek 网络助手</h1>
                <p>我可以帮助您设计网络拓扑图并解答网络相关问题</p>
            </div>

            <div className="ai-chat-container">
                {/* AI对话界面 */}
                <div className="chat-section">
                    <div className="chat-header">
                        <h3>DeepSeek网络助手对话</h3>
                        <Link to="/topology-editor" className="go-to-topology">
                            网络拓扑图
                        </Link>
                    </div>
                    <div className="chat-messages">
                        {messages.map((msg, index) => (
                            <div
                                key={index}
                                className={`message ${msg.role} ${msg.isError ? 'error' : ''}`}
                            >
                                <div className="message-header">
                                    <strong>{msg.role === 'user' ? '您' : 'DeepSeek助手'}</strong>
                                    <span>{msg.timestamp}</span>
                                </div>
                                <div className="message-content">
                                    {msg.content.split('\n').map((line, i) => (
                                        <p key={i}>{line}</p>
                                    ))}
                                </div>
                            </div>
                        ))}
                        {isLoading && (
                            <div className="message assistant">
                                <div className="message-header">
                                    <strong>DeepSeek助手</strong>
                                    <span>正在思考...</span>
                                </div>
                                <div className="message-content loading">
                                    <div className="dot-flashing"></div>
                                </div>
                            </div>
                        )}
                        <div ref={messagesEndRef} />
                    </div>

                    <div className="chat-input">
                        <textarea
                            value={inputMessage}
                            onChange={(e) => setInputMessage(e.target.value)}
                            onKeyDown={handleChatKeyDown}
                            placeholder="输入您的问题或网络需求... (Ctrl+Enter换行, Enter发送)"
                            disabled={isLoading}
                            rows={3}
                        />
                        <button
                            className="send-button"
                            onClick={handleSendMessage}
                            disabled={isLoading || !inputMessage.trim()}
                        >
                            {isLoading ?
                                <div className="button-loader"></div> :
                                <span className="send-icon">➤</span>
                            }
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default AIChatPage;