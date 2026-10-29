(* METADATA
{
	"v3Meta": {
		"objectGuid": "491601d3-570f-478a-91fa-0fcb47bab279"
	}
}
*)
Function_Block CoeWriteObject
VAR_INPUT
  i_b_Reset : BOOL;
  i_b_Execute   : BOOL; // Execute Read Object!
  i_by_EcID   : UINT;   // ID im Ec
  i_w_ObjectNum : WORD; // Codestelle im Regler
  i_by_SubIndex : BYTE; // Sub Codestelle
  i_w_DataTyp   : WORD; // Datentyp der Codestelle
  i_p_Var       : __XWORD; //Pointer auf die Variable
  i_w_BufSize   : WORD; // Buffer Size
END_VAR
VAR
  l_ec_WriteToDevice : EC_CoeWriteObject;
  steplSchritt       : STEPS_TE := STEP_1001_E; 
  l_ui_TimeOutCount  : UINT;  
  l_a_udi_AbortMsg   : ARRAY[0..4] OF UDINT;
END_VAR
VAR_OUTPUT
  o_b_Busy       : BOOL;
  o_b_Aborted    : BOOL;
  o_di_AbortCode : DINT;

  o_by_AbortCode_ErrorTask : BYTE;
  o_ui_AbortCode_ErrorNr : UINT;
END_VAR
VAR CONSTANT 
 DH_FEHLER_COP_READ_OBJ            : UDINT := 8002;
END_VAR
// Reset everything
IF i_b_Reset THEN
  i_b_Reset := FALSE;
  i_b_Execute := FALSE;
  l_ec_WriteToDevice(xExecute := FALSE);
  steplSchritt := STEP_1001_E;
END_IF

// Start 
IF  i_b_Execute
AND steplSchritt = STEP_1001_E
THEN
  i_b_Execute := FALSE;
  steplSchritt := STEP_0_E;
END_IF

o_b_Busy := ( steplSchritt >= STEP_0_E ) AND ( steplSchritt <= STEP_1000_E );

CASE steplSchritt OF
   0: // Clean ReadObject
      o_di_AbortCode := 0;
      l_ec_WriteToDevice(xExecute := FALSE);
      steplSchritt := STEP_10_E;

  10:  // Set Parameters and Start Transfer
      l_ec_WriteToDevice.wAddress   := i_by_EcID;    
      l_ec_WriteToDevice.wObjectNum := i_w_ObjectNum;    
      l_ec_WriteToDevice.bySubIndex := i_by_SubIndex;    
      l_ec_WriteToDevice.wDataType  := i_w_DataTyp;    
      l_ec_WriteToDevice.pBuffer    := i_p_Var;    
      l_ec_WriteToDevice.wBufSize   := i_w_BufSize;    
      l_ec_WriteToDevice.timTimeOut := T#100MS;    
      l_ec_WriteToDevice(xExecute := TRUE);
      steplSchritt := STEP_20_E;
      
  20: //Transfer active
      l_ec_WriteToDevice();
      IF l_ec_WriteToDevice.xDone THEN
         //Successful
         l_ec_WriteToDevice(xExecute := FALSE);
         steplSchritt := STEP_1001_E;
       ELSIF l_ec_WriteToDevice.xAborted THEN
         //Aborted
         MemCopy(ADR(o_by_AbortCode_ErrorTask),ADR(l_ec_WriteToDevice.diAbortCode)+2,1);
         MemCopy(ADR(o_ui_AbortCode_ErrorNr)+1,ADR(l_ec_WriteToDevice.diAbortCode)+0,1);
         MemCopy(ADR(o_ui_AbortCode_ErrorNr)+0,ADR(l_ec_WriteToDevice.diAbortCode)+1,1);
         l_ec_WriteToDevice(xExecute := FALSE);
         CASE o_ui_AbortCode_ErrorNr OF 
           1029: // TimeOut
             INC_UI(l_ui_TimeOutCount);
             IF l_ui_TimeOutCount > 3 THEN
               steplSchritt := STEP_30_E;
             ELSE
               steplSchritt := STEP_0_E;
             END_IF
         ELSE
           steplSchritt := STEP_30_E;
         END_CASE
       END_IF    
       
   30: o_di_AbortCode := l_ec_WriteToDevice.diAbortCode;
       o_b_Aborted := TRUE;
       l_a_udi_AbortMsg[0] := i_by_EcID;
       l_a_udi_AbortMsg[1] := 0;
       l_a_udi_AbortMsg[2] := o_ui_AbortCode_ErrorNr;
       l_a_udi_AbortMsg[3] := i_w_ObjectNum;
       l_a_udi_AbortMsg[4] := i_by_SubIndex;
       PlcError(DH_FEHLER_COP_READ_OBJ, 2, ADR(' NodeID: %ld BusID: %ld ErrorNr: %ld Object: %i DubIndex: %ld'), ADR(l_a_udi_AbortMsg));
       steplSchritt := STEP_1001_E;
END_CASE
END_FUNCTION_BLOCK