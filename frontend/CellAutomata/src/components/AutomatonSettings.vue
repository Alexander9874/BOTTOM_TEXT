<template>
  <div class="settings">
    <label for="projectName">Project Name:   </label>
    <label for="projectName">{{ localprojectName }}      </label>

    <label for="projectDescription" style="display: block;">Project Description:</label>

   
    <textarea
      v-model="localprojectDescription"
      placeholder="Edit project description..."
      rows="5"
      maxlength="250"
    ></textarea>

    <button @click="saveProject">Save new name and description and exit</button>
    <button v-if="numcolorMode === 'one'" @click="setnumColor('two')">Change_mode_on_two</button>
    <button v-if="numcolorMode === 'two'" @click="setnumColor('three')">Change_mode_on_three</button>
    <button v-if="numcolorMode === 'three'" @click="setnumColor('one')">Change_mode_on_one</button>
    <h4 v-if="numcolorMode === 'one'">true</h4>
    <h3 v-if="numcolorMode === 'two' || numcolorMode === 'three'">Blue Settings</h3>
    <label>
      Death Conditions:
      <input type="text" v-model="blue.deathConditionsInput" placeholder="e.g., 0123" maxlength="50"/>
    </label>
    <label>
      Birth Conditions:
      <input type="text" v-model="blue.birthConditionsInput" placeholder="e.g., 0123" maxlength="50"/>
    </label>
    <label v-if="numcolorMode === 'two' || numcolorMode === 'three'">
      Death Conditions (Other):
      <input type="text" v-model="blue.deathConditionsOtherInput" placeholder="e.g., 0123" maxlength="50"/>
    </label>
    <label v-if="numcolorMode === 'two' || numcolorMode === 'three'">
      Birth Conditions (Other):
      <input type="text" v-model="blue.birthConditionsOtherInput" placeholder="e.g., 0123" maxlength="50"/>
    </label>

    <h3 v-if="numcolorMode === 'two' || numcolorMode === 'three'" >Green Settings</h3>
    <label v-if="numcolorMode === 'two' || numcolorMode === 'three'" >
      Death Conditions:
      <input type="text" v-model="green.deathConditionsInput" placeholder="e.g., 0123" maxlength="50"/>
    </label >
    <label v-if="numcolorMode === 'two' || numcolorMode === 'three'">
      Birth Conditions:
      <input type="text" v-model="green.birthConditionsInput" placeholder="e.g., 0123" maxlength="50"/>
    </label>
    <label v-if="numcolorMode === 'two' || numcolorMode === 'three' ">
      Death Conditions (Other):
      <input type="text" v-model="green.deathConditionsOtherInput" placeholder="e.g., 0123" maxlength="50"/>
    </label>
    <label v-if="numcolorMode === 'two' || numcolorMode === 'three'">
      Birth Conditions (Other):
      <input type="text" v-model="green.birthConditionsOtherInput" placeholder="e.g., 0123" maxlength="50"/>
    </label>

    <h3 v-if=" numcolorMode === 'three'" >Violet Settings</h3>
    <label v-if="numcolorMode === 'three'" >
      Death Conditions:
      <input type="text" v-model="violet.deathConditionsInput" placeholder="e.g., 0123" maxlength="50"/>
    </label >
    <label v-if=" numcolorMode === 'three'">
      Birth Conditions:
      <input type="text" v-model="violet.birthConditionsInput" placeholder="e.g., 0123" maxlength="50"/>
    </label>
    <label v-if=" numcolorMode === 'three' ">
      Death Conditions (Other):
      <input type="text" v-model="violet.deathConditionsOtherInput" placeholder="e.g., 0123" maxlength="50"/>
    </label>
    <label v-if="numcolorMode === 'three'">
      Birth Conditions (Other):
      <input type="text" v-model="violet.birthConditionsOtherInput" placeholder="e.g., 0123" maxlength="50"/>
    </label>

    <button @click="applySettings">Apply Settings</button>
    <button @click="$emit('run-simulation')">Run</button>
    <button @click="$emit('reset-simulation')">Reset</button>
    <button @click="$emit('pause-simulation')">Pause</button>
    <button @click="setColor('void')">Void</button>
    <button @click="setColor('blue')">Blue</button>
    <button v-if="numcolorMode === 'two' || numcolorMode === 'three'" @click="setColor('green')">Green</button>
    <button v-if="numcolorMode === 'three'" @click="setColor('violet')">Violet</button>
    <button @click="setColor('dead')">Eraseer</button>
    <button v-if="Torusmode == false" @click="setGridMode(true)">Torus mode on</button>
    <button v-if="Torusmode == true" @click="setGridMode(false)">Torus mode off</button>
    <button @click="exit()">Exit</button>
  </div>
</template>

<script>

import { extractIdentifiers } from 'vue/compiler-sfc';
import DescriptionModal from './DescriptionModal.vue';
import axios from 'axios';
export default {
  components: {DescriptionModal},
  props: {
    numcolorMode: { type: String, Required: 'one'},
    Torusmode: { type: Boolean, Required: false},
    selectedColor: { type: String, default: 'blue' },
    projectName: String,
    projectDescription: String, 
  },
  emits: [
    "updateSettings",
    "runSimulation",
    "resetSimulation",
    "pauseSimulation",
    "updatenumColors",
    "updateTorusMode",
    "updateProjectName",
    "updateProjectDescription"
  ],
  data() {
    return {
      localprojectDescription: '',
      localprojectName: '',
      isDescriptionModealOpen: false,
      blue: {
        deathConditionsInput: '8',
        birthConditionsInput: '03',
        deathConditionsOtherInput: '7',
        birthConditionsOtherInput: '6',
      },
      green: {
        deathConditionsInput: '8',
        birthConditionsInput: '3',
        deathConditionsOtherInput: '7',
        birthConditionsOtherInput: '6',
      },
      violet: {
        deathConditionsInput: '8',
        birthConditionsInput: '3',
        deathConditionsOtherInput: '7',
        birthConditionsOtherInput: '6',
      },
    };
  },
  created() {
    this.localprojectDescription = this.projectDescription;
    this.localprojectName = this.projectName;
  },
  methods: {
    applySettings() {
      const parseConditions = (input) => {
        return new Set([...input].map(Number).filter((n) => !isNaN(n)));
      };

      const newSettings = {
        blue: {
          deathConditions: parseConditions(this.blue.deathConditionsInput),
          birthConditions: parseConditions(this.blue.birthConditionsInput),
          deathConditionsOther: parseConditions(this.blue.deathConditionsOtherInput),
          birthConditionsOther: parseConditions(this.blue.birthConditionsOtherInput),
        },
        green: {
          deathConditions: parseConditions(this.green.deathConditionsInput),
          birthConditions: parseConditions(this.green.birthConditionsInput),
          deathConditionsOther: parseConditions(this.green.deathConditionsOtherInput),
          birthConditionsOther: parseConditions(this.green.birthConditionsOtherInput),
        },
        violet: {
          deathConditions: parseConditions(this.violet.deathConditionsInput),
          birthConditions: parseConditions(this.violet.birthConditionsInput),
          deathConditionsOther: parseConditions(this.violet.deathConditionsOtherInput),
          birthConditionsOther: parseConditions(this.violet.birthConditionsOtherInput),
        },
      };

      this.$emit('update-settings', newSettings);
    },
    toggleMode() {
      this.$emit('updateSingColorMode');
    },
    setColor(color) {
      this.$emit('update:selectedColor', color);
    },
    setGridMode(gridmode) {
      this.$emit('updateTorusMode',gridmode);
    },
    setnumColor(numColors) {
      this.$emit('updatenumColors',numColors);
    },
    openDescriptionModal() {
      this.isDescriptionModealOpen = true;
    },
    closeDescriptionModeal() {
      this.isDescriptionModealOpen = false;
    },
    async saveProject() {
      const token = localStorage.getItem("token");
      if (!token) {
        console.error("No token found");
        this.$router.push("/");
        return;
      }
      const data = {
        projectname: this.localprojectName,
        new_projectname: this.localprojectName,
        new_description: this.localprojectDescription,
      };
      console.log('Saving project with the following data:');
      console.log(`Old Project Name: ${this.localprojectName}`);
      console.log(`New Project Name: ${this.localprojectName}`);
      console.log(`New Description: ${this.localprojectDescription}`);
      try {
        const response = await  axios.post('http://127.0.0.1:8000/UpdateProject',data,{
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
        });
        if (response.data.status === 'success') {
        } else {
          alert("Error saving project");
        }
      } catch(error) {
        console.error('Error: ',error);
        alert("An error occurred while saving the project");
      }
    },
    exit() {
      this.$router.push('/home');
    }
  },
};
</script>



<style scoped>
.settings {
  max-height: 1250px;
  overflow-y: auto;
  overflow-x: hidden;
  padding: 40px;
  border: 1px solid #ccc;
  border-radius: 5px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  width: 100%;
  box-sizing: border-box;
}
button {
  width: 200px;
  margin-top: 10px;
  padding: 5px 10px;
  background-color: #4caf50;
  color: white;
  cursor: pointer;
}

textarea{
  width: 100%;
  padding: 8px;
  resize: none;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: 14px;
  box-sizing: border-box;
}
</style>