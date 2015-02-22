function [ features, thresholds, polarities, alphas ] = boost( Z, t )
%boost Implements the boost algorithm from class.
    
%     % Augment for the threshold descion stump, but don't split on
%     % the class flag (will give perfect descrimination obviously)
%     AugTrain1 = augment(Train1);
%     AugTrain2 = augment(Train2);
%     % Set class flag without modifying data
%     AugTrain2(:, 1) = -AugTrain2(:, 1);
%     Z = [AugTrain1; AugTrain2];
    
    % Possible polarities
    ps = [-1, 1];
    
    % Preallocate the output vectors
    features = ones(t, 1);
    thresholds = ones(t, 1);
    polarities = ones(t, 1);
    alphas = ones(t, 1);
    
    % Give even weight to all examples
    D = ones(size(Z,1),1);
    D = D./(size(Z,1));
    % Loop t times
    for i = 1:t
        % Find the best weak classifier
        % Iterate through features
        best_feat = 0;
        best_thresh = 0;
        best_polar = 0;
        best_err = 1.1; % Impossibly high, will be replaced immediately
        for j = 2:size(Z,2) % Iterate through features
            % Try to make descision stump for each feature (column)
            uniVals = unique(Z(:,j)); % Also sorted
            % Thresholds at averages between pairs of unique values
            for k = 1:(size(uniVals,1)-1) % Iterate through pairs of vaules
               thresh = (uniVals(k)+uniVals(k+1))/2;
               % Evaluate errors for both polarities
               for p = ps % Iterate polarities
                  % Test the classifier, check error
                  h = sign(p*(thresh-Z(:,j)));
                  misClass = Z(:,1)~=h; % True when they disagree
                  err = sum(misClass.*D); % / size(Z,1);
                  % Update tracking of which feature is best
                  if (err < best_err)
                     best_feat = j;
                     best_thresh = thresh;
                     best_polar = p;
                     best_err = err;
                  end
               end
            end
        end
        % Calculate alpha
        alphas(i,1) = 0.5*log((1-best_err)/best_err);
        % Output results
        features(i,1) = best_feat;
        thresholds(i,1) = best_thresh;
        polarities(i,1) = best_polar;
        % Update weights
        h = sign(best_polar*(best_thresh-Z(:,best_feat)));
        D = D.*exp(-alphas(i,1)*Z(:,1).*h);
        D = D./sum(D);
    % end loop
    end
    % Shift features list over one (the 1st entry is the class in my
    % augmented matrix, but that isn't a feature obviously).
    features = features-1;
end

