Analyzing circular arena videos:

ArenaInfo = ArenaSetup() ;
    Determines ArenaEdge and calculates BackgroundImage of arena separately for Cam0 and Cam1

FlySpotter.m
    Locates flies centroids and returns 
    Frame.FlySpots.Centroid

FlyCounter.m
    Counts flies in each quadrant and returns
    FlyCount(Frame,Quadrant)

PICalculator.m
    Calculates PIs based on FlyCount and returns
    PI timecourse
    half PI i.e. PI for one odor