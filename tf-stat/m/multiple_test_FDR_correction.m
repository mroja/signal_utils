function [accepted, adjustetd_p, cutoff]= multiple_test_FDR_correction(p, c)

% correction for multiple tests using False Discovery Rate for correlated statistics 
% code based on Benjamini Y, Yekutieli D, (2001) The control of the False Discovery Rate Under Dependancy. Ann.Stat, 29, 1165-1188

N_tests=(c.map_y_size*(c.map_x_size-c.ref(end)-c.right_time_margin_px));
spm_corr=zeros(c.map_y_size,c.map_x_size);

adjustetd_p=ones(size(p));
accepted=zeros(size(p));

j=1:N_tests;
C_N=sum(ones(1,N_tests)./[1:N_tests]);

p_vec=reshape(p(:,c.ref(end)+1:end-c.right_time_margin_px),1,N_tests);
[A, ix]=sort(p_vec);
A_a=min(A*N_tests*C_N./j,1);
A_a(ix)=A_a;
A_ar=reshape(A_a,c.map_y_size,(c.map_x_size-c.ref(end)-c.right_time_margin_px));
adjustetd_p(:,c.ref(end)+1:end-c.right_time_margin_px)=A_ar;

B=j*c.FDR_q/(C_N*N_tests);
C=A-B;
ix=find(C<0);
if ~isempty(ix)
    d=max(ix);
    cutoff=A(d);
else
    cutoff=0;
end
if c.PLOT_FDR
    figure(2)
    switch c.MAP_TYPE
	case 'MP'
		name=sprintf('%s_%s_%s_%.2fx%.2f_%.1f-%.1fs_%.0f-%.0fHz_scale_%.2f-%.2f_OscNum_%.2f_%s', c.base_name,c.STATISTICS, c.MULTIPLE_TEST_CORRECTION,c.dt, c.df, c.tmin, c.tmax, c.f_min, c.f_max, c.filter_scale(1), c.filter_scale(2), c.OSC_NUM , c.ENERGY_SCALE);
	case 'SP'
name=sprintf('%s_%s_%s_%.2fx%.2f_%.1f-%.1fs_%.0f-%.0fHz_%s', c.base_name, c.STATISTICS, c.MULTIPLE_TEST_CORRECTION,c.dt, c.df, c.tmin, c.tmax, c.f_min, c.f_max, c.ENERGY_SCALE);
	case 'CWT'
	name=sprintf('%s_%s_%s_%.2fx%.2f_%.1f-%.1fs_%.0f-%.0fHz_w_%d_%s', c.base_name, c.STATISTICS, c.MULTIPLE_TEST_CORRECTION, c.dt, c.df, c.tmin, c.tmax, c.f_min, c.f_max,c.WAVE, c.ENERGY_SCALE);
end
    plot(j,A,'r',j,A+sqrt((1-cutoff).*cutoff/c.Npseudot),'b', j, A-sqrt((1-cutoff).*cutoff/c.Npseudot),'b',j,B)
    ylim([0 max(2*cutoff,1e-5)]);
    title(sprintf('Effective p: p< %f in %s %s %s',cutoff, c.MULTIPLE_TEST_CORRECTION, c.ENERGY_SCALE,name))
    prname=sprintf('fig/FDR_%s.eps',name);
orient landscape
print('-depsc2', prname);
end
accepted(find(p<cutoff))=1;
accepted(:,1:c.ref(end))=0;
accepted(:,end-c.right_time_margin_px+1:end)=0;



