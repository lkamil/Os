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