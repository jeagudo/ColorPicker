function varargout = ColorPicker(varargin)
% COLORPICKER M-file for ColorPicker.fig
%      COLORPICKER, by itself, creates a new COLORPICKER or raises the existing
%      singleton*.
%
%      H = COLORPICKER returns the handle to a new COLORPICKER or the handle to
%      the existing singleton*.
%
%      COLORPICKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COLORPICKER.M with the given input arguments.
%
%      COLORPICKER('Property','Value',...) creates a new COLORPICKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ColorPicker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ColorPicker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ColorPicker

% Last Modified by GUIDE v2.5 31-Jan-2014 13:35:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ColorPicker_OpeningFcn, ...
                   'gui_OutputFcn',  @ColorPicker_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before ColorPicker is made visible.
function ColorPicker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ColorPicker (see VARARGIN)

% Choose default command line output for ColorPicker
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using ColorPicker.
if strcmp(get(hObject,'Visible'),'off')
    %Show CIE1931 image at start
    axes(handles.axes1);
    CIE=imread('CIExy1931_sRGB.png');
   imshow(CIE);
   
end

% UIWAIT makes ColorPicker wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ColorPicker_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;
%Select showed image depending on popup menu
popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
        %Show CIE1931
        imshow('CIExy1931_sRGB.png');
    case 2
        %Show CIE L* a* b*
        imshow('CieLab.png');
    case 3
        %Show uncorrected color image
        imshow('GuadianaEnBadajoz.tif');
    case 4
        %Show corrected color image
        A=imread('GuadianaEnBadajoz.tif');
        P = iccread('GuadianaEnBadajoz.tif');
        Q = iccread('sRGB Color Space Profile.icm');
        R = makecform('icc', P, Q);
        CorrectedImage = applycform(A,R);
        imshow(CorrectedImage);
        

end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'CIE 1931', 'CIE Lab','Color Management Test', 'Color Management Test'});


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Show information message and disable button
set(handles.text22,'String','wait...measuring');
set(handles.pushbutton4,'Enable','off');

% Measure sample
RGBpicked=SingleMeasurement(3);

%Load calibration data and transformation matrix
load 'CalibrationData.mat';
load M.mat;

load RGB.txt;

RGBt=RGB';

%Fix Starting and End white point
WPE = whitepoint('d65');
WPS=[97.37,100,118.29];

%Define several color transformations
D = makecform('adapt', 'WhiteStart', WPS, 'WhiteEnd', WPE, 'AdaptModel', 'Bradford');%White adapt transform

E= makecform('xyz2lab','WhitePoint', WPE); % Tristimulus to Lab transform

C= makecform('lab2srgb','AdaptedWhitePoint', WPE); % Lab to sRGB transform

%Define white patch of color checker
RGBwhite=[0.9427 0.9406 0.9276];

%Normalize RGBpicked values
RGBpicked(1)=RGBpicked(1)./RGBt(1,19).*RGBwhite(1);
RGBpicked(2)=RGBpicked(2)./RGBt(2,19).*RGBwhite(2);
RGBpicked(3)=RGBpicked(3)./RGBt(3,19).*RGBwhite(3);

%Tranform to tristimulus
XYZpicked=M*RGBpicked';

%Unadapted cromaticity coordinates
xa=XYZpicked(1)./(XYZpicked(1)+XYZpicked(2)+XYZpicked(3));
ya=XYZpicked(2)./(XYZpicked(1)+XYZpicked(2)+XYZpicked(3));

%White adaptation transform
XYZd65=applycform(XYZpicked',D);

%White adapted cromaticity coordinates
x=XYZd65(1)./(XYZd65(1)+XYZd65(2)+XYZd65(3));
y=XYZd65(2)./(XYZd65(1)+XYZd65(2)+XYZd65(3));

%Transform to CIE Lab
Lab=applycform(XYZd65,E);

%Transform to sRGB
sRGB=applycform(Lab,C);

%Update labels values

set(handles.text17,'String',fix(sRGB(1)*255));
set(handles.text18,'String',fix(sRGB(2)*255));
set(handles.text19,'String',fix(sRGB(3)*255));

set(handles.text11,'String',sprintf('%4.3f',x));
set(handles.text12,'String',sprintf('%4.3f',y));
set(handles.text13,'String',sprintf('%4.1f',XYZd65(2)*100));
set(handles.text14,'String',sprintf('%4.1f',Lab(1)));
set(handles.text15,'String',sprintf('%4.2f',Lab(2)));
set(handles.text16,'String',sprintf('%4.2f',Lab(3)));

%Check showed graph
popup_sel_index = get(handles.popupmenu1, 'Value');

%If graph is CIE 1931
if popup_sel_index==1
    
CIE=imread('CIExy1931_sRGB.png');
posX=fix(54+x*583.75);
posY=fix(548-y*584.44);

for i=posX:(posX+5)
    for j=posY:(posY+5)
CIE(j,i,:)=[0 0 0];
    end
end

axes(handles.axes1);
cla;

imshow(CIE);

elseif popup_sel_index==2
%If graph is CIE Lab 
CIELAB=imread('CieLab.png');

posX=fix(320+Lab(2)*4);
posY=fix(302-Lab(3)*4);

for i=posX:(posX+5)
    for j=posY:(posY+5)
CIELAB(j,i,:)=[0 0 0];
    end
end

axes(handles.axes1);
cla;

imshow(CIELAB);
end
%Draw patch pf picked color
axes(handles.axes2);
patch([0 1 1 0],[0 0 1 1],[(sRGB(1)*1.0) (sRGB(2)*1.0) (sRGB(3)*1.0)]);

%Check if Export to ACO is marked
checkStatus = get(handles.checkbox1, 'value');

%Save .aco file
if checkStatus
    cadena=get(handles.edit1,'String');
    nombre = [cadena '.aco'];
    fid = fopen(nombre, 'w');
    Array=zeros(7);
    Array(1)=0; %version
    Array(2)=1; %Number of color (always 1)
    Array(3)=7; %Color Space (Lab)
    Array(4)=Lab(1)*100;
    Array(5)=Lab(2)*100;
    Array(6)=Lab(3)*100;
    Array(7)=0;

    fwrite(fid, Array, 'int16','b');
    fclose(fid);
end

%Update information label and enable button
set(handles.text22,'String','done...ready');
set(handles.pushbutton4,'Enable','on');

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton4.
function pushbutton4_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over checkbox1.
function checkbox1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(checkbox1, value) ==1
    set(handles.text20,'Visible','on');
    set(handles.text21,'Visible','on');
    set(handles.edit1,'Visible','on');
else
    set(handles.text20,'Visible','off');
    set(handles.text21,'Visible','off');
    set(handles.edit1,'Visible','off');
end
