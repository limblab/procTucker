function plot_abort_positions(tdf,stimcode)
    %this function plots all abort trials from a single tdf on the same
    %plot
    
    % compose trial table for only abort trials
    tt = tdf.tt( ( tdf.tt(:,tdf.tt_hdr.trial_result) == 1 &  tdf.tt(:,tdf.tt_hdr.stim_code) == stimcode) ,  :);
    disp(strcat('Found ',num2str(length(tt(:,1))),' abort trials.'))
    figure
    hold on
    title('Abort trials')
    axis equal
    %loop across the trial table and plot the movements for each trial
    for i=1:length(tt(:,1))
        %find the start and stop index for this trial
        t_1=find(tdf.pos(:,1)>tt(i,tdf.tt_hdr.bump_time),1,'first');
        t_2=find(tdf.pos(:,1)>tt(i,tdf.tt_hdr.end_time),1,'first');
        %add the current trial abort position to the figure
        plot(tdf.pos(t_1,2),tdf.pos(t_1,3))
        plot(tdf.pos(t_2,2),tdf.pos(t_2,3),'r')

    end
    
    

end