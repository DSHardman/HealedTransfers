function [net, errorout, depthpercentage] = TrainNetwork(state)
% Train neural network on a given sensor state's data

    inp=state.random.extracted10;
    out=state.random.positions;
    
    % Normalise inputs & choose 4500 random samples for training
    mu=mean(inp);
    sig=std(inp);
    
    P=randperm(length(inp));
    XTrain=(inp(P(1:4500),:)-mu)./sig; % 10 percent used for validation
    YTrain=out(P(1:4500),:);
    YTrain(:,1:2) = YTrain(:,1:2)./34.5; % Normalise responses
    YTrain(:,3) = YTrain(:,3) - 0.5; % Normalise responses
    
    % Final 500 used as normalised validation set
    XVal=(inp(P(4500:end),:)-mu)./sig;
    YVal=out(P(4500:end),:);
    YVal(:,1:2) = YVal(:,1:2)./34.5; % Normalise responses
    YVal(:,3) = YVal(:,3) - 0.5; % Normalise responses
    
    
    % Define network and training options
    layers = [
        featureInputLayer(size(XTrain,2),"Name","featureinput")
        fullyConnectedLayer(20,"Name","fc_1")
         tanhLayer("Name","relu2")
        fullyConnectedLayer(10,"Name","fc_2")
        tanhLayer("Name","reluw")
            fullyConnectedLayer(10,"Name","fc_5")
        reluLayer("Name","relu3e")
        fullyConnectedLayer(3,"Name","fc_6")
        regressionLayer("Name","regressionoutput")];
    
    opts = trainingOptions('adam', ...
        'MaxEpochs',2000, ...
        'MiniBatchSize', 512*7,...
         'ValidationData',{XVal,YVal}, ...
        'ValidationFrequency',30, ...
        'GradientThreshold',1, ...
        'ValidationPatience',10,...
        'InitialLearnRate',0.005*10, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropPeriod',125*10, ...
        'LearnRateDropFactor',0.2/1, ...
        'Verbose',0, ...
        'Plots','none', 'ExecutionEnvironment', 'gpu');
    
    % Training
    [net, ~] = trainNetwork(XTrain,YTrain,layers,opts);
    
    % Calculate errors and plot heatmaps
    [errorout, depthpercentage] = heatscat(net, Original, mu, sig,...
        "InputNumber_" + string(n) + "_" + string(k));
end