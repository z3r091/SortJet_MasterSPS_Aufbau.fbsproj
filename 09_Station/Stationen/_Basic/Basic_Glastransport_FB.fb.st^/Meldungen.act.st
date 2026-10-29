(* METADATA
{
	"v3Meta": {
		"objectGuid": "90c12f93-b400-411b-bdf2-d780a50021ce"
	}
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* AKTION MELDUNGEN *)
(***************************************************************************************************)
IF( Antrieb.bpFehler
   AND NOT (  steplAustransport        = STEP_900_E
      OR steplAustransportRueckwaertig = STEP_900_E
      OR steplEintransport             = STEP_900_E
      OR steplEintransportRueckwaertig = STEP_900_E
      OR steplVortransport             = STEP_900_E
      OR steplVortransportRueckwaertig = STEP_900_E
      OR steplDurchtransport           = STEP_900_E
      OR steplGlaslaengenMessung       = STEP_900_E
      OR steplCheck                    = STEP_900_E
      OR steplReset                    = STEP_900_E
      OR steplReferenz                 = STEP_900_E )
  )
THEN
  wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
  bpFehler := TRUE;
END_IF
END_ACTION