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

That is mostly backend/Django work. For frontend, you need some simple styling for homePage, then landing page for logged in Users, Questions page, submitted Answers page. 
