// Code for Barricelli Cellular Automata by Alex Hyman 
// inspired by https://akkartik.name/post/2024-08-30-devlog
int cols;
int rows;
float rez;
int[][] world;
int M;
int i;
float brightnessIntensifier = 1; 
boolean finished; 
 
// The statements in the setup() function 
// run once when the program begins
void setup() {
  size(1000, 800);  // Size should be the first statement
  frameRate(100);
  start_world(); 
}

void draw() { 
  if(i < rows - 1 && !finished){
    drawRow(world, i); // draw the current row 
    calculateNextRow(world, i); // calculate the next row
    i += 1;
  } else {
    finished = true; 
    print("done");
  }
  // Call magnify function after drawing the scene
  magnify(mouseX, mouseY, 50, 3); 
}

void start_world(){
  background(255);
  finished = false; 
  cols = 500;
  rows = 500;
  rez = (float) width/cols;
  M = 5; 
  i = 0;
  world = new int[rows][cols];
  
  // init first row
  for(int c = 0; c < cols; c++){
    world[0][c] = (int) random(-M, M+1);
  }
}

void calculateNextRow(int[][] world, int curRowIndex){
  int[] curRow = world[curRowIndex];
  int[] world_after_movements = new int[cols];
  int[] collisions = new int[cols];
  for(int c = 0; c < cols; c++){
    collisions[c] = -1; 
  }
  
  // Move cells left/right based on their number 
  for(int c = 0; c < cols; c++){
    int cell = curRow[c]; 
    if (cell != 0){ // Without this condition the screen becomes overwhelmingly red 
      int next_position = pythonMod(c + cell, cols); // matches modding in python
      world_after_movements[next_position] = cell; // Actually move the cell 
      collisions[next_position] += 1; // record collision
    } 
  }
  
  // If two or more cells tried to move to the same position then clear the space
  // without this we get cool diagonal stripes
  for(int c = 0; c < cols; c++){
    if(collisions[c] > 0){
      world_after_movements[c] = 0; 
    }
  }
  
  // Init world_after_reproduction as copy of world_after_movements
  int[] world_after_reproduction = new int[cols];
  for (int c = 0; c < cols; c++){
    world_after_reproduction[c] = world_after_movements[c]; 
  }
  
  int[] children = new int[cols];
  int[] birth = new int[cols];
  for (int c = 0; c < cols; c++){
    int cell = world_after_movements[c]; 
    if(cell != 0 && curRow[c] !=0){ // After the cells have moved, if there is a nonred cell and there was a non red cell the time before
      int next_position = pythonMod(c - cell + curRow[c], cols); // Then produce a new cell nearby related to the parents 
      birth[next_position] += 1; // count the birth 
      children[next_position] = cell; // record that a child has been born
    }
  }
  
  for(int c = 0; c < cols; c++){
    // for each cell, if there was exactly one birth and there was nothing there when cells move
    if(birth[c] == 1 && world_after_reproduction[c] == 0){
      world_after_reproduction[c] = children[c]; // then place the child there
    }
  }
  
  
  // update world 
  for(int c = 0; c < cols; c++){
    world[curRowIndex+1][c] = world_after_reproduction[c];
    //world[curRowIndex+1][c] = world_after_movements[c];
  }
}

int pythonMod(int n, int m){
  return ((n % m) + m) % m; 
}

void drawRow(int[][] world, int curRowIndex){
  int[] curRow = world[curRowIndex];
  for(int c = 0; c < cols; c++){
    int cell = curRow[c];
    float x = (float) c * rez; 
    float y = (float) curRowIndex * rez;
    
    if(cell == 0){
      fill(255, 0, 0);
    } else if (cell < 0){
      // colour blue 
      fill(0, 0, brightnessIntensifier * 255 * -cell/(float) M);
    } else {
      // colour green
      fill(0, brightnessIntensifier * 255 * cell/(float) M, 0);
    }
    
    rect(x, y, rez, rez);
  }
}

// This magnifying code was made by chatgpt (WTF!)
void magnify(int mx, int my, int zoomSize, float scaleFactor) {
  int zoomWidth = zoomSize; 
  int zoomHeight = zoomSize;

  // Ensure magnified area does not go out of bounds
  int x = constrain(mx - zoomWidth / 2, 0, width - zoomWidth);
  int y = constrain(my - zoomHeight / 2, 0, height - zoomHeight);

  // Get pixels from the selected region
  PImage zoomedArea = get(x, y, zoomWidth, zoomHeight);

  // Calculate where to display the zoomed-in section
  int magnifyX = width - (int)(zoomWidth * scaleFactor) - 20; // Place at the top-right
  int magnifyY = 20;

  // Draw a border for the magnified section
  stroke(0);
  fill(255);
  rect(magnifyX - 2, magnifyY - 2, zoomWidth * scaleFactor + 4, zoomHeight * scaleFactor + 4);

  // Display the zoomed-in image
  image(zoomedArea, magnifyX, magnifyY, zoomWidth * scaleFactor, zoomHeight * scaleFactor);
}


// mouseclick means we restart the world
void mousePressed() {
  start_world();
}
