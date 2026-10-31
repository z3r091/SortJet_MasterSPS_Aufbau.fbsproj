(* METADATA
{
  "v3Meta": {
    "objectGuid": "d9517076-9027-4521-9841-230a08ac6f62"
  }
}
*)
ACTION A_Timer
(***************************************************************************************************)
(* TIMER, TRIGGER, ETC. *)
(***************************************************************************************************)
(* Eingangsauswertung
*)
rtlTasterQuittierung(CLK := in_bTasterFehlmessungQuittiern);
rtlFussleisteStart(CLK := NOT in_bTasterGlasAngelegt AND NOT in_bFussTaster);

(* Hinweis:
  -Freigabe mit Timer überlegt, da von SI Relais der unverzögerte Kontakt auf die SPS
   verdrahtet wurde. Der verzögerte Kontakt (Leistung) ist mit 1,2 sec versehen 
*)
tonlFreigabeErhalten(IN:= BasisStationsParameter.bFreigabe ,PT:= t#2s);

ftlGlastransportCheckMitNachfolger( CLK := Glastransport.bpCheckMitNachfolger );
END_ACTION