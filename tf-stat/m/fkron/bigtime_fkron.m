function bigtime_fkron(count,maxsize)
%
%	To exercise the fkron routine on various inputs.
%
%	bigtime_fkron(count,maxsize)
%	count 			is the number of iterations to run.
%	maxsize			is the maximum size of matrices to use.
%
%	bigtime_fkron(10,13)	for example
%
t=zeros(2,maxsize);	% 1 is kron, 2 is fkron
disp('Testing kronecker product routine');
for s=1:maxsize
	disp(['Size of matrices under test is ', num2str(s)]);
	for i=1:count,
		for density=0:.1:1
			a=sprandn(s,s,density);	% sparse
			b=sprandn(s,s,density);	% sparse
			A=randn(s,s);		% full
			B=randn(s,s);		% full
			% sparse-sparse
			t0=clock;
			C=kron(a,b);
			t(1,s)=t(1,s)+etime(clock,t0);
			t0=clock;
			c=fkron(a,b);
			t(2,s)=t(2,s)+etime(clock,t0);
			% check result
			if sum(sum(~(C==c)))
				disp('Error in fkron');
			end
			% sparse-full
			t0=clock;
			C=kron(a,B);
			t(1,s)=t(1,s)+etime(clock,t0);
			t0=clock;
			c=fkron(a,B);
			t(2,s)=t(2,s)+etime(clock,t0);
			% check result
			if sum(sum(~(C==c)))
				disp('Error in fkron');
			end
			% full-sparse
			t0=clock;
			C=kron(A,b);
			t(1,s)=t(1,s)+etime(clock,t0);
			t0=clock;
			c=fkron(A,b);
			t(2,s)=t(2,s)+etime(clock,t0);
			% check result
			if sum(sum(~(C==c)))
				disp('Error in fkron');
			end
			% full-full
			t0=clock;
			C=kron(A,B);
			t(1,s)=t(1,s)+etime(clock,t0);
			t0=clock;
			c=fkron(A,B);
			t(2,s)=t(2,s)+etime(clock,t0);
			% check result
			if sum(sum(~(C==c)))
				disp('Error in fkron');
			end
		end
	end
end
ss=sprintf('%3.1f ', t(1,:));
disp(['Using kron   ', ss]);
ss=sprintf('%3.1f ', t(2,:));
disp(['Using fkron  ', ss]);
