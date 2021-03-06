function bumps=convert_bump_mag(tdf)
    %generates the commanded force for each trial. starting from a tdf
    %object (bdf extended with trial table and trial table  header fields)
    %if there is no force field in the bdf one will be created with the
    %same sample rate as the kinematics

    if isfield(tdf,'force')
        bumps=[tdf.force(:,1),zeros(length(tdf.force),2)];
        time_step=mean(diff(tdf.force(:,1)));
    else
        bumps=[tdf.pos(:,1),zeros(length(tdf.pos),2)];
        time_step=mean(diff(tdf.pos(:,1)));
    end
    for trial=1:length(tdf.tt)
        if tdf.tt(trial,tdf.tt_hdr.bump_time)>0
            %find the index of the bump for this trial
            idx=find(bumps(:,1)>(tdf.tt(trial,tdf.tt_hdr.bump_time)),1,'first');
 %           disp(idx)
            %get the bump timing parameters for this trial
            bump_hold_time=tdf.tt(trial,tdf.tt_hdr.bump_dur);
            bump_rise_time=tdf.tt(trial,tdf.tt_hdr.bump_ramp);
            %build hold vector
            numpnts=floor(bump_hold_time/time_step);
            bump_hold=ones(numpnts,1)*  tdf.tt(trial,tdf.tt_hdr.bump_mag);
            %build rise vector
            t=[0:time_step:bump_rise_time]';
            bump_rise=(1-cos(pi*t/bump_rise_time))*bump_hold(1,1)/2;
            %composite bump
            
            bump_amplitude=[bump_rise; bump_hold; flipud(bump_rise)];
%            plot(bump_amplitude)
            %insert into bumps array:     
            bump_ang=tdf.tt(trial,tdf.tt_hdr.bump_angle)+tdf.tt(trial,tdf.tt_hdr.tgt_angle);
            bumps(idx:(idx+length(bump_amplitude)-1),2)=bump_amplitude*cos(pi*bump_ang/180);
            bumps(idx:(idx+length(bump_amplitude)-1),3)=bump_amplitude*sin(pi*bump_ang/180);
%            plot(bumps(1:(idx+length(bump_amplitude)-1),1),bumps(1:(idx+length(bump_amplitude)-1),2))
        end
    end
   
end

