(* METADATA
{
	"v3Meta": {
		"objectGuid": "b16aec39-c9ae-4650-bc77-489ad5cf5efd"
	}
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* AKTION: MELDUNGEN, AUSNAHMESITUATIONEN *)
(***************************************************************************************************)
IF (      bpFreigabe
  AND NOT toflMotorschutz.Q
  AND NOT blMeldungAbgesetzt
  AND bpTeilnehmerErreichbar )
THEN

  blMeldungAbgesetzt := TRUE;

  awlErrorAdditional[0] := stStationsNummern.NummerExtern;
  wpFehlerNr := cMELDUNG_ANTRIEB_GEBLAESE;

  SpsError( eFehler_Station,
            wpFehlerNr, stStationsNummern.NummerIntern,
            AutomatikkreisBestimmen(stStationsNummern.NummerIntern),
            awlErrorAdditional );

  bpFehler := TRUE;
END_IF
END_ACTION