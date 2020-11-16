public class batchApex implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id  from account ';
        return Database.getQueryLocator(query);
   }
 
   public void execute(Database.BatchableContext BC, List<Account> scope){
       for(account ac : scope){
           
           ac.state__c = 'UP';
       }
     update scope;
    }
 
   public void finish(Database.BatchableContext BC){
   }

}