<template>
    <div class="homepage">
      <!-- Sidebar -->
      <aside class="sidebar">
        <!-- Top Section with Community Button -->
        <div class="community-section">
          <button @click="goToCommunity" class="btn-community">Community</button>
        </div>
  
        <!-- Projects Section -->
        <div class="projects-section">
          <button @click="createNewProject" class="btn-new-project">Create New Project</button>
          <div class="projects-list">
            <ul>
              <li v-if="projects.length === 0" class="empty-list">No projects found</li>
              <li v-for="project in projects" :key="project.id" class="project-item">
                <span>{{ project.name }}</span>
                <button @click="openProject(project.id)">Open</button>
              </li>
            </ul>
          </div>
        </div>
      </aside>
  
      <!-- Main Content -->
      <main class="user-info">
        <header class="header">
          <button @click="logout" class="btn-logout">Log Out</button>
        </header>
        <div class="user-details">
          <h1>Welcome,</h1>
          <h2>{{ user.name }}</h2>
          <div class="about-me">
            <p v-if="!isEditingAbout">{{ user.about.slice(0,20)}}...</p>
            <textarea
              v-if="isEditingAbout"
              v-model="user.about"
              placeholder="About me"
              maxlength="254"
            ></textarea>
            <button @click="toggleEditAbout" class="btn-edit">
              {{ isEditingAbout ? "Save" : "Edit" }}
            </button>
          </div>
        </div>
      </main>
    </div>
  </template>
  
  <script>
import { toHandlers } from 'vue';
import axios from 'axios';
  export default {
    name: "HomePage",
    data() {
      return {
        user: {
          name: "User",
          about: "About me",
        },
        projects: [],
        isEditingAbout: false,
      };
    },
    methods: {
      async fetchUserInfo() {
        const token = localStorage.getItem("token");
        console.log("Token from localStorage: ",token);
        if (token) {
          try {
            const response = await axios.get("http://127.0.0.1:8000/GetUserInfo", {
              headers: {
                Authorization: `Bearer ${token}`,
                "Content-Type": "application/json"
              },
            });
            if (response.data.status === "success") {
              this.user.name = response.data.data.username;
              this.user.about = response.data.data.about_me;
            } else {
              alert("response not success")
              throw new Error("Failed to fetch user info");
            }
          } catch (error) {
            console.error("Error fetching user info: ",error);
            this.logout();
          }
        } else {
          alert("else");
          console.error("Token not found");
          this.logout();
        }
        
      },
      async fetchProjects() {
        try {
          const response = await fetch("/api/projects");
          if (!response.ok) {
            throw new Error("Failed to load projects");
          }
          this.projects = await response.json();
        } catch (error) {
          console.error("Error fetching projects:", error);
        }
      },
      createNewProject() {
        this.$router.push("/projects/new");
      },
      openProject(projectId) {
        this.$router.push('/projects/${projectId}');
      },
      async logout() {
        const token = localStorage.getItem("token");
        if (!token) {
          console.error("No token found");
          this.$router.push("/");
          return;
        }
        try {
          const response = await axios.post("http://127.0.0.1:8000/logout", {}, {
            headers: {
              "Authorization": `Bearer ${token}`,
              "Content-Type": "application/json",
            },
          });
          if (response.data.detail === "Logout successful. Token revoked.") {
            console.log("Logout successful");
            localStorage.removeItem("token");
            this.$router.push("/");
          } else {
            console.error("Logout failed: ", response.data.detail);
          }
        } catch (error) {
          console.error("Error logout: ",error);
        }
      },
      goToCommunity() {
        this.$router.push("/community");
      },
      toggleEditAbout() {
        if (this.isEditingAbout) {
          this.saveUserInfo();
        }
        this.isEditingAbout = !this.isEditingAbout;
      },
      async saveUserInfo() {
        const token = localStorage.getItem("token");
        if (!token) {
          console.error("No token found");
          return;
        }
        try {
          const response = await axios.post("http://127.0.0.1:8000/UpdateAuboutMe", {
            about_me: this.user.about,
          }, {
            headers: {
              "Authorization": `Bearer ${token}`,
              "Content-Type": "application/json",
            },
          });
          if (response.data.status === "success") {
            console.log("Profile updated successfully");
            this.isEditingAbout = false;
          } else {
            throw new Error(response.data.message || "Failed to update user info");
          }
        } catch (error) {
          console.error("Error updating user info: ", error);
        }
      },
    },
    async created() {
      await this.fetchUserInfo();
    },
  };
  </script>
  
  <style scoped>
  
  
  /* General Layout */
  .homepage {
    display: flex;
    height: 100vh;
    color: #fff;
    background: #121212;
    font-family: Arial, sans-serif;
  }
  
  /* Sidebar (Left 1/3 of screen) */
  .sidebar {
    width: 33%;
    display: flex;
    flex-direction: column;
    background: #1e1e1e;
    border-right: 1px solid #333;
  }
  
  /* Community Section */
  .community-section {
    height: 20%;
    display: flex;
    align-items: center;
    justify-content: center;
    border-bottom: 1px solid #333;
  }
  
  .btn-community {
    background: #007bff;
    color: white;
    padding: 30px 40px;
    font-size: 1.5rem;
    border: none;
    border-radius: 8px;
    cursor: pointer;
  }
  
  .btn-edit{
    background: #007bff;
    color: white;
    padding: 10px 15px;
  }

  /* Projects Section */
  .projects-section {
    height: 80%;
    padding: 10px;
    display: flex;
    flex-direction: column;
  }
  
  .btn-new-project {
    background: #4caf50;
    color: white;
    padding: 15px;
    margin-bottom: 10px;
    border: none;
    border-radius: 4px;
    font-size: 1.2rem;
    cursor: pointer;
  }
  
  .projects-list {
    flex-grow: 1;
    overflow-y: auto;
    scrollbar-width: thin;
    scrollbar-color: #555 #1e1e1e;
  }
  
  .projects-list::-webkit-scrollbar {
    width: 6px;
  }
  
  .projects-list::-webkit-scrollbar-thumb {
    background: #555;
    border-radius: 4px;
  }
  
  .empty-list {
    color: #999;
    text-align: center;
  }
  
  /* Main Content (Right 2/3 of screen) */
  .user-info {
    flex-grow: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    padding: 20px;
    border: 5px solid #000b70;
  }
  
  .header {
    position: absolute;
    top: 20px;
    right: 20px;
  }
  
  .btn-logout {
    background: #f44336;
    color: white;
    padding: 20px 30px;
    font-size: 1.5rem;
    border: none;
    border-radius: 8px;
    cursor: pointer;
  }
  
  .user-details {
    border: 5px solid #004268;
    max-width: 600px;
    padding: 40px;
    border-radius: 30px;
  }
  
  .user-details h1 {
    font-size: 3rem;
  }
  
  .user-details h2 {
    font-size: 2.5rem;
    margin-top: 10px;
  }
  
  .about-me {
    margin-top: 30px;
  }
  
  .about-me p {
    font-size: 1.8rem;
  }
  
  .about-me textarea {
    width: 100%;
    height: 150px;
    background: #2e2e2e;
    border: 1px solid #444;
    color: white;
    padding: 15px;
    border-radius: 4px;
    font-size: 1.5rem;
  }
  
  
  </style>