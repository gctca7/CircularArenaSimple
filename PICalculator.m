%% Calculate PI from a circular olfactory arena experiment
% Outputs the structure 'Behavior' with fields:
% .ExptPathName     Directory where the extracted flycounts are stored
% .Camera           Which camera the data came from
% .PairedOdor       Which odor was the CS+.  Restricted to either OCT or MCH
% .FlyCountCSPlus                       = n_flies(:,1) ;
% .FlyCountCSMinus                     = n_flies(:,2) ;
% .RollingPI        (CS+ - CS-)/(CS+ + CS-) at each frame. PI_TW sets timewindow
% .PI               Mean of RollingPI ;

% >>NOTE<< This pipeline assumes there are two cameras and only one arena
% HAVE THIS NOTE EITHER ON FRONT END OR IN ALL SCRIPTS


%% Read in the experiment list from xls file
% Change directory to folder containing experiment lists
% (or just start on Desktop)
cd('/Users/glennturner/Dropbox (HHMI)/Data/BehaviorDataKarenHibbard/Behavior_DataLists')
% User selects spreadsheet containing experiment names
[FileName, PathName] = uigetfile('*', 'Select spreadsheet containing experiment names', 'off') ;
% Return cell array where each cell contains directory path to folders containing flycounts
[~, Expts, ~] = xlsread([PathName, FileName]);

%% Specify timing parameters
FrameRate = 30 ;                % Acquisition rate (in frames per sec)
PI_TW   = [FrameRate*60 FrameRate*90] ;  % TimeWindow to calculate PI
Pre_TW  = [FrameRate*5  FrameRate*35] ;  % TimeWindow of pre-odor period to calculate BiasPI
Odor_TW = [FrameRate*30 FrameRate*90] ;

%% Loop through each experiment and calculate PI

for ExptIdx = 1:length(Expts)
    ExptName = Expts{ExptIdx, 1} ;
    % CD and load FlyCounts
    cd(ExptName)
    load('FlyCounts.mat') % returns FlyCount (frames x odors)
    
    % Create the structure 'Behavior' and add a field for the Pathname
    % to the directory containing the extracted flycounts
    Behavior(ExptIdx).ExptPathName = ExptName ;
    
    % Determine camera number - need for assigning Odors to Quadrants
    Cam0 = strfind(ExptName,'Cam0');
    if ~isempty(Cam0)
        Behavior(ExptIdx).Camera = 'Cam0' ;
    else
        Cam1 = strfind(ExptName,'Cam1');
        if ~isempty(Cam1)
            Behavior(ExptIdx).Camera = 'Cam1' ;
        end
    end
    
    %     Determine odor that is CS+
    OCT = strfind(ExptName,'OCT+');
    if ~isempty(OCT)
        Behavior(ExptIdx).PairedOdor = 'OCT' ;
    else
        MCH = strfind(ExptName,'MCH+');
        if ~isempty(MCH)
            Behavior(ExptIdx).PairedOdor = 'MCH' ;
        end
    end
    
    % Specify Odor Quandrants based on which which camera took video
    % >> Odor quadrants are different on each camera <<
    Cam = Behavior(ExptIdx).Camera ;
    switch Cam
        case 'Cam0'         % Cam0 - UL:MCH UR:OCT LR:MCH LL:OCT
            MCHQuads = [1 3] ;
            OCTQuads = [2 4] ;
        case 'Cam1'         % Cam1 - UL:OCT UR:MCH LR:OCT LL:MCH
            MCHQuads = [2 4] ;
            OCTQuads = [1 3] ;
        otherwise
            warning('Cam not Cam0 or Cam1')
    end
    
    % Count flies in CS+ and CS- quadrants accordingly
    CSPlus = Behavior(ExptIdx).PairedOdor ;
    switch CSPlus
        case 'OCT'
            FlyCountCSPlus  = sum(FlyCount(:,OCTQuads),2) ;
            FlyCountCSMinus = sum(FlyCount(:,MCHQuads),2) ;
        case 'MCH'
            FlyCountCSPlus  = sum(FlyCount(:,MCHQuads),2) ;
            FlyCountCSMinus = sum(FlyCount(:,OCTQuads),2) ;
        otherwise
            warning('Odor not MCH or OCT')
    end
    
    TotalFlyCount   = sum(FlyCount,2) ;
    RollingDiff     = FlyCountCSPlus - FlyCountCSMinus ; 
    RollingPI       = RollingDiff./TotalFlyCount ;
    PI              = mean(RollingPI(PI_TW(1):PI_TW(2))); ;
    % Calculate how flies are distributed before odor
    BiasPI         = mean(RollingPI(Pre_TW(1):Pre_TW(2))) ;
        
    Behavior(ExptIdx).FlyCount        = FlyCount ;
    Behavior(ExptIdx).TotalFlyCount   = TotalFlyCount ;
    Behavior(ExptIdx).FlyCountCSPlus  = FlyCountCSPlus ;
    Behavior(ExptIdx).FlyCountCSMinus = FlyCountCSMinus ;
    Behavior(ExptIdx).RollingDiff     = RollingDiff ;
    Behavior(ExptIdx).RollingPI       = RollingPI ;
    Behavior(ExptIdx).PI              = PI ;
    Behavior(ExptIdx).BiasPI          = BiasPI ;
    
    % Save Behavior in the same directory as the FlyCounts.mat
    save BehaviorResult Behavior PI ;
    disp(['PI = ' num2str(PI)])
    % CD back up
    cd ..
end


%% Plot FlyCount for each odor over TimeSec as well as Total Fly Count to identify missed fly detections

for ExptIdx = 1:length(Expts)
    ExptName = Expts{ExptIdx, 1} ;
    % CD and load BehaviorResults
    cd(ExptName)
    load ('BehaviorResult.mat')
    
    TotalFrames = length(Behavior(ExptIdx).TotalFlyCount) ;
    TimeSec = [1/FrameRate : 1/FrameRate : TotalFrames/FrameRate] ;
    TimeSec = TimeSec' ;
    
    figure
    plot(TimeSec,Behavior(ExptIdx).FlyCountCSPlus,'r','linewidth',3)  ; hold on
    plot(TimeSec,Behavior(ExptIdx).FlyCountCSMinus,'b','linewidth',3) ; hold on
    plot(TimeSec,Behavior(ExptIdx).TotalFlyCount,'color',[.5 .5 .5],'linewidth',1)
    
    xlim([0, 120]) ;
    ylim([-2.5, 35]) ;
    xOdorPatch = [30 30 90 90] ;
    yOdorPatch = [-2.5 45 45 -2.5] ;
    patch(xOdorPatch, yOdorPatch, 'black','facealpha',0.1,'edgecolor','none') ;
    xPIPatch = [60 60 90 90];
    yPIPatch = [0 42 42 0];
    patch(xPIPatch, yPIPatch, 'blue','facealpha',0.3,'edgecolor','none') ;
    
    PIstr = (['PI= ' num2str(round(Behavior(ExptIdx).PI,2))]) ;
    text(100,30,PIstr)
    
    set(gca,'DataAspectRatio', [1 1.6 1]);
    
    title([Behavior(ExptIdx).Camera ' ' Behavior(ExptIdx).PairedOdor ' CS+ '])
    xlabel('TimeSec (sec)')
    ylabel('Fly counts')
    print('Count_v_Time', '-dpng')
end

%% Plot PI for CS+ OCT and CS+ MCH individually
figure
for ExptIdx = 1:length(Expts)
    ExptName = Expts{ExptIdx, 1} ;
    % CD and load BehaviorResults
    cd(ExptName)
    load ('BehaviorResult.mat')
    
    CSPlus = Behavior(ExptIdx).PairedOdor ;
    
    switch CSPlus
        case 'MCH'
            subplot(1,2,1)
            plot(1,Behavior(ExptIdx).PI,'b.','markersize',24); hold on;
            title('PI for CS+ MCH')
            xlim([0.5  1.5])
            ylim([-.75 .75])
        case 'OCT'
            subplot(1,2,2)
            plot(1,Behavior(ExptIdx).PI,'b.','markersize',24); hold on;
            title('PI for CS+ OCT')
            xlim([0.5  1.5])
            ylim([-.75 .75])
        otherwise
            warning('Odor not MCH or OCT')
    end
end
hold off
%% Plot how much flies redistribute before/after odor
figure
for ExptIdx = 1:length(Expts)
    ExptName = Expts{ExptIdx, 1} ;
    % CD and load BehaviorResults
    cd(ExptName)
    load ('BehaviorResult.mat')
    
    CSPlus = Behavior(ExptIdx).PairedOdor ;
    switch CSPlus
        case 'MCH'
            subplot(1,2,1)
            plot(1,Behavior(ExptIdx).BiasPI,'b.','markersize',24); hold on;
            plot(2,Behavior(ExptIdx).PI,'b.','markersize',24); hold on;
            line ([1 2],[Behavior(ExptIdx).BiasPI Behavior(ExptIdx).PI],'color','b')
            xlim([0.5  2.5])
            ylim([-.75 .75])
            title('CS+ MCH Fly Count Shift Pre/Post')
        case 'OCT'
            subplot(1,2,2)
            plot(1,30*(Behavior(ExptIdx).BiasPI),'b.','markersize',24); hold on;
            plot(2,30*(Behavior(ExptIdx).PI),'b.','markersize',24); hold on;
            line ([1 2],[30*Behavior(ExptIdx).BiasPI 30*Behavior(ExptIdx).PI],'color','b')
            xlim([0.5  2.5])
            ylim([-10 10])
            title('CS+ OCT Fly Count Shift Pre/Post')
        otherwise
            warning('Odor not MCH or OCT')
    end
end
hold off

%% Plot reciprocal PI
% Calculate reciprocal from experiments on same Camera



