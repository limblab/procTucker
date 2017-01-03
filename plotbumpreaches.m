
    bumpDirs=sort(unique(ex.trials.data.bumpDir));
    bumpDirs(isnan(bumpDirs))=[];
    numBumps=numel(bumpDirs);
    numUnits=numel(ex.binConfig.include(1).which);
    trialMask=false(size(ex.trials.data,1),numel(bumpDirs));
    for i=1:numel(bumpDirs)
        trialMask=ex.trials.data.bumpDir==bumpDirs(i);
        windows=[ex.trials.data.bumpTime(trialMask),ex.trials.data.bumpTime(trialMask)+.4];
        x=ex.kin.data.x(windows2mask(ex.kin.data.t,windows));
        y=ex.kin.data.y(windows2mask(ex.kin.data.t,windows))+32;
        figure;plot(x,y)
        title(['POS:bumps to ',num2str(bumpDirs(i)),'deg'])
        
        fx=ex.force.data.fx(windows2mask(ex.force.data.t,windows));
        fy=ex.force.data.fy(windows2mask(ex.force.data.t,windows));
        figure;plot(fx,fy)
        title(['Force:bumps to ',num2str(bumpDirs(i)),'deg'])
    end
    
     savefolder='/home/tucker/bumpPlotsForLee';
     savenamebase='bumpsTo';
    bumpDirList=ex.trials.data.bumpDir+ex.trials.data.tgtDir;
    %bumpDirList=sort(ex.trials.data.tgtDir);
     bumpDirList(bumpDirList>=360)=bumpDirList(bumpDirList>=360)-360;
     bumpDirList(bumpDirList<0)=bumpDirList(bumpDirList<0)+360;
    bumpDirs=sort(unique(bumpDirList));
    bumpDirs(isnan(bumpDirs))=[];
    numBumps=numel(bumpDirs);
    numUnits=numel(ex.binConfig.include(1).which);
    trialMask=false(size(ex.trials.data,1),numel(bumpDirs));
    for i=1:numel(bumpDirs)
        trialMask=bumpDirList==bumpDirs(i) & ~isnan(ex.trials.data.bumpTime);
        windows=[ex.trials.data.bumpTime(trialMask),ex.trials.data.bumpTime(trialMask)+.25];
        H1=figure;
        H2=figure;
        %for j=1:size(windows,1)
        for j=1:3
            mask=windows2mask(ex.kin.data.t,windows(j,:));
            x=ex.kin.data.x(mask);
            %x=x-x(1);
            y=ex.kin.data.y(mask)+32;
            %y=y-y(1);
            figure(H1);plot(x,y)
            hold on
            plot(x(1),y(1),'*k')
            fx=ex.force.data.fx(windows2mask(ex.force.data.t,windows(j,:)));
            fy=ex.force.data.fy(windows2mask(ex.force.data.t,windows(j,:)));
            figure(H2);plot(fx,fy)
            hold on
            plot(fx(1),fy(1),'*k')
        end
        figure(H1)
        axis equal
        title(['POS:bumps to ',num2str(bumpDirs(i)),'deg'])
        print('-dpng',H1,strcat(savefolder,filesep,'POS-',savenamebase,num2str(bumpDirs(i)),'deg.png'))
        figure(H2)
        axis equal
        title(['Force:bumps to ',num2str(bumpDirs(i)),'deg'])
        print('-dpng',H1,strcat(savefolder,filesep,'FORCE-',savenamebase,num2str(bumpDirs(i)),'deg.png'))
    end
    
    
    
        %bumpDirList=sort(ex.trials.data.bumpDir+ex.trials.data.tgtDir);
    moveDirList=ex.trials.data.tgtDir;
    moveDirList(moveDirList>=360)=moveDirList(moveDirList>=360)-360;
    moveDirList(moveDirList<0)=moveDirList(moveDirList<0)+360;
    moveDirs=sort(unique(moveDirList));
    moveDirs(isnan(moveDirs))=[];
    numMoves=numel(moveDirs);
%     bumpDirList=sort(ex.trials.data.tgtDir);
%     bumpDirList(bumpDirList>=360)=bumpDirList(bumpDirList>=360)-360;
%     bumpDirList(bumpDirList<=0)=bumpDirList(bumpDirList<=0)+360;
%     bumpDirs=unique(bumpDirList);
%     bumpDirs(isnan(bumpDirs))=[];
%     numBumps=numel(bumpDirs);
%     numUnits=numel(ex.binConfig.include(1).which);
    for i=1:numel(moveDirs)
        trialMask=(moveDirList==moveDirs(i) & ~isnan(ex.trials.data.moveTime));
        %trialMask=bumpDirList==bumpDirs(i);
        windows=[ex.trials.data.moveTime(trialMask),ex.trials.data.endTime(trialMask)];
        H1=figure;
        H2=figure;
        for j=1:size(windows,1)
            x=ex.kin.data.x(windows2mask(ex.kin.data.t,windows(j,:)));
            y=ex.kin.data.y(windows2mask(ex.kin.data.t,windows(j,:)))+32;
            figure(H1);
            plot(x,y)
            hold on
            fx=ex.force.data.fx(windows2mask(ex.force.data.t,windows(j,:)));
            fy=ex.force.data.fy(windows2mask(ex.force.data.t,windows(j,:)));
            figure(H2);
            plot(fx,fy)
            hold on
        end
        figure(H1)
        axis equal
        title(['POS:reach to ',num2str(moveDirs(i)),'deg'])
        figure(H2)
        axis equal
        title(['Force:reach to ',num2str(moveDirs(i)),'deg'])
    end
    
    
    
mask=windows2mask(cds.force.t,[goCueList(trial),times.endTime(trial)]);
figure;plot(cds.kin.x(mask),cds.kin.y(mask))
axis equal
title('pos: during reach')
figure;plot(cds.force.fx(mask),cds.force.fy(mask))
title('force: during reach')
axis equal
disp('tgt ang:')
tgtAngle(trial)
    
    
mask=windows2mask(cds.force.t,[bumpTimeList(trial),goCueList(trial)]);
figure;plot(cds.kin.x(mask),cds.kin.y(mask))
title('pos: during bump')
axis equal
figure;plot(cds.force.fx(mask),cds.force.fy(mask))
title('force: during bump')
axis equal
disp('bump ang:')
bumpAngle(trial)-tgtAngle(trial)
    
    
    