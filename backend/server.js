// populate object process.env from the file .env
const dotenv = require('dotenv');
dotenv.config();

// create express.js webapp
const express = require('express');
const app = express();
app.set("view engine", "ejs");
app.set("views", "views");
app.listen(process.env.WEB_PORT, '0.0.0.0',
    function() { console.log("Listening on "+process.env.WEB_PORT); }
);

// *** MIDDLEWARES ***
// app.use(callbackFunction1, callbackFunction2, callbackFunction3)

// process form input (create request.body from POST data or json in the http request)
const bodyParser = require("body-parser");
app.use(bodyParser.json(), bodyParser.urlencoded({ extended: true }));

// allow serverside session storage
const session = require("express-session");
app.use(session({
    secret: "SecretRandomStringDskghadslkghdlkghdghaksdghdksh",   // session storage will be stored encrypted
    saveUninitialized: true,
    cookie: { maxAge: 1000 * 60 * 60 * 24 }, // storing session identifier, maxAge is the time the cookie will be stored in the browser (1 day, in milliseconds)
    resave: false
}));
// if (request.session.cart===undefined) request.session.cart = [];
// request.session.cart.push("xxxx");

// enable Cross Origin Resource Sharing (needed for cross-origin API)
const cors = require('cors');
app.use(cors({ origin: "http://localhost:8080", credentials: true, methods: [ 'GET', 'POST' ] })); 


// configure passport
const auth = require("./utils/user.auth");
auth.initializeAuthentications(app);
app.use("/auth", require("./controllers/auth.route"));


// *** ROUTES/CONTROLLERS ***

// setup default route
app.get('/', (request, response) => { // 'GET' or 'POST'...
    let clientIp = request.ip;
    response.send(`Hello, dear ${clientIp}. I am a nodejs website...`);
    response.end(); // optional
});

// setup additional routes
// app.use(routeBase, callback);

app.use("/static", express.static(__dirname + '/static'));
app.use("/api/games", require("./controllers/gamesapi.route"));
app.use("/api/users", require("./controllers/user.route"));
app.use("/api/auth", require("./controllers/auth.route"));
app.use("/api/ratings", require("./controllers/ratingsapi.route"));