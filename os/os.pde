
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

    changeLandForm();

    // weather.display();
    // println(frameRate);
    // t.displayHeightmap(); // comment out camera() in setup to draw heightmap correctly
}

void flyOverTerrain() {
    camera.moveForward();
    weather.moveSun(camera.speed);

    if (camera.yPos % terrain.scl == 0) {
        float freq = analyzer.getLoudestFreq();
        // println(freq);
        float vol = analyzer.getVol();
        // println(vol);

        terrain.calculateNewRow(freq, vol); 
        terrain.startRow += 1;
    }
}

void changeLandForm() {
    float now = millis();
    if ((now - m > 2500) && (now - m < 2600)) {
        terrain.landForm.create(LandFormType.lakeland);
    }
    if ((now - m > 7000) && (now - m < 7100 )) {
        terrain.landForm.create(LandFormType.mountains);
    }
    if ((now - m > 12000) && (now -m < 12100)){
        terrain.landForm.create(LandFormType.lakeland);
    }
}

// strictMap() is a strict version of processing's map() function
// it always return a value between newMin and newMax even if the given value
// is not in the original range
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
