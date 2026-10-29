(* METADATA
{
	"v3Meta": {
		"objectGuid": "e71d18ad-be72-46a0-818f-b835d457fbfa"
	}
}
*)
ACTION Auswertung
(***************************************************************************************************)
(* AUSWERTUNG DER BYTE REIHENFOLGE *)
(***************************************************************************************************)

(* Hinweis:
   - Anzeige der Byte- Reihenfolge 
     => Visualisierung
*)
SysMemCpy(ADR(aOutByteAuftragsdatenScheibenID_1_0), ADR(out_stSenderAuftragsdaten.adwScheibenID_1[0]), 4 );
SysMemCpy(ADR(aOutByteAuftragsdatenScheibenID_1_1), ADR(out_stSenderAuftragsdaten.adwScheibenID_1[1]), 4 );
SysMemCpy(ADR(aOutByteAuftragsdatenScheibenID_1_2), ADR(out_stSenderAuftragsdaten.adwScheibenID_1[2]), 4 );
SysMemCpy(ADR(aOutByteAuftragsdatenScheibenID_1_3), ADR(out_stSenderAuftragsdaten.adwScheibenID_1[3]), 4 );

(* Hinweis:
   - Anzeige der ID ins ASCII- Format
     => Visualisierung
*)
IF ( bpDatenformatASCII ) THEN

  strScheibenID := ' ID: ';
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_0[0]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_0[1]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_0[2]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_0[3]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_1[0]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_1[1]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_1[2]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_1[3]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_2[0]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_2[1]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_2[2]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_2[3]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_3[0]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_3[1]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_3[2]] );
  strScheibenID:=CONCAT(STR1:=strScheibenID  , STR2:=  ascii[aOutByteAuftragsdatenScheibenID_1_3[3]] );

END_IF
END_ACTION