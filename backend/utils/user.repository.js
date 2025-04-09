require('dotenv').config();
let path = __dirname + "\\db.include.js";
pool = require(path);

module.exports = {
    getBlankUser() {
        return {
            "user_id": 0,
            "user_name": 'name',
            "user_email": 'email@example.com',
            "user_password": '',
            "user_created": new Date().toISOString().slice(0, 19).replace('T', ' '),
            "user_role": 'USER'
        };
    },

    async getAllUsers() {
        try {
            let sql = "SELECT * FROM users";
            const [rows, fields] = await pool.execute(sql);
            rows.forEach(row => {
                row.user_created = row.user_created.toISOString().slice(0, 10);
                // convert date from javascript format (YYYY-MM-DDT00:00:00.000Z) to SQL format (YYYY-MM-DD)
            });
            console.log("Users FETCHED: " + rows.length);
            return rows;
        } catch (err) {
            console.log(err);
            throw err;
        }
    },

    async getUserById(user_id) {
        let connection;
        try {
            let sql = "SELECT * FROM users WHERE user_id = ?";
            const [rows, fields] = await pool.execute(sql, [user_id]);
            if (rows.length === 1) {
                return rows[0];
            } else {
                return null;
            }
        } catch (err) {
            console.error("Error in getUserById:", err);
            throw err;
        }
    },

    async getUserRoleById(user_id) {
        try {
            let sql = "SELECT user_role FROM users WHERE user_id = ?";
            const [rows, fields] = await pool.execute(sql, [user_id]);
            if (rows.length === 1) {
                return rows[0].user_role;
            } else {
                return false;
            }
        }
        catch (err) {
            console.log(err);
            throw err;
        }
    },

    async addUser(user_name, user_email, user_password, user_role) {
        try {
            let sql = "INSERT INTO users (user_name, user_email, user_password, user_created, user_role) " +
                      "VALUES (?, ?, SHA2(CONCAT(now(), ?), 224), now(), ?)";
            const [okPacket, fields] = await pool.execute(sql, [user_name, user_email, user_password, user_role]);
            console.log("INSERT " + JSON.stringify(okPacket));
            return okPacket.insertId;
        } catch (err) {
            console.log(err);
            throw err;
        }
    },

    async updateUser(user_id, user_name, user_email, user_password, user_role) {
        try {
            let sql = "UPDATE users SET user_name=?, user_email=?, user_password=SHA2(CONCAT(now(), ?), 224), user_role=? WHERE user_id=?";
            const [okPacket, fields] = await pool.execute(sql, [user_name, user_email, user_password, user_role, user_id]);
            console.log("UPDATE " + JSON.stringify(okPacket));
            return okPacket.affectedRows;
        } catch (err) {
            console.log(err);
            throw err;
        }
    },

    async deleteUser(user_id) {
        try {
            // First delete related borrow records
            let sql = "DELETE FROM borrow WHERE user_id = ?";
            let [okPacket, fields] = await pool.execute(sql, [user_id]);
            
            sql = "DELETE FROM users WHERE user_id = ?";    
            [okPacket, fields] = await pool.execute(sql, [user_id]);
            console.log("DELETE " + JSON.stringify(okPacket));
            return okPacket.affectedRows;
        } catch (err) {
            console.log(err);
            throw err;
        }
    },

    async areValidCredentials(username, password) {
        try {
          let sql = "SELECT * FROM USERS WHERE user_name = ? AND user_password COLLATE utf8mb4_general_ci = sha2(concat(user_created, ?), 224) COLLATE utf8mb4_general_ci "; 
          // TODO: better salt + pw hash (bcrypt, pbkdf2, argon2)
          // COLLATE usually not needed (mariaDb compatibility)
          const [rows, fields] = await pool.execute(sql, [username, password]); 
          console.log(rows);
          if (rows.length == 1 && rows[0].user_name === username) {
            return true;
          } else {
            return false;
          }
        } catch (err) {
          console.log(err);
          throw err;
        }
    },
      
    async getOneUser(userName) {
        try {
          let conn = await pool.getConnection();
          let sql = "SELECT user_id,user_name,user_email,user_role FROM users WHERE user_name = ? ";
          // must leave out the password+hash info from result!
          const [rows, fields] = await pool.execute(sql, [ userName ]);
          if (rows.length == 1) {
            return rows[0];
          } else {
            return false;
          }
        } catch (err) {
          console.log(err);
          throw err;
        }
    }
};