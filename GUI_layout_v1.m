function varargout = GUI_layout_v1(varargin)
%GUI_LAYOUT_V1 MATLAB code file for GUI_layout_v1.fig
%      GUI_LAYOUT_V1, by itself, creates a new GUI_LAYOUT_V1 or raises the existing
%      singleton*.
%
%      H = GUI_LAYOUT_V1 returns the handle to a new GUI_LAYOUT_V1 or the handle to
%      the existing singleton*.
%
%      GUI_LAYOUT_V1('Property','Value',...) creates a new GUI_LAYOUT_V1 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to GUI_layout_v1_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      GUI_LAYOUT_V1('CALLBACK') and GUI_LAYOUT_V1('CALLBACK',hObject,...) call the
%      local function named CALLBACK in GUI_LAYOUT_V1.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_layout_v1

% Last Modified by GUIDE v2.5 06-Apr-2018 00:50:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_layout_v1_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_layout_v1_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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


% --- Executes just before GUI_layout_v1 is made visible.
function GUI_layout_v1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

fig = gcf; % current figure handle
fig.Color = [1 1 1];

% Set up the GUI details
addpath('/Volumes/GoogleDrive/My Drive/functions')

set(handles.PathForModelPred, 'String', 'Browse Model Predictions file')
set(handles.PathForMeasurements, 'String', 'Browse Measurements file')
set(handles.PathForUncertainty, 'String', 'Browse Uncertainties file')

set(handles.BrosweForModelPred, 'string', 'Browse')
set(handles.BrowseForMeasurements, 'string', 'Browse')
set(handles.BrowseForUncertainty, 'string', 'Browse')
set(handles.PopUpSensorUnc,'string','Select a sensor')

List{1}='Select interpretation methodology';
List{2}='EDMF';
List{3}='BMU';
List{4}='Res Min';
set(handles.SysIdMethod, 'String', List)

% Choose default command line output for GUI_layout_v1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_layout_v1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_layout_v1_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in BrowseForMeasurements.
function BrowseForMeasurements_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseForMeasurements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('*.xls');
set(handles.PathForMeasurements, 'String', [path, '/', file])
Measurements=xlsread([path, '/', file]);
handles.Measurements=Measurements;
handles.NumSensors=max(size(Measurements));
List{1}='Select sensor for uncertainty plot';
for i= 2:handles.NumSensors+1
    List{i}=['Sensor_', num2str(i-1)];
end
set(handles.PopUpSensorUnc, 'String', List)
guidata(hObject, handles);


% --- Executes on button press in BrowseForUncertainty.
function BrowseForUncertainty_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseForUncertainty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('*.xls');
set(handles.PathForUncertainty, 'String', [path, '/', file])
% Read uncertainty file
for i=1:handles.NumSensors
    UncertaintyInSensor{i}=xlsread([path, '/', file], ['Sheet',num2str(i)]);
    CombinedUncertainty{i}=random('normal', UncertaintyInSensor{i}(1,1), UncertaintyInSensor{i}(1,2), 1E4, 1);
end
handles.UncertaintyInSensor=CombinedUncertainty;
guidata(hObject, handles);

% --- Executes on selection change in PopUpSensorUnc.
function PopUpSensorUnc_Callback(hObject, eventdata, handles)
% hObject    handle to PopUpSensorUnc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopUpSensorUnc contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopUpSensorUnc
handles.PlotDataForSensor=get(hObject,'Value');
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function PopUpSensorUnc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopUpSensorUnc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SysIdMethod.
function SysIdMethod_Callback(hObject, eventdata, handles)
% hObject    handle to SysIdMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SysIdMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SysIdMethod
% Proceed with EDMF
handles.MethodSelected=get(hObject,'Value');
guidata(hObject, handles)



% --- Executes during object creation, after setting all properties.
function SysIdMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SysIdMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in BrosweForModelPred.
function BrosweForModelPred_Callback(hObject, eventdata, handles)
% hObject    handle to BrosweForModelPred (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile('*.xls');
set(handles.PathForModelPred, 'String', [path, '/', file])
handles.ModelPred=xlsread([path, '/', file]);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function PathForModelPred_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PathForModelPred (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in SaveHandles.
function SaveHandles_Callback(hObject, eventdata, handles)
% hObject    handle to SaveHandles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save('DataGenerated.mat','handles')


% --- Executes on button press in PlotUncForSensor.
function PlotUncForSensor_Callback(hObject, eventdata, handles)
% hObject    handle to PlotUncForSensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if 1<=handles.PlotDataForSensor<=handles.NumSensors
    i=handles.PlotDataForSensor;
    figure()
    histogram(handles.UncertaintyInSensor{i})
else
    figure()
end


% --- Executes on button press in PlotCM.
function PlotCM_Callback(hObject, eventdata, handles)
% hObject    handle to PlotCM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.MethodSelected==2
    figure()
    plot(handles.CMset(:,1), handles.CMset(:,2), 'b.')
else
    msgbox('Select method first')
end

% --- Executes on button press in InterpretData.
function InterpretData_Callback(hObject, eventdata, handles)
% hObject    handle to InterpretData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Model_Resp=handles.ModelPred(:,end-handles.NumSensors+1:end);
Parameters=handles.ModelPred(:,1:end-handles.NumSensors);
Measurements=handles.Measurements;
if handles.MethodSelected==2
    for i=1:handles.NumSensors
        [Tlow(i), Thigh(i)]= f_getThres(handles.UncertaintyInSensor{i}, 0.95^(1/handles.NumSensors), 1E3);
    end
    residual=Model_Resp-repmat(Measurements,[size(Model_Resp,1),1]);
    EDMF_logical = f_EDMF(residual,Tlow,Thigh);
    EDMF_logical= sortrows([EDMF_logical Parameters residual],-1);
    CM=EDMF_logical(EDMF_logical(:,1)==1,2:end);
    CM=CM(:,1:size(Parameters, 2));
    handles.CMset=CM;
    guidata(hObject, handles)
else handles.MethodSelected==1
    %     figure()
    %     plot(handles.CMset(:,1), handles.CMset(:,2), 'r.')
    msgbox('Select method first')
    
end
