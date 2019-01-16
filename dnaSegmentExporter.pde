import gifAnimation.*;

GifMaker gifExport;
int gif_index = -1;

float frameSlowdown = 0.08f;
float alphaAmplitude = 100;

int targetNumberOfSegments = 3;

ArrayList<Cell> cells;

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
  int minWidth = 3;
  int maxWidth = 10;
  int widthMultiplier = 3;
  int curWidth = floor(random(minWidth, maxWidth)) * widthMultiplier ;
  cells = new ArrayList<Cell>();
  while (x < width) {
    curWidth = Math.min(floor(this.random(minWidth, maxWidth)) * widthMultiplier, width - x);
    cells.add(new Cell(x, curWidth));
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
    ;
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
