%% 参数
clear
Domain=input('input domain:');
V=[20,50,50,40]';
P=[0.3,0.7,0.3,0.5]';
Usafe=[10 30 30,20]';
Pos=[1,2,1,1]';
D=table(P,V,Usafe,Pos);
D.Loss=D.V-D.Usafe;
%% path
Home_path=cd;
Pic_path=[cd,'\practice',num2str(Domain)];

%%
Tips=8;
cd(Pic_path)
for i=1:Tips
    Qimg=imread(['Q (',num2str(i),').png']);
    Fimg=imread(['F (',num2str(i),').png']);
    Timg=imread(['T (',num2str(i),').png']);
    eval(['Q_Box.Q',num2str(i),'=Qimg;'])
    eval(['F_Box.F',num2str(i),'=Fimg;'])
    eval(['T_Box.T',num2str(i),'=Timg;'])
end
cd(Home_path)
%% 屏幕打开
BGColor=[1 1 1].*0;
Screen('Preference', 'SkipSyncTests', 1);
[win,wsize] =Screen('OpenWindow',0,BGColor);
Xcenter=mean(wsize([1,3]));Ycenter=mean(wsize([2,4]));
iCX=Xcenter;iCY=Ycenter;
HideCursor
%%
Instru2=imread('prac.png');
Instru=imread('test.png');
InsSize=size(Instru);h=1080;w=InsSize(2)/InsSize(1)*h;
insRect=[iCX-w/2,iCY-h/2,iCX+w/2,iCY+h/2];
Ins=Screen('MakeTexture',win,Instru);
Ins2=Screen('MakeTexture',win,Instru2);
pass=0;
while pass~=1
    Screen('DrawTexture',win,Ins,[],insRect);
    Screen(win,'Flip')
    [keyIsDown,s,keyCode]=KbCheck;
    if keyIsDown
        if find(keyCode)==83
            pass=1;
        end
        while KbCheck;end
    end
end

%%
Ans_Box=[2 2 1 1 2 2 2 1];
forced=0;
if 1
for i=1:Tips
    eval(['Qimg=Q_Box.Q',num2str(i),';'])
    eval(['Fimg=F_Box.F',num2str(i),';'])
    eval(['Timg=T_Box.T',num2str(i),';'])
    Qsize=size(Qimg);h=1080;wq=Qsize(2)/Qsize(1)*h;
    QRect=[iCX-wq/2,iCY-h/2,iCX+wq/2,iCY+h/2];
    Fsize=size(Fimg);h=1080;wf=Fsize(2)/Fsize(1)*h;
    FRect=[iCX-wf/2,iCY-h/2,iCX+wf/2,iCY+h/2];
    Tsize=size(Timg);h=1080;wt=Tsize(2)/Tsize(1)*h;
    TRect=[iCX-wt/2,iCY-h/2,iCX+wt/2,iCY+h/2];
    Q=Screen('MakeTexture',win,Qimg);
    F=Screen('MakeTexture',win,Fimg);
    T=Screen('MakeTexture',win,Timg);
    Ans=Ans_Box(i);judge=0;wrong=1;
    r=1;
    while 1
        Screen('DrawTexture',win,Q,[],QRect);
        [keyIsDown,s,keyCode]=KbCheck;
        if keyIsDown
            if find(keyCode)==27
                forced=1;
                break
            end
            if ~judge
                if find(keyCode)==65%←A
                    judge=1;
                elseif find(keyCode)==66%→B
                    judge=2;
                end
            else
                if find(keyCode)==32
                    if wrong
                        judge=0;
                    else
                        break;
                    end
                end
            end
            while KbCheck;end
        end
        wrong=(judge~=Ans);
        if judge
            if wrong
                Screen('DrawTexture',win,F,[],FRect);
            else
                Screen('DrawTexture',win,T,[],TRect);
            end
        end
        Screen(win,'Flip');
    end
    if forced
        break
    end
end
if forced
    ShowCursor
    sca
end
WaitSecs(0.2)
end
%%

while 1
    Screen('DrawTexture',win,Ins2,[],insRect);
    Screen(win,'Flip')
    [keyIsDown,s,keyCode]=KbCheck;
    if keyIsDown
        if find(keyCode)==83
            break
        end
        while KbCheck;end
    end
end
a=0;
Self(win,wsize,D,Domain);
Observe(win,wsize,D,a,0,Domain);
ShowCursor
sca
