function [H]=plotLikelihoodClassData(classData,plotData,varargin)

    if numel(varargin)>0
        for i=1:2:numel(varargin)
            switch varargin{i}
                case 'legend'
                    doLegend=true;
                    legendStrings=varargin{i+1};
                case 'title'
                    doTitle=true;
                    titleString=varargin{i+1};
                case 'name'
                    doName=true;
                    nameString=varargin{i+1};
                otherwise
                    error('plotLikelihoodClassData:unrecognizedInput',['did not recognize input key: ',varargin{i}])
            end
        
        end
    end

    
    colorSet=jet(numel(classData.classList));
    
    H=figure;
    hold on
    for i=1:numel(classData.classList)
        classMask=classData.class==classData.classList(i) & classData.correct;
         plot(plotData.reducedData(classMask,1),plotData.reducedData(classMask,2),'*','color',colorSet(i,:))
        classMask=classData.class==classData.classList(i) & ~classData.correct;
         plot(plotData.reducedData(classMask,1),plotData.reducedData(classMask,2),'o','color',colorSet(i,:))
    end
    if doLegend
        legend(legendStrings)
    end
    if doTitle
        title(titleString)
    end
    if doName
        set(gcf,'name',nameString)
    end
end