/*
 * GreenScreen-Ersetzungs-Tool (von Felix W.)
 * -> Ziel des Programms: 
 *    Ersetzt alle Pixel eines Bildes in einem definierten Farbbereich mit Pixeln aus einem zweiten Bild.
 * -> Bedienung:
 *    * Die Input-Bilder lassen sich im Code über SOURCE_IMG und REPLACEMENT_IMG definieren,
 *      das Ausgangsbild in einem Textfeld des GUI (Enter drücken, um zu bestätigen). 
 *      Die Dateipfade sind relativ zum Sketch-Ordner.
 *    * Der Farbbereich ist standardmäßig auf "grün" festgelegt und lässt sich über die drei Schieberegler
 *      im GUI verändern.
 *    * Abschließend kann man das generierte Bild mit dem "Save"-Knopf abspeichern.
 */

/*
 * Importiert die ControlP5-library.
 * Sollte diese nicht gefunden werden, muss sie manuell in Processing importiert werden.
 */
import controlP5.*;
import java.util.Arrays;

// Standardmäßige Bildpfade: Quellbild                  Bild, mit dem ersetzt wird           Ausgangsbild
static final String          SOURCE_IMG = "source.png", REPLACEMENT_IMG = "replacement.png", DEFAULT_RESULT_IMG = "result.png";

ControlP5 cp5; // ControlP5 Objekt
public GreenScreen gs; // GreenScreen Objekt

void setup() {       // Einstiegspunkt
    size(1280, 720); // Fenster mit der Größe von 1280x720px
    colorMode(HSB);  // setze den Farbmodus auf HSB (Hue Saturation Brightness)

    cp5 = new ControlP5(this); 
    gs = new GreenScreen(SOURCE_IMG, REPLACEMENT_IMG); // Lade die input-Bilder

    // Füge Controller aus den @Annotations hinzu
    cp5.addControllersFor(this);
    cp5.addControllersFor("gs", gs);

    // Füge eigene Controller hinzu
    cp5.addButton("btn_SaveCallback", 2)
        .setLabel("Save")
        .setSize(100, 20)
        .setPosition(width - 105, 5);

    cp5.addTextfield("newName")
        .setPosition(width - 320, 5)
        .setAutoClear(false)
        .setSize(200, 20)
        .setValue(DEFAULT_RESULT_IMG)
        .setLabel("");
}

void draw() {      // Programmschleife
    background(0); // schwarzer Hintergrund
    fill(200);     // Grauer Balken oben
    noStroke();
    rect(0, 0, width, 29);
    fill(0);
    line(0, 30, width, 29);

    gs.replaceGreenscreen();
    gs.display(0, 30, width, height - 30); // zeichne das Bild

    // setze die Farben der Slider für die Farbauswahl
    gs.setControllerCol("minhue", color(gs.minhue, 255, 255));
    gs.setControllerCol("maxhue", color(gs.maxhue, 255, 255));
    gs.setControllerCol("minbright", color(0, 0, gs.minbright));
}

void btn_SaveCallback() {                                     // Wird von ControlP5 aufgerufen
    gs.saveAs(cp5.get(Textfield.class, "newName").getText()); // speichere das Bild mit dem Namen des Textfeldes
}

class GreenScreen { // GreenScreen-Klasse
    final private PImage source,      // PImage -> eigentliches Bild
                         working,     // Berechnung findet auf diesem Bild statt
                         replacement; // Bild, mit dem ersetzt wird
 
    // Variablen, die den Farbbereich vorgeben, in dem eine Farbe z.B. als "grün" identifiziert wird.
    @ControlElement(x=10, y=5, label="min. Hue", properties={"min=0", "max=255", "type=slider", "height=20", "width=200", "value=70"})
    public int minhue = 70;
    @ControlElement(x=255, y=5, label="max. Hue", properties={"min=0", "max=255", "type=slider", "height=20", "width=200", "value=120"})
    public int maxhue = 120;
    @ControlElement(x=500, y=5, label="min. Brightness", properties={"min=0", "max=255", "type=slider", "height=20", "width=200"})
    public int minbright = 100;

    public GreenScreen(String path, String replacement_path) {   // Konstruktor  
        source = loadImage(path);                                // PImages laden
        replacement = loadImage(replacement_path);
        working = createImage(source.width, source.height, RGB); // erstelle ein neues Bild, auf dem gearbeitet wird
        source.loadPixels();                                     // Pixel laden
    }

    public void replaceGreenscreen() {                                        // Ersetzt alle Pixel, deren Farbton zwischen minhue und maxhue liegt, mit Pixeln aus dem "replacement"-Bild
        working.pixels = Arrays.copyOf(source.pixels, working.pixels.length); // kopiert die Pixel des original-Bildes
        replacement.resize(source.width, source.height);                      // 2tes bild auf die gleiche Größe brigen

        for(int i = 0; i < working.pixels.length; i++)                        // jedes Pixel durchgehen
            if(pixelInRange(i))                                               // falls der Pixel "grün" ist, ersetze ihn
                working.pixels[i] = replacement.pixels[i];
        working.updatePixels();                                               // Pixel aktualisieren
    }

    public void saveAs(String path) { // Speichert das Bild unter gegebenem Pfad
        working.save(path);
    }

    private boolean pixelInRange(int idx) { // findet heraus, ob ein pixel im Farbbereich ist, oder nicht
        color pixel = source.pixels[idx];
        return hue(pixel) <= maxhue && hue(pixel) >= minhue && brightness(pixel) >= this.minbright;
    }

    public void display(int x, int y, int w, int h) {                                             // Funktion zum Zeichnen des Bildes
        float ratio = min((float) w / (float) working.width, (float) h / (float) working.height); // findet den Faktor der Vergrößerung/-kleinerung des Bildes, damit es ohne zu verzerren gezeichnet werden kann.
        int draw_w = (int) (working.width * ratio), draw_h = (int) (working.height * ratio);      // skalierte Größe des Bildes
        image(working, x + (w - draw_w) / 2, y + (h - draw_h) / 2, draw_w, draw_h); // zeichnet das Bild
    }
     
    public void setControllerCol(String id, color col) { // Setzt die Farbe eines Controller Elements
        CColor ccol = new CColor().setActive(col);       // erstelle ein ControlP5 Farb-Objekt
        cp5.getController(id, this).setColor(ccol);      // setze die Farbe für this.id
    }
}
