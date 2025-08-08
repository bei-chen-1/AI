import re

DEVICE_TYPES = {
    'router': {'name': '路由器'},
    'switch': {'name': '交换机'},
    'firewall': {'name': '防火墙'},
    'server': {'name': '服务器'},
    'host': {'name': '主机'},
    'ap': {'name': '无线AP'}
}

def convert_chinese_number(chinese_num):
    cn2num = {'一': 1, '二': 2, '三': 3, '四': 4, '五': 5,
              '六': 6, '七': 7, '八': 8, '九': 9, '十': 10}
    if not chinese_num:
        return 1
    if chinese_num.isdigit():
        return int(chinese_num)
    if chinese_num in cn2num:
        return cn2num[chinese_num]
    if chinese_num.startswith('十'):
        return 10 + cn2num.get(chinese_num[1], 0)
    return 1

def extract_device_layers(description):
    normalized = description.replace('连接着', '连接') \
        .replace('连接到', '连接') \
        .replace('相连', '连接') \
        .replace('下方是', '连接') \
        .replace('下方连接', '连接')

    segments = re.split(r'(?:连接|下面连接|下方连接)', normalized)

    layers = []
    for segment in segments:
        segment = segment.strip()
        if not segment:
            continue

        types = []
        for key, val in DEVICE_TYPES.items():
            matches = re.findall(rf'(?:[一二三四五六七八九十\d]*)(个)?{val["name"]}', segment)
            if matches:
                count_matches = re.findall(rf'([一二三四五六七八九十\d]+)?个?{val["name"]}', segment)
                if count_matches and isinstance(count_matches[0], (tuple, list)):
                    count_str = count_matches[0][0] or "1"
                elif isinstance(count_matches[0], str):
                    count_str = count_matches[0] or "1"
                else:
                    count_str = "1"
                count = convert_chinese_number(count_str)
                types.extend([key] * count)
        layers.append(types)

    return layers


def parse_topology_description(description):
    """
    从自然语言描述生成设备和连接列表，保持顺序，支持多设备并列连接。
    """
    devices = []
    connections = []
    id_counter = {}
    conn_id = 1
    device_layers = []
    layers = extract_device_layers(description)

    for layer in layers:
        device_ids = []
        for dtype in layer:
            index = id_counter.get(dtype, 1)
            device_id = f"{dtype}_{index}"
            device = {
                'id': device_id,
                'type': dtype,
                'label': f"{DEVICE_TYPES[dtype]['name']}_{index}",
                'position': {'x': 0, 'y': 0}
            }
            devices.append(device)
            device_ids.append(device_id)
            id_counter[dtype] = index + 1
        device_layers.append(device_ids)

    # 构建连接关系：每一层第一个设备连接下一层所有设备
    for i in range(len(device_layers) - 1):
        src = device_layers[i][0]
        for tgt in device_layers[i + 1]:
            connections.append({
                'id': f"conn_{conn_id}",
                'source': src,
                'target': tgt,
                'type': 'ethernet'
            })
            conn_id += 1

    return devices, connections

def generate_smart_layout(devices):
    y_order = {
        'router': 80, 'firewall': 160, 'switch': 240,
        'server': 320, 'host': 400, 'ap': 320
    }
    layer_count = {}
    for d in devices:
        y = y_order.get(d['type'], 300)
        x_index = layer_count.get(d['type'], 0)
        d['position']['x'] = 150 + x_index * 140
        d['position']['y'] = y
        layer_count[d['type']] = x_index + 1
    return devices

def generate_topology(description):
    devices, connections = parse_topology_description(description)
    devices = generate_smart_layout(devices)
    return {
        'devices': devices,
        'connections': connections
    }
