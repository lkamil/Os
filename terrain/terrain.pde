
import processing.sound.*;


// create new terrain and new camera object
Terrain terrain = new Terrain();
Camera camera = new Camera();
SoundAnalyzer analyzer = new SoundAnalyzer(this);
Weather weather = new Weather();

int m;

void setup() {
    // create a 3D canvas
    size(800, 600, P3D);
    camera.setToDefaultPosition();
    m = millis(); // for timing events
    weather.setSunLocation();

}

void draw() {
    background(220, 220, 255);
    directionalLight(120, 120, 100, 1, -1, -1);
    ambientLight(120,120,150);

    flyOverTerrain();

    camera.run();
    camera.moveDown(350);

    terrain.display();

    // weather.display();
    // println(frameRate);
    // t.displayHeightmap(); // comment out camera() in setup to draw heightmap correctly
}

void flyOverTerrain() {
    camera.moveForward();
    weather.moveSun(camera.speed);

    if (camera.yPos % terrain.scl == 0) {
        float freq = analyzer.getLoudestFreqFake();
        float vol = analyzer.getVolFake();
        // println(analyzer.getVol());
        terrain.calculateNewRow(freq, vol); 
        terrain.startRow += 1;
    }
}

class Terrain {
    int cols, rows;
    int startRow = 0; // the first row that needs to be displayes (old rows don't need to be displayed,
    // because they are not in the camera frame)
    int scl; // determines the size of the triangles
    int w, h; // width and height - or better depth -  of the terrain
    float[][] heightMap; // contains the height - or z value - for each vertice

    float xoff = 0.0;
    float yoff = 0.0;

    Landscape landscape;
    Palette palette = new Palette();
    Paintbox paintbox = new Paintbox();

    //float increasedHeight = 150;
    int currentFreq = cols / 2;

    // Constructor
    Terrain() {
        // TODO: w and h should depend on the width and height of the sketch
        w = 1000;
        h = 600;
        scl = 5;

        cols = w / scl;
        rows = h / scl;

        heightMap = new float[cols][rows];

        landscape = new Landscape(LandForm.mountains);

        calculateZValues(); // Calculates a HeightMap
    }

    // Gets called from the Constructor to create a HeightMap
    void calculateZValues() {
        for (int y = 0; y < rows; y++) {
            xoff = 0.0; // set xoff to 0 before traversing a new row!
            for (int x = 0; x < cols; x++) {

                // set a z value for each element using perlin noise
                float z = map(noise(xoff, yoff), 0, 1, 0, landscape.height);

                if (z <= landscape.sealevel) {
                    heightMap[x][y] = landscape.sealevel;
                } else {
                    heightMap[x][y] = z;
                }

                xoff += landscape.offset;  // increase xoff value before moving on to the next col
            }
            yoff += landscape.offset; // increase xoff value before traversing a new row
        }
    }

    // Gets called when the camera flies over the terrain
    // Creates new Terrain based on Audio Input
    void calculateNewRow(float loudestFreq, float vol) {
        // changes values to make landscape react to music
        reactToMusic(loudestFreq, vol);

        int rowCount = heightMap[0].length; // amount of rows the heightMap array contains
        int y = rowCount;
        xoff = 0.0;

        for(int x = 0; x < cols; x++) { // traverse each col
            // add new row (increase length by one for each col)
            heightMap[x] = expand(heightMap[x], rowCount + 1);

            if (heightShouldBeChanged(x)) {
                landscape.increasedHeight += 0.7;
            } else if (landscape.increasedHeight > landscape.minHeight) {
                landscape.increasedHeight -= 0.7;
            }

            float z = map(noise(xoff, yoff), 0, 1, 0, landscape.increasedHeight);

            if (z <= landscape.sealevel) {
                heightMap[x][y] = landscape.sealevel;
            } else {
                heightMap[x][y] = z;
            }

            xoff += landscape.offset;
        }
        yoff += landscape.offset;
        rows += 1;
    }

    boolean heightShouldBeChanged(int x) {
        return (x > (currentFreq - 30) && x < (currentFreq + 30) && landscape.increasedHeight < landscape.maxHeight);
    }

    void reactToMusic(float loudestFreq, float vol) {
       changeOffsetForTerrainGeneration(vol);
       updateCurrentFrequency(loudestFreq);
    }

    void changeOffsetForTerrainGeneration(float vol) {
        // change the offset that is used by the noise function 
        // depending on the frequency that currenty has highest volume
        if (vol > 5 && landscape.offset < landscape.maxOffset) {
            landscape.offset += landscape.offsetStep;
        } else if (landscape.offset > landscape.minOffset) {
            landscape.offset -= landscape.offsetStep;
        }
    }

    void updateCurrentFrequency(float loudestFreq) {
         // increase or decrease currentFreq, depending if it grows or drops 
        if (currentFreq < loudestFreq) {
            currentFreq += 1;
        } else {
            currentFreq -= 1;
        }
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
        switch(landscape.currentLandForm) {
            case sea:
            case lakeland:
                if (z == landscape.sealevel) {
                    return paintbox.seaBlue;
                } else if (z < landscape.height * 0.55) {
                    return paintbox.grassGreen;
                } else {
                    float darken = map(z, landscape.height, landscape.height * 0.55, 0.4, 1);
                    if (darken < 0.4) {
                        darken = 0.4;
                    }
                    return palette.changeBrightness(paintbox.pineGreen, darken);
                }
            case mountains:
                // the sea gets a blue color
                // the tips of the mountains are white
                // the main part of the mountains is graadient from dark grey to light grey
                if (z == landscape.sealevel) {
                    return paintbox.lakeBlue;
                } else if (z > landscape.height * 0.6) {
                    return paintbox.snow;
                } else {
                    float lighten = map(z, landscape.sealevel, landscape.height * 0.6, 1, 4);
                    return palette.changeBrightness(paintbox.darkStone, lighten);
                }
            default:
                println("No Colors defined for this landform!");
                return color(0);
        } 
    }

    void displayHeightmap() {
        noStroke();
        for (int y = 0; y < rows - 1; y++) {
            for (int x = 0; x < cols; x++) {
                float c_val = map(heightMap[x][y], 0, landscape.height, 0, 255);
                fill(c_val, c_val, c_val);
                rect(x*scl, y*scl, scl, scl);
            }
        }
    }
}

float strictMap(float val, float min, float max, float newMin, float newMax) {
    if (val <= min) {
        return newMin;
    } else if (val > max) {
        return newMax;
    } else {
        float factor = (newMax - newMin) / (max - min);
        float newVal = (val - min) * factor + newMin;

        return newVal;
    }
}
