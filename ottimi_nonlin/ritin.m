function yr=ritin(y,ltot)

%s � la forma d'onda 
%d � il ritardo da introdurre
%ltot= durata totale

%taglio solo la forma d'onda

yr=[zeros(1,ltot/2) y zeros(1,ltot/2-length(y))];

    
