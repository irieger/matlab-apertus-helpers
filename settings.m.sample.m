function map = settings()
	map = containers.Map;

	map('data_path_base') = '/Users/irieger/apertus/data';
	map('matlab_code_dir') = '/Users/irieger/apertus/matlab';

	map('apertus_script') = strcat(map('matlab_code_dir'), '/apertus_com.bash');
    map('tmp_dir') = strcat(map('data_path_base'), '/tmp');

end