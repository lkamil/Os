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
        audio.start(); // start capturing microphone input

        // set the audio input for the analyzer
        fft.input(audio);
    }

    void attachSoundFile(SoundFile audio) {
        fft.input(audio);
        audio.play();
    }

    void calculateSpectrum() {
        // calculates the current spectrum
        fft.analyze(spectrum);
    }

    // returns a value between 0 and 1
    // 1 = highest frequency is the loudest
    // 0 = lowest frequency is the loudest
    int getLoudestFrequence() {
        calculateSpectrum();

        int loudest = 0;
        for (int i = 0; i < bands; i++) {
            if (spectrum[i] > spectrum[loudest]) {
                loudest = i;
            }
        }

        return loudest;
    }
}