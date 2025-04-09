const passport = require("passport");
const usersRepo = require(__dirname + "\\user.repository.js"); // use same folder as the current file

// const localStrategy = require('passport-local');
// passport.use(new LocalStrategy(xxx));
// check https://www.passportjs.org/howtos/password/ for full localStrategy implementation
// instead, we will call request.login on our own, much cleaner...

// session+passport docs:
// https://www.passportjs.org/howtos/session/
// https://www.passportjs.org/concepts/authentication/sessions/

module.exports = {
  initializeAuthentications(app) {
    app.use(passport.initialize());
    app.use(passport.authenticate('session'));
    // app.use(passport.session()); // old syntax

    // Serialization will be called during request.login(userFromDb) 
    // Result will be saved into session
    passport.serializeUser(function (userFromDb, doneFunction) { 
      console.log("SERIALIZING...");
      // Only store the minimal necessary data in the session
      const userObj = { "id": userFromDb.user_id }; // Only store ID for lookups
      console.log(userObj);
      doneFunction(null, userObj);
    });
    
    passport.deserializeUser(async function (userObj, doneFunction) { 
      console.log("DE - SERIALIZING... ");
      console.log(userObj);
      
      try {
        // Use getUserById instead of getOneUser
        let userFromDb = await usersRepo.getUserById(userObj.id);
        
        if (!userFromDb) {
          console.log("User not found in database during deserialization");
          return doneFunction(null, false);
        }
        
        console.log(userFromDb);
        return doneFunction(null, userFromDb);
      } catch (error) {
        console.error("Database error during deserialization:", error);
        return doneFunction(error);
      }
    });
  },

  authorizeRequest(requiredRole) {
    return function (request, response, next) {
      if (request.isAuthenticated()) { // Do we have an authenticated user?
        if (requiredRole) { // No special role needed for page -> check if current user has the SAME role (todo: hierarchy?)
          if (requiredRole === request.user.user_role) { 
            return next();
          } else {
            console.log("401 Unautorized (bad user level)");
            return response.end("401 Unautorized (bad user level)"); 
          }
        } else { // No special role needed for page -> next middleware
          return next();
        }
      } else { // not authenticated at all
        console.log("401 Unautorized (not authenticated)");
        return response.end("401 Unautorized (not authenticated)");
        // OR: response.redirect("/auth"); 
      }
    }
  }
};