import { LightningElement,track } from 'lwc';
import fetchData from '@salesforce/apex/ShortSoqlQuery.fetchData';

export default class ShortSoqlEditor extends LightningElement {


   @track soqlText = 'hjghj';
   @track result ='';
  
   handleInput = async()=>{

      let jsonObject = {}


       let soqlText = this.soqlText;
       let arrStr = soqlText.split('\[');
       jsonObject['parent'] = arrStr[0].substring(1,arrStr[0].length);
       arrStr = arrStr[1].split('\]')
       jsonObject['filters'] = arrStr[0];
       arrStr = arrStr[1].split('\(');
       let parts = arrStr[1];
       jsonObject['fields'] = arrStr[1].substring(0 , parts.indexOf(')')); 
       
      // this.soqlText=[...arrStr];
     /*  arrStr.forEach(parts => {
           alert(parts)
           if(parts.indexOf('\[')!== -1){
                 jsonObject['parent'] = parts.substring(1,parts.indexOf('\['));
                 jsonObject['filters'] = parts.substring(parts.indexOf('\[')+1,parts.indexOf('\]')) 
            }
        
          if(parts.indexOf('\(') !== -1 && parts.indexOf('\)')!==-1){

              jsonObject['fields'] = parts.substring(parts.indexOf('\(') +1 , parts.indexOf(')')); 
          }

            
        }); */

        console.log(JSON.stringify(jsonObject));
        try{
        this.result = await fetchData({params:JSON.stringify(jsonObject)});
        }catch(e){this.result = JSON.stringify(e);}
       //patterns.. Object1[filters].(fields)  [select fields from object where filters]
       //Account[filters].(fields).sort(fields).desc().skip(20).limit(5)
       
       //Account(Contacts[filteers1])[filters].(fields) [select fields , (select fields from child where filters1 ) from Accoount where filters]
       //create json and send. 
    }

   getSoqlText = (event) =>{ 
     
       // this.soqlText = event.target.value;
       // console.log(soqlText);
       //console.log(event.target.value);
       try{
         let soqlText = JSON.stringify(event.target.value);
         this.soqlText=soqlText;
       }
       catch(e){
           console.log(e);
       }
    
    }


}