import gifAnimation.*;

GifMaker gifExport;
int gif_index = -1;

float frameSlowdown = 0.08f;
float alphaAmplitude = 100;

int targetNumberOfSegments = 60;

ArrayList<Cell> cells;

boolean USE_COLORED_SEGMENTS = true;
boolean USE_RED_CELLS = true;

void setup() {
  size(300, 30);
  frameRate(30);
  noStroke();

  newAnimation();
}

void draw() {
  background(0);
  for (int i = 0; i < cells.size(); i++) {
    cells.get(i).show();
  }

  gifExport.setDelay(1);
  gifExport.addFrame();

  if (frameCount * frameSlowdown > 2*PI) {
    gifExport.finish();

    newAnimation();
    frameCount = 0;
  }
}
void newAnimation() {
  restartValues();
  gif_index++;
  if (gif_index >= targetNumberOfSegments) {
    exit();
  } else {
    gifExport = new GifMaker(this, "segment_" + gif_index + ".gif");
    gifExport.setRepeat(0);
  }
}

void restartValues() {
  int x = 0;
  int minWidth = 2;
  int maxWidth = 10;
  int widthMultiplier = 3;
  int curWidth = floor(random(minWidth, maxWidth)) * widthMultiplier ;
  int coloredSegemntMinWidth = 33;
  int coloredSegmentMaxWidth = 110;
  cells = new ArrayList<Cell>();
  int coloredStart = maxWidth + 1;
  int coloredEnd = maxWidth + 1;
  int colorWidth = 0;
  if (USE_COLORED_SEGMENTS) {
    colorWidth = floor(this.random(coloredSegemntMinWidth, coloredSegmentMaxWidth));
    coloredStart = floor(this.random(0, width - colorWidth));
    coloredEnd = coloredStart + colorWidth;
  }
  while (x < width) {
    curWidth = Math.min(floor(this.random(minWidth, maxWidth)) * widthMultiplier, width - x);
    
    if (x > coloredStart && x < coloredEnd) {
      if (USE_RED_CELLS) {
          cells.add(new RedCell(x, curWidth));
      } else {
          cells.add(new ColoredCell(x, curWidth));
      }
    } else {
        cells.add(new Cell(x, curWidth));
    }
    x += curWidth;
  }
}

class Cell {
  int x;
  float alpha;
  float sinOffset;
  int myWidth;

  Cell(int new_x, int new_width) {
    x = new_x;
    myWidth = new_width;
    alpha = random(alphaAmplitude, 255);
    sinOffset = random(0, 200);
  }

  void show() {
    fill(255, 255, 255, 
      alpha + 
      sin((frameCount + sinOffset) * frameSlowdown) * alphaAmplitude
      );
    rect(x, 0, myWidth, height);
  }
}

class ColoredCell extends Cell{

  float r, g, b;
  float r_offset, g_offset, b_offset;
  
  ColoredCell(int new_x, int new_width) {
    super(new_x, new_width);
     r = random(alphaAmplitude, 255);
     g = random(alphaAmplitude, 255);
     b = random(alphaAmplitude, 255);
     r_offset = random(0, 200);
     g_offset = random(0, 200);
     b_offset = random(0, 200);
  }

  @Override void show() {
    
    fill(r + sin((frameCount + r_offset) * frameSlowdown) * alphaAmplitude,
         g + sin((frameCount + g_offset) * frameSlowdown) * alphaAmplitude,
         b + sin((frameCount + b_offset) * frameSlowdown) * alphaAmplitude
         );
    rect(x, 0, myWidth, height);
  }
}

class RedCell extends Cell {
  RedCell(int new_x, int new_width) {
    super(new_x, new_width);
  }

  @Override void show() {
    fill(255, 0, 0, 
      alpha + 
      sin((frameCount + sinOffset) * frameSlowdown) * alphaAmplitude
      );
    rect(x, 0, myWidth, height);
  }
}
