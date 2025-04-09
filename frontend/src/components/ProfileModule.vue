<template>
  <div>

    {{ this.role }}

    <div v-if="action === 'myprofile'">
      <!-- If the user is not logged in -->
      <div v-if="this.role === 'GUEST'">
        <h1 class="component-h1">You don't have a profile yet?</h1>
        <a href="#/profile/register">Click here</a> to create your profile.
        <br><br><br><br><br><br><br><br><br><br><br><br>
      </div>

      <!-- If the user is logged in -->
      <div v-if="this.role !== 'GUEST'">
        {{ currentUser }}
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
        
        <!-- Book list -->
        <div>
          <h1 class="component-h1">Your borrows</h1>
          <ul class="book-list">
            <li v-for="book of bookArray" v-bind:key="book.book_id" class="zoom-hover">
              <table class="table table-bordered">
                <thead>
                  <tr>
                    <th colspan="3">
                      <a :href="'/#/books/show/' + book.book_id">
                        {{ book.book_name }}<br/>
                        <i><small>{{ book.book_author }}</small></i>
                      </a>
                    </th>
                  </tr>
                  <tr>
                    <th colspan="3">
                      <a :href="'/#/books/show/' + book.book_id">
                        <img v-bind:src="'../../static/book-covers/'+book.book_imageFileName" alt="" width="150" height="230">
                      </a>
                    </th>
                  </tr>
                </thead>

                <tbody>
                  <tr>
                    <td>
                      <b>Borrow status:</b><br/>
                      {{ book.borrow_status }}
                    </td>
                  </tr>
                  <tr>
                    <td>
                      <b>Due date:</b><br/>
                      {{book.borrow_returnDate}}
                    </td>
                  </tr>
                  <tr>
                    <td>
                      <b>Fine:</b> {{book.borrow_fine}}$
                    </td>
                  </tr>
                </tbody>
              </table>
            </li>
          </ul>
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
          <button type="submit" @click="sendEditRequest()" class="zoom-hover send-update">Submit</button>
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
            bookArray: [],
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
            // Uncomment and fix this if you want to load borrowed books
            // response = await this.$http.get("http://localhost:9000/api/borrow/userbooks/"+this.currentUser.user_id);
            // this.bookArray = response.data;
          }
        } catch (error) {
          console.log(error);
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

  /************ BOOK LIST ************/
  .book-list {
    margin: auto; /* Center the ul element */
    margin-top: 20px;
    display: flex;
    flex-wrap: wrap;
    flex-direction: row;
    align-items: center;
    justify-content: center;
    text-align: center;
    max-width: 1500px;
    list-style-type: none; /* Remove dots */
  }

  .book-list li {
    margin: 0 20px 20px;
    text-align: center;
    position: relative;
    max-width: 200px;
  }

  .book-list a {
    color: #000000;
    text-decoration: none;
  }

  .book-list a:hover {
    text-decoration: underline;
  }
</style>