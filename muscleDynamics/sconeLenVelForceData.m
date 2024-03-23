function data = sconeLenVelForceData(muscleIdx, type, sconeIdxEnd, normalGait)

fiberLenN{1} = normalGait.vasti_rfiber_length_norm;
fiberLenN{2} = normalGait.hamstrings_rfiber_length_norm;
fiberLenN{3} = normalGait.glut_max_rfiber_length_norm;
fiberLenN{4} = normalGait.iliopsoas_rfiber_length_norm;
fiberLenN{5} = normalGait.gastroc_rfiber_length_norm;
fiberLenN{6} = normalGait.soleus_rfiber_length_norm;
fiberLenN{7} = normalGait.tib_ant_rfiber_length_norm;
fiberLenN{8} = normalGait.vasti_lfiber_length_norm;
fiberLenN{9} = normalGait.hamstrings_lfiber_length_norm;
fiberLenN{10} = normalGait.glut_max_lfiber_length_norm;
fiberLenN{11} = normalGait.iliopsoas_lfiber_length_norm;
fiberLenN{12} = normalGait.gastroc_lfiber_length_norm;
fiberLenN{13} = normalGait.soleus_lfiber_length_norm;
fiberLenN{14} = normalGait.tib_ant_lfiber_length_norm;

fiberForceN{1} = normalGait.vasti_rmtu_force_norm;
fiberForceN{2} = normalGait.hamstrings_rmtu_force_norm;
fiberForceN{3} = normalGait.glut_max_rmtu_force_norm;
fiberForceN{4} = normalGait.iliopsoas_rmtu_force_norm;
fiberForceN{5} = normalGait.gastroc_rmtu_force_norm;
fiberForceN{6} = normalGait.soleus_rmtu_force_norm;
fiberForceN{7} = normalGait.tib_ant_rmtu_force_norm;
fiberForceN{8} = normalGait.vasti_lmtu_force_norm;
fiberForceN{9} = normalGait.hamstrings_lmtu_force_norm;
fiberForceN{10} = normalGait.glut_max_lmtu_force_norm;
fiberForceN{11} = normalGait.iliopsoas_lmtu_force_norm;
fiberForceN{12} = normalGait.gastroc_lmtu_force_norm;
fiberForceN{13} = normalGait.soleus_lmtu_force_norm;
fiberForceN{14} = normalGait.tib_ant_lmtu_force_norm;

fiberVelN{1} = normalGait.vasti_rfiber_velocity_norm;
fiberVelN{2} = normalGait.hamstrings_rfiber_velocity_norm;
fiberVelN{3} = normalGait.glut_max_rfiber_velocity_norm;
fiberVelN{4} = normalGait.iliopsoas_rfiber_velocity_norm;
fiberVelN{5} = normalGait.gastroc_rfiber_velocity_norm;
fiberVelN{6} = normalGait.soleus_rfiber_velocity_norm;
fiberVelN{7} = normalGait.tib_ant_rfiber_velocity_norm;
fiberVelN{8} = normalGait.vasti_lfiber_velocity_norm;
fiberVelN{9} = normalGait.hamstrings_lfiber_velocity_norm;
fiberVelN{10} = normalGait.glut_max_lfiber_velocity_norm;
fiberVelN{11} = normalGait.iliopsoas_lfiber_velocity_norm;
fiberVelN{12} = normalGait.gastroc_lfiber_velocity_norm;
fiberVelN{13} = normalGait.soleus_lfiber_velocity_norm;
fiberVelN{14} = normalGait.tib_ant_lfiber_velocity_norm;

tendonLen{1} = normalGait.vasti_rtendon_length;
tendonLen{2} = normalGait.hamstrings_rtendon_length;
tendonLen{3} = normalGait.glut_max_rtendon_length;
tendonLen{4} = normalGait.iliopsoas_rtendon_length;
tendonLen{5} = normalGait.gastroc_rtendon_length;
tendonLen{6} = normalGait.soleus_rtendon_length;
tendonLen{7} = normalGait.tib_ant_rtendon_length;
tendonLen{8} = normalGait.vasti_ltendon_length;
tendonLen{9} = normalGait.hamstrings_ltendon_length;
tendonLen{10} = normalGait.glut_max_ltendon_length;
tendonLen{11} = normalGait.iliopsoas_ltendon_length;
tendonLen{12} = normalGait.gastroc_ltendon_length;
tendonLen{13} = normalGait.soleus_ltendon_length;
tendonLen{14} = normalGait.tib_ant_ltendon_length;

pennAngle{1} = acos(normalGait.vasti_rcos_pennation_angle);
pennAngle{2} = acos(normalGait.hamstrings_rcos_pennation_angle);
pennAngle{3} = acos(normalGait.glut_max_rcos_pennation_angle);
pennAngle{4} = acos(normalGait.iliopsoas_rcos_pennation_angle);
pennAngle{5} = acos(normalGait.gastroc_rcos_pennation_angle);
pennAngle{6} = acos(normalGait.soleus_rcos_pennation_angle);
pennAngle{7} = acos(normalGait.tib_ant_rcos_pennation_angle);
pennAngle{8} = acos(normalGait.vasti_lcos_pennation_angle);
pennAngle{9} = acos(normalGait.hamstrings_lcos_pennation_angle);
pennAngle{10} = acos(normalGait.glut_max_lcos_pennation_angle);
pennAngle{11} = acos(normalGait.iliopsoas_lcos_pennation_angle);
pennAngle{12} = acos(normalGait.gastroc_lcos_pennation_angle);
pennAngle{13} = acos(normalGait.soleus_lcos_pennation_angle);
pennAngle{14} = acos(normalGait.tib_ant_lcos_pennation_angle);

data = [];
switch type
    case 'fiberLenN'
        data = fiberLenN{muscleIdx};
    case 'fiberForceN'
        data = fiberForceN{muscleIdx};
    case 'fiberVelN'
        data = fiberVelN{muscleIdx};
    case 'tendonLen'
        data = tendonLen{muscleIdx};
    case 'pennAngle'
        data = pennAngle{muscleIdx};
    otherwise
        error('Should select a type of data');
end
data = data(1 : sconeIdxEnd);

end