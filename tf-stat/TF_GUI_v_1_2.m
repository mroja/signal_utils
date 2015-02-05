function start_g_en()

% GUI for time-frequency Event Related data analysis
% Programmed by Mariusz Beksa
%   $Revision: 1 $  $Date: 2006/01/30 $

%glowny kod
addpath('m');  %dodanie sciezki do plikow
%przygotowanie okienka
scrsz = get(0,'ScreenSize');
figure('name','config','Position',[200 scrsz(4)/2-150 scrsz(3)/2+140 scrsz(4)/2-40],'color',[0.9 0.9 0.9],'resize','off');%'toolbar','none',,'menubar','none'
c.numer=1;
c=reset(c);  %wartosci standardowe struktury c ktora przechowuje wszystkie parametry
set(0,'userdata',c);
tworz_ekran(c.numer);
end


function [id]=tworz_obiekt(co,napis,polozenie,help,zaznaczony)
%Przeznaczenie: tworzy pola edycyjne i labele - nadaje tez czesc wartosci standardowe
%Parametry wejsciowe: co-oznacza jaki obiekt ma byc stworzony (l-label,
%                     e-pole edycyjne, c-check box
%                     napis-nazwa wyswietlana przez obiekt
%                     polozenie-polozenie na ekranie;
%                     help-tresc pomocy
%                     zaznaczony-tylko dla check box-ow zaznacza go
%Kiedy wywolywana: gdy umieszczamy obiekt na ekranie
%Parametry wyjsciowe: id-zwraca numer obiektu aby mozliwa byla identyfikacja kontrolki
if co=='l'
    id=uicontrol('style','text','string',napis,'horizontalalignment','right','position',polozenie,'backgroundcolor',[0.9 0.9 0.9],'foregroundcolor',[0 0 0.7],'tooltip',help);
end
if co=='e'
    id=uicontrol('style','edit','string',napis,'BackgroundColor','white','position',polozenie,'tooltip',help);
end
if co=='c'
    id=uicontrol('style','check','string',napis,'position',polozenie,'Value',zaznaczony,'backgroundcolor',[0.9 0.9 0.9],'foregroundcolor',[0 0 0.7],'tooltip',help);
end

%koniec funkcji tworz obiekt
end


function [panel]=panel(numer)
%Przeznaczenie:  rysuje panel z przyciskami po prawej stronie
%Parametry wejsciowe: numer-numer ekranu ktory ma zostac narysowany
%Kiedy wywolywana: przez funkcje rysujaca ekran
%Parametry wyjsciowe: panel-identyfikator panelu

id=uicontrol(gcf,'style','frame','position',[430,20,200,300],'backgroundcolor',[0.9 0.9 0.9],'foregroundcolor',[1 1 1]);
id=uicontrol('style','text','STRING',['STEP: ' num2str(numer) '/5'],'position',[450,270,160,30],'fontsize',12,'fontweight','bold','backgroundcolor',[0.9 0.9 0.9],'foregroundcolor',[0 0 0.7]);

id=tworz_obiekt('l','base name for output files',[470,242,130,20],'Enter base name');
panel.e1=tworz_obiekt('e','podaj nazwe',[475,230,120,20],'Enter base name');
%  id=tworz_obiekt('l','t-f energy estimator:',[500,202,60,20],'Select a method for estimation of energy density in time-frequency plane');
id=tworz_obiekt('l','t-f energy estimator:',[465,202,120,20],'Select a method for estimation of energy density in time-frequency plane');
panel.pop1=uicontrol('Style', 'popup','String', 'SP|CWT|MP','backgroundcolor',[1 1 1],'foregroundcolor',[0 0 0.7],'enable','off','Position', [475,190,120,20],'tooltip','Select a method for estimation of energy density in time-frequency plane','callback',@mp);

%przyciski panelu
id=tworz_obiekt('l','Your parameters:',[455,130,120,20],'');
id=uicontrol('style','push','string','load','position',[440,110,60,25],'callback',@laduj,'tooltip','Load configuration');
id=uicontrol('style','push','string','reset','position',[500,110,60,25],'callback',@reset2,'tooltip','Default configuration');
id_save=uicontrol('style','push','string','save','position',[560,110,60,25],'callback',@zapisz,'enable','off','tooltip','Save  configuration');
id_back=uicontrol('style','push','string','<< back','position',[440,50,60,25],'callback',@back);
id_next=uicontrol('style','push','string','next >>','position',[560,50,60,25],'callback',@next);
id=uicontrol('style','push','string','help','position',[500,50,60,25],'callback',@help1);

% nadanie wartosci w zaleznosci od numeru ekranu
if numer==1
    set(id_back,'enable','off');
    set(panel.pop1,'enable','on');
end
if numer==5
    set(id_next,'string','start');
    set(id_save,'enable','on');
end

d=get(0,'userdata')'; %wczytanie parametrow programu
set(panel.e1,'String',d.base_name);
set(panel.pop1,'Value',d.e.pop1_num);
%koniec funkcji panel
end


function tworz_ekran(numer)
%Przeznaczenie:  rysuje odpowiedni ekran
%Parametry wejsciowe: numer-numer ekranu ktory ma zostac narysowany
%Kiedy wywolywana: przez funkcje obsugi przycikow next i back oraz na
%                  poczatku pracy programu
%Parametry wyjsciowe: brak
clf;
c=get(0,'userdata')';
%rysuje panel i ramki
c.panel=panel(numer);
%id=uicontrol(gcf,'style','frame','position',[20,20,400,300],'backgroundcolor',[0.9 0.9 0.9],'foregroundcolor',[1 1 1]);
annotation(gcf,'rectangle',[0.035 0.058 0.61 0.867],'EdgeColor',[1 1 1]);
annotation(gcf,'rectangle',[0.058 0.078 0.56 0.76],'EdgeColor',[1 1 1]);
%id=uicontrol(gcf,'style','frame','position',[40,40,360,235],'backgroundcolor',[0.9 0.9 0.9],'foregroundcolor',[1 1 1]);
id_1=uicontrol('style','text','position',[120,280,200,20],'fontsize',12,'fontweight','bold');

%rysuje 1 ekran (wszystkie kontrolki widziane na pierwszym ekranie)
%wazne: numerki przy zmiennych przed funkcja tworz_obiket sa aby mozna bylo
%odczytywac z nich wartosci jezeli jest tylko id to sa one tylko rysowane
set(id_1,'backgroundcolor',[0.9 0.9 0.9],'foregroundcolor',[0 0 0.7]);
if numer==1
    set(id_1,'string','FILE CONFIGURATION');
    id1=tworz_obiekt('l','data path',[60,195,80,20],'Enter data file name');
    id=tworz_obiekt('l','montage file',[60,155,80,20],'Enter montage file name');
    id2=tworz_obiekt('l','*.m reading data',[60,115,80,20],'Enter file name of the function for reading data');
    id=tworz_obiekt('l','output directory',[60,75,80,20],'Enter paht for results');

    %pola edycyjne
    c.e.e1=tworz_obiekt('e',c.data_file,[150,200,180,20],'Enter data file name');
    c.e.e2=tworz_obiekt('e',c.montage,[150,160,180,20],'Enter montage data file name');
    c.e.e3=tworz_obiekt('e',c.read_raw_data,[150,120,180,20],'Enter file name of the function for reading data');
    c.e.e4=tworz_obiekt('e',c.output_directory,[150,80,180,20],'Enter paht for results');

    id=uicontrol('style','push','string','...','position',[340,200,20,20],'callback',@g1,'tooltip','Select file');
    id=uicontrol('style','push','string','...','position',[340,160,20,20],'callback',@g2,'tooltip','Select file');
    id55=uicontrol('style','push','string','...','position',[340,120,20,20],'callback',@g3,'tooltip','Select file');
    id=uicontrol('style','push','string','...','position',[340,80,20,20],'callback',@g4,'tooltip','Select directory');

    %gdy MP to nadajemy odpowiednie wartosci
    if c.e.pop1_num==3
        set(c.e.e3,'enable','off');
        set(id55,'enable','off');
        set(id1,'string','book name');
        set(id2,'ForegroundColor',[0.5 0.5 0.5]);
    end
end

%rysuje 2 ekran (wszystkie kontrolki widziane na pierwszym ekranie)
%tak jak wyzej
if numer==2
    set(id_1,'string','SIGNAL PARAMETERS');
    id=tworz_obiekt('l','samples',[100,235,70,20],'Enter length of signal in samples');
    id=tworz_obiekt('l','sampling',[100,205,70,20],'Enter sampling frequency in Hz');
    %id=tworz_obiekt('l','time length',[100,175,70,20],'Enter signal length in seconds');
    id=tworz_obiekt('l','Number of trials',[80,145,90,20],'Enter number of trials');
    id1=tworz_obiekt('l','Hz',[270,205,25,20],'');
    % id2=tworz_obiekt('l','s',[270,175,25,20],'');
    set(id1,'horizontalalignment','left');
    %    set(id2,'horizontalalignment','left');

    c.e.e1=tworz_obiekt('e',c.dimBase,[180,240,80,20],'Enter length of signal in samples');
    c.e.e2=tworz_obiekt('e',c.sampling,[180,210,80,20],'Enter sampling frequency in Hz');
    %c.e.e3=tworz_obiekt('e',c.time_length,[180,180,80,20],'Enter signal length in seconds');
    c.e.e4=tworz_obiekt('e',c.N,[180,150,80,20],'Enter number of trials');
    %dodatkowe
    id51=tworz_obiekt('l','Morlet Wavelet par.',[60,115,110,20],'Enter wave constant (f/sig_f)');
    id52=tworz_obiekt('l','Min. periods in waveform',[45,85,125,20],'Enter minimal number of periods for an t-f atom included in the t-f map');
    id53=tworz_obiekt('l','Accepted scales:',[60,45,110,20],'Enter range of acceptable duration of an t-f atom');
    id=tworz_obiekt('l','min',[170,65,30,20],'Minimal value in seconds');
    id=tworz_obiekt('l','max',[220,65,30,20],'Maximal value in seconds');
    id3=tworz_obiekt('l','s',[270,45,25,20],'');
    set(id3,'horizontalalignment','left');

    c.e.e21=tworz_obiekt('e',c.WAVE,[180,120,80,20],'Enter wave constant (f/sig_f)');
    c.e.e22=tworz_obiekt('e',c.OSC_NUM,[180,90,80,20],'Enter minimal number of periods for an t-f atom');
    c.e.e23=tworz_obiekt('e',c.filter_scale(1),[180,50,40,20],'Minimal value in seconds');
    c.e.e24=tworz_obiekt('e',c.filter_scale(2),[220,50,40,20],'Maximal value in seconds');

    set(c.e.e21,'enable','off');
    set(c.e.e22,'enable','off');
    set(c.e.e23,'enable','off');
    set(c.e.e24,'enable','off');

    %nadawanie wartosci w zaleznosci od wybranych opcji
    switch c.e.pop1_num
        case 1
            set(id51,'ForegroundColor',[0.5 0.5 0.5]);
            set(id52,'ForegroundColor',[0.5 0.5 0.5]);
            set(id53,'ForegroundColor',[0.5 0.5 0.5]);
        case 2
            set(c.e.e21,'enable','on');
            set(id52,'ForegroundColor',[0.5 0.5 0.5]);
            set(id53,'ForegroundColor',[0.5 0.5 0.5]);
        case 3
            set(c.e.e22,'enable','on');
            set(c.e.e23,'enable','on');
            set(c.e.e24,'enable','on');
            set(id51,'ForegroundColor',[0.5 0.5 0.5]);
    end
end

%trzeci ekran
if numer==3
    set(id_1,'string','GRAPHICAL OUTPUT');

    c.e.c1=tworz_obiekt('c','t-f maps of accepted ERD/ERS',[140,130,180,20],'Check to compute map of significant ERD/ERS',c.OUTPUT_ACCEPTED);


    c.e.c2=tworz_obiekt('c','raw t-f map of ERD/ERS',[140,160,180,20],'Check to compute map of raw ERD/ERS',c.OUTPUT_ERD_ERS);
    c.e.c3=tworz_obiekt('c','t-f map of mean energy distribution',[140,240,180,20],'Check to compute map of energy density',c.OUTPUT_MEAN_MAP);
    %c.e.c4=tworz_obiekt('c','FDR criterion display',[140,80,180,20],'Check to compute curve for FDR criterion',c.PLOT_FDR);
    set(c.e.c3,'callback',@energia);
    id1=tworz_obiekt('l','energy scale',[150,210,70,20],'Select energy scale (affects  only the maps of energy density)');
    c.e.pop2 = uicontrol('Style', 'popup','String', 'LIN|LOG|SQRT','Position', [240,215,80,20],'backgroundcolor',[1 1 1],'foregroundcolor',[0 0 0.7],'enable','off','tooltip','Select energy scale (affects  only the maps of energy density)');
    set(c.e.pop2,'Value',c.e.pop2_num);
    if c.OUTPUT_MEAN_MAP==1
        set(c.e.pop2,'enable','on');
    else
        set(id1,'ForegroundColor',[0.5 0.5 0.5]);
    end
    % Radiobuttons for selecting manual or automatic colorscale for ERD ERS
    % maps. Manual is useful when comparing between  subjects / tasks
    c.l.min=tworz_obiekt('l','min',[150,60,40,20],'');
    c.l.max=tworz_obiekt('l','max',[220,60,40,20],'');
    if ~isfield(c,'erd'), c.erd=-100; end
    c.e.erd=tworz_obiekt('e',c.erd,[150 45 60 20],'maximal ERD %');
    if ~isfield(c,'ers'), c.ers=100; end
    c.e.ers=tworz_obiekt('e',c.ers,[220 45 60 20],'maximal ERS %');
    if ~isfield(c,'ERD_ERS_COLOR'),c.ERD_ERS_COLOR='AUTO'; end
    if strcmp(c.ERD_ERS_COLOR,'AUTO')
        set(c.e.erd,'Enable','off');
        set(c.e.ers,'Enable','off');
        set(c.l.max,'ForegroundColor',[0.5 0.5 0.5]);
        set(c.l.min,'ForegroundColor',[0.5 0.5 0.5]);
    else
        set(c.e.erd,'Enable','on');
        set(c.e.ers,'Enable','on');
        set(c.l.max,'ForegroundColor',[0 0 0.7]);
        set(c.l.min,'ForegroundColor',[0 0 0.7]);
    end

    rb=uibuttongroup('visible','on',...
        'title','Color scale for ERD/ERS maps',...
        'Position',[0.2 0.09 0.27 0.26],...
        'backgroundcolor',[0.9 0.9 0.9],'foregroundcolor',[0 0 0.7],...
        'BorderType','etchedin');
    u0 = uicontrol('Style','Radio','String','auto',...
        'Position',[20 50 60 20],'parent',rb,'HandleVisibility','on');
    u1 = uicontrol('Style','Radio','String','manual',...
        'pos',[90 50 60 20],'parent',rb,'HandleVisibility','on');
    set(rb,'SelectionChangeFcn',@auto_manual_color);
    if strcmp(c.ERD_ERS_COLOR,'AUTO')
        set(rb,'SelectedObject',u0);
    else
        set(rb,'SelectedObject',u1);
    end
    set(rb,'Visible','on');
    set(0,'userdata',c);
end

%czwarty ekran
if numer==4
    set(id_1,'string','AXES PARAMETERS');

    if c.tmax==0
        c.tmax  = c.time_length;
    end
    if c.f_max==0
        c.f_max  = c.sampling/2;
    end

    id=tworz_obiekt('l','time',[70,225,80,20],'Enter time range in seconds');
    id=tworz_obiekt('l','frequency',[70,195,80,20],'Enter frequency range in Hz');
    id=tworz_obiekt('l','reference period',[50,165,100,20],'Reference period range in seconds');
    id=tworz_obiekt('l','min',[150,250,40,20],'');
    id=tworz_obiekt('l','max',[220,250,40,20],'');
    id1=tworz_obiekt('l','s',[290,225,20,20],'');
    id2=tworz_obiekt('l','Hz',[290,195,20,20],'');
    id3=tworz_obiekt('l','s',[290,170,20,20],'');
    set(id1,'horizontalalignment','left');
    set(id2,'horizontalalignment','left');
    set(id3,'horizontalalignment','left');

    c.e.e1=tworz_obiekt('e',c.tmin,[155,230,60,20],'Begining');
    c.e.e2=tworz_obiekt('e',c.tmax,[225,230,60,20],'End');
    c.e.e3=tworz_obiekt('e',c.f_min,[155,200,60,20],'Lowest frequency');
    c.e.e4=tworz_obiekt('e',c.f_max,[225,200,60,20],'Highest frequency');
    c.e.e5=tworz_obiekt('e',c.ref_sec(1),[155,170,60,20],'Begining of the reference period');
    c.e.e6=tworz_obiekt('e',c.ref_sec(2),[225,170,60,20],'End of the reference period');

    id=tworz_obiekt('l','right margin',[70,135,80,20],'Enter right margin (for t-f maps) in seconds');
    id=tworz_obiekt('l','frequency tick',[70,105,80,20],'Enter frequency ticks');
    id=tworz_obiekt('l','time tick',[70,75,80,20],'Enter time ticks');
    id=tworz_obiekt('l','lines',[70,45,80,20],'Enter time for marker lines');
    id3=tworz_obiekt('l','s',[290,45,20,20],'');
    set(id3,'horizontalalignment','left');

    c.e.e7=tworz_obiekt('e',c.right_time_margin,[155,140,130,20],'Enter right margin (for t-f maps) in seconds');
    c.e.e8=tworz_obiekt('e',c.numfreq ,[155,110,130,20],'Enter frequency ticks');
    c.e.e9=tworz_obiekt('e',c.num_time,[155,80,130,20],'Enter time ticks');
    c.e.e10=tworz_obiekt('e',['[' num2str(c.lines) ']'],[155,50,130,20],'Enter time for marker lines');
end

%piaty ekran
if numer==5
    set(id_1,'string','STATISTICS');

    c.e.pop3 = uicontrol('Style', 'popup','backgroundcolor',[1 1 1],'foregroundcolor',[0 0 0.7],'String',...
        'Bootstraped T-statistics|Permutation test|Parametric T-test|Welch T-test|Parametric Z-test','Position', [210,190,140,20],...
        'Value',c.e.pop3_num,'callback',@testy,'tooltip','Select type of test');
    c.e.pop4 = uicontrol('Style', 'popup','backgroundcolor',[1 1 1],'foregroundcolor',[0 0 0.7],'String',...
        'FDR|BH|Bonferroni|NONE','Position', [210,160,140,20],'Value',c.e.pop4_num,'callback',@testy,...
        'tooltip','Select correction for multiple tests');
    c.e.e1=tworz_obiekt('e',c.dt,[210,220,140,20],'Enter resel size in seconds');
    c.e.e2=tworz_obiekt('e',c.p_level,[210,130,140,20],'Enter significance level');
    c.e.e3=tworz_obiekt('e',c.FDR_q,[210,100,140,20],'Enter acceptable level of false discoveries');
    c.e.e4=tworz_obiekt('e',c.Npseudot,[210,70,140,20],'Enter number of bootstraps');
    set(c.e.e2,'enable','off');
    set(c.e.e3,'enable','off');
    set(c.e.e4,'enable','off');

    if c.OUTPUT_ACCEPTED==1
        %jesli potrzebna bedzie statystyka
        id=tworz_obiekt('l','dt',[90,215,110,20],'Enter resel size in seconds');
        id4=tworz_obiekt('l','s',[360,215,20,20],'');
        set(id4,'horizontalalignment','left');
        id=tworz_obiekt('l','statistics',[90,185,110,20],'Select type of test');
        id=tworz_obiekt('l','correction for multiple tests',[60,155,140,20],'Enter significance level');
        id1=tworz_obiekt('l','p level',[90,125,110,20],'Enter significance level');
        id2=tworz_obiekt('l','q (FDR)',[90,95,110,20],'Enter acceptable level of false discoveries');
        id11=tworz_obiekt('l','Number of permutation',[90,65,110,20],'Enter number of permutation');

        if get(c.e.pop4,'value')==1
            set(c.e.e3,'enable','on');
            set(id1,'ForegroundColor',[0.5 0.5 0.5]);
        else
            set(c.e.e2,'enable','on');
            set(id2,'ForegroundColor',[0.5 0.5 0.5]);
        end

        switch get(c.e.pop3,'value')
            case 1
                set(c.e.e4,'enable','on');
                set(id11,'string','Number of bootstraps');
            case 2
                set(c.e.e4,'enable','on');
            case 3
                set(id11,'ForegroundColor',[0.5 0.5 0.5]);
            case 4
                set(id11,'ForegroundColor',[0.5 0.5 0.5]);
            case 5
                set(id11,'ForegroundColor',[0.5 0.5 0.5]);
        end

    else
        id=uicontrol('style','text','string','NO STATISTICS CHOOSEN','position',[70,150,300,30],'fontsize',12,...
            'fontweight','bold');
        set(c.e.pop3,'visible','off');
        set(c.e.pop4,'visible','off');
        set(c.e.e1,'visible','off');
        set(c.e.e2,'visible','off');
        set(c.e.e3,'visible','off');
        set(c.e.e4,'visible','off');
    end

end  %koniec piatego ekranu
set(0,'userdata',c);
%koniec funkcji tworz_ekran
end

function testy(src,evt)
%Przeznaczenie:  odrysowuje na nowo ekran 5 gdy zmienimy opcje w polach wyboru
%Parametry wejsciowe: systemowe
%Kiedy wywolywana: przez zmiane parametru w statystyce 5 ekran
%Parametry wyjsciowe: brak
zapisz_ekran(5);
c=get(0,'userdata')';
c.e.pop3_num=get(c.e.pop3,'value');
c.e.pop4_num=get(c.e.pop4,'value');
set(0,'userdata',c);
tworz_ekran(c.numer);
end


function energia(src,evt)
%Przeznaczenie:  zapamietuje wartosc kontrolki energy scale
%Parametry wejsciowe: systemowe
%Kiedy wywolywana: przez zmiane parametru w kontrolce energy scale
%Parametry wyjsciowe: brak
zapisz_ekran(3);
tworz_ekran(3);
end

function mp(src,evt)
%Przeznaczenie:  zapamietuje wartosc kontrolki map type
%Parametry wejsciowe: systemowe
%Kiedy wywolywana: przez zmiane parametru w kontrolce map type
%Parametry wyjsciowe: brak
c=get(0,'userdata')';
disp(c.panel.e1);
zapisz_ekran(1);
tworz_ekran(1);
end


function zapisz_ekran(numer)
%Przeznaczenie:  zapisuje wartosci z kontrolek do struktyry przechowujacej
%wszystkie parametry
%Parametry wejsciowe: numer ekranu
%Kiedy wywolywana: przez przyciski next  i back
%Parametry wyjsciowe: brak
c=get(0,'userdata')';
c.base_name=get(c.panel.e1,'String');

%pierwszy ekran
if numer==1
    c.data_file=get(c.e.e1,'String');
    c.montage=get(c.e.e2,'String');
    c.read_raw_data=get(c.e.e3,'String');
    c.output_directory=get(c.e.e4,'String');
    c.bookname=c.data_file;
    c.e.pop1_num=get(c.panel.pop1,'Value');
    switch c.e.pop1_num
        case 1
            c.MAP_TYPE='SP';
        case 2
            c.MAP_TYPE='CWT';
        case 3
            c.MAP_TYPE='MP';
    end
end

%drugi ekran
if numer==2
    c.dimBase=str2num(get(c.e.e1,'String'));
    c.sampling=str2num(get(c.e.e2,'String'));
    c.time_length=c.dimBase/c.sampling;% str2num(get(c.e.e3,'String'));
    c.N=str2num(get(c.e.e4,'String'));
    c.WAVE=str2num(get(c.e.e21,'String'));
    c.OSC_NUM=str2num(get(c.e.e22,'String'));
    % c.filter_min=str2num(get(c.e.e23,'String'));
    % c.filter_max=str2num(get(c.e.e24,'String'));
    c.filter_scale=[str2num(get(c.e.e23,'String')) str2num(get(c.e.e24,'String'))];
end

%trzeci ekran
if numer==3
    c.OUTPUT_ACCEPTED=get(c.e.c1,'Value');
    c.OUTPUT_ERD_ERS=get(c.e.c2,'Value');
    c.OUTPUT_MEAN_MAP=get(c.e.c3,'Value');
    c.PLOT_FDR=0;%get(c.e.c4,'Value');
    c.e.pop2_num=get(c.e.pop2,'Value');
    switch c.e.pop2_num
        case 1
            c.ENERGY_SCALE='LIN';
        case 2
            c.ENERGY_SCALE='LOG';
        case 3
            c.ENERGY_SCALE='1_2';
    end
    if strcmp(c.ERD_ERS_COLOR,'MANUAL')
        c.erd=str2num(get(c.e.erd,'String'));
        c.ers=str2num(get(c.e.ers,'String'));
    end

end

%czwarty ekran
if numer==4
    c.tmin=str2num(get(c.e.e1,'String'));
    c.tmax=str2num(get(c.e.e2,'String'));
    c.f_min=str2num(get(c.e.e3,'String'));
    c.f_max=str2num(get(c.e.e4,'String'));
    c.ref_sec=[str2num(get(c.e.e5,'String')) str2num(get(c.e.e6,'String'))];
    c.right_time_margin=str2num(get(c.e.e7,'String'));
    c.numfreq=str2num(get(c.e.e8,'String'));
    c.num_time=str2num(get(c.e.e9,'String'));
    c.lines=eval(get(c.e.e10,'String'));
    c.MAX_RES=1;

end

%piaty ekran
if numer==5
    c.dt=str2num(get(c.e.e1,'String'));
    c.p_level=str2num(get(c.e.e2,'String'));
    c.FDR_q=str2num(get(c.e.e3,'String'));
    c.Npseudot=str2num(get(c.e.e4,'String'));
    c.Nboot=c.Npseudot;
    c.e.pop3_num=get(c.e.pop3,'Value');
    switch c.e.pop3_num
        case 1
            c.STATISTICS='PSEUDO_T';
        case 2
            c.STATISTICS='PERM_TEST';
        case 3
            c.STATISTICS='T_TEST';
        case 4
            c.STATISTICS='WELCH';
        case 5
            c.STATISTICS='Z_TEST';
    end

    c.e.pop4_num=get(c.e.pop4,'Value');
    switch c.e.pop4_num
        case 1
            c.MULTIPLE_TEST_CORRECTION='FDR';
        case 2
            c.MULTIPLE_TEST_CORRECTION='BH';
        case 3
            c.MULTIPLE_TEST_CORRECTION='FULL_BONFERRONI';
        case 4
            c.MULTIPLE_TEST_CORRECTION='NONE';
    end

end %koniec piatego ekranu

set(0,'userdata',c);
end %koniec funkci zapisz_ekran


function next(src,evt)
%Przeznaczenie:  wyswietla kolejne ekrany a gdy jest to ostatni to
%                uruchamia wyliczenia
%Parametry wejsciowe: systemowe
%Kiedy wywolywana: przez przycisk next
%Parametry wyjsciowe: brak
c=get(0,'userdata')';
zapisz_ekran(c.numer);
c=get(0,'userdata')';
c.numer=c.numer+1;

%kontrola parametrow
jaki=kontrola(c.numer-1);
if (jaki)
    warndlg(['Wrong value in field nr: ' num2str(jaki) ],'Wrong value');
    return
end

%gdy ostatni ekran
if c.numer==6
    c=wylicz(c);
    disp(c);
    close 'config';
    drawnow;
    make_output_v_1_2(c);
    %back
else
    set(0,'userdata',c);
    tworz_ekran(c.numer);
end
end


function back(src,evt)
%Przeznaczenie:  wyswietla kolejne ekrany
%Parametry wejsciowe: systemowe
%Kiedy wywolywana: przez przycisk back
%Parametry wyjsciowe: brak
c=get(0,'userdata')';
zapisz_ekran(c.numer);

c=get(0,'userdata')';
c.numer=c.numer-1;
set(0,'userdata',c);
tworz_ekran(c.numer);
end


function reset2(src,evt)
%Przeznaczenie: wywoluje funkcje do przywrocenia wartosci domyslnych
%Parametry wejsciowe: systemowe
%Kiedy wywolywana: przez przycisk reset
%Parametry wyjsciowe: brak
c=get(0,'userdata')';
c.numer=1;
c=reset(c);
set(0,'userdata',c);
tworz_ekran(c.numer);
end

function [c]=reset(c)
%Przeznaczenie: nadaje wartosci domyslne parametrom
%Parametry wejsciowe: struktura c-ktora przechowuje wysztkie zmienne
%Kiedy wywolywana: gdy przywracamy wartosci domyslne
%Parametry wyjsciowe: struktura c

% zmienne inicjujace ustawienia comboboxow - odpowiadaja za wybor
% standardowy
c.e.pop1_num=1;
c.e.pop2_num=1;
c.e.pop3_num=1;
c.e.pop4_num=1;
c.output_directory='enter directory';
c.filter_min=0;
c.filter_max=0;

% zmienne niezbedne do prawidlowej pracy funkcji obliczajacej:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                signal parameters,
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% nazwy plikow:
c.base_name='enter name';  % rdzen do nazywania plikow wynikowych:
c.data_file='enter data file';  % plik z danymi
c.montage='enter montage file'; % plik z danymi montazu
c.read_raw_data='enter read data fuction'; % nazwa pliku z funkcja czytajaca dane
c.bookname = ''; %nazwa pliku z ksiazka  (rownowazne chyba nazwie funkcji czytajacej tylko dla mp


c.dimBase=0; % number of points in single epoch
c.sampling=0; % sampling frequency in Hz
c.time_length=0;   % time length in seconds
c.N=0; %number of repetition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		   MAPS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c.OUTPUT_TYPE=' '; % parametr pomocniczy (nazwa) do wolania topo_tf_cwt
c.OUTPUT_ACCEPTED=1; % 'ACCEPTED' Display map of accepted ERD/ERS
c.OUTPUT_ERD_ERS=1; % 'ERD_ERS' Display raw map of ERD/ERS
c.OUTPUT_MEAN_MAP=1;  % Display map of mean energy distribution 'MEAN_MAP'

% nie musza byc teraz inicjowane - w trakcie programu
c.ENERGY_SCALE='';   % typ skali  'LIN' 'LOG' or 'SQRT' or, 'LOGIT' ,'LOG+1' 'LOG_SQRT', 'SQRT_SQRT' ,'1/3'
c.MAP_TYPE='';   % rodzaj mapy
c.WAVE=20; % tylko do CWT
c.MAX_RES=1; 	       % Use MaxRes in MP displays or CWT default 1
c.OSC_NUM = 0; % filtr do wyboru atomow - tylko dla MP

% marginesy:
% prawy uzywany b. intensywnie, lewy - wcale, lewy bierzemy jako lewa granice referencji
c.left_time_margin=1;                    % number of seconds to skip on map ...
c.right_time_margin=1;                   % ... to avoid border problems

c.dt = 0;           % time width of resel in sec
c.f_min = 0; 		% in Hz; kontrola z Fs
c.f_max = 0;		% in Hz; kontrola z Fs
c.tmin  = 0;		% in sec; kontrola
c.tmax  = 0;        % in sec; kontrola z time_length

c.correction_mode = 'real, strict limits'; % params = '(exp|integral),(strict resel|strict limits),(real|points))'
c.calculating_maps_mode = 'integral, real, no correction'; % (exp|integral)
c.calculating_max_res_mode = 'exp, points, no correction';
c.filter_scale = [0.07 11];	% in sec   % only for MP maps

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                      STATISTICS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nie musza byc teraz inicjowane - w trakcie programu
c.STATISTICS   = '' ;              % 'PSEUDO_T' or 'PERM_TEST' or 'T_TEST' ,'Z_TEST'
c.MULTIPLE_TEST_CORRECTION = '' ;	% or 'BH' or 'BY_COLUMN' or 'FDR' or 'FULL_BONFERRONI' or 'NONE'
c.p_level=0.05;			% two-sided test
c.FDR_q=0.05;		% max % of falsely rejected true hyp. in FDR
% przy wyborze resamplingu:
c.Nboot    = 2e6;                      % number of permutations in PERM_TEST
% przy wyborze pseudo_t:
c.Npseudot = 2e6;                      % number of rep. in estimating PSEUDO_T statistics
%Liczba permutacji
% koniecznie w wyliczeniach

%obszar referencyjny - zawsze
% konfiguracja "na poczatku":
c.ref_sec = [0.5 3];          		% reference period in seconds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         DISPLAY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c.numfreq = 10;          % Hz between  frequency ticks on the axis - affects only display
c.num_time =1;           % secs between time ticks - affects only display
%full_pres - tego nie bedzie - do usuniecia z kodu:
c.FULL_PRES=0;           % FULL PRESENTATION -- MORE PLOTS for MP
%full_pres - tego nie bedzie - do usuniecia z kodu:
c.PLOT_FDR =0;           % opens extra window (2) for FDR display
c.lines = [3, 4, 5]; %miejsca, w ktorych beda linie na wykresach koncowych
c.erd=-100;
c.ers=100;
c.ERD_ERS_COLOR='AUTO';
%koniec funkcji reset
end



%Przeznaczenie:  ponizsze 4 funkcje wczytuja nazwy plikow i katalogow
%Parametry wejsciowe: systemowe
%Kiedy wywolywana: przez przyciski na pierwszym ekranie
%Parametry wyjsciowe: brak
function g1(src,evt)
c=get(0,'userdata')';
[filename, pathname] = uigetfile('*.*', 'Choose file');
if isequal(filename,0)
    ;
else
    set(c.e.e1,'String',fullfile(pathname, filename));
end
end

function g2(src,evt)
c=get(0,'userdata')';
[filename, pathname] = uigetfile('*.mtg;*.s2d', 'Choose file');
if isequal(filename,0)
    ;
else
    set(c.e.e2,'String',fullfile(pathname, filename));
end
end

function g3(src,evt)
c=get(0,'userdata')';
[filename, pathname] = uigetfile('*.*', 'Choose file');
if isequal(filename,0)
    ;
else
    set(c.e.e3,'String',fullfile(pathname, filename));
    addpath(pathname);
end
end

function g4(src,evt)
c=get(0,'userdata')';
dname = uigetdir('','Browse for directory');
if isequal(dname,0)
    ;
else
    set(c.e.e4,'String',dname);
end
end



function[c]= wylicz(c)
%Przeznaczenie:  dokonywane sa przeliczenia parametrow ich zamiana ze
%stringow na liczby itp.
%Parametry wejsciowe: struktura c
%Kiedy wywolywana: przycisk start
%Parametry wyjsciowe: struktura c

[pathstr,name,ext] = fileparts(c.read_raw_data);
c.read_raw_data=['data=' name '(c);'];
c.m=read_mtg_v_1_1(c.montage);
end



function laduj(src,evt)
%Przeznaczenie: laduje strukture c zapisana na dysku
%Parametry wejsciowe: systemowe
%Kiedy wywolywana: przez przycisk laduj
%Parametry wyjsciowe: brak
c=get(0,'userdata')';
[filename, pathname] = uigetfile('*.mat', 'Select an M-file');
if isequal(filename,0) | isequal(pathname,0)
    disp('User selected Cancel')
else
    disp(['User selected',fullfile(pathname,filename)]);
    c=load(filename);
    c.numer=1;
    set(0,'userdata',c);
    tworz_ekran(c.numer);
end
end

function zapisz(src,evt)
%Przeznaczenie: zapisuje strukture c zapisana na dysku
%Parametry wejsciowe: systemowe
%Kiedy wywolywana: przez przycisk save
%Parametry wyjsciowe: brak
c=get(0,'userdata')';
[filename, pathname] = uiputfile('*.mat', 'save an M-file');
if isequal(filename,0) | isequal(pathname,0)
    disp('User selected Cancel')
else
    disp(['User selected',fullfile(pathname,filename)]);
    save (filename, '-struct', 'c');
end
end

function[jaki]=kontrola(numer)
%Przeznaczenie: sprawdza czy dane na ekranie sa poprawne
%Parametry wejsciowe: numer ekranu
%Kiedy wywolywana: przez przycisk next i back
%Parametry wyjsciowe: jaki - ktory parametr zly
jaki=0;
c=get(0,'userdata')';
if numer==1
    if strcmp('enter data file',c.data_file) jaki=1; return; end
    if strcmp('enter montage file',c.montage)  jaki=2; return; end
    if strcmp('enter read data fuction',c.read_raw_data)  jaki=3; return;  end
    if strcmp('enter directory',c.output_directory)  jaki=4; return; end

end

if numer==2
    if (isempty(c.dimBase) | c.dimBase==0) jaki=1; return; end
    if (isempty(c.sampling) | c.sampling==0) jaki=2; return; end
    %if (isempty(c.time_length) | c.time_length==0) jaki=3; return; end
    % if c.dimBase~=c.sampling*c.time_length jaki=3; return; end
    if (isempty(c.N) | c.N==0) jaki=4; return; end

end
if numer==5
    if (isempty(c.dt) | c.dt==0) jaki=1; return; end
end

end

function help1(src,evt)
%Przeznaczenie:  zapamietuje wartosc kontrolki map type
%Parametry wejsciowe: systemowe
%Kiedy wywolywana: przez zmiane parametru w kontrolce map type
%Parametry wyjsciowe: brak
c=get(0,'userdata')';
str=sprintf('web ekran%d.htm',c.numer) ;
eval(str);
end


function auto_manual_color(source,eventdata)
c=get(0,'userdata')';
%disp(source);
% disp([eventdata.EventName,'  ',...
%      get(eventdata.OldValue,'String'),'  ', ...
%      get(eventdata.NewValue,'String')]);
tryb=get(get(source,'SelectedObject'),'String')
switch tryb
    case 'auto'
        c.ERD_ERS_COLOR='AUTO'
        %set(c.e.erd,'ForegroundColor',[0.5 0.5 0.5]);
        set(c.e.erd,'Enable','off');
        %set(c.e.ers,'ForegroundColor',[0.5 0.5 0.5]);
        set(c.e.ers,'Enable','off');
        set(c.l.max,'ForegroundColor',[0.5 0.5 0.5]);
        set(c.l.min,'ForegroundColor',[0.5 0.5 0.5]);

    case 'manual'
        c.ERD_ERS_COLOR='MANUAL'
        %set(c.e.erd,'ForegroundColor',[0 0 0.7]);
        set(c.e.erd,'Enable','on');
        %set(c.e.ers,'ForegroundColor',[0 0 0.7]);
        set(c.e.ers,'Enable','on');
        set(c.l.max,'ForegroundColor',[0 0 0.7]);
        set(c.l.min,'ForegroundColor',[0 0 0.7]);
end
set(0,'userdata',c);
end