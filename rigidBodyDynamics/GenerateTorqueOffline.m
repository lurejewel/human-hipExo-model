function TorqueVector = GenerateTorqueOffline(startTime, peakTime, endTime, peakTorque)
% 先假设轨迹已知，步态周期可以直接求出。
% 后面再改进为步态周期未知，需要用脚跟触地事件 + 过往步态周期估计当前步态的情况。

% 确定步态，以右脚跟着地为准
gaitStart = [0.507 1.622 2.749 3.884 5.024 6.1714 7.3023 8.4619 9.5953]; % 手动记录的无外骨骼助力时的HeelStrike，因为实验数据里好像没有明显的HeelStrike
gaitCycle = diff(gaitStart); % 步态周期，共八步

% 三次插值法拟合助力曲线：
% Torque = a1 * t^3 + b1 * t^2 + c1 * t + d1, startTime <= t <= peakTime;
%          a2 * t^3 + b2 * t^2 + c2 * t + d2, peakTime < t <= endTime
a1 = 2 * peakTorque / (startTime^3 - peakTime^3 + 3*startTime*peakTime*(peakTime-startTime));
b1 = -3 * a1 * (startTime + peakTime) / 2;
c1 = 3 * a1 * startTime * peakTime;
d1 = -a1 * startTime^3 - b1 * startTime^2 - c1 * startTime;
a2 = 2 * peakTorque / (peakTime^3 - endTime^3 - 3*peakTime*endTime*(peakTime-endTime));
b2 = -3 * a2 * (endTime + peakTime) / 2;
c2 = 3 * a2 * endTime * peakTime;
d2 = -a2 * endTime^3 - b2 * endTime^2 - c2 * endTime;


% % 助力曲线图
% T = zeros(100*100,1);
% j = 1;
% for i = 0 : 0.01 : 100
%     if i < startTime 
%         T(j) = 0;
%     elseif i < peakTime
%         T(j) = a1 * i^3 + b1 * i^2 + c1 * i + d1;
%     elseif i < endTime
%         T(j) = - (a2 * i^3 + b2 * i^2 + c2 * i + d2);
%     else
%         T(j) = 0;
%     end
%     j = j + 1;
% end
% figure, plot(0:0.01:100, T, 'LineWidth', 2, 'Color', [0.2 0.2 0.2]);


% 生成全部时程（10秒）的助力值
gaitStep = 0; % 记录当前是第几步
TorqueVector = zeros(10000,1);
iter = 1;
for t = 0 : 0.001 : 10
    if gaitStep < 9 && t >= gaitStart(gaitStep+1) % 切换到下一步
        gaitStep = gaitStep + 1;
        TorqueVector(iter) = 0;
        iter = iter + 1;
        continue;
    end
    if gaitStep == 0 || gaitStep >= 9 % 第一步之前不产生助力，最后一步后不助力
        TorqueVector(iter) = 0;
        iter = iter + 1;
        continue;
    end
    gaitPercent = 100*(t - gaitStart(gaitStep))/gaitCycle(gaitStep); % 当前时刻占步态周期百分比
    if gaitPercent < startTime
        TorqueVector(iter) = 0;
    elseif gaitPercent < peakTime
        TorqueVector(iter) = a1 * gaitPercent^3 + b1 * gaitPercent^2 + c1 * gaitPercent + d1;
    elseif gaitPercent < endTime
        TorqueVector(iter) = -(a2 * gaitPercent^3 + b2 * gaitPercent^2 + c2 * gaitPercent + d2);
    end
    iter = iter + 1;
end
% figure, plot(0:0.001:10,TorqueVector);
end