const express = require('express');
const router = express.Router();
const gamesRepo = require('../utils/ratings.repository');

router.get('/add/:user_id/:game_id/:rating/:comment', addRatingAction);


async function addRatingAction(request, response) {
    var user_id = request.params.user_id;
    var game_id = request.params.game_id;
    var rating = request.params.rating;
    var comment = request.params.comment;
    var result = await gamesRepo.addRating(user_id, game_id, rating, comment);
    response.send(JSON.stringify(result));
}



module.exports = router;