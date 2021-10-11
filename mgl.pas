unit mgl;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, OpenGL, StdCtrls,
  Controls, SysUtils, Spin, Menus, Dialogs;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    PopupMenu1: TPopupMenu;
    Rotatespeed1: TMenuItem;
    x1: TMenuItem;
    y1: TMenuItem;
    z1: TMenuItem;
    X2: TMenuItem;
    Y2: TMenuItem;
    Z2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Rotatespeed1Click(Sender: TObject);
    procedure x1Click(Sender: TObject);
    procedure y1Click(Sender: TObject);
    procedure z1Click(Sender: TObject);
    procedure Z2Click(Sender: TObject);
    procedure X2Click(Sender: TObject);
    procedure Y2Click(Sender: TObject);

  private
    DC : HDC;
    hrc : HGLRC;
    Angle, AngleX, AngleY, AngleZ: GLfloat;

    procedure DrawScene;
    procedure InitializeRC;
    procedure SetDCPixelFormat;

  protected
    // Обработка сообщения WM_PAINT - аналог события OnPaint
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;

  end;

var
  Form1: TForm;
  ch, c, i: integer;
  s: string;
  ShowHelp: boolean=true;

implementation

{$R *.DFM}

const
 // массив свойств материала
 MaterialColor: Array [0..3] of GLfloat = (0.5, 0.0, 1.0, 1.0);

 // Процедура инициализации источника цвета
procedure TForm1.InitializeRC;
begin
 glEnable(GL_DEPTH_TEST); // разрешаем тест глубины
 glEnable(GL_LIGHTING); // разрешаем работу с освещенностью
 glEnable(GL_LIGHT0); // включаем источник света 0
end;

 // Отрисовка картинки
procedure TForm1.DrawScene;
begin
 // очистка буфера цвета и буфера глубины
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

 // трехмерность
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef(0.0, 0.0, -8.0); // влево/вправо, вверх/вниз, назад/вперед
 glRotatef(AngleX, 1.0, 0.0, 0.0); // поворот на угол X
 glRotatef(AngleY, 0.0, 1.0, 0.0); // поворот на угол Y
 glRotatef(AngleZ, 0.0, 0.0, 1.0); // поворот на угол Z

 // Шесть сторон куба
 glBegin(GL_POLYGON);
  glNormal3f(0.0, 0.0, 1.0);
  glVertex3f(1.0, 1.0, 1.0);
  glVertex3f(-1.0, 1.0, 1.0);
  glVertex3f(-1.0, -1.0, 1.0);
  glVertex3f(1.0, -1.0, 1.0);
 glEnd;

 glBegin(GL_POLYGON);
  glNormal3f(0.0, 0.0, -1.0);
  glVertex3f(1.0, 1.0, -1.0);
  glVertex3f(1.0, -1.0, -1.0);
  glVertex3f(-1.0, -1.0, -1.0);
  glVertex3f(-1.0, 1.0, -1.0);
 glEnd;

 glBegin(GL_POLYGON);
  glNormal3f(-1.0, 0.0, 0.0);
  glVertex3f(-1.0, 1.0, 1.0);
  glVertex3f(-1.0, 1.0, -1.0);
  glVertex3f(-1.0, -1.0, -1.0);
  glVertex3f(-1.0, -1.0, 1.0);
 glEnd;

 glBegin(GL_POLYGON);
  glNormal3f(1.0, 0.0, 0.0);
  glVertex3f(1.0, 1.0, 1.0);
  glVertex3f(1.0, -1.0, 1.0);
  glVertex3f(1.0, -1.0, -1.0);
  glVertex3f(1.0, 1.0, -1.0);
 glEnd;

 glBegin(GL_POLYGON);
  glNormal3f(0.0, 1.0, 0.0);
  glVertex3f(-1.0, 1.0, -1.0);
  glVertex3f(-1.0, 1.0, 1.0);
  glVertex3f(1.0, 1.0, 1.0);
  glVertex3f(1.0, 1.0, -1.0);
 glEnd;

 glBegin(GL_POLYGON);
  glNormal3f(0.0, -1.0, 0.0);
  glVertex3f(-1.0, -1.0, -1.0);
  glVertex3f(1.0, -1.0, -1.0);
  glVertex3f(1.0, -1.0, 1.0);
  glVertex3f(-1.0, -1.0, 1.0);
 glEnd;

 SwapBuffers(DC);   // конец работы
end;

 // Обработка таймера
procedure TForm1.Timer1Timer(Sender: TObject);
begin
 Angle:=Angle+1.0;
 if (Angle>=90.0)
 then Angle:=0.0;
 Application.ProcessMessages;
 InvalidateRect(Handle, nil, False); // перерисовка региона (Windows API)
end;

 // Дальше идут обычные для OpenGL действия, Создание окна
procedure TForm1.FormCreate(Sender: TObject);
begin
 Form1.PopupMenu:=PopupMenu1;
 Angle:=0;
 AngleX:=30;
 AngleY:=0;
 AngleZ:=0;
 c:=1;
 DC:=GetDC(Handle);
 SetDCPixelFormat;
 hrc:=wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);
 InitializeRC;
 // Определяем свойства материала - лицевые стороны - рассеянный
 // цвет материала и диффузное отражение материала - значения из массива
 glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @MaterialColor);
end;

 // Установка формата пикселей
procedure TForm1.SetDCPixelFormat;
var
 nPixelFormat: integer;
 pfd: TPixelFormatDescriptor;
begin
 FillChar(pfd, SizeOf(pfd), 0);
 with pfd do
  begin
   nSize   :=sizeof(pfd);
   nVersion:=1;
   dwFlags :=PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or
                                             PFD_DOUBLEBUFFER;
   iPixelType:=PFD_TYPE_RGBA;
   cColorBits:=24; // 24
   cDepthBits:=32; // 32
   iLayerType:= PFD_MAIN_PLANE;
 end;
 nPixelFormat := ChoosePixelFormat(DC, @pfd);
 SetPixelFormat(DC, nPixelFormat, @pfd);
end;

 // Изменение размеров окна
procedure TForm1.FormResize(Sender: TObject);
begin
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective(30.0, Width/Height, 1.0, 10.0);
 glViewport(0, 0, Width, Height);
 glMatrixMode(GL_MODELVIEW);
 InvalidateRect(Handle, nil, False);
end;

 // Обработка сообщения WM_PAINT, рисование окна
procedure TForm1.WMPaint(var Msg: TWMPaint);
var
 ps: TPaintStruct;
begin
 BeginPaint(Handle, ps);
 DrawScene;
 EndPaint(Handle, ps);
end;

 // Конец работы программы
procedure TForm1.FormDestroy(Sender: TObject);
begin
 Timer1.Enabled:=False;
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC(Handle, DC);
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
 if (key='x') then c:=1;
 if (key='y') then c:=3;
 if (key='z') then c:=5;
 if (key='X') then c:=2;
 if (key='Y') then c:=4;
 if (key='Z') then c:=6;
 if ord(key)=27 then Application.Terminate; // Esc
 //
 if key='h' then
  begin
   ShowHelp:=not(ShowHelp);
   key:='g';
  end;
 //
 FormResize(nil);
end;

procedure TForm1.Rotatespeed1Click(Sender: TObject);
begin
 ch:=StrToInt(InputBox('Rotate','Sleep:','0'));
 i:=1;
 if Form1.CanFocus then Form1.SetFocus;
 while i=1 do
  case c of
   1:
     begin
      AngleX:=AngleX-1.0;
      if (AngleX>=90.0)
      then AngleX:=0.0;
      Sleep(ch);
      if Application.Terminated then Break;
      Application.ProcessMessages;
      InvalidateRect(Handle, nil, False); // перерисовка региона (Windows API)
     end;
   2:
     begin
      AngleX:=AngleX+1.0;
      if (AngleX>=90.0)
      then AngleX:=0.0;
      Sleep(ch);
      if Application.Terminated then Break;
      Application.ProcessMessages;
      InvalidateRect(Handle, nil, False); // перерисовка региона (Windows API)
     end;
   3:
     begin
      AngleY:=AngleY-1.0;
      if (AngleY>=90.0)
      then AngleY:=0.0;
      Sleep(ch);
      if Application.Terminated then Break;
      Application.ProcessMessages;
      InvalidateRect(Handle, nil, False); // перерисовка региона (Windows API)
     end;
   4:
     begin
      AngleY:=AngleY+1.0;
      if (AngleY>=90.0)
      then AngleY:=0.0;
      Sleep(ch);
      if Application.Terminated then Break;
      Application.ProcessMessages;
      InvalidateRect(Handle, nil, False); // перерисовка региона (Windows API)
     end;
   5:
     begin
      AngleZ:=AngleZ-1.0;
      if (AngleZ>=90.0)
      then AngleZ:=0.0;
      Sleep(ch);
      if Application.Terminated then Break;
      Application.ProcessMessages;
      InvalidateRect(Handle, nil, False); // перерисовка региона (Windows API)
     end;
   6:
     begin
      AngleZ:=AngleZ+1.0;
      if (AngleZ>=90.0)
      then AngleZ:=0.0;
      Sleep(ch);
      if Application.Terminated then Break;
      Application.ProcessMessages;
      InvalidateRect(Handle, nil, False); // перерисовка региона (Windows API)
     end;
  end;
end;

procedure TForm1.x1Click(Sender: TObject);
begin
 c:=2;
end;

procedure TForm1.y1Click(Sender: TObject);
begin
 c:=1;
end;

procedure TForm1.z1Click(Sender: TObject);
begin
 c:=3;
end;

procedure TForm1.Z2Click(Sender: TObject);
begin
 c:=6;
end;

procedure TForm1.X2Click(Sender: TObject);
begin
 c:=4;
end;

procedure TForm1.Y2Click(Sender: TObject);
begin
 c:=5;
end;

end.

