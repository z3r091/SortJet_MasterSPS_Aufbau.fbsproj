(* METADATA
{
  "v3Meta": {
    "objectGuid": "0f9ee576-0110-44f2-822b-96aae40b0d13"
  }
}
*)
METHOD INTERNAL Slave_Transfershuttle
VAR_INPUT
  wStation : WORD;
END_VAR

// ****************************************************9*********************************************
// STEUERUNG: TRANSPORTKOPPLUNG
// *************************************************************************************************

IF ( AuftragsdatenTransfershuttle[wStation].wAuftrag = eStation_Transportkopplung ) THEN
  (* Hinweis:
     - Aufruf der Schrittkette
  *)
  TS_Transportkopplung[wStation]( Auftragsdaten := AuftragsdatenTransfershuttle[wStation], wStation := wStation );
  (* Hinweis:
     - Fehler-Auswertung
  *)
  blFehlerTS[wStation] := TS_Transportkopplung[wStation].bpFehler;
  IF rtlFehlerTS[wStation].Q THEN
    CASE AuftragsdatenTransfershuttle[wStation - 1].wAuftrag OF
      eStation_Eintransport:
        IF ( ( awlGlasSender[wStation - 1] >= cERSTES_INPUTSHUTTLE )
             AND ( awlGlasSender[wStation - 1] <= cLETZTES_INPUTSHUTTLE ) )
        THEN
          AutomatikFehlerTransfershuttleSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler, cSPEICHER_EINLAUFSEITE);    
        ELSIF ( ( awlGlasSender[wStation - 1] >= cERSTES_OUTPUTSHUTTLE )
                AND ( awlGlasSender[wStation - 1] <= cLETZTES_OUTPUTSHUTTLE ) )
        THEN
          AutomatikFehlerTransfershuttleSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler, cSPEICHER_AUSLAUFSEITE);
        ELSE
          AutomatikFehlerSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
        END_IF
      eStation_Austransport:
        IF ( ( awlGlasSender[wStation - 1] >= cERSTES_OUTPUTSHUTTLE )
             AND ( awlGlasSender[wStation - 1] <= cLETZTES_OUTPUTSHUTTLE ) )
        THEN
          AutomatikFehlerTransfershuttleSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler, cSPEICHER_EINLAUFSEITE);
        ELSIF ( ( awlGlasSender[wStation - 1] >= cERSTES_INPUTSHUTTLE )
                AND ( awlGlasSender[wStation - 1] <= cLETZTES_INPUTSHUTTLE ) )
        THEN
          AutomatikFehlerTransfershuttleSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler, cSPEICHER_AUSLAUFSEITE);
        ELSE
          AutomatikFehlerSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
        END_IF
      eStation_Vortransport:
        AutomatikFehlerSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
      ELSE
        IF atonlWarteAufMasterAuftrag[wStation].Q THEN
          AutomatikFehlerSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
        END_IF
    END_CASE
  END_IF
ELSE
  (* Hinweis:
     - Reset der Schrittkette
  *)
  IF ( TS_Transportkopplung[wStation].steplSchritt <> STEP_0_E ) THEN 
    TS_Transportkopplung[wStation](bpReset := TRUE);
  END_IF
END_IF

// ****************************************************9*********************************************
// STEUERUNG: QUERFAHRT
// *************************************************************************************************

IF ( AuftragsdatenTransfershuttle[wStation].wAuftrag = eStation_Vorabpositionierung ) THEN
  (* Hinweis:
     - Aufruf der Schrittkette
  *)
  TS_Querfahrt[wStation]( Auftragsdaten := AuftragsdatenTransfershuttle[wStation], wStation := wStation );
  (* Hinweis:
     - Abschluss der Schrittkette
  *)
  IF TS_Querfahrt[wStation].bpDone THEN
    AuftragsdatenTransfershuttle[wStation] := Querfahrt[wStation].Auftragsdaten;
    TS_Querfahrt[wStation](bpReset := TRUE);
  END_IF
  (* Hinweis:
     - Fehler-Auswertung
  *)
  blFehlerTS[wStation] := TS_Querfahrt[wStation].bpFehler;
  IF rtlFehlerTS[wStation].Q THEN
    AutomatikFehlerSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis:
     - Reset der Schrittkette
  *)
  IF ( TS_Querfahrt[wStation].steplSchritt <> STEP_0_E ) THEN 
    TS_Querfahrt[wStation](bpReset := TRUE);
  END_IF
END_IF
END_METHOD