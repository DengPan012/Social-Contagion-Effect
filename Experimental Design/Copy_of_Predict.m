function Data_pre=Predict(win,wsize,a)
%% 颜色参数
WHITE=[255,255,255];
YELLOW=[255,255,0];
RED=[180 0 0];
GREEN=[0 180 0];
PURPLE=[255 0 255];
%% 原始参数 数据
V=[33,33,25,25,20,20]';
P=[0.3,0.3,0.4,0.4,0.5,0.5]';
Trail=randperm(size(V,1))';Pos=repmat([1,2]',size(V,1)/2,1);
D=table(Trail,P,V,Pos);
Data_pre=sortrows(D,{'Trail'},{'ascend'});
b=4;
Ug=D.V.*P+a.*D.V.^2.*D.P.*(1-D.P);Us=10;
pc=1./(1+exp(-b.*(Ug-Us)));N=ones(size(V,1),1);
Data_pre.ChooseGamble=binornd(N,pc);
Data_pre.Judge=zeros(height(Data_pre),1);
Data_pre.RT=zeros(height(Data_pre),1);
%% 指导语
Xcenter=mean(wsize([1,3]));Ycenter=mean(wsize([2,4]));
iCX=Xcenter;iCY=Ycenter-150;
Instru=imread('Predict.jpg');
InsSize=size(Instru);h=700;w=InsSize(2)/InsSize(1)*h;
Rect=[iCX-w/2,iCY-h/2,iCX+w/2,iCY+h/2];
word1=double('预测他的选择');
word2=double('准备好后按空格键开始');
pass=0;
Text_X=480;
Text_Y=750;
Ins=Screen('MakeTexture',win,Instru);
ColorI=PURPLE;
while pass~=1
    Screen('DrawTexture',win,Ins,[],Rect);
    Screen('FrameRect',win,ColorI,Rect,20);
    Screen('TextSize', win,80);
    Screen('DrawText',win,word1,Text_X,Text_Y,ColorI);
    Screen('TextSize', win,25);
    Screen('DrawText',win,word2,Text_X+200,Text_Y+200,ColorI);
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

gHalf=350;
gCX=Xcenter;gCY=Ycenter-80;
kuo=[-gHalf,-gHalf,gHalf,gHalf];
Place=[gCX,gCY,gCX,gCY]+kuo;
VX=gCX+70;VY=gCY-200;
%% 文字
BX1=gCX-400;
BX2=gCX+100;BY=gCY+gHalf+50;
BX_box=[BX1,BX2,BX1];
VSize=100;TSize=70;
TColor=WHITE;
B_place1=[BX1-20,BY-10,BX1+320,BY+155];
B_place2=[BX2-20,BY-10,BX2+320,BY+155];
B_Box=[B_place1;B_place2];
%% 实验开始
forced=0;
Choose_time=100;
Comfirm_time=1;
for trail=1:height(Data_pre)
    p=Data_pre.P(trail);
    v=Data_pre.V(trail);
    pos=Data_pre.Pos(trail);
    ITI=randi([1,2]);
    tic
    while toc<ITI
        fixationPoint(win,wsize)
        Screen(win,'Flip');
    end
    tic
    judge=0;pressed=0;
    t1=0;t2=0;qui=0;
    while ~pressed || t2<=Comfirm_time
        
        if pressed==0 && t1>=Choose_time
            pressed=3;tic
        end
        if pressed 
            t2=toc;
        else
            t1=toc;
        end
        Screen('FillOval',win,RED,Place);
        Screen('FillArc',win,GREEN,Place,0,p*360);
        Screen('TextSize', win,VSize);
        Screen('DrawText',win,double(num2str(v)),VX,VY,TColor);
        Screen('TextSize', win,TSize);
        Screen('DrawText',win,double('接受'),BX_box(pos),BY,TColor);
        Screen('DrawText',win,double('拒绝'),BX_box(pos+1),BY,TColor);
        [keyIsDown,s,keyCode]=KbCheck;
        if keyIsDown
            reactionTime=t1;
            if find(keyCode)==27
                forced=1;
                break
            else
                if pressed==0
                    if find(keyCode)==49%1
                        judge=1;pressed=1;tic
                    elseif find(keyCode)==50%2
                        judge=2;pressed=1;tic
                    end
                else
                    if find(keyCode)==49%1
                        judge=1;qui=1;pressed=1;
                    elseif find(keyCode)==50%1
                        judge=2;qui=1;pressed=1;
                    end
                end
            end
            while KbCheck;end
        end
        if pressed==1
            Screen('FrameRect', win,YELLOW,B_Box(judge,:),10);
        end
        Screen(win,'Flip');
        if qui==1
            WaitSecs(0.1)
            break
        end
    end
    if judge==0
        reactionTime=Choose_time;
    end
    Data_pre.Judge(trail)=judge;
    Data_pre.RT(trail)=reactionTime;
    if forced
        sca;
        break
    end
end
Data_pre=Data_pre;
end