(* METADATA
{
  "v3Meta": {
    "objectGuid": "e5781056-5434-4b12-a4a2-e1c1e4aeb816"
  }
}
*)
FUNCTION ScheibenQuittierung : BOOL
VAR_INPUT

  (* WORD *)
  wpQuellstation : WORD;
  wpZielStation  : WORD;
  wpQuellwand    : WORD := 1;
  wpZielwand     : WORD := 1;
  wpAuftragsTyp  : WORD := 0;

  (* DWORD *)
  dwpWartezeit   : DWORD := 0;

END_VAR

VAR

  (* BOOLEAN *)
  blResult : BOOL := FALSE;

END_VAR
(***************************************************************************************************)
(* FUNKTION: QUITTIEREN DER SCHEIBE *)
(***************************************************************************************************)

wSps2MmiZielStation  := wpZielStation;
wSps2MmiQuellStation := wpQuellstation;
wSps2MmiZielWand     := wpZielwand;
wSps2MmiQuellWand    := wpQuellwand;
dwSps2MmiWartezeit   := dwpWartezeit;
wSPS2MMIAuftragstyp  := wpAuftragsTyp;

MsgToMmi(auftragsnr_w := SB0_SPS_QUIT_SHEET_ORDER );


ScheibenQuittierung := TRUE;
END_FUNCTION