function p=welch_t(x,y)
nx=length(x);
ny=length(y);

mx=mean(x);
my=mean(y);
vx=var(x);
vy=var(y);

ax=vx/nx;
ay=vy/ny;

t=abs(mx-my)/sqrt(ax+ay);
df=floor((ax+ay)^2/(ax^2/(nx-1) + ay^2/(ny-1) ));
p=2*(1-tcdf(t,df));