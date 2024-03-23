function torqueRecord = init_torqueRecord(tEnd, T)

npts = fix(tEnd/T);

torqueRecord.hipR   = zeros(1, npts);
torqueRecord.kneeR  = zeros(1, npts);
torqueRecord.ankleR = zeros(1, npts);
torqueRecord.exoR   = zeros(1, npts);
torqueRecord.hipL   = zeros(1, npts);
torqueRecord.kneeL  = zeros(1, npts);
torqueRecord.ankleL = zeros(1, npts);
torqueRecord.exoL   = zeros(1, npts);

end