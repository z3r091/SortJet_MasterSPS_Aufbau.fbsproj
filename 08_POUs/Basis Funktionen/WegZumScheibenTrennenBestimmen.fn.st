(* METADATA
{
  "v3Meta": {
    "objectGuid": "975fc77d-048f-43ed-b0dc-a9d95a26ef34"
  }
}
*)
FUNCTION WegZumScheibenTrennenBestimmen : REAL
VAR_INPUT

  // REAL
  rpAuftragsLaenge       : REAL := REAL#0; // [mm]
  rpRampe                : REAL := 1000.0; // [mm/s^2] Verzoegerungsrampe  => Werte muessen umgerechnet werden in [m/s^2]
  rpGeschwindigkeit      : REAL := 1000;   // [m/s]   Sollgeschwindigkeit => Werte muessen umgerechnet werden in [m/s]
  rpTrennGeschwindigkeit : REAL := 500;    // [m/s]   Geschwindigkeit mit der die Beladung aufgetrennt werden soll => Werte muessen umgerechnet werden in [m/s]

END_VAR
VAR

  // REAL
  rlBerechneteTrennStrecke         : REAL := REAL#0;
  rlBerechneteVerzoegerungsStrecke : REAL := REAL#0;
  rlValidierungWert                : REAL := REAL#0;
  rlRueckgabeWert                  : REAL := REAL#0;

END_VAR
VAR CONSTANT

  // REAL
  cVALIDIERUNG_NULL             : REAL := REAL#0;
  cVALIDIERUNGSWERT             : REAL := 100.0;
  cDEFAULT_RAMPE                : REAL := 1000.0;
  cDEFAULT_GESCHWINDIGKEIT      : REAL := 1000.0;
  cDEFAULT_TRENNGESCHWINDIGKEIT : REAL := 500.0;

  // WORD
  cMILLIMETER_ZU_METER_FAKTOR   : WORD := 1000;

END_VAR
// Info:
//   - Es wird mittels uebergebener Daten ein Weg berechnet ab wann der Antrieb verzoegern muss, um
//     eine Stationsbeladung sauber aufzutrennen.

//-------------------------------------------------------------------------------------------------
// FUNKTION: ERMITTELN EINER STRECKE ZUM TRENNEN EINER STATIONSBELADUNG
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Auftragslaenge muss angegeben werden
*)
IF ( rpAuftragsLaenge <= 0 ) THEN
  WegZumScheibenTrennenBestimmen := REAL#0;
  RETURN;
END_IF

(* Hinweis:
   - Sicherstellen das keine 0 Rampen bzw. keine 0 Geschwindigkeit angegeben wurde
     => Fuellen mit default Werten (Division durch null Verhindern)
*)
IF ( ABS(rpRampe) <= cVALIDIERUNG_NULL ) THEN
  rpRampe := cDEFAULT_RAMPE;
END_IF

IF ( ABS(rpGeschwindigkeit) <= cVALIDIERUNG_NULL ) THEN
  rpGeschwindigkeit := cDEFAULT_GESCHWINDIGKEIT;
END_IF

IF ( ABS(rpTrennGeschwindigkeit) <= cVALIDIERUNG_NULL ) THEN
  rpTrennGeschwindigkeit := cDEFAULT_TRENNGESCHWINDIGKEIT;
END_IF

(* Hinweis:
   - Werte in die passende pysikalische Einheit umwandeln
     => Rampe von mm/s^2 zu m/s^2
     => Geschwindigkeit von mm/s zu m/s
     => Laenge von mm zu m
*)
rpRampe                 := ABS( rpRampe / cMILLIMETER_ZU_METER_FAKTOR );
rpGeschwindigkeit       := ABS( rpGeschwindigkeit / cMILLIMETER_ZU_METER_FAKTOR );
rpTrennGeschwindigkeit  := ABS( rpTrennGeschwindigkeit / cMILLIMETER_ZU_METER_FAKTOR );
rpAuftragsLaenge        := ABS( rpAuftragsLaenge / cMILLIMETER_ZU_METER_FAKTOR );


(* Hinweis:
   - Strecke berechnen die benoetigt wird, um von der Soll- Geschwindigkeit auf die reduzierte
     Trenn- Geschwindigkeit zu kommen
      => s =  v^2 - v0^2 / 2*a
*)
rlBerechneteTrennStrecke := LREAL_TO_REAL(ABS((EXPT(rpGeschwindigkeit,2) - EXPT(rpTrennGeschwindigkeit,2)) / ( 2 * rpRampe )));

(* Hinweis:
   - Strecke berechnen die gebraucht wird, wenn aus maximaler (Soll-) Geschwindigkeit abgebremst wird
     => S = v^2 / (2*a)
*)
rlBerechneteVerzoegerungsStrecke := LREAL_TO_REAL((EXPT(rpGeschwindigkeit,2) ) / ( 2 * rpRampe ));

(* Hinweis:
   - Strecken summieren
*)
rlValidierungWert :=  ( ( rpAuftragsLaenge - ( rlBerechneteVerzoegerungsStrecke + rlBerechneteTrennStrecke) ) * cMILLIMETER_ZU_METER_FAKTOR );

IF ( rlValidierungWert <= cVALIDIERUNGSWERT ) THEN
  rlRueckgabeWert := REAL#0;

ELSE
  rlRueckgabeWert := rlValidierungWert;

END_IF

WegZumScheibenTrennenBestimmen := rlRueckgabeWert;
END_FUNCTION