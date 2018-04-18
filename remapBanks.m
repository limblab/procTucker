%script to flip data labels on bank B and bank C data (lines were plugged into wrong amp sockets)


%setup:
workingDir='
archiveDir='



%get list of nev files:
fileList=dir('*.nev');
nameList={fileList.name};
%loop through list:
for i=1:numel(nameList)
    
    %open nev
        nev=openNEV([workingDir,filesep,nameList{i}],'nosave');
        nev2=nev;
    %relable data in nev
    for j=1:numel(nev.MetaTags.ChannelID)
        if (nev.MetaTags.ChannelID(j)>32 && nev.MetaTags.ChannelID(j)<65)
        %fix data recorded in bank B to be labeled as bank C    
            %MetaTags.ChannelID
            nev2.MetaTags.ChannelID(j)=nev.MetaTags.ChannelID(j)+32;
            %ElectrodesInfo
                %ElectrodeID    -> this is just the channel num with a
                %fancy name:
                nev2.electrodesInfo(j).ChannelID=nev2.MetaTags.ChannelID(j);
                %bank:
                nev2.electrodesInfo(j).ConnectorBank='C';
                
            %Data
            mask=nev.Data.Spikes.Electrode==nev.electrodesInfo(j).ChannelID;
            nev2.Data.Spikes.Electrode(mask)=nev2.electrodesInfo(j).ChannelID;
            %IOLabels
        elseif (nev.MetaTags.ChannelID(j)>64 && nev.MetaTags.ChannelID(j)<97)
        %fix data recorded in bank C to be labeled as bank B
            %MetaTags.ChannelID
            nev2.MetaTags.ChannelID(j)=nev.MetaTags.ChannelID(j)-32;
            %ElectrodesInfo
                %ElectrodeID    -> this is just the channel num with a
                %fancy name:
                nev2.electrodesInfo(j).ChannelID=nev2.MetaTags.ChannelID(j);
                %bank:
                nev2.electrodesInfo(j).ConnectorBank='B';
            %Data
            mask=nev.Data.Spikes.Electrode==nev.electrodesInfo(j).ChannelID;
            nev2.Data.Spikes.Electrode(mask)=nev2.electrodesInfo(j).ChannelID;
            %IOLabels
        end
    end
    %sort nev fields so they appear in the correct order:
        %MetaTags.ChannelID
        [nev2.MetaTags.ChannelID,sortMask]=sort(nev2.MetaTags.ChannelID);
        %ElectrodeID
        nev2.ElectrodesInfo=nev2.ElectrodesInfo(sortMask);
        
    %move old nev file
        movefile([workingDir,filesep,nameList{i}],[archiveDir,filesep,nameList{i}])
    %save new nev file
        saveNEV(nev,[workingDir,filesep,nameList{i}])
    %open ns5
        ns5Name=[nameList{i}(1:end-4),'.ns5'];
        ns5=openNSx([workingDir,filesep,ns5Name],'read');
        ns52=ns5;
    %relable data in ns5
    for j=1:numel(ns5.MetaTags.ChannelID)
        if (ns5.MetaTags.ChannelID(j)>32 &&  ns5.MetaTags.ChannelID(j)<65)
        %fix data recorded in bank B to be labeled as bank C   
            %MetaTags.ChannelID 
            ns52.MetaTags.ChannelID(j)=ns5.MetaTags.ChannelID(j)+32;
        elseif (ns5.MetaTags.ChannelID(j)>64 &&  ns5.MetaTags.ChannelID(j)<97)
        %fix data recorded in bank C to be labeled as bank B
            %MetaTags.ChannelID
            ns52.MetaTags.ChannelID(j)=ns5.MetaTags.ChannelID(j)-32;
        end
    end
    %sort ns5 fields so they appear in the correct order:
        %MetaTags.ChannelID
        [ns52.MetaTags.ChannelID,sortMask]=sort(ns52.MetaTags.ChannelID);
        %Data
        for j=1:numel(ns5.Data)
            ns52.Data{j}=ns52.Data{j}(sortMask,:);
        end
    %move old ns5 file
        movefile([archiveDir,filesep,ns5Name],[archiveDir,filesep,ns5Name])
    %save new ns5 file
        saveNSx(ns52,[archiveDir,filesep,ns5Name])
    
end
