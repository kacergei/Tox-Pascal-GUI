﻿//  MessageBase.pas
//
//  Работает с базой данных. Загружает и сохраняет сообщения для конкретного
//  пользователя
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Dmitry
//
unit MessageBase;

interface
  {$I tox.inc}

uses
  ClientAddress, SQLiteTable3, SQLite3, SysUtils, StringUtils, MessageItem,
  FriendList, Math, FriendItem, DataBase, Classes;

type
  TMessageBase = class
  private
    FBase: TSQLiteDatabase;
    FDataBase: TDataBase;
    FClientInt: Integer;
    FClient: DataString;
    FCount: Integer;
    FBuffer: TMessageArray;
    FBufferRemove: array of Boolean;
    FBufferStart: Integer;
    FFriendItem: TFriendItem;
    FMyItem: TFriendItem;
    function GetItemByNumber(Number: Integer): TMessageItem;
    procedure SetRemoveFlag;
  public
    constructor Create(MyItem, FriendItem: TFriendItem; DataBase: TDataBase);
    destructor Destroy; override;

    procedure Insert(Mess: TMessageItem);

    function Select(Number: Integer): TMessageItem;
    function SelectRange(From, Count: Integer; out Messages: TMessageArray): Boolean;
    procedure Update(Mess: TMessageItem);

    property Count: Integer read FCount;
    property Friend: TFriendItem read FFriendItem;
  end;

  TMessageBaseList = TList;

implementation

{ TMessageBase }

constructor TMessageBase.Create(MyItem, FriendItem: TFriendItem;
  DataBase: TDataBase);
var
  Table: TSQLiteTable;
begin
  FMyItem := MyItem;
  FFriendItem := FriendItem;
  FClientInt := FFriendItem.BaseId;
  FClient := IntToStr(FClientInt);

  FBufferStart := -1;
  FBase := DataBase.Base;
  FDataBase := DataBase;

  if FDataBase.IsLoad then
  begin
    Table := FBase.GetTable('SELECT * FROM dialog WHERE user_id = ' + AnsiString(FClient));
    try
      FCount := Table.RowCount;
    finally
      Table.Free;
    end;
  end
  else
    FCount := 0;
end;

destructor TMessageBase.Destroy;
begin

  inherited;
end;

function BoolToInt(Value: Boolean): Integer;
begin
  if Value then
    Result := 1
  else
    Result := 0;
end;

function IntToBool(Value: Integer): Boolean;
begin
  Result := Value <> 0;
end;

procedure TMessageBase.Insert(Mess: TMessageItem);
var
  SQL: AnsiString;
  Query: TSQLiteQuery;
begin
  SQL := 'INSERT INTO "dialog" ("text","time","is_my","is_send","is_read","user_id") VALUES (?1,?2,?3,?4,?5,?6)';
  Query := FBase.PrepareSQL(SQL);
  try
    FBase.BindSQL(Query, 1, Mess.Text);
    sqlite3_bind_double(Query.Statement, 2, Double(Mess.Time));
    sqlite3_bind_int(Query.Statement, 3, BoolToInt(Mess.IsMy));
    sqlite3_bind_int(Query.Statement, 4, BoolToInt(Mess.IsSend));
    sqlite3_bind_int(Query.Statement, 5, BoolToInt(Mess.IsRead));
    sqlite3_bind_int(Query.Statement, 6, FClientInt);
  finally
    FBase.ExecSQL(Query);
  end;
  
  Mess.BaseId := FBase.GetLastInsertRowID;

  Inc(FCount);
end;

function TMessageBase.Select(Number: Integer): TMessageItem;
var
  BuffCount: Integer;
  BuffStart: Integer;
  Item: TMessageArray;
  i: Integer;
begin
  BuffCount := Length(FBuffer);

  if (Number < 0) or (Number >= FCount) then
  begin
    Result := nil;
    Exit;
  end;

  if (Number >= FBufferStart) and (Number < FBufferStart + BuffCount) then
  begin
    Result := FBuffer[Number - FBufferStart];
  end
  else
  begin
    BuffStart := Number - 100;
    BuffCount := 200;

    if BuffStart < 0 then
      BuffStart := 0;

    if BuffStart + BuffCount >= FCount then
      BuffCount := FCount - BuffStart - 1;

    if (BuffCount = 0) or (BuffStart < 0) or (BuffStart >= FCount) then
    begin
      Result := nil
    end
    else
    begin
      SelectRange(BuffStart, BuffCount, Item);

      for i := Low(FBuffer) to High(FBuffer) do
        if FBufferRemove[i] then
          FBuffer[i].Free;

      SetLength(FBuffer, 0);
      FBuffer := Item;
      // TODO: ПРОВЕРИТЬ ЭТУ ФУНКЦИЮ!!
      Result := FBuffer[Number - FBufferStart];
    end;
  end;
end;

function TMessageBase.GetItemByNumber(Number: Integer): TMessageItem;
var
  i: Integer;
begin
  Result := nil;

  for i := Low(FBuffer) to High(FBuffer) do
  begin
    if FBuffer[i].Number = Number then
    begin
      Result := FBuffer[i];
      FBufferRemove[i] := False;
      Break;
    end;
  end;
end;

procedure TMessageBase.SetRemoveFlag;
var
  i: Integer;
begin
  SetLength(FBufferRemove, Length(FBuffer));
  for i := Low(FBufferRemove) to High(FBufferRemove) do
    FBufferRemove[i] := True;
end;

function TMessageBase.SelectRange(From, Count: Integer;
  out Messages: TMessageArray): Boolean;
var
  SQL: DataString;
  Table: TSQLiteTable;
  c, i: Integer;
  Number: Integer;
begin
  SQL := 'SELECT * FROM "dialog" WHERE "user_id" = ' + FClient +
    ' LIMIT ' + IntToStr(From) + ', ' + IntToStr(Count) + ';';
  Table := FBase.GetTable(AnsiString(SQL));
  try
    c := Table.RowCount;
    SetLength(Messages, c);

    for i := 0 to c - 1 do
    begin
      Number := From + i;

      Messages[i] := GetItemByNumber(Number);

      if not Assigned(Messages[i]) then
      begin
        Messages[i] := TMessageItem.Create;
        Messages[i].Text := Table.FieldAsString(1);
        Messages[i].Time := TDateTime(Table.FieldAsDouble(2));
        Messages[i].IsMy := IntToBool(Table.FieldAsInteger(3));
        Messages[i].IsSend := IntToBool(Table.FieldAsInteger(4));
        Messages[i].IsRead := IntToBool(Table.FieldAsInteger(5));

        // Порядковый номер сообщения в базе
        Messages[i].Number := From + i;

        // Номер записи в таблице
        Messages[i].BaseId := Table.Row;

        if not Messages[i].IsMy then
          Messages[i].Friend := FFriendItem;
      end;

      Table.Next;
    end;

    Result := True;
  finally
    Table.Free;
  end;
end;

procedure TMessageBase.Update(Mess: TMessageItem);
var
  SQL: AnsiString;
  Query: TSQLiteQuery;
begin
  SQL := 'UPDATE "dialog" SET "text" = ?1, "time" = ?2, "is_my" = ?3, '+
    '"is_send" = ?4, "is_read" = ?5, "user_id" = ?6 WHERE  "id" = ' + 
    AnsiString(IntToStr(Mess.BaseId));
  
  Query := FBase.PrepareSQL(SQL);
  FBase.BindSQL(Query, 1, Mess.Text);
  sqlite3_bind_double(Query.Statement, 2, Double(Mess.Time));
  sqlite3_bind_int(Query.Statement, 3, BoolToInt(Mess.IsMy));
  sqlite3_bind_int(Query.Statement, 4, BoolToInt(Mess.IsSend));
  sqlite3_bind_int(Query.Statement, 5, BoolToInt(Mess.IsRead));
  sqlite3_bind_int(Query.Statement, 6, Mess.Friend.BaseId);  
  FBase.ExecSQL(Query);
end;

end.
