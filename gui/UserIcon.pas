//  UserIcon.pas
//
//  ��������������� ���������������� ������ � ������������ ����.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Dmitry
//
//TODO: ���������, ����� ��������� ��������� ������ ������������ � Tox Core
unit UserIcon;

interface
  {$I tox.inc}

uses
  Graphics;

type
  TUserIcon = class
  private
    FImage: TBitmap;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Default;

    property Image: TBitmap read FImage;
  end;

implementation

{ TUserIcon }

constructor TUserIcon.Create;
begin
  FImage := TBitmap.Create;
  FImage.Width := 44;
  FImage.Height := 41;
  //FImage.SetSize(44, 41);
  Default;
end;

{*  ��������� ����������� ����������� �� ������-�����
 *  ����������.
 *}
procedure TUserIcon.Default;
var
  Image: TBitmap;
begin
  Image := TBitmap.Create;
  try
    Image.LoadFromResourceName(0, 'DefaultUserface');
    FImage.Assign(Image);
  finally
    Image.Free;
  end;
end;

destructor TUserIcon.Destroy;
begin
  FImage.Free;
  inherited;
end;

end.


