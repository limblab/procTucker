%script to set input data and execute data processing
%% process psyhcometrics
folderpath='/media/tucker/My Passport/local processing/Han/experiment_20170425-28_BD_2degPD/';
function_name='quickscript_function_looped';
input_data.matchstring='Han';
input_data.labnum=6;
input_data.stimcodes=[0 1 2 3 5];
input_data.num_stim_cases=4;
input_data.currents=[30000 30001 30002 30003 30004 ];
input_data.current_units='pA';
run_data_processing(function_name,folderpath,input_data)
%% psychometrics for stimcodes 0,1 2 all stim 4 electrods @ 20uA, and codes 3-6 stim 1 different elctrode at 40uA
folderpath='/media/tucker/My Passport/local processing/chips/experiment_20160527-29_BD_322degstim20uA_4distractors40uA/';
function_name='psychometrics_3at20uA_4distractorsAt40uA';
input_data.matchstring='Chips';
input_data.labnum=6;
input_data.mainPD=322;
input_data.distractorPD=[147 -165 -83 101];
input_data.distractor_current=40;
input_data.main_current=20;
input_data.current_units='uA';
run_data_processing(function_name,folderpath,input_data)

%% batch of psychometrics:
function_name='quickscript_function_looped';
input_data.labnum=3;
input_data.stimcodes=[0 1 2 3];
input_data.num_stim_cases=4;
input_data.currents=[5 10 15 20];
input_data.matchstring='Kramer';
folderpath='E:\local_processing\kramer\experiment_20130305_0322_BD_70degstim';
run_data_processing(function_name,folderpath,input_data)
%% process PDs
folderpath='/media/tucker/My Passport/local processing/Han/experiment_20170403_RW_oldPD/';
input_data.filename='Han_20170403_RW_tucker_001-s.nev';
input_data.matchstring='Han';
function_name='get_move_pds_function';
input_data.labnum=6;
input_data.array_map_path='/media/tucker/My Passport/local processing/Han/experiment_20170403_RW_oldPD/SN 6251-001459.cmp';
data_struct = runDataProcessing(function_name,folderpath,input_data);

%% process PDs using Raeed/Tucker functions
folderpath='/media/tucker/My Passport/local processing/Chips/experiment_20160128_RW/';
input_data.prefix='Chips_20160128_RW_tucker_002';
function_name='get_PDs';
input_data.labnum=6;
input_data.do_unit_pds=0;
input_data.do_electrode_pds=1;
input_data.only_sorted=1;
input_data.task='RW';
input_data.offset=-.015;%latency from neural action to motor effect
input_data.binsize=.05;%bin size to compute firing rate
input_data.vel_pd=1;%default flag is 1
input_data.force_pd=0;%default flag is 0
data_struct2 = run_data_processing(function_name,folderpath,input_data);
%% actVSpass pd comparison
folderpath='/media/tucker/My Passport/local processing/Han/experiment_20170502_COBump_PD/';
functionName='comparePD_actpass';
inputData.fileName='Han_20170502_COBump_tucker001.nev';
inputData.task='taskCObump';
inputData.ranBy='ranByTucker'; 
inputData.array='arrayS1Area2';
inputData.monkey='monkeyHan';
inputData.mapFile='mapFile/media/tucker/My Passport/local processing/Han/experiment_20170403_RW_oldPD/SN 6251-001459.cmp';
inputData.lab=6;
data_struct=runDataProcessing(functionName,folderpath,inputData);
%% new data format PD's from CO bump task:
folderpath='/media/tucker/My Passport/local processing/chips/experiment_20161018_COBump_bumpArtifactTesting/';
functionName='CObump_tuning';
inputData.fileName='chips_20161018_COBump_tucker_holdDelayBumps_002.nev';
inputData.task='taskCObump';
inputData.ranBy='ranByTucker'; 
inputData.array='arrayS1Area2';
inputData.monkey='monkeyChips';
inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161112/SN 6251-001459.cmp';

inputData.unsorted=true;

inputData.lab=6;
data_struct=runDataProcessing(functionName,folderpath,inputData);

%% bump PDs from bump-direction/psychophysics task
folderpath='E:\local processing\chips\experiment_20160225_BD_bumpPDs';
input_data.prefix='Chips';
function_name='get_PDs';
input_data.labnum=6;
input_data.do_unit_pds=0;
input_data.do_electrode_pds=1;
input_data.only_sorted=0;
input_data.task='BC';
input_data.offset=-.015;%latency from neural action to motor effect
input_data.binsize=.05;%bin size to compute firing rate
input_data.vel_pd=0;%default flag is 1
input_data.force_pd=1;%default flag is 0
input_data.parse_type='bumps';
input_data.data_window=.5;%window after go cue that will be included in PD analysis
data_struct = run_data_processing(function_name,folderpath,input_data);
%% reach PDs from bump-direction/psychophysics task
folderpath='E:\local processing\chips\experiment_20160225_BD_reachPDs';
input_data.prefix='Chips';
function_name='get_PDs';
input_data.labnum=6;
input_data.do_unit_pds=0;
input_data.do_electrode_pds=1;
input_data.only_sorted=0;
input_data.task='BC';
input_data.offset=-.015;%latency from neural action to motor effect
input_data.binsize=.05;%bin size to compute firing rate
input_data.vel_pd=1;%default flag is 1
input_data.force_pd=0;%default flag is 0
input_data.parse_type='go cues';
input_data.data_window=.5;%window after go cue that will be included in PD analysis
data_struct2 = run_data_processing(function_name,folderpath,input_data);
%% force pds
folderpath='E:\local_processing\kevin\04-03-15';
input_data.prefix='Kevin_IsoBoxCO_HC_SpikesEMGsForces_04032015_SN_001';
function_name='get_PDs';
input_data.labnum=1;
input_data.do_unit_pds=1;
input_data.do_electrode_pds=0;
input_data.only_sorted=1;
input_data.task='WF';
input_data.offset=.015;%latency from neural action to motor effect
input_data.binsize=.05;%bin size to compute firing rate
input_data.vel_pd=1;%default flag is 1
input_data.force_pd=1;%default flag is 0
data_struct = run_data_processing(function_name,folderpath,input_data);

%% process single unit PDs
folderpath='Z:\MrT_9I4\Processed\experiment_20141009_RW_file1';
input_data.filename='MrT_RW_20141008_tucker_-4rms_001.nev - Shortcut.lnk';
function_name='move_PDs';
input_data.labnum=6;
data_struct = run_data_processing(function_name,folderpath,input_data);

%% get PDs from bump direction file
folderpath='Z:\MrT_9I4\Processed\experiment_20140903_BD_PDAnalysis';
function_name='BumpDirection_PDs';
input_data.labnum=6;
input_data.matchstring='MrT';
data_struct = run_data_processing(function_name,folderpath,input_data);

%% check for unit stability
folderpath='C:\Users\limblab\Documents\local_processing\chips\20150220-27_unit_stability';
function_name='compute_unit_stability';
input_data.num_channels=96;
input_data.min_moddepth=2*10^-4;
unit_stability=run_data_processing(function_name,folderpath,input_data);

%% check for electrode stability
folderpath='C:\Users\limblab\Documents\local_processing\chips\20150220-27_electrode_stability';
function_name='compute_electrode_stability';
input_data.num_channels=96;
input_data.min_moddepth=2*10^-4;
electrode_stability=run_data_processing(function_name,folderpath,input_data);
%% compute SNR
folderpath='';
function_name='analyze_SNR';
run_data_processing(function_name,folderpath,input_data)
%% make polar plots of stimulated electrode groups for chips
folderpath='Z:\Chips_12H1\processed\summary of stim directions';
function_name='make_chips_polar_PD_summaries';
input_data.monkey_name='C';
data_struct = run_data_processing(function_name,folderpath,input_data);
%% Track Neurons across days
folderpath='E:\local processing\pedro\20100726_neuron_tracking';
function_name='get_neuron_matching';
input_data.matchstring='Pedro';
input_data.labnum=2;
data_struct = run_data_processing(function_name,folderpath,input_data);
%% parse file for katsaggelos group using commonDataStructure:
% folderpath='/media/tucker/My Passport/local processing/lando/20170511_RW_withmotion_forKatsaggelos/';
% inputData.fileName1='Lando_RW_20170511_CDS_MotionTracking.mat';
folderpath='/media/tucker/My Passport/local processing/lando/20170728_RW_motionTracking_katsaggelos_improved/';
inputData.fileName1='Lando_RW_hold_20170728_001_CDS_MotionTracking.mat';
inputData.mapFile='/media/tucker/My Passport/local processing/lando/SN 6251-001701.cmp';
inputData.monkey='monkeyLando';

% folderpath='/media/tucker/My Passport/local processing/Han/experiment_20160315_RW_withmotiontracking_forKatsaggelos/';
% inputData.fileName1='Han_20160315_RW_area2_001_CDS.mat';
% inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161112/SN 6251-001459.cmp';
% inputData.monkey='monkeyHan';

% folderpath='/media/tucker/My Passport/local processing/chips/experiment_20151203_RW_forKatsaggelosGrp/';
% inputData.fileName1='Chips_20151203_RW_002_CDS.mat';
% inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/SN 6251-001455.cmp';
% inputData.monkey='monkeyChips';

functionName='parseForKatsaggelos';

inputData.task='taskRW';
inputData.ranBy='ranByRaeed'; 
inputData.array1='arrayArea2'; 
inputData.lab=6;

inputData.binMethod='bin';
inputData.kernelWidth=.05;

dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
%% export data for katsaggelos group
folderpath='E:\local processing\pedro\20100726_export_data_for_Katsaggelos_Grp';
function_name='export_for_katsaggelos';
input_data.filename='stable_session.mat';
data_struct = run_data_processing(function_name,folderpath,input_data);
%% export single file data for katsaggelos group
folderpath='E:\local processing\kramer\experiment_20130314_RW_Katsaggelos';
function_name='dump_file_for_katsaggelos';
input_data.filename='Kramer_RW_03142013_tucker_001-01.nev';
input_data.only_sorted=1;
input_data.labnum=3;
input_data.task='RW';
data_struct = run_data_processing(function_name,folderpath,input_data);
%% export file for warren grill group
folderPath='/media/tucker/My Passport/local processing/Han/experiment_20160620_COBump_GrillExport/';
inputData.fileName='Han_20160620_grill_bump_data_Chris_001';
functionName='parseForWG';
inputData.labNum=6;
inputData.ranBy='ranByChris';
inputData.monkey='monkeyHan';
inputData.array='arrayS1Area2';
inputData.task='taskCObump';
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/chips/array_map/SN6251-001455.cmp';
inputData.mapFile='mapFile/media/tucker/My Passport/local processing/Han/mapfile/SN 6251-001459.cmp';
dataStruct=runDataProcessing(functionName,folderPath,inputData);

%% test encoder skipping:
folderpath='E:\local processing\test_skips';
function_name='testEncoderSkips';
data_struct=run_data_processing(function_name,folderpath);

%% process stimulation artifacts:
folderpath='/media/tucker/My Passport/local processing/stimTesting/20180202_UC_StimSwitchTest/cathodal_100Hz/';
functionName='processStimArtifact';

inputData.task='tasknone';
inputData.ranBy='ranByTucker'; 
inputData.array1='arrayS1'; 
inputData.monkey='monkeyResistor';
%han
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161112/SN 6251-001459.cmp';
%chips
% inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/SN 6251-001455.cmp';
%chewie
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161205_chewie_PMDStim_PMD-recording/Chewie Left PMd SN 6251-001469.cmp';
%saline
inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161020_saline/1025-0370.cmp';
%saline2
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161220_saline/SN 6251-001695.cmp';
inputData.windowSize=30*10;%in points
inputData.presample=5;%in points
inputData.plotRange=08.300;%in mV
inputData.lab=6;
inputData.useSyncLabel=[];
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
%% get stimulation artifact examples:
folderpath='/media/tucker/My Passport/local processing/stimTesting/20161020_saline/20uA_unmodAmp_examples/';
functionName='processStimArtifactExamples';

inputData.task='tasknone';
inputData.ranBy='ranByTucker'; 
inputData.array1='arraySaline'; 
inputData.monkey='monkeySaline';
%han
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161112/SN 6251-001459.cmp';
%chips
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/SN 6251-001455.cmp';
%chewie
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161205_chewie_PMDStim_PMD-recording/Chewie Left PMd SN 6251-001469.cmp';
%saline
inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161020_saline/1025-0370.cmp';
inputData.windowSize=30*15;%in points
inputData.presample=5;%in points
inputData.plotRange=8.200;%in mV
inputData.lab=6;
inputData.useSyncLabel=[];
inputData.useBlock='useBlocklast';
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);

%% compare stimulation artifacts:
folderpath='/media/tucker/My Passport/local processing/stimTesting/20161107/1vs5/50uA-10uA/';
functionName='compareArtifacts';
inputData.multiStimFile='/media/tucker/My Passport/local processing/stimTesting/20161107/1vs5/50uA-10uA/multiChanArtifactData.mat';
inputData.singleStimFile='/media/tucker/My Passport/local processing/stimTesting/20161107/1vs5/50uA-10uA/singleChanArtifactData.mat';
inputData.posList='/media/tucker/My Passport/local processing/stimTesting/20161107/1vs5/50uA-10uA/posList.mat';
inputData.eList='/media/tucker/My Passport/local processing/stimTesting/20161107/1vs5/50uA-10uA/eList.mat';
inputData.presample=30;%in points
inputData.plotRange=8.2;%in mv
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);

%% plot impedance heatmap:
folderPath='/media/tucker/My Passport/local processing/stimTesting/20161224_saline/imp96/';
functionName='impedanceHeatmap';
inputData.impedanceFile='impedance96.mat';
inputData.maxImpedance=100;
%han
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161112/SN 6251-001459.cmp';
%chips
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/SN 6251-001455.cmp';
%chewie
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161205_chewie_PMDStim_PMD-recording/Chewie Left PMd SN 6251-001469.cmp';
%saline1
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161020_saline/1025-0370.cmp';
%saline2
inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161220_saline/SN 6251-001695.cmp';
runDataProcessing(functionName,folderPath,inputData)
%% unit tracking study

%% efference copy dimensionality reduction analysis
folderpath='/media/tucker/My Passport/local processing/lando/efferenceCopy/20170910_COBump/';
functionName='efferenceCopyAnalysis';
inputData.fileName='Lando_20170910_COBump_LeftS1_002.nev';
inputData.task='taskCObump';
inputData.ranBy='ranByTucker'; 
inputData.array1='arrayS1'; 
inputData.monkey='monkeyLando';
%han
% inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161112/SN 6251-001459.cmp';
%chips
% inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/SN 6251-001455.cmp';
%chewie
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161205_chewie_PMDStim_PMD-recording/Chewie Left PMd SN 6251-001469.cmp';
%lando
inputData.mapFile='mapFile/media/tucker/My Passport/local processing/lando/efferenceCopy/SN 6251-001701.cmp';
%saline
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161020_saline/1025-0370.cmp';
%saline2
%inputData.mapFile='mapFile/media/tucker/My Passport/local processing/stimTesting/20161220_saline/SN 6251-001695.cmp';

inputData.lab=6;

inputData.rootTransform=true;
inputData.doTimeseries=false;
inputData.classifyOnKin=true;
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);

%% check CV effect on impedance
folderPath='/media/tucker/My Passport/local processing/chips/MET16_testing/20170807_CV_effect/';
functionName='checkCVEffect';
inputData=[];

dataStruct=runDataProcessing(functionName,folderPath,inputData)
%% check EIS stability over multiple recordings:
folderPath='/media/tucker/My Passport/local processing/chips/MET16_testing/20170809_EIS_variability/';
functionName='checkEISStability';
inputData=[];

dataStruct=runDataProcessing(functionName,folderPath,inputData)

%% parse full badwidth file into threshold crossings:
folderPath='/media/tucker/My Passport/local processing/Chewie/20171015/';
functionName='getSpikesFromFullBW';
inputData.fileName='Chewie_20171015_tucker_PMD_RW_008.ns5';
inputData.HPFreq=250;
inputData.poles=2;
inputData.stdErrThresh=4;
inputData.clearHighChans=true;%clears channels above 96
inputData.manualCheck=false;
inputData.meanFilter=false;
inputData.PCAFilter=true;
inputData.preSample=10;
inputData.postSample=38;

dataStruct=runDataProcessing(functionName,folderPath,inputData)
%% process stim sweep for artifact duration:
%% process stimulation artifacts from sweeps in current amplitude:
folderpath='/media/tucker/My Passport/local processing/stimTesting/20180202_2/CH1/';
functionName='processStimAmpSweep';

inputData.task='tasknone';
inputData.ranBy='ranByTucker'; 
inputData.array1='arrayNSS'; 
inputData.monkey='monkeyNSS';

inputData.ampStep=5;
inputData.minAmp=1;
inputData.maxAmp=50;

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
inputData.windowSize=30*100;%in points
inputData.presample=5;%in points
inputData.lab=6;
inputData.useSyncLabel=[];
dataStruct2 = runDataProcessing(functionName,folderpath,inputData);
