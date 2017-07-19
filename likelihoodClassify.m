function [classData,varargout]=likelihoodClassify(data,class)
    
    classData.class=class;
    classData.classList=unique(class);
    for i=1:numel(classData.classList)
        dataByClass{i}=data(class==classData.classList(i),:);
        classData.classMeans(i,:)=mean(dataByClass{i});
    end
    for i=1:numel(classData.classList)%loop through targets 
        for j=1:size(dataByClass{i},2)%for each target's data, loop through all the features
            %build a distribution using only data to the ith class:
            distList(i,j)=fitdist(dataByClass{i}(:,j),'kernel');
            %get the probability of ALL the actual data points on that
            %distribution
            probs(i,j,:)=pdf(distList(i,j),data(:,j));
        end
        %given the probabilities for each feature, compute the joint
        %likelihood, as the cumulative product of the negative log
        %likelihood.
        
        tmp=probs;
        tmp(tmp==0)=eps;%ensure we don't try to get the log likelihood of 0 if the kernel distribution tells us the likelihood is zero
        classData.classProbs(i,:)=squeeze(sum(abs(log(tmp(i,:,:))),2));

    end
    %now that we have the probability of each point on the target 
    %distributions, classify the point based on its highest probability:
    for i=1:size(classData.classProbs,2)
        [~,idx]=min(classData.classProbs(:,i));
        classData.classGuess(i)=classData.classList(idx);
    end
    %flag whether the classification was correct
    classData.correct=classData.classGuess'==class;
    classData.pctCorrect=sum(classData.correct)/numel(classData.correct);
    
    if nargout==2
        %we have plotdata as an output, so compute the best
        %projection of data onto a 2d plane for plotting:
        plotData.LLRatio=[];
        for i=1:size(classData.classProbs,1)-1
            for j=i+1:size(classData.classProbs,1)
                plotData.LLRatio(:,end+1)=sqrt(classData.classProbs(i,:)./classData.classProbs(j,:));
            end
        end
        for i=1:numel(classData.classList)
            plotData.probDiffByClass{i}=plotData.LLRatio(class==classData.classList(i),:);
            plotData.probDiffMeans(i,:)=mean(plotData.probDiffByClass{i});
        end
        probDiffCoefs=pca(plotData.probDiffMeans-repmat(mean(plotData.probDiffMeans),numel(classData.classList),1));
        plotData.plotBasis=probDiffCoefs(:,1:2);
        plotData.reducedData=plotData.LLRatio*plotData.plotBasis;
        varargout{1}=plotData;
    end
    
end