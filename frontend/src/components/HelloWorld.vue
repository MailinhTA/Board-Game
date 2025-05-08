<template>
  <div class="hello">
    <h1 style="margin-top: 40px;">{{ msg }}</h1>
    <h2>The utilmate website to know everything about board games !</h2>
    <div style="margin-top: 30px;">
      <img :src="img_board_game" alt="Mon logo" class="responsive-img" width="500"/>
    </div>
    <section class="welcome-section"  style="margin-top: 30px;">
      <p class="intro-text">
        Looking for the perfect board game for your next game night?
        Browse through <strong>hundreds of games</strong> with detailed <strong>descriptions</strong>,
        <strong>ratings out of 10</strong>, and more.
      </p>
      <p class="intro-text">
        Use our <strong>smart filters</strong> and <strong>search tool</strong> to find exactly what you need.
      </p>
      <p class="intro-text">
        And don’t forget — <strong>rate the games you’ve played</strong> and help the community make the best choices!
      </p>
    </section>
  </div>
</template>

<script>
export default {
  name: 'HelloWorld',
  data () {
    return {
      msg: 'Welcome to Wikigames',
      img_board_game: require('../assets/boardgameIMG.jpg')
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}

.welcome-section {
  max-width: 950px;
  margin: 50px auto;
  padding: 30px;
  text-align: center;
  font-size: 22px;
}

.responsive-img {
  max-width: 80%; /* L'image prendra 100% de la largeur du conteneur parent */
  height: auto; /* La hauteur sera ajustée pour garder les proportions */
}

</style>
