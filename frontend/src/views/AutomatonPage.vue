<template>
  <div class="automaton-page">
    <div class="settings-panel">
      <AutomatonSettings
        @update-settings="updateSettings"
        @run-simulation="runSimulation"
        @reset-simulation="resetSimulation"
        @pause-simulation="pauseSimulation"
        :singcolorMode="singcolorMode" @updateSingColorMode="toggleMode"
        :selectedColor="selectedColor" @update:selectedColor="updateColor"
      />
    </div>
    <div class="grid-panel">
      <CellAutomaton
        :rows="80"
        :cols="80"
        :settings="settings"
        :selectedColor="selectedColor"
        ref="automaton"
      />
    </div>
  </div>
</template>

<script>
import AutomatonSettings from '../components/AutomatonSettings.vue';
import CellAutomaton from '../components/CellAutomaton.vue';

export default {
  components: {
    AutomatonSettings,
    CellAutomaton
  },
  data() {
    return {
      singcolorMode: true,
      selectedColor: 'blue',
      settings: {
        blue: {
          deathConditions: new Set([8]),
          birthConditions: new Set([0,3]),
          deathConditionsOther: new Set([7]),
          birthConditionsOther: new Set([6])
        },
        green: {
          deathConditions: new Set([8]),
          birthConditions: new Set([3]),
          deathConditionsOther: new Set([7]),
          birthConditionsOther: new Set([6])
        }
      }    
    };
  },
  methods: {
    updateSettings(newSettings) {
      this.settings = {...newSettings}; // Создаём новый объект
    },
    runSimulation() {
      if (this.singcolorMode === false) {
        alert("false");
        this.$refs.automaton.startSimulation();
      } else {
        alert("true");
        this.$refs.automaton.onestartSimulation();
      }
    },
    resetSimulation() {
      this.$refs.automaton.resetGrid();
    },
    pauseSimulation(){
      this.$refs.automaton.pauseSim();
    },
    updateColor(newColor) {
      this.selectedColor = newColor;
    },
    toggleMode() {
      this.selectedColor = 'blue';
      this.$refs.automaton.resetGrid();
      this.singcolorMode = !this.singcolorMode;
    }
  }
};
</script>

<style scoped>
.automaton-page {
  display: flex;
  height: 100vh;
}

.settings-panel {
  width: 200px;
  padding: 20px;
  background-color: #282c34;
  color: #ffffff;
}

.grid-panel {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #020138;
}
</style>