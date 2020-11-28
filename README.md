# CircularArenaSimple
 Analyze data from Yoshi Aso's circular arena - count flies in quadrants and return their x-y positions

ArenaInfo = ArenaSetup() ;
    Determines ArenaEdge and calculates BackgroundImage of arena separately for Cam0 and Cam1

FlySpotter.m
    Locates flies centroids and returns. 
		Frame.FlySpots.Centroid

FlyCounter.m
    Counts flies in each quadrant and returns  
		FlyCount(Frame,Quadrant)

PICalculator.m
    Calculates PIs based on FlyCount and returns  
		i) PI timecourse  
		ii) half PI i.e. PI for one odor