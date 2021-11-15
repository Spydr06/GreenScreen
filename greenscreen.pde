void setup() {
    new Image("img1.png")
        .replaceGreenscreen(loadImage("img2.png"))
        .saveAs("res.png");
    exit();
}

class Image {
    final private PImage img;
    private float minhue = 60, maxhue = 110;

    public Image(String path) {
        img = loadImage(path);
        img.loadPixels();
    }

    public Image replaceGreenscreen(PImage replacement) {
        replacement.resize(img.width, img.height);

        for(int i = 0; i < img.pixels.length; i++)
            if(pixelInRange(i))
                img.pixels[i] = replacement.pixels[i];

        return this;
    }

    public void saveAs(String path) {
        img.updatePixels();
        img.save(path);
    }

    private boolean pixelInRange(int idx) {
        color pixel = img.pixels[idx];
        return hue(pixel) <= maxhue && hue(pixel) >= minhue;
    }

    public Image setColorBounds(float minhue, float maxhue) {
        this.minhue = minhue;
        this.maxhue = maxhue;
        return this;
    }
}