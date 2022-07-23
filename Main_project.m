%% 1- reading the data in the file...
clc
clear all;
close all;
f = fopen("Test_Text_File.txt");
data = fileread("Test_Text_File.txt");
fclose(f);
fprintf('%s\n','The message is :')
fprintf('%s',data)
keyset= unique(data); %% find all characters in the file ...
%% 2- calculate the entropy....
P=[];
entrop=0;
for i = 1:length(keyset)
P=[P count(data,keyset(i))/length(data)];
e=P(i)*log2(1/P(i)); % calculating entropy of this character...
entrop = entrop+e;% add entropy of this character to the previous characters...
end
disp('The entropy is')
disp(entrop); 
disp('bits/symbol')
%% 3- Number of bits for construction of a fixed length code
len=ceil(log2(length(keyset)));
disp(len)
disp('bits/symbol')
disp('Efficiency for this construction:')
disp((entrop/len)*100)


%% 4- Huffman Encoder...
[codeword,indices,P] = Huffencoder(P,keyset);

%% 5- calculating L:(average codeword length)'
L_codeword = 0;
for i = 1:length(P)
  L=P(i)*length(cell2mat(codeword(indices(i))));
  L_codeword= L_codeword + L;
end
disp('L average =')
disp(L_codeword)
disp('bits/symbol')
%% 6- Efficiency
efficiency = (entrop/L_codeword)*100;
disp('Efficiency =')
disp(efficiency)

%% 7- Encode the whole text in the file 
seq=[];
for i =1:length(data)
    k=find(keyset==data(i)); %% find the index in keyset where it and the data(i)((first letter in text for example)) are equal....
    seq=[seq cell2mat(codeword(k))]; %% get the codeword for this letter which its index is k...
    %this sequance will be decoded...
end
fprintf('%d',seq);
fileID = fopen('encodedseq.txt','w');
fprintf(fileID,'%-10s\r\n','The Encoded sequence');
fprintf(fileID,'%d',seq);
fclose(fileID);

%% 8- Decoding with AWGN, No channel coding
disp('Decoding without channel coding and No AWGN:')
out = Huffdecoder(codeword,seq,keyset,'decoded_message.txt');


disp('Decoding without channel coding AWGN SNR = 2:')
seq1=AddingNoise(seq,2);
out1 = Huffdecoder(codeword,seq1,keyset,'Noisy_decoded_message1.txt');
disp('Number of errors is:')
[number,ratio] = biterr(seq1,seq);
disp(number)

disp('Decoding  without channel coding AWGN SNR = 7:')
seq2=AddingNoise(seq,7);
out2 = Huffdecoder(codeword,seq2,keyset,'Noisy_decoded_message2.txt');
disp('Number of errors is:')
[number,ratio] = biterr(seq2,seq);
disp(number)

disp('Decoding without channel coding AWGN SNR = 15:')
seq3=AddingNoise(seq,15);
out3 = Huffdecoder(codeword,seq3,keyset,'Noisy_decoded_message3.txt');
disp('Number of errors is:')
[number,ratio] = biterr(seq3,seq);
disp(number)
%% Using Convolutional Encoder
disp('Decoding using channel coding')
stream=Convolutional_Encoder(seq);

disp('Decoding with AWGN SNR = 2:')
stream1=AddingNoise(stream,2);
stream1=Viterbi_Decoder(stream1);
out1 = Huffdecoder(codeword,stream1,keyset,'Noisy_decoded_Conv1.txt');
disp('Number of errors is:')
[number,ratio] = biterr(stream1,seq);
disp(number)

disp('Decoding with AWGN SNR = 7:')
stream2=AddingNoise(stream,7);
stream2=Viterbi_Decoder(stream2);
out2 = Huffdecoder(codeword,stream2,keyset,'Noisy_decoded_Conv2.txt');
disp('Number of errors is:')
[number,ratio] = biterr(stream2,seq);
disp(number)


disp('Decoding with AWGN SNR = 15:')
stream3=AddingNoise(stream,15);
stream3=Viterbi_Decoder(stream3);
out3 = Huffdecoder(codeword,stream3,keyset,'Noisy_decoded_Conv3.txt');
disp('Number of errors is:')
[number,ratio] = biterr(stream3,seq);
disp(number)

%% Plotting BER VS SNR 
BER1=[];
BER2=[];
snr=0:1:15;
for i = 1:length(snr)
    
    seq1=AddingNoise(seq,snr(i));
    [number,ratio] = biterr(seq1,seq);
    BER1=[BER1 ratio];
    
    stream1=AddingNoise(stream,snr(i));
    stream1=Viterbi_Decoder(stream1);
    [number,ratio] = biterr(stream1,seq);
    BER2=[BER2 ratio];
end

figure 
plot(snr,BER1)
hold on
plot(snr,BER2)
xlabel('SNR (dB)');
ylabel('BER');
legend('Without Channel Coding','With Channel Coding')
title('BER Vs SNR plot');

figure 
semilogy(snr,BER1)
hold on
semilogy(snr,BER2)
xlabel('SNR (dB)');
ylabel('BER');
legend('Without Channel Coding','With Channel Coding')
title('BER Vs SNR plot');

%% 9- Checking if the decoded message is the same as original message (phase 1)
if(isequal(data,out))
    disp('They are exactly the same')
else 
    disp('They are not the same')
end