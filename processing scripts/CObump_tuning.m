function [figureList,dataStruct]=CObump_tuning(folderpath,inputData)
    figureList=[];
    dataStruct=[];

    %% if we already got to an experiment just load that bad boy up
    if RDPIsAlreadyDone('ex',folderpath)
        ex=RDPLoadExisting('ex',folderpath);
    else
        %% load data into cds
        if RDPIsAlreadyDone('cds',folderpath)
            cds=RDPLoadExisting('cds',folderpath);
        else
            cds=commonDataStructure();
            if ~strcmp(folderpath(end),filesep)
                folderpath=[folderpath,filesep];
            end
            cds.file2cds([folderpath,inputData.fileName],inputData.ranBy,inputData.array,inputData.monkey,inputData.lab,'ignoreJumps',inputData.task,inputData.mapFile);
            RDPSave(cds,'cds',folderpath)
        end
        %% create new experiment object
        ex=experiment();
        % set which variables to load from cds
        ex.meta.hasLfp=false;
        ex.meta.hasKinematics=true;
        ex.meta.hasForce=true;
        ex.meta.hasUnits=true;
        ex.meta.hasTrials=true;
        % load experiment from cds:
        ex.addSession(cds)
        clear cds
        ex.units.deleteInvalid;

    %% set experiment configuration parameters that are not default 
        %pdConfig setup:
        ex.bin.pdConfig.pos=false;
        ex.bin.pdConfig.vel=false;
        ex.bin.pdConfig.force=true;
        ex.bin.pdConfig.speed=true;
        ex.bin.pdConfig.units={};%just use all of them
        ex.bin.pdConfig.bootstrapReps=50;
        % set binConfig parameters:
        ex.binConfig.include(1).field='units';
        if inputData.unsorted
            ex.units.removeSorting;
            ex.binConfig.include(1).which=find([ex.units.data.ID]==0);
        else
            ex.binConfig.include(1).which=find([ex.units.data.ID]>0 & [ex.units.data.ID]<255);
        end
        ex.binConfig.include(2).field='kin';
            ex.binConfig.include(2).which={};
        ex.binConfig.include(3).field='force';
            ex.binConfig.include(3).which={};

        % set firingRateConfig parameters
        ex.firingRateConfig.cropType='tightCrop';
        ex.firingRateConfig.offset=-.015;
        %ex.firingRateConfig.lags=[-2 3];

    %% bin the data
        ex.binData()
        %save('E:\local processing\chips\experiment_20160421_COBump_bumpTuning\ex.mat','ex','-v7.3')

    %% PDs during bump:
        abortMask=true(size(ex.trials.data,1),1);
        abortMask(strmatch('A',ex.trials.data.result,'exact'))=false;
        %do bumps:
        %get trials with bumps:
        bumpTrials=~isnan(ex.trials.data.bumpTime) & abortMask;
        ex.bin.pdConfig.windows=[ex.trials.data.bumpTime(bumpTrials),ex.trials.data.bumpTime(bumpTrials)+.125];
        %run pd analysis for force pds:
        ex.bin.pdConfig.pos=false;
        ex.bin.pdConfig.vel=false;
        ex.bin.pdConfig.force=true;
        ex.bin.pdConfig.speed=true;
        ex.bin.fitPds
        ex.analysis(end).notes='force pds during bump';

        ex.bin.pdConfig.pos=false;
        ex.bin.pdConfig.speed=true;
        ex.bin.pdConfig.vel=true;
        ex.bin.pdConfig.force=false;
        ex.bin.fitPds
        ex.analysis(end).notes='vel pds during bump';
        %do move PDs
        %get move onsets:
    %% PDs during move: 
        disp('finding the starts of movement')
        ex.getMoveStart()
        moveTrials=~isnan(ex.trials.data.moveTime) & abortMask;
        ex.bin.pdConfig.windows=[ex.trials.data.moveTime(moveTrials),ex.trials.data.moveTime(moveTrials)+.125];
        %get force pds
        ex.bin.pdConfig.pos=false;
        ex.bin.pdConfig.vel=false;
        ex.bin.pdConfig.force=true;
        ex.bin.pdConfig.speed=true;
        ex.bin.fitPds
        ex.analysis(end).notes='force pds during move';

        ex.bin.pdConfig.pos=false;
        ex.bin.pdConfig.speed=true;
        ex.bin.pdConfig.vel=true;
        ex.bin.pdConfig.force=false;
        ex.bin.fitPds
        ex.analysis(end).notes='vel pds during move';

        RDPSave(ex,'ex',folderpath);
    end
%% modulation with bump:
    %get trials in each bump direction:
    bumpDirs=sort(unique(ex.trials.data.bumpDir));
    bumpDirs(isnan(bumpDirs))=[];
    numBumps=numel(bumpDirs);
    numUnits=numel(ex.binConfig.include(1).which);
    trialMask=false(size(ex.trials.data,1),numel(bumpDirs));
    for i=1:numel(bumpDirs)
        trialMask(:,i)=ex.trials.data.bumpDir==bumpDirs(i);
    end
    modulationData=nan(numUnits,numBumps,3);
    for i=1:numUnits
        %make a histogram plot of spiking in response to each bump
        %direction and put them on a common figure:
        H=figure;
        set(H,'Name',[ex.units.getUnitName(ex.binConfig.include(1).which(i)),'-Bump-modulation'])
        numPlotPixels=2000;
        set(H,'Position',[100 100 numPlotPixels numPlotPixels]);
        paperSize=0.2+numPlotPixels/get(H,'ScreenPixelsPerInch');
        set(H,'PaperSize',[paperSize,paperSize]);
        for j=1:numBumps
            %figure out the plot position based on the bump direction, and
            %generate a new set of axes there:
            plotCtr=[cos(bumpDirs(j)*pi/180),sin(bumpDirs(j)*pi/180)]*.35+[.5 .5];
            offset=[.2,.15]/2;
            plotRect=[plotCtr-offset,2*offset];
            axisID=axes('position',plotRect);
            [histData,histErrs]=ex.units.PESTH(ex.trials.data.bumpTime(trialMask(:,j)),...%use the bumps from trials associated with this bump direction
                                    0.025,...%20ms pre-bump window
                                    0.125,...%200ms post-bump window
                                    ex.binConfig.include(1).which(i),...%we are working on this unit
                                    'useRate',true,...%divide count by bin width
                                    'numBins',[-.025:.025:.125],...
                                    'plotErr',true,...
                                    'useAxis',axisID);
            %now get the count data and store it so we can make our polar
            %tuning plot and return the modulation:  
            modIdx=3;
            modulationData(i,j,:)=[histData.counts(modIdx),histErrs(modIdx)*1.96,mean(histData.counts(3:end))];
        end
        %plot polar tuning circle in the middle:
        axisID=axes('position',[.3,.3,.4,.4]);
        
        PDIdx=find(ex.analysis(2).data.chan==ex.units.data(ex.binConfig.include(1).which(i)).chan & ex.analysis(2).data.ID==ex.units.data(ex.binConfig.include(1).which(i)).ID);
        polarTuningPlot(bumpDirs,squeeze(modulationData(i,:,1)),...%direction values and activity values 
                        'CI',[(squeeze(modulationData(i,:,1))'-squeeze(modulationData(i,:,2))') (squeeze(modulationData(i,:,1))'+squeeze(modulationData(i,:,2))')],...%
                        'PD',[ex.analysis(2).data.velDir(PDIdx),ex.analysis(2).data.velDirCI(PDIdx,:)],...
                        'useAxis',axisID)
        
        %add a title by putting a hidden axes with visible title bar on the
        %figure:
        set(H,'NextPlot','add');
        axes;
        H2 = title([ex.units.getUnitName(ex.binConfig.include(1).which(i)),' tuning during bumps. Moddepth: ',num2str(max(squeeze(modulationData(i,:,modIdx)))-min(squeeze(modulationData(i,:,modIdx))))]);
        set(gca,'Visible','off');
        set(H2,'Visible','on'); 
        RDPSaveFig(H,folderpath)
        close(H)
    end
    dataStruct.bumpModulationData=modulationData;
    %plot the distribution of modulation depths:
    figureList(end+1)=figure;
    set(figureList(end),'Name',['bumpModulationDistribution'])
    numPlotPixels=1200;
    set(figureList(end),'Position',[100 100 numPlotPixels numPlotPixels]);
    paperSize=0.2+numPlotPixels/get(figureList(end),'ScreenPixelsPerInch');
    set(figureList(end),'PaperSize',[paperSize,paperSize]);
    H=axes;
    histogram(H,squeeze(max(modulationData(:,:,1),[],2))-min(modulationData(:,:,1),[],2));
    title('distribution of modulation depths')
%% modulation with movement:
%get trials in each bump direction:
    moveDirs=sort(unique(ex.trials.data.tgtDir));
    moveDirs(isnan(moveDirs))=[];
    numMoveDirs=numel(moveDirs);
    numUnits=numel(ex.binConfig.include(1).which);
    trialMask=false(size(ex.trials.data,1),numel(moveDirs));
    for i=1:numel(moveDirs)
        trialMask(:,i)=ex.trials.data.tgtDir==moveDirs(i) & ~isnan(ex.trials.data.moveTime);
    end
    modulationData=nan(numUnits,numMoveDirs,3);
    for i=1:numUnits
        %make a histogram plot of spiking in response to each bump
        %direction and put them on a common figure:
        H=figure;
        set(H,'Name',[ex.units.getUnitName(ex.binConfig.include(1).which(i)),'-Move-modulation'])
        numPlotPixels=2000;
        set(H,'Position',[100 100 numPlotPixels numPlotPixels]);
        paperSize=0.2+numPlotPixels/get(H,'ScreenPixelsPerInch');
        set(H,'PaperSize',[paperSize,paperSize]);
        for j=1:numMoveDirs
            %figure out the plot position based on the bump direction, and
            %generate a new set of axes there:
            plotCtr=[cos(bumpDirs(j)*pi/180),sin(bumpDirs(j)*pi/180)]*.35+[.5 .5];
            offset=[.2,.15]/2;
            plotRect=[plotCtr-offset,2*offset];
            axisID=axes('position',plotRect);
            [histData,histErrs]=ex.units.PESTH(ex.trials.data.bumpTime(trialMask(:,j)),...%use the bumps from trials associated with this bump direction
                                    0.025,...%20ms pre-bump window
                                    0.125,...%200ms post-bump window
                                    ex.binConfig.include(1).which(i),...%we are working on this unit
                                    'useRate',true,...%divide count by bin width
                                    'numBins',[-.025:.025:.125],...
                                    'plotErr',true,...
                                    'useAxis',axisID);
            %now get the count data and store it so we can make our polar
            %tuning plot and return the modulation:  
            modIdx=3;
            modulationData(i,j,:)=[histData.counts(modIdx),histErrs(modIdx)*1.96,mean(histData.counts(3:end))];
        end
        %plot polar tuning circle in the middle:
        axisID=axes('position',[.3,.3,.4,.4]);
        
        
        PDIdx=find(ex.analysis(4).data.chan==ex.units.data(ex.binConfig.include(1).which(i)).chan & ex.analysis(4).data.ID==ex.units.data(ex.binConfig.include(1).which(i)).ID);
        polarTuningPlot(bumpDirs,squeeze(modulationData(i,:,1)),...%direction values and activity values 
                        'CI',[(squeeze(modulationData(i,:,1))'-squeeze(modulationData(i,:,2))') (squeeze(modulationData(i,:,1))'+squeeze(modulationData(i,:,2))')],...%
                        'PD',[ex.analysis(4).data.velDir(PDIdx),ex.analysis(4).data.velDirCI(PDIdx,:)],...
                        'useAxis',axisID)
        
        %add a title by putting a hidden axes with visible title bar on the
        %figure:
        set(H,'NextPlot','add');
        axes;
        H2 = title([ex.units.getUnitName(ex.binConfig.include(1).which(i)),' tuning during bumps. Moddepth: ',num2str(max(squeeze(modulationData(i,:,modIdx)))-min(squeeze(modulationData(i,:,modIdx))))]);
        set(gca,'Visible','off');
        set(H2,'Visible','on'); 
        RDPSaveFig(H,folderpath)
        close(H)
    end
    dataStruct.moveModulationData=modulationData;
    RDPSave(modulationData,'moveModulationData',folderpath)
    %plot the distribution of modulation depths:
    figureList(end+1)=figure;
    set(figureList(end),'Name',['moveModulationDistribution'])
    numPlotPixels=1200;
    set(figureList(end),'Position',[100 100 numPlotPixels numPlotPixels]);
    paperSize=0.2+numPlotPixels/get(figureList(end),'ScreenPixelsPerInch');
    set(figureList(end),'PaperSize',[paperSize,paperSize]);
    H=axes;
    histogram(H,squeeze(max(modulationData(:,:,1),[],2))-min(modulationData(:,:,1),[],2));
    title('distribution of modulation depths')
%% compare PDs
    %plot act vs pass force PD
    figureList(end+1)=figure;
    plot(ex.analysis(1).data.forceDir,ex.analysis(3).data.forceDir,'xk')
    hold on
    p=polyfit(ex.analysis(1).data.forceDir,ex.analysis(3).data.forceDir,1);
    fitRange=[min(ex.analysis(1).data.forceDir),max(ex.analysis(1).data.forceDir)];
    fitLine=polyval(p,fitRange);
    plot(fitRange,fitLine,'r');
    title('Force PD: during reaching vs during bumps')
    ylabel('PD during reach')
    xlabel('PD during bump')
    formatForLee(figureList(end))
    %plot act vs pass vel PD
    figureList(end+1)=figure;
    plot(ex.analysis(2).data.velDir,ex.analysis(4).data.velDir,'xk')
    hold on
    p=polyfit(ex.analysis(2).data.velDir,ex.analysis(4).data.velDir,1);
    fitRange=[min(ex.analysis(2).data.velDir),max(ex.analysis(2).data.velDir)];
    fitLine=polyval(p,fitRange);
    plot(fitRange,fitLine,'r');
    title('Vel PD: during reaching vs during bumps')
    ylabel('PD during reach')
    xlabel('PD during bump')
    formatForLee(figureList(end))
    %plot act move vs force PD
    figureList(end+1)=figure;
    plot(ex.analysis(3).data.forceDir,ex.analysis(4).data.velDir,'xk')
    hold on
    p=polyfit(ex.analysis(3).data.forceDir,ex.analysis(4).data.velDir,1);
    fitRange=[min(ex.analysis(3).data.forceDir),max(ex.analysis(3).data.forceDir)];
    fitLine=polyval(p,fitRange);
    plot(fitRange,fitLine,'r');
    title('Vel PD vs Force PD, during reaching')
    ylabel('vel PD')
    xlabel('force PD')
    formatForLee(figureList(end))
    %plot pass move vs force PD
    figureList(end+1)=figure;
    plot(ex.analysis(1).data.forceDir,ex.analysis(2).data.velDir,'xk')
    hold on
    p=polyfit(ex.analysis(1).data.forceDir,ex.analysis(2).data.velDir,1);
    fitRange=[min(ex.analysis(1).data.forceDir),max(ex.analysis(1).data.forceDir)];
    fitLine=polyval(p,fitRange);
    plot(fitRange,fitLine,'r');
    title('Vel PD vs Force PD, during bumps')
    ylabel('PD during reach')
    xlabel('PD during bump')
    formatForLee(figureList(end))
    
    
    
    