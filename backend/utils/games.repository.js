require('dotenv').config();
const path = require('path');
let dbPath = path.join(__dirname, "db.include.js");
pool = require(dbPath);

//const { verifyInput } = require('../utils/inputvalidation');


module.exports = {
    getBlankGame() {
        return {
            "id": 0,
            "primary_name": "xxx",
            "description": "xxx",
            "yearpublished": 0,
            "minplayers": 0,
            "maxplayers": 0,
            "playingtime": 0,
            "minplaytime": 0,
            "maxplaytime": 0,
            "minage": 0,
            "bgg_rank": 0,
            "average_rating": 0.00,
            "bayes_average": 0.000,
            "users_rated" : 0,
            "url": "xxx",
            "thumbnail": "xxx",
            "owned": 0,
            "trading": 0,
            "wanting": 0,
            "wishing": 0
        };
    },

    async getAllGames() {
        try {
            let sql = "SELECT * FROM games";
            const [rows, fields] = await pool.execute(sql);
            console.log("Games FETCHED: " + rows.length);
            return rows;
            
        } catch (err) {
            console.log(err);
            throw err;
        }
    },

    async getGamePage(page, pageSize, sort) {
        try {
            let sql = "CALL get_games_page(?, ?, ?)";
            const [rows, fields] = await pool.execute(sql, [page, pageSize, sort]);
            console.log("Games FETCHED: " + rows[0].length);
            return rows[0];
            
        } catch (err) {
            console.log(err);
            throw err;
        }
    },

    async getSearchGamePage(searchTerm, page, pageSize, sort) {
        try {
            let sql = "CALL search_games_by_name(?, ?, ?, ?)";
            const [rows, fields] = await pool.execute(sql, [searchTerm, page, pageSize, sort]);
            console.log("Games FETCHED: " + rows[0].length);
            return rows[0];
            
        } catch (err) {
            console.log(err);
            throw err;
        }
    },

    async getCategoryGamePage(category, page, pageSize, sort) {
        try {
            let sql = "CALL get_games_by_category(?, ?, ?, ?)";
            const [rows, fields] = await pool.execute(sql, [category, page, pageSize, sort]);
            console.log("Games FETCHED: " + rows[0].length);
            return rows[0];
            
        } catch (err) {
            console.log(err);
            throw err;
        }
    },

    async getTotalGames() {
        try {
            let sql = "SELECT get_total_games()";
            const [rows, fields] = await pool.execute(sql);
            console.log("NUMBER of games: " + rows[0]['get_total_games()']);
            return rows[0]['get_total_games()'];
        }
        catch (err) {
            console.log(err);
            throw err;
        }
    },

    async getTotalPages(pageSize) {
        try {
            let sql = "SELECT get_total_games()";
            const [rows, fields] = await pool.execute(sql);
            let pageNumber = Math.ceil(rows[0]['get_total_games()'] / pageSize);
            console.log("NUMBER of pages: " + pageNumber);
            return pageNumber;
        }
        catch (err) {
            console.log(err);
            throw err;
        }
    },

    async getGameById(id) {
        try {
            let sql = "CALL get_game_by_id(?)";
            const [rows, fields] = await pool.execute(sql, [id]);
            console.log("Game FETCHED of ID: " + id);
            return rows;
        }
        catch (err) {
            console.log(err);
            throw err;
        }
    }
};
