function Rest(win,wsize,time)
%% ��ɫ����
WHITE=[255,255,255];
Screen('TextFont', win,'Helvetica');
%% ָ����
Xcenter=mean(wsize([1,3]));Ycenter=mean(wsize([2,4]));
iCX=Xcenter-150;iCY=Ycenter-100;
word1=double('����Ϣһ��...');
Text_X=480;
Text_Y=250;
tic
t=0;
while t<time-1
    t=toc;
    Screen('TextSize', win,140);
    Screen('DrawText',win,double(num2str(time-t,'%4.0f')),iCX,iCY,WHITE);
    Screen('TextSize', win,70);
    Screen('DrawText',win,word1,Text_X,Text_Y,WHITE);
    Screen(win,'Flip');
end
