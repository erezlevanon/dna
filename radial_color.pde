int concentricDivision = 50;
int radialDivision = 36;

float offset1 = 0, offset2 = 0;
float speed1 = 0.002, speed2 = -0.003;
float pMouseTheta, mouseTheta;
boolean draggedLayer = false;

float halfDiagonal;

float layerColorDiff = 100;
int layerPerLayer = 5;
int center = 5;
int centerColor = 255;

float darkenChance = 0.12;
float darkerDelta = 40;

Segment[][] segments = new Segment[concentricDivision][radialDivision];

boolean getDirection(int layer) {
  return (layer - center) / layerPerLayer % 2 == 0;
}

void setup() {
  frameRate(30);
  size(600, 600);
  halfDiagonal = sqrt((width/2) * (width/2) + (height/2) * (height/2));
  cursor(CROSS);
  for (int layer = 0; layer < concentricDivision; layer++) {
    for (int hour = 0; hour < radialDivision; hour++) {
      segments[layer][hour] = new Segment(layer,hour);
    }
  }
  background(0);
}

void draw() {
  offset1 += speed1;
  offset1 = offset1 < 0 ? offset1 + 2*PI : offset1;
  offset2 = offset2 + speed2;
  offset2 = offset2 < 0 ? offset2 + 2*PI : offset2;
  loadPixels();
  int newi, newj;
  int pixelLayer, pixelHour;
  float pixelR, pixelTheta;
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      newi = i - width / 2;
      newj = j - height / 2;
      pixelR = sqrt((newi*newi) + (newj*newj));    // Convert cartesian to polar
      pixelTheta = atan2(newj,newi) + PI;         // Convert cartesian to polar
      pixelLayer = floor(map(pixelR, 0, halfDiagonal, 0, concentricDivision-1));
      if (getDirection(pixelLayer)) {
        pixelHour = floor(map(pixelTheta + offset2 , 0, 2*PI, 0, radialDivision-1)) % radialDivision;
      } else {
        pixelHour = floor(map(pixelTheta + offset1, 0, 2*PI, 0, radialDivision-1)) % radialDivision;
      }
      color val = pixelLayer < center ? color(centerColor) : segments[pixelLayer][pixelHour].getColor();
      pixels[i+j*width] = val;
    }
  }
  updatePixels();
  if (random(0,1) < darkenChance) {
    int hourChanged = floor(random(0, radialDivision-0.1));
    for (int i = 0; i < concentricDivision; i++) {
      segments[i][hourChanged].makeDarker();
    }
  }
  for (int layer = 0; layer < concentricDivision; layer++) {
    for (int hour = 0; hour < radialDivision; hour++) {
      segments[layer][hour].updateColor();
    }
  }
  filter(BLUR, 5);
  filter(INVERT);
}

void mousePressed() {
    float newx = mouseX - width / 2;
    float newy = mouseY - height / 2;
    int mouseLayer = floor(map(sqrt((newx*newx) + (newy*newy)), 0, halfDiagonal, 0, concentricDivision-1));
    draggedLayer = getDirection(mouseLayer);
    pMouseTheta = atan2(newx, newy) + PI;
  }
  
void mouseDragged() {
  float newx = mouseX - width / 2;
  float newy = mouseY - height / 2;
  mouseTheta = atan2(newx, newy) + PI;
  if (!draggedLayer) {
    offset1 += mouseTheta - pMouseTheta;
    offset1 = offset1 < 0 ? offset1 + 2*PI : offset1;
  } else {
    offset2 += mouseTheta - pMouseTheta;
    offset2 = offset2 < 0 ? offset2 + 2*PI : offset2;
  }
  pMouseTheta = mouseTheta;
}

class Segment {

  float sinOffset;
  int layer, hour;
  
  float r, g, b;
  float maxr, maxg, maxb;
  
  boolean goingDark = false;
  float darkTargetR = 0, darkTargetG = 0, darkTargetB = 0;
  
  Segment(int layer, int hour) {
    this.layer = layer;
    this.hour = hour;
    
    this.maxr = random(0, 255);
    this.maxg = random(0, 255);
    this.maxb = random(0, 255);


    if (getDirection(layer)) {
      this.maxr = random(layerColorDiff, 255);
      this.maxg = random(layerColorDiff, 255);
      this.maxb = random(layerColorDiff, 255);
    }
    
    this.r = maxr;
    this.g = maxg;
    this.b = maxb;
    
    this.sinOffset = random(0,500);
  }
  
  color getColor() {
    float curR = r + sin((frameCount*0.33 + sinOffset) * 0.2) * 50;
    float curG = g + sin((frameCount*0.33 + sinOffset) * 0.2) * 50;
    float curB = b + sin((frameCount*0.33 + sinOffset) * 0.2) * 50;
    return color(curR, curG, curB);
  }
  
  void updateColor() {
    if (goingDark) {
        r = max(darkTargetR, r - 5);
        g = max(darkTargetG, g - 5);
        b = max(darkTargetB, b - 5);
        if (r <= darkTargetR) {
          goingDark = false;
        }
    } else {
        r = min(maxr, r + 5);
        g = min(maxg, g + 5);
        b = min(maxb, b + 5);
    }
  }
  
  void makeDarker() {
    goingDark = true;
    darkTargetR = makeRGBDarker(r, maxr);
    darkTargetG = makeRGBDarker(g, maxg);
    darkTargetB = makeRGBDarker(b, maxb);

  }
  
  float makeRGBDarker(float c, float maxc) {
    float res;
    res = (c-darkerDelta) / maxc;
    res = res*res;
    res = res * maxc;
    return res;
  }
  
  
}
