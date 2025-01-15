<template>
    <div v-if="isOpen" class="modal-overlay">
      <div class="modal">
        <h3>Edit Project Description</h3>
        <textarea
          v-model="tempDescription"
          placeholder="Enter project description..."
          rows="10"
          maxlength="254"
        ></textarea>
        <p>{{ tempDescription.length }}/254</p>
        <div class="modal-buttons">
          <button @click="confirmDescription">Confirm</button>
          <button @click="cancelDescrition">Cancel</button>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    props: {
      isOpen: { type: Boolean, required: true },
      description: { type: String, default: "" }
    },
    emits: ["close", "updateDescription"],
    data() {
      return {
        tempDescription: this.description
      };
    },
    watch: {
        description(newVal) {
            this.tempDescription = newVal;
        }
    },
    methods: {
      closeModal() {
        this.$emit("close");
      },
      confirmDescription() {
        this.$emit("updateDescription", this.tempDescription);
        this.closeModal();
      },
      cancelDescrition() {
        this.tempDescription = this.description;
        this.closeModal();
      }
    }
  };
  </script>
  
  <style scoped>
  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
  }
  
  .modal {
    background: rgb(11, 28, 107);
    padding: 20px;
    border-radius: 5px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    width: 400px;
    max-width: 90%;
  }
  
  .modal-buttons {
    display: flex;
    justify-content: space-between;
    margin-top: 10px;
  }
  
  textarea {
    width: 100%;
    padding: 8px;
    resize: none;
    border: 1px solid #6b6b6b;
    border-radius: 4px;
    font-size: 14px;
    box-sizing: border-box;
  }

  button{
    width: 40%;
    padding: 4px;
  }

  </style>