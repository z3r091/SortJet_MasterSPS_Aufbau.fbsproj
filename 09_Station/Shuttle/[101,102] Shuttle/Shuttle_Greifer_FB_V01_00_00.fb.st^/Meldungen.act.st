(* METADATA
{
	"v3Meta": {
		"objectGuid": "5dd66886-8ad5-4e2d-a6b4-b534c8c4b956"
	}
}
*)
ACTION Meldungen
//-------------------------------------------------------------------------------------------------
// AKTION: MELDUNGEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Antriebsfehler ausserhalb der Schrittketten melden
   - WatchIO-Meldungen des Greifers werden im Shuttle erzeugt (Meldungsnummer der Station)
*)
IF (     NOT bpFehler
     AND Antrieb.bpFehler )
THEN
  Antrieb.wpBetriebsart := KEINE_FUNKTION;
  wpFehlerNr := cMELDUNG_ANTRIEB_GREIFER_STOESSEL;
  bpFehler   := TRUE;
END_IF

IF (     NOT bpFehler
     AND ( GreiferHub.bpFehler OR Zange[cZANGE_EINLAUF].bpFehler OR Zange[cZANGE_AUSLAUF].bpFehler ) )
THEN
  IF ( GreiferHub.bpFehler ) THEN
    wpFehlerNr := GreiferHub.wpFehlerNr;
  ELSIF ( Zange[cZANGE_EINLAUF].bpFehler ) THEN
    wpFehlerNr := Zange[cZANGE_EINLAUF].wpFehlerNr;
  ELSE
    wpFehlerNr := Zange[cZANGE_AUSLAUF].wpFehlerNr;
  END_IF
  bpFehler := TRUE;
END_IF
END_ACTION