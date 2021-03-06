function NEV=combine_NEVs_in_folder(folderpath,matchstring,do_units,do_kin,do_force)
    
    %concatinates all the bdf's in the specified folder path into a single
    %object.  All bdf's are assumed to have the same channel arrangement,
    %and are concatinated in alphabetical order by filename. This function
    %only operates on .mat files- other file types are ignored. each .mat
    %file is assumed to have a single bdf stored such that, when loaded, it
    %will generate a single workspace variable called bdf
    
    
    foldercontents=dir(folderpath);
    fnames={foldercontents.name};%extracts just the names from the foldercontents
    full_bdf=[];
    for i=1:length(foldercontents)
        if (length(fnames{i})>3)
            if (strcmp(fnames{i}((length(fnames{i})-3):end),'.nev') & ~isempty(strfind(fnames{i},matchstring)))
                %if we have a .nev file
                disp(strcat('Working on: ',folderpath, fnames{i}))
                load(strcat(folderpath, fnames{i}));

                NEV=openNEV('read', [basepath '\' fname '.nev'],'nosave','nomat','report');
                
                if isempty(full_bdf)
                    %if our new bdf is empty start it
                    full_bdf=bdf;
                else
                    %if our new bdf already has something in it, append to
                    %the end of the new bdf
                    full_bdf=concatenate_bdfs(  full_bdf,   bdf,    30,     do_units,   do_kin, do_force);
	
                    
                end
                
                clear bdf

            end
        end
    end
end