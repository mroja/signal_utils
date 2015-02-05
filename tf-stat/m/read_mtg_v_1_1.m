function mtg=read_mtg_v_1_1(name)
% function for reading montage information contained in file 'name'
% return struct mtg
% v_1_1 implements free positioning of sensors in 2D  *.s2d
% Format description: text file
% 1st line contains two numbers specifing width and height of a single
%     subplot
% the following lines consist of a number specifing channel number in the
% file  next two numbers are the X and Y position of the sensor the last
% element is a string with a title for the subplot
%
% and supports old format of montage specification *.mtg
% Format description: text file
% lines consist of 4 elements:
% - a number specifing channel number in the file
% - next two numbers are the X and Y position of the sensor in the rectangular grid of subplots
% - the last element is a string with a title for the subplot

[pathstr,n,ext] = fileparts(name);
if ext=='.mtg'
    mtg = struct('chan', {[]}, 'x', {[]}, 'y',{[]}, 'label', {{}},'XSize',[],'YSize',[],'N',[],'Pos',[]);
    [mtg.chan, mtg.x, mtg.y, mtg.label]=textread(name,'%d %d %d %s', 'commentstyle','shell');
    mtg.XSize=max(mtg.x)-min(mtg.x)+1;
    mtg.YSize=max(mtg.y)-min(mtg.y)+1;
    mtg.N=length(mtg.x);
    mtg.Pos=mtg.x-min(mtg.x)+mtg.XSize.*(mtg.y-min(mtg.y))+1;
    mtg.v='mtg';

elseif ext=='.s2d'
    fi=fopen(name,'rt');
    L=textscan(fi,'%f %f',1,'commentstyle','shell'); %read width and height of a single subplot
    mtg.width=L{1};
    mtg.height=L{2};
    L=textscan(fi,'%d %f %f %s','headerLines',1, 'commentstyle','shell');

    mtg.chan=L{1};
    mtg.X=L{2};
    mtg.Y=L{3};
    mtg.label=L{4};
    fclose(fi);

    mtg.X=mtg.X-min(mtg.X);
    if max(mtg.X)~=0
       mtg.X=(0.9-mtg.width)*mtg.X/max(mtg.X);
    end
    mtg.X=mtg.X+0.05;
    
    mtg.Y=mtg.Y-min(mtg.Y);
    if max(mtg.Y)~=0
        mtg.Y=(0.9-mtg.height)*mtg.Y/max(mtg.Y);
    end
    mtg.Y=mtg.Y+0.05;
    mtg.N=length(mtg.X);
    mtg.v='s2d';
end