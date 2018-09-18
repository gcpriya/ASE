clc;
clear all;
close all;
%----------- tokenize code--------

text = fileread('email.txt');
C = strsplit(text,' ');
A = cell2mat(C);
w = [{'make'},'address','all','3d','over','order','mail','receive','people','report','addresses','free','you','credit','font','hp','george','857','data','415','parts','direct','cs','original','project','re','edu','table','conference',';:','(:','{:','!:','$:','#:']; %	Cap_len_avg	cap_len_lngst	cap_len_tot	spam/ham
w;
[m1,n1]=size(C);
[p1,q1]=size(w);
%--------------- uninterrupted cap letters-----------
un=0;
lon=0;
count=0;
sum=0;
occured=0;
for i=1:n1
     f = isstrprop(C(1,i),'upper');
     tf = double(cell2mat(f));
     [a,b]=size(tf);
     for j=1:b
             if(isequal(tf(1,j),1))
                 un=un+1;
                 occured=1;
             elseif (isequal(tf(1,j),0))
                 if(lon<un)
                     lon=un;
                 end    
                 sum=sum+un;
                 un=0;
                if(occured==1)
                 count=count+1;
                 occured=0;
                end
             end   
     end  
     if (j==b)
       if(lon<un)
         lon=un;
       end    
         sum=sum+un;
         un=0;
     end   
     if(occured==1)
        count=count+1;
        occured=0;
     end
end
avg=sum/count;    


%-----------------
v= zeros(1,q1);

for i=1:n1
   C{1,i}=lower(C{1,i}); 
end    

for i = 1:n1
    for j=1:q1
        if (isequal(C{1,i},w{j}))
           v(j)=v(j)+1; 
        end   
    end    
end 
    for j=1:q1 
      v(j)=((v(j)/n1)*100); 
    end   
    v(q1+1)=avg;
    v(q1+2)=lon;
    v(q1+3)=sum;
    v(:)

%---------------------------------------- get features--

filename='data.csv';
data= csvread(filename);
x = data(:,1:end-1);
y = data(:,end);
m=47;
c=cov(x);
[V,D]=eig(c);
V=V(:,end:-1:1);
V=V(:,1:m);
f=zeros(57,1);

for i=1:57
   for j=1:m
       f(i)=f(i)+ abs(V(i,j)); 
   end    
end    
disp('sorted values');
[s,ids]=sort(f);
[s1,ids1]=sort(f,'descend')
n=1;
p=38;
sid=sort(ids(1:p));

filename = sprintf('fs_training_%d_x',p);
file = strcat(filename,'.csv');
trx=csvread(file);
filename = sprintf('fs_training_%d_y',p);
file = strcat(filename,'.csv');
ty=csvread(file);
filename = sprintf('fs_testing_%d_x',p);
file = strcat(filename,'.csv');
tsx=csvread(file);
filename = sprintf('fs_testing_%d_y',p);
file = strcat(filename,'.csv');
tsy=csvread(file);

svmStruct = svmtrain(trx(:,sid(1:p,1)), ty(:), 'kernel_function','rbf','rbf_sigma',7);
disp('training completed....');
pr_op = svmclassify(svmStruct,tsx(:,sid(1:p,1)),'showplot',false);
ac_op = tsy(:);
check=svmclassify(svmStruct,v(1,:),'showplot',false);

[m,n] = size(pr_op);
for i = 1 : m
    for j = 1 : n
        if (pr_op(i,j)==0)
            pr_op(i,j)=2;
        end
        
        if (ac_op(i,j)==0)
            ac_op(i,j)=2;
        end
    end
end
pr_op = ind2vec(pr_op',2);
ac_op = ind2vec(ac_op',2);
[c,cm]  = confusion(pr_op,ac_op);
figure, plotconfusion(pr_op,ac_op);
%}
Message1='The GIven text is unsolicited i.e., SPAM';
Message2='The GIven text is Legitimate i.e., HAM';
if check==1
    disp(' TheGIven text is unsolicited i.e., SPAM');
    h = msgbox(Message1,'Label')
else
    disp(' TheGIven text is legitimate i.e., HAM');
    h = msgbox(Message2,'Label')
end    