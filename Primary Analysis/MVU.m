function minuslli = MVU(params, V,P,Us,N,C)
a=params(1);b=params(2);
Ug=V.*P+a.*V.^2.*P.*(1-P);
pcg=1./(1+exp(-b.*(Ug-Us)));

pcg(pcg<1e-16) = 1e-16;
pcg(pcg>1-1e-16) = 1-1e-16;
minuslli = -sum(C.*log(pcg)+(N-C).*log(1-pcg));

end

