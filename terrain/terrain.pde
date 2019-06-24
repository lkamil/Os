
// ______________________
// ___ Global Objects ___
// ______________________
// create new terrain and new camera object
Terrain terrain = new Terrain();
Camera camera = new Camera();

// ___________________________
// ___  setup() and draw() ___
// ___________________________

void setup() {
    // create a 3D canvas
    size(800, 600, P3D);
    camera.setToDefaultPosition();  
}

void draw() {
    background(50);
    
    flyOverTerrain();
    camera.run();
    terrain.display();
    
    // println(frameRate);
    // t.displayHeightmap(); // comment out camera() in setup to draw heightmap correctly
}

// _________________________
// ___  global functions ___
// _________________________

void flyOverTerrain() {
    camera.moveForward();

    if (camera.yPos % terrain.scl == 0) {
        terrain.calculateNewRow(); 
        terrain.startRow += 1;
    }
}

// ____________________
// ___ Terrain Class___
// ____________________

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

// ___________________
// ___ Camera Class___
// ___________________

class Camera {
    // variables for moving and positioning the camera
    float yoff; // determines how "far away" the camera is from the start point
    float speed;

    float angle; // angle of the camera for calculathin the z position
    float zoff; // variable for moving the focus and the camera itself up

    // x, y and z values place the camera
    float xPos;
    float yPos;
    float zPos;

    // x, y and z values of the scene determine where the camera's focus lies
    float focusX;
    float focusY;
    float focusZ;

    Camera() {
        speed = 5;
    }

    void calculateZPos() {
        zPos = abs(focusY) / tan(angle * PI / 180) + zoff;
    }

    void setToDefaultPosition() {
        yoff = 0;

        angle = 60.0;
        zoff = 100;

        focusX = width / 2;
        focusY = -height / 2;
        focusZ = zoff;

        xPos = width / 2;
        yPos = 0;
        calculateZPos();
    }

    void moveForward() {
        yPos -= speed;
        focusY = -height / 2 + yPos;
    }

    void run() {
        camera(xPos, yPos, zPos, focusX, focusY, focusZ, 0, 1, 0);
    }
}
