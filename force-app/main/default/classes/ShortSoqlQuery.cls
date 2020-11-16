public class ShortSoqlQuery {
    
   class query {
     String parent;
     String filters;
     String fields;
        
        }
    
    @auraEnabled
    public static String fetchData(String params){
        query q = (Query)JSON.deserializeStrict(params, Query.class);
        
       String QueryString = ' select ' + q.fields + ' from  ' +  q.parent + ' ' + ' Where ' + q.filters;
       System.debug(QueryString); 
        
        return JSON.serialize(Database.query(QueryString));
        
    }
    
    
 

}