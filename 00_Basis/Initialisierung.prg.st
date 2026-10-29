(* METADATA
{
	"v3Meta": {
		"objectGuid": "cf26b0b7-1f73-4db7-a5c7-b5425b79f88d"
	}
}
*)
PROGRAM Initialisierung
VAR_INPUT

  // BOOL
  bpReset                             : BOOL;
  bpInitialisierung                   : BOOL;

END_VAR
VAR_OUTPUT

  // BOOL
  bpFehler                             : BOOL;
  bpInitialisierungAktiv               : BOOL;

END_VAR
VAR

  // BOOL
  blErsterZyklus                       : BOOL := TRUE;
  blReturn                             : BOOL; // Wird gesetzt um im nächsten Zyklus mit Return rauszuspringen. Vorher sollen die WatchIO's zurück gesetzt werden
  blFreigabeZumReferenzieren           : BOOL;
  blFreigabeAutokreis                  : BOOL;
  blAlleSKGeschlossen                  : BOOL;
  blDruckluftOK                        : BOOL;
  blShuttleErreichbar                  : BOOL;
  blInitDurchFehlerGeblockt            : BOOL;

  // WORD
  wlIndex                              : WORD;
  wlSubIndex                           : WORD;
  wlMeldungsnummer                     : WORD;
    
  // INT 
  ilAnzahlStationenReferenzAktiv       : INT;
  ilAnzahlShuttleReferenzAktiv         : INT;
  ilAnzahlTransfershuttleReferenzAktiv : INT;

  // TIMER 
  tonlWait_Init                        : TON;
  tonlFreigabeReferenzierung           : TON;

  // STEPS 
  steplInitialisierung                 : STEPS_TE;

END_VAR








(***************************************************************************************************)
(* INITIALISIERUNG *)
(***************************************************************************************************)
IF ( blErsterZyklus ) THEN
 blErsterZyklus := FALSE;
END_IF

IF bgInitialisierungUeberbruecken THEN
  M_Init_Ok := TRUE;
END_IF

IF (  NOT M_Init_Ok
  AND NOT blErsterZyklus )
THEN
  bpInitialisierung := TRUE;
  blReturn          := FALSE;
ELSIF blReturn THEN
  RETURN; // Init abgeschlossen
ELSE
  bpInitialisierung := FALSE;
  blReturn          := TRUE;
END_IF

(***************************************************************************************************)
(* AKTIONEN *)
(***************************************************************************************************)
Meldungen();
Init();

(***************************************************************************************************)
(* Setzen der Freigabe für die Initialisierung ( Referenzierung ) *)
(***************************************************************************************************)
// Abfrage ob kein Reset aktiv ist 
blFreigabeAutokreis := TRUE;
FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO 
  IF agbResetAktiv[wlIndex] THEN
    blFreigabeAutokreis := FALSE;
  END_IF
END_FOR

blInitDurchFehlerGeblockt := FALSE;
FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO
 blInitDurchFehlerGeblockt := blInitDurchFehlerGeblockt OR Job.ablFehlerAktiv[wlIndex];
END_FOR

blFreigabeZumReferenzieren := ( (     NotHalt.bpNotHaltOK
	                               AND blAlleSKGeschlossen )
                                  OR bgSicherheitstechnikBruecken )
                               AND ( bgMMIOK OR bgMMIBruecken )
                               AND blDruckluftOK
										           AND blShuttleErreichbar
										           AND blFreigabeAutokreis
                              AND bgEtherCatOK
                              AND NOT blInitDurchFehlerGeblockt;

tonlFreigabeReferenzierung(IN := blFreigabeZumReferenzieren ,PT := t#5s);
END_PROGRAM