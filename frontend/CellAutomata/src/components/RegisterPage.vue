<template>
    <div class="register-page">
      <!-- Фон с GIF -->
      <div class="background">
        <img src="@/assets/background.gif" alt="Background GIF" />
      </div>
  
      <!-- Полупрозрачный прямоугольник с формой -->
      <div class="form-container">
        <div class="form">
          <h2>Log In / Sign Up</h2>
          
          <!-- Форма с полями Username и Password -->
          <form>
            <input 
              type="text" 
              placeholder="Username" 
              v-model="username" 
              class="input-field" 
              maxlength="30"
            />
            <input 
              type="password" 
              placeholder="Password" 
              v-model="password" 
              class="input-field" 
              maxlength="127"
            />
  
            <!-- Кнопки Log In и Sign Up -->
            <div class="buttons">
              <button @click.prevent="login" class="btn btn-login">Log In</button>
              <button @click.prevent="signup" class="btn btn-signup">Sign Up</button>
            </div>
          </form>
        </div>
      </div>
  
      <!-- Черная полоса внизу -->
      <div class="footer">
        <p>BOTTOM_TEXT</p>
      </div>
    </div>
  </template>
  
  <script>

  import axios from "axios";
import { errorMessages } from "vue/compiler-sfc";

  export default {
    data() {
      return {
        username: '',
        password: ''
      };
    },
    methods: {
      async login() {
        if (this.username.length < 2) {
          alert("Name must be at least 2 characters long")
          return;
        }
        if (this.password.length < 2) {
          alert("Password must be at least 2 characters long")
          return;
        }
        try {
          const response = await axios.post("http://127.0.0.1:8000/login",{
            username: this.username,
            password: this.password,
          });
          if (response.data.access_token) {
            localStorage.setItem("token",response.data.access_token);
            console.log("Token saved to localStorage: ", localStorage.getItem("token"));
            this.$router.push('/home');
          } else {
            console.error("Login failed: Missing access token in response");
            alert("Login failed. Please try again");
          }
        } catch (error) {
          console.error("Login failed:", error.response?.data || errormessages);
          alert("Login failed. Please check your credentials");
        }
        // Логика для входа
      },
      async signup() {
        if (this.username.length < 2) {
          alert("Name must be at least 2 characters long")
          return;
        }
        if (this.password.length < 2) {
          alert("Password must be at least 2 characters long")
          return;
        }
        try {
          const response = await axios.post("http://127.0.0.1:8000/signup",{
            username: this.username,
            password: this.password,
          });
          if (response.data.detail === "Registration successful") {
            alert("Registration successful. Please log in");
            this.username = "";
            this.password = "";
          } else {
            alert("Registration failed: " + response.data.message);
          }
        } catch (error) {
          console.error("Signup failed: ", error.response?.data || error.message);
          alert("Signup failed. Please try again.");
        }
      },
    },
  };
  </script>
  
  <style scoped>
  /* Общие стили */
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }
  
  html, body {
    height: 100%;
    width: 100%;
    font-family: Arial, sans-serif;
  }
  
  .register-page {
    height: 100%;
    width: 100%;
    position: relative;
  }
  
  /* Фон с GIF */
  .background {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: -1;
  }
  
  .background img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
  
  /* Полупрозрачный контейнер */
  .form-container {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100%;
  }
  
  .form {
    background-color: rgba(34, 34, 34, 0.9); /* Полупрозрачный */
    padding: 40px;
    border-radius: 8px;
    width: 600px;
    text-align: center;
  }
  
  h2 {
    margin-bottom: 20px;
    font-size: 24px;
    color: #c5c0c0;
  }
  
  /* Поля ввода */
  .input-field {
    font-size: 25px;
    width: 100%;
    padding: 12px;
    margin-bottom: 20px;
    border: 1px solid #ccc;
    border-radius: 4px;
    color: aqua;
    background-color: rgba(255, 255, 255, 0.1); /* Мутные поля */
  }
  
  /* Кнопки */
  .buttons {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }
  
  .btn {
    width: 100%;
    padding: 12px;
    border: none;
    border-radius: 4px;
    color: white;
    cursor: pointer;
    font-size: 18px;
  }
  
  .btn-login {
    background-color: #1e90ff; /* Темноголубая кнопка */
  }
  
  .btn-signup {
    background-color: #1e90ff; 
  }
  
  .btn:hover {
    opacity: 0.8;
  }
  
  /* Черная полоса внизу */
  .footer {
    position: absolute;
    bottom: 0;
    width: 100%;
    background-color: black;
    color: #00008b; /* Темно-синий цвет */
    text-align: center;
    padding: 10px 0;
    font-size: 40px;
  }
  </style>