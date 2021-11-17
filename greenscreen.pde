// Einstiegspunkt
void setup() {
    new Image("img3.jpg")                           // Neues Bild laden
        .setColorBounds(60f, 130f)                  // Farbbereich definieren
        .replaceGreenscreen(loadImage("img2.png"))  // Greenscreen mit 2tem Bild ersetzen
        .saveAs("res.png");                         // Abspeichern
    exit();                                         // beenden
}

// Bild-Klasse
class Image {
    final private PImage img;                 // PImage -> eigentliches Bild
    private float minhue = 60, maxhue = 110,  // bereich, in dem ein Farbton als "grün erkannt wird"
                  minbright = 100;
    public Image(String path) { // Konstruktor  
        img = loadImage(path);  // PImage laden
        img.loadPixels();       // Pixel laden
    }

    // Ersetzt alle Pixel, deren Farbton zwischen minhue und maxhue liegt, mit Pixeln aus dem "replacement"-Bild
    public Image replaceGreenscreen(PImage replacement) {
        replacement.resize(img.width, img.height); // 2tes bild auf die gleiche Größe brigen

        for(int i = 0; i < img.pixels.length; i++) // jedes Pixel durchgehen
            if(pixelInRange(i))                    // falls der Pixel "grün" ist, ersetze ihn
                img.pixels[i] = replacement.pixels[i];

        return this; // gebe die Instanz der Klasse zurück, um Funktionen aneinanderzureihen
    }

    public void saveAs(String path) { // speichere das Bild unter gegebenem Pfad
        img.updatePixels();           // aktualisiere die Pixel
        img.save(path);
    }

    // bestimmt, ob ein pixel im Farbbereich ist, oder nicht
    private boolean pixelInRange(int idx) {
        color pixel = img.pixels[idx];
        return hue(pixel) <= maxhue && hue(pixel) >= minhue &&
               brightness(pixel) >= this.minbright;
    }

    // funktion, um den farbbereich manuell zu definieren
    public Image setColorBounds(float minhue, float maxhue) {
        this.minhue = minhue;
        this.maxhue = maxhue;
        return this; // gebe die Instanz der Klasse zurück, um Funktionen aneinanderzureihen
    }
    
    // Funktion, um die minimale Helligkeit des greenscreens zu definieren
    public Image setMinBrightness(float minbright) {
        this.minbright = minbright;
        return this; // gebe die Instanz der Klasse zurück, um Funktionen aneinanderzureihen
    }
}