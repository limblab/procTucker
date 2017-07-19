function noiseEst=getNoiseEst(data,varargin)
    %estimates the noise component in the data using the method of Machens
    %etal
    %assumes that the input data is for a single experimental condition, so
    %all observations will have the same underlying factors, with
    %superimponsed noise. This function should be called separately for
    %each target, or experimental condition
    
    %machens method is limited to estimating a number of noise components
    %equal to the number of time points. This is because they only take a
    %single difference per bootstrap instance. With low numbers of time
    %points per trial, this will tend to erroneously represent the variance
    %
    
    %This function extends the original method to use a full bootstrap 
    if mod(numel(varargin),2)==1
        error('getNoiseEst:inputMustBeKeyValue','secondary input must be given as key-value pairs')
    end
    
    for i=1:2:numel(varargin)
        switch(varargin{i})
            case 'nBoot'
                nBoot=varargin{i+1};
            case 'pctile'
                pctile=varargin{1+i};
            otherwise
                error('getNoiseEst:UnrecognizedOption',['did not recognize input option: ',varargin{i}])
        end
    end
    if ~exist('nBoot','var')
        nBoot=100;
    end
    if ~exist('pctile','var')
        pctile=.99;
    end
    nPoints=size(data,2);
    nObs=size(data,1);
    
    %build matrix of observations:
    obsMat=repmat(reshape(data,[1,nObs,nPoints]),[nObs,1,1]);
    %get differences in matrix space by transposing the matrix and
    %subtracting:
    diffMat=(obsMat-permute(obsMat,[2,1,3]))/sqrt(2*nObs);
    %mask out the self comparisons and convert into 
    mask=true(size(diffMat,1));
    mask=triu(mask,1);% | tril(mask,-1);
    diffList=diffMat(repmat(mask,[1,1,size(data,2)]));
    diffList=reshape(diffList,[numel(diffList)/nPoints,nPoints]);
    function [latent]=pcaWrapper(x)
        %inline so we can use diffList without passing it
        [~,~,latent]=pca(diffList(x,:));
%         varargout=mat2cell(latent,ones(numel(latent),1),1);
    end
    fcnHandle=@(idxList) pcaWrapper(idxList);
    idxList=1:size(diffList,1);
    [bootStat]=bootstrp(nBoot,fcnHandle,idxList);
    %get correct pctile index for each dimension:
    for i=1:size(bootStat,2)
        bootStat(:,i)=sort(bootStat(:,i));
    end
    idxPctile=ceil(size(bootStat,1)*pctile);
    noiseEst=sort(bootStat(idxPctile,:),1,'descend');%sort is necessary since 
end

