clear all;
clc;

m=[0.1;1;0.1];
G=[2.0309 0 0;1.4142 1.4142 0;1.0642 1.0642 3.7193];
dc=G*m;
n1=[0.1;0;0];
n2=[0;0.1;0];
n3=[0;0;0.1];
Gp=inv(G);
%Guardo come il rumore sulle diverse componenti del vettore dati influenza
%la stima dei parametri del modello
dn1=dc+n1;
dn2=dc+n2;
dn3=dc+n3;
%Aumento percentuale di rumore su ogni componente
ru1=(n1./dc)*100;
ru2=(n2./dc)*100;
ru3=(n3./dc)*100;
%stima con rumore dei parametri del modello
mrum1=Gp*dn1; %con rumore sulla 1 comp ecc
mrum2=Gp*dn2;
mrum3=Gp*dn3;
%Scostamenti percentuali della stima con rumore sui dati, dal valore esatto
%della soluzione
sc1=((mrum1-m)./m)*100;
sc2=((mrum2-m)./m)*100;
sc3=((mrum3-m)./m)*100;
%Analisi di sensibilitÓ
ru1,sc1,ru2,sc2,ru3,sc3