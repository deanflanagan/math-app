# Math app

Tasks for math-app project

The frontend and backends are based on this [tutorial](https://www.geeksforgeeks.org/build-an-authentication-system-using-django-react-and-tailwind/)
That only has authentication. We need to built out authorization for normal user and admin user (like Django superuser)

The Django project from the same tutorial I have extended the model a little bit by changing the User model and added a Questions model

Once a user is registered, authorized users can:
- Login and POST answers to Questions
- Once they submit their questions (with a form), they can GET their answers on a new page
- Admins can view everyones answers on a different page, non admins can only GET their own answers once they have POSTed their answers to all questions
- Until that time they can still PATCH their answer
- Answers are 1-to-1 relationship with Questions and Users: each Answer has a Question id and a User id
- Users are in 1-to-many relationship with Answers
- Answer model has a `save()` method to check if submitted Answer was correct (1-to-1 with Question)
- Can populate the Questions with:
```
#!/bin/bash

# Create 5 simple math questions with their associated answers
questions=(
  "What is 2 + 2?" 4
  "What is 5 * 3?" 15
  "What is 10 - 4?" 6
  "What is 7 / 1?" 7
  "What is 9 * 9?" 81
)

for ((i=0; i<${#questions[@]}; i+=2)); do
  question=${questions[i]}
  answer=${questions[i+1]}
  echo "Creating question: $question"
  python manage.py shell <<EOF
from api.models import Question
q = Question(text="$question", correct_answer=$answer)
q.save()
EOF
done
```
- Will need to add Questions & Answers to DRF, URLs, etc

That is mostly backend/Django work. For frontend, you need some simple styling for homePage, then landing page for logged in Users, Questions page, submitted Answers page. 
