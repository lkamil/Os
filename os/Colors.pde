// These classes are used by the Terrain class to set and change colors

class Paintbox {
    color seaBlue = color(23, 87, 126);
    color lakeBlue = color(135, 187, 255);
    color snow = color(255);
    color darkStone = color(50);
    color pineGreen = color(56, 85, 40);
    color grassGreen = color(228, 228, 199);
}


class Palette {
    // percentage determines the amount of the second color
    color blendColors(color c1, color c2, float percentage) {
        return lerpColor(c1, c2, percentage);
    }

    // a value greate 1 will lighten the color
    // a value less than 1 darkens the color
    color changeBrightness(color c1, float factor) {
        float r = red(c1);
        float g = green(c1);
        float b = blue(c1);

        return color(r * factor, g * factor, b * factor);
    }

}
