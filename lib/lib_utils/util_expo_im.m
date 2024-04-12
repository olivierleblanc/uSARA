function expo_im = util_expo_im(im, expo_factor)
    % generate the exponentiated image
    %
    % args:
    %   im: image of interest
    %   expo_factor: exponentiation factor
    % 
    % output:
    %   expo_im: exponentiated image

    expo_im = (expo_factor.^im - 1) / expo_factor;
end