int numShells = 500;
double[] energies = new double[numShells];
double[] temperatures = new double[numShells];
double[] power = new double[numShells];
double thickness = 0.05; // thickness in meters
double l = 1; // length in meters
double dr = thickness / numShells;
double dt = 0.00005;
double r0 = 0.001; // inner radius in meters

double cv = 390; // J/kgK
double lambda = 390; // W/mK
double rho = 8960; // kg/m3'

double startTemp = 273.15; // Kelvin
double t0 = 273.15 + 120;

int sideMargins = 40;
int bottomMargin = 40;
int scaling = 8;

double frameTime = 1.0d/20;
double stepsPerFrame = (frameTime/dt);
double time = 0;

void setup() {
  size(1920, 1080);
  stroke(255);
  frameRate(1000000);
  
  println("Steps per frame: " + stepsPerFrame);
  
  for(int i = 0; i < numShells; i++) {
    energies[i] = startTemp * cv;
  }
  updateTemperatures();
}

double[] newEnergies;
void updateEnergies() {
  double[] newEnergies = energies;
  
  for(int i = 1; i < numShells; i++) {
    double r = r0 + dr * i;
    double dtdry = 0;
    double dtdri = (temperatures[i] - temperatures[i - 1])/dr;
    if(i < numShells - 1) { // last cell can't flow energy out
      dtdry = (temperatures[i + 1] - temperatures[i])/dr;
    }
    double dqdt = 2 * lambda * PI * l * ((r + dr) * dtdry - r * dtdri);
    
    power[i] = - dtdri * lambda * r;
    
    newEnergies[numShells - 1] = startTemp * cv;
    newEnergies[i] += dqdt * dt;
  }
  
  energies = newEnergies;
}

void updateTemperatures() {
  for(int i = 0; i < numShells; i++) {
    temperatures[i] = energies[i]/cv;
  }
  temperatures[0] = t0;
}

void drawCoordinateSystem() {
  stroke(255);
  float xaxisycoord = height - bottomMargin;
  float yaxisxcoord = sideMargins;
  line(0, xaxisycoord, width, xaxisycoord);
  line(yaxisxcoord, 0, yaxisxcoord, height);
}

void draw() { 
  background(0);
  stroke(256, 256, 256);
  strokeWeight(2);
  noFill();
  
  for(int i = 0; i < stepsPerFrame; i++) {
    updateEnergies();
    updateTemperatures();
    time += dt; 
  }
  
  double pxprm = (width - 2 * sideMargins)/thickness;
  beginShape();
  for(int i = 0; i < numShells; i++) {
    //println(temperatures[i]);
    double x = sideMargins + pxprm*dr*i;
    double y = (height - (temperatures[i]-273.15) * scaling) - bottomMargin;
    //circle(x, y, 5);
    vertex((float)x, (float)y);
  }
  endShape();
  
  stroke(256, 256, 0);
  beginShape();
  for(int i = 1; i < numShells; i++) {
    //println(temperatures[i]);
    double x = sideMargins + pxprm*dr*i;
    double y = (height - (power[i])/100) - bottomMargin;
    //circle(x, y, 5);
    vertex((float)x, (float)y);
  }
  endShape();
  
  stroke(256, 0, 256);
  beginShape();
  for(int i = 0; i < numShells; i++) {
    double x = sideMargins + pxprm*dr*i;
    double y = (height - (-30.5202*log((float)(i*dr+r0))-90.8259)*scaling) - bottomMargin;
    //circle(x, y, 5);
    vertex((float)x, (float)y);
  }
  endShape();
  
  textSize(36);
  text("t = " + nf((float)time, 0, 1), sideMargins + 10, 40);
  
  drawCoordinateSystem();
  
  saveFrame("frames/####.tif");
  
} 
