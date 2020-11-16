public class VisionController {
    // You can upload the `einstein_platform.pem` into your Salesforce org as `File` sObject and read it as below
    public static String getAccessToken() {
        // Ignore the File upload part and "jwt.pkcs" if you used a Salesforce certificate to sign up 
        // for an Einstein Platform account
        ContentVersion base64Content = [SELECT Title, VersionData FROM ContentVersion where Title='einstein_platform' OR  Title='predictive_services' ORDER BY Title LIMIT 1];
        String keyContents = base64Content.VersionData.tostring();
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');

        // Get a new token
        JWT jwt = new JWT('RS256');
        // jwt.cert = 'JWTCert'; // Uncomment this if you used a Salesforce certificate to sign up for an Einstein Platform account
        jwt.pkcs8 = keyContents; // Comment this if you are using jwt.cert
        jwt.iss = 'developer.force.com';
        jwt.sub = 'rahul.sinha.raw@gmail.com';
        jwt.aud = 'https://api.einstein.ai/v2/oauth2/token';
        jwt.exp = '3600';
        String access_token = JWTBearerFlow.getAccessToken('https://api.einstein.ai/v2/oauth2/token', jwt);
        return access_token;    
    }

    public List<Vision.Prediction> getCallVisionUrl() {
        // Get a new token
        String access_token = getAccessToken();
    
        // Make a prediction using URL to a file
        return Vision.predictUrl('https://einstein.ai/images/generalimage.jpg',access_token,'GeneralImageClassifier');
    }

    public  List<Vision.Prediction> getCallVisionContent() {
        // Get a new token
        String access_token = getAccessToken();

        // Make a prediction for an image stored in Salesforce
        // by passing the file as blob which is then converted to base64 string
        ContentVersion content = [SELECT Title,VersionData FROM ContentVersion where Id = '0682w0000009vtfAAA' LIMIT 1];
        return Vision.predictBlob(content.VersionData, access_token, 'GeneralImageClassifier');
    }
   
   @auraEnabled
   public static Response predictImage(string picId){
       String access_token = getAccessToken();
       Contentversion version = [select id,VersionData,fileextension  from contentversion where isLatest=true and contentdocumentid = :picId];
       List<Vision.Prediction> predictions =  Vision.predictBlob(version.VersionData, access_token, 'GeneralImageClassifier');
       Response res = new Response();
       res.id = 'data:image/'+ version.FileExtension+';base64,'+ EncodingUtil.base64Encode(version.VersionData);
       res.predictions = predictions;
       return res;
       
    }
    
    @AuraEnabled
    public static string genUrl(String picId){
        
        Contentversion version = [select id,VersionData,fileextension  from contentversion where isLatest=true and contentdocumentid = :picId];
        ContentDocumentLink cdllink = [select id,visibility from contentDocumentLink where contentDocumentId = :picId];
        
        ContentDistribution newDist = new ContentDistribution();
        newDist.contentVersionId = version.id;
        newDist.name='external link';
        newDist.PreferencesNotifyOnVisit = false;
        newDist.PreferencesAllowViewInBrowser = true;
        newDist.PreferencesAllowOriginalDownload = true;
        insert newDist; 
        
        cdllink.Visibility ='AllUsers';
        update cdllink;
       
        List<ContentDistribution> cdts = [select id,DistributionPublicUrl,ContentDownloadURL from ContentDistribution where contentDocumentId =:picId];
        String imageUrl = cdts[0].ContentDownloadURL;        
        return 'success';
        
    }
    @AuraEnabled 
    public static Response predictOcr(String picId){
        String access_token = getAccessToken();
      
        List<ContentDistribution> cdts = [select id,DistributionPublicUrl,ContentDownloadURL from ContentDistribution where contentDocumentId =:picId];
        String imageUrl = cdts[0].ContentDownloadURL;
        String result = Vision.predictUrlOCR(imageUrl,access_token,'GeneralImageClassifier');
        //EinsteinOCRReponse text = EinsteinOCRReponse.parse(result);
       // String val ='';
        
       // for(EinsteinOCRReponse.Probability prob : text.probabilities){
          //  val += ' '+  prob.label;
       // }
        
       
        Response res = new Response();
       //res.id = 'data:image/'+ version.FileExtension+';base64,'+ EncodingUtil.base64Encode(version.VersionData);
        res.id = imageUrl;
       res.predictions = null;
       res.textResult = result;
       return res;
    }
    
    public class Response {
        @auraEnabled
        public string id;
        @auraEnabled
        public List<Vision.Prediction> predictions;
        @AuraEnabled
        public String textResult='';
    }
    
    
    @AuraEnabled 
    public static List<Account> createAccounts( String json){
        system.debug(json);
        try{   
       List<AccountWrp> wrap = (List<Accountwrp>) system.JSON.deserialize(json,List<AccountWrp>.class);
       List<Account> accList = new List<Account>();
        for(accountwrp w : wrap){
            if(String.isNotBlank(w.name) && String.isNotBlank(w.state) && w.name != 'Name' && w.state != 'State'){
             account ac = new account();
             ac.name = w.name;
             ac.State__c = w.state;
             accList.add(ac);
        }
        } 
        
        insert accList;
        
        return accList;
        }catch(Exception e){
            return null;
        }
     }
    
    
    public class AccountWrp{
        
         String name ;
         String state ;
        
    }
    
    
}