(* METADATA
{
  "v3Meta": {
    "objectGuid": "6b86eeab-fdc2-4247-b783-cb86ac5f0d72"
  }
}
*)
FUNCTION_BLOCK Transfershuttle_FB
VAR_IN_OUT

  // STRUKT
  BasisStationsParameter : StationBasisParameter_ST;

END_VAR
VAR_INPUT

  // BOOLEAN
  bpStarteSpeicherfachValidierung       : BOOL;
  bpTransfershuttleVerbundAktiv         : BOOL := false; // Hinweis: Transferverbund zwischen 2 Transvershuttle-Systmen aktiv
  bpScheibenNeuAusrichten               : BOOL;

  // REAL 
  rpVorpositionierweg                   : REAL; // Auftragsdaten: Der Weg der Vorpositioniert werden soll

  // STRUCT 
  stpInTransportVerbund                 : Interface_TransfershuttleVerbund; // STRUKTUR: Schnittstelle zwischen den Transfershuttlen
  pAuftragsdatenPositionieren           : PositionierAuftrag_ST; // Daten fur die Positionierung [Rampen / Soll- Position / Soll- Geschwindigkeit
                                        
END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpShuttleKannSicherVerfahrenWerden     : BOOL; // Shuttle kann sicherverfahren werden - Shuttle ist unten , Abfragen sind unten
  bpAnforderungBetriebsstopp             : BOOL; // Hinweis: Anforderung zum setzen des Betriebsstopps fuer die Auslaufseite des Transfershuttles
  bpSpeicherfachValidierungAbgeschlossen : BOOL; // BETRIEBSART: Validierung des Speicherfachs wurde abgeschlossen
  bpScheibenNeuAusrichtenAbgeschlossen   : BOOL;

  // WORD
  wpAusnahmefehlerTyp    : WORD := WORD#0; // Sensorfehlertyp: 0 = Allgemeiner Fehler / 1 = Einlauf / 2 = Auslauf / 3 = Ein- Aus- Lauf

  // DWORD 
  dwlHandfunktionen      : DWORD;  // Handfunktionen: 0..31 Bit

  // INT 
  iPhaseSpeichervalidierung : INT;

  // REAL 
  rpVorpositionierterWeg          : REAL; // OUT-STATUS: Status wie weit vorpositioniert wurde
  rpIstPositionNachPositionierung : REAL;

  // ENUM 
  ReservierungsStatus    : TransfershuttleReservierungsTyp_EN;

  // STRUKTUR 
  stpOutTransportVerbund : Interface_TransfershuttleVerbund; // STRUKTUR: Schnittstelle zwischen den Transfershuttlen

END_VAR
VAR

  // BOOLEAN 
  blErsterZyklus                             : BOOL := TRUE; // Initialisierung
  blZielPositionErreicht                     : BOOL;
  blShuttleKannSicherVerfahrenWerden         : BOOL := FALSE;
  blUpdateTimer                              : BOOL; // VERFAHRLOGIK 
  blValidierungLuftabfrageAuslaufUnten       : BOOL := FALSE;
  blValidierungLuftabfrageEinlaufUnten       : BOOL := FALSE;
  blHinweisGenerierenSKAusgeloest            : BOOL := FALSE;

  // WORD 
  wlWatchIONachrichtenNummer                 : WORD;

  // STEPS
  steplEintransport          : Steps_TE;
  steplAustransport          : Steps_TE;
  steplVortransport          : Steps_TE;
  steplReset                 : Steps_TE;
  steplCheck                 : Steps_TE;
  steplReferenz              : Steps_TE;
  steplVorabpositionierung   : Steps_TE;
  steplScheibenNeuAusrichten : Steps_TE;

  // TRIGGER 
  ftlBausteinDeaktivierung   : F_TRIG;

  // TIMER
  tonlMaxWarteAufResetErfolgreich     : TON; 
  tonlUpdateTimer                     : TON; 
  tonlWarteShuttleSicherVerfahren     : TON; // Max. Warte Zeit wenn Shuttle nicht verfahren koennte, damit die WatchIO vorher aufkommen koennen *)


  // BAUSTEINE
  Glastransport                   : Transfershuttle_Glastransport_FB;
  Zentralschmierung               : Zentralschmierung_DLS_4xxi_FB;  
  Querfahrt                       : Querfahrt_Shuttle_FB; 

END_VAR

VAR

  // HARDWARE - EINGAENGE
  in_bSensorShuttleOben                                       : BOOL;
  in_bSensorShuttleUnten                                      : BOOL;
  in_bSensorScheibenKontrolleAuslaufSeiteOben                 : BOOL;
  in_bSensorScheibenKontrolleAuslaufSeiteUnten                : BOOL;
  in_bSensorScheibenKontrolleAuslaufSeiteFrei                 : BOOL; // Öffner
  in_bSensorScheibenKontrolleEinlaufSeiteOben                 : BOOL;
  in_bSensorScheibenKontrolleEinlaufSeiteUnten                : BOOL;
  in_bSensorScheibenKontrolleEinlaufSeiteFrei                 : BOOL; // Öffner
  in_bDruckluftEinlaufSeiteOK                                 : BOOL;
  in_bDruckluftAuslaufSeiteOK                                 : BOOL;
  in_bDruckluftWartungseinheitOK                       AT %I* : BOOL;
  in_bLeitungsschutz_Querfahrt_OK                      AT %I* : BOOL;
  
END_VAR

//-------------------------------------------------------------------------------------------------
// INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus ) THEN
  blErsterZyklus:=FALSE;

  A_Baustein_Initialisierung();

END_IF

BasisStationsParameter.stMKs.bDeaktivieren := BasisStationsParameter.stMKs.bDeaktivieren;

in_bSensorScheibenKontrolleEinlaufSeiteFrei := Glastransport.Antrieb.blSensoren[1];
in_bSensorScheibenKontrolleAuslaufSeiteFrei := Glastransport.Antrieb.blSensoren[2];

//-------------------------------------------------------------------------------------------------
// DEAKTIVIERUNG
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Werte wieder passend abloeschen, wenn der Baustein wieder aktiviert wird
*)
ftlBausteinDeaktivierung( CLK := BasisStationsParameter.stMKs.bDeaktivieren );

IF ( ftlBausteinDeaktivierung.Q ) THEN

  SendShuttlePosition();

  BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := FALSE;
  BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := FALSE;
  BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := FALSE;
  BasisStationsParameter.bVorabpositionierenAbgeschlossen    := FALSE;
  bpSpeicherfachValidierungAbgeschlossen := FALSE;
  bpScheibenNeuAusrichtenAbgeschlossen   := FALSE;

  BasisStationsParameter.bIstReferenziert       := FALSE;
  BasisStationsParameter.bCheckAbgeschlossen    := FALSE;
  BasisStationsParameter.bReferenzAbgeschlossen := FALSE;

END_IF

(* Hinweis:
   - Deaktivierung des Bausteins
     => Der Baustein wird zum Ende der RETURN-Anweisung verlassen
*)
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN
  
  IF ( apgTransfershuttleVerfahrparameter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].eParkposition = PARKPOSITION_MAX ) THEN
    BasisStationsParameter.rAktuellePositionQuerfahrt := apgTransfershuttleVerfahrparameter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].rParkpositionMaximum;
  ELSE
    BasisStationsParameter.rAktuellePositionQuerfahrt := apgTransfershuttleVerfahrparameter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].rParkpositionMinimum;
  END_IF

  BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := TRUE;
  BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := TRUE;
  BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := TRUE;
  BasisStationsParameter.bVorabpositionierenAbgeschlossen    := TRUE;
  BasisStationsParameter.bReset                              := FALSE;
  bpSpeicherfachValidierungAbgeschlossen := TRUE;
  bpScheibenNeuAusrichtenAbgeschlossen   := TRUE;

  BasisStationsParameter.bIstReferenziert       := TRUE;
  BasisStationsParameter.bCheckAbgeschlossen    := TRUE;
  BasisStationsParameter.bReferenzAbgeschlossen := TRUE;

  BasisStationsParameter.bFehler                := FALSE;
  BasisStationsParameter.wFehlerNummer          := 0;

  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - SystemCheck
*)
Systemcheck();

(* Hinweis:
   - Automatik- Aktionen
*)
Eintransport();
Vortransport();
Austransport();
Vorabpositionierung();
//Transportkopplung();
ScheibenNeuAusrichten();

(* Hinweis:
   - Gesonderte- Aktionen
*)
SpeicherfachValidierung();

(* Hinweis:
   - Basis- Aktionen
*)

Reset();
Referenz();
Handfunktionen();
Meldungen();

A_Schnittstelle();
A_Aufrufe();
A_Ausgaenge();
END_FUNCTION_BLOCK