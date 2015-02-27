trigger BeforeUpdateCheck on Opportunity (before update) {
sObject[] no = Trigger.new;
sObject[] oo = Trigger.old;    
System.debug('Entering Before Update Trigger');
/*for (integer i=0; i< no.size();i++)
{ 
  System.debug('New Transfer = '+ no[i].get('TransferStatus__c'));
  System.debug('Old Transfer = '+ oo[i].get('TransferStatus__c'));    
  if ((no[i].get('TransferStatus__c') == 'P') && (oo[i].get('TransferStatus__c') == 'P')) 
    no[i].addError('Can not update Pending records.');
}
*/
}