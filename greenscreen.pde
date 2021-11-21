// Einstiegspunkt
void setup() {
    size(1280, 720);
    background(0);

    new GreenScreen("img3.jpg", "img5.jpg")         // Neues Bild laden
        .replaceGreenscreen()                       // Greenscreen mit 2tem Bild ersetzen
        .display(width, height)                     // anzeigen
        .saveAs("res.png")                          // Abspeichern
    ;
}

// Bild-Klasse
class GreenScreen {
    final private PImage source,              // PImage -> eigentliches Bild
                         replacement;         // Bild, mit dem ersetzt wird
    
    public byte minhue = 60, maxhue = 110,  // bereich, in dem ein Farbton als "grün erkannt wird"
                minbright = 100;

    public GreenScreen(String path, String replacement_path) { // Konstruktor  
        source = loadImage(path);                   // PImages laden
        replacement = loadImage(replacement_path);

        source.loadPixels(); // Pixel laden
    }
    // Ersetzt alle Pixel, deren Farbton zwischen minhue und maxhue liegt, mit Pixeln aus dem "replacement"-Bild
    public GreenScreen replaceGreenscreen() {
        replacement.resize(source.width, source.height); // 2tes bild auf die gleiche Größe brigen

        for(int i = 0; i < source.pixels.length; i++) // jedes Pixel durchgehen
            if(pixelInRange(i))                       // falls der Pixel "grün" ist, ersetze ihn
                source.pixels[i] = replacement.pixels[i];
        source.updatePixels(); // aktualisiere die Pixel

        return this; // gebe die Instanz der Klasse zurück, um Funktionen aneinanderzureihen
    }

    public GreenScreen saveAs(String path) { // speichere das Bild unter gegebenem Pfad
        source.save(path);
        return this; // gebe die Instanz der Klasse zurück, um Funktionen aneinanderzureihen
    }

    // bestimmt, ob ein pixel im Farbbereich ist, oder nicht
    private boolean pixelInRange(int idx) {
        color pixel = source.pixels[idx];
        return hue(pixel) <= maxhue && hue(pixel) >= minhue &&
               brightness(pixel) >= this.minbright;
    }

    // funktion, um den farbbereich manuell zu definieren
    public GreenScreen setMinHue(byte minhue) {
        this.minhue = minhue;
        return this; // gebe die Instanz der Klasse zurück, um Funktionen aneinanderzureihen
    }

    // funktion, um den farbbereich manuell zu definieren
    public GreenScreen setMaxHue(byte maxhue) {
        this.maxhue = maxhue;
        return this; // gebe die Instanz der Klasse zurück, um Funktionen aneinanderzureihen
    }
    
    // Funktion, um die minimale Helligkeit des greenscreens zu definieren
    public GreenScreen setMinBrightness(byte minbright) {
        this.minbright = minbright;
        return this; // gebe die Instanz der Klasse zurück, um Funktionen aneinanderzureihen
    }

    // Funktion zum Zeichnen des Bildes
    public GreenScreen display(int w, int h) {
        float ratio = min((float) w / (float) source.width, (float) h / (float) source.height); // findet den Faktor der Vergrößerung/-kleinerung des Bildes, damit es ohne zu verzerren gezeichnet werden kann.
        int draw_w = (int) (source.width * ratio),  // skalierte Größe des Bildes
            draw_h = (int) (source.height * ratio);

        image(source, (w - draw_w) / 2, (h - draw_h) / 2, draw_w, draw_h); // zeichnet das Bild

        return this; // gebe die Instanz der Klasse zurück, um Funktionen aneinanderzureihen
    }
}