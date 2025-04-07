<template>
  <div id="app">
    <AppHeader />
    <router-view/>   <!-- This is where your pages/components will be rendered -->
    <AppFooter />
  </div>
</template>

<script>
import AppHeader from './components/Header.vue';  // Import the header component
import AppFooter from './components/Footer.vue';  // Import the footer component

export default {
  name: 'App',
  components: {   // Register the components so they can be used in the template
    AppHeader,
    AppFooter
  }
}
</script>

<style>
  #app {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;
  }
  .zoom-hover:hover {
    transform: scale(1.1);
    transition: transform 0.1s;
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
