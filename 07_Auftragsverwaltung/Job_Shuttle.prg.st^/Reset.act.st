(* METADATA
{
	"v3Meta": {
		"objectGuid": "238ec719-f16e-4d9c-9f71-7a8241f71645"
	}
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// AKTION: RESET
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Zuruecksetzen des AK
     => Inputshuttle [expliziet]
*)
FOR wlIndexReset := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

  IF abpReset[wlIndexReset] THEN

    abpReset[wlIndexReset] := FALSE;
    abpFehler[wlIndexReset] := FALSE;

    FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
      IF StationInAutomatikkreis(starrShuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wlIndexReset) THEN
        AuftragsSpeicherShuttle[wlIndex].bpReset := TRUE;
        AuftragsSpeicherShuttle[wlIndex]();

        abgVerfahrfreigabeShuttle[wlindex] := TRUE;

        AuftragsdatenStation[wlIndex].wAuftrag := eStation_Kein_Auftrag;

        starrShuttleBasisParameter[wlIndex].bReset := TRUE;

        Querfahrt[wlIndex]( bpReset := TRUE );
        Racksuche[wlIndex]( bpReset := TRUE );

        FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO

          AuftragsSpeicherWand[wlIndex,wlIndexWand].bpReset := TRUE;
          AuftragsSpeicherWand[wlIndex,wlIndexWand]();

          Eintransport[wlIndex, wlIndexWand]( bpReset := TRUE );
          Austransport[wlIndex, wlIndexWand]( bpReset := TRUE );

          VorabkomponentenAnsteuerung[wlIndex, wlIndexWand]( bpReset := TRUE );

          AuftragsdatenWand[wlIndex, wlIndexWand].wAuftrag := eStation_Kein_Auftrag;
          VorAbAuftragsDaten[wlIndex, wlIndexWand].wAuftrag := eStation_Kein_Auftrag;

          blFehler[wlIndex, wlIndexWand] := FALSE;

          starrShuttleBasisParameter[wlIndex].bEintransportGewesen[wlIndexWand] := FALSE;
        END_FOR

      END_IF
    END_FOR

    FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE  DO

      // WICHTIG: OR_ELSE -> ZWEITE BEDINGUNG WIRD NUR GEPRÜFT, WENN ERSTE FALSE IST !!! IST DIE ERSTE FALSE, WIRD DIE 2. BEDINGUNG GEPRÜFT ; IST DIE ERSTE TRUE, WIRD DIE 2. BEDINGUNG IGNORIERT UND NICHT MEHR GEPRÜFT (wg. ZUGRIFFSVERLETZTUNG)
      // Alle konfigurierten Automatikkreise des TS sind in Hand
      // ODER
      // Output-AK ist nicht in den vorhandenen Automatikkreisen der Maschine definiert ; das heißt, Erster AK = 1 und ANZAHL < wlAutomatikkreis2 --- OR_ELSE der 2. konfigurierte Automatikkreis für das TS ist 0; somit ist das TS nur in einem AK definiert
      IF   ( NOT AutomatikAktiv(wlIndex)
             OR ( ( cANZAHL_AUTOMATIKKREISE = 1 ) OR_ELSE ( starrTransfershuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis[wlAutomatikkreis2] = 0 ) ) )
           AND StationInAutomatikkreis(starrTransfershuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wlIndexReset)
      THEN
        AuftragsSpeicherTransfershuttle[wlIndex].bpReset := TRUE;
        AuftragsSpeicherTransfershuttle[wlIndex]();

        abgVerfahrfreigabeShuttle[wlindex] := TRUE;

        abpStarteParalleleBausteinAnsteuerung[wlIndex] := FALSE;
        abpSpeicherfachValidierung[wlIndex]  := FALSE;
        AuftragsdatenTransfershuttle[wlIndex].wAuftrag := eStation_Kein_Auftrag;
        starrTransferShuttleBasisParameter[wlIndex].bReset := TRUE;
        blFehlerTS[wlIndex] := FALSE;

      ELSE


        // Der zu resettende AK entspricht dem ERSTEN (INPUTSEITE) konfigurierten AK des TS
        // UND Doppelte Sicherheit: Nochmal prüfen, dass das TS im zu resetten AK ist
        // UND Automatik des zu resettenden AK darf NICHT mehr TRUE sein
        IF        wlIndexReset = starrTransfershuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis[1]
                  AND     StationInAutomatikkreis(starrTransfershuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wlIndexReset)
                  AND NOT M_Automatik_Aktiv[starrTransfershuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis[1]]
        THEN
          IF ( ( ( AuftragsdatenTransfershuttle[wlIndex].wAuftrag = eStation_Eintransport )
                 OR ( AuftragsdatenTransfershuttle[wlIndex].wAuftrag = eStation_Scheibenkorrektur )
                 OR ( aTransfershuttles[wlIndex].ReservierungsStatus = TS_EINTRANSPORT_RESERVIERUNG )
                 OR ( aTransfershuttles[wlIndex].ReservierungsStatus = TS_AUSTRANSPORT_RUECKWERTIG_RESERVIERUNG ) )
               AND NOT aTransfershuttles[wlIndex].bpAnforderungBetriebsstopp )
          THEN
            AuftragsSpeicherTransfershuttle[wlIndex].bpReset := TRUE;
            AuftragsSpeicherTransfershuttle[wlIndex]();

            abgVerfahrfreigabeShuttle[wlindex] := TRUE;

            abpStarteParalleleBausteinAnsteuerung[wlIndex] := FALSE;
            abpSpeicherfachValidierung[wlIndex]  := FALSE;
            AuftragsdatenTransfershuttle[wlIndex].wAuftrag := eStation_Kein_Auftrag;
            starrTransferShuttleBasisParameter[wlIndex].bReset := TRUE;
            blFehlerTS[wlIndex] := FALSE;

            (* Hinweis:
               - Gilt nur fuer Systeme mit Master - Slave  Transfershuttle
            *)
            IF ( wlIndex MOD 2 = 1 ) AND ( UPPER_BOUND(AuftragsdatenTransfershuttle, 1 ) >= (wlIndex + 1) ) AND_THEN ( AuftragsdatenTransfershuttle[wlIndex + 1].wAuftrag = eStation_Transportkopplung ) THEN
              AuftragsdatenTransfershuttle[wlIndex + 1].wAuftrag := eStation_Kein_Auftrag;
              starrTransferShuttleBasisParameter[wlIndex + 1].bReset := TRUE;
            END_IF
          END_IF
        END_IF

        // Der zu resettende AK entspricht dem ZWEITEN (OUTPUTSEITE) konfigurierten AK des TS
        // UND Doppelte Sicherheit: Nochmal prüfen, dass das TS im zu resetten AK ist
        // UND Automatik des zu resettenden AK darf NICHT mehr TRUE sein
        IF        wlIndexReset = starrTransfershuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis[wlAutomatikkreis2]
                  AND_THEN     StationInAutomatikkreis(starrTransfershuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wlIndexReset)
                  AND_THEN NOT M_Automatik_Aktiv[starrTransfershuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis[wlAutomatikkreis2]]
        THEN
          IF ( ( ( AuftragsdatenTransfershuttle[wlIndex].wAuftrag = eStation_Austransport )
                 OR ( AuftragsdatenTransfershuttle[wlIndex].wAuftrag = eStation_Scheibenkorrektur )
                 OR ( aTransfershuttles[wlIndex].ReservierungsStatus = TS_AUSTRANSPORT_RESERVIERUNG )
                 OR ( aTransfershuttles[wlIndex].ReservierungsStatus = TS_EINTRANSPORT_RUECKWERTIG_RESERVIERUNG ) )
               AND NOT aTransfershuttles[wlIndex].bpAnforderungBetriebsstopp )
          THEN
            AuftragsSpeicherTransfershuttle[wlIndex].bpReset := TRUE;
            AuftragsSpeicherTransfershuttle[wlIndex]();

            abgVerfahrfreigabeShuttle[wlindex] := TRUE;

            abpStarteParalleleBausteinAnsteuerung[wlIndex] := FALSE;
            abpSpeicherfachValidierung[wlIndex]  := FALSE;
            AuftragsdatenTransfershuttle[wlIndex].wAuftrag := eStation_Kein_Auftrag;
            starrTransferShuttleBasisParameter[wlIndex].bReset := TRUE;
            blFehlerTS[wlIndex] := FALSE;
            (* Wichtig:
               - Gilt nur fuer Systeme mit Master - Slave  Transfershuttle-Verbund
            *)
            IF ( wlIndex MOD 2 = 1 ) AND ( UPPER_BOUND(AuftragsdatenTransfershuttle, 1 ) >= (wlIndex + 1) ) AND_THEN ( AuftragsdatenTransfershuttle[wlIndex + 1].wAuftrag = eStation_Transportkopplung ) THEN
              AuftragsdatenTransfershuttle[wlIndex + 1].wAuftrag := eStation_Kein_Auftrag;
              starrTransferShuttleBasisParameter[wlIndex + 1].bReset := TRUE;
            END_IF
          END_IF
        END_IF

      END_IF

    END_FOR

  END_IF

END_FOR
END_ACTION