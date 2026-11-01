(* METADATA
{
  "v3Meta": {
    "objectGuid": "c1b0cb81-ca36-4c89-b223-c59fbfe1da3d"
  }
}
*)
FUNCTION_BLOCK ScheibenZaehler_FB

// SET - PROPERTIES
VAR_INPUT

  // BOOLEAN
  bpReset    : BOOL; // Hinweis: Ruecksetzen des Bausteins
  bpAktiv    : BOOL; // Hinweis: AKtivieren des Bausteins
  bpStart    : BOOL; // Hinweis: AKtivieren des Bausteins
  bpSensor   : BOOL; // Hinweis: Sensor mittels dem die Scheiben gezaehlt werden sollen

END_VAR

// GET - PROPERTIES
VAR_OUTPUT

  // BOOLEAN
  bpFehler            : BOOL := FALSE;
  bpScheibeQuittieren : BOOL;

END_VAR

VAR_IN_OUT

  // INT
  ipScheibenAnzahl : INT;

END_VAR

// PRIVATE MEMBER
VAR

  // BOOLEAN
  blScheibenAnfangErkannt : BOOL;

  // TRIGGER
  rtlScheibenAnfangErkannt : R_TRIG;
  rtlScheibenEndeErkannt   : R_TRIG;

  // TIMER
  tonlSensor : TON; // Einschalverzoegerung
  toflSensor : TOF; // Ausschalverzoegerung

END_VAR

VAR CONSTANT
  cSENSOR_SCHALTVERZOEGERUNG : TIME := T#50ms;
END_VAR

IF ( bpReset ) THEN

  bpStart  := FALSE;
  bpFehler := FALSE;
  bpReset  := FALSE;

  blScheibenAnfangErkannt := FALSE;

  rtlScheibenAnfangErkannt(CLK := FALSE);
  rtlScheibenEndeErkannt(CLK := FALSE);

ELSE

  IF ( bpAktiv ) THEN

    (* Hinweis:
       - Entprellen des Sensors
    *)
    tonlSensor( IN := bpSensor, PT:= cSENSOR_SCHALTVERZOEGERUNG );
    toflSensor( IN := bpSensor, PT:= cSENSOR_SCHALTVERZOEGERUNG );

    (* Hinweis:
       - Starten des Vorgangs
    *)
    IF ( bpStart ) THEN

      (* Hinweis:
         - Scheibenquittierung zuruecksetzen
      *)
      bpScheibeQuittieren := FALSE;


      (* Hinweis:
         - Es wurde eine Scheibenkante erkannt [Scheibenanfang]
      *)
      rtlScheibenAnfangErkannt( CLK := tonlSensor.Q
                                AND NOT blScheibenAnfangErkannt);

      IF ( rtlScheibenAnfangErkannt.Q ) THEN
        blScheibenAnfangErkannt := TRUE;
      END_IF

      (* Hinweis:
         - Es wurde eine Scheibenanfang erkannt es muss nun ein Scheibenende kommen
      *)
      rtlScheibenEndeErkannt( CLK := ( NOT toflSensor.Q
                                       AND blScheibenAnfangErkannt) );

      IF ( rtlScheibenEndeErkannt.Q ) THEN
        blScheibenAnfangErkannt := FALSE;
        ipScheibenAnzahl := ipScheibenAnzahl -1;

        bpScheibeQuittieren := TRUE;

      END_IF

    ELSE
      blScheibenAnfangErkannt := FALSE;

    END_IF // Ende bpStart

  END_IF // Ende bpAktiv

END_IF // Ende bpReset
END_FUNCTION_BLOCK