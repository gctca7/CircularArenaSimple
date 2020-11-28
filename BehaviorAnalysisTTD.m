BehaviorAnalysisTTD

Instead of analyzed.txt make an analyzed folder and search for it.  Give user the option to skip or to overwrite
X Pass FrameRate to FlySpotter
X PassBackgroundImage and ArenaEdge to FlySpotter
Regularize all terms across functions
X Would masking be faster as a matrix operation?

X Interactively place the arena border
X Adjust so it matches ArenaX CamX
X Test how accurate FlySpotter is by plotting 6 or 8 random frames (not binarized!) with centroid markers
Test how much faster FlySpotter is if you just collect Centroids (and if you do it NOT in a structure)

X Have a QC where you plot Flyspots for the frames with lower number total flies
X Also plot the circle used for Arena and quadrant markers.

X What information do you want to pass from ArenaEdgesnBackground
    X Should rename function as CirclePrep.m or ArenaSetup (what did Yichun do?)
        X video header info (incl timestamps)
        X Arena & Camera
        X BackgroundImage & ArenaEdge
        
What is best directory arrangement for analyzed flies?
    Do you want to use the analyzed.txt tag or is it annoying to have to delete when you reanalyze?
Check if subpixel resolution is working with inpolygon using a test fly centroid with fractional location
X Change Start Stop to Dur = [t1 t2] & Dur(1) for start Dur(2) for stop 
Find pretty way of plotting halfPI and PI and FlyCount Timecourse (thicken line for PI count - patch for odor)
Finish PICalcaultor with plotting of reciprocal PIs.
X Plot quadrants on the arena as part of ArenaSetup

Save PI vs time plots so you don't have to crop them.