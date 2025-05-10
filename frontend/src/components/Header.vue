<template>
  <header>
    <nav>
      <ul>
        <li>
          <a href="#/">
            <h1>
              <img src="../assets/logos/wikigames.png" alt="" width="80">
              Wikigames </h1>
          </a>
        </li>
        <li class="zoom-hover">
          <a href="#/games/list/all/"> Games</a>
        </li>
        <!--
        <li class="zoom-hover">
          <a href="#/libraries/list/all" @click="getUserRole()"> Libraries</a>
        </li>
        <li v-if="user_role === 'ADMIN'" class="zoom-hover">
          <a href="#/mappings/list/all"> Mappings</a>
        </li>
        <li v-if="user_role === 'ADMIN'" class="zoom-hover">
          <a href="#/borrow/list/all"> Borrows</a>
        </li>
        <li v-if="user_role === 'ADMIN'" class="zoom-hover">
          <a href="#/users/list/all"> Users</a>
        </li>
        <li class="zoom-hover">
          <a href="#/statistics"> Statistics</a>
        </li>-->
      </ul>

      <ul @mouseover="active = true" @mouseleave="active = false" >
        <li>
          <div>
            Profile
            <!--<img src="../assets/logos/profile-logo.png" alt="" width="50">-->

            <ul v-if="active === true" class="profile-list">
              <li class="zoom-hover">
                <a href="#/profile/myprofile"> My Profile</a>
              </li>
              <li class="zoom-hover">
                <a href="#/profile/register"> Register</a>
              </li>
              <li class="zoom-hover">
                <a href="#/profile/login"> Login</a>
              </li>
              <li class="zoom-hover">
                <input type="button" @click="sendLogoutRequest('get', 'logout')" value="LOGOUT" />
              </li>
            </ul>
          </div>
        </li>
      </ul>

    </nav>
  </header>
</template>

<script>
export default {
  name: 'AppHeader',

  data () {
    return {   // variables that can be used in the template
      user_role: 'GUEST',
      active: false
      }
  },

  methods: {
    async sendLogoutRequest(method, endpoint, params) {
      try {
        this.$router.push('/profile/login');
        let response = null;
        response = await this.$http.get("http://localhost:9000/api/auth/"+endpoint);
        this.msg = JSON.stringify(response.data);
      } catch (error) {
        console.log(ex)
      }
    }
  },
};
</script>

<style scoped>
  header {
    background-color: #4b5861;
    padding-top: 10px;
    color: white;
    text-align: left;
  }

  nav {
    margin-left: 50px;
    margin-right: 50px;
    display: flex;
    justify-content: space-between;
  }

  nav ul {
    list-style: none;
    display: flex;
    flex-wrap: wrap;
    gap: 40px;
    align-items: center;
  }

  a {
    color: white;
    text-decoration: none;
  }

  div img {
    margin-right: 10px;
    margin-left: 10px;
  }

  .profile-list {
    position: absolute;
    right: 0;
    background-color: black;
    padding: 20px;
    margin-top: 10px;
    border-radius: 5px;
    display: flex;
    flex-direction: column;
    gap: 20px;
    z-index: 100;
  }

  
  /* button OR input[type="button"] */
  button, input[type="button"] {
    background-color: #4CAF50; /* Green */
    border: none;
    color: white;
    padding: 9px 20px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 16px;
    margin: 4px 2px;
    cursor: pointer;
    border-radius: 4px;
  }
  button:hover, input[type="button"]:hover {
    background-color: #45a049;
  }
  button:disabled, input[type="button"]:disabled {
    background-color: #ccc;
    cursor: not-allowed;
  }
</style>
