import processing.sound.*;


// ______________________
// ___ Global Objects ___
// ______________________

// create new terrain and new camera object
Terrain terrain = new Terrain();
Camera camera = new Camera();
SoundAnalyzer analyzer = new SoundAnalyzer(this);

// ___________________________
// ___  setup() and draw() ___
// ___________________________

void setup() {
    // create a 3D canvas
    size(800, 600, P3D);
    camera.setToDefaultPosition(); 

}

void draw() {
    background(220, 220, 255);
    directionalLight(120, 120, 100, 1, -1, -1);
    ambientLight(120,120,150);

    println(analyzer.getLoudestFrequence());
    
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
        float l = analyzer.getLoudestFrequence();
        terrain.calculateNewRow(l); 
        terrain.startRow += 1;
    }
}

class SoundAnalyzer {
    FFT fft;
    AudioIn audio;

    int bands = 8; // number of frequency bands for the FFT
    float[] spectrum = new float[bands];

    SoundAnalyzer(PApplet parent) {
        fft = new FFT(parent, bands);

        audio = new AudioIn(parent);
        audio.start();

        // set the audio input for the analyzer
        fft.input(audio);
    }

    void calculateSpectrum() {
        // calculates the current spectrum
        fft.analyze(spectrum);
    }

    // returns a value between 0 and 1
    // 1 = highest frequency is the loudest
    // 0 = lowest frequency is the loudest
    float getLoudestFrequence() {
        calculateSpectrum();

        float loudest = 0;
        for (int i = 0; i < bands; i++) {
            if (spectrum[i] > loudest) {
                loudest = spectrum[i];
            }
        }

        return map((loudest / bands), 0, 0.02, 0, 10);
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

    float offset = 0.03;
    float sealevel;

    Terrain() {
        w = 1000;
        h = 600;
        scl = 5;
        maxHeight = 200;
        sealevel = maxHeight * 0.3;

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
                float z = map(noise(xoff, yoff), 0, 1, 0, maxHeight);

                if (z < sealevel) {
                    heightMap[x][y] = sealevel;
                } else {
                    heightMap[x][y] = z;
                }

                xoff += offset;  // increase xoff value before moving on to the next col
            }
            yoff += offset; // increase xoff value before traversing a new row
        }
    }

    void calculateNewRow(float loudestFrequence) {
        //maxHeight = maxHeight + int(loudestFrequence) * 20;
        int rowCount = heightMap[0].length; // amount of rows the heightMap array contains
        int y = rowCount;
        xoff = 0.0;
        for(int x = 0; x < cols; x++) { // traverse each col
            // add new row (increase length by one for each col)
            heightMap[x] = expand(heightMap[x], rowCount + 1);
            // heightMap[x][y] = map(noise(xoff, yoff), 0,1, 0, maxHeight);
            float z = map(noise(xoff, yoff), 0, 1, 0, maxHeight);

            if (z < sealevel) {
                heightMap[x][y] = sealevel;
            } else {
                heightMap[x][y] = z;
            }

            xoff += offset;
        }
        yoff += offset;
        rows += 1;
    }

    void display() {
        //hint(DISABLE_DEPTH_TEST);
        noStroke();

        for (int y = startRow; y < rows - 1; y++) {
            int widthOffset = 100;
            beginShape(TRIANGLE_STRIP); // Build triangle strip row by row
            for (int x = 0; x < cols; x++) {
                fill(getColor(heightMap[x][y]));
                vertex(x * scl - widthOffset, - y * scl, heightMap[x][y]);

                fill(getColor(heightMap[x][y+1]));
                vertex(x * scl - widthOffset, - (y + 1) * scl, heightMap[x][y+1]);
            }
            endShape();
        }
    }

    color getColor(float z) {
        if (z == sealevel) {
            return color(135, 187, 255);
        }
        if (z > maxHeight * 0.6) {
            return color(255);
        } else {
            return color(69, 173, 78);
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