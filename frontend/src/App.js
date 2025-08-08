import React, { useState, useEffect } from 'react';
import './App.css';

// 获取API基础URL
const API_BASE = "http://localhost:5001";

function App() {
  const [subjects, setSubjects] = useState([]);
  const [selectedSubject, setSelectedSubject] = useState('');
  const [question, setQuestion] = useState('');
  const [answer, setAnswer] = useState('');
  const [result, setResult] = useState('');
  const [loading, setLoading] = useState(false);
  const [history, setHistory] = useState([]);
  const [apiStatus, setApiStatus] = useState({ 
    subjects: 'pending', 
    generate: 'idle',
    judge: 'idle'
  });

  // 加载学科列表
  useEffect(() => {
    const fetchSubjects = async () => {
      try {
        setApiStatus(prev => ({...prev, subjects: 'loading'}));
       
        const response = await fetch(`${API_BASE}/api/subjects`); 
        console.log("收到响应:", response.status);       
  
        if (!response.ok) {
          const errorText = await response.text();
          console.error("API 请求失败:", response.status, errorText);
          throw new Error(`API 请求失败: ${response.status} ${errorText}`); 
        }
        
        const data = await response.json();
        console.log("解析的学科数据:", data);
        setSubjects(data);
        
        if (data.length > 0) {
          setSelectedSubject(data[0].name);
        }
        
        setApiStatus(prev => ({...prev, subjects: 'success'}));
      } catch (error) {
        console.error('加载学科失败:', error);
        setApiStatus(prev => ({...prev, subjects: 'error'}));
 
        // 后备学科数据
        const fallbackSubjects = [
          { id: 1, name: "数学", description: "数学相关题目" },
          { id: 2, name: "物理", description: "物理相关题目" },
          { id: 3, name: "化学", description: "化学相关题目" },
          { id: 4, name: "生物", description: "生物相关题目" }
        ];

        console.log("使用后备学科数据"); 
        setSubjects(fallbackSubjects);
        setSelectedSubject(fallbackSubjects[0].name);
      }
    };
    
    fetchSubjects();   
 
    // 加载历史记录
    const savedHistory = localStorage.getItem('questionHistory');
    if (savedHistory) {
      try {
        setHistory(JSON.parse(savedHistory));
      } catch (e) {
        console.error('解析历史记录失败:', e);
        localStorage.removeItem('questionHistory');
      }
    }
  }, []);

  // 保存历史记录
  useEffect(() => {
    if (history.length > 0) {
      localStorage.setItem('questionHistory', JSON.stringify(history));
    }
  }, [history]);

  // 生成题目
  const generateQuestion = async () => {
    if (loading) return;  // 防止重复点击
 
    setLoading(true);
    setApiStatus(prev => ({...prev, generate: 'loading'}));
    
    try {
      const response = await fetch(`${API_BASE}/api/generate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ subject: selectedSubject })
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`请求失败: ${response.status} ${errorText}`);
      }

      const data = await response.json();
      setQuestion(data.question);
      setAnswer('');
      setResult('');
      
      // 添加到历史记录
      setHistory(prev => [
        ...prev, 
        {
          subject: selectedSubject,
          question: data.question,
          timestamp: new Date().toISOString()
        }
      ]);
      
      setApiStatus(prev => ({...prev, generate: 'success'}));
    } catch (error) {
      console.error('生成题目失败:', error);
      setResult(`生成题目失败: ${error.message}`);
      setApiStatus(prev => ({...prev, generate: 'error'}));
    } finally {
      setLoading(false);
    }
  };

  // 提交答案
  const submitAnswer = async () => {
    if (!answer || !question) return;
    
    setLoading(true);
    setApiStatus(prev => ({...prev, judge: 'loading'}));
    
    try {
      const response = await fetch(`${API_BASE}/api/judge`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question, answer })
      });
 
      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`请求失败: ${response.status} ${errorText}`);
      }
      
      const data = await response.json();
      setResult(data.result);
      
      // 更新历史记录
      setHistory(prev => prev.map(item => 
        item.question === question 
          ? {...item, answer, result: data.result} 
          : item
      ));
      
      setApiStatus(prev => ({...prev, judge: 'success'}));
    } catch (error) {
      console.error('提交答案失败:', error);
      setResult(`提交答案失败: ${error.message}`);
      setApiStatus(prev => ({...prev, judge: 'error'}));
    } finally {
      setLoading(false);
    }
  };

  // 加载历史题目
  const loadHistoryQuestion = (item) => {
    setSelectedSubject(item.subject);
    setQuestion(item.question);
    setAnswer(item.answer || '');
    setResult(item.result || '');
  };

  // API状态显示文本
  const getStatusText = (status) => {
    const statusMap = {
      pending: '等待',
      loading: '加载中',
      success: '成功',
      error: '错误',
      idle: '空闲'
    };
    return statusMap[status] || status;
  };

  return (
    <div className="app">
      <header>
        <div className="logo">
          <span className="logo-deep">Deep</span>
          <span className="logo-seek">Seek</span>
          <span className="logo-edu">学习助手</span>
        </div>
        
        {/* API 状态指示器 */}
        <div className="api-status-container">
          <div className={`api-status ${apiStatus.subjects}`}>
            学科加载: {getStatusText(apiStatus.subjects)}
          </div>
          <div className={`api-status ${apiStatus.generate}`}>
            题目生成: {getStatusText(apiStatus.generate)}
          </div>
          <div className={`api-status ${apiStatus.judge}`}>
            判题服务: {getStatusText(apiStatus.judge)}
          </div>
          <div className="env-indicator">
            环境: {process.env.REACT_APP_ENV} | API: {API_BASE}
          </div>
        </div>
      </header> 
      
      <div className="main-container">
        <div className="control-panel">
          <div className="subject-selector">
            <label>选择学科:</label>
            <select 
              value={selectedSubject} 
              onChange={(e) => setSelectedSubject(e.target.value)}
              disabled={loading}
            >
              {subjects.map(subject => (
                <option key={subject.id} value={subject.name}>
                  {subject.name}
                </option>
              ))}
            </select>
          </div>
          
          <button 
            className="generate-btn"
            onClick={generateQuestion} 
            disabled={loading}
          >
            {loading ? '题目生成中...' : '生成新题目'}
          </button>
        </div>
        
        {question && (
          <div className="question-box">
            <div className="question-header">
              <span className="subject-tag">{selectedSubject}</span>
              <h3>题目:</h3>
            </div>
            <div className="question-content">{question}</div>
            
            <div className="answer-section">
              <h3>你的答案:</h3>
              <textarea
                value={answer}
                onChange={(e) => setAnswer(e.target.value)}
                placeholder="在此输入您的答案..."
                rows={4}
                disabled={loading}
              />
            </div>
            
            <button 
              className="submit-btn"
              onClick={submitAnswer} 
              disabled={loading || !answer}
            >
              {loading ? '判题中...' : '提交答案'}
            </button>
          </div>
        )}
        
        {result && (
          <div className="result-box">
            <h3>批改结果:</h3>
            <div className="result-content">{result}</div>
          </div>
        )}
        
        {history.length > 0 && (
          <div className="history-panel">
            <h3>历史记录</h3>
            <div className="history-list">
              {history.slice().reverse().map((item, index) => (
                <div 
                  key={index} 
                  className={`history-item ${item.question === question ? 'active' : ''}`}
                  onClick={() => loadHistoryQuestion(item)}
                >
                  <div className="history-subject">{item.subject}</div>
                  <div className="history-question">
                    {item.question.length > 50 
                      ? item.question.substring(0, 50) + '...' 
                      : item.question}
                  </div>
                  <div className="history-time">
                    {new Date(item.timestamp).toLocaleString()}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
      
      <footer>
        <p>DeepSeek 学习助手 v1.0 &copy; {new Date().getFullYear()}</p>
      </footer>
    </div>
  );
}

export default App;
