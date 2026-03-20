%
% EKVFIT Attempts to fit a simplified EKV model to (VG, ISAT) pairs.
%    EKVFIT(VG, ISAT, EPSILON) attempts to fit a simplified EKV model for
%    the saturation region of MOS transistor operation to measured values
%    of gate voltage (specified in VG) and channel current (specified in
%    ISAT).  The assumed form of the model is
%
%        ISAT = Is * (log(1 + exp(kappa*(VG - VT)/(2*0.0258)))).^2
%
%    The return values are [Is, VT, kappa].  EKVFIT makes use of LINEFIT.
%    First, it attempts to find parameters for the weak-inversion region by
%    using LINEFIT on VG and log(ISAT).  Then, it attepts to find
%    parameters for the strong-inversion region by using LINEFIT on VG and
%    sqrt(ISAT).  It then uses the x-axis intercept from the
%    strong-inversion fit as a starting value for VT and computes a
%    starting value for IS via cubic-spline interpolation as twice the
%    value of ISAT when VG = VT.  EKVFIT then attepts to find a the value
%    of IS in the interval between one tenth the initial value of IS and
%    ten times the inital value of IS that minimizes the curvature of the
%    inverse EKV model applied to ISAT, given by
%
%                     log(exp(sqrt(ISAT/Is)) - 1),
%
%    when plotted as a function of VG, using the golden-section search.
%    Once the best value of Is is found, EKVFIT uses LINEFIT to get the
%    slope and intercept of the best-fit line to the EKV model inverse
%    expression, given above, applied to ISAT versus VG.  The slope of this
%    curve should be kappa/(2*UT) and the VG-axis intercept should be VT.
%
%    See the LINEFIT help comment for an explanation of the EPSILON 
%    parameter.
%
function [Is, VT, kappa]=ekvfit(Vg, Isat, epsilon, varargin)

if nargin==3,
    plotting = 'off';
else
    plotting = varargin(1);
end

Is = 0;
VT = 0;
kappa = 0;

[WIfirst, WIlast, WIm, WIb, WIN]=linefit(Vg, log(Isat), epsilon);
if WIN==0
    error('Could not find a weak-inversion region.');
elseif strcmp(plotting, 'on')==1
    semilogy(Vg, Isat);
    temp = axis;
    semilogy(Vg, Isat, 'b.', Vg(WIfirst:WIlast), Isat(WIfirst:WIlast), 'r.', Vg, exp(WIm*Vg + WIb), 'k-');
    axis(temp);
    xlabel('{\it V}_G (V)');
    ylabel('{\it I}_{sat} (A)');
    title('Weak-Inversion Fit');
    pause;
end
if min(abs(Isat(WIfirst:WIlast)))>1e-6
    error('Identified a candidate weak-inversion region, but all current levels exceed typical weak-inversion currents.');
end
if max(abs(Isat(WIfirst:WIlast)))>1e-6
    warning('Identified a candidate weak-inversion region, but some current levels exceed typical weak-inversion currents.');
end

[SIfirst, SIlast, SIm, SIb, SIN]=linefit(Vg, sqrt(Isat), epsilon);
if SIN==0
    error('Could not find a strong-inversion region.');
elseif strcmp(plotting, 'on')==1
    plot(Vg, sqrt(abs(Isat)));
    temp = axis;
    plot(Vg, sqrt(abs(Isat)), 'b.', Vg(SIfirst:SIlast), sqrt(Isat(SIfirst:SIlast)), 'r.', Vg, SIm*Vg + SIb, 'k-');
    axis(temp);
    xlabel('{\it V}_G (V)');
    ylabel('{\it I}^{1/2}_{sat} (A^{1/2})');
    title('Strong-Inversion Fit');
    pause;
end
if max(abs(Isat(SIfirst:SIlast)))<0.1e-6
    error('Identified a candidate strong-inversion region, but all current levels are lower than typical strong-inversion currents.');
end
if min(abs(Isat(SIfirst:SIlast)))<0.1e-6
    warning('Identified a candidate strong-inversion region, but some current levels are lower than typical strong-inversion currents.');
end

if SIfirst>WIlast
    first = WIfirst;
    last = SIlast;
elseif WIfirst>SIlast
    first = SIfirst;
    last = WIlast;
else
    error('Weak-inversion and strong-inversion regions found were not disjoint.');
end

VT=-SIb/SIm;
Is=2*spline(Vg(first:last), Isat(first:last), VT);

R=0.61803399;
C=1.-R;
tol=1e-4;

x0=0.1*Is;
x1=Is;
x2=(1.+9.*C)*Is;
x3=10.*Is;

dVg=diff(Vg(first:last));
temp=diff(log(exp(sqrt(Isat(first:last)/x1))-1))./dVg;
f1=std(temp)/mean(temp);
temp=diff(log(exp(sqrt(Isat(first:last)/x2))-1))./dVg;
f2=std(temp)/mean(temp);

while abs(x3-x0)>tol*(abs(x1)+abs(x2)),
    if f2<f1,
        x0=x1; x1=x2; x2=R*x1+C*x3;
        f1=f2;
        temp=diff(log(exp(sqrt(Isat(first:last)/x2))-1))./dVg;
        f2=std(temp)/mean(temp);
        if strcmp(plotting, 'on')==1
            [EKVfirst, EKVlast, m, b, N]=linefit(Vg(first:last), log(exp(sqrt(Isat(first:last)/x2))-1), epsilon);
            plot(Vg(first:last), log(exp(sqrt(Isat(first:last)/x2))-1), 'b.', Vg(first:last), m*Vg(first:last)+b, 'k-');
            xlabel('{\it V}_G (V)');
            ylabel('log(exp(sqrt({\it I}_{sat}/{\it I}_s))-1)');
            title(['Optimizing Specific Current: {\it I}_s = ', num2str(x2), 'A']);
            pause;
        end
    else
        x3=x2; x2=x1; x1=R*x2+C*x0;
        f2=f1;
        temp=diff(log(exp(sqrt(Isat(first:last)/x1))-1))./dVg;
        f1=std(temp)/mean(temp);
        if strcmp(plotting, 'on')==1
            [EKVfirst, EKVlast, m, b, N]=linefit(Vg(first:last), log(exp(sqrt(Isat(first:last)/x1))-1), epsilon);
            plot(Vg(first:last), log(exp(sqrt(Isat(first:last)/x1))-1), 'b.', Vg(first:last), m*Vg(first:last)+b, 'k-');
            xlabel('{\it V}_G (V)');
            ylabel('log(exp(sqrt({\it I}_{sat}/{\it I}_s))-1)');
            title(['Optimizing Specific Current: {\it I}_s = ', num2str(x1), 'A']);
            pause;
        end
    end
end

if f1<f2,
    Is=x1;
else
    Is=x2;
end

[EKVfirst, EKVlast, m, b, N]=linefit(Vg(first:last), log(exp(sqrt(Isat(first:last)/Is))-1), epsilon);
VT=-b/m;
kappa=2*m*0.0258;
if strcmp(plotting, 'on')==1
    semilogy(Vg, Isat);
    temp = axis;
    semilogy(Vg, Isat, 'b.', Vg(first:last), Isat(first:last), 'r.', Vg, Is*(log(1+exp(kappa*(Vg-VT)/(2*0.0258)))).^2, 'k-');
    axis(temp);
    xlabel('{\it V}_G (V)');
    ylabel('{\it I}_{sat} (A)');
    title(['EKV Fit: {\it I}_s = ', num2str(Is), 'A, {\it V}_T = ', num2str(VT), 'V, \kappa = ', num2str(kappa)]);
    pause;
    plot(Vg, sqrt(abs(Isat)));
    temp = axis;
    plot(Vg, sqrt(abs(Isat)), 'b.', Vg(first:last), sqrt(Isat(first:last)), 'r.', Vg, sqrt(Is*(log(1+exp(kappa*(Vg-VT)/(2*0.0258)))).^2), 'k-');
    axis(temp);
    xlabel('{\it V}_G (V)');
    ylabel('{\it I}^{1/2}_{sat} (A^{1/2})');
    title(['EKV Fit: {\it I}_s = ', num2str(Is), 'A, {\it V}_T = ', num2str(VT), 'V, \kappa = ', num2str(kappa)]);
    pause;
end
