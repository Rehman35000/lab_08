# Smart Campus — University Assistant

A beginner-friendly Flutter/Dart prototype for Assignment 2.

## Features
- User registration and login
- In-memory list-based user records (no database or external authentication)
- Named routes (`/` and `/dashboard`)
- Role-specific Student, Teacher, and Admin dashboard options
- Basic form validation and error messages
- Logout that clears the current user and removes dashboard navigation history
- Demo accounts for quick testing

## Run in VS Code
1. Install Flutter and the Flutter extension in VS Code.
2. Install Android Studio/Android SDK or connect an Android device.
3. Open a terminal in this folder and run:
   ```bash
   flutter pub get
   flutter doctor
   flutter run
   ```

## Demo accounts
- Student: `student` / `student123`
- Teacher: `teacher` / `teacher123`
- Admin: `admin` / `admin123`

You can also register a new account. The role dropdown is for educational demonstration only.

## Navigation
- `/` — login and registration
- `/dashboard` — dashboard selected using the logged-in user's role

The dashboard route checks whether a current user exists and redirects to the authentication screen if not. Login clears previous routes and opens the dashboard. Logout clears the user and returns to `/`.

## Important limitations
This assignment prototype stores credentials in plain text in memory. Data normally disappears when the app process ends. Do not use this design for a real application. Production systems require secure password handling, trusted authentication, and server-side authorization. The role dropdown must not allow users to grant themselves privileged roles in a real system.

## Screenshots
Capture screenshots from your own running app and add them to the `screenshots/` folder before submission:
1. Login screen
2. Registration screen
3. Student dashboard
4. Teacher dashboard
5. Logout/navigation flow
