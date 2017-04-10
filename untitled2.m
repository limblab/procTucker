%% process stimulation artifacts:
functionName='processStimArtifact';

inputData.task='tasknone';
inputData.ranBy='ranByTucker'; 
inputData.array1='arrayS1'; 
inputData.monkey='monkeyChips';
%han
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161112/SN 6251-001459.cmp';
%chips
inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/SN 6251-001455.cmp';
%chewie
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161205_chewie_PMDStim_PMD-recording/Chewie Left PMd SN 6251-001469.cmp';
%saline
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161020_saline/1025-0370.cmp';
%saline2
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161220_saline/SN 6251-001695.cmp';
inputData.badChList=1:32;
inputData.windowSize=30*5;%in points. multiply ms by 30 to get points
inputData.presample=5;%in points
inputData.plotRange=0.300;%in mV
inputData.interpulse=.0001;%in s
inputData.lab=6;
inputData.useSyncLabel=[];
inputData.doFilter=true;
inputData.syncLength=.000200;%in s
inputData.forceReload=true;

folderbase='/media/tucker/My Passport/local processing/Han/figures for 2017 S1 grant progress report/fastSettle/';
close all
inputData.pWidth1=.0002;
inputData.pWidth2=.0002;
folderpath=[folderbase,'100us/'];
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.interpulse=.00025;


inputData.pWidth1=.0002;
inputData.pWidth2=.0002;
folderpath=[folderbase,'250us/'];
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all



% 
% close all
% inputData.pWidth1=.0002;
% inputData.pWidth2=.0002;
% folderpath=[folderbase,'200-200us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
% 
% close all
% inputData.pWidth1=.000196;
% inputData.pWidth2=.0002;
% folderpath=[folderbase,'196-200us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
% 
% close all
% inputData.pWidth1=.000192;
% inputData.pWidth2=.0002;
% folderpath=[folderbase,'192-200us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
% 
% close all
% inputData.pWidth1=.000188;
% inputData.pWidth2=.0002;
% folderpath=[folderbase,'188-200us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
% 
% 
% close all
% inputData.pWidth1=.0002;
% inputData.pWidth2=.000196;
% folderpath=[folderbase,'200-196us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
% 
% close all
% inputData.pWidth1=.0002;
% inputData.pWidth2=.000192;
% folderpath=[folderbase,'200-192us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
% close all
% inputData.pWidth1=.0002;
% inputData.pWidth2=.000188;
% folderpath=[folderbase,'200-188us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);

% 
% close all
% inputData.pWidth1=.000196;
% inputData.pWidth2=.000196;
% folderpath=[folderbase,'50uA196us-50uA196us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
% 
% close all
% inputData.pWidth1=.000196;
% inputData.pWidth2=.0002;
% folderpath=[folderbase,'50uA196us-49uA200us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
% 
% close all
% inputData.pWidth1=.000192;
% inputData.pWidth2=.000192;
% folderpath=[folderbase,'50uA192us-50uA192us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
% 
% close all
% inputData.pWidth1=.000192;
% inputData.pWidth2=.0002;
% folderpath=[folderbase,'50uA192us-48uA200us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
% 
% close all
% inputData.pWidth1=.000180;
% inputData.pWidth2=.000180;
% folderpath=[folderbase,'50uA180us-50uA180us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
% close all
% inputData.pWidth1=.000180;
% inputData.pWidth2=.0002;
% folderpath=[folderbase,'50uA180us-45uA200us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
% 
% close all
% inputData.pWidth1=.0002;
% inputData.pWidth2=.000196;
% folderpath=[folderbase,'49uA200us-50uA196us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
% close all
% inputData.pWidth1=.0002;
% inputData.pWidth2=.000192;
% folderpath=[folderbase,'48uA200us-50uA192us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
% close all
% inputData.pWidth1=.0002;
% inputData.pWidth2=.000180;
% folderpath=[folderbase,'45uA200us-50uA180us/'];
% dataStruct2 = runDataProcessing(functionName,folderpath,inputData);


