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
inputData.badChList=[];
inputData.windowSize=30*3;%in points. multiply ms by 30 to get points
inputData.presample=5;%in points
inputData.plotRange=0.300;%in mV
inputData.interpulse=.000053;%in s
inputData.lab=6;
inputData.useSyncLabel=[];
inputData.doFilter=false;
inputData.syncLength=.000053;%in s
inputData.forceReload=true;

folderbase='/media/tucker/My Passport/local processing/stimTesting/20170512_Saline/';
close all
inputData.pWidth1=.0002;
inputData.pWidth2=.0010;
folderpath=[folderbase,'IP53/','A1-50_A2-10_PW1-200_PW2-1000_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);

close all
inputData.pWidth1=.0010;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP53/','A1-10_A2-50_PW1-1000_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.0005;
folderpath=[folderbase,'IP53/','A1-50_A2-20_PW1-200_PW2-500_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0005;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP53/','A1-20_A2-50_PW1-500_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.0004;
folderpath=[folderbase,'IP53/','A1-50_A2-25_PW1-200_PW2-400_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.0010;
folderpath=[folderbase,'IP53/','A1-25_A2-50_PW1-400_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.00018;
folderpath=[folderbase,'IP53/','A1-45_A2-50_PW1-200_PW2-180_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.000184;
folderpath=[folderbase,'IP53/','A1-46_A2-50_PW1-200_PW2-184_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.000188;
folderpath=[folderbase,'IP53/','A1-47_A2-50_PW1-200_PW2-188_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.000192;
folderpath=[folderbase,'IP53/','A1-48_A2-50_PW1-200_PW2-192_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.000196;
folderpath=[folderbase,'IP53/','A1-49_A2-50_PW1-200_PW2-196_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00018;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP53/','A1-50_A2-45_PW1-180_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000184;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP53/','A1-50_A2-46_PW1-184_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000188;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP53/','A1-50_A2-47_PW1-188_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000192;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP53/','A1-50_A2-48_PW1-192_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000196;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP53/','A1-50_A2-49_PW1-196_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000204;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP53/','A1-50_A2-51_PW1-204_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000208;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP53/','A1-50_A2-52_PW1-208_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000212;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP53/','A1-50_A2-53_PW1-212_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000216;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP53/','A1-50_A2-54_PW1-216_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00022;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP53/','A1-50_A2-55_PW1-220_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.000204;
folderpath=[folderbase,'IP53/','A1-51_A2-50_PW1-200_PW2-204_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.000208;
folderpath=[folderbase,'IP53/','A1-52_A2-50_PW1-200_PW2-208_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.000212;
folderpath=[folderbase,'IP53/','A1-53_A2-50_PW1-200_PW2-212_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.000216;
folderpath=[folderbase,'IP53/','A1-54_A2-50_PW1-200_PW2-216_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.000220;
folderpath=[folderbase,'IP53/','A1-55_A2-50_PW1-200_PW2-220_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP53/','A1-50_A2-50_PW1-200_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP53/','A1-10_A2-10_PW1-200_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP53/','A1-20_A2-20_PW1-200_PW2-200_IP-53/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

%% 

inputData.interpulse=.0001;
inputData.syncLength=.0001;%in s


close all
inputData.pWidth1=.0002;
inputData.pWidth2=.0010;
folderpath=[folderbase,'IP100/','A1-50_A2-10_PW1-200_PW2-1000_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);

close all
inputData.pWidth1=.0010;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP100/','A1-10_A2-50_PW1-1000_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.0005;
folderpath=[folderbase,'IP100/','A1-50_A2-20_PW1-200_PW2-500_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0005;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP100/','A1-20_A2-50_PW1-500_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.0004;
folderpath=[folderbase,'IP100/','A1-50_A2-25_PW1-200_PW2-400_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.0010;
folderpath=[folderbase,'IP100/','A1-25_A2-50_PW1-400_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.00018;
folderpath=[folderbase,'IP100/','A1-45_A2-50_PW1-200_PW2-180_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.000184;
folderpath=[folderbase,'IP100/','A1-46_A2-50_PW1-200_PW2-184_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.000188;
folderpath=[folderbase,'IP100/','A1-47_A2-50_PW1-200_PW2-188_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.000192;
folderpath=[folderbase,'IP100/','A1-48_A2-50_PW1-200_PW2-192_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.000196;
folderpath=[folderbase,'IP100/','A1-49_A2-50_PW1-200_PW2-196_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00018;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP100/','A1-50_A2-45_PW1-180_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000184;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP100/','A1-50_A2-46_PW1-184_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000188;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP100/','A1-50_A2-47_PW1-188_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000192;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP100/','A1-50_A2-48_PW1-192_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000196;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP100/','A1-50_A2-49_PW1-196_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000204;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP100/','A1-50_A2-51_PW1-204_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000208;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP100/','A1-50_A2-52_PW1-208_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000212;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP100/','A1-50_A2-53_PW1-212_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000216;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP100/','A1-50_A2-54_PW1-216_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00022;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP100/','A1-50_A2-55_PW1-220_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.000204;
folderpath=[folderbase,'IP100/','A1-51_A2-50_PW1-200_PW2-204_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.000208;
folderpath=[folderbase,'IP100/','A1-52_A2-50_PW1-200_PW2-208_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.000212;
folderpath=[folderbase,'IP100/','A1-53_A2-50_PW1-200_PW2-212_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.000216;
folderpath=[folderbase,'IP100/','A1-54_A2-50_PW1-200_PW2-216_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.000220;
folderpath=[folderbase,'IP100/','A1-55_A2-50_PW1-200_PW2-220_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP100/','A1-50_A2-50_PW1-200_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP100/','A1-10_A2-10_PW1-200_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP100/','A1-20_A2-20_PW1-200_PW2-200_IP-100/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all


%% 
inputData.syncLength=.00025;%in s

inputData.interpulse=.00025;

close all
inputData.pWidth1=.0002;
inputData.pWidth2=.0010;
folderpath=[folderbase,'IP250/','A1-50_A2-10_PW1-200_PW2-1000_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);

close all
inputData.pWidth1=.0010;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP250/','A1-10_A2-50_PW1-1000_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.0005;
folderpath=[folderbase,'IP250/','A1-50_A2-20_PW1-200_PW2-500_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0005;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP250/','A1-20_A2-50_PW1-500_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.0004;
folderpath=[folderbase,'IP250/','A1-50_A2-25_PW1-200_PW2-400_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.0010;
folderpath=[folderbase,'IP250/','A1-25_A2-50_PW1-400_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.00018;
folderpath=[folderbase,'IP250/','A1-45_A2-50_PW1-200_PW2-180_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.000184;
folderpath=[folderbase,'IP250/','A1-46_A2-50_PW1-200_PW2-184_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.000188;
folderpath=[folderbase,'IP250/','A1-47_A2-50_PW1-200_PW2-188_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.000192;
folderpath=[folderbase,'IP250/','A1-48_A2-50_PW1-200_PW2-192_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.0002;
inputData.pWidth2=.000196;
folderpath=[folderbase,'IP250/','A1-49_A2-50_PW1-200_PW2-196_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00018;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP250/','A1-50_A2-45_PW1-180_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000184;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP250/','A1-50_A2-46_PW1-184_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000188;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP250/','A1-50_A2-47_PW1-188_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000192;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP250/','A1-50_A2-48_PW1-192_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000196;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP250/','A1-50_A2-49_PW1-196_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000204;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP250/','A1-50_A2-51_PW1-204_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000208;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP250/','A1-50_A2-52_PW1-208_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000212;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP250/','A1-50_A2-53_PW1-212_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.000216;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP250/','A1-50_A2-54_PW1-216_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00022;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP250/','A1-50_A2-55_PW1-220_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.000204;
folderpath=[folderbase,'IP250/','A1-51_A2-50_PW1-200_PW2-204_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.000208;
folderpath=[folderbase,'IP250/','A1-52_A2-50_PW1-200_PW2-208_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.000212;
folderpath=[folderbase,'IP250/','A1-53_A2-50_PW1-200_PW2-212_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.000216;
folderpath=[folderbase,'IP250/','A1-54_A2-50_PW1-200_PW2-216_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.000220;
folderpath=[folderbase,'IP250/','A1-55_A2-50_PW1-200_PW2-220_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP250/','A1-50_A2-50_PW1-200_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP250/','A1-10_A2-10_PW1-200_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all

inputData.pWidth1=.00020;
inputData.pWidth2=.0002;
folderpath=[folderbase,'IP250/','A1-20_A2-20_PW1-200_PW2-200_IP-250/']
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
close all
