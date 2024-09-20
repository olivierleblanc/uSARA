function log_im = util_log_im(im, a)
    % generate the logarithified image
    %
    % args:
    %   im: image of interest
    %   a: dynamic range
    % 
    % output:
    %   log_im: logarithmified image
    im_max = max(im, [], 'all');
    log_im = im_max .* log10(a / im_max * im + 1) ./ log10(a);
end
