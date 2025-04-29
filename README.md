# Board-Game


## Configuration
- Install [node.js](https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi)
- Run the following commands

```bash
cd frontend
npm install
```

- Run the sql script ```boardgames.sql``` to create the tables and the stored functions / procedures (requires ```pip install mysql-connector-python```)
- Run the python script ```fill-database.py``` to populate the MySQL database with the csv data. You will need to modify the 2 following lines in the python code (do not push the file with your updated info): 
  - ```path_before_file = 'C:/Users/.../Board-Game/backend/'```
  - ```'password': 'INSERT_PASS_HERE',```

- Copy the .env file in the folder ```backend/!dotenv-template``` to the root of the ```backend``` folder. Then update the ```DB_PASS``` field to your actual MySQL root user password.


## How to run
- In the frontend folder

```bash
npm run dev
```

- In the backend folder

```bash
node server.js
```


## To Do

- add a table for ratings / comments with a trigger so that each time someone ranks a game, an entry in this table is added (Done?)

## Functionalities
-See the list of board games
-Filter the games
-Search for a game
-See a game's details
-Register and login
-Access and modify the personal informations
