import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class terrain extends PApplet {

int cols, rows;
int scl = 10;
int w = 2000;
int h = 1200;
int maxHeight;
float flying = 0;

float[][] terrain;

public void setup() {
    
    
    cols = w / scl;
    rows = h / scl;
    maxHeight = 150;

    terrain = new float[cols][rows];
    //frameRate(1000);
}

public void draw() {
    translate(width / 2, height / 2); // draw everything relative to the center of the window
    rotateX(PI/3); // rotate x axis by 60° degrees

    background(40);
    
    mountains(); // draw mountains
    //println(frameRate);
}

public void mountains() {
    createMountains();
    displayMountains();
    // createNewMountainRange();
    // fly();
}

public void createMountains() {
    float yoff = 0;
    for (int y = 0; y < rows; y++) {
         float xoff = 0;
        for (int x = 0; x < cols; x++) {
            terrain[x][y] = map(noise(xoff, yoff), 0, 1, 0, maxHeight); // use noise function to determine height
            xoff += 0.1f;
        }
        yoff += 0.1f;
    }
}

public void displayMountains() {
    stroke(255);
    noFill();
    for (int y = -rows/2; y < rows/2 - 1; y++) {
        beginShape(TRIANGLE_STRIP); // Each row is a triangle strip

        for (int x = -cols/2; x < cols / 2; x++) {

            float zPos1 = terrain[x + cols/2][y + rows/2];
            vertex(x * scl, y * scl, zPos1);

            float zPos2 = terrain[x + cols / 2][y + 1 + rows / 2];
            vertex(x * scl, (y+1) * scl, zPos2);
            
        }
        endShape();
    }
}

// void createNewRow() {

// }

// void moveCamera() {

// }

// void createNewMountainRange() {
//     float yoff = flying; // y offset value for 2D perlin noise
//     for (int y = 0; y < rows; y++) {
//         float xoff = 0; // x offset value for 2D perlin noise
//         for (int x = 0; x < cols; x++) {
//             terrain[x][y] = map(noise(xoff,yoff),0,1,0,maxHeight); // pick random z values for terrain
//             xoff += 0.1;
//         }
//         yoff += 0.1;
//     }
//     flying -= 0.04;
// }

// void fly() {
//     stroke(255, 20);
//     // noStroke();
//     //fill(100, 100, 255, 100);

//     for (int y = -rows/2; y < rows/2 - 1; y++) {
//         beginShape(TRIANGLE_STRIP); // Each row is a triangle strip

//         for (int x = -cols/2; x < cols / 2; x++) {

//             float zPos1 = terrain[x + cols/2][y + rows/2];
//             color clr = checkVegetation(zPos1);
//             fill(clr);
//             vertex(x * scl, y * scl, zPos1);

//             float zPos2 = terrain[x + cols / 2][y + 1 + rows / 2];
//             clr = checkVegetation(zPos2);
//             fill(clr);
//             vertex(x * scl, (y+1) * scl, zPos2);
            
//         }
//         endShape();
//     }
// }

public int checkVegetation(float zPos) {
    int base = color(96, 177, 76);
    int pines = color(34, 68, 35);
    int rocks = color(80, 102, 102);
    int snow = color(229, 255, 252);

    float step = maxHeight / 4;

    if (zPos <= step) {
        return base;
    } else if (zPos > step && zPos <= step * 2) {
        return pines;
    } else if (zPos > step * 2 && zPos <= step *3) {
        return rocks;
    } else {
        return snow;
    }
}

// color checkVegetation(float zPos) {
//     float step = maxHeight / 4;

//     float maxBaseHeight = step;
//     color base = color(96, 177, 76);

//     float maxPinesHeight = step * 2;
//     color pines = color(34, 68, 35);

//     float maxRocksHeight = step * 3;
//     color rocks = color(80, 102, 102);

//     float maxSnowHeight = step * 4;
//     color snow = color(229, 255, 252);

//     if (zPos < maxBaseHeight) { // base vegetation
//         if (zPos < maxBaseHeight / 2) {
//             return base;
//         } else {
//             float inter = map(zPos, maxBaseHeight / 2, maxBaseHeight, 0, 1);
//             return lerpColor(base, pines, inter);
//         }
//     } else if (zPos >= maxBaseHeight && zPos < maxPinesHeight) { // pine vegetation
//         if (zPos < maxBaseHeight + step / 2) {
//             return pines;
//         } else {
//             float inter = map(zPos, maxBaseHeight + step / 2, maxPinesHeight, 0, 1);
//             return lerpColor(pines, rocks, inter);
//         }
//     } else if (zPos > maxPinesHeight && zPos < maxSnowHeight) { // rock vegetation
//         if (zPos < maxPinesHeight + step / 2) {
//             return rocks;
//         } else {
//             float inter = map(zPos, maxPinesHeight + step / 2, maxSnowHeight, 0, 1);
//             return lerpColor(rocks, snow, inter);
//         }
//     } else {  // snow vegetation
//         return color(229, 255, 252);
//     }

// }

  public void settings() {  size(950, 720, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "terrain" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
