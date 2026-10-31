(* METADATA
{
  "v3Meta": {
    "objectGuid": "23ce62b1-5b0b-40f5-8f51-012d540e19cc"
  }
}
*)
FUNCTION_BLOCK Auftragsspeicher_FB
VAR_INPUT

	bpAktivieren     : BOOL := TRUE;
	bpWertAuslesen   : BOOL; (* READ  *)
	bpWerteSchreiben : BOOL; (* WRITE *)
	bpReset          : BOOL; (* RST *)

  (* STRUCT *)
	stEingabeWert : Auftragsdaten_ST;

END_VAR
VAR_OUTPUT

  (* BOOLEAN *)
	blWarteschlangeLeer : BOOL := TRUE;
	blWarteschlangeVoll : BOOL;

  (* STRUCT *)
	stAusgabeWert  : Auftragsdaten_ST;

END_VAR
VAR

  (* STRUCT *)
	warrlWarteSchlange : ARRAY[0..cINDEX] OF Auftragsdaten_ST;

  (* INT *)
	ilReadPosition   : INT; (* pr *)
	ilWritePosition  : INT; (* pw *)
	iIndex           : INT;
END_VAR

VAR CONSTANT
	cINDEX : INT := 10;	(* WICHTIG: Aenderungen an diesem Wert aendert die Anzahl der Elemente in der Warteschlange [FIFO] *)
END_VAR
(***************************************************************************************************)
(* BAUSTEIN: AUFTRAGSVERWALTUNG TRANSFERSHUTTLE *)
(***************************************************************************************************)
IF ( bpReset ) THEN

   ilReadPosition      := 0;
   ilWritePosition     := 0;
   blWarteschlangeVoll := FALSE;
   blWarteschlangeLeer := TRUE;

   bpReset := FALSE;

ELSIF ( bpAktivieren ) THEN


   IF (  NOT blWarteschlangeLeer
     AND bpWertAuslesen )
   THEN
      stAusgabeWert := warrlWarteSchlange[ilReadPosition];
      ilReadPosition:= INCI(ilReadPosition, cINDEX );
      blWarteschlangeLeer := ( ilReadPosition = ilWritePosition );
      blWarteschlangeVoll := FALSE;
      bpWertAuslesen      := FALSE;
   END_IF;

   IF (  NOT blWarteschlangeVoll
     AND bpWerteSchreiben )
   THEN
       warrlWarteSchlange[ilWritePosition] := stEingabeWert;
       ilWritePosition := INCI( ilWritePosition, cINDEX );
       blWarteschlangeVoll := ( ilWritePosition = ilReadPosition );
       blWarteschlangeLeer := FALSE;
       bpWerteSchreiben    := FALSE;
   END_IF;

END_IF;
END_FUNCTION_BLOCK