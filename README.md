# Or!enteering

A game app that aims to digitise the treasure hunt games that are played in a lot of orientation camps and team building programmes. Players shall check in to different locations and complete tasks.

## Key Features
- 2 Game Modes
- Game Master and Player roles
- Game Master can set up tasks for different locations
- Players can check in to locations and complete tasks
- Real-time Scoreboard

## Game Modes
There are two game modes, Indoor and Outdoor. In both game modes Game Master has to set up task for different locations. Outdoor mode is meant to be playing outdoors and Indoor mode would be suitable for orientation within a building.
### Indoor Mode
Upon setting up game task details, a QR code would be saved to phone local storage and could be accessed by using file browser. The QR code shall be printed by Game Master and placed at the location where the task is to be completed. Players would scan the QR code to check in to the location and complete the task.
### Outdoor Mode
Upon setting up game task details, Game Master has to specify the GPS coordinates of the location on the map where the task is to be completed. Players would have to be within a certain radius of the location to check in and complete the task.

## Getting Started
**Only Android is supported at the moment.**
1. Clone the repository on your local machine.
2. Install [JsonServer](https://github.com/typicode/json-server/tree/v0)  
3. Start the backend server by navigating to the `backend` directory and running `json-server --host 0.0.0.0 db.json`.
4. Install [Flutter](https://docs.flutter.dev/get-started/install) and ensure the JAVA version 23 is installed.
5. Run main.dart in the `lib` directory on your emulator or physical device. It is suggested to run on 2 devices to test the game master and player roles.
6. Play around with the app and have fun!

