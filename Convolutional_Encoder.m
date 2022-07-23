function Encoded_seq = Convolutional_Encoder(inputStream)

G=[1 0 1;0 0 1;1 1 1];%generator polynomials
[n,K] = size(G);
state = zeros(1,K-1);%set registers to zero (2 registers)
Encoded_seq=[];
for i=1:length(inputStream)%h=number of input bits
    input=inputStream(i);
for j=1:n

   reg1 = G(j,1)*input;
   reg2= G(j,2)*state(1);
   reg3= G(j,3)*state(2);
   out=reg1+reg2+reg3;
   output(j) = rem(out,2);

end
state = [input, state(1)];
Encoded_seq=[Encoded_seq ,output];%new element added to sequence
end
end