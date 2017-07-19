baseFolder='/media/tucker/My Passport/local processing/stimTesting/20170512_Saline/'

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