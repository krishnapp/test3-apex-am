@isTest(SeeAllData=true)
public class Sales2OraclePushTest {

    static testMethod void verifyopportunity()
    {
      String objectName = 'Opportunity';
      String fieldName  = 'StageName';    
      String newStatus  = 'Contracts';
    
      Sales2OracleTriggerSetup__c [] sos = [SELECT PPMessageType__c 
                                            FROM Sales2OracleTriggerSetup__c 
                                            WHERE SalesforceObject__c=:objectName 
                                            and TriggerFieldName__c = :fieldName 
                                            and TriggerFieldValue__c = :newStatus];

        
       // Testing XML parsing
       String xmlString = '<PICRequestStatus><Status>SUCCESS</Status><OutputParams><RequestId>12345</RequestId></OutputParams><Message></Message><Details></Details></PICRequestStatus>'; 
       Map<String,String> xmlDataR =  Sales2OraclePush.XMLParser(xmlString);
        
        String selString = 'select Id';
      selString += '  from Opportunity Where Name = \'ITPFM\'';
      System.debug('Query = ' + selString);
      //SObject[] newOpps  = database.query(selString);
      String oName = 'ITPFM';
      Sobject[] newOpps = [select Id from Opportunity where name = :oName];
      newOpps[0].put('StageName','Contracts');
      newOpps[0].put('ProjectPartners__Ready_to_Sync__c',true);  
      List<SObject> sObjectsToUpdate = new List<SObject>();
      sObjectsToUpdate.add(newOpps[0]);
      update sObjectsToUpdate;
        
//      if (newOpps.size() > 0 )
//      {
        Sales2OraclePush.updateTransferStatus(sos[0].PPMessageType__c,'Opportunity',newOpps[0].Id,'P','','');
        Sales2OraclePush.push2oracle(objectName,sos[0].PPMessageType__c,newOpps[0].Id,'1');
//      }
        Map<String,String> xmlData = new Map<String,String>();
        xmlData.put('ReturnData','<Message></Message>');
        Sales2OraclePush.updateReference(sos[0].PPMessageType__c,'Opportunity',newOpps[0].Id,xmlData);
   }
}