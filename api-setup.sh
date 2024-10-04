#!/bin/bash

set -e

python -m venv venv
source venv/bin/activate

pip install django djangorestframework django-cors-headers psycopg2-binary 

django-admin startproject backend
(cd backend; python manage.py startapp api)

SETTINGS_FILE="backend/backend/settings.py"

sed -i "/INSTALLED_APPS = \[/ a\    'api',\n    'corsheaders',\n    'rest_framework'," $SETTINGS_FILE

cat <<EOF > backend/api/models.py
from django.db import models
from django.contrib.auth.models import AbstractUser

class Token(models.Model):
    id = models.AutoField(primary_key=True)
    token = models.CharField(max_length=255)
    created_at = models.DateTimeField()
    expires_at = models.DateTimeField()
    user_id = models.IntegerField()
    is_used = models.BooleanField(default=False)

class User(AbstractUser):
    phone = models.CharField(max_length=10, null=True)
    country = models.CharField(max_length=63)
    groups = models.ManyToManyField(
        'auth.Group',
        related_name='api_user_set',  # Add related_name to avoid clashes
        blank=True,
        help_text='The groups this user belongs to. A user will get all permissions granted to each of their groups.',
        verbose_name='groups',
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission',
        related_name='api_user_set',  # Add related_name to avoid clashes
        blank=True,
        help_text='Specific permissions for this user.',
        verbose_name='user permissions',
    )

    def __str__(self) -> str:
        return self.username

class Question(models.Model):
    id = models.AutoField(primary_key=True)
    text = models.TextField()
    correct_answer = models.IntegerField()

    def __str__(self) -> str:
        return f'Question {self.id}: {self.text}'

class Answer(models.Model):
    id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='answers')
    question = models.ForeignKey(Question, on_delete=models.CASCADE, related_name='answers')
    answer = models.IntegerField()
    is_correct = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self) -> str:
        return f'Answer {self.id} by {self.user.username} for Question {self.question.id}'
EOF

cat <<EOF > backend/api/serializers.py
from rest_framework import serializers
from .models import User, Token


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["username", "email", "password", "country", "phone"]


class TokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = Token
        fields = ["token", "created_at", "expires_at", "user_id", "is_used"]
EOF

cat <<EOF > backend/api/views.py
from django.shortcuts import render
from django.contrib.auth.hashers import make_password
from django.core.mail import send_mail
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import User, Token
from .serializers import UserSerializer, TokenSerializer
from django.conf import settings
from datetime import datetime, timedelta
import hashlib
import uuid
from django.utils import timezone

SALT = "8b4f6b2cc1868d75ef79e5cfb8779c11b6a374bf0fce05b485581bf4e1e25b96c8c2855015de8449"
URL = "http://localhost:3000"


def mail_template(content, button_url, button_text):
    return f"""<!DOCTYPE html>
            <html>
            <body style="text-align: center; font-family: "Verdana", serif; color: #000;">
                <div style="max-width: 600px; margin: 10px; background-color: #fafafa; padding: 25px; border-radius: 20px;">
                <p style="text-align: left;">{content}</p>
                <a href="{button_url}" target="_blank">
                    <button style="background-color: #444394; border: 0; width: 200px; height: 30px; border-radius: 6px; color: #fff;">{button_text}</button>
                </a>
                <p style="text-align: left;">
                    If you are unable to click the above button, copy paste the below URL into your address bar
                </p>
                <a href="{button_url}" target="_blank">
                    <p style="margin: 0px; text-align: left; font-size: 10px; text-decoration: none;">{button_url}</p>
                </a>
                </div>
            </body>
            </html>"""


# Create your views here.
class ResetPasswordView(APIView):
    def post(self, request, format=None):
        user_id = request.data["id"]
        token = request.data["token"]
        password = request.data["password"]

        token_obj = Token.objects.filter(
            user_id=user_id).order_by("-created_at")[0]
        if token_obj.expires_at < timezone.now():
            return Response(
                {
                    "success": False,
                    "message": "Password Reset Link has expired!",
                },
                status=status.HTTP_200_OK,
            )
        elif token_obj is None or token != token_obj.token or token_obj.is_used:
            return Response(
                {
                    "success": False,
                    "message": "Reset Password link is invalid!",
                },
                status=status.HTTP_200_OK,
            )
        else:
            token_obj.is_used = True
            hashed_password = make_password(password=password, salt=SALT)
            ret_code = User.objects.filter(
                id=user_id).update(password=hashed_password)
            if ret_code:
                token_obj.save()
                return Response(
                    {
                        "success": True,
                        "message": "Your password reset was successfully!",
                    },
                    status=status.HTTP_200_OK,
                )


class ForgotPasswordView(APIView):
    def post(self, request, format=None):
        email = request.data["email"]
        user = User.objects.get(email=email)
        created_at = timezone.now()
        expires_at = timezone.now() + timezone.timedelta(1)
        salt = uuid.uuid4().hex
        token = hashlib.sha512(
            (str(user.id) + user.password + created_at.isoformat() + salt).encode(
                "utf-8"
            )
        ).hexdigest()
        token_obj = {
            "token": token,
            "created_at": created_at,
            "expires_at": expires_at,
            "user_id": user.id,
        }
        serializer = TokenSerializer(data=token_obj)
        if serializer.is_valid():
            serializer.save()
            subject = "Forgot Password Link"
            content = mail_template(
                "We have received a request to reset your password. Please reset your password using the link below.",
                f"{URL}/resetPassword?id={user.id}&token={token}",
                "Reset Password",
            )
            send_mail(
                subject=subject,
                message=content,
                from_email=settings.EMAIL_HOST_USER,
                recipient_list=[email],
                html_message=content,
            )
            return Response(
                {
                    "success": True,
                    "message": "A password reset link has been sent to your email.",
                },
                status=status.HTTP_200_OK,
            )
        else:
            error_msg = ""
            for key in serializer.errors:
                error_msg += serializer.errors[key][0]
            return Response(
                {
                    "success": False,
                    "message": error_msg,
                },
                status=status.HTTP_200_OK,
            )


class RegistrationView(APIView):
    def post(self, request, format=None):
        request.data["password"] = make_password(
            password=request.data["password"], salt=SALT
        )
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(
                {"success": True, "message": "You are now registered on our website!"},
                status=status.HTTP_200_OK,
            )
        else:
            error_msg = ""
            for key in serializer.errors:
                error_msg += serializer.errors[key][0]
            return Response(
                {"success": False, "message": error_msg},
                status=status.HTTP_200_OK,
            )


class LoginView(APIView):
    def post(self, request, format=None):
        email = request.data["email"]
        password = request.data["password"]
        hashed_password = make_password(password=password, salt=SALT)
        user = User.objects.get(email=email)
        if user is None or user.password != hashed_password:
            return Response(
                {
                    "success": False,
                    "message": "Invalid Login Credentials!",
                },
                status=status.HTTP_200_OK,
            )
        else:
            return Response(
                {"success": True, "message": "You are now logged in!"},
                status=status.HTTP_200_OK,
            )
from django.shortcuts import render, get_object_or_404
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.views import View
from .models import Question
import json

class QuestionListView(View):
    def get(self, request):
        questions = Question.objects.all().values('id', 'text', 'correct_answer')
        return JsonResponse(list(questions), safe=False)

    @method_decorator(csrf_exempt)
    def post(self, request):
        data = json.loads(request.body)
        question = Question.objects.create(
            text=data['text'],
            correct_answer=data['correct_answer']
        )
        return JsonResponse({'id': question.id, 'text': question.text, 'correct_answer': question.correct_answer})

class QuestionDetailView(View):
    def get(self, request, pk):
        question = get_object_or_404(Question, pk=pk)
        return JsonResponse({'id': question.id, 'text': question.text, 'correct_answer': question.correct_answer})
EOF

cat <<EOF > backend/api/urls.py
from django.urls import path
from .views import RegistrationView, LoginView, ForgotPasswordView, ResetPasswordView, QuestionListView, QuestionDetailView

urlpatterns = [
    path("register", RegistrationView.as_view(), name="register"),
    path("login", LoginView.as_view(), name="login"),
    path("forgotPassword", ForgotPasswordView.as_view(), name="forgotPassword"),
    path("resetPassword", ResetPasswordView.as_view(), name="resetPassword"),
    path('questions/<int:pk>/', QuestionDetailView.as_view(), name='question-detail'),
    path('questions/', QuestionListView.as_view(), name='question-list'),
]
EOF

cat <<EOF > backend/backend/urls.py
# backend/urls.py

from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),
]
EOF

sed -i "/MIDDLEWARE = \[/ a\    'corsheaders.middleware.CorsMiddleware'," $SETTINGS_FILE

cat <<EOF >> $SETTINGS_FILE

CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
]

CORS_ALLOW_CREDENTIALS = True

EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend"
EMAIL_HOST = "smtp.gmail.com"
EMAIL_USE_TLS = True
EMAIL_PORT = 587
EMAIL_HOST_USER = "someone@gmail.com"
EMAIL_HOST_PASSWORD = "superlamepassword"
TIME_ZONE = 'EST'
EOF

sed -i "/TIME_ZONE = 'UTC'/d" $SETTINGS_FILE

cat <<EOF > backend/api/admin.py
from django.contrib import admin
from .models import User, Token

# Register your models here.
admin.site.register(User)
admin.site.register(Token)
EOF

(cd backend; python manage.py makemigrations ; python manage.py migrate)
(cd backend; echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@myproject.com', 'admin')" | python manage.py shell)

