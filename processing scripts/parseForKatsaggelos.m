function [figureList,outputData]=parseForKatsaggelos(folderpath,inputData)
    figureList=[];
    %% initial loading of data
    cds=commonDataStructure();
    disp('loading first file')
    cds.file2cds([folderpath,inputData.fileName1],inputData.ranBy,inputData.array1,inputData.monkey,inputData.lab,'ignoreJumps',inputData.task,inputData.mapFile1);
    disp('loading second file')
    cds.file2cds([folderpath,inputData.fileName2],inputData.ranBy,inputData.array2,inputData.monkey,inputData.lab,'ignoreJumps',inputData.task,inputData.mapFile2);
    cd(folderpath)
    outputData.cds=cds;
    %% copy data to experiment
    disp('passing data to experiment')
    ex=experiment();
        % set which variables to load from cds
        ex.meta.hasLfp=false;
        ex.meta.hasKinematics=true;
        ex.meta.hasForce=false;
        ex.meta.hasUnits=true;
        ex.meta.hasTrials=true;

    ex.addSession(cds);
    clear cds
    %% configure experiment
    % set binConfig parameters:
    ex.binConfig.include(1).field='units';
    ex.binConfig.include(1).which=find([ex.units.data.ID]>0 & [ex.units.data.ID]<255);
    ex.binConfig.include(2).field='kin';
        ex.binConfig.include(2).which={};
     % set firingRateConfig parameters
        ex.firingRateConfig.cropType='tightCrop';
        ex.firingRateConfig.offset=-.015;
        %ex.firingRateConfig.lags=[-2 3];

    %% bin the data
        disp('binning data')
        ex.binData()
    %% configure weiner filter
    disp('compting weiner filter on full data')
    whichUnits=find([ex.units.data.ID]>0 & [ex.units.data.ID]<255);
    ex.bin.weinerConfig.inputList=ex.units.getUnitName(whichUnits);
    ex.bin.weinerConfig.outputList={'x','y','vx','vy','ax','ay'};
    ex.bin.fitWeiner
    ex.analysis(end).notes='fit on whole data set';
    
    disp('finding the starts of movement')
    ex.getMoveStart()
    
    disp('computing weiner filter on only data from reaches')
    ex.bin.weinerConfig.windows=[ex.trials.data.moveTime,ex.trials.data.endTime];
    windowMask=~sum(isnan(ex.bin.weinerConfig.windows),2);
    ex.bin.weinerConfig.windows=ex.bin.weinerConfig.windows(windowMask,:);
    ex.bin.fitWeiner
    ex.analysis(end).notes='fit on only movement';

    outputData.ex=ex;
    outputData.allBins=ex.bins.data;
    outputData.moveBins=ex.bins.data(windows2mask(),:);
end