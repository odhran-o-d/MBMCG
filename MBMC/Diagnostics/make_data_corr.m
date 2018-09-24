function  make_data_corr(corr, n)
x = normrnd(0,1, 1, n);
%y = normrnd(1902, 700, 1, n);
y = normrnd(0,1, 1, n);
%x = normrnd(266.6*1.6, 43.63*1.6, 1, n);
a = corr/(1-corr^2)^0.5;
z=a*x+y;

m2 = 1902;
m1 = mean(z);
s2 = 700;
s1 = std(z);

z= m2 + (z-m1) * (s2/s1);

m2 = 266.6*1.6;
m1 = mean(x);
s2 = 43.63*1.6;
s1 = std(x);

x= m2 + (x-m1) * (s2/s1);

coefficient = corrcoef(x, z);

if abs(coefficient(2) - corr) < 0.001 && ~any(z(:) < 0)
    disp(corrcoef(x, z))
figure(); scatter(x,z)
else
    make_data_corr(corr, n)
end
%{
while abs(coefficient(2) - corr) > 0.001 && any(z(:) < 0) && result==false
    
    result = make_data_corr(corr, n);
    
    if result == true
        break
    end
    
end



if abs(coefficient(2) - corr) < 0.001 && ~any(z(:) < 0)
    disp(corrcoef(x, z))
figure(); scatter(x,z)
result = true;
else
    result = false;
end

%}