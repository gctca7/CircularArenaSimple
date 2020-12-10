% Splits the arena into 4 quadrants and counts number FlySpots in each
% Inputs:
% ArenaInformation      From ArenaSetup - located in Daily Experiment
%                       Folder
% ExptName              From spreadsheet user selects

% Load ArenaInformation
startingFolder = '/Users/glennturner/Data/DataKarenHibbard/Behavior_Raw' ;
% User selects daily experiment folder
DataDayDir = uigetdir(startingFolder,'Select Folder with ArenaInformation');
cd (DataDayDir)
load ('ArenaInformation.mat')

% Change directory to folder containing experiment lists
% (or just start on Desktop)
cd('/Users/glennturner/Dropbox (HHMI)/Data/BehaviorDataKarenHibbard/Behavior_DataLists')
% User selects spreadsheet containing experiment names
[FileName, PathName] = uigetfile('*', 'Select spreadsheet containing experiment names', 'off') ;
% Return cell array where each cell contains full directory path to folders containing flycounts
[~, ExptName, ~] = xlsread([PathName, FileName]);

for ExptIdx = 1:length(ExptName)
    cd (ExptName{ExptIdx})
    load FlySpots.mat
    
    % Determine Camera used & load appropriate ArenaEdge and BackgroundImage
    Cam0 = strfind(ExptName,'Cam0');
    if ~isempty(Cam0)
        ArenaCenter = ArenaInfo(1).ArenaCenter ;
    else
        Cam1 = strfind(ExptName,'Cam1');
        if ~isempty(Cam1)
            ArenaCenter = ArenaInfo(2).ArenaCenter ;
        end
    end
    
    % Pre-Allocate matrix that will be saved below in FlyCounts.mat
    FlyCount = zeros(length(Frame),4) ;
    
    % Define relevant points for quadrants
    FS = size(ArenaInfo(1).BackgroundImage) ; % Note odd indexing where X comes second
    EX = FS(2) ;
    EY = FS(1) ;
    CX = ArenaCenter(1) ;
    CY = ArenaCenter(2) ;
       
    % Quad1: Upper Left
    X_Quad1 = [1 CX CX 1] ;
    Y_Quad1 = [1 1 CY CY] ;
    % Quad2: Upper Right
    X_Quad2 = [CX EX EX CX] ;
    Y_Quad2 = [1 1 CY CY] ;
    % Quad3: Bottom Right
    X_Quad3 = [CX EX EX CX] ;
    Y_Quad3 = [CY CY EY EY] ;
    % Quad4: Bottom Left
    X_Quad4 = [1 CX CX 1] ;
    Y_Quad4 = [CY CY EY EY] ;
    
    for FrameIdx = 1:length(Frame)
        z = cat(1,Frame(FrameIdx).FlySpots.Centroid) ;
        X_Locs = z(:,1) ;
        Y_Locs = z(:,2) ;
        
        inQuad1 = inpolygon (X_Locs,Y_Locs,X_Quad1,Y_Quad1) ;
        inQuad2 = inpolygon (X_Locs,Y_Locs,X_Quad2,Y_Quad2) ;
        inQuad3 = inpolygon (X_Locs,Y_Locs,X_Quad3,Y_Quad3) ;
        inQuad4 = inpolygon (X_Locs,Y_Locs,X_Quad4,Y_Quad4) ;
        
        FlyCount(FrameIdx,1) = numel(X_Locs(inQuad1)) ;
        FlyCount(FrameIdx,2) = numel(X_Locs(inQuad2)) ;
        FlyCount(FrameIdx,3) = numel(X_Locs(inQuad3)) ;
        FlyCount(FrameIdx,4) = numel(X_Locs(inQuad4)) ;
    end
    
    save FlyCounts.mat FlyCount
    disp(['Quadants counted expt ' num2str(ExptIdx) ' of ' num2str(length(ExptName))])
    
    % CD back up one level
    cd ..
end