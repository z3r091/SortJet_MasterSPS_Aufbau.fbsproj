(* METADATA
{
  "v3Meta": {
    "objectGuid": "62b3e7d5-59d7-4fa9-a26b-9f6c0e862cd9"
  }
}
*)
FUNCTION_BLOCK Querfahrt_FB_V01_00_00
VAR_INPUT

  // BOOLEAN
  bpAktivieren                           : BOOL;
  bpFreigabe                             : BOOL;
  bpAutomatikAktiv                       : BOOL;
  bpPositionieren                        : BOOL;
  bpReset                                : BOOL;
  bpReferenz                             : BOOL;
  bpHandfahrenPlus                       : BOOL;
  bpHandfahrenMinus                      : BOOL;

  bpSensorEinlauf                        : BOOL;
  bpSensorAuslauf                        : BOOL;
  bpSensorAuslaufVorgaenger              : BOOL;
  bpVerfahrfreigabe                      : BOOL := TRUE; // Externe Freigabe zum Verfahren (ohne Beschaltung TRUE)
  bpQuittungAuftragsstatusZurueckgesetzt : BOOL; // Auftrag wurde zurueckgesetzt
  bpReglungAktivSchalten                 : BOOL; // Da der Querfahrtantrieb keine Bremse hat, muss um die Position zu halten der Regler in Regelung stehen, sonst verschiebt sich die Station *)

  // REAL
  rpZielPosition                         : REAL;

  // POINTER
  ppParameterBaustein                    : REFERENCE TO Parameter_Querfahrt;
  ppAntriebsInformationen                : REFERENCE TO AntriebsInformationen;

  // STRUKTUR
  stStationsNummern                      : Station_ST;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpDone                                 : BOOL;
  bpFehler                               : BOOL;
  bpAntrieblaeuft                        : BOOL;
  bpAuftragAktiv                         : BOOL;
  bpAuftragsstatusZuruecksetzen          : BOOL := FALSE;
  bpPositionierungGestartet              : BOOL := FALSE;
  bpPositionierungAbgeschlossen          : BOOL := FALSE;
  bpMinEndschalterBelegt                 : BOOL := FALSE;
  bpMaxEndschalterBelegt                 : BOOL := FALSE;
  bpZielPositionErreicht                 : BOOL;
  bpInReferenz                           : BOOL;

  // WORD
  wpFehlerNr                             : Fehlerkonstanten_EN;

  // REAL
  rpAktuellePosition                     : REAL;

END_VAR
VAR

  // BOOL
  blErsterZyklus                         : BOOL := TRUE;
  blVerfahrfreigabe                      : BOOL;
  blAbbruchPositionierung                : BOOL := FALSE;

  // STEPS
  steplPositionieren                     : Steps_TE;
  steplReferenz                          : Steps_TE;
  steplReset                             : Steps_TE;

  // TIMER
  tonlEndschalterFreifahren              : TON;
  tonlMaxWarteAufResetErfolgreich        : TON;
  toflHardwareEndschalterFrei            : TOF;
  toflReglerFreigabeErhalten             : TOF;

  // Antrieb
  Antrieb : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02;

END_VAR

//-------------------------------------------------------------------------------------------------
// INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus ) THEN

  IF ( __ISVALIDREF(ppAntriebsInformationen) ) THEN

    blErsterZyklus := FALSE;

    Antrieb REF= pgAntriebe[ppAntriebsInformationen.wAchsID];

    (* Hinweis:
       - Initialisierung Antriebsinformationen
    *)
    Antrieb.ppAntriebsInformationen REF= ppAntriebsInformationen;

    (* Hinweis:
       - Für die Zielpunktkontrolle muss im ersten Zyklus die Zielposition initialisiert werden
    *)
    Antrieb.rpZielPosition := Antrieb.rpIstPosition;

    (* Hinweis:
       - Antriebswerte vorinitialisieren
    *)
    Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
    Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
    Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
    Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;

  ELSE
    RETURN;
  END_IF

END_IF

//-------------------------------------------------------------------------------------------------
// DEAKTIVIEREN
//-------------------------------------------------------------------------------------------------
IF ( NOT bpAktivieren ) THEN

  bpDone                        := TRUE;
  bpAuftragsstatusZuruecksetzen := FALSE;

  bpFehler   := FALSE;
  wpFehlerNr := 0;

  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
// Verfahrfreigabe (lokal, der Eingang wird nicht ueberschrieben)
blVerfahrfreigabe :=     bpVerfahrfreigabe
                         AND NOT bpSensorEinlauf
                         AND NOT bpSensorAuslauf
                         AND NOT bpSensorAuslaufVorgaenger;

Verfahrlogik();
Positionieren();
Handfunktionen();
Reset();
Referenz();
Meldungen();

//-------------------------------------------------------------------------------------------------
// Freigabe zum Verfahren
//-------------------------------------------------------------------------------------------------
IF NOT blVerfahrfreigabe AND Antrieb.wpBetriebsart <> AntriebsBetriebsart_EN.RESET AND Antrieb.wpBetriebsart <> KEINE_FUNKTION THEN
  Antrieb.wpBetriebsart := KEINE_FUNKTION;
END_IF

//-------------------------------------------------------------------------------------------------
// Freigaben
//-------------------------------------------------------------------------------------------------
// Antriebsfreigabe
toflReglerFreigabeErhalten( IN := (   bpPositionieren
                                    OR bpReferenz
                                    OR bpHandfahrenPlus
                                    OR bpHandfahrenMinus
                                    OR bpReglungAktivSchalten // Da der Querfahrtantrieb keine Bremse hat, muss um die Position zu halten der Regler in Regelung stehen, sonst verschiebt sich die Station
                                    OR bpReset ),
                            PT := ppParameterBaustein.tZeitAntriebsfreigabeErhalten );

Antrieb.bpFreigabe        := ( bpFreigabe  AND toflReglerFreigabeErhalten.Q );
Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;
Antrieb.stStationsNummern := stStationsNummern;

// Ausgänge
bpAuftragAktiv             := bpPositionieren;
rpAktuellePosition         := Antrieb.rpIstPosition;
bpAntrieblaeuft            := Antrieb.bpAntrieblaeuft;
bpInReferenz               := Antrieb.bpIstReferenziert;
bpMinEndschalterBelegt     := Antrieb.bpMinSchalterBelegt;
bpMaxEndschalterBelegt     := Antrieb.bpMaxSchalterBelegt;
bpPositionierungGestartet  := steplPositionieren > STEP_0_E;
bpPositionierungAbgeschlossen := bpDone AND NOT bpPositionieren;

// Positionsabfrage:
//    - Wurde die Zielposition aus dem Auftrag erreicht, bzw. stimmt die aktuelle Shuttleposition mit der
//      Position aus dem Auftrag ueberein.
bpZielPositionErreicht := ( ( ABS( Antrieb.rpIstPosition - argZuletztQuittiertePositionShuttle[stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz )
                            OR
                            ( ABS( rpZielposition - argZuletztQuittiertePositionShuttle[stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz )
                            OR  ( ABS( rpZielposition - Antrieb.rpIstPosition ) <= rgMKZielPositionToleranz ) );
END_FUNCTION_BLOCK