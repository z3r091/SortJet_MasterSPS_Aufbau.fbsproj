(* METADATA
{
	"v3Meta": {
		"objectGuid": "6f7ed93d-1901-4e95-8818-3caa484a7623"
	}
}
*)
FUNCTION_BLOCK Horn_FB
VAR_INPUT

  // BOOLEAN
  bpAktiv          : BOOL;
  bpReset          : BOOL;
  bpHornAktivieren : BOOL;  // Horn / Hupe vom Shuttle aus aktiviert

  // WORD
  wpStatusArt   : WORD; // Art des Hupsignales: 1=Dauerton 1; 2= Blinker 1/ 3= Blinker 2

  // TIME
  tpHornZeit   : TIME; // Zeit wie lange das Horn arbeitet

END_VAR
VAR_OUTPUT
END_VAR

VAR

  // BOOL
  blHornAktiv : BOOL;

  // TRIEGGER
  ftlHornAus  : F_TRIG;

  // TIMER
  tonlHornAus : TON;

END_VAR

VAR

  // HARDWAREAUSGAENGE
  out_bHorn       AT %Q* : BOOL; // akustische Anzeige, dass Checkroutine läuft

END_VAR


//-------------------------------------------------------------------------------------------------
// BAUSTEIN: ABLAUF HORNSIGNAL
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Baustein zuruecksetzen
*)
IF ( bpReset  ) THEN

  bpReset    := FALSE;
  blHornAktiv := FALSE;

  out_bHorn  := FALSE;

ELSE

  (* Hinweis:
     - Aktivieren des Bausteins (Ablauf)
  *)
  IF ( bpAktiv ) THEN

    (* Hinweis:
       - Timer \ Trigger
    *)
    tonlHornAus(IN := blHornAktiv, PT:=tpHornZeit);

    ftlHornAus(CLK := blHornAktiv);

    IF ( bpHornAktivieren AND NOT blHornAktiv ) THEN
      blHornAktiv       := TRUE;
      bpHornAktivieren := FALSE;
    END_IF

    IF ( tonlHornAus.Q ) THEN
      blHornAktiv := FALSE;
    END_IF

    IF ( ftlHornAus.Q ) THEN
      out_bHorn := FALSE;
    END_IF


    (* Hinweis:
       - Hornsignal
    *)
    IF ( blHornAktiv ) THEN

      CASE wpStatusArt OF

        0,1:
          out_bHorn := TRUE;

        2:
          out_bHorn:= gbFlashbit1sec;

        3:
          out_bHorn:= gbFlashbit05sec;

        4:
          out_bHorn:= gbFlashbit02sec;

        5:
          out_bHorn:= gbFlashbit03sec;

        6:
          out_bHorn := gbFlashbit03sec AND gbFlashbit12sec;

        7:
          out_bHorn := gbFlashbit03sec AND gbFlashbit12sec;

      END_CASE

    ELSE
      out_bHorn  := FALSE;

    END_IF

  ELSE
    bpHornAktivieren := FALSE;
    out_bHorn := FALSE;

  END_IF

END_IF
END_FUNCTION_BLOCK