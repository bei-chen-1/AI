// 文件：frontend/src/components/GoJSTopology.js

import React, { useEffect, useRef } from 'react';
import * as go from 'gojs';
import './GoJSTopology.css';

const DEVICE_TYPES = {
    router: { name: '路由器' },
    switch: { name: '交换机' },
    firewall: { name: '防火墙' },
    server: { name: '服务器' },
    host: { name: '主机' },
    ap: { name: '无线AP' }
};

export default function GoJSTopology({ topologyData }) {
    const diagramRef = useRef(null);

    const handleDrop = (e) => {
        e.preventDefault();
        const type = e.dataTransfer.getData('device/type');
        if (!type) return;

        const rect = diagramRef.current.getBoundingClientRect();
        const mousePt = new go.Point(e.clientX - rect.left, e.clientY - rect.top);
        const diagram = go.Diagram.fromDiv(diagramRef.current);
        const diagramPoint = diagram.transformViewToDoc(mousePt);

        diagram.model.addNodeData({
            key: type + '_' + Math.floor(Math.random() * 10000),
            label: DEVICE_TYPES[type]?.name || type,
            loc: `${diagramPoint.x} ${diagramPoint.y}`
        });
    };

    useEffect(() => {
        const $ = go.GraphObject.make;

        const diagram = $(go.Diagram, diagramRef.current, {
            initialContentAlignment: go.Spot.Center,
            'undoManager.isEnabled': true,
            allowDrop: true,
            'draggingTool.isGridSnapEnabled': true,
            'grid.visible': true,
            layout: $(go.ForceDirectedLayout, { defaultSpringLength: 100 }),
        });

        diagram.nodeTemplate = $(
            go.Node,
            'Auto',
            { deletable: true },
            $(go.Shape, 'RoundedRectangle',
                {
                    fill: '#A0C4FF',
                    strokeWidth: 0,
                    portId: '',
                    cursor: 'pointer',
                    fromLinkable: true,
                    toLinkable: true
                }),
            $(go.TextBlock,
                { margin: 8 },
                new go.Binding('text', 'label'))
        );

        diagram.linkTemplate = $(
            go.Link,
            { routing: go.Link.AvoidsNodes, corner: 5, deletable: true },
            $(go.Shape),
            $(go.Shape, { toArrow: 'Standard' })
        );

        if (topologyData) {
            const model = new go.GraphLinksModel();
            model.nodeDataArray = topologyData.devices.map(d => ({
                key: d.id,
                label: d.label,
                loc: `${d.position.x} ${d.position.y}`
            }));
            model.linkDataArray = topologyData.connections.map(c => ({
                from: c.source,
                to: c.target
            }));
            diagram.model = model;
        }

        window.addEventListener('keydown', (e) => {
            if (e.key === 'Delete') {
                diagram.commandHandler.deleteSelection();
            }
        });

        window.addEventListener('exportTopologyPNG', () => {
            diagram.makeImageData({
                background: 'white',
                returnType: 'blob',
                callback: (blob) => {
                    const url = URL.createObjectURL(blob);
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = 'topology.png';
                    a.click();
                    URL.revokeObjectURL(url);
                }
            });
        });

        return () => {
            diagram.div = null;
        };
    }, [topologyData]);

    return (
        <div
            ref={diagramRef}
            className="gojs-diagram"
            onDrop={handleDrop}
            onDragOver={(e) => e.preventDefault()}
        />
    );
}
