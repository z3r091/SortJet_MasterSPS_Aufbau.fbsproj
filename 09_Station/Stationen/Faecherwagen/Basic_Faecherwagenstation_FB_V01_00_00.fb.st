(* METADATA
{
  "v3Meta": {
    "objectGuid": "908407cd-758c-45db-8a2d-c326aeb0e347"
  }
}
*)
FUNCTION_BLOCK ABSTRACT Basic_Faecherwagenstation_FB_V01_00_00 EXTENDS Basic_Station_FB_V01_00_00 IMPLEMENTS I_Faecherwagenstation
VAR_INPUT

  // BOOL
  blMerkerEinschleusenQuittiert     : BOOL; // Einschleusen vom Bediener an der Station quittiert
  bpRolltorUnten                    : BOOL; // Rolltor unten (aus der Sicherheitstechnik)
  bpMMIFWBaldVoll                   : BOOL; // Faecherwagen in der Station laut MMI bald voll (Anzeige an der Station), Ruecksetzen beim Verlassen der Beladeposition

  // WORD
  wlRFID_Nummer_Schreiben           : WORD; // Neue Nummer fuer den RFID-Chip des Faecherwagens (vom MMI)

END_VAR
VAR_OUTPUT

  // BOOL
  bpDone                            : BOOL;
  bpEinschleusenAbgeschlossen       : BOOL;
  bpAusschleusenAbgeschlossen       : BOOL;
  bpAuftragAktiv                    : BOOL;
  bpFehler                          : BOOL;
  bpErzwingeAusschleusen            : BOOL;
  bpErzwingeEinschleusen            : BOOL;
  bpBoxInHomePosition               : BOOL; // Mechanik der Station in Grundstellung
  bpOutBereitZumAustransport        : BOOL; // OUT STATUS: Bereit zum Austransport [Eintransport auf die Nachfolgerstation]
  bpOutBereitZumEintransport        : BOOL; // OUT STATUS: Bereit zum Eintransport [Austransport auf die Vorgaengerstation]
  bpStatusStationInBeladePosition   : BOOL; // Faecherwagen steht in der Beladeposition (zyklisch)
  bpHinweisEingriffErforderlich     : BOOL; // Bedienereingriff am Faecherwagen erforderlich (Ampel blau blinkend, Aktion Ampelsignal in Job)

  // WORD
  wpFehlerNr                        : WORD; // FEHLER-AUSWERTUNG: Fehlernummer[Const]

END_VAR
VAR

  // BOOL
  blRolltorAuf                      : BOOL; // Anforderung Rolltor oeffnen
  blRolltorAb                       : BOOL; // Anforderung Rolltor schliessen
  blRolltorAufDone                  : BOOL;
  blRolltorAbDone                   : BOOL;
  blRolltorAbFreigabe               : BOOL := TRUE; // Variante: Rolltor darf schliessen (z.B. nichts im Bereich des Rolltors)
  blRolltorAbBlockiert              : BOOL; // Variante: Schliessen sofort mit Fehler abbrechen (z.B. Abrollsicherung ausgeloest)
  blStationsposUndefiniert          : BOOL; // Station weder in Grundstellung noch in Beladeposition und kein Auftrag aktiv
  blStarteSicherheitskreisReset     : BOOL; // Anforderung Sicherheitsrelais der Station quittieren (MMI, Variante setzt nach Ausfuehrung zurueck)

  // WORD
  wlZeitHochfahren                  : WORD;
  wlZeitRunterfahren                : WORD;
  wlRFID_Nummer                     : WORD; // Zuletzt gelesene RFID-Nummer des Faecherwagens

  // TIME
  tlZeitHochfahren                  : TIME;
  tlZeitRunterfahren                : TIME;

  // STEPS
  steplRolltorAuf                   : Steps_TE;
  steplRolltorAb                    : Steps_TE;

  // TIMER
  tonlFreigabe                      : TON;
  tonlUeberwachungRolltor           : TON;
  tonlRolltorOeffnenSchliesen       : TON;
  tonlZeitRunterfahren              : TON; // Zum ermitteln wie lange das Rolltor runterfaehrt
  tonlZeitHochfahren                : TON; // Zum ermitteln wie lange das Rolltor hochfaehrt

  // ENUM
  eLetzterStatus                    : eLetzter_FW_Status; // Zuletzt erreichter Schritt fuer Systemcheck und MMI
  elLetzterStatusGesendet           : eLetzter_FW_Status; // Zuletzt ans MMI gemeldeter Status (STATION_UPDATE)

  // HARDWARE: ROLLTOR
  in_bNichtRolltorGeoeffnet         AT %I* : BOOL; // TRUE = Rolltor nicht oben
  out_bRolltorAb                    AT %Q* : BOOL;
  out_bRolltorAuf                   AT %Q* : BOOL;

END_VAR
VAR CONSTANT

  // TIME
  cZEIT_UEBERWACHUNG_ROLLTOR        : TIME := T#60S;

END_VAR

//-------------------------------------------------------------------------------------------------
// MASTER AUFRUFEN
//-------------------------------------------------------------------------------------------------
IF NOT __ISVALIDREF(BasisStationsParameter.stMKs) THEN
  dwpHandfunktionenReturn := DWORD#0;
  RETURN;
END_IF

SUPER^(BasisStationsParameter := BasisStationsParameter);

//-------------------------------------------------------------------------------------------------
// DEAKTIVIEREN
//-------------------------------------------------------------------------------------------------
// Werte wieder passend abloeschen, wenn der Baustein wieder aktiviert wird
IF ( ftlBausteinDeaktivierung.Q ) THEN
  bpDone                      := FALSE;
  bpEinschleusenAbgeschlossen := FALSE;
  bpAusschleusenAbgeschlossen := FALSE;
END_IF

(* Hinweis:
   - Deaktivierte Station: nichts melden, nichts bewegen
   - Die Variante prueft die Deaktivierung nach dem Aufruf selbst und setzt ihre Anforderungen zurueck
*)
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN

  bpDone                          := TRUE;
  bpEinschleusenAbgeschlossen     := TRUE;
  bpAusschleusenAbgeschlossen     := TRUE;
  bpStatusStationInBeladePosition := FALSE;
  bpAuftragAktiv                  := FALSE;
  bpFehler                        := FALSE;
  blStationsposUndefiniert        := FALSE;

  blRolltorAuf                    := FALSE;
  blRolltorAb                     := FALSE;
  out_bRolltorAuf                 := FALSE;
  out_bRolltorAb                  := FALSE;

  A_Visu();
  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// TIMER
//-------------------------------------------------------------------------------------------------
tonlFreigabe( IN := BasisStationsParameter.bFreigabe, PT := T#1S );

bpFehler := BasisStationsParameter.bFehler;

// Meldung "Faecherwagen bald voll" gilt nur fuer den Faecherwagen in der Beladeposition
IF NOT bpStatusStationInBeladePosition THEN
  bpMMIFWBaldVoll := FALSE;
END_IF

//-------------------------------------------------------------------------------------------------
// STATUS AN MMI MELDEN
//-------------------------------------------------------------------------------------------------
// Hinweis:
//   - Der fuer den Systemcheck gemerkte Status (eLetzterStatus) wird bei jeder Aenderung und bei
//     neuer MMI-Verbindung gemeldet; das MMI zeigt die Geraete der Station passend dazu an
IF ( eLetzterStatus <> elLetzterStatusGesendet ) OR Job.rtlMmiOk.Q THEN
  stStationUpdate.wStationsNummer       := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
  stStationUpdate.eUpdateTyp            := StationUpdateTyp_EN.FW_STATUS;
  stStationUpdate.wAnzahlWerte          := 1;
  stStationUpdate.astWerte[1].eDatenTyp := UpdateDatenTyp_EN.TYP_WORD;
  stStationUpdate.astWerte[1].wWert     := TO_WORD( eLetzterStatus );
  MsgToMmi( auftragsnr_w := SB0_SPS_STATION_UPDATE );

  elLetzterStatusGesendet := eLetzterStatus;
END_IF
END_FUNCTION_BLOCK