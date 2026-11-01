(* METADATA
{
  "v3Meta": {
    "objectGuid": "03cf6ff6-d378-4ff5-8445-541e648ef0b8"
  }
}
*)
FUNCTION_BLOCK Hub_FB
VAR_INPUT

  // BOOLEAN
  bpAktivieren               : BOOL; 
  bpStartHubAuf              : BOOL;
  bpStartHubAb               : BOOL;
  bpReset                    : BOOL;
  bpSensorEinlaufNachfolger  : BOOL; 
  bpSensorAuslaufVorgaenger  : BOOL; 
  bpSensorEinlauf            : BOOL; 
  bpSensorAuslauf            : BOOL;

  // STRUCT
  stStationsNummern          : Station_ST;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpFehler        : BOOL;
  bpDone          : BOOL;

  // WORD
  wpFehlerNr : WORD;

  // ENUM 
  epHubStatus  : Hub_EN; // Status: Gibt die Aktuelle Position des Antriebs aus

END_VAR

VAR

  // BOOLEAN 
  blErsterZyklus        : BOOL := TRUE;

  // TIMER
  tonlMaxWarteZeit                        : TON;
  tonlHubAntriebOK                        : TON;
  tonlMaximaleWartezeitAufReset           : TON;
  tonlFehlermeldungUnterdrueckenAntriebOK : TON;
  tonlReset                               : TON;

  // STEPS
  steplHubAb    : Steps_TE;
  steplHubAuf   : Steps_TE;
  steplReset    : Steps_TE;
  
END_VAR

VAR
  // HARDWARE EINGÄNGE 
  in_bSensorNichtUnten             AT%I* : BOOL;
  in_bSensorNichtOben              AT%I* : BOOL;
  in_bMotorstarter_OK              AT%I* : BOOL; 
  in_bLSBremse_OK                  AT%I* : BOOL; 
  in_bLS400V_OK                    AT%I* : BOOL; 

  // HARDWARE AUSGÄNGE
  out_bHubAbSetzen                 AT%Q* : BOOL;
  out_bHubAufSetzen                AT%Q* : BOOL;
  out_bReset                       AT%Q* : BOOL;
  out_bBremseLoesen                AT%Q* : BOOL;

END_VAR

VAR CONSTANT

  // TIME 
  MAXIMALE_WARTEZEIT_HUB                       : TIME := T#5000MS; // Maximale Wartezeit die abgewartet wird bis der Hub-Antrieb auf Position gefahren ist

END_VAR
//-------------------------------------------------------------------------------------------------
// BAUSTEIN: INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus ) THEN
  blErsterZyklus := FALSE;

  (* Hinweis:
     - Timer initialisieren
  *)
  tonlHubAntriebOK(IN:=TRUE);
  tonlMaxWarteZeit(IN:=FALSE);
  tonlFehlermeldungUnterdrueckenAntriebOK( IN := FALSE );


END_IF



//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AKTIONEN
//-------------------------------------------------------------------------------------------------
IF ( bpAktivieren ) THEN

  HubAuf();
  HubAb();

  Ausgaenge();
  Meldungen();
  Timer();
  Reset();

ELSE

  bpDone   := TRUE;
  bpFehler := FALSE;

  IF (bpStartHubAb AND NOT bpStartHubAuf) THEN
    epHubStatus := eHub_Unten;
  ELSIF (bpStartHubAuf AND NOT bpStartHubAb) THEN
    epHubStatus := eHub_Oben;
  ELSIF (bpStartHubAb AND NOT bpStartHubAuf) THEN
    epHubStatus := eHub_Undefiniert;
  END_IF

END_IF
END_FUNCTION_BLOCK