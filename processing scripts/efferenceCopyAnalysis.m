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
    fileList=dir('*.nev');
    if RDPIsAlreadyDone('cds',folderpath) && (~isfield(inputData,'forceReload') || ~inputData.forceReload)
        warning('processStimArtifact:foundExistingData','loading data from previous processing. This will have the PREVIOUS settings for time window, presample etc')
        cds =RDPLoadExisting('cds',folderpath);
    else
        for i=1:numel(fileList)
            %% load file
            disp(['working on:'])
            disp(fileList(i).name)
            cds=commonDataStructure();
%             cds.file2cds([folderpath,fileList(i).name],inputData.ranBy,inputData.array1,inputData.monkey,inputData.lab,'ignoreJumps',inputData.task,inputData.mapFile,'recoverPreSync');
            cds.file2cds([folderpath,fileList(i).name],inputData.ranBy,inputData.array1,inputData.monkey,inputData.lab,'ignoreJumps',inputData.task,inputData.mapFile);
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
    ex.firingRateConfig.sampleRate = 10;
    ex.firingRateConfig.kernelWidth=1/10;
    ex.binConfig.include(1).field='units';
    ex.binConfig.include(1).which=find([ex.units.data.ID]>0 & [ex.units.data.ID]<255);
    ex.binConfig.include(2).field='kin';
        ex.binConfig.include(2).which={};
    ex.binConfig.include(3).field='force';
        ex.binConfig.include(3).which={};
    ex.binConfig.filterConfig.sampleRate=10;
    ex.binConfig.filterConfig.cutoff=5;
    
    ex.binData('recalcFiringRate')
        
    %% find move onset and establish windows from 300-50ms prior to move onset
    ex.getMoveStart();
       
    moveTime=ex.trials.data.moveTime(~isnan(ex.trials.data.moveTime) & ...  %only look at trials that have a move time
                                        ~isnan(ex.trials.data.tgtDir) & ... %only look at trials that have a target direction
                                        ~ex.trials.data.delayBump);         %only look at trials that do not have a bump during the delay period
                                    
    %% set up dimensionality reduction configuration                                
    ex.bin.dimReductionConfig.windows=[moveTime-.4,moveTime-.3];
    ex.bin.dimReductionConfig.which=12:numel(find([ex.units.data.ID]>0 & [ex.units.data.ID]<255 ))+11;
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
    for i=1:2:numel(tgtDirList)*2
        legendStrings{i}=[num2str(tgtDirList((i+1)/2)),'deg correct'];
        legendStrings{i+1}=[num2str(tgtDirList((i+1)/2)),'deg error'];
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
    
    %% run PCA    
    if inputData.rootTransform
        ex.bin.fitPCA('MachensFloor',tgts,'rootTransform',true);
        ex.analysis(end).notes='full data PCA, root transform firing rates';
    else
        ex.bin.fitPCA('MachensFloor',tgts,'rootTransform',false);
        ex.analysis(end).notes='full data PCA, non-transformed firing rates';
    end

    PCDRData=[DRData(:,2:end)*ex.analysis(end).data.coeff(:,ex.analysis(end).data.MachensFloor.goodPC)];
    numPCFeatures=sum(ex.analysis(end).data.MachensFloor.goodPC);
    PCNoise=ex.analysis(end).data.MachensFloor.noise;%for use with PPC and FA analysis
    
    [outputData.PCClassData,outputData.PCPlotData]=likelihoodClassify(PCDRData(:,ex.analysis(end).data.MachensFloor.goodPC),tgtDir);
    outputFigures(end+1)=plotLikelihoodClassData(outputData.PCClassData,outputData.PCPlotData,'legend',legendStrings,'title','clusters in log-likelihood ratio space for PC analysis','name','PCClusters');
    
     
    %% run PPCA
    ex.bin.fitPPCA();
    
    %get mask for PPC's based on which eigenvaluse exceed the noise floor:
    PPCmask=ex.analysis(end).data.latent>(PCNoise(1:numel(ex.analysis(end).data.latent)));
    disp(['found ',num2str(sum(PPCmask)),' PPCs with eigenvalues above the noise floor']);
    %convert DRData into PPCA space
    PPCDRData=ex.analysis(end).data.stats.Recon;
    PPCDRData=PPCDRData(:,PPCmask);
    
    [outputData.PPCClassData,outputData.PPCPlotData]=likelihoodClassify(PPCDRData,tgtDir);
    outputFigures(end+1)=plotLikelihoodClassData(outputData.PPCClassData,outputData.PPCPlotData,'legend',legendStrings,'title','clusters in log-likelihood ratio space for PPC analysis','name','PPCClusters');

    
    %% run FA
    ex.bin.dimReductionConfig.dimension=numPCFeatures;
    ex.bin.fitFA();
    
    FAData=[ex.analysis(end).data.F];%factor loadings
    
    [outputData.FAClassData,outputData.FAPlotData]=likelihoodClassify(FAData,tgtDir);
    outputFigures(end+1)=plotLikelihoodClassData(outputData.FAClassData,outputData.FAPlotData,'legend',legendStrings,'title','clusters in log-likelihood ratio space for Factor analysis','name','FAClusters');

    %% move objects into outputs
    outputData.cds=cds;
    outputData.ex=ex;
end