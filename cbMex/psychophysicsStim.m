%script to handle stimulation for Kramer psychophysical bias task:

%script setup- 
%general setup:
maxSessionTime=2*60*60;%max lenght of session in seconds
%configure stim parameters
electrodeList=[1 2 3 4];
stimAmps=[5 10 15 20];%different amplitudes of stimulation
pulseWidth=200;%time for each phase of a pulse in uS
freq=200;%frequency of pulses in Hz
trainLength=0.4;%length of the pulse train in s
numPulses=freq*trainLength;
% configure cbmex parameters:
stimWordMask=hex2dec('60');
maxWait=400;%maximum interval to wait before exiting
pollInterval=.01;%polling interval in s
chan=151;%digital input is CH151

sessionTimer=tic;

%initialize connection to cerebus using cbmex:
if ~cbmex('open',1) %try to open a cerebus connection and check that the connection was successful in 1 line
    error('psychophysicsStim:CerebusConnectionFailed','failed to open a connection with a central instance on this PC')
end
%set up central to only send the words:
cbmex('mask',0,0)%set all to disabled
cbmex('mask',chan,1)
%clear the data buffers in central:
cbmex('trialconfig',1);

try

    %initialize cerestim object:
    Bstimulator=cerestim96('stim100');
    %connect to cerestim:
    Bstimulator.connect(1)%flag of 1 forces usb connection
    if ~Bstimulator.isConnected
        error('psychophysicsStim:couldNotConnect','failed to connect to the cerestim')
    end

    %establish stimulation waveforms for each stimulation amplitude:
    for i=1:numel(stimAmps)
        %configure waveform:
        Bstimulator.setStimPattern('waveform',i,...
                                    'polarity',0,...
                                    'pulses',numPulses,...
                                    'amp1',stimAmps(i),...
                                    'amp2',stimAmps(i),...
                                    'width1',pulseWidth,...
                                    'width2',pulseWidth,...
                                    interphase',53,...
                                    'frequency',freq);


    end
    h=msgbox('Central Connection is open: stimulation is running','CBmex-notifier');
    btnh=findobj(h,'style','pushbutton');
    set(btnh,'String','Close Connection');
    set(btnh,'Position',[15 7 120 17]);
    
    %wait for stim word via cbmex:
    intertrialTimer=tic;
    while(ishandle(h))

        try%see if we can get a chunk of data from the cerebus
            data=cbmex('trialdata',1);
        catch
            %maybe cbmex wasn't set to read mode yet:
            CBInitWordRead(mode);
            data=cbmex('trialdata',1);
        end
        if isempty(data)%if there wasn't anything to read, skip this poll cycle
            if ~isempty(pollInterval)
                pause(pollInterval)
            end
            continue
        else%if we found some data:
            %parse raw word data from the digital channel:
            words=data{chan,2:3};%2col vector, col1 is ts, col2 is word
            %convert word into single byte that contains the limblab state info
            words(:,2)=bitshift(bitand(hex2dec('FE00'),words(:,2)),-8)+bitget(words(:,2),1);
            %check if the words we found were stim words:
            idx=find(words(:,2)==stimWordMask);
            %if we found no stim words, continue:
            if isempty(idx)
                if ~isempty(pollInterval)
                    pause(pollInterval)
                end
                continue
            end
            %if we found more than 1 stim word, issue a warning and contunue
            %using the first one:
            if numel(idx)>1
                warning('psychophysicsStim:missedStimCommand','we missed a stim command. The polling time is probably too long')
            end
            stimCode=bitand(hex2dec('0f'),words(idx(1)));
        end
        %if we got here, then we found a stim word. use the code to issue a
        %stim command:
            %construct stim sequence based on word
        Bstimulator.beginSequence;
        Bstimulator.beginGroup;
        for i=1:numel(electrodeList)
            Bstimulator.autoStim(electrodeList(i),stimCode)
        end
        Bstimulator.endGroup;
        Bstimulator.endSequence;

        if ~isempty(pollInterval)
            pause(pollInterval)
        end
    end
catch ME
    %clean up cerebus connection and then error
    if ~cbmex('close');
        warning('psychophysicsStim:failedCentralDisconnect','failed to disconnect from Central while handling error')
    end
    if ishandle(h)
        close(h)
    end
    if ~Bstimulator.disconnect(1);
        warning('psychophysicsStim:failedStimDisconnect','failed to disconnect from stimulator while handling error')
    end
    rethrow(ME)
end



