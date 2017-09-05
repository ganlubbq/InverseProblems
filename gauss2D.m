%gaussiane bivariate, indipendenti e correlate

%indipendenti
figure(1),
for i=1:800
w=sqrt(5)*randn(2,1);
hold on, plot(w(1,1),w(2,1),'k*'),axis([-10 10 -10 10]),hold on,
end

%correlate con coeff di correlazione k e varianza desiderata per entrambe
%le componenti varx
k=0.8;
varx=5;
varp=varx*(1-k^2);
figure(2),
for i=1:800
w(1,1)=(sqrt(varx)*randn);
w(2,1)=k*w(1,1)+sqrt(varp)*randn;
hold on,plot(w(1,1),w(2,1),'r*'),axis([-8 8 -8 8]),hold on,
end