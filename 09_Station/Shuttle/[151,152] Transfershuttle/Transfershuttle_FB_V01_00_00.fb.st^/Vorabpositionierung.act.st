(* METADATA
{
  "v3Meta": {
    "objectGuid": "19ab5345-d42d-4dbb-b212-acd789e3a5f4"
  }
}
*)
ACTION Vorabpositionierung
//-------------------------------------------------------------------------------------------------
// AKTION VORABPOSITIONIERUNG
//-------------------------------------------------------------------------------------------------
(* Anmerkung:
   - Auftragsart = 3 => Verfahrauftrag zu einer bestimmten Position.[ Ohne Ein- oder Austransport von Glas]
     Dieser Auftrag wird nur ausgeführt und nicht quittiert zum MMI.
   - Auftrag kann jederzeit abgebrochen werden wenn ein Ein- bzw. Austransport Auftrag aktiv wird [Auftragsart 0 bzw. 1]

     Hinweis:
   - !!! Der Positionier-Auftrag soll jetzt auch fuer das MANUELLE POSITIONIEREN genutzt werden !!!
*)
IF ( BasisStationsParameter.bVorabpositionieren
     AND NOT BasisStationsParameter.bEintransport[cWAND_1]
     AND NOT BasisStationsParameter.bAustransport[cWAND_1] )
THEN
  CASE steplVorabpositionierung OF
    // VORABPOSITIONIERUNG ==============================
    STEP_0_E:
      BasisStationsParameter.bUpdateVorabPositionieren := FALSE;
      blUpdateTimer := FALSE;
      tonlWarteShuttleSicherVerfahren(IN:=FALSE);

      rpIstPositionNachPositionierung := REAL#0;

      // evtl. Zielposition shon erreicht ?
      //    z.B.: für ein Vortransport
      IF (ABS( Querfahrt.rpAktPosition - BasisStationsParameter.pAuftragVorabPositionierung.rVorabPosition ) <= rgMKZielPositionToleranz ) THEN
        rpIstPositionNachPositionierung := Querfahrt.rpAktPosition;
        BasisStationsParameter.bUpdateVorabPositionieren := TRUE;
        steplVorabpositionierung := STEP_1000_E;
      ELSE

        Glastransport.bpShuttleAbsenken := TRUE;
        steplVorabpositionierung := STEP_10_E;

      END_IF
    // VORABPOSITIONIERUNG ==============================
    STEP_10_E:
      (* Hinweis:
         - Warten auf evtl. noch einzufahrenden Luftschranken oder Zylinder
      *)
      tonlWarteShuttleSicherVerfahren(IN:=TRUE,PT:=t#4s);


      // Shuttle auf Position fahren
      IF ( Glastransport.bpBereitZumVerfahren AND blShuttleKannSicherVerfahrenWerden ) THEN
        Querfahrt.rpDestinationPosition := BasisStationsParameter.pAuftragVorabPositionierung.rVorabPosition;
        steplVorabpositionierung := STEP_20_E;
      END_IF

      IF tonlWarteShuttleSicherVerfahren.Q THEN
        BasisStationsParameter.wFehlerNummer := cMELDUNG_QUERFAHRT_NICHT_VERFAHR_BEREIT;
        steplVorabpositionierung := STEP_900_E;
      END_IF

    // VORABPOSITIONIERUNG ==============================
    STEP_20_E:
      Querfahrt.bpVerfahreShuttle := TRUE;

      IF ( Querfahrt.bpAntriebLaeuft OR Querfahrt.bpDone ) THEN
        blUpdateTimer := TRUE;
        steplVorabpositionierung := STEP_30_E;
      END_IF

      (* Fehlerbehandlung:
         - Querfahrt [VERFAHRLOGIK]
      *)
      IF ( Querfahrt.bpFehler ) THEN
        Querfahrt.bpVerfahreShuttle  := FALSE;
        BasisStationsParameter.wFehlerNummer := Querfahrt.wpFehlerNr;
        steplVorabpositionierung := STEP_900_E;
      END_IF

    // VORABPOSITIONIERUNG ==============================
    STEP_30_E:
      (* Anmerkung:
         - Sollte das Verfahren frueher abgeschlossen werden als der Zeitwert des Timers "tonlUpdateTimer"
           muss das Bit "bpUpdate" gesetzt werden. Damit ist Sichergestellt ist das wir in der Steuerung
           das Verfahren abgeschlossen werden kann.
           => Senden der Positionsnachricht [Steuerung]
      *)
      IF ( Querfahrt.bpDone (* AND blZielPositionErreicht *) ) THEN

        (* Hinweis:
           - Position merken vor dem heben, durch das Heben kann es passieren das sich die Endposition
             verschiebt und damit an die HMI eine fehlerhafte Ist-Position geschickt wird
        *)
        rpIstPositionNachPositionierung := Querfahrt.rpAktPosition;

        IF ( NOT tonlUpdateTimer.Q ) THEN
          tonlUpdateTimer(IN := FALSE);
          blUpdateTimer := FALSE;
          BasisStationsParameter.bUpdateVorabPositionieren := TRUE;
        END_IF

        Querfahrt.bpVerfahreShuttle  := FALSE;

        steplVorabpositionierung := STEP_100_E;
      END_IF

      (* Hinweis:
         - Senden der Positionsnachricht [Steuerung]
      *)
      IF ( tonlUpdateTimer.Q ) THEN
        tonlUpdateTimer(IN := FALSE);
        blUpdateTimer := FALSE;
        BasisStationsParameter.bUpdateVorabPositionieren := TRUE;
      END_IF

      (* Fehlerbehandlung:
         - Querfahrt [VERFAHRLOGIK]
      *)
      IF ( Querfahrt.bpFehler ) THEN
        Querfahrt.bpVerfahreShuttle  := FALSE;
        BasisStationsParameter.wFehlerNummer := Querfahrt.wpFehlerNr;
        steplVorabpositionierung := STEP_900_E;
      END_IF

    // VORABPOSITIONIERUNG ==============================
    STEP_100_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< FOLGEAUFTRAG IST EIN- AUS- TRANSPORT >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   HINWEIS:
      //   - Nach dem Positionieren kann das Transfershuttle heben wenn der Folgeauftrag ein Ein- bzw. Aus- Transportauftrag ist
      IF ( pAuftragsdatenPositionieren.wAuftragstyp  = cFOLGEAUFTRAG_AKTIV ) THEN

        IF ( BasisStationsParameter.pVorAbAuftragsdaten[cWAND_1].wShuttleNummer = BasisStationsParameter.stMKs.stStationsNummern.NummerSPS )
        THEN

          (* Hinweis:
             - Der Auftragsstyp ist immer der selbe wie im dazugehörigen <MULTISHUTTLEDATA>- der Transportshuttle.
               Dies Bedeutet konkret:
               => (Input-) Shuttle Austransport-Auftrag so wird das Transfershuttle auch den Auftragsstatus Austransport gesendet bekommen
                  Die Logik ist somit invertiert zum Shuttle:
               Beispiel:
                    Shuttle - 0 -> Eintransport => TS - 0 -> Austransport
                    Shuttle - 1 -> Austransport => TS - 1 -> Eintransport
               ReservierungsStatus := SEL( pVorAbAuftragsdaten.wAuftragstyp.0,
                                      TS_AUSTRANSPORT_RESERVIERUNG,
                                      TS_EINTRANSPORT_RESERVIERUNG );
          *)

          Glastransport.pAuftrag.stAuftragsInformationen := BasisStationsParameter.pVorAbAuftragsdaten[cWAND_1].stAuftragsInformationen;
          Glastransport.bpStarteHebeVorgang              := TRUE;

          steplVorabpositionierung := STEP_110_E;

        ELSE
          steplVorabpositionierung := STEP_1000_E;

        END_IF

      ELSE
        steplVorabpositionierung := STEP_1000_E;

      END_IF

    // VORABPOSITIONIERUNG ==============================
    STEP_110_E:
      (* Hinweis:
         - Hebe-Vorgang abgeschlossen
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpStarteHebeVorgang := FALSE;
        steplVorabpositionierung := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
      *)
      IF ( Glastransport.bpFehler ) THEN
        Glastransport.bpStarteHebeVorgang := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplVorabpositionierung := STEP_900_E;
      END_IF

    // VORABPOSITIONIERUNG ==============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // VORABPOSITIONIERUNG ==============================
    STEP_1000_E:
      BasisStationsParameter.bVorabpositionierenAbgeschlossen := TRUE;

  // VORABPOSITIONIERUNG ==============================
  END_CASE
END_IF

IF ( NOT BasisStationsParameter.bVorabpositionieren ) THEN

  IF (steplVorabpositionierung > STEP_0_E) THEN
    BasisStationsParameter.bVorabpositionierenAbgeschlossen := FALSE;
    BasisStationsParameter.bUpdateVorabPositionieren        := FALSE;
    blUpdateTimer := FALSE;

    tonlUpdateTimer(IN := FALSE);
    Querfahrt.bpVerfahreShuttle := FALSE;

    Glastransport.bpShuttleAbsenken   := FALSE;
    Glastransport.bpStarteHebeVorgang := FALSE;

    steplVorabpositionierung := STEP_0_E;
  END_IF

END_IF
END_ACTION