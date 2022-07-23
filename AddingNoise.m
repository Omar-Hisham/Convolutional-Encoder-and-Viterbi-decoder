function NoisyStream = AddingNoise(stream,snr)
NoisyStream= awgn(stream,snr,'measured');
pos=NoisyStream>0.5; %find index where NoisyCode greater than 0.5
neg=NoisyStream<0.5;
NoisyStream(pos)=1;
NoisyStream(neg)=0;
end

