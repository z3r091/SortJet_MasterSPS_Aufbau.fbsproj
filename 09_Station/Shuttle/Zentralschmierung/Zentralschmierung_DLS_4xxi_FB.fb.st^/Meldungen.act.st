(* METADATA
{
  "v3Meta": {
    "objectGuid": "5ed03f19-4f8a-45e9-a25a-7de1a07b9187"
  }
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* NACHRICHTEN, MELDUNGEN  *)
(***************************************************************************************************)

(* Hinweis:
   - Erkennung des 0,5Herz Signals bei bald leerer Fettkartusche
*)
Taktberechnung( Signal := in_bStatus );
blSchmierhubOkBaldLeer := ( Taktberechnung.Herz > 0.45 AND Taktberechnung.Herz < 0.55 );

(* Hinweis:
   - Erkennung des 1 Herz Signals bei leerer Fettkartusche
*) 
//Taktberechnung( Signal := in_bStatus );//MW müsste auch mit vorherigem Taktberechnung noch klappen
blKeineOderLeereKartusche := ( Taktberechnung.Herz > 0.95 AND Taktberechnung.Herz < 1.05 );


(* Erkennung der Funktionskontrolle und unterscheideung zur Takterkennung des blKeineOderLeereKartusche Signals*)
tonlFunktionskontrolle (IN:= in_bStatus, PT:=T#1100MS);

rtlFunktionskontrolle (CLK:=tonlFunktionskontrolle.Q);
IF rtlFunktionskontrolle.Q THEN
  blSchmierhubOk:= TRUE;
END_IF

(* Hinweis :
   - Fehlerbit setzen damit WatchIO im Stationsbaustein angezeigt wird
*)
blGeraeteFehler := tonlSchmierungNichtBetriebsbereit.Q OR bpInternerFehler;

IF rtlMeldungFehlerPumpe.Q THEN
  wpgFehlerdaten[0] := stStationsNummern.NummerExtern;
  SpsError( eFehler_Station, 
            cMELDUNG_ZENTRALSCHMIERUNG_GERAETEFEHLER, 
            stStationsNummern.NummerIntern, 
            AutomatikkreisBestimmen(0), 
            wpgFehlerdaten );

  bpFehler := TRUE;
END_IF

IF blKeineOderLeereKartusche THEN
  wpgFehlerdaten[0] := stStationsNummern.NummerExtern;
  SpsError( eFehler_Station, 
            cMELDUNG_ZENTRALSCHMIERUNG_FETT_LEER, 
            stStationsNummern.NummerIntern, 
            AutomatikkreisBestimmen(0), 
            wpgFehlerdaten );

  bpFehler   := TRUE;
  blFettLeer := TRUE;
END_IF
END_ACTION