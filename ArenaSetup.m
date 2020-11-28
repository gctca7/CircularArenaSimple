function ArenaInfo = ArenaSetup() ;
% Calculate a BackgroundImage and Identify ArenaEdges for fly detection
% Returns a structure ArenaInfo for each Cam with fields
% .Camera           Cam0 or Cam1
% .BackgroundImage  From averaging over many frames of the movie (frames chosen randomly).
%                   Subtract from each movie frame to remove stationary objects
%                   otherwise mistaken for flies
%                   NOTE Even averaging 15sec of frames I still see fly shadows in the BackgroundImage
% .ArenaEdge        Use to create a mask on the arena border

% IMPROVEMENTS
% Draw a spot in the center of the ArenaEdges circle to make sure it's in the center of the arena
% Save this info as a structure in the Raw Data folder from that day
% It may be quicker to simply average the entire movie with appropriate ufmf script

%% CD into folder from first experiment of the day

startingFolder = '/Users/glennturner/Data/DataKarenHibbard/Behavior_Raw' ;
% User selects daily experiment folder
DataDayDir = uigetdir(startingFolder);
cd (DataDayDir)
% List all files and folders in this folder
% ufmf videos are stored in folders with 'Cam' in the name
files = dir('*Cam*') ;
% Get a logical vector that tells which is a directory
dirFlags = [files.isdir] ;
% Extract only those that are directories.
subFolders = files(dirFlags) ;

% Determine which subFolders correspond to Cam0 & Cam1
IdxHolder = zeros(length(subFolders),1) ;
for i = 1:length(subFolders)
    Expt = subFolders(i).name ;
    Cam1Folder = strfind(Expt,'Cam1') ;
    if ~isempty (Cam1Folder)
        IdxHolder(i) = 1 ;
    end
end
Cam0SubFolder = find(IdxHolder==0) ;
Cam1SubFolder = find(IdxHolder) ;

%% Calculate Background image
for i = 1:2
    ExptName = subFolders(i).name ;
    ArenaInfo(i).ExptPathName = ExptName ;
    
    % Determine camera number - need for assigning Odors to Quadrants
    Cam0 = strfind(ExptName,'Cam0');
    if ~isempty(Cam0)
        ArenaInfo(i).Camera = 'Cam0' ;
    else
        Cam1 = strfind(ExptName,'Cam1');
        if ~isempty(Cam1)
            ArenaInfo(i).Camera = 'Cam1' ;
        end
    end
    
    cd(ExptName)
    video = dir('movie_Test*.ufmf') ;
    Header = ufmf_read_header(video(1).name) ;
    ArenaInfo(i).Header = Header ;
    
    FrameRate = round(1/mean(diff(Header.timestamps))) ;
    FrameSize = [Header.max_width Header.max_height] ;
    TotalFrames = Header.nframes - rem(Header.nframes, FrameRate); % Round the number of frames to the nearest second
    
    % Choose a random chunk of 15s worth of frames frames to average for Background
    BackgroundFrames = randi([1 TotalFrames],15*FrameRate,1) ;
    % Initialize the BackgroundImage x-y-t using x-y from FirstFrame
    BackgroundStack = NaN(FrameSize(1),FrameSize(2),length(BackgroundFrames)) ;
    tic
    % Construct the full BackgroundImage x-y-t
    for FrameIdx = 1:length(BackgroundFrames)
        tmp = ufmf_read_frame(Header, FrameIdx) ;
        BackgroundStack(:,:,FrameIdx) = tmp ;
    end
    toc
    BackgroundImage = mean(BackgroundStack,3) ;
    BackgroundImage = uint8(BackgroundImage) ;
    ArenaInfo(i).BackgroundImage = BackgroundImage ;
    toc
    % CD back up because of the abbreviated way directory is specified above
    cd ..
end


%% Demarcate the arena borders with a circular ROI & Draw Quadrants
% Manually position the ROI and then double click to store location etc.
for i = 1:2
    ArenaInfo(i).Camera ;
    BI = ArenaInfo(i).BackgroundImage ;

    figure;
    imshow(BI) ; hold on ;
    h = drawcircle('Center',[639.7627, 508.5204],'Radius',445.1274,'StripeColor','red') ;
    [Center Radius] = customWait(h)
    mm = createMask(h) ;
    ArenaInfo(i).ArenaCenter = Center ;
    ArenaInfo(i).ArenaRadius = Radius ;
    ArenaInfo(i).Mask = mm ;
    
    FS = size(BI) ;         % Note odd indexing where X comes second
    EX = FS(2) ;
    EY = FS(1) ;
    CX = Center(1) ;        % Indexing here is X first
    CY = Center(2) ;
    
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
    
    patch(X_Quad1,Y_Quad1,'r','facealpha',0.1)
    patch(X_Quad2,Y_Quad2,'g','facealpha',0.1)
    patch(X_Quad3,Y_Quad3,'r','facealpha',0.1)
    patch(X_Quad4,Y_Quad4,'g','facealpha',0.1)
    title (ArenaInfo(i).Camera) ;

    % Save ArenaInfo in DataDayDir
    save ArenaInformation ArenaInfo 
end   

    function [Center Radius] = customWait(hROI)
    % Listen for mouse clicks on the ROI
    l = addlistener(hROI,'ROIClicked',@clickCallback);
    % Block program execution
    uiwait;
    % Remove listener
    delete(l);
    % Return circle Center and Radius
    Center = hROI.Center ;
    Radius = hROI.Radius ;
    end
    
    function clickCallback(~,evt)
    
    if strcmp(evt.SelectionType,'double')
        uiresume;
    end
    end
end
