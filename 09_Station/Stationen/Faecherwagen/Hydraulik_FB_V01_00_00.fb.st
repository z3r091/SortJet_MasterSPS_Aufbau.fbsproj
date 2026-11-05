(* METADATA
{
  "v3Meta": {
    "objectGuid": "c072031a-76c2-44a8-94fd-df0eea8cf4c6"
  }
}
*)
FUNCTION_BLOCK Hydraulik_FB_V01_00_00
VAR_INPUT

  // WORD
  wpHydraulikstationNr             : WORD; // Nummer der Hydraulikstation (Index in apgMKHydraulikstation)

END_VAR
VAR_OUTPUT

  // BOOL
  bpHydraulikLaeuft                : BOOL; // Aggregat laeuft, Umlaufventil geschlossen: hydraulische Bewegungen moeglich

END_VAR
VAR

  // BOOL
  blErsterZyklus                   : BOOL := TRUE;
  blAnforderungHydraulik           : BOOL; // Gesammelte Anforderungen der Faecherwagenstationen (laufender Zyklus)
  blAnforderungUmlaufventilPause   : BOOL; // Gesammelte Pausen-Anforderungen der Faecherwagenstationen (laufender Zyklus)
  blHydraulikStarten               : BOOL;
  blUmlaufventilPause              : BOOL;

  // WORD
  wlAktiveAuftraege                : WORD; // Aktive Auftraege der zugeordneten Stationen (letzter Zyklus)
  wlAktiveAuftraegeZyklus          : WORD; // Aktive Auftraege (laufender Zyklus, ueber M_AuftragFreigabe)
  wlNeueAuftraegeZyklus            : WORD; // Im laufenden Zyklus neu freigegebene Auftraege

  // REFERENZ
  refMK                            : REFERENCE TO Parameter_Hydraulikstation;

  // TIMER
  tonlUmlaufventilEin              : TON; // Umlaufventil erst nach dem Hochlaufen des Motors schalten

  // HARDWARE EINGAENGE
  in_bMotorschuetz_Hydraulikkreislauf_OK  AT %I* : BOOL;

  // HARDWARE AUSGAENGE
  out_bHydraulikkreislauf_MotorEin        AT %Q* : BOOL;
  out_bHydraulikkreislauf_UmlaufventilAuf AT %Q* : BOOL;

END_VAR
VAR CONSTANT

  // WORD
  cUMRECHNUNG_MILLISEKUNDEN_SEKUNDEN : WORD := WORD#1000;

END_VAR

//-------------------------------------------------------------------------------------------------
// INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus ) THEN
  blErsterZyklus := FALSE;

  IF     ( wpHydraulikstationNr >= cERSTE_HYDRAULIKSTATIONS_NR )
     AND ( wpHydraulikstationNr <= cLETZTE_HYDRAULIKSTATIONS_NR )
  THEN
    refMK REF= apgMKHydraulikstation[wpHydraulikstationNr];
  END_IF
END_IF

//-------------------------------------------------------------------------------------------------
// ANFORDERUNGEN UEBERNEHMEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Die Faecherwagenstationen melden ihre Anforderungen vor diesem Aufruf ueber M_Anfordern
     und ihre Auftraege ueber M_AuftragFreigabe
   - Uebernehmen und fuer den naechsten Zyklus loeschen
*)
blHydraulikStarten             := blAnforderungHydraulik;
blUmlaufventilPause            := blAnforderungUmlaufventilPause;
blAnforderungHydraulik         := FALSE;
blAnforderungUmlaufventilPause := FALSE;
wlAktiveAuftraege              := wlAktiveAuftraegeZyklus;
wlAktiveAuftraegeZyklus        := 0;
wlNeueAuftraegeZyklus          := 0;

//-------------------------------------------------------------------------------------------------
// DEAKTIVIEREN
//-------------------------------------------------------------------------------------------------
IF NOT __ISVALIDREF(refMK) THEN
  out_bHydraulikkreislauf_MotorEin        := FALSE;
  out_bHydraulikkreislauf_UmlaufventilAuf := FALSE;
  bpHydraulikLaeuft                       := FALSE;
  RETURN;
END_IF

IF ( refMK.bDeaktivieren ) THEN
  tonlUmlaufventilEin( IN := FALSE );
  out_bHydraulikkreislauf_MotorEin        := FALSE;
  out_bHydraulikkreislauf_UmlaufventilAuf := FALSE;
  bpHydraulikLaeuft                       := FALSE;
  RETURN;
END_IF

//-------------------------------------------------------------------------------------------------
// PROZESS
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Motor laeuft, solange eine Station eine hydraulische Bewegung anfordert
   - Umlaufventil nach wgTimeHydraulikUmlaufEin schalten; eine Station kann es zwischen zwei
     direkt folgenden Bewegungen kurz zuruecknehmen (Pause)
*)
out_bHydraulikkreislauf_MotorEin := blHydraulikStarten;

tonlUmlaufventilEin( IN := out_bHydraulikkreislauf_MotorEin AND NOT blUmlaufventilPause,
                     PT := WORD_TO_TIME( wgTimeHydraulikUmlaufEin * cUMRECHNUNG_MILLISEKUNDEN_SEKUNDEN ) );

out_bHydraulikkreislauf_UmlaufventilAuf := tonlUmlaufventilEin.Q;

//-------------------------------------------------------------------------------------------------
// AUSGAENGE
//-------------------------------------------------------------------------------------------------
bpHydraulikLaeuft :=     out_bHydraulikkreislauf_MotorEin
                     AND out_bHydraulikkreislauf_UmlaufventilAuf
                     AND in_bMotorschuetz_Hydraulikkreislauf_OK;

//-------------------------------------------------------------------------------------------------
// MELDUNGEN
//-------------------------------------------------------------------------------------------------
WatchIo( NOT in_bMotorschuetz_Hydraulikkreislauf_OK, refMK.wMeldungsNummer );
END_FUNCTION_BLOCK