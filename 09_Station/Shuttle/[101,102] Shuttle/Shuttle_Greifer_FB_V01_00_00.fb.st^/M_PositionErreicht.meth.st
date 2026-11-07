(* METADATA
{
	"v3Meta": {
		"objectGuid": "1edc7426-caec-4d96-a98e-0fd4c2f89ae2"
	}
}
*)
METHOD PRIVATE M_PositionErreicht : BOOL

(* Hinweis:
   - Absolutfahrt abgeschlossen und Zielposition innerhalb der Toleranz erreicht
*)
M_PositionErreicht :=     Antrieb.bpDone
                      AND ( ABS( Antrieb.rpZielPosition - Antrieb.rpIstPosition ) <= cTOLERANZ_POSITION );
END_METHOD