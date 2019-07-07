
// The terrain class manages the terrain generation
// It uses a landForm instance to determine what kind of terrain it generates

class Terrain {
    int cols, rows;
    int startRow = 0; // the first row that needs to be displayes (old rows don't need to be displayed,
    // because they are not in the camera frame)
    int scl; // determines the size of the triangles
    int w, h; // width and height - or better depth -  of the terrain
    float[][] heightMap; // contains the height - or z value - for each vertice

    float xoff = 0.0;
    float yoff = 0.0;

    LandForm landForm;
    Palette palette = new Palette();
    Paintbox paintbox = new Paintbox();

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

        landForm = new LandForm(LandFormType.sea);

        calculateZValues(); // Calculates a HeightMap
    }

    // Gets called from the Constructor to create a HeightMap
    void calculateZValues() {
        for (int y = 0; y < rows; y++) {
            xoff = 0.0; // set xoff to 0 before traversing a new row!
            for (int x = 0; x < cols; x++) {

                // set a z value for each element using perlin noise
                float z = map(noise(xoff, yoff), 0, 1, 0, landForm.height);

                if (z <= landForm.sealevel) {
                    heightMap[x][y] = landForm.sealevel;
                } else {
                    heightMap[x][y] = z;
                }

                xoff += landForm.offset;  // increase xoff value before moving on to the next col
            }
            yoff += landForm.offset; // increase xoff value before traversing a new row
        }
    }

    // Gets called when the camera flies over the terrain
    // Creates new Terrain based on Audio Input
    void calculateNewRow(float loudestFreq, float vol) {
        // println(landForm.currentLandForm.name());
        // landForm.create();
        // changes values to make landForm react to music
        reactToMusic(loudestFreq, vol);

        int rowCount = heightMap[0].length; // amount of rows the heightMap array contains
        int y = rowCount;
        xoff = 0.0;

        for(int x = 0; x < cols; x++) { // traverse each col
            // add new row (increase length by one for each col)
            heightMap[x] = expand(heightMap[x], rowCount + 1);

            if (heightShouldBeChanged(x)) {
                landForm.increasedHeight += 0.7;
            } else if (landForm.increasedHeight > landForm.minHeight) {
                landForm.increasedHeight -= 0.7;
            }

            float z = map(noise(xoff, yoff), 0, 1, 0, landForm.increasedHeight);

            if (z <= landForm.sealevel) {
                heightMap[x][y] = landForm.sealevel;
            } else {
                heightMap[x][y] = z;
            }

            xoff += landForm.offset;
        }
        yoff += landForm.offset;
        rows += 1;
    }

    boolean heightShouldBeChanged(int x) {
        return (x > (currentFreq - 30) && x < (currentFreq + 30) && landForm.increasedHeight < landForm.maxHeight);
    }

    void reactToMusic(float loudestFreq, float vol) {
       changeOffsetForTerrainGeneration(vol);
       updateCurrentFrequency(loudestFreq);
    }

    void changeOffsetForTerrainGeneration(float vol) {
        // change the offset that is used by the noise function 
        // depending on the frequency that currenty has highest volume
        if (vol > 5 && landForm.offset < landForm.maxOffset) {
            landForm.offset += landForm.offsetStep;
        } else if (landForm.offset > landForm.minOffset) {
            landForm.offset -= landForm.offsetStep;
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
        switch(landForm.currentLandForm) {
            case sea:
            case lakeland:
                if (z == landForm.sealevel) {
                    return paintbox.seaBlue;
                } else if (z < landForm.height * 0.55) {
                    return paintbox.grassGreen;
                } else {
                    float darken = map(z, landForm.height, landForm.height * 0.55, 0.4, 1);
                    if (darken < 0.4) {
                        darken = 0.4;
                    }
                    return palette.changeBrightness(paintbox.pineGreen, darken);
                }
            case mountains:
                // the sea gets a blue color
                // the tips of the mountains are white
                // the main part of the mountains is graadient from dark grey to light grey
                if (z == landForm.sealevel) {
                    return paintbox.lakeBlue;
                } else if (z > landForm.height * 0.6) {
                    return paintbox.snow;
                } else {
                    float lighten = map(z, landForm.sealevel, landForm.height * 0.6, 1, 4);
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
                float c_val = map(heightMap[x][y], 0, landForm.height, 0, 255);
                fill(c_val, c_val, c_val);
                rect(x*scl, y*scl, scl, scl);
            }
        }
    }
}