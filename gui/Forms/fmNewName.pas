unit fmNewName;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFormNewName = class(TForm)
    labTitle: TLabel;
    edName: TEdit;
    btnChange: TButton;
    btnCancel: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnChangeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FNewName: string;
    { Private declarations }
  public
    procedure InsertCaptions;
    property NewName: string read FNewName;
  end;

implementation

{$R *.dfm}

{*  ������� �� ������� ������. ������ �������� ������ �����
 *}
procedure TFormNewName.btnCancelClick(Sender: TObject);
begin
  Close;
end;

{*  ������� �� ������ ��������� �����. ��������� ��������� �������������
 *  ��� � ������� �������� ������ � ������ �� �������������.
 *  � ������ ��������� �������� �����, ����������� ����
 *}
procedure TFormNewName.btnChangeClick(Sender: TObject);
begin
  FNewName := Trim(edName.Text);
  edName.Text := FNewName;

  if FNewName = '' then
  begin
    MessageBox(Handle, '�� �� ����� ��� ������������', PWideChar(Caption), MB_ICONERROR);
  end
  else
    Close;
end;

procedure TFormNewName.FormCreate(Sender: TObject);
begin
  KeyPreview := True;
  InsertCaptions;
end;

{*  ������� �� ������� ������� �� ����������.
 *  ��������� ���� ���� ���� ������ ������� Escape
 *}
procedure TFormNewName.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

{*  ���������� ��� ��������� ������ ����������� � �����������
 *  �� ���������� ����� ����������
 *}
procedure TFormNewName.InsertCaptions;
begin
  // TODO: �������� �������� ����
  Caption := '����� ���';
  labTitle.Caption := '������� ����� ���:';
  btnChange.Caption := '��������';
  btnCancel.Caption := '������';
end;

end.
