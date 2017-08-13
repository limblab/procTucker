function [H]=plotClassData(dataPoints,class,varargin)

    if numel(varargin)>0
        for i=1:2:numel(varargin)
            switch varargin{i}
                case 'patchAlpha'
                    patchAlpha=varargin{i+1};
                case 'correct'
                    correct=varargin{i+1};
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
    
    if ~exist('correct','var')
        correct=true(size(dataPoints,1),1);
    end
    if ~exist('patchAlpha','var')
        patchAlpha=0.05;
    end
    if ~exist('doLegend','var')
        doLegend=false;
    end
    if ~exist('doName','var')
        doName=false;
    end
    if ~exist('doTitle','var')
        doTitle=false;
    end
    
    classList=unique(class);
    colorSet=jet(numel(classList));
    
    H=figure;
    hold on
    for i=1:numel(classList)
        %plot the data points, * for correct guesses, o for errors:
        classMask=class==classList(i) & correct;
         plot(dataPoints(classMask,1),dataPoints(classMask,2),'*','color',colorSet(i,:))
        classMask=class==classList(i) & ~correct;
         plot(dataPoints(classMask,1),dataPoints(classMask,2),'o','color',colorSet(i,:))
         %draw an ellipse around the cluster:
         %start by finding the major and minor axis of the data:
         classMask=class==classList(i);
         [coeffs]=pca(dataPoints(classMask,:));%the coeffs are the major and minor axis of the variance ellipse for this data, latent is the variance on each axis
         PCErrs=std(dataPoints*coeffs);
         ctr=mean(dataPoints(classMask,:),1);
         %get the basic shape of the ellipse
         baseX=PCErrs(1)*cos([0:360]*pi/180);
         baseY=PCErrs(2)*sin([0:360]*pi/180);
         %now create a rotated ellipse of that shape at the center point
         ellipseAngle=atan2(coeffs(1,2),coeffs(1,1));
         x=ctr(1)+baseX*cos(ellipseAngle)-baseY*sin(ellipseAngle);
         y=ctr(2)+baseX*sin(ellipseAngle)+baseY*cos(ellipseAngle);
         %now plot the ellipse:
         patch(x,y,'b','FaceColor',colorSet(i,:),'FaceAlpha',patchAlpha,'EdgeColor','none')
         
         %replot the elipse at 2standard deviations
         PCErrs=2*PCErrs;
         %get the basic shape of the ellipse
         baseX=PCErrs(1)*cos([0:360]*pi/180);
         baseY=PCErrs(2)*sin([0:360]*pi/180);
         %now create a rotated ellipse of that shape at the center point
         x=ctr(1)+baseX*cos(ellipseAngle)-baseY*sin(ellipseAngle);
         y=ctr(2)+baseX*sin(ellipseAngle)+baseY*cos(ellipseAngle);
         %now plot the ellipse:
         patch(x,y,'b','FaceColor',colorSet(i,:),'FaceAlpha',patchAlpha*.5,'EdgeColor','none')
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