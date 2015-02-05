function mtg=read_mtg(name)
% function for reading montage information contained in file 'name'
% return struct mtg

mtg = struct('chan', {[]}, 'x', {[]}, 'y',{[]}, 'label', {{}},'XSize',[],'YSize',[],'N',[],'Pos',[]);
[mtg.chan, mtg.x, mtg.y, mtg.label]=textread(name,'%d %d %d %s', 'commentstyle','shell');
mtg.XSize=max(mtg.x)-min(mtg.x)+1;
mtg.YSize=max(mtg.y)-min(mtg.y)+1;
mtg.N=length(mtg.x);
mtg.Pos=mtg.x-min(mtg.x)+mtg.XSize.*(mtg.y-min(mtg.y))+1;