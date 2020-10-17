%% 输入被试编号 & block次数
clear;clc
NUMBER=input('input subject ID:');
if exist('NUMBER','var')==0
    NUMBER=2019;
end
%% 参数
rng('default')
P_Box=[0.10, 0.25, 0.40, 0.60, 0.75, 0.90]';
V_Box=[10 20 50 90]';
% P_Box=[0.1 0.5 0.9]';
% V_Box=[10 50 100]';
%% 颜色参数
Vmax=max(V_Box);Vmin=min(V_Box);
ValueColorBox=[flipud(([zeros(1,Vmin),Vmin+1:Vmax])'./Vmax),ones(Vmax,2)].*[255 255 0];
WHITE=[255,255,255];
YELLOW=[255,255,0];
RED=[255 0 0];
BLACK=[0 0 0];
GRAY=[1 1 1].*50;
%% 原始参数
Vzhi=sort(repmat(V_Box,length(P_Box),1));
Pzhi=repmat(P_Box,length(V_Box),1);
VPzhi=[Vzhi,Pzhi];
Index=nchoosek(1:size(VPzhi,1),2);
Pairs1=[VPzhi(Index(:,1),:),VPzhi(Index(:,2),:)];
Pairs2=[VPzhi(Index(:,2),:),VPzhi(Index(:,1),:)];
Pairs=[Pairs1;Pairs2];
V1=Pairs(:,1);P1=Pairs(:,2);V2=Pairs(:,3);P2=Pairs(:,4);
Position=Shuffle([ones(length(V1)/2,1);2.*ones(length(V1)/2,1)]);
%处理一下
D=table(V1,V2,P1,P2,Position);
D(D.V1>D.V2 & D.P1>D.P2 | D.V1.*D.P1<D.V2.*D.P2 | D.V1==D.V2 | D.P1==D.P2,:)=[];

T=(1:height(D))';
D.trail=Shuffle(T);
Trail=table(T);
D2=sortrows(D,{'trail'},{'ascend'});
Data=[Trail,D2(:,1:5)];
% 存储数据
Data.Judge=zeros(height(Data),1).*(-1);
Data.N=ones(height(Data),1);
Data.C=zeros(height(Data),1);
Data.Outcome=zeros(height(Data),1);
Data.RT=zeros(height(Data),1);
%% 屏幕打开
Screen('Preference', 'SkipSyncTests', 1);
[win,wsize] =Screen('OpenWindow',0,BLACK);
Xcenter=mean(wsize([1,3]));Ycenter=mean(wsize([2,4]));
%% 路径
Home_path=cd;
Data_path=[cd,'\ProData'];% 存储原始数据

%% 指导语
FontSize=25;
word1=double('请选择其中按键选择两个圆盘中的一个');
word2=double('按[F]键选择左边，按[J]键选择右边');
word3=double('圆盘上方数字代表可能获得的积分');
word4=double('圆盘的白色区域所占面积表示获得该积分的概率');
word5=double('自动计算每轮选择所获得价值,无即刻的反馈');
word6=double('按照规律取一半轮次的均值换算为最后的奖励数');
word7=double('准备好后按下空格键[space]开始');
pass=0;
HangSize=3*FontSize;
Text_X=50;
Text_Y=50;
while pass~=1
    Screen('TextSize', win,FontSize);
    Screen('DrawText',win,word1,Text_X,Text_Y,WHITE);
    Screen('DrawText',win,word2,Text_X,Text_Y+1*HangSize,WHITE);
    Screen('DrawText',win,word3,Text_X,Text_Y+2*HangSize,WHITE);
    Screen('DrawText',win,word4,Text_X,Text_Y+3*HangSize,WHITE);
    Screen('DrawText',win,word5,Text_X,Text_Y+4*HangSize,WHITE);
    Screen('DrawText',win,word6,Text_X,Text_Y+5*HangSize,WHITE);
    Screen('DrawText',win,word7,Text_X,Text_Y+6*HangSize,WHITE);
    Screen(win,'Flip');
    [keyIsDown,seconds,keyCode]=KbCheck;
    if keyIsDown
        if find(keyCode)==32
            pass=1;
        else
            x=1;%占位pass
        end
        while KbCheck;end
    end
end
gHalf=120;
ECC=300;
gCX1=Xcenter-ECC;gCX2=Xcenter+ECC;
gCY=Ycenter+1.2*gHalf;
kuo=[-gHalf,-gHalf,gHalf,gHalf];

Place1=[gCX1,gCY,gCX1,gCY]+kuo;
Place2=[gCX2,gCY,gCX2,gCY]+kuo;
PlaceBox=[Place1;Place2;Place1];
%% 实验开始
Gap_time=1;
Cue_time=1;
Choose_time=5;
forced=0;
ValueSize=135;
TextX1=gCX1-ValueSize;TextX2=gCX2-ValueSize;
TextY1=gCY-gHalf*2-ValueSize*2.3039/2;TextY2=gCY-gHalf*2-ValueSize*2.3039/2;
T1=[TextX1,TextY1];
T2=[TextX2,TextY2];
TBox=[T1;T2;T1];

Screen('TextSize', win,ValueSize);
Bad=0;BadUp=5;%漏判断5次自动退出
for trail=1:height(Data)
    v1=Data.V1(trail);
    v2=Data.V2(trail);
    p1=Data.P1(trail);
    p2=Data.P2(trail);
    pos=Data.Position(trail);
    V1place=PlaceBox(pos,:);
    V2place=PlaceBox(pos+1,:);
    TX1=TBox(pos,1);TY1=TBox(pos,2);
    TX2=TBox(pos+1,1);TY2=TBox(pos+1,2);
    ValueColor1=WHITE;%ValueColorBox(v1,:);
    ValueColor2=WHITE;%ValueColorBox(v2,:);
    tic
    while toc<Gap_time
        Screen(win,'Flip');
    end
    tic
    while toc<Cue_time
        fixationPoint(win,wsize);
        Screen(win,'Flip');
    end
    tic
    judge=0;
    forced=(Bad>=5);
    while 1
        t=toc;
        Screen('FillOval', win, GRAY, V1place);
        Screen('FillArc',win,ValueColor1,V1place,0,p1*360);
        Screen('FillOval', win, GRAY, V2place);
        Screen('FillArc',win,ValueColor2,V2place,0,p2*360)
        nuo1=-ValueSize*(v1==100)*0.9;
        Screen('DrawText',win,double(num2str(v1)),TX1+nuo1,TY1,ValueColor1);%ValueColor1);
        nuo2=-ValueSize*(v2==100)*0.9;
        Screen('DrawText',win,double(num2str(v2)),TX2+nuo2,TY2,ValueColor2);%ValueColor2);
        reYs=900;reYt=950;sLen=200;reXs=Xcenter-sLen/2;
        %         Screen('FillRect', win, [128 128 128],[reXs,reYs,reXs+sLen*(1-t/Choose_time),reYt])
        Screen(win,'Flip');
        [keyIsDown,seconds,keyCode]=KbCheck;
        if keyIsDown
            reactionTime=toc;
            if find(keyCode)==27
                forced=1;
                break
            elseif find(keyCode)==70%F
                judge=1;
                break
            elseif find(keyCode)==74%J
                judge=2;
                break
            else
                x=1;%占位pass
            end
            while KbCheck;end
        end
    end
    if judge==1 || judge==2
        Data.Judge(trail)=judge;
        Data.RT(trail)=reactionTime;
    else
        Bad=Bad+1;
        Data.RT(trail)=Choose_time;
    end
    if forced
        sca;
        break
    end
end
%%
if ~forced
    Data(Data.Judge==-1,:)=[];
    Data.C(Data.Judge==Data.Position)=1;
    cd(Data_path)
    save(['Prime',num2str(NUMBER),'.mat'],'Data')
    cd(Home_path)
    %%
    O1=Data(Data.C==1,:);
    O2=Data(Data.C==0,:);
    Data.Outcome(Data.C==1,:)=(O1.V1).*binornd(ones(height(O1),1),O1.P1);
    Data.Outcome(Data.C==0,:)=(O2.V2).*binornd(ones(height(O2),1),O2.P2);
    Data.Outcome(Data.Judge==-1,:)=0;
    Reward=mean(Data.Outcome);
    %%
    if exist('win','var')==0
        Screen('Preference', 'SkipSyncTests', 1);
        [win,wsize] =Screen('OpenWindow',0,[128,128,128]);
    end
    while 1
        Screen('TextSize', win,80);
        Screen('DrawText',win,double(['最终获得:',num2str(Reward*0.75,'%5.0f')]),200,Ycenter,WHITE);
        Screen(win,'Flip');
        [keyIsDown,seconds,keyCode]=KbCheck;
        if keyIsDown
            reactionTime=toc;
            if find(keyCode)==27
                sca;
                break
            end
            while KbCheck;end
        end
    end
    %% 最大似然估计
    LB = [0 0 0];
    UB = [Inf Inf Inf];%规定参数界限和随机开始的点
    x0 = [rand rand rand];
    options = optimset('MaxFunEvals',100000, 'MaxIter', 100000);
    [paramsEst, ~, ~] = ...
        fminsearchbnd(@(params)LP(params, Data.V1,Data.P1,Data.V2,Data.P2,Data.N,Data.C), x0, LB, UB,options);%调用了PsychFun函数,并利用fminsearchbnd函数获得最大似然的值
    A = paramsEst(1);C = paramsEst(2);Lam = paramsEst(3);
    fprintf('似然估计:a_hat = %2.6f,c_Hat=%2.6f,lam_Hat=%2.6f\n',paramsEst)
    %% bootstrap
    % Weight Function & Utility
    
    WF1=@(a,x)x.^a./(x.^a+(1-x).^a).^(1/a);
    WF2=@(a,x)exp(-((-log(x)).^a));
    U=@(c,x)x.^c;
    WF=WF2;
    X=0:0.01:1;
    plot(X,WF(A,X))
    % EU
    EU=@(a,c,v,p)U(c,v).*WF(a,p);
    % double
    EUpair1=@(a,c,v1,p,v2,q)U(c,v1+v2).*WF(a,p.*q)+U(c,v1).*WF(a,p.*(1-q))+U(c,v2).*WF(a,(1-p).*q);
    EUpair2=@(a,c,v1,p,v2,q)(v2+v1)^c.*WF(a,p).*WF(a,q)+v1^c.*WF(a,p).*WF(a,1-q)+v2^c.*WF(a,1-p).*WF(a,q);
    EU3=@(v1,v2,p,q)v1.*p+v2.*q;
    EUsingle=@(a,c,v,p)U(c,v).*WF(a,p);
    % p
    pc=@(lam,EU1,EU2)exp(lam.*EU1)./(exp(lam.*EU1)+exp(lam.*EU2));
    Probability=@(a,c,lam,v1,p1,v2,p2)pc(lam,EU(a,c,v1,p1),EU(a,c,v2,p2));%总算法
    tot=100;
    aBox=zeros(1,tot);
    cBox=zeros(1,tot);
    lamBox=zeros(1,tot);
    
    fprintf('Bootstrap……\n')
    Db=Data;
    Db.Pcc=Probability(A,C,Lam,Db.V1,Db.P1,Db.V2,Db.P2);
    for k=1:tot
        LB = [0 0 0];
        UB = [Inf Inf Inf];%规定参数界限和随机开始的点
        x0 = [rand rand rand];
        Db.C=binornd(Db.N,Db.Pcc);
        [paramsEst, ~, ~] = ...
            fminsearchbnd(@(params)LP(params, Db.V1,Db.P1,Db.V2,Db.P2,Db.N,Db.C), x0, LB, UB,options);%调用了PsychFun函数,并利用fminsearchbnd函数获得最大似然的值
        aHat = paramsEst(1);cHat = paramsEst(2);lamHat = paramsEst(3);
        aBox(k)=aHat;cBox(k)=cHat;lamBox(k)=lamHat;
    end
    % 输出CI结果
    aCI=quantile(aBox,[0.0250 0.975]);%不满足正态分布,取位于2.5%和97.5%的点作为置信区间
    cCI=quantile(cBox,[0.0250 0.975]);
    lamCI=quantile(lamBox,[0.0250 0.975]);
    fprintf('Parametric Bootstrap得到:\na_hat 的中位数%2.6f,均值%2.6f,置信区间为 [%2.6f, %2.6f]\n',median(aBox),mean(aBox),aCI)
    fprintf('c_hat 的中位数%2.6f,均值%2.6f,置信区间为 [%2.6f, %2.6f]\n',median(cBox),mean(cBox),cCI)
    fprintf('lam_hat 的中位数%2.6f,均值%2.6f,置信区间为 [%2.6f, %2.6f]\n\n',median(lamBox),mean(lamBox),lamCI)
    figure
    plot(X,WF(median(aBox),X))
end