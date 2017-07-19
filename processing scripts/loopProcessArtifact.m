functionName='processStimArtifact';

inputData.task='tasknone';
inputData.ranBy='ranByTucker'; 
inputData.array1='arrayResistor'; 
inputData.monkey='monkeyNone';
%han
inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161112/SN 6251-001459.cmp';
%chips
% inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/SN 6251-001455.cmp';
%chewie
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161205_chewie_PMDStim_PMD-recording/Chewie Left PMd SN 6251-001469.cmp';
%saline
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161020_saline/1025-0370.cmp';
%saline2
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161220_saline/SN 6251-001695.cmp';
inputData.badChList=[];
inputData.windowSize=30*10;%in points. multiply ms by 30 to get points
inputData.presample=5;%in points
inputData.plotRange=0.300;%in mV
inputData.interpulse=.000053;%in s
inputData.lab=6;
inputData.useSyncLabel=[];
inputData.doFilter=false;
inputData.syncLength=.00000200;%in s
inputData.forceReload=true;
inputData.doFigures=false;


baseDir='/media/tucker/My Passport/local processing/stimTesting/20170710_RC/IP0/IP53/CH3/';
folderList=dir([baseDir,'A1*']);

for i=1:numel(folderList)
    %get A1, A2, PW1, PW2 and interpulse from file name/path
    tmpName=folderList(i).name;
    
    A1st=strfind(tmpName,'_A1-');
    A2st=strfind(tmpName,'_A2-');
    PW1st=strfind(tmpName,'_PW1-');
    PW2st=strfind(tmpName,'_PW2-');

    A1=str2num(tmpName(A1st+4:A2st-1));
    A2=str2num(tmpName(A2st+4:PW1st-1));
    inputData.pWidth1=str2num(tmpName(PW1st+5:PW2st-1))*10^-6;
    inputData.pWidth2=str2num(tmpName(PW2st+5:end))*10^-6;

    IPst=strfind(baseDir,[filesep,'IP']);
    IPen=strfind(baseDir,[filesep,'CH']);
    inputData.syncLength=str2num(baseDir(IPst+3:IPen-1))*10^-8;
    dataStruct2 = runDataProcessing(functionName,[baseDir,tmpName],inputData);
    close all
    clear dataStruct2
end