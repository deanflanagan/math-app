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