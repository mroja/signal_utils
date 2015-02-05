
function data = read_data(c) % c is the config structure 
    % c.data_file – a field in the config structure containning 
    %               string with the name of the data file
    % c.current_channel – number of channel being analyzed
    fid = fopen(c.data_file, 'rb');

    % c.dimBase - number of samples per single trial
    % c.N - numer of trials
    d = fread(fid, [c.dimBase, c.N], 'float64');
    data = transpose(d);

    fclose(fid);
end
