(* METADATA
{
  "v3Meta": {
    "objectGuid": "6659315d-9c24-4f87-b231-8f013a58b29e"
  }
}
*)
ACTION A_Hubrahmen
//==================================================================================================
// AKTION HUBRAHMEN
//==================================================================================================
// Hinweis:
// - Die Schrittketten fordern mit blHubrahmenPositionieren eine Achse an (elHubrahmenZielAchse)
// - Riemenachse angefordert => Hubrahmen ausfahren (oben), sonst einfahren (unten)
// - Im Handbetrieb steuern die Handfunktionen den Hubrahmen direkt
IF ( blHubrahmenPositionieren ) THEN
  Hubrahmen.bpStartAusfahren := ( elHubrahmenZielAchse = elRiemenAchse );
  Hubrahmen.bpStartEinfahren := ( elHubrahmenZielAchse <> elRiemenAchse );

ELSIF ( NOT blBetriebsartHand ) THEN
  Hubrahmen.bpStartAusfahren := FALSE;
  Hubrahmen.bpStartEinfahren := FALSE;

END_IF

// Ohne Hubrahmen (MK) meldet der Zylinder kein Done, die Ketten duerfen dann nicht warten
blHubrahmenInPosition := (    (     Hubrahmen.bpDone
                                AND ( (     ( elHubrahmenZielAchse = elRiemenAchse )
                                        AND ( Hubrahmen.epStatusZylinder = eZylinderAusgefahren ) )
                                      OR (     ( elHubrahmenZielAchse <> elRiemenAchse )
                                           AND ( Hubrahmen.epStatusZylinder = eZylinderEingefahren ) ) ) )
                           OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen );
END_ACTION