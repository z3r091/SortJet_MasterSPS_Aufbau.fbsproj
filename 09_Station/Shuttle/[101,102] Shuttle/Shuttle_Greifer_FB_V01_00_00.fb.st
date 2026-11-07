(* METADATA
{
	"v3Meta": {
		"objectGuid": "bb2ac76d-e136-43b9-91b5-1f4b010b201a"
	}
}
*)
FUNCTION_BLOCK Shuttle_Greifer_FB_V01_00_00
VAR_INPUT

  // BOOLEAN
  bpAktivieren                            : BOOL := FALSE; // WICHTIG: Aktivieren des Bausteins (stStationsAufbau.bGreifer)
  bpFreigabe                              : BOOL; // STATUS: Der Greifer ist freigegeben und kann Prozesse abarbeiten
  bpAutomatikAktiv                        : BOOL;
  bpTeilnehmerErreichbar                  : BOOL;
  bpReset                                 : BOOL;
  bpFahreReferenz                         : BOOL; // BETRIEBSMODUS: Greiferachse referenzieren
  bpCheck                                 : BOOL; // BETRIEBSMODUS: Systemcheck
  bpStartGrundstellungsfahrt              : BOOL; // BETRIEBSMODUS: Grundstellungsfahrt
  bpPositionieren                         : BOOL; // BETRIEBSMODUS: Greifer hinter die Glaskante positionieren (Laenge aus rpGlaslaenge)
  bpStarteVorabPositionierungEintransport : BOOL; // BETRIEBSMODUS: Greifer vor einem Eintransport an die Wandseite stellen
  bpStarteEintransport                    : BOOL; // BETRIEBSMODUS: Scheibe aus dem Faecherwagen auf das Shuttle ziehen
  bpStarteAustransport                    : BOOL; // BETRIEBSMODUS: Scheibe vom Shuttle in den Faecherwagen schieben
  bpSlaveKopplungAktiv                    : BOOL; // STATUS: Glastransport ist auf die Greiferachse gekoppelt
  bpKorrekturfahrtBeendet                 : BOOL; // STATUS: Korrekturfahrt des Glastransports bei uebergrosser Scheibe abgeschlossen
  bpSensorEinlauf                         : BOOL; // STATUS: Einlaufsensor
  bpSensorAuslauf                         : BOOL; // STATUS: Auslaufsensor

  // HANDBETRIEB
  bpHandfahrenPlus                        : BOOL; // Greiferachse in positive Richtung
  bpHandfahrenMinus                       : BOOL; // Greiferachse in negative Richtung
  bpHandGreiferAusfahren                  : BOOL;
  bpHandGreiferEinfahren                  : BOOL;
  bpHandZangeSchliessen                   : BOOL;
  bpHandZangeOeffnen16mm                  : BOOL;
  bpHandZangeOeffnen23mm                  : BOOL;
  bpHandZangeOeffnen29mm                  : BOOL;
  bpHandGlasRueckhalterAusfahren          : BOOL;

  // ENUM
  epGreiferTyp                            : Greifertyp_EN; // AUFTRAGSDATEN: Greiferseite, eGreiferDefault = Seite aus der MK

  // REAL
  rpGlaslaenge                            : REAL; // Scheibenlaenge fuer das Positionieren hinter die Glaskante

  // STRUCT
  pAuftrag                                : Auftragsdaten_ST; // AUFTRAG: Aktuelle Daten zum Auftrag [Laenge, Hoehe, Dicke, Zangenstellung]
  stStationsNummern                       : Station_ST;

  // POINTER
  ppParameterGreifer                      : REFERENCE TO Parameter_Greifer;
  ppAntriebsInformationen                 : REFERENCE TO AntriebsInformationen;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpDone                                         : BOOL; // Reset bzw. Referenz abgeschlossen
  bpFehler                                       : BOOL;
  bprtScheibe                                    : BOOL; // Scheibe quittieren
  bpIstInReferenz                                : BOOL;
  bpSicherePosition                              : BOOL; // WICHTIG: Greifer ragt nicht ueber das Shuttle -> Querfahrt erlaubt
  bpGlasRueckhalterEingefahren                   : BOOL; // WICHTIG: Glasrueckhalter eingefahren -> Querfahrt erlaubt
  bpAnforderungSlaveKopplung                     : BOOL; // Anforderung: Glastransport auf die Greiferachse koppeln
  bpKorrekturfahrtAnfordern                      : BOOL; // Anforderung: Glastransport zieht den Rest einer uebergrossen Scheibe auf das Shuttle
  bpKorrekturfahrtRueckwaerts                    : BOOL; // Richtung der Korrekturfahrt: Sensor der Greiferseite frei fahren
  bpAuftragAktiv                                 : BOOL;
  bpVorpositioniertEintransport                  : BOOL; // Greifer steht ausgefahren an der Wandseite fuer den Eintransport
  bpPositionierungAbgeschlossen                  : BOOL;
  bpVorabPositionierungEintransportAbgeschlossen : BOOL;
  bpEintransportAbgeschlossen                    : BOOL;
  bpAustransportAbgeschlossen                    : BOOL;
  bpGrundstellungsfahrtAbgeschlossen             : BOOL;
  bpSystemCheckAbgeschlossen                     : BOOL;

  // WORD
  wpFehlerNr                                     : WORD;
  awpFehlerInformationen                         : ARRAY[0..25] OF WORD;

  // REAL
  rpWegGlasUebergabeposition                     : REAL; // Weg der Scheibe ueber den Sensor der Greiferseite vor dem Austransport
  rpIstPosition                                  : REAL;

  // ENUM
  epGreiferTypAktiv                              : Greifertyp_EN; // Greiferseite, mit der gearbeitet wird

END_VAR
VAR

  // BOOLEAN
  blErsterZyklus              : BOOL := TRUE;
  blReduzierteGeschwindigkeit : BOOL;
  blUebergrosseScheibe        : BOOL; // Scheibe zu lang, um sie komplett mit dem Greifer zu ziehen
  blSensorSeite               : BOOL; // Sensor der Greiferseite
  blSensorGegenseite          : BOOL; // Sensor der gegenueberliegenden Seite
  blHandAktiv                 : BOOL;
  blZangeSeiteVorhanden       : BOOL; // Greiferzange der aktiven Greiferseite laut MK vorhanden
  blCheckScheibeZiehen        : BOOL; // Systemcheck: Scheibe im Greifer wird auf das Shuttle gezogen (sonst in den Faecherwagen geschoben)
  blCheckNichtQuittieren      : BOOL; // Systemcheck: Greiferzange war offen, die Scheibe wird nicht quittiert
  ablRueckhalterAusfahren     : ARRAY[cZANGE_EINLAUF..cZANGE_AUSLAUF] OF BOOL;

  // INT
  ilZange                     : INT; // Greiferzange der aktiven Seite

  // REAL
  rlRichtung                  : REAL; // +1 Einlaufseite, -1 Auslaufseite: Richtung "auf das Shuttle"
  rlWegBisZumSensor           : REAL;
  rlUebernahmePosition        : REAL;
  rlUebergabePosition         : REAL;
  rlGrundstellungsPosition    : REAL;
  rlGrundstellungGegenseite   : REAL;
  rlGrundstellungEintransport : REAL;
  rlEintransportOffset        : REAL;
  rlPositionUebergrosseScheibe: REAL;
  rlKorrekturOffset           : REAL;
  rlPositionAntriebBeiStart   : REAL;
  rlZielPosition              : REAL;
  rlGlasgewicht               : REAL;

  // ENUM
  elZangeOeffnung             : PneumatikZylinderStatus_EN;

  // STEPS
  steplEintransport                      : Steps_TE;
  steplEintransportMerker                : Steps_TE;
  steplAustransport                      : Steps_TE;
  steplAustransportMerker                : Steps_TE;
  steplPositionieren                     : Steps_TE;
  steplPositionierenMerker               : Steps_TE;
  steplVorabPositionierungEintransport   : Steps_TE;
  steplVorabPositionierungMerker         : Steps_TE;
  steplGrundstellungsfahrt               : Steps_TE;
  steplGrundstellungsfahrtMerker         : Steps_TE;
  steplCheck                             : Steps_TE;
  steplCheckMerker                       : Steps_TE;
  steplReset                             : Steps_TE;
  steplReferenz                          : Steps_TE;
  steplReferenzMerker                    : Steps_TE;

  // TIMER
  tonlAntriebFreigegeben                 : TON; // Endstufe nach "Regler bereit" sicher durchgeschaltet
  tonlMaxWarteAufResetErfolgreich        : TON;
  toflReglerFreigabeErhalten             : TOF; // Reglerfreigabe fuer eine bestimmte Zeit erhalten
  toflSensorSeite                        : TOF; // Entprellen Sensor der Greiferseite
  tonlEndschalterFreifahren              : TON;
  tofHardwareEndschalterFrei             : TOF;
  tonlWarteSchrittEndschalterFreifahren  : TON;
  tonlUeberwachungEintransport           : TON; // Zeitueberwachung der Wartestellen je Schrittkette
  tonlUeberwachungAustransport           : TON;
  tonlUeberwachungPositionieren          : TON;
  tonlUeberwachungVorab                  : TON;
  tonlUeberwachungGrundstellung          : TON;
  tonlUeberwachungCheck                  : TON;
  tonlUeberwachungReferenz               : TON;

  // BAUSTEINE
  Antrieb      : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02;
  GreiferHub   : ZylinderPneumatik_FB_V01_00_00; // Greifer aus- / einfahren (ausgefahren = auf Glashoehe)
  Zange        : ARRAY[cZANGE_EINLAUF..cZANGE_AUSLAUF] OF Greiferzange_FB_V01_00_00;

END_VAR
VAR

  // HARDWARE EINGAENGE
  in_bGreiferAusgefahren                 AT %I* : BOOL; // STATUS: Zylinderabfrage Greifer ausgefahren
  in_bGreiferEingefahren                 AT %I* : BOOL; // STATUS: Zylinderabfrage Greifer eingefahren
  in_bGlasRueckhalterEinlaufEingefahren  AT %I* : BOOL; // STATUS: Glasrueckhalter Einlaufseite eingefahren
  in_bGlasRueckhalterAuslaufEingefahren  AT %I* : BOOL; // STATUS: Glasrueckhalter Auslaufseite eingefahren

  // HARDWARE AUSGAENGE
  out_bGreiferAusfahren                  AT %Q* : BOOL; // Impuls Zylinder Greifer ausfahren
  out_bGreiferEinfahren                  AT %Q* : BOOL; // Impuls Zylinder Greifer einfahren
  out_bGlasRueckhalterEinlaufAusfahren   AT %Q* : BOOL; // Federrueckstellventil Glasrueckhalter Einlaufseite: TRUE = ausgefahren
  out_bGlasRueckhalterAuslaufAusfahren   AT %Q* : BOOL; // Federrueckstellventil Glasrueckhalter Auslaufseite: TRUE = ausgefahren

END_VAR
VAR CONSTANT

  // INT
  cZANGE_EINLAUF      : INT := 1;
  cZANGE_AUSLAUF      : INT := 2;

  // REAL
  cTOLERANZ_POSITION  : REAL := 2.5; // [mm] Zielposition erreicht

  // TIME
  cZEIT_SENSOR_ENTPRELLEN : TIME := T#50MS;

END_VAR
(* Anmerkung:
   - Greifer im Shuttle: eigene Greiferachse, Greifer aus-/einfahren, Greiferzange und Glasrueckhalter je Seite
     optional (Parameter_Greifer.bZange...Vorhanden / bGlasRueckhalter...Vorhanden)
   - Ablaeufe ueber eine Greiferseite ohne Greiferzange werden mit Meldung abgelehnt
   - Eintransport: Scheibe im Faecherwagen greifen und auf das Shuttle ziehen, der Glastransport ist dabei
     auf die Greiferachse gekoppelt (Slave)
   - Austransport: Scheibe greifen und in den Faecherwagen schieben
*)
//-------------------------------------------------------------------------------------------------
// BAUSTEIN: DEAKTIVIERUNG
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Ein deaktivierter Greifer meldet kein Done und keine Status-Freigaben; der Aufrufer verknuepft
     mit der Aktivierung aus der MK (z.B. Greifer.bpSicherePosition OR NOT stStationsAufbau.bGreifer[wWand])
*)
IF ( NOT bpAktivieren ) THEN

  out_bGreiferAusfahren                := FALSE;
  out_bGreiferEinfahren                := FALSE;
  out_bGlasRueckhalterEinlaufAusfahren := FALSE;
  out_bGlasRueckhalterAuslaufAusfahren := FALSE;

  ablRueckhalterAusfahren[cZANGE_EINLAUF] := FALSE;
  ablRueckhalterAusfahren[cZANGE_AUSLAUF] := FALSE;

  GreiferHub();
  Zange[cZANGE_EINLAUF]();
  Zange[cZANGE_AUSLAUF]();

  bpDone                                         := FALSE;
  bpFehler                                       := FALSE;
  wpFehlerNr                                     := cMELDUNG_NULL;
  bprtScheibe                                    := FALSE;
  bpIstInReferenz                                := FALSE;
  bpSicherePosition                              := FALSE;
  bpGlasRueckhalterEingefahren                   := FALSE;
  bpAnforderungSlaveKopplung                     := FALSE;
  bpKorrekturfahrtAnfordern                      := FALSE;
  bpAuftragAktiv                                 := FALSE;
  bpVorpositioniertEintransport                  := FALSE;
  bpPositionierungAbgeschlossen                  := FALSE;
  bpVorabPositionierungEintransportAbgeschlossen := FALSE;
  bpEintransportAbgeschlossen                    := FALSE;
  bpAustransportAbgeschlossen                    := FALSE;
  bpGrundstellungsfahrtAbgeschlossen             := FALSE;
  bpSystemCheckAbgeschlossen                     := FALSE;

  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus ) THEN

  IF ( __ISVALIDREF(ppAntriebsInformationen) AND __ISVALIDREF(ppParameterGreifer) ) THEN

    blErsterZyklus := FALSE;

    Antrieb REF= pgAntriebe[ppAntriebsInformationen.wAchsID];

    (* Hinweis:
       - Initialisierung Antriebsinformationen
    *)
    Antrieb.ppAntriebsInformationen REF= ppAntriebsInformationen;
    Antrieb.rpZielPosition    := Antrieb.rpIstPosition;
    Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
    Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
    Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
    Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;

    (* Hinweis:
       - Pneumatik: Greifer mit Endlagenabfragen, Greiferzangen laut MK
       - Eine nicht vorhandene Greiferzange ist deaktiviert (keine Ausgaenge, kein Done, kein Fehler)
    *)
    GreiferHub.bpAktivieren                  := TRUE;
    GreiferHub.bpAbfrageAusgefahrenVorhanden := TRUE;
    GreiferHub.bpAbfrageEingefahrenVorhanden := TRUE;

    Zange[cZANGE_EINLAUF].bpAktivieren := ppParameterGreifer.bZangeEinlaufVorhanden;
    Zange[cZANGE_AUSLAUF].bpAktivieren := ppParameterGreifer.bZangeAuslaufVorhanden;

  ELSE
    RETURN;
  END_IF

END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: GREIFERSEITE
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Seite aus dem Auftrag, sonst aus der MK
   - rlRichtung: Richtung der Greiferachse "auf das Shuttle" (Einlaufseite positiv, Auslaufseite negativ)
*)
IF ( epGreiferTyp <> eGreiferDefault ) THEN
  epGreiferTypAktiv := epGreiferTyp;
ELSE
  epGreiferTypAktiv := ppParameterGreifer.eGreiferTyp;
END_IF

IF ( epGreiferTypAktiv = eGreiferAuslaufseite ) THEN
  ilZange                      := cZANGE_AUSLAUF;
  rlRichtung                   := -1.0;
  rlWegBisZumSensor            := ppParameterGreifer.rWegBisZumAuslaufsensor;
  rlUebernahmePosition         := ppParameterGreifer.rUebernahmePosition_Auslauf;
  rlUebergabePosition          := ppParameterGreifer.rUebergabePosition_Auslauf;
  rlGrundstellungsPosition     := ppParameterGreifer.rGrundstellungsPosition_Auslauf;
  rlGrundstellungGegenseite    := ppParameterGreifer.rGrundstellungsPosition_Einlauf;
  rlGrundstellungEintransport  := ppParameterGreifer.rGrundstellungsPosition_AuslaufEintransport;
  rlPositionUebergrosseScheibe := ppParameterGreifer.rPositionUebergrosseScheibe_Auslauf;
  rlKorrekturOffset            := ppParameterGreifer.rKorrekturOffset_Auslauf;
  blSensorSeite                := bpSensorAuslauf;
  blSensorGegenseite           := bpSensorEinlauf;
  IF ( pAuftrag.bLetzteScheibe ) THEN
    rlEintransportOffset := ppParameterGreifer.rGlasEintransportOffset_Auslauf;
  ELSE
    rlEintransportOffset := ppParameterGreifer.rGlasEintransportOffset_AuslaufSammeln;
  END_IF
ELSE
  ilZange                      := cZANGE_EINLAUF;
  rlRichtung                   := 1.0;
  rlWegBisZumSensor            := ppParameterGreifer.rWegBisZumEinlaufsensor;
  rlUebernahmePosition         := ppParameterGreifer.rUebernahmePosition_Einlauf;
  rlUebergabePosition          := ppParameterGreifer.rUebergabePosition_Einlauf;
  rlGrundstellungsPosition     := ppParameterGreifer.rGrundstellungsPosition_Einlauf;
  rlGrundstellungGegenseite    := ppParameterGreifer.rGrundstellungsPosition_Auslauf;
  rlGrundstellungEintransport  := ppParameterGreifer.rGrundstellungsPosition_EinlaufEintransport;
  rlPositionUebergrosseScheibe := ppParameterGreifer.rPositionUebergrosseScheibe_Einlauf;
  rlKorrekturOffset            := ppParameterGreifer.rKorrekturOffset_Einlauf;
  blSensorSeite                := bpSensorEinlauf;
  blSensorGegenseite           := bpSensorAuslauf;
  IF ( pAuftrag.bLetzteScheibe ) THEN
    rlEintransportOffset := ppParameterGreifer.rGlasEintransportOffset_Einlauf;
  ELSE
    rlEintransportOffset := ppParameterGreifer.rGlasEintransportOffset_EinlaufSammeln;
  END_IF
END_IF

bpKorrekturfahrtRueckwaerts := ( epGreiferTypAktiv = eGreiferAuslaufseite );

(* Hinweis:
   - Ohne Greiferzange auf der aktiven Seite lehnen Ein-/Austransport, Positionieren, Vorabpositionierung
     und Systemcheck mit cMELDUNG_AUFTRAGSDATEN_SHUTTLE_GREIFER_AUFTRAGSTYP_UNGUELTIG ab
*)
blZangeSeiteVorhanden :=    ( ( ilZange = cZANGE_EINLAUF ) AND ppParameterGreifer.bZangeEinlaufVorhanden )
                         OR ( ( ilZange = cZANGE_AUSLAUF ) AND ppParameterGreifer.bZangeAuslaufVorhanden );

(* Hinweis:
   - Uebergrosse Scheibe: der Greifer zieht nur bis rPositionUebergrosseScheibe, den Rest zieht der Glastransport
   - Oeffnung der Greiferzange aus dem Auftrag, ohne Vorgabe maximal geoeffnet
*)
blUebergrosseScheibe := ( pAuftrag.rAuftragsLaenge >= ppParameterGreifer.rLaengeUebergroesseScheibe )
                        AND ( ppParameterGreifer.rLaengeUebergroesseScheibe > 0.0 );

IF ( blUebergrosseScheibe ) THEN
  rpWegGlasUebergabeposition := ppParameterGreifer.rWegGlasUebergabepositionLang;
ELSE
  rpWegGlasUebergabeposition := ppParameterGreifer.rWegGlasUebergabeposition;
END_IF

IF (    ( pAuftrag.stAuftragsOptionen.eGreiferZangeStellung = eZylinderStellung16mm )
     OR ( pAuftrag.stAuftragsOptionen.eGreiferZangeStellung = eZylinderStellung23mm )
     OR ( pAuftrag.stAuftragsOptionen.eGreiferZangeStellung = eZylinderStellung29mm ) )
THEN
  elZangeOeffnung := pAuftrag.stAuftragsOptionen.eGreiferZangeStellung;
ELSE
  elZangeOeffnung := eZylinderStellung29mm;
END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: TIMER, EINSTELLUNGEN, ETC.
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Die Endstufe des Umrichters ist bei "bpReglerBereit" noch nicht sicher durchgeschaltet
*)
tonlAntriebFreigegeben( IN := Antrieb.bpReglerBereit, PT := T#200MS );

tonlMaxWarteAufResetErfolgreich( IN := bpReset, PT := tgMaxWartezeitReset - T#1S );

toflSensorSeite( IN := blSensorSeite, PT := cZEIT_SENSOR_ENTPRELLEN );

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AKTIONEN
//-------------------------------------------------------------------------------------------------
SystemCheck();

Positionieren();
VorabPositionierungEintransport();
Eintransport();
Austransport();
Grundstellung();

Reset();
Referenz();
Handfunktionen();
Meldungen();

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: SICHERHEIT UND STATUS
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Greifer ragt nicht ueber die Aussenkanten des Shuttles
   - Glasrueckhalter eingefahren (ein nicht vorhandener Glasrueckhalter gilt als eingefahren)
*)
bpSicherePosition := (     Antrieb.bpIstReferenziert
                       AND ( Antrieb.rpIstPosition >= ppParameterGreifer.rSicherPositionMinimal )
                       AND ( Antrieb.rpIstPosition <= ppParameterGreifer.rSicherPositionMaximal ) );

bpGlasRueckhalterEingefahren :=     ( in_bGlasRueckhalterEinlaufEingefahren OR NOT ppParameterGreifer.bGlasRueckhalterEinlaufVorhanden )
                                AND ( in_bGlasRueckhalterAuslaufEingefahren OR NOT ppParameterGreifer.bGlasRueckhalterAuslaufVorhanden );

bpIstInReferenz := Antrieb.bpIstReferenziert;
rpIstPosition   := Antrieb.rpIstPosition;

bpAuftragAktiv :=    ( bpStarteEintransport AND ( steplEintransport > STEP_0_E ) )
                  OR ( bpStarteAustransport AND ( steplAustransport > STEP_0_E ) )
                  OR ( bpPositionieren AND ( steplPositionieren > STEP_0_E ) )
                  OR ( bpStarteVorabPositionierungEintransport AND ( steplVorabPositionierungEintransport > STEP_0_E ) )
                  OR ( bpStartGrundstellungsfahrt AND ( steplGrundstellungsfahrt > STEP_0_E ) );

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: FREIGABEN UND AUFRUFE
//-------------------------------------------------------------------------------------------------
toflReglerFreigabeErhalten( IN := (    bpHandfahrenPlus
                                    OR bpHandfahrenMinus
                                    OR bpFahreReferenz
                                    OR bpCheck
                                    OR bpStarteEintransport
                                    OR bpStarteAustransport
                                    OR bpPositionieren
                                    OR bpStarteVorabPositionierungEintransport
                                    OR bpStartGrundstellungsfahrt ),
                            PT := ppParameterGreifer.tZeitAntriebsfreigabeErhalten );

// Aufruf Antrieb (der Antrieb selbst wird zentral im Programm Antriebe aufgerufen)
Antrieb.bpFreigabe        := bpFreigabe AND toflReglerFreigabeErhalten.Q;
Antrieb.stStationsNummern := stStationsNummern;
Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;

// Aufruf Pneumatik
GreiferHub( in_bStatusZylinderAusgefahren := in_bGreiferAusgefahren,
            in_bStatusZylinderEingefahren := in_bGreiferEingefahren );

Zange[cZANGE_EINLAUF]( bpZylinderAbfragenVorhanden := ppParameterGreifer.bZangeAbfragenVorhanden );
Zange[cZANGE_AUSLAUF]( bpZylinderAbfragenVorhanden := ppParameterGreifer.bZangeAbfragenVorhanden );

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AUSGAENGE
//-------------------------------------------------------------------------------------------------
out_bGreiferAusfahren := GreiferHub.out_bZylinderAusfahren;
out_bGreiferEinfahren := GreiferHub.out_bZylinderEinfahren;

out_bGlasRueckhalterEinlaufAusfahren := ablRueckhalterAusfahren[cZANGE_EINLAUF] AND ppParameterGreifer.bGlasRueckhalterEinlaufVorhanden;
out_bGlasRueckhalterAuslaufAusfahren := ablRueckhalterAusfahren[cZANGE_AUSLAUF] AND ppParameterGreifer.bGlasRueckhalterAuslaufVorhanden;
END_FUNCTION_BLOCK