function [out_map, xx, yy]=calculate_maps_MP(c, name, res_max);

if nargin < 3
   res_max = 0;
end;

if res_max
%maximum resolution - natural
   Xsize=c.Tsize;
   Ysize=c.Fsize;
else
   Xsize=c.map_x_size;
   Ysize=c.map_y_size;
   Dt=round(c.sampling*c.dt);
   Df=round(c.df*c.dimBase/c.sampling);
end

% indices of parameters in the book array (constants)
SCALE=1; FREQ=2; POS=3; MODULUS=4; AMPLI=5; PHASE1 =6; % absolute - counted from the beg. of signal
PHASE2 =7; % relative to the atom's center


if res_max
   map_filename=sprintf('calc_map/%s_MaxRes.mat', name);
else
   map_filename=sprintf('calc_map/%s.mat', name);
end

disp(['  map: ' map_filename]);

xx=[];
yy=[];
if exist(map_filename)~=2 %jesli plik nie istnieje
   fo=fopen(map_filename,'wb');
   if fo==-1
      disp('error opening map file for writing');
      return;
   end


   for i=1:c.N
      % czytamy ksiazke
      [book, dimBase, sampling1, header]=readbook(c.bookname,i-1);


         if dimBase~=c.sampling*c.time_length
            error('wrong dimBase');
         end
         if abs(sampling1-c.sampling)>1
	 disp([sampling1 c.sampling])
            error('wrong sampling ');
         end


      % SELEKCJA ATOMOW
%      if (c.filter_scale(1) ~= 0 )|(c.filter_scale(2) ~=inf)
         chosen_idx=find((book(:,SCALE) >= c.filter_scale(1))...
                       & (book(:,SCALE) <= c.filter_scale(2))...
                       & (book(:,SCALE).*book(:,FREQ)>=c.OSC_NUM));
         chosen=book(chosen_idx,:);
         %  else
         %chosen=book;
         %      end

      %drawing single map
      fprintf(1,'map1:%3d/%-3d',i,c.N);

      if res_max
        [mapaXY, xx, yy]=hmp2tf(chosen, header, c.calculating_max_res_mode, 1,1,c.minF,c.maxF,c.minT,c.maxT);
        mapaXY = mapaXY';
      else
        [mapaXY, xx, yy]=hmp2tf(chosen, header, c.calculating_maps_mode, c.dt, c.df,c.f_min,c.f_max,c.tmin,c.tmax);
        mapaXY = mapaXY';
      end;
      fwrite(fo,mapaXY,'double');
      pause(0);
   end
   fclose(fo);
   fprintf(1,'\n');
end

if res_max
%counting average map transformed by ENERGY_SCALE
  fid=fopen(map_filename,'rb');
  if fid==-1
     disp('error opening map file for reading');
     return;
  end
  out_map=zeros(Ysize,Xsize);
  map_linear=zeros(Ysize,Xsize);
  for i=1:c.N
     map_linear = fread(fid,[Xsize, Ysize],'double')';
     out_map = out_map+map_transform(map_linear, c.ENERGY_SCALE);
  end
  out_map = out_map/c.N;
  fclose(fid);
else
%reading set of linear maps
  fid=fopen(map_filename,'rb');
  if fid==-1
     disp('error opening map file for reading');
     return;
  end
  out_map=zeros(c.N,Ysize,Xsize);
  for i=1:c.N
     out_map(i,:,:) = map_transform(fread(fid,[Xsize, Ysize],'double')', c.ENERGY_SCALE);
  end
  fclose(fid);
end











%  [batoms ,size, sampling,  header]=readbook(string filename, int offset);
%  filename        - file w/results of MP decomposition ver. II, III and IV
%  offset          - offset (counting from 0)
%
%  batoms          - matrix of atoms parameters:
%
%                    SCALE, FREQ, POS, MODULUS, AMPLI(p2p), PHASE1, PHASE2
%
%  size              - signal size
%  sampling          - sampling frequency
%  header            - 11 values from the file header:
%                     [sampling frequency, signal size, points per microvolt,
%                     number of channels in file, energy percent,
%                     max number of iterations, dictionary size, channel,
%                     file offset, signal energy, book energy]
%

function  [batoms ,size, sampling, header]=readbook(filename, offset)

%offset=offset-1;
if offset<0
   error('offset <= 0');
end;
SCALE  =1;
FREQ   =2;
POS    =3;
MODULUS=4;
AMPLI  =5;

H_SAMPLING_FREQ=1;
H_SIGNAL_SIZE=2;
H_POINTS_PER_MICROVOLT=3;
H_VERSION=4;
pwd

if ~exist(filename, 'file')
   error([filename ' does not exist']);
end

[batoms , header]=readrawb_m(filename, offset);

batoms(:,SCALE)   = batoms(:,SCALE)./header(H_SAMPLING_FREQ);

batoms(:,FREQ)    = batoms(:,FREQ).*header(H_SAMPLING_FREQ)/header(H_SIGNAL_SIZE);

batoms(:,POS)     = batoms(:,POS)./header(H_SAMPLING_FREQ);

batoms(:,MODULUS) = batoms(:,MODULUS)./header(H_POINTS_PER_MICROVOLT);

batoms(:,AMPLI)   = 2.*batoms(:,AMPLI)./header(H_POINTS_PER_MICROVOLT);

size=header(H_SIGNAL_SIZE);
sampling=header(H_SAMPLING_FREQ);

function answer=bookversion(filename)
  id=fopen(filename,'rb');
  if id==-1
    answer=-1;
    return;
  end
  answer=checkbook(id);
  fclose(id);

function answer=checkbook(id)
  position=ftell(id);
  fseek(id,0,-1);
  [magic, num]=fread(id,4,'char');
  fseek(id,position,-1);
  if num~=4
    answer=-1;
    return;
  end

  name=char(magic');
  answer=2;

  if strcmp(name, 'MPv3')==1
    answer=3;
  elseif strcmp(name, 'MPv4')==1
    answer=4;
  end

  function Result=hmphase(freq, position, phase)
  pi2=2*pi;
  if phase<0.0
     RawPhase=pi2+phase;
  else
     RawPhase=phase;
  end

  RawPhase=RawPhase+freq*position;
  Result=RawPhase-pi2*floor(RawPhase/pi2);

  function Result=mphase(freq, position, phase)
  phase=hmphase(freq, position, phase);
  pi2=2.0*pi;
  RawPhase=phase-freq*position;
  NewPhase=RawPhase-pi2*floor(RawPhase/pi2);

  if (NewPhase>=pi)
     NewPhase=NewPhase-pi2;
  end

  NewPhase=NewPhase-freq*position;
  Result=NewPhase-pi2*floor(NewPhase/pi2);

function [sampling_freq, points_per_microvolt, energy_percent, dictionary_size,  number_of_chanels_in_file]=readhead(id)

TEXT_INFO  =1;
DATE_INFO  =2;
SIGNAL_INFO=3;
DECOMP_INFO=4;

points_per_microvolt=1.0;
sampling_freq=1.0;
energy_percent=-1.0;
dictionary_size=-1;
number_of_chanels_in_file=-1;

fseek(id,0,-1);
magic=fread(id,4,'char');
if strcmp(char(magic'),'MPv3')~=1 & strcmp(char(magic'),'MPv4')~=1
   error('bad file format');
end

max_header_size=fread(id,1,'ushort');
%disp(sprintf('header size: %d',max_header_size));

header_size=6;
while (header_size<max_header_size)
   code=fread(id,1,'uchar');
   block=fread(id,1,'uchar');

   if (code==TEXT_INFO) | (code==DATE_INFO)
      string=fread(id, block, 'char');

      string(size(string,1))=32;
%       if code==TEXT_INFO
%          disp(sprintf('info: %s',string));
%       else
%          disp(sprintf('Data: %s',string));
%       end
   elseif code==SIGNAL_INFO
      sampling_freq=fread(id,1,'float32');
      points_per_microvolt=fread(id,1,'float32');
      number_of_chanels_in_file=fread(id,1,'int32');

%      disp(sprintf('Sampling: %g Calib: %g MaxChannels: %g', ...
%         sampling_freq, points_per_microvolt, number_of_chanels_in_file));
   elseif code==DECOMP_INFO
      energy_percent=fread(id,1,'float32');
      max_number_of_iterations=fread(id,1,'int32');
      dictionary_size=fread(id,1,'int32');
      dictionary_type=fread(id,1,'char');
      dummy=fread(id,3,'uchar');

%      disp(sprintf('DicType: %c MaxIter: %d DicSize: %d Energy %g', ...
%         dictionary_type, max_number_of_iterations, dictionary_size, ...
%         energy_percent));
   else
      fread(id,block,'uchar');
%      disp('unknown block [size: %d code: %d] !',block, code);
   end
   header_size=header_size+(block+2);
end

fseek(id, max_header_size,-1);


function [atoms, signal_size,FREQUENCY, points_per_micro_V]=readonebookv2(id)
file_offset=fread(id,1,'short');
book_size=  fread(id,1,'short');
signal_size=fread(id,1,'int32');
points_per_micro_V=fread(id,1,'float32');
FREQUENCY=fread(id,1,'float32');
signal_energy=fread(id,1,'float32');
book_energy=fread(id,1,'float32');

%disp(sprintf('Sampling: %g Calib: %g Signal Size: %d\n',...
%   FREQUENCY, points_per_micro_V, signal_size));

atoms=zeros(book_size,7);
for i=1:book_size
   fread(id,1,'short');                  % offset
   atoms(i,1)=2^fread(id,1,'uchar');     % octave
   fread(id,1,'uchar');                  % type
   freq=fread(id,1,'short');
   atoms(i,2)=freq;                      % czestosc
   atoms(i,3)=fread(id,1,'short');       % pozycja
   atoms(i,4)=fread(id,1,'float32');     % modulus
   atoms(i,5)=fread(id,1,'float32');     % amplituda
   phase=fread(id,1,'float32');          % faza

   if phase<0.0
      atoms(i,6)=phase+2.0*pi;
   else
      atoms(i,6)=phase;
   end

   atoms(i,7)=hmphase((2.0*pi*freq)/signal_size,atoms(i,3),phase);
end

function [atoms, signal_size]=readonebookv3(id)
channel=fread(id,1,'int32');
file_offset=fread(id,1,'int32');
book_size=fread(id,1,'int32');
signal_size=fread(id,1,'int32');

%disp(sprintf('Signal Size: %d',signal_size));

signal_energy=fread(id,1,'float32');
book_energy=fread(id,1,'float32');

atoms=zeros(book_size,7);
for i=1:book_size
   atoms(i,1)=fread(id,1,'int32');         % scale;
   freq=fread(id,1,'int32');
   atoms(i,2)=freq;                        % frequency;
   atoms(i,3)=fread(id,1,'int32');         % position;
   atoms(i,4)=fread(id,1,'float32');       % modulus;
   atoms(i,5)=fread(id,1,'float32');       % amplitude;
   phase=fread(id,1,'float32');            % phase;

   atoms(i,6)=mphase((2.0*pi*freq)/signal_size,atoms(i,3),phase);
   atoms(i,7)=phase;
end

function [atoms, signal_size]=readonebookv4(id)
channel=fread(id,1,'int32');
file_offset=fread(id,1,'int32');
book_size=fread(id,1,'int32');
signal_size=fread(id,1,'int32');

%disp(sprintf('Signal Size: %d',signal_size));

signal_energy=fread(id,1,'float32');
book_energy=fread(id,1,'float32');

atoms=zeros(book_size,7);
for i=1:book_size
   atoms(i,1)=fread(id,1,'float32');         % scale;
   freq=fread(id,1,'float32');
   atoms(i,2)=freq;                        % frequency;
   atoms(i,3)=fread(id,1,'float32');         % position;
   atoms(i,4)=fread(id,1,'float32');       % modulus;
   atoms(i,5)=fread(id,1,'float32');       % amplitude;
   phase=fread(id,1,'float32');            % phase;

   atoms(i,6)=mphase((2.0*pi*freq)/signal_size,atoms(i,3),phase);
   atoms(i,7)=phase;
end

function [atoms, header]=readrawb_m(filename,n)
id=fopen(filename,'rb','ieee-be');
if(id==-1)
   error('cant open file');
end

energy_percent=-1;
dictionary_size=-1;
number_of_chanels_in_file=-1;

mode=checkbook(id);
if (mode==-1)
   error('bad file ID');
elseif mode==2
%   disp('Book version II');
   if seekbookv2(id, n)==-1
      error('cant seek position');
   end
   [atoms, signal_size, sampling, calib]=readonebookv2(id);
elseif mode==3
%   disp('Book version III');
   [ sampling, calib, energy_percent, dictionary_size, number_of_chanels_in_file ]=readhead(id);
   if seekbookv3(id, n)==-1
      error('bad format or seek position (III)');
   end
   [atoms, signal_size]=readonebookv3(id);
elseif mode==4
%    disp('Book version IV');
    [ sampling, calib, energy_percent, dictionary_size,  number_of_chanels_in_file ]=readhead(id);
    if seekbookv4(id, n)==-1
      error('bad format or seek position (IV)');
   end
   [atoms, signal_size]=readonebookv4(id);
else
   error('this book format is not implemented');
end;

H_SAMPLING_FREQ=1;
H_SIGNAL_SIZE=2;
H_POINTS_PER_MICROVOLT=3;
H_VERSION=4;
H_OFFSET=5;
H_DICSIZE=6;
H_ENERG=7;
H_CHN=8;

header(H_SAMPLING_FREQ)=sampling;
header(H_SIGNAL_SIZE)=signal_size;
header(H_POINTS_PER_MICROVOLT)=calib;
header(H_VERSION)=mode;
header(H_OFFSET)=ftell(id);
header(H_DICSIZE)=dictionary_size;
header(H_ENERG)=energy_percent;
header(H_CHN)=number_of_chanels_in_file;
fclose(id);

function answer=seekbookv2(id,n)
fseek(id,0,-1);
position=0;

for i=1:n
   Count=0;
   [ file_offset, num]=fread(id,1,'short');
   Count=Count+num;
   [ book_size, num]=fread(id,1,'short');
   Count=Count+num;
   [ signal_size, num ]=fread(id,1,'int32');
   Count=Count+num;
   [ points_per_micro_V, num]=fread(id,1,'float32');
   Count=Count+num;
   [ FREQUENCY, num]=fread(id,1,'float32');
   Count=Count+num;
   [ signal_energy, num]=fread(id,1,'float32');
   Count=Count+num;
   [ book_energy, num]=fread(id,1,'float32');
   Count=Count+num;

   if Count ~= 7
      answer=-1;
      return;
   end

   position=position+24+book_size*20;
   if fseek(id,position,-1) ~=0
      answer=-1;
      return;
   end
end

answer=0;

function answer=seekbookv3(id, n)
fseek(id,0,-1);
magic=fread(id,4,'char');
if strcmp(char(magic'),'MPv3')~=1
   answer=-1;
   return;
end

fseek(id,4,-1);
head_size=fread(id,1,'short');
fseek(id,head_size,-1);

position=head_size;
for i=1:n
   Count=0;
   [channel, num]   =fread(id,1,'int32');
   Count=Count+num;
   [file_offset,num]=fread(id,1,'int32');
   Count=Count+num;
   [book_size,num]  =fread(id,1,'int32');
   Count=Count+num;
   [signal_size,num]=fread(id,1,'int32');
   Count=Count+num;
   [signal_energy,num]=fread(id,1,'float32');
   Count=Count+num;
   [book_energy,num]=fread(id,1,'float32');
   Count=Count+num;

   if Count~=6
      answer=-1;
      return;
   end

   position=position+24+book_size*24;
   if fseek(id,position,-1) ~=0
      answer=-1;
      return;
   end
end

answer=0;

function answer=seekbookv4(id, n)
fseek(id,0,-1);
magic=fread(id,4,'char');
if strcmp(char(magic'),'MPv4')~=1
   answer=-1;
   return;
end

fseek(id,4,-1);
head_size=fread(id,1,'short');
fseek(id,head_size,-1);

position=head_size;
for i=1:n
   Count=0;
   [channel, num]   =fread(id,1,'int32');
   Count=Count+num;
   [file_offset,num]=fread(id,1,'int32');
   Count=Count+num;
   [book_size,num]  =fread(id,1,'int32');
   Count=Count+num;
   [signal_size,num]=fread(id,1,'int32');
   Count=Count+num;
   [signal_energy,num]=fread(id,1,'float32');
   Count=Count+num;
   [book_energy,num]=fread(id,1,'float32');
   Count=Count+num;

   if Count~=6
      answer=-1;
      return;
   end

   position=position+24+book_size*24;
   if fseek(id,position,-1) ~=0
      answer=-1;
      return;
   end
end

answer=0;

