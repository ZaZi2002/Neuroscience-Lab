clc
close all
clear all

% Amirhossein Zahedi
% 99101705
% HWNeuroLab 3

%% Part 1
load("Data_Search_Time.mat");

%% Part 2
model = fitlm([Data.DS, Data.TD], Data.SearchTime);

% a
disp('Regression Coefficients, significance, t-values and p-values :');
disp(model.Coefficients);

MSR = model.SSR / model.NumCoefficients;
MSE = model.MSE;
F_stat = MSR / MSE;
disp('F-statistic :')
disp(F_stat);

% b
X1 = Data.DS;
X2 = Data.TD;
Y = Data.SearchTime;
betha_0 = model.Coefficients{1,1};
betha_1 = model.Coefficients{2,1};
betha_2 = model.Coefficients{3,1};
Y_hat = betha_1*X1 + betha_2*X2 + betha_0;
figure;
scatter(X1,Y);
title('Display Size VS Search Time');
xlabel('Display Size');
ylabel('Search Time');
grid minor
hold on
plot(X1,betha_1*X1 + betha_0);

figure;
scatter(X2,Y);
title('Training Duration VS Search Time');
xlabel('Training Duration');
ylabel('Search Time');
grid minor
hold on
plot(X2,betha_2*X2 + betha_0);

figure;
scatter3(X1,X2,Y,'red');
hold on
x1 = linspace(2, 10, 50);
x2 = linspace(0, 6, 50);
[X1_mesh,X2_mesh] = meshgrid(x1,x2);
Y_hat_mesh = betha_1*X1_mesh + betha_2*X2_mesh + betha_0;
surf(X1_mesh,X2_mesh,Y_hat_mesh);
title('Training Duration and Display Size VS Search Time');
xlabel('Training Duration');
ylabel('Display Size');
zlabel('Search Time');
grid minor

% c
plotSlice(model);

%% Part 3
% a
Residuals = model.Residuals.Raw;
figure;
qqplot(Residuals);
title('Q-Q Plot of Residuals');
grid minor

% b
mean_residuals = mean(Residuals);
disp('mean_residuals:');
disp(mean_residuals);

figure;
scatter(Y_hat, Residuals);
xlabel('Predicted Values');
ylabel('Residuals');
title('Residuals VS Predicted Values');
grid minor
hold on
plot(Y_hat,mean_residuals*ones(length(Y_hat)));
xlim tight

% c
figure;
scatter(X1, Residuals);
xlabel('Display Size');
ylabel('Residuals');
title('Residuals VS Display Size');
grid minor
hold on
plot(X1,mean_residuals*ones(length(Y_hat)));

%% Part 4
model_ds = fitlm(X1,Y);
model_ds_td = fitlm(model_ds.Residuals.Raw,X2);
model_td = fitlm(X2,Y);
model_td_ds = fitlm(model_td.Residuals.Raw,X1);
disp(model_ds.Coefficients);
disp(model_ds_td.Coefficients);
disp(model_td.Coefficients);
disp(model_td_ds.Coefficients);

%% Part 5
figure;
qqplot(Y);
title('Q-Q Plot of Search Time');
grid minor

figure;
histogram(Y);
title('Histogram of Search Time');
grid minor

% Transformation
Y_trans = Y.^-1.15;
figure;
qqplot(Y_trans);
title('Q-Q Plot of trasnsformed Search Time');
grid minor

figure;
histogram(Y_trans);
title('Histogram of transformed Search Time');
grid minor

% Regression
model_trans = fitlm([X1,X2],Y_trans);
disp('Regression Coefficients, significance, t-values and p-values :');
disp(model_trans.Coefficients);

% Residuals
figure;
qqplot(model_trans.Residuals.Raw);
title('Q-Q Plot of Residuals');
grid minor

%% Part 6
% b
[~,~,resuts_anova,~] = anovan(Y,[X1 X2]);
disp('ANOVA Results:');
disp(resuts_anova);

% c
[Tukey,~,~,Name1] = multcompare(resuts_anova, 'CType', 'hsd');
tukey_results = table(Tukey(:,1), Tukey(:,2), Tukey(:,3), Tukey(:,6), ...
    'VariableNames', {'Group1', 'Group2', 'Difference', 'pValue'});
disp('Tukey HSD Post-Hoc Comparison:');
disp(tukey_results);

scheffe = multcompare(resuts_anova, 'CType', 'scheffe');
scheffe_results = table(scheffe(:,1), scheffe(:,2), scheffe(:,3), scheffe(:,6), ...
    'VariableNames', {'Group1', 'Group2', 'Difference', 'pValue'});
disp('Scheffe Post-Hoc Comparison:');
disp(scheffe_results);

bonferroni = multcompare(resuts_anova, 'CType', 'bonferroni');
bonferroni_results = table(bonferroni(:,1), bonferroni(:,2), bonferroni(:,3), bonferroni(:,6), ...
    'VariableNames', {'Group1', 'Group2', 'Difference', 'pValue'});
disp('Bonferroni Post-Hoc Comparison:');
disp(bonferroni_results);

%% Part 7
[~,~,resuts_anova_subject,~] = anovan(Y,[X1 X2 Data.Subject]);
disp('ANOVA Results with Subject:');
disp(resuts_anova_subject);
