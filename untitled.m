folder='/media/tucker/My Passport/local processing/stimTesting/20180128_grp2/IP10000/';

tmp=dir(folder);
folderNames={tmp.name};

outputDataPath='A1-50_A2-50_PW1-200_PW2-200/Output_Data/';
artifactString='artifactData.mat';
channelString='chList.mat';
stimChanList=[1:7:2:31];
chanResistorList=[1.000 10.0 1.000 10.0 1.000 10.0 1.000 2.740 2.740 2.740 3.920 3.920 3.920 4.990 4.990 4.990 5.620 5.620 5.620];


StimChanArtifactData=[];
for i=3:numel(folderNames)
    %load artifact data
    load([folder,folderNames{i},filesep,outputDataPath,artifactString])
    load([folder,folderNames{i},filesep,outputDataPath,channelString])
    %find the artifact assoicated with the stim channel:
    chIdx=find(chList==artifactData.stimChannel);
    ch4Idx=find(chList==4);
    ch2Idx=find(chList==2);
    StimChanArtifactData(numel(StimChanArtifactData)+1).chan=artifactData.stimChannel;
    StimChanArtifactData(end).artifact=squeeze(artifactData.artifact(chIdx,:,:));
    StimChanArtifactData(end).ch2StimArtifact=squeeze(artifactData.artifact(ch2Idx,:,:));
    StimChanArtifactData(end).ch4StimArtifact=squeeze(artifactData.artifact(ch4Idx,:,:));
end




