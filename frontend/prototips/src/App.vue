<template>
  <div id="app">
    <router-view></router-view>
  </div>
</template>

<script>
import HomePage from './components/HomePage.vue';
import RegisterPage from './components/RegisterPage.vue';

export default {
  name: "App",
  components: {
    HomePage,
    RegisterPage,
  },

};
</script>

<style>
</style>