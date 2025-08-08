// 设备类型配置
export const topologyElements = {
    router: {
        icon: '/icons/router.svg',
        label: '路由器',
        ports: 8
    },
    switch: {
        icon: '/icons/switch.svg',
        label: '交换机',
        ports: 24
    },
    firewall: {
        icon: '/icons/firewall.svg',
        label: '防火墙',
        ports: 4
    },
    server: {
        icon: '/icons/server.svg',
        label: '服务器',
        ports: 2
    },
    host: {
        icon: '/icons/pc.svg',
        label: '主机',
        ports: 1
    },
    wifi: {
        icon: '/icons/wifi.svg',
        label: '无线AP',
        ports: 1
    },
    default: {
        icon: '/icons/device.svg',
        label: '网络设备',
        ports: 4
    }
};

// 设备SVG图标（直接内联）
export const deviceIcons = {
    router: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <rect x="3" y="5" width="18" height="14" rx="2" fill="none" stroke="currentColor" stroke-width="2"/>
        <circle cx="7" cy="9" r="1" fill="currentColor"/>
        <circle cx="12" cy="9" r="1" fill="currentColor"/>
        <circle cx="17" cy="9" r="1" fill="currentColor"/>
        <path d="M5 15h14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
    </svg>`,
    
    switch: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <rect x="3" y="4" width="18" height="16" rx="2" fill="none" stroke="currentColor" stroke-width="2"/>
        <circle cx="8" cy="8" r="1" fill="currentColor"/>
        <circle cx="8" cy="12" r="1" fill="currentColor"/>
        <circle cx="8" cy="16" r="1" fill="currentColor"/>
        <circle cx="16" cy="8" r="1" fill="currentColor"/>
        <circle cx="16" cy="12" r="1" fill="currentColor"/>
        <circle cx="16" cy="16" r="1" fill="currentColor"/>
        <path d="M12 5v14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
    </svg>`,
    
    firewall: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M12 2L3 7v10l9 5 9-5V7l-9-5z" fill="none" stroke="currentColor" stroke-width="2"/>
        <path d="M12 12l-9-5M12 12v10M12 12l9-5" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
        <circle cx="12" cy="12" r="3" fill="currentColor"/>
    </svg>`,
    
    server: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <rect x="3" y="4" width="18" height="16" rx="2" fill="none" stroke="currentColor" stroke-width="2"/>
        <rect x="6" y="8" width="12" height="3" rx="1" fill="currentColor"/>
        <rect x="6" y="14" width="12" height="3" rx="1" fill="currentColor"/>
    </svg>`,
    
    pc: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <rect x="3" y="3" width="18" height="14" rx="2" fill="none" stroke="currentColor" stroke-width="2"/>
        <rect x="9" y="17" width="6" height="3" rx="1" fill="currentColor"/>
        <path d="M8 7h8M8 11h8" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
    </svg>`,
    
    wifi: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M12 19a1 1 0 100-2 1 1 0 000 2z" fill="currentColor"/>
        <path d="M12 15c-2.76 0-5 2.24-5 5M5.5 9.5c4.42-4.42 11.58-4.42 16 0M8.5 12.5c2.76-2.76 7.24-2.76 10 0" 
              fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
    </svg>`,
    
    default: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <rect x="3" y="3" width="18" height="18" rx="2" fill="none" stroke="currentColor" stroke-width="2"/>
        <circle cx="12" cy="12" r="3" fill="currentColor"/>
        <path d="M3 12h3M18 12h3M12 3v3M12 18v3" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
    </svg>`
};