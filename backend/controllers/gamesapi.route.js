const express = require('express');
const router = express.Router();
const gamesRepo = require('../utils/games.repository');

router.get('/list', gamesListAction); //Works


async function gamesListAction(request, response) {
    var games = await gamesRepo.getAllGames();
    response.send(JSON.stringify(games));
}


module.exports = router;