# Kitaby - Reading Tracker (Flutter Version)

This is a Flutter application for tracking reading progress and challenges, inspired by the original Next.js version.

## Getting Started

This project is a starting point for a Flutter application.

To run this project:

1.  Ensure you have Flutter installed: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2.  Clone the repository.
3.  Navigate to the project directory: `cd kitaby_flutter`
4.  Install dependencies: `flutter pub get`
5.  Run the app: `flutter run`

## Project Structure

-   `lib/main.dart`: Application entry point.
-   `lib/models/`: Data models (Book, Challenge).
-   `lib/providers/`: State management providers.
-   `lib/screens/`: UI Screens for different parts of the app.
-   `lib/services/`: Data persistence logic (using shared_preferences).
-   `lib/widgets/`: Reusable UI components.
-   `lib/utils/`: Utility functions and constants.

## Features

-   Add and manage books across categories (Reading, Read, Want to Read, Complete Later).
-   Track reading progress (current page).
-   Add cover images for books.
-   Create and track reading challenges (by books or pages).
-   View active and past challenges.
-   Update challenge progress.
-   Data persistence using local storage.
-   Arabic language and RTL layout support.
