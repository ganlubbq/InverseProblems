%% Esercizio tomografia
clear all;
clc;
close all;


%Modello di vertical Seismic Profile con 30 sorgenti e 20 ricevitori, e
%dimensioni del modello 20x20 pixels
[G,RegDx,RegDy,RegD2x,RegD2y,RegLap] = ServizioVSP(50, 20, 30, 30);

%Creazione del modello di lentezza
m = modello(30, 30, [10,3], [16,6], 0.2); %0.2 � l'ampiezza dell'anomalia rispetto al background


%Creazione dei dati
mv=reshape(m,size(m,1)*size(m,2),1);
d=G*mv;

%inversione con SVD troncata ai primi 200 autovettori
[U D V]=svd(G);

minv=zeros(size(mv));
j=400; %la migliore
for i=1:j 
minv=minv+(V(:,i)*(1/D(i,i))*U(:,i)'*d);
end
minv_m=reshape(minv,size(m,1),size(m,2));
figure(1),imagesc(minv_m),caxis([0 1.2]),title('Modello invertito con SVD troncata ai primi 200 autovettori (no rumore)')



%inversione ai minimi quadrati con dumping
%usare pinv � come usare SVD troncata, ma scarta tutti gli autovalori dal
%valore della tolleranza TOL, in gi�

mu=1e-12;
Gp=(G'*G+eye(size(G'*G))*mu)\G';
    mod=Gp*d;

mod_m=reshape(mod,20,20);
figure(2),imagesc(mod_m),title('Modello invertito con dumping, mu=1e-12 (no rumore)')


%ricalcolo i dati dai modelli invertiti
dric_dump=G*mod;
figure(3),imagesc(reshape(dric_dump,30,20)'),colormap('gray'),title('Dati ricalcolati da modello invertito')
%residuo nello spazio dei dati
figure(4),imagesc(reshape(abs(dric_dump-d),30,20)'),title('Residuo nello spazio dei dati')


%Sconfiggere il rumore sommando un numero sufficiente di realizzazioni
%indipendenti

%% Esercizio 2

k=[0.5 1 2 5];
figure,
for i=1:length(k)
dn=d+ k(i)*std(d)*randn(size(d));
%subplot(2,2,i),imagesc(reshape(dn,50,20)'),colormap('gray'),title('Dati rumorosi')
Gp=pinv(G'*G)*G';
minv=Gp*dn;
dric=G*minv; %dati ricalcolati
%subplot(2,2,i),imagesc(reshape(dric,50,20)'),colormap('gray'),title('Dati ricalcolati')
res=dn-dric;
subplot(2,2,i),imagesc(reshape(res,50,20)'),colormap('gray'),title('Residuo')
end


%% Esercizio 3
%Matrice di risoluzione
tol=[0.01 0.02 0.03];
figure,
for i=1:length(tol)
Gp=pinv(G'*G,tol(i))*G';
R=Gp*G;
Ris=diag(R);
m_norum=Gp*d; %modello invertito da dati non rumorosi
subplot(3,2,i*2-1),imagesc(reshape(Ris,30,30)),subplot(3,2,i*2),imagesc(reshape(m_norum,30,30))
end


%% Esercizio 4 (inversione dati rumorosi)

tol=0.02;
k=[0.009 0.01 0.02];
figure,
for i=1:length(k)
    dn=d+ k(i)*std(d)*randn(size(d));
    Gp=pinv(G'*G,tol)*G';
    m_rum=Gp*dn;
    subplot(3,1,i),imagesc(reshape(m_rum,30,30))
end
    


%% Esercizio 5 (corrispondenza SVD troncata <---> pinv con tol)

%il rango � 438
%svd troncata
[U D V]=svd(G);
inv_100=zeros(size(G'));
j=100; 
for i=1:j 
inv_100=inv_100+V(:,i)*(1/D(i,i))*U(:,i)';
end

inv_200=zeros(size(G'));
j=200; 
for i=1:j 
inv_200=inv_200+V(:,i)*(1/D(i,i))*U(:,i)';
end

inv_300=zeros(size(G'));
j=300; 
for i=1:j 
inv_300=inv_300+V(:,i)*(1/D(i,i))*U(:,i)';
end

inv_400=zeros(size(G'));
j=400; 
for i=1:j 
inv_400=inv_400+V(:,i)*(1/D(i,i))*U(:,i)';
end

R100=inv_100*G;
Ris_100=diag(R100);
R200=inv_200*G;
Ris_200=diag(R200);
R300=inv_300*G;
Ris_300=diag(R300);
R400=inv_400*G;
Ris_400=diag(R400);

% tol=linspace(0.05,6,50);
% for i=1:length(tol)
%     Gp=pinv(G'*G,tol(i))*G';
%     R=Gp*G;
%     Ris=diag(R);
%     err_100(i)=norm(Ris-Ris_100);
%     err_200(i)=norm(Ris-Ris_200);
%     err_300(i)=norm(Ris-Ris_300);
%     err_400(i)=norm(Ris-Ris_400);
% end
% 
% [val1 ind1]=min(err_100);
% [val2 ind2]=min(err_200);
% [val3 ind3]=min(err_300);
% [val4 ind4]=min(err_400);

%seleziono e plotto insieme a quelle con SVD
Gp=pinv(G'*G,D(100,100)^2)*G';
R=Gp*G;
Rp_100=diag(R);
Gp=pinv(G'*G,D(200,200)^2)*G';
R=Gp*G;
Rp_200=diag(R);
Gp=pinv(G'*G,D(300,300)^2)*G';
R=Gp*G;
Rp_300=diag(R);
Gp=pinv(G'*G,D(400,400)^2)*G';
R=Gp*G;
Rp_400=diag(R);
Rp=[Rp_200 Rp_300 Rp_400];
Rsvd=[Ris_200 Ris_300 Ris_400];
figure,
for i=1:size(Rp,2)
    subplot(3,2,i*2-1),imagesc(reshape(Rp(:,i),30,30)),title('Risoluzione pinv'),
    subplot(3,2,i*2),imagesc(reshape(Rsvd(:,i),30,30)),title('Risoluzione svd'),
end

%% Esercizio 6 (inversione con regolarizzatori)

%Dx
mu=[0.0001 0.001 0.01 0.1 1 10];
dn=d+ 0.01*std(d)*randn(size(d));

figure,
for i=1:length(mu)
Gp_dx=(G'*G+mu(i)*RegDx'*RegDx)\G'; %regolarizzatore che minimizza la derivata prima in direz orizzontale
R=Gp_dx*G;
Ris_dx(:,i)=diag(R);
m_inv_dx(:,i)=Gp_dx*dn;
imagesc(reshape(Ris_dx(:,i),30,30)),
refresh,
pause,
dric(:,i)=G*m_inv_dx(:,i); %dati ricalcolati
end

for i=1:size(dric,2)
n_res(i)=norm(dric(:,i)-dn);
n_mod(i)=norm(m_inv_dx(:,i));
end

[val,ind]=min((n_res+n_mod));
figure,imagesc(reshape(m_inv_dx(:,ind),30,30))
%% realizzazioni di rumore (PUNTO 9)


N=10000; 
k=0.1; %fattore per regolare la deviazione std del rumore
%j=1;
%for L=100:100:10000
drum=zeros(600,N); 
for i=1:N
    drum(:,i)=d+k*std(d)*randn(size(d)); %10000 realizzazioni con rumore gaussiano
end

Gp=pinv(G'*G)*G'; %invertitore elementare
minvs=zeros(400,N);
for i=1:N
    minvs(:,i)=Gp*drum(:,i);
end

% L=1;
% mn=zeros(400,1);
%     for i=1:L
%         mn=mn+minvs(:,i);
%     end
%     mn=mn/L;
% figure(5),imagesc(reshape(mn,20,20)),colormap('gray'),title('Modello invertito con 1 realizzazioni')
% 
% L=100;
% mn=zeros(400,1);
%     for i=1:L
%         mn=mn+minvs(:,i);
%     end
%     mn=mn/L;
% figure(6),imagesc(reshape(mn,20,20)),colormap('gray'),title('Modello invertito con 100 realizzazioni')
L=1;
mn=zeros(400,1);
    for i=1:L
        mn=mn+minvs(:,i);
    end
    mn=mn/L;
figure,imagesc(reshape(mn,20,20)),colormap('gray'),title('Modello invertito con 1 realizzazione')

L=100;
mn=zeros(400,1);
    for i=1:L
        mn=mn+minvs(:,i);
    end
    mn=mn/L;
figure,imagesc(reshape(mn,20,20)),colormap('gray'),title('Modello invertito con 100 realizzazioni')

L=1000;
mn=zeros(400,1);
    for i=1:L
        mn=mn+minvs(:,i);
    end
    mn=mn/L;
figure,imagesc(reshape(mn,20,20)),colormap('gray'),title('Modello invertito con 1000 realizzazioni')


L=10000;
mn=zeros(400,1);
    for i=1:L
        mn=mn+minvs(:,i);
    end
    mn=mn/L;
figure,imagesc(reshape(mn,20,20)),colormap('gray'),title('Modello invertito con 10000 realizzazioni')

%Ora variando tolleranza di pinv con 1 realizzazione sola

% toll=0.01:.01:.5;
% for j=1:length(toll)
% Gp=pinv(G'*G,toll(j))*G';
% Gpl=(G'*G+toll(j)*RegLap'*RegLap)*G';
% mini(:,j)=Gp*drum(:,1);
% minil(:,j)=Gpl*drum(:,1);
% res_1(:,j)=d-(G*mini(:,j)); %norma dei vari residui calcolati a partire dai diversi modelli invertiti con diverse tolleranze
% res_1l(:,j)=d-(G*minil(:,j));
% end
% 
% for i=1:size(res_1,2)
%     nres(i)=norm(res_1(:,i)-dric_100);
%     n_resl(i)=norm(res_1l(:,i)-dric_100);
% end
% 
% 
% [val,ind]=min(n_res);
% [vall,indl]=min(n_resl);
% 
% figure,imagesc(reshape(mini(:,ind),20,20)),colormap('gray')
% figure,imagesc(reshape(minil(:,indl),20,20)),colormap('gray')
    
%% Come il dumping influenza il condizionamento della matrice (G'*G), che �
%soggetta a inversione nella costruzione della pseudoinversa

%mu va da 1e-16 a 1 a passo *10
for i=1:16
    mu=(1e-14)*10^i;
cond(G'*G+mu*eye(size(G'*G)))
%mu
end

%Calcolo del residuo nello spazio dei dati
Dric=G*mn;
res=norm(d-Dric);
%disp('Norma 2 del residuo nello spazio dei dati: '),res %mostra la norma del residuo nello spazio dei dati

%% Usando una sola realizzazione dei dati rumorosi, cercare di ottenere il
%meglio possibile --> minimizzazione della norma del residuo e di quella
%del modello, mantenendo dei valori di scala sensati

dru=d+0.01*std(d)*randn(size(d)); %1 realizzazione di dati rumorosi

mu=0.1;


for i=1:60

    Gp= pinv(G,mu);
    minv=Gp*dru;
    Dric=G*minv;
    ris(:,i)=[mu; norm(minv-mv);norm(d-Dric)];
    %imagesc(reshape(minv,20,20)),colormap('gray'),
    %disp('Soglia per autovalori posta a : '),mu
    %pause,
mu=mu+0.005;
end

[mini,ind]=min(ris(3,:)); %minimizzo norma dell'errore e norma del residuo

Gp= pinv(G,ris(1,ind));
minv=Gp*dru;
figure,imagesc(reshape(minv,20,20)),colormap('gray')

%% Ora provo a fare la stessa cosa ma con SVD

%Regolarizzazione con Laplaciano, gradiente orizzontale e verticale pi�
%dumping

close;
mu=0.267;

k=1e-4;
n=std(d)*randn(size(d));
figure,
for i=1:4    
dru = d + k*n;

    GpLap= (G'*G+mu*(RegLap'*RegLap))^-1*G'; %inversa generalizzata con regolarizzatore gradiente orizzontale
    minv=GpLap*dru;
    Dric=G*minv;
    imagesc(reshape(minv,20,20)),colormap('gray'),caxis([0 1.4])
    k
    pause,
    k=k*10;
    
end


    
    %imagesc(reshape(minv,20,20)),colormap('gray'),
    %disp('Soglia per autovalori posta a : '),mu
    %pause,


% [mini,ind]=min(ris(3,:)); %minimizzo norma dell'errore e norma del residuo
% 
% Gp= pinv(G,ris(1,ind));
% minv=Gp*dru;
% figure,imagesc(reshape(minv,20,20)),colormap('gray')


