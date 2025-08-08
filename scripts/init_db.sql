-- 创建数据库
CREATE DATABASE IF NOT EXISTS knowledge_db;
USE knowledge_db;

-- 创建学科表
CREATE TABLE subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);

-- 创建题目表（调整后的options字段）
CREATE TABLE questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subject_id INT NOT NULL,
    question TEXT NOT NULL,
    question_type ENUM(
        'single_choice',
        'multiple_choice',
        'true_false',
        'fill_in_blank',
        'short_answer',
        'comprehensive'
    ) NOT NULL DEFAULT 'single_choice',
    difficulty ENUM('easy', 'medium', 'hard') DEFAULT 'medium',
    score INT NOT NULL DEFAULT 1,
    options JSON COMMENT '题目选项（JSON格式），包含key和text',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(id)
);

-- 创建答案表（添加correct_key字段）
CREATE TABLE answers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT NOT NULL,
    answer TEXT NOT NULL,
    explanation TEXT,
    correct_key VARCHAR(255) COMMENT '正确答案的key（选择题/判断题使用）',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

-- 插入三个学科
INSERT INTO subjects (name, description) VALUES
('IPv6', 'IPv6协议原理、地址配置、过渡技术等'),
('SDN', '软件定义网络架构、OpenFlow协议、控制器技术等'),
('HCIA', '华为认证网络工程师基础：路由协议、子网划分、设备配置等');

-- ===== IPv6题目 =====
-- 单选题（添加选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty, options) VALUES
(1, 'IPv6地址的长度是多少位？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "32位"},
    {"key": "B", "text": "64位"},
    {"key": "C", "text": "128位"},
    {"key": "D", "text": "256位"}]'),

(1, 'IPv6地址2001:0db8:85a3:0000:0000:8a2e:0370:7334的正确压缩形式是？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "2001:db8:85a3::8a2e:370:7334"},
    {"key": "B", "text": "2001:db8:85a3:0:0:8a2e:370:7334"},
    {"key": "C", "text": "2001:db8:85a3:::8a2e:370:7334"},
    {"key": "D", "text": "2001:db8:85a3:0000::8a2e:370:7334"}]'),

(1, '在IPv6中，链路本地地址的前缀是什么？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "fe80::/10"},
    {"key": "B", "text": "fc00::/7"},
    {"key": "C", "text": "2000::/3"},
    {"key": "D", "text": "ff00::/8"}]'),

(1, 'IPv6的地址类型不包括以下哪项？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "单播地址"},
    {"key": "B", "text": "组播地址"},
    {"key": "C", "text": "任播地址"},
    {"key": "D", "text": "广播地址"}]'),

(1, 'IPv6的组播地址范围是？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "ff00::/8"},
    {"key": "B", "text": "fe80::/10"},
    {"key": "C", "text": "2000::/3"},
    {"key": "D", "text": "fc00::/7"}]'),

(1, 'IPv6地址中，全球单播地址的前缀是？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "2000::/3"},
    {"key": "B", "text": "fc00::/7"},
    {"key": "C", "text": "fe80::/10"},
    {"key": "D", "text": "ff00::/8"}]'),

(1, 'IPv6的环回地址是？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "::1"},
    {"key": "B", "text": "::"},
    {"key": "C", "text": "127.0.0.1"},
    {"key": "D", "text": "2001::1"}]'),

(1, 'IPv6地址中，未指定地址是？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "::"},
    {"key": "B", "text": "::1"},
    {"key": "C", "text": "0.0.0.0"},
    {"key": "D", "text": "ffff::"}]'),

(1, 'IPv6地址由几组16进制数组成？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "4组"},
    {"key": "B", "text": "6组"},
    {"key": "C", "text": "8组"},
    {"key": "D", "text": "10组"}]'),

(1, 'IPv6地址中，唯一本地地址的前缀是？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "fc00::/7"},
    {"key": "B", "text": "fe80::/10"},
    {"key": "C", "text": "2000::/3"},
    {"key": "D", "text": "ff00::/8"}]'),

(1, 'IPv6地址中，站点本地地址已被什么替代？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "唯一本地地址(ULA)"},
    {"key": "B", "text": "链路本地地址"},
    {"key": "C", "text": "全局单播地址"},
    {"key": "D", "text": "组播地址"}]'),

(1, 'IPv6地址中，组播地址的前缀是？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "ff00::/8"},
    {"key": "B", "text": "fe80::/10"},
    {"key": "C", "text": "2000::/3"},
    {"key": "D", "text": "fc00::/7"}]'),

(1, 'IPv6地址中，任播地址的特点是什么？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "发送到最近的一组中的一个"},
    {"key": "B", "text": "发送到所有接口"},
    {"key": "C", "text": "发送到特定接口"},
    {"key": "D", "text": "发送到任意一个接口"}]'),

(1, 'IPv6地址中，接口标识符的长度是多少位？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "32位"},
    {"key": "B", "text": "48位"},
    {"key": "C", "text": "64位"},
    {"key": "D", "text": "128位"}]'),

(1, 'IPv6地址中，链路本地地址的作用范围是？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "本地链路"},
    {"key": "B", "text": "整个网络"},
    {"key": "C", "text": "特定站点"},
    {"key": "D", "text": "全局范围"}]'),

(1, 'IPv6地址中，全球单播地址的结构是什么？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "全局路由前缀+子网ID+接口标识符"},
    {"key": "B", "text": "网络前缀+主机地址"},
    {"key": "C", "text": "地址类型+组播范围"},
    {"key": "D", "text": "路由前缀+任意播ID"}]'),

(1, 'IPv6地址中，组播地址的Flags字段中，T=1表示什么？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "基于网络前缀的组播地址"},
    {"key": "B", "text": "永久分配的组播地址"},
    {"key": "C", "text": "临时分配的组播地址"},
    {"key": "D", "text": "本地链路组播地址"}]'),

(1, 'IPv6地址中，被请求节点组播地址的前缀是什么？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "ff02::1:ff00:0/104"},
    {"key": "B", "text": "ff02::1:ff00:0/96"},
    {"key": "C", "text": "ff02::1:ff00:0/128"},
    {"key": "D", "text": "ff02::1:ff00:0/64"}]'),

(1, 'IPv6地址中，IPv4映射地址的格式是什么？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "::ffff:0:0/96"},
    {"key": "B", "text": "::1"},
    {"key": "C", "text": "2001::/32"},
    {"key": "D", "text": "fe80::/10"}]'),

(1, 'IPv6地址中，兼容IPv4的地址格式是什么？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "::/96"},
    {"key": "B", "text": "::1"},
    {"key": "C", "text": "2001::/32"},
    {"key": "D", "text": "fe80::/10"}]');

-- 多选题（添加选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty, options) VALUES
(1, 'IPv6相比IPv4有哪些优势？（多选）', 'multiple_choice', 2, 'easy',
  '[{"key": "A", "text": "更大的地址空间"},
    {"key": "B", "text": "更小的路由表"},
    {"key": "C", "text": "增强的安全性"},
    {"key": "D", "text": "即插即用"},
    {"key": "E", "text": "更好的QoS支持"}]'),

(1, 'IPv6的地址类型包括哪些？（多选）', 'multiple_choice', 2, 'medium',
  '[{"key": "A", "text": "单播地址"},
    {"key": "B", "text": "组播地址"},
    {"key": "C", "text": "任播地址"},
    {"key": "D", "text": "广播地址"},
    {"key": "E", "text": "链路本地地址"}]'),

(1, 'IPv6过渡技术包括哪些？（多选）', 'multiple_choice', 2, 'hard',
  '[{"key": "A", "text": "双栈技术"},
    {"key": "B", "text": "隧道技术"},
    {"key": "C", "text": "协议转换"},
    {"key": "D", "text": "地址转换"},
    {"key": "E", "text": "路由优化"}]'),

(1, 'IPv6邻居发现协议的功能包括哪些？（多选）', 'multiple_choice', 2, 'medium',
  '[{"key": "A", "text": "地址解析"},
    {"key": "B", "text": "路由器发现"},
    {"key": "C", "text": "邻居不可达检测"},
    {"key": "D", "text": "域名解析"},
    {"key": "E", "text": "IP地址分配"}]'),

(1, 'IPv6地址自动配置的类型包括哪些？（多选）', 'multiple_choice', 2, 'hard',
  '[{"key": "A", "text": "无状态自动配置"},
    {"key": "B", "text": "有状态自动配置"},
    {"key": "C", "text": "半自动配置"},
    {"key": "D", "text": "手动配置"},
    {"key": "E", "text": "动态配置"}]'),

(1, 'IPv6扩展头部包括哪些？（多选）', 'multiple_choice', 2, 'hard',
  '[{"key": "A", "text": "逐跳选项头"},
    {"key": "B", "text": "路由头"},
    {"key": "C", "text": "分片头"},
    {"key": "D", "text": "认证头"},
    {"key": "E", "text": "封装安全载荷头"}]'),

(1, 'IPv6安全机制包括哪些？（多选）', 'multiple_choice', 2, 'medium',
  '[{"key": "A", "text": "IPsec集成"},
    {"key": "B", "text": "数据加密"},
    {"key": "C", "text": "身份验证"},
    {"key": "D", "text": "访问控制"},
    {"key": "E", "text": "防火墙"}]'),

(1, 'IPv6地址压缩规则包括哪些？（多选）', 'multiple_choice', 2, 'medium',
  '[{"key": "A", "text": "前导零可省略"},
    {"key": "B", "text": "连续零组可用::代替"},
    {"key": "C", "text": "所有零必须保留"},
    {"key": "D", "text": "每组必须4位十六进制"},
    {"key": "E", "text": "只能使用一次::"}]'),

(1, 'IPv6地址分配方式包括哪些？（多选）', 'multiple_choice', 2, 'medium',
  '[{"key": "A", "text": "手动配置"},
    {"key": "B", "text": "无状态自动配置"},
    {"key": "C", "text": "有状态自动配置"},
    {"key": "D", "text": "动态分配"},
    {"key": "E", "text": "随机分配"}]'),

(1, 'IPv6路由协议包括哪些？（多选）', 'multiple_choice', 2, 'hard',
  '[{"key": "A", "text": "RIPng"},
    {"key": "B", "text": "OSPFv3"},
    {"key": "C", "text": "BGP4+"},
    {"key": "D", "text": "IS-ISv6"},
    {"key": "E", "text": "EIGRPv6"}]');

-- 判断题（无需选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty) VALUES
(1, 'IPv6地址中可以使用两个连续的"::"进行压缩。', 'true_false', 1, 'easy'),
(1, 'IPv6的环回地址是::1。', 'true_false', 1, 'easy'),
(1, 'IPv6不需要NAT技术。', 'true_false', 1, 'medium'),
(1, 'IPv6地址长度是IPv4地址长度的4倍。', 'true_false', 1, 'easy'),
(1, 'IPv6的全球单播地址前缀是2000::/3。', 'true_false', 1, 'medium'),
(1, 'IPv6的链路本地地址前缀是FE80::/10。', 'true_false', 1, 'medium'),
(1, 'IPv6的任播地址可以被分配给多个接口。', 'true_false', 1, 'hard'),
(1, 'IPv6的组播地址范围是FF00::/8。', 'true_false', 1, 'medium'),
(1, 'IPv6地址中，每16位为一组，用冒号分隔。', 'true_false', 1, 'easy'),
(1, 'IPv6支持即插即用，不需要DHCP服务器。', 'true_false', 1, 'medium');

-- 填空题（无需选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty) VALUES
(1, 'IPv6地址由____组16进制数组成。', 'fill_in_blank', 1, 'easy'),
(1, 'IPv6的未指定地址是______。', 'fill_in_blank', 1, 'medium'),
(1, 'IPv6的全球单播地址前缀是______。', 'fill_in_blank', 1, 'hard'),
(1, 'IPv6链路本地地址的前缀是______。', 'fill_in_blank', 1, 'medium'),
(1, 'IPv6地址压缩规则中，连续的零可以用______表示。', 'fill_in_blank', 1, 'easy'),
(1, 'IPv6邻居发现协议替代了IPv4中的______协议。', 'fill_in_blank', 1, 'medium'),
(1, 'IPv6地址中，接口标识符通常由______地址生成。', 'fill_in_blank', 1, 'hard'),
(1, 'IPv6的任播地址用于发送到______的接口。', 'fill_in_blank', 1, 'hard'),
(1, 'IPv6组播地址中，被请求节点组播地址的前缀是______。', 'fill_in_blank', 1, 'hard'),
(1, 'IPv6过渡技术中，6to4隧道使用特殊的______地址。', 'fill_in_blank', 1, 'hard');

-- 简答题（无需选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty) VALUES
(1, '简述IPv6地址的三种主要类型及其用途。', 'short_answer', 5, 'medium'),
(1, '解释IPv6的邻居发现协议的主要功能。', 'short_answer', 5, 'hard'),
(1, 'IPv6相比IPv4有哪些主要优势？', 'short_answer', 5, 'medium'),
(1, '简述IPv6地址自动配置的过程。', 'short_answer', 5, 'hard');

-- 综合应用题（无需选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty) VALUES
(1, '某公司获得IPv6地址块2001:db8:abcd::/48。请设计子网划分方案，要求：1) 划分16个子网；2) 每个子网至少支持1000台主机；3) 写出第一个子网的地址范围。', 'comprehensive', 10, 'hard'),
(1, '设计一个IPv6过渡方案，使现有IPv4网络能够逐步迁移到IPv6，同时保证两种协议共存期间的通信。', 'comprehensive', 10, 'hard');

-- ===== SDN题目 =====
-- 单选题（添加选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty, options) VALUES
(2, 'SDN架构的核心组件是？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "控制器"},
    {"key": "B", "text": "交换机"},
    {"key": "C", "text": "路由器"},
    {"key": "D", "text": "防火墙"}]'),

(2, 'OpenFlow协议默认使用的端口号是？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "6633"},
    {"key": "B", "text": "80"},
    {"key": "C", "text": "443"},
    {"key": "D", "text": "22"}]'),

(2, 'SDN中负责集中控制策略的组件是？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "SDN控制器"},
    {"key": "B", "text": "OpenFlow交换机"},
    {"key": "C", "text": "北向接口"},
    {"key": "D", "text": "南向接口"}]'),

(2, 'OpenFlow协议中，流表项不包含以下哪个字段？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "TTL字段"},
    {"key": "B", "text": "匹配字段"},
    {"key": "C", "text": "指令"},
    {"key": "D", "text": "计数器"}]'),

(2, 'SDN的三层架构不包括以下哪一层？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "传输层"},
    {"key": "B", "text": "应用层"},
    {"key": "C", "text": "控制层"},
    {"key": "D", "text": "基础设施层"}]'),

(2, '以下哪个不是主流的SDN控制器？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "Cisco IOS"},
    {"key": "B", "text": "OpenDaylight"},
    {"key": "C", "text": "ONOS"},
    {"key": "D", "text": "Floodlight"}]'),

(2, 'OpenFlow协议中，Packet-in消息的作用是？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "将无法处理的数据包发送给控制器"},
    {"key": "B", "text": "修改流表项"},
    {"key": "C", "text": "添加新的流表项"},
    {"key": "D", "text": "删除流表项"}]'),

(2, 'SDN中，南向接口协议不包括？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "SNMP"},
    {"key": "B", "text": "OpenFlow"},
    {"key": "C", "text": "OVSDB"},
    {"key": "D", "text": "NETCONF"}]'),

(2, 'OpenFlow交换机中，流表项的优先级范围是？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "0-65535"},
    {"key": "B", "text": "0-255"},
    {"key": "C", "text": "1-1000"},
    {"key": "D", "text": "0-100"}]'),

(2, 'SDN中，OpenFlow协议的版本不包括？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "OpenFlow 4.0"},
    {"key": "B", "text": "OpenFlow 1.0"},
    {"key": "C", "text": "OpenFlow 1.3"},
    {"key": "D", "text": "OpenFlow 1.5"}]'),

(2, '以下哪个不是SDN的主要特征？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "硬件依赖"},
    {"key": "B", "text": "控制与转发分离"},
    {"key": "C", "text": "集中控制"},
    {"key": "D", "text": "开放接口"}]'),

(2, 'OpenFlow协议中，Flow-Mod消息的作用是？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "修改流表"},
    {"key": "B", "text": "发送数据包"},
    {"key": "C", "text": "查询交换机状态"},
    {"key": "D", "text": "建立连接"}]'),

(2, 'SDN中，控制层与基础设施层之间的接口称为？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "南向接口"},
    {"key": "B", "text": "北向接口"},
    {"key": "C", "text": "东西向接口"},
    {"key": "D", "text": "API接口"}]'),

(2, 'Open vSwitch中，查看流表的命令是？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "ovs-ofctl dump-flows"},
    {"key": "B", "text": "ovs-vsctl show"},
    {"key": "C", "text": "ovs-appctl fdb/show"},
    {"key": "D", "text": "ovs-dpctl show"}]'),

(2, 'SDN中，网络功能虚拟化(NFV)的主要目标是？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "将网络功能从专用硬件解耦"},
    {"key": "B", "text": "提高硬件性能"},
    {"key": "C", "text": "减少软件依赖"},
    {"key": "D", "text": "增加网络设备"}]'),

(2, 'OpenFlow协议中，Match字段不能匹配以下哪个？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "应用层数据"},
    {"key": "B", "text": "源IP地址"},
    {"key": "C", "text": "目的MAC地址"},
    {"key": "D", "text": "输入端口"}]'),

(2, 'SDN中，北向接口的主要作用是？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "为应用程序提供网络抽象"},
    {"key": "B", "text": "连接交换机"},
    {"key": "C", "text": "管理物理设备"},
    {"key": "D", "text": "配置控制器"}]'),

(2, 'OpenFlow协议中，多级流表的最大数量是？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "255"},
    {"key": "B", "text": "256"},
    {"key": "C", "text": "128"},
    {"key": "D", "text": "64"}]'),

(2, 'SDN中，控制器的分布式部署方式不包括？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "主从模式"},
    {"key": "B", "text": "对等模式"},
    {"key": "C", "text": "混合模式"},
    {"key": "D", "text": "单点模式"}]'),

(2, 'OpenFlow协议中，Group表的作用是？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "实现组播和负载均衡"},
    {"key": "B", "text": "存储流表项"},
    {"key": "C", "text": "管理交换机连接"},
    {"key": "D", "text": "处理数据包"}]');

-- 多选题（添加选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty, options) VALUES
(2, 'SDN的三层架构包括哪些？（多选）', 'multiple_choice', 2, 'easy',
  '[{"key": "A", "text": "应用层"},
    {"key": "B", "text": "控制层"},
    {"key": "C", "text": "基础设施层"},
    {"key": "D", "text": "数据链路层"},
    {"key": "E", "text": "物理层"}]'),

(2, 'OpenFlow协议支持的消息类型包括哪些？（多选）', 'multiple_choice', 2, 'medium',
  '[{"key": "A", "text": "控制器到交换机"},
    {"key": "B", "text": "异步"},
    {"key": "C", "text": "对称"},
    {"key": "D", "text": "广播"},
    {"key": "E", "text": "组播"}]'),

(2, 'SDN控制器的功能包括哪些？（多选）', 'multiple_choice', 2, 'hard',
  '[{"key": "A", "text": "网络拓扑发现"},
    {"key": "B", "text": "流表管理"},
    {"key": "C", "text": "策略下发"},
    {"key": "D", "text": "状态监控"},
    {"key": "E", "text": "数据转发"}]'),

(2, 'SDN的主要优势包括哪些？（多选）', 'multiple_choice', 2, 'medium',
  '[{"key": "A", "text": "网络可编程性"},
    {"key": "B", "text": "集中管理"},
    {"key": "C", "text": "快速创新"},
    {"key": "D", "text": "资源优化"},
    {"key": "E", "text": "硬件依赖减少"}]'),

(2, 'OpenFlow流表项的组成部分包括哪些？（多选）', 'multiple_choice', 2, 'medium',
  '[{"key": "A", "text": "匹配字段"},
    {"key": "B", "text": "指令"},
    {"key": "C", "text": "计数器"},
    {"key": "D", "text": "超时"},
    {"key": "E", "text": "Cookie"}]'),

(2, 'SDN中，南向接口协议包括哪些？（多选）', 'multiple_choice', 2, 'hard',
  '[{"key": "A", "text": "OpenFlow"},
    {"key": "B", "text": "OVSDB"},
    {"key": "C", "text": "NETCONF"},
    {"key": "D", "text": "SNMP"},
    {"key": "E", "text": "RESTCONF"}]'),

(2, 'SDN应用场景包括哪些？（多选）', 'multiple_choice', 2, 'medium',
  '[{"key": "A", "text": "数据中心网络"},
    {"key": "B", "text": "广域网"},
    {"key": "C", "text": "5G网络"},
    {"key": "D", "text": "物联网"},
    {"key": "E", "text": "家庭网络"}]'),

(2, 'OpenFlow协议中，Action类型包括哪些？（多选）', 'multiple_choice', 2, 'hard',
  '[{"key": "A", "text": "输出"},
    {"key": "B", "text": "丢弃"},
    {"key": "C", "text": "修改字段"},
    {"key": "D", "text": "推送标签"},
    {"key": "E", "text": "转到表"}]'),

(2, 'SDN中，网络虚拟化的实现方式包括哪些？（多选）', 'multiple_choice', 2, 'hard',
  '[{"key": "A", "text": "VxLAN"},
    {"key": "B", "text": "Geneve"},
    {"key": "C", "text": "网络切片"},
    {"key": "D", "text": "VLAN"},
    {"key": "E", "text": "MPLS"}]'),

(2, 'SDN面临的挑战包括哪些？（多选）', 'multiple_choice', 2, 'hard',
  '[{"key": "A", "text": "安全性"},
    {"key": "B", "text": "可扩展性"},
    {"key": "C", "text": "标准化"},
    {"key": "D", "text": "部署复杂性"},
    {"key": "E", "text": "性能瓶颈"}]');

-- 判断题（无需选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty) VALUES
(2, 'SDN实现了控制平面与数据平面的分离。', 'true_false', 1, 'easy'),
(2, 'OpenFlow是SDN的唯一南向接口协议。', 'true_false', 1, 'medium'),
(2, 'OVSDB协议用于管理Open vSwitch的配置。', 'true_false', 1, 'hard'),
(2, 'SDN控制器只能部署在单一服务器上。', 'true_false', 1, 'medium'),
(2, 'OpenFlow协议支持IPv6地址匹配。', 'true_false', 1, 'medium'),
(2, 'SDN中，应用层通过北向接口与控制器通信。', 'true_false', 1, 'easy'),
(2, 'OpenFlow交换机必须支持所有OpenFlow协议定义的功能。', 'true_false', 1, 'hard'),
(2, 'SDN可以提高网络管理的灵活性。', 'true_false', 1, 'easy'),
(2, 'OpenFlow协议中，流表项的优先级数值越大，优先级越高。', 'true_false', 1, 'medium'),
(2, 'SDN只适用于数据中心网络。', 'true_false', 1, 'medium');

-- 填空题（无需选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty) VALUES
(2, 'SDN的英文全称是______。', 'fill_in_blank', 1, 'easy'),
(2, 'OpenFlow协议中，控制器与交换机之间通过______通道通信。', 'fill_in_blank', 1, 'medium'),
(2, '查看Open vSwitch流表的命令是______。', 'fill_in_blank', 1, 'hard'),
(2, 'SDN的三层架构包括应用层、______和基础设施层。', 'fill_in_blank', 1, 'easy'),
(2, 'OpenFlow协议当前最新版本是______。', 'fill_in_blank', 1, 'hard'),
(2, 'SDN中，将网络功能抽象为软件实体的技术称为______。', 'fill_in_blank', 1, 'medium'),
(2, 'OpenFlow协议中，用于交换机主动连接控制器的端口是______。', 'fill_in_blank', 1, 'hard'),
(2, 'SDN控制器使用______协议与交换机通信。', 'fill_in_blank', 1, 'medium'),
(2, 'OpenFlow交换机中，当数据包不匹配任何流表项时，会发送______消息给控制器。', 'fill_in_blank', 1, 'medium'),
(2, 'SDN中，用于实现网络切片的技术是______。', 'fill_in_blank', 1, 'hard');

-- 简答题（无需选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty) VALUES
(2, '简述SDN架构的主要优势。', 'short_answer', 5, 'medium'),
(2, '解释OpenFlow流表的基本结构和工作原理。', 'short_answer', 5, 'hard'),
(2, 'SDN与传统网络架构的主要区别是什么？', 'short_answer', 5, 'medium'),
(2, '简述SDN控制器的主要功能。', 'short_answer', 5, 'medium');

-- 综合应用题（无需选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty) VALUES
(2, '设计一个基于SDN的校园网QoS方案，要求：1) 支持不同用户组的带宽保障；2) 支持关键应用的优先级调度；3) 描述控制器如何实现策略下发。', 'comprehensive', 10, 'hard'),
(2, '使用SDN技术设计一个网络安全防护系统，要求：1) 实现DDoS攻击检测；2) 实现自动流量清洗；3) 描述控制器与安全设备的协同机制。', 'comprehensive', 10, 'hard');

-- ===== HCIA题目 =====
-- 单选题（添加选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty, options) VALUES
(3, 'OSPF协议中，Router ID的选择优先级是？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "手动配置的最高IP地址"},
    {"key": "B", "text": "最大的接口IP地址"},
    {"key": "C", "text": "最小的接口IP地址"},
    {"key": "D", "text": "随机选择"}]'),

(3, '在STP协议中，根桥的选择依据是？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "最小的桥ID"},
    {"key": "B", "text": "最大的桥ID"},
    {"key": "C", "text": "最先启动的设备"},
    {"key": "D", "text": "端口数量最多的设备"}]'),

(3, 'IP地址192.168.1.0/24的子网掩码是？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "255.255.255.0"},
    {"key": "B", "text": "255.255.0.0"},
    {"key": "C", "text": "255.0.0.0"},
    {"key": "D", "text": "255.255.255.255"}]'),

(3, 'TCP协议中，建立连接的过程称为？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "三次握手"},
    {"key": "B", "text": "四次挥手"},
    {"key": "C", "text": "两次握手"},
    {"key": "D", "text": "直接连接"}]'),

(3, '以下哪个是私有IP地址范围？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "10.0.0.0/8"},
    {"key": "B", "text": "172.16.0.0/12"},
    {"key": "C", "text": "192.168.0.0/16"},
    {"key": "D", "text": "以上都是"}]'),

(3, 'VLAN的主要作用是？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "分割广播域"},
    {"key": "B", "text": "增加带宽"},
    {"key": "C", "text": "提高安全性"},
    {"key": "D", "text": "简化管理"}]'),

(3, '路由器工作在OSI模型的哪一层？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "网络层"},
    {"key": "B", "text": "数据链路层"},
    {"key": "C", "text": "传输层"},
    {"key": "D", "text": "应用层"}]'),

(3, 'DHCP协议的主要功能是？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "自动分配IP地址"},
    {"key": "B", "text": "域名解析"},
    {"key": "C", "text": "路由选择"},
    {"key": "D", "text": "错误检测"}]'),

(3, 'ACL中，标准访问控制列表基于什么进行过滤？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "源IP地址"},
    {"key": "B", "text": "目的IP地址"},
    {"key": "C", "text": "端口号"},
    {"key": "D", "text": "协议类型"}]'),

(3, 'NAT技术主要用于解决什么问题？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "IPv4地址短缺"},
    {"key": "B", "text": "网络速度慢"},
    {"key": "C", "text": "安全性问题"},
    {"key": "D", "text": "路由复杂性"}]'),

(3, 'OSPF协议中，邻居关系建立的最后状态是？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "Full"},
    {"key": "B", "text": "Init"},
    {"key": "C", "text": "2-Way"},
    {"key": "D", "text": "ExStart"}]'),

(3, '在以太网中，MAC地址的长度是？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "48位"},
    {"key": "B", "text": "32位"},
    {"key": "C", "text": "64位"},
    {"key": "D", "text": "128位"}]'),

(3, 'IPv6地址中，全球单播地址的前缀是？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "2000::/3"},
    {"key": "B", "text": "fc00::/7"},
    {"key": "C", "text": "fe80::/10"},
    {"key": "D", "text": "ff00::/8"}]'),

(3, '在路由表中，0.0.0.0/0表示？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "默认路由"},
    {"key": "B", "text": "本地环回"},
    {"key": "C", "text": "直接连接"},
    {"key": "D", "text": "无效路由"}]'),

(3, 'ICMP协议的主要作用是？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "传递控制消息"},
    {"key": "B", "text": "数据加密"},
    {"key": "C", "text": "地址分配"},
    {"key": "D", "text": "路由选择"}]'),

(3, '在华为设备中，查看路由表的命令是？', 'single_choice', 1, 'easy',
  '[{"key": "A", "text": "display ip routing-table"},
    {"key": "B", "text": "show route"},
    {"key": "C", "text": "display route"},
    {"key": "D", "text": "show ip route"}]'),

(3, 'VLAN Trunk协议的作用是？', 'single_choice', 1, 'medium',
  '[{"key": "A", "text": "跨交换机传输多个VLAN数据"},
    {"key": "B", "text": "创建新的VLAN"},
    {"key": "C", "text": "删除VLAN"},
    {"key": "D", "text": "配置VLAN IP地址"}]'),

(3, 'OSPF协议中，缺省的Hello时间间隔是？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "10秒"},
    {"key": "B", "text": "30秒"},
    {"key": "C", "text": "60秒"},
    {"key": "D", "text": "5秒"}]'),

(3, '在STP协议中，非根桥的根端口是？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "到根桥路径开销最小的端口"},
    {"key": "B", "text": "端口ID最小的端口"},
    {"key": "C", "text": "优先级最高的端口"},
    {"key": "D", "text": "带宽最大的端口"}]'),

(3, 'IPSec协议中，用于数据加密的协议是？', 'single_choice', 1, 'hard',
  '[{"key": "A", "text": "ESP"},
    {"key": "B", "text": "AH"},
    {"key": "C", "text": "IKE"},
    {"key": "D", "text": "ISAKMP"}]');

-- 多选题（添加选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty, options) VALUES
(3, '路由协议的类型包括？（多选）', 'multiple_choice', 2, 'medium',
  '[{"key": "A", "text": "距离矢量协议"},
    {"key": "B", "text": "链路状态协议"},
    {"key": "C", "text": "路径矢量协议"},
    {"key": "D", "text": "交换协议"},
    {"key": "E", "text": "传输协议"}]'),

(3, '网络拓扑类型包括？（多选）', 'multiple_choice', 2, 'easy',
  '[{"key": "A", "text": "星型"},
    {"key": "B", "text": "环型"},
    {"key": "C", "text": "总线型"},
    {"key": "D", "text": "网状"},
    {"key": "E", "text": "树型"}]'),

(3, 'TCP协议的特点包括？（多选）', 'multiple_choice', 2, 'medium',
  '[{"key": "A", "text": "面向连接"},
    {"key": "B", "text": "可靠传输"},
    {"key": "C", "text": "流量控制"},
    {"key": "D", "text": "无序传输"},
    {"key": "E", "text": "不可靠"}]'),

(3, 'VLAN的优点包括？（多选）', 'multiple_choice', 2, 'medium',
  '[{"key": "A", "text": "分割广播域"},
    {"key": "B", "text": "提高安全性"},
    {"key": "C", "text": "简化管理"},
    {"key": "D", "text": "增加带宽"},
    {"key": "E", "text": "减少延迟"}]'),

(3, '网络安全措施包括？（多选）', 'multiple_choice', 2, 'hard',
  '[{"key": "A", "text": "防火墙"},
    {"key": "B", "text": "入侵检测"},
    {"key": "C", "text": "VPN"},
    {"key": "D", "text": "ACL"},
    {"key": "E", "text": "加密"}]'),

(3, 'WAN技术包括？（多选）', 'multiple_choice', 2, 'hard',
  '[{"key": "A", "text": "PPP"},
    {"key": "B", "text": "Frame Relay"},
    {"key": "C", "text": "MPLS"},
    {"key": "D", "text": "Ethernet"},
    {"key": "E", "text": "Wi-Fi"}]'),

(3, 'IPv6的特点包括？（多选）', 'multiple_choice', 2, 'medium',
  '[{"key": "A", "text": "地址空间大"},
    {"key": "B", "text": "简化头部"},
    {"key": "C", "text": "安全性增强"},
    {"key": "D", "text": "即插即用"},
    {"key": "E", "text": "更好的QoS支持"}]'),

(3, 'QoS技术包括？（多选）', 'multiple_choice', 2, 'hard',
  '[{"key": "A", "text": "分类"},
    {"key": "B", "text": "标记"},
    {"key": "C", "text": "队列"},
    {"key": "D", "text": "拥塞避免"},
    {"key": "E", "text": "流量整形"}]'),

(3, '无线网络的安全协议包括？（多选）', 'multiple_choice', 2, 'hard',
  '[{"key": "A", "text": "WEP"},
    {"key": "B", "text": "WPA"},
    {"key": "C", "text": "WPA2"},
    {"key": "D", "text": "WPA3"},
    {"key": "E", "text": "RADIUS"}]'),

(3, '网络故障排除方法包括？（多选）', 'multiple_choice', 2, 'hard',
  '[{"key": "A", "text": "分层法"},
    {"key": "B", "text": "替换法"},
    {"key": "C", "text": "排除法"},
    {"key": "D", "text": "对比法"},
    {"key": "E", "text": "日志分析法"}]');

-- 判断题（无需选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty) VALUES
(3, 'OSPF是一种距离矢量路由协议。', 'true_false', 1, 'medium'),
(3, '交换机可以隔离广播域。', 'true_false', 1, 'medium'),
(3, 'TCP提供可靠的数据传输服务。', 'true_false', 1, 'easy'),
(3, '/24子网掩码是255.255.255.0。', 'true_false', 1, 'easy'),
(3, 'VLAN 1是默认的管理VLAN。', 'true_false', 1, 'medium'),
(3, '路由器可以分割冲突域。', 'true_false', 1, 'medium'),
(3, 'DHCP服务器可以分配DNS服务器地址。', 'true_false', 1, 'easy'),
(3, 'ACL可以应用于出方向和入方向。', 'true_false', 1, 'medium'),
(3, 'NAT技术可以解决IP地址短缺问题。', 'true_false', 1, 'easy'),
(3, 'OSPF协议支持VLSM。', 'true_false', 1, 'hard');

-- 填空题（无需选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty) VALUES
(3, 'OSPF协议中，RouterDeadInterval的缺省值是______秒。', 'fill_in_blank', 1, 'hard'),
(3, '在华为设备中，保存配置的命令是______。', 'fill_in_blank', 1, 'easy'),
(3, 'TCP协议中，用于流量控制的机制是______。', 'fill_in_blank', 1, 'medium'),
(3, 'IP地址127.0.0.1表示______。', 'fill_in_blank', 1, 'easy'),
(3, 'STP协议中，根桥的选择依据是______最小的设备。', 'fill_in_blank', 1, 'medium'),
(3, '在子网划分中，/30子网支持______个可用主机地址。', 'fill_in_blank', 1, 'hard'),
(3, 'DHCP协议中，客户端发送的第一个消息是______。', 'fill_in_blank', 1, 'medium'),
(3, 'ACL中，deny语句的规则号是______。', 'fill_in_blank', 1, 'hard'),
(3, 'NAT技术中，PAT使用______区分不同连接。', 'fill_in_blank', 1, 'hard'),
(3, 'OSPF协议中，骨干区域的Area ID是______。', 'fill_in_blank', 1, 'hard');

-- 简答题（无需选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty) VALUES
(3, '简述DHCP的工作过程。', 'short_answer', 5, 'medium'),
(3, '解释VLAN的作用和工作原理。', 'short_answer', 5, 'medium'),
(3, '比较OSPF和RIP路由协议的优缺点。', 'short_answer', 5, 'hard'),
(3, '简述ACL的作用和分类。', 'short_answer', 5, 'medium');

-- 综合应用题（无需选项）
INSERT INTO questions (subject_id, question, question_type, score, difficulty) VALUES
(3, '设计一个企业网络方案，要求：1) 总部与两个分支机构通过VPN连接；2) 总部使用OSPF作为内部路由协议；3) 分支机构使用静态路由；4) 描述网络地址规划和路由配置要点。', 'comprehensive', 10, 'hard'),
(3, '某公司网络拓扑如下：核心交换机连接4个接入交换机，每个接入交换机连接20台PC。要求：1) 设计VLAN划分方案；2) 配置DHCP服务器；3) 实现访问控制策略；4) 描述STP配置要点。', 'comprehensive', 10, 'hard');

-- ===== 插入答案 =====
-- IPv6答案
INSERT INTO answers (question_id, answer, explanation, correct_key) VALUES
-- 单选题
(1, 'C', 'IPv6地址长度为128位', 'C'),
(2, 'A', '正确压缩形式是2001:db8:85a3::8a2e:370:7334', 'A'),
(3, 'A', '链路本地地址前缀为fe80::/10', 'A'),
(4, 'D', 'IPv6没有广播地址', 'D'),
(5, 'A', '组播地址范围是ff00::/8', 'A'),
(6, 'A', '全球单播地址前缀是2000::/3', 'A'),
(7, 'A', '::1是IPv6的环回地址', 'A'),
(8, 'A', '未指定地址是::', 'A'),
(9, 'C', 'IPv6地址由8组组成', 'C'),
(10, 'A', '唯一本地地址前缀是fc00::/7', 'A'),
(11, 'A', '被唯一本地地址替代', 'A'),
(12, 'A', '组播地址前缀是ff00::/8', 'A'),
(13, 'A', '发送到最近的一组中的一个', 'A'),
(14, 'C', '接口标识符长度64位', 'C'),
(15, 'A', '本地链路范围内有效', 'A'),
(16, 'A', '全局路由前缀+子网ID+接口标识符', 'A'),
(17, 'A', 'T=1表示基于网络前缀的组播地址', 'A'),
(18, 'A', '前缀是ff02::1:ff00:0/104', 'A'),
(19, 'A', '格式是::ffff:0:0/96', 'A'),
(20, 'A', '兼容IPv4地址格式是::/96', 'A'),

-- 多选题
(21, 'A,C,D', '优势：更大的地址空间、增强的安全性、即插即用', 'A,C,D'),
(22, 'A,B,C', '地址类型：单播、组播、任播', 'A,B,C'),
(23, 'A,B,C', '过渡技术：双栈、隧道、协议转换', 'A,B,C'),
(24, 'A,B,C', '功能：地址解析、路由器发现、邻居不可达检测', 'A,B,C'),
(25, 'A,B', '自动配置类型：无状态、有状态', 'A,B'),
(26, 'A,B,C', '扩展头部：逐跳选项头、路由头、分片头', 'A,B,C'),
(27, 'A,B,C', '安全机制：IPsec集成、数据加密、身份验证', 'A,B,C'),
(28, 'A,B,E', '规则：前导零可省略、连续零组可用::代替、只能使用一次::', 'A,B,E'),
(29, 'A,B,C', '分配方式：手动配置、无状态自动配置、有状态自动配置', 'A,B,C'),
(30, 'A,B,C', '路由协议：RIPng、OSPFv3、BGP4+', 'A,B,C'),

-- 判断题
(31, '错误', '只能使用一个::进行压缩', 'false'),
(32, '正确', '::1是IPv6的环回地址', 'true'),
(33, '正确', 'IPv6地址空间足够大，不需要NAT', 'true'),
(34, '正确', 'IPv6为128位，IPv4为32位', 'true'),
(35, '正确', '全球单播地址范围', 'true'),
(36, '正确', '链路本地地址前缀', 'true'),
(37, '正确', '任播地址可分配给多个接口', 'true'),
(38, '正确', '组播地址前缀', 'true'),
(39, '正确', 'IPv6地址格式', 'true'),
(40, '错误', 'IPv6支持无状态自动配置，但仍可使用DHCPv6', 'false'),

-- 填空题
(41, '8', 'IPv6地址由8组16位十六进制数组成', ''),
(42, '::', '未指定地址', ''),
(43, '2000::/3', '全球单播地址范围', ''),
(44, 'fe80::/10', '链路本地地址前缀', ''),
(45, '::', '零压缩规则', ''),
(46, 'ARP', '邻居发现替代ARP', ''),
(47, 'MAC', '基于MAC地址生成', ''),
(48, '最近', '任播地址特点', ''),
(49, 'ff02::1:ff00:0/104', '被请求节点组播地址', ''),
(50, '2002::/16', '6to4隧道地址', ''),

-- 简答题
(51, '1. 单播地址：一对一通信\n2. 组播地址：一对多通信\n3. 任播地址：一对最近的一组中的一个', '三种地址类型及其用途', ''),
(52, '1. 地址解析（替代ARP）\n2. 路由器发现\n3. 邻居不可达检测\n4. 重定向功能', '邻居发现协议的主要功能', ''),
(53, '1. 更大的地址空间（128位）\n2. 简化的报文头\n3. 增强的安全性（IPsec集成）\n4. 更好的QoS支持\n5. 即插即用（自动配置）', 'IPv6主要优势', ''),
(54, '1. 路由器发送RA消息\n2. 主机根据RA生成地址\n3. 地址冲突检测（DAD）\n4. 地址配置完成', '自动配置过程', ''),

-- 综合题
(55, '子网划分方案：\n1. 使用前52位作为前缀（2001:db8:abcd:0000::/52）\n2. 每个子网有16位子网ID（2^16=65536个子网）\n3. 每个子网主机位64位（2^64主机）\n4. 第一个子网范围：2001:db8:abcd:0000:: - 2001:db8:abcd:0000:ffff:ffff:ffff:ffff', '子网划分方案', ''),
(56, '过渡方案：\n1. 初期：双栈技术（设备同时支持IPv4/IPv6）\n2. 中期：隧道技术（6to4, Teredo）\n3. 后期：协议转换（NAT64/DNS64）\n4. 最终：纯IPv6网络', 'IPv6过渡方案', '');

-- SDN答案
INSERT INTO answers (question_id, answer, explanation, correct_key) VALUES
-- 单选题
(57, 'A', '核心组件是控制器', 'A'),
(58, 'A', '默认端口6633', 'A'),
(59, 'A', '负责集中控制的是SDN控制器', 'A'),
(60, 'A', '流表项不包含TTL字段', 'A'),
(61, 'A', '不包括传输层', 'A'),
(62, 'A', 'Cisco IOS不是SDN控制器', 'A'),
(63, 'A', '将无法处理的数据包发送给控制器', 'A'),
(64, 'A', 'SNMP不是主要南向协议', 'A'),
(65, 'A', '0-65535', 'A'),
(66, 'A', '没有OpenFlow 4.0', 'A'),
(67, 'A', '硬件依赖不是SDN特征', 'A'),
(68, 'A', '修改流表', 'A'),
(69, 'A', '南向接口', 'A'),
(70, 'A', 'ovs-ofctl dump-flows', 'A'),
(71, 'A', '将网络功能从专用硬件解耦', 'A'),
(72, 'A', '不能匹配应用层数据', 'A'),
(73, 'A', '为应用程序提供网络抽象', 'A'),
(74, 'A', '最多255个', 'A'),
(75, 'D', '不包括单点模式', 'D'),
(76, 'A', '实现组播和负载均衡', 'A'),

-- 多选题
(77, 'A,B,C', '应用层、控制层、基础设施层', 'A,B,C'),
(78, 'A,B,C', '控制器到交换机、异步、对称', 'A,B,C'),
(79, 'A,B,C', '网络拓扑发现、流表管理、策略下发', 'A,B,C'),
(80, 'A,B,C', '网络可编程性、集中管理、快速创新', 'A,B,C'),
(81, 'A,B,C', '匹配字段、指令、计数器', 'A,B,C'),
(82, 'A,B,C', 'OpenFlow、OVSDB、NETCONF', 'A,B,C'),
(83, 'A,B,C', '数据中心网络、广域网、5G网络', 'A,B,C'),
(84, 'A,B,C', '输出、丢弃、修改字段', 'A,B,C'),
(85, 'A,B,C', 'VxLAN、Geneve、网络切片', 'A,B,C'),
(86, 'A,B,C', '安全性、可扩展性、标准化', 'A,B,C'),

-- 判断题
(87, '正确', 'SDN核心思想', 'true'),
(88, '错误', '还有OVSDB等其他南向协议', 'false'),
(89, '正确', 'OVSDB用于配置管理', 'true'),
(90, '错误', '可分布式部署', 'false'),
(91, '正确', 'OpenFlow支持IPv6', 'true'),
(92, '正确', '北向接口作用', 'true'),
(93, '错误', '交换机可实现部分功能', 'false'),
(94, '正确', 'SDN优势', 'true'),
(95, '正确', '优先级数值越大优先级越高', 'true'),
(96, '错误', '适用于多种网络场景', 'false'),

-- 填空题
(97, 'Software Defined Networking', 'SDN全称', ''),
(98, 'TLS/SSL', '安全通信通道', ''),
(99, 'ovs-ofctl dump-flows', '查看流表命令', ''),
(100, '控制层', 'SDN三层架构', ''),
(101, 'OpenFlow 1.5', '当前最新版本', ''),
(102, '网络功能虚拟化(NFV)', 'NFV技术', ''),
(103, '6633', '控制器监听端口', ''),
(104, 'OpenFlow', '主要南向协议', ''),
(105, 'Packet-in', '未匹配时的消息', ''),
(106, '网络切片', '实现多租户隔离', ''),

-- 简答题
(107, '1. 集中控制，简化管理\n2. 网络可编程性\n3. 快速创新\n4. 资源优化', 'SDN主要优势', ''),
(108, '流表结构：匹配字段+指令+计数器\n工作原理：数据包进入后按优先级匹配流表项，执行对应指令', 'OpenFlow工作原理', ''),
(109, '1. 控制与转发分离\n2. 集中控制 vs 分布式控制\n3. 开放接口 vs 封闭系统\n4. 软件定义 vs 硬件固定', 'SDN与传统网络区别', ''),
(110, '1. 网络拓扑发现\n2. 流表管理\n3. 策略下发\n4. 状态监控', '控制器功能', ''),

-- 综合题
(111, 'QoS方案：\n1. 控制器收集拓扑和流量信息\n2. 定义用户组和应用优先级策略\n3. 下发流表实现带宽保障和优先级队列\n4. 实时监控调整策略', 'SDN QoS方案', ''),
(112, '安全系统：\n1. 控制器监控流量特征，检测异常\n2. 发现攻击后，重定向流量到清洗设备\n3. 下发流表隔离攻击源\n4. 清洗后流量回注', 'SDN安全防护', '');

-- HCIA答案
INSERT INTO answers (question_id, answer, explanation, correct_key) VALUES
-- 单选题
(113, 'A', '手动配置的最高IP地址优先', 'A'),
(114, 'A', '最小的桥ID', 'A'),
(115, 'A', '255.255.255.0', 'A'),
(116, 'A', '三次握手', 'A'),
(117, 'D', '10.0.0.0/8,172.16.0.0/12,192.168.0.0/16', 'D'),
(118, 'A', '分割广播域', 'A'),
(119, 'A', '网络层', 'A'),
(120, 'A', '自动分配IP地址', 'A'),
(121, 'A', '源IP地址', 'A'),
(122, 'A', 'IPv4地址短缺', 'A'),
(123, 'A', 'Full', 'A'),
(124, 'A', '48位', 'A'),
(125, 'A', '2000::/3', 'A'),
(126, 'A', '默认路由', 'A'),
(127, 'A', '传递控制消息', 'A'),
(128, 'A', 'display ip routing-table', 'A'),
(129, 'A', '跨交换机传输多个VLAN数据', 'A'),
(130, 'A', '10秒', 'A'),
(131, 'A', '到根桥路径开销最小的端口', 'A'),
(132, 'A', 'ESP', 'A'),

-- 多选题
(133, 'A,B,C', '距离矢量协议、链路状态协议、路径矢量协议', 'A,B,C'),
(134, 'A,B,C,D', '星型、环型、总线型、网状', 'A,B,C,D'),
(135, 'A,B,C', '面向连接、可靠传输、流量控制', 'A,B,C'),
(136, 'A,B,C', '分割广播域、提高安全性、简化管理', 'A,B,C'),
(137, 'A,B,C,D', '防火墙、入侵检测、VPN、ACL', 'A,B,C,D'),
(138, 'A,B,C', 'PPP、Frame Relay、MPLS', 'A,B,C'),
(139, 'A,B,C', '地址空间大、简化头部、安全性增强', 'A,B,C'),
(140, 'A,B,C,D', '分类、标记、队列、拥塞避免', 'A,B,C,D'),
(141, 'A,B,C', 'WEP、WPA、WPA2', 'A,B,C'),
(142, 'A,B,C', '分层法、替换法、排除法', 'A,B,C'),

-- 判断题
(143, '错误', 'OSPF是链路状态协议', 'false'),
(144, '错误', '交换机分割冲突域，路由器分割广播域', 'false'),
(145, '正确', 'TCP提供可靠传输', 'true'),
(146, '正确', '/24对应255.255.255.0', 'true'),
(147, '正确', 'VLAN 1是默认管理VLAN', 'true'),
(148, '正确', '路由器分割广播域', 'true'),
(149, '正确', 'DHCP可分配IP、掩码、网关、DNS等', 'true'),
(150, '正确', 'ACL可应用于进出方向', 'true'),
(151, '正确', 'NAT解决地址短缺问题', 'true'),
(152, '正确', 'OSPF支持VLSM', 'true'),

-- 填空题
(153, '40', 'RouterDeadInterval为Hello间隔的4倍', ''),
(154, 'save', '保存配置命令', ''),
(155, '滑动窗口', 'TCP流量控制机制', ''),
(156, '环回地址', '127.0.0.1含义', ''),
(157, '桥ID', '根桥选择依据', ''),
(158, '2', '/30子网有4个地址，2个可用', ''),
(159, 'DHCP Discover', '客户端第一个消息', ''),
(160, '5', 'deny语句规则号', ''),
(161, '端口号', 'PAT使用端口号区分', ''),
(162, '0', '骨干区域Area 0', ''),

-- 简答题
(163, '1. Discover广播发现服务器\n2. Offer服务器提供IP\n3. Request客户端请求IP\n4. Ack服务器确认分配', 'DHCP工作过程', ''),
(164, '作用：分割广播域，提高安全性和管理灵活性\n原理：基于端口或标签划分逻辑网络', 'VLAN作用原理', ''),
(165, 'OSPF优点：快速收敛，支持大规模网络，无跳数限制\n缺点：配置复杂，资源消耗大\nRIP优点：配置简单，资源消耗小\n缺点：跳数限制，收敛慢', 'OSPF与RIP比较', ''),
(166, '作用：控制网络访问，提高安全性\n分类：基本ACL（2000-2999），高级ACL（3000-3999）', 'ACL作用分类', ''),

-- 综合题
(167, '方案：\n1. 总部：10.0.0.0/16，分支机构：10.1.0.0/16，10.2.0.0/16\n2. 总部配置OSPF，通告内部网络\n3. 分支机构配置静态路由指向总部\n4. 建立IPSec VPN隧道', '企业网络方案', ''),
(168, '方案：\n1. 按部门划分VLAN：VLAN10(市场), VLAN20(研发)\n2. 核心交换机配置DHCP中继\n3. 接入交换机配置端口安全\n4. 配置RSTP防止环路', '公司网络方案', '');

-- 创建应用用户
CREATE USER 'deepseek_app'@'localhost' IDENTIFIED BY 'DeepSeek123!';
GRANT ALL PRIVILEGES ON knowledge_db.* TO 'deepseek_app'@'localhost';
FLUSH PRIVILEGES;