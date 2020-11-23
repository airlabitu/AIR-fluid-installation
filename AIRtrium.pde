/**
 * 
 * PixelFlow | Copyright (C) 2016 Thomas Diewald - http://thomasdiewald.com
 * 
 * A Processing/Java library for high performance GPU-Computing (GLSL).
 * MIT License: https://opensource.org/licenses/MIT
 * 
 */
 
 // Lyd library der skal bruges hedder: 


import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;
import com.thomasdiewald.pixelflow.java.fluid.DwFluidParticleSystem2D;

import controlP5.Accordion;
import controlP5.ControlP5;
import controlP5.Group;
import controlP5.RadioButton;
import controlP5.Toggle;
import processing.core.*;
import processing.opengl.PGraphics2D;


// For Minim Audio
import ddf.minim.*;
// need to import this so we can use Mixer and Mixer.Info objects
import javax.sound.sampled.*;

Minim minim;
AudioInput in;
// an array of info objects describing all of 
// the mixers the AudioSystem has. we'll use
// this to populate our gui scroll list and
// also to obtain an actual Mixer when the
// user clicks on an item in the list.
Mixer.Info[] mixerInfo;

int activeMixer = 3; // Indstiller hvilken Mikrofon der bruges. Tjek array der skrives i konsollen for hvilken mic index der skal bruges.
float leftMicrophone = 0.0;
float rightMicrophone = 0.0;
float px, py, vx, vy, radius, vscale, temperature, rightMicRadius, leftMicRadius, rightMicVx, leftMicVx, leftMicMin, leftMicMax, rightMicMin, rightMicMax, leftChannelAverage, rightChannelAverage;

      boolean rightMicVyDirection = true;
      float rightMicVy = 0;
      float leftMicVy = 0;
      float scaleFactor = 100.0;  
  
  PFont PrimeRegular96;
  //PFont PrimeRegular55;
  //PrimeRegular55 = loadFont("Prime-Regular-55.vlw");
 
  
  private class MyFluidData implements DwFluid2D.FluidData{
     
    @Override
    // this is called during the fluid-simulation update step.
    public void update(DwFluid2D fluid) {
    boolean mouse_input = !cp5.isMouseOver() && mousePressed;
      if(mouse_input ){
        
        vscale = 15; 
        px     = mouseX;
        py     = height-mouseY;
        vx     = (mouseX - pmouseX) * +vscale;
        vy     = (mouseY - pmouseY) * -vscale;
        
        if(mouseButton == LEFT){
          radius = 45; // Scale for user input, default = 20
          fluid.addVelocity(px, py, radius, vx, vy);
        }
        if(mouseButton == CENTER){
          radius = 50;
          fluid.addDensity (px, py, radius, 1, 1, 1, 1f, 1);
        }
        if(mouseButton == RIGHT){
          radius = 15;
          fluid.addTemperature(px, py, radius, 1f);
        }
      }     
      
      int yTop = height;
      int yMiddle = height/2+0;
      int yBottom = 0;
      
      int xLeft = 0;
      int xMiddle = width/2+0;
      int xRight = width;

      vscale = 15;
      
      // for Microphone controlled velocities
      rightMicRadius = 25;
      leftMicRadius = 25;

      /*println("Right Channel = " + rightChannelAverage);
      println("Left Channel = " + leftChannelAverage);
      println();*/

      rightMicVx = rightChannelAverage * 10;
      cp5.getController("rightMicVx").setValue(rightMicVx);
      
      leftMicVx = leftChannelAverage * 10;
      cp5.getController("leftMicVx").setValue(leftMicVx);
      
      /*println("right = " + rightMicVx, map(rightMicrophone, -1, 1, 0, 100));
      println("left = " + leftMicVx, map(leftMicrophone, -1, 1, 0, 100));
      println(); */
        
      temperature = 0.5f; // Temperature setting, not used.
      vscale = 15; // Velocity Scale
      
///// Right Liquid /////
      float[] rightLiquidRGB = {240f, 245f, 116f};
      
      radius = 200;
      px     = width+(radius-10); // Default = width/2-0
      py     = height/2+0; // Default = 0
      fluid.addDensity (px, py, radius+10, (1f / 255f) * 237, (1f / 255f) * 115, (1f / 255f) * 200, 0.7f, 1); // Pink
      fluid.addDensity (px, py, radius+8, 1f, 1f, 1f, 0.7f, 1); // White
      fluid.addDensity (px+4, py, radius, ((1f/255f) * rightLiquidRGB[0]), ((1f / 255f) * rightLiquidRGB[1]), ((1f / 255f) * rightLiquidRGB[2]), 1f, 0);

      //Velocities and temperatures impacting the right liquid
      fluid.addVelocity(xRight+10, yMiddle, rightMicRadius, -rightMicVx, 0); // Microphone controlled Velocity
      
      fluid.addVelocity(xRight, yMiddle, 30, -0.75, 0); // Velocity on X
      fluid.addTemperature(xRight, yMiddle-5, 1, 1); // Positive temperature
      fluid.addVelocity(xRight, yMiddle, 30, 0, 0.5); // Velocity on positive Y
      fluid.addTemperature(xRight, yMiddle+5, 1, -1); // Negative temperature
      fluid.addVelocity(xRight, yMiddle, 30, 0, -0.5); // Velocity on negative Y
      
///// Left Liquid /////
      float[] leftLiquidRGB = {240f, 245f, 110f};

      radius = 200;
      px     = -(radius-10); // Default = width/2+0
      py     = height/2+0; // Default = height
      fluid.addDensity (px, py, radius+10, (1f / 255f) * 237, (1f / 255f) * 115, (1f / 255f) * 200, 0.7f, 1); // Pink
      fluid.addDensity (px, py, radius+8, 1f, 1f, 1f, 0.7f, 1); // White
      fluid.addDensity (px-4, py, radius, ((1f/255f) * leftLiquidRGB[0]), ((1f / 255f) * leftLiquidRGB[1]), ((1f / 255f) * leftLiquidRGB[2]), 1f, 0);

      // Velocities and temperatures impacting the left liquid);
      fluid.addVelocity(xLeft-10, yMiddle, leftMicRadius, leftMicVx, 0); // Microphone controlled Velocity
      
      fluid.addVelocity(xLeft, yMiddle, 30, 0.75, 0); // Velocity on X
      fluid.addTemperature(xLeft, yMiddle-5, 1, 1); // Positive temperature
      fluid.addVelocity(xLeft, yMiddle, 30, 0, 0.5); // Velocity on positive Y
      fluid.addTemperature(xLeft, yMiddle+5, 1, -1); // Negative temperature
      fluid.addVelocity(xLeft, yMiddle, 30, 0, -0.5); // Velocity on negative Y       
      
      // Top center
      radius = 30;
      fluid.addDensity (xMiddle, yTop, radius, 20, 0, 100, 0.20f, 1);
      fluid.addTemperature(xMiddle-5,yTop+15,30,-0.15);
     
      
      // Bottom center

      radius = 30;
      fluid.addDensity (xMiddle, yBottom, radius, 20, 0, 100, 0.20f, 1);
      fluid.addTemperature(xMiddle+5,yBottom-15,30,0.15);
    }
    
  }
  
  //int viewport_w = 3840;
  //int viewport_h = 1080;
  
  //int viewport_w = 5760;
  //int viewport_h = 1080;
  
  //int viewport_w = 1280;
  //int viewport_h = 720;
  
  int viewport_w = 1920;
  int viewport_h = 400;
  
  int viewport_x = 0;
  int viewport_y = 0;
  
  int gui_w = viewport_w;
  int gui_x = viewport_w-gui_w;
  int gui_y = 0;
  
  int fluidgrid_scale = 1;
  

  DwFluid2D fluid;
  MyFluidData cb_fluid_data;
  
  // default particle system
  DwFluidParticleSystem2D particle_system;
  
  // fluid rendertarget
  PGraphics2D pg_fluid;
  
  //texture-buffer, for adding obstacles
  PGraphics2D pg_obstacles;

  // some state variables for the GUI/display
  int     BACKGROUND_COLOR           = 0;
  boolean UPDATE_FLUID               = true;
  boolean DISPLAY_FLUID_TEXTURES     = true;
  boolean DISPLAY_FLUID_VECTORS      = false;
  int     DISPLAY_fluid_texture_mode = 0;
  boolean DISPLAY_PARTICLES          = false;

  public void settings() {
    size(viewport_w, viewport_h, P2D);
    smooth(4);
  }
  

  public void setup() {
    textAlign(LEFT, TOP);
  
    minim = new Minim(this);
    
    mixerInfo = AudioSystem.getMixerInfo();  
    println(mixerInfo[3]); // use this
    for (int i = 0; i < mixerInfo.length; i++){
      println(i, mixerInfo[i]);
    }
    
    Mixer mixer = AudioSystem.getMixer(mixerInfo[activeMixer]);

    if ( in != null )  {
      in.close();
    }
    
    minim.setInputMixer(mixer);
    
    in = minim.getLineIn(Minim.STEREO);
    
    PrimeRegular96 = loadFont("Prime-Regular-96.vlw");
    textFont(PrimeRegular96);
    
    surface.setLocation(viewport_x, viewport_y);
    
    // main library context
    DwPixelFlow context = new DwPixelFlow(this);
    context.print();
    context.printGL();

    // fluid simulation
    fluid = new DwFluid2D(context, viewport_w, viewport_h, fluidgrid_scale);

    // Parameters for both fluids
    fluid.param.dissipation_density     = 0.99f;
    fluid.param.dissipation_velocity    = 1f; // Default = 0.85f;
    fluid.param.dissipation_temperature = 0.99f;
    fluid.param.vorticity               = 0.25f; // Default = 0.00f
    fluid.param.timestep                = 0.5f; // Default = 0.25f, 1 is very fast.
    fluid.param.num_jacobi_projection   = 10; // Iterations, lower performs better, higher looks better
    
    // interface for adding data to the fluid simulation
    cb_fluid_data = new MyFluidData();
    fluid.addCallback_FluiData(cb_fluid_data);

    // fluid render target
    pg_fluid = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
    pg_fluid.smooth(4);

    
    /*pg_obstacles = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
    pg_obstacles.smooth(4);
    pg_obstacles.beginDraw();
    pg_obstacles.clear();
    pg_obstacles.rectMode(CENTER);
    pg_obstacles.fill(64);
    pg_obstacles.noStroke();
    pg_obstacles.translate(width/2, height/2);
    
    pg_obstacles.ellipse(  0, -180, 80, 80);
    pg_obstacles.ellipse(-30, +200, 50, 50);
    pg_obstacles.ellipse(+30, +200, 50, 50);

    pg_obstacles.endDraw();    */
 
    // particles
    particle_system = new DwFluidParticleSystem2D();
    particle_system.resize(context, viewport_w/3, viewport_h/3);
    
    createGUI();

    background(0);
    frameRate(60);
  }
  
  
  

  public void draw() {
    
    if ( in != null)
    { 
      
      float leftBufferAverage = 0.0;
      float rightBufferAverage = 0.0;
      
      for(int i = 0; i < in.bufferSize() - 1; i++)
      {
        
        /*if (in.left.get(i+1)*50 < 0 || in.right.get(i+1)*50 < 0){
          //println("Boy, it sure is quiet here");
          leftMicrophone = 0.0;
          rightMicrophone = 0.0;
        }
        else{
          leftMicrophone = in.left.get(i+1)*50;
          rightMicrophone = in.right.get(i)*50;
        }*/
        
        leftMicrophone = in.left.get(i+1);
        rightMicrophone = in.right.get(i);
        
        if (leftMicrophone > 0) leftBufferAverage += leftMicrophone*scaleFactor;
        if (rightMicrophone > 0) rightBufferAverage += rightMicrophone*scaleFactor;
        
        if (leftMicrophone < leftMicMin)leftMicMin=leftMicrophone;
        if (leftMicrophone > leftMicMax)leftMicMax=leftMicrophone;
        if (rightMicrophone < rightMicMin)rightMicMin=rightMicrophone;
        if (rightMicrophone > rightMicMax)rightMicMax=rightMicrophone;
        
        /*println("left min = " + leftMicMin);
        println("right min = " + rightMicMin);
        
        println("left max = " + leftMicMax);
        println("right max = " + rightMicMax);
        println();*/
        /*println("Left input says: " + leftMicrophone);
        println("Right input says: " + rightMicrophone);*/
      }
      
      //println(leftBufferAverage/in.bufferSize());
      //println(rightBufferAverage/in.bufferSize());
      
      leftChannelAverage = leftBufferAverage/in.bufferSize();
      rightChannelAverage = rightBufferAverage/in.bufferSize();
    }
    
    if(UPDATE_FLUID){
      //fluid.addObstacles(pg_obstacles);
      fluid.update();
      particle_system.update(fluid);
    }

    pg_fluid.beginDraw();
    //pg_fluid.background(BACKGROUND_COLOR); // Original background color
    pg_fluid.background(237,115,200); // AIRLab Pink background
    //pg_fluid.background(0,0,0); // AIRLab Sort background
    pg_fluid.endDraw();
    
    if(DISPLAY_FLUID_TEXTURES){
      fluid.renderFluidTextures(pg_fluid, DISPLAY_fluid_texture_mode);
    }
    
    if(DISPLAY_FLUID_VECTORS){
      fluid.renderFluidVectors(pg_fluid, 10);
    }
    
    if(DISPLAY_PARTICLES){
      particle_system.render(pg_fluid, null, 0);
    }
    
    // display
    image(pg_fluid    , 0, 0);
    
    fill(237,115,200);
    textSize(64);
    textAlign(CENTER);
    text("AIR LAB", width/2-0, height/2-0);
    
    
    //textFont(PrimeRegular55);
    fill(237,115,200);
    textSize(50);
    textAlign(CENTER);
    text("Affective Interactions & Relations", width/2-0, height/2+70);
    
    // Lower right corner   
    //fluid.addTemperature(width, 0, 50, 1f);
    
    // Upper left corner
    //fluid.addVelocity(0, height, 50, 25, -25);
    //fluid.addDensity (0, height, 50, 237, 0, 115, 0.25f, 0);
    
    //image(pg_obstacles, 0, 0);
    
    // info
    String txt_fps = String.format(getClass().getName()+ "   [size %d/%d]   [frame %d]   [fps %6.2f]", fluid.fluid_w, fluid.fluid_h, fluid.simulation_step, frameRate);
    surface.setTitle(txt_fps);
    
  }
  
  public void fluid_resizeUp(){
    fluid.resize(width, height, fluidgrid_scale = max(1, --fluidgrid_scale));
  }
  public void fluid_resizeDown(){
    fluid.resize(width, height, ++fluidgrid_scale);
  }
  public void fluid_reset(){
    fluid.reset();
  }
  public void fluid_togglePause(){
    UPDATE_FLUID = !UPDATE_FLUID;
  }
  public void fluid_displayMode(int val){
    DISPLAY_fluid_texture_mode = val;
    DISPLAY_FLUID_TEXTURES = DISPLAY_fluid_texture_mode != -1;
  }
  public void fluid_displayVelocityVectors(int val){
    DISPLAY_FLUID_VECTORS = val != -1;
  }

  public void fluid_displayParticles(int val){
    DISPLAY_PARTICLES = val != -1;
  }


  public void keyReleased(){
    if(key == 'p') fluid_togglePause(); // pause / unpause simulation
    if(key == '+') fluid_resizeUp();    // increase fluid-grid resolution
    if(key == '-') fluid_resizeDown();  // decrease fluid-grid resolution
    if(key == 'r') fluid_reset();       // restart simulation
    
    if(key == '1') DISPLAY_fluid_texture_mode = 0; // density
    if(key == '2') DISPLAY_fluid_texture_mode = 1; // temperature
    if(key == '3') DISPLAY_fluid_texture_mode = 2; // pressure
    if(key == '4') DISPLAY_fluid_texture_mode = 3; // velocity
    
    if(key == 'q') DISPLAY_FLUID_TEXTURES = !DISPLAY_FLUID_TEXTURES;
    if(key == 'w') DISPLAY_FLUID_VECTORS  = !DISPLAY_FLUID_VECTORS;
    
    if(key == '0'){
      leftMicMax = 0;
      leftMicMin = 0;
      rightMicMax = 0;
      rightMicMin = 0;
    }
  }
 
  
  
  ControlP5 cp5;
  
  public void createGUI(){
    cp5 = new ControlP5(this);
    
    int sx, sy, px, py, oy;
    
    sx = 100; sy = 14; oy = (int)(sy*1.5f);
    

    ////////////////////////////////////////////////////////////////////////////
    // GUI - FLUID
    ////////////////////////////////////////////////////////////////////////////
    Group group_fluid = cp5.addGroup("fluid");
    {  
      group_fluid.setHeight(20).setSize(gui_w, 150)
      .setBackgroundColor(color(16, 180)).setColorBackground(color(16, 180));
      group_fluid.getCaptionLabel().align(CENTER, CENTER);
      
      px = 10; py = 15;
      
      cp5.addButton("reset").setGroup(group_fluid).plugTo(this, "fluid_reset"     ).setSize(80, 18).setPosition(px    , py);
      cp5.addButton("+"    ).setGroup(group_fluid).plugTo(this, "fluid_resizeUp"  ).setSize(39, 18).setPosition(px+=82, py);
      cp5.addButton("-"    ).setGroup(group_fluid).plugTo(this, "fluid_resizeDown").setSize(39, 18).setPosition(px+=41, py);
      
      px = 10;
     
      cp5.addSlider("velocity").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py+=(int)(oy*1.5f))
          .setRange(0, 1).setValue(fluid.param.dissipation_velocity).plugTo(fluid.param, "dissipation_velocity");
      
      cp5.addSlider("density").setGroup(group_fluid).setSize(sx, sy).setPosition(px + 150, py)
          .setRange(0, 1).setValue(fluid.param.dissipation_density).plugTo(fluid.param, "dissipation_density");
      
      cp5.addSlider("temperature").setGroup(group_fluid).setSize(sx, sy).setPosition(px + 300, py)
          .setRange(0, 1).setValue(fluid.param.dissipation_temperature).plugTo(fluid.param, "dissipation_temperature");
      
      cp5.addSlider("vorticity").setGroup(group_fluid).setSize(sx, sy).setPosition(px + 500, py)
          .setRange(0, 1).setValue(fluid.param.vorticity).plugTo(fluid.param, "vorticity");
          
      cp5.addSlider("iterations").setGroup(group_fluid).setSize(sx, sy).setPosition(px + 700, py)
          .setRange(0, 80).setValue(fluid.param.num_jacobi_projection).plugTo(fluid.param, "num_jacobi_projection");
            
      cp5.addSlider("timestep").setGroup(group_fluid).setSize(sx, sy).setPosition(px + 900, py)
          .setRange(0, 1).setValue(fluid.param.timestep).plugTo(fluid.param, "timestep");
          
      cp5.addSlider("gridscale").setGroup(group_fluid).setSize(sx, sy).setPosition(px + 1100, py)
          .setRange(0, 50).setValue(fluid.param.gridscale).plugTo(fluid.param, "gridscale");
      
      RadioButton rb_setFluid_DisplayMode = cp5.addRadio("fluid_displayMode").setGroup(group_fluid).setSize(80,18).setPosition(px, py+=(int)(oy*1.5f))
          .setSpacingColumn(2).setSpacingRow(2).setItemsPerRow(2)
          .addItem("Density"    ,0)
          .addItem("Temperature",1)
          .addItem("Pressure"   ,2)
          .addItem("Velocity"   ,3)
          .activate(DISPLAY_fluid_texture_mode);
      for(Toggle toggle : rb_setFluid_DisplayMode.getItems()) toggle.getCaptionLabel().alignX(CENTER);
      
      cp5.addRadio("fluid_displayVelocityVectors").setGroup(group_fluid).setSize(18,18).setPosition(px+150, py)
          .setSpacingColumn(2).setSpacingRow(2).setItemsPerRow(1)
          .addItem("Velocity Vectors", 0)
          .activate(DISPLAY_FLUID_VECTORS ? 0 : 2);
          
      cp5.addSlider("rightMicVx").setGroup(group_fluid).setSize(sx, sy).setPosition(width, py+50).setRange(0,1000);
      cp5.addSlider("leftMicVx").setGroup(group_fluid).setSize(sx, sy).setPosition(0, py+50).setRange(0,1000);
    }
    
    
    ////////////////////////////////////////////////////////////////////////////
    // GUI - DISPLAY
    ////////////////////////////////////////////////////////////////////////////
    /*
    Group group_display = cp5.addGroup("display");
    {
      group_display.setHeight(20).setSize(gui_w, 50)
      .setBackgroundColor(color(16, 180)).setColorBackground(color(16, 180));
      group_display.getCaptionLabel().align(CENTER, CENTER);
      
      px = 10; py = 15;
      
      cp5.addSlider("BACKGROUND").setGroup(group_display).setSize(sx,sy).setPosition(px, py)
          .setRange(0, 255).setValue(BACKGROUND_COLOR).plugTo(this, "BACKGROUND_COLOR");
      
      cp5.addRadio("fluid_displayParticles").setGroup(group_display).setSize(18,18).setPosition(px, py+=(int)(oy*1.5f))
          .setSpacingColumn(2).setSpacingRow(2).setItemsPerRow(1)
          .addItem("display particles", 0)
          .activate(DISPLAY_PARTICLES ? 0 : 2);
    }
    */
    
    
    ////////////////////////////////////////////////////////////////////////////
    // GUI - ACCORDION
    ////////////////////////////////////////////////////////////////////////////
    
    cp5.addAccordion("acc").setPosition(gui_x, gui_y).setWidth(gui_w).setSize(gui_w, height)
      .setCollapseMode(Accordion.MULTI)
      .addItem(group_fluid)
      //.addItem(group_display)
      .open(0, 1);
  }
  
