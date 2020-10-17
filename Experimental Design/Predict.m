function Data_pre=Predict(win,wsize,a,Ses,Domain)
%% 颜色参数
WHITE=[255,255,255];
RED=[170 0 0];
GREEN=[0 170 0];
PURPLE=[255 0 255];
YELLOW=[255 255 0];
themeColor=PURPLE;
%% 原始参数 数据
V=[50,50,40,40,20,20]';
P=[0.6,0.6,0.5,0.5,0.5,0.5]';
Usafe=[30 30 20 20 10 10]';
Screen('TextFont', win,'Helvetica');
Trail=randperm(size(V,1))';Pos=Shuffle(repmat([1,2]',size(V,1)/2,1));
D=table(Trail,P,V,Usafe,Pos);D.Loss=D.V-D.Usafe;
Data=sortrows(D,{'Trail'},{'ascend'});
b=4;
D.Ug=D.V.*P+a.*D.V.^2.*D.P.*(1-D.P);
pc=1./(1+exp(-b.*(D.Ug-D.Usafe)));N=ones(size(V,1),1);
Data.ChooseGamble=binornd(N,pc);
Data.Judge=zeros(height(Data),1);
Data.RT=zeros(height(Data),1);
trialLen=height(Data);
%% 指导语
Xcenter=mean(wsize([1,3]));Ycenter=mean(wsize([2,4]));
iCX=Xcenter;iCY=Ycenter-150;
Instru=imread(['O',num2str(Ses),'.jpg']);
InsSize=size(Instru);h=700;w=InsSize(2)/InsSize(1)*h;
Rect=[iCX-w/2,iCY-h/2,iCX+w/2,iCY+h/2];
word1=double('预测他的选择');
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
Comfirm_time=0.5;
Cue_time=2;
Screen('TextStyle', win,1);
for trail=1:trialLen
    p=Data.P(trail);
    v=Data.V(trail);
    vsafe=Data.Usafe(trail);
    loss=Data.Loss(trail);
    pos=Data.Pos(trail);
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
    judge=0;pressed=0;VSize=34;
    while ~pressed 
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
        
        [keyIsDown,s,keyCode]=KbCheck;
        if keyIsDown && ~pressed
            if find(keyCode)==27
                forced=1;
                break
            elseif find(keyCode)==37%←左
                judge=1;pressed=1;reactionTime=t;tic
            elseif find(keyCode)==39%→右
                judge=2;pressed=1;reactionTime=t;tic
            end
            while KbCheck;end
        end
        if pressed==1
            Screen('FrameRect', win,YELLOW,B_Box(judge,:),14);
            Screen(win,'Flip');
            WaitSecs(Comfirm_time)
            break
        else
        Screen(win,'Flip');
        end
    end
    if ~forced
    Data.Judge(trail)=judge;
    Data.RT(trail)=reactionTime;
    else
        ShowCursor
        sca;
        break
    end
end
Data.Choice=(Data.Pos==Data.Judge).*1;
Data_pre=Data;
end