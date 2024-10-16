load('points.mat','x','y');
figure;hold on;
plot(x,y,'kx');
axis equal


% Adjust N 
N = 88

% Initialize variables to store the best line model and its inliers
best_model = [];
best_inliers = [];
best_num_inliers = 0;

for iteration = 1:N

    %Draw 2 points uniformly at random from set
    random_idx = randi([1, length(x)]);
    x_1 = x(random_idx);
    y_1 = y(random_idx);
    %plot(x_1,y_1,'rx');
    
    random_idx = randi([1, length(x)]);
    x_2 = x(random_idx);
    y_2 = y(random_idx);
    %plot(x_2,y_2,'rx');
    
    % Fit a line between (x_1, y_1) and (x_2, y_2) and plot it in red
    coefficients = polyfit([x_1, x_2], [y_1, y_2], 1);
    fitted_x = linspace(min(x), max(x), 100);
    fitted_y = polyval(coefficients, fitted_x);
    %plot(fitted_x, fitted_y, 'r', 'LineWidth', 0.5);
    
    % Set the distance threshold 't'
    t = 5; % Adjust this threshold as needed
    
    % Calculate the distance from each point to the fitted line
    distances = abs(coefficients(1) * x + (-1) * y + coefficients(2)) / sqrt(coefficients(1)^2 + 1);
    
    % Identify inliers based on the threshold 't'
    inliers = find(distances < t);
    
    % Plot inliers in green ('go')
    %plot(x(inliers), y(inliers), 'gx');

    % Check if the current model has more inliers than the best model
    num_inliers = length(inliers);
    if num_inliers > best_num_inliers
        best_model = coefficients;
        best_inliers = inliers;
        best_num_inliers = num_inliers;
    end


end

% Extract the coordinates of the inliers
inliers_x = x(best_inliers);
inliers_y = y(best_inliers);
x_mean=mean(inliers_x);
y_mean=mean(inliers_y);

% Perform total least squares fitting to all inliers
U = [inliers_x'-x_mean, inliers_y'-y_mean];
%obtain eigenvectors
[~, S, V] = svd(U'*U);
best_params = V(:,end)  % The last column of V contains the solution

% Calculate the refined line using the total least squares fitting
refined_x = linspace(min(inliers_x), max(inliers_x), 100);
refined_d = best_params(1) * x_mean + best_params(2)*y_mean;
refined_y = -best_params(1) * refined_x/best_params(2) + refined_d/best_params(2);

% Plot the original data points
plot(x, y, 'kx');

% Plot the initial line with the most inliers
initial_fitted_x = linspace(min(x), max(x), 100);
initial_fitted_y = polyval(best_model, initial_fitted_x);
plot(initial_fitted_x, initial_fitted_y, 'b', 'LineWidth', 0.5);

% Plot the refined line in blue
plot(refined_x, refined_y, 'r', 'LineWidth', 1);

% Plot the inliers in green ('gx')
plot(inliers_x, inliers_y, 'gx');

title('Original Data Points, Initial Line, Refined Line, and Inliers');
hold off;

disp(['Number of inliers: ', num2str(best_num_inliers)]);
disp(['Initial line model (ax + by + c = 0):']);
disp(['a = ', num2str(best_model(1))]);
disp(['b = ', num2str(-1)]);
disp(['c = ', num2str(best_model(2))]);

disp(['Refined line model (ax + by + c = 0):']);
disp(['a = ', num2str(best_params(1))]);
disp(['b = ', num2str(-1)]);
disp(['c = ', num2str(best_params(2))]);