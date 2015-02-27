trigger Sales2Oracle on Opportunity (after update) {
    
sObject[] no = Trigger.new;
sObject[] oo = Trigger.old;    
String objectName = 'Opportunity'; 
if ( no[0].get('ProjectPartners__Ready_to_Sync__c') == false)
 return;
   
Sales2OracleTriggerSetup__c [] sos = [SELECT PPMessageType__c,TriggerFieldName__c,TriggerFieldValue__c  FROM Sales2OracleTriggerSetup__c WHERE SalesforceObject__c=:objectName order by TriggerFieldValue__c];
    
String changeFlag = null;
String messageType = null;
Sales2OracleTriggerSetup__c stagerec;
    
for (integer i=0; i< sos.size();i++)
{
  stagerec = sos[i];
  System.debug('In sales2oracle: In loop ');
  if ( stagerec.TriggerFieldValue__c == 'update')
  {   
      System.debug('In sales2oracle: Value is null ');
      if (( no[0].get(stagerec.TriggerFieldName__c) != oo[0].get(stagerec.TriggerFieldName__c))
        || (no[0].get('ProjectPartners__Ready_to_Sync__c') == true))
      {
         System.debug('In sales2oracle: Value is not matching ');
         messageType = stagerec.PPMessageType__c;
         changeFlag  = 'Y';
         break;
      }
  }
  else if ( stagerec.TriggerFieldValue__c == 'create')
  {
      System.debug('In sales2oracle: Create Loop ');
      if (no[0].get(stagerec.TriggerFieldName__c) == null)
      {
         messageType = stagerec.PPMessageType__c;
         changeFlag  = 'Y';
         System.debug('In sales2oracle: Exiting Create Loop '); 
         break;
      }
  }
  else
  {
      if (( no[0].get(stagerec.TriggerFieldName__c) != oo[0].get(stagerec.TriggerFieldName__c))
         && ( no[0].get(stagerec.TriggerFieldName__c) == stagerec.TriggerFieldValue__c )) 
      {
         messageType = stagerec.PPMessageType__c;
         changeFlag  = 'Y';
         break;
      }
  }
}    
System.debug('In sales2oracle ');

if ((changeFlag == 'Y') && (no[0].get('TransferStatus__c') != 'P'))
{
    System.debug('In sales2oracle: Pushing data to Oracle ');
    String rId = Sales2OraclePush.updateTransferStatus(messageType,'Opportunity',(String)no[0].get('Id'),'P','','');
    Sales2OraclePush.push2oracle(objectName,messageType,(String)no[0].get('Id'), rId);
    
}    
/**
String newStatus = newOpps[0].StageName;
String oldStatus = oldOpps[0].StageName;
String objectName = 'Opportunity';
String fieldName  = 'StageName';    
    
Sales2OracleTriggerSetup__c [] sos = [SELECT PPMessageType__c  FROM Sales2OracleTriggerSetup__c WHERE SalesforceObject__c=:objectName and TriggerFieldName__c = :fieldName and TriggerFieldValue__c = :newStatus];

if (sos.size() > 0)
{
  if ( newStatus  != oldStatus )
  {
    System.debug('In sales2oracle: Pushing data to Oracle ');
    Sales2OraclePush.updateTransferStatus(sos[0].PPMessageType__c,newOpps[0].Id,'P','');
    Sales2OraclePush.push2oracle(objectName,sos[0].PPMessageType__c,newOpps[0].Id);
          
  }  
}  **/  
}