function [figureList,outputData]=checkCVEffect(baseFolder,inputData)
    figureList=[];

%% establish strings that we will use to parse filenames
    preCVLabel='_1_';
    postCVLabel='_2_';
    
    evenChannels='2_EIS_';
    oddChannels='1_EIS_';

%% get list of folders within main folder and parse them as pre or post CV
    folderList=dir([baseFolder,'*_EIS_*']);
    folderNames={folderList.name};
    preNames=folderNames(~cellfun(@isempty, strfind(folderNames,'_1_')));
    postNames=folderNames(~cellfun(@isempty, strfind(folderNames,'_2_')));
    
%% work on EIS data collected prior to CV
    %load pre-CV EIS data into array of tables:
    postData=[];
    for i=1:numel(postNames)
        fileList=dir([baseFolder,postNames{i},filesep,'*_eis.csv']);
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
        
            postData(end+1).cerebusChan=pinInBank+bankNum*32;
            postData(end).EIS=readtable([baseFolder,postNames{i},filesep,fileNames{j}]);
        end
    end

%% work on EIS data collected after CV
    %load post-CV EIS data into array of tables
    preData=[];
    for i=1:numel(preNames)
        fileList=dir([baseFolder,preNames{i},filesep,'*_eis.csv']);
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

            preData(end+1).cerebusChan=pinInBank+bankNum*32;
            preData(end).EIS=readtable([baseFolder,preNames{i},filesep,fileNames{j}]);
        end
    end
%% generate list of change in impedance (per freq?)

for i=1:numel(postNames)
    %find the matching channel in preData:
    preIdx=[preData.cerebusChan]==postData(i).cerebusChan;
    %get the change in impedance and phase and put them into matrices for
    %plotting
    impChange(i,:)=log(preData(preIdx).EIS.mag)-log(postData(i).EIS.mag);
    phaseChange(i,:)=preData(preIdx).EIS.phase-postData(i).EIS.phase;
end

figureList(end+1)=figure;subplot(2,1,1),boxplot(impChange,round(postData(1).EIS.freq));set(gca,'XTickLabelRotation',90)
title('Change in log impedance')
xlabel('frequency(Hz)')
ylabel('change in log impendance')

subplot(2,1,2),boxplot(phaseChange,round(postData(1).EIS.freq));set(gca,'XTickLabelRotation',90)
title('phase changes')
xlabel('frequency(Hz)')
ylabel('change in phase')



%dump variables into output data:
outputData.preCV=preData;
outputData.postCV=postData;
outputData.impChange=impChange;
outputData.phaseChange=phaseChange;







