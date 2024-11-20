<template>
    <div class="project-list">
      <button @click="createNewProject">Create New Project</button>
      <ul>
        <li v-for="project in projects" :key="project.id">{{ project.name }}</li>
      </ul>
    </div>
  </template>
  
  <script>
  export default {
    props: {
      projects: {
        type: Array,
        default: () => []
      }
    },
    methods: {
      createNewProject() {
        this.$emit('create-project'); // Передаем событие создания проекта наверх
      }
    }
  };
  </script>
  
  <style scoped>
  .project-list {
    text-align: left;
    padding: 10px;
  }
  
  button {
    margin-bottom: 10px;
  }
  
  ul {
    list-style-type: none;
    padding: 0;
  }
  </style>