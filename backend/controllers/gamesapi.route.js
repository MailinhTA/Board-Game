const express = require('express');
const router = express.Router();
const gamesRepo = require('../utils/games.repository');

router.get('/list', gamesListAction); //Works
router.get('/page/:page/:pageSize', gamesPageAction); //Works
router.get('/total/games', totalGamesAction);
router.get('/total/pages/:pageSize', totalPagesAction); //Works


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

async function totalGamesAction(request, response) {
    var total = await gamesRepo.getTotalGames();
    response.send(JSON.stringify(total));
}

async function totalPagesAction(request, response) {
    var pageSize = request.params.pageSize;
    var total = await gamesRepo.getTotalPages(pageSize);
    response.send(JSON.stringify(total));
}


module.exports = router;