/*MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNmmmmmNMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM/     /MMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMhy.   hMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMNNNNMMMMMMMMMMMMMMMMMMMMMMNMMMMMMMNNNNNm   -MMMMMMMMMMNNNMMMMM
MMMMMMMMMy////oNh+:..-oNN/////sMMMN+///MMMMo:/oNMMdo:-.-::   yMy////oMdo:./MMMMM
MMMMMMMMM/-`   /`-:`   od--   /MMN+    MMMs   sMN+` `:++-   .NM/-`   +``..dMMMMM
MMMMMMMMMMM-   :mMMh   :MMM.  /MMo ``  MMy  `yMm-  -dMMMs   oMMMM-   .smmmMMMMMM
MMMMMMMMMMd   -NMMMh   +MMM:  /Ms  s`  Md` `yMM/  `mMMMM-  `mMMMd   .mMMMMMMMMMM
MMMMMMMMMM/   hMMMM+   dMMM/  +h` oN   m. `hMMd   /MMMMh   /MMMM:   dMMMMMMMMMMM
MMMMMMMMMm`  .NMMMy   oMMMMo  /` oMN  .: `hMMMs   sMMMd.   dMMMd   :MMMNddNMMMMM
MMMMMMMMMo   :hdh+` `oNMMMMs    +NMm    .dMMMMs   -hho..  `yyNM/   hMMd.``.hMMMM
MMMMMMMMN`    ``  ./dMMMMMMy   +NMMd   .dMMMMMN:    `:hy.```.MN```-MMMh`  `yMMMM
MMMMMMMMs   +dhyhdmMMMMMMMMNdddNMMMNdddmMMMMMMMNdyyhmNMMNmmmmMNmmmNMMMMmhhmMMMMM
MMMMMNdd.   ydMMddddddddddddddddddddddddddddddddddddddddddddddddddddddddddNMMMMM
MMMMMy``    `.Mm``````````````````````````````````````````````````````````mMMMMM
MMMMMmdddddddmMNddddddddddddddddddddddddddddddddddddddddddddddddddddddddddMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMM                                                          MMMMMMMMMMM
MMMMMMMMMMM Software for Pwdr three-dimensional powder based printer MMMMMMMMMMM
MMMMMMMMMMM Author: Alex Budding                                     MMMMMMMMMMM
MMMMMMMMMMM E-mail: pwdr@wetterhorn.nl                               MMMMMMMMMMM
MMMMMMMMMMM                                                          MMMMMMMMMMM
MMMMMMMMMMM This software released under the GNU/GPL license         MMMMMMMMMMM 
MMMMMMMMMMM                                                          MMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/

import processing.serial.*;

PImage backgroundImage, backgroundImageMask;
PFont myFont;

// !Redundant!

int clickColorInt;
int sliceNumber = 1;

String GUIstate = "converting";


void setup(){
  size(800,600);
  // The low framerate reduce CPU load, can't be used during convertion
  frameRate(10);
  // Load the background images
  backgroundImage = loadImage("Converting.png");
  // Load the mask for click detection. 
  backgroundImageMask = loadImage("ConvertingMask.png");
  // Load font
  myFont = loadFont("OfficinaSerif.vlw");
  textFont(myFont, 19);
}

void draw(){
  background(backgroundImage);
  
  if(GUIstate == "connection"){
    // Store and count avalaible serial ports
    comList = myPort.list();
    String comlist = join(comList, ",");
    String COMlist = comList[0];
    int size2 = COMlist.length();
    int size1 = comlist.length() / size2; 
    
    for(int i=0; i< size1; i++){
      stroke(0);
      fill(#666666);
      text(i+1+" : "+comList[i], 173, 145+i*27);
      noFill();
      strokeWeight(2);
      stroke(#666666);
      rect(136, 128+27*i, 20, 20);
      if (serialSet) {
        fill(#666666);
        rect(136, 128+27*(selectPort-1), 20, 20);
      }
    }
    
    fill(#666666);
    text(serialString, 136, 500);
    
  } else if((GUIstate == "converting...") && (FileName != null) && (sliceNumber <= maxSlices)) {
    // Slice the STL file
    // Increase framerate for the slicing of the STL file
    frameRate(60);
    
     //Generate a Slice
    Line2D Intersection;
    Slice = new ArrayList();
    
    for(int i = STLFile.Triangles.size()-1;i>=0;i--){
      Triangle tri = (Triangle) STLFile.Triangles.get(i);
      Intersection = tri.GetZIntersect(MeshHeight*sliceNumber/maxSlices);
      if(Intersection!=null)Slice.add(Intersection);
    }
  
    //Draw the profile
    stroke(0);
    strokeWeight(1);
  
    for(int i = Slice.size()-1;i>=0;i--){
      Line2D lin = (Line2D) Slice.get(i);
      line(208+lin.x1,30+lin.y1,208+lin.x2,30+lin.y2);
    }    
    loadPixels();
    floodFill(new Vec2D(121,31), #000000, #FFFFFF);
    updatePixels();
    // Debug output
    //saveFrame("slices/slice-####.png");
    loadPixels();
    convertModel();
    
    if (sliceNumber == maxSlices){
        GUIstate = "converting";
        frameRate(10);
    }
  } else if(GUIstate == "printing"){
    textAlign(CENTER);
    fill(#666666);
    text(serialString, 450, 395);
    textAlign(LEFT);
  }
}
