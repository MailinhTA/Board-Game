require('dotenv').config();
let path = __dirname + "\\db.include.js";
pool = require(path);

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
    }
};
