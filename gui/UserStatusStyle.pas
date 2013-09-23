//  UserStatusStyle.pas
//
//  ��������� ���������� �������� GUI ��� ������� ������� ������������
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Dmitry
//
unit UserStatusStyle;

interface
  {$I tox.inc}

uses
  {$I tox-uses.inc}
  Graphics;

type
  // TODO: ��������!!!!
  TTUserStatusStyle = class
  private
    function GetBackgroundColor: TColor;
    function GetHeight: Integer;
    function GetMinWidth: Integer;
    function GetRightButtonBackgroundNormal: TColor;
    function GetRightButtonBackgroundActive: TColor;
    function GetRightButtonBackgroundDown: TColor;
    function GetRightButtonWidth: Integer;
    function GetIconPositionLeft: Integer;
    function GetIconWidth: Integer;
    function GetIconHeight: Integer;
    function GetUserNameMarginLeft: Integer;
    function GetUserNameMarginTop: Integer;
    function GetUserNameHeight: Integer;
  public
    // �������� ���� ����
    property BackgroundColor:TColor read GetBackgroundColor;
    // ���������� ������ ������
    property Height: Integer read GetHeight;
    // ����������� ����� ������
    property MinWidth: Integer read GetMinWidth;
    // ���� ���� ������ ������ � ������� ���������
    property RightButtonBackgroundNormal: TColor read GetRightButtonBackgroundNormal;
    // ���� ���� ������ ������ � ��������� ��������� ����
    property RightButtonBackgroundActive: TColor read GetRightButtonBackgroundActive;
    // ���� ���� ������ ������ � ��������� ������� ����
    property RightButtonBackgroundDown: TColor read GetRightButtonBackgroundDown;
    // ������ ������ ������
    property RightButtonWidth: Integer read GetRightButtonWidth;
    // ������ �������� ������������ �� ������ ����
    property IconPositionLeft: Integer read GetIconPositionLeft;
    // ����� ������
    property IconWidth: Integer read GetIconWidth;
    // ������ ������
    property IconHeight: Integer read GetIconHeight;
    // ������ ��� ����� � ����� �������
    property UserNameMarginLeft: Integer read GetUserNameMarginLeft;
    // ������ ��� ����� ������
    property UserNameMarginTop: Integer read GetUserNameMarginTop;
    // ������ �����
    property UserNameHeight: Integer read GetUserNameHeight;
  end;

function TUserStatusStyle: TTUserStatusStyle;

implementation

var
  a: TTUserStatusStyle;

function TUserStatusStyle: TTUserStatusStyle;
begin
  if not Assigned(a) then
    a := TTUserStatusStyle.Create;
  Result := a;
end;

{ TUserStatusStyle }

function TTUserStatusStyle.GetBackgroundColor: TColor;
begin
  Result := RGB(35, 31, 32);
end;

function TTUserStatusStyle.GetHeight: Integer;
begin
  Result := 59
end;

function TTUserStatusStyle.GetIconHeight: Integer;
begin
  Result := 41;
end;

function TTUserStatusStyle.GetIconPositionLeft: Integer;
begin
  Result := 8;
end;

function TTUserStatusStyle.GetIconWidth: Integer;
begin
  Result := 44;
end;

function TTUserStatusStyle.GetMinWidth: Integer;
begin
  Result := 223;
end;

function TTUserStatusStyle.GetRightButtonBackgroundActive: TColor;
begin
  Result := $525051;
end;

function TTUserStatusStyle.GetRightButtonBackgroundDown: TColor;
begin
  Result := $323031;
end;

function TTUserStatusStyle.GetRightButtonBackgroundNormal: TColor;
begin
  Result := $424041;
end;

function TTUserStatusStyle.GetRightButtonWidth: Integer;
begin
  Result := 13;
end;

function TTUserStatusStyle.GetUserNameHeight: Integer;
begin
  Result := 15;
end;

function TTUserStatusStyle.GetUserNameMarginLeft: Integer;
begin
  Result := 10;
end;

function TTUserStatusStyle.GetUserNameMarginTop: Integer;
begin
  Result := 15;
end;

end.
