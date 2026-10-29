(* METADATA
{
	"v3Meta": {
		"objectGuid": "0fab3b3e-6742-4984-990c-b65a2821afa3"
	}
}
*)
ACTION MsgEnd

PutMsg( smpSpsMessage := smlSpsMessage_POLL, bpTrig := TRUE );
SendMsg();
IF( Memcomp( ADR( SpsToMmiMem ), ADR( SpsToMmi ), SIZEOF( SpsToMmi ) ) <> 0 )THEN
  Memcopy( ADR( SpsToMmiMem ), ADR( SpsToMmi ), SIZEOF( SpsToMmi ) );
END_IF
IF TCPMain.bpIOAnzeigeAktivieren THEN
 UpdateIoAnzeige();
END_IF
END_ACTION