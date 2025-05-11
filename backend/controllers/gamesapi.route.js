const express = require('express');
const router = express.Router();
const gamesRepo = require('../utils/games.repository');

router.get('/list', gamesListAction); //Works
router.get('/page/:page/:pageSize/:sort', gamesPageAction); //Works
router.get('/search/:searchTerm/:page/:pageSize/:sort', gamesSearchPageAction); //Works
router.get('/category/:category/:page/:pageSize/:sort', gamesCategoryPageAction); //Works

router.get('/total/games', totalGamesAction);
router.get('/total/pages/:pageSize', totalPagesAction); //Works

router.get('/:id', getGameByIdAction);


async function gamesListAction(request, response) {
    var games = await gamesRepo.getAllGames();
    response.send(JSON.stringify(games));
}

async function gamesPageAction(request, response) {
    var page = request.params.page;
    var pageSize = request.params.pageSize;
    var sort = request.params.sort;
    var games = await gamesRepo.getGamePage(page, pageSize, sort);
    response.send(JSON.stringify(games));
}

async function gamesSearchPageAction(request, response) {
    var searchTerm = request.params.searchTerm;
    var page = request.params.page;
    var pageSize = request.params.pageSize;
    var sort = request.params.sort;
    var games = await gamesRepo.getSearchGamePage(searchTerm, page, pageSize, sort);
    response.send(JSON.stringify(games));
}

async function gamesCategoryPageAction(request, response) {
    var category = request.params.category;
    var page = request.params.page;
    var pageSize = request.params.pageSize;
    var sort = request.params.sort;
    var games = await gamesRepo.getCategoryGamePage(category, page, pageSize, sort);
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

async function getGameByIdAction(request, response) {
    var id = request.params.id;
    var game = await gamesRepo.getGameById(id);
    response.send(JSON.stringify(game));
}

module.exports = router;