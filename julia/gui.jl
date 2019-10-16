
# simple gui
# display and update Polar Plot

# imports
using PyPlot ;
using Interact;
using Blink;

# global variables
polarFig = nothing;
ax = nothing;
point = nothing;
label = nothing;
paused = false;

maxTheta = 60; # beamwidth/2 (degrees)

# takes theta (rad) and range (m) and returns cartesian coords (m,m)
function cartesian(theta, r)
   x = r*cos(theta);
   y = r*sin(theta);
   x = round(x;digits=3);
   y = round(y;digits=3);
   return x, y;
end

# update GUI by removing point and adding new one with new coords
function updateGUI(theta, r)
   global ax;
   global point;
   global label;
   # pos = cartesian(theta, r);
   # println(pos);
   point.remove();
   label.remove();
   pos = cartesian(theta, r);
   # point = ax[:scatter](theta,r, color="red") ; # add point
   # label = ax.annotate("  (10, 0)", [10, 0]); # add label
   labelStr = string("Cartesian: x=", string(pos[1]), " y=", string(pos[2])
      , "\nPolar: theta=", string(round(theta; digits=4)), " r=", string(round(r, digits=2)));
   point = ax[:scatter](theta,r, color="red") ; # add point
   label = ax.annotate( labelStr, xy=[0,0], xytext=[-3pi/4,10]); # add label
end

# set up plot
function setupPlot(x=0)
   global polarFig;
   global ax;
   global point;
   global label;
   polarFig = figure("Polar Plot",figsize=(20,20)) ; # Create a new figure
   ax = polarFig.add_subplot(111, polar=true) ; # create polar axis
   ax.set_rmax(10); # set max range
   ax.set_thetamin(-maxTheta); # set beamwidth min
   ax.set_thetamax(maxTheta); # set beamwidth max
   point = ax[:scatter](0,10, color="red") ; # add a point
   label = ax.annotate("  (10, 0)", [10, 0]); # add label
end

function pauseFunc(x=0)
   global paused;
   global pauseButton;
   paused = !paused;
   # println(pauseButton[:label])
   # pauseButton[:label] = "A new label"
   # print(paused);
end

function stopFunc(x=0)
   global polarFig;
   close(polarFig);
end

function loopFunc(x=0)
   for i in 0:0.1:1
      updateGUI(i,i+1);
      sleep(1);
   end
end

function singleFunc(x=0)
   global dialog;
   dialog = Text(456);
   updateGUI(2*rand() - 1, 10*abs(rand()));
end



# ------- GUI ------------
# create buttons

function setupGUI()
   startButton = button("Start");
   pauseButton = button("Pause");
   stopButton = button("Stop");
   loopButton = button("Loop");
   singleButton = button("single");

   # connect buttons to functions
   on(setupPlot, startButton);
   on(pauseFunc, pauseButton);
   on(stopFunc, stopButton);
   on(loopFunc, loopButton);
   on(singleFunc, singleButton);

   buttons = hbox(hskip(1em), startButton, hskip(1em), pauseButton, hskip(1em)
         , stopButton, hskip(1em) ,loopButton, hskip(1em), singleButton) # aligns vertically

   dialog = Text("123");

   ui = vbox(buttons, dialog);
   display(ui);

   # setup blink window
   w = Window();
   # title(w, "SONAR CONTROL");
   body!(w,ui);

   pos = cartesian(0, 10);
   println(pos);
end
