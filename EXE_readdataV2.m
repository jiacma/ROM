%%%DK
load ScheduleData2;  % modified
load ChillerCLM CHCLM;
load CHMS;
load IceStorage; % Ice storage model:(Tinlet,TCHeSP,TOA)|--> chiller power
%% donwsizing unit to 30 T.
for i=1:4
    CHM{i}.P.theta=1*CHM{i}.P.theta;
    CHM{i}.Q.theta=1*CHM{i}.Q.theta;
end
CHCLM.theta=1*CHCLM.theta;
%% 


Cp=0.9243*1.055056*2.20462*1.8; % Btu/lbm-F, 1 BTU = 1.055056 kJ, 2.20462 lbm/kg, 1.8degF/degC
SpecificGravity = 1.031;
Cs=ton2kW(50)*(5*3600); % ice storage capacitance (kJ) which can meet cooling load of 50 ton for 5-hr (total)

Mode_str_choices={'CH','CHI','I','F','OFF'}; % last mode to be changed later 'FC', when model is ready
%% Extracts data for days of interest
dumm=datenum(dates);
DOIindx=[find(dumm==DOI(1)):1:find(dumm==DOI(end))];
dates=dates(DOIindx); % update dates
CWL     =CWL(DOIindx);
Nday=round(diff(DOI));
T_db_oa_shifted_ahutime=T_db_oa_shifted_ahutime(DOIindx);

switch casestudy
    case 1
        np=0.141; mp=0.141; pp=0.141; % DLAT, PG&E, A-10-CSMART
        dum=[np*ones(8,1);mp*ones(4,1);pp*ones(6,1);mp*ones(4,1);np*ones(2,1)]; % [0,8),[8,12),[12,6),[6,10),[10,12)
        dumday=kron(dum,ones(4,1));% 15 min sampling time
        kWhRate=repmat(dumday,[Nday,1]);

        if numel(kWhRate)~=numel(dates)
            error();
        end


        np=20.27;mp=np; pp= np ; % DLAT, PG&E, A-10-CSMART
        dum=[np*ones(8,1);mp*ones(4,1);pp*ones(6,1);mp*ones(4,1);np*ones(2,1)]; % [0,8),[8,12),[12,6),[6,10),[10,12)
        dumday=kron(dum,ones(4,1));% 15 min sampling time
        kWRate=repmat(dumday,[Nday,1]);


        Occupied=Occupied(DOIindx);
        Peak    =Peak(DOIindx);

        %nonHVACP=30*(NonChillerLoad_kW(DOIindx))/max(NonChillerLoad_kW(DOIindx));
        nonHVACP=NonChillerLoad_kW(DOIindx);
        nonHVACP=30*(nonHVACP>5);
        [~,~,dum]=H_plotseg(nonHVACP,4*24,0); % 5 min sampling time
        for i=1:size(dum,2)
            if i==1
                dum2(:,i)=2*dum(:,i);
            else
                dum2(:,i)=dum(:,i);
            end
        end
        nonHVACP=reshape(dum2,numel(dum2),1);
        
        % reduced COP
        QCH_0=ton2kW(50);
        COP_ratio=1.5;
        TOAdum=T_db_oa_shifted_ahutime;
        Correct_COP(); % Correct COP to see ES

    case 2 % utility PG&E A-10-CSMART, reduced COP, ideal nonHVAC
        np=0.141; mp=0.141; pp=0.141; % DLAT, PG&E, A-10-CSMART
        dum=[np*ones(8,1);mp*ones(4,1);pp*ones(6,1);mp*ones(4,1);np*ones(2,1)]; % [0,8),[8,12),[12,6),[6,10),[10,12)
        dumday=kron(dum,ones(4,1));% 15 min sampling time
        kWhRate=repmat(dumday,[Nday,1]);

        if numel(kWhRate)~=numel(dates)
            error();
        end


        np=20.27;mp=np; pp= np ; % DLAT, PG&E, A-10-CSMART
        dum=[np*ones(8,1);mp*ones(4,1);pp*ones(6,1);mp*ones(4,1);np*ones(2,1)]; % [0,8),[8,12),[12,6),[6,10),[10,12)
        dumday=kron(dum,ones(4,1));% 15 min sampling time
        kWRate=repmat(dumday,[Nday,1]);


        Occupied=Occupied(DOIindx);
        Peak    =Peak(DOIindx);

        %nonHVACP=30*(NonChillerLoad_kW(DOIindx))/max(NonChillerLoad_kW(DOIindx));
        nonHVACP=NonChillerLoad_kW(DOIindx);
        nonHVACP=30*(nonHVACP>5);
        [~,~,dum]=H_plotseg(nonHVACP,4*24,0); % 5 min sampling time
        for i=1:size(dum,2)
            if i==1
                dum2(:,i)=2*dum(:,i);
            else
                dum2(:,i)=dum(:,i);
            end
        end
        nonHVACP=reshape(dum2,numel(dum2),1);
        
        % reduced COP
        QCH_0=ton2kW(50);
        COP_ratio=1.5;
        TOAdum=T_db_oa_shifted_ahutime;
        Correct_COP(); % Correct COP to see ES 
    case 3 % utility PG&E A-10-CSMART, reduced COP, real nonHVAC
        np=0.141; mp=0.141; pp=0.141; % DLAT, PG&E, A-10-CSMART
        dum=[np*ones(8,1);mp*ones(4,1);pp*ones(6,1);mp*ones(4,1);np*ones(2,1)]; % [0,8),[8,12),[12,6),[6,10),[10,12)
        dumday=kron(dum,ones(4,1));% 15 min sampling time
        kWhRate=repmat(dumday,[Nday,1]);

        if numel(kWhRate)~=numel(dates)
            error();
        end


        np=10.27;mp=np; pp= np ; % DLAT, PG&E, A-10-CSMART
        dum=[np*ones(8,1);mp*ones(4,1);pp*ones(6,1);mp*ones(4,1);np*ones(2,1)]; % [0,8),[8,12),[12,6),[6,10),[10,12)
        dumday=kron(dum,ones(4,1));% 15 min sampling time
        kWRate=repmat(dumday,[Nday,1]);


        Occupied=Occupied(DOIindx);
        Peak    =Peak(DOIindx);

        %nonHVACP=30*(NonChillerLoad_kW(DOIindx))/max(NonChillerLoad_kW(DOIindx));
        nonHVACP=NonChillerLoad_kW(DOIindx);
        nonHVACP(1:96)=1.5*nonHVACP(1:96);
        % reduced COP
        QCH_0=ton2kW(50);
        COP_ratio=1.5;
        TOAdum=T_db_oa_shifted_ahutime;
        Correct_COP(); % Correct COP to see ES        
    case 4 % utility PG&E A-10-CSMART, reduced COP, real nonHVAC but scaled
        np=0.141; mp=0.141; pp=0.141; % DLAT, PG&E, A-10-CSMART
        dum=[np*ones(8,1);mp*ones(4,1);pp*ones(6,1);mp*ones(4,1);np*ones(2,1)]; % [0,8),[8,12),[12,6),[6,10),[10,12)
        dumday=kron(dum,ones(4,1));% 15 min sampling time
        kWhRate=repmat(dumday,[Nday,1]);

        if numel(kWhRate)~=numel(dates)
            error();
        end


        np=20.27;mp=np; pp= np ; % DLAT, PG&E, A-10-CSMART
        dum=[np*ones(8,1);mp*ones(4,1);pp*ones(6,1);mp*ones(4,1);np*ones(2,1)]; % [0,8),[8,12),[12,6),[6,10),[10,12)
        dumday=kron(dum,ones(4,1));% 15 min sampling time
        kWRate=repmat(dumday,[Nday,1]);


        Occupied=Occupied(DOIindx);
        Peak    =Peak(DOIindx);

        nonHVACP=30*(NonChillerLoad_kW(DOIindx))/max(NonChillerLoad_kW(DOIindx));
        nonHVACP(1:96)=1.5*nonHVACP(1:96);
        % reduced COP
        QCH_0=ton2kW(50);
        COP_ratio=1.5;
        TOAdum=T_db_oa_shifted_ahutime;
        Correct_COP(); % Correct COP to see ES       
        
    case 6 % utility PG&E A-10-CSMART, reduced COP, real nonHVAC but scaled
        np=0.0577; mp=0.0804; pp=0.228; % DLAT, PG&E, A-10-CSMART
        dum=[np*ones(8,1);mp*ones(4,1);pp*ones(6,1);mp*ones(4,1);np*ones(2,1)]; % [0,8),[8,12),[12,6),[6,10),[10,12)
        dumday=kron(dum,ones(4,1));% 15 min sampling time
        kWhRate=repmat(dumday,[Nday,1]);

        if numel(kWhRate)~=numel(dates)
            error();
        end


        np=0;mp=3.83; pp=  20; % DLAT, PG&E, A-10-CSMART
        dum=[np*ones(8,1);mp*ones(4,1);pp*ones(6,1);mp*ones(4,1);np*ones(2,1)]; % [0,8),[8,12),[12,6),[6,10),[10,12)
        dumday=kron(dum,ones(4,1));% 15 min sampling time
        kWRate=repmat(dumday,[Nday,1]);


        Occupied=Occupied(DOIindx);
        Peak    =Peak(DOIindx);

        nonHVACP=30*(NonChillerLoad_kW(DOIindx))/max(NonChillerLoad_kW(DOIindx));
        nonHVACP(1:96)=1.5*nonHVACP(1:96);
        % reduced COP
        QCH_0=ton2kW(50);
        COP_ratio=1.5;
        TOAdum=T_db_oa_shifted_ahutime;
        Correct_COP(); % Correct COP to see ES      

end
clearvars Y




% CWL filtering
CWL=1*filtfilt(ones(4,1),4,CWL); %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
np=0;mp=1;np=0;
dum=[np*ones(7,1);mp*ones(12,1);np*ones(5,1)]; % [0,7),[7,7),[7,12)
dumday=kron(dum,ones(4,1));% 15 min sampling time
occupiedsignal=repmat(dumday,[Nday,1]);
CWL=CWL.*occupiedsignal;


