# CAPSTONE-Chuah-Mobile-App

Installation: You'll need git installed to clone this repository.  Once cloned, cd into the "mobile_app" folder and run main.dart on an emulator or physical device.  Please ensure you have the correct version of Flutter installed and, if using an emulator, a version that is compatible with this app.  

Run 'flutter pub get' under mobile_app to add dependencies

Run 'flutter run' to run app after you open an emulator or directly run it in Android Studio

Summary: This app is a help coach app geared towards college students to get them active and interested in the community while also helping to relieve stress through features such as location-based commenting with others, daily activities, journaling, profile sharing, and quests to keep users interested. The "mobile_app" folder is where our app is contained - anything outside of that is testing or legacy data. The "lib" folder inside of that contains all of the pages of our app.

Firebase: Our app uses Firebase Firestore as our database for user and location information. Create your own google-services.json using firebase and replace it under android/app, an example is provided https://firebase.google.com/docs/android/setup

You need to fill in the missing parts of the codes in files under ./mobile_app/lib

Week1: Create your own firebase and complete the register/login codes in signup.dart

Week2: Add some sample locations of colleges into firebase (refer to the format in slide) and correctly fetch them in Home Page

Week3: Complete the missing parts starting line 430 in home.dart

Week4: Complete the missing parts in group.dart