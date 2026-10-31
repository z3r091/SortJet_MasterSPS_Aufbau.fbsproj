(* METADATA
{
  "v3Meta": {
    "objectGuid": "74a6612c-c54e-4353-b111-97703b6d8bd7"
  }
}
*)
ACTION SpeicherfachValidierung
(***************************************************************************************************)
(* SPEICHERFACH VALIDIEREN *)
(***************************************************************************************************)
(* Hinweis:
   - Validierung eines Speicherfachs nach einer Ausnahmesituation
     => Eine Ausnahmesituation entsteht dann wenn Glas aus dem Speicher herraus stehen koennte       
*)
IF ( bpStarteSpeicherfachValidierung ) THEN

  CASE iPhaseSpeichervalidierung OF

    (* --------------------------------------------------------- *)
    SPEICHERFACHVALIDIERUNG_IDLE:
      bpSpeicherfachValidierungAbgeschlossen := FALSE;

      iPhaseSpeichervalidierung := SPEICHERFACHVALIDIERUNG_INIT;


    (* --------------------------------------------------------- *)
    SPEICHERFACHVALIDIERUNG_INIT:
      bpSpeicherfachValidierungAbgeschlossen := FALSE;

      IF ( NOT Glastransport.bpFehler ) THEN
       Glastransport.pSystemCheckDaten := BasisStationsParameter.pAuftrag[cWAND_1];
        Glastransport.bpSpeicherfachValidierung := TRUE;

        iPhaseSpeichervalidierung := SPEICHERFACHVALIDIERUNG_AKTIV;
      ELSE
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        iPhaseSpeichervalidierung := SPEICHERFACHVALIDIERUNG_FEHLER;
      END_IF


    (* --------------------------------------------------------- *)
    SPEICHERFACHVALIDIERUNG_AKTIV:
      (* Hinweis:
         - Validierung des Speicherfachs erfolgreich abgeschlossen
      *)
      IF ( Glastransport.bpSpeicherfachValidierungAbgeschlossen ) THEN
        Glastransport.bpSpeicherfachValidierung := FALSE;
        iPhaseSpeichervalidierung := SPEICHERFACHVALIDIERUNG_ABGESCHLOSSEN;
      END_IF

      (* Fehlerbehandlung
         - Glastransport
      *)
      IF ( Glastransport.bpFehler ) THEN
        Glastransport.bpSpeicherfachValidierung := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        iPhaseSpeichervalidierung := SPEICHERFACHVALIDIERUNG_FEHLER;
      END_IF


    (* --------------------------------------------------------- *)
    SPEICHERFACHVALIDIERUNG_FEHLER:
      BasisStationsParameter.bFehler := TRUE;


    (* --------------------------------------------------------- *)
    SPEICHERFACHVALIDIERUNG_ABGESCHLOSSEN:
      bpSpeicherfachValidierungAbgeschlossen := TRUE;

  END_CASE

END_IF

IF ( NOT bpStarteSpeicherfachValidierung ) THEN

   IF ( iPhaseSpeichervalidierung <> SPEICHERFACHVALIDIERUNG_IDLE ) THEN
     bpSpeicherfachValidierungAbgeschlossen := FALSE;
     iPhaseSpeichervalidierung := SPEICHERFACHVALIDIERUNG_IDLE;
     Glastransport.bpSpeicherfachValidierung := FALSE;
   END_IF

END_IF
END_ACTION