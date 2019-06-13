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
int scl = 20;
int w = 2000;
int h = 1200;
float flying = 0;

float[][] terrain;

public void setup() {
    
    
    cols = w / scl;
    rows = h / scl;

    terrain = new float[cols][rows];
}

public void draw() {
    translate(width / 2, height / 2); // draw everything relative to the center of the window
    rotateX(PI/3); // rotate x axis by 60° degrees

    background(40);
    
    mountains();
}

public void mountains() {
    createNewMountainRange();
    fly();
}

public void createNewMountainRange() {
    stroke(255);
    fill(255, 50);

    float yoff = flying; // offset value for perlin noise
    for (int y = 0; y < rows; y++) {
        float xoff = 0; // offset value for perlin noise
        for (int x = 0; x < cols; x++) {
            terrain[x][y] = map(noise(xoff,yoff),0,1,-50,150); // pick random z values for terrain
            xoff += 0.25f;
        }
        yoff += 0.25f;
    }

    flying -= 0.09f;
}

public void fly() {
    for (int y = -rows/2; y < rows/2 - 1; y++) {
        beginShape(TRIANGLE_STRIP); // Each row is a triangle strip
        for (int x = -cols/2; x < cols / 2; x++) {
            vertex(x * scl, y * scl, terrain[x + cols/2][y + rows/2]);
            vertex(x * scl, (y+1) * scl, terrain[x + cols / 2][y + 1 + rows / 2]);
        }
        endShape();
    }
}

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
