a = [1 2 3 ; 4 5 6; 7 8 9];
c = [1 2 3 ; 4 5 6; 7 8 9];
b=[] 
b=[b,a]
b=[b,c]
c=[a,b]% add one row
c=[a;repmat(b,7,1)]  %add 7rows