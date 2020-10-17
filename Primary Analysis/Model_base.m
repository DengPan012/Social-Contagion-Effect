clear;clc;close all
for domain=1:2
    %%
    Del1=[];Del2=[];Num1=22;Num2=24;
    Dword={'Gain','Loss'};
    eval(['Del=Del',num2str(domain),';'])
    eval(['Num=Num',num2str(domain),';'])
    %%
    orange=[240,110,50]./255;
    blue=[30,50,180]./255;
    figure
    tt=0;
    self_Data=table;
    for su=1:Num
        %%
        
        fprintf('%1.0f¡­\n',su)
        load([Dword{domain},'Sub',num2str(su+600+100*domain),'_all.mat'])
        A_box=[0,0.02,0,-0.015,0;0,-0.015,0,0.02,0];
        A=A_box(mod(su,2)+1,:);
        
        Data=ALLData_SELF;
        Data.C=Data.Choice;Data.N=ones(height(ALLData_SELF),1);
        
        %% 
        NewA=zeros(1,4);
        for ses=1:4
            D=Data(Data.session==ses,:);
            tot=10;
            options = optimset('MaxFunEvals',100000, 'MaxIter', 10000);
            % Maximum Loglikelihood Estimation
            aBox1=zeros(1,tot);bBox1=zeros(1,tot);LLBox1=zeros(1,tot);
            rBox2=zeros(1,tot);bBox2=zeros(1,tot);LLBox2=zeros(1,tot);
            for k=1:tot
                fprintf('%1.0f¡­',k)
                LB = [-Inf -Inf -Inf];
                UB = [Inf Inf Inf];
                x0 = [rand rand rand];
                [paramsEst1, minuslli1, ~] = ...
                    fminsearchbnd(@(params)MVU(params,D.V,D.P,D.Usafe,D.N,D.C), x0, LB, UB,options);
                aBox1(k) = paramsEst1(1);bBox1(k) = paramsEst1(2);LLBox1(k)= minuslli1;
            end
            %%
            
            a=median(aBox1);
            if a<=-0.04
                a=-0.04;
            elseif a>=0.05
                a=0.05;
            end
            NewA(ses)=a;
        end
        subD=NewA;
        self_Data.id(su)=su;
        self_Data.Observee2(su)=A(2);self_Data.Observee4(su)=A(4);
        if mod(su,2)==0
            self_Data.Session(su,:)=subD;
            self_Data.Seeking_contagion(su)=subD(2)-subD(1);self_Data.First_contagion(su)=self_Data.Seeking_contagion(su);
            self_Data.Averse_contagion(su)=subD(3)-subD(4);self_Data.Second_contagion(su)=self_Data.Averse_contagion(su);
            self_Data.Obs_averse(su)=A(4);self_Data.Obs_seeking(su)=A(2);
        else
            self_Data.Session(su,:)=subD;
            self_Data.Seeking_contagion(su)=subD(4)-subD(3);self_Data.Second_contagion(su)=self_Data.Seeking_contagion(su);
            self_Data.Averse_contagion(su)=subD(1)-subD(2);self_Data.First_contagion(su)=self_Data.Averse_contagion(su);
            self_Data.Obs_averse(su)=A(2);self_Data.Obs_seeking(su)=A(4);
        end
        if ~ismember(su,Del)
            tt=tt+1;
            subplot(3,8,tt)
            
            hold on
            plot(1:4,subD,'-o','LineWidth',3,'Color',orange);
            scatter([2,4],A([2,4]),50,'o','MarkerEdgeColor',blue,'LineWidth',3,'MarkerFaceColor',blue);
            ax=gca;ax.FontSize=14;ax.LineWidth=2;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
            ylim([-0.05,0.05]),xlim([0.5 4.5]);xticks(1:4);yticks(-0.04:0.02:0.04);
            if tt==1
                ylabel('Risk Preference');xlabel('Session');
            end
            set(gcf,'unit','normalized','Position',[0,0,24/24,1])
            hold off
        end
        
    end
    saveas(gca,['aSub',Dword{domain},'.jpg'])
    close all
    
    AllNewA=self_Data(~ismember(self_Data.id,Del),:);
    
    eval(['AllNewA',Dword{domain},'=AllNewA;'])
end
AllNewAGain.Domain=ones(height(AllNewAGain),1).*1;
AllNewALoss.Domain=ones(height(AllNewALoss),1).*2;
All_Data=[AllNewAGain;AllNewALoss];

writetable(All_Data,'All_Data_model_base.csv');
