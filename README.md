# Kaquiz (Location tracking app)

The app allows users to search for users by email, send them friendships requests and track friends last known location.

User's location is sent to database every 5 seconds.

Backend is implemented via Firebase and Frondend is done with Flutter.

# Audit helper

For the sake of simplicity the whole audit process was recorded on video

## Authentication and friends

https://youtu.be/bjS1wVuu-Jc

## Locations tracking

https://youtu.be/NuBIzjuJrJs

## Project Description and Audit

- Full project description: https://github.com/01-edu/public/tree/master/subjects/mobile-dev/kahoot

- Audit questions: https://github.com/01-edu/public/tree/master/subjects/mobile-dev/kahoot/audit

# Technologies

- Firestore database (Firebase)
- Firebase authentication
- Google maps
- Geolocator
- State management with Provider pattern

# Run project locally (If you're that crazy)

- Proceed to the official guide for flutter "Get started" https://docs.flutter.dev/get-started/install
- Clone this repo to your machine
- Run **flutter pub get**
- Run **main.dart** file with debugger (ctrl+F5 in VSCode)
- Enjoy the app (or don't enjoy)
