<template>
   <div>
    <p>{{ userName }}</p>
   </div>
</template>
  
  <script>
  export default {
    data() {
      return {
        userName: 'standart_name',
        aboutUser: 'standart_about_me'
      };
    },
    methods: {
      startEditing() {
        this.isEditing = true;
      },
      saveChanges() {
        this.isEditing = false;
        this.$emit('update-about-me', this.editedAboutMe); // Передаем обновление наверх
      }
    }
  };
  </script>
  
  <style scoped>
  
  </style>