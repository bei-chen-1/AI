// 文件：frontend/src/pages/TopologyEditorPage.js

import React, { useState } from 'react';
import { toast } from 'sonner';
import { Download, Sparkles } from 'lucide-react';
import GoJSTopology from '../components/GoJSTopology';
import '../styles/TopologyEditorPage.css';

const API_BASE = process.env.REACT_APP_API_BASE || 'http://localhost:5001';

const DEVICE_TYPES = [
    { type: 'router', label: '路由器' },
    { type: 'switch', label: '交换机' },
    { type: 'firewall', label: '防火墙' },
    { type: 'server', label: '服务器' },
    { type: 'host', label: '主机' },
    { type: 'ap', label: '无线AP' }
];

export default function TopologyEditorPage() {
    const [description, setDescription] = useState('');
    const [topologyData, setTopologyData] = useState(null);
    const [loading, setLoading] = useState(false);

    const handleGenerate = async () => {
        if (!description.trim()) return toast.error('请输入网络拓扑描述');
        setLoading(true);
        try {
            const res = await fetch(`${API_BASE}/api/ai/generate-topology`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ description })
            });
            const result = await res.json();
            if (!result.devices) {
                toast.error('拓扑生成失败');
                return;
            }
            setTopologyData(result);
        } catch (err) {
            toast.error('生成请求出错');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleExport = (type) => {
        if (!topologyData) return;
        if (type === 'json') {
            const blob = new Blob([JSON.stringify(topologyData, null, 2)], {
                type: 'application/json'
            });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'topology.json';
            a.click();
            URL.revokeObjectURL(url);
        } else if (type === 'png') {
            window.dispatchEvent(new CustomEvent('exportTopologyPNG'));
        }
    };

    return (
        <div className="topology-editor">
            <header className="editor-header">
                <h1 className="title">AI 网络拓扑图生成器</h1>
                <p className="subtitle">输入描述，生成可视化拓扑图并支持自定义拖拽</p>
            </header>

            <div className="editor-controls">
                <input
                    type="text"
                    placeholder="例如：一个路由器连接一个交换机"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    className="desc-input"
                />
                <button onClick={handleGenerate} className="btn-generate" disabled={loading}>
                    <Sparkles size={16} className="mr-2" />
                    {loading ? '生成中...' : '生成拓扑图'}
                </button>
                <button onClick={() => handleExport('json')} className="btn-export">
                    <Download size={16} className="mr-1" /> JSON
                </button>
                <button onClick={() => handleExport('png')} className="btn-export">
                    <Download size={16} className="mr-1" /> PNG
                </button>
            </div>

            <div className="main-content">
                <div className="sidebar">
                    <div className="sidebar-title">网络设备</div>
                    {DEVICE_TYPES.map(device => (
                        <div
                            key={device.type}
                            className="device-item"
                            draggable
                            onDragStart={(e) => {
                                e.dataTransfer.setData('device/type', device.type);
                            }}
                        >
                            {device.label}
                        </div>
                    ))}
                </div>

                <div className="topology-canvas">
                    <GoJSTopology topologyData={topologyData} />
                </div>
            </div>
        </div>
    );
}
