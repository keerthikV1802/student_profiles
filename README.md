📘 Student Profile Book – Flutter Application

A role-based Student Profile Management mobile application built using Flutter and Firebase, designed to manage student, faculty, and admin workflows in a structured and secure way.

🚀 Overview

Student Profile Book is a Flutter application that provides a centralized platform for managing student profiles, academic details, and faculty interactions.
The app supports role-based authentication and navigation, ensuring each user type accesses only relevant features.

👥 User Roles
🔑 Admin

Secure admin login

Manage departments

Approve faculty registrations

View all students and faculty data

👨‍🏫 Faculty

Faculty signup with admin approval

View students by department & year

Access assigned student profiles

Update academic-related details

🎓 Student

Student registration & login

View personal profile and academic info

Department & year-based classification

✨ Key Features

🔐 Role-based Authentication (Admin / Faculty / Student)

🔄 Firebase Authentication

🗄️ Cloud Firestore for structured data storage

🧭 Role-based Navigation

🧑‍💼 Admin approval flow for faculty

🏫 Department & year-based student organization

📱 Clean, modern Flutter UI (Android-focused)

⚡ Real-time data updates using Firestore

🛠️ Tech Stack

Flutter (Dart)

Firebase Authentication

Cloud Firestore

Firebase Storage (if used for profile images)

REST API ready architecture

Material UI

📂 Project Structure
lib/
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   ├── admin/
│   │   ├── admin_home_screen.dart
│   ├── faculty/
│   │   ├── faculty_home_screen.dart
│   ├── student/
│   │   ├── student_home_screen.dart
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
├── models/
│   ├── user_model.dart
├── widgets/
└── main.dart

🔐 Authentication Flow

User selects role (Admin / Faculty / Student)

Firebase Authentication handles login/signup

User role stored in Firestore

Role-based navigation to respective dashboard

Faculty accounts require admin approval before access

