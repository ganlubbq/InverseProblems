%effetti degli errori di modellizzazione (gaussiani)

close all;
clear all;
clc;

m=[0.1;1;0.1];
Go=jacob([90; 60; 30],1,2,3,3);
dc=Go*m;
v=1:100;
for i=1:1000
    noise=0.01*max(max(Go))*randn(size(Go,1),size(Go,2));
    G=Go+noise;
    Gp=inv(G);
    g11(i)=G(1,1);
    mric(i,:)=Gp*dc;
end

figure,hist(g11,100),xlabel('G11'),figure,hist(mric(:,1),100),xlabel('m1'),
figure,hist(mric(:,2),100),xlabel('m2'),
figure,hist(mric(:,3),100),xlabel('m3')

%Si nota che errori di modellizzazione gaussiani si trasferiscono in errori
%sul modello gaussiani, per questo problema (radiometro)