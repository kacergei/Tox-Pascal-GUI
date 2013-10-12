unit MessageItem;

interface

uses
  StringUtils, SysUtils, FriendList;

type
  // �����, ����������� ���� ���������
  TMessageItem = class
  private
    FTime: TDateTime;
    FText: DataString;
    FUserMessage: Boolean;
    FStatusSend: Boolean;
    FIndex: Integer;
    FData: TObject;
    FFriend: TFriendItem;
    FIsRead: Boolean;
    FBaseId: Int64;
    procedure SetText(const Value: DataString);
  public
    class function FromText(Text: DataString): TMessageItem;
    property BaseId: Int64 read FBaseId write FBaseId;
    property Data: TObject read FData write FData;
    property Friend: TFriendItem read FFriend write FFriend;
    property Index: Integer read FIndex write FIndex;
    // ����� �������� ���������
    property Time: TDateTime read FTime write FTime;
    // ����� ���������
    property Text: DataString read FText write SetText;

    property IsMy: Boolean read FUserMessage write FUserMessage;
    // ��������� �������� ��������� ������������
    property IsSend: Boolean read FStatusSend write FStatusSend;
    property IsRead: Boolean read FIsRead write FIsRead;
  end;

  TMessageArray = array of TMessageItem;

implementation

{ TMessageItem }

class function TMessageItem.FromText(Text: DataString): TMessageItem;
var
  Item: TMessageItem;
begin
  Item := TMessageItem.Create;
  Item.Text := Text;
  Item.Time := Now;
  Result := Item;
end;

procedure TMessageItem.SetText(const Value: DataString);
begin
  FText := Value;
end;

end.
