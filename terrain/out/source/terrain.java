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

// create a terrain instance
Terrain t = new Terrain();

// values for camera
float centerHeight = 100;
float cameraAngle = 60.0f;
float shift = 0; // for moving the camera to fly over the terrain
float cameraY = 0;

public void setup() {
    // create a 3D canvas
    
    // camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ)
    // camera(width/2, height, centerZ + centerY / tan(cameraAngle * PI / 180), width/2, centerY, centerZ, 0, 1, 0);
    camera(width/2, cameraY, centerHeight + (height / 2) / tan(cameraAngle * PI / 180), width/2, (-height / 2), centerHeight, 0, 1, 0);
    
}

public void draw() {
    background(50);
    // positionCanvas();
    t.display();
    // t.displayHeightmap(); // comment out camera() in setup to draw heightmap correctly

    t.fly();
    moveCamera();
}

public void moveCamera() {
    cameraY -= 2;
    //camera(width/2, height - shift, centerZ + centerY / tan(cameraAngle * PI / 180), width/2, centerY - shift, centerZ, 0, 1, 0);
    camera(width/2, cameraY, centerHeight + (height / 2) / tan(cameraAngle * PI / 180), width/2, (-height / 2) + cameraY, centerHeight, 0, 1, 0);
}

public void positionCanvas() {
    translate(0, height / 2, 0);
    rotateX(PI / 3); // rotate canvas so that we don't see the mountains straight from the top
}

class Terrain {
    int cols, rows;
    int scl; // determines the size of the triangles
    int w, h; // width and height - or better depth -  of the terrain
    int maxHeight; // defines the maximum height a mountain can have
    float[][] heightMap; // contains the height - or z value - for each vertice

    float xoff = 0.0f;
    float yoff = 0.0f;

    Terrain() {
        w = 1000;
        h = 600;
        scl = 10;
        maxHeight = 200;

        cols = w / scl;
        rows = h / scl;

        heightMap = new float[cols][rows];

        calculateZValues();
    }

    public void calculateZValues() {
        for (int y = 0; y < rows; y++) {
            xoff = 0.0f; // set xoff to 0 before traversing a new row!
            for (int x = 0; x < cols; x++) {

                // set a z value for each element using perlin noise
                heightMap[x][y] = map(noise(xoff, yoff), 0, 1, 0, maxHeight); 

                xoff += 0.1f;  // increase xoff value before moving on to the next col
            }
            yoff += 0.1f; // increase xoff value before traversing a new row
        }
    }

    // generates a new row and moves camera
    public void fly() {
        if ((cameraY % scl) == 0) {
            calculateNewRow();
        }
    }

    public void calculateNewRow() {
        int rowCount = heightMap[0].length; // amount of rows the heightMap array contains
        int y = rowCount;
        xoff = 0.0f;
        for(int x = 0; x < cols; x++) { // traverse each col
            // add new row (increase length by one for each col)
            heightMap[x] = expand(heightMap[x], rowCount + 1);
            heightMap[x][y] = map(noise(xoff, yoff), 0,1, 0, maxHeight);
            xoff += 0.1f;
        }
        yoff += 0.1f;
        rows += 1;

        // TODO: if rows is bigger than threshold: move camera back and make a copy of the array only containing
        // the current values
    }

    public void display() {
        stroke(255);
        //noFill();
        hint(DISABLE_DEPTH_TEST);
        fill(255, 50);

        for (int y = 0; y < rows - 1; y++) {
            int widthOffset = 100;
            beginShape(TRIANGLE_STRIP); // Build triangle strip row by row
            for (int x = 0; x < cols; x++) {
                vertex(x * scl - widthOffset, - y * scl, heightMap[x][y]);
                vertex(x * scl - widthOffset, - (y + 1) * scl, heightMap[x][y+1]);
            }
            endShape();
        }
    }

    public void displayHeightmap() {
        noStroke();
        for (int y = 0; y < rows - 1; y++) {
            for (int x = 0; x < cols; x++) {
                float c_val = map(heightMap[x][y], 0, maxHeight, 0, 255);
                fill(c_val, c_val, c_val);
                rect(x*scl, y*scl, scl, scl);
            }
        }
    }
}

// class 2DArray {
//     ArrayList<float[]> rows = new ArrayList<float[]>();

//     2DArray(cols) {
//         float[] cols = new float[cols];
//     }

//     // vals = coumn values for the new row
//     void appendRow(float[] vals {
//         rows.add(vals);
//     }
// }

  public void settings() {  size(800, 600, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "terrain" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
