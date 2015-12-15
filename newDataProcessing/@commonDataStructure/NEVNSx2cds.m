function NEVNSx2cds(cds,NEVNSx,varargin)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %NEVNSx2cds(NEVNSx,options...)
    %takes an NEVNSx object and a structure of options, and fills a common
    %data structure (CDS) object from the data in the NEVNSx structure.
    %Accepts the following options as additional input arguments:
    %'noforce'      ignores any force data in the NEVNSx, treating it as
    %               plain analog data, rather tahn formatted force
    %'nokin'        ignores any kinematic or kinetic data
    %'rothandle'    assumes the handle was flipped upside down, and
    %               converts force signals appropriately
    %'ignore_jumps' does not flag jumps in encoder output when converting
    %               encoder data to position. Useful for Lab1 where the
    %               encoder stream is used to process force, not angle
    %               steps. 
    %'ignore_filecat'   Ignores the join time between two files. Normally
    %               the join time is flagged and included in the list of
    %               bad kinematic times so that artifacts associated with
    %               the kinematic discontinuity can be avoided in further
    %               processing
    %lab number:    an integer number designating the lab from the set 
    %               1,2,3,6
    %
    %example: cds.NEVNSx2cds(NEVNSx, 'rothandle', 3) 
    %imports the data from NEVNSx into the fields of cds, assuming the
    %robot handle was inverted, and the data came from lab3
    
    %% Initial setup
        % make sure LaTeX is turned off and save the old state so we can turn
        % it back on at the end
        defaulttextinterpreter = get(0, 'defaulttextinterpreter'); 
        set(0, 'defaulttextinterpreter', 'none');

        %initial setup
        opts=struct('force',1,'kin',1,'analog',1,'lfp',1,'emg',1,'triggers',1,'labnum',-1,'rothandle',0,'ignore_jumps',0,'ignore_filecat',0,'robot',0); 

        % Parse arguments
        if ~isempty(varargin)
            for i = 1:length(varargin)
                opt_str = char(varargin{i});           
                if strcmp(opt_str, 'noForce')
                    opts.force = 0;
                elseif strcmp(opt_str, 'noKin')
                    opts.kin = 0;
                    opts.force = 0;
                elseif strcmp(opt_str,'noEMG')
                    opts.emg=0;
                elseif strcmp(opt_str,'noLFP')
                    opts.lfp=0;
                elseif strcmp(opt_str,'noAnalog')
                    opts.analog=0;
                elseif strcmp(opt_str,'noTriggers')
                    opts.triggers=0;    
                elseif strcmp(opt_str, 'rothandle')
                    opts.rothandle = varargin{i+1};
                elseif strcmp(opt_str, 'ignoreJumps')
                    opts.ignore_jumps=1;
                elseif strcmp(opt_str, 'ignoreFilecat')
                    opts.ignore_filecat=1;
                elseif ischar(opt_str) && length(opt_str)>4 && strcmp(opt_str(1:4),'task')
                    task=opt_str(5:end);
                elseif ischar(opt_str) && length(opt_str)>5 && strcmp(opt_str(1:5),'array')
                    opts.array=opt_str(6:end);
                elseif ischar(opt_str) && length(opt_str)>5 && strcmp(opt_str(1:6),'monkey')
                    opts.monkey=opt_str(7:end);
                elseif isnumeric(varargin{i})
                    opts.labnum=varargin{i};    %Allow entering of the lab number               
                else 
                    error('Unrecognized option: %s', opt_str);
                end
            end
        end
        %check the options and throw warnings if some things aren't set:
        flag=0;
        if ~exist('task','var')
            flag=1;
            warning('NEVNSx2cds:taskNotSet','No task was passed as an input variable. Further processing can attempt to automatically identify the task, but success is not garaunteed')
        end
        if ~isfield(opts,'array')
            flag=1;
            warning('NEVNSx2cds:arrayNotSet','No array label was passed as an input variable.')
        end
        if opts.labnum==-1
            flag=1;
            warning('NEVNSx2cds:labNotSet','The lab number where this data was collected was not passed as an input variable')
        end
        if ~isfield(opts,'monkey')
            flag=1;
            warning('NEVNSx2cds:monkeyNotSet','The monkey from which this data was collected was not passed as an input variable')
        end
        if flag
            while 1
                s=input('Do you want to cancel and re-run this data load including the information missing above? (y/n)\n','s');
                if strcmpi(s,'y')
                    error('NEVNSx2cds:UserCancelled','User cancelled execution to re-run with additional input')
                elseif strcmpi(s,'n')
                    break
                else
                    disp([s,' is not a valid response'])
                end
            end
        end
        
    %% get the info of data we have to work with
        % Build catalogue of entities
        unit_list = unique([NEVNSx.NEV.Data.Spikes.Electrode;NEVNSx.NEV.Data.Spikes.Unit]','rows');

        NSxInfo.NSx_labels = {};
        NSxInfo.NSx_sampling = [];
        NSxInfo.NSx_idx = [];
        if ~isempty(NEVNSx.NS2)
            NSxInfo.NSx_labels = {NSxInfo.NSx_labels{:} NEVNSx.NS2.ElectrodesInfo.Label}';
            NSxInfo.NSx_sampling = [NSxInfo.NSx_sampling repmat(1000,1,size(NEVNSx.NS2.ElectrodesInfo,2))];
            NSxInfo.NSx_idx = [NSxInfo.NSx_idx 1:size(NEVNSx.NS2.ElectrodesInfo,2)];
        end
        if ~isempty(NEVNSx.NS3)
            NSxInfo.NSx_labels = {NSxInfo.NSx_labels{:} NEVNSx.NS3.ElectrodesInfo.Label};
            NSxInfo.NSx_sampling = [NSxInfo.NSx_sampling repmat(2000,1,size(NEVNSx.NS3.ElectrodesInfo,2))];
            NSxInfo.NSx_idx = [NSxInfo.NSx_idx 1:size(NEVNSx.NS3.ElectrodesInfo,2)];
        end
        if ~isempty(NEVNSx.NS4)
            NSxInfo.NSx_labels = {NSxInfo.NSx_labels{:} NEVNSx.NS4.ElectrodesInfo.Label}';
            NSxInfo.NSx_sampling = [NSxInfo.NSx_sampling repmat(10000,1,size(NEVNSx.NS4.ElectrodesInfo,2))];
            NSxInfo.NSx_idx = [NSxInfo.NSx_idx 1:size(NEVNSx.NS4.ElectrodesInfo,2)];
        end
        if ~isempty(NEVNSx.NS5)
            NSxInfo.NSx_labels = {NSxInfo.NSx_labels{:} NEVNSx.NS5.ElectrodesInfo.Label}';
            NSxInfo.NSx_sampling = [NSxInfo.NSx_sampling repmat(30000,1,size(NEVNSx.NS5.ElectrodesInfo,2))];
            NSxInfo.NSx_idx = [NSxInfo.NSx_idx 1:size(NEVNSx.NS5.ElectrodesInfo,2)];
        end
        %sanitize labels
        NSxInfo.NSx_labels = NSxInfo.NSx_labels(~cellfun('isempty',NSxInfo.NSx_labels));
        NSxInfo.NSx_labels = deblank(NSxInfo.NSx_labels);
        %apply aliases to labels:
        if ~isempty(cds.aliasList)
            for i=1:size(cds.aliasList,1)
                NSxInfo.NSx_labels(find(~cellfun('isempty',strfind(NSxInfo.NSx_labels,cds.aliasList{i,1}))))=cds.aliasList(i,2);
            end
        end
    %% Events: 
        %do this first since the task check requires the words to already be processed, and task is required to work on kinematics and force
        cds.eventsFromNEVNSx(NEVNSx)
    %% if a task was not passed in, set task varable
        if ~exist('task','var')%if no task label was passed into the function call
            if strcmp(cds.meta.task,'Unknown')
                task=[];
            else 
                task=cds.meta.task;
            end
        end
        [opts]=cds.getTask(task,opts);
        
    %% the kinematics
        %convert event info into encoder steps:
        if opts.kin 
            cds.kinematicsFromNEVNSx(NEVNSx,opts)
        end

    %% the kinetics
        if opts.force
            cds.forceFromNEVNSx(NEVNSx,NSxInfo,opts)
        end
    %% The Units
        if ~isempty(unit_list)   
            cds.unitsFromNEVNSx(NEVNSx,opts)
        end
    %% EMG
        if opts.emg
            cds.emgFromNEVNSx(NEVNSx,NSxInfo)
        end
    %% LFP. any collection channel that comes in with the name chan* will be treated as LFP
        if opts.lfp
            cds.LFPFromNEVNSx(NEVNSx,NSxInfo)
        end
    %% Triggers
        %get list of triggers
        if opts.triggers
            cds.triggersFromNEVNSx(NEVNSx,NSxInfo)
        end
    %% Analog
        if opts.analog
            cds.analogFromNEVNSx(NEVNSx,NSxInfo)
        end
    %% trial data
        if strcmp(cds.meta.task,'Unknown') || isempty( cds.meta.task)
            warning('NEVNSx2cds:UnknownTask','The task for this file is not known, the trial data table may be inaccurate')
        end
        %set the cds.meta.datetime field so that task table code can check
        %run date range specific code:
        meta=cds.meta;
        dateTime = [int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(2)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(4)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(1)) ...
        ' ' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(5)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(6)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(7)) '.' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(8))];
        meta.datetime=dateTime;
        cds.getTrialTable
    %% Set metadata. Some metadata will already be set, but this should finish the job
        cds.metaFromNEVNSx(NEVNSx,opts)
        
end
