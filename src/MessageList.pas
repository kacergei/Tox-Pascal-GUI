//  MessageList.pas
//
//  ������������ ������ � ����������, ���������� � ���� ������
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Dmitry
//
unit MessageList;

interface
  {$I tox.inc}

uses
  StringUtils;

type
  TMessageStatus = (msSending, msSend);

  // �����, ����������� ���� ���������
  TMessageItem = class
  private
    FTime: TDateTime;
    FText: DataString;
    FUserMessage: Boolean;
    FFriendId: AnsiString;
    FStatusSend: Boolean;
  public
    // ����� �������� ���������
    property Time: TDateTime read FTime;
    // ����� ���������
    property Text: DataString read FText;
    // ���������� �� ��� ��������� ������������� ��� ���
    property UserMessage: Boolean read FUserMessage;
    // ��������� ���� ������������
    property FriendId: AnsiString read FFriendId;
    // ��������� �������� ��������� ������������
    property StatusSend: Boolean read FStatusSend;
  end;

  TMessageArray = array of TMessageItem;

  //TODO: ��� �������� ���� ������ ������������ SQLite
  //TODO: FriendId �������� � ��������� ������� � ������������� ��� ���������� �����
  TMessageList = class
  public
    constructor Create;
    destructor Destroy; override;

    function GetMessageCount(FriendId: AnsiString): Integer;
    function GetMessageRange(FriendId: AnsiString; StartRange, EndRange: Integer;
      var Messages: TMessageArray): Boolean;
    procedure SetMessage(FriendId: AnsiString; Text: DataString;
      UserMessage: Boolean);
  end;

implementation

{ TMessageList }

constructor TMessageList.Create;
begin

end;

destructor TMessageList.Destroy;
begin

  inherited;
end;

// ���������� ���������� ��������� ��� ���������� ������������,
// ���������� � ���� ������
function TMessageList.GetMessageCount(FriendId: AnsiString): Integer;
begin
  Result := 0; // TODO: �����������
end;

// ��������� �� ���� ������ ���������, ������� ��������� � ����������
// ������������ �� ��������� ���������
function TMessageList.GetMessageRange(FriendId: AnsiString; StartRange,
  EndRange: Integer; var Messages: TMessageArray): Boolean;
begin
  Result := False; // TODO: �����������
end;

// ��������� ����� ��������� � ���� ������
procedure TMessageList.SetMessage(FriendId: AnsiString; Text: DataString;
  UserMessage: Boolean);
begin
// TODO: �����������
end;

end.
