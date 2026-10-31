(* METADATA
{
  "v3Meta": {
    "objectGuid": "753f5c5d-6a5a-4872-b6fd-48516db59d96"
  }
}
*)
ACTION CheckBetriebsart
(***************************************************************************************************)
(* AKTION: BETRIEBSART PRUEFEN *)
(***************************************************************************************************)
(* Hinweis:
   - Dieser Buastein soll alle Stop- und Unterbrechungsszenarien abfangen und verwalten 
   - inkl. Messagehandling an die Steuerung beim Auftreten eines Stopszenarios (Notaus, Sicherheitskreis, Betriebsstop,...
*)

blSendJobStatus := FALSE; // zurücksetzen


// Wichtig !!!
// Es muss nur das Statuswort für die Iso Linien angepasst werden. 
// 6. Statuswort: Fremdanlage / ISO-Linie / Abnahmewand [AKTIV] 
IF (  (awSPS2MMIMaschineStatusWord[6].0 <> FALSE ) ) THEN
  awSPS2MMIMaschineStatusWord[6].0 := FALSE;
  blSendJobStatus := TRUE;
END_IF


(*----------------------------------------------------------------------------------------------------------*)
// 1. Statuswort: Autmatik aktiv
FOR i := ( cERSTER_AUTOMATIKKREIS -1 ) TO ( cLETZTER_AUTOMATIKKREIS -1 ) DO
    mask := SHL(1, i); // 1 << i
    oldValue := (awSPS2MMIMaschineStatusWord[1] AND mask) <> 0;
    newValue := M_Automatik_Aktiv[i+1];

    IF oldValue <> newValue THEN
        // Bit aktualisieren
        IF newValue THEN
            awSPS2MMIMaschineStatusWord[1] := awSPS2MMIMaschineStatusWord[1] OR mask; // Bit setzen
        ELSE
            awSPS2MMIMaschineStatusWord[1] := awSPS2MMIMaschineStatusWord[1] AND NOT mask; // Bit löschen
        END_IF

        // Änderung erkannt
        blSendJobStatus := TRUE;
    END_IF
END_FOR

(************************************************************************************************************)
// 2. Statuswort: Sicherheitskreise geschlossen
FOR i := ( cERSTER_SICHERHEITSKREIS -1 ) TO ( cLETZTER_SICHERHEITSKREIS -1 ) DO
    mask := SHL(1, i); // 1 << i
    oldValue := (awSPS2MMIMaschineStatusWord[2] AND mask) <> 0;
    newValue := ( Sicherheitskreis[i+1].bpSicherheitskreisGeschlossen OR bgSimulationSiKreisGeschlossen[i+1] );

    IF oldValue <> newValue THEN
        // Bit aktualisieren
        IF newValue THEN
            awSPS2MMIMaschineStatusWord[2] := awSPS2MMIMaschineStatusWord[2] OR mask; // Bit setzen
        ELSE
            awSPS2MMIMaschineStatusWord[2] := awSPS2MMIMaschineStatusWord[2] AND NOT mask; // Bit löschen
        END_IF

        // Änderung erkannt
        blSendJobStatus := TRUE;
    END_IF
END_FOR

(************************************************************************************************************)
// 3. Statuswort: Sicherheitskreis angefordert
FOR i := ( cERSTER_SICHERHEITSKREIS -1 ) TO ( cLETZTER_SICHERHEITSKREIS -1 ) DO
    mask := SHL(1, i); // 1 << i
    oldValue := (awSPS2MMIMaschineStatusWord[3] AND mask) <> 0;
    newValue := Sicherheitskreis[i+1].bpAnforderungSKGestellt;

    IF oldValue <> newValue THEN
        // Bit aktualisieren
        IF newValue THEN
            awSPS2MMIMaschineStatusWord[3] := awSPS2MMIMaschineStatusWord[3] OR mask; // Bit setzen
        ELSE
            awSPS2MMIMaschineStatusWord[3] := awSPS2MMIMaschineStatusWord[3] AND NOT mask; // Bit löschen
        END_IF

        // Änderung erkannt
        blSendJobStatus := TRUE;
    END_IF
END_FOR

(************************************************************************************************************)
// 4. Statuswort: Betriebsstop
FOR i := ( cERSTER_AUTOMATIKKREIS -1 ) TO ( cLETZTER_AUTOMATIKKREIS -1 ) DO
    mask := SHL(1, i); // 1 << i
    oldValue := (awSPS2MMIMaschineStatusWord[4] AND mask) <> 0;
    newValue := ( Stop_Baustein.abpBetriebsstop[i+1] OR ablFehlerAktiv[i+1] );

    IF oldValue <> newValue THEN
        // Bit aktualisieren
        IF newValue THEN
            awSPS2MMIMaschineStatusWord[4] := awSPS2MMIMaschineStatusWord[4] OR mask; // Bit setzen
        ELSE
            awSPS2MMIMaschineStatusWord[4] := awSPS2MMIMaschineStatusWord[4] AND NOT mask; // Bit löschen
        END_IF

        // Änderung erkannt
        blSendJobStatus := TRUE;
    END_IF
END_FOR

(************************************************************************************************************)
// 5. Statuswort: Not-Halt
FOR i := ( cERSTER_AUTOMATIKKREIS -1 ) TO ( cLETZTER_AUTOMATIKKREIS -1 ) DO
    mask := SHL(1, i); // 1 << i
    oldValue := (awSPS2MMIMaschineStatusWord[5] AND mask) <> 0;
    newValue := NotHalt.bpNotHaltOK;

    IF oldValue <> newValue THEN
        // Bit aktualisieren
        IF newValue THEN
            awSPS2MMIMaschineStatusWord[5] := awSPS2MMIMaschineStatusWord[5] OR mask; // Bit setzen
        ELSE
            awSPS2MMIMaschineStatusWord[5] := awSPS2MMIMaschineStatusWord[5] AND NOT mask; // Bit löschen
        END_IF

        // Änderung erkannt
        blSendJobStatus := TRUE;
    END_IF
END_FOR

(************************************************************************************************************)
//7. Statuswort: Safety, EtherCAT
IF (  (awSPS2MMIMaschineStatusWord[7].0 <> NOT Interface_SLC.bpOperatorAcknowledgeRequested ) OR
      (awSPS2MMIMaschineStatusWord[7].1 <> bgEtherCatOK )
) THEN
  awSPS2MMIMaschineStatusWord[7].0 := NOT Interface_SLC.bpOperatorAcknowledgeRequested;
  awSPS2MMIMaschineStatusWord[7].1 := bgEtherCatOK;
  blSendJobStatus := TRUE;
END_IF

(************************************************************************************************************)
// 8. Statuswort: Systemcheck
FOR i := ( cERSTER_AUTOMATIKKREIS -1 ) TO ( cLETZTER_AUTOMATIKKREIS -1 ) DO
    mask := SHL(1, i); // 1 << i
    oldValue := (awSPS2MMIMaschineStatusWord[8] AND mask) <> 0;
    newValue := SystemCheck.abpCheck[i+1];

    IF oldValue <> newValue THEN
        // Bit aktualisieren
        IF newValue THEN
            awSPS2MMIMaschineStatusWord[8] := awSPS2MMIMaschineStatusWord[8] OR mask; // Bit setzen
        ELSE
            awSPS2MMIMaschineStatusWord[8] := awSPS2MMIMaschineStatusWord[8] AND NOT mask; // Bit löschen
        END_IF

        // Änderung erkannt
        blSendJobStatus := TRUE;
    END_IF
END_FOR

(************************************************************************************************************)
// 9. Statuswort: Init
FOR i := ( cERSTER_AUTOMATIKKREIS -1 ) TO ( cLETZTER_AUTOMATIKKREIS -1 ) DO
    mask := SHL(1, i); // 1 << i
    oldValue := (awSPS2MMIMaschineStatusWord[9] AND mask) <> 0;
    newValue := Initialisierung.bpInitialisierung;

    IF oldValue <> newValue THEN
        // Bit aktualisieren
        IF newValue THEN
            awSPS2MMIMaschineStatusWord[9] := awSPS2MMIMaschineStatusWord[9] OR mask; // Bit setzen
        ELSE
            awSPS2MMIMaschineStatusWord[9] := awSPS2MMIMaschineStatusWord[9] AND NOT mask; // Bit löschen
        END_IF

        // Änderung erkannt
        blSendJobStatus := TRUE;
    END_IF
END_FOR

(************************************************************************************************************)
// 10. Statuswort: Shuttle Status
FOR i := ( cERSTES_SHUTTLE -101 ) TO ( cLETZTES_SHUTTLE -101 ) DO
    mask := SHL(1, i); // 1 << i
    oldValue := (awSPS2MMIMaschineStatusWord[10] AND mask) <> 0;
    newValue := ( aShuttle[i+101].blShuttleErreichbar AND NOT starrShuttleBasisParameter[i+101].stMKs.bDeaktivieren );

    IF oldValue <> newValue THEN
        // Bit aktualisieren
        IF newValue THEN
            awSPS2MMIMaschineStatusWord[10] := awSPS2MMIMaschineStatusWord[10] OR mask; // Bit setzen
        ELSE
            awSPS2MMIMaschineStatusWord[10] := awSPS2MMIMaschineStatusWord[10] AND NOT mask; // Bit löschen
        END_IF

        // Änderung erkannt
        blSendJobStatus := TRUE;
    END_IF
END_FOR

(************************************************************************************************************)
// 11. Statuswort: Reset
FOR i := ( cERSTER_AUTOMATIKKREIS -1 ) TO ( cLETZTER_AUTOMATIKKREIS -1 ) DO
    mask := SHL(1, i); // 1 << i
    oldValue := (awSPS2MMIMaschineStatusWord[11] AND mask) <> 0;
    newValue := agbResetAktiv[i+1];

    IF oldValue <> newValue THEN
        // Bit aktualisieren
        IF newValue THEN
            awSPS2MMIMaschineStatusWord[11] := awSPS2MMIMaschineStatusWord[11] OR mask; // Bit setzen
        ELSE
            awSPS2MMIMaschineStatusWord[11] := awSPS2MMIMaschineStatusWord[11] AND NOT mask; // Bit löschen
        END_IF

        // Änderung erkannt
        blSendJobStatus := TRUE;
    END_IF
END_FOR
END_ACTION