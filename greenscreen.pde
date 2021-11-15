void setup()
{
    new Image("img1.png")
        .replaceGreenscreen(loadImage("img2.png"))
        .saveAs("res.png");
}

class Image {
    final private PImage img;
    
    private color mincol = color(0,  100, 0), 
                  maxcol = color(48, 233, 9);

    public Image(String path) 
    {
        this.img = loadImage(path);
        this.img.loadPixels();
    }

    public Image replaceGreenscreen(PImage replacement)
    {
        replacement.resize(this.img.width, this.img.height);

        for(int i = 0; i < this.img.pixels.length; i++)
            if(pixelInRange(i))
                this.img.pixels[i] = replacement.pixels[i];        

        updatePixels();

        return this;
    }

    public void saveAs(String path)
    {
        this.img.updatePixels();
        this.img.save(path);
    }

    private boolean pixelInRange(int idx)
    {
        color pixel = this.img.pixels[idx];
        return red(pixel)   <= red(this.maxcol)   && red(pixel)   >= red(this.mincol)   && 
               green(pixel) <= green(this.maxcol) && green(pixel) >= green(this.mincol) && 
               blue(pixel)  <= blue(this.maxcol)  && blue(pixel)  >= blue(this.mincol);
    }

    private void updatePixels() 
    {
        this.img.updatePixels();
    }

    public Image setMinCol(color mincol)
    {
        this.mincol = mincol;
        return this;
    }

    public Image setMaxCol(color maxcol)
    {
        this.maxcol = maxcol;
        return this;
    }
}
