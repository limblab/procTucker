function [fig_list,output_data]=Perievent_histograms_target_appearance(folderpath_base,input_data)
    %intended for use with run_data_processing(...) generates a perievent
    %histogram around the center hold time (target appearance in RW trials
    %with short center hold times) returns figure handle list, and
    %histogram data
    %takes in the path of the folder to performa analysis in, and a struct:
    %input_data with the following fields:
    %labnum, matchstring, window, binsize
    close all


    disp('converting nev files to bdf format')
    [file_list,bdf_list]=autoconvert_nev_to_bdf_listreturn(folderpath_base,input_data.matchstring,input_data.labnum);

    bdf=[];
    for i=1:length(bdf_list)
        [tempfolder,tempname,tempext]=fileparts(file_list{i});

        data_struct.(tempname)=bdf_list{i};
        if isempty(bdf)
            %if our new bdf is empty start it
            bdf=bdf_list{i};
            data_struct.file_list=strcat(tempname);
        else
            bdf=concatenate_bdfs(  bdf,   bdf_list{i},    30,     do_units,   do_kin, do_force);
            data_struct.file_list=strcat(',',tempname);
        end
    end

    output_data.bdf=bdf;

    ul=unit_list(bdf,1);

    %get_event_times
    word_ctr_hold = hex2dec('a0');
    event_times = bdf.words( bitand(hex2dec('f0'),bdf.words(:,2)) == word_ctr_hold, 1);%hex2dec('f0') is a bitwise mask for the leading bit

    for(i=1:length(ul))
        chan=ul(i,1);
        unit_num=ul(i,2);
        [fig_list(i), hist_data{i}]=make_PEH(bdf,event_times,input_data.window,ul(i,:),input_data.binsize,1);
        figure(fig_list(i));
        title(strcat('Peri-event histogram: channel ', num2str(chan),'unit ',num2str(unit_num)))
        set(fig_list(i),'Name',strcat('Channel ', num2str(chan),'unit ',num2str(unit_num)));
    end

    output_data.histogram_data=hist_data;
end