function [] = savetxt(fname,Xk_total)
%SAVETXT 此处显示有关此函数的摘要
%   此处显示详细说明
fid=fopen(fname,'wt');%写入文件路径LC_CutPre25s.txt
fprintf(fid,'              N                 E                 U               t              week\n');
[m,n]=size(Xk_total);
for i=1:1:m
    for j=1:1:n
        if j==n
            fprintf(fid,'%13d\n',Xk_total(i,j));
        elseif j==n-1
            fprintf(fid,'%18.2f',Xk_total(i,j));
        else
            fprintf(fid,'%18.6f',Xk_total(i,j));
        end
    end
end

fclose(fid);

end

