function p=p_Z(mapa, c, name);

p=zeros(c.map_y_size, c.map_x_size);
sum_ref=0;
sum_p=0;
sum_ref_ad=0;
sum_p_ad=0;

ref_len=length(c.ref);
N_ref=c.N*ref_len;
rr=zeros(N_ref,1);

f_txt=fopen(sprintf('txt/%s_not_normal.txt',name),'wt');
fprintf(f_txt,'%s\n',name);
fprintf(f_txt,' violated norm. assumpt. of :\n');

for f=1:c.map_y_size
       for i=1:c.N
                rr(1+(i-1)*ref_len:i*ref_len) = mapa(i,f,c.ref);
       end
      s2_ref=var(rr);
      mean_ref=mean(rr);
      [h_rr, p_rr,ls,cv]=lillietest(rr);
      sum_ref=sum_ref+h_rr;
      [h_rr_ad, p_rr_ad]=ad_test(rr);
      sum_ref_ad=sum_ref_ad+h_rr_ad;
	if (h_rr==1) | (h_rr_ad==1)
		fprintf(f_txt,' ref. reg. at freq %.2f Hz    h_l: %d  p_l: %.3f ; h_a %d p_a  %.3f\n',f*c.df+c.f_min, h_rr, p_rr,h_rr_ad, p_rr_ad );
	 end
      figure(3)
			subplot(c.map_y_size/4, 4, f)
				% histfit(rr);
				normplot(rr);
				title(sprintf('f: %.1f Hz hl: %d    ha: %d',f*c.df+c.f_min  , h_rr ,  h_rr_ad),'FontSize',7);
set(gca,'XTickLabel',[],'FontSize',7);
set(gca,'YTickLabel',[],'FontSize',7);
xlabel('');
ylabel('');

       for i=c.ref(end)+1:c.map_x_size
           	 point=mapa(:,f,i); % point for which difference is assesed
	    	% for this test we have to check normality of  rr and point

		[h_p, p_p,ls,cv]=lillietest(point);
		sum_p=sum_p+h_p;
		[h_p_ad, p_p_ad]=ad_test(point);
      		sum_p_ad=sum_p_ad+h_p_ad;
		if (h_p==1)|(p_p_ad==1)
		 	fprintf(f_txt,'\t point at freq %.2f Hz  time: %.2fs , h_l: %d  p_l: %.3f ; h_a %d p_a %.3f\n',f*c.df+c.f_min, (c.ref(end)+1+i)*c.dt,h_p,p_p,h_p_ad,p_p_ad);
		 end
	    [h, p(f,i), ci]=ztest(point,mean_ref,sqrt(s2_ref));
       end
            disp(sprintf('%d/%d', f, c.map_y_size));
            %disp(sprintf('t2=%5.3f\n', toc));
end
fclose(f_txt);

xlabel(sprintf('%s %s', c.MAP_TYPE, c.ENERGY_SCALE));
axes('Position',[0 0 1 1],'Visible','off')
hx=gca;
set(gcf,'CurrentAxes',hx)
str=sprintf('normality violated at %d / %d ref. regions and %d / %d points in lillietest and at  %d / %d ref. regions and %d / %d points in ad test', sum_ref,c.map_y_size, sum_p, length(c.ref(end)+1:c.map_x_size)*c.map_y_size ,sum_ref_ad,c.map_y_size, sum_p_ad, length(c.ref(end)+1:c.map_x_size)*c.map_y_size )
text(0.1,0.06,str,'FontSize',7,'interpreter','none');
str=sprintf('DATA: %s',name)
text(0.1,0.04,str,'FontSize',7,'interpreter','none');


axh=gca;
orient tall

prname=sprintf('fig/%s_norm_test.eps',name);
print('-depsc', prname);

disp(sprintf('normality violated at %d / %d ref. regions and %d / %d points', sum_ref,c.map_y_size, sum_p, length(c.ref(end)+1:c.map_x_size)*c.map_y_size ))
