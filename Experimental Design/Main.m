close all;clear;clc;
%% 输入被试编号
NUMBER=input('input subject ID:');
Domain=input('input domain:');
if exist('NUMBER','var')==0
    NUMBER=2019;
end
if Domain~=1 && Domain~=2
    Domain=1;
end
Dword={'Gain','Loss'};
%% 参数
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
D(D.Usafe==20 & D.P==0.3 & D.V>=30,1:3)={50,0.6,20;50,0.5,20};
D.Loss=D.V-D.Usafe;
D(D.Usafe==10 & D.V>=40,:)=[];
Da=D;
HH=height(D)/2;
%% 屏幕打开
BGColor=[1 1 1].*0;
Screen('Preference', 'SkipSyncTests', 1);
[win,wsize] =Screen('OpenWindow',0,BGColor);
Screen('TextStyle', win,0);
Phase(win,wsize,0)
%% 路径
folderName=['Sub',num2str(NUMBER)];
Home_path=cd;
Data_path=[cd,'\contagion_Data'];
cd(Data_path)
mkdir(folderName)
Sub_path=[Data_path,'\',folderName];% 存储原始数据
cd(Home_path)

ALLData_PRE=table;ALLData_SELF=table;ALLData_OBS=table;

A_box=[0,0.03,0,-0.015,0;0,-0.015,0,0.03,0];
A=A_box(mod(NUMBER,2)+1,:);
HideCursor
%%
startSes=1;lastSes=4;

%try
for Ses=startSes:lastSes
    Phase(win,wsize,Ses)
    Data_SELF=table;Data_PRE=table;Data_OBS=table;
    if mod(Ses,2)==0
        
        self_select=Shuffle([ones(HH,1);ones(HH,1).*2]);
        obs_select=Shuffle(self_select);
        a=A(Ses);
        Data_pre=Predict(win,wsize,a,Ses,Domain);
        Data_pre.session=ones(height(Data_pre),1).*Ses;Data_pre.seq=zeros(height(Data_pre),1);
        Data_PRE=[Data_PRE;Data_pre];
        
        for Seq=1:2
            for sel=1:2
                Block=2*(Seq-1)+sel;
                D_self=D(self_select==sel,:);
                D_obs=D(obs_select==sel,:);
                Data_obs=Observe(win,wsize,D_obs,a,Ses,Domain);
                Data_self=Self(win,wsize,D_self,Domain);
                % 数据
                Data_obs.session=ones(height(Data_obs),1).*Ses;Data_obs.block=ones(height(Data_obs),1).*Block;
                Data_obs.seq=ones(height(Data_obs),1).*Seq;Data_OBS=[Data_OBS;Data_obs];
                Data_self.session=ones(height(Data_self),1).*Ses;Data_self.block=ones(height(Data_self),1).*Block;
                Data_self.seq=ones(height(Data_self),1).*Seq;Data_SELF=[Data_SELF;Data_self];
            end
            Data_pre=Predict(win,wsize,a,Ses,Domain);
            Data_pre.session=ones(height(Data_pre),1).*Ses;Data_pre.seq=ones(height(Data_pre),1).*Seq;
            Data_PRE=[Data_PRE;Data_pre];
            cd(Sub_path)
            eval(['Data_SELF',num2str(Ses),'_q',num2str(Seq),'=Data_SELF'])
            eval(['Data_OBS',num2str(Ses),'_q',num2str(Seq),'=Data_OBS'])
            eval(['Data_PRE',num2str(Ses),'_q',num2str(Seq),'=Data_PRE'])
            save([Dword{Domain},'Sub',num2str(NUMBER),'_Ses',num2str(Ses),'_q',num2str(Seq),'.mat'],['Data_SELF',num2str(Ses),'_q',num2str(Seq)],['Data_OBS',num2str(Ses),'_q',num2str(Seq)],['Data_PRE',num2str(Ses),'_q',num2str(Seq)])
            cd(Home_path)
            if Seq==1
                Rest(win,wsize,30)
            end
        end
    else
        Data_self=Self(win,wsize,D,Domain);
        Data_self.session=ones(height(Data_self),1).*Ses;
        Data_self.block=zeros(height(Data_self),1);
        Data_self.seq=zeros(height(Data_self),1);
        Data_SELF=[Data_SELF;Data_self];
    end
    cd(Sub_path)
    eval(['Data_SELF',num2str(Ses),'=Data_SELF'])
    eval(['Data_OBS',num2str(Ses),'=Data_OBS'])
    eval(['Data_PRE',num2str(Ses),'=Data_PRE'])
    save([Dword{Domain},'DataSub',num2str(NUMBER),'_Ses',num2str(Ses),'.mat'],['Data_SELF',num2str(Ses)],['Data_OBS',num2str(Ses)],['Data_PRE',num2str(Ses)])
    cd(Home_path)
    
    ALLData_SELF=[ALLData_SELF;Data_SELF];ALLData_OBS=[ALLData_OBS;Data_OBS];ALLData_PRE=[ALLData_PRE;Data_PRE];
    if  Ses~=lastSes
        Rest(win,wsize,60)
    else
        ExpEnd(win,wsize,ALLData_SELF,ALLData_PRE)
    end
end
cd(Data_path)
save([Dword{Domain},'Sub',num2str(NUMBER),'_all.mat'],'ALLData_SELF','ALLData_OBS','ALLData_PRE')
ShowCursor
sca
% catch
%     cd(Sub_path)
%     save(['par_Sub',num2str(NUMBER),'_all.mat'],'ALLData_SELF','ALLData_OBS','ALLData_PRE')
%     warning('强制退出');
%     sca
% end
