// Note:
// The camera moves deeper and deeper in 3D space (overflow danger?)
// The code seems to be efficient though, because "old" landscape that was displayed doesn't get displayed anymore

// create a terrain instance
Terrain t = new Terrain();

// values for camera
float centerHeight = 100;
float cameraAngle = 60.0;
float shift = 0; // for moving the camera to fly over the terrain
float cameraY = 0;

void setup() {
    // create a 3D canvas
    size(800, 600, P3D);
    // camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ)
    // camera(width/2, height, centerZ + centerY / tan(cameraAngle * PI / 180), width/2, centerY, centerZ, 0, 1, 0);
    camera(width/2, cameraY, centerHeight + (height / 2) / tan(cameraAngle * PI / 180), width/2, (-height / 2), centerHeight, 0, 1, 0);
    
}

void draw() {
    //println(frameRate);
    background(50);
    t.display();
    // t.displayHeightmap(); // comment out camera() in setup to draw heightmap correctly

    t.fly();
    moveCamera();
}

void moveCamera() {
    cameraY -= 5;
    //camera(width/2, height - shift, centerZ + centerY / tan(cameraAngle * PI / 180), width/2, centerY - shift, centerZ, 0, 1, 0);
    camera(width/2, cameraY, centerHeight + (height / 2) / tan(cameraAngle * PI / 180), width/2, (-height / 2) + cameraY, centerHeight, 0, 1, 0);
}

class Terrain {
    int cols, rows;
    int startRow = 0; // the first row that needs to be displayes (old rows don't need to be displayed,
    // because they are not in the camera frame)
    int scl; // determines the size of the triangles
    int w, h; // width and height - or better depth -  of the terrain
    int maxHeight; // defines the maximum height a mountain can have
    float[][] heightMap; // contains the height - or z value - for each vertice

    float xoff = 0.0;
    float yoff = 0.0;

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

    void calculateZValues() {
        for (int y = 0; y < rows; y++) {
            xoff = 0.0; // set xoff to 0 before traversing a new row!
            for (int x = 0; x < cols; x++) {

                // set a z value for each element using perlin noise
                heightMap[x][y] = map(noise(xoff, yoff), 0, 1, 0, maxHeight); 

                xoff += 0.1;  // increase xoff value before moving on to the next col
            }
            yoff += 0.1; // increase xoff value before traversing a new row
        }
    }

    // generates a new row and moves camera
    void fly() {
        if ((cameraY % scl) == 0) {
            calculateNewRow();
            startRow += 1; // old rows no longer need to be displayed
        }
    }

    void calculateNewRow() {
        int rowCount = heightMap[0].length; // amount of rows the heightMap array contains
        int y = rowCount;
        xoff = 0.0;
        for(int x = 0; x < cols; x++) { // traverse each col
            // add new row (increase length by one for each col)
            heightMap[x] = expand(heightMap[x], rowCount + 1);
            heightMap[x][y] = map(noise(xoff, yoff), 0,1, 0, maxHeight);
            xoff += 0.1;
        }
        yoff += 0.1;
        rows += 1;
    }

    void display() {
        stroke(255);
        //noFill();
        hint(DISABLE_DEPTH_TEST);
        fill(255, 50);

        for (int y = startRow; y < rows - 1; y++) {
            int widthOffset = 100;
            beginShape(TRIANGLE_STRIP); // Build triangle strip row by row
            for (int x = 0; x < cols; x++) {
                vertex(x * scl - widthOffset, - y * scl, heightMap[x][y]);
                vertex(x * scl - widthOffset, - (y + 1) * scl, heightMap[x][y+1]);
            }
            endShape();
        }
    }

    void displayHeightmap() {
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
