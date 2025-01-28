<template>
    <div class="error-page">
      <h1 class="error-code">404</h1>
    </div>
  </template>
  
  <script>
  export default {
    name: "Error404Page",
  };
  </script>
  
  <style scoped>
  .error-page {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    background-color: black;
    margin: 0;
  }
  
  .error-code {
    color: red;
    font-size: 8rem;
    font-weight: bold;
  }
  </style>
  