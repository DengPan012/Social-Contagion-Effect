clear;clc;close all
Data_pre=table;
for domain=1:2
    %%
    Del1=[];Del2=[];
    Num1=22;Num2=24;
    Dword={'Gain','Loss'};
    eval(['Del=Del',num2str(domain),';'])
    eval(['Num=Num',num2str(domain),';'])
    %% paramters
    P_Box=(3:7)'./10;
    V_Box=[50,40,30,20]';
    Us_Box=[30,20,10]';
    V=repmat(V_Box,length(P_Box),1);
    P=sort(repmat(P_Box,length(V_Box),1));
    D=table(V,P);
    HD=height(D);
    D=[D;D;D];
    D.Usafe=sort(repmat(Us_Box,HD,1));
    %%
    D.Loss=D.V-D.Usafe;D(~ismember(D.Loss,Us_Box),:)=[];
    D(D.Usafe==20 & D.V>=50,:)=[];
    D(D.Usafe==40,:)=[];
    D(D.Usafe==30 & D.P<=0.3,:)=[];
    D(D.Usafe==10 & D.P>=0.7 & D.V==20,1:3)={20,1,10};
    D(D.Usafe==10 & D.P>=0.7 & D.V==30,1:3)={40,0,30};
    D(D.Usafe==20 & D.P==0.3 & D.V>=30,1:3)={50,0.6,20;50,0.5,20};
    D.Loss=D.V-D.Usafe;
    D(D.Usafe==10 & D.V>=40,:)=[];
    Da=D;
    %%
    a=0.00;b=5;
    D.Ug=D.V.*D.P+a.*D.V.^2.*D.P.*(1-D.P);
    D.pc=1./(1+exp(-b.*(D.Ug-D.Usafe)));
    D.pc(D.pc>0.5)=1;
    D.pc(D.pc<0.5)=0;
    Neutral=mean(D.pc);
    %%
    ColorBox=[34,223,169;223,34,169]./255;
    
    subColor=[240,110,50]./255;
    blue=[30,50,180]./255;
    
    figure
    tt=0;
    self_Data=table;
    for su=1:Num
        self_Data.id(su)=su;
        %%
        load([Dword{domain},'Sub',num2str(su+600+100*domain),'_all.mat'])
        Data_obsserve=ALLData_OBS;
        Data=ALLData_SELF;
        ALLData_PRE.id=ones(height(ALLData_PRE),1).*(100*domain+su);
        Data_pre=[Data_pre;ALLData_PRE];
        subject_Data=zeros(1,4);
        for sesssion=1:4
            subject_Data(sesssion)=mean(Data.Choice(Data.session==sesssion,:))-Neutral;
        end
        observee_risk_preference=zeros(1,4);
        for sesssion=2:2:4
            observee_risk_preference(sesssion)=mean(Data_obsserve.ChooseGamble(Data_obsserve.session==sesssion,:))-Neutral;
        end
        self_Data.observee2(su)=observee_risk_preference(2);self_Data.observee4(su)=observee_risk_preference(4);
        if mod(su,2)==0
            self_Data.Session(su,:)=subject_Data;
            self_Data.Seeking_contagion(su)=subject_Data(2)-subject_Data(1);self_Data.First_contagion(su)=self_Data.Seeking_contagion(su);
            self_Data.Averse_contagion(su)=subject_Data(3)-subject_Data(4);self_Data.Second_contagion(su)=self_Data.Averse_contagion(su);
            self_Data.Obs_averse(su)=observee_risk_preference(4);self_Data.Obs_seeking(su)=observee_risk_preference(2);
        else
            self_Data.Session(su,:)=subject_Data;
            self_Data.Seeking_contagion(su)=subject_Data(4)-subject_Data(3);self_Data.Second_contagion(su)=self_Data.Seeking_contagion(su);
            self_Data.Averse_contagion(su)=subject_Data(1)-subject_Data(2);self_Data.First_contagion(su)=self_Data.Averse_contagion(su);
            self_Data.Obs_averse(su)=observee_risk_preference(2);self_Data.Obs_seeking(su)=observee_risk_preference(4);
        end
        %% plot results out
        if ~ismember(su,Del)
            tt=tt+1;
            subplot(3,8,tt)
            
            hold on
            plot(1:4,subject_Data,'-o','LineWidth',3,'Color',subColor);
            scatter([2,4],observee_risk_preference([2,4]),30,'o','MarkerEdgeColor',blue,'LineWidth',2,'MarkerFaceColor',blue);
            ax=gca;ax.FontSize=14;ax.LineWidth=1.5;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
            ylim([-0.45,0.45]),xlim([0.5 4.5]);xticks(1:4);yticks(-0.4:0.2:0.4);
            if tt==1
                ylabel('Risk Preference');xlabel('Session');
            end
            set(gcf,'unit','normalized','Position',[0,0,24/24,1])
            hold off
        end
        
    end
    saveas(gca,['pSub',Dword{domain},'.jpg'])
    close all
    
    AllNewP=self_Data(~ismember(self_Data.id,Del),:);
    
    eval(['AllNewP',Dword{domain},'=AllNewP;'])
end
AllNewPGain.Domain=ones(height(AllNewPGain),1).*1;
AllNewPLoss.Domain=ones(height(AllNewPLoss),1).*2;
All_Data=[AllNewPGain;AllNewPLoss];

writetable(All_Data,'All_Data_model_free.csv');
writetable(Data_pre,'All_Data_predict.csv');