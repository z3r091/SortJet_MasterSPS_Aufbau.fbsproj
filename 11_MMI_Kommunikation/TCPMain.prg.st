(* METADATA
{
  "v3Meta": {
    "objectGuid": "bf44ddad-4c4e-44de-9f11-5004840b8d3d"
  }
}
*)
PROGRAM TCPMain
VAR_INPUT
 bpIOAnzeigeAktivieren : BOOL;
  l_fb_SortjetHMI : Hegla_Gateway_Komm_FB;
END_VAR
VAR
  bInit : BOOL := TRUE;
END_VAR

(*MAIN PRG*)
IF bInit
THEN
  RegisterCallbacks();
  bInit := FALSE;
END_IF

l_fb_SortjetHMI();
END_PROGRAM