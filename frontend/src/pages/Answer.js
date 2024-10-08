import { useParams } from 'react-router-dom';

const Answer = () => {
  const { id } = useParams();

  return (
    <div>
      <div>This is the problem {id}</div>
    </div>
  );
};

export default Answer;
