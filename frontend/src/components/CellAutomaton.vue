
<template>
  <div class="grid" @mousedown="isDragging = true" @mouseup="isDragging = false">
     <div v-for="(row, rowIndex) in cells" :key="rowIndex" class="row">
       <div
         v-for="(cell, colIndex) in row"
         :key="colIndex"
         :class="['cell', cell]"
         @click="toggleCell(rowIndex, colIndex)"
         @mouseover="isDragging && toggleCell(rowIndex, colIndex)"
       ></div>
     </div>
   </div>
 </template>
 
 <script>
 export default {
   props: {
     rows: { type: Number, default: 60 },
     cols: { type: Number, default: 60 },
     selectedColor: { type: String,default: 'blue'},
     settings: {
       type: Object,
       default: () => ({
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
       })
     }
   },
   data() {
     return {
       cells: this.createEmptyGrid(),
       interval: null,
       isDragging: false
     };
   },
   methods: {
     createEmptyGrid() {
       return Array.from({ length: this.rows }, () => Array(this.cols).fill('dead'));
     },
     toggleCell(row, col) {
       if (this.cells[row][col] !== 'dead') {
         this.cells[row][col] = 'dead';
       } else {
         this.cells[row][col] = this.selectedColor;
       }
     },
     countNeighborsForLiveCell(row, col, cellColor) {
     const directions = [
       [0, 1], [1, 1], [1, 0], [1, -1],
       [0, -1], [-1, -1], [-1, 0], [-1, 1]
     ];
     let sameColorNeighbors = 0;
     let otherColorNeighbors = 0;
 
     for (const [dx, dy] of directions) {
       const newRow = row + dx;
       const newCol = col + dy;
       if (
         newRow >= 0 && newRow < this.rows &&
         newCol >= 0 && newCol < this.cols
       ) {
         const neighborCell = this.cells[newRow][newCol];
         if (neighborCell === cellColor) {
           sameColorNeighbors++;
         } else if (neighborCell !== 'dead') {
           otherColorNeighbors++;
         }
       }
     }
 
     return { sameColorNeighbors, otherColorNeighbors };
   },
 
     countNeighborsForDeadCell(row, col) {
       const directions = [
         [0, 1], [1, 1], [1, 0], [1, -1],
         [0, -1], [-1, -1], [-1, 0], [-1, 1]
       ];
       let blueNeighbors = 0;
       let greenNeighbors = 0;
 
       for (const [dx, dy] of directions) {
         const newRow = row + dx;
         const newCol = col + dy;
         if (
           newRow >= 0 && newRow < this.rows &&
           newCol >= 0 && newCol < this.cols
         ) {
           const neighborCell = this.cells[newRow][newCol];
           if (neighborCell === 'blue') {
             blueNeighbors++;
           } else if (neighborCell === 'green') {
             greenNeighbors++;
           }
         }
       }
 
       return { blueNeighbors, greenNeighbors };
     },
 
     updateCells() {
       const newCells = this.cells.map((row, rowIndex) =>
         row.map((cell, colIndex) => {
           if (cell !== 'dead') {
             // Для живой клетки проверяем условия смерти
             const { sameColorNeighbors, otherColorNeighbors } =
               this.countNeighborsForLiveCell(rowIndex, colIndex, cell);
             const rules = this.settings[cell];
             
             if (
               rules.deathConditions.has(sameColorNeighbors) ||
               rules.deathConditionsOther.has(otherColorNeighbors)
             ) {
               return 'dead'; // Клетка умирает
             } else {
               return cell; // Клетка остаётся живой
             }
           } else {
             // Для мёртвой клетки проверяем условия рождения
             const { blueNeighbors, greenNeighbors } =
               this.countNeighborsForDeadCell(rowIndex, colIndex);
             const birthColors = [];
 
             for (const [color, rules] of Object.entries(this.settings)) {
               const ownNeighbors =
                 color === 'blue' ? blueNeighbors : greenNeighbors;
               const otherNeighbors =
                 color === 'blue' ? greenNeighbors : blueNeighbors;
               
               if (
                 rules.birthConditions.has(ownNeighbors) ||
                 rules.birthConditionsOther.has(otherNeighbors)
               ) {
                 birthColors.push(color);
               }
             }
 
             // Проверка конфликтов: если только один цвет соответствует условиям
             return birthColors.length === 1 ? birthColors[0] : 'dead';
           }
         })
       );
       this.cells = newCells;
     },


     onecountAliveNeighbors(row, col) {
        const directions = [
          [0, 1], [1, 1], [1, 0], [1, -1],
          [0, -1], [-1, -1], [-1, 0], [-1, 1]
        ];
        let aliveNeighbors = 0;
        for (const [dx, dy] of directions) {
          const newRow = row + dx;
          const newCol = col + dy;
          if (
            newRow >= 0 && newRow < this.rows &&
            newCol >= 0 && newCol < this.cols &&
            (this.cells[newRow][newCol] === 'blue')
          ) {
            aliveNeighbors++;
          }
        }
        return aliveNeighbors;
      },
      oneupdateCells() {
        const newCells = this.cells.map((row, rowIndex) =>
          row.map((cell, colIndex) => {
            const aliveNeighbors = this.onecountAliveNeighbors(rowIndex, colIndex);
            if (cell !== 'dead') {
              if (this.settings.blue.deathConditions.has(aliveNeighbors)) {
                return 'dead';
              } else {
                return 'blue';
              }
            } else {
              if (this.settings.blue.birthConditions.has(aliveNeighbors)) {
                return 'blue';
              } else {
                return 'dead';
              }
            }
          })
        );
        this.cells = newCells;
      },
      onestartSimulation() {
        if (!this.interval) {
          this.interval = setInterval(this.oneupdateCells, 300);
        }
      },

   // Подсчет количества соседей своего цвета и других
     stopSimulation() {
       clearInterval(this.interval);
       this.interval = null;
     },
 
     startSimulation() {
       if (!this.interval) {
         this.interval = setInterval(this.updateCells, 300);
       }
     },
     resetGrid() {
       this.stopSimulation();
       this.cells = this.createEmptyGrid();
     },
     pauseSim() {
       this.stopSimulation();
     }
 
   }
 };
 </script>
 
 <style scoped>
 .grid {
   display: grid;
   grid-template-columns: repeat(80, 15px);
   grid-template-rows: repeat(80, 15px);
   gap: 1px;
   background-color: #0c0c0c;
   padding: 1px;
 }
 
 .cell {
   width: 100%;
   height: 100%;
   cursor: pointer;
   border: 1px solid #383838;
   box-sizing: border-box;
 }
 
 .blue {
   background-color: rgb(0, 0, 255);
 }
 .green {
   background-color: green;
 }
 
 
 .dead {
   background-color: #000000;
 }
 </style>