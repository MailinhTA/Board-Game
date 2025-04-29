<template>
  <footer>
    <nav>
      <ul>
        <li>
          <a href="#/">
            <!--<img src="../assets/logos/borrrow-logo-white.png" alt="BooknBorrow" width="80">-->
          </a>
        </li>
        <li>
          <a href="#/">
            <h2> WIKIGAMES </h2>
            <ul>
              <li class="zoom-hover">
                <a href="#/contact">
                  Contact us
                </a>
              </li>
            </ul>
          </a>
        </li>
        <li>
          <h2>TEAM</h2>
          <ul>
            <li class="zoom-hover">
              <a href="https://github.com/Hormone4" class="author-link">
                <img src="../assets/logos/github-logo.png" alt="">
                Hormone
              </a>
            </li>
            <li class="zoom-hover">
              <a href="https://github.com/MailinhTA" class="author-link">
                <img src="../assets/logos/github-logo.png" alt="">
                Thi Mailinh TA
              </a>
            </li>
            <li class="zoom-hover">
              <a href="https://github.com/Robinprev" class="author-link">
                <img src="../assets/logos/github-logo.png" alt="">
                Robin Prevotat
              </a>
            </li>
            <li class="zoom-hover">
              <a href="https://github.com/TiphDPRX" class="author-link">
                <img src="../assets/logos/github-logo.png" alt="">
                Tiphanie Depreaux
              </a>
            </li>
          </ul>
        </li>
      </ul>
    </nav>
    <br/>
    © 2025 Wikigames Team
  </footer>
</template>

<script>
export default {
  name: 'AppFooter'
}
</script>

<style scoped>
footer {
  background-color: black;
  padding: 20px 10px 10px;
  color: white;
  font-size: small;
}

h2 {
  font-size: small;
  font-weight: bolder;
}

nav {
  margin: auto;
  display: flex;
  text-align: center;
  align-content: center;
  justify-content: center;
}

nav ul {
  list-style: none;
  display: flex;
  flex-wrap: wrap;
  gap: 50px;
}

nav ul li ul {
  margin-top: 14px;
  flex-direction: column;
  gap: 10px;
  /* align the li items to the left */

  text-align: left;

}

a {
  color: white;
  text-decoration: none;
}

.author-link {
  text-decoration: underline;
  display: flex;
  align-content: center;
}
.author-link img {
  margin-right: 10px;
}
</style>
