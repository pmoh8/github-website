String path = "data.csv";
String xName;
String yName;
String[] names;  
int[] values;

int minVal;
int maxVal;
int numRows;
int range;
float margin = 0.20;
float boxWidthScale = 0.7;
float yGraphBuffer = .9;
float yAxisLabelOffset=.85;
int pointRadius = 10;

float k=1.0;
float frames = 500.0;

int axesTextSize=12;

float xOrigin;
float yOrigin;
float yZero;
float xMax;
float yMax;
float boxWidth;  
  
float yAxisLength;
float xAxislength;

float buttWidth;
float buttHeight;

float buttX;
float barButtY;
float lineButtY;

boolean bar = true;
boolean line = false;
boolean animating = false;

float[] xBars;
float[] yBars;

float[] xLines;
float[] yLines;

void setup(){
  size(1000,800);
  surface.setResizable(true);
  background(255);  
  fill(50,140,200);
  readData();
}


void draw(){
  background(255); 
  updateValues();
  
  fill(50,140,200);
  rect(buttX,barButtY,buttWidth,buttHeight);
  rect(buttX,lineButtY,buttWidth,buttHeight);
  textSize(buttHeight*.9);
  fill(255,255,255);
  textAlign(LEFT, BOTTOM);
  text("Bar",buttX*1.01,barButtY+buttHeight);
  text("Line",buttX*1.01,lineButtY+buttHeight);
  textSize(axesTextSize);
  
  for(int i = 1; i<=numRows;i++){
    yBars[i-1] = values[i-1]*yAxisLength/range*yGraphBuffer;
    xBars[i-1] = xOrigin+(i-1)*boxWidth+boxWidth*(1-boxWidthScale);
    yLines[i-1] = values[i-1]*yAxisLength/range*yGraphBuffer;
    xLines[i-1]= xOrigin+(i-1)*boxWidth+boxWidth*(1-boxWidthScale)+.5*boxWidth*boxWidthScale; 
  }
  
  fill(50,140,200);
  if(animating){
    drawAxes();
    if(bar){
      animateBar();
    }
    else if(line){
      animateLine();
    }   
  }
  else{
    if(bar){
      drawBar();
    }
    else if(line){
      drawLine();
    }
  } 
  drawInfo();
  
} 

void drawAxes(){
  int j=0;
  if(minVal>0){
    range = maxVal;
    j = 0;
  }
  else{
    range = maxVal-minVal;
    j = minVal;
  }
  int opt = optimalTicks(range);
  println(j);
  
  int counter=0;
  while(j<=maxVal+opt){
    int label = j;
    float tickLocation = yOrigin-yAxisLength*counter*opt/range*yGraphBuffer;
    stroke(200);
    line(xOrigin, tickLocation, xMax, tickLocation);
    text(label,xOrigin*yAxisLabelOffset,tickLocation);
    j+=opt;
    counter++;
    yMax=tickLocation;
  }
  stroke(0);
  if(minVal>=0){
    yZero = yOrigin;
  }
  else{
    yZero = yOrigin-yAxisLength*(0-minVal)/range*yGraphBuffer;
  }
  
  line(xOrigin, yZero, xMax, yZero);
  for(int i = 1; i<=numRows;i++){
    textAlign(CENTER, TOP);
    textSize(axesTextSize);
    text(names[i-1],xBars[i-1]-.5*boxWidth*(1-boxWidthScale),yOrigin*1.02,
    boxWidth,4*(textAscent()+textDescent()));
  }
  
  textSize(25);
  line(xOrigin, yOrigin, xOrigin, yMax);
  textAlign(CENTER, TOP);
  text(yName,.1*xOrigin,.5*(yMax+yOrigin),.7*xOrigin,yAxisLength);
  //line(xOrigin, yOrigin, xMax, yOrigin);
  text(xName,.5*(xMax+xOrigin),.5*(height+yOrigin));
  
  
}


void drawBar(){
  drawAxes();
  for(int i = 1; i<=numRows;i++){
    rect(xBars[i-1],yZero-yBars[i-1],boxWidth*boxWidthScale,yBars[i-1]);
  }
  
}

void animateBar(){
  for(int i = 1; i<=numRows;i++){
        if(i!=numRows){
          line(xLines[i-1],yZero-yLines[i-1],lerp(xLines[i],xLines[i-1],k/frames),lerp(yZero-yLines[i],yZero-yLines[i-1],k/frames));
        }
        
        rect(lerp(xLines[i-1]-.5*pointRadius,xBars[i-1],k/frames),
        yZero-lerp(yLines[i-1]+.7*pointRadius,yBars[i-1],k/frames),
        lerp(pointRadius,boxWidth*boxWidthScale,k/frames),lerp(pointRadius,yBars[i-1],k/frames),
        lerp(pointRadius,0,k/frames));
        k++;
        
      }
      if(k>frames){
          animating=false;
          k=1.0;
      }
}
void drawLine(){
  drawAxes();
  
  textSize(axesTextSize);
  for(int i = 1; i<=numRows;i++){
    if(i!=numRows){
      line(xLines[i-1],yZero-yLines[i-1],xLines[i],yZero-yLines[i]);
    }
    ellipse(xLines[i-1],yZero-yLines[i-1],pointRadius,pointRadius);
  } 
}
void animateLine(){
  for(int i = 1; i<=numRows;i++){
        if(i!=numRows){
          line(xLines[i-1],yZero-yLines[i-1],lerp(xLines[i-1],xLines[i],k/frames),lerp(yZero-yLines[i-1],yZero-yLines[i],k/frames));
        }
        
        rect(lerp(xBars[i-1],xLines[i-1]-.5*pointRadius,k/frames),
        yZero-lerp(yBars[i-1],yLines[i-1]+.7*pointRadius,k/frames),
        lerp(boxWidth*boxWidthScale,pointRadius,k/frames),lerp(yBars[i-1],pointRadius,k/frames),
        lerp(0,pointRadius,k/frames));
        k++;
      }
      if(k>frames){
          animating=false;
          k=1.0;
      }
}

void mouseClicked(){
  if(mouseX>=buttX && mouseX<=buttX+buttWidth){
    if(mouseY>=barButtY&&mouseY<=barButtY+buttHeight&&!bar){
      animating = true;
      bar=true;
      line=false;
    }
    else if(mouseY>=lineButtY&&mouseY<=lineButtY+buttHeight&&!line){
      animating = true;
      bar=false;
      line=true;
    }
  }
}

void drawInfo(){
  
  textAlign(CENTER, BOTTOM);
  textSize(axesTextSize);
  if(bar){
    for(int i = 1; i<=numRows;i++){
    if(mouseX >= xBars[i-1] && mouseX <= xBars[i-1] + boxWidth*boxWidthScale 
    && (mouseY <= yZero && mouseY>= yZero-yBars[i-1] ||
    mouseY >=yZero&&mouseY<=yZero-yBars[i-1])){
      fill(255,255,255);
        String s = "("+names[i-1]+", "+values[i-1]+")";
        rect(mouseX-textWidth(s)/2-textWidth(s)*.05,mouseY,textWidth(s)*1.1,-(textAscent()+textDescent()));
        fill(0,0,0);
        text(s,mouseX,mouseY);
        fill(50,140,200);
      }
    }
  }
  
  else if(line){
    for(int i = 1; i<=numRows;i++){
    float disX = xLines[i-1] - mouseX;
    float disY = yZero-yLines[i-1] - mouseY;
    if(sq(disX) + sq(disY) < sq(pointRadius) ) {
        fill(255,255,255);
        String s = "("+names[i-1]+", "+values[i-1]+")";
        rect(mouseX-textWidth(s)/2-textWidth(s)*.05,mouseY,textWidth(s)*1.1,-(textAscent()+textDescent()));
        fill(0,0,0);
        text(s,mouseX,mouseY);
        fill(50,140,200);
      }
    }
  }
  
}

void readData(){
  //read in data
  String[] lines = loadStrings(path);
  String[] firstLine = split(lines[0],",");
  xName = firstLine[0];
  yName = firstLine[1];
  names = new String[lines.length-1];
  
  values = new int[lines.length-1];
  
  for(int i = 1; i<lines.length;i++){
    String[] row = split(lines[i],",");
    names[i-1] = row[0];
    values[i-1] = (int) parseFloat(row[1]);
  }

  //determine max and min
    maxVal = max(values);
    minVal = min(values);
    numRows=values.length;
   
   xBars = new float[numRows];
   yBars = new float[numRows];
   xLines = new float[numRows];
   yLines = new float[numRows];
}

void updateValues(){
  xOrigin=width*margin;
  yOrigin=height*(1-margin);
  xMax = width*(1-margin);
  yMax = height*margin;
  
  yAxisLength = height*(1-margin)-height*margin;
  xAxislength = width*(1-margin)-width*margin;
  boxWidth = (xAxislength/numRows);
   
  buttWidth=width*.1;
  buttHeight=height*.05;
  buttX = .47*(xMax+width);
  barButtY =.3*(height+yMax);
  lineButtY =.4*(height+yMax);
}

int optimalTicks(int range){
  float x=pow(10,floor(log(range)/log(10)));
  int tick;
  if (range/x >= 5){
   tick = int(x);
  }
  else if(range/x >= 10){
    tick = int(x/2);
  }
  else{
    tick = int(x/5);
  } //<>//
  println(tick);
  return tick;
}