%% move artifact data from processed folders into common folder for processing: 
baseFolder='/media/tucker/My Passport/local processing/Han/experiment_20170519_stimParamGridTesting/CH64/'

topLevelList=dir([baseFolder,'IP*']);

for i=1:numel(topLevelList)
    sublevel1=topLevelList(i).name;
    sublevel1List=dir([baseFolder,sublevel1,'/A*']);%specifying 'A*' excludes '.' and '..'
    disp(['working on: ',sublevel1])
    for j=1:numel(sublevel1List)
        if ~isempty(dir([baseFolder,sublevel1,filesep,sublevel1List(j).name,'/Output_*']))
            disp(['    moving: ',sublevel1List(j).name])
            srcName=[baseFolder,sublevel1,filesep,sublevel1List(j).name,'/Output_Data/','artifactData.mat'];
            destName=[baseFolder,'allArtifacts/',sublevel1List(j).name,'.mat'];
            copyfile(srcName,destName)
        end
    end
end

%% get all artifact data into structure:
sourcefolder='/media/tucker/My Passport/local processing/Han/experiment_20170519_stimParamGridTesting/CH64/allArtifacts/';


fileList=dir([sourcefolder,'A*']);

for i=1:numel(fileList)
    load([sourcefolder,fileList(i).name])%loads data and dummy file
    testData(i).artifactData=artifactData;
    [~,tmp,~]=fileparts(fileList(i).name);
    testConfig=strsplit(tmp,'_');
    for j=1:numel(testConfig)
        if ~isempty(strfind(testConfig{j},'A1-'))
            testData(i).amp1=str2num(testConfig{j}(strfind(testConfig{j},'A1-')+3:end));
        elseif ~isempty(strfind(testConfig{j},'A2-'))
            testData(i).amp2=str2num(testConfig{j}(strfind(testConfig{j},'A2-')+3:end));
        elseif ~isempty(strfind(testConfig{j},'PW1-'))
            testData(i).pulseWidth1=str2num(testConfig{j}(strfind(testConfig{j},'PW1-')+4:end));
        elseif ~isempty(strfind(testConfig{j},'PW2-'))
            testData(i).pulseWidth2=str2num(testConfig{j}(strfind(testConfig{j},'PW2-')+4:end));
        elseif ~isempty(strfind(testConfig{j},'IP-'))
            testData(i).fastSettleTime=str2num(testConfig{j}(strfind(testConfig{j},'IP-')+3:end));
        else
            warning('bad string')
            disp(testConfig{j})
        end
    end
    
    
end
%% extract stim channels from list of all channels

for i=1:numel(testData)
    stimChanTestData(i).amp1=testData(i).amp1;
    stimChanTestData(i).amp2=testData(i).amp2;
    stimChanTestData(i).pulseWidth1=testData(i).pulseWidth1;
    stimChanTestData(i).pulseWidth2=testData(i).pulseWidth2;
%     stimChanTestData(i).fastSettleTime=testData(i).fastSettleTime;
    stimChanTestData(i).chanList=[testData(i).artifactData.stimChannel];
    stimChanTestData(i).stimOn=[testData(i).artifactData.stimOn];
    for j=1:numel(testData(i).artifactData)
        stimChanTestData(i).artifact{j}=squeeze(testData(i).artifactData(j).artifact(testData(i).artifactData(j).stimChannel,:,:));
    end
end

%% generate plots for asymmetry:

%% amplitudes:
 % 10,10: 20,20: 50:50
    %find the tests we care about:
    
    testIdx(1)=find([stimChanTestData.amp1]==1 ...
                    & [stimChanTestData.amp2]==1 ...
                    & [stimChanTestData.pulseWidth1]==200 ...
                    & [stimChanTestData.pulseWidth2]==200 ...
                )
    testIdx(2)=find([stimChanTestData.amp1]==5 ...
                    & [stimChanTestData.amp2]==5 ...
                    & [stimChanTestData.pulseWidth1]==200 ...
                    & [stimChanTestData.pulseWidth2]==200 ...
                )
    testIdx(3)=find([stimChanTestData.amp1]==10 ...
                    & [stimChanTestData.amp2]==10 ...
                    & [stimChanTestData.pulseWidth1]==200 ...
                    & [stimChanTestData.pulseWidth2]==200 ...
                )
    testIdx(4)=find([stimChanTestData.amp1]==20 ...
                    & [stimChanTestData.amp2]==20 ...
                    & [stimChanTestData.pulseWidth1]==200 ...
                    & [stimChanTestData.pulseWidth2]==200 ...
                )
    testIdx(5)=find([stimChanTestData.amp1]==50 ...
                    & [stimChanTestData.amp2]==50 ...
                    & [stimChanTestData.pulseWidth1]==200 ...
                    & [stimChanTestData.pulseWidth2]==200 ...
                )
    %find number of channels
    
    nChan=numel(stimChanTestData(1).chanList);
    %for every channel
    for i=1:nChan
        %make a figure
        H1=figure;
        %make a subplot for each amp test:
        for j=1:numel(testIdx)
            %extract relevant artifact:
%             artifactData=stimChanTestData(testIdx(j)).artifact{i}';
            %plot extracted artifact:
            timeVec=[-5:size(artifactData,1)-6]'/30;
            subplot(numel(testIdx),1,j)
            plot(timeVec,squeeze(artifactData(:,1:2:end))*8/1000,'r')
            hold on
            plot(timeVec,squeeze(artifactData(:,2:2:end))*8/1000,'b')
            title([num2str(stimChanTestData(testIdx(j)).amp1),'uA, ', num2str(stimChanTestData(testIdx(j)).pulseWidth1),'us pulses'])
        end
        set(gcf,'NextPlot','add');
        axes;
%         h = title(['CH: ',num2str(stimChanTestData(i).chanList(i)),' symmetric pulse artifact']);
        set(gca,'Visible','off');
        set(H1,'Visible','on'); 
    end
        
%% assymmetry
 % leading stable group:
 %50 50, 50 25, 50 20, 50 10testIdx(1)=find([stimChanTestData.amp1]==10 & ...
    testIdx(1)=find([stimChanTestData.amp1]==50 & ...
                    [stimChanTestData.amp2]==10 )
    testIdx(2)=find([stimChanTestData.amp1]==50 & ...
                    [stimChanTestData.amp2]==20 )
    testIdx(3)=find([stimChanTestData.amp1]==50 & ...
                    [stimChanTestData.amp2]==25 )
    testIdx(4)=find([stimChanTestData.amp1]==50 & ...
                    [stimChanTestData.amp2]==50 )
    %find number of channels
    nChan=numel(stimChanTestData(1).chanList);
    %for every channel
    for i=1:nChan
        %make a figure
        H1=figure;
        %make a subplot for each amp test:
        for j=1:numel(testIdx)
            %extract relevant artifact:
            artifactData=stimChanTestData(testIdx(j)).artifact{i}';
            %plot extracted artifact:
            timeVec=[-5:size(artifactData,1)-6]'/30;
            subplot(numel(testIdx),1,j)
            plot(timeVec,squeeze(artifactData(:,1:2:end))*8/1000,'r')
            hold on
            plot(timeVec,squeeze(artifactData(:,2:2:end))*8/1000,'b')
            title([num2str(stimChanTestData(testIdx(j)).amp1),'uA, ', num2str(stimChanTestData(testIdx(j)).pulseWidth1),'us ',num2str(stimChanTestData(testIdx(j)).amp2),'uA, ', num2str(stimChanTestData(testIdx(j)).pulseWidth2),'us pulses'])
        end
        set(gcf,'NextPlot','add');
        axes;
        h = title(['CH: ',num2str(stimChanTestData(i).chanList(i)),' asymmetric pulse artifact']);
        set(gca,'Visible','off');
        set(h,'Visible','on'); 
    end
 % trailing stable group:
 %50 50, 25 50, 20 50, 10 50
 testIdx(1)=find([stimChanTestData.amp1]==10 & ...
                    [stimChanTestData.amp2]==50)
    testIdx(2)=find([stimChanTestData.amp1]==20 & ...
                    [stimChanTestData.amp2]==50)
    testIdx(3)=find([stimChanTestData.amp1]==25 & ...
                    [stimChanTestData.amp2]==50  )
    testIdx(4)=find([stimChanTestData.amp1]==50 & ...
                    [stimChanTestData.amp2]==50  )
    %find number of channels
    nChan=numel(stimChanTestData(1).chanList);
    %for every channel
    for i=1:nChan
        %make a figure
        H1=figure;
        %make a subplot for each amp test:
        for j=1:numel(testIdx)
            %extract relevant artifact:
            artifactData=stimChanTestData(testIdx(j)).artifact{i}';
            %plot extracted artifact:
            timeVec=[-5:size(artifactData,1)-6]'/30;
            subplot(numel(testIdx),1,j)
            plot(timeVec,squeeze(artifactData(:,1:2:end))*8/1000,'r')
            hold on
            plot(timeVec,squeeze(artifactData(:,2:2:end))*8/1000,'b')
            title([num2str(stimChanTestData(testIdx(j)).amp1),'uA, ', num2str(stimChanTestData(testIdx(j)).pulseWidth1),'us ',num2str(stimChanTestData(testIdx(j)).amp2),'uA, ', num2str(stimChanTestData(testIdx(j)).pulseWidth2),'us pulses'])
        end
        set(gcf,'NextPlot','add');
        axes;
        h = title(['CH: ',num2str(stimChanTestData(i).chanList(i)),' asymmetric pulse artifact']);
        set(gca,'Visible','off');
        set(h,'Visible','on'); 
    end
 %unstable:
%normalize by charge delivered?

%% imbalance