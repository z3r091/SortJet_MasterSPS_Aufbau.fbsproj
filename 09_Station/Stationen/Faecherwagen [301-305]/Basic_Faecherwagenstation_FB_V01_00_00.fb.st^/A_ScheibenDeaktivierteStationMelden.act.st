(* METADATA
{
	"v3Meta": {
		"objectGuid": "9787c6c4-89ac-4e67-aebe-436ca2600e9a"
	}
}
*)
ACTION A_ScheibenDeaktivierteStationMelden
// @TEXT_IMPLEMENTATION := 'ST'
//-------------------------------------------------------------------------------------------------
// DEAKTIVIERTE STATION: SCHEIBEN AN MMI MELDEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Ersetzt die gleichnamige Aktion von Basic_Station_FB (auch beim Aufruf aus deren Rumpf)
   - Faecherwagenstationen melden dem MMI keine Scheiben auf der Station
*)
;
END_ACTION