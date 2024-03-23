%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Name: init_CMAES
% Function: initialize the CMA-ES (Evolution Strategy with Covariance 
% Matrix Adaption for nonlinear function minimization) optimization
% algorithm configuration.
% Parameter(s): 
%   - para: initial value of the parameters for CMA-ES optimization.
%   - paraNum: number of the paramters.
%   - sigma: 
%   - stage: using which type of fitness function, corresponding to
%   different optimization stages
% Output(s):
%   - optConfig: a structure ready for optimization.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function optConfig = init_CMAES(para, paraNum, sigma, stage)

% initial points
noise = 0.05;
xmean = [para.tib.KL; para.tib.L0; para.tib_sol.KF; para.sol.KF; para.gas.KF;...
    para.ili_pelvis_tilt.KP; para.ili_pelvis_tilt.KV; para.ili_pelvis_tilt.C0; ...
    para.ili.C0; para.ili.KL; para.ili.L0; para.ili_pelvis_tilt.P02; ...
    para.ili_pelvis_tilt.KP2; para.ili_pelvis_tilt.KV2; para.ili_ham.KL; ...
    para.ili_ham.L0; para.ham_pelvis_tilt.KP; para.ham_pelvis_tilt.KV; ...
    para.ham_pelvis_tilt.C0; para.ham_glu.KF; para.glu_pelvis_tilt.KP; ...
    para.glu_pelvis_tilt.KV; para.glu_pelvis_tilt.C0; para.glu.KF; ...
    para.vas.KF1; para.vas.KF2; para.vas.C0; para.vas_knee.pos_max; ...
    para.peakForce];

% selection of points
lambda = 4 + floor(3*log(paraNum)); % population size [=14 for 29 pars; =13 for 28 pars]
mu = lambda / 2; 
weights = log(mu+1 / 2) - log(1:mu)'; % muXone recombination weights
mu = floor(mu); % number of parents/points for recombination
weights = weights / sum(weights); % normalize recombination weights array
mueff = sum(weights)^2 / sum(weights.^2); % variance-effective size of mu

% adaptation
cc = (4 + mueff/paraNum) / (paraNum + 4 + 2*mueff/paraNum); % time constant for cumulation for C
cs = (mueff+2) / (paraNum+mueff+5); % t-const for cumulation for sigma control
c1 = 2 / ((paraNum+1.3)^2 + mueff); % learning rate for rank-one update of C
cmu = 2 * (mueff - 2 + 1/mueff) / ((paraNum+2)^2 + 2*mueff/2); % and for rank-mu update
damps = 1 + 2 * max(0, sqrt((mueff-1)/(paraNum+1))-1) + cs; % damping for sigma

% Initialize dynamic (internal) strategy parameters and constants
pc = zeros(paraNum,1); ps = zeros(paraNum,1); % evolution paths for C and sigma
B = eye(paraNum); % B defines the coordinate system
D = eye(paraNum); % diagonal matrix D defines the scaling
C = B * D * (B*D)'; % covariance matrix
chiN = paraNum^0.5*(1-1/(4*paraNum)+1/(21*paraNum^2)); % expectation of

Opt_Record = [];

% assign
optConfig.cc        = cc;
optConfig.cs        = cs;
optConfig.c1        = c1;
optConfig.cmu       = cmu;
optConfig.mu        = mu;
optConfig.mueff     = mueff;
optConfig.lambda    = lambda;
optConfig.damps     = damps;
optConfig.pc        = pc;
optConfig.B         = B;
optConfig.D         = D;
optConfig.C         = C;
optConfig.chiN      = chiN;
optConfig.Record    = Opt_Record;
optConfig.noise     = noise;
optConfig.sigma     = sigma;
optConfig.xmean     = xmean;
optConfig.pc        = pc;
optConfig.ps        = ps;
optConfig.weights   = weights;
optConfig.stage     = stage;

end