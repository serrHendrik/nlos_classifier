%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (C) 2006 DAVIDE SCARAMUZZA
%
%   Author: Davide Scaramuzza - email: davsca@tiscali.it
%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
%   USA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function optimizefunction(calib_data)
tol_MSE = 1e-4;
MSE_old = 0;
MSE_new = Inf;
iter = 0;

fprintf(1,'This function alternately refines EXTRINSIC and INTRINSIC calibration parameters\n');
fprintf(1,'by using an interative non linear minimization method \n');
fprintf(1,'Because of the computations involved this refinement can take some seconds\n');

fprintf(1,'Loop interrupting: Press enter to stop refinement. (OCamCalib GUI must be selected!)\n');

max_iter = input('\n Maximum number of iterations ([] = 100, 0 = abort, -1 = no limit) = ');

if ~isempty(max_iter)
    if max_iter == 0
        return;
    elseif max_iter == -1;
        max_iter = Inf;
    end
else
    max_iter = 100;
end


if isempty(calib_data.n_ima) | calib_data.calibrated==0,
    fprintf(1,'\nNo calibration data available. You must first calibrate your camera.\nClick on "Calibration" or "Find center"\n\n');
    return;
end;

pause(0.01);
figure(1);          %obrand used for runtime interrupting
pause(0.01);
set(gcf,'CurrentChar', 'a');


while (iter < max_iter && abs(MSE_new - MSE_old) > tol_MSE) && get(gcf,'CurrentChar') ~= 13
    iter = iter + 1;
    fprintf(1, '\nIteration %i\n',iter);
    
    fprintf(1,'Starting refinement of EXTRINSIC parameters...\n');
    
    options=optimset('Display','off',...
        'LargeScale','off', ...
        'TolX',1e-4,...
        'TolFun',1e-4,...
        'DerivativeCheck','off',...
        'Diagnostics','off',...
        'Jacobian','off',...
        'JacobMult',[],... % JacobMult set to [] by default
        'JacobPattern','sparse(ones(Jrows,Jcols))',...
        'MaxFunEvals','100*numberOfVariables',...
        'DiffMaxChange',1e-1,...
        'DiffMinChange',1e-8,...
        'PrecondBandWidth',0,...
        'TypicalX','ones(numberOfVariables,1)',...
        'MaxPCGIter','max(1,floor(numberOfVariables/2))', ...
        'TolPCG',0.1,...
        'MaxIter',10000,...
        'Algorithm','levenberg-marquardt');
    %'Algorithm','trust-region-reflective');
    
    
    
    if (isempty(calib_data.ocam_model.c) & isempty(calib_data.ocam_model.d) & isempty(calib_data.ocam_model.e))
        calib_data.ocam_model.c=1;
        calib_data.ocam_model.d=0;
        calib_data.ocam_model.e=0;
    end
    int_par=[calib_data.ocam_model.c,calib_data.ocam_model.d,calib_data.ocam_model.e,calib_data.ocam_model.xc,calib_data.ocam_model.yc];
    M=[calib_data.Xt,calib_data.Yt,zeros(size(calib_data.Xt))]; %Coordinate assolute 3D dei punti di calibrazione nel riferimento della scacchiera
    fprintf(1,'Optimizing chessboard pose ');
    for i=calib_data.ima_proc
        fprintf(1,'%d,  ',i);
        R=calib_data.RRfin(:,:,i);
        R(:,3)=cross(R(:,1),R(:,2));
        r=rodrigues(R);
        t=calib_data.RRfin(:,3,i);
        x0=[r(1),r(2),r(3),t(1),t(2),t(3)]; %condizione iniziale
        [x0,resnorm,residual,exitflag,output] =lsqnonlin(@prova,x0,-inf*ones(size(x0)),inf*ones(size(x0)),options,calib_data.ocam_model.ss,int_par,calib_data.Xp_abs(:,:,i), calib_data.Yp_abs(:,:,i),M,calib_data.ocam_model.width,calib_data.ocam_model.height);
        RRfinOpt(:,:,i)=rodrigues(x0(1:3));
        RRfinOpt(:,3,i)=x0(4:6)';
    end
    
    calib_data.RRfin=RRfinOpt;
    
    
    fprintf(1,'\nStarting refinement of INTRINSIC parameters...\n');
    
    ss0=calib_data.ocam_model.ss;
    
    
    options=optimset('Display','off',...
        'LargeScale','off', ...
        'TolX',1e-4,...
        'TolFun',1e-4,...
        'DerivativeCheck','off',...
        'Diagnostics','off',...
        'Jacobian','off',...
        'JacobMult',[],... % JacobMult set to [] by default
        'JacobPattern','sparse(ones(Jrows,Jcols))',...
        'MaxFunEvals','100*numberOfVariables',...
        'DiffMaxChange',1e-1,...
        'DiffMinChange',1e-8,...
        'PrecondBandWidth',0,...
        'TypicalX','ones(numberOfVariables,1)',...
        'MaxPCGIter','max(1,floor(numberOfVariables/2))', ...
        'TolPCG',0.1,...
        'MaxIter',10000,...
        'Algorithm','levenberg-marquardt');
    
    
    f0=[1,1,calib_data.ocam_model.c,calib_data.ocam_model.d,calib_data.ocam_model.e,ones(1,size(calib_data.ocam_model.ss,1))];
    lb=[0,0,0,-1,-1,zeros(1,size(calib_data.ocam_model.ss,1))];
    ub=[2,2,2,1,1,2*ones(1,size(calib_data.ocam_model.ss,1))];
    [ssout,resnorm,residual,exitflag,output] =lsqnonlin(@prova3,f0,-inf*ones(length(f0),1),inf*ones(length(f0),1),options,calib_data.ocam_model.xc,calib_data.ocam_model.yc,ss0,calib_data.RRfin,calib_data.ima_proc,calib_data.Xp_abs,calib_data.Yp_abs,M, calib_data.ocam_model.width, calib_data.ocam_model.height);
    calib_data.ocam_model.ss=ss0.*ssout(6:end)';
    calib_data.ocam_model.xc=calib_data.ocam_model.xc*ssout(1);
    calib_data.ocam_model.yc=calib_data.ocam_model.yc*ssout(2);
    calib_data.ocam_model.c=ssout(3);
    calib_data.ocam_model.d=ssout(4);
    calib_data.ocam_model.e=ssout(5);
    
    [err,stderr,MSE] = reprojectpoints_quiet(calib_data.ocam_model, calib_data.RRfin, calib_data.ima_proc, calib_data.Xp_abs, calib_data.Yp_abs, M);
    fprintf(1,'Sum of squared errors:  %f\n',MSE);
    MSE_old = MSE_new;
    
end

if get(gcf,'CurrentChar') == 13
    fprintf(1,'\n\nCamera model refinement interrupted');
else
    fprintf(1,'\n\nCamera model optimized');
end
[err,stderr,MSE] = reprojectpoints_adv(calib_data.ocam_model, calib_data.RRfin, calib_data.ima_proc, calib_data.Xp_abs, calib_data.Yp_abs, M);
ss = calib_data.ocam_model.ss;
ss



