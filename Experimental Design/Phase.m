function Phase(win,wsize,Ses)
Xcenter=mean(wsize([1,3]));Ycenter=mean(wsize([2,4]));
iCX=Xcenter;iCY=Ycenter;
Instru=imread(['start (',num2str(Ses),').png']);
InsSize=size(Instru);h=1080;w=InsSize(2)/InsSize(1)*h;
Rect=[iCX-w/2,iCY-h/2,iCX+w/2,iCY+h/2];
Ins=Screen('MakeTexture',win,Instru);
WaitSecs(0.1)
while 1
    Screen('DrawTexture',win,Ins,[],Rect);
    Screen(win,'Flip')
    [keyIsDown,~,keyCode]=KbCheck;
    if keyIsDown
        if find(keyCode)==83
            if Ses
                break
            end
        elseif find(keyCode)==32
            if ~Ses
                break
            end
        end
        while KbCheck;end
    end
end
end