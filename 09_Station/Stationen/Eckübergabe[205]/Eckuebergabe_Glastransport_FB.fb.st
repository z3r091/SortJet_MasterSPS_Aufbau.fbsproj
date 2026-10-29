(* METADATA
{
	"v3Meta": {
		"objectGuid": "81c1a0e8-072a-43b4-9d9a-102ae1b3c537"
	}
}
*)
FUNCTION_BLOCK Eckuebergabe_Glastransport_FB EXTENDS Basic_Glastransport_FB

// Hinweis:
// - Je Achse der Eckuebergabe eine Instanz (Glastransport_X, Glastransport_Y)
// - Ein Antrieb je Achse, kein Slave-Antrieb

// Master aufrufen
SUPER^();
END_FUNCTION_BLOCK