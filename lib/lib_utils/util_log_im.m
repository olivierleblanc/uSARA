function log_im = util_log_im(im, a)
    im_max = max(im, [], 'all');
    log_im = im_max .* log10(a / im_max * im + 1) ./ log10(a);
end
