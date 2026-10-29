(* METADATA
{
	"v3Meta": {
		"objectGuid": "a019a64a-c8d9-4c29-b804-142b5a61873a"
	}
}
*)
FUNCTION WegZeitBestimmen : TIME
VAR_INPUT

  (* REAL *)
  rpWegStrecke      : REAL := REAL#0; (* EINHEIT: mm     *)
  rpGeschwindigkeit : REAL := REAL#0; (* EINHEIT: mm/s   *)
  rpRampe           : REAL := REAL#0; (* EINHEIT: mm/s^2 | Beschleunigung \ Verzoegerung *)
 
END_VAR
VAR

  (* INT *)
  ilBerechnungsModus   : INT := 1;  

  (* REAL *)
  rlErrechneteZeit : REAL;

  (* TIME *)
  tlZeitWert       : TIME;

END_VAR
VAR CONSTANT

  (* WORD *)
  cUMRECHNUNG_MILLISEKUNDEN_SEKUNDEN : WORD := WORD#1000;

  (* REAL *)
  cVALIDIERUNGSWERT          : REAL := REAL#0;
  cDEFAULT_WEGSTRECKE        : REAL := 1.0;
  cDEFAULT_RAMPE             : REAL := 1000.0;
  cDEFAULT_GESCHWINDIGKEIT   : REAL := 1.0;

END_VAR

(*
########################################## Changelog ################################################

  2019-11-26 KV - Erstellt
     => Funktion neu Eingebunden
        Ermitteln eines Zeitwertes fuer eine definierte Strecke
      

########################################## Changelog ################################################ 
*)
(* Hinweis:
   - Division durch Null verhindern 
*)
IF ( ABS(rpWegStrecke) <= cVALIDIERUNGSWERT ) THEN
  rpWegStrecke := cDEFAULT_WEGSTRECKE;
END_IF

IF ( ABS(rpGeschwindigkeit) <= cVALIDIERUNGSWERT ) THEN
  rpGeschwindigkeit := cDEFAULT_GESCHWINDIGKEIT;
END_IF

IF ( ABS(rpRampe) <= cVALIDIERUNGSWERT ) THEN
  rpRampe := cDEFAULT_RAMPE;
END_IF


(* Hinweis:
   - Starten der Berwchnung
*)
CASE ilBerechnungsModus OF 

  1:
    (* Hinweis:
       - Geradlinige Bewegung v = konst.
          => S = v * t  | t = S/v
    *)
    rlErrechneteZeit :=  rpWegStrecke / rpGeschwindigkeit;

  2:
    (* Hinweis:
       - Beschleunigte Bewegung
          => S = 0,5 * a * t^2
    *)
    rlErrechneteZeit := SQRT( ((2* rpWegStrecke) / rpRampe ) );

  ELSE
    rlErrechneteZeit := REAL#0;

END_CASE


(* Hinweis:
   - Ausgabe des berechneten Wertes
*)
IF ( rlErrechneteZeit > 0 ) THEN
  tlZeitWert := REAL_TO_TIME(rlErrechneteZeit * cUMRECHNUNG_MILLISEKUNDEN_SEKUNDEN);
ELSE
  tlZeitWert := T#0s;
END_IF

WegZeitBestimmen := tlZeitWert;
END_FUNCTION