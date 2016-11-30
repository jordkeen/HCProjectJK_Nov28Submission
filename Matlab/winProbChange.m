%set home directory
cd('****\HCProjectJK_Nov28Submission-Master');

%direct to Matlab directory
cd Matlab

%read in data exported from STATA
%2016 season - fixed effects model
clear;
data = readtable('winProbData.xlsx');

%generates figure X
data.winProbNeutral = 1 - normcdf(0,data.predMarginNeutral,data.stdf);
data.winProbHome = 1 - normcdf(0,data.predMarginNeutral + data.teamHomeCoef,data.stdf);
data.winProbChange = data.winProbHome - data.winProbNeutral;


scatter(data.predMarginNeutral,data.winProbChange,'.');

%make Table 5
avgStdf = mean(data.stdf);
teamHome = mean(data.teamHomeCoef);
predMarginNeutral = zeros(41,1);
index = -20;
for xx = 1:size(predMarginNeutral)
    predMarginNeutral(xx,:) = index;
    index = index + 1;
end

winProbNeutral = 1 - normcdf(0,predMarginNeutral,avgStdf);
winProbHome = 1 - normcdf(0,predMarginNeutral+teamHome,avgStdf);
changeWinProb = winProbHome - winProbNeutral;

table5array = [predMarginNeutral,winProbNeutral,winProbHome,changeWinProb];
table5 = array2table(table5array);

table5.Properties.VariableNames{'table5array1'} = 'predMarginNeutral';
table5.Properties.VariableNames{'table5array2'} = 'winProbNeutral';
table5.Properties.VariableNames{'table5array3'} = 'winProbHome';
table5.Properties.VariableNames{'table5array4'} = 'changeWinProb';

cd ..
cd Tables
writetable(table5,'table5.xlsx');

%make Figure 4

figure4 = figure;
plot(predMarginNeutral,changeWinProb,'-');
xlabel({'Predicted Scoring Margin - Neutral Site'});
ylabel({'Expected Change in Win Probability at Home'});

cd ..
cd Figures
saveas(figure4,'winProbChangeFigure.png');

