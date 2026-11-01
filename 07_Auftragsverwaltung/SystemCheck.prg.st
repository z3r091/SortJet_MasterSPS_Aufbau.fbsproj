(* METADATA
{
  "v3Meta": {
    "objectGuid": "0b2e66de-e2de-4ed3-849b-e96a185ab44d"
  }
}
*)
PROGRAM SystemCheck
VAR_INPUT

  // BOOLEAN
  abpCheck                 : ARRAY [cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL;
  abpReset                 : ARRAY [cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL; // Fehler aus dem Resetbaustein heraus zurücksetzen
  abpStationsDatenErhalten : ARRAY [cERSTES_SHUTTLE..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF BOOL;


END_VAR
VAR_OUTPUT

  // BOOL
  abpFehler        : ARRAY [cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL;

END_VAR
VAR

  // BOOL
  blErsterZyklus                      : BOOL := TRUE;
  ablTimeOutMeldungGenerieren         : ARRAY [cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL; 
  blCheckAktiv                        : BOOL;
  ablCheck                            : ARRAY [cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS, 1..cMAX_ANZAHL_SYSTEMCHECKZYKLEN] OF BOOL;
  ablCheckDone                        : ARRAY [cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS, 1..cMAX_ANZAHL_SYSTEMCHECKZYKLEN] OF BOOL;
  ablStationCheckAktiv                : ARRAY[cERSTE_STATION..cLETZTE_STATION] OF BOOL;
  ablFWCheckAktiv                     : ARRAY[cERSTE_FAECHERWAGENSTATIONS_NR..cLETZTE_FAECHERWAGENSTATIONS_NR] OF BOOL;
  ablShuttleCheckAktiv                : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF BOOL;

  // STEPS
  asteplCheck                         : ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS, 1..cMAX_ANZAHL_SYSTEMCHECKZYKLEN] OF Steps_TE;

  // WORD
  wlIndex                            : WORD;
  wlIndexSystemcheckZyklus           : WORD;
  wlIndexAutomatikkreis              : WORD;
  wlIndexStationsnummer              : WORD;
  wlIndexQuitt                       : WORD;
  wlAktiverZyklus                    : WORD;

  // INT
  ailAnzahlStationenCheckAktiv       : ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF INT;
  ailAnzahlShuttleCheckAktiv         : ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF INT;
  ailAnzahlFWStationenCheckAktiv     : ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF INT;

  // TIMER                                                                                           
  atonlWarnungSystemCheckBeginnt     : ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF TON;
  atonlWaitCheck                     : ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF TON;
  atonlCheck                         : ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF TON;
  atonlCheckWarteAufMMIDaten         : ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF TON;
  tonlCheckAktiv                     : ton;

END_VAR
//-------------------------------------------------------------------------------------------------
// INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
// Zeiger Initialisieren
//  - SystemCheck mit Vorgaenger- bzw. Nachfolger- Station
IF ( blErsterZyklus ) THEN
  blErsterZyklus := FALSE;

  FOR wlIndex := cERSTES_SHUTTLE TO cLETZTE_STATION DO
    abpStationsDatenErhalten[wlIndex,1] := FALSE;
  END_FOR

END_IF

// Check aktiv und Init nicht OK
blCheckAktiv := FALSE;
FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO
  IF abpCheck[wlIndex] OR abpReset[wlIndex] THEN
    blCheckAktiv := TRUE;
  END_IF
END_FOR

Reset();
// Wenn kein Systemcheck aktiv -> Rausspringen
tonlCheckAktiv( IN  := NOT blCheckAktiv, PT := T#100MS);
IF tonlCheckAktiv.Q THEN  
  RETURN; //Funktioniert noch nicht richtig
END_IF

//-------------------------------------------------------------------------------------------------
// TIMER
//-------------------------------------------------------------------------------------------------
(* Anmerkung:
   - Wartezeit bis mit dem SystemCheck begonnen wird
   - Die Sicherheitskreise müssen einen Moment lang quittiert sein, damit alle Antriebe hoch gelaufen sind

     SystemCheck starten
   - Verbindung zur MMI ist vorhanden
   - Freigabe [Rest ist nicht aktiv]
   - Sicherheitskreise geschlossen
   - Notaus nicht aktiv
   - Arbeitsdruck [Druckluft] ist in Ordnung
*)
FOR wlIndexAutomatikkreis := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

  atonlWaitCheck[wlIndexAutomatikkreis]( IN := ( M_INIT_OK
                                                 AND NotHalt.bpNotHaltOK
                                                 AND EtherCAT_Master.xConfigFinished
                                                 AND checkSafetyCircuitsClosedFromAutomaticCircuit(wlIndexAutomatikkreis)
                                                 AND ( TCPMain.l_fb_SortjetHMI.o_b_WatchdogOk OR bgMMIBruecken )
                                                 AND StatusAnlage.bpAnlageOK ),
                                         PT := T#3S);

END_FOR

//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------

Vorsteuerung();

FOR wlIndexAutomatikkreis := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO
  FOR wlIndexSystemcheckZyklus := 1 TO wgAnzahlSystemcheckZyklen DO
    Systemcheck(wlIndexAutomatikkreis, wlIndexSystemcheckZyklus);
  END_FOR
END_FOR

Quittierung_Scheiben();
Meldungen();
END_PROGRAM