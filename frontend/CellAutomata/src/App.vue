<!-- src/App.vue -->
<template>
  <div id="app">
     <AutomatonPage /> 
  </div>
</template>

<script>
import AutomatonPage from './views/AutomatonPage.vue';

export default {
  name: 'App',
  components: {
    AutomatonPage
  }
};
</script>

<style>
/* Общий стиль для всего приложения */
html, body{
  margin: 0;
  padding: 0;
  height: 100%;
}

.app {
  display: flex;
  height: 100vh;
}

.settings{
  width: 200px;
  background-color: #222;
  color: #fff;
  padding: 20px;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.celll-automaton {
  flex-grow: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}

</style>