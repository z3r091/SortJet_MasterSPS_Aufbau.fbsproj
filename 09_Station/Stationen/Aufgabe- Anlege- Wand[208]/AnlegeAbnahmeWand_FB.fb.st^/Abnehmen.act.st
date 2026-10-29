(* METADATA
{
	"v3Meta": {
		"objectGuid": "8022e3a3-f996-4335-9e0b-7503e096fe34"
	}
}
*)
ACTION Abnehmen
(***************************************************************************************************)
(* ABNEHMEN *)
(***************************************************************************************************)
IF ( BasisStationsParameter.bAbnehmen
  AND blBetriebsartAutomatik )
THEN
  (* Fehlerbehandlung
     - Kippen
  *)
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplAbnehmen := STEP_900_E;
  END_IF
  
  CASE steplAbnehmen OF
(* ABNEHMEN =====================*)
    STEP_0_E:
      (* Hinweis:
         - Freigabe durch Quittierten Si-Kreis da ?
      *)
      out_bSignalScheibeAbnehmen := FALSE;
      BasisStationsParameter.bAbnehmenAbgeschlossen := FALSE;
      
      IF ( tonlFreigabeErhalten.Q ) THEN
        ilScheibenZaehler := WORD_TO_INT(BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben);
        steplAbnehmen := STEP_10_E;
      END_IF

(* ABNEHMEN =====================*)
    STEP_10_E:
      (* Hinweis:
         - Pruefen ob das Geblase aktiv ist
           => Sicherung nicht ausgeloest
      *)
      IF ( in_bMotorschutzGeblaese_Ok ) THEN
        out_bDrosselklappeOeffnen := TRUE;
        steplAbnehmen := STEP_20_E;

      ELSE
        out_bDrosselklappeOeffnen := FALSE;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplAbnehmen:=STEP_900_E;

      END_IF

(* ABNEHMEN =====================*)
    STEP_20_E:
      IF ( NOT Kippen.bpFehler ) THEN
        out_bDrosselklappeOeffnen := TRUE;
		
        Kippen.epZielPosition := eKippen_Position_84Grad;
	     Kippen.bpPositionieren := TRUE;
		
        steplAbnehmen := STEP_30_E;
      ELSE
        Kippen.bpPositionieren := FALSE;
        BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
        steplAbnehmen := STEP_900_E;
      END_IF

(* ABNEHMEN =====================*)
    STEP_30_E:
      (* Zentrierleiste verfahren
         - Nach einem Notaus bzw. Stop fehlen die Auftragsdaten somit wuerde die Leiste nur die Abstandverfahren.
           Deshalb wird beim SystemCheck die Zentrierleiste ganz hoch gefahren 
      *)
      IF ( Kippen.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1]) THEN
        out_bDrosselklappeOeffnen := FALSE;
        Kippen.bpPositionieren := FALSE;

        out_bAmpelSignalGruen := TRUE;
        out_bSignalScheibeAbnehmen := TRUE;

        steplAbnehmen := STEP_50_E;
      END_IF

(* ABNEHMEN =====================*)
    STEP_50_E:
      out_bAmpelSignalGruen                  := gbFlashbit05sec;
      out_bSignalScheibeAbnehmen             := gbFlashbit05sec;

      (* Hinweis:
         - Erst die Lichtschranke unterbrechen und zur Station gehen
      *)
      IF ( tonlFreigabeErhalten.Q ) THEN (* NOT *)
        steplAbnehmen := STEP_60_E;
      END_IF

(* ABNEHMEN =====================*)
    STEP_60_E:
      out_bAmpelSignalGruen                  := gbFlashbit05sec;
      out_bSignalScheibeAbnehmen             := gbFlashbit05sec;

      IF ( ( in_bTasterQuittierungGlasAbgenommen OR in_bFussTaster )
  (* todo     AND NOT Glastransport.bpSensorEinlaufVorAb  
        AND NOT Glastransport.bpSensorEinlauf 
        AND NOT Glastransport.bpSensorAuslaufVorAb*) )
      THEN 
          ilScheibenZaehler := ( ilScheibenZaehler - 1 );

          IF ( ilScheibenZaehler > 0 ) THEN
            steplAbnehmen := STEP_70_E;

          ELSE
            out_bSignalScheibeGlasbruch     := FALSE;
            out_bAmpelSignalGruen           := FALSE;
            out_bSignalScheibeAbnehmen      := FALSE;

            steplAbnehmen := STEP_1000_E;
          END_IF
      END_IF

(* ABNEHMEN =====================*)
    STEP_70_E:
    
      out_bSignalScheibeGlasbruch := FALSE;

      IF ( NOT in_bTasterQuittierungGlasAbgenommen 
        AND NOT in_bFussTaster )
      THEN
        steplAbnehmen := STEP_60_E;
      END_IF

(* ABNEHMEN =====================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      Messachse.bpPositionierung     := FALSE;
      Kippen.bpPositionieren         := FALSE; 

(* ABNEHMEN =====================*)
    STEP_1000_E:
      BasisStationsParameter.bAbnehmenAbgeschlossen := TRUE;

(* ABNEHMEN =====================*)
  END_CASE
ELSE
  IF (steplAbnehmen > STEP_0_E) THEN
    out_bDrosselklappeOeffnen   := FALSE;
    out_bSignalScheibeAbnehmen  := FALSE;
    out_bAmpelSignalGruen       := FALSE;
    out_bSignalScheibeGlasbruch := FALSE;

    Messachse.bpPositionierung  := FALSE;
    Kippen.bpPositionieren      := FALSE;
	
    BasisStationsParameter.bAbnehmenAbgeschlossen := FALSE;

    steplAbnehmen := STEP_0_E;
  END_IF
END_IF
END_ACTION