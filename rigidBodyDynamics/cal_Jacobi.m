function [Jxb, Jy, Jgrf, dJxb] = cal_Jacobi(in)

pq      = in(3);        dpq     = in(14);
hipR    = in(4);        dhipR   = in(15);
kneeR   = in(5);        dkneeR  = in(16);
ankleR  = in(6);        dankleR = in(17);
exoR    = in(7);        dexoR   = in(18);
hipL    = in(8);        dhipL   = in(19);
kneeL   = in(9);        dkneeL  = in(20);
ankleL  = in(10);       dankleL = in(21);
exoL    = in(11);       dexoL   = in(22);

qhR     = pq + hipR;                        dqhR    = dpq + dhipR;
qhkR    = pq + hipR + kneeR;                dqhkR   = dpq + dhipR + dkneeR;
qhkaR   = pq + hipR + kneeR + ankleR;       dqhkaR  = dpq + dhipR + dkneeR + dankleR;
qhL     = pq + hipL;                        dqhL    = dpq + dhipL;
qhkL    = pq + hipL + kneeL;                dqhkL   = dpq + dhipL + dkneeL;
qhkaL   = pq + hipL + kneeL + ankleL;       dqhkaL  = dpq + dhipL + dkneeL + dankleL;
qheR    = pq + hipR + exoR;                 dqheR   = dpq + dhipR + dexoR;
qheL    = pq + hipL + exoL;                 dqheL   = dpq + dhipL + dexoL;


Jxb = [1, 0, -0.0215*cos(pq)+0.0707*sin(pq), 0, 0, 0, 0, 0, 0, 0, 0;
    1, 0, -0.4015*cos(pq)+0.1379*sin(pq), 0, 0, 0, 0, 0, 0, 0, 0;
    1, 0, 0.0661*cos(pq)+0.17*cos(qhR)+0.0707*sin(pq), 0.17*cos(qhR), 0, 0, 0, 0, 0, 0, 0;
    1, 0, 0.0661*cos(pq)+0.396*cos(qhR)+0.1867*cos(qhkR)+0.0707*sin(pq), 0.396*cos(qhR)+0.1867*cos(qhkR), 0.1867*cos(qhkR), 0, 0, 0, 0, 0, 0;
    1, 0, 0.0661*cos(pq)+0.396*cos(qhR)+0.43*cos(qhkR)+0.0195*cos(qhkaR)+0.0707*sin(pq)-0.05123*sin(qhkaR), 0.396*cos(qhR)+0.43*cos(qhkR)+0.0195*cos(qhkaR)-0.05123*sin(qhkaR), 0.43*cos(qhkR)+0.0195*cos(qhkaR)-0.05123*sin(qhkaR), 0.0195*cos(qhkaR)-0.05123*sin(qhkaR), 0, 0, 0, 0, 0;
    1, 0, 0.0661*cos(pq)+0.1818*cos(qheR)+0.0707*sin(pq)+0.0294*sin(qheR), 0.1818*cos(qheR)+0.0294*sin(qheR), 0, 0, 0.1818*cos(qheR)+0.0294*sin(qheR), 0, 0, 0, 0;
    1, 0, 0.0661*cos(pq)+0.17*cos(qhL)+0.0707*sin(pq), 0, 0, 0, 0, 0.17*cos(qhL), 0, 0, 0;
    1, 0, 0.0661*cos(pq)+0.396*cos(qhL)+0.1867*cos(qhkL)+0.0707*sin(pq), 0, 0, 0, 0, 0.396*cos(qhL)+0.1867*cos(qhkL), 0.1867*cos(qhkL), 0, 0;
    1, 0, 0.0661*cos(pq)+0.396*cos(qhL)+0.43*cos(qhkL)+0.0195*cos(qhkaL)+0.0707*sin(pq)-0.05123*sin(qhkaL), 0, 0, 0, 0, 0.396*cos(qhL)+0.43*cos(qhkL)+0.0195*cos(qhkaL)-0.05123*sin(qhkaL), 0.43*cos(qhkL)+0.0195*cos(qhkaL)-0.05123*sin(qhkaL), 0.0195*cos(qhkaL)-0.05123*sin(qhkaL), 0;
    1, 0, 0.0661*cos(pq)+0.1818*cos(qheL)+0.0707*sin(pq)+0.0294*sin(qheL), 0, 0, 0, 0, 0.1818*cos(qheL)+0.0294*sin(qheL), 0, 0, 0.1818*cos(qheL)+0.0294*sin(qheL);
    0, 1, -0.0707*cos(pq)-0.0215*sin(pq), 0, 0, 0, 0, 0, 0, 0, 0;
    0, 1, -0.1307*cos(pq)-0.3943*sin(pq), 0, 0, 0, 0, 0, 0, 0, 0;
    0, 1, -0.0707*cos(pq)+0.0661*sin(pq)+0.17*sin(qhR), 0.17*sin(qhR), 0, 0, 0, 0, 0, 0, 0;
    0, 1, -0.0707*cos(pq)+0.0661*sin(pq)+0.396*sin(qhR)+0.1867*sin(qhkR), 0.396*sin(qhR)+0.1867*sin(qhkR), 0.1867*sin(qhkR), 0, 0, 0, 0, 0, 0;
    0, 1, -0.0707*cos(pq)+0.05123*cos(qhkaR)+0.0661*sin(pq)+0.396*sin(qhR)+0.43*sin(qhkR)+0.0195*sin(qhkaR), 0.05123*cos(qhkaR)+0.396*sin(qhR)+0.43*sin(qhkR)+0.0195*sin(qhkaR), 0.05123*cos(qhkaR)+0.43*sin(qhkR)+0.0195*sin(qhkaR), 0.05123*cos(qhkaR)+0.0195*sin(qhkaR), 0, 0, 0, 0, 0;
    0, 1, -0.0707*cos(pq)-0.0294*cos(qheR)+0.0661*sin(pq)+0.1818*sin(qheR), -0.0294*cos(qheR)+0.1818*sin(qheR), 0, 0, -0.0294*cos(qheR)+0.1818*sin(qheR), 0, 0, 0, 0;
    0, 1, -0.0707*cos(pq)+0.0661*sin(pq)+0.17*sin(qhL), 0, 0, 0, 0, 0.17*sin(qhL), 0, 0, 0;
    0, 1, -0.0707*cos(pq)+0.0661*sin(pq)+0.396*sin(qhL)+0.1867*sin(qhkL), 0, 0, 0, 0, 0.396*sin(qhL)+0.1867*sin(qhkL), 0.1867*sin(qhkL), 0, 0;
    0, 1, -0.0707*cos(pq)+0.05123*cos(qhkaL)+0.0661*sin(pq)+0.396*sin(qhL)+0.43*sin(qhkL)+0.0195*sin(qhkaL), 0, 0, 0, 0, 0.05123*cos(qhkaL)+0.396*sin(qhL)+0.43*sin(qhkL)+0.0195*sin(qhkaL), 0.05123*cos(qhkaL)+0.43*sin(qhkL)+0.0195*sin(qhkaL), 0.05123*cos(qhkaL)+0.0195*sin(qhkaL), 0;
    0, 1, -0.0707*cos(pq)-0.0294*cos(qheL)+0.0661*sin(pq)+0.1818*sin(qheL), 0, 0, 0, 0, -0.0294*cos(qheL)+0.1818*sin(qheL), 0, 0, -0.0294*cos(qheL)+0.1818*sin(qheL)
    ];

dJxb = [0, 0, 0.0707*cos(pq)*dpq+0.0215*sin(pq)*dpq, 0, 0, 0, 0, 0, 0, 0, 0;
    0, 0, 0.1379*cos(pq)*dpq+0.4015*sin(pq)*dpq, 0, 0, 0, 0, 0, 0, 0, 0;
    0, 0, 0.0707*cos(pq)*dpq-0.0661*sin(pq)*dpq-0.17*sin(qhR)*dqhR, -0.17*sin(qhR)*dqhR, 0, 0, 0, 0, 0, 0, 0;
    0, 0, 0.0707*cos(pq)*dpq-0.0661*sin(pq)*dpq-0.396*sin(qhR)*dqhR-0.1867*sin(qhkR)*dqhkR, -0.396*sin(qhR)*dqhR-0.1867*sin(qhkR)*dqhkR, -0.1867*sin(qhkR)*dqhkR, 0, 0, 0, 0, 0, 0;
    0, 0, 0.0707*cos(pq)*dpq-0.0661*sin(pq)*dpq-0.396*sin(qhR)*dqhR-0.43*sin(qhkR)*dqhkR-0.05123*cos(qhkaR)*dqhkaR-0.0195*sin(qhkaR)*dqhkaR, -0.396*sin(qhR)*dqhR-0.43*sin(qhkR)*dqhkR-0.05123*cos(qhkaR)*dqhkaR-0.0195*sin(qhkaR)*dqhkaR, -0.43*sin(qhkR)*dqhkR-0.05123*cos(qhkaR)*dqhkaR-0.0195*sin(qhkaR)*dqhkaR, -0.05123*cos(qhkaR)*dqhkaR-0.0195*sin(qhkaR)*dqhkaR, 0, 0, 0, 0, 0;
    0, 0, 0.0707*cos(pq)*dpq-0.0661*sin(pq)*dpq+0.0294*cos(qheR)*dqheR-0.1818*sin(qheR)*dqheR, 0.0294*cos(qheR)*dqheR-0.1818*sin(qheR)*dqheR, 0, 0, 0.0294*cos(qheR)*dqheR-0.1818*sin(qheR)*dqheR, 0, 0, 0, 0; % 
    0, 0, 0.0707*cos(pq)*dpq-0.0661*sin(pq)*dpq-0.17*sin(qhL)*dqhL, 0, 0, 0, 0, -0.17*sin(qhL)*dqhL, 0, 0, 0;
    0, 0, 0.0707*cos(pq)*dpq-0.0661*sin(pq)*dpq-0.396*sin(qhL)*dqhL-0.1867*sin(qhkL)*dqhkL, 0, 0, 0, 0, -0.396*sin(qhL)*dqhL-0.1867*sin(qhkL)*dqhkL, -0.1867*sin(qhkL)*dqhkL, 0, 0;
    0, 0, 0.0707*cos(pq)*dpq-0.0661*sin(pq)*dpq-0.396*sin(qhL)*dqhL-0.43*sin(qhkL)*dqhkL-0.05123*cos(qhkaL)*dqhkaL-0.0195*sin(qhkaL)*dqhkaL, 0, 0, 0, 0, -0.396*sin(qhL)*dqhL-0.43*sin(qhkL)*dqhkL-0.05123*cos(qhkaL)*dqhkaL-0.0195*sin(qhkaL)*dqhkaL, -0.43*sin(qhkL)*dqhkL-0.05123*cos(qhkaL)*dqhkaL-0.0195*sin(qhkaL)*dqhkaL, -0.05123*cos(qhkaL)*dqhkaL-0.0195*sin(qhkaL)*dqhkaL, 0;
    0, 0, 0.0707*cos(pq)*dpq-0.0661*sin(pq)*dpq+0.0294*cos(qheL)*dqheL-0.1818*sin(qheL)*dqheL, 0, 0, 0, 0, 0.0294*cos(qheL)*dqheL-0.1818*sin(qheL)*dqheL, 0, 0, 0.0294*cos(qheL)*dqheL-0.1818*sin(qheL)*dqheL; % 
    0, 0, -0.0215*cos(pq)*dpq+0.0707*sin(pq)*dpq, 0, 0, 0, 0, 0, 0, 0, 0;
    0, 0, -0.3943*cos(pq)*dpq+0.1307*sin(pq)*dpq, 0, 0, 0, 0, 0, 0, 0, 0;
    0, 0, 0.0661*cos(pq)*dpq+0.0707*sin(pq)*dpq+0.17*cos(qhR)*dqhR, 0.17*cos(qhR)*dqhR, 0, 0, 0, 0, 0, 0, 0;
    0, 0, 0.0661*cos(pq)*dpq+0.0707*sin(pq)*dpq+0.396*cos(qhR)*dqhR+0.1867*cos(qhkR)*dqhkR, 0.396*cos(qhR)*dqhR+0.1867*cos(qhkR)*dqhkR, 0.1867*cos(qhkR)*dqhkR, 0, 0, 0, 0, 0, 0;
    0, 0, 0.0661*cos(pq)*dpq+0.0707*sin(pq)*dpq+0.396*cos(qhR)*dqhR+0.43*cos(qhkR)*dqhkR+0.0195*cos(qhkaR)*dqhkaR-0.05123*sin(qhkaR)*dqhkaR, 0.396*cos(qhR)*dqhR+0.43*cos(qhkR)*dqhkR+0.0195*cos(qhkaR)*dqhkaR-0.05123*sin(qhkaR)*dqhkaR, 0.43*cos(qhkR)*dqhkR+0.0195*cos(qhkaR)*dqhkaR-0.05123*sin(qhkaR)*dqhkaR, 0.0195*cos(qhkaR)*dqhkaR-0.05123*sin(qhkaR)*dqhkaR, 0, 0, 0, 0, 0;
    0, 0, 0.0661*cos(pq)*dpq+0.0707*sin(pq)*dpq+0.1818*cos(qheR)*dqheR+0.0294*sin(qheR)*dqheR, 0.1818*cos(qheR)*dqheR+0.0294*sin(qheR)*dqheR, 0, 0, 0.1818*cos(qheR)*dqheR+0.0294*sin(qheR)*dqheR, 0, 0, 0, 0; % 
    0, 0, 0.0661*cos(pq)*dpq+0.0707*sin(pq)*dpq+0.17*cos(qhL)*dqhL, 0, 0, 0, 0, 0.17*cos(qhL)*dqhL, 0, 0, 0;
    0, 0, 0.0661*cos(pq)*dpq+0.0707*sin(pq)*dpq+0.396*cos(qhL)*dqhL+0.1867*cos(qhkL)*dqhkL, 0, 0, 0, 0, 0.396*cos(qhL)*dqhL+0.1867*cos(qhkL)*dqhkL, 0.1867*cos(qhkL)*dqhkL, 0, 0;
    0, 0, 0.0661*cos(pq)*dpq+0.0707*sin(pq)*dpq+0.396*cos(qhL)*dqhL+0.43*cos(qhkL)*dqhkL+0.0195*cos(qhkaL)*dqhkaL-0.05123*sin(qhkaL)*dqhkaL, 0, 0, 0, 0, 0.396*cos(qhL)*dqhL+0.43*cos(qhkL)*dqhkL+0.0195*cos(qhkaL)*dqhkaL-0.05123*sin(qhkaL)*dqhkaL, 0.43*cos(qhkL)*dqhkL+0.0195*cos(qhkaL)*dqhkaL-0.05123*sin(qhkaL)*dqhkaL, 0.0195*cos(qhkaL)*dqhkaL-0.05123*sin(qhkaL)*dqhkaL, 0;
    0, 0, 0.0661*cos(pq)*dpq+0.0707*sin(pq)*dpq+0.1818*cos(qheL)*dqheL+0.0294*sin(qheL)*dqheL, 0, 0, 0, 0, 0.1818*cos(qheL)*dqheL+0.0294*sin(qheL)*dqheL, 0, 0, 0.1818*cos(qheL)*dqheL+0.0294*sin(qheL)*dqheL % 
    ];

Jy = [0, 1, -0.0707*cos(pq)-0.0215*sin(pq), 0, 0, 0, 0, 0, 0, 0, 0;
    0, 1, -0.1307*cos(pq)-0.3943*sin(pq), 0, 0, 0, 0, 0, 0, 0, 0;
    0, 1, -0.0707*cos(pq)+0.0661*sin(pq)+0.17*sin(qhR), 0.17*sin(qhR), 0, 0, 0, 0, 0, 0, 0;
    0, 1, -0.0707*cos(pq)+0.0661*sin(pq)+0.396*sin(qhR)+0.1867*sin(qhkR), 0.396*sin(qhR)+0.1867*sin(qhkR), 0.1867*sin(qhkR), 0, 0, 0, 0, 0, 0;
    0, 1, -0.0707*cos(pq)+0.05123*cos(qhkaR)+0.0661*sin(pq)+0.396*sin(qhR)+0.43*sin(qhkR)+0.0195*sin(qhkaR), 0.05123*cos(qhkaR)+0.396*sin(qhR)+0.43*sin(qhkR)+0.0195*sin(qhkaR), 0.05123*cos(qhkaR)+0.43*sin(qhkR)+0.0195*sin(qhkaR), 0.05123*cos(qhkaR)+0.0195*sin(qhkaR), 0, 0, 0, 0, 0;
    0, 1, -0.0707*cos(pq)-0.0294*cos(qheR)+0.0661*sin(pq)+0.1818*sin(qheR), -0.0294*cos(qheR)+0.1818*sin(qheR), 0, 0, -0.0294*cos(qheR)+0.1818*sin(qheR), 0, 0, 0, 0;
    0, 1, -0.0707*cos(pq)+0.0661*sin(pq)+0.17*sin(qhL), 0, 0, 0, 0, 0.17*sin(qhL), 0, 0, 0;
    0, 1, -0.0707*cos(pq)+0.0661*sin(pq)+0.396*sin(qhL)+0.1867*sin(qhkL), 0, 0, 0, 0, 0.396*sin(qhL)+0.1867*sin(qhkL), 0.1867*sin(qhkL), 0, 0;
    0, 1, -0.0707*cos(pq)+0.05123*cos(qhkaL)+0.0661*sin(pq)+0.396*sin(qhL)+0.43*sin(qhkL)+0.0195*sin(qhkaL), 0, 0, 0, 0, 0.05123*cos(qhkaL)+0.396*sin(qhL)+0.43*sin(qhkL)+0.0195*sin(qhkaL), 0.05123*cos(qhkaL)+0.43*sin(qhkL)+0.0195*sin(qhkaL), 0.05123*cos(qhkaL)+0.0195*sin(qhkaL), 0;
    0, 1, -0.0707*cos(pq)-0.0294*cos(qheL)+0.0661*sin(pq)+0.1818*sin(qheL), 0, 0, 0, 0, -0.0294*cos(qheL)+0.1818*sin(qheL), 0, 0, -0.0294*cos(qheL)+0.1818*sin(qheL)
    ];

Jf = [1, 0, 0.0661*cos(pq)+0.396*cos(qhR)+0.43*cos(qhkR)+0.027*cos(qhkaR)+0.0707*sin(pq)+0.0338*sin(qhkaR), 0.396*cos(qhR)+0.43*cos(qhkR)+0.027*cos(qhkaR)+0.0338*sin(qhkaR), 0.43*cos(qhkR)+0.027*cos(qhkaR)+0.0338*sin(qhkaR), 0.027*cos(qhkaR)+0.0338*sin(qhkaR), 0, 0, 0, 0, 0;
    1, 0, 0.0661*cos(pq)+0.396*cos(qhR)+0.43*cos(qhkR)+0.027*cos(qhkaR)+0.0707*sin(pq)-0.1362*sin(qhkaR), 0.396*cos(qhR)+0.43*cos(qhkR)+0.027*cos(qhkaR)-0.1362*sin(qhkaR), 0.43*cos(qhkR)+0.027*cos(qhkaR)-0.1362*sin(qhkaR), 0.027*cos(qhkaR)-0.1362*sin(qhkaR), 0, 0, 0, 0, 0;
    1, 0, 0.0661*cos(pq)+0.396*cos(qhL)+0.43*cos(qhkL)+0.027*cos(qhkaL)+0.0707*sin(pq)+0.0338*sin(qhkaL), 0, 0, 0, 0, 0.396*cos(qhL)+0.43*cos(qhkL)+0.027*cos(qhkaL)+0.0338*sin(qhkaL), 0.43*cos(qhkL)+0.027*cos(qhkaL)+0.0338*sin(qhkaL), 0.027*cos(qhkaL)+0.0338*sin(qhkaL), 0;
    1, 0, 0.0661*cos(pq)+0.396*cos(qhL)+0.43*cos(qhkL)+0.027*cos(qhkaL)+0.0707*sin(pq)-0.1362*sin(qhkaL), 0, 0, 0, 0, 0.396*cos(qhL)+0.43*cos(qhkL)+0.027*cos(qhkaL)-0.1362*sin(qhkaL), 0.43*cos(qhkL)+0.027*cos(qhkaL)-0.1362*sin(qhkaL), 0.027*cos(qhkaL)-0.1362*sin(qhkaL), 0
    ];

Jn = [0, 1, -0.0707*cos(pq)-0.0338*cos(qhkaR)+0.0661*sin(pq)+0.396*sin(qhR)+0.43*sin(qhkR)+0.027*sin(qhkaR), -0.0338*cos(qhkaR)+0.396*sin(qhR)+0.43*sin(qhkR)+0.027*sin(qhkaR), -0.0338*cos(qhkaR)+0.43*sin(qhkR)+0.027*sin(qhkaR), -0.0338*cos(qhkaR)+0.027*sin(qhkaR), 0, 0, 0, 0, 0;
    0, 1, -0.0707*cos(pq)+0.1362*cos(qhkaR)+0.0661*sin(pq)+0.396*sin(qhR)+0.43*sin(qhkR)+0.027*sin(qhkaR), 0.1362*cos(qhkaR)+0.396*sin(qhR)+0.43*sin(qhkR)+0.027*sin(qhkaR), 0.1362*cos(qhkaR)+0.43*sin(qhkR)+0.027*sin(qhkaR), 0.1362*cos(qhkaR)+0.027*sin(qhkaR), 0, 0, 0, 0, 0;
    0, 1, -0.0707*cos(pq)-0.0338*cos(qhkaL)+0.0661*sin(pq)+0.396*sin(qhL)+0.43*sin(qhkL)+0.027*sin(qhkaL), 0, 0, 0, 0, -0.0338*cos(qhkaL)+0.396*sin(qhL)+0.43*sin(qhkL)+0.027*sin(qhkaL), -0.0338*cos(qhkaL)+0.43*sin(qhkL)+0.027*sin(qhkaL), -0.0338*cos(qhkaL)+0.027*sin(qhkaL), 0;
    0, 1, -0.0707*cos(pq)+0.1362*cos(qhkaL)+0.0661*sin(pq)+0.396*sin(qhL)+0.43*sin(qhkL)+0.027*sin(qhkaL), 0, 0, 0, 0, 0.1362*cos(qhkaL)+0.396*sin(qhL)+0.43*sin(qhkL)+0.027*sin(qhkaL), 0.1362*cos(qhkaL)+0.43*sin(qhkL)+0.027*sin(qhkaL), 0.1362*cos(qhkaL)+0.027*sin(qhkaL), 0;
    ];

Jgrf = [Jf; Jn];

end