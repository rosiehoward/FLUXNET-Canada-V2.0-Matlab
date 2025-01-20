function structProject = get_TAB_project_configuration(projectPath)
% This function will be replaced with a single config.yml file
% in the projectPath folder that the parent function will read.
%
% To simplify writing of YAML config files and reduce cutting and pasting
% errors, we could write a Matlab GUI to create the initial YAML using the code
% below. The resulting YAML can then be
% edited by either the same GUI or by the user using a text editor.
% 
% Here is the matlab structure structProject that could be saved
% as YAML file using yaml.dumpFile function.
%-------- start yaml ---------------------
projectName = 'FLUXNET-Canada-V2.0';
structProject.projectName   = projectName;
structProject.path          = fullfile(projectPath);
structProject.databasePath  = fullfile(structProject.path,'Database');
structProject.sitesPath     = fullfile(structProject.path,'Sites');
structProject.matlabPath    = fullfile(structProject.path,'Matlab');
%-------- end yaml ---------------------------

