const express = require('express');
const router = express.Router();
const gamesRepo = require('../utils/ratings.repository');

router.post('/add', addRatingAction);
router.get('/getlast/:game_id', getRatingsAction);
router.get('/getuser/:user_id', getUserRatingsAction);
router.get('/delete/:user_id/:game_id', deleteRatingAction);


async function addRatingAction(request, response) {
    try {
        if (!request.body) {
            return response.status(400).json({ error: 'No data provided in request body' });
        }

        if (request.isAuthenticated()) { // Do we have an authenticated user?
            let userID = request.user.user_id;

            let result = await gamesRepo.addRating(
                userID,
                request.body.game_id,
                request.body.rating,
                request.body.comment
            );
            response.send(JSON.stringify(result));
        }
        else {
            response.status(401).send("Unauthorized: User not authenticated");
        }

    } catch (error) {
        console.error("Error adding product:", error);
        response.status(500).send("Internal Server Error");
    }
}

async function getRatingsAction(request, response) {
    try {
        let gameID = request.params.game_id;
        let result = await gamesRepo.getRatings(gameID);
        response.send(JSON.stringify(result));
    } catch (error) {
        console.error("Error getting ratings:", error);
        response.status(500).send("Internal Server Error");
    }
}


async function getUserRatingsAction(request, response) {
    try {
        let userID = request.params.user_id;
        let result = await gamesRepo.getUserRatings(userID);
        response.send(JSON.stringify(result));
    } catch (error) {
        console.error("Error getting user ratings:", error);
        response.status(500).send("Internal Server Error");
    }
}


async function deleteRatingAction(request, response) {
    try {
        if (request.isAuthenticated()) {
            let userIDA = request.user.user_id;
            let userIDP = request.params.user_id;
            if (userIDA == userIDP || request.user.user_role == "ADMIN") {
                let gameID = request.params.game_id;
                let result = await gamesRepo.deleteRating(userIDP, gameID);
                response.send(JSON.stringify(result));
            }
            else {
                response.status(403).send("Forbidden: User not authorized to delete this rating");
            }
        }
        else {
            response.status(401).send("Unauthorized: User not authenticated");
        }
    } catch (error) {
        console.error("Error deleting rating:", error);
        response.status(500).send("Internal Server Error");
    }
}



module.exports = router;