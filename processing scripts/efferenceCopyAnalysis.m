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
    ex.bin.dimReductionConfig.windows=[moveTime-.4,moveTime-.2];
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
    for i=1:3:numel(tgtDirList)*3
        legendStrings{i}=[num2str(tgtDirList((i+2)/3)),'deg correct'];
        legendStrings{i+1}=[num2str(tgtDirList((i+2)/3)),'deg error'];
        legendStrings{i+2}='';
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
    %get perfromance of matlab builtin functions:
    [~,outputData.classData.classifyErr]=classify(DRData,DRData,tgtDir);
    discrModel=fitcdiscr(DRData,tgtDir);
    pred=predict(discrModel,DRData);
    outputData.classData.fitdiscrErr=sum(pred==tgtDir)/numel(tgtDir);
    %do tuckers wonky classifier:
    [outputData.classData,outputData.plotData]=likelihoodClassify(DRData,tgtDir);
    outputFigures(end+1)=plotClassData(outputData.plotData.reducedData,outputData.classData.class,'correct',outputData.classData.fullModelCorrect,'legend',legendStrings,'title','Pre-Move: clusters in log-likelihood ratio space for full neural analysis','name','unreducedClusters');
    disp(['fit full data with success rate: ',num2str(outputData.classData.fullModelCorrect), ' and overfitting rate: ',num2str(outputData.classData.overfit)])

    
    %% run PCA    
    ex.bin.fitPCA('MachensFloor',tgts);
    ex.analysis(end).notes='full data PCA';
    PCDRData=[DRData(:,2:end)*ex.analysis(end).data.coeff(:,ex.analysis(end).data.MachensFloor.goodPC)];
    numPCFeatures=sum(ex.analysis(end).data.MachensFloor.goodPC);
    PCNoise=ex.analysis(end).data.MachensFloor.noise;%for use with PPC and FA analysis
    
    %get perfromance of matlab builtin functions:
    [~,outputData.PCClassData.classifyErr]=classify(PCDRData,PCDRData,tgtDir);
    discrModel=fitcdiscr(PCDRData.tgtDir);
    pred=predict(discrModel,PCDRData);
    outputData.PCClassData.fitdiscrErr=sum(pred==tgtDir)/numel(tgtDir);
    %do tucker's wonky classifier:
    [outputData.PCClassData,outputData.PCPlotData]=likelihoodClassify(PCDRData(:,ex.analysis(end).data.MachensFloor.goodPC),tgtDir);
    outputFigures(end+1)=plotClassData(outputData.PCPlotData.reducedData,outputData.PCClassData.class,'correct',outputData.PCClassData.fullModelCorrect,'legend',legendStrings,'title','Pre-Move: clusters in log-likelihood ratio space for PC analysis','name','PCClusters');
    disp(['fit PCA Machens reduced data with success rate: ',num2str(outputData.PCClassData.fullModelCorrect), ' and overfitting rate: ',num2str(outputData.PCClassData.overfit)])
    

%     %% run PPCA
%     ex.bin.fitPPCA();
%     ex.analysis(end).notes='full data PPCA';
%     
%     %get mask for PPC's based on which eigenvaluse exceed the noise floor:
%     PPCmask=ex.analysis(end).data.latent>(PCNoise(1:numel(ex.analysis(end).data.latent)));
%     disp(['found ',num2str(sum(PPCmask)),' PPCs with eigenvalues above the noise floor']);
%     %convert DRData into PPCA space
%     PPCDRData=ex.analysis(end).data.stats.Recon;
%     PPCDRData=PPCDRData(:,PPCmask);
%     
%     %get perfromance of matlab builtin functions:
%     [~,outputData.PPCClassData.classifyErr]=classify(PPCDRData,PPCDRData,tgtDir);
%     discrModel=fitcdiscr(PPCDRData,tgtDir);
%     pred=predict(discrModel,PPCDRData);
%     outputData.PPCClassData.fitdiscrErr=sum(pred==tgtDir)/numel(tgtDir);
%     %do tucker's wonky classifier:
%     [outputData.PPCClassData,outputData.PPCPlotData]=likelihoodClassify(PPCDRData,tgtDir);
%     outputFigures(end+1)=plotClassData(outputData.PPCPlotData.reducedData,outputData.PPCClassData.class,'correct',outputData.PPCClassData.fullModelCorrect,'legend',legendStrings,'title','Pre-Move: clusters in log-likelihood ratio space for PPC analysis','name','PPCClusters');
%     disp(['fit PPCA reduced data with success rate: ',num2str(outputData.PPCClassData.fullModelCorrect), ' and overfitting rate: ',num2str(outputData.PPCClassData.overfit)])
% 
%     
%     %% run FA
%     ex.bin.dimReductionConfig.dimension=numPCFeatures;
%     ex.bin.fitFA();
%     ex.analysis(end).notes='Factor Analysis';
%     
%     FAData=[ex.analysis(end).data.F];%factor loadings
%         
%     %get perfromance of matlab builtin functions:
%     [~,outputData.FAClassData.classifyErr]=classify(FAData,FAData,tgtDir);
%     discrModel=fitcdiscr(FAData,tgtDir);
%     pred=predict(discrModel,FAData);
%     outputData.FAClassData.fitdiscrErr=sum(pred==tgtDir)/numel(tgtDir);
%     %do tucker's wonky classifier:
%     [outputData.FAClassData,outputData.FAPlotData]=likelihoodClassify(FAData,tgtDir);
%     outputFigures(end+1)=plotClassData(outputData.FAPlotData.reducedData,outputData.FAClassData.class,'correct',outputData.FAClassData.fullModelCorrect,'legend',legendStrings,'title','Pre-Move: clusters in log-likelihood ratio space for Factor analysis','name','FAClusters');
%     disp(['fit FA reduced data with success rate: ',num2str(outputData.FAClassData.fullModelCorrect), ' and overfitting rate: ',num2str(outputData.FAClassData.overfit)])
% 
%     
    %% run DPCA:
    %construct class table:
    
    %% re-run analyses on movment data:
    %% set up dimensionality reduction configuration                                
    ex.bin.dimReductionConfig.windows=[moveTime+.1,moveTime+.3];
    
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
    [outputData.moveClassData,outputData.movePlotData]=likelihoodClassify(DRData,tgtDir);
    outputFigures(end+1)=plotClassData(outputData.movePlotData.reducedData,outputData.moveClassData.class,'correct',outputData.moveClassData.fullModelCorrect,'legend',legendStrings,'title','During-Move: clusters in log-likelihood ratio space for full neural analysis','name','unreducedClusters');
    
    %% run PCA    
    ex.bin.fitPCA('MachensFloor',tgts);
    ex.analysis(end).notes='full data PCA';

    PCDRData=[DRData(:,2:end)*ex.analysis(end).data.coeff(:,ex.analysis(end).data.MachensFloor.goodPC)];
    numPCFeatures=sum(ex.analysis(end).data.MachensFloor.goodPC);
    PCNoise=ex.analysis(end).data.MachensFloor.noise;%for use with PPC and FA analysis
    
    [outputData.movePCClassData,outputData.movePCPlotData]=likelihoodClassify(PCDRData(:,ex.analysis(end).data.MachensFloor.goodPC),tgtDir);
    outputFigures(end+1)=plotClassData(outputData.movePCPlotData.reducedData,outputData.movePCClassData.class,'correct',outputData.movePCClassData.fullModelCorrect,'legend',legendStrings,'title','During-Move: clusters in log-likelihood ratio space for PC analysis','name','PCClusters');
    
%      
%     %% run PPCA
%     ex.bin.fitPPCA();
%     ex.analysis(end).notes='full data PPCA';
%     
%     %get mask for PPC's based on which eigenvaluse exceed the noise floor:
%     PPCmask=ex.analysis(end).data.latent>(PCNoise(1:numel(ex.analysis(end).data.latent)));
%     disp(['found ',num2str(sum(PPCmask)),' PPCs with eigenvalues above the noise floor']);
%     %convert DRData into PPCA space
%     PPCDRData=ex.analysis(end).data.stats.Recon;
%     PPCDRData=PPCDRData(:,PPCmask);
%     
%     [outputData.movePPCClassData,outputData.movePPCPlotData]=likelihoodClassify(PPCDRData,tgtDir);
%     outputFigures(end+1)=plotClassData(outputData.movePPCPlotData.reducedData,outputData.movePPCClassData.class,'correct',outputData.movePPCClassData.fullModelCorrect,'legend',legendStrings,'title','During-Move: clusters in log-likelihood ratio space for PPC analysis','name','PPCClusters');
% 
%     
%     %% run FA
%     ex.bin.dimReductionConfig.dimension=numPCFeatures;
%     ex.bin.fitFA();
%     ex.analysis(end).notes='Factor Analysis';
%     
%     FAData=[ex.analysis(end).data.F];%factor loadings
%     
%     [outputData.moveFAClassData,outputData.moveFAPlotData]=likelihoodClassify(FAData,tgtDir);
%     outputFigures(end+1)=plotClassData(outputData.moveFAPlotData.reducedData,outputData.moveFAClassData.class,'correct',outputData.moveFAClassData.fullModelCorrect,'legend',legendStrings,'title','During-Move: clusters in log-likelihood ratio space for Factor analysis','name','FAClusters');

    
    %% move objects into outputs
    outputData.cds=cds;
    outputData.ex=ex;
end