(* METADATA
{
	"v3Meta": {
		"objectGuid": "0474b6fd-4043-4228-8e53-82e27dbe01a7"
	}
}
*)
METHOD M_GeschwindigkeitGlaetten
VAR_INPUT
END_VAR
VAR
  rlGeschwindigkeitSoll              : REAL; // Ungeglaettete Geschwindigkeit aus der Schnittstelle
  rlMindestGeschwindigkeitsAenderung : REAL;
END_VAR
(***************************************************************************************************)
(* GLAETTUNG: GESCHWINDIGKEIT ZUR SORTIERUNG *)
(***************************************************************************************************)
(* Hinweis:
   - Aufruf in der abgeleiteten Schnittstelle, nachdem rpGeschwindigkeit berechnet wurde
   - Eine neue Geschwindigkeit wird nur uebernommen, wenn sie sich um mindestens
     rMindestGeschwindigkeitsAenderung geaendert hat und seit der letzten Uebernahme
     tMindestZeitZwischenGeschwAenderung vergangen ist
   - Stillstand (0) wird immer sofort ausgegeben, der erste Wert danach ebenfalls
*)
rlGeschwindigkeitSoll              := rpGeschwindigkeit;
rlMindestGeschwindigkeitsAenderung := MAX( BasisStationsParameter.stMKs.stFremdanlage.rMindestGeschwindigkeitsAenderung, 0.0 );

IF ( rlGeschwindigkeitSoll = 0.0 ) THEN
  rlGeschwindigkeitFreigegeben       := 0.0;
  blGeschwindigkeitInitialisiert     := FALSE;
  blGeschwindigkeitUpdateSperreAktiv := FALSE;

ELSIF NOT blGeschwindigkeitInitialisiert THEN
  rlGeschwindigkeitFreigegeben       := rlGeschwindigkeitSoll;
  blGeschwindigkeitInitialisiert     := TRUE;
  blGeschwindigkeitUpdateSperreAktiv := TRUE;

ELSIF NOT blGeschwindigkeitUpdateSperreAktiv
  AND ( ABS( rlGeschwindigkeitSoll - rlGeschwindigkeitFreigegeben ) >= rlMindestGeschwindigkeitsAenderung )
THEN
  rlGeschwindigkeitFreigegeben       := rlGeschwindigkeitSoll;
  blGeschwindigkeitUpdateSperreAktiv := TRUE;
END_IF

// Sperrzeit abgelaufen -> Aenderung ab dem naechsten Zyklus wieder freigeben
IF ( blGeschwindigkeitUpdateSperreAktiv AND tonlGeschwindigkeitUpdateSperre.Q ) THEN
  blGeschwindigkeitUpdateSperreAktiv := FALSE;
END_IF

tonlGeschwindigkeitUpdateSperre( IN := blGeschwindigkeitUpdateSperreAktiv,
                                 PT := BasisStationsParameter.stMKs.stFremdanlage.tMindestZeitZwischenGeschwAenderung );

rpGeschwindigkeit := rlGeschwindigkeitFreigegeben;
END_METHOD
