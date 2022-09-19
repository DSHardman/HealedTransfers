function [errorout, depthpercentage] = heatscat(net, state, mu, sig, savename)
% Plot heatmaps of error

    x = state.random.positions(:,1);
    y = state.random.positions(:,2);

    ypred = predict(net, (state.random.extracted10-mu)./sig);
    ypred(:,1:2) = 34.5*ypred(:,1:2);
    ypred(:,3) = ypred(:,3) + 0.5;
    z=rssq((ypred(:,1:2)-state.random.positions(:,1:2))');
    depthpercentage = round((ypred(:,3)-state.random.positions(:,3))*2)/2;
    depthpercentage = 100*length(find(depthpercentage==0))/state.random.n;
    
    if nargin == 5
        fid = fopen('InputNumber.txt', 'a+');
        fprintf(fid, savename + ": %.2f, %.2f\n", mean(z), depthpercentage);
        fclose(fid);
    else
        mean(z)
        depthpercentage
    end
    
    errorout = mean(z);
   
    z = min(z, 48.8); % error cannot exceed corner-to-corner square size
    
    % use interpolated contour maps
    interpolant = scatteredInterpolant(x,y,double(z).');
    [xx,yy] = meshgrid(linspace(0,34.5,100));
    error_interp = interpolant(xx,yy);
    contourf(xx,yy,error_interp, 'LineColor', 'none');
    
    axis('equal')
    colormap('hot')
    caxis([0 30])
    set(gca, 'Visible', 'off');
    if nargin==5
        exportgraphics(gcf, strcat('Images/',savename,'.png'));
    end
end