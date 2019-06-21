// create a terrain instance
Terrain t = new Terrain();

// values for camera
float centerHeight = 100;
float cameraAngle = 60.0;
float shift = 0; // for moving the camera to fly over the terrain

void setup() {
    // create a 3D canvas
    size(800, 600, P3D);
    // camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ)
    // camera(width/2, height, centerZ + centerY / tan(cameraAngle * PI / 180), width/2, centerY, centerZ, 0, 1, 0);
    camera(width/2, 0, centerHeight + (height / 2) / tan(cameraAngle * PI / 180), width/2, (-height / 2), centerHeight, 0, 1, 0);
    
}

void draw() {
    background(50);
    // positionCanvas();
    t.display();
    // t.displayHeightmap(); // comment out camera() in setup to draw heightmap correctly

    t.fly();
    moveCamera();
}

void moveCamera() {
    shift += 0.5;
    //camera(width/2, height - shift, centerZ + centerY / tan(cameraAngle * PI / 180), width/2, centerY - shift, centerZ, 0, 1, 0);
    camera(width/2, 0 - shift, centerHeight + (height / 2) / tan(cameraAngle * PI / 180), width/2, (-height / 2) - shift, centerHeight, 0, 1, 0);
}

void positionCanvas() {
    translate(0, height / 2, 0);
    rotateX(PI / 3); // rotate canvas so that we don't see the mountains straight from the top
}

class Terrain {
    int cols, rows;
    int scl; // determines the size of the triangles
    int w, h; // width and height - or better depth -  of the terrain
    int maxHeight; // defines the maximum height a mountain can have
    float[][] heightMap; // contains the height - or z value - for each vertice

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
        float yoff = 0.0;
        for (int y = 0; y < rows; y++) {
            float xoff = 0.0; // set xoff to 0 before traversing a new row!
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
        calculateNewRow();
    }

    void calculateNewRow() {
        // create new array, with an additional row?
        for(int x = 0; x < cols; x++) {
            append(heightMap[x], 500);
        }
        
    }

    void display() {
        stroke(255);
        //noFill();
        fill(255, 20);

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