class SoundAnalyzer {
    FFT fft;
    AudioIn audio;

    int bands = 512; // number of frequency bands for the FFT
    float[] spectrum = new float[bands];

    // // maximum of the ranges for grouping the frequencies (bands = 512)
    // float f_superLow = 30; // range 0 - 30 
    // float f_low = 80;
    // float f_middles = ;
    // float f_high;
    // float f_superHigh:

    SoundAnalyzer(PApplet parent) {
        fft = new FFT(parent, bands);
        audio = new AudioIn(parent);
        //audio.start(); // start capturing microphone input
        audio.play();

        // set the audio input for the analyzer
        fft.input(audio);
    }

    // void attachSoundFile(SoundFile audio) {
    //     fft.input(audio);
    //     audio.play();
    // }

    void calculateSpectrum() {
        // calculates the current spectrum
        fft.analyze(spectrum);
    }

    float highFreqsVol() {
        calculateSpectrum();
        int lower = int(bands * 0.97);
        int upper = bands;
        float vol = 0;

        for (int i = lower; i < upper; i++) {
            vol += spectrum[i];
        }
        float average = vol / (upper - lower);
        return strictMap(average, 0, 0.00003, 0, 100); // value between 0 and 15

    }

    // returns a value equal to the cols in the Terrain object
    int getLoudestFreq() {
        calculateSpectrum();

        int loudest = 0;
        for (int i = 0; i < bands; i++) {
            if (spectrum[i] > spectrum[loudest]) {
                loudest = i;
            }
        }
        return int(strictMap(loudest, 0, 10, 20, width / 5 - 20));
    }

    float getVol() {
        calculateSpectrum();

        float loudest = 0;
        for (int i = 0; i < bands; i++) {
            if (spectrum[i] > loudest) {
                loudest = spectrum[i];
            }
        }
        return strictMap(loudest, 0, 0.2, 0, 10);
        //return loudest;
    }
}