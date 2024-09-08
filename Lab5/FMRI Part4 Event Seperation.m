clc
clear all

%% Reading data
data = readtable('FMRI Data.xlsx');
N = size(data,1);

%% Seperating events
standard = [];
oddball = [];
response = [];
t_stand = 0;
t_odd = 0;
t_resp = 0;
for i = 1:N
    if (strcmp(data{i,3},'visual standard stimulus presentation'))
        t_stand = t_stand + 1;
        standard(t_stand,1) = data{i,1};
    elseif (strcmp(data{i,3},'visual oddball stimulus presentation'))
        t_odd = t_odd + 1;
        oddball(t_odd,1) = data{i,1};
    elseif (strcmp(data{i,3},'behavioral response time following visual oddball stimulus onset'))
        t_resp = t_resp + 1;
        response(t_resp,1) = data{i,1};
        response(t_resp,2) = data{i,2};
        response(t_resp,2) = response(t_resp,2) - 0.2;
    end
end

%% Saving in text file
writematrix(standard, 'standard.txt');
writematrix(oddball, 'oddball.txt');
writematrix(response, 'response.txt','Delimiter', ' ');