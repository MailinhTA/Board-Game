// controllers/auth.route.js
const express = require('express');
const router = express.Router();
const auth = require("../utils/user.auth");
const userRepo = require("../utils/user.repository");

// http://localhost:9000/auth
// USE AUTHORIZATION HERE (the method does not know if authorization is present)
// MAC/DAC/RBAC, Claims-based authorization, Policy-based authorization, Resource-based authorization
router.get("/user", auth.authorizeRequest("USER"), userdataAction); // expose function only for USER roles
router.get("/admin", auth.authorizeRequest("ADMIN"), userdataAction); // expose function only for ADMIN roles
router.get("/protected", protectedGetAction); // execute authorization in action method: needed for resource-based auth
router.post("/login", loginPostAction);
router.get("/logout", logoutAction);
router.get("/role", getRoleAction);

async function getRoleAction(request, response) {
  if (request.isAuthenticated()) { // Do we have an authenticated user?
    if (request.user.user_role === "ADMIN") 
      response.send("ADMIN");
    else
      response.send("USER");
  }
  else
    response.send("GUEST");
}

// use same endpoints for both roles
async function userdataAction(request, response) {
  let userJson = JSON.stringify(request.user); 
  response.send(userJson);
}

async function protectedGetAction(request, response) {
  // TODO: authorize using all factors (resource / context / environment) ...
  let userRole = "GUEST CONTENT";
  if (request.isAuthenticated()) {   // the isAuthenticated() method is provided by passport
    if (request.user.user_role === "ADMIN") {
      userRole = "ADMIN CONTENT";
    } else {
      userRole = "USER CONTENT";
    }
  } 
  response.send(userRole);
}

async function loginPostAction(request, response) {
  try {
    let areValid = await userRepo.areValidCredentials(request.body.username, request.body.userpass);
    
    if (areValid) {
      let user = await userRepo.getOneUser(request.body.username);
      if (!user) {
        return response.status(401).json({ 
          "loginResult": false, 
          "message": "User not found", 
          "timestamp": new Date().toLocaleString() 
        });
      }
      
      request.login(user, function (err) { 
        if (err) { 
          console.log("LOGIN ERROR:", err);
          return response.status(500).json({ 
            "loginResult": false, 
            "message": "Login process failed", 
            "timestamp": new Date().toLocaleString() 
          });
        }
        
        let resultObject = { 
          "loginResult": true, 
          "timestamp": new Date().toLocaleString(), 
          "userRole": user.user_role 
        };
        response.json(resultObject);
      });
    } else {
      response.json({ 
        "loginResult": false, 
        "message": "Invalid credentials",
        "timestamp": new Date().toLocaleString() 
      });
    }
  } catch (error) {
    console.error("Authentication error:", error);
    response.status(500).json({ 
      "loginResult": false, 
      "message": "Server error during authentication",
      "timestamp": new Date().toLocaleString() 
    });
  }
}

function logoutAction(request, response) {
  request.logout(function(err){
    let resultObject = { "logoutResult": true, "timestamp": new Date().toLocaleString() };
    if (err) { 
      console.log("LOGINERROR");
      console.log(err); 
      areValid = false;
      // return next(err);
    }
    response.send(JSON.stringify(resultObject));
  });
}

module.exports = router;