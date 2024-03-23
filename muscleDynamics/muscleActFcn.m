%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 功能：计算一个仿真步长内（当前时刻）肌肉激活度随时间的变化
% 参数：
% - t: 时刻
% - simT: 仿真步长
% - muscleIdx: 肌肉编号
% - excitation: 肌肉兴奋
% - record: 整个仿真时程的肌肉动力学数据
% - initMuscleArch: 0时刻肌肉结构体数据
% 返回：
% - muscleAct: 肌肉激活度
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function muscleAct = muscleActFcn(t, simT, muscleIdx, excitation, record, initMuscleArch)

loopNum                     = record(muscleIdx).loopNum;
h                           = simT;
excitation_                 = excitation;
excitation_(excitation_<0)  = 0;
if mod(t, h) == 0 % tspan(1) = tspan(2)
    tspan                   = [floor(t/h)*h-h floor(t/h)*h];
else
    tspan                   = [fix(t/h)*h t];
end

if record(muscleIdx).loopNum == 0 % 0~0.005s，则使用SCONE中的初始值
    muscleAct = initMuscleArch.a(muscleIdx);
    
else % 非0时刻，根据肌肉兴奋（在0.005s内为恒值）计算肌肉激活
    muscleAct = record(muscleIdx).activationState(loopNum);
    if tspan(1) < tspan(2)
%         [~, act]  = ode15s(@(t,act)calcFirstOrderActivationDerivative(t,excitation_,act), tspan, muscleAct);
        h       = 0.0005;
        tV      = tspan(1) : h : tspan(2);
        act     = zeros(1, length(tV));
        act(1)  = muscleAct; % initial value
        for xe = 1 : length(tV)-1
            t1 = tV(xe);
            k1 = calcFirstOrderActivationDerivative(t1, excitation_, act(xe));
            k2 = calcFirstOrderActivationDerivative(t1+h/2, excitation_, act(xe)+h/2*k1); % dfcn(t1,[ye(xe,1)+h/2;ye(xe,2);ye(xe,3);ye(xe,4)]+h/2*k1);
            k3 = calcFirstOrderActivationDerivative(t1+h/2, excitation_, act(xe)+h/2*k2); % dfcn(t1,[ye(xe,1)+h/2;ye(xe,2);ye(xe,3);ye(xe,4)]+h/2*k2);
            k4 = calcFirstOrderActivationDerivative(t1+h, excitation_, act(xe)+h/2*k3); % dfcn(t1,[ye(xe,1);ye(xe,2);ye(xe,3);ye(xe,4)]+h*k3);
            act(xe+1) = act(xe) + h/6*(k1+2*k2+2*k3+k4);
        end
        muscleAct = act(end);
    end
    
end