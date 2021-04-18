%this function computes the optimal params for SVM
function [ bestc, bestg]=func_SVM_param_optz (Labels, samples)
           
       bestc = 0; 
       bestg=  0;
       bestcv = 0;
for log2c = -4:12,  %  -1:3,
  for log2g = -4:8, % -4:1,
    cmd = ['-v 2 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
   
    cv = svmtrain(Labels, samples,cmd);

    if (cv >= bestcv),
      bestcv = cv;
      
      bestc = 2^log2c; 
      bestg = 2^log2g;
    end
%     fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
  end
end
 
% for log2c = -1:3,
%   for log2g = -4:1,
save file_best_cg bestc bestg