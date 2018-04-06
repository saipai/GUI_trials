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

% Last Modified by GUIDE v2.5 26-Mar-2018 14:24:57
addpath('\\imacnas2\DataServer\EDMF_GUI_folder\')

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

% Set up the GUI details
set(handles.PathForModelPred, 'String', 'Browse Model Predictions file')
set(handles.PathForMeasurements, 'String', 'Browse Measurements file')
set(handles.PathForUncertainty, 'String', 'Browse Uncertainties file')

set(handles.BrosweForModelPred, 'string', 'Browse')
set(handles.BrowseForMeasurements, 'string', 'Browse')
set(handles.BrowseForUncertainty, 'string', 'Browse')

List{1}='EDMF';
List{2}='BMU';
List{3}='Res Min';
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
for i= 1:handles.NumSensors
    List{i}=['Sensor_', num2str(i)];
end
set(handles.PopUpSensorUnc, 'String', List)
guidata(hObject, handles);


% --- Executes on button press in BrowseForUncertainty.
function BrowseForUncertainty_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseForUncertainty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Edited by YR on APR04
[file,path] = uigetfile('*.xls');
set(handles.PathForUncertainty, 'String', [path, '/', file])
% Read uncertainty file

[~,SheetsInXLS,~] = xlsfinfo(handles.PathForUncertainty.String);
numUncSensors = length(SheetsInXLS);
if (numUncSensors ~= 1) && (numUncSensors ~= handles.NumSensors)
    error('Number of Uncertainty definitions not correct')
end

CombinedUncertainty = cell(1,handles.NumSensors);
if (numUncSensors == handles.NumSensors)
    for i=1:handles.NumSensors
        [UncertaintyInSensor{i},UncertaintyTypeInSensor{i}]=xlsread([path, '/', file], ['Sheet',num2str(i)]);
        numUncSources = size(UncertaintyInSensor{i},1);
        InstUncComb = 1E4;
        UncVals = zeros(InstUncComb,numUncSources);
        for j = 1:numUncSources
            if strcmpi('normal',UncertaintyTypeInSensor{i}(1,2))
            UncVals(:,j)=random('Normal',UncertaintyInSensor{i}(1,1),UncertaintyInSensor{i}(1,2),InstUncComb,1);
            elseif strcmpi('uniform',UncertaintyTypeInSensor{i}(1,2))
                UncVals(:,j)=random('Uniform',UncertaintyInSensor{i}(1,1),UncertaintyInSensor{i}(1,2),InstUncComb,1);
            else
                error('Wrong Type of Uncertainty -- accepted types are ''uniform'' and ''normal'' ')
            end
                
            if strcmp(UncertaintyTypeInSensor{i}(1,2),'Relative')
                UncVals(:,j) = (1+UncVals(:,j)).*handles.Measurements(j);
            end
        end
        CombinedUncertainty{i}=sum(UncVals,2);
    end
else
    [UncertaintyInSensor{1},UncertaintyTypeInSensor{1}]=xlsread([path, '/', file], 'Sheet1');
    numUncSources = length(UncertaintyInSensor{1});
    InstUncComb = 1E4;
    UncVals = zeros(InstUncComb,numUncSources);
    for j = 1:numUncSources
        UncVals(:,j)=random(UncertaintyTypeInSensor{1}(1,2),UncertaintyInSensor{1}(1,1),UncertaintyInSensor{1}(1,2),InstUncComb,1);
        if strcmp(UncertaintyTypeInSensor{1}(1,2),'Relative')
            UncVals(:,j) = (1+UncVals(:,j)).*handles.Measurements(j);
        end
    end
    for i = 1:handles.NumSensors
    CombinedUncertainty{i}=sum(UncVals,2);
    end
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
addpath('/Volumes/GoogleDrive/My Drive/functions')
Model_Resp=handles.ModelPred(:,end-handles.NumSensors+1:end);
Parameters=handles.ModelPred(:,1:end-handles.NumSensors);
Measurements=handles.Measurements;
Tlow = zeros(1,length(Measurements));
Thigh = zeros(1,length(Measurements));
for i=1:handles.NumSensors
    [Tlow(i), Thigh(i)]= f_getThres(handles.UncertaintyInSensor{i}, 0.95^(1/handles.NumSensors), 1E3);
end
handles.Tvals = [Tlow ;Thigh];
residual=Model_Resp-repmat(Measurements,[size(Model_Resp,1),1]);
EDMF_logical = f_EDMF(residual,Tlow,Thigh);
handles.CMindexes = EDMF_logical;
EDMF_logical= sortrows([EDMF_logical Parameters residual],-1);
CM=EDMF_logical(EDMF_logical(:,1)==1,2:end);
CM=CM(:,1:size(Parameters, 2));
handles.CMset=CM;
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
     
    figure()
    plot(randperm(length(handles.ModelPred(:,i)),sum(abs(handles.CMindexes-1))),handles.ModelPred((handles.CMindexes==0),end-handles.NumSensors+i),'r.') %#ok<*FNDSB>
    hold on
    plot(randperm(length(handles.ModelPred(:,i)),sum(handles.CMindexes)),handles.ModelPred((handles.CMindexes==1),end-handles.NumSensors+i),'g.')
    
    UNCvalues = handles.UncertaintyInSensor{i} + handles.Measurements(i);
    
    %GetExtremeValuesForPlot
  
    if min(UNCvalues) < 0
        MINPLOTVALUEunc = 1.1*min(UNCvalues);
    else
        MINPLOTVALUEunc = 0.9*min(UNCvalues);
    end
    
    if max(UNCvalues) < 0
        MAXPLOTVALUEunc = 0.9*max(UNCvalues);
    else
        MAXPLOTVALUEunc = 1.1*max(UNCvalues);
    end
    
    plot(1.05*length(handles.ModelPred).*ones(1,2),[MINPLOTVALUEunc MAXPLOTVALUEunc],'k-')
    UncPlotEdges = linspace(MINPLOTVALUEunc,MAXPLOTVALUEunc,68);
    [UncDist,UncPlotEdges] = histcounts(UNCvalues,UncPlotEdges,'Normalization','pdf');
    plot(1.05*length(handles.ModelPred)+UncDist./max(UncDist).*0.1.*length(handles.ModelPred),...
        UncPlotEdges(1:end-1)+0.5*(UncPlotEdges(2)-UncPlotEdges(1)),'b-')
    plot([0 1.05*length(handles.ModelPred)],handles.Measurements(i).*ones(1,2),'c--','LineWidth',2)
    plot([0 1.05*length(handles.ModelPred)],handles.Measurements(i).*ones(1,2)+handles.Tvals(1,i),'k--','LineWidth',2)
    plot([0 1.05*length(handles.ModelPred)],handles.Measurements(i).*ones(1,2)+handles.Tvals(2,i),'k--','LineWidth',2)
    
    title(['EDMF for Sensor #',num2str(i)])
    xlabel('Model Instances')
    ylabel('Measurement / Model prediction')
    legend('Falsified MI','Candidate MI')
       
else
    figure()
end


% --- Executes on button press in PlotCM.
function PlotCM_Callback(hObject, eventdata, handles)
% hObject    handle to PlotCM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.MethodSelected==1
    figure()
    plot(handles.CMset(:,1), handles.CMset(:,2), 'b.')
    
else
    figure()
end