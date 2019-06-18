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
        maxHeight = 150;

        cols = w / scl;
        rows = h / scl;

        heightMap = new float[cols][rows];

        // Set initial values
        for (int x = 0; x < cols; x++) {
            for (int y = 0; y < rows; y++) {
                heightMap[x][y] = 0;
            }
        }
    }

    void calculateZValues() {
        float xoff = 0.01;
        float yoff = 0.01;
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