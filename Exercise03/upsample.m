% Function to upsample an image by adding zeros between rows and columns
function upsampled = upsample(image)
    [rows, cols, ~] = size(image);
    upsampled = zeros(2 * rows, 2 * cols, size(image, 3));
    upsampled(1:2:end, 1:2:end, :) = image;
end