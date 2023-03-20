clear

accfile0='acc10520.dat';
fp=fopen(accfile0,'w+');

AidDir = 'C:\Users\BDS-JING\Desktop\taibai\052\ACC'; 	% Select a folder interactively.
if AidDir == 0 			% User cancels selection
    fprintf('Please Select a New Folder!\n');
else
%     cd(AidDir)
    RawFile = dir(AidDir); %extract all files.
    AllFile = RawFile([RawFile.isdir]==0);
    if isempty(fieldnames(AllFile))
        fprintf('There are no files in this folder!\n');
    else	% There are files in the current folder. Feedback the number of files.
        fprintf('Number of Files: %i \n',size(AllFile,1));
    end
end
[FileNum,b]=size(AllFile);

for i_f=1:FileNum
    filename=AllFile(i_f).name;
    file=split(filename,'.');
    if file(2,:)=="dat"
        accfile=filename;
        accpath=[AidDir,'\',filename];
    end
    
    doy=str2num(accfile(5:7));
    hour=accfile(8)-96;
    year=2023;
    
    [ep,time]=ydoy2time(year,doy);
    
    ts=timeadd(time,(hour-1)*3600);
    te=timeadd(time,(hour)*3600);
    
    [ts_week,ts_sow]=time2gpst(ts);
    [te_week,te_sow]=time2gpst(te);
    
    acc=load(accpath);
    
    for i=1:length(acc(:,1))
        if(acc(i,4)>=ts_sow && acc(i,4)<=te_sow)
            fprintf(fp,"%18.6f%18.6f%18.6f%14.2f%8d\n",acc(i,1),acc(i,2),acc(i,3),acc(i,4),acc(i,5));
        end
    end
    
end


% accfile='acc1052a.dat';




fclose(fp);