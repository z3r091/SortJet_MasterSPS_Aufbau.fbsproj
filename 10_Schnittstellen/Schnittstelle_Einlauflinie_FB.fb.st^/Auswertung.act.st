(* METADATA
{
  "v3Meta": {
    "objectGuid": "b211a69e-d473-4dc0-bf58-fc8914298d91"
  }
}
*)
ACTION Auswertung
//-------------------------------------------------------------------------------------------------
// AUSWERTUNG DER BYTE REIHENFOLGE
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Anzeige der Byte- Reihenfolge
     => Visualisierung
*)
SysMemCpy(ADR(aInByteAuftragsdatenScheibenID_1_0), ADR(in_stSenderAuftragsdaten.adwScheibenID_1[0]), 4 );
SysMemCpy(ADR(aInByteAuftragsdatenScheibenID_1_1), ADR(in_stSenderAuftragsdaten.adwScheibenID_1[1]), 4 );
SysMemCpy(ADR(aInByteAuftragsdatenScheibenID_1_2), ADR(in_stSenderAuftragsdaten.adwScheibenID_1[2]), 4 );
SysMemCpy(ADR(aInByteAuftragsdatenScheibenID_1_3), ADR(in_stSenderAuftragsdaten.adwScheibenID_1[3]), 4 );


(* Hinweis:
   - Anzeige der Byte- Reihenfolge (Gedreht)
     => Visualisierung
*)
aInDWordAuftragsdatenScheibenID[0] := SWAP_DWORD_SIEMENS(dwpWert := in_stSenderAuftragsdaten.adwScheibenID_1[0] );
aInDWordAuftragsdatenScheibenID[1] := SWAP_DWORD_SIEMENS(dwpWert := in_stSenderAuftragsdaten.adwScheibenID_1[1] );
aInDWordAuftragsdatenScheibenID[2] := SWAP_DWORD_SIEMENS(dwpWert := in_stSenderAuftragsdaten.adwScheibenID_1[2] );
aInDWordAuftragsdatenScheibenID[3] := SWAP_DWORD_SIEMENS(dwpWert := in_stSenderAuftragsdaten.adwScheibenID_1[3] );


//aInDWordAuftragsdatenScheibenID[0] := in_stSenderAuftragsdaten.adwScheibenID_1[0];
//aInDWordAuftragsdatenScheibenID[1] := in_stSenderAuftragsdaten.adwScheibenID_1[1];
//aInDWordAuftragsdatenScheibenID[2] := in_stSenderAuftragsdaten.adwScheibenID_1[2];
//aInDWordAuftragsdatenScheibenID[3] := in_stSenderAuftragsdaten.adwScheibenID_1[3];

SysMemCpy(ADR(aInByteSwapAuftragsdatenScheibenID_1_0), ADR(aInDWordAuftragsdatenScheibenID[0]), 4 );
SysMemCpy(ADR(aInByteSwapAuftragsdatenScheibenID_1_1), ADR(aInDWordAuftragsdatenScheibenID[1]), 4 );
SysMemCpy(ADR(aInByteSwapAuftragsdatenScheibenID_1_2), ADR(aInDWordAuftragsdatenScheibenID[2]), 4 );
SysMemCpy(ADR(aInByteSwapAuftragsdatenScheibenID_1_3), ADR(aInDWordAuftragsdatenScheibenID[3]), 4 );


(* Hinweis:
   - Anzeige der ID ins ASCII- Format
     => Visualisierung
*)
IF ( bpDatenformatASCII ) THEN

  strScheibenID := ' ID: ';

  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_0[0]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_0[1]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_0[2]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_0[3]] );

  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_1[0]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_1[1]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_1[2]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_1[3]] );

  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_2[0]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_2[1]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_2[2]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_2[3]] );

  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_3[0]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_3[1]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_3[2]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:= '-');
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aInByteSwapAuftragsdatenScheibenID_1_3[3]] );

END_IF



(* Hinweis:
   - Anzeige des Live Counters
     => Visualisierung
*)
wlLiveCounterSender := SWAP_WORD( wpWert := in_wSenderLiveCounter) ;
END_ACTION