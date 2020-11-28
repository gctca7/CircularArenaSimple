% ArenaQualityControl
%
% For each Experiment, find frames where FlyCount is particularly high or low
% Take two high and two low frames
% Plot the frame image itself + centoid markers + quadrant boundaries

% IMPROVEMENTS
% Put text of FlyCount within each quadrant
% Also show backgroundimage - maybe not necessary since that's an earlier part of the pipline

%% Load ArenaInformation

startingFolder = '/Users/glennturner/Data/DataKarenHibbard/Behavior_Raw' ;
% User selects daily experiment folder
DataDayDir = uigetdir(startingFolder,'Select Folder with ArenaInformation');
cd (DataDayDir)
load ('ArenaInformation.mat')

%% Load directory paths to folders containing FlySpots & FlyCounts

% Change directory to folder containing experiment lists
% (or just start on Desktop)
cd('/Users/glennturner/Dropbox (HHMI)/Data/BehaviorDataKarenHibbard/Behavior_DataLists')
% User selects spreadsheet containing experiment names
[FileName, PathName] = uigetfile('*', 'Select spreadsheet containing experiment names', 'off') ;
% Return cell array where each cell contains full directory path to folders containing flycounts
[~, ExptName, ~] = xlsread([PathName, FileName]);

%% Show frames with outlier FlyCounts with FlySpots overlaid and Quadrants marked

for ExptIdx = 1:length(ExptName)
    cd (ExptName{ExptIdx})
    load FlySpots.mat
    load FlyCounts.mat
    TotalFlyCount = sum(FlyCount,2) ;
    [H, I] = sort(TotalFlyCount,'descend') ;
    HighCounts = I([1 2]) ;
    [L, I] = sort(TotalFlyCount,'ascend') ;
    LowCounts = I([1 2]) ;
    TestIdx = [HighCounts ; LowCounts] ;
    disp(['High Count = ' num2str(H(1)) ' Low Count = ' num2str(L(1))])
    figure;plot(TotalFlyCount,'.','markersize',18)
    
    % cd to movie folder using replace
    RawDir = replace(ExptName{ExptIdx},'Analysis','Raw') ;
    cd (RawDir)
    video = dir('movie_Test*.ufmf') ;
    Header = ufmf_read_header(video(1).name);
    
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
    
    FS = size(ArenaInfo(1).BackgroundImage) ; % Note odd indexing where X comes second
    EX = FS(2) ;
    EY = FS(1) ;
    CX = ArenaCenter(1) ;                     % Indexing here is X first
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
    
    figure;
    for i = 1:length(TestIdx)
        tmp = ufmf_read_frame(Header, TestIdx(i)) ;
        z = cat(1,Frame(TestIdx(i)).FlySpots.Centroid) ;
        X_Locs = z(:,1) ;
        Y_Locs = z(:,2) ;
        subplot(2,2,i)
        imshow(tmp) ; hold on
        plot(X_Locs,Y_Locs,'.','markersize',10,'color','g') ; hold on;
        patch(X_Quad1,Y_Quad1,'r','facealpha',0.1)
        patch(X_Quad2,Y_Quad2,'g','facealpha',0.1)
        patch(X_Quad3,Y_Quad3,'r','facealpha',0.1)
        patch(X_Quad4,Y_Quad4,'g','facealpha',0.1)
    end
end

% Return equivalent diameters of FlySpots - may be useful to find fly overlaps
Diams = NaN(25,3600) ;
for i = 1:3600
    zz = cat(1,Frame(i).FlySpots.EquivDiameter) ;
    Diams(1:length(zz),i) = zz ;
end

