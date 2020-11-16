public class AccountData {

    
  @AuraEnabled(cacheable= true)
  public static List<Account> getAccounts(){

     return [select id,Name,Phone,Website from Account];

  }

}