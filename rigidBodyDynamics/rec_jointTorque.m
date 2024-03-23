function torqueRecord = rec_jointTorque(i, jointTorque, exoTorque, torqueRecord)

assert(i > 0, 'loop number should be positive.');

torqueRecord.hipR(i) = jointTorque.hipR;
torqueRecord.kneeR(i) = jointTorque.kneeR;
torqueRecord.ankleR(i) = jointTorque.ankleR;
torqueRecord.exoR(i) = exoTorque.exoR;
torqueRecord.hipL(i) = jointTorque.hipL;
torqueRecord.kneeL(i) = jointTorque.kneeL;
torqueRecord.ankleL(i) = jointTorque.ankleL;
torqueRecord.exoL(i) = exoTorque.exoL;

end