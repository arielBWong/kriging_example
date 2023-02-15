clc;
clear all;
problem_folder = strcat(pwd,'\Surrogate\Methods\Surrogate');
addpath(problem_folder);

n = 1000;
x = linspace(0, 1, n);
x = x';
f = forrest(x);
plot(x, f,'b', 'LineWidth', 2); hold on;
bl = [0];
bu = [1];

% init solutions
init = 3;
total_eval = 100;
trgx = repmat(bl, init, 1) + (repmat(bu, init, 1) - repmat(bl, init, 1)) .* rand(init, 1);
trgf = forrest(trgx);
plot(trgx, trgf, 'ro');

arc.muf = [];
arc.x = [];

arc.x = [arc.x; trgx];
arc.muf = [arc.muf; trgf];

% param.GPR_type=1 for GPR of Matlab; 2 for DACE
param.GPR_type   = 2;
param.no_trials  = 1;

for i= init + 1: total_eval
    clf;
    yyaxis left
    plot(x, f,'b', 'LineWidth', 2); hold on;
    plot(arc.x,arc.muf, 'ro');

    
    mdl = Train_GPR(arc.x, arc.muf, param);
    [predf, mse] = Predict_GPR(mdl, x, param, arc);
    %  [~, indx] = sort(predf);
    curve1 = predf - mse;
    curve2 = predf + mse;
    inbetween_x = [x', fliplr(x')];
    inbetween_f = [curve1', fliplr(curve2')];
    fill(inbetween_x, inbetween_f, 'k', 'FaceAlpha', 0.1);
    plot(x, predf,'g--','LineWidth', 2)
    fmin = min(arc.muf);
    fmin       = repmat(fmin, n, 1);
    imp        = f - predf;
    z          = imp ./ mse;
    ei1        = imp .* Gaussian_CDF(z);
    ei1(mse==0)= 0;
    ei2        = mse .* Gaussian_PDF(z);
    eim        = (ei1 + ei2);
    
    [~, indx] = sort(-eim);
    xnew = x(indx(1));
    fnew = forrest(xnew);
    
    
    arc.x = [arc.x; xnew];
    arc.muf = [arc.muf; fnew];
    
    plot(xnew, fnew, 'go','MarkerSize',10,'MarkerFaceColor','g');
    title(num2str(i));
    
    
    yyaxis right
    plot(x, eim);
    
end