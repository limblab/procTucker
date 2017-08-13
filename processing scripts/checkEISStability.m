function [figureList,outputData]=checkEISStability(baseFolder,inputData)
    figureList=[];

%% establish strings that we will use to parse filenames

    evenChannels='2_EIS_';
    oddChannels='1_EIS_';

%% get list of folders within main folder and parse them as pre or post CV
    folderList=dir([baseFolder,'*_EIS_*']);
    folderNames={folderList.name};
    
%% get data out of sub-folders and into an array of tables:
    %load pre-CV EIS data into array of tables:
    data=[];
    for i=1:numel(folderNames)
        fileList=dir([baseFolder,folderNames{i},filesep,'*_eis.csv']);
        fileNames={fileList.name};
        for j=1:numel(fileNames)
            disp(['workin on: ',fileNames{j}])
            %parse file-name to get cerebus channel#
            endIdx=strfind(fileNames{j},'_eis.csv')-1;
            startList=strfind(fileNames{j}(1:endIdx),'_E');
            startIdx=startList(end)+2;
            MET16Chan=str2num(fileNames{j}(startIdx:endIdx));
            if ~isempty(strfind(fileNames{j},evenChannels))
                pinInBank=MET16Chan*2;
                bankID=fileNames{j}(strfind(fileNames{j},evenChannels)-1);            

            elseif ~isempty(strfind(fileNames{j},oddChannels))
                pinInBank=MET16Chan*2-1;
                bankID=fileNames{j}(strfind(fileNames{j},oddChannels)-1);
            else
                error('checkCVEffect:couldNotDetermineEvenOdd','could not identify whether this file is from an even or odd bank')
            end

            switch bankID
                case 'A'
                    bankNum=0;
                case 'B'
                    bankNum=1;
                case 'C'
                    bankNum=2;
                otherwise
                    error('checkCVEffect:unrecognizedBank','did not exctract a recognized bank label from the file name')
            end
        
            data(i,j).cerebusChan=pinInBank+bankNum*32;
            data(i,j).EIS=readtable([baseFolder,folderNames{i},filesep,fileNames{j}]);
        end
    end


%% convert our cell array of tables into an array of impedances and an array of phases
impFigH=figure;
        numPlotPixels=1800;
        set(impFigH,'Position',[100 100 numPlotPixels numPlotPixels]);
        paperSize=0.2+numPlotPixels/get(impFigH,'ScreenPixelsPerInch');
        set(impFigH,'PaperSize',[paperSize,paperSize]);
phaseFigH=figure;
        set(phaseFigH,'Position',[100 100 numPlotPixels numPlotPixels]);
        paperSize=0.2+numPlotPixels/get(phaseFigH,'ScreenPixelsPerInch');
        set(phaseFigH,'PaperSize',[paperSize,paperSize]);
plotIdx=1;
for i=1:numel(fileNames)        
    %get data for an electrode from all the different runs into a single 
    %array:
    for j=1:numel(folderNames)
        eImpData(:,j)=log10(data(j,i).EIS.mag);
        ePhaseData(:,j)=data(j,i).EIS.phase;
    end
            
    %box-plot data for this electrode:
    figure(impFigH);
    subplot(4,4,plotIdx),boxplot(eImpData',round(data(1).EIS.freq));
    set(gca,'XTickLabelRotation',90)
%     title('Change in log impedance')
%     xlabel('frequency(Hz)')
%     ylabel('change in log impendance')
    figure(phaseFigH);
    subplot(4,4,plotIdx),boxplot(ePhaseData',round(data(1).EIS.freq));
    set(gca,'XTickLabelRotation',90)
%     title('phase changes')
%     xlabel('frequency(Hz)')
%     ylabel('change in phase')
    plotIdx=plotIdx+1;
end


figureList(end+1)=impFigH;
figureList(end+1)=phaseFigH;



%dump variables into output data:
outputData.postCV=data;







