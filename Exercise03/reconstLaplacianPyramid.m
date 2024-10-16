
% Function to reconstruct an image from its Laplacian pyramid
function reconstructed = reconstLaplacianPyramid(pyramid)
    levels = length(pyramid);
    
    % Initialize the reconstructed image with the top-level Laplacian image
    reconstructed = pyramid{levels};
    
    % Binomial filter kernel for upsampling
    g = [1 4 6 4 1] / 16;
    
    for level = levels-1:-1:1
        % Upsample the reconstructed image
        upsampled = upsample(reconstructed);
        
        % Filter the upsampled image
        filtered = imfilter(upsampled, 2 * g', 'replicate');
        
        if(size(filtered,1)>size(pyramid{level},1))
            %resize if needed
            filtered=filtered(1:end-1, 1:end-1, :);
        end

        % Add the current level of the Laplacian pyramid
        reconstructed = pyramid{level} + filtered;
    end
end

