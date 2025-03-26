<template>
  <div>

    <div v-if="action === 'show'">
      <h1 class="component-h1">{{ currentGame.primary_name }}</h1>

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


      <ul class="book-list">
        <li v-for="game of gameArray" v-bind:key="game.id">
            {{ game.primary_name }}, {{ game.id }}
            <!-- the src of the img will be the field game.thumbnail of the game object-->
            <img v-bind:src="game.thumbnail" alt="game thumbnail">
        </li>
      </ul>
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
      gameArray: [],
      libraryArray: [],

      currentGame: {
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
        wishing: 0
      }
    };
  },

  methods: {   // logic that can be called from the template

    async getAllData() {
      try {
        let responseGames = await this.$http.get('http://localhost:9000/api/games/page/2/30');
        this.gameArray = await responseGames.data[0];

      } catch (exception) {
        console.log(exception);
      }
    },


    /*
    async refreshcurrentGame() {
      if (this.$props.id === "all" || this.$props.id === "0") {
        this.currentGame = {
          book_id: 0,
          book_name: 'Book Name',
          book_author: 'Book Author',
          book_description: 'Description...',
          book_publicationDate: '2000-01-01',
          book_isbn: '9780000000000',
          book_imageFileName: 'default-cover.jpg'
        };
        return;
      }
      try {
        let responseBook = await this.$http.get("http://localhost:9000/api/books/show/" + this.$props.id);
        this.currentGame = responseBook.data;

        let responseLibraries = await this.$http.get("http://localhost:9000/api/books/listlibraries/" + this.$props.id);
        this.libraryArray = responseLibraries.data;

      } catch (ex) {
        console.log(ex);
      }

      // for testing purposes
      //this.currentGame = this.bookArray.find(b => b.book_id === Number(this.$props.id));   // or String(b.book_id)
    },

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
      //this.refreshcurrentGame();
    },
    action: function(newAction, oldAction) {
      if (newAction === 'list') {
        this.getAllData();
      }
    }
  },

  created() {   // executed when the component is created
    //this.getUserRole();
    this.getAllData();
    //this.refreshcurrentGame();
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


  

</style>