% Function to generate Gaussian and Laplacian pyramids
function pyramid = generateLaplacianPyramid(image, type, levels)
    pyramid = cell(1, levels);
   

    % Initialize pyramid with the original image
    pyramid{1} = image;

    % Binomial filter kernel for downsampling
    g = [1 4 6 4 1] / 16;

    for level = 2:levels
        % Apply a low-pass filter before downsampling
        image = imfilter(image, g, 'replicate');
        
        % Downsample the image
        image = image(1:2:end, 1:2:end, :);


        if strcmp(type, 'lap')
            % Calculate the Laplacian by subtracting the upsampled and filtered image
            upsampled = upsample(image);
            filtered = imfilter(upsampled, 2 * g, 'replicate');
            
            if(size(filtered,1)>size(pyramid{level - 1},1))
                %resize if needed
                filtered=filtered(1:end-1, 1:end-1, :);
            end

            pyramid{level} = pyramid{level - 1} - filtered;
            pyramid{level}=pyramid{level}(1:2:end, 1:2:end, :);
        
        elseif strcmp(type, 'gauss')
            pyramid{level} = image;
        else
            error('Invalid pyramid type. Use ''lap'' or ''gauss''.');
        end
    end
end