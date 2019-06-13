int cols, rows;
int scl = 20;
int w = 2000;
int h = 1200;
float flying = 0;

float[][] terrain;

void setup() {
    size(950, 720, P3D);
    
    cols = w / scl;
    rows = h / scl;

    terrain = new float[cols][rows];
}

void draw() {
    translate(width / 2, height / 2); // draw everything relative to the center of the window
    rotateX(PI/3); // rotate x axis by 60° degrees

    background(40);
    
    mountains();
}

void mountains() {
    createNewMountainRange();
    fly();
}

void createNewMountainRange() {
    stroke(255);
    fill(255, 50);

    float yoff = flying; // offset value for perlin noise
    for (int y = 0; y < rows; y++) {
        float xoff = 0; // offset value for perlin noise
        for (int x = 0; x < cols; x++) {
            terrain[x][y] = map(noise(xoff,yoff),0,1,-50,150); // pick random z values for terrain
            xoff += 0.25;
        }
        yoff += 0.25;
    }

    flying -= 0.09;
}

void fly() {
    for (int y = -rows/2; y < rows/2 - 1; y++) {
        beginShape(TRIANGLE_STRIP); // Each row is a triangle strip
        for (int x = -cols/2; x < cols / 2; x++) {
            vertex(x * scl, y * scl, terrain[x + cols/2][y + rows/2]);
            vertex(x * scl, (y+1) * scl, terrain[x + cols / 2][y + 1 + rows / 2]);
        }
        endShape();
    }
}

