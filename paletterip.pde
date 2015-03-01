// Creates a proportional color palette of non-black/white colors 
// from a source image using a color distance algorithm

PImage sourceimg;
ArrayList<Pixel> colors;
int iwidth;
int iheight;
float tolerance = 50.0;
int totalCount = 0; 
float proptolerance = 0.005;
String filename = "jundi1";

float colorDist(color c1, color c2) {
  float r = red(c1) - red(c2);
  float g = green(c1) - green(c2);
  float b = blue(c1) - blue(c2);
  
  return sqrt(sq(r) + sq(g) + sq(b));
}

void sortColors() {
  colorMode(HSB);
  
  boolean swapped = true;
  int j = 0;
  while(swapped) {
    swapped = false;
    j++;
    for(int idx = 0; idx < colors.size()-j; idx++) {
      color currColor = colors.get(idx).pixelcolor;
      color nextColor = colors.get(idx+1).pixelcolor;
      color currCount = colors.get(idx).count;
      color nextCount = colors.get(idx+1).count;
      
     if(hue(currColor) > hue(nextColor)) {
       colors.get(idx+1).pixelcolor = currColor;
       colors.get(idx+1).count = currCount;
       
       colors.get(idx).pixelcolor = nextColor;
       colors.get(idx).count = nextCount;
       
       swapped = true;
     }
    }
  }
  
}

void addPixel(color currpix) {
  Pixel p = new Pixel();
  p.pixelcolor = currpix;
  p.count = 1;
  colors.add(p);
  totalCount++;
}

// ignores colors that are pure black/white
boolean notBlackorWhite(color col) {
  return ((col != 0.0) && (col != 255.0)); 
}

void setup() {
  background(0);
  size(900, 200);
  frame.setResizable(true);
  colors = new ArrayList<Pixel>();
  sourceimg = loadImage(filename+".jpg");
  iwidth = sourceimg.width;
  iheight = sourceimg.height;
  
  for(int i = 0; i < iheight; i++) {
    for(int j = 0; j < iwidth; j++) {
      color currpix = sourceimg.get(i,j);
      
      if(notBlackorWhite(currpix)) {
        if(colors.size() == 0) {
          addPixel(currpix);
        }
        
        else {
          int idx;
          boolean foundMatch = false;
          int prevIdx = 0;
          float minDist = 1000000.0;
          for(idx = 0; idx < colors.size(); idx++) {
            float currDist = colorDist(currpix, colors.get(idx).pixelcolor);
            if(currDist < tolerance) {
                  if(foundMatch && (currDist < minDist)) {
                    colors.get(idx).count++;
                    colors.get(prevIdx).count--;
                    
                    prevIdx = idx;
                    minDist = currDist;
                  }
                  else if(!foundMatch && (currDist < minDist)) {
                    colors.get(idx).count++;
                    totalCount++;
                    foundMatch = true;
                    prevIdx = idx;
                    minDist = currDist;
                  }
                }
          }
          
          if(!foundMatch) {
            // couldn't find a matching color
            addPixel(currpix);
            
          }
          
        }
      }
    }
  }
  
  int netCount = totalCount; 
  for(int idx = 0; idx < colors.size(); idx++) { 
    float prop = colors.get(idx).count / ((float)totalCount);
    
    if(prop < proptolerance) {
      netCount -= colors.get(idx).count;
    }
  }
  
  float xpos = 0f;
  color prevColor= colors.get(0).pixelcolor;
  sortColors();
  for(int idx = 0; idx < colors.size(); idx++) { 
    float prop = colors.get(idx).count / ((float)netCount);
    float rwidth = width*prop;
    
    if(prop < proptolerance) {
      xpos -= rwidth;
    }
    else {
      stroke(colors.get(idx).pixelcolor);
      fill(colors.get(idx).pixelcolor);
    }
    rect(xpos, 0, rwidth, height);
    xpos += rwidth;
    prevColor = colors.get(idx).pixelcolor;
  }
  
  save(filename + "-palette.png");
}



