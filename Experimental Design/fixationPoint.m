function fixationPoint(win,wsize,judgement)
if exist('judgement','var')==0
    judgement=2;
end
center_X=(wsize(3)+wsize(1))/2;
center_Y=(wsize(4)+wsize(2))/2;
%% 注视点参数
fix_length=80;
fix_width=6;
%% 注视点颜色
Red=[255,0,0];
Green=[0,255,0];
White=[255 255 255];
if judgement==1
    fix_color=Green;
elseif judgement==0
    fix_color=Red;
else
    fix_color=White;
end
%% 计算注视点位置
fix_from_Y=center_Y-fix_length/2;
fix_from_X=center_X-fix_length/2;
fix_to_Y=center_Y+fix_length/2;
fix_to_X=center_X+fix_length/2;
%%
Screen('DrawLine', win, fix_color, center_X,fix_from_Y,center_X,fix_to_Y, fix_width);
Screen('DrawLine', win, fix_color, fix_from_X,center_Y,fix_to_X,center_Y, fix_width);
end