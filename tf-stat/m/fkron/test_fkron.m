%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Just a simple example of the usage of fkron.
%	For a more complete exercise, see bigtime_fkron.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A=[1 0 3; 4 0 6]		% a couple of matrices
B=[1 0; 9 5]			% and their sparse equivalents.
a=sparse(A);
b=sparse(B);
C=kron(a,b);			% the m-file call
c=fkron(a,b);			% the mex-file call
if sum(sum(~(C==c)))
	disp('error in sparse routine')
else
	disp('Sparse routine is OK.')
end
C=kron(A,B);
c=fkron(A,B)
if sum(sum(~(C==c)))
	disp('error in full routine')
else
	disp('Full routine is OK.')
end
