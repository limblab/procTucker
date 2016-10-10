function waveShifted=shiftWave(wave,nShift)
    x=ones(10);
    display(wave)
    display(nShift)
    waveShifted=[nan(1,max(0,nShift)),x(1,1+max(0,nShift):end-max(0,-nShift)),nan(1,max(0,-nShift))];
    display(waveShifted)
end
