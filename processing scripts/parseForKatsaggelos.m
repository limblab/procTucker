function [figureList,outputData]=parseForKatsaggelos(folderpath,inputData)
    figureList=[];
    outputData=[];
    %% initial loading of data
    if strcmp(inputData.fileName1(end-3:end),'.mat')
        load([folderpath,inputData.fileName1])
    elseif RDPIsAlreadyDone('cds',folderpath)
        disp('loading prevously computed cds')
        cds=RDPLoadExisting('cds',folderpath);
    else
        cds=commonDataStructure();
        disp('loading first file')
        cds.file2cds([folderpath,inputData.fileName1],inputData.ranBy,inputData.array1,inputData.monkey,inputData.lab,'ignoreJumps',inputData.task,inputData.mapFile1);
        RDPSave(cds,'cds',folderpath);
    end
    %% copy data to experiment
    disp('passing data to experiment')
    ex=experiment();
        % set which variables to load from cds
        ex.meta.hasLfp=false;
        ex.meta.hasKinematics=true;
        ex.meta.hasForce=false;
        ex.meta.hasUnits=true;
        ex.meta.hasTrials=true;
        ex.meta.hasAnalog=true;

    ex.addSession(cds);
    clear cds
    %% configure experiment
    % set binConfig parameters:
    ex.binConfig.include(1).field='units';
    ex.binConfig.include(1).which=find([ex.units.data.ID]>0 & [ex.units.data.ID]<255);
    ex.binConfig.include(2).field='kin';
    ex.binConfig.include(2).which={};
    ex.binConfig.include(3).field='analog';
    ex.binConfig.include(3).which=ex.analog(end).data.Properties.VariableNames(2:end);%kinect data\
    
     % set firingRateConfig parameters
        ex.firingRateConfig.cropType='tightCrop';
        ex.firingRateConfig.offset=-.015;
        ex.firingRateConfig.method=inputData.binMethod;
        ex.firingRateConfig.kernelWidth=inputData.kernelWidth;
        %ex.firingRateConfig.lags=[-2 3];

    %% bin the data
        disp('binning data')
        ex.binData()
    %% configure weiner filter
    disp('computing weiner filter on full data')
    whichUnits=find([ex.units.data.ID]>0 & [ex.units.data.ID]<255);
%     ex.bin.weinerConfig.inputList=ex.units.getUnitName(whichUnits);
%     ex.bin.weinerConfig.outputList=[{'x','y','vx','vy','ax','ay'},ex.binConfig.include(3).which];
%     ex.bin.weinerConfig.outputList=ex.units.getUnitName(whichUnits);
%     ex.bin.weinerConfig.inputList=[{'x','y','vx','vy','ax','ay'},ex.binConfig.include(3).which];
%     ex.bin.fitWeiner
%     ex.analysis(end).notes='fit on whole data set';
    
    RDPSave(ex.bin.data,'allBins',folderpath);
    data=ex.bin.data{:,:};
    labels=ex.bin.data.Properties.VariableNames;
    save([folderpath,'Output_Data/','allBinsArray.mat'],'data','labels','-v7.3')
    
    disp('finding the starts of movement')
    ex.getMoveStart()
    
%     disp('computing weiner filter on only data from reaches')
     ex.bin.weinerConfig.windows=[ex.trials.data.moveTime,ex.trials.data.endTime];
     windowMask=~sum(isnan(ex.bin.weinerConfig.windows),2);
     ex.bin.weinerConfig.windows=ex.bin.weinerConfig.windows(windowMask,:);
%     ex.bin.fitWeiner
%     ex.analysis(end).notes='fit on only movement';

    RDPSave(ex.bin.data(windows2mask(ex.bin.data.t,ex.bin.weinerConfig.windows),:),'moveBins',folderpath);
    data=ex.bin.data{windows2mask(ex.bin.data.t,ex.bin.weinerConfig.windows),:};
    labels=ex.bin.data.Properties.VariableNames;
    save([folderpath,'Output_Data/','moveBinsArray.mat'],'data','labels','-v7.3')
    
    %re-run analysis including lags:
    disp('re-computing bins with neural lags')
    ex.firingRateConfig.lags=10;
    ex.calcFiringRate;
    ex.binData
%     disp('computing weiner filter on movement data using lags')
%     ex.bin.fitWeiner;
%     ex.analysis(end).notes='fit on movement with 10 lags';
    
    RDPSave(ex.bin.data,'allBins10Lag',folderpath);
    data=ex.bin.data{:,:};
    labels=ex.bin.data.Properties.VariableNames;
    save([folderpath,'Output_Data/','moveBins10LagArray.mat'],'data','labels','-v7.3')
    
    
%     disp('computing weiner filter on all data using lags')
%     ex.bin.weinerConfig.windows=[];
%     ex.bin.fitWeiner;
%     ex.analysis(end).notes='fit on all data with 10 lags';
    RDPSave(ex.bin.data,'moveBins10Lag',folderpath);
    data=ex.bin.data{:,:};
    labels=ex.bin.data.Properties.VariableNames;
    save([folderpath,'Output_Data/','allBins10LagArray.mat'],'data','labels','-v7.3')
    
    disp('saving experiment')
    %RDPSave(ex,'ex',folderpath);  
    outputData.ex=ex;
end