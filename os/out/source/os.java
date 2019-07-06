import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.sound.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class os extends PApplet {





// create new terrain and new camera object
Terrain terrain = new Terrain();
Camera camera = new Camera();
SoundAnalyzer analyzer = new SoundAnalyzer(this);
Weather weather = new Weather();

int m;

public void setup() {
    // create a 3D canvas
    
    camera.setToDefaultPosition();
    m = millis(); // for timing events
    weather.setSunLocation();

}

public void draw() {
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

public void flyOverTerrain() {
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

    float xoff = 0.0f;
    float yoff = 0.0f;

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
    public void calculateZValues() {
        for (int y = 0; y < rows; y++) {
            xoff = 0.0f; // set xoff to 0 before traversing a new row!
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
    public void calculateNewRow(float loudestFreq, float vol) {
        // changes values to make landscape react to music
        reactToMusic(loudestFreq, vol);

        int rowCount = heightMap[0].length; // amount of rows the heightMap array contains
        int y = rowCount;
        xoff = 0.0f;

        for(int x = 0; x < cols; x++) { // traverse each col
            // add new row (increase length by one for each col)
            heightMap[x] = expand(heightMap[x], rowCount + 1);

            if (heightShouldBeChanged(x)) {
                landscape.increasedHeight += 0.7f;
            } else if (landscape.increasedHeight > landscape.minHeight) {
                landscape.increasedHeight -= 0.7f;
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

    public boolean heightShouldBeChanged(int x) {
        return (x > (currentFreq - 30) && x < (currentFreq + 30) && landscape.increasedHeight < landscape.maxHeight);
    }

    public void reactToMusic(float loudestFreq, float vol) {
       changeOffsetForTerrainGeneration(vol);
       updateCurrentFrequency(loudestFreq);
    }

    public void changeOffsetForTerrainGeneration(float vol) {
        // change the offset that is used by the noise function 
        // depending on the frequency that currenty has highest volume
        if (vol > 5 && landscape.offset < landscape.maxOffset) {
            landscape.offset += landscape.offsetStep;
        } else if (landscape.offset > landscape.minOffset) {
            landscape.offset -= landscape.offsetStep;
        }
    }

    public void updateCurrentFrequency(float loudestFreq) {
         // increase or decrease currentFreq, depending if it grows or drops 
        if (currentFreq < loudestFreq) {
            currentFreq += 1;
        } else {
            currentFreq -= 1;
        }
    }

    public void display() {
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

    public int getColor(float z) {
        switch(landscape.currentLandForm) {
            case sea:
            case lakeland:
                if (z == landscape.sealevel) {
                    return paintbox.seaBlue;
                } else if (z < landscape.height * 0.55f) {
                    return paintbox.grassGreen;
                } else {
                    float darken = map(z, landscape.height, landscape.height * 0.55f, 0.4f, 1);
                    if (darken < 0.4f) {
                        darken = 0.4f;
                    }
                    return palette.changeBrightness(paintbox.pineGreen, darken);
                }
            case mountains:
                // the sea gets a blue color
                // the tips of the mountains are white
                // the main part of the mountains is graadient from dark grey to light grey
                if (z == landscape.sealevel) {
                    return paintbox.lakeBlue;
                } else if (z > landscape.height * 0.6f) {
                    return paintbox.snow;
                } else {
                    float lighten = map(z, landscape.sealevel, landscape.height * 0.6f, 1, 4);
                    return palette.changeBrightness(paintbox.darkStone, lighten);
                }
            default:
                println("No Colors defined for this landform!");
                return color(0);
        } 
    }

    public void displayHeightmap() {
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

public float strictMap(float val, float min, float max, float newMin, float newMax) {
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

    // when angle is given
    public float calculateZPos() {
        return abs(focusY) / tan(angle * PI / 180) + focusZ;
    }

    // when zPos is given
    public void calculateAngle() {
        angle = atan(abs(focusY) / (zPos - focusZ));
    }

    public float calculateFocusY() {
        if (focusZ < zPos) {
            return -tan(angle * PI /180) * (zPos - focusZ) + yPos;
        } else {
            return focusY;
        }
        
    }

    // when zPos and angle are given
    public float calculateFocusZ(){
        // calculate helper varaible using an angle function
        float a = abs(focusY) / sin(angle * PI / 180);

        // calculate helper variable using cathetus theorem
        float p = pow(a, 2) / zPos;
        
        // return "q"
        return zPos - p;
    }

    public void setToDefaultPosition() {
        yoff = 0;

        angle = 70.0f;

        xPos = width / 2;
        yPos = 0;
        zPos = 400;

        focusX = width / 2;
        focusY = -height / 2;
        focusZ = calculateFocusZ();
    }

    public void moveForward() {
        yPos -= speed;
        // focusY = -height / 2 + yPos;
        focusY -= speed;
    }

    public void moveDown(float newZPos) {
        // DANGER: please check if newZPos is still above the mountains!!
        if (zPos > newZPos) {
                focusZ -= 1;
                zPos -= 1;
        }
    }

    public void moveUp(float newZPos) {
        if (zPos < newZPos) {
            focusZ += 1;
            zPos += 1;
        }
    }

    public void setSpeed() {
        // TODO: implement a function to change the speed of the camera!
    }

    public void run() {
        camera(xPos, yPos, zPos, focusX, focusY, focusZ, 0, 1, 0);
    }
}
class Paintbox {
    int seaBlue = color(23, 87, 126);
    int lakeBlue = color(135, 187, 255);
    int snow = color(255);
    int darkStone = color(50);
    int pineGreen = color(56, 85, 40);
    int grassGreen = color(228, 228, 199);
}


class Palette {
    // percentage determines the amount of the second color
    public int blendColors(int c1, int c2, float percentage) {
        return lerpColor(c1, c2, percentage);
    }

    // a value greate 1 will lighten the color
    // a value less than 1 darkens the color
    public int changeBrightness(int c1, float factor) {
        float r = red(c1);
        float g = green(c1);
        float b = blue(c1);

        return color(r * factor, g * factor, b * factor);
    }

}
enum LandForm {
        lakeland,
        mountains,
        sea
}

class Landscape {
    LandForm currentLandForm;
    
    float height;
    float increasedHeight; // for increasing the MaxHeight of a segment based on the loudest Frequency
    float offset;
    float sealevel;

    // Attributes for reacting to music
    float minOffset;
    float maxOffset;
    float offsetStep;
    float maxHeight;
    float minHeight;


    Landscape(LandForm firstLandscape) {
        currentLandForm = firstLandscape;
        switch (currentLandForm) {
            case mountains:
                createMountains();
                break;
            case lakeland:
                createLakeland();
                break;
            case sea:
                createSea();
                break;
        }
    }

    public void createLakeland() {
        currentLandForm = LandForm.lakeland;

        height = 150;
        increasedHeight = 150;
        offset = 0.03f;
        sealevel = height * 0.5f;
        
        minOffset = 0.025f;
        maxOffset = 0.03f;
        offsetStep = 0.00025f;
        maxHeight = 220;
        minHeight = 140;
    }

    public void createMountains() {
        currentLandForm = LandForm.mountains;

        height = 300;
        increasedHeight = 300;
        offset = 0.025f;
        sealevel = height * 0.3f;

        minOffset = 0.023f;
        maxOffset = 0.027f;
        offsetStep = 0.00015f;
        maxHeight = 500;
        minHeight = 280;
    }

    public void createSea() {
        currentLandForm = LandForm.sea;

        height = 0;
        sealevel = 75;
        offset = 0.05f;
    }
    }
class SoundAnalyzer {
    FFT fft;
    AudioIn audio;

    int bands = 512; // number of frequency bands for the FFT
    float[] spectrum = new float[bands];

    // variables for mockup
    float volOff;
    float freqOff;

    SoundAnalyzer(PApplet parent) {
        fft = new FFT(parent, bands);
        audio = new AudioIn(parent);
        audio.start(); // start capturing microphone input
        // audio.play();

        // set the audio input for the analyzer
        fft.input(audio);

        volOff = 0;
        freqOff = 0;
    }

    public void calculateSpectrum() {
        // calculates the current spectrum
        fft.analyze(spectrum);
    }

    // returns a value equal to the cols in the Terrain object
    public int getLoudestFreq() {
        calculateSpectrum();

        int loudest = 0;
        for (int i = 0; i < bands; i++) {
            if (spectrum[i] > spectrum[loudest]) {
                loudest = i;
            }
        }
        return PApplet.parseInt(strictMap(loudest, 0, 10, 20, width / 5 - 20));
    }

    public float getVol() {
        calculateSpectrum();

        float loudest = 0;
        for (int i = 0; i < bands; i++) {
            if (spectrum[i] > loudest) {
                loudest = spectrum[i];
            }
        }
        return strictMap(loudest, 0, 0.2f, 0, 10);
        //return loudest;
    }

    // Functions for mockup

    public float getLoudestFreqFake() {
        freqOff += 0.1f;
        return map(noise(freqOff), 0, 0.1f, 20, width / 5 - 20);
    }

    public float getVolFake() {
        volOff += 0.1f;
        return map(noise(volOff), 0, 0.1f, 0, 10);
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

    public void setSunLocation() {
        sunX = width * 0.2f;
        sunY = -height;
        sunZ = 200;
    }

    public void moveSun(float speed) {
        sunY -= speed;
    }

    public void display() {
        switch(currentWeather) {
            case sunny:
            case cloudy:
                fill(255, 255, 0);
                translate(sunX, sunY, sunZ);
                sphere(30);
        }
    }
}
  public void settings() {  size(800, 600, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "os" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
