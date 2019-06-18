// create a terrain instance
Terrain t = new Terrain();

void setup() {
    // create a 3D canvas
    size(800, 600, P3D);
}

void draw() {
    background(50);
    positionCanvas();
    t.display();
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
        w = 820;
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

    void display() {
        stroke(255);
        noFill();

        for (int y = 0; y < rows - 1; y++) {
            beginShape(TRIANGLE_STRIP); // Build triangle strip row by row
            for (int x = 0; x < cols; x++) {
                vertex(x * scl, y * scl, heightMap[x][y]);
                vertex(x * scl, (y + 1) * scl, heightMap[x][y+1]);
            }
            endShape();
        }
    }
}