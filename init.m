function config = init(set_keys, set_values)
	config = settings();

    if nargin == 2
        tmp_map = containers.Map(set_keys,set_values);
        config = [config; tmp_map];
        %disp('nargin == 2');
    end

    path(strcat(config('matlab_code_dir'), '/bayer/helpers'),path);
	path(strcat(config('matlab_code_dir'), '/bayer'),path);
	path(config('matlab_code_dir'),path);
    
    
    global idata_path;
    idata_path = config('data_path_base');

end