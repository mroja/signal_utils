test=0;
for i=1:100
x=randn(200,1);
 y=x.^2;
 [d ,l ]=b_c(y);
 %normplot(d)
 lh(i)=l;
 test=test+lillietest(d,0.01);
end
hist(lh,20)
test