(* METADATA
{
	"v3Meta": {
		"objectGuid": "e71d18ad-be72-46a0-818f-b835d457fbfa"
	}
}
*)
ACTION Auswertung
//-------------------------------------------------------------------------------------------------
// AUSWERTUNG DER BYTE REIHENFOLGE
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Anzeige der Byte- Reihenfolge der Lade-ID auf dem Bus
     => Visualisierung
*)
SysMemCpy( ADR( aOutByteLadeID ), ADR( out_awSenderLadeID ), SIZEOF( aOutByteLadeID ) );

(* Hinweis:
   - Anzeige der ID ins ASCII- Format
     => Visualisierung
*)
IF ( bpDatenformatASCII ) THEN

  strScheibenID := ' ID: ';

  FOR ilIndex := 0 TO 15 DO
    strScheibenID := CONCAT( STR1 := strScheibenID, STR2 := ascii[aOutByteLadeID[ilIndex]] );
  END_FOR

END_IF
END_ACTION