/*
 * GreenScreen-Ersetzungs-Tool (von Felix W.)
 * -> Ziel des Programms: 
 *    Ersetzt alle Pixel eines Bildes in einem definierten Farbbereich mit Pixeln aus einem zweiten Bild.
 * -> Bedienung:
 *    * Die Input-Bilder lassen sich im Code über SOURCE_IMG und REPLACEMENT_IMG definieren,
 *      das Ausgangsbild in einem Textfeld des GUI. Die Dateipfade sind relativ zum Sketch-Ordner.
 *    * Der Farbbereich ist standardmäßig auf "grün" festgelegt und lässt sich über die drei Schieberegler
 *      im GUI verändern.
 *    * durch den "Calculate"-Knopf wird der "Green"screen mit den aktuellen Parametern ersetzt.
 *    * Abschließend kann man das generierte Bild mit dem "Save"-Knopf abspeichern.
 */

/*
 * Importiert die ControlP5-library.
 * Sollte diese nicht gefunden werden, muss sie manuell in Processing importiert werden.
 */
import controlP5.*;
import java.util.Arrays;

static final String SOURCE_IMG         = "source.png",
                    REPLACEMENT_IMG    = "replacement.png",
                    DEFAULT_RESULT_IMG = "result.png";

// ControlP5 Objekt
ControlP5 cp5;

// GreenScreen Objekt
public GreenScreen gs;

// Name, mit dem die neu generierte Datei gespeichert werden soll
@ControlElement(x=850, y=5, label="New File Name")
public String newName = DEFAULT_RESULT_IMG;

// Einstiegspunkt
void setup() {
    size(1280, 720); // Fenster mit der Größe von 1280x720px
    colorMode(HSB);  // setze den Farbmodus auf HSB (Hue Saturation Brightness)

    cp5 = new ControlP5(this); 
    gs = new GreenScreen(SOURCE_IMG, REPLACEMENT_IMG); // Lade die input-Bilder

    // Füge Controller aus den @Annotations hinzu
    cp5.addControllersFor(this);
    cp5.addControllersFor("gs", gs);

    // Füge eigene Controller hinzu
    cp5.addButton("btn_CalcCallback", 1)
        .setLabel("Calculate")
        .setPosition(760, 5);
    
    cp5.addButton("btn_SaveCallback", 2)
        .setLabel("Save")
        .setPosition(1000, 5);

    cp5.getController("newName", this)
        .listen(true);
}

// Programmschleife
void draw() {
    background(0); // schwarzer Hintergrund

    gs.display(0, 30, width, height - 30); // zeichne das Bild

    // setze die Farben der Slider für die Farbauswahl
    setControllerCol("minhue", gs, color(gs.minhue, 255, 255));
    setControllerCol("maxhue", gs, color(gs.maxhue, 255, 255));
    setControllerCol("minbright", gs, color(0, 0, gs.minbright));
}

// Setzt die Farbe eines Controller Element eines Feldes in einem bekannten Datentypen T
<T> void setControllerCol(String id, T type, color col) {
    CColor ccol = new CColor(); // erstelle ein ControlP5 Farb-Objekt
    ccol.setActive(col);

    cp5.getController(id, type).setColor(ccol); // setze die Farbe für T.id
}

// Button Callbacks (von ControlP5 aufgerufen)
void btn_CalcCallback() {
    gs.replaceGreenscreen();
}

void btn_SaveCallback() {
    gs.saveAs(newName);
}

// GreenScreen-Klasse
class GreenScreen {
    final private PImage source,      // PImage -> eigentliches Bild
                         working,     // Berechnung findet auf diesem Bild statt
                         replacement; // Bild, mit dem ersetzt wird
    
    // Variablen, die den Farbbereich vorgeben, in dem eine Farbe z.B. als "grün" identifiziert wird.
    @ControlElement(x=10, y=5, label="min. Hue", properties={"min=0", "max=255", "type=slider", "height=20", "width=200"})
    public int minhue = 60;

    @ControlElement(x=255, y=5, label="max. Hue", properties={"min=0", "max=255", "type=slider", "height=20", "width=200"})
    public int maxhue = 110;

    @ControlElement(x=500, y=5, label="min. Bright.", properties={"min=0", "max=255", "type=slider", "height=20", "width=200"})
    public int minbright = 100;

    public GreenScreen(String path, String replacement_path) { // Konstruktor  
        // PImages laden
        source = loadImage(path);  
        replacement = loadImage(replacement_path);

        /**
         * ! ACHTUNG, nicht optimal: bild bei "path" wird zweifach geladen.
         * Dies ist notwendig, da Processing es nicht leicht macht, ein PImage direkt im Code zu generieren.
         * Wenn man es schafft, eines zu erstellen, lässt es sich zudem nicht mehr abspeichern.
         * Demnach ist dies die einfachste, mir bekannte Methode.
         */
        working = loadImage(path);

        source.loadPixels(); // Pixel laden
    }

    // Ersetzt alle Pixel, deren Farbton zwischen minhue und maxhue liegt, mit Pixeln aus dem "replacement"-Bild
    public GreenScreen replaceGreenscreen() {
        working.pixels = Arrays.copyOf(source.pixels, working.pixels.length);

        replacement.resize(source.width, source.height); // 2tes bild auf die gleiche Größe brigen

        for(int i = 0; i < working.pixels.length; i++) // jedes Pixel durchgehen
            if(pixelInRange(i))                       // falls der Pixel "grün" ist, ersetze ihn
                working.pixels[i] = replacement.pixels[i];
        working.updatePixels();

        return this; // gebe die Instanz der Klasse zurück, um Funktionen aneinanderzureihen
    }

    // Speichere das Bild unter gegebenem Pfad
    public GreenScreen saveAs(String path) {
        working.save(path);
        return this; // gebe die Instanz der Klasse zurück, um Funktionen aneinanderzureihen
    }

    // Bestimmt, ob ein pixel im Farbbereich ist, oder nicht
    private boolean pixelInRange(int idx) {
        color pixel = source.pixels[idx];
        return hue(pixel) <= maxhue && hue(pixel) >= minhue &&
               brightness(pixel) >= this.minbright;
    }

    // Funktion, um den farbbereich manuell zu definieren
    public GreenScreen setMinHue(int minhue) {
        this.minhue = minhue;
        return this; // gebe die Instanz der Klasse zurück, um Funktionen aneinanderzureihen
    }

    // Funktion, um den farbbereich manuell zu definieren
    public GreenScreen setMaxHue(int maxhue) {
        this.maxhue = maxhue;
        return this; // gebe die Instanz der Klasse zurück, um Funktionen aneinanderzureihen
    }
    
    // Funktion, um die minimale Helligkeit des greenscreens zu definieren
    public GreenScreen setMinBrightness(int minbright) {
        this.minbright = minbright;
        return this; // gebe die Instanz der Klasse zurück, um Funktionen aneinanderzureihen
    }

    // Funktion zum Zeichnen des Bildes
    public GreenScreen display(int x, int y, int w, int h) {
        float ratio = min((float) w / (float) working.width, (float) h / (float) working.height); // findet den Faktor der Vergrößerung/-kleinerung des Bildes, damit es ohne zu verzerren gezeichnet werden kann.
        int draw_w = (int) (working.width * ratio),  // skalierte Größe des Bildes
            draw_h = (int) (working.height * ratio);

        image(working, x + (w - draw_w) / 2, y + (h - draw_h) / 2, draw_w, draw_h); // zeichnet das Bild

        return this; // gebe die Instanz der Klasse zurück, um Funktionen aneinanderzureihen
    }
}