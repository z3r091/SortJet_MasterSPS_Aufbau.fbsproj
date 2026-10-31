(* METADATA
{
  "v3Meta": {
    "objectGuid": "9404f6fa-2a6f-44db-8f42-3f6f32f76ed1"
  }
}
*)
FUNCTION_BLOCK Shuttle_Ansteuerung_Ressourcen_FB EXTENDS Basic_Shuttle_Aktion_FB
VAR
  tonlTimeout : TON;
END_VAR
(***************************************************************************************************)
(* AKTION ANSTEUERUNG RESOURCEN WAEHREND DER QUERFAHRT *)
(***************************************************************************************************)
(* WICHTIG:
   - Es handelt isch hier um eine Aktion die waehrend der Shuttlequerfahrt [Verfahrauftrag] abgearbeitet wird.
   - Zu beachten ist das:
     => Wenn der Riemen verfahrern werden soll pruefen ob der autarke Vortransport aktiv ist
     => Aktion laeuft parallel zum Verfahrauftrag der Oberflaeche   
*)
IF (  BasisStationsParameter.bVorabKomponentenAnsteuerung[wWand]
  AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpVortransport              := FALSE;
    Glastransport.bpVortransportRueck         := FALSE;
    Glastransport.bpStarteVorabPositionierung := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer :=  Kippen.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF
  
  IF ( Wandverstellung.bpFehler ) THEN
    Wandverstellung.bpStartePositionierung := FALSE;
    BasisStationsParameter.wFehlerNummer :=  Wandverstellung.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplAktion OF
(* VORAB KOMPONENTEN ANSTEUERUNG ======================== *)
    STEP_0_E:
      BasisStationsParameter.bVorabKomponentenAnsteuerungAbgeschlossen[wWand] := FALSE;
      tonlTimeout( IN := FALSE );

      IF ( BasisStationsParameter.stMKs.stStationsOptionen.bVorAbKomponentenAnsteuerung ) THEN
        steplAktion := STEP_10_E;
      ELSE
        steplAktion := STEP_1000_E;
      END_IF


(* VORAB KOMPONENTEN ANSTEUERUNG WAND 1 ======================== *)
    STEP_10_E:
      (* Hinweis:
       - Wandverstellung ansteuern
        - Kippen ansteuern
      *)
      Wandverstellung.epSollStellung         := BasisStationsParameter.pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eDickenverstellung;
      Wandverstellung.bpStartePositionierung := TRUE;

      IF BasisStationsParameter.pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eKippen_SollPosition <> eKippen_Default THEN
         Kippen.epZielPosition := BasisStationsParameter.pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eKippen_SollPosition;
         Kippen.bpPositionieren := TRUE;
      END_IF

      steplAktion := STEP_20_E;

(* VORAB KOMPONENTEN ANSTEUERUNG WAND 1 ======================== *)
    STEP_20_E:  
      (* Hinweis:
        - Glastransport ansteuern
      *)
      tonlTimeout(IN := TRUE, PT := T#30S);

      IF NOT Glastransport.bpEintransport
        AND NOT Glastransport.bpRueckwaertsEintransportieren 
      THEN

        CASE BasisStationsParameter.pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eGlastransport OF
        
          eGlastransport_Default,
          eGlastransport_AufEinlauf:
          ;

          eGlastransport_AufEinlaufVorab:
              Glastransport.bpVortransportRueck := TRUE;
        
          eGlastransport_AufAuslauf,
          eGlastransport_AufAuslaufVorab:
            Glastransport.bpStarteVorabPositionierung := NOT Glastransport.bpAuftragAktiv;
        
        END_CASE
        
        tonlTimeout( IN := FALSE );
        steplAktion := STEP_100_E;

     ELSIF tonlTimeout.Q THEN

        tonlTimeout( IN := FALSE );
        steplAktion := STEP_100_E;

     END_IF

(* VORAB KOMPONENTEN ANSTEUERUNG WAND 1 ======================== *)
    STEP_100_E:
     (* Hinweis:
       - Einsammeln aller ausgelösten Ereignisse auf bpDone 
     *)
    // Nach 60s Fehler melden, dass die Komponenten nicht fertig werden
    tonlTimeout(IN := TRUE, PT := T#60S);

     IF (   ( Kippen.bpDone OR NOT Kippen.bpPositionieren )
       AND (( Glastransport.bpVortransport AND Glastransport.bpDone) OR NOT Glastransport.bpVortransport)
       AND (( Glastransport.bpVortransportRueck AND Glastransport.bpDone) OR NOT Glastransport.bpVortransportRueck)
       AND (( Glastransport.bpStarteVorabPositionierung AND Glastransport.bpDone) OR NOT Glastransport.bpStarteVorabPositionierung)
       AND (( Wandverstellung.bpStartePositionierung AND Wandverstellung.bpDone) OR NOT Wandverstellung.bpStartePositionierung) )
     THEN

       Glastransport.bpVortransport                    := FALSE;
       Glastransport.bpVortransportRueck               := FALSE;
       Glastransport.bpStarteVorabPositionierung       := FALSE;

       Wandverstellung.bpStartePositionierung          := FALSE;
       Kippen.bpPositionieren                          := FALSE;
       
       steplAktion := STEP_1000_E;
     END_IF

    IF tonlTimeout.Q THEN
       BasisStationsParameter.wFehlerNummer := cMELDUNG_STATION_VORABKOMPONENTENANSTEUERUN_NOT_DONE;
       steplAktion := STEP_900_E;
    END_IF

(* VORAB KOMPONENTEN ANSTEUERUNG WAND 1 ======================== *)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(* VORAB KOMPONENTEN ANSTEUERUNG WAND 1 ======================== *)
     STEP_1000_E:

       Glastransport.bpVortransport                    := FALSE;
       Glastransport.bpVortransportRueck               := FALSE;
       Glastransport.bpStarteVorabPositionierung       := FALSE;

       Wandverstellung.bpStartePositionierung          := FALSE;
       Kippen.bpPositionieren                          := FALSE;
       
       BasisStationsParameter.bVorabKomponentenAnsteuerungAbgeschlossen[wWand] := TRUE;

(* VORAB KOMPONENTEN ANSTEUERUNG WAND 1 ======================== *)
  END_CASE

END_IF

IF ( NOT BasisStationsParameter.bVorabKomponentenAnsteuerung[wWand] ) THEN

  IF ( steplAktion > STEP_0_E ) THEN
    
    IF ( NOT BasisStationsParameter.bVorabKomponentenAnsteuerungAbgeschlossen[wWand] ) THEN

      Glastransport.bpVortransport                    := FALSE;
      Glastransport.bpVortransportRueck               := FALSE;
      Glastransport.bpStarteVorabPositionierung       := FALSE;

      Wandverstellung.bpStartePositionierung          := FALSE;
      Kippen.bpPositionieren                                   := FALSE;
    END_IF
   
    BasisStationsParameter.bVorabKomponentenAnsteuerungAbgeschlossen[wWand] := FALSE;

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK