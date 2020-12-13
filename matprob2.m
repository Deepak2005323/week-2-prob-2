function sldemo_clutchplot(Action)
FigHandle=findobj(allchild(0),'flat','Tag','OverlayFigure');
FigPlotHandle=findobj(allchild(0),'flat','Tag','OverlayPlotFigure');
if nargin
  Data=get(FigHandle,'UserData');  
  switch Action  
    case 'Close'
      close(FigPlotHandle)
      delete(FigHandle)      
    case 'Plot'
      LocalPlot(Data,FigPlotHandle) 
    case 'Start'
      if ~isempty(FigHandle)    
        set(Data.Handles,'Enable','off');    
      end         
    case 'Stop'
      if ~isempty(FigHandle)   
        figure(FigHandle)        
        set(Data.Handles,'Enable','on');    
        LocalPlot(Data,FigPlotHandle) 
      else
        LocalInitFig(FigHandle)
      end 
      otherwise   
      LocalInitFig(FigHandle)   
  end 
else
  LocalInitFig(FigHandle);
end 
function LocalPlot(Data,FigPlotHandle)

LineStyleOrder={'-';'--';':';'-.'};
LineW=2;  
ColorOrder='rgbymc';
Value=get(Data.Handles,{'Value'});
CheckList = Value;
Value=find([Value{:}]);
Vars=evalin('base','whos(''sldemo_clutch_output'')');
FigPlotOpen=~isempty(FigPlotHandle);
if ~isempty(Vars) && ~isempty(Value)   
  if ~FigPlotOpen
    FigPlotHandle=figure('Tag','OverlayPlotFigure', ...
                         'Name','Clutch demo Input and Output Plots'  ...
                        );
  end
  figure(FigPlotHandle);
  cla
  AxesHandle=findobj(FigPlotHandle,'Type','axes');   
  LineIndex=1;
  ColorIndex=1;  
  String={};  
  PlotMe=[];
  for lp=1:10          
      if CheckList{lp}==1
          EvalStr = Data.Names{lp};
      switch EvalStr
          case 'Clutch Pedal'
              PlotMe = 'Fn';
          case 'Engine Torque'
              PlotMe = 'Tin';
          case 'we'
              PlotMe = 'EngineSpeed';
          case 'wv'
              PlotMe = 'VehicleSpeed';
          case 'w'
              PlotMe = 'ShaftSpeed';
          case 'Locked Flag'
              PlotMe = 'LockedFlag';
          case 'Lockup Flag'
              PlotMe = 'LockupFlag';
          case 'Break-Apart Flag'
              PlotMe = 'UnlockFlag';
          case 'FrictionTorque Required for Lockup'
              PlotMe = 'Tfmaxk';
          case 'Max Static Friction Torque'
              PlotMe = 'Tfmaxs';
      end 
      y_data=evalin('base',['sldemo_clutch_output.get(''', PlotMe ''')', '.Values.Data']);        
      x_data=evalin('base',['sldemo_clutch_output.get(''', PlotMe ''')', '.Values.Time']);        

      plot(x_data,y_data, ...
          'LineStyle',LineStyleOrder{LineIndex}, ...
          'LineWidth',LineW, ...            
          'Color',ColorOrder(ColorIndex))
    hold on
    grid on    
    String=[String {[' ' PlotMe '(' ...
            ColorOrder(ColorIndex) ...
            LineStyleOrder{LineIndex} ')']}]; 
    ColorIndex=ColorIndex+1;
    if ColorIndex>length(ColorOrder)
      LineIndex=LineIndex+1;
      ColorIndex=1;
    end
      end 
  end
  
  if length(Value)<5
    String=strcat(String{:});    
  elseif length(Value)<8
    String={strcat(String{1:4});strcat(String{5:end})};
  else
    String={strcat(String{1:4});strcat(String{5:7});strcat(String{8:end})};
  end    
  TtlHandle=title(String);
  set([FigPlotHandle,AxesHandle,TtlHandle],'Units','points');  
  AxesPos=get(AxesHandle,'Position');
  FigPos=get(FigPlotHandle,'Position');
  TtlExtent=get(TtlHandle,'Extent');
  TtlPos=get(TtlHandle,'Position');
  Offset=0;  
  if sum(AxesPos(1,[2 4]))+TtlExtent(4)+5>FigPos(4)
    Offset=FigPos(4)-TtlExtent(4)-sum(AxesPos(1,[2 4]))-5;
  end    
  AxesPos(4)=AxesPos(4)+Offset;
  TtlPos(2)=TtlPos(2)+Offset;
  set(AxesHandle,'Position',AxesPos);
  set(TtlHandle,'Position',TtlPos);
  set([FigPlotHandle,AxesHandle,TtlHandle],'Units','normalized');  
  xlabel('Time (sec.)')        
  axis([0 10 -.2 2.2]); 
  zoom on  
else 
  if FigPlotOpen 
    set(0,'CurrentFigure',FigPlotHandle);
    cla
    title('')    
  end
end 
function LocalInitFig(FigHandle)

FigOpen=~isempty(FigHandle);
if ~isempty(find_system(0,'flat','name','sldemo_clutch')) && ...
   strcmp(get_param('sldemo_clutch','Open'),'off')
  return
end
if isempty(find_system(0,'flat','name','sldemo_clutch'))
  sldemo_clutch
end  
if FigOpen
  figure(FigHandle)    
  return
end
ReturnChar=sprintf('\n');          
Name=find_system('sldemo_clutch','SearchDepth',1,'BlockType','Outport');
PortNumber = zeros(length(Name),1);
OutputName = cell(length(Name),1);
OutputHandles = zeros(length(Name),1);
for lp=1:length(Name)
  PortNumber(lp,1)=str2double(get_param(Name{lp},'Port'));
  OutputName{lp,1}=get_param(Name{lp},'Name');
  OutputName{lp,1}(OutputName{lp,1}==ReturnChar)=' ';      
  OutputHandles(lp,1)=get_param(Name{lp},'Handle');      
end
[Junk,SortIndex]=sort(PortNumber);
OutputName=OutputName(SortIndex);
OutputHandles=OutputHandles(SortIndex);      
OutputName=[{'Outputs'};OutputName];
TempInputName=find_system('sldemo_clutch'     , ...
                          'SearchDepth',1, ...
                          'BlockType'  ,'FromWorkspace');          
InputName = cell(length(TempInputName),1);
InputHandles = zeros(length(TempInputName),1);
for lp=1:length(TempInputName)
  InputName{lp,1}=get_param(TempInputName{lp},'Name');      
  InputName{lp,1}(InputName{lp,1}==ReturnChar)=' ';      
  InputHandles(lp,1)=get_param(TempInputName{lp},'Handle');      
end
InputName=[{'Inputs'};InputName];
Names=[InputName;OutputName];   
Offset=10; 
ButtonWidth=150;              ButtonHeight=20; 

FigWidth=2*Offset+ButtonWidth;

BtnPos = zeros(length(Names),4);
   
Ct=0;    
for lp=length(Names):-1:1
  BtnPos(lp,:)=[Offset Offset+Ct*ButtonHeight ButtonWidth ButtonHeight];
  Ct=Ct+1;        
end 

BtnPos(1:length(InputName),2)=BtnPos(1:length(InputName),2)+2*Offset;  

Frame2Y=BtnPos(length(InputName),2)-Offset;
FramePos=[0 0 FigWidth sum(BtnPos(length(InputName)+1,[2 4]))+Offset
          0 Frame2Y FigWidth sum(BtnPos(1,[2 4]))+Offset-Frame2Y];   
FigHeight=sum(BtnPos(1,[2 4]))+Offset;
ScreenUnits=get(0,'Units');
set(0,'Units','pixels');
ScreenPos=get(0,'ScreenSize');
set(0,'Units',ScreenUnits);    
ModelPos=get_param('sldemo_clutch','Location');
FigX=0;FigY=0;  
Fig=figure('Units'          ,'points'                                , ...
           'Position'       ,[FigX FigY FigWidth FigHeight]          , ...
           'CloseRequestFcn','sldemo_clutchplot Close'                      , ...
           'Menubar'        ,'none'                                  , ...
           'Colormap'       ,[]                                      , ...
           'NumberTitle'    ,'off'                                   , ...
           'Name'           ,'Clutch Demo Signals'                   , ...
           'Color'          ,get(0,'defaultuicontrolbackgroundcolor'), ...
           'IntegerHandle'  ,'off'                                   , ...   
           'Visible'        ,'off'                                   , ...
           'Tag'            ,'OverlayFigure'                           ...
           );
set(Fig,'Units','pixels');
FigPos=get(Fig,'Position');
FigX=ModelPos(3)+Offset;
if FigX>ScreenPos(3)-FigPos(3)
  FigX=ScreenPos(3)-FigPos(3);
end    
FigY=ScreenPos(4)-ModelPos(2)-FigPos(4);
FigPos(1:2)=[FigX FigY];
set(Fig,'Position',FigPos,'Units','points');
Frame = zeros(size(FramePos,1),1);
for lp=1:size(FramePos,1)   
  Frame(lp)=uicontrol('Style'   ,'frame'       , ...
                      'Units'   ,'points'      , ...
                      'Position',FramePos(lp,:), ...
                      'Units'   ,'normalized'    ...                      
                      );
end 

UI = zeros(length(Names),1);
   
for lp=1:length(Names)   
  UI(lp)=uicontrol('Style'   ,'checkbox'       , ...
                   'Units'   ,'points'         , ...
                   'Position',BtnPos(lp,:)     , ...
                   'Units'   ,'normalized'     , ...               
                   'String'  ,Names{lp}        , ...
                   'Callback','sldemo_clutchplot Plot', ...                       
                   'Tag'     ,Names{lp}          ...
                   );
end
Loc=[1 length(InputName)+1];
set(UI(Loc),'Style','text');
UI(Loc)=[];
Names(Loc)=[];

Data.BlockHandles=[InputHandles;OutputHandles];      
Data.Handles=UI;
Data.Names=Names;
Data.NumInputs=length(InputName)-1;      

set(Fig,'UserData',Data,'HandleVisibility','callback','Visible','on');
