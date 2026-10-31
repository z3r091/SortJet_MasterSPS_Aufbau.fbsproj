(* METADATA
{
  "v3Meta": {
    "objectGuid": "d364c674-6de1-44be-9866-add197db1182"
  }
}
*)
PROGRAM RegisterCallbacks
(*
  Import function to register a callback which closes open socket handles.
  Return: None
*)
VAR_OUTPUT
  Callback : DWORD;
END_VAR
VAR
  sCallbackStart         : CB.CB_CALLBACK;
  sCallbackStop          : CB.CB_CALLBACK;
  sCallbackBeforeReset    : CB.CB_CALLBACK;
  sCallbackAfterReset     : CB.CB_CALLBACK;
  sCallbackBeforeDownload : CB.CB_CALLBACK;
  
  peCallbackStartError       : CB.ERROR;
  peCallbackStopError        : CB.ERROR;
  peCallbackBeforeResetError    : CB.ERROR;
  peCallbackAfterResetError     : CB.ERROR;
  peCallbackBeforeDownloadError : CB.ERROR;
END_VAR

IF NOT TCP_Global.g_bCallbackRegistered THEN
  
  (* Fill Callback-Structures and register Callbacks *)
  (* START *)
  sCallbackStart.pPOUFunc := ADR(Callback_Shutdown);
  sCallbackStart.eEvent   := CB.EVENT.START;
  sCallbackStart.eSource  := CB.EVENT_SOURCE.ALL_SOURCES;
  sCallbackStart.eClass   := CB.EVENT_CLASS.ONLINE_EVENTS;
  IF CB.RegisterCallback(sCallbackStart, ADR(peCallbackStartError)) = 0 THEN
   Callback.0 := TRUE;  
  END_IF
  
  
  (* STOP *)
  sCallbackStop.pPOUFunc := ADR(Callback_Shutdown);
  sCallbackStop.eEvent   := CB.EVENT.STOP;
  sCallbackStop.eSource  := CB.EVENT_SOURCE.ALL_SOURCES;
  sCallbackStop.eClass   := CB.EVENT_CLASS.ONLINE_EVENTS;
  IF CB.RegisterCallback(sCallbackStop, ADR(peCallbackStopError)) = 0 THEN
   Callback.1 := TRUE;  
  END_IF
  
  (* BEFORE RESET *)
  sCallbackBeforeReset.pPOUFunc := ADR(Callback_BEFORE_RESET);
  sCallbackBeforeReset.eEvent   := CB.EVENT.BEFORE_RESET;
  sCallbackBeforeReset.eSource  := CB.EVENT_SOURCE.ALL_SOURCES;
  sCallbackBeforeReset.eClass   := CB.EVENT_CLASS.ONLINE_EVENTS;
  IF CB.RegisterCallback(sCallbackBeforeReset, ADR(peCallbackBeforeResetError)) = 0 THEN
   Callback.2 := TRUE;  
  END_IF
  
  (* AFTER RESET *)
  sCallbackAfterReset.pPOUFunc := ADR(Callback_Shutdown);
  sCallbackAfterReset.eEvent   := CB.EVENT.AFTER_RESET;
  sCallbackAfterReset.eSource  := CB.EVENT_SOURCE.ALL_SOURCES;
  sCallbackAfterReset.eClass   := CB.EVENT_CLASS.ONLINE_EVENTS;
  IF CB.RegisterCallback(sCallbackAfterReset, ADR(peCallbackAfterResetError)) = 0 THEN
   Callback.3 := TRUE;  
  END_IF
  
  (* BEFORE DOWNLOAD *)
  sCallbackBeforeDownload.pPOUFunc := ADR(CallBack_BEFORE_DOWNLOAD);
  sCallbackBeforeDownload.eEvent   := CB.EVENT.BEFORE_DOWNLOAD;
  sCallbackBeforeDownload.eSource  := CB.EVENT_SOURCE.ALL_SOURCES;
  sCallbackBeforeDownload.eClass   := CB.EVENT_CLASS.ONLINE_EVENTS;
  IF CB.RegisterCallback(sCallbackBeforeDownload, ADR(peCallbackBeforeDownloadError)) = 0 THEN
   Callback.5 := TRUE;  
  END_IF

  TCP_Global.g_bCallbackRegistered := TRUE;
END_IF
END_PROGRAM