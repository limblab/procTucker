function [tt, hdr]= bc_trial_table4(bdf)
% BC_TRIAL_TABLE - returns a table containing the key timestamps for all of
%                  the bump choice trials in BDF. In addition to the trial
%                  table, this function returns a header struct that maps
%                  the column number of each field
%


words = bdf.words;
db_times = cell2mat( bdf.databursts(:,1) );

result_codes = 'RAFI------------';

bump_word_base = hex2dec('50');
all_bumps = words(words(:,2) >= (bump_word_base) & words(:,2) <= (bump_word_base+5), 1)';

word_start = hex2dec('1F');
start_words = words(words(:,2) == word_start, 1);

word_go = hex2dec('31');
go_cues = words(words(:,2) == word_go, 1);

word_end = hex2dec('20');
end_words = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 1);%hex2dec('f0') is a bitwise mask for the leading bit
end_codes = words( bitand(hex2dec('f0'),words(:,2)) == word_end, 2);

word_stim=hex2dec('60');
stim_words=words( bitand(hex2dec('f0'),words(:,2)) == word_stim,1);
stim_codes=words( bitand(hex2dec('f0'),words(:,2)) == word_stim,2);


burst_times=zeros(length(bdf.databursts),1);
for i=1:length(burst_times)
    burst_times(i)=bdf.databursts{i,1};
end
num_trials = length(burst_times);
disp(strcat('Found: ',num2str(num_trials),' trials'))

disp('composing trial table assuming db v 4')
disp(strcat('db version:',num2str(bdf.databursts{2,2}(2))))
disp('If actual db version does not match assumed version, fix the trial table code')



tt = zeros(num_trials-1, 40);
skip_counter=0;
for trial = 1:num_trials-1
    
        start_time = start_words(trial);
        if length(start_words)>trial
            next_trial_start = start_words(trial+1);
        else
            %if we have the last trial of the session, just use all the
            %remaining data
            next_trial_start = start_words(trial)+100;
        end
        
        burstindex= find((burst_times > start_time) & (burst_times < next_trial_start));
        if length(burstindex)>1 
            %if we have two start times kill the burst index. this is
            %usually the result of concatenating two files where the trial
            %did not end properly
            burstindex=[];
        end
            
        if ( isempty(burstindex) ) %if we don't have a databurst, or the databurst is empty
            skip_counter=skip_counter+1;
            continue
        else
            if isnan(bdf.databursts{burstindex,2})
                skip_counter=skip_counter+1;
                continue
            else
                db = bdf.databursts{ burstindex,2};
            end
        end
        trial_end_idx = find(end_words > start_time & end_words < next_trial_start, 1, 'first');
        if isempty(trial_end_idx)
            end_time = next_trial_start - .001;
            trial_result = -1;
        else
            end_time = end_words(trial_end_idx);
            trial_result = mod(end_codes(trial_end_idx),32); %0 is reward, 1 is abort, 2 is fail, and 3 is incomplete (incomplete should never happen)
        end

        idx = find(all_bumps > start_time & all_bumps < end_time, 1);
        if ~isempty(idx)
            bump_time = all_bumps(idx);
        else
            bump_time = -1;
        end

        idx = find(go_cues > start_time & go_cues < end_time, 1);
        if ~isempty(idx)
            go_cue = go_cues(idx);
        else
            go_cue = -1;
        end
        
        idx = find(stim_words > start_time & stim_words < end_time,1);
        if ~isempty(idx)
            stim_code = bitand(hex2dec('0f'),stim_codes(idx));%hex2dec('0f') is a bitwise mask for the trailing bit of the word
        else
            stim_code = -1;
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%from mastercon code to ensure matching when extracting data from
%databurst:
% 2         db->addByte(DATABURST_VERSION);
% 3         db->addByte('2');
% 4         db->addByte('B');
% 5         db->addByte('C');
% 6         db->addByte(BEHAVIOR_VERSION_MAJOR);
% 7         db->addByte(BEHAVIOR_VERSION_MINOR);
% 8         db->addByte((BEHAVIOR_VERSION_MICRO & 0xFF00) >> 8);
% 9         db->addByte(BEHAVIOR_VERSION_MICRO & 0x00FF);
% 10:13 	db->addFloat((float)this->tgt_angle);
% 14:17 	db->addFloat((float)this->bump_dir);
% 18        db->addByte((byte)this->params->use_random_targets);
% 19:22 	db->addFloat((float)this->params->target_floor);
% 23:26 	db->addFloat((float)this->params->target_ceiling);
% 27:30 	db->addFloat((float)this->bumpmag_local);
% 31:34 	db->addFloat((float)this->params->bump_duration);
% 35:38 	db->addFloat((float)this->params->bump_ramp);
% 39:42 	db->addFloat((float)this->params->bump_floor);
% 43:46 	db->addFloat((float)this->params->bump_ceiling);
% 47        db->addByte((byte)this->stim_trial);
% 48        db->addByte((byte)this->training_trial);
% 49:52 	db->addFloat((float)this->params->training_frequency);
% 53:56 	db->addFloat((float)this->params->stim_prob);
% 57        db->addByte((byte)this->params->recenter_cursor);
% 58:61 	db->addFloat((float)this->params->target_radius);
% 62:65 	db->addFloat((float)this->params->target_size);
% 66:69 	db->addFloat((float)this->params->intertrial_time);
% 70:73 	db->addFloat((float)this->params->penalty_time);
% 74:77 	db->addFloat((float)this->params->bump_hold_time);
% 78:81 	db->addFloat((float)this->params->ct_hold_time);
% 82:85 	db->addFloat((float)this->params->bump_delay_time);
% 86        db->addByte((byte)this->params->show_target_during_bump);
% 87:90 	db->addFloat((float)this->params->bump_incr);
% 91        db->addByte((byte)this->is_primary_target);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

        numbytes=db(1);
        db_version=db(2);
        two=db(3);
        b=db(4);
        c=db(5);
        behavior_version_maj=db(6);
        behavior_version_minor=db(7);
        behavior_version_micro1=db(8);
        behavior_version_micro2=db(9);

        target_angle=bytes2float(db(10:13));
        bump_dir=bytes2float(db(14:17));
        random_tgt_flag=db(18);
        tgt_dir_floor=bytes2float(db(19:22));
        tgt_dir_ceil=bytes2float(db(23:26));
        bump_mag=bytes2float(db(27:30));
        bump_dur=bytes2float(db(31:34));
        bump_ramp=bytes2float(db(35:38));
        bump_floor=bytes2float(db(39:42));
        bump_ceil=bytes2float(db(43:46));
        stim_trial_flag=db(47);
        training_trial_flag=db(48);
        training_trial_freq=bytes2float(db(49:52));
        stim_freq=bytes2float(db(53:56));
        recenter_cursor_flag=db(57);
        tgt_radius=bytes2float(db(58:61));
        tgt_size=bytes2float(db(62:65));
        intertrial_time=bytes2float(db(66:69));
        penalty_time=bytes2float(db(70:73));
        bump_hold_time=bytes2float(db(74:77));
        ct_hold_time=bytes2float(db(78:81));
        bump_delay_time=bytes2float(db(82:85));
        targets_during_bump=db(86);
        bump_increment=bytes2float(db(87:90));
        primary_target_flag=db(91);
        
        temprow =  [     numbytes,                   db_version,                 two,                        b,                          c, ...%5
                            behavior_version_maj,       behavior_version_minor,     behavior_version_micro1,    behavior_version_micro2,    target_angle,...%5
                            bump_dir,                   random_tgt_flag,            tgt_dir_floor,              tgt_dir_ceil,               bump_mag,... %5
                            bump_dur,                   bump_ramp,                  bump_floor,                 bump_ceil,                  stim_trial_flag,...
                            training_trial_flag,        training_trial_freq,        stim_freq,                  recenter_cursor_flag,       tgt_radius,...
                            tgt_size,                   intertrial_time,            penalty_time,               bump_hold_time,             ct_hold_time,...
                            bump_delay_time,            targets_during_bump,        bump_increment,             primary_target_flag,        trial_result,...
                            start_time,                 bump_time,                  go_cue,                     end_time                    stim_code];
        if ~isempty(find(abs(temprow)>100000000000))
            skip_counter=skip_counter+1;
            continue
        else
            tt(trial-skip_counter,:)=temprow;
        end
end

disp(strcat('Found ',num2str(skip_counter),' bad databursts. Trials associated with these databursts were skipped'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%build hdr object with associated column numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdr.numbytes                =   1;%     bytes transmitted
hdr.db_version              =   2;%     db_version=db(2);%2
                      %                 two=db(3);%3
                      %                 b=db(4);%4
                      %                 c=db(5);%5
hdr.Behavior_version_major  =   6;%     behavior_version_maj=db(6);%6
hdr.Behavior_version_minor  =   7;%     behavior_version_minor=db(7);%7
hdr.Behavior_version_micro1 =   8;%     behavior_version_micro1=db(8);%8
hdr.Behavior_version_micro2 =   9;%     behavior_version_micro2=db(9);%9
hdr.tgt_angle               =   10;%    target_angle=round((180/3.1415)*bytes2float(db(15:18)));%13
hdr.bump_angle              =   11;%    bump_dir=bytes2float(db(19:22));%14
hdr.rand_tgt_flag           =   12;%    random_tgt_flag=db(23);%15
hdr.tgt_floor               =   13;%    tgt_dir_floor=bytes2float(db(24:27));%16
hdr.tgt_ceil                =   14;%    tgt_dir_ceil=bytes2float(db(28:31));%17
hdr.bump_mag                =   15;%    bump_mag=bytes2float(db(32:35));%18
hdr.bump_dur                =   16;%    bump_dur=bytes2float(db(36:39));%19
hdr.bump_ramp               =   17;%    bump_ramp=bytes2float(db(40:43));%20
hdr.bump_floor              =   18;%    bump_floor=bytes2float(db(45:48));%22
hdr.bump_ceil               =   19;%    bump_ceil=bytes2float(db(49:52));%23
hdr.stim_trial              =   20;%    stim_trial_flag=db(57);%25
hdr.training_trial          =   21;%    training_trial_flag=(58);%26
hdr.training_freq           =   22;%    training_trial_freq=bytes2float(db(59:62));%27
hdr.stim_freq               =   23;%    stim_freq=bytes2float(db(63:66));%28
hdr.recenter_cursor         =   24;%    recenter_cursor_flag=db(67);%29
hdr.tgt_radius              =   25;%    tgt_radius=bytes2float(db(68:71));%30
hdr.tgt_size                =   26;%    tgt_size=bytes2float(db(72:75));%31
hdr.intertrial_time         =   27;%    intertrial_time=bytes2float(db(76:79));
hdr.penalty_time            =   28;%    penalty_time=bytes2float(db(80:83));
hdr.bump_hold_time          =   29;%    bump_hold_time=bytes2float(db(84:87));
hdr.ct_hold_time            =   30;%    ct_hold_time=bytes2float(db(88:71));
hdr.bump_delay              =   31;%    bump_delay_time=bytes2float(db(82:85));
hdr.targets_during_bump     =   32;%    targets_during_bump=db(86);
hdr.bump_increment          =   33;%    bump_increment=db(87:90);
hdr.primary_target          =   34;%    primary_target_flag=db(91);
hdr.trial_result            =   35;%    result of the trial
hdr.start_time              =   36;%    start time
hdr.bump_time               =   37;%    bump time
hdr.go_cue                  =   38;%    time of the go cue
hdr.end_time                =   39;%    time the trial ended
hdr.stim_code               =   40;%    the code for the stimulus with the base stim word removed


