function dakota = dakotaRead(params)

fid = fopen(params,'r');
C = textscan(fid,'%n%s');
fclose(fid);

num_vars = C{1}(1);
disp(num_vars)


% set design variables -- could use vector notation
% rosenbrock x1, x2

for i = 1:num_vars
    x{i} = C{1}(i+1);
end

disp(datetime)
disp(x)
dakota = x;