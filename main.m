clc;
clear;
close all;
rng(42);

 filename = 'breast_cancer_clean.csv';
% filename = 'heart.csv';

T = readtable(filename);

X = T{:,1:end-1};
y = T{:,end};

X = fillmissing(X,'constant',0);
X = normalize(X);
y = y(:);

nVar = size(X,2);
nPop = 50;
MaxIt = 100;
alpha = 0.9;

CostFunction = @(position) fitnessFunction(position, X, y, alpha);

algorithms = {'PSO','GA','WCA'};

Results = table();

Curves = struct();

for a = 1:length(algorithms)

    algorithmName = algorithms{a};

    fprintf('\n==============================\n');
    fprintf('Running Algorithm: %s\n', algorithmName);
    fprintf('==============================\n');

    tic;

    if strcmp(algorithmName,'PSO')
        [BestPosition, BestCost, Curve] = PSO_FS(CostFunction, nVar, nPop, MaxIt);

    elseif strcmp(algorithmName,'GA')
        [BestPosition, BestCost, Curve] = GA_FS(CostFunction, nVar, nPop, MaxIt);

    elseif strcmp(algorithmName,'WCA')
        [BestPosition, BestCost, Curve] = WCA_FS(CostFunction, nVar, nPop, MaxIt);
    end

    ExecutionTime = toc;

    Selected = BestPosition > 0.5;

    if sum(Selected) == 0
        Selected(1) = 1;
    end

    XSelected = X(:,Selected);

    cv = cvpartition(y,'KFold',10);

Accuracies = zeros(cv.NumTestSets,1);
Precisions = zeros(cv.NumTestSets,1);
Recalls = zeros(cv.NumTestSets,1);
F1Scores = zeros(cv.NumTestSets,1);

for k = 1:cv.NumTestSets

    trainIdx = training(cv,k);
    testIdx = test(cv,k);

    model = fitcknn( ...
        XSelected(trainIdx,:), ...
        y(trainIdx), ...
        'NumNeighbors',5);

    pred = predict(model,XSelected(testIdx,:));
    trueLabels = y(testIdx);

    Accuracies(k) = mean(pred == trueLabels);

    positiveClass = max(y);

    TP = sum((pred == positiveClass) & ...
             (trueLabels == positiveClass));

    FP = sum((pred == positiveClass) & ...
             (trueLabels ~= positiveClass));

    FN = sum((pred ~= positiveClass) & ...
             (trueLabels == positiveClass));

    Precisions(k) = TP/(TP+FP+eps);
    Recalls(k) = TP/(TP+FN+eps);

    F1Scores(k) = ...
        2*(Precisions(k)*Recalls(k))/ ...
        (Precisions(k)+Recalls(k)+eps);

end

Accuracy  = mean(Accuracies);
Precision = mean(Precisions);
Recall    = mean(Recalls);
F1Score   = mean(F1Scores);

    positiveClass = max(y);

    TP = sum((pred == positiveClass) & (trueLabels == positiveClass));
    FP = sum((pred == positiveClass) & (trueLabels ~= positiveClass));
    FN = sum((pred ~= positiveClass) & (trueLabels == positiveClass));

    Precision = TP / (TP + FP + eps);
    Recall = TP / (TP + FN + eps);
    F1Score = 2 * (Precision * Recall) / (Precision + Recall + eps);

    SelectedFeatures = find(Selected);
    NumFeatures = sum(Selected);

    fprintf('\nAlgorithm: %s\n', algorithmName);
    fprintf('Accuracy = %.4f\n', Accuracy);
    fprintf('Precision = %.4f\n', Precision);
    fprintf('Recall = %.4f\n', Recall);
    fprintf('F1-Score = %.4f\n', F1Score);
    fprintf('Execution Time = %.4f seconds\n', ExecutionTime);
    fprintf('Selected Features:\n');
    disp(SelectedFeatures);
    fprintf('Number of Selected Features = %d\n', NumFeatures);
    fprintf('Best Cost = %.4f\n', BestCost);

    Results = [Results; table( ...
        string(algorithmName), ...
        Accuracy, ...
        Precision, ...
        Recall, ...
        F1Score, ...
        NumFeatures, ...
        BestCost, ...
        ExecutionTime, ...
        'VariableNames', {'Algorithm','Accuracy','Precision','Recall','F1Score','SelectedFeatures','BestCost','Time'})];

    Curves.(algorithmName) = Curve;

    figure;
    plot(Curve,'LineWidth',2);
    xlabel('Iteration');
    ylabel('Best Cost');
    title([algorithmName ' Convergence Curve']);
    grid on;

    saveas(gcf,[algorithmName '_Convergence_Curve.png']);

end

disp(' ');
disp('Final Results Table:');
disp(Results);

figure;
plot(Curves.PSO,'LineWidth',2);
hold on;
plot(Curves.GA,'LineWidth',2);
plot(Curves.WCA,'LineWidth',2);

xlabel('Iteration');
ylabel('Best Cost');
title('Convergence Curves Comparison');
legend('PSO','GA','WCA');
grid on;

saveas(gcf,'All_Algorithms_Convergence_Curves.png');

writetable(Results,'Final_Results_Table.xlsx');