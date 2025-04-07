<template>
  <div>

    <div v-if="action === 'show'">
      <h1>{{ currentGame[0][0].primary_name }}, {{ currentGame[0][0].yearpublished }}</h1>


      <table class="table table-striped table-bordered table-hover">
        <thead>
          <th colspan="2">
            Game Details
          </th>
        </thead>

        <tbody>
          <tr>
            <td rowspan="5">
              <img v-bind:src="currentGame[0][0].thumbnail" alt="game thumbnail" width="100px">
            </td>
          </tr>
          <tr>
            <td><strong>Play info:</strong><br/>
              Duration: {{ currentGame[0][0].playingtime }} min<br/>
              Min Age: {{ currentGame[0][0].minage }}<br/>
              Play Time: {{ currentGame[0][0].minplaytime }} min - {{ currentGame[0][0].maxplaytime }} max<br/>
            </td>
          </tr>
          <tr>
            <td><strong>Ranking:</strong>
              <ul>
                <li>BGG Rank: {{ currentGame[0][0].bgg_rank }}</li>
                <li>Average Rating: {{ currentGame[0][0].average_rating }}</li>
                <li>Bayes Average: {{ currentGame[0][0].bayes_average }}</li>
                <li>Users Rated: {{ currentGame[0][0].users_rated }}</li>
              </ul>
            </td>
          </tr>
          <tr>
            <td>
              <strong>Game Description:</strong><br/>
              {{ currentGame[0][0].description }}
            </td>
          </tr>


        </tbody>


      </table>


      <!-- show image -->
      <img v-bind:src="currentGame[0][0].thumbnail" alt="game thumbnail">

      <p>
      </p>

      <!-- display number of players -->
      <p>
        <strong>Number of Players:</strong><br/>
        {{ currentGame[0][0].minplayers }} - {{ currentGame[0][0].maxplayers }}
      </p>

    
      <table class="table table-striped table-bordered table-hover">
        <thead>
          <th colspan="2">
            Game Details
          </th>
        </thead>

        <tbody>
          <tr>
            <td><strong>Game ID:</strong></td>
            <td>{{ currentGame[0][0].id }}</td>
          </tr>
          <tr>
            <td><strong>Year Published:</strong></td>
            <td>{{ currentGame[0][0].yearpublished }}</td>
          </tr>
          <tr>
            <td><strong>Average Rating:</strong></td>
            <td>{{ currentGame[0][0].average_rating }}</td>
          </tr>
          <tr>
            <td><strong>Bayes Average:</strong></td>
            <td>{{ currentGame[0][0].bayes_average }}</td>
          </tr>
          <tr>
            <td><strong>BGG Rank:</strong></td>
            <td>{{ currentGame[0][0].bgg_rank }}</td>
          </tr>
          <tr>
            <td><strong>Users Rated:</strong></td>
            <td>{{ currentGame[0][0].users_rated }}</td>
          </tr>
          <tr>
            <td><strong>Playing Time:</strong></td>
            <td>{{ currentGame[0][0].playingtime }}</td>
          </tr>
          <tr>
            <td><strong>Min Players:</strong></td>
            <td>{{ currentGame[0][0].minplayers }}</td>
          </tr>
          <tr>
            <td><strong>Max Players:</strong></td>
            <td>{{ currentGame[0][0].maxplayers }}</td>
          </tr>
          <tr>
            <td><strong>Min Age:</strong></td>
            <td>{{ currentGame[0][0].minage }}</td>
          </tr>
          <tr>
            <td><strong>Min Play Time:</strong></td>
            <td>{{ currentGame[0][0].minplaytime }}</td>
          </tr>

        </tbody>
      </table>

      <table class="table table-striped table-bordered table-hover">
        <tbody>
          <tr v-for="list of currentGame">
            {{ list }}
          </tr>
        </tbody>
      </table>


      {{ currentGame }}
      </br>

    </div>


    <!--
    <div v-if="action === 'edit'">
    </div>
    -->
    <!-- v-model is a two-way data-binding, when the input changes, the variable changes too -->



    <!-- when on: /books/list/all -->
    <div  v-if="action === 'list'">   <!-- v-if is a conditional rendering -->
      <h1 class="component-h1">Game List</h1>

      <ul class="games-list">
        <li v-for="game of gameArray" v-bind:key="game.id" class="zoom-hover">
          <a :href="'/#/games/show/' + game.id">
            <table class="table table-bordered">
              <thead>
                <tr>
                  <th colspan="3">
                      {{ game.primary_name }}<br/>
                      <i><small>{{ game.yearpublished }}</small></i>
                  </th>
                </tr>
                <tr>
                  <th colspan="3">
                      <img v-bind:src="game.thumbnail" alt="game thumbnail">
                  </th>
                </tr>
              </thead>

              <!--
              <tbody>
                <tr>
                  <td>
                    Wanting
                  </td>
                  <td>
                    Trading
                  </td>
                  <td>
                    Wishlisted
                  </td>
                </tr>
                <tr>
                  <td>
                    {{ game.wanting }}
                  </td>
                  <td>
                    {{ game.trading }} / {{ game.owned }}
                  </td>
                  <td>
                    {{ game.wishing }}
                  </td>
                </tr>
              </tbody>
              -->
            </table>
          </a>
        </li>
      </ul>


      <!-- Page selector -->
      <div class="pagination" style="margin-top: 20px; text-align: center;">
        <button @click="pageNumber = Number(pageNumber) - 1" :disabled="pageNumber <= 1">Previous</button>
        <span>Page
          <!--<input type="number" v-model="pageNumber" min="1" :max="Math.ceil(gameArray.length / pageSize)" style="width: 50px; text-align: center;"/> of {{ Math.ceil(gameArray.length / pageSize) }}-->
          <input type="number" v-model="pageNumber" min="1" />
          / {{ numberOfPages }}
        </span>
        <button @click="pageNumber = Number(pageNumber) + 1" :disabled="pageNumber >= numberOfPages">Next</button>
      </div>


    </div>

  </div>
</template>


<script>
export default {
  name: 'Games',
  props: ['action', 'id'],  // properties that can be passed to the component
  // action: show, edit, list
  // id: book_id
  data() {
    return {   // variables that can be used in the template
      //user_role: 'GUEST',
      pageNumber: 1,
      pageSize: 30,
      numberOfPages: 0,

      gameArray: [],
      libraryArray: [],

      currentGame: {
        /*[0] is game
        */
        /*
        id: 0,
        primary_name: "xxx",
        description: "xxx",
        yearpublished: 0,
        minplayers: 0,
        maxplayers: 0,
        playingtime: 0,
        minplaytime: 0,
        maxplaytime: 0,
        minage: 0,
        bgg_rank: 0,
        average_rating: 0.00,
        bayes_average: 0.000,
        users_rated : 0,
        url: "xxx",
        thumbnail: "xxx",
        owned: 0,
        trading: 0,
        wanting: 0,
        wishing: 0*/
      }
    };
  },

  methods: {   // logic that can be called from the template

    async getAllData(pageNumber, pageSize) {
      try {
        let responseGames = await this.$http.get('http://localhost:9000/api/games/page/' + this.pageNumber + '/' + this.pageSize);
        this.gameArray = await responseGames.data;

      } catch (exception) {
        console.log(exception);
      }
    },

    async getNumberOfPages() {
      try {
        let response = await this.$http.get('http://localhost:9000/api/games/total/pages/' + this.pageSize);
        return response.data;
      } catch (exception) {
        console.log(exception);
      }
    },


    async refreshcurrentGame() {
      if (this.$props.id === "all" || this.$props.id === "0") {
        this.currentGame = {
          /*
          id: 0,
          primary_name: "xxx",
          description: "xxx",
          yearpublished: 0,
          minplayers: 0,
          maxplayers: 0,
          playingtime: 0,
          minplaytime: 0,
          maxplaytime: 0,
          minage: 0,
          bgg_rank: 0,
          average_rating: 0.00,
          bayes_average: 0.000,
          users_rated : 0,
          url: "xxx",
          thumbnail: "xxx",
          owned: 0,
          trading: 0,
          wanting: 0,
          wishing: 0*/
        };
        return;
      }
      try {
        let responseGame = await this.$http.get("http://localhost:9000/api/games/" + this.$props.id);
        this.currentGame = responseGame.data;

      } catch (ex) {
        console.log(ex);
      }
    },

    /*
    async sendDeleteRequest(book_id) {
      try {
        alert("DELETING BOOK #" + book_id + "...");
        let response = await this.$http.get("http://localhost:9000/api/books/del/" + book_id);
        alert("DELETED: " + response.data.rowsDeleted + " book(s)");
        this.getAllData();

      } catch (ex) {
        console.log(ex);
      }
    },

    async sendEditRequest() {
      try {
        alert("EDITING BOOK #" + this.currentGame.book_id + "...");
        let response = await this.$http.post("http://localhost:9000/api/books/update/" + this.currentGame.book_id, {
          book_name: this.currentGame.book_name,
          book_author: this.currentGame.book_author,
          book_description: this.currentGame.book_description,
          book_publicationDate: this.currentGame.book_publicationDate,
          book_isbn: this.currentGame.book_isbn,
          book_imageFileName: this.currentGame.book_imageFileName
        });
        alert("EDITED: " + response.data.rowsUpdated);
        this.$router.push({path: '/books'}); // redirect to the book list
        this.getAllData();

      } catch (ex) {
        console.log(ex)
      }
    },

    async borrowBook(book_library_mapping_id) {
      try {
        if (this.user_role === 'GUEST') {
          alert("You must create an account to borrow a book");
          return;
        }
        else {
          //alert("BORROWING BOOK #" + book_library_mapping_id + "...");
          let response = await this.$http.get("http://localhost:9000/api/borrow/add/" + book_library_mapping_id);
          alert("BORROWED: " + response.data.rowsUpdated + " book(s)");
        }
      } catch (ex) {
        console.log(ex);
      }
    },

    async searchRequest() {
      try {
        let searchValue = document.getElementById("searchBar").value;
        if (searchValue === "") {
          this.getAllData();
          return;
        }
        let response = await this.$http.get("http://localhost:9000/api/books/search/" + searchValue);
        this.bookArray = response.data;

      } catch (ex) {
        console.log(ex);
      }
    }*/

  },

  watch: {   // watch for changes in the variables
    id: function(newId, oldId) {
      this.refreshcurrentGame();
    },

    action: function(newAction, oldAction) {
      if (newAction === 'list') {
        this.getAllData(this.pageNumber, this.pageSize);
      }
    },

    pageNumber: function(newPageNumber, oldPageNumber) {
      this.getAllData(this.pageNumber, this.pageSize);
    },

    pageSize: function(newPageSize, oldPageSize) {
      this.getAllData(this.pageNumber, this.pageSize);
    }
  },

  created() {   // executed when the component is created
    //this.getUserRole();
    this.getAllData(this.pageNumber, this.pageSize);
    this.getNumberOfPages().then((numberOfPages) => {
      this.numberOfPages = numberOfPages;
    });
    this.refreshcurrentGame();
  }
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  h1, h2 {
    font-weight: normal;
  }

  a {
    color: #000000;
    text-decoration: none;
  }

  a:hover {
    text-decoration: underline;
  }

  .new-button {
    padding: 10px;
    margin-bottom: 20px;
    margin-top: -30px;
  }


  /************ GAMES LIST ************/
  .games-list {
    margin: auto; /* Center the ul element */
    margin-top: 20px;
    display: flex;
    flex-wrap: wrap;
    flex-direction: row;
    align-items: center;
    justify-content: center;
    text-align: center;
    max-width: 1300px;
    list-style-type: none; /* Remove dots */
  }

  .games-list li {
    margin: 0 20px 20px;
    text-align: center;
    position: relative;
    max-width: 200px;
  }
  
  .games-list li img {
    max-width: 100px;
    max-height: 100px;
  }

  .games-list tbody {
    text-align: center;
    font-size: 0.8em;
  }

  /************ Pagination ************/
  .pagination {
    display: flex;
    justify-content: center;
    align-items: center;
    /* space between the buttons */
    gap: 10px;
  }

  .pagination input[type="number"] {
    width: 70px;
    text-align: center;
  }

  table {
    width: 80%;
    /* center the table */
    margin: 20px auto;
  }
  

</style>