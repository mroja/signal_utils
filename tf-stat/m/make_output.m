function make_output(c)
if c.OUTPUT_MEAN_MAP==1,
	c.OUTPUT_TYPE='MEAN_MAP';
	topo_tf_cwt(c);
end
if c.OUTPUT_ERD_ERS==1, % 'ERD_ERS' Display raw map of ERD/ERS
	c.OUTPUT_TYPE='ERD_ERS' ;
	topo_tf_cwt(c);
end
if c.OUTPUT_ACCEPTED==1
	c.OUTPUT_TYPE='ACCEPTED';
	topo_tf_cwt(c);
end
