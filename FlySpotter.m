%% Locate each fly in the circular arena
% For each Experiment (i.e. each directory that has a Test*.ufmf video in
% it) this returns Frame.FlySpots which has the fields:
% .Centroid         Fly centroids
% .EquivDiameter    Diameter of a circle with the same area as the region
% .FilledImage      Image the same size as the bounding box of the region

% Saves as FlySpots.mat into a directory above the ExptDay directory i.e. at same level as RawData directory

% NOTES:
% The last two fields could be useful for making trajectory movies but currently
% we only use .Centroid

% IMPROVEMENTS:
% If you made each binary object a different color and did a t-projection you could have every flies tracks plotted
% Flies are counted by thresholding and binarizing in mark_flies.m.  We
% need quality control to make sure the thresholding is correct.
% Have an alert for frames where total # flies changes.  Flies dropping from one frame not a problem but dropping for all remaining frames undesireable
% We could return the size of the binary objects and figure out how to parse things that are too big for a single fly
% X Don't display every frame analyzed - do it every framerate*60 for 1
% minute chunks
% X Average several frames to get a background to subtract
% X Why load movie in little chunks - what does it help?
% >> First work through all Cam0 files then all Cam1.  That way you don't have to load new masks every loop
% Preallocate Frame structure for speed


%% Set parameters for fly tracking
MinObjectArea = 50 ;            % Minimum area of a fly (in pixels)

%% Directories for raw data
% Master folder enclosing all daily experiment folders
% (Or you could start on the desktop and use UI to find data folder)
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

%% Load ArenaInformation from ArenaSetup()
load ('ArenaInformation.mat')

%% Loop through each data subfolder and detect FlySpots using ArenaInfo for each Camera

for ExptIdx = 1:length(subFolders)
    ExptName = subFolders(ExptIdx).name;
    cd(ExptName)
tic    
    video = dir('movie_Test*.ufmf') ;
    % SKIP if folder does not contain a Test video file or if folder contains analyzed tag
    % To include a folder manually delete analyzed.txt from the directory
    analyzed_file = [ExptName, '/', 'analyzed.txt'];
    if (size(video, 1) == 0) || (exist(analyzed_file, 'file') ~= 0)
        disp(['FlySpotter run previously - Skipping subFolder ' num2str(ExptIdx) ' of ' num2str(length(subFolders))])
        % CD back up one level to day's directory
        cd ..
        continue
    end
    
    % Determine Camera used & load appropriate ArenaEdge and BackgroundImage
    Cam0 = strfind(ExptName,'Cam0');
    if ~isempty(Cam0)
        ArenaEdge       = ArenaInfo(1).Mask ;
        BackgroundImage = ArenaInfo(1).BackgroundImage ;
    else
        Cam1 = strfind(ExptName,'Cam1');
        if ~isempty(Cam1)
            ArenaEdge       = ArenaInfo(2).Mask ;
            BackgroundImage = ArenaInfo(2).BackgroundImage ;
        end
    end
    
    Header      = ufmf_read_header(video(1).name);
    FrameRate   = round(1/mean(diff(Header.timestamps))) ;
    TotalFrames = Header.nframes - rem(Header.nframes, FrameRate); % Round the number of frames to the nearest second
    
    %     disp(['Marking Flies for ' ExptName])
    disp(['Marking Flies for Expt ' num2str(ExptIdx) ' of ' num2str(length(subFolders))])    
    for FrameIdx = 1:TotalFrames
        tmp = ufmf_read_frame(Header, FrameIdx) ;
        Frame(FrameIdx).FlySpots = MarkFlies(tmp, BackgroundImage, ArenaEdge, MinObjectArea) ;
    end
    
    % Tag the folder containing the ufmf video with a file to indicate the data inside has been analyzed
    % Note that you are still in the Behavior_Raw directory
    file = fopen('analyzed.txt', 'w');
    fclose(file);
    
    % Create a directory to save output from MarkFlies
    AnalysisDir = replace(DataDayDir, 'Raw', 'Analysis') ;
    AnalysisDir = ([AnalysisDir,'/' ExptName]) ;
    create_folder = mkdir(AnalysisDir) ;
    save([AnalysisDir, '/', 'FlySpots'], 'Frame') ;
toc    
    % CD up one level to day's directory - still in Behavior_Raw
    cd ..
end