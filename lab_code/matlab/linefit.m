%
% LINEFIT Fits tries to fit a line to an appropriate part of a given curve.
%    LINEFIT(X, Y, EPSILON) steps through the curve specified by vectors
%    X and Y searching for a consecutive run of at least 10 coordinate
%    pairs to which a straight line can be fit using linear regression with
%    an R^2 (i.e., goodness of fit) value of greater than 1-EPSILON.  If
%    there are more than one such run of points, the one with the steepest
%    slope is used.  A typical value for EPSILON is in the range of 5e-4 to
%    5e-3.  The return values are [FIRST, LAST, MMAX, BMAX, NMAX], where
%
%        FIRST is the index of the first point used in the fit,
%        LAST is the index of the last point used in the fit,
%        MMAX is the slope of the best fit line,
%        BMAX is the y-axis intercept of the best-fit line, and
%        NMAX is the number of points used in the fit.
function [first, last, mmax, bmax, Nmax]=linefit(x, y, epsilon)

first=0;
last=0;
mmax=0;
bmax=0;
Nmax=0;

i=1;
while i<length(x),
    R2=1;
    N=1;
    sumX=x(i);
    sumX2=x(i)*x(i);
    sumY=y(i);
    sumY2=y(i)*y(i);
    sumXY=x(i)*y(i);
    j=i;
    while (j<length(x)) & (R2>1-epsilon),
        j=j+1;
        N=N+1;
        sumX=sumX+x(j);
        sumX2=sumX2+x(j)*x(j);
        sumY=sumY+y(j);
        sumY2=sumY2+y(j)*y(j);
        sumXY=sumXY+x(j)*y(j);
        SXX=sumX2-sumX*sumX/N;
        SYY=sumY2-sumY*sumY/N;
        SXY=sumXY-sumX*sumY/N;
        m=SXY/SXX;
        b=(sumY-m*sumX)/N;
        R2=SXY*SXY/(SXX*SYY);
    end
    if ((N>10) & (abs(m)>abs(mmax))),
        first=i;
        last=j;
        mmax=m;
        bmax=b;
        Nmax=N;
    end
    i=j;
end
