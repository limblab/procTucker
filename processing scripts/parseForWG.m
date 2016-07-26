function [figureList,outputData]=parseForWG(folderpath,inputData)
    figureList=[];
    %% initial loading of data
    outputData.cds=commonDataStructure();
    disp('loading first file')
    outputData.cds.file2cds([folderpath,inputData.fileName],inputData.ranBy,inputData.array,inputData.monkey,inputData.labNum,'ignoreJumps',inputData.task,inputData.mapFile);
    
    %% copy data to experiment
    disp('passing data to experiment')
    ex=experiment();
        % set which variables to load from cds
        ex.meta.hasLfp=false;
        ex.meta.hasKinematics=true;
        ex.meta.hasForce=true;
        ex.meta.hasUnits=true;
        ex.meta.hasTrials=true;

    ex.addSession(outputData.cds);
    %clean up units:
    ex.units.deleteInvalid;
    ex.units.removeSorting;
    
    disp('finding the starts of movement')
    ex.getMoveStart();
   
    outputData.experiment=ex;
    outputData.units=ex.units.data;
    outputData.kinematics=ex.kin.data;
    outputData.force=ex.force.data;
    outputData.trials=ex.trials.data;
    outputData.electrode_grid=unitTrialArray(outputData.units,outputData.trials);
end


function unitTrialArray(units,trials)
    %takes in a units table and returns a cell array of structures.
    %Each structure represents the firing data for a single unit. Each
    %structure has a field for every reach direction. Every reach
    %direction's field is a cell array where each cell contains a vector of
    %timestamps for the spike events corresponding to a single trial.
    
    
    %initialize the main cell array
    electrode_grid=cell(10);
    
    %get the windows for all trials:
    windows=[trials.moveTime, trials.endTime];
    
    %mask off trials where the move never happens:
    mask=~isnan(sum(windows,2)) & ~isnan(trials.tgtDir);
    windows=windows(mask,:);
    subTrials=trials(mask,:);
        
    %build an empty spike times structure:
    directions=unique(trials.tgtDir(mask));
    for j=1:numel(directions)
        spikeTimes.(['reach_direction',num2str(directions(j)),'_spike_times'])=[];
    end
    
    %loop through all the units we have
    for i=1:numel(units)
        %get the electrode position:
        iRow=units(i).rowNum;
        iCol=units(i).colNum;
        
        %put the empty structure into the cell array:
        electrode_grid{iRow,iCol}=spikeTimes;
        %populate the spike data for this unit
        for j=1:numel(subTrials.number)
            tgtDir=subTrials.tgtDir(j);
            %get the spikes from the current trial:
            mask=units(i).spikes.ts>windows(j,1) & units(i).spikes.ts<windows(j,2);
            timeStamps=units(i).spikes.ts(mask);
            %put the timestamps into our cell array
            electrode_grid{iRow,iCol}.(['reach_direction',num2str(tgtDir),'_spike_times']){end+1}=timeStamps;
        end
    end
    
end