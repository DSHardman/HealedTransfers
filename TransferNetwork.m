function [errorout, depthpercentage] = TransferNetwork(net, newstate, pts, frozen, method, damagedsensor, mu, sig, savename)
    % transfer learning: copy network but zero first few layer learning rates
    layers=net.Layers;
    layers(1:frozen) = freezeWeights(layers(1:frozen));

    % new inputs, outputs, normalised training/validation sets for healed
    inp=newstate.random.extracted10;
    out=newstate.random.positions;

    % Sampling method: random, grid, or weighted
    if method == "random" % locations are randomly sampled
        P=randperm(length(inp));
        XTrain=(inp(P(1:round(0.9*pts)),:)-mu)./sig; % 10 percent used for validation
        YTrain=out(P(1:round(0.9*pts)),:);

        XVal=(inp(P(round(0.9*pts)+1:pts),:)-mu)./sig;
        YVal=out(P(round(0.9*pts)+1:pts),:);
    elseif method == "grid" % locations are arranged in a grid
        side = floor(sqrt(pts));
        locations = 0:34.5/((side-1)):34.5;
        x = zeros(side^2, 1);
        y = zeros(side^2, 1);
        for i = 1:side
            for j = 1:side
                x((i-1)*side+j) = locations(j);
                y((j-1)*side+i) = locations(j);
            end
        end
        
        indices = newstate.findclosest(x, y);
        P = indices(randperm(length(indices)));
        XTrain=(inp(P(1:round(0.9*length(P))),:)-mu)./sig;
        YTrain=out(P(1:round(0.9*length(P))),:);
        
        XVal=(inp(P(round(0.9*length(P))+1:length(P)),:)-mu)./sig;
        YVal=out(P(round(0.9*length(P))+1:length(P)),:);
    elseif method == "weighted" % locations are weighted in 1D with a Gaussian
        if damagedsensor <= 4
            truncated = truncate(makedist('Normal',(4-damagedsensor)*11.5,15),0,34.5);
            x = random(truncated,pts,1);
            y = 34.5*rand(pts, 1);
        else
            truncated = truncate(makedist('Normal',(8-damagedsensor)*11.5,15),0,34.5);
            y = random(truncated,pts,1);
            x = 34.5*rand(pts, 1);
        end
        
        indices = newstate.findclosest(x, y);
        P = indices(randperm(length(indices)));
        XTrain=(inp(P(1:round(0.9*length(P))),:)-mu)./sig;
        YTrain=out(P(1:round(0.9*length(P))),:);
        
        XVal=(inp(P(round(0.9*length(P))+1:length(P)),:)-mu)./sig;
        YVal=out(P(round(0.9*length(P))+1:length(P)),:);
    elseif method == "2d"
        samples = zeros(pts, 2);
        num = 0;
        while num < pts
            sample = mvnrnd(damagedsensor, [20 20], 1);
            if sample(1) <= 34.5 && sample(1) >= 0
                if sample(2) <= 34.5 && sample(2) >= 0
                    num = num + 1;
                    samples(num, :) = sample;
                end
            end
        end
        
        indices = newstate.findclosest(samples(:,1), samples(:,2));
        P = indices(randperm(length(indices)));
        XTrain=(inp(P(1:round(0.9*length(P))),:)-mu)./sig;
        YTrain=out(P(1:round(0.9*length(P))),:);
        
        XVal=(inp(P(round(0.9*length(P))+1:length(P)),:)-mu)./sig;
        YVal=out(P(round(0.9*length(P))+1:length(P)),:);
    elseif method == "weightedinvert"
        options = 0:0.05:34.5;
        weights = zeros(691,1);
        if damagedsensor <= 4
            for i = 1:691
                weights(i) = 1 - exp(-(((options(i)-(4-damagedsensor)*11.5)/15)^2)/2);
            end
            inds = randsample(691,pts,true,weights);
            x = options(inds);
            y = 34.5*rand(pts, 1);
        else
            for i = 1:691
                weights(i) = 1 - exp(-(((options(i)-(8-damagedsensor)*11.5)/15)^2)/2);
            end
            inds = randsample(691,pts,true,weights);
            y = options(inds);
            x = 34.5*rand(pts, 1);
        end
            
        indices = newstate.findclosest(x, y);
        P = indices(randperm(length(indices)));
        XTrain=(inp(P(1:round(0.9*length(P))),:)-mu)./sig;
        YTrain=out(P(1:round(0.9*length(P))),:);
        
        XVal=(inp(P(round(0.9*length(P))+1:length(P)),:)-mu)./sig;
        YVal=out(P(round(0.9*length(P))+1:length(P)),:);
    else
        error('Invalid Sampling Method');
    end

    YTrain(:,1:2) = YTrain(:,1:2)./34.5; % normalise responses
    YTrain(:,3) = YTrain(:,3) - 0.5; % normalise responses
    YVal(:,1:2) = YVal(:,1:2)./34.5; % normalise responses
    YVal(:,3) = YVal(:,3) - 0.5; % normalise responses

    % Transfer Training
    opts = trainingOptions('adam', ...
        'MaxEpochs',2000, ... % number of training iterations.
        'MiniBatchSize', 512*7,... %%%512
        'ValidationData',{XVal,YVal}, ...
        'GradientThreshold',10, ...
        'ValidationFrequency',30, ...
        'ValidationPatience',10,...
        'InitialLearnRate',0.005*10, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropPeriod',125*10, ...%%changed
        'LearnRateDropFactor',0.2/1, ...%%
        'Verbose',0, ...
        'Plots','none', 'ExecutionEnvironment', 'gpu');

    [net2,~] = trainNetwork(XTrain,YTrain,layers,opts);

    % Calcute and plot 3D error
    figure();
    if nargin == 9 % save if input savename is given
        [errorout, depthpercentage] = heatscat(net2, newstate, mu, sig, savename);
        close();
    else
        [errorout, depthpercentage] = heatscat(net2, newstate, mu, sig);
    end
end