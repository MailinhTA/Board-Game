# Board-Game


## Configuration
- Install [node.js](https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi)
- Run the following commands

```bash
cd frontend
npm install
```

- Run the sql scripts ```boardgames_tables.sql```, ```boardgames_indexes.sql```, and ```boardgames_functions.sql``` to create the database, tables, indexes, triggers, stored procedures, and views on your local MySQL server.
- Run the python script ```fill-database.py``` to populate the MySQL database with the csv data (requires ```pip install mysql-connector-python```). You will need to modify the 2 following lines in the python code (do not push the file with your updated info): 
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



## Functionalities
- Register and login
- See the list of board games (by pages)
- Sort the games on demand
- Search for a game
- See a game's details
- Rate a game
- See other people's ratings
- Update your rating
- See all your ratings