function [ outputFigures,outputData ] = efferenceCopyAnalysis(folderpath, inputData )
    %script to load stimulation files and generate perievent plots of 30khz
    %data. Formatted to work with runDataProcessing
    outputFigures=[];
    %% generate cds from raw data (or load existing cds)
    outputFigures=[];
    outputData=[];
    %get list of all files in the folder:
    if ~strcmp(folderpath(end),filesep)
        folderpath=[folderpath,filesep];
    end
    cd(folderpath);
    if RDPIsAlreadyDone('cds',folderpath) && (~isfield(inputData,'forceReload') || ~inputData.forceReload)
        warning('processStimArtifact:foundExistingData','loading data from previous processing. This will have the PREVIOUS settings for time window, presample etc')
        cds =RDPLoadExisting('cds',folderpath);
    else
        if ~isfield(inputData,'fileName')
            fileList=dir('*.nev');
            for i=1:numel(fileList)
                %% load file
                disp(['working on:'])
                disp(fileList(i).name)
                cds=commonDataStructure();
    %             cds.file2cds([folderpath,fileList(i).name],inputData.ranBy,inputData.array1,inputData.monkey,inputData.lab,'ignoreJumps',inputData.task,inputData.mapFile,'recoverPreSync');
                cds.file2cds([folderpath,fileList(i).name],inputData.ranBy,inputData.array1,inputData.monkey,inputData.lab,'ignoreJumps',inputData.task,inputData.mapFile);
            end
        else
            cds=commonDataStructure();
            cds.file2cds([folderpath,inputData.fileName],inputData.ranBy,inputData.array1,inputData.monkey,inputData.lab,'ignoreJumps',inputData.task,inputData.mapFile);
        end
    end
    %% migrate data into experiment object:
    ex=experiment();
    ex.meta.hasUnits=true;
    ex.meta.hasKinematics=true;
    ex.meta.hasForce=true;
    ex.meta.hasTrials=true;
    
    ex.addSession(cds);
        
    %% get FR data from unit structure
    ex.firingRateConfig.cropType='tightCrop';
    ex.firingRateConfig.offset=-.015;
    ex.firingRateConfig.sampleRate = 20;
    ex.firingRateConfig.kernelWidth=1/20;
    ex.binConfig.include(1).field='units';
    fun=@(x) size(x,1);
    highFiringMask=cellfun(fun,{ex.units.data.spikes})/ex.meta.duration>1/ex.firingRateConfig.sampleRate;
    ex.binConfig.include(1).which=find([ex.units.data.ID]>0 & [ex.units.data.ID]<255 & highFiringMask);
    ex.binConfig.include(2).field='kin';
        ex.binConfig.include(2).which={};
    ex.binConfig.include(3).field='force';
        ex.binConfig.include(3).which={};
    ex.binConfig.filterConfig.sampleRate=ex.firingRateConfig.sampleRate;
    ex.binConfig.filterConfig.cutoff=10;
    
    ex.binData('recalcFiringRate')
        
    %% find move onset and establish windows from 300-50ms prior to move onset
    ex.getMoveStart();
       
    moveTime=ex.trials.data.moveTime(~isnan(ex.trials.data.moveTime) & ...  %only look at trials that have a move time
                                        ~isnan(ex.trials.data.tgtDir) & ... %only look at trials that have a target direction
                                        ~ex.trials.data.delayBump & ... %only look at trials that do not have a bump during the delay period
                                        (ex.trials.data.moveTime-ex.trials.data.goCueTime)<0.4 & ... %only look at trials where movement starts within 400ms of target presentation
                                        (ex.trials.data.moveTime-ex.trials.data.goCueTime)>0.1);%only look at trails where movement starts more than 100ms after go cue
    %% set up dimensionality reduction configuration                                
    ex.bin.dimReductionConfig.windows=[moveTime-.4-.005,moveTime-.2+.005];
    ex.bin.dimReductionConfig.which=(size(ex.force.data,2)+size(ex.kin.data,2)):size(ex.bin.data,2);
    ex.bin.dimReductionConfig.dimension=numel(ex.bin.dimReductionConfig.which);
    
    %% get premove data that will be used in the dimensionality reductions, and compute the target directions
    premoveMask=windows2mask(ex.bin.data.t,ex.bin.dimReductionConfig.windows);
    if inputData.rootTransform
        DRData=[ex.bin.data.t(premoveMask),sqrt(ex.bin.data{premoveMask,ex.bin.dimReductionConfig.which})];
    else
        DRData=ex.bin.data{premoveMask,[1,ex.bin.dimReductionConfig.which]};
    end
    tgtDir=nan(size(DRData,1),1);
    for i=1:size(DRData,1)
        %find which trial the point was from and add its target direction 
        %to the tgtDir vector 
        trialIdx=find(ex.trials.data.startTime<DRData(i,1) & ex.trials.data.endTime>DRData(i,1),1,'first');
        tgtDir(i)=ex.trials.data.tgtDir(trialIdx);
    end
    tgtDir=round(tgtDir);
    tgtDirList=unique(tgtDir);
    for i=1:4:numel(tgtDirList)*4
        legendStrings{i}=[num2str(tgtDirList((i+3)/4)),'deg correct'];
        legendStrings{i+1}=[num2str(tgtDirList((i+3)/4)),'deg error'];
        legendStrings{i+2}='';
        legendStrings{i+3}='';
        
    end
    
    %% get a cell array of window vectors where each vector only contains trials for a single target direction
    %will be used with Machen's method to estimate noise floor:
    windowsBase=ex.bin.dimReductionConfig.windows;
    %get target directions for each window:
    tgts=nan(size(windowsBase,1),1);
    for i=1:size(windowsBase,1);
        trialIdx=find(ex.trials.data.startTime<windowsBase(i,1) & ex.trials.data.endTime>windowsBase(i,2),1,'first');
        tgts(i)=ex.trials.data.tgtDir(trialIdx);
    end
    %% perform analysis in full neural feature space:
    discrModel=fitcdiscr(DRData,tgtDir,'Leaveout','on');
    pred=kfoldPredict(discrModel);
    outputData.classData.fitAccuracy=sum(pred==tgtDir)/numel(tgtDir);
    outputData.classData.correct=pred==tgtDir;
    outputData.plotData=classifierPlotData(DRData,tgtDir);
    outputFigures(end+1)=plotClassData(outputData.plotData.reducedData,tgtDir,'correct',outputData.classData.correct,'legend',legendStrings,'title','Pre-Move: clusters in log-likelihood ratio space for full neural analysis','name','unreducedClusters');
        numPlotPixels=1200;
        set(outputFigures(end),'Position',[100 100 numPlotPixels numPlotPixels]);
        paperSize=0.2+numPlotPixels/get(outputFigures(end),'ScreenPixelsPerInch');
        set(outputFigures(end),'PaperSize',[paperSize,paperSize]);
    % classify in LL space using plot data:
    discrModel=fitcdiscr(outputData.plotData.LLRatio,tgtDir,'Leaveout','on');
    pred=kfoldPredict(discrModel);
    outputData.classData.LLSpaceFitAccuracy=sum(pred==tgtDir)/numel(tgtDir);
    outputData.classData.LLSpaceCorrect=pred==tgtDir;
    
    %% run PCA    
    ex.bin.fitPCA('MachensFloor',tgts);
    ex.analysis(end).notes='full data PCA';
    PCDRData=[DRData(:,2:end)*ex.analysis(end).data.coeff(:,ex.analysis(end).data.MachensFloor.goodPC)];
    numPCFeatures=sum(ex.analysis(end).data.MachensFloor.goodPC);
    PCNoise=ex.analysis(end).data.MachensFloor.noise;%for use with PPC and FA analysis
    
    discrModel=fitcdiscr(PCDRData,tgtDir,'Leaveout','on');
    pred=kfoldPredict(discrModel);
    outputData.PCClassData.fitAccuracy=sum(pred==tgtDir)/numel(tgtDir);
    outputData.PCClassData.correct=pred==tgtDir;
    outputData.PCPlotData=classifierPlotData(PCDRData,tgtDir);
    outputFigures(end+1)=plotClassData(outputData.PCPlotData.reducedData,tgtDir,'correct',outputData.PCClassData.correct,'legend',legendStrings,'title','Pre-Move: clusters in log-likelihood ratio space for PC analysis','name','PCClusters');
        numPlotPixels=1200;
        set(outputFigures(end),'Position',[100 100 numPlotPixels numPlotPixels]);
        paperSize=0.2+numPlotPixels/get(outputFigures(end),'ScreenPixelsPerInch');
        set(outputFigures(end),'PaperSize',[paperSize,paperSize]);
        
        
    if inputData.classifyOnKin
        %try classifying the future target based on the instructed hold
        %data:
        kinData=ex.bin.data{premoveMask,[4:ex.bin.dimReductionConfig.which(1)-4]};
        discrModel=fitcdiscr(kinData,tgtDir,'Leaveout','on');
        pred=kfoldPredict(discrModel);
        outputData.kinClassData.fitAccuracy=sum(pred==tgtDir)/numel(tgtDir);
        outputData.kinClassData.correct=pred==tgtDir;
        outputData.kinPlotData=classifierPlotData(kinData,tgtDir);
        outputFigures(end+1)=plotClassData(outputData.kinPlotData.reducedData,tgtDir,'correct',outputData.kinClassData.correct,'legend',legendStrings,'title','Pre-Move: clusters in log-likelihood ratio space for kinetics','name','kinClusters');
        numPlotPixels=1200;
        set(outputFigures(end),'Position',[100 100 numPlotPixels numPlotPixels]);
        paperSize=0.2+numPlotPixels/get(outputFigures(end),'ScreenPixelsPerInch');
        set(outputFigures(end),'PaperSize',[paperSize,paperSize]);
        % classify in LL space using plot data:
        discrModel=fitcdiscr(outputData.kinPlotData.LLRatio,tgtDir,'Leaveout','on');
        pred=kfoldPredict(discrModel);
        outputData.kinClassData.LLSpaceFitAccuracy=sum(pred==tgtDir)/numel(tgtDir);
        outputData.kinClassData.LLSpaceCorrect=pred==tgtDir;
    end

    %% re-run analyses on movment data:
    %% set up dimensionality reduction configuration                                
    ex.bin.dimReductionConfig.windows=[moveTime+.1-.005,moveTime+.3+.005];
    
    %% get premove data that will be used in the dimensionality reductions, and compute the target directions
    moveMask=windows2mask(ex.bin.data.t,ex.bin.dimReductionConfig.windows);
    
    %% get a cell array of window vectors where each vector only contains trials for a single target direction
    %will be used with Machen's method to estimate noise floor:
    windowsBase=ex.bin.dimReductionConfig.windows;
    %get target directions for each window:
    tgts=nan(size(windowsBase,1),1);
    for i=1:size(windowsBase,1);
        trialIdx=find(ex.trials.data.startTime<windowsBase(i,1) & ex.trials.data.endTime>windowsBase(i,2),1,'first');
        if ~isempty(trialIdx)
            tgts(i)=ex.trials.data.tgtDir(trialIdx);
        end
    end
    mask=isnan(tgts(:,1));
    ex.bin.dimReductionConfig.windows(mask,:)=[];
    tgts(mask)=[];
    %% find the data and put it in an array:
    if inputData.rootTransform
        DRData=[ex.bin.data.t(moveMask),sqrt(ex.bin.data{moveMask,ex.bin.dimReductionConfig.which})];
    else
        DRData=ex.bin.data{moveMask,[1,ex.bin.dimReductionConfig.which]};
    end
    %get target directions for each observation in the data array
    tgtDir=nan(size(DRData,1),1);
    for i=1:size(DRData,1)
        %find which trial the point was from and add its target direction 
        %to the tgtDir vector 
        trialIdx=find(ex.trials.data.startTime<DRData(i,1) ,1,'last');
        tgtDir(i)=round(ex.trials.data.tgtDir(trialIdx));
    end
    %% perform analysis in full neural feature space:    
    discrModel=fitcdiscr(DRData,tgtDir,'Leaveout','on');
    pred=kfoldPredict(discrModel);
    outputData.moveClassData.fitAccuracy=sum(pred==tgtDir)/numel(tgtDir);
    outputData.moveClassData.correct=pred==tgtDir;
    outputData.movePlotData=classifierPlotData(DRData,tgtDir);
    outputFigures(end+1)=plotClassData(outputData.movePlotData.reducedData,tgtDir,'correct',outputData.moveClassData.correct,'legend',legendStrings,'title','During-Move: clusters in log-likelihood ratio space for full neural analysis','name','unreducedClusters');
        numPlotPixels=1200;
        set(outputFigures(end),'Position',[100 100 numPlotPixels numPlotPixels]);
        paperSize=0.2+numPlotPixels/get(outputFigures(end),'ScreenPixelsPerInch');
        set(outputFigures(end),'PaperSize',[paperSize,paperSize]);
    
    %% run PCA    
    ex.bin.fitPCA('MachensFloor',tgts);
    ex.analysis(end).notes='full data PCA';

    PCDRData=[DRData(:,2:end)*ex.analysis(end).data.coeff(:,ex.analysis(end).data.MachensFloor.goodPC)];
    numPCFeatures=sum(ex.analysis(end).data.MachensFloor.goodPC);
    PCNoise=ex.analysis(end).data.MachensFloor.noise;%for use with PPC and FA analysis
    
    discrModel=fitcdiscr(PCDRData,tgtDir,'Leaveout','on');
    pred=kfoldPredict(discrModel);
    outputData.movePCClassData.fitAccuracy=sum(pred==tgtDir)/numel(tgtDir);
    outputData.movePCClassData.correct=pred==tgtDir;
    outputData.movePCPlotData=classifierPlotData(PCDRData,tgtDir);
    outputFigures(end+1)=plotClassData(outputData.movePCPlotData.reducedData,tgtDir,'correct',outputData.movePCClassData.correct,'legend',legendStrings,'title','During-Move: clusters in log-likelihood ratio space for PC analysis','name','PCClusters');
        numPlotPixels=1200;
        set(outputFigures(end),'Position',[100 100 numPlotPixels numPlotPixels]);
        paperSize=0.2+numPlotPixels/get(outputFigures(end),'ScreenPixelsPerInch');
        set(outputFigures(end),'PaperSize',[paperSize,paperSize]);
    
    %% run FA:
%     ex.bin.dimReductionConfig.dimension=10;
%     ex.bin.fitFA()
    
%% do timeseries analysis of prediction success rate
    %start with target onset:
    if inputData.doTimeseries
        targetTime=ex.trials.data.tgtOnTime(~isnan(ex.trials.data.moveTime) & ...  %only look at trials that have a move time
                                            ~isnan(ex.trials.data.tgtDir) & ... %only look at trials that have a target direction
                                            ~ex.trials.data.delayBump);         %only look at trials that do not have a bump during the delay period


        for i=1:15
            ex.bin.dimReductionConfig.windows=[targetTime+(i-5)*.05-.045,targetTime+(i-5)*.05+.045];
             % find the data and put it in an array:
             dataMask=windows2mask(ex.bin.data.t,ex.bin.dimReductionConfig.windows);
            if inputData.rootTransform
                DRData=[ex.bin.data.t(dataMask),sqrt(ex.bin.data{dataMask,ex.bin.dimReductionConfig.which})];
            else
                DRData=ex.bin.data{dataMask,[1,ex.bin.dimReductionConfig.which]};
            end
            %get target directions for each observation in the data array
            tgtDir=nan(size(DRData,1),1);
            for j=1:size(DRData,1)
                %find which trial the point was from and add its target direction 
                %to the tgtDir vector 
                trialIdx=find(ex.trials.data.startTime<DRData(j,1) ,1,'last');
                tgtDir(j)=round(ex.trials.data.tgtDir(trialIdx));
            end
            discrModel=fitcdiscr(DRData,tgtDir,'Leaveout','on');
            pred=kfoldPredict(discrModel);
            outputData.preMoveSequence(i).predictions=pred;
            outputData.preMoveSequence(i).correct=pred==tgtDir;
            outputData.preMoveSequence(i).accuracy=sum(pred==tgtDir)/numel(pred);
        end
        hold off
        outputFigures(end+1)=plot(.05*[-4:10],[outputData.preMoveSequence.accuracy]);
        title('prediction accuracy vs time after target appearance')
        xlabel('time(s)')
        ylabel('prediction accuracy')
        set(gcf,'Name','DelayAccuracyVSTime')
        %now do go cue:
        for i=1:15
            ex.bin.dimReductionConfig.windows=[moveTime+i*.05-.045,moveTime+i*.05+.045];
             % find the data and put it in an array:
             dataMask=windows2mask(ex.bin.data.t,ex.bin.dimReductionConfig.windows);
            if inputData.rootTransform
                DRData=[ex.bin.data.t(dataMask),sqrt(ex.bin.data{dataMask,ex.bin.dimReductionConfig.which})];
            else
                DRData=ex.bin.data{dataMask,[1,ex.bin.dimReductionConfig.which]};
            end
            %get target directions for each observation in the data array
            tgtDir=nan(size(DRData,1),1);
            for j=1:size(DRData,1)
                %find which trial the point was from and add its target direction 
                %to the tgtDir vector 
                trialIdx=find(ex.trials.data.startTime<DRData(j,1) ,1,'last');
                tgtDir(j)=round(ex.trials.data.tgtDir(trialIdx));
            end
            discrModel=fitcdiscr(DRData,tgtDir,'Leaveout','on');
            pred=kfoldPredict(discrModel);
            outputData.moveSequence(i).predictions=pred;
            outputData.moveSequence(i).correct=pred==tgtDir;
            outputData.moveSequence(i).accuracy=sum(pred==tgtDir)/numel(pred);
        end
        hold off
        outputFigures(end+1)=plot(.05*[-4:7],[outputData.moveSequence.accuracy]);
        title('prediction accuracy vs time after go cue')
        xlabel('time(s)')
        ylabel('prediction accuracy')
        set(gcf,'Name','MoveAccuracyVSTime')


        %% move objects into outputs
        outputData.cds=cds;
        outputData.ex=ex;
    end
    
    
    
    outputData.cds=cds;
    outputData.ex=ex;
end

























