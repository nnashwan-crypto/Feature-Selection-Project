function [BestPosition, BestCost, BestCostCurve] = ...
         WCA_FS(CostFunction,nVar,nPop,MaxIt)

%% WCA Parameters

Nsr = 4;          % Number of Rivers
C = 2;            % Flow Coefficient
dmax = 1e-6;      % Evaporation Threshold

VarMin = 0;
VarMax = 1;

%% Initialization

empty.Position = [];
empty.Cost = [];

pop = repmat(empty,nPop,1);

for i = 1:nPop

    pop(i).Position = rand(1,nVar);

    pop(i).Cost = CostFunction(pop(i).Position);

end

%% Sort Population

Costs = [pop.Cost];

[Costs, SortOrder] = sort(Costs);

pop = pop(SortOrder);

Sea = pop(1);

Rivers = pop(2:Nsr+1);

Streams = pop(Nsr+2:end);

BestCostCurve = zeros(MaxIt,1);

%% Main Loop

for it = 1:MaxIt

    %% Streams Flow Toward Rivers

    for i = 1:length(Streams)

        riverIndex = randi(length(Rivers));

        Streams(i).Position = ...
            Streams(i).Position ...
            + rand*C.* ...
            (Rivers(riverIndex).Position ...
            - Streams(i).Position);

        Streams(i).Position = ...
            max(Streams(i).Position,VarMin);

        Streams(i).Position = ...
            min(Streams(i).Position,VarMax);

        Streams(i).Cost = ...
            CostFunction(Streams(i).Position);

        if Streams(i).Cost < Rivers(riverIndex).Cost

            temp = Rivers(riverIndex);

            Rivers(riverIndex) = Streams(i);

            Streams(i) = temp;

        end
    end

    %% Rivers Flow Toward Sea

    for i = 1:length(Rivers)

        Rivers(i).Position = ...
            Rivers(i).Position ...
            + rand*C.* ...
            (Sea.Position ...
            - Rivers(i).Position);

        Rivers(i).Position = ...
            max(Rivers(i).Position,VarMin);

        Rivers(i).Position = ...
            min(Rivers(i).Position,VarMax);

        Rivers(i).Cost = ...
            CostFunction(Rivers(i).Position);

        if Rivers(i).Cost < Sea.Cost

            temp = Sea;

            Sea = Rivers(i);

            Rivers(i) = temp;

        end
    end

    %% Evaporation and Rain

    for i = 1:length(Rivers)

        distance = norm(Rivers(i).Position - Sea.Position);

        if distance < dmax

            Rivers(i).Position = rand(1,nVar);

            Rivers(i).Cost = ...
                CostFunction(Rivers(i).Position);

        end

    end

    BestCostCurve(it) = Sea.Cost;

    fprintf('WCA Iteration %d : Best Cost = %f\n', ...
             it, BestCostCurve(it));

end

BestPosition = Sea.Position;
BestCost = Sea.Cost;

end