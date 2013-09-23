//  UserStatus.pas
//
//  ������ �������� ��������� ������������. ���������� ������� �� ���������
//  ��������� � ����������� �� �������� ������������.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Dmitry
//
unit UserStatus;

interface
  {$I tox.inc}

uses
  {$I tox-uses.inc}
  {$IFNDEF FPC}PngImage,{$ENDIF}
  Graphics, Classes, Controls, UserIcon, ResourceImage, ImageUtils,
  StringUtils, SysUtils, UserStatusStyle, ActiveRegion, Menus, ImgList,
  PaintSprite;

type
  {$IFDEF FPC}TPngImage = TPortableNetworkGraphic;{$ENDIF}
  {$IFDEF OLD_DELPHI}TPngImage = TPngObject;{$ENDIF}

  TState = (sOffline, sOnline, sAway, sLoading);
  TProcStateChange = procedure(Sender: TObject; State: TState) of object;

  TUserStatus = class(TCustomControl)
  private
    FUserIcon: TUserIcon;
    FImages: TResourceImage;
    FImageLoading: TPaintSprite;
    FState: TState;
    FStateMenu: TPopupMenu;
    FRightButtonRegion: TActiveRegion;
    FRightButtonState: TDownState;
    FUserIconRegion: TActiveRegion;
    FUserName: DataString;
    FUsernameRegion: TActiveRegion;
    FOnStateChange: TProcStateChange;
    FOnChangeUserName: TNotifyEvent;
    procedure DrawRightButton;
    procedure SetUserIcon(const Value: TUserIcon);
    procedure DrawUserIcon;
    procedure SetState(const Value: TState);
    procedure SetUserString(const Value: DataString);
    procedure DrawUserName;
    procedure RightButtonMessage(Sender: TObject; RegionMessage: TRegionMessage;
      const x, y: Integer; Button: TMouseButton; Shift: TShiftState);
    procedure UpdateStateMenu;
    procedure StatusMenuOnClick(Sender: TObject);
    procedure UserNameMessage(Sender: TObject; RegionMessage: TRegionMessage;
      const x, y: Integer; Button: TMouseButton; Shift: TShiftState);
  protected
    procedure CreateWnd; override;
    procedure Paint; override;

  public
    constructor Create(AOwner: TComponent); override;

    property UserIcon: TUserIcon read FUserIcon write SetUserIcon;
    property UserName: DataString read FUserName write SetUserString;
    property State: TState read FState write SetState;

    property OnChangeUserName: TNotifyEvent read FOnChangeUserName write FOnChangeUserName;
    property OnStateChange: TProcStateChange read FOnStateChange write FOnStateChange;
  end;


implementation

{ TUserStatus }

constructor TUserStatus.Create(AOwner: TComponent);
begin
  inherited;
  // TODO: ��������
  UserIcon := TUserIcon.Create;

  FState := sOffline;
  FRightButtonState := dsNone;

  // ��������� ������ �� ������ � �������������
  FImages := TResourceImage.Clone;

  DoubleBuffered := True;

  // �������� ������ ��� ������ ������ ��������� �������
  FRightButtonRegion := TActiveRegion.Create(Self);
  FRightButtonRegion.Parent := Self;
  FRightButtonRegion.Width := TUserStatusStyle.RightButtonWidth;
  FRightButtonRegion.Height := TUserStatusStyle.Height;
  FRightButtonRegion.OnCursorMessage := RightButtonMessage;
  FRightButtonRegion.Cursor := crHandPoint;

  // �������� ������ ��� ������ ������������
  FUserIconRegion := TActiveRegion.Create(Self);
  FUserIconRegion.Parent := Self;
  FUserIconRegion.Width := TUserStatusStyle.IconWidth;
  FUserIconRegion.Height := TUserStatusStyle.IconHeight;
  FUserIconRegion.Left := TUserStatusStyle.IconPositionLeft;
  FUserIconRegion.Cursor := crHandPoint;

  FUsernameRegion := TActiveRegion.Create(Self);
  FUsernameRegion.Parent := Self;
  FUsernameRegion.Left := TUserStatusStyle.IconPositionLeft +
    TUserStatusStyle.IconWidth + TUserStatusStyle.UserNameMarginLeft;
  FUsernameRegion.Top := TUserStatusStyle.UserNameMarginTop;
  FUsernameRegion.Height := TUserStatusStyle.UserNameHeight;
  FUsernameRegion.Width := Width - 35 - FUsernameRegion.Left;
  FUsernameRegion.Cursor := crHandPoint;
  FUsernameRegion.OnCursorMessage := UserNameMessage;

  // �������� ���� ��� ������ �������
  FStateMenu := TPopupMenu.Create(Self);
  FStateMenu.Alignment := paRight;
  FStateMenu.Images := FImages.ImagesMenu;
  UpdateStateMenu;

  // ����������� ��������
  FImageLoading := TPaintSprite.Create(FImages.LoadingAnimate10, Self);
end;

{*  ������� ���������� ��� �������� ����
 *}
procedure TUserStatus.CreateWnd;
begin
  inherited;
  // ��������� ������������ ������� ����������
  Constraints.MinWidth := TUserStatusStyle.MinWidth;
  Constraints.MinHeight := TUserStatusStyle.Height;
  Constraints.MaxHeight := TUserStatusStyle.Height;

  ClientWidth := TUserStatusStyle.MinWidth;
  ClientHeight := TUserStatusStyle.Height;

  // ��������� ����� ����
  ParentColor := False;
  Color := TUserStatusStyle.BackgroundColor;
end;

{*  ��������� ������, ������������� � ������ �������
 *  ����������. ������ �������� ���� ��� � ����������� ��
 *  �������� ����
 *  ������ ����� ������ 13x������
 *}
procedure TUserStatus.DrawRightButton;
var
  LeftPoint, TopPoint: Integer;
  PaintRect: TRect;
begin
  // ������� ���� ������
  case FRightButtonState of
    dsNone:
      Canvas.Brush.Color := TUserStatusStyle.RightButtonBackgroundNormal;
    dsActive:
      Canvas.Brush.Color := TUserStatusStyle.RightButtonBackgroundActive;
    dsDown:
      Canvas.Brush.Color := TUserStatusStyle.RightButtonBackgroundDown;
  end;

  Canvas.Brush.Style := bsSolid;

  // ��������� ���� ������
  LeftPoint := ClientWidth - TUserStatusStyle.RightButtonWidth;
  TopPoint := 0;

  PaintRect.Left := LeftPoint;
  PaintRect.Top := TopPoint;
  PaintRect.Right := LeftPoint + TUserStatusStyle.RightButtonWidth;
  PaintRect.Bottom := Height;
  Canvas.FillRect(PaintRect);

  // ��������� ������� ��� ������
  FRightButtonRegion.Left := LeftPoint;
  FRightButtonRegion.Top := TopPoint;

  // ��������� ������ �� ������ �� ������
  LeftPoint := ClientWidth - TUserStatusStyle.RightButtonWidth +
    (TUserStatusStyle.RightButtonWidth - FImages.UserstatusButtonDown.Width) div 2;

  TopPoint := (ClientHeight - FImages.UserstatusButtonDown.Height) div 2;
  Canvas.Draw(LeftPoint, TopPoint, FImages.UserstatusButtonDown);

  // ��������� ������ �������� ��������� ������������
  LeftPoint := ClientWidth - TUserStatusStyle.RightButtonWidth - 16;
  TopPoint := (ClientHeight - 10) div 2; // 10 - ������ ������

  if FState <> sLoading then
    FImageLoading.Stop;


  case FState of
    sOffline:
      Canvas.Draw(LeftPoint, TopPoint, FImages.StatusOfflineTransporent);
    sOnline:
      Canvas.Draw(LeftPoint, TopPoint, FImages.StatusOnlineTransporent);
    sAway:
      // ��������
      Canvas.Draw(LeftPoint, TopPoint, FImages.StatusAwayTransporent);
    sLoading:
      FImageLoading.Draw(Canvas, LeftPoint, TopPoint);
  end;
end;

{*  ������ ���������� ����������� ������������ � ����������� ��
 *  ���������.
 *  ��������� �������� � ����������� �� �������� ������������
 *}
procedure TUserStatus.DrawUserIcon;
var
  LeftPoint: Integer;
  TopPoint: Integer;
begin
  LeftPoint := TUserStatusStyle.IconPositionLeft;
  // ������������ �� �������� ������
  TopPoint := (ClientHeight - FUserIcon.Image.Height) div 2;

  FUserIconRegion.Top := TopPoint;

  Canvas.Draw(LeftPoint, TopPoint, FUserIcon.Image);
end;

{*  ��������� ����� ������������
 *}
procedure TUserStatus.DrawUserName;
var
  PaintRect: TRect;
begin
  Canvas.Font.Color := clWhite;
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Style := [fsBold];
  Canvas.Font.Height := TUserStatusStyle.UserNameHeight;

  PaintRect.Left := TUserStatusStyle.IconPositionLeft + TUserStatusStyle.IconWidth +
    TUserStatusStyle.UserNameMarginLeft;
  PaintRect.Top := TUserStatusStyle.UserNameMarginTop;
  PaintRect.Right := ClientWidth - 35;
  PaintRect.Bottom := ClientHeight;
  TextRectW(Canvas, PaintRect, FUserName, [tfEndEllipsis]);

  FUsernameRegion.Top := PaintRect.Top;
  FUsernameRegion.Width := PaintRect.Right - PaintRect.Left;
end;

{*  ������� ���������� ��� ����������� ����
 *}
procedure TUserStatus.Paint;
begin
  inherited;

  DrawRightButton;
  DrawUserIcon;
  DrawUserName;
end;

{*  ������ �� �������� ����� �� ������ ������ ��������� �������
 *}
procedure TUserStatus.RightButtonMessage(Sender: TObject; RegionMessage: TRegionMessage;
  const x, y: Integer; Button: TMouseButton; Shift: TShiftState);
var
  IsLeftClick: Boolean;
  p: TPoint;
begin
  IsLeftClick := Button = mbLeft;

  case RegionMessage of
    rmMouseEnter:
      begin
        FRightButtonState := dsActive;
        Invalidate;
      end;

    rmMouseLeave:
      begin
        FRightButtonState := dsNone;
        Invalidate;
      end;

    rmMouseMove: ;
    rmMouseDown:
      begin
        if IsLeftClick then
        begin
          FRightButtonState := dsDown;
          Invalidate;
        end;
      end;

    rmMouseUp:
      begin
        if IsLeftClick and (FRightButtonState = dsDown) then
        begin
          FRightButtonState := dsActive;
          Invalidate;
        end;
      end;

    rmMouseClick, rmMouseDblClick:
      begin
        p.X := FRightButtonRegion.Left + TUserStatusStyle.RightButtonWidth;
        p.Y := FRightButtonRegion.Top + TUserStatusStyle.Height;
        p := ClientToScreen(p);
        FStateMenu.Popup(p.X, p.Y);

        FRightButtonState := dsNone;
        Invalidate;
      end;
  end;
end;

procedure TUserStatus.UserNameMessage(Sender: TObject; RegionMessage: TRegionMessage;
  const x, y: Integer; Button: TMouseButton; Shift: TShiftState);
begin
  if (RegionMessage = rmMouseClick) and Assigned(FOnChangeUserName) then
    FOnChangeUserName(Self);
end;

procedure TUserStatus.SetState(const Value: TState);
begin
  FState := Value;
  Invalidate;
end;

procedure TUserStatus.SetUserIcon(const Value: TUserIcon);
begin
  FUserIcon := Value;
end;

procedure TUserStatus.SetUserString(const Value: DataString);
begin
  FUserName := Value;
  Invalidate;
end;

{*  ������� ������ ������ ������� ������������
 *}
procedure TUserStatus.StatusMenuOnClick(Sender: TObject);
var
  State: TState;
begin
  case TMenuItem(Sender).Tag of
    0: State := sOnline;
    1: State := sAway;
    2: State := sLoading;
    3: State := sOffline;
  else
    State := sOffline;
  end;

  if Assigned(FOnStateChange) then
    FOnStateChange(Self, State);

  //Self.State := State;
end;

{*  ���������� ������ ������������ ���� ��� ������������
 *  ��������� ������������
 *}
procedure TUserStatus.UpdateStateMenu;
var
  Item: TMenuItem;
begin
  FStateMenu.Items.Clear;

  Item := TMenuItem.Create(FStateMenu);
  FStateMenu.Items.Add(Item);
  Item.Caption := 'Online';
  Item.ImageIndex := 0;
  Item.Tag := 0;
  Item.OnClick := StatusMenuOnClick;

  Item := TMenuItem.Create(FStateMenu);
  FStateMenu.Items.Add(Item);
  Item.Caption := 'Away';
  Item.Tag := 1;
  Item.OnClick := StatusMenuOnClick;

  Item := TMenuItem.Create(FStateMenu);
  FStateMenu.Items.Add(Item);
  Item.Caption := 'Busy';
  Item.Tag := 2;
  Item.OnClick := StatusMenuOnClick;

  Item := TMenuItem.Create(nil);
  FStateMenu.Items.Add(Item);
  Item.Caption := '-';

  Item := TMenuItem.Create(FStateMenu);
  FStateMenu.Items.Add(Item);
  Item.Caption := 'Disconnect';
  Item.Tag := 3;
  Item.OnClick := StatusMenuOnClick;
end;

end.
