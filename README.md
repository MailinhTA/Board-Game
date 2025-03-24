# Board-Game


## Configuration & Dependencies
- Install [node.js](https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi)
- Run the following commands

```bash
cd frontend
npm install
```


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