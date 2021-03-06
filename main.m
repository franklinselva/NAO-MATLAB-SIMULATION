%%%  robot_simulation.m
close all
clear
clc

%% Initial Values
global uLINK G M BodyPos Dtime 
G = 9.8;  % Gravity acceleration [m/s^2]
i=1;
BodyPos= [0.0, 0.0, 0.203 + 0.04519 ];
%% Objects
% q_d = readmatrix('q.txt'); % reading all the desired q values
q_d = [0, 0, 0, 0  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.0349, 0, 0, 0, 0, 0.0349, 0];
p_d = readmatrix('p.txt');% reading all the desired positions
r_d = readmatrix('r.txt');% reading all the desired orientations
v_d = readmatrix('v.txt');
w_d = readmatrix('w.txt');

%%
SetupBipedRobot2;   % Biped robot in Fig.2.19, Fig.20 with center of mass and inertia tensor for each link
M = TotalMass(1);
Dtime = 0.005; % Sampling time
% EndTime = 0.13;
EndTime = 1.6;
time = 0:Dtime:EndTime;
tsize = length(time);
com_m = zeros(tsize,3);
zmp_m = zeros(tsize,2);

%% Main Loop
figure
tic
for k = i:tsize
    
    err_t_Body.p = p_d((((k-1)*3)+1):(((k-1)*3)+3),1) - p_d((((k)*3)+1):(((k)*3)+3),1);
    %     err_t_Body.R = quat2rotm( r_d(  (((k-1)*4)+1):(((k-1)*4)+4),1 )' ) ;
    %     t_Body.p = p_d((((k-1)*3)+1):(((k-1)*3)+3),1);
    %     t_Body.R = quat2rotm( r_d(  (((k-1)*4)+1):(((k-1)*4)+4),1 )' );
    %     t_Body.v = dq_d(k*1:(k*1)+2,1);
    %     t_Body.w = dq_d(k*4:(k*4)+2,1);
    
    
    %% Target
    Targets;
%     InverseKinematicsAllBody(BODY, t_BODY, 1);
    InverseKinematicsAll(RLEG_J6, t_Rfoot);
    InverseKinematicsAll(LLEG_J6, t_Lfoot);
    InverseKinematicsAll(LARM_J5, t_Lhand);
    InverseKinematicsAll(RARM_J5, t_Rhand);
    
    uLINK(1).p = uLINK(1).p - err_t_Body.p ;
%     ForwardKinematics(1);
%     ForwardVelocity(1);

        ForwardDynamics;
        GroundContact()
        [P, L] = IntegrateEuler(1);  % makes the robot sink
        
%     P   = calcP(1);   % Linear momentum
%     L   = calcL(1);   % Angular momentum
    com = calcCoM;
    %% ZMP
    if k == i
        P1 = calcP(1); % calculation of robot's momentum
        L1 = calcL(1); % calculation of robot's angular momentum
    end
    dP = (P-P1)/Dtime; % \dot{\mathcal{P}} is the Linear Momentum
    dL = (L-L1)/Dtime; % \dot{\mathcal{L}} is the Angular Momentum
    [zmpx, zmpy, zmpz] = calcZMP(com,dP,dL);
    P1 = P;
    L1 = L;
    zmp_m(k,:) = [zmpx, zmpy];
    com_m(k,:) = com';

    %% Plot
    Plot;
end
toc