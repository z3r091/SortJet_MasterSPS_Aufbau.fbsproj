(* METADATA
{
  "v3Meta": {
    "objectGuid": "09251e11-594b-475c-82f1-a1c97d91d23a"
  }
}
*)
ACTION Reset
(***************************************************************************************************)
(* AKTION: RESET *)
(***************************************************************************************************)

IF ( bpStarteReset ) THEN

  bpAnforderungSK := FALSE;
  bpStarteReset   := FALSE;

END_IF
END_ACTION