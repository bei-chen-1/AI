import {Routes, Route, Link } from 'react-router-dom';
import AIChatPage from './pages/AIChatPage';
import TopologyEditorPage from './pages/TopologyEditorPage';
import React, { useState, useEffect } from 'react';
import './App.css';

// 获取API基础URL
const API_BASE = "http://localhost:5001";

// 本地存储键名
const HISTORY_KEY = "examHistory";

function App() {
  const [subjects, setSubjects] = useState([]);
  const [selectedSubject, setSelectedSubject] = useState('');
  const [exam, setExam] = useState(null);
  const [answers, setAnswers] = useState({});
  const [results, setResults] = useState(null);
  const [loading, setLoading] = useState(false);
  const [apiStatus, setApiStatus] = useState({
    subjects: 'pending',
    generate: 'idle',
    judge: 'idle'
  });
  
  // 新增：历史记录状态
  const [history, setHistory] = useState([]);
  const [showHistory, setShowHistory] = useState(false); // 修复变量名
  const [activeHistoryId, setActiveHistoryId] = useState(null);

  // 加载学科列表
  useEffect(() => {
    const fetchSubjects = async () => {
      try {
        setApiStatus(prev => ({...prev, subjects: 'loading'}));
        const response = await fetch(`${API_BASE}/api/subjects`);

        if (!response.ok) {
          const errorText = await response.text();
          throw new Error(`API请求失败: ${response.status} ${errorText}`);
        }

        const data = await response.json();
        setSubjects(data);
        setApiStatus(prev => ({...prev, subjects: 'success'}));
      } catch (error) {
        console.error('加载学科失败:', error);
        setApiStatus(prev => ({...prev, subjects: 'error'}));

        // 后备学科数据
        const fallbackSubjects = [
          { id: 1, name: "IPv6", description: "IPv6协议相关题目" },
          { id: 2, name: "SDN", description: "软件定义网络题目" },
          { id: 3, name: "HCIA", description: "华为认证网络工程师题目" }
        ];

        setSubjects(fallbackSubjects);
      }
    };

    fetchSubjects();
  }, []);

  // 新增：从本地存储加载历史记录
  useEffect(() => {
    const savedHistory = localStorage.getItem(HISTORY_KEY);
    if (savedHistory) {
      try {
        const parsedHistory = JSON.parse(savedHistory);
        setHistory(parsedHistory);
      } catch (e) {
        console.error("解析历史记录失败:", e);
        localStorage.removeItem(HISTORY_KEY);
      }
    }
  }, []);

  // 新增：保存历史记录到本地存储
  const saveHistory = (newHistory) => {
    setHistory(newHistory);
    localStorage.setItem(HISTORY_KEY, JSON.stringify(newHistory));
  };

  // 新增：加载历史试卷
  const loadHistoryExam = (historyItem) => {
    setExam(historyItem.exam);
    setAnswers(historyItem.answers);
    setResults(historyItem.results);
    setActiveHistoryId(historyItem.id);
    setShowHistory(false);
  };

  // 新增：清除历史记录
  const clearHistory = () => {
    if (window.confirm("确定要清除所有历史记录吗？此操作不可撤销。")) {
      setHistory([]);
      localStorage.removeItem(HISTORY_KEY);
      setActiveHistoryId(null);
    }
  };

  // 生成试卷
  const generateExam = async () => {
    if (!selectedSubject) return;

    setLoading(true);
    setApiStatus(prev => ({...prev, generate: 'loading'}));

    try {
      const response = await fetch(`${API_BASE}/api/generate_exam`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ subject: selectedSubject })
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`请求失败: ${response.status} ${errorText}`);
      }

      const data = await response.json();
      console.log("试卷数据:", data); // 调试日志

      // 初始化答案对象
      const initialAnswers = {};
      data.questions.forEach(question => {
        if (question.type === 'multiple_choice') {
          initialAnswers[question.id] = [];
        } else {
          initialAnswers[question.id] = '';
        }
      });

      setExam(data);
      setAnswers(initialAnswers);
      setResults(null);
      setApiStatus(prev => ({...prev, generate: 'success'}));
      setActiveHistoryId(null); // 重置活动历史ID
    } catch (error) {
      console.error('生成试卷失败:', error);
      setApiStatus(prev => ({...prev, generate: 'error'}));
    } finally {
      setLoading(false);
    }
  };

  // 处理单选题变化
  const handleSingleChoice = (questionId, optionKey) => {
    setAnswers(prev => ({
      ...prev,
      [questionId]: optionKey
    }));
  };

  // 处理多选题变化
  const handleMultipleChoice = (questionId, optionKey) => {
    setAnswers(prev => {
      const current = prev[questionId] || [];
      let newValue;

      if (current.includes(optionKey)) {
        newValue = current.filter(key => key !== optionKey);
      } else {
        newValue = [...current, optionKey];
      }

      return {
        ...prev,
        [questionId]: newValue
      };
    });
  };

  // 处理判断题变化
  const handleTrueFalse = (questionId, value) => {
    setAnswers(prev => ({
      ...prev,
      [questionId]: value
    }));
  };

  // 处理填空题和主观题变化
  const handleTextAnswer = (questionId, value) => {
    setAnswers(prev => ({
      ...prev,
      [questionId]: value
    }));
  };

  // 提交试卷
  const submitExam = async () => {
    if (!exam || Object.keys(answers).length === 0) return;

    setLoading(true);
    setApiStatus(prev => ({...prev, judge: 'loading'}));

    try {
      // 准备答案数据
      const answerData = exam.questions.map(question => {
        let userAnswer = answers[question.id];

        // 处理多选题格式（数组转逗号分隔字符串）
        if (question.type === 'multiple_choice' && Array.isArray(userAnswer)) {
          userAnswer = userAnswer.join(',');
        }

        return {
          question_id: question.id,
          type: question.type,
          answer: userAnswer || '', // 确保不会发送undefined
          score: question.score,
          question_text: question.question // 添加问题文本用于主观题判分
        };
      });

      console.log("提交的答案数据:", answerData); // 调试日志

      const response = await fetch(`${API_BASE}/api/judge_exam`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ answers: answerData })
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`请求失败: ${response.status} ${errorText}`);
      }

      const data = await response.json();
      setResults(data);
      setApiStatus(prev => ({...prev, judge: 'success'}));
      
      // 新增：保存到历史记录
      const newHistoryItem = {
        id: Date.now(), // 使用时间戳作为唯一ID
        subject: exam.subject,
        date: new Date().toLocaleString(),
        exam: exam,
        answers: {...answers}, // 保存当前答案
        results: data, // 保存判卷结果
        totalScore: data.total_score
      };
      
      const newHistory = [newHistoryItem, ...history]; // 新的历史记录放在前面
      saveHistory(newHistory);
      setActiveHistoryId(newHistoryItem.id);
    } catch (error) {
      console.error('提交试卷失败:', error);
      setApiStatus(prev => ({...prev, judge: 'error'}));
    } finally {
      setLoading(false);
    }
  };

  // 获取题目类型名称
  const getQuestionTypeName = (type) => {
    const typeNames = {
      'single_choice': '单选题',
      'multiple_choice': '多选题',
      'true_false': '判断题',
      'fill_in_blank': '填空题',
      'short_answer': '简答题',
      'comprehensive': '综合应用题'
    };
    return typeNames[type] || type;
  };

  // 格式化答案显示（特别是将 true/false 转换为中文）
  const formatAnswerDisplay = (answer, type) => {
    if (type === 'true_false') {
      if (answer === 'true') return '正确';
      if (answer === 'false') return '错误';
    }
    return answer;
  };

  // 渲染选项
  const renderOptions = (options, questionId, type) => {
    if (!Array.isArray(options)) {
      options = [];
    }

    return (
        <div className="options">
          {options.map(option => (
              <label key={option.key}>
                {type === 'single_choice' ? (
                    <input
                        type="radio"
                        name={`q_${questionId}`}
                        value={option.key}
                        checked={answers[questionId] === option.key}
                        onChange={() => handleSingleChoice(questionId, option.key)}
                        disabled={loading || results}
                    />
                ) : (
                    <input
                        type="checkbox"
                        value={option.key}
                        onChange={() => handleMultipleChoice(questionId, option.key)}
                        checked={answers[questionId]?.includes(option.key) || false}
                        disabled={loading || results}
                    />
                )}
                <span className="option-text">
                {option.key}. {option.text}
              </span>
              </label>
          ))}
        </div>
    );
  };

  // 渲染题目输入组件
  const renderAnswerInput = (question) => {
    const result = results?.results.find(r => r.question_id === question.id);

    if (result) {
      return (
          <div className="result-box">
            <div className={`result-score ${result.score > 0 ? 'correct' : 'incorrect'}`}>
              得分: {result.score}/{question.score}
            </div>
            <div className="result-feedback">
              <p><strong>你的答案:</strong> {formatAnswerDisplay(result.user_answer, question.type)}</p>
              <p><strong>正确答案:</strong> {formatAnswerDisplay(result.correct_answer, question.type)}</p>
              {result.explanation && (
                  <p><strong>解析:</strong> {result.explanation}</p>
              )}
              {result.ai_response && (
                  <p><strong>AI评语:</strong> {result.ai_response}</p>
              )}
            </div>
          </div>
      );
    }

    switch(question.type) {
      case 'single_choice':
        return renderOptions(question.options, question.id, question.type);

      case 'multiple_choice':
        return renderOptions(question.options, question.id, question.type);

      case 'true_false':
        return (
            <div className="options">
              <label>
                <input
                    type="radio"
                    name={`q_${question.id}`}
                    value="true"
                    checked={answers[question.id] === 'true'}
                    onChange={() => handleTrueFalse(question.id, 'true')}
                    disabled={loading || results}
                />
                正确
              </label>
              <label>
                <input
                    type="radio"
                    name={`q_${question.id}`}
                    value="false"
                    checked={answers[question.id] === 'false'}
                    onChange={() => handleTrueFalse(question.id, 'false')}
                    disabled={loading || results}
                />
                错误
              </label>
            </div>
        );

      case 'fill_in_blank':
        return (
            <input
                type="text"
                className="blank-input"
                placeholder="请输入答案"
                value={answers[question.id] || ''}
                onChange={(e) => handleTextAnswer(question.id, e.target.value)}
                disabled={loading || results}
            />
        );

      default:
        return (
            <textarea
                className="answer-textarea"
                rows={4}
                placeholder="请输入您的答案..."
                value={answers[question.id] || ''}
                onChange={(e) => handleTextAnswer(question.id, e.target.value)}
                disabled={loading || results}
            />
        );
    }
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
          <div className="header-content">
            <div className="logo-container">
              <div className="logo">
                <span className="logo-deep">Deep</span>
                <span className="logo-seek">Seek</span>
                <span className="logo-edu">智能考试系统</span>
              </div>
              <div className="env-indicator">
                环境: {process.env.REACT_APP_ENV} | API: {API_BASE}
              </div>
            </div>
            {/* API 状态指示器 */}
            <div className="api-status-container">
              <div className={`api-status ${apiStatus.subjects}`}>
                学科: {getStatusText(apiStatus.subjects)}
              </div>
              <div className={`api-status ${apiStatus.generate}`}>
                组卷: {getStatusText(apiStatus.generate)}
              </div>
              <div className={`api-status ${apiStatus.judge}`}>
                判卷: {getStatusText(apiStatus.judge)}
              </div>
            </div>
          </div>
        </header>

        <div className="main-container">
          <Routes>
            <Route path="/ai-chat" element={<AIChatPage />} />
            <Route path="/topology-editor" element={<TopologyEditorPage />} />
            <Route path="/" element={
              <>
                {/* 欢迎消息和特性卡片 - 移动到控制面板上方 */}
                {!exam && !showHistory && (
                  <div className="welcome-container">
                    <div className="welcome-message">
                      <h3>欢迎使用DeepSeek智能考试系统</h3>
                      <p>请选择学科并点击"生成试卷"按钮开始考试</p>
                    </div>
                    
                    <div className="features">
                      <div className="feature-card">
                        <div className="feature-icon">📚</div>
                        <h4>智能组卷</h4>
                        <p>按标准试卷结构自动生成试题</p>
                        <div className="exam-structure">
                          <p><span className="exam-type">单选题</span> (每题1分，共20题，共20分)</p>
                          <p><span className="exam-type">多选题</span> (每题2分，共10题，共20分)</p>
                          <p><span className="exam-type">判断题</span> (每题1分，共10题，共10分)</p>
                          <p><span className="exam-type">填空题</span> (每空1分，共10空，共10分)</p>
                          <p><span className="exam-type">简答题</span> (每题5分，共4题，共20分)</p>
                          <p><span className="exam-type">综合应用题</span> (共2题，共20分)</p>
                        </div>
                      </div>
                      
                      <div className="feature-card">
                        <div className="feature-icon">✅</div>
                        <h4>自动批改</h4>
                        <p>客观题自动判分，主观题AI评分</p>
                        <div className="grading-details">
                          <p>• 单选题、多选题、判断题自动评分</p>
                          <p>• 填空题和简答题由AI智能评分</p>
                          <p>• 提供详细解析和参考答案</p>
                        </div>
                      </div>
                      
                      <div className="feature-card">
                        <div className="feature-icon">📊</div>
                        <h4>历史记录</h4>
                        <p>保存每次考试结果，方便复习回顾</p>
                        <div className="history-details">
                          <p>• 查看历史考试成绩</p>
                          <p>• 复习错题和解析</p>
                          <p>• 跟踪学习进度</p>
                        </div>
                      </div>
                    </div>
                  </div>
                )}

                <div className="control-panel">
                  <div className="subject-selector">
                    <label>选择学科:</label>
                    <select
                        value={selectedSubject}
                        onChange={(e) => setSelectedSubject(e.target.value)}
                        disabled={loading}
                    >
                      <option value="">-- 请选择学科 --</option>
                      {subjects.map(subject => (
                          <option key={subject.id} value={subject.name}>
                            {subject.name}
                          </option>
                      ))}
                    </select>
                  </div>

                  <div className="action-buttons">
                    <button
                        className="generate-btn"
                        onClick={generateExam}
                        disabled={!selectedSubject || loading}
                    >
                      {loading ? '试卷生成中...' : '生成试卷'}
                    </button>

                    {exam && (
                        <button
                            className="submit-btn"
                            onClick={submitExam}
                            disabled={loading || Object.keys(answers).length < exam.questions.length || results}
                        >
                          {loading ? '试卷批改中...' : '提交试卷'}
                        </button>
                    )}

                    {/* 新增：历史记录按钮 */}
                    <button 
                      className="history-btn"
                      onClick={() => setShowHistory(!showHistory)}
                    >
                      {showHistory ? '隐藏历史' : '历史记录'}
                    </button>

                    {/* 新增AI对话按钮 */}
                    <Link to="/ai-chat" className="ai-chat-btn">
                      AI对话
                    </Link>
                  </div>
                </div>

                {/* 新增：历史记录面板 */}
                {showHistory && (
                  <div className="history-panel">
                    <div className="history-header">
                      <h3>历史考试记录</h3>
                      <button className="clear-history-btn" onClick={clearHistory}>
                        清除记录
                      </button>
                    </div>
                    
                    {history.length === 0 ? (
                      <div className="empty-history">
                        <p>暂无历史考试记录</p>
                        <p>完成考试后，您的记录将显示在这里</p>
                      </div>
                    ) : (
                      <ul className="history-list">
                        {history.map(item => (
                          <li 
                            key={item.id} 
                            className={`history-item ${activeHistoryId === item.id ? 'active' : ''}`}
                            onClick={() => loadHistoryExam(item)}
                          >
                            <div className="history-content">
                              <div className="history-subject">{item.subject}</div>
                              <div className="history-date">{item.date}</div>
                            </div>
                            <div className="history-score">
                              <span className="score-value">{item.totalScore}</span>
                              <span className="score-total">/{item.exam.total_score}</span>
                            </div>
                          </li>
                        ))}
                      </ul>
                    )}
                  </div>
                )}

                {exam && (
                    <div className="exam-container">
                      <div className="exam-header">
                        <h2>{exam.subject}试卷 {activeHistoryId && <span className="history-tag">历史记录</span>}</h2>
                        <div className="exam-meta">
                          <span>总分: {exam.total_score}分</span>
                          <span>题数: {exam.questions.length}题</span>
                          {results && <span className="total-score">得分: {results.total_score}分</span>}
                          {activeHistoryId && <span className="history-date">完成时间: {history.find(h => h.id === activeHistoryId)?.date}</span>}
                        </div>
                      </div>

                      <div className="exam-paper">
                        {exam.questions.map((question, index) => (
                            <div key={question.id} className="question-item">
                              <div className="question-header">
                                <span className="question-number">{index + 1}.</span>
                                <span className="question-type">{getQuestionTypeName(question.type)}</span>
                                <span className="question-score">({question.score}分)</span>
                              </div>

                              <div className="question-content">{question.question}</div>

                              <div className="answer-section">
                                {renderAnswerInput(question)}
                              </div>
                            </div>
                        ))}
                      </div>
                    </div>
                )}
              </>
            } />
          </Routes>
        </div>

        <footer>
          <p>DeepSeek 智能考试系统 v2.1 &copy; {new Date().getFullYear()}</p>
          <p className="storage-info">
            您的考试记录已保存在本地存储中，清除浏览器数据将删除历史记录
          </p>
        </footer>
      </div>
  );
}

export default App;