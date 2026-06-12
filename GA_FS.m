function [BestPosition, BestCost, BestCostCurve] = GA_FS(CostFunction,nVar,nPop,MaxIt)

pc = 0.8;
nc = round(pc*nPop/2)*2;

pm = 0.2;
nm = round(pm*nPop);

empty.Position = [];
empty.Cost = [];

pop = repmat(empty,nPop,1);

for i = 1:nPop
    pop(i).Position = rand(1,nVar) > 0.5;
    pop(i).Cost = CostFunction(pop(i).Position);
end

Costs = [pop.Cost];
[~, SortOrder] = sort(Costs);
pop = pop(SortOrder);

BestSol = pop(1);
BestCostCurve = zeros(MaxIt,1);

for it = 1:MaxIt

    popc = repmat(empty,nc/2,2);

    for k = 1:nc/2

        p1 = pop(randi(nPop));
        p2 = pop(randi(nPop));

        cut = randi([1 nVar-1]);

        c1.Position = [p1.Position(1:cut) p2.Position(cut+1:end)];
        c2.Position = [p2.Position(1:cut) p1.Position(cut+1:end)];

        c1.Cost = CostFunction(c1.Position);
        c2.Cost = CostFunction(c2.Position);

        popc(k,1) = c1;
        popc(k,2) = c2;

    end

    popc = popc(:);

    popm = repmat(empty,nm,1);

    for k = 1:nm

        p = pop(randi(nPop));
        m = p;

        j = randi(nVar);
        m.Position(j) = ~m.Position(j);

        m.Cost = CostFunction(m.Position);

        popm(k) = m;

    end

    pop = [pop; popc; popm];

    Costs = [pop.Cost];
    [~, SortOrder] = sort(Costs);
    pop = pop(SortOrder);

    pop = pop(1:nPop);

    if pop(1).Cost < BestSol.Cost
        BestSol = pop(1);
    end

    BestCostCurve(it) = BestSol.Cost;

    fprintf('GA Iteration %d : Best Cost = %.4f\n', it, BestCostCurve(it));

end

BestPosition = BestSol.Position;
BestCost = BestSol.Cost;

end