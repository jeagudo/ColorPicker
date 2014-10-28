%Calibration Real color picker

clear all

%Load measured RGB values of Color Checker
RGB2=load('RGB.txt');

%Traspose and change variable name
RGB=RGB2';

%Load calibration parameters for ColorCheker (Reflectance, Light Source Spectra, Standard Observer)
load 'CalibrationData.mat';

%Fix spectral range and width
lambda=[380:5:780];

%Normalize light source spectra
Fuentes(:,1) = Fuentes(:,1).*100./(683.*5.*sum(Fuentes(:,1).*Observador(:,3)));

%Calculate tristimulus value of source 
[Xtris]= Fuentes(:,1).*Observador(:,2);
SumaX = 683 * 5* sum (Xtris);
[Ytris]= Fuentes(:,1).*Observador(:,3);
SumaY = 683 * 5* sum (Ytris);
[Ztris]= Fuentes(:,1).*Observador(:,4);
SumaZ = 683 * 5* sum (Ztris);
Blanco(1,:) = [SumaX SumaY SumaZ];

%Calculate chromaticity coodinates of white
xw(1)=SumaX./(SumaX+SumaY+SumaZ);
yw(1)=SumaY./(SumaX+SumaY+SumaZ);

%Calculate tristimulus value of 24 chromatic samples of ColocChecker
for n=1:24
    
    [Triestimulos(:,n,1)] =Fuentes(:,1).*Reflectancias(:,n).*Observador(:,2);
    X(n) = 683 * 5* sum (Triestimulos(:,n,1));
    [Triestimulos(:,n,2)]= Fuentes(:,1).*Reflectancias(:,n).*Observador(:,3);
    Y(n) = 683 * 5* sum (Triestimulos(:,n,2));
    [Triestimulos(:,n,3)]=Fuentes(:,1).*Reflectancias(:,n).*Observador(:,4);
    Z(n) = 683 * 5* sum (Triestimulos(:,n,3));
    x(n)=X(n)./(X(n)+Y(n)+Z(n));
    y(n)=Y(n)./(X(n)+Y(n)+Z(n));
   
    XYZ(n,1,:)=[X(n) Y(n) Z(n)];
         
end


%Change of name and number of dimensions
xyz(:,:)=XYZ(:,1,:);

%Relative RGB reflectance of ColorChecker white patch 
RGBwhite=[0.9427 0.9406 0.9276];

%Normalice measured RGB values
RGB(1,:)=RGB(1,:)./RGB(1,19).*RGBwhite(1);
RGB(2,:)=RGB(2,:)./RGB(2,19).*RGBwhite(2);
RGB(3,:)=RGB(3,:)./RGB(3,19).*RGBwhite(3);

%Calculate transformation matrix through a pseudoinverse method
M=xyz'*pinv(RGB);

%Save calibration matrix
save ('M.mat','M');


