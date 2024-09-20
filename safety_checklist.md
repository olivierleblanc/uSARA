Here is a list of conditions important to check before running test benchs:

- [ ] The groundtruth image choice and resolution.
- [ ] Verify that the original groundtruth is exponentiated using the ``expo_factor`` parameter but is shown in log-scale using the ``targetDynamicRange`` parameter.
- [ ] The parameter choice in general: param_uv, param_ROP, param_weighting.
- [ ] How the noise std $\tau$ is chosen. 
- [ ] Visualize the ``PSF`` and ``dirty image``.
- [ ] Check that the noise is correctly applied on the final data (and not intermediate visibilities eventually).
- [ ] Adjoint test of the total forward imaging operator $\boldsymbol\Phi$. The relative distance between $\langle \boldsymbol{y}, \boldsymbol{\Phi x} \rangle$ and $\langle \boldsymbol{\Phi}^*\boldsymbol{y}, \boldsymbol{x} \rangle$ should equal or above $10^{-2}$. 
- [ ] Intermediate data dimensions: $Q^2B$, $N_{\mathrm p} B$, $N_{\mathrm p} N_{\mathrm m}$.