function [diffKS,putativeMatchKS,diffDist,empDist,matchDist]=getISIcomps_SA(units,data)
%stand alone function for analysis of neuron tracking techniques:

    allChans=[[units.data.chan],[data.chan]]';
    allArray=[{units.data.array},{data.array}]';
    allInUnits=[true(numel(units.data),1);false(numel(data),1)];
    allISI=[arrayfun(@(x) diff(x.spikes.ts),units.data,'UniformOutput',false),...
            arrayfun(@(x) diff(x.spikes.ts),data,'UniformOutput',false)]';
    KS=nan(0.5*(numel(allChans)-1)*numel(allChans),1);
    knownDiff=false(size(KS));
    idx=1;
    %get the distribution of KS statistics for this data. Also track
    %whether each comparison is from a pair we know are not the same unit,
    %or if they are from units on the same electrode that MAY be the same:
    for i=1:numel(allChans)-1
        for j=i+1:numel(allChans)
            if allChans(i)==allChans(j) && strcmp(allArray{i},allArray{j}) && xor(allInUnits(i),allInUnits(j))
                knownDiff(idx)=false;
            else
                knownDiff(idx)=true;
            end
            [~,~,KS(idx)]=kstest2(allISI{i},allISI{j});
            idx=idx+1;
        end
    end
    
    %now that we have the distribution of KS statistic values, get the
    %distribution of those values for known difference comparisons, and
    %find the match distribution as the residual of the known difference,
    %and putative match distributions:
    MIN=min(KS);
    MAX=max(KS);
    nDiff=min(sum(knownDiff),2^10);
    nEmp=min(sum(~knownDiff),2^10);
    %kde is a file-exchange function that computes the optimal bandwidth 
    %rather than estimating it from the 'rule of thumb'. This should be
    %less sensitive to non-gaussian distributions, but may return
    %bandwidths small enough to start capturing variability in the pdf due
    %to noise    
    [diffBandwidth,diffPDF,diffXmesh,~]=kde(KS(knownDiff),nDiff,MIN-(MAX-MIN)/10,MAX+(MAX-MIN)/10);
    [empBandwidth,empPDF,empXmesh,~]=kde(KS(~knownDiff),nEmp,MIN-(MAX-MIN)/10,MAX+(MAX-MIN)/10);

    %the above distributions are on different ranges, truncate them so
    %that we can just work with them as matched data:
    if min(diffXmesh)<min(empXmesh)
        idxMinDiff=find(diffXmesh>=empXmesh(1),1,'first');
        startVal=diffXmesh(idxMinDiff);
    else
        idxMinEmp=find(empXmesh>=diffXmesh(1),1,'first');
        startVal=empXmesh(idxMinEmp);
    end
    if max(diffXmesh)>max(empXmesh)
        idxMaxDiff=find(diffXmesh<=empXmesh(end),1,'last');
        endVal=diffXmesh(idxMaxDiff);
    else
        idxMaxEmp=find(empXmesh<=diffXmesh(end),1,'last');
        endVal=empXmesh(idxMaxEmp);
    end
    baseScale=1/(max(128,numel(diffXmesh)/2));%number of points in kde output will be 2^12 unless forced to something else by input
    baseMesh=startVal:baseScale:endVal;
    diffPDF=interp1(diffXmesh,diffPDF,baseMesh);
    empPDF=interp1(empXmesh,empPDF,baseMesh);

    %now that we have PDF estimates for the known diff and empirical
    %sets, estimate the match dist as the residual of the empirical and
    %known diff sets:
    %assume that the larger statistic values in the empirical set are
    %entirely the result of the known diff set, and that the diffPDF is
    %unimodal, or at least has one large peak to the right of all the match
    %values
    [~,idx]=max(diffPDF);
    PDFScale=regress(empPDF(idx:end)',diffPDF(idx:end)');
    matchPDFresidual=empPDF-PDFScale*diffPDF;

    matchPDFresidual(matchPDFresidual<0)=0;
        
    %convert pdf into matlab distribution:
    diffDist=fitdist(baseMesh','kernel','frequency',round(diffPDF'*(1/min(diffPDF(diffPDF>0)))),'width',diffBandwidth);
    empDist=fitdist(baseMesh','kernel','frequency',round(empPDF'*(1/min(empPDF(empPDF>0)))),'width',empBandwidth);
    matchFrequency=round(matchPDFresidual*(1/min(matchPDFresidual(matchPDFresidual>0))));
    %The following line creates a cell array where each cell is an array of
    %the same value. The value is the corresponding value in the baseMesh 
    %vector, and the number of elements is the corresponding value in 
    %matchFrequency. cell2mat then puts this all into a single array with
    %the same statistics as the underlying distribution:
    matchData=cell2mat(arrayfun(@(x) repmat(baseMesh(x),[1,matchFrequency(x)]),1:numel(matchFrequency),'UniformOutput',false));
    [matchBandwidth,~,~,~]=kde(matchData);
    matchDist=fitdist(baseMesh','kernel','frequency',matchFrequency','width',matchBandwidth);
    
    diffKS=KS(knownDiff);%used varargout
    putativeMatchKS=KS(~knownDiff);
end



