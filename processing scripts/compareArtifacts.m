function [outputFigures,outputData]=compareArtifacts(folderpath,inputData)
    outputFigures=[];
    outputData=[];
    multiStimData=load(inputData.multiStimFile);
    singleStimData=load(inputData.singleStimFile);
    

    %get mean artifact out of multiStimData
    invertMask=ones(1,size(multiStimData.artifactData.artifact,2),1);
    invertMask(logical(mod(1:numel(invertMask),2)))=-1;
    invertMask=repmat(invertMask,[size(multiStimData.artifactData.artifact,1),1,size(multiStimData.artifactData.artifact,3)]);
    artifact=multiStimData.artifactData.artifact.*invertMask;
    artifact=artifact-repmat(artifact(:,:,1),[1,1,size(artifact,3)]);
    multiStimArtifact=squeeze(mean(artifact,2));
    outputData.multiStimArtifact=multiStimArtifact;

    %get the single stim artifacts
    invertMask=ones(1,size(singleStimData.artifactData(1).artifact,2),1);
    invertMask(logical(mod(1:numel(invertMask),2)))=-1;
    invertMask=repmat(invertMask,[size(singleStimData.artifactData(1).artifact,1),1,size(singleStimData.artifactData(1).artifact,3)]);
    for i=1:numel(singleStimData.artifactData)
        artifact=singleStimData.artifactData(i).artifact.*invertMask;
        artifact=artifact-repmat(artifact(:,:,1),[1,1,size(artifact,3)]);
        singleStimArtifact(:,:,i)=squeeze(mean(artifact,2));
    end
    singleStimArtifact=sum(singleStimArtifact,3);
    outputData.singleStimArtifact=singleStimArtifact;
    %get mapdata:
    load(inputData.posList)%should create a variable named posList 
    load(inputData.eList)%should create a variable named posList 
    
    %plot both artifacts on the same axes:
    
    outputFigures(end+1)=figure;
    set(outputFigures(end),'Name',['artifactComparison'])
    numPlotPixels=1200;
    set(outputFigures(end),'Position',[100 100 numPlotPixels numPlotPixels]);
    paperSize=0.2+numPlotPixels/get(outputFigures(end),'ScreenPixelsPerInch');
    set(outputFigures(end),'PaperSize',[paperSize,paperSize]);
    for i=1:size(singleStimArtifact,1)
        posIdx=find(strcmp(eList,multiStimData.artifactData.electrodeNames{i}));
        eRow=posList(posIdx,1);
        eCol=posList(posIdx,2);
        h=subplot(10,10,10*(eRow-1)+eCol);
        plot(multiStimArtifact(i,:),'k')
        hold on
        plot(singleStimArtifact(i,:),'r');
        %add line @ 1ms:
        plot([1,1]*(inputData.presample+30),[8000,-8000],'g')
        %add line @ 1.5ms:
        plot([1,1]*(inputData.presample+45),[8000,-8000],'b')
        axis tight%keeps from padding time, we will set y axis below:
        ylim([-inputData.plotRange,inputData.plotRange]*1000);
        set(gca,'XTickLabel',[])
        set(gca,'YTickLabel',[])
    end
    
    
    %plot difference between artifacts:
    outputFigures(end+1)=figure;
    set(outputFigures(end),'Name',['artifactDiff'])
    numPlotPixels=1200;
    set(outputFigures(end),'Position',[100 100 numPlotPixels numPlotPixels]);
    paperSize=0.2+numPlotPixels/get(outputFigures(end),'ScreenPixelsPerInch');
    set(outputFigures(end),'PaperSize',[paperSize,paperSize]);
    for i=1:size(singleStimArtifact,1)
        posIdx=find(strcmp(eList,multiStimData.artifactData.electrodeNames{i}));
        eRow=posList(posIdx,1);
        eCol=posList(posIdx,2);
        h=subplot(10,10,10*(eRow-1)+eCol);
        plot(multiStimArtifact(i,:)-singleStimArtifact(i,:),'k')
        hold on
        %add line @ 1ms:
        plot([1,1]*(inputData.presample+30),[8000,-8000],'g')
        %add line @ 1.5ms:
        plot([1,1]*(inputData.presample+45),[8000,-8000],'b')
        axis tight%keeps from padding time, we will set y axis below:
        ylim([-inputData.plotRange,inputData.plotRange]*1000);
        set(gca,'XTickLabel',[])
        set(gca,'YTickLabel',[])
    end
    
end