import React, { useState, useEffect } from 'react';
import './ExamPanel.css';

const ExamPanel = () => {
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
  const [timeLeft, setTimeLeft] = useState(7200); // 120分钟
  const [error, setError] = useState('');

  // 加载学科列表
  useEffect(() => {
    const fetchSubjects = async () => {
      try {
        setApiStatus(prev => ({...prev, subjects: 'loading'}));
        const response = await fetch('http://localhost:5001/api/subjects');

        if (!response.ok) {
          const errorText = await response.text();
          throw new Error(`请求失败: ${response.status} ${errorText}`);
        }

        const data = await response.json();
        setSubjects(data);
        if (data.length > 0) {
          setSelectedSubject(data[0].name);
        }
        setApiStatus(prev => ({...prev, subjects: 'success'}));
      } catch (error) {
        console.error('加载学科失败:', error);
        setApiStatus(prev => ({...prev, subjects: 'error'}));
        setError('加载学科失败，使用默认数据');

        // 后备学科数据
        setSubjects([
          { id: 1, name: "IPv6", description: "IPv6协议原理、地址配置、过渡技术等" },
          { id: 2, name: "SDN", description: "软件定义网络架构、OpenFlow协议、控制器技术等" },
          { id: 3, name: "HCIA", description: "华为认证网络工程师基础：路由协议、子网划分、设备配置等" }
        ]);
        setSelectedSubject("IPv6");
      }
    };

    fetchSubjects();
  }, []);

  // 生成试卷
  const generateExam = async () => {
    if (!selectedSubject || loading) return;

    setLoading(true);
    setError('');
    setApiStatus(prev => ({...prev, generate: 'loading'}));

    try {
      const response = await fetch('http://localhost:5001/api/generate_exam', {
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
      setExam(data);
      setAnswers({});
      setResults(null);

      // 初始化答案对象
      const initialAnswers = {};
      data.questions.forEach(q => {
        if (q.type === 'multiple_choice') {
          initialAnswers[q.id] = [];
        } else {
          initialAnswers[q.id] = '';
        }
      });
      setAnswers(initialAnswers);

      setApiStatus(prev => ({...prev, generate: 'success'}));
    } catch (error) {
      console.error('生成试卷失败:', error);
      setApiStatus(prev => ({...prev, generate: 'error'}));
      setError(`生成试卷失败: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  // 处理答案变化
  const handleAnswerChange = (questionId, value) => {
    setAnswers(prev => ({
      ...prev,
      [questionId]: value
    }));
  };

  // 处理多选题变化
  const handleMultipleChoiceChange = (questionId, option) => {
    setAnswers(prev => {
      const currentAnswers = prev[questionId] || [];
      const newAnswers = currentAnswers.includes(option)
          ? currentAnswers.filter(item => item !== option)
          : [...currentAnswers, option];

      return {
        ...prev,
        [questionId]: newAnswers
      };
    });
  };

  // 提交试卷
  const submitExam = async () => {
    if (!exam || loading) return;

    setLoading(true);
    setError('');
    setApiStatus(prev => ({...prev, judge: 'loading'}));

    try {
      // 准备答案数据 - 确保为数组格式
      const answerData = exam.questions.map(q => ({
        question_id: q.id,
        type: q.type,
        answer: Array.isArray(answers[q.id])
            ? answers[q.id].join(';;')
            : answers[q.id],
        score: q.score
      }));

      console.log("提交的答案数据:", answerData); // 调试日志

      const response = await fetch('http://localhost:5001/api/judge_exam', {
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
    } catch (error) {
      console.error('提交试卷失败:', error);
      setApiStatus(prev => ({...prev, judge: 'error'}));
      setError(`提交试卷失败: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  // 计时器
  useEffect(() => {
    if (!exam || results) return;

    const timer = setInterval(() => {
      setTimeLeft(prev => {
        if (prev <= 0) {
          clearInterval(timer);
          submitExam();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [exam, results]);

  // 格式化时间
  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
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

  if (results) {
    return (
        <div className="exam-results">
          <h2>考试结果 - {selectedSubject}</h2>
          <div className="score-summary">
            <h3>总分: {results.total_score}</h3>
            <button onClick={() => window.location.reload()}>返回首页</button>
          </div>

          <div className="detailed-results">
            {results.results.map((result, index) => (
                <div key={index} className="result-item">
                  <h4>题目 {index + 1}</h4>
                  <div className="result-content">
                    <p><strong>你的答案:</strong> {result.user_answer}</p>
                    <p><strong>参考答案:</strong> {result.correct_answer}</p>
                    {result.ai_response && (
                        <p><strong>AI评语:</strong> {result.ai_response}</p>
                    )}
                    <p className={`score-display ${result.score > 0 ? 'correct' : 'incorrect'}`}>
                      得分: {result.score} / {result.max_score || (exam && exam.questions.find(q => q.id === result.question_id)?.score) || '?'}
                    </p>
                    <p><strong>解析:</strong> {result.explanation}</p>
                  </div>
                </div>
            ))}
          </div>
        </div>
    );
  }

  return (
      <div className="exam-container">
        <div className="exam-header">
          <h2>DeepSeek 智能考试系统 - v2.0</h2>

          {/* API 状态指示器 */}
          <div className="api-status-container">
            <div className={`api-status ${apiStatus.subjects}`}>
              学科加载: {getStatusText(apiStatus.subjects)}
            </div>
            <div className={`api-status ${apiStatus.generate}`}>
              题目生成: {getStatusText(apiStatus.generate)}
            </div>
          </div>

          <div className="subject-controls">
            <select
                value={selectedSubject}
                onChange={(e) => setSelectedSubject(e.target.value)}
                disabled={loading || exam}
            >
              {subjects.map(subject => (
                  <option key={subject.id} value={subject.name}>
                    {subject.name}
                  </option>
              ))}
            </select>

            {!exam ? (
                <button onClick={generateExam} disabled={loading}>
                  {loading ? '试卷生成中...' : '开始考试'}
                </button>
            ) : (
                <div className="timer">
                  剩余时间: {formatTime(timeLeft)}
                  <button onClick={submitExam} disabled={loading}>
                    {loading ? '提交中...' : '提交试卷'}
                  </button>
                </div>
            )}
          </div>
        </div>

        {error && (
            <div className="error-message">
              {error}
              <button onClick={() => setError('')}>关闭</button>
            </div>
        )}

        {apiStatus.generate === 'loading' && (
            <div className="loading-indicator">
              <div className="spinner"></div>
              <p>试卷生成中，请稍候...</p>
            </div>
        )}

        {exam && apiStatus.generate === 'success' && (
            <div className="exam-content">
              <div className="exam-info">
                <h3>{selectedSubject} 试卷</h3>
                <p>总分: {exam.total_score}分 | 题量: {exam.questions.length}题</p>
              </div>

              <div className="questions-container">
                {exam.questions.map((question, index) => (
                    <div key={`${question.id}-${index}`} className="question-item">
                      <div className="question-header">
                        <span className="question-number">{index + 1}.</span>
                        <span className="question-type">{getTypeLabel(question.type)}</span>
                        <span className="question-score">{question.score}分</span>
                      </div>

                      <div className="question-text">{question.question}</div>

                      {renderAnswerInput(question, answers[question.id], handleAnswerChange, handleMultipleChoiceChange)}
                    </div>
                ))}
              </div>
            </div>
        )}
      </div>
  );
};

// 获取题型标签
const getTypeLabel = (type) => {
  const labels = {
    single_choice: '单选题',
    multiple_choice: '多选题',
    true_false: '判断题',
    fill_in_blank: '填空题',
    short_answer: '简答题',
    comprehensive: '综合题'
  };
  return labels[type] || type;
};

// 渲染答案输入框
const renderAnswerInput = (question, answer, handleChange, handleMultipleChoice) => {
  switch (question.type) {
    case 'single_choice':
      return (
          <div className="options">
            {['A', 'B', 'C', 'D'].map(option => (
                <label key={option}>
                  <input
                      type="radio"
                      name={`q_${question.id}`}
                      value={option}
                      checked={answer === option}
                      onChange={() => handleChange(question.id, option)}
                  />
                  {option}
                </label>
            ))}
          </div>
      );

    case 'multiple_choice':
      return (
          <div className="options">
            {['A', 'B', 'C', 'D', 'E'].map(option => (
                <label key={option}>
                  <input
                      type="checkbox"
                      value={option}
                      checked={answer && answer.includes(option)}
                      onChange={() => handleMultipleChoice(question.id, option)}
                  />
                  {option}
                </label>
            ))}
          </div>
      );

    case 'true_false':
      return (
          <div className="options">
            <label>
              <input
                  type="radio"
                  name={`q_${question.id}`}
                  value="true"
                  checked={answer === 'true'}
                  onChange={() => handleChange(question.id, 'true')}
              />
              正确
            </label>
            <label>
              <input
                  type="radio"
                  name={`q_${question.id}`}
                  value="false"
                  checked={answer === 'false'}
                  onChange={() => handleChange(question.id, 'false')}
              />
              错误
            </label>
          </div>
      );

    case 'fill_in_blank':
      return (
          <input
              type="text"
              value={answer || ''}
              onChange={(e) => handleChange(question.id, e.target.value)}
              placeholder="请填写答案"
          />
      );

    case 'short_answer':
    case 'comprehensive':
      return (
          <textarea
              value={answer || ''}
              onChange={(e) => handleChange(question.id, e.target.value)}
              placeholder="请在此输入您的答案..."
              rows={question.type === 'comprehensive' ? 6 : 4}
          />
      );

    default:
      return <p>不支持的题型</p>;
  }
};

export default ExamPanel;