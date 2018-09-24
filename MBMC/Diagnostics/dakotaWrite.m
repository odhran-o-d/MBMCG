function dakotaWrite(results, out)

%------------------------------------------------------------------
% WRITE results.out
%------------------------------------------------------------------
fprintf('%20.10e     f\n', out);
fid = fopen(results,'w');
fprintf(fid,'%20.10e     f\n', out);
%fprintf(fid,'%20.10e     params\n', C{1}(2:5));

fclose(fid);

end