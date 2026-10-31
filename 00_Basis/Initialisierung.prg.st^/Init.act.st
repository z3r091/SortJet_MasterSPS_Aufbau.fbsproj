(* METADATA
{
  "v3Meta": {
    "objectGuid": "cd5c5864-c71f-4180-a1ae-035e373e6989"
  }
}
*)
ACTION Init
(***************************************************************************************************)
(* AKTION: INITIALISIERUNG *)
(***************************************************************************************************)

IF ( bpInitialisierung
  AND NOT bpReset )
THEN
 CASE steplInitialisierung OF
(* INITIALISIERUNG [REFERENZ] ===================================== *)
  STEP_0_E:
    IF ( tonlFreigabeReferenzierung.Q ) THEN

      // Horn aktivieren
      FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

      FOR wlSubIndex := 1 TO cANZAHL_HUPEN DO
          Horn_AK[wlIndex,wlSubIndex].wpStatusArt      := 4;
          Horn_AK[wlIndex,wlSubIndex].tpHornZeit       := T#3S;
          Horn_AK[wlIndex,wlSubIndex].bpHornAktivieren := TRUE;
      END_FOR

      END_FOR

      (* Hinweis:
         - Setzen der Verfahrfreigabe der Shuttle
      *)
      FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
        abgVerfahrfreigabeShuttle[wlIndex] := TRUE;
      END_FOR

      FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
        abgVerfahrfreigabeShuttle[wlIndex] := TRUE;
      END_FOR

      ilAnzahlStationenReferenzAktiv         := INT#0;
      ilAnzahlShuttleReferenzAktiv           := INT#0;
      ilAnzahlTransfershuttleReferenzAktiv   := INT#0;

      steplInitialisierung := STEP_5_E;

   END_IF

(* INITIALISIERUNG [REFERENZ] ===================================== *)
  STEP_5_E:
    (* Hinweis:
       - Referenzierung der Antriebe
         => Shuttle / Einlauf / Auslauf
    *)
    tonlWait_Init(IN := FALSE);

    // SHUTTLE
    FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
      IF NOT starrShuttleBasisParameter[wlIndex].bIstReferenziert AND NOT starrShuttleBasisParameter[wlIndex].stMKs.bDeaktivieren THEN
      IF ( starrShuttleBasisParameter[wlIndex].stMKs.eStationsTyp = eInputshuttle ) OR ( starrShuttleBasisParameter[wlIndex].stMKs.eStationsTyp = eOutputshuttle ) THEN
            starrShuttleBasisParameter[wlIndex].bReferenz := TRUE;
            ilAnzahlShuttleReferenzAktiv := ilAnzahlShuttleReferenzAktiv + 1;
        END_IF
      END_IF
    END_FOR

    // TRANSFERSHUTTLE
    FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
      IF ( NOT starrTransfershuttleBasisParameter[wlIndex].bIstReferenziert AND NOT starrTransfershuttleBasisParameter[wlIndex].stMKs.bDeaktivieren ) THEN
      IF ( starrTransfershuttleBasisParameter[wlIndex].stMKs.eStationsTyp = eTransfershuttle ) THEN
          starrTransfershuttleBasisParameter[wlIndex].bReferenz := TRUE;
          ilAnzahlTransfershuttleReferenzAktiv := ilAnzahlTransfershuttleReferenzAktiv + 1;
        END_IF
      END_IF
    END_FOR

    // STATIONEN
    FOR wlIndex := cERSTE_STATION  TO cLETZTE_STATION DO
      IF ( NOT starrStationBasisParameter[wlIndex].bIstReferenziert AND NOT starrStationBasisParameter[wlIndex].stMKs.bDeaktivieren ) THEN
    IF ( starrStationBasisParameter[wlIndex].stMKs.eStationsTyp = eStation ) THEN
          starrStationBasisParameter[wlIndex].bReferenz := TRUE;
          ilAnzahlStationenReferenzAktiv := ilAnzahlStationenReferenzAktiv + 1;
        END_IF
      END_IF
    END_FOR

    steplInitialisierung := STEP_100_E;

(* INITIALISIERUNG [REFERENZ] ===================================== *)
  STEP_100_E:
    (* Anmerkung:
       - Warten bis die Antriebe referneziert melden,wenn kein Fehlerauftritt muss die referenzierung der Antriebe wieder zurueck genommen werden.
         Kommt es zu einem Fehlverhalten bei der Referenzierung bzw. der Timer läuft ab, muss ein Fehler geworfen werden.
    *)
    tonlWait_Init(IN := TRUE, PT := tgTimeWarteAufInitDone);

    // SHUTTLE
    FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO

      IF (  starrShuttleBasisParameter[wlIndex].bReferenzAbgeschlossen
        AND starrShuttleBasisParameter[wlIndex].bReferenz )
      THEN
        starrShuttleBasisParameter[wlIndex].bReferenz := FALSE;
        ilAnzahlShuttleReferenzAktiv := ilAnzahlShuttleReferenzAktiv - 1;
      END_IF

    END_FOR

    // TRANSFERSHUTTLE
    FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO

      IF (  starrTransfershuttleBasisParameter[wlIndex].bReferenzAbgeschlossen
        AND starrTransfershuttleBasisParameter[wlIndex].bReferenz )
      THEN
        starrTransfershuttleBasisParameter[wlIndex].bReferenz := FALSE;
        ilAnzahlTransfershuttleReferenzAktiv := ilAnzahlTransfershuttleReferenzAktiv - 1;
      END_IF

    END_FOR

    // STATIONEN
    FOR wlIndex := cERSTE_STATION  TO cLETZTE_STATION DO

      IF (  starrStationBasisParameter[wlIndex].bReferenzAbgeschlossen
        AND starrStationBasisParameter[wlIndex].bReferenz )
      THEN
        starrStationBasisParameter[wlIndex].bReferenz := FALSE;
        ilAnzahlStationenReferenzAktiv :=  ilAnzahlStationenReferenzAktiv - 1;
      END_IF

    END_FOR

    (* Hinweis:
       - Referenzierung der Stationen \ Shuttle abgeschlossen
    *)
    IF (  ilAnzahlStationenReferenzAktiv = 0
      AND ilAnzahlShuttleReferenzAktiv   = 0
      AND ilAnzahlTransfershuttleReferenzAktiv = 0 )
    THEN
      steplInitialisierung := STEP_1000_E;
    END_IF

    (* Fehlerbehandlung:
       - Zeitlicheueberwachung, ob die Referenzierung der Antriebe in der angegebenen Zeit ablaeuft. 
    *)
    IF ( tonlWait_Init.Q ) THEN

      SpsError( eFehler_Station, 
                cMELDUNG_INITIALISIEURNG_TIME_OUT, 
                0, 
                AutomatikkreisBestimmen(0),
                wpgFehlerdaten );

      // SHUTTLE
      FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
        starrShuttleBasisParameter[wlIndex].bReferenz := FALSE;

        IF ( NOT starrShuttleBasisParameter[wlIndex].bFehler ) THEN
          SpsError( eFehler_Station, 
                    starrShuttleBasisParameter[wlIndex].wFehlerNummer,
                    wlIndex, 
                    AutomatikkreisBestimmen(wlIndex), 
                    starrShuttleBasisParameter[wlIndex].awFehlerInformationen );
        END_IF

      END_FOR

      // TRANSFERSHUTTLE
      FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
        starrTransfershuttleBasisParameter[wlIndex].bReferenz := FALSE;

        IF ( NOT starrTransfershuttleBasisParameter[wlIndex].bFehler ) THEN
          SpsError( eFehler_Station,
                    starrTransfershuttleBasisParameter[wlIndex].wFehlerNummer, 
                    wlIndex,
                    AutomatikkreisBestimmen(wlIndex),
                    starrTransfershuttleBasisParameter[wlIndex].awFehlerInformationen );
        END_IF

      END_FOR

      // STATIONEN
      FOR wlIndex := cERSTE_STATION  TO cLETZTE_STATION DO
        starrStationBasisParameter[wlIndex].bReferenz := FALSE;

        IF ( starrStationBasisParameter[wlIndex].bFehler ) THEN
          SpsError( eFehler_Station, 
                    starrStationBasisParameter[wlIndex].wFehlerNummer, 
                    wlIndex, 
                    AutomatikkreisBestimmen(wlIndex), 
                    starrStationBasisParameter[wlIndex].awFehlerInformationen );
        END_IF

      END_FOR

      steplInitialisierung := STEP_900_E;

    END_IF

(* INITIALISIERUNG [REFERENZ] ===================================== *)
    STEP_900_E:
      bpFehler := TRUE;

(* INITIALISIERUNG [REFERENZ] ===================================== *)
    STEP_1000_E:
      M_Init_Ok := TRUE;

(* INITIALISIERUNG [REFERENZ] ===================================== *)
  END_CASE

END_IF

IF ( NOT bpInitialisierung OR bpReset ) THEN

 IF ( steplInitialisierung > STEP_0_E OR bpReset ) THEN

   bpInitialisierung := FALSE;
   tonlFreigabeReferenzierung( IN := FALSE );
 
   steplInitialisierung := STEP_0_E;

    // SHUTTLE
    FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
      starrShuttleBasisParameter[wlIndex].bReferenz := FALSE;
    END_FOR

    // TRANSFERSHUTTLE 
    FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
      starrTransfershuttleBasisParameter[wlIndex].bReferenz := FALSE;
    END_FOR

    // STATIONEN 
    FOR wlIndex := cERSTE_STATION  TO cLETZTE_STATION DO
      starrStationBasisParameter[wlIndex].bReferenz := FALSE;
    END_FOR

   // Reset 
   bpFehler := FALSE;
   bpReset := FALSE;

 END_IF

END_IF
END_ACTION