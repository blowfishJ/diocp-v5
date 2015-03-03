(*
 *	 Unit owner: D10.Mofen
 *         homePage: http://www.diocp.org
 *	       blog: http://www.cnblogs.com/dksoft
 *
 *   2015-02-22 08:29:43
 *     DIOCP-V5 ����
 *
 *
 *)
unit utils.zipTools;

interface

{$if CompilerVersion>= 21}
  {$define NEWZLib}
{$IFEND}

uses
  Classes, Zlib, SysUtils;

type
{$if CompilerVersion< 18.5}
  TBytes = array of Byte;
{$IFEND}

  TZipTools = class(TObject)
  public
    /// <summary>
    ///   ��ѹ
    /// </summary>
    class procedure UnZipStream(const pvInStream, pvOutStream: TStream);

    /// <summary>
    ///   ѹ��
    /// </summary>
    class procedure ZipStream(const pvInStream, pvOutStream: TStream);


    class function verifyData(const buf; len:Cardinal): Cardinal;
    class function verifyStream(pvStream:TStream; len:Cardinal): Cardinal;
  end;

implementation

class procedure TZipTools.UnZipStream(const pvInStream, pvOutStream: TStream);
var
  lvBytes:TBytes;
  l:Integer;
  OutBuf: Pointer;
  OutBytes: Integer;
begin
  if pvInStream= nil then exit;
  l := pvInStream.Size;
  if l = 0 then Exit;
  setLength(lvBytes, l);
  pvInStream.Position := 0;
  pvInStream.ReadBuffer(lvBytes[0], l);
  {$if defined(NEWZLib)}
  ZLib.ZDecompress(@lvBytes[0], l, OutBuf, OutBytes);
  {$ELSE}
  Zlib.DecompressBuf(@lvBytes[0], l, 0, OutBuf, OutBytes);
  {$ifend}
  try
    pvOutStream.Size := OutBytes;
    pvOutStream.Position := 0;
    pvOutStream.WriteBuffer(OutBuf^, OutBytes);
  finally
    FreeMem(OutBuf, OutBytes);
  end;
end;

class function TZipTools.verifyData(const buf; len: Cardinal): Cardinal;
var
  i:Cardinal;
  p:PByte;
begin
  i := 0;
  Result := 0;
  p := PByte(@buf);
  while i < len do
  begin
    Result := Result + p^;
    Inc(p);
    Inc(i);
  end;
end;

class function TZipTools.verifyStream(pvStream:TStream; len:Cardinal):
    Cardinal;
var
  l, j:Cardinal;
  lvBytes:TBytes;
begin
  SetLength(lvBytes, 1024);

  if len = 0 then
  begin
    j := pvStream.Size - pvStream.Position;
  end else
  begin
    j := len;
  end;

  Result := 0;

  while j > 0 do
  begin
    if j <1024 then l := j else l := 1024;

    pvStream.ReadBuffer(lvBytes[0], l);

    Result := Result + verifyData(lvBytes[0], l);
    Dec(j, l);
  end;
end;

class procedure TZipTools.ZipStream(const pvInStream, pvOutStream: TStream);
var
  lvInBuf: TBytes;
  OutBuf: Pointer;
  OutBytes: Integer;
  l: Integer;

begin
  if pvInStream= nil then exit;
  l := pvInStream.Size;
  if l = 0 then Exit;

  SetLength(lvInBuf, l);
  pvInStream.Position := 0;
  pvInStream.ReadBuffer(lvInBuf[0], l);
{$if defined(NEWZLib)}
  ZLib.ZCompress(@lvInBuf[0], l, OutBuf, OutBytes);
{$ELSE}
  ZLib.CompressBuf(@lvInBuf[0], l, OutBuf, OutBytes);
{$ifend}
  try
    pvOutStream.Size := OutBytes;
    pvOutStream.Position := 0;
    pvOutStream.WriteBuffer(OutBuf^, OutBytes);
  finally
    FreeMem(OutBuf, OutBytes);
  end;

end;

end.