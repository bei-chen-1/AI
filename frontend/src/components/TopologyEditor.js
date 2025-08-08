import React, { useEffect, useRef, useState } from 'react';
import { topologyElements, deviceIcons } from '../utils/topologyElements';
import './TopologyEditor.css';

const TopologyEditor = ({ topologyData, onGenerate }) => {
    const svgRef = useRef(null);
    const [elements, setElements] = useState([]);
    const [connections, setConnections] = useState([]);
    const [selectedElement, setSelectedElement] = useState(null);
    const [description, setDescription] = useState('');
    
    useEffect(() => {
        if (topologyData) {
            setElements(topologyData.devices || []);
            setConnections(topologyData.connections || []);
        }
    }, [topologyData]);
    
    const handleGenerate = () => {
        if (description.trim() && onGenerate) {
            onGenerate(description);
        }
    };
    
    const renderDevice = (device) => {
        const elementConfig = topologyElements[device.type] || topologyElements.default;
        const isSelected = selectedElement?.id === device.id;
        const iconSvg = deviceIcons[device.type] || deviceIcons.default;
        
        return (
            <g
                key={device.id}
                className={`device ${isSelected ? 'selected' : ''}`}
                transform={`translate(${device.position.x}, ${device.position.y})`}
                onClick={() => setSelectedElement(device)}
            >
                <g 
                    dangerouslySetInnerHTML={{ __html: iconSvg }}
                    transform="scale(0.7) translate(0, 0)"
                    fill="currentColor"
                />
                <text 
                    x="35" 
                    y="85" 
                    textAnchor="middle" 
                    fontSize="12" 
                    fill={isSelected ? '#1890ff' : '#333'}
                >
                    {device.label}
                </text>
            </g>
        );
    };
    
    const renderConnection = (conn) => {
        const sourceDevice = elements.find(d => d.id === conn.source);
        const targetDevice = elements.find(d => d.id === conn.target);
        
        if (!sourceDevice || !targetDevice) return null;
        
        const lineConfig = {
            ethernet: { stroke: '#1890ff', strokeDasharray: null },
            fiber: { stroke: '#ff4d4f', strokeDasharray: null },
            wireless: { stroke: '#52c41a', strokeDasharray: '5,5' },
            wan: { stroke: '#722ed1', strokeDasharray: '10,5' }
        }[conn.type] || lineConfig.ethernet;
        
        return (
            <g key={conn.id} className="connection">
                <line
                    x1={sourceDevice.position.x + 35}
                    y1={sourceDevice.position.y + 35}
                    x2={targetDevice.position.x + 35}
                    y2={targetDevice.position.y + 35}
                    stroke={lineConfig.stroke}
                    strokeWidth="2"
                    strokeDasharray={lineConfig.strokeDasharray}
                />
                {conn.label && (
                    <text
                        x={(sourceDevice.position.x + targetDevice.position.x) / 2 + 35}
                        y={(sourceDevice.position.y + targetDevice.position.y) / 2 + 35}
                        textAnchor="middle"
                        fill="#666"
                        fontSize="10"
                    >
                        {conn.label}
                    </text>
                )}
            </g>
        );
    };
    
    return (
        <div className="topology-editor">
            <div className="editor-controls">
                <textarea
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    placeholder="描述您的网络拓扑需求，例如：2个路由器连接3台主机..."
                    rows={3}
                />
                <button onClick={handleGenerate}>生成拓扑图</button>
            </div>
            
            <div className="editor-canvas">
                <svg
                    ref={svgRef}
                    width="100%"
                    height="400"
                    viewBox="0 0 800 400"
                    xmlns="http://www.w3.org/2000/svg"
                >
                    {/* 渲染连接线 */}
                    {connections.map(renderConnection)}
                    
                    {/* 渲染设备 */}
                    {elements.map(renderDevice)}
                </svg>
            </div>
            
            {selectedElement && (
                <div className="device-details">
                    <h4>设备详情</h4>
                    <p><strong>ID:</strong> {selectedElement.id}</p>
                    <p><strong>类型:</strong> {selectedElement.type}</p>
                    <p><strong>标签:</strong> {selectedElement.label}</p>
                    <p>
                        <strong>位置:</strong> 
                        X: {selectedElement.position.x}, 
                        Y: {selectedElement.position.y}
                    </p>
                </div>
            )}
        </div>
    );
};

export default TopologyEditor;