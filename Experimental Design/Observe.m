function Data=Observe(win,wsize,D,a,Ses,Domain)
%% 颜色参数
WHITE=[255,255,255];
RED=[160 0 0];
GREEN=[0 160 0];
CYAN=[0 255 255];
YELLOW=[255 255 0];
themeColor=CYAN;
Screen('TextFont', win,'Helvetica');
%% 存储数据
b=5;
h=height(D);
D.Ug=D.V.*D.P+a.*D.V.^2.*D.P.*(1-D.P);
D.Pos=Shuffle(repmat([1,2]',h/2,1));
Data=D;
Data.pc=1./(1+exp(-b.*(D.Ug-D.Usafe)));N=ones(height(D),1);
Data.ChooseGamble=binornd(N,Data.pc);
Data.Judge=zeros(height(Data),1);
Data.Judge(Data.ChooseGamble==1,:)=Data.Pos(Data.ChooseGamble==1,:);
Data.Judge(Data.ChooseGamble==0,:)=3-Data.Pos(Data.ChooseGamble==0,:);
Data.RT=2+randn(height(Data),1)*0.5;
Data.Trail=randperm(height(Data))';
Data=sortrows(Data,{'Trail'},{'ascend'});
Data.RT_obs=ones(height(Data),1);

trialLen=height(Data);
%% 指导语
Xcenter=mean(wsize([1,3]));Ycenter=mean(wsize([2,4]));
iCX=Xcenter;iCY=Ycenter-150;
Instru=imread(['O',num2str(Ses),'.jpg']);
InsSize=size(Instru);he=700;w=InsSize(2)/InsSize(1)*he;
Rect=[iCX-w/2,iCY-he/2,iCX+w/2,iCY+he/2];
word1=double('观察他的选择');
word2=double(['一共',num2str(trialLen),'轮，准备好后按空格键开始']);
pass=0;
Text_X=480;
Text_Y=780;
Ins=Screen('MakeTexture',win,Instru);
Screen('TextStyle', win,0);
while pass~=1
    
    Screen('DrawTexture',win,Ins,[],Rect);
    Screen('FrameRect',win,themeColor,Rect,30);
    Screen('TextSize', win,80);
    Screen('DrawText',win,word1,Text_X,Text_Y,themeColor);
    Screen('TextSize', win,25);
    Screen('DrawText',win,word2,Text_X+100,Text_Y+200,themeColor);
    Screen(win,'Flip');
    [keyIsDown,s,keyCode]=KbCheck;
    if keyIsDown
        if find(keyCode)==32
            pass=1;
        end
        while KbCheck;end
    end
end
%% 位置
gHalf=300;
ECC=400;
gCX1=Xcenter-ECC;gCX2=Xcenter+ECC;
gCY=Ycenter;
kuo=[-1,-1,1,1].*gHalf;

Place1=[gCX1,gCY,gCX1,gCY]+kuo;
Place2=[gCX2,gCY,gCX2,gCY]+kuo;
PlaceBox=[Place1;Place2;Place1];
B_Box=[Place1+kuo./12;Place2+kuo./12];
%% shuzhi
TextX1=gCX1-280;TextX2=gCX2-280;
TextY1=gCY-100;TextY2=gCY-100;
T1=[TextX1,TextY1];
T2=[TextX2,TextY2];
TBox=[T1;T2;T1];
TColor=WHITE;
%% 实验开始
forced=0;
trialLen=height(Data);
Cue_time=2;
Screen('TextStyle', win,1);
for trail=1:trialLen
    p=Data.P(trail);
    v=Data.V(trail);
    vsafe=Data.Usafe(trail);
    loss=Data.Loss(trail);
    pos=Data.Pos(trail);
    rt=Data.RT(trail);
    judge=Data.Judge(trail);
    V1place=PlaceBox(pos,:);
    V2place=PlaceBox(pos+1,:);
    TX1=TBox(pos,1);TY1=TBox(pos,2);
    TX2=TBox(pos+1,1);TY2=TBox(pos+1,2);
    ITI=1;
    tic
    while toc<ITI
        fixationPoint(win,wsize)
        Screen(win,'Flip');
    end
    tic
    while toc<Cue_time
        Screen('TextSize', win,50);
        Screen('DrawText',win,double('Receive'),Xcenter-190,Ycenter-320,TColor);
        Screen('TextSize', win,180);
        Screen('DrawText',win,double(num2str(v)),Xcenter-190,Ycenter-200,TColor);
        Screen(win,'Flip');
    end
    tic
    stay=1;VSize=34;
    while stay 
        t=toc;
        Screen('TextSize', win,27);
        Screen('DrawText',win,double(num2str(trail)),1850,25,WHITE);
        Screen('FillOval',win,RED,V1place);
        Screen('FillArc',win,GREEN,V1place,0,p*360);
        
        if p<1 && p>0
        gWord='Lose all  Keep all';
        elseif p==0
        gWord='Lose all           ';
        else
        gWord='           Keep all';
        end
        Screen('TextSize', win,50);
        Screen('DrawText',win,double(['You have ',num2str(v)]),640,30,WHITE);
        Screen('TextSize', win,VSize);
        Screen('DrawText',win,double(gWord),TX1,TY1,WHITE);%ValueColor2);
        Screen('TextSize', win,VSize+20);
        if Domain==1
        Screen('FillOval', win, GREEN, V2place);
        Screen('DrawText',win,double(['   Keep ',num2str(vsafe)]),TX2,TY2,WHITE);
        else
            Screen('FillOval', win, RED, V2place);
        Screen('DrawText',win,double(['   Loss ',num2str(loss)]),TX2,TY2,WHITE);
        end
        
        if t>=rt
            [keyIsDown,s,keyCode]=KbCheck;
            if keyIsDown
                if find(keyCode)==27
                    forced=1;
                    break
                elseif find(keyCode)==32
                    reactionTime=t-rt;
                    stay=0;
                end
                while KbCheck;end
            end
            Screen('FrameRect',win,YELLOW,B_Box(judge,:),14);
        end
        Screen(win,'Flip');
    end
    if forced
        ShowCursor
        sca;
        break
    else
        Data.RT_obs(trail)=reactionTime;
    end
end
end