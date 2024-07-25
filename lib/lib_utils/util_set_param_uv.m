function param_uv = util_set_param_uv(path_uv_data)
    
    % [u, v, w, na] = generate_uv_coverage(frequency, nTimeSamples, obsTime, telescope, use_ROP);
    %%% TODO %%%
    load(path_uv_data, 'u_ab', 'v_ab', 'w_ab', 'na');

    param_uv = struct();
    param_uv.u = u_ab;
    param_uv.v = v_ab;
    param_uv.w = w_ab;
    % switch param_general.ROP_type
    %     case 'none'
    %         na = 27;
    %     case 'modul'
    %         na = 54;
    % end
    na = 27;
    param_uv.na = na;
    param_uv.nTimeSamples = size(u_ab, 1);
end