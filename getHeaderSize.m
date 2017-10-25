function   hdrSize=getHeaderSize(NEV)
    %hdrSize=getHeaderSize(NEV)
    %accepts a NEV object in the format supplied by openNEV, and 
    %computes the size of the full header that will be written if the NEV
    %object is saved to disk. Output is computed in bits. NEV object may be
    %composed from scratch rather than a direct result of calling openNEV,
    %and as long as the fields use the same naming convention getHeaderSize
    %should operate correctly.
    %
    %
    %For NEV file specification Rev. 2.3, as presented in LB-0023 Rev 5.00,
    %and saveNEV version 1.1.0.0
    %
    %
    %written by Tucker Tomlinson, Oct 2017
    
    
    basicHeader=336;%size of basic header before variable length 'extended header'
    extendedHeader=0;
    
    
    if isfield(NEV,'ArrayInfo')
        %extended header will have some entries associated with the array
        %information:
        if isfield(NEV.ArrayInfo,'ElectrodeName')
            extendedHeader=extendedHeader+32;
        end
        if isfield(NEV.ArrayInfo,'ArrayComment')
            extendedHeader=extendedHeader+32;
        end
        if isfield(NEV.ArrayInfo,'ArrayCommentCont')
            extendedHeader=extendedHeader+32;
        end
        if isfield(NEV.ArrayInfo,'MapFile')
            extendedHeader=extendedHeader+32;
        end
    end

    if isfield(NEV,'ElectrodesInfo')
        if isfield(NEV.ElectrodesInfo(1),'ElectrodeID')
            %we will have an NEUEVWAV entry for each electrode in 
            %electrodesInfo
            extendedHeader=extendedHeader+32*numel(NEV.ElectrodesInfo);
        end
        if isfield(NEV.ElectrodesInfo(1),'ElectrodeLabel')
            %we will have a NEUEVLBL entry for each electrode in
            %electrodesInfo
            extendedHeader=extendedHeader+32*numel(NEV.ElectrodesInfo);
        end
        if isfield(NEV.ElectrodesInfo(1),'HighFreqCorner')
            %we will have a NEUEVFLT entry for each electrode in
            %electrodesInfo
            extendedHeader=extendedHeader+32*numel(NEV.ElectrodesInfo);
        end
            
    end
    if isfield(NEV,'IOLabels')
        %we will have two DIGLABEL entries, the front panel and serial
        extendedHeader=extendedHeader+32*2;
    end
    if isfield(NEV,'VideoSyncInfo')
        %we will have one VIDEOSYN entry per element of videoSyncInfo
        extendedHeader=extendedHeader+32*numel(NEV.VideoSyncInfo);
    end
    if isfield(NEV,'NSAS')
        %This might exist in a future version of Central
    end
    if isfield(NEV,'ObjTrackInfo')
        extendedHeader=extendedHeader+32*numel(NEV.ObjTrackInfo);
    end
    if isfield(NEV,'Rabbits')
        %Fill in the details about Rabbits at some point in the future.
    end
    
    hdrSize=basicHeader+extendedHeader;
end