(* METADATA
{
  "v3Meta": {
    "objectGuid": "565d8e9e-6f44-455e-86f5-d16ff6a06f95"
  }
}
*)
FUNCTION_BLOCK Auftragswarteschlange_Fremdanlage_FB
VAR_INPUT

  bpAktivieren     : BOOL := TRUE;
  bpWertAuslesen   : BOOL; (* READ  *)
  bpWerteSchreiben : BOOL; (* WRITE *)
  bpReset          : BOOL; (* RST *)

  (* WORD *)
  ppEingabeWert : Schnittstelle_Auftragsdaten_ST;

END_VAR
VAR_OUTPUT
  (* BOOLEAN *)
  bpWarteschlangeLeer  : BOOL := TRUE;
  bpWarteschlangeVoll  : BOOL;

  (* STRUCT *)
  ppAusgabeWert  : Schnittstelle_Auftragsdaten_ST;

END_VAR
VAR

  (* STRUCT *)
  awlWarteSchlange : ARRAY[0..cINDEX] OF Schnittstelle_Auftragsdaten_ST;

  (* INT *)
  ilAktuellePosition  : INT; (* pr *)
  ilLetztePosition    : INT; (* pw *)

END_VAR

VAR CONSTANT
  cINDEX : INT := 5;    (* WICHTIG: Aenderungen an diesem Wert aendert die Anzahl der Elemente in der Warteschlange [FIFO] *)
END_VAR
IF ( bpReset ) THEN
  ilLetztePosition := ilAktuellePosition := 0 ;
  bpWarteschlangeVoll := FALSE;
  bpWarteschlangeLeer := TRUE;

  bpReset := FALSE;

ELSIF ( bpAktivieren ) THEN

  IF (  NOT bpWarteschlangeLeer
    AND bpWertAuslesen )
  THEN
    ppAusgabeWert := awlWarteSchlange[ilAktuellePosition];
    ilAktuellePosition  := INCI(ilAktuellePosition,cINDEX);
    bpWarteschlangeLeer := ilAktuellePosition = ilLetztePosition;
    bpWarteschlangeVoll := FALSE;
    bpWertAuslesen      := FALSE;
  END_IF;

  IF (  NOT bpWarteschlangeVoll
    AND bpWerteSchreiben )
  THEN
    awlWarteSchlange[ilLetztePosition] := ppEingabeWert;
    ilLetztePosition    := INCI(ilLetztePosition,cINDEX);
    bpWarteschlangeVoll := ilLetztePosition = ilAktuellePosition;
    bpWarteschlangeLeer := FALSE;
    bpWerteSchreiben    := FALSE;
  END_IF;

END_IF;
END_FUNCTION_BLOCK