clear
clc
%% -----------------20230311 add by yh   find all files---------------------
AidDir = 'C:\Users\BDS-JING\Desktop\accgnss_bat'; 	% 手动输入文件夹地址 
if AidDir == 0 			% User cancels selection
    fprintf('Please Select a New Folder!\n');
else
    cd(AidDir)
    RawFile = dir('**/*.23rtcm3*'); %extract all files.
    AllFile = RawFile([RawFile.isdir]==0);
    if isempty(fieldnames(AllFile))
        fprintf('There are no files in this folder!\n');
    else	% There are files in the current folder. Feedback the number of files.
        fprintf('Number of Files: %i \n',size(AllFile,1));
        FileName = string({RawFile.name}')   %输出所有.23rtcm3格式的文件名
    end
end
[a,b]=size(AllFile);

%% -----20230311 add by yh    Look for suffixes with 23rtcm3 -------
for i_f=1:a
    filename=AllFile(i_f).name;
    
    file=split(filename,'.');
    
%% 只输入混合数据文件路径
    if file(2,:)=="23rtcm3"           %if suffixes is 23rtcm3

        ifile_str=filename;
        ifile_str_=split(ifile_str,'.');
        
        ifile_str_GNSS=strcat(ifile_str_(1,:),".rtcm");
        ifile_str_ACC=strcat(ifile_str_(1,:),".dat");
        
        
        % 提取年year
        str_year=cell2mat(ifile_str_(2,1));
        year=str2num(str_year(1:2))+2000;
        
        % 提取年纪日doy
        str_doy=cell2mat(ifile_str_(1,1));
        doy=str2num(str_doy(5:7));
        
        % 提取GPS周week
        %%add by yh   [ep,t]=ydoy2time(year,doy);
        [ep,t]=ydoy2time(year,doy);
        [week,sow]=time2gpst(t);
        
        % 提取年月日ep(1) ep(2) ep(3)
        %ep=time2epoch(t);
        tr=sprintf('%d/%d/%d 00:00:00',ep(1),ep(2),ep(3));
        
        %计算数据时段
        str_sign=cell2mat(ifile_str_(1,1));
        sign=str_sign(8);
        m=sign-96;  %ASCII码值的减运算,比如a-96，得到1

        interval_0=sow+(m-1)*3600;
        interval_1=sow+m*3600;
  
        
        % 调用convbin_acc.exe 分离加速度数据和RTCM数据
        % 示例 "convbin_acc.exe acc1052b.23rtcm3 -r rtcm3 -week 2250"
        cmd_accpar_str=sprintf('convbin_acc.exe %s -r rtcm3 -tr %s -week %d',ifile_str,tr,week);
        system(cmd_accpar_str)
        
        pause(3);
        
%% ------------20230311 add by yh     delete head data-------------
        [N,E,U,t_A,week_A]=textread(ifile_str_ACC,'%f %f %f %f %d %*[^\n]');
        n=size(t_A);
        j=1;u=0;
        % Find the first two integer seconds
        for i=1:n
            if (t_A(i)- interval_0)==0       %找到开始时间
                ts=i;j=j+1;
            end
            if(t_A(i)- interval_1)==0       %找到结束时间
               te=i;u=u+1;
            end
        end

        if (j==1)   %如果没有找到该时段对应的起始时间则终止程序
           printf("未找到起始时段，请检查数据");
           quit;
        else       %找到则开始输出
            i=ts;
            if(u==0)  %如果没有找到该时段对应的结束时间则直接处理按开始时间后所有数据
            ACC=[N(i:end),E(i:end),U(i:end),t_A(i:end),week_A(i:end)];
%             figure(i_f);     %每处理好一个文件输出一个加速度图片
            figure();
            subplot(3,1,1);
            plot(t_A(i:end),N(i:end));title('acceleration data N');ylabel('m/s2');hold on;
            subplot(3,1,2);
            plot(t_A(i:end),E(i:end));title('acceleration data E');ylabel('m/s2');hold on;
            subplot(3,1,3);
            plot(t_A(i:end),U(i:end));title('acceleration data U');ylabel('m/s2');hold on;
            sgtitle(str_sign);

            else
            ACC=[N(i:te),E(i:te),U(i:te),t_A(i:te),week_A(i:te)];
%             figure(i_f);     
            figure();
            subplot(3,1,1);
            plot(t_A(i:te),N(i:te));title('acceleration data N');ylabel('m/s2');hold on;
            subplot(3,1,2);
            plot(t_A(i:te),E(i:te));title('acceleration data E');ylabel('m/s2');hold on;
            subplot(3,1,3);
            plot(t_A(i:te),U(i:te));title('acceleration data U');ylabel('m/s2');hold on;
            sgtitle(str_sign);
            end
            savetxt(ifile_str_ACC,ACC);

        end
        
%% 同理调用convbin.exe 解码RTCM数据
        cmd_rtcmpar_str=sprintf('convbin.exe %s -r rtcm3 -tr %s',ifile_str_GNSS,tr);
        system(cmd_rtcmpar_str)
              
    end
end

