baseDir='/media/tucker/My Passport/local processing/stimTesting/20170710_RC/';


A1List=[1,5,10,20,25,50,50,50,50,50                ];
A2List=[50,50,50,50,50,1,5,10,20,25                ];
PW1List=[10000,2000,1000,500,400,200,200,200,200,200];
PW2List=[200,200,200,200,200,10000,2000,1000,500,400];

A1List=[A1List,[ 1,5,10,20,50]];
A2List=[A2List, [ 1,5,10,20,50]];
PW1List=[PW1List, [200,200,200,200,200]];
PW2List=[PW2List, [200,200,200,200,200]];

A1List=[A1List,[50,50,50,50,50,50,50,50 ]];
A2List=[A2List, [50,50,50,50,50,50,50,50 ]];
PW1List=[PW1List, [196 197 198 199 200 200 200 200 ]];
PW2List=[PW2List, [200 200 200 200 196 197 198 199 ]];

A1List=[A1List,[49,48,47,46,45,50,50,50,50,50 ]];
A2List=[A2List, [50,50,50,50,50,49,48,47,46,45 ]];
PW1List=[PW1List, [200,200,200,200,200,200,200,200,200,200 ]];
PW2List=[PW2List, [200,200,200,200,200,200,200,200,200,200 ]];

for i=1:numel(A1List)
    subDir=['A1-',num2str(A1List(i)),'_A2-',num2str(A2List(i)),'_PW1-',num2str(PW1List(i)),'_PW2-',num2str(PW2List(i)),filesep];
%     mkdir(baseDir,subDir)
    files=dir(baseDir);
    for j=1:numel(files)
        %parse filename:
        tmpName=files(j).name;
        A1st=strfind(tmpName,'_A1-');
        A2st=strfind(tmpName,'_A2-');
        PW1st=strfind(tmpName,'_PW1-');
        PW2st=strfind(tmpName,'_PW2-');
        IPst=strfind(tmpName,'_interpulse');
        IPen=strfind(tmpName,'_2017_')-1;
        chanst=strfind(tmpName,'__chan');
        chanen=strfind(tmpName,'stim_')-1;
        
        A1=str2num(tmpName(A1st+4:A2st-1));
        A2=str2num(tmpName(A2st+4:PW1st-1));
        PW1=str2num(tmpName(PW1st+5:PW2st-1));
        PW2=str2num(tmpName(PW2st+5:IPst-1));
        
        if (~isempty(A1) && A1==A1List(i) && ...
           ~isempty(A2) && A2==A2List(i) && ...
           ~isempty(PW1) && PW1==PW1List(i) && ...
           ~isempty(PW2) && PW2==PW2List(i)  )
            %put the file into our new subdirectories:
            IPDir=['IP',tmpName(IPst+11:IPen),filesep];
            chanDir=['CH',tmpName(chanst+6:chanen),filesep];
            newDir=[baseDir,IPDir,chanDir,subDir];
            if ~(exist(newDir,'dir')==7)
                mkdir([baseDir,IPDir,chanDir],subDir)
            end
            
            movefile([baseDir,tmpName], [newDir,tmpName]);
        else
            %this isn't a matching file, so skip it
            continue
        end
    end
end