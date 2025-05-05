const express = require('express');
const router = express.Router();
const gamesRepo = require('../utils/ratings.repository');

router.post('/add', addRatingAction);


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



module.exports = router;