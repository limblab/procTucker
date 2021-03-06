function [plotData]=classifierPlotData(data,dataClass)
    
    classData.class=dataClass;
    classData.classList=unique(dataClass);

    [classData.fullModelDistributions,classData.fullModelCorrect,classData.fullModelClassGuess,classData.fullModelClassProbs]=doClassifier(data,dataClass);

    classData.fullModelPctCorrect=sum(classData.fullModelCorrect)/numel(classData.fullModelCorrect);

    %we have plotdata as an output, so compute the best
    %projection of data onto a 2d plane for plotting:

    %convert the joint-log likelihood feature space into likelihood
    %ratio space
    plotData.LLRatio=[];
    mask=triu(true(size(classData.fullModelClassProbs,2)),1);
    for i=1:size(classData.fullModelClassProbs,1)
        tmpLLVec=classData.fullModelClassProbs(i,:);
        tmpLLMat=repmat(tmpLLVec,[numel(tmpLLVec),1]);
        tmpLLMat=sqrt(tmpLLMat./tmpLLMat');

        plotData.LLRatio(i,:)=tmpLLMat(mask);
    end
    for i=1:numel(classData.classList)
        plotData.LLRByClass{i}=plotData.LLRatio(dataClass==classData.classList(i),:);
        plotData.LLRMeans(i,:)=mean(plotData.LLRByClass{i});
    end
    LLRCoefs=pca(plotData.LLRMeans-repmat(mean(plotData.LLRMeans),numel(classData.classList),1));
    plotData.plotBasis=LLRCoefs(:,1:2);
    plotData.reducedData=plotData.LLRatio*plotData.plotBasis;

    
end


    

function [distList,correct,classGuess,classProbs]=doClassifier(redData,redClass)
    classList=unique(redClass);
    for i=1:numel(classList)
        dataByClass{i}=redData(redClass==classList(i),:);
        classMeans(i,:)=mean(dataByClass{i});
    end
    classProbs=[];
    for i=1:numel(classList)%loop through targets 
        for j=1:size(dataByClass{i},2)%for each target's data, loop through all the features
            %build a distribution using only data to the ith class:
            distList(i,j)=fitdist(dataByClass{i}(:,j),'kernel');
            %get the probability of ALL the actual data points on that
            %distribution
            probs(i,j,:)=pdf(distList(i,j),redData(:,j));
        end
        %given the probabilities for each feature, compute the joint
        %likelihood, as the cumulative product of the negative log
        %likelihood.
        
        tmp=probs;
        tmp(tmp==0)=eps;%ensure we don't try to get the log likelihood of 0 if the kernel distribution tells us the likelihood is zero
        classProbs(:,i)=squeeze(sum(abs(log(tmp(i,:,:))),2));

    end
    %now that we have the probability of each point on the target 
    %distributions, classify the point based on its highest probability:
    classGuess=nan(size(classProbs,2),1);
    for i=1:size(classProbs,1)
        [~,idx]=min(classProbs(i,:));
        classGuess(i)=classList(idx);
    end
    %flag whether the classification was correct
    correct=classGuess==redClass;
    
end