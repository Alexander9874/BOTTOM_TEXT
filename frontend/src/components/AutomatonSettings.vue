<template>
  <div class="settings">
    <button @click="toggleMode">Change_mode</button>
    <h4 v-if="singcolorMode === true">true</h4>
    <h3 v-if="singcolorMode === false">Blue Settings</h3>
    <label>
      Death Conditions:
      <input type="text" v-model="blue.deathConditionsInput" placeholder="e.g., 0123" />
    </label>
    <label>
      Birth Conditions:
      <input type="text" v-model="blue.birthConditionsInput" placeholder="e.g., 0123" />
    </label>
    <label v-if="singcolorMode === false">
      Death Conditions (Other):
      <input type="text" v-model="blue.deathConditionsOtherInput" placeholder="e.g., 0123" />
    </label>
    <label v-if="singcolorMode === false">
      Birth Conditions (Other):
      <input type="text" v-model="blue.birthConditionsOtherInput" placeholder="e.g., 0123" />
    </label>

    <h3 v-if="singcolorMode === false" >Green Settings</h3>
    <label v-if="singcolorMode === false" >
      Death Conditions:
      <input type="text" v-model="green.deathConditionsInput" placeholder="e.g., 0123" />
    </label >
    <label v-if="singcolorMode === false">
      Birth Conditions:
      <input type="text" v-model="green.birthConditionsInput" placeholder="e.g., 0123" />
    </label>
    <label v-if="singcolorMode === false">
      Death Conditions (Other):
      <input type="text" v-model="green.deathConditionsOtherInput" placeholder="e.g., 0123" />
    </label>
    <label v-if="singcolorMode === false">
      Birth Conditions (Other):
      <input type="text" v-model="green.birthConditionsOtherInput" placeholder="e.g., 0123" />
    </label>

    <button @click="applySettings">Apply Settings</button>
    <button @click="$emit('run-simulation')">Run</button>
    <button @click="$emit('reset-simulation')">Reset</button>
    <button @click="$emit('pause-simulation')">Pause</button>
    <button v-if="singcolorMode === false" @click="setColor('blue')">Blue</button>
    <button v-if="singcolorMode === false" @click="setColor('green')">Green</button>
  </div>
</template>

<script>
export default {
  props: {
    singcolorMode: { type: Boolean, Required: true},
    selectedColor: { type: String, default: 'blue' },
  },
  data() {
    return {
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
    };
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
      };

      this.$emit('update-settings', newSettings);
    },
    toggleMode() {
      this.$emit('updateSingColorMode')
    },
    setColor(color) {
      this.$emit('update:selectedColor', color);
    },
  },
};
</script>



<style scoped>
.settings {
  padding: 20px;
  background-color: #282c34;
  color: white;
  border-right: 1px solid #444;
}
button {
  margin-top: 10px;
  padding: 5px 10px;
  background-color: #4caf50;
  color: white;
  cursor: pointer;
}
</style>