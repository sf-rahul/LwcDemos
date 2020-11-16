public with sharing class ContactHandler {

  @AuraEnabled(cacheable= true)
  public static List<Contact> getContacts(){

     return [select id,Name,Phone from Contact];

  }

}