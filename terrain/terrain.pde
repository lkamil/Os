
import processing.sound.*;

// int lastFreq; // only for debugging

// create new terrain and new camera object
Terrain terrain = new Terrain();
Camera camera = new Camera();
SoundAnalyzer analyzer = new SoundAnalyzer(this);
// Weather weather = new Weather();

void setup() {
    // create a 3D canvas
    size(800, 600, P3D);
    camera.setToDefaultPosition();
    // weather.setSunLocation();

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
    
    // changeLandscape();

    // println(frameRate);
    // t.displayHeightmap(); // comment out camera() in setup to draw heightmap correctly
}

void flyOverTerrain() {
    camera.moveForward();
    // weather.moveSun(camera.speed);

    if (camera.yPos % terrain.scl == 0) {
        float freq = analyzer.getLoudestFreq();
        float vol = analyzer.getVol();
        // println(analyzer.getVol());
        terrain.calculateNewRow(freq, vol); 
        terrain.startRow += 1;
    }
}

enum Landscape {
        lakeland,
        mountains,
        desert
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

    float offset;
    float sealevel;

    Landscape currentLandscape;

    float rangeMaxHeight = 150;
    int currentFreq = cols / 2;

    Terrain() {
        w = 1000;
        h = 600;
        scl = 5;

        cols = w / scl;
        rows = h / scl;

        heightMap = new float[cols][rows];

        // Default landscape: Mountains
        createMountains();
        // createLakeland();
        // createDesert();

        calculateZValues();
    }

    void createLakeland() {
        maxHeight = 150;
        rangeMaxHeight = 150;
        sealevel = maxHeight * 0.5;
        offset = 0.03;

        currentLandscape = Landscape.lakeland;

    }

    void createMountains() {
        offset = 0.025;
        maxHeight = 300;
        sealevel = maxHeight * 0.3;

        currentLandscape = Landscape.mountains;

        // note: for harsher mountains, increase offset (and maybe raise sealevel)
    }

    void createDesert() {
        maxHeight = 150;
        offset = 0.007;
        sealevel = 0;

        currentLandscape = Landscape.desert;
    }

    void calculateZValues() {
        for (int y = 0; y < rows; y++) {
            xoff = 0.0; // set xoff to 0 before traversing a new row!
            for (int x = 0; x < cols; x++) {

                // set a z value for each element using perlin noise
                float z = map(noise(xoff, yoff), 0, 1, 0, maxHeight);

                if (z <= sealevel) {
                    heightMap[x][y] = sealevel;
                } else {
                    heightMap[x][y] = z;
                }

                xoff += offset;  // increase xoff value before moving on to the next col
            }
            yoff += offset; // increase xoff value before traversing a new row
        }
    }

    void calculateNewRow(float loudestFreq, float vol) {
        switch(currentLandscape) {
            case lakeland:
                // change of offset is determined by current volume
                if (vol > 5 && offset < 0.03) {
                    offset += 0.00025;
                } else if (offset > 0.025) {
                    offset -= 0.00025;
                }

                // increase or decrease currentFreq, depending if it grows or drops 
                if (currentFreq < loudestFreq) {
                    currentFreq += 1;
                } else {
                    currentFreq -= 1;
                }
            case mountains:
                // change of offset is determined by current volume
                if (vol > 5 && offset < 0.027) {
                    offset += 0.00015;
                } else if (offset > 0.023) {
                    offset -= 0.00015;
                }
            case desert:
                // createDesert();
        }

        // define range for increasing the maxHeight
        float rangeMin = currentFreq - 30;
        float rangeMax = currentFreq + 30;

        // increase or decrease currentFreq, depending if it grows or drops 
        if (currentFreq < loudestFreq) {
            currentFreq += 1;
        } else {
            currentFreq -= 1;
        }


        int rowCount = heightMap[0].length; // amount of rows the heightMap array contains
        int y = rowCount;
        xoff = 0.0;

        for(int x = 0; x < cols; x++) { // traverse each col
            // add new row (increase length by one for each col)
            heightMap[x] = expand(heightMap[x], rowCount + 1);

            switch (currentLandscape) {
                case lakeland:
                    // increase maxHeight depending on the index of the loudest frequency
                    if (x > rangeMin && x < rangeMax && rangeMaxHeight < 250) {
                        rangeMaxHeight += 0.7;
                    } else if (rangeMaxHeight > 150) {
                        rangeMaxHeight -= 0.7;
                    }
                case mountains:
                    if (x > rangeMin && x < rangeMax && rangeMaxHeight < 500) {
                        rangeMaxHeight += 0.7;
                    } else if (rangeMaxHeight > 300) {
                        rangeMaxHeight -= 0.7;
                    }
                case desert:
            }

            // maybe change overall maxHeight if the music is really loud
            // if (vol > 2 && rangeMaxHeight < 250) {
            //     rangeMaxHeight += 0.2;
            // } else if (rangeMaxHeight > 150) {
            //     rangeMaxHeight -= 0.2;
            // }

            float z = map(noise(xoff, yoff), 0, 1, 0, rangeMaxHeight);

            if (z <= sealevel) {
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
        switch(currentLandscape) {
            case lakeland:
                if (z == sealevel) {
                    return color(23, 87, 126);
                } else if (z < maxHeight * 0.55) {
                    return color(228, 228, 199);
                } else {
                    //return color(69, 173, 78);
                    float darken = map(z, maxHeight, maxHeight * 0.55, 0.4, 1);
                    if (darken < 0.4) {
                        darken = 0.4;
                    }
                    int r = int(darken * 146);
                    int g = int(darken * 212);
                    int b = int(darken * 97);
                    return color(r, g, b);
                }
            case mountains:
                // the sea gets a blue color
                // the tips of the mountains are white
                // the main part of the mountains is graadient from dark grey to light grey
                if (z == sealevel) {
                    return color(135, 187, 255);
                } else if (z > maxHeight * 0.6) {
                    return color(255);
                } else {
                    //return color(69, 173, 78);
                    int greyVal = int(map(z, sealevel, maxHeight * 0.6, 50, 200));
                    return color(greyVal);
                }
            case desert:
                return color(255, 200, 61);
            default:
                println("Something went wrong!");
                return color(255);
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

enum Condition {
    sunny,
    cloudy
}

class Weather {
    Condition currentWeather;

    float sunX;
    float sunY;
    float sunZ;

    Weather() {
        // default weather condition is sunny
        currentWeather = Condition.sunny;   
    }

    void setSunLocation() {
        sunX = width * 0.2;
        sunY = -height;
        sunZ = 200;
    }

    void moveSun(float speed) {
        sunY -= speed;
    }

    void display() {
        switch(currentWeather) {
            case sunny:
            case cloudy:
                fill(255, 255, 0);
                translate(sunX, sunY, sunZ);
                sphere(30);
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
