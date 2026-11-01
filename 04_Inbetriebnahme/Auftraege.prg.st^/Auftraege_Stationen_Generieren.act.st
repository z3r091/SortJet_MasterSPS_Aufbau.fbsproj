(* METADATA
{
  "v3Meta": {
    "objectGuid": "33e76168-bed7-472e-856d-00c3c96ee9ee"
  }
}
*)
ACTION Auftraege_Stationen_Generieren
//-------------------------------------------------------------------------------------------------
// AKTION: AUFTRAEGE FUER STATIONEN GENERIEREN
//-------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------
//  ABSETZEN DES AUFTRAGS
//
//  Hinweis:
// - Absetzen des Auftrags
// ---------------------------------------------------------------------------------------
IF ( arrbpButtonStationsAuswahl[201] ) THEN
  bgAuftragGenerieren := TRUE;
  arrbpButtonStationsAuswahl[201] := FALSE;
  wlInbetriebnahmeStationsnummer := 201;

// 202
ELSIF ( arrbpButtonStationsAuswahl[202] ) THEN
  bgAuftragGenerieren := TRUE;
  arrbpButtonStationsAuswahl[202] := FALSE;
  wlInbetriebnahmeStationsnummer  := 202;

// 203
ELSIF ( arrbpButtonStationsAuswahl[203] ) THEN
  bgAuftragGenerieren := TRUE;
  arrbpButtonStationsAuswahl[203] := FALSE;
  wlInbetriebnahmeStationsnummer  := 203;

// 204
ELSIF ( arrbpButtonStationsAuswahl[204] ) THEN
  bgAuftragGenerieren := TRUE;
  arrbpButtonStationsAuswahl[204] := FALSE;
  wlInbetriebnahmeStationsnummer  := 204;

// 202
ELSIF ( arrbpButtonStationsAuswahl[205] ) THEN
  bgAuftragGenerieren := TRUE;
  arrbpButtonStationsAuswahl[205] := FALSE;
  wlInbetriebnahmeStationsnummer := 205;

// 206
ELSIF ( arrbpButtonStationsAuswahl[206] ) THEN
  bgAuftragGenerieren := TRUE;
  arrbpButtonStationsAuswahl[206] := FALSE;
  wlInbetriebnahmeStationsnummer  := 206;

// 215
ELSIF ( arrbpButtonStationsAuswahl[215] ) THEN
  bgAuftragGenerieren := TRUE;
  arrbpButtonStationsAuswahl[215] := FALSE;
  wlInbetriebnahmeStationsnummer  := 215;

END_IF

// ---------------------------------------------------------------------------------------
//  AUFTRAGSTYP BESTIMMEN [FREMDANLAGE]
//
//  Hinweis:
// - Auswahl um was fuer einen Auftragstyp es sich handelt
// - AUswahl muss am Ende stehen
// ---------------------------------------------------------------------------------------
IF ( arrbpButtonFremdanlageAuswahl[401] ) THEN
  bgAuftragGenerieren := TRUE;
  arrbpButtonFremdanlageAuswahl[401] := FALSE;
  wlInbetriebnahmeStationsnummer  := 401;

// 402
ELSIF ( arrbpButtonFremdanlageAuswahl[402] ) THEN
  bgAuftragGenerieren := TRUE;
  arrbpButtonFremdanlageAuswahl[402] := FALSE;
  wlInbetriebnahmeStationsnummer  := 402;

// 403
ELSIF ( arrbpButtonFremdanlageAuswahl[403] ) THEN
  bgAuftragGenerieren := TRUE;
  arrbpButtonFremdanlageAuswahl[403] := FALSE;
  wlInbetriebnahmeStationsnummer  := 403;

END_IF

// ---------------------------------------------------------------------------------------
//  AUFTRAGSTYP BESTIMMEN
//
//  Hinweis:
// - Auswahl um was fuer einen Auftragstyp es sich handelt
// - AUswahl muss am Ende stehen
// ---------------------------------------------------------------------------------------
IF  (bgAuftragGenerieren ) THEN

  bgAuftragGenerieren := FALSE;

  IF (      bgButtonAnlegeAuftrag
       AND NOT bgButtonStationsAuftrag )
  THEN
    bgInbetriebnahmeAnlegeAuftrag   := TRUE;
    bgInbetriebnahmeStationsauftrag := FALSE;

  ELSIF (   bgButtonStationsAuftrag
          AND NOT bgButtonAnlegeAuftrag )
  THEN
    bgInbetriebnahmeStationsauftrag := TRUE;
    bgInbetriebnahmeAnlegeAuftrag   := FALSE;

  ELSE
    bgInbetriebnahmeAnlegeAuftrag   := FALSE;
    bgInbetriebnahmeStationsauftrag := FALSE;

  END_IF

END_IF
END_ACTION