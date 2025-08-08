import axios from 'axios';

// 在请求方法中直接修改
const fetchSubjects = async () => {
  try {
    // 修改端口为5001
    const response = await axios.get('http://localhost:5001/api/subjects');
    return response.data;
  } catch (error) {
    console.error('API请求失败:', error);
    throw error;
  }
};
