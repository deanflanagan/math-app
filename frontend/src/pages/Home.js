// pages/Home.js
import { useEffect, useState } from 'react';
import axios from 'axios';
import QuizItemAvatar from '../images/quiz item.png';

const URL = process.env.REACT_APP_BACKEND_URL + '/api/questions';

const Home = () => {
  const name = localStorage.getItem('username');
  const email = localStorage.getItem('email');
  const isLoggedIn = name && email;

  const [quizData, setQuizData] = useState();
  const [currentIdx, setCurrentIdx] = useState(1);
  const [answer, setAnswer] = useState([]);

  useEffect(() => {
    const fetchItems = async () => {
      const res = await axios.get(URL);
      const data = res.data;
      setQuizData(data);
      const blankAnswer = Array(data.length).fill('');
      setAnswer(blankAnswer);
    };
    if (isLoggedIn) {
      fetchItems();
    }
  }, [isLoggedIn, name, email]);

  const onAnswer = () => {};

  const onAnswerChange = (event) => {
    const copyAnswer = [...answer];
    copyAnswer[currentIdx] = event.target.value;
    setAnswer(copyAnswer);
  };

  return (
    <div className="w-full justify-center items-center flex flex-col gap-12 h-screen p-8">
      {!isLoggedIn && (
        <>
          <h1 className="font-semibold text-[80px]">Math Quiz</h1>
          <div className="flex flex-row gap-4">
            <a
              href="/login"
              className="focus:outline-none text-white bg-purple-600 hover:bg-purple-700 focus:ring-4 focus:ring-purple-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-purple-500 dark:hover:bg-purple-600 dark:focus:ring-purple-800"
            >
              LogIn
            </a>
            <a
              href="/register"
              className="focus:outline-none text-white bg-purple-600 hover:bg-purple-700 focus:ring-4 focus:ring-purple-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-purple-500 dark:hover:bg-purple-600 dark:focus:ring-purple-800"
            >
              SignUp
            </a>
          </div>
        </>
      )}
      {isLoggedIn && (
        <div className="flex flex-col gap-12 w-full px-4 h-full pt-16">
          <h1 className="w-full text-center text-4xl lg:text-6xl">
            Welcome to Math Quiz, {name}.
          </h1>
          <div className="w-full flex flex-col sm:flex-row h-[calc(100%-100px)] gap-8">
            <div className="w-full sm:w-1/3 sm:max-w-[300px] gap-2 md:gap-4 flex flex-row sm:flex-col sm:h-full overflow-auto">
              {quizData &&
                quizData.map((item, idx) => (
                  <button
                    key={`prob-${item?.id}`}
                    onClick={() => {
                      setCurrentIdx(idx);
                    }}
                    className={`w-full px-3.5 py-3 gap-4 flex flex-row rounded-full shadow-md bg-white border hover:border-purple-500 justify-center items-center ${
                      idx === currentIdx ? 'border-2 border-purple-500' : ''
                    }`}
                  >
                    <div className="size-18 rounded-full">
                      <img
                        src={QuizItemAvatar}
                        alt="Quiz Item"
                        width={72}
                        height={72}
                      />
                    </div>
                    <div className="w-full text-md md:text-xl truncate">
                      {item?.text}
                    </div>
                  </button>
                ))}
            </div>
            {!!quizData && (
              <div className="w-full relative flex flex-col h-full justify-center items-center gap-8 bg-white rounded-3xl p-4">
                <div className="text-3xl sm:text-5xl text-center">
                  {quizData[currentIdx]?.text}
                </div>
                <div className="flex flex-col sm:flex-row w-full gap-4 justify-center items-center">
                  <input
                    className="bg-gray-50 rounded-full border max-sm:w-full max-sm:max-w-[200px] border-gray-300 text-gray-900 text-sm focus:ring-purple-500 focus:border-purple-500 block p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-purple-500 dark:focus:border-purple-500 max-w-[200px]"
                    onChange={onAnswerChange}
                    value={answer[currentIdx]}
                  />
                  <button
                    className="rounded-full py-2.5 px-4 max-sm:w-full max-sm:max-w-[200px] text-white bg-blue-700"
                    onClick={onAnswer}
                  >
                    Answer
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default Home;
