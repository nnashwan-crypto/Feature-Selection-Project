function [GlobalBestPosition, GlobalBestCost, Curve] = PSO_FS(CostFunction, nVar, nPop, MaxIt)

w = 0.5;
c1 = 1.5;
c2 = 2.0;

GlobalBestCost = inf;
GlobalBestPosition = zeros(1,nVar);

empty.Position = [];
empty.Velocity = [];
empty.Cost = [];
empty.Best.Position = [];
empty.Best.Cost = [];

particle = repmat(empty,nPop,1);

for i = 1:nPop

    particle(i).Position = rand(1,nVar) > 0.5;
    particle(i).Velocity = zeros(1,nVar);

    particle(i).Cost = CostFunction(particle(i).Position);

    particle(i).Best.Position = particle(i).Position;
    particle(i).Best.Cost = particle(i).Cost;

    if particle(i).Cost < GlobalBestCost
        GlobalBestCost = particle(i).Cost;
        GlobalBestPosition = particle(i).Position;
    end

end

Curve = zeros(MaxIt,1);

for it = 1:MaxIt

    for i = 1:nPop

        particle(i).Velocity = ...
            w * particle(i).Velocity ...
            + c1 * rand(1,nVar) .* (particle(i).Best.Position - particle(i).Position) ...
            + c2 * rand(1,nVar) .* (GlobalBestPosition - particle(i).Position);

        S = 1 ./ (1 + exp(-particle(i).Velocity));

        particle(i).Position = rand(1,nVar) < S;

        particle(i).Cost = CostFunction(particle(i).Position);

        if particle(i).Cost < particle(i).Best.Cost
            particle(i).Best.Cost = particle(i).Cost;
            particle(i).Best.Position = particle(i).Position;
        end

        if particle(i).Cost < GlobalBestCost
            GlobalBestCost = particle(i).Cost;
            GlobalBestPosition = particle(i).Position;
        end

    end

    Curve(it) = GlobalBestCost;
    fprintf('Iteration %d: Best Cost = %.4f\n', it, GlobalBestCost);

end

end