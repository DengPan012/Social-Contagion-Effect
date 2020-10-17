function ExpEnd(win,wsize,Self,Pre)
D=Self;D.EV=D.P.*D.V;
D.reward1=D.Choice.*D.V.*binornd(1,D.P)+(1-D.Choice).*D.Usafe;
mean(D.reward1);
waitReward1=D.reward1(D.Usafe==30 & D.EV<=30,:);
c1=randperm(numel(waitReward1));
waitReward2=D.reward1(D.Usafe==20 & D.EV<=20,:);
c2=randperm(numel(waitReward2));
waitReward3=D.reward1(D.Usafe==10 & D.EV<=10,:);
c3=randperm(numel(waitReward3));
Self_reward=(waitReward1(c1(1))+waitReward2(c2(1))+waitReward3(c3(1)))/3;
%%
Screen('TextFont', win,'Helvetica');
word2=double(['在“自己选择”阶段最终获得 ￥',num2str(Self_reward,'%3.1f')]);

Pre_sel=Pre(Pre.seq~=0,:);
ch=Pre_sel(randi([1,height(Pre_sel)]),:);
Pre_reward=10*(ch.ChooseGamble(1)==ch.Choice(1));
if logical(Pre_reward)
    word3=double('在抽取的轮次中您预测正确，获得 ￥10');
else
    word3=double('在抽取的轮次中您预测错误，获得 ￥0');
end
Final_reward=20+Self_reward+Pre_reward;
word4=double(['最终报酬: ￥',num2str(Final_reward,'%3.1f')]);
word5=double('填写事后问卷：');
%%
Xcenter=mean(wsize([1,3]));Ycenter=mean(wsize([2,4]));
word1=double('实验结束');
Instru=imread('Question.png');
Rect=[1620,800,1820,1000];
Ins=Screen('MakeTexture',win,Instru);
pass=0;
Color=[255 255 255];
while pass~=1
    Screen('DrawTexture',win,Ins,[],Rect);
    Screen('TextSize', win,100);
    Screen('DrawText',win,word1,Xcenter-400,Ycenter-320,Color);
    Screen('TextSize', win,30);
    Screen('DrawText',win,word2,Xcenter-400,Ycenter-50,Color);
    Screen('DrawText',win,word3,Xcenter-400,Ycenter+50,Color);
    Screen('DrawText',win,word4,Xcenter-400,Ycenter+150,Color);
    Screen('DrawText',win,word5,Xcenter+200,Ycenter+300,Color);
    Screen(win,'Flip')
    [keyIsDown,~,keyCode]=KbCheck;
    if keyIsDown
        if find(keyCode)==27
            pass=1;
        end
        while KbCheck;end
    end
end
sca
end
