// https://medium.com/@nickobrien/diamond-square-algorithm-explanation-and-c-implementation-5efa891e486f

void setup() {

}

void draw() {

}

class Terrain {
    int arraySize;
    int max;
    int map[][];

    Terrain(int detail) {
        arraySize = pow(2, detail) + 1;
        max = size - 1;
        map = new int[size][size];
    }

    // set the corners to a seed value - half of the maximum height
    void setCorners(){
        map[0][0] = max / 2;
        map[0][max] = max / 2;
        map[max][0] = max / 2;
        map[max][max] = max / 2;
    }

    // calculates terrain using the diamond square algorithm
    // alternately calls squareStep() and diamondStep()
    void diamondSquare(size) {
        float half = max / 2;

        if (half < 1) {
            // if all values are set -> algorithm is done
            return;
        }

        // square steps
        for (int y = half; y < size; y += size) {
            for (int x = half; x < size; x += size) {
                squareStep(x % size; y % size, half);
            }
        }

        // diamond steps
        int col = 0;
        for (int x = 0; x < size; x += half) {
            col += 1;
            if (col % 2 == 1) {
                for (int y = half; y < size; y += size) {
                    diamondStep(x % size, y % size, half);
                }
            } else {
                for (int y = 0; y < size; y += size) {
                    diamondStep(x % size, y % size, half);
                }
            }

            diamondSquare(size / 2);
        }



    }
}