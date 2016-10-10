knownDiffProj=dPrime(knownDiff,:)*coeff';
putativeMatchProj=dPrime(~knownDiff,:)*coeff';
rangeProj=[min(dPrime*coeff'),max(dPrime*coeff')];
x=rangeProj(1):diff(rangeProj)/1000:rangeProj(2);

diffDist=fitdist(knownDiffProj,'kernel','width',4);
empDist=fitdist(putativeMatchProj,'kernel','width',4);
%diffDist=fitdist(knownDiffProj,'kernel');
%empDist=fitdist(putativeMatchProj,'kernel');

diffPDF=pdf(diffDist,x);
empPDF=pdf(empDist,x);
[mx,idx]=max(diffPDF);
%PDFScale=empPDF(idx)/mx;
PDFScale=regress(empPDF(idx:end)',diffPDF(idx:end)');
matchPDF=empPDF-PDFScale*diffPDF;

matchPDF(matchPDF<0)=0;
%convert the PDF into theoretical counts:
matchCounts=round(matchPDF/min(matchPDF(matchPDF>0)));
matchDist=fitdist(x','kernel','frequency',matchCounts','width',4);
%matchDist=fitdist(x','kernel','frequency',matchCounts');


pdf_mixture=@(x,p) (1-p)*pdf(matchDist,x)+p*pdf(empDist,x);

pStart=PDFScale;
%vector of variables is [p,mu,s]
lb=[0];
ub=[1];
paramEsts=mle(x,'pdf',pdf_mixture,'start',[pStart],'lower',lb,'upper',ub);


figure;
hold on
%putative match distribution:
plot(pdf(empDist,x),'k','LineWidth',2)
%knownDiff component:
plot(paramEsts(1)*pdf(diffDist,x),'b','LineWidth',2)
%matched Component:
plot((1-paramEsts(1))*pdf(matchDist,x),'r','LineWidth',2)
%sum of components:
plot(paramEsts(1)*pdf(diffDist,x)+(1-paramEsts(1))*pdf(matchDist,x),'g','LineWidth',2)
disp('MLE MSE:')
MSE=sqrt(sum((paramEsts(1)*pdf(diffDist,x)+(1-paramEsts(1))*pdf(matchDist,x)-pdf(empDist,x)).^2))
title('PDF components for MLE fit')
legend('empirical','diff component','match component','jointPDF')
figure;
hold on
%putative match distribution:
plot(pdf(empDist,x),'k','LineWidth',2)
%knownDiff component:
plot(PDFScale*pdf(diffDist,x),'b','LineWidth',2)
%matched Component:
plot((1-PDFScale)*pdf(matchDist,x),'r','LineWidth',2)
%sum of components:
plot(PDFScale*pdf(diffDist,x)+(1-PDFScale)*pdf(matchDist,x),'g','LineWidth',2)
disp('best guess MSE:')
MSE=sqrt(sum((PDFScale*pdf(diffDist,x)+(1-PDFScale)*pdf(matchDist,x)-pdf(empDist,x)).^2))
title('PDF components for empirical fit')
legend('empirical','diff component','match component','jointPDF')

figure
hold on
mse_mixture=@(p) sqrt(sum((p*pdf(diffDist,x)+(1-p)*pdf(matchDist,x)-pdf(empDist,x)).^2));
pEst=fminsearch(mse_mixture,PDFScale);
%putative match distribution:
plot(pdf(empDist,x),'k','LineWidth',2)
%knownDiff component:
plot(pEst*pdf(diffDist,x),'b','LineWidth',2)
%matched Component:
plot((1-pEst)*pdf(matchDist,x),'r','LineWidth',2)
%sum of components:
plot(PDFScale*pdf(diffDist,x)+(1-pEst)*pdf(matchDist,x),'g','LineWidth',2)
disp('minimized MSE:')
MSE=sqrt(sum((pEst*pdf(diffDist,x)+(1-pEst)*pdf(matchDist,x)-pdf(empDist,x)).^2))
title('PDF components for minimized MSE fit')
legend('empirical','diff component','match component','jointPDF')

figure
hold on
plot(cdf(matchDist,x),'r','LineWidth',2)
plot(cdf(diffDist,x),'b','LineWidth',2)





matchPDF=matchPDF-min(matchPDF)