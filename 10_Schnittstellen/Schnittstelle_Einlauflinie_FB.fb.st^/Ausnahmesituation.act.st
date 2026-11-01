(* METADATA
{
  "v3Meta": {
    "objectGuid": "0bde9ffc-2d27-4715-909e-df579dd535e6"
  }
}
*)
ACTION Ausnahmesituation
//-------------------------------------------------------------------------------------------------
// AKTION: AUSNAHMESITUATIONEN
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Fehlermeldung ausgeben
     => Kommunikations- Probleme
*)
rtlFehlermeldungGenerierenKommunikation( CLK := blFehlermeldungGenerierenKommunikation );

IF ( rtlFehlermeldungGenerierenKommunikation.Q ) THEN

  wpgFehlerdaten[0] := stStationsNummern.NummerExtern;
  SpsError( eFehler_Schnittstelle, 
            cMELDUNG_SCHNITTSTELLE_KOMUNIKATION_TIMEOUT, 
            stStationsNummern.NummerSPS, 
            1,  
            wpgFehlerdaten );

END_IF
END_ACTION