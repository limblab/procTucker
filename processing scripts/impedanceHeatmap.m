function    [outputFigures,outputData]=impedanceHeatmap(folderPath,inputData)
    outputFigures=[];
    outputData=[];
    
    if ~strcmp(folderPath(end),filesep)
        folderPath(end+1)=filesep;
    end
    
    %% load impedance data
    %check file extension to see if its a stimulator or patient cable file:
    if strcmp(inputData.impedanceFile(end-3:end),'.mat')
        isStimImpedance=true;
    else
        isStimImpedance=false;
    end
    %load impedance with routine appropriate for the type of file
    if isStimImpedance
        tmp=load([folderPath,inputData.impedanceFile]);
        varName=fieldnames(tmp);
        %skip the first data as that is the 'internal channel' of the
        %stimulator. data for electrodes 1:96 are in rows 2:97 of the stim
        %impedance object.
        impedance=table([1:96]',tmp.(varName{1}).impedance(2:97)/1000,repmat({'KOhm'},[96,1]),'VariableNames',{'chan','imp','range'});
    else
        fid=fopen([folderPath inputData.impedanceFile]);
        inHeader=true;
        impVals=[];
        impLabels={};
        impUnits={};
        while ~feof(fid)
            tline=fgets(fid);
            if isempty(deblank(tline))
                continue
            end
            if inHeader 
                if ~isempty(strfind(tline,'****'))
                    inHeader=false;
                end
                continue
            end
            tmp=textscan(tline,'%s');
            impLabels(end+1)=tmp{1}(1);
            impVals(end+1)=str2num(tmp{1}{2});
            impUnits(end+1)=tmp{1}(3);
        end
        fclose(fid);
        impedance=table(impLabels',impVals',impUnits','VariableNames',{'label','imp','range'});
    end
    
    %% get the mapfile
    if strcmp(inputData.mapFile(1:7),'mapFile')
        mapPath=inputData.mapFile(8:end);
    else
        mapPath=inputData.mapFile;
    end
    mapData=loadMapFile(mapPath);

    %% plot the impedance on a 10x10 grid:
    %establish base figure:
    outputFigures(end+1)=figure;
    set(outputFigures(end),'Name',['impedanceHeatmap'])
    numPlotPixels=1200;
    set(outputFigures(end),'Position',[100 100 numPlotPixels numPlotPixels]);
    paperSize=0.2+numPlotPixels/get(outputFigures(end),'ScreenPixelsPerInch');
    set(outputFigures(end),'PaperSize',[paperSize,paperSize]);
    %set up the boarders of a simple box so we can make a color-fill to
    %tile the figure:
    boxX=[0 1 1 0 0];
    boxY=[0 0 1 1 0];
    %get the colors to plot each tile:
    numChans=size(mapData,1);
    if isfield(inputData,'maxImpedance')
        maxImp=inputData.maxImpedance;
        imp=impedance.imp;%make a dummy variable so we can plot on a restricted color range without overwriting the main impedance variable
        imp(imp>maxImp)=maxImp;
    else
        maxImp=max(impedance.imp);
    end
    colorjet=interp1(linspace(0,maxImp,100),jet(100),double(imp));
    %loop through the list of impedances:
    for i=1:numChans
        %find the row in the mapfile for this impedance:
        if ~isempty(find(strcmp(impedance.Properties.VariableNames,'chan')))
            %look for the row in the mapData table based on channel since
            %it won't have a label column (loaded from stimulator impedance file)
            mapIdx=mapData.chan==impedance.chan(i);
        elseif ~isempty(find(strcmp(impedance.Properties.VariableNames,'label')))
            %look for the row in the mapData table based on label since
            %it won't have a label column (loaded from cerebus impedance file)
            mapIdx=strcmp(mapData.label,impedance.label{i});
        end
        %set the subplot to the correct tile:
        plotIdx=10*(mapData.row(mapIdx)-1)+mapData.col(mapIdx);

        subplot(10,10,plotIdx);
        fill(boxX,boxY,colorjet(i,:))
        set(gca,'XTickLabel',[])
        set(gca,'YTickLabel',[])
        axis tight
        title([num2str(impedance.imp(i)),' ',impedance.range{i}])
    end
    %add overall title:
    set(gcf,'NextPlot','add');
    axes;
    h = title('Impedance heatmap');
    set(gca,'Visible','off');
    set(h,'Visible','on'); 
end