function stream = Viterbi_Decoder(rcv)

trellis = {{[0 0 0],[1 0 1]},{[0 0 1],[1 0 0]},{[1 1 1],[0 1 0]},{[1 1 0],[0 1 1]}};
decoded_tree={};

%%stage one
input = rcv(1:3);
error11=sum(input~=trellis{1}{1}); %state 1 recieve error from state 1
error21=sum(input~=trellis{1}{2}); %state 2 recieve error from state 1
decoded_tree{1}={{trellis{1}{1},error11};{trellis{1}{2},error21};
           {[],[]};{[],[]}};
       
input = rcv(4:6);
e1=error11;
error11=e1+sum(input~=trellis{1}{1});
error32=error21+sum(input~=trellis{2}{1});
error42=error21+sum(input~=trellis{2}{2});
error21=e1+sum(input~=trellis{1}{2});

decoded_tree{2}={{trellis{1}{1},error11};{trellis{1}{2},error21};
           {trellis{2}{1},error32};{trellis{2}{2},error42}};
       
stage=3;
error_s1=error11;
error_s2=error21;
error_s3=error32;
error_s4=error42;
for i = 7:3:length(rcv)
    input = rcv(i:i+2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% for state 1 (stage>2)%%%%%%%%%%%%%%%%%%%%%%%%%%%
    er=error_s1; % to save error of previous stage
    error_s1=error_s1+sum(input~=trellis{1}{1});
    error_s1_2=error_s3+sum(input~=trellis{3}{1});
    
if error_s1 <= error_s1_2 
    decoded_tree{stage}{1}= {trellis{1}{1},error_s1};
else
    decoded_tree{stage}{1}= {trellis{3}{1},error_s1_2};
    error_s1= error_s1_2;
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% for state 2 (stage >2)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    er2=error_s2;
    error_s2=er+sum(input~=trellis{1}{2});
    error_s2_2=error_s3+sum(input~=trellis{3}{2});
    
if error_s2 <= error_s2_2 
    decoded_tree{stage}{2}= {trellis{1}{2},error_s2};
else
    decoded_tree{stage}{2}= {trellis{3}{2},error_s2_2};
    error_s2= error_s2_2;
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% for state 3 (stage >2)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    error_s3=er2+sum(input~=trellis{2}{1});
    error_s3_2=error_s4+sum(input~=trellis{4}{1});
    
if error_s3 <= error_s3_2 
    decoded_tree{stage}{3}= {trellis{2}{1},error_s3};
else
    decoded_tree{stage}{3}= {trellis{4}{1},error_s3_2};
    error_s3= error_s3_2;
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% for state 4 (stage >2)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    error_s4_2=error_s4+sum(input~=trellis{4}{2});
    error_s4=er2+sum(input~=trellis{2}{2});
    
    
if error_s4 <= error_s4_2 
    decoded_tree{stage}{4}= {trellis{2}{2},error_s4};
else
    decoded_tree{stage}{4}= {trellis{4}{2},error_s4_2};
    error_s4= error_s4_2;
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stage=stage+1;
end
       
temp = decoded_tree{end};
[trash,index]= min([temp{1}{2} temp{2}{2} temp{3}{2} temp{4}{2}]);
stream=[];
for i = length(decoded_tree):-1:1
%decoded_tree{i}{index}{1};
if index == 1 
    
if isequal(trellis{1}{1},decoded_tree{i}{index}{1})
    stream = [stream 0];
    index =1;
else   %isequal(trellis{3}{1},decoded_tree{i}{index}{1});
    stream = [stream 0]; 
     index =3;                 
end

elseif index == 2
    
if isequal(trellis{1}{2},decoded_tree{i}{index}{1})
    stream = [stream 1];
    index =1;
else   %isequal(trellis{3}{2},decoded_tree{i}{index}{1});
    stream = [stream 1]; 
     index =3;                 
end
    

elseif index == 3
    
    if isequal(trellis{2}{1},decoded_tree{i}{index}{1})
        stream = [stream 0];
        index =2;
    else   %isequal(trellis{4}{1},decoded_tree{i}{index}{1});
        stream = [stream 0];
        index =4;
    end
    
else
  if isequal(trellis{2}{2},decoded_tree{i}{index}{1})
        stream = [stream 1];
        index =2;
    else   %isequal(trellis{4}{2},decoded_tree{i}{index}{1});
        stream = [stream 1];
        index =4;
    end      
    
end
        
end
stream=flip(stream);
end
    
    
    