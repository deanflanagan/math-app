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

  useEffect(() => {
    const fetchItems = async () => {
      const res = await axios.get(URL);
      const data = res.data;
      setQuizData(data);
    };
    if (isLoggedIn) {
      fetchItems();
    }
  }, [isLoggedIn, name, email]);

  return (
    <div className="container justify-center items-center flex flex-col gap-12 h-screen">
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
        <div className="flex flex-col gap-8 w-full px-4">
          <h1 className="w-full text-center text-4xl md:text-6xl">
            Welcome to Math Quiz, {name}.
          </h1>
          <div className="grid w-full items-center justify-center gap-8 grid-cols-2 md:grid-cols-3">
            {quizData &&
              quizData.map((item) => (
                <a
                  href={`/solve/${item.id}`}
                  className="w-full px-3.5 py-3 gap-4 flex flex-row rounded-full shadow-md bg-white border hover:border-purple-500 justify-center items-center"
                >
                  <div className="size-18 rounded-full">
                    <img
                      src={QuizItemAvatar}
                      alt="Quiz Item"
                      width={72}
                      height={72}
                    />
                  </div>
                  <div className="w-full text-md md:text-xl">{item?.text}</div>
                </a>
              ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default Home;
