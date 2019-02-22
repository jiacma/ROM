% night time COP is reduced. 

% values of utility signal is modified (X)
% nonHVAC load profile gets back to data (X).
clc;clear;
%% Specify simulation period and read corresponding data
DOI=[datenum('12-Jun-17 00:00 AM'),datenum('11-July-17 11:45 PM')]';
% fixed parameters: 2days prediction, 3 hr updates
casestudy=6; % reduced COP, utility ideal, nonHVAC ideal
EXE_readdataV2();


%% 
for jc=1:3 % iteration over control logics
    figure(3)
    EXE_setupV2(); % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    % Controller setup
    switch jc
        case 1
            Ctrl='simple'; 
            MPC=MPC_Conv(2,UpdateRate,CHM,CHCLM,IS,2); % dummy to calculate HVAC system
        case 2
            Ctrl='MPC';
            clearvars MPC
            Np=24*4*2; % 24 hr prediction = 24*4 steps (15 min sampling time)
            MPC=MPC_Conv(Np,UpdateRate,CHM,CHCLM,IS,Np/4);%test_IRMPC_DC_objV3_DP_m(Np,UpdateRate,CHM,CHCLM,IS,Np/4);
        case 3
            Ctrl='MPC';
            Np=24*4*2; % 24 hr prediction = 24*4 steps (15 min sampling time)
            MPC=MPC_H_V1(Np,UpdateRate,CHM,CHCLM,IS,Np/4);%test_IRMPC_DC_objV3_DP_m(Np,UpdateRate,CHM,CHCLM,IS,Np/4); 
    end
    
    % simulation
    EXE_simulation_m();

    % storing results
    Y{jc}.t=dates(1:(n-24*4));%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Y{jc}.P=simout(1:(n-24*4),9)+simout(1:(n-24*4),14);%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Y{jc}.ER=kWhRate(1:(n-24*4));%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Y{jc}.QBL=CWL(1:(n-24*4));%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Y{jc}.QCH=simout(1:(n-24*4),6);%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Y{jc}.X=X(1:(n-24*4),:);%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Y{jc}.Z=simout(1:(n-24*4),end-1:end);%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Y{jc}.P(isnan(Y{jc}.P))=0;
end
%%
% save IR_Comparisons2017_heuristic_z
% save IR_Comparisons2016_heuristic_z
% save Paper_comparison3
save(['casestudy',num2str(casestudy),'.mat'])
EXE_postprocess()