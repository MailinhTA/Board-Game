<template>
  <div>

    <div v-if="action === 'show'" class="game-details-container">
      <div class="game-header">
        <div class="container">
          <div class="row align-items-center py-4">
            <div class="col-md-3 text-center">
              <img v-bind:src="currentGame[0][0].thumbnail" alt="game thumbnail" class="game-cover-image shadow">
            </div>
            <div class="col-md-9">
              <h1 class="game-title">{{ currentGame[0][0].primary_name }}</h1>
              <div class="game-year">{{ currentGame[0][0].yearpublished }}</div>
              <div class="game-meta mt-3">
                <span class="badge bg-primary me-2">Players: {{ currentGame[0][0].minplayers }} - {{ currentGame[0][0].maxplayers }}</span>
                <span class="badge bg-success me-2">Age: {{ currentGame[0][0].minage }}+</span>
                <span class="badge bg-info me-2">Time: {{ currentGame[0][0].minplaytime }}-{{ currentGame[0][0].maxplaytime }} min</span>
                <span class="badge bg-warning text-dark">BGG Rank: #{{ currentGame[0][0].bgg_rank }}</span>
              </div>
              <div class="rating-container mt-3">
                <div class="rating-stars">
                  <div class="rating-value" :style="{ width: (currentGame[0][0].average_rating * 10) + '%' }"></div>
                </div>
                <div class="rating-text">{{ parseFloat(currentGame[0][0].average_rating).toFixed(1) }}/10 
                  <small class="text-muted">({{ currentGame[0][0].users_rated }} ratings)</small>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="container mt-4">
        <div class="row">
          <!-- Main content column -->
          <div class="col-lg-8">
            <div class="card mb-4 shadow-sm">
              <div class="card-header bg-white">
                <h4 class="mb-0"><i class="fas fa-book me-2"></i>Description</h4>
              </div>
              <div class="card-body">
                <p class="game-description">{{ currentGame[0][0].description }}</p>
              </div>
            </div>

            <div class="card mb-4 shadow-sm">
              <div class="card-header bg-white">
                <h4 class="mb-0"><i class="fas fa-gamepad me-2"></i>Game Info</h4>
              </div>
              <div class="card-body">
                <div class="row info-item">
                  <div class="col-md-6">
                    <div class="info-item">
                      <div class="info-label">Designer</div>
                      <div class="info-value">{{ currentGame[1][0].designer_name }}</div>
                    </div>
                    <div class="info-item">
                      <div class="info-label">Players</div>
                      <div class="info-value">{{ currentGame[0][0].minplayers }} - {{ currentGame[0][0].maxplayers }}</div>
                    </div>
                    <div class="info-item">
                      <div class="info-label">Playing Time</div>
                      <div class="info-value">{{ currentGame[0][0].playingtime }} minutes</div>
                    </div>
                    <div class="info-item">
                      <div class="info-label">Age</div>
                      <div class="info-value">{{ currentGame[0][0].minage }}+</div>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="info-item">
                      <div class="info-label">Category</div>
                        <div class="info-value">
                        <a href="#" @click.prevent="() => { categorySearch = true; categoryFilter = currentGame[4][0].category_name; $router.push('/games/list/all'); searchRequestCategory(); }">
                          {{ currentGame[4][0].category_name }}
                        </a>
                        </div>
                    </div>
                    <div class="info-item">
                      <div class="info-label">Year Published</div>
                      <div class="info-value">{{ currentGame[0][0].yearpublished }}</div>
                    </div>
                    <div class="info-item">
                      <div class="info-label">BGG ID</div>
                      <div class="info-value">{{ currentGame[0][0].id }}</div>
                    </div>
                    <div class="info-item">
                      <div class="info-label">Play Time Range</div>
                      <div class="info-value">{{ currentGame[0][0].minplaytime }} - {{ currentGame[0][0].maxplaytime }} min</div>
                    </div>
                  </div>
                </div>

                <div class="info-item">
                  <div class="info-label">Families</div>
                  <div v-for="family in currentGame[6]" :key="family.family_id" class="info-value">
                    {{ family.family_name }},
                  </div>
                </div>
              </div>
            </div>


        <!-- Recent Ratings Section -->
        <div class="row mt-5">
          <div class="col-12">
            <div class="card shadow-sm">
              <div class="card-header bg-white">
                <h4 class="mb-0"><i class="fas fa-comments me-2"></i>Recent Ratings</h4>
              </div>
              <div class="card-body">
                <div v-if="ratingsArray.length === 0" class="text-center py-4">
                  <p class="text-muted">No ratings yet. Be the first to rate this game!</p>
                </div>
                <div v-else>
                  <div class="rating-item mb-3 pb-3 border-bottom" v-for="(rating, index) in ratingsArray" :key="rating.rating_id">
                    <div class="d-flex justify-content-between align-items-start">
                      <div>
                        <h5 class="mb-1">{{ rating.user_name }}</h5>
                        <div class="text-muted small">{{ rating.rating_date }}</div>
                      </div>
                      <div class="rating-badge">
                        <span class="badge bg-primary">{{ parseFloat(rating.rating).toFixed(1) }}/10</span>
                      </div>
                    </div>
                    <p class="mt-2 mb-0"><b>" </b>{{ rating.rating_comment }}<b> "</b></p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>



          </div>

          <!-- Sidebar column -->
          <div class="col-lg-4">
            <div class="card mb-4 shadow-sm">
              <div class="card-header bg-white">
                <h4 class="mb-0"><i class="fas fa-chart-bar me-2"></i>Rankings & Stats</h4>
              </div>
              <div class="card-body">
                <div class="stat-item">
                  <div class="stat-label">BGG Rank</div>
                  <div class="stat-value">#{{ currentGame[0][0].bgg_rank }}</div>
                </div>
                <div class="stat-item">
                  <div class="stat-label">Average Rating</div>
                  <div class="stat-value">{{ parseFloat(currentGame[0][0].average_rating).toFixed(2) }}/10</div>
                  <div class="progress mt-1">
                    <div class="progress-bar bg-success" role="progressbar" 
                         :style="{ width: (currentGame[0][0].average_rating * 10) + '%' }" 
                         :aria-valuenow="currentGame[0][0].average_rating * 10" 
                         aria-valuemin="0" aria-valuemax="100">
                    </div>
                  </div>
                </div>
                <div class="stat-item">
                  <div class="stat-label">Rating from our users</div>
                  <div class="stat-value">{{ parseFloat(currentGame[0][0].total_rating).toFixed(2) }}/10</div>
                  <div class="progress mt-1">
                    <div class="progress-bar bg-warning" role="progressbar" 
                         :style="{ width: (currentGame[0][0].total_rating * 10) + '%' }" 
                         :aria-valuenow="currentGame[0][0].total_rating * 10" 
                         aria-valuemin="0" aria-valuemax="100">
                    </div>
                  </div>
                </div>
                <div class="stat-item">
                  <div class="stat-label">Bayes Average</div>
                  <div class="stat-value">{{ parseFloat(currentGame[0][0].bayes_average).toFixed(2) }}/10</div>
                  <div class="progress mt-1">
                    <div class="progress-bar bg-info" role="progressbar" 
                         :style="{ width: (currentGame[0][0].bayes_average * 10) + '%' }" 
                         :aria-valuenow="currentGame[0][0].bayes_average * 10" 
                         aria-valuemin="0" aria-valuemax="100"></div>
                  </div>
                </div>
                <div class="stat-item">
                  <div class="stat-label">total Users who Rated this game</div>
                  <div class="stat-value">{{ currentGame[0][0].users_rated }}</div>
                </div>
              </div>
            </div>

            <div class="card mb-4 shadow-sm">
              <div class="card-header bg-white">
                <h4 class="mb-0"><i class="fas fa-link me-2"></i>Rate this game!</h4>
                <small class="text-muted"> (You must be logged in)</small>
              </div>
              <div class="card-body">
                <form @submit.prevent="addRating(rating, comment)">
                  <div class="mb-3">
                    <label for="rating" class="form-label">Your Rating<small class="text-muted"> (1-10)</small></label>
                    <input type="number" v-model="rating" min="1" max="10" step="0.1" class="form-control" id="rating" required>
                  </div>
                  <div class="mb-3">
                    <label for="comment" class="form-label">Your Comment</label>
                    <textarea v-model="comment" class="form-control" id="comment" rows="3"></textarea>
                  </div>
                  <button type="submit" class="btn btn-primary w-100">Submit Rating</button>
                  <small class="text-muted">If you already rated this game, your rating will be updated.</small>
                </form>
              </div>
              <!--
              <div class="card-body">
                <a href="#" class="btn btn-outline-primary btn-block mb-2 w-100">
                  <i class="fas fa-heart me-2"></i>Add to Wishlist
                </a>
                <a href="#" class="btn btn-outline-success btn-block mb-2 w-100">
                  <i class="fas fa-plus-circle me-2"></i>Mark as Owned
                </a>
                <a href="#" class="btn btn-outline-info btn-block w-100">
                  <i class="fas fa-external-link-alt me-2"></i>View on BGG
                </a>
              </div>
              -->
            </div>
          </div>
        </div>

        <div class="mt-4 text-center">
          <a href="/#/games/list/all" class="btn btn-secondary">
            <i class="fas fa-arrow-left me-2"></i>Back to Games List
          </a>
        </div>
      </div>
    </div>

    <!-- when on: /games/list/ -->
    <div v-if="action === 'list'">
      <div class="list-header bg-light py-4 mb-4">
        <div class="container">
          <h1 class="text-center mb-0">Board Game Collection</h1>
          <p class="text-center text-muted mb-0">Discover amazing games for your next game night</p>
        </div>

        <!-- Search bar -->
        <div v-if="categorySearch === false" class="container">
          <div class="row height d-flex justify-content-center align-items-center">
            <div class="col-md-8">
              <div class="search">
                <input type="text" v-model="searchField" id="searchBar" class="form-control" placeholder="Search for a Game name...">
                <input type="button" value="Search" @click="searchRequest()" class="zoom-hover"/>
              </div>
            </div>
          </div>
        </div>

        <div class="container mt-3">
          <div class="row justify-content-center">
            <div class="col-md-6">
              <div class="sorting-controls d-flex align-items-center justify-content-center">
                <label for="sortOrder" class="me-2">Sort by:</label>
                <select id="sortOrder" v-model="order_by" class="form-select" @change="getAllData()">
                  <option value="average_rating">Average Rating (from users)</option>
                  <option value="bayes_average">Bayes Average (weighed average)</option>
                  <option value="users_rated">Number of Ratings (popularity)</option>
                  <option value="yearpublished">Year Published</option>
                </select>
              </div>
            </div>
          </div>
        </div>


        <!-- button to change categorySearch to true -->
        <div class="container mt-3">
          <div class="row justify-content-center">
            <div class="col-md-6 text-center">
              <button class="btn btn-outline-primary" @click="categorySearch = !categorySearch">
                Filter by Category
              </button>
            </div>
          </div>
        </div>

        
        <div v-if="categorySearch === true" class="container">


          <div class="mt-4">
            <h5 class="text-center mb-3">Select a Category</h5>
            <div class="category-filter-container">
              <div class="row">
                <div class="col-md-4">
                  <div class="form-check mb-2" v-for="(category, index) in [
                    'World War II', 'Ancient', 'Adventure', 'Civilization', 'Pirates',
                    'Fan Expansion', 'Spies/Secret Agents', 'Memory', 'Korean War', 'Sports',
                    'Negotiation', 'Maze', 'Travel', 'Wargame', 'Miniatures',
                    'Expansion for Base-game', 'Collectible Components', 'Music', 'Math', 'Space Exploration',
                    'Number', 'Political', 'Abstract Strategy', 'Video Game Theme', 'Mafia',
                    'Zombies', 'Renaissance', 'Nautical'
                  ]" :key="'cat1-'+index">
                    <input class="form-check-input" type="radio" v-model="categoryFilter" :value="category" :id="'category-'+category">
                    <label class="form-check-label" :for="'category-'+category">{{ category }}</label>
                  </div>
                </div>
                
                <div class="col-md-4">
                  <div class="form-check mb-2" v-for="(category, index) in [
                    'Deduction', 'Vietnam War', 'Murder/Mystery', 'Mature / Adult', 'City Building',
                    'Puzzle', 'American Revolutionary War', 'Age of Reason', 'World War I', 'Exploration',
                    'Action / Dexterity', 'Economic', 'Humor', 'Pike and Shot', 'Fighting',
                    'Racing', 'Novel-based', 'Game System', 'Bluffing', 'Aviation / Flight',
                    'Party Game', 'Religious', 'Farming', 'Horror', 'Medical',
                    'Dice', 'Book', 'American Civil War'
                  ]" :key="'cat2-'+index">
                    <input class="form-check-input" type="radio" v-model="categoryFilter" :value="category" :id="'category-'+category">
                    <label class="form-check-label" :for="'category-'+category">{{ category }}</label>
                  </div>
                </div>
                
                <div class="col-md-4">
                  <div class="form-check mb-2" v-for="(category, index) in [
                    'Territory Building', 'Industry / Manufacturing', 'Medieval', 'Fantasy', 'Trivia',
                    'American Indian Wars', 'Word Game', 'Civil War', 'Real-time', 'Transportation',
                    'Post-Napoleonic', 'Print & Play', 'Environmental', 'Napoleonic', 'Electronic',
                    'Card Game', 'Science Fiction', 'Movies / TV / Radio theme', 'Prehistoric', 'Modern Warfare',
                    'Comic Book / Strip', 'Trains', 'Mythology', 'Animals', 'Educational',
                    'Arabian', 'American West'
                  ]" :key="'cat3-'+index">
                    <input class="form-check-input" type="radio" v-model="categoryFilter" :value="category" :id="'category-'+category">
                    <label class="form-check-label" :for="'category-'+category">{{ category }}</label>
                  </div>
                </div>
              </div>
              
              <div class="row mt-3">
                <div class="col-12 text-center">
                  <button class="btn btn-primary me-2" @click="searchRequestCategory()">Search by Category</button>
                  <button class="btn btn-secondary" @click="categoryFilter = ''; getAllData()">Clear Filter</button>
                </div>
              </div>
            </div>
          </div>






        </div>








      </div>

      <div class="container">
        <div class="row">
          <div class="col-sm-6 col-md-4 col-lg-3 mb-4" v-for="game of gameArray" v-bind:key="game.id">
            <div class="card h-100 shadow-sm game-card">
              <div class="card-header text-center bg-light">
                <h5 class="card-title mb-0 text-truncate" :title="game.primary_name">{{ game.primary_name }}</h5>
                <small class="text-muted">{{ game.yearpublished }}</small>
                <p><small><b>BGG Rank:</b> #{{ game.bgg_rank }}</small></p>
              </div>
              <div class="game-thumbnail-container">
                <img v-bind:src="game.thumbnail" alt="game thumbnail" class="game-thumbnail">
              </div>
              <div class="card-body d-flex flex-column">
                <div class="game-card-stats">
                  <div class="stat">
                    <span class="stat-label">Players</span>
                    <span class="stat-value">{{ game.minplayers }}-{{ game.maxplayers }}</span>
                  </div>
                  <div class="stat">
                    <span class="stat-label">Time</span>
                    <span class="stat-value">{{ game.playingtime }} min</span>
                  </div>
                  <div class="stat">
                    <span class="stat-label">Age</span>
                    <span class="stat-value">{{ game.minage }}+</span>
                  </div>
                </div>
                <div class="rating-mini mt-2">
                  <div class="rating-value" :style="{ width: (game.average_rating * 10) + '%' }"></div>
                </div>
                <small class="text-center text-muted">{{ parseFloat(game.average_rating).toFixed(1) }}/10 from users</small>
                <div class="rating-mini mt-2">
                  <div class="rating-value" :style="{ width: (game.bayes_average * 10) + '%' }"></div>
                </div>
                <small class="text-center text-muted">{{ parseFloat(game.bayes_average).toFixed(1) }}/10 weighted</small>
                <div class="mt-auto text-center pt-3">
                  <router-link :to="'/games/show/' + game.id" class="btn btn-primary w-100">
                    <i class="fas fa-info-circle me-1"></i> View Details
                  </router-link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Page selector -->
      <div class="pagination-container mt-4">
        <div class="container">
          <div class="pagination d-flex justify-content-center align-items-center">
            <button class="btn btn-outline-primary" @click="pageNumber = Number(pageNumber) - 1" :disabled="pageNumber <= 1">
              <i class="fas fa-chevron-left"></i> Previous
            </button>
            <div class="pagination-info mx-3">
              Page
              <input type="number" v-model="pageNumber" min="1" class="form-control d-inline-block mx-2" style="width: 70px;">
              of {{ numberOfPages }}
            </div>
            <button class="btn btn-outline-primary" @click="pageNumber = Number(pageNumber) + 1" :disabled="pageNumber >= numberOfPages">
              Next <i class="fas fa-chevron-right"></i>
            </button>

            <div class="page-size-selector ms-3">
              <label for="pageSize" class="me-2">Items per page:</label>
              <select id="pageSize" v-model="pageSize" class="form-select form-select-sm d-inline-block" style="width: 80px;">
                <option value="10">10</option>
                <option value="20">20</option>
                <option value="30">30</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>


          </div>
        </div>
      </div>
    </div>

  </div>
</template>


<script>
export default {
  name: 'Games',
  props: ['action', 'id'],
  data() {
    return {
      pageNumber: 1,
      pageSize: 30,
      numberOfPages: 0,
      order_by: 'bayes_average',
      searchField: '',

      categoryFilter: '',
      categorySearch: false,

      gameArray: [],
      ratingsArray: [],

      currentGame: {}
    };
  },

  methods: {
    async getAllData() {
      try {
        if (this.searchField !== "") {
          this.searchRequest();
          return;
        }
        let responseGames = await this.$http.get('http://localhost:9000/api/games/page/' + this.pageNumber + '/' + this.pageSize + '/' + this.order_by);
        this.gameArray = await responseGames.data;

        this.getNumberOfPages() .then((numberOfPages) => {
          this.numberOfPages = numberOfPages;
        });
      } catch (exception) {
        console.log(exception);
      }
    },

    async searchRequest() {
      try {
        let searchFieldEncoded = encodeURIComponent(this.searchField);
        if (this.searchField !== "") {
          let responseGames = await this.$http.get('http://localhost:9000/api/games/search/' + searchFieldEncoded + '/' + this.pageNumber + '/' + this.pageSize + '/' + this.order_by);
          this.gameArray = await responseGames.data;

          this.numberOfPages = "?";
        }
        else {
          this.getAllData();
        }
      } catch (exception) {
        console.log(exception);
      }
    },

    async searchRequestCategory() {
      try {
        let searchFieldEncoded = encodeURIComponent(this.categoryFilter);
        if (this.categoryFilter !== "") {
          let responseGames = await this.$http.get('http://localhost:9000/api/games/category/' + searchFieldEncoded + '/' + this.pageNumber + '/' + this.pageSize + '/' + this.order_by);
          this.gameArray = await responseGames.data;

          this.numberOfPages = "?";
        }
        else {
          this.getAllData();
        }
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

    async getRatings() {
      try {
        let responseRatings = await this.$http.get('http://localhost:9000/api/ratings/getlast/' + this.$props.id);
        this.ratingsArray = await responseRatings.data;
      } catch (exception) {
        console.log(exception);
      }
    },

    async refreshcurrentGame() {
      if (this.$props.id === "all" || this.$props.id === "0") {
        this.currentGame = {};
        return;
      }
      try {
        let responseGame = await this.$http.get("http://localhost:9000/api/games/" + this.$props.id);
        this.currentGame = responseGame.data;
        this.getRatings();
      } catch (ex) {
        console.log(ex);
      }
    },

    async addRating(ratingg, commentt) {
      try {

        let responseGame = await this.$http.post("http://localhost:9000/api/ratings/add", 
          {
            game_id: this.$props.id,
            rating: ratingg,
            comment: commentt,
          }
        );
        this.refreshcurrentGame();

      } catch (ex) {
        console.log(ex);
        if (ex.response.status === 401) {
          alert("You must be logged in to rate a game.");
        } else if (ex.response.status === 400) {
          alert("Error: " + ex.response.data.message);
        } else if (ex.response.status === 500) {
          alert("Server error. Please try again later.");
        } else {
          alert("Error: " + ex);
        }
      }
    }
  },

  watch: {
    id: function(newId, oldId) {
      this.refreshcurrentGame();
    },

    action: function(newAction, oldAction) {
      if (newAction === 'list') {
        this.getAllData();
      }
    },

    pageNumber: function(newPageNumber, oldPageNumber) {
      this.getAllData();
    },

    order_by: function(newOrderBy, oldOrderBy) {
      this.pageNumber = 1; // Reset to first page when sorting changes
    },

    pageSize: function(newPageSize, oldPageSize) {
      this.getAllData();
    },

    categorySearch: function(newCategorySearch, oldCategorySearch) {
      if (newCategorySearch === false) {
        this.categoryFilter = '';
        this.getAllData();
      }
    },
  },

  created() {
    this.getAllData();
    this.getNumberOfPages().then((numberOfPages) => {
      this.numberOfPages = numberOfPages;
    });
    this.refreshcurrentGame();
  }
};
</script>

<style scoped>
  /* General styles */
  h1, h2, h3, h4, h5 {
    font-weight: 600;
  }

  a {
    text-decoration: none;
  }
  
  /* Game Cards on List Page */
  .game-card {
    border-radius: 10px;
    overflow: hidden;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
    border: 1px solid rgba(0,0,0,0.1);
  }

  .game-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 20px rgba(0,0,0,0.1);
  }

  .game-thumbnail-container {
    height: 180px;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 15px;
    background-color: #f8f9fa;
  }

  .game-thumbnail {
    max-height: 150px;
    max-width: 100%;
    object-fit: contain;
  }

  .game-card-stats {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
  }

  .game-card-stats .stat {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
  }

  .game-card-stats .stat-label {
    font-size: 0.7rem;
    color: #6c757d;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .game-card-stats .stat-value {
    font-weight: bold;
    font-size: 0.9rem;
  }

  /* Game Details Page */
  .game-details-container {
    margin-bottom: 50px;
  }

  .game-header {
    background: linear-gradient(to right, #f8f9fa, #e9ecef);
    padding: 20px 0;
    margin-bottom: 20px;
    border-bottom: 1px solid #dee2e6;
  }

  .game-cover-image {
    max-width: 200px;
    max-height: 200px;
    border-radius: 10px;
    object-fit: contain;
  }

  .game-title {
    font-size: 2.2rem;
    font-weight: 700;
    margin-bottom: 5px;
  }

  .game-year {
    font-size: 1.2rem;
    color: #6c757d;
    margin-bottom: 10px;
  }

  .game-meta .badge {
    font-size: 0.9rem;
    padding: 0.5rem 0.7rem;
    border-radius: 20px;
  }

  .game-description {
    font-size: 1rem;
    line-height: 1.6;
  }

  /* Rating Stars */
  .rating-container {
    display: flex;
    align-items: center;
  }

  .rating-stars {
    width: 150px;
    height: 30px;
    background-color: #e9ecef;
    border-radius: 15px;
    margin-right: 10px;
    position: relative;
    overflow: hidden;
  }

  .rating-stars .rating-value {
    height: 100%;
    background: linear-gradient(to right, #ffc107, #fd7e14);
    border-radius: 15px;
  }

  .rating-text {
    font-weight: 600;
    font-size: 1.1rem;
  }

  .rating-mini {
    height: 10px;
    background-color: #e9ecef;
    border-radius: 5px;
    position: relative;
    overflow: hidden;
  }

  .rating-mini .rating-value {
    height: 100%;
    background: linear-gradient(to right, #ffc107, #fd7e14);
    border-radius: 5px;
  }

  /* Info Items on Details Page */
  .info-item, .stat-item {
    margin-bottom: 15px;
    padding-bottom: 15px;
    border-bottom: 1px solid #eee;
  }

  .info-item:last-child, .stat-item:last-child {
    border-bottom: none;
    margin-bottom: 0;
    padding-bottom: 0;
  }

  .info-label, .stat-label {
    font-size: 0.8rem;
    color: #6c757d;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 3px;
  }

  .info-value, .stat-value {
    font-weight: 600;
    font-size: 1.1rem;
  }

  /* Pagination */
  .pagination-container {
    background-color: #f8f9fa;
    padding: 20px 0;
    border-top: 1px solid #dee2e6;
  }

  .pagination-info {
    font-size: 1rem;
  }

  /* List Header */
  .list-header {
    border-bottom: 1px solid #dee2e6;
  }



  /************ SEARCH BAR ************/
  .search {
    position: relative;
    box-shadow: 0 0 40px rgba(51, 51, 51, .1);
  }

  .search input[type="text"] {
    height: 60px;
    text-indent: 25px;
    border: 2px solid #d6d4d4;
  }


  .search input[type="text"]:focus {
    box-shadow: none;
    border: 2px solid #42b983;
  }

  .search input[type="button"] {
    position: absolute;
    top: 5px;     /* 5px from the top   */
    right: 5px;   /* 5px from the right */
    height: 50px;
    width: 110px;
    background: #42b983;
    color: #fff;
    border: none;
    border-radius: 5px;
  }

  .search input[type="button"]:active {
    background: #d6d4d4;
  }
</style>
