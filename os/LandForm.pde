
enum LandFormType {
    lakeland,
    mountains,
    sea
}

class LandForm {
    LandFormType currentLandForm;
    
    float height;
    float increasedHeight; // for increasing the MaxHeight of a segment based on the loudest Frequency
    float offset;
    float sealevel;

    // Attributes for reacting to music
    float minOffset;
    float maxOffset;
    float offsetStep;
    float maxHeight;
    float minHeight;


    LandForm(LandFormType firstLandForm) {
        currentLandForm = firstLandForm;
        switch (currentLandForm) {
            case mountains:
                createMountains();
                break;
            case lakeland:
                createLakeland();
                break;
            case sea:
                createSea();
                break;
        }
    }

    void createLakeland() {
        currentLandForm = LandFormType.lakeland;

        height = 150;
        increasedHeight = 150;
        offset = 0.03;
        sealevel = height * 0.5;
        
        minOffset = 0.025;
        maxOffset = 0.03;
        offsetStep = 0.00025;
        maxHeight = 220;
        minHeight = 140;
    }

    void createMountains() {
        currentLandForm = LandFormType.mountains;

        height = 300;
        increasedHeight = 300;
        offset = 0.025;
        sealevel = height * 0.3;

        minOffset = 0.023;
        maxOffset = 0.027;
        offsetStep = 0.00015;
        maxHeight = 500;
        minHeight = 280;
    }
    void createSea() {
        currentLandForm = LandFormType.sea;

        height = 0;
        sealevel = 75;
        offset = 0.05;
    }

    void create(LandFormType newLandForm) {
        currentLandForm = newLandForm;
        switch(currentLandForm) {
            case sea:
                createSea();
                break;
            case lakeland:
                createLakeland();
                break;
            case mountains:
                createMountains();
                break;
        }
    }
}