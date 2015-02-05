function [accepted, adjustetd_p, p_eff]= multiple_test_BH_correction(p, c)

N_tests=(c.map_y_size*(c.map_x_size-c.ref(end)-c.right_time_margin_px));
   p_OK=zeros(1,N_tests);
   p_vec=zeros(1,N_tests);
   p_OK=zeros(1,N_tests);
   p_OK_unsort=zeros(1,N_tests);
   a_tmp=zeros(size(p(:,c.ref(end)+1:end-c.right_time_margin_px)));
   accepted=zeros(size(p));

   p_vec=reshape(p(:,c.ref(end)+1:end-c.right_time_margin_px),1,N_tests);

   [p_sort, s_ix]=sort(p_vec);
   A_p=min(p_sort.*[N_tests:-1:1],1);
   thresh_vec=c.p_level./[N_tests:-1:1];

   p_OK=p_sort<thresh_vec;
   
   A_p_uns(s_ix)=A_p;
   p_OK_unsort(s_ix)=p_OK;

   p_eff_ix=max(find(p_OK==1));
   p_eff=p_sort(p_eff_ix);

   %figure
   %plot([1:N_tests],p_sort,[1:N_tests],thresh_vec)
   a_tmp=reshape(p_OK_unsort,c.map_y_size,c.map_x_size-c.ref(end)-c.right_time_margin_px);
   A_p_tmp=reshape(A_p_uns,c.map_y_size,c.map_x_size-c.ref(end)-c.right_time_margin_px);
   accepted=[zeros(size(p(:,1:c.ref(end)))) a_tmp zeros(size( p(:,end-c.right_time_margin_px+1:end) ) )];
   adjustetd_p=[ones(size(p(:,1:c.ref(end)))) A_p_tmp ones(size( p(:,end-c.right_time_margin_px+1:end) ) )];

