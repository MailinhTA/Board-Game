const express = require('express');
const router = express.Router();
const gamesRepo = require('../utils/games.repository');

router.get('/list', gamesListAction); //Works
router.get('/page/:page/:pageSize', gamesPageAction); //Works


async function gamesListAction(request, response) {
    var games = await gamesRepo.getAllGames();
    response.send(JSON.stringify(games));
}

async function gamesPageAction(request, response) {
    var page = request.params.page;
    var pageSize = request.params.pageSize;
    var games = await gamesRepo.getGamePage(page, pageSize);
    response.send(JSON.stringify(games));
}


module.exports = router;