require('dotenv').config();
const path = require('path');
let dbPath = path.join(__dirname, "db.include.js");
pool = require(dbPath);



module.exports = {

    async addRating(p_user_id, p_game_id, p_rating, p_comment) {
        try {
            let sql = "CALL add_game_rating(?, ?, ?, ?)";
            const [rows, fields] = await pool.execute(sql, [p_user_id, p_game_id, p_rating, p_comment]);
            console.log("ADDED Rating for game " + p_game_id + " by user " + p_user_id);
            return rows;
        }
        catch (err) {
            console.log(err);
            throw err;
        }
    },

    async getRatings(p_game_id) {
        try {
            let sql = "CALL get_latest_game_ratings(?)";
            const [rows, fields] = await pool.execute(sql, [p_game_id]);
            console.log("GET Ratings for game " + p_game_id);
            // change date format from YYYY-MM-DDTHH:MM:SS to YYYY-MM-DD
            for (let i = 0; i < rows[0].length; i++) {
                rows[0][i].rating_date = rows[0][i].rating_date.toISOString().split('T')[0];
            }
            return rows[0];
        }
        catch (err) {
            console.log(err);
            throw err;
        }
    },

    async getUserRatings(p_user_id) {
        try {
            let sql = "CALL get_user_ratings(?)";
            const [rows, fields] = await pool.execute(sql, [p_user_id]);
            console.log("GET Ratings for user " + p_user_id);
            // change date format from YYYY-MM-DDTHH:MM:SS to YYYY-MM-DD
            for (let i = 0; i < rows[0].length; i++) {
                rows[0][i].rating_date = rows[0][i].rating_date.toISOString().split('T')[0];
            }
            return rows[0];
        }
        catch (err) {
            console.log(err);
            throw err;
        }
    },

    async deleteRating(p_user_id, p_game_id) {
        try {
            let sql = "CALL delete_game_rating(?, ?)";
            const [rows, fields] = await pool.execute(sql, [p_user_id, p_game_id]);
            console.log("DELETED Rating for game " + p_game_id + " by user " + p_user_id);
            return rows;
        }
        catch (err) {
            console.log(err);
            throw err;
        }
    }


};