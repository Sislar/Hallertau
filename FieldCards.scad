// Roundness
$fn = 20;

// Render
Objects = "Box"; //  [Both, Box, Lid]

// Width of a single card + buffer
CardWidth = 70;    

// Height of a single card (exact)
CardHeight = 44;  

// Box Height  (Total = height card + gWT (bottom) + 2.2 lid + buffer)
BoxHeight = 50; 

// Size of each Card slot
Slots = [15,15,15,15];

// Number of rows of cards
Rows = 1;

// Slant the front of the box 
SlantFront = true;

// Labels for each card slot  (only recommended when Rows=1)
Labels = ["", "Markets", "",""];

// Size of botton cutout, % of width
Removal = 0.5;
AccessDepth = 0.3;

// Wall Thickness
gWT = 1.6;

// Tolerance
gTol = 0.3;
// Type of lid pattern
gPattern = "Leaf"; //  [Hex, Diamond, Web, Solid, Fancy]

// Box Height
LidH = 2.2;
RailThick = 1.4;
RailWidth = LidH + RailThick;

function SumList(list, start, end) = (start == end) ? list[start] : list[start] + SumList(list, start+1, end);

Angle = (((BoxHeight-gWT)/CardHeight) < 1) ? acos((BoxHeight-gWT)/CardHeight) : 0;
  
//Wall space for tilted wall
gWS =  gWT / cos(Angle);
// BoxWidth = CardWidth + 2*gWT;  obsolete

SlotsAdj = [for (i = [0:len(Slots)-1]) Slots[i]/cos(Angle)];
BoxLength = SumList(SlotsAdj,0,len(SlotsAdj)-1) + 2 *(len(Slots)+1);
RailPlace = [for (i = [0:len(Slots)-1]) -BoxLength/2 + SumList(SlotsAdj,0,i)+ (i+1)*2 ];

TotalX = BoxLength;
TotalY = CardWidth + 2*RailWidth;
TotalZ = BoxHeight;

// Height not counting the lid
AdjBoxHeight = TotalZ - LidH;

// final diminsions 
echo(TotalX,TotalY,TotalZ, Angle, RailPlace);

module RCube(x,y,z,ipR=4) {
    translate([-x/2,-y/2,0]) hull(){
      translate([ipR,ipR,ipR]) sphere(ipR);
      translate([x-ipR,ipR,ipR]) sphere(ipR);
      translate([ipR,y-ipR,ipR]) sphere(ipR);
      translate([x-ipR,y-ipR,ipR]) sphere(ipR);
      translate([ipR,ipR,z-ipR]) sphere(ipR);
      translate([x-ipR,ipR,z-ipR]) sphere(ipR);
      translate([ipR,y-ipR,z-ipR]) sphere(ipR);
      translate([x-ipR,y-ipR,z-ipR]) sphere(ipR);
      }  
} 

module football() {
    scale([0.7,0.7])
    intersection(){
        translate([-4,0]) circle(6);
        translate([4,0]) circle(6);
    }
}

module leaf_lattice(ipX, ipY, DSize, WSize)  {
    lXOffset = 4;
    lYOffset = 22;

	difference()  {
		square([ipX, ipY]);
		for (x=[0:lXOffset:ipX]) {
            for (y=[0:lYOffset:ipY+lYOffset]){
  			   translate([x, y+(1/8*lYOffset)+0.5]) rotate([0,0,-45]) football();
			   translate([x, y+(3/8*lYOffset)]) rotate([0,0,45]) football();
  			   translate([x, y-(1/8*lYOffset)-0.5]) rotate([0,0,-45]) football();
			   translate([x, y-(3/8*lYOffset)]) rotate([0,0,45]) football();		}
        }  
	}
}


module lid(ipPattern = "Hex", ipTol = 0.3){
  lAdjX = TotalX;  // remove 1mm for the backstop
  lAdjY = TotalY-RailWidth*2-ipTol*2;  
  lAdjZ = LidH;
  CutX = lAdjX - 8;
  CutY = lAdjY - 8;
  lFingerX = 15;
  lFingerY = 16;  

  // main square with center removed for a pattern. 0.01 addition is a kludge to avoid a 2d surface remainging when substracting the lid from the box.
  difference() {
      translate([0,0,lAdjZ/2]) cube([lAdjX+0.01, lAdjY+0.01 , lAdjZ], center=true);

      translate([0,0,lAdjZ/2]) cube([CutX, CutY, lAdjZ], center = true);

      // remove 1mm for backdrop
//      translate([TotalX/2-1/2,0,LidH/2])cube([1.01,TotalY-RailWidth,LidH],center=true);

     // make a slot for the latch can flex         
     translate([TotalX/2,TotalY/2-RailWidth-1.4,-1]) RCube(18,0.8,4,0.4);
     translate([TotalX/2,-TotalY/2+RailWidth+1.4,-1]) RCube(18,0.8,4,0.4);
  }
  
  // The Side triangles
  difference() {
    intersection () {
      union () {
          translate([-lAdjX/2,-lAdjY/2-LidH,LidH]) rotate([0,90,0]) linear_extrude(TotalX-2) polygon([[LidH,0],[LidH,LidH],[0,LidH]], paths=[[0,1,2]]);
          translate([-lAdjX/2,lAdjY/2,LidH]) rotate([0,90,0]) linear_extrude(TotalX-2) polygon([[0,0],[LidH,0],[LidH,LidH]], paths=[[0,1,2]]);
      }
      
      // check if this is real lid (ipTol>0) or negative lid (iptol = 0)
      // if real lid remove center for pattern and remove latches
      if (ipTol>0) 
         {cube([lAdjX, lAdjY + 2*LidH-0.2, lAdjZ*2], center=true);}
    }
       
    if (ipTol>0)
    {
        // cut out slots for the latch  7mm in instead of 8 due to backstop   
        translate([TotalX/2-7,lAdjY/2+RailWidth/2+ipTol,LidH/2]) scale([1.5,1,1]) rotate([0,0,45]) cube ([2+ipTol,2+ipTol,LidH+1],center=true);
          
        translate([TotalX/2-7,-lAdjY/2-RailWidth/2-ipTol,LidH/2]) scale([1.5,1,1]) rotate([0,0,45]) cube ([2+ipTol,2+ipTol,LidH+1],center=true);
  
        // trip the rail to ease going past the nub
        translate([TotalX/2,TotalY/2-LidH/2-ipTol,0]) cube([12,LidH,LidH*2],center=true); 
        translate([TotalX/2,-TotalY/2+LidH/2+ipTol,0]) cube([12,LidH,LidH*2],center=true); 
    }
    
  }
 
  // Finger slot
  difference () {
      translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
      translate([-CutX/2+lFingerX/2,0,20+LidH/2])sphere(20);     
  }

  // Solid top
  if (ipPattern == "Solid") 
      {   
       difference (){ 
         translate([-CutX/2,-CutY/2,0]) cube([CutX, CutY,   lAdjZ]);
         translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
      }
    }
    
  // Leaf top
  if (ipPattern == "Leaf") 
    {   
       difference (){ 
         translate([-CutX/2,-CutY/2,0]) linear_extrude(height = lAdjZ) leaf_lattice(CutX,CutY,4,2);
         translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
      }
    }

}


//  Main Box
module Box() {
   intersection() 
   {
     RCube(TotalX,TotalY,TotalZ,1);
       
     difference() // Box + dividers - access - weight reduction
     {  
        union() // Box with Dividers
        { 
            // add backstop
            translate([TotalX/2-1/2,0,TotalZ-LidH/2])cube([1,TotalY-RailWidth,2*LidH],center=true);
            
           difference() // Box shell with names on outside
           {    
              translate ([0,0,AdjBoxHeight/2]) cube([TotalX,TotalY,AdjBoxHeight], center = true);
                   
              // Hollow out the box  
              translate([0,0,BoxHeight/2+gWT]) cube([TotalX,TotalY-2*RailWidth,BoxHeight], center=true);
                   
              translate([-16,-TotalY/2+0.4,TotalZ/2]) rotate([90,0,0]) linear_extrude(0.4) text("Farmyard", size = 8, spacing = 0.9, direction = "ltr",  font="Helvetica:style=Bold");
              rotate([0,0,180]) translate([-16,-TotalY/2+0.4,TotalZ/2]) rotate([90,0,0]) linear_extrude(0.4) text("Farmyard", size = 8, spacing = 0.9, direction = "ltr",  font="Helvetica:style=Bold");
               
           }  // shell of box
              
           // add the dividers  
           translate([-TotalX/2+1,0,gWT+CardHeight/2]) cube([2, CardWidth, AdjBoxHeight],center=true);
           for(x=[0:len(Slots)-1]) {  
              translate([RailPlace[x]+1,0,gWT+CardHeight/2]) cube([2, CardWidth, AdjBoxHeight],center=true);
           }
               
        } // End the union after here is substraction
              
        // create gap at top to access the cards
        AccessWidth = CardWidth * 0.4;
        hull(){
            translate([0,-AccessWidth/2+6,BoxHeight+10]) rotate([0,90,0])cylinder(r=6,h=TotalX,center=true);;
            translate([0,AccessWidth/2-6,BoxHeight+10]) rotate([0,90,0])cylinder(r=6,h=TotalX,center=true);;
            translate([0,-AccessWidth/2+6,BoxHeight*(1-AccessDepth)])rotate([0,90,0])cylinder(r=6,h=TotalX,center=true);;
            translate([0,AccessWidth/2-6,BoxHeight*(1-AccessDepth)])rotate([0,90,0])cylinder(r=6,h=TotalX,center=true);;
        } // hull
         
            translate([0,-AccessWidth/2-6,BoxHeight-6])difference(){
               cube([TotalX,12,12], center = true);
               rotate([0,90,0])cylinder(r=6,h=TotalX,center=true);
                translate([0,-6,0])cube([TotalX,12,12], center = true);
                translate([0,0,-6])cube([TotalX,12,12], center = true);
            }
           translate([0,+AccessWidth/2+6,BoxHeight-6]) difference(){
               cube([TotalX,12,12], center = true);
               rotate([0,90,0])cylinder(r=6,h=TotalX,center=true);
                translate([0,6,0])cube([TotalX,12,12], center = true);
                translate([0,0,-6])cube([TotalX,12,12], center = true);
            }

        // Remove some from the bottem to reduce plastic
        hull() {
            translate([TotalX/2-(TotalY*Removal/2)-15,0,0]) sphere(r=(TotalY*Removal)/2);
            translate([-TotalX/2+(TotalY*Removal/2)+15,0,0]) sphere (r=(TotalY*Removal)/2);
        }
           
      } // end diff
   }  // Instersection
   
  // top rails
  difference() {
      union() {
          translate([0,-TotalY/2+RailWidth/2,AdjBoxHeight+LidH/2]) cube([TotalX,RailWidth,LidH],center = true);  
          translate([0,TotalY/2-RailWidth/2,AdjBoxHeight+LidH/2]) cube([TotalX,RailWidth,LidH],center = true);
           }
       
      // Trim each rail top to a 45 degree angle     
      translate([0,-TotalY/2,AdjBoxHeight+RailWidth]) rotate([45,0,0]) cube([TotalX,RailWidth+0.7,RailWidth+0.7], center=true); 
      translate([0,TotalY/2,AdjBoxHeight+RailWidth])  rotate([45,0,0]) cube([TotalX,RailWidth+0.7,RailWidth+0.7], center=true);  

      // Substract the lid from the rails
      translate([0,0,AdjBoxHeight]) lid(ipPattern = "Solid",ipTol =0);      
  }  
    
  // create the latches 
    translate([TotalX/2-8,TotalY/2-0.1-RailWidth/2,TotalZ-LidH/2]) scale([1.5,1,1]) difference(){
      rotate([0,0,45]) cube ([2,2,LidH+1],center=true);
      translate([0,2,0]) cube ([4,4,LidH+2],center=true);
      translate([0,-2,0])cube([2,2,LidH+2], center=true);
      }  
    translate([TotalX/2-8,-TotalY/2+0.1+RailWidth/2,TotalZ-LidH/2]) scale([1.5,1,1]) difference(){
      rotate([0,0,45]) cube ([2,2,LidH+1],center=true);
      translate([0,-2,0]) cube ([4,4,LidH+2],center=true);
      translate([0,2,0])cube([2,2,LidH+2], center=true);
    }
}




// Production Box
if ((Objects == "Both") || (Objects == "Box")){
   intersection() 
   {
     RCube(TotalX,TotalY,TotalZ,1);
     Box();
   }
}

// translate([0,0,TotalZ+2]) lid(ipPattern = gPattern, ipTol = gTol);


// Production Lid
if ((Objects == "Both")  || (Objects == "Lid")){
  intersection() {
      translate([-TotalX/2,0,0]) lid(ipPattern = gPattern, ipTol = gTol);
      translate([-TotalX/2-0.5,0,LidH/2]) cube([TotalX-1,TotalY,LidH],center=true);
  }
}




