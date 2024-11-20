<template>
    <div class="form-container">
      <h2>Log In / Sign Up</h2>
      <form @submit.prevent="handleSubmit">
        <input type="text" v-model="username" placeholder="Username" required />
        <input type="password" v-model="password" placeholder="Password" required />
        <button type="button" @click="handleLogin">Log In</button>
        <button type="button" @click="handleSignup">Sign Up</button>
      </form>
      <p>{{ output }}</p>
      <div id="bottomText">BOTTON_TEXT</div>
    </div>
  </template>
  
  <script>
  export default {
    data() {
      return {
        username: '',
        password: '',
        output: ''
      };
    },
    methods: {
      handleLogin() {

      },
      handleSignup() {

      }
    }
  };
  </script>
  
  <style scoped>
  .form-container {
      background-color: rgba(34, 34, 34, 0.9); 
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 0 15px rgba(0, 0, 0, 0.5);
      max-width: 300px;
      width: 100%;
      text-align: center;
      margin: 0 auto;
  }
  
  h2 {
      color: #fff;
  }
  
  input {
      width: calc(100% - 20px);
      padding: 10px;
      margin: 10px 0;
      border-radius: 4px;
      border: 1px solid #555;
      background-color: rgba(255, 255, 255, 0.1);
      color: #fff;
  }
  
  input::placeholder {
      color: #bbb;
  }
  
  button {
      width: 100%;
      padding: 10px;
      margin: 10px 0;
      border: none;
      background-color: #1E88E5;
      color: white;
      border-radius: 4px;
      cursor: pointer;
  }
  
  button:hover {
      background-color: #1565C0;
  }
  
  #bottomText {
    border: 0;
    border-radius: 15px;
      background-color: #000;
      color: #598cd8;
      text-align: center;
      padding: 20px 0;
      font-size: 24px;
      font-weight: bold;
  }
  </style>