<template>
  <div class="automaton-page">
    <div class="settings-panel">
      <AutomatonSettings
        @update-settings="updateSettings"
        @run-simulation="runSimulation"
        @reset-simulation="resetSimulation"
        @pause-simulation="pauseSimulation"
        :numcolorMode="numcolorMode" @updatenumColors="toggleMode"
        :selectedColor="selectedColor" @update:selectedColor="updateColor"
        :Torusmode="Torusmode" @updateTorusMode="gridupdate"
      />
    </div>
    <div class="grid-panel">
      <CellAutomaton
        :rows="80"
        :cols="80"
        :settings="settings"
        :selectedColor="selectedColor"
        :Torusmode="Torusmode"
        :numcolorMode="numcolorMode"
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
      numcolorMode: 'one',
      Torusmode: false,
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
        },
        violet: {
          deathConditions: new Set([8]),
          birthConditions: new Set([4]),
          deathConditionsOther: new Set([6]),
          birthConditionsOther: new Set([5]),
        }
      }    
    };
  },
  methods: {
    updateSettings(newSettings) {
      this.settings = {...newSettings}; // Создаём новый объект
    },
    runSimulation() {
      if (this.numcolorMode === 'two' || this.numcolorMode === 'three') {
        this.$refs.automaton.startSimulation();
      } else if (this.numcolorMode === 'one'){
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
    toggleMode(numColors) {
      this.selectedColor = 'blue';
      this.$refs.automaton.resetGrid();
      this.numcolorMode = numColors;
    },
    gridupdate(gridmode) {
      this.Torusmode = gridmode;
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