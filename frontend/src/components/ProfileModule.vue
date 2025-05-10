<template>
  <div>

    <!--{{ this.role }}-->

    <div v-if="action === 'myprofile'">
      <!-- If the user is not logged in -->
      <div v-if="this.role === 'GUEST'">
        <h1 class="component-h1">You don't have a profile yet?</h1>
        <a href="#/profile/register">Click here</a> to create your profile.
        <br><br><br><br><br><br><br><br><br><br><br><br>
      </div>

      <!-- If the user is logged in -->
      <div v-if="this.role !== 'GUEST'">
        <!--{{ currentUser }}-->
        <h1 class="component-h1">Your Profile, {{currentUser.user_name}}</h1>
        <div class="show-user">
            <table class="table table-striped table-bordered">
                <tbody>
                    <tr>
                        <th>User ID</th>
                        <td>{{ currentUser.user_id }}</td>
                    </tr>
                    <tr>
                        <th>Name</th>
                        <td>{{ currentUser.user_name }}</td>
                    </tr>
                    <tr>
                        <th>Email</th>
                        <td>{{ currentUser.user_email }}</td>
                    </tr>
                    <tr>
                        <th>Role</th>
                        <td>{{ currentUser.user_role }}</td>
                    </tr>
                </tbody>
            </table>
        </div>
        <br><br>
        <hr>
        
        <!-- Ratings list -->
        <div>
          <h1 class="component-h1">Your Ratings</h1>
          <!--{{ RatingsArray }}-->
          <div v-if="RatingsArray.length === 0">
            <p>You haven't rated any games yet.</p>
          </div>
          <div v-else class="ratings-container">
            <div v-for="rating in RatingsArray" :key="rating.rating_id" class="rating-card">
              <div class="rating-header">
                <h3 class="game-name">{{ rating.primary_name }}</h3>
                <div class="rating-score">
                  {{ rating.rating }}
                </div>
              </div>
              <div class="rating-content">
                <p class="rating-comment"><b>" </b>{{ rating.rating_comment || "No comment" }}<b> "</b></p>
                <div class="rating-date">Rated on: {{ rating.rating_date }}</div>
              </div>
              <div class="rating-actions">
                <a :href="'#/games/show/' + rating.game_id" class="btn">View Game</a>
                <button @click="deleteRating(currentUser.user_id, rating.game_id)" class="btn">Delete Rating</button>
            </div>
            </div>
          </div><br><br><br><br><br>
        </div>

      </div>
    </div>


    <div v-if="action === 'register'">
      <h1 class="component-h1">Register</h1>
      <div class="form">
        <div class="form-group">
          <label for="username">Username:</label>
          <input type="text" class="form-control" id="username" name="username" v-model="currentUser.user_name">
          <br>
          <label for="email">Email:</label>
          <input type="email" class="form-control" id="email" name="email" v-model="currentUser.user_email">
          <br>
          <label for="password">Password:</label>
          <input type="password" class="form-control" id="password" name="password" v-model="currentUser.user_password">
          <br>
          <button type="submit" @click="sendAddRequest()" class="zoom-hover send-update">Submit</button>
          <p> you already have an account? <a href="#/profile/login">Login</a></p>
        </div>
      </div>
    </div>


    <div v-if="action === 'login'">
      <h1 class="component-h1">Login</h1>
      <div class="form">
        <div class="form-group">
          <label for="username">Username:</label>
          <input type="text" class="form-control" id="username" name="username" required>
          <br>
          <label for="password">Password:</label>
          <input type="password" class="form-control" id="password" name="password" required>
          <br>
          <button type="submit" @click="submitAuth()" class="zoom-hover">Submit</button>
          <p> you don't have an account? <a href="#/profile/register">Register</a></p>
        </div>
      </div>
      <div>
        <h1 class="component-h1">For testing purposes</h1>
          ('John Doe', 'john.doe@example.com', SHA2(CONCAT(now(), 'password123'), 224), now(), 'USER'),</br>
          ('Jane Smith', 'jane.smith@example.com', SHA2(CONCAT(now(), 'secretpass'), 224), now(), 'USER'),</br>
          ('Emily Clark', 'emily.clark@example.com', SHA2(CONCAT(now(), 'mypassword'), 224), now(), 'USER'),</br>
          ('Sarah Lee', 'sarah.lee@example.com', SHA2(CONCAT(now(), 'letmein'), 224), now(), 'USER'),</br>
          ('Michael Brown', 'michael.brown@example.com', SHA2(CONCAT(now(), 'adminpass'), 224), now(), 'ADMIN')</br>
      </div>
    </div>

    <div id="edit-error"></div>
  </div>
</template>


<script>
  export default {
    name: 'Authentication',
    props: ['action'],

    data() {
        return {
            role: '',
            RatingsArray: [],
            currentUser: {
                user_id: 0,
                user_name: '',
                user_email: '',
                user_role: ''
            }
        };
    },

    methods: {
      submitAuth() {
        const username = document.getElementById("username").value;
        const password = document.getElementById("password").value;
        this.sendRequest('post', 'login', { username: username, userpass: password });
      },

      async getUserRole() {
        try {
          let response = await this.$http.get("http://localhost:9000/api/auth/role");
          this.role = response.data;
          // Call refreshCurrentUser after role is updated
          if (this.role !== 'GUEST') {
            await this.refreshCurrentUser();
          }
        } catch (ex) {
          console.log(ex);
        }
      },

      async refreshCurrentUser() {
        try {
          if (this.role && this.role !== 'GUEST') {
            let response = await this.$http.get("http://localhost:9000/api/auth/"+this.role.toLowerCase());
            this.currentUser = response.data;
            await this.getRatings();
          }
        } catch (error) {
          console.log(error);
        }
      },

      async getRatings() {
        try {
          let response = await this.$http.get("http://localhost:9000/api/ratings/getuser/"+this.currentUser.user_id);
          this.RatingsArray = response.data;
        } catch (error) {
          console.log(error);
        }
      },

      async deleteRating(userID, gameID) {
        try {
          await this.$http.get("http://localhost:9000/api/ratings/delete/"+userID+"/"+gameID);
          // Refresh the ratings after deletion
          await this.getRatings();
        } catch (error) {
          if (error.response.status === 403) {
            alert("You are not allowed to delete this rating.");
          } else if (error.response.status === 401) {
            alert("Unauthorized. Please log in.");
          } else if (error.response.status === 500) {
            alert("Server error. Please try again later.");
          } else {
            alert(error);
          }
        }
      },

      async sendRequest(method, endpoint, params) {
        let errorDiv = document.createElement("div");
        try {
          let response = null;
          if (method === "post") 
            response = await this.$http.post("http://localhost:9000/api/auth/"+endpoint, params);
          else
            response = await this.$http.get("http://localhost:9000/api/auth/"+endpoint);
          
          this.role = response.data.userRole;
          if (response.data.loginResult) {
            errorDiv.innerHTML = "Login successful";
            this.$router.push('/profile/myprofile');
          }
          else
            errorDiv.innerHTML = "Wrong username or password";
          //errorDiv.innerHTML = JSON.stringify(response.data).replace(/\"/g, "");
          errorDiv.style.color = "red";
          document.getElementById("edit-error").appendChild(errorDiv);
          // redirect to profile page

        } catch (error) {
          console.log(ex)

          errorDiv.innerHTML = "Wrong username or password";
          errorDiv.style.color = "red";
          document.getElementById("edit-error").appendChild(errorDiv);
        }
      },

      async sendRequest(method, endpoint, params) {
        let errorDiv = document.createElement("div");
        try {
          let response = null;
          if (method === "post") 
            response = await this.$http.post("http://localhost:9000/api/auth/"+endpoint, params);
          else
            response = await this.$http.get("http://localhost:9000/api/auth/"+endpoint);
          
          this.role = response.data.userRole;
          if (response.data.loginResult) {
            await this.refreshCurrentUser(); // Make sure user data is refreshed after login
            errorDiv.innerHTML = "Login successful";
            this.$router.push('/profile/myprofile');
          }
          else
            errorDiv.innerHTML = "Wrong username or password";
          errorDiv.style.color = "red";
          document.getElementById("edit-error").appendChild(errorDiv);

        } catch (error) { // Fixed variable name from 'ex' to 'error'
          console.log(error);
          errorDiv.innerHTML = "Wrong username or password";
          errorDiv.style.color = "red";
          document.getElementById("edit-error").appendChild(errorDiv);
        }
      },
      
      async sendAddRequest() {
        try {
            let response = await this.$http.post("http://localhost:9000/api/users/add" , {
                user_name: this.currentUser.user_name,
                user_email: this.currentUser.user_email,
                user_password: this.currentUser.user_password
            });

            let errorDiv = document.createElement("div");
            errorDiv.innerHTML = "Profile successfully created. You can now login";
            errorDiv.style.color = "red";
            document.getElementById("edit-error").appendChild(errorDiv);
        } catch (error) {
            console.log(error);
            let errorDiv = document.createElement("div");
            errorDiv.innerHTML = "Someone with that username/email already exists";
            errorDiv.style.color = "red";
            document.getElementById("edit-error").appendChild(errorDiv);
        }
      },

    },

    watch: {

      // if logout, call getUserRole 
      id: function(newId, oldId) {
        if (newRole !== 'GUEST') {
          this.refreshCurrentUser();
        }
      },
      action: function(newAction, oldAction) {
        if (newAction === "myprofile") {
          this.getUserRole(); // Call getUserRole instead of refreshCurrentUser directly
        }
        else
          document.getElementById("edit-error").innerHTML = "";
      }

    },

    created() {
      this.getUserRole(); // This will also call refreshCurrentUser when complete
    }
  }
</script>


<style scoped>
  .show-user {
      margin: auto;
      width: 80%;
      max-width: 800px;
  }

  .show-user table {
      width: 100%;
  }

  input[type="button"], button {
    padding: 10px;
    margin-bottom: 20px;
  }

  .form {
    display: flex;
    flex-direction: column;
    width: 100%;
    max-width: 500px;
    border: #42b983 3px solid;
    padding: 20px;
    margin: auto auto 20px;
  }


  /************ RATINGS LIST ************/

  .ratings-container {
    max-width: 1200px;
    margin: auto;
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
    margin-top: 20px;
  }


  .rating-card {
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    padding: 16px;
    transition: transform 0.2s, box-shadow 0.2s;
  }

  .rating-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
  }

  .rating-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
    border-bottom: 1px solid #f0f0f0;
    padding-bottom: 8px;
  }

  .game-name {
    margin: 0;
    font-size: 18px;
    font-weight: bold;
  }

  .rating-score {
    font-weight: bold;
    padding: 5px 10px;
    border-radius: 15px;
    min-width: 35px;
    text-align: center;
  }

  .low-rating { background-color: #ffcccc; color: #d32f2f; }
  .medium-rating { background-color: #fff0c8; color: #ff8f00; }
  .high-rating { background-color: #d4edda; color: #28a745; }
  .rating-content {
    padding-top: 8px;
  }

  .rating-comment {
    font-style: italic;
    margin-bottom: 12px;
  }

  .rating-date {
    font-size: 0.8rem;
    color: #666;
    text-align: right;
  }

  .rating-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 12px;
  }

  .rating-actions .btn {
    background-color: #007bff;
    color: white;
    padding: 10px 15px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    text-decoration: none;
  }
  .rating-actions .btn:hover {
    background-color: #0056b3;
  }
</style>