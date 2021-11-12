void setup()
{
    PImage replacementImage = loadImage("img2.png");
    new Image("img1.png")
        .replaceGreenscreen(replacementImage)
        .saveAs("res.png");
}

class Image {

    final private PImage img;
    final int width, height;
    
    color mincol = color(0,  100, 0), 
          maxcol = color(48, 233, 9);

    public Image(String path) 
    {
        this.img = loadImage(path);
        this.img.loadPixels();

        this.width = this.img.width;
        this.height = this.img.height;
    }

    public Image replaceGreenscreen(PImage replacement)
    {
        for(int i = 0; i < this.width; i++)
            for(int j = 0; j < this.height; j++)
                if(pixelInRange(i, j))
                {
                    int replacement_x = (int) map(i, 0, this.width,  0, replacement.width ),
                        replacement_y = (int) map(j, 0, this.height, 0, replacement.height);
                    replacePixel(i, j, replacement.pixels[replacement_x + replacement.width * replacement_y]);
                }

        updatePixels();

        return this;
    }

    public void saveAs(String path)
    {
        this.img.updatePixels();
        this.img.save(path);
    }

    private boolean pixelInRange(int x, int y)
    {
        color pixel = this.img.pixels[x + this.img.width * y];
        return red(pixel)   <= red(this.maxcol)   && red(pixel)   >= red(this.mincol)   && 
               green(pixel) <= green(this.maxcol) && green(pixel) >= green(this.mincol) && 
               blue(pixel)  <= blue(this.maxcol)  && blue(pixel)   >= blue(this.mincol);
    }

    private void replacePixel(int x, int y, color newcol)
    {
        this.img.pixels[x + this.img.width * y] = newcol;
    }

    private void updatePixels()
    {
        this.img.updatePixels();
    }

    /*************************
     * Getter und Setter     *
     ************************/

    public Image setMinCol(color mincol)
    {
        this.mincol = mincol;
        return this;
    }

    public color getMinCol()
    {
        return this.mincol;
    }

    public Image setMaxCol(color maxcol)
    {
        this.maxcol = maxcol;
        return this;
    }

    public color getMaxCol()
    {
        return this.maxcol;
    }

    public PImage getPImage()
    {
        return this.img;
    }

}