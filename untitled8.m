t=[1:size(artifactData.artifact,3)]/30;
figure;subplot(4,1,1); for i=1:2:10; plot(t,squeeze(artifactData.artifact(1,i,:)),'r');hold on;end
subplot(4,1,1); for i=2:2:10; plot(t,squeeze(artifactData.artifact(1,i,:)),'b');hold on;end
subplot(4,1,2); for i=1:2:10; plot(t,squeeze(artifactData.artifact(2,i,:)),'r');hold on;end
subplot(4,1,2); for i=2:2:10; plot(t,squeeze(artifactData.artifact(2,i,:)),'b');hold on;end
subplot(4,1,3); for i=1:2:10; plot(t,squeeze(artifactData.artifact(3,i,:)),'r');hold on;end
subplot(4,1,3); for i=2:2:10; plot(t,squeeze(artifactData.artifact(3,i,:)),'b');hold on;end
subplot(4,1,4); for i=1:2:10; plot(t,squeeze(artifactData.artifact(4,i,:)),'r');hold on;end
subplot(4,1,4); for i=2:2:10; plot(t,squeeze(artifactData.artifact(4,i,:)),'b');hold on;end




t=[0:30]/30;
figure;subplot(4,1,1); for i=1:2:10; plot(t,squeeze(artifactData.artifact(1,i,5:35)),'r');hold on;end
subplot(4,1,1); for i=2:2:10; plot(t,squeeze(artifactData.artifact(1,i,5:35)),'b');hold on;end
subplot(4,1,2); for i=1:2:10; plot(t,squeeze(artifactData.artifact(2,i,5:35)),'r');hold on;end
subplot(4,1,2); for i=2:2:10; plot(t,squeeze(artifactData.artifact(2,i,5:35)),'b');hold on;end
subplot(4,1,3); for i=1:2:10; plot(t,squeeze(artifactData.artifact(3,i,5:35)),'r');hold on;end
subplot(4,1,3); for i=2:2:10; plot(t,squeeze(artifactData.artifact(3,i,5:35)),'b');hold on;end
subplot(4,1,4); for i=1:2:10; plot(t,squeeze(artifactData.artifact(4,i,5:35)),'r');hold on;end
subplot(4,1,4); for i=2:2:10; plot(t,squeeze(artifactData.artifact(4,i,5:35)),'b');hold on;end
