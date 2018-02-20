
color c1, c2,c3,ultraHighlight;
String path = "data.csv";

//store column headers and row names
String[] attributes;
String[] names;
float[] maxes;
float[] mins;
float[][] data;
int[] orientations;

//data related stuff
int numAttributes;
int numItems;
IntList highlights;
int superMegaUltraHighlight = -1;

boolean set = false;
boolean axisSelect = false;
boolean selectBoxActive = false;
//good ol' visual things
float xMargin = .15;
float yMargin = .2;

float chartLengthX;
float chartLengthY;

float chartOriginX;
float chartOriginY;

float intervalLength;
String colorMode = "default";
int selAttr;
//some mousey things
float clickX1;
float clickY1;
float clickX2;
float clickY2;


void setup(){
  size(1000,800);
  surface.setResizable(true);
  background(255);  
  fill(50,140,200);
  c1 = color(66, 134, 244);
  c2 = color(0,0,0);
  c3 = color(200,200,200);
  ultraHighlight = color(200,100,100);
  highlights = new IntList();
  readData();
}

void draw(){
  background(255); 
  updateUIValues();

  drawLines();
  drawAxes();
  drawSelectionBox();
  hoverInfo();

}

void mousePressed(){
  clickX1 = mouseX;
  clickY1 = mouseY;
  clickX2=0;
  clickY2=0;
  for(int i = 0; i <numAttributes; i++){
    float xCoord = chartOriginX + i *intervalLength;
    if(abs(mouseX-xCoord)<50 && 
    (abs(mouseY-chartOriginY*.8)<10 || abs(mouseY-height*.85)<10)){
      orientations[i] = - orientations[i];
    }
  }
}
void mouseDragged(){
  clickX2 = mouseX-clickX1;
  clickY2 = mouseY-clickY1;
}

void updateUIValues(){
  chartLengthX = width*(1-2*xMargin);
  chartLengthY = height*(1-2*yMargin);
  
  chartOriginX = width*xMargin;
  chartOriginY = height*yMargin;
  intervalLength = chartLengthX/(numAttributes-1);
}

void readData(){
  //read in data
  String[] lines = loadStrings(path);
  String[] firstLine = split(lines[0],",");
  
  //firstLine.length - 1 = # of attributes
  //lines.length - 1 = # of data points
  numAttributes = firstLine.length - 1;
  numItems = lines.length - 1;
  
  attributes = new String[numAttributes];
  names = new String[numItems];
  data = new float[numAttributes][numItems]; 
  maxes = new float[numAttributes];
  mins = new float[numAttributes];
  orientations = new int[numAttributes];
  
  for (int i = 0; i<numItems; i++){
    String[] row = split(lines[i+1],",");
    names[i] = row[0];
    for(int j = 0; j<numAttributes; j++){
      //THE DATA MATRIX IS TRANSPOSED!!!!!!!!!!
      data[j][i]=(int) parseFloat(row[j+1]);
    }
  }
  
  for (int i = 0; i < numAttributes; i++){
    attributes[i] = firstLine[i+1];
    maxes[i] = max(data[i]);
    mins[i] = min(data[i]);
    orientations[i] = 1;
  }   
}

void drawAxes(){
  strokeWeight(2);
  float intervalLength = chartLengthX/(numAttributes-1);
  textAlign(CENTER);
  
  for (int i = 0; i < numAttributes; i ++){
    float xCoord = chartOriginX + i *intervalLength;
    fill(100,100,100,70);
    stroke(0,0);
    rect(xCoord-5,chartOriginY,10,chartLengthY);
    stroke(0,0,0);
    line(xCoord,chartOriginY,xCoord,chartOriginY+chartLengthY);
    textSize(16);
    fill(ultraHighlight);
    text(attributes[i],xCoord,chartOriginY*.6);
    
    textSize(12);
    if(orientations[i] == 1){
      fill(c1);
      text(maxes[i],xCoord,chartOriginY*.8);
      fill(c2);
      text(mins[i],xCoord,height*.85);
    }
    else{
      fill(c1);
      text(maxes[i],xCoord,height*.85);
      fill(c2);
      text(mins[i],xCoord,chartOriginY*.8);
    }
  }
}
void drawSelectionBox(){
   for (int i = 0; i < numAttributes; i ++){
    float xCoord = chartOriginX + i *intervalLength;
    if(clickY1 > chartOriginY && clickY1 < chartOriginY + chartLengthY){
      
      //selection along data range enabled
      if(abs(clickX1-xCoord)<5){
          float drawY = clickY2;
          if(clickY1+clickY2 <=chartOriginY){
            drawY = (chartOriginY-clickY1)*1.01;
          }
          else if(clickY1+clickY2 >= chartOriginY+chartLengthY){
            drawY = (chartOriginY+chartLengthY-clickY1)*1.01;
          }
          if(abs(drawY)>1){
            colorMode = "highlight";
            highlights.clear();
            float range = maxes[i]-mins[i];
            float valTop;
            float valBottom;
            if(orientations[i] == 1){
              valTop = ((chartOriginY+chartLengthY)-min(clickY1,clickY1+drawY))/chartLengthY*range+mins[i];
              valBottom = ((chartOriginY+chartLengthY)-max(clickY1,clickY1+drawY))/chartLengthY*range+mins[i]; 
            }
            else{
              valTop = maxes[i] - ((chartOriginY+chartLengthY)-min(clickY1,clickY1+drawY))/chartLengthY*range;
              valBottom = maxes[i] - ((chartOriginY+chartLengthY)-max(clickY1,clickY1+drawY))/chartLengthY*range; 
            }
            //println(valTop);
            for(int j = 0; j <numItems; j++){
              float point = data[i][j];
              
              if(point<=max(valTop,valBottom)&&point>=min(valTop,valBottom)){
                highlights.append(j);
                
              }
            }
            stroke(0,0,0,0);
            fill(c1);
            rect(xCoord-5,clickY1,10,drawY);
            set = true;
            axisSelect = true;
          }
          else{
            colorMode = "oneForAll";
            fill(lerpColor(c1,c2,.5));
            rect(xCoord-5,chartOriginY,10,chartLengthY);
            println("-");
            set = true;
            selAttr = i;
          }
        }
        
        else if (abs(clickX1-xCoord)>5&& !axisSelect){
          //println(abs(clickX1-xCoord));
          float drawY = clickY2;
          float drawX = clickX2;
          if(clickY1+clickY2 <chartOriginY){
            drawY = chartOriginY-clickY1;
          }
          else if(clickY1+clickY2 > chartOriginY+chartLengthY){
            drawY = chartOriginY+chartLengthY-clickY1;
          }
          if(clickX1+clickX2<chartOriginX){
            drawX = chartOriginX-clickX1;
          }
          else if(clickX1+clickX2 > chartOriginX+chartLengthX){
            drawX = chartOriginX+chartLengthX-clickX1;
          }
          if(abs(drawY)>1&&abs(drawX)>1){
            colorMode = "highlight";
            highlights.clear();
            stroke(0,0,0,0);
            fill(200,200,200,80);
            highlights.clear();
            highlights = findIntersectingLines(clickX1,clickY1,drawX,drawY);
            rect(clickX1,clickY1,drawX,drawY);
            set = true;
            selectBoxActive = true;
          }
          else{
            selectBoxActive = false;
          }
          
        }
    }  
  }
  if(!set){
    colorMode = "default";
    clickY2 = 0;
  }
  
}
void drawLines(){
  //lines.beginDraw();
  //for every data point...
  for(int i = 0; i < numItems; i++){
    float prevPtX=0;
    float prevPtY=0;
    color prevColor = color(0,0,0);
    //draw lines attribute by attribute.
    for(int j = 0; j < numAttributes; j++){
      color colorTop;
      color colorBottom;
      float range = maxes[j]-mins[j];
      float point = data[j][i];
      float ratio = (point-mins[j])/range;
      float ptX = chartOriginX + j *intervalLength;;
      float ptY = getYCoord(point, j);
      color col;
      
      if(orientations[j] == 1){
        colorTop = c1;
        colorBottom = c2;
        col = lerpColor(colorBottom,colorTop,ratio);
        
      }
      else{
        colorTop = c2;
        colorBottom = c1;
        col = lerpColor(colorTop,colorBottom,ratio);
      }
      
      
      if(j!=0){
        strokeWeight(1);
        //println(colorMode);
        if(colorMode == "default"){
          axisSelect = false;
          for (int k = 0; k<11; k++){
            stroke(lerpColor(prevColor,col,1-k/10.0));
            float x = lerp(prevPtX,ptX,1-k/10.0);
            float y = lerp(prevPtY,ptY,1-k/10.0);
            line(prevPtX,prevPtY,x,y);
          }
        }
        else if (colorMode=="highlight"){
          
          if(highlights.hasValue(i)){
            if(i==superMegaUltraHighlight){
              stroke(ultraHighlight);
              line(prevPtX,prevPtY,ptX,ptY);
            }
            else{
              for (int k = 0; k<11; k++){
              stroke(lerpColor(prevColor,col,1-k/10.0));
              float x = lerp(prevPtX,ptX,1-k/10.0);
              float y = lerp(prevPtY,ptY,1-k/10.0);
              line(prevPtX,prevPtY,x,y);
            }
            }
            
            
          }
          else{
            stroke(c3);
            line(prevPtX,prevPtY,ptX,ptY);
            
          }
        }
        else if (colorMode=="oneForAll"){
          float ratioColor = (data[selAttr][i]-mins[selAttr])/(maxes[selAttr]-mins[selAttr]);
          if(orientations[selAttr] == 1){
            colorTop = c1;
            colorBottom = c2;
            col = lerpColor(colorBottom,colorTop,ratioColor);
            
          }
          else{
            colorTop = c2;
            colorBottom = c1;
            
            col = lerpColor(colorTop,colorBottom,ratioColor);
          }
          stroke(col);
          line(prevPtX,prevPtY,ptX,ptY);
        }
        //int b = (i+1)%20;
        //int g = (i+1)/20;
        //int r = (i+1)/(20*20);
        //lines.stroke(color(10*r,10*g,10*b));
        //lines.strokeWeight(3);
        //lines.line(prevPtX,prevPtY,ptX,ptY);
        
      }
      prevColor = col;
      prevPtX = ptX;
      prevPtY = ptY;
    }
  }
  //lines.endDraw();
  //image(lines,0,0);
}

float getYCoord(float pointValue, int attrInd){
  float ptY;
  float range = maxes[attrInd]-mins[attrInd];
  float ratio = (pointValue-mins[attrInd])/range;
  if(orientations[attrInd] == 1){
        ptY = chartOriginY + chartLengthY - ratio*chartLengthY;
  }
  else{
        ptY = chartOriginY + ratio*chartLengthY;
      }
  return ptY;
}

IntList findIntersectingLines(float x1, float y1, float xLength, float yLength){
  
  IntList list = new IntList();
  int a1 = (int)((x1 - chartOriginX)/intervalLength);
  int a2 = (int)((x1+xLength-chartOriginX)/intervalLength);
  int attrL1 = min(a1,a2);
  int attrL2 = max(a1,a2);
 
  println(attrL1);
  for(int j = attrL1; j<=min(attrL2,numAttributes-2);j++){
      float xMin;
      float xMax;
      if (j==attrL1){
        xMin = min(x1, x1+xLength);
      }
      else{
        xMin = chartOriginX+j*intervalLength;
      }
      if(j==attrL2){
        xMax = max(x1,x1+xLength);
      }
      else{
        xMax = chartOriginX+(j+1)*intervalLength;
      }
      for(int i = 0; i < numItems; i++){
        float xL = chartOriginX+j*intervalLength;
        float yL = getYCoord(data[j][i], j);
        float xR = chartOriginX+(j+1)*intervalLength;
        float yR = getYCoord(data[j+1][i], j+1);
        float slope = (yL-yR)/(xL-xR);
        boolean intersectL = (slope*xMin-slope*xL+yL)>min(y1,yLength+y1) && (slope*xMin-slope*xL+yL)<max(y1,yLength+y1);
        boolean intersectR = (slope*(xMax)-slope*xL+yL)>min(y1,yLength+y1) && (slope*(xMax)-slope*xL+yL)<max(y1,yLength+y1);
        boolean intersectTop = (slope*xL+y1-yL)/slope >xMin && (slope*xL+y1-yL)/slope <xMax;
        boolean intersectBottom = (slope*xL+(y1+yLength)-yL)/slope >xMin && (slope*xL+(y1+yLength)-yL)/slope < xMax;
        if(intersectL ||intersectR|| intersectTop|| intersectBottom){
          if(!list.hasValue(i)){
            list.append(i);
          }
        }
      }
    
    }
  
  println(list);
  return list;
  
}

void hoverInfo(){
  if (!axisSelect && !selectBoxActive){
    IntList list = new IntList();
    list = findIntersectingLines(mouseX-3,mouseY-3,6,6);
    println("---"+list.size());
    if(list.size()>0){
      colorMode = "highlight";
      set=true;
      highlights=list;
      int attrLeft = (int)((mouseX - chartOriginX)/intervalLength);
      int index = list.get(list.size()-1);
      
        stroke(ultraHighlight);
        superMegaUltraHighlight = index;
      String s1 = names[index];
      String s2 = attributes[attrLeft]+": "+data[attrLeft][index];
      String s3;
      if(attrLeft < numAttributes-1){
        s3 = attributes[attrLeft+1]+": "+data[attrLeft + 1][index];
      }
      else{
        s3="";
      }
      
      float boxLength = 1.1*max(textWidth(s1),textWidth(s2),textWidth(s3));
      fill(250,250,250,200);
      rect(mouseX+15,mouseY-3*textAscent(),boxLength,6*textAscent());
      textAlign(LEFT);
      fill(color(0,0,0));
      text(s1,mouseX+20,mouseY-20);
      text(s2,mouseX+20,mouseY);
      text(s3,mouseX+20,mouseY+20);
    }
    else{
      colorMode="default";
      superMegaUltraHighlight = -1;
      highlights.clear();
    }
  }
  else{
    set=false;
    IntList list = new IntList();
    list = findIntersectingLines(mouseX-3,mouseY-3,6,6);
    println("---"+list.size());
    if(list.size()>0){
      colorMode = "highlight";
      set=true;

      int attrLeft = (int)((mouseX - chartOriginX)/intervalLength);
      int index = list.get(list.size()-1);
      highlights.append(index);
        stroke(ultraHighlight);
        superMegaUltraHighlight = index;
      String s1 = names[index];
      String s2 = attributes[attrLeft]+": "+data[attrLeft][index];
      String s3;
      if(attrLeft < numAttributes-1){
        s3 = attributes[attrLeft+1]+": "+data[attrLeft + 1][index];
      }
      else{
        s3="";
      }
      
      float boxLength = 1.1*max(textWidth(s1),textWidth(s2),textWidth(s3));
      fill(250,250,250,200);
      rect(mouseX+15,mouseY-3*textAscent(),boxLength,6*textAscent());
      textAlign(LEFT);
      fill(color(0,0,0));
      text(s1,mouseX+20,mouseY-20);
      text(s2,mouseX+20,mouseY);
      text(s3,mouseX+20,mouseY+20);
    }
    else{
      superMegaUltraHighlight = -1;
    }
  }
  //color yes =lines.get(mouseX,mouseY);
  //int b = (int)blue(yes);
  //int g = ((int)green(yes));
  //int r = ((int)red(yes));
  
  //int index = b/10-1+g/10*20+r/10*(20^2);
 
  //print(r);print(".");print(g);print(".");println(b);
  //println(index);

    
      // int attrLeft = (int)((mouseX - chartOriginX)/intervalLength);
      //int index = list.get(0);
      //String s1 = names[index];
      //String s2 = attributes[attrLeft]+": "+data[attrLeft][index];
      //String s3;
      //if(attrLeft < numAttributes-1){
      //  s3 = attributes[attrLeft+1]+": "+data[attrLeft + 1][index];
      //}
      //else{
      //  s3="";
      //}
      
      //fill(240,240,240,95);
      //float boxLength = 1.1*max(textWidth(s1),textWidth(s2),textWidth(s3));
      //stroke(0,0,0,0);
      //rect(mouseX+15,mouseY-3*textAscent(),boxLength,6*textAscent());
      //textAlign(LEFT);
      //fill(color(0,0,0));
      //text(s1,mouseX+20,mouseY-20);
      //text(s2,mouseX+20,mouseY);
      //text(s3,mouseX+20,mouseY+20);
    
 
}