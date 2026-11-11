(* METADATA
{
	"v3Meta": {
		"objectGuid": "73efd810-dec5-4d32-85b4-2242d401284d"
	}
}
*)
FUNCTION DiagnoseAuswertung : Rexroth_Fehler
VAR_INPUT
  wFehlernummer : UDINT;
END_VAR
VAR
  arrFehlerByte                    : ARRAY[1..8] OF BYTE;
  bSubCategoryActive               : BOOL;
  byFehlerKategorieMitSubKategorie : BYTE;
END_VAR

// Daten extrahieren
arrFehlerByte[1] := UDINT_TO_BYTE( wFehlernummer AND 16#F );             // Fehlernummer
arrFehlerByte[2] := UDINT_TO_BYTE( SHR( wFehlernummer , 4  ) AND 16#F ); // Fehlernummer
byFehlerKategorieMitSubKategorie := UDINT_TO_BYTE( SHR( wFehlernummer , 8  ) AND 16#F ); // Fehlernummer bzw. auch teilweise Subkategorie
arrFehlerByte[4] := UDINT_TO_BYTE( SHR( wFehlernummer , 12 ) AND 16#F ); // Fehlerkategorie, sie Strukturen
arrFehlerByte[5] := UDINT_TO_BYTE( SHR( wFehlernummer , 16 ) AND 16#F ); // A, C, E, F
arrFehlerByte[6] := UDINT_TO_BYTE( SHR( wFehlernummer , 20 ) AND 16#F ); // Bit 20 auswertung ; Bit 21-23 nicht genutzt
arrFehlerByte[7] := UDINT_TO_BYTE( SHR( wFehlernummer , 24 ) AND 16#F ); // Sercos Profil (source type / specification) dem die Diagnose angehört
arrFehlerByte[8] := UDINT_TO_BYTE( SHR( wFehlernummer , 28 ) AND 16#F ); // Gibt an in wessen Verantwortung die Spezifikation der Diagnose liegt
byFehlerKategorieMitSubKategorie := UDINT_TO_BYTE( SHR( wFehlernummer , 8 ) AND 16#FF );

// Type Meldung identifizieren (A, C, E, F)
DiagnoseAuswertung.eType := arrFehlerByte[5];

// Commands können zeitgleich auch ein CommandError sein ; Cxxx0 = Command, ; Cxxxx = Command Error
IF ( DiagnoseAuswertung.eType = eRexroth_Fehler_Command ) THEN // Type = 16#Cxx0
  IF ( arrFehlerByte[1] <> 0 ) THEN
    DiagnoseAuswertung.eType := eRexroth_Fehler_CommandError; // Type = 16#Cxxx
  END_IF
END_IF

// Type der Warnung identifizieren
bSubCategoryActive := FALSE; // Anfänglich zurücksetzen
DiagnoseAuswertung.eWarningType := eRexroth_Warning_None; // Auf 0 setzen
IF ( DiagnoseAuswertung.eType = eRexroth_Fehler_Warning ) THEN // Type = 16#E
  DiagnoseAuswertung.bWarning := TRUE;
  DiagnoseAuswertung.bError := FALSE;
  // Hauptkategorie setzen
  DiagnoseAuswertung.eWarningType := arrFehlerByte[4];
  // Es ist möglich, dass in einer bestimmten Kategorie noch eine Subkategorie verfügbar ist
  IF ( DiagnoseAuswertung.eWarningType = eRexroth_Warning_Fatal ) THEN // Fatale Warnungen kann eine Sub-Kategorie enthalten
    IF ( byFehlerKategorieMitSubKategorie = eRexroth_Warning_Fatal_Safety ) THEN // Subkategorie 16#3
      bSubCategoryActive := TRUE;
      DiagnoseAuswertung.eWarningType := eRexroth_Warning_Fatal_Safety;
    END_IF
  END_IF
END_IF

// Type des Fehlers identifizieren
bSubCategoryActive := FALSE; // Anfänglich zurücksetzen
DiagnoseAuswertung.eErrorType := eRexroth_Error_No_Reaction; // Auf 0 setzen
IF ( DiagnoseAuswertung.eType = eRexroth_Fehler_Error ) THEN // Type = 16#F
  DiagnoseAuswertung.bWarning := FALSE;
  DiagnoseAuswertung.bError := TRUE;
  // Hauptkategorie setzen
  DiagnoseAuswertung.eErrorType := arrFehlerByte[4];
  // Es ist möglich, dass in einer bestimmten Kategorie noch eine Subkategorie verfügbar ist
  IF ( DiagnoseAuswertung.eErrorType = eRexroth_Error_Fatal ) THEN // Fatale Fehler kann eine Sub-Kategorie enthalten
    IF ( byFehlerKategorieMitSubKategorie = eRexroth_Error_Fatal_PowerUnit ) THEN // Subkategorie 16#8
      bSubCategoryActive := TRUE;
      DiagnoseAuswertung.eErrorType := eRexroth_Error_Fatal_PowerUnit;
    ELSIF ( byFehlerKategorieMitSubKategorie = eRexroth_Error_Fatal_Safety ) THEN // Subkategorie 16#3
      bSubCategoryActive := TRUE;
      DiagnoseAuswertung.eErrorType := eRexroth_Error_Fatal_Safety;
    END_IF
  END_IF
  IF ( DiagnoseAuswertung.eErrorType = eRexroth_Error_EmergencyStop ) THEN // EStop Fehler kann eine Sub-Kategorie enthalten
    IF ( byFehlerKategorieMitSubKategorie = eRexroth_Error_EmergencyStop_PowerUnit ) THEN // Subkategorie 16#8
      bSubCategoryActive := TRUE;
      DiagnoseAuswertung.eErrorType := eRexroth_Error_EmergencyStop_PowerUnit;
    END_IF
  END_IF
  IF ( DiagnoseAuswertung.eErrorType = eRexroth_Error_Non_Fatal ) THEN // Non Fatale Fehler kann eine Sub-Kategorie enthalten
    IF ( byFehlerKategorieMitSubKategorie = eRexroth_Error_Non_Fatal_PowerUnit ) THEN // Subkategorie 16#8
      bSubCategoryActive := TRUE;
      DiagnoseAuswertung.eErrorType := eRexroth_Error_Non_Fatal_PowerUnit;
    END_IF
  END_IF
END_IF

// Type F -> Bit 20 = 1 -> Fehler löschbar, Bit 20 = 0 -> Fehler nicht löschbar
DiagnoseAuswertung.bDeleteable    := FALSE; // Status zurücksetzen
IF ( DiagnoseAuswertung.eType = eRexroth_Fehler_Error ) THEN // Type = 16#F
  IF wFehlernummer.20 THEN
    DiagnoseAuswertung.bDeleteable := TRUE;
  ELSE
    DiagnoseAuswertung.bDeleteable := FALSE;
  END_IF
END_IF

// Type C -> Bit 20 = 1 -> Kommando beendet, Bit 20 = 0 -> Kommando in Bearbeitung
DiagnoseAuswertung.bCommandActive := FALSE; // Status zurücksetzen
IF ( DiagnoseAuswertung.eType = eRexroth_Fehler_Command ) THEN // Type = 16#CXXXX (und nicht 16#CXXX0)
  IF wFehlernummer.20 THEN
    DiagnoseAuswertung.bCommandActive := TRUE;
  ELSE
    DiagnoseAuswertung.bCommandActive := FALSE;
  END_IF
END_IF

// Fehlernummer schreiben
IF bSubCategoryActive THEN
  DiagnoseAuswertung.wFehlerNr := UDINT_TO_WORD( wFehlernummer AND 16#FF );
ELSE
  DiagnoseAuswertung.wFehlerNr := UDINT_TO_WORD( wFehlernummer AND 16#FFF );
END_IF
END_FUNCTION