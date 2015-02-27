public class Sales2OraclePush {

/*  public static void push()
  {
    System.debug('In sales2oraclePush:Starting.... ');
    push2oracle();
    System.debug('In sales2oraclePush:Ending.... ');
  }
*/
  public static String getServer()
  {
      Sales2OracleSetup__c[] soc;
      String returnVal;
      soc = [select PPServerInfo__c from Sales2OracleSetup__c 
             where Name  = 'mobile'];
      if (soc.size() > 0)
      {
          returnVal = soc[0].PPServerInfo__c;
      }
      return returnVal;
      
  }


 public static String getEbizId()
  {
      SObject[] userObj  = database.query('select Oracle_Security_Id__c	 from user where ID=\''+UserInfo.getUserId()+'\'' );
      String returnVal = null;
      if (userObj.size() > 0)
      {
          returnVal = (String)userObj[0].get('Oracle_Security_Id__c');
      }
      if ( returnVal == null)
      {
        Sales2OracleSetup__c[] soc;

        soc = [select PPServerInfo__c from Sales2OracleSetup__c 
               where Name  = 'EBizId'];
        if (soc.size() > 0)
        {
          returnVal = soc[0].PPServerInfo__c;
        }          
      }
      return returnVal;
      
  }
   
    
public Static Map<String,String> XMLParser(String strXml){
  System.debug('####Inside XMLParser Method########'+strXml);
  Map<String,String> orgInfo=new Map<String,String>();
  Dom.Document doc = new Dom.Document();
  doc.load(strXml);
//Retrieve the root element for this document.

  Dom.XMLNode Envelope = doc.getRootElement();
  System.debug('Root = '+ Envelope.getName());
  Dom.XMLNode outNode = null;
  for(Dom.XMLNode child : Envelope.getChildElements()) {
   System.debug('Child = ' + child.getName());
   if ( child.getName() == 'OutputParams')
      outNode = child; 
   if ( child.getName() == 'Message')
   {
       orgInfo.put(child.getName(),child.getText());
   }   
      
  }
  if ( outNode == null)
     return orgInfo;
  for(Dom.XMLNode child : outNode.getChildElements()) {
   System.debug('Child = ' + child.getName());
   System.debug('value = ' + child.getText());
   orgInfo.put(child.getName(),child.getText());
  }
  return orgInfo;

}
    
public static String updateTransferStatus(String msgType, 
                                          String objectName, 
                                          String internalId, 
                                          String status, 
                                          String message,
                                          String jsonStr)
{
      String rId = null;
      String selString = 'select TransferStatus__c,Transfer_Error_Message__c ';
      selString += '  from '+ objectName + ' Where Id = \''+  internalId + '\'';
      System.debug('Query = ' + selString);
      SObject[] refObj  = database.query(selString);
      System.debug('Before Update Status = '+  refObj[0].get('TransferStatus__c'));
      refObj[0].put('TransferStatus__c',status);
      refObj[0].put('Transfer_Error_Message__c',message);
      refObj[0].put('ProjectPartners__Ready_to_Sync__c',false);
      List<SObject> sObjectsToUpdate = new List<SObject>();
      sObjectsToUpdate.add(refObj[0]);
      System.debug('Before Update!!');
      update sObjectsToUpdate;
      System.debug('After Update!! with status = '+ status);
      if (status == 'P')
      {
          System.debug('Before registering Request');
          rId = insertRequest(msgType,objectName,internalId,status,'',jsonStr);
          System.debug('After registering Request');
      }
      return rId;
}    
    
public static String insertRequest(String msgType,
                            String objectName,
                            String internalId,
                            String TransferStatusCode,
                            String ErrorMessage,
                            String JSONStr)
{
/**    ProjectPartners__PPOracleReuestTracking__c[] pport = new List<ProjectPartners__PPOracleReuestTracking__c>();
    ProjectPartners__PPOracleReuestTracking__c prec = new ProjectPartners__PPOracleReuestTracking__c
                                                       (
                                                         ProjectPartners__TransferStatus__c = TransferStatusCode,
                                                         ProjectPartners__ErrorMessage__c   = ErrorMessage,
                                                         ProjectPartners__MessageType__c    = msgType,
                                                         ProjectPartners__ObjectId__c       = internalId,
                                                         ProjectPartners__ObjectName__c     = objectName,
                                                         ProjectPartners__JSONAttr__c       = JSONStr
                                                        );
    System.debug('Before Adding Request');
    pport.add(prec);
    insert pport;
    System.debug('After Adding Request');
    
    String qString = 'select max(ProjectPartners__RequestId__c) X from ProjectPartners__PPOracleReuestTracking__c '+
                 ' where ProjectPartners__ObjectId__c = \'' + internalId + '\'' +
                 ' and   ProjectPartners__TransferStatus__c = \'' + TransferStatusCode +'\'' +
                 ' and   ProjectPartners__MessageType__c    = \'' + msgType + '\'' +
                 ' and   ProjectPartners__ObjectName__c     = \'' + objectName +'\'';
    SObject[] refObj  = database.query(qString);
    
    if ( refObj.size() > 0)
      return (String)refObj[0].get('X');
    else
      return '0';
**/
     return '0';
}    


public static void updateRequest(String requestId,
                                 String TransferStatusCode,
                                 String ErrorMessage)
{
    
/**    System.debug('Entering updating Request');
    String selString = 'select ProjectPartners__TransferStatus__c,ProjectPartners__ErrorMessage__c from ProjectPartners__PPOracleReuestTracking__c where ProjectPartners__RequestId__c = \'' + requestId + '\'';
    SObject[] refObj  = database.query(selString);
    
    refObj[0].put('ProjectPartners__TransferStatus__c',TransferStatusCode);
    refObj[0].put('ProjectPartners__ErrorMessage__c',ErrorMessage);
    
    List<SObject> sObjectsToUpdate = new List<SObject>();
    sObjectsToUpdate.add(refObj[0]);
    update sObjectsToUpdate;
    
    System.debug('After updating Request');**/
    
}    
    
public static void updateReference(String msgType,String objectName,String internalId,Map<String,String> xmlData)
{
    // get meta data first
    Oracle2SalesTriggerMapping__c[] oso;
    oso = [select OracleTag__c,SalesObject__c,SalesObjectColumn__c from Oracle2SalesTriggerMapping__c where Name = :msgType];
    String selString = 'select TransferStatus__c,Transfer_Error_Message__c';
    for (Integer i=0; i < oso.size();i++)
    {
       selString += ',' + oso[i].SalesObjectColumn__c;
    }
    if (oso.size() > 0)
    {
      selString += '  from '+ oso[0].SalesObject__c + ' Where Id = \''+  internalId + '\'';
    }
    else
    {
      selString += '  from '+ objectName + ' Where Id = \''+  internalId + '\'';
    }
    System.debug('Query = ' + selString);
    SObject[] refObj  = database.query(selString);
    for (Integer i=0; i < oso.size();i++)
    {
       refObj[0].put(oso[i].SalesObjectColumn__c,xmlData.get(oso[i].OracleTag__c));
    }    
    refObj[0].put('TransferStatus__c','T');
    refObj[0].put('Transfer_Error_Message__c','');
    
    List<SObject> sObjectsToUpdate = new List<SObject>();
    sObjectsToUpdate.add(refObj[0]);
    update sObjectsToUpdate;
    
}    
@future (callout=true)
  public static void push2oracle(String objectName, String messageType, String oppId, String requestId)
  {
   // set transfer status to 'P'
   //updateTransferStatus(messageType,oppId);   
   // Read Metadata to generate JSON string
   //Sales2OraclePush.updateTransferStatus(messageType,objectName,oppId,'P','');
   
   Sales2OracleTriggerMapping__c [] sos;
   sos = [SELECT name,AttributeName__c,SourceAttribute__c,SourceObject__c,Reference_Object__c,Reference_Column__c FROM Sales2OracleTriggerMapping__c WHERE name=:messageType];
   System.debug('In sales2oraclePush:Starting....1N '+ sos.size());
   System.debug('Id = '+ oppId);
   String colList;
   Map<String,String> qMap    = new Map<String,String>(); 
   Map<String,String> attrval = new Map<String,String>(); 
   String queryList = null;   
   if (sos.size() > 0)
   {
     for (Integer i=0; i < sos.size();i++)
     {
       queryList = qMap.get(sos[i].SourceObject__c);
         
       if ( queryList == null)
         queryList = sos[i].SourceAttribute__c;
       else
         queryList += ','+sos[i].SourceAttribute__c;
       System.debug('Object = '+ sos[i].SourceObject__c + ':Value:'+ queryList);
       qMap.put(sos[i].SourceObject__c,queryList);
     }
     System.debug('In sales2oraclePush:Starting....2N ');       
     Set<String> QSet = qMap.keySet();
     String qObj;
     String selList;
     String QStr;
     System.Iterator<String> qObjIt = Qset.iterator();
     while  (qObjIt.hasNext())
     {
       qObj = qObjIt.next();
       selList = qMap.get(qObj);
       String retval;
       Qstr = 'Select '+ selList+ ' FROM ' + qObj + ' Where Id = \''+  oppId + '\'';
           System.debug('Qstr = '+ Qstr);
       String refStr = null;
       SObject[] usrObj  = database.query(Qstr);
       if (usrObj.size() > 0)
       {
           for (Integer i=0; i < sos.size();i++)
           {
               System.debug('Getting Object value = '+i + ' for '+sos[i].SourceAttribute__c);
               
               if ( sos[i].Reference_Object__c == null)
               {
                  retVal = (String)usrObj[0].get(sos[i].SourceAttribute__c);
                  System.debug('retVal = '+ retVal + ' Key = '+ sos[i].AttributeName__c);
                  attrVal.put(sos[i].AttributeName__c,retVal);
               }
               else
               {
                   String fName = sos[i].SourceAttribute__c;
                   String mName = fName.substringBefore('.')+'Id';
                   retVal = (String)usrObj[0].get(mName);
                   refStr = 'select '+ sos[i].Reference_Column__c+ ' from ' 
                                     + sos[i].Reference_Object__c+ ' where Id = \''
                                     + retVal +'\'';
                   System.debug('RefStr = '+ refStr);
                   SObject[] RefObj  = database.query(RefStr);
                   String valName = (String)RefObj[0].get(sos[i].Reference_Column__c);
                   attrVal.put(sos[i].AttributeName__c,valName);
               }
               
           }
       }
     }
     System.debug('In sales2oraclePush:Starting....3N ');
     Set<String> aSet = attrval.keySet();
     System.Iterator<String> aIt = aSet.iterator();
     String attrName;
     String attrvalS;
     String jSonString = '{"MY":{"MyArray":[{"context_name":"'+messageType+'","';
     String separator = null;                                                  
     while ( aIt.hasNext())
     {
        attrName = aIt.next();
        System.debug('AttrName = '+ attrName);
        attrValS = attrval.get(attrName);
        if (separator == null)
        {
            jSonString += attrName+'":"'+attrValS+'"';
            separator = ',';
        }
        else
        {
            jSonString += separator + '"'+attrName+'":"'+attrValS+'"';
        }
        
     }
     jSonString += '}]}}';
     System.debug('In sales2oraclePush:jSonString ='+ jSonString);         
     HttpRequest req = new HttpRequest();
     req.setMethod('GET');
     String serverInfo = getServer();
     String ebizId     = getEbizId();
     String jsonStringE =  EncodingUtil.urlEncode(jsonString, 'UTF-8'); 
     String reqString = serverInfo+'/OA_HTML/jsp/fnd/PicDisconn.jsp?PICAction=SalesIntegration&ebizId='+ebizId+'&messageType=PPSFDC_Record&jsonData='+jSonStringE;
     System.debug('In sales2oraclePush:reqString ='+ reqString);                 
     req.setEndpoint(reqString);
     req.setTimeout(60000);
     Http http = new Http();
     try {
      //Execute web service call here      
      HTTPResponse res = http.send(req);   
      String respBody = res.getBody();
      System.debug('res to string:'+respBody.trim() );
      System.debug('In sales2oraclePush:3 ');
      String xmlStr = respBody.trim();
      Map<String,String> xmlList = XMLParser(xmlStr);
      //System.debug('Value = ' + xmlList );
      String errMessage = xmlList.get('Message');
      System.debug('Error = '+errMessage);
      Integer endPos = errMessage.length();
      if ( endPos > 100) endPos = 100;
      String  emsg = null;
      if ( errMessage == '')
      {
        System.debug('Calling errMessage');  
        updateReference(messageType,objectName,oppId,xmlList);
      }
      else
      { 
        System.debug('Calling updateTransferStatus');
        emsg = errMessage.substring(0,endPos-1);
        System.debug('Calling updateTransferStatus = '+ emsg);  
        String rId = updateTransferStatus(messageType,objectName,oppId,'E',emsg,'');
      }
      updateRequest(requestId,'C',emsg);
     
   }
   catch(System.CalloutException e) {
            System.debug('Exception:'+e);
   } 
   catch (System.TypeException te){
        System.debug('Synch Failed , not able to convert response to json');   
   } 
   }
  }    
}