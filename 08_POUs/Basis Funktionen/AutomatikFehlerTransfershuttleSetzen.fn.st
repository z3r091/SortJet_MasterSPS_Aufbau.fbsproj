(* METADATA
{
  "v3Meta": {
    "objectGuid": "9a4c379e-af86-4c9e-b628-bbb819ee7aed"
  }
}
*)
FUNCTION AutomatikFehlerTransfershuttleSetzen : BOOL
VAR_INPUT
  eaAutomatikkreise    : ARRAY[cERSTER_AUTOMATIKKREIS..cANZAHL_AUTOMATIKKREISE] OF Automatikkreis_EN;
  abpFehler            : REFERENCE TO ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL;
  wSpeicherseiteFehler : BYTE; // cSPEICHER_EINLAUFSEITE oder cSPEICHER_AUSLAUFSEITE
END_VAR

// Hinweis:
// - Ein TS liegt meist als Trennglied unter dem Speicher in 2 AKs:
//   AK 1 = Einlaufseite, AK 2 = Auslaufseite
// - Welche Seite betroffen ist (Ein-/Austransport, rueckwaerts, Betriebsstopp)
//   entscheidet der Aufrufer in Job_Shuttle

// TS hat nur einen AK
IF ( eaAutomatikkreise[1] <> 0 AND eaAutomatikkreise[2] = 0 ) THEN
  abpFehler[eaAutomatikkreise[1]] := TRUE;

// TS hat 2 AK
ELSIF ( eaAutomatikkreise[1] <> 0 AND eaAutomatikkreise[2] <> 0 ) THEN
  IF ( wSpeicherseiteFehler = cSPEICHER_EINLAUFSEITE ) THEN
    abpFehler[eaAutomatikkreise[1]] := TRUE;
  ELSIF ( wSpeicherseiteFehler = cSPEICHER_AUSLAUFSEITE ) THEN
    abpFehler[eaAutomatikkreise[2]] := TRUE;
  END_IF
END_IF

AutomatikFehlerTransfershuttleSetzen := TRUE;
END_FUNCTION