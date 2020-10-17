clear,clc;close all
Pcc=[];
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
D(D.Usafe==10 & D.V>=40,:)=[];
% D(D.Usafe==20 & D.V==30 & D.P==0.3,:)=[];
% D(D.P==0.5 & D.V==50,:)=[];
%%
D.EV=D.V.*D.P;
b=5;percent=[];
type=1;
if type==1
    aBox=-0.013:0.002:0.03;
    for a=aBox
        % D.Ug=D.V.^rou.*D.P;
        D.Ug=D.V.*D.P+a.*D.V.^2.*D.P.*(1-D.P);
        D.pc=1./(1+exp(-b.*(D.Ug-D.Usafe)));N=ones(height(D),1);
        D.C=binornd(N,D.pc);
        percent=[percent,mean(D.C)];
    end
    scatter(aBox,percent,50,'filled');
    %%
else
    rBox=0.7:0.01:1.2;
    for rou=rBox
        D.Ug=D.V.^rou.*D.P;
        % D.Ug=D.V.*D.P+a.*D.V.^2.*D.P.*(1-D.P);
        D.pc=1./(1+exp(-b.*(D.Ug-D.Usafe)));N=ones(height(D),1);
        D.C=binornd(N,D.pc);
        percent=[percent,mean(D.C)];
    end
    scatter(rBox,percent,50,'filled');
end
if Pcc
    Pcc=[Pcc;percent];
else
    Pcc=percent;
end
ax=gca;ax.FontSize=16;ax.LineWidth=2.4;ax.FontName='TimesNewRoman';
title(ax,'新设计');ylim([0 1]);ylabel('选择赌博比例');xlabel('风险偏好参数\alpha')
ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';set(gcf,'unit','normalized','Position',[0.1,0.1,9/24,12/24])
saveas(gcf,'NewCorrelation.jpg')

Da=D;
%%
c_Box={'r','g','b'};
%%
figure
tt=0;
text={'规避风险','寻求风险'};
for a=[-0.013,0.03]%ro=[0.93 1.16]
    tt=tt+1;
    subplot(1,2,tt)
    hold on
    for i=0:0.1:1
        plot([i i],[0 70],'k--','LineWidth',0.5);
    end
    k=0;
    for i=10:10:70
        plot([0 1],[i i],'k--','LineWidth',0.5);
    end
    x=0.01:0.01:1;
    for j=1:length(Us_Box)
        
        Us=Us_Box(j);
        Dl=Da(Da.Usafe==Us,:);
        %             Ug=Dl.V.^ro.*Dl.P
        Ug=Dl.V.*Dl.P+a.*Dl.V.^2.*Dl.P.*(1-Dl.P);
        Dl.pc=1./(1+exp(-b.*(Ug-Us)));N=ones(height(Dl),1);
        
        color=c_Box{j};
        f=@(x)Us./x;
        y=f(x);
        plot(x,y,[color,'-'],'LineWidth',2);
        scatter(Dl.P,Dl.V,(length(Us_Box)+5-j)*200+50,'o','MarkerEdgeColor',color,'MarkerEdgeAlpha',3/4,...
            'LineWidth',1.4);
        for i=1:height(Dl)
            
            scatter(Dl.P(i),Dl.V(i),(length(Us_Box)-j)*200+50,'o',...
                'LineWidth',1,'MarkerFaceColor',color,'MarkerFaceAlpha',Dl.pc(i),'MarkerEdgeColor',color,'MarkerEdgeAlpha',Dl.pc(i));
        end
    end
    title(text(tt))
    ax=gca;ax.FontSize=12;ax.LineWidth=2.4;ax.FontName='TimesNewRoman';
    xlim([0 1.0]);ylim([0 60]);
    xticks([0 0.25 0.5 0.75 1.0])
    ylabel('奖励金额(￥)');xlabel('获得奖励的概率')
    ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
    set(gcf,'unit','normalized','Position',[0.1,0.1,18/24,12/24])
end
saveas(gcf,['New',num2str(type),'.jpg'])
Da.Ug=[];Da.pc=[];Da.C=[];Da.N=[];