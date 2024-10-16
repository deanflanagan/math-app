import { useEffect, useState } from 'react';
import axios from 'axios';

const URL = process.env.REACT_APP_BACKEND_URL + '/api/report';

const Report = () => {
  const is_staff = localStorage.getItem('is_staff') === 'true';
  const [reportData, setReportData] = useState([]);
  useEffect(() => {
    const fetch = async () => {
      const res = await axios.get(URL);
      const data = res.data;
      setReportData(data);
    };
    if (!is_staff) {
      console.log('here');
      return;
    }
    fetch();
  }, [is_staff]);
  if (!is_staff) {
    return <div>You can't access this page</div>;
  }

  return (
    <div className="container">
      <div className="flex flex-col w-full">
        <div className="flex flex-row gap-4">
          <div className="w-full">User ID</div>
          <div className="w-full">Question ID</div>
          <div className="w-full">Country</div>
          <div className="w-full">Answer</div>
        </div>
        {reportData &&
          reportData.map((item) => (
            <div className="flex flex-row gap-4">
              <div className="w-full">{item?.user_id}</div>
              <div className="w-full">{item?.question_id}</div>
              <div className="w-full">{item?.country}</div>
              <div className="w-full">{item?.answer}</div>
            </div>
          ))}
      </div>
    </div>
  );
};

export default Report;
