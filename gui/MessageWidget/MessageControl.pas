﻿//  MessageControl.pas
//
//  Виджет вывода сообщений пользователей. Содержит в себе следующие элементы:
//      * список сообщений
//      * полоса прокрутки
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Dmitry
//
unit MessageControl;

interface
  {$I tox.inc}

uses
  {$I tox-uses.inc}
  Classes, SysUtils, Controls, Graphics, StringUtils, MessageList,
  MessageDraw, Messages, ActiveRegion, MessageItem, FriendItem, MessageHeader;

type
  TMessagePosition = (mpBefore, mpAfter);

  TMessageControl = class(TCustomControl)
  private
    FIsDown: Boolean;
    FPosition: Integer;
    FActive: TActiveRegion;
    FFrienSelect: TFriendItem;
    FMessageList: TMessageList;
    FDraw: TMessageDraw;
    FMessageHeader: TMessageHeader;
    procedure MessageGet(Sender: TObject; const Index: Integer; out Exist: Boolean;
      out Mess: TMessageItem);
    procedure ActiveOnMessage(Sender: TObject; RegionMessage: TRegionMessage;
      const x, y: Integer; Button: TMouseButton; Shift: TShiftState);
  protected
    procedure CreateWnd; override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint)
      : Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint)
      : Boolean; override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent; MessageList: TMessageList); reintroduce;
    destructor Destroy; override;

    procedure SelectFriend(Friend: TFriendItem);
  end;

implementation

{ TMessageControl }

constructor TMessageControl.Create(AOwner: TComponent;
  MessageList: TMessageList);
begin
  inherited Create(AOwner);
  FMessageList := MessageList;
  FActive := TActiveRegion.Create(Self);
  FActive.Align := alClient;
  FActive.OnCursorMessage := ActiveOnMessage;
end;

destructor TMessageControl.Destroy;
begin
  FActive.Free;
  inherited;
end;

procedure TMessageControl.ActiveOnMessage(Sender: TObject; RegionMessage: TRegionMessage;
  const x, y: Integer; Button: TMouseButton; Shift: TShiftState);
begin
  case RegionMessage of
    rmMouseEnter: ;
    rmMouseLeave: ;
    rmMouseMove:
      begin
        if FIsDown then
        begin
          FDraw.ScrollDown(FPosition - y);
          FPosition := y;
        end;
      end;
    rmMouseDown:
      begin
        FPosition := y;
        FIsDown := True;
      end;
    rmMouseUp:
      FIsDown := False;
    rmMouseClick: ;
    rmMouseDblClick: ;
  end;
end;

function TMessageControl.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  FDraw.ScrollDown(40);
  Result := True;
end;

function TMessageControl.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  FDraw.ScrollUp(40);
  Result := True;
end;

procedure TMessageControl.CreateWnd;
begin
  inherited;
  DoubleBuffered := True;
  {$IFNDEF FPC}
  ParentBackground := False;
  {$ENDIF}

  FDraw := TMessageDraw.Create(Self);
  FDraw.Align := alClient;
  FDraw.Parent := Self;
  FDraw.OnGet := MessageGet;
  FActive.Parent := Self;

  FMessageHeader := TMessageHeader.Create(Self);
  FMessageHeader.Align := alTop;
  FMessageHeader.Parent := Self;
end;

{ *  Запрос на следующее сообщение
  * }
procedure TMessageControl.MessageGet(Sender: TObject; const Index: Integer;
  out Exist: Boolean; out Mess: TMessageItem);
begin
  if not Assigned(FFrienSelect) then
    Exist := False
  else
    Exist := FMessageList.GetMessage(FFrienSelect.ClientId, Index, Mess);
end;

{ *  Открытие диалога с новым пользователем
  * }
procedure TMessageControl.SelectFriend(Friend: TFriendItem);
var
  LastMessage: Integer;
begin
  LastMessage := FMessageList.GetMessageCount(Friend.ClientId) - 1;
  FFrienSelect := Friend;
  FDraw.Redraw(LastMessage);

  FMessageHeader.SelectFriend(Friend);
end;

procedure TMessageControl.WndProc(var Message: TMessage);
  function GET_WHEEL_DELTA_WPARAM(wp: longint): smallint;
  begin
    Result := smallint(wp shr 16);
  end;

begin
  inherited;
  case Message.Msg of
    CM_MOUSEENTER:
      SetFocus;

{$IFDEF FPC}
    LM_MOUSEWHEEL:
      begin
        if GET_WHEEL_DELTA_WPARAM(Message.wParam) > 0 then
          DoMouseWheelUp([], Point(0, 0))
        else
          DoMouseWheelDown([], Point(0, 0));

        Message.Result := 1;
      end;
{$ENDIF}
  end;
end;

end.
