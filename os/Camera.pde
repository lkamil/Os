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
    float calculateZPos() {
        return abs(focusY) / tan(angle * PI / 180) + focusZ;
    }

    // when zPos is given
    void calculateAngle() {
        angle = atan(abs(focusY) / (zPos - focusZ));
    }

    float calculateFocusY() {
        if (focusZ < zPos) {
            return -tan(angle * PI /180) * (zPos - focusZ) + yPos;
        } else {
            return focusY;
        }
        
    }

    // when zPos and angle are given
    float calculateFocusZ(){
        // calculate helper varaible using an angle function
        float a = abs(focusY) / sin(angle * PI / 180);

        // calculate helper variable using cathetus theorem
        float p = pow(a, 2) / zPos;
        
        // return "q"
        return zPos - p;
    }

    void setToDefaultPosition() {
        yoff = 0;

        angle = 70.0;

        xPos = width / 2;
        yPos = 0;
        zPos = 350;

        focusX = width / 2;
        focusY = -height / 2;
        focusZ = calculateFocusZ();
    }

    void moveForward() {
        yPos -= speed;
        // focusY = -height / 2 + yPos;
        focusY -= speed;
    }

    void moveDown(float newZPos) {
        // DANGER: please check if newZPos is still above the mountains!!
        if (zPos > newZPos) {
                focusZ -= 1;
                zPos -= 1;
        }
    }

    void moveUp(float newZPos) {
        if (zPos < newZPos) {
            focusZ += 1;
            zPos += 1;
        }
    }

    void setSpeed() {
        // TODO: implement a function to change the speed of the camera!
    }

    void run() {
        camera(xPos, yPos, zPos, focusX, focusY, focusZ, 0, 1, 0);
    }
}