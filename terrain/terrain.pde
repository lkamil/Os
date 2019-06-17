int cols, rows;
int scl = 10;
int w = 2000;
int h = 1200;
int maxHeight;
float flying = 0;

float[][] terrain;

void setup() {
    size(950, 720, P3D);
    
    cols = w / scl;
    rows = h / scl;
    maxHeight = 150;

    terrain = new float[cols][rows];
    //frameRate(1000);
}

void draw() {
    translate(width / 2, height / 2); // draw everything relative to the center of the window
    rotateX(PI/3); // rotate x axis by 60° degrees

    background(40);
    
    mountains(); // draw mountains
    //println(frameRate);
}

void mountains() {
    createNewMountainRange();
    fly();
}

void createNewMountainRange() {
    float yoff = flying; // y offset value for 2D perlin noise
    for (int y = 0; y < rows; y++) {
        float xoff = 0; // x offset value for 2D perlin noise
        for (int x = 0; x < cols; x++) {
            terrain[x][y] = map(noise(xoff,yoff),0,1,0,maxHeight); // pick random z values for terrain
            xoff += 0.1;
        }
        yoff += 0.1;
    }
    flying -= 0.04;
}

void fly() {
    stroke(255, 20);
    // noStroke();
    //fill(100, 100, 255, 100);

    for (int y = -rows/2; y < rows/2 - 1; y++) {
        beginShape(TRIANGLE_STRIP); // Each row is a triangle strip

        for (int x = -cols/2; x < cols / 2; x++) {

            float zPos1 = terrain[x + cols/2][y + rows/2];
            color clr = checkVegetation(zPos1);
            fill(clr);
            vertex(x * scl, y * scl, zPos1);

            float zPos2 = terrain[x + cols / 2][y + 1 + rows / 2];
            clr = checkVegetation(zPos2);
            fill(clr);
            vertex(x * scl, (y+1) * scl, zPos2);
            
        }
        endShape();
    }
}

color checkVegetation(float zPos) {
    color base = color(96, 177, 76);
    color pines = color(34, 68, 35);
    color rocks = color(80, 102, 102);
    color snow = color(229, 255, 252);

    float step = maxHeight / 4;

    if (zPos <= step) {
        return base;
    } else if (zPos > step && zPos <= step * 2) {
        return pines;
    } else if (zPos > step * 2 && zPos <= step *3) {
        return rocks;
    } else {
        return snow;
    }
}

// color checkVegetation(float zPos) {
//     float step = maxHeight / 4;

//     float maxBaseHeight = step;
//     color base = color(96, 177, 76);

//     float maxPinesHeight = step * 2;
//     color pines = color(34, 68, 35);

//     float maxRocksHeight = step * 3;
//     color rocks = color(80, 102, 102);

//     float maxSnowHeight = step * 4;
//     color snow = color(229, 255, 252);

//     if (zPos < maxBaseHeight) { // base vegetation
//         if (zPos < maxBaseHeight / 2) {
//             return base;
//         } else {
//             float inter = map(zPos, maxBaseHeight / 2, maxBaseHeight, 0, 1);
//             return lerpColor(base, pines, inter);
//         }
//     } else if (zPos >= maxBaseHeight && zPos < maxPinesHeight) { // pine vegetation
//         if (zPos < maxBaseHeight + step / 2) {
//             return pines;
//         } else {
//             float inter = map(zPos, maxBaseHeight + step / 2, maxPinesHeight, 0, 1);
//             return lerpColor(pines, rocks, inter);
//         }
//     } else if (zPos > maxPinesHeight && zPos < maxSnowHeight) { // rock vegetation
//         if (zPos < maxPinesHeight + step / 2) {
//             return rocks;
//         } else {
//             float inter = map(zPos, maxPinesHeight + step / 2, maxSnowHeight, 0, 1);
//             return lerpColor(rocks, snow, inter);
//         }
//     } else {  // snow vegetation
//         return color(229, 255, 252);
//     }

// }

