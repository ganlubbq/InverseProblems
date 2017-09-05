%Simulated Annealing usato per allineamento di tre segnali
clear all;
close all;
clc;

%Definizione dei segnali
Te=-18:18;
fc=6;
N=4000; %durata dell'intera traccia


y1=sincs(Te,fc,3);
y2=sincs(Te,fc,3);
y3=sincs(Te,fc,3);
y1r=ritin(y1,N);
y2r=ritin(y2,N);
y3r=ritin(y3,N);
dur=length(Te); %durata forma d'onda
maxrit=4*dur; %ritardo max consentito
maxant=-4*dur; %anticipo max consentito


%Definizione funzione costo
f=@(x) ((y1r+rit(y2r,x(1),dur,N)+rit(y3r,x(2),dur,N)))*((y1r+rit(y2r,x(1),dur,N)+rit(y3r,x(2),dur,N)))';

%Calcolo funzione su griglia intera (solo per visualizzazione, se lo facessi non servirebbe SA)
d2=-200:1:200;
d3=-200:1:200;
fcost=zeros(length(d2),length(d3));
for i=1:length(d2)
    for j=1:length(d3)
        fcost(i,j)=f([d2(i) d3(j)]);
    end
end
[D2 D3]=meshgrid(d2,d3);
mesh(D2,D3,fcost),colormap('gray'),title('Funzione costo')

%START
x(:,1)=[100;300]; %guess iniziale

Ns=6; %iterazioni del ciclo di ricerca
NT=50;%max(100,5*size(x,1)); %numero iterazioni del ciclo di aggiornamento del passo

%Ciclo di raffreddamento

h=1;
r=0.6;
fmax=0;
T(1,1)=100/r;
for k=1:3
if(h>2)
while(abs(f(xopt(:,h-1)')-f(xopt(:,h-2)'))>1e-3 || (f(xopt(:,h-1)')<=(fmax-1e-3) || f(xopt(:,h-2)')<=(fmax-1e-3)) || h<10)  %per convergenza controllo che la funzione obiettivo sia intrappolata
     %il nuovo passo � pari all'ultimo
%Ciclo Aggiornamento passo
v=zeros(2,NT);
x(:,1)=xopt(:,h-1);

for c_pas=1:NT
        if(c_pas==1)
            v(:,c_pas)=[maxrit;maxrit];
        else
            q=q/Ns;
            ri=cora(q);
            v(1,c_pas)=ri(1)*v(1,(c_pas-1));
            v(2,c_pas)=ri(2)*v(2,(c_pas-1));
            if(v(1,c_pas)>maxrit)
                v(1,c_pas)=maxrit;
            end
            
            if(v(2,c_pas)>maxrit)
                v(2,c_pas)=maxrit;
            end
            if(v(1,c_pas)<maxant)
                v(1,c_pas)=maxant;
            end
            
            if(v(2,c_pas)<maxant)
                v(2,c_pas)=maxant;
            end
        end

%Ciclo di Ricerca (Ns=20 volte,perturbo una ad una tutte le componenti di x, per riempire il vettore q delle accetazioni/rifiuti)

q=zeros(2,1); %vettore delle accettazioni
xc1=zeros(size(x)); %vettore punti candidati
xc2=zeros(size(x));
for i=1:Ns-1
%perturbo componente 1
xc1=[x(1,i)+round((2*rand-1)*v(1,c_pas)); x(2,i)]; %punto candidato
if (f(xc1')>=f(x(:,i)'))
    x(1,i+1)=xc1(1); %punto candidato � il nuovo punto corrente, passo a perturbare la componente successiva
    q(1)=q(1)+1;
else
    df=f(xc1')-f(x(:,i)');
    ris=metrop(df,T(1,h));
    if(ris==1)
        x(1,i+1)=xc1(1); %accetto comunque il punto anche se mi allontano apparentemente dal minimo
        q(1)=q(1)+1; 
    else
        x(:,i+1)=x(:,i);
    end
end

%perturbo la seconda
xc2=[x(1,i); x(2,i)+round((2*rand-1)*v(2,c_pas))]; %punto candidato
if (f(xc2')>=f(x(:,i)'))
    x(2,i+1)=xc2(2); %punto candidato � il nuovo punto corrente, passo a perturbare la componente successiva
    q(2)=q(2)+1;
else
    df=f(xc2')-f(x(:,i)');
    ris=metrop(df,T(1,h));
    if(ris==1)
        x(2,i+1)=xc2(2); %accetto comunque il punto anche se mi allontano apparentemente dal minimo
        q(2)=q(2)+1;
    else
        x(:,i+1)=x(:,i);
    end
end

%hold on,plot3(x(1,i),x(2,i),f(x(:,i)'),'or')

%fine Ciclo di ricerca
end
%trova e salva punto ottimo
ma=1;
for i=1:Ns
    if(f(x(:,i)')>ma)
        mac(:,c_pas)=x(:,i);
        ma=f(x(:,i)');
    end
end
%fine ciclo di Aggiornamento passo
end

xopt(:,h)=mac(:,1);%la soluzione determinata alla fine del ciclo di aggiornamento del passo � la ottima per la temperatura T
for i=2:NT
    if(f(mac(:,i)')>f(xopt(:,h)'))
        xopt(:,h)=mac(:,i);
    end
end
hold on, plot3(xopt(1,h),xopt(2,h),f(xopt(:,h)'),'or')
if(f(xopt(:,h)')>fmax)
    fmax=f(xopt(:,h)');
end
%fine ciclo di raffreddamento
h=h+1;
T(1,h)=r*T(1,h-1);
pause;
end


%se no fai i primi 2 cicli
else
    %
    %
    %Ciclo Aggiornamento passo
    
    
    v=zeros(2,NT);
    if(h>1)
    x(:,1)=xopt(:,h-1);
    end
for c_pas=1:NT
        if(c_pas==1)
            v(:,c_pas)=[maxrit;maxrit];
        else
            
            q=q/Ns;
            ri=cora(q);
            v(1,c_pas)=ri(1)*v(1,(c_pas-1));
            v(2,c_pas)=ri(2)*v(2,(c_pas-1));
            
            if(v(1,c_pas)>maxrit)
                v(1,c_pas)=maxrit;
            end
            
            if(v(2,c_pas)>maxrit)
                v(2,c_pas)=maxrit;
            end
            if(v(1,c_pas)<maxant)
                v(1,c_pas)=maxant;
            end
            
            if(v(2,c_pas)<maxant)
                v(2,c_pas)=maxant;
            end
        end

%Ciclo di Ricerca (Ns=20 volte,perturbo una ad una tutte le componenti di x, per riempire il vettore q delle accetazioni/rifiuti)

q=zeros(2,1); %vettore delle accettazioni
xc1=zeros(size(x)); %vettore punti candidati
xc2=zeros(size(x));
for i=1:Ns-1
%perturbo componente 1
xc1=[x(1,i)+round((2*rand-1)*v(1,c_pas)); x(2,i)]; %punto candidato
if (f(xc1')>=f(x(:,i)'))
    x(1,i+1)=xc1(1); %punto candidato � il nuovo punto corrente, passo a perturbare la componente successiva
    q(1)=q(1)+1;
else
    df=f(xc1')-f(x(:,i)');
    ris=metrop(df,T(1,h));
    if(ris==1)
        x(1,i+1)=xc1(1); %accetto comunque il punto anche se mi allontano apparentemente dal minimo
        q(1)=q(1)+1; 
    else
        x(:,i+1)=x(:,i);
    end
end

%perturbo la seconda
xc2=[x(1,i); x(2,i)+round((2*rand-1)*v(2,c_pas))]; %punto candidato
if (f(xc2')>=f(x(:,i)'))
    x(2,i+1)=xc2(2); %punto candidato � il nuovo punto corrente, passo a perturbare la componente successiva
    q(2)=q(2)+1;
else
    df=f(xc2')-f(x(:,i)');
    ris=metrop(df,T(1,h));
    if(ris==1)
        x(2,i+1)=xc2(2); %accetto comunque il punto anche se mi allontano apparentemente dal minimo
        q(2)=q(2)+1;
    else
        x(:,i+1)=x(:,i);
    end
end

%hold on,plot3(x(1,i),x(2,i),f(x(:,i)'),'or')

%fine Ciclo di ricerca
end
%trova e salva punto ottimo
ma=1;
for i=1:Ns
    if(f(x(:,i)')>ma)
        mac(:,c_pas)=x(:,i);
        ma=f(x(:,i)');
    end
end
%fine ciclo di Aggiornamento passo
end

xopt(:,h)=mac(:,1);%la soluzione determinata alla fine del ciclo di aggiornamento del passo � la ottima per la temperatura T
for i=2:NT
    if(f(mac(:,i)')>f(xopt(:,h)'))
        xopt(:,h)=mac(:,i);
    end
end
hold on, plot3(xopt(1,h),xopt(2,h),f(xopt(:,h)'),'or')
if(f(xopt(:,h)')>fmax)
    fmax=f(xopt(:,h)');
end
%fine ciclo di raffreddamento
h=h+1;
T(1,h)=r*T(1,h-1);
end
pause;
end

%plotting linee

