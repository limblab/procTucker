function [outputFigures,outputData]=getSNR(folderPath,inputData)


%script to calculate SNR of sorted units when given a sorted nev, and a
%30kNSx




%% load data into cds
    cds=commonDataStructure;
    cds.file2cds([folderPath,inputData.fileName],inputData.ranBy,inputData.array,inputData.monkey,inputData.lab,'ignoreJumps',inputData.task,inputData.mapFile);
%% loop through units and calculate the SNR, variance of units, variance of background, and unit amplitude
    unitList=find(cds.units.ID>0 &&    cds.units.ID<255);
    for i=1:numel(unitList)
        outputData.signalStats(i).ID=cds.units(unitList(i)).ID;
        outputData.signalStats(i).chan=cds.units(unitList(i)).chan;
        %unit Amp
        outputData.signalStats(i).unitAmp=mean(max(cds.units(unitList(i)).spikes.waves)-min(cds.units(unitList(i)).spikes.waves));
        %unit variance
        outputData.signalStats(i).unitVar=var(reshape(cds.units(unitList(i)).spikes.waves,[1,numel(cds.units(unitList(i)).spikes.waves)]));
        %background variance
            %identify correct analog structure:
            colName=['chan',num2str(cds.units(unitList(i)).chan)];
            colIdx=[];
            for j=1:numel(cds.analog)
                chanNames=cds.analog{j}.Properties.VariableNames;
                for k=1:numel(chanNames)
                    if strcmp(colName,chanNames(k));
                        analogIdx=j;
                        colIdx=k;
                    end
                    break
                end
                if ~isempty(colIdx)
                    break
                end
            end
            %convert spikes.ts into index
            indexList=round(cds.units(unitList(i)).spikes.ts/median(diff(cds.analog{analogIdx}.t)));
            %generate mask around all indexes
            waveWindow=[-inputData.preSample:inputData.postSample];
            maskMat=repmat(indexList,[1,length(waveWindow)])+repmat(waveWindow,[length(indexList),1]);
        backgroundMask=true(length(cds.analog{analogIdx}.t),1);    
        backgroundMask(reshape(maskMat,[numel(maskMat),1]))=false;
        outputData.signalStats(i).backgroundVar=var(cds.analog{analogIdx}.(colName)(backgroundMask));
        %SNR
        outputData.signalStats(i).SNR=signalsStats(i).unitVar/signalsStats(i).backgroundVar;
        %channel variance overall
        outputData.signalStats(i).fullBWVar=var(cds.analog{analogIdx}.(colname));
    end
%% generate histograms
    outputFigures=[];
    outputFigures(end+1)=figure;
    hist([outputData.signalStats.unitAmp]);
    set(outputFigures(end),'name','UnitAmplitude')
    title('Unit Amplitude histogram')
    xlabel('uv')
    
    outputFigures=[];
    outputFigures(end+1)=figure;
    hist([outputData.signalStats.unitVar]);
    set(outputFigures(end),'name','UnitVariance')
    title('Unit Variance histogram')
    xlabel('uv')
    
    outputFigures=[];
    outputFigures(end+1)=figure;
    hist([outputData.signalStats.backgroundVar]);
    set(outputFigures(end),'name','Background Variance')
    title('Background Variance histogram')
    xlabel('uv')
    
    outputFigures=[];
    outputFigures(end+1)=figure;
    hist([outputData.signalStats.SNR]);
    set(outputFigures(end),'name','SNR')
    title('SNR histogram')
    xlabel('uv')
    
    outputFigures=[];
    outputFigures(end+1)=figure;
    hist([outputData.signalStats.fullBWVar]);
    set(outputFigures(end),'name','fullBWVar')
    title('full signal variance histogram')
    xlabel('uv')
end