<template>
  <div class="automaton-page">
    <div class="settings-panel">
      <AutomatonSettings
        @update-settings="updateSettings"
        @run-simulation="runSimulation"
        @reset-simulation="resetSimulation"
        @pause-simulation="pauseSimulation"
        @send-update-request="sendUpdateRequest"
        :numcolorMode="numcolorMode" @updatenumColors="toggleMode"
        :selectedColor="selectedColor" @update:selectedColor="updateColor"
        :Torusmode="Torusmode" @updateTorusMode="gridupdate"
        :projectName="projectName" 
        :projectDescription="projectDescription" 
        :settings = "settings"
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
        :parantcells="cells"
        @update:cells="updateCells"
        ref="automaton"
      />
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import AutomatonSettings from '../components/AutomatonSettings.vue';
import CellAutomaton from '../components/CellAutomaton.vue';

export default {
  components: {
    AutomatonSettings,
    CellAutomaton
  },
  props: ['projectName','projectDescription'],
  data() {
    return {
      cells: [],
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
  created() {
    this.getParams();
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
    },
    updateCells(newCells) {
      this.cells = newCells;
    },
    async sendUpdateRequest() {
      const token = localStorage.getItem("token");
      if (!token) {
        alert("No token found");
        return;
      }
      try {
        const colorsNumMapping = {one: 0,two: 1,three: 2};
        const cellTypeMapping = {dead: 0, blue: 1,green: 2,violet: 3,void: 4};

        const grid = this.cells.map(row => row.map(cell => cellTypeMapping[cell] || 0));
        const payload = {
          projectname: this.projectName,
          colors_num: colorsNumMapping[this.numcolorMode] || 0,
          torus_mode: this.Torusmode,
          blue_death_conditions: Array.from(this.settings.blue.deathConditions),
          blue_birth_conditions: Array.from(this.settings.blue.birthConditions),
          blue_death_conditions_other: Array.from(this.settings.blue.deathConditionsOther),
          blue_birth_conditions_other: Array.from(this.settings.blue.birthConditionsOther),

          green_death_conditions: Array.from(this.settings.green.deathConditions),
          green_birth_conditions: Array.from(this.settings.green.birthConditions),
          green_death_conditions_other: Array.from(this.settings.green.deathConditionsOther),
          green_birth_conditions_other: Array.from(this.settings.green.birthConditionsOther),

          violet_death_conditions: Array.from(this.settings.violet.deathConditions),
          violet_birth_conditions: Array.from(this.settings.violet.birthConditions),
          violet_death_conditions_other: Array.from(this.settings.violet.deathConditionsOther),
          violet_birth_conditions_other: Array.from(this.settings.violet.birthConditionsOther),
          grid:  grid.flat(),
        };
        const response = await axios.post("http://127.0.0.1:8000/UpdateParam",
            payload,
          {
          headers: {
            "Authorization": `Bearer ${token}`,
            "Content-Type": "application/json",
          },
        });

        if (response.status === 200) {
          alert("Data saved");
        } else {
          alert("Error data was not saved");
        }
      } catch(error) {
        console.error("Error sending request:  ",error);
        alert("Sending error");
      }
    },
    convertGridToCells(grid) {
      const rows = 80;
      const cols = 80;
      let cells = Array.from({length: rows}, () => Array(cols).fill('dead'));
      grid.forEach((value,index) => {
        const row = Math.floor(index/cols);
        const col = index % cols;
        cells[row][col] = value;
      });
      return cells;
    },
    async getParams() {
      const token = localStorage.getItem("token");
      if (!token) {
        alert("No token found");
        this.$router.push("/");
        return;
      }
      try{
        const response = await axios.get("http://127.0.0.1:8000/GetParam",{
          headers: {
            "Authorization": `Bearer ${token}`,
            "Accept": "application/json"
          },
          params: {projectname: this.projectName}
        });
        if (response.status === 200 && response.data.status === "success") {
          const data = response.data.data;

          const colorsNumMapping = {0: 'one', 1: 'two', 2: 'three'};
          const cellTypeMapping = {0: 'dead', 1: 'blue', 2: 'green', 3: 'violet', 4: 'void'};

          this.numcolorMode = colorsNumMapping[data.colors_num] || 'one';
          this.Torusmode = data.torus_mode;

          this.settings.blue.deathConditions = new Set(data.blue_death_conditions);
          this.settings.blue.birthConditions = new Set(data.blue_birth_condittions);
          this.settings.blue.deathConditionsOther = new Set(data.blue_death_conditions_other);
          this.settings.blue.birthConditionsOther = new Set(data.blue_birth_condittions_other);

          this.settings.green.deathConditions = new Set(data.green_death_conditions);
          this.settings.green.birthConditions = new Set(data.green_birth_condittions);
          this.settings.green.deathConditionsOther = new Set(data.green_death_conditions_other);
          this.settings.green.birthConditionsOther = new Set(data.green_birth_condittions_other);


          this.settings.violet.deathConditions = new Set(data.violet_death_conditions);
          this.settings.violet.birthConditions = new Set(data.violet_birth_condittions);
          this.settings.violet.deathConditionsOther = new Set(data.violet_death_conditions_other);
          this.settings.violet.birthConditionsOther = new Set(data.violet_birth_condittions_other);

          const grid = data.grid.map(cell => cellTypeMapping[cell] || 'dead');
          this.cells = this.convertGridToCells(grid);
          console.log("grid:  ",this.cells[0]);
        } else {
          alert("Error fetching parameters:  ",error);
        }
      } catch (error) {
        console.error("Error fetching parameters:  ",error);
        alert("Fetching error");
      }
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
  width: 300px;
  padding: 10px;
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