class SoundAnalyzer {
    FFT fft;
    AudioIn audio;

    int bands = 512; // number of frequency bands for the FFT
    float[] spectrum = new float[bands];

    // variables for mockup
    float volOff;
    float freqOff;

    SoundAnalyzer(PApplet parent) {
        fft = new FFT(parent, bands);
        audio = new AudioIn(parent);
        audio.start(); // start capturing microphone input
        // audio.play();

        // set the audio input for the analyzer
        fft.input(audio);

        volOff = 0;
        freqOff = 0;
    }

    void calculateSpectrum() {
        // calculates the current spectrum
        fft.analyze(spectrum);
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
        return strictMap(loudest, 0, 0.02, 0, 10);
        //return loudest;
    }

    // Functions for mockup
    float getLoudestFreqFake() {
        freqOff += 0.01;
        return map(noise(freqOff), 0, 0.01, 20, width / 5 - 20);
    }

    float getVolFake() {
        volOff += 0.01;
        return map(noise(volOff), 0, 0.01, 0, 10);
    }
}