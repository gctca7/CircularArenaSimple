function FlySpots  = MarkFlies(image, BackgroundImage, ArenaEdge, MinObjectArea)
% Image processing on in dividual ufmf frames to identify fly locations.
% Inputs:
% image               Frame from a ufmf movie
% BackgroundImage     Calculated by averaging frames in ArenaEdgesnBackground.m 
% ArenaEdge           Circular border identified in ArenaEdgesnBackground.m
% 
% Subtracts BackgroundImage from current frame
% Masks out everything beyond ArenaEdge
% Thresholds with global value
% Binarizes & tosses binary objects smaller than MinObjectArea
% 
% Returns FlySpots structure with the fields
% .Centroid         Fly centroids
% .EquivDiameter    Diameter of a circle with the same area as the region
% .FilledImage      Image the same size as the bounding box of the region

% NOTES:
% You will probably still have fly shadows in the BackgroundImage

% Invert image so flies are bright
image = imcomplement(image) ; 
% Subtract background image (flies need to be bright there too)
% >>NB You can probably still see fly shadows in the BackgroundImage<<
BackgroundImage = imcomplement(BackgroundImage) ; 
image = image - BackgroundImage ; 
% Mask out everything outside Arena Border
% image(ArenaEdge == 0) = 0 ;
image(~ArenaEdge) = 0 ; 
% Threshold the image based on global image pixel values.  
% NB Worked better than adaptive thresholding with a uniform image & high contrast flies 
Threshold = graythresh(image) ;
BinaryImage = imbinarize (image, Threshold) ; 
% Remove any small objects from the binary image
BinaryImage = bwareaopen(BinaryImage, MinObjectArea);
% Metrics of detected objects i.e. (ideally) individual flies
FlySpots = regionprops(BinaryImage,'Centroid','EquivDiameter','FilledImage');

