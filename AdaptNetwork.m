function adaptedmetric = AdaptNetwork(net, newstate)
% Transfer learning one data-point at a time
% For plots in Figs 5 & 6 - returns mean localization error every time

    adaptednet = net;
    adaptedmetric = zeros(5001,1);
    
    % Make predictions in new state before any transfer
    errors = zeros(5000,1);
    pred = adaptednet(newstate.random.extracted3.');
    for j = 1:5000
        errors(j) = sqrt((pred(1,j)-newstate.random.positions(j,1))^2 + ...
            (pred(2,j)-newstate.random.positions(j,2))^2);
    end
    adaptedmetric(1) = mean(errors);
    
    % Randomise order of new state data for transfer
    randomorder = randsample(5000,5000);
    for i = 1:5000
        % Adapt network one random sample at a time
        adaptednet = adapt(net, newstate.random.extracted3(randomorder(1:i),:).',...
            newstate.random.positions(randomorder(1:i),:).');
        
        % Calculate error metric for adapted network
        errors = zeros(5000,1);
        pred = adaptednet(newstate.random.extracted3.');
        for j = 1:5000
            errors(j) = sqrt((pred(1,j)-newstate.random.positions(j,1))^2 + ...
                (pred(2,j)-newstate.random.positions(j,2))^2);
        end
        adaptedmetric(i+1) = mean(errors);

        % Show progress in command window
        if rem(i,100) == 0
            i
        end
    end
end

