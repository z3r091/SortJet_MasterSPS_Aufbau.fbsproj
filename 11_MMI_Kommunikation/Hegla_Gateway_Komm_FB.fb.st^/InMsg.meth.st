(* METADATA
{
  "v3Meta": {
    "objectGuid": "cda33201-c5a6-4fe7-8396-38f1974bd209"
  }
}
*)
METHOD InMsg : BOOL
VAR_INPUT
  psmSpsMessage : SpsMessage;
END_VAR
VAR
  i : INT;
  j : INT;
END_VAR

i := smqSpsMessageQueue.iInzeig;
j := (i+1) MOD 25;   // 25 mögliche Queueeinträge möglich

// noch Platz frei ?
IF( j = smqSpsMessageQueue.iOutzeig )THEN
  // Queue ist voll, älteste Nachricht wird verworfen
  smqSpsMessageQueue.iOutzeig := (j+1) MOD 25;
END_IF;

// in jedem Fall eintragen
smqSpsMessageQueue.asmSpsMessage[i] := psmSpsMessage;
smqSpsMessageQueue.iInzeig  := j;

InMsg := TRUE;
END_METHOD