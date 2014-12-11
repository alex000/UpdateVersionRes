(*
 *  Copyright © 2014 alex000, github.com/alex000
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 *)

program UpdateVersionRes;
{$APPTYPE CONSOLE}

uses
  Windows, SysUtils, Classes, DateUtils, unitResFile, unitResourceDetails, unitResourceVersionInfo;

function VerExprParse(VerExpr : String; OrigVer:TULargeInteger): TULargeInteger;
var
  v1,v2,v3,v4 : word;
  S: String;
  P : Integer;
  ok : boolean;
begin
	v1 := HiWord(OrigVer.HighPart);
	v2 := LoWord(OrigVer.HighPart);
	v3 := HiWord(OrigVer.LowPart);
	v4 := LoWord(OrigVer.LowPart);

  s := VerExpr;
  p := Pos('.', s);
  ok := False;
  if p > 0 then
  begin
    case s[1] of
      '*': v1 := v1;
      '+': v1 := v1 + StrToInt(Copy (s, 1, p - 1));
      'M': v1 := MonthOf(Now());
      'Y': v1 := YearOf(Now());
      'D': v1 := DayOf(Now());
      else
        v1 := StrToInt(Copy (s, 1, p - 1));
    end;
    s := Copy(s, p + 1, MaxInt);
    p := Pos('.', s);
    if p > 0 then
    begin
      case s[1] of
        '*': v2 := v2;
        '+': v2 := v2 + StrToInt(Copy (s, 1, p - 1));
        'M': v2 := MonthOf(Now());
        'Y': v2 := YearOf(Now());
        'D': v2 := DayOf(Now());
        else
          v2 := StrToInt(Copy (s, 1, p - 1));
      end;
      s := Copy (s, p + 1, MaxInt);
      p := Pos ('.', s);
      if p > 0 then
      begin
        case s[1] of
          '*': v3 := v3;
          '+': v3 := v3 + StrToInt(Copy (s, 1, p - 1));
          'M': v3 := MonthOf(Now());
          'Y': v3 := YearOf(Now());
          'D': v3 := DayOf(Now());
          else
            v3 := StrToInt(Copy (s, 1, p - 1));
        end;
        s := Copy (s, p + 1, MaxInt);
        p := MaxInt;
        if p > 0 then
        begin
          case s[1] of
            '*': v4 := v4;
            '+': v4 := v4 + StrToInt(Copy (s, 1, p - 1));
            'M': v4 := MonthOf(Now());
            'Y': v4 := YearOf(Now());
            'D': v4 := DayOf(Now());
            else
              v4 := StrToInt(Copy (s, 1, p - 1));
          end;
          ok := True;
        end;
      end
    end
  end;

  if not ok then
    raise exception.Create ('bad expression: "' + VerExpr+'"');

	result.HighPart := 65536 * v1 + v2;
	result.LowPart := 65536 * v3 + v4;
end;

var
  VerExpr,NewVerStr: String;
  I: Integer;
  HasFileParameter: Boolean = False;
  NumFiles: Integer = 0;
  resFile: TResModule;
  VerInfo : TVersionInfoResourceDetails = nil;
  SetPV : boolean = True;
  SetFV : boolean = True;
 	newVer : TULargeInteger;
begin
  try
    Writeln('UpdateVersionRes v1.0, Copyright (C) 2014 alex000, github.com/alex000');
    if ParamCount = 0 then begin
      Writeln('Updates VersionInfo structure in already compiled *.res file');
      Writeln;
      Writeln('usage:  UpdateVersionRes filename.res [/pv or /fv] 1.2.3.4');
      Writeln('where:');
      Writeln('  /pv - set only ProductVersion');
      Writeln('  /fv - set only FileVersion');
      Writeln('  both ProductVersion and FileVersion are set by default');
      Writeln;
      Writeln('  1.2.3.4 is new version string witch can contain following elements:');
      Writeln('  123   number');
      Writeln('  *     leave old value');
      Writeln('  +1    increment version number');
      Writeln('  YYYY  current year');
      Writeln('  MM    current month');
      Writeln('  DD    current day');
      Writeln;
      Writeln('example: UpdateVersionRes resfile.res YYYY.MM.DD.*');
      Halt(1);
    end;
    Writeln;

    if not FileExists(ParamStr(1)) then
    begin
      Writeln(ParamStr(1), ': File not found.');
      Halt(1);
    end;

    VerExpr := ParamStr(2);
    if VerExpr[1] = '/' then
    begin
      if      VerExpr[2] = 'p' then SetFV := false
      else if VerExpr[2] = 'f' then SetPV := false;
      VerExpr := ParamStr(3);
    end;

  	resFile := TResModule.Create();
	  resFile.LoadFromFile(ParamStr(1));

    for i := 0 to resFile.ResourceCount - 1 do
    begin
      if resFile.ResourceDetails[i].ResourceType = '16' then
      begin
        VerInfo := (resFile.ResourceDetails[i] as TVersionInfoResourceDetails);
        break;
      end;
    end;

    if not Assigned(VerInfo) then
    begin
      Writeln('No VersionInfo structure found in file');
      Halt(1);
    end;

  if SetFV then
  begin
    newVer := VerExprParse(VerExpr,VerInfo.FileVersion);
    VerInfo.FileVersion := newVer;
  	NewVerStr := Format('%d.%d.%d.%d', [HiWord(newVer.HighPart), LoWord(newVer.HighPart), HiWord(newVer.LowPart), LoWord(newVer.LowPart)]);
    VerInfo.SetKeyValue('FileVersion',NewVerStr);
  end;

  if SetPV then
  begin
    newVer := VerExprParse(VerExpr,VerInfo.ProductVersion);
    VerInfo.ProductVersion := newVer;
  	NewVerStr := Format('%d.%d.%d.%d', [HiWord(newVer.HighPart), LoWord(newVer.HighPart), HiWord(newVer.LowPart), LoWord(newVer.LowPart)]);
    VerInfo.SetKeyValue('ProductVersion',NewVerStr);
  end;

  resFile.SaveToFile(ParamStr(1));

  except
    on E: Exception do begin
      Writeln('Fatal error: ', E.Message);
      Halt(3);
    end;
  end;
end.

