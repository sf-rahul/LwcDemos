import { LightningElement, track, api } from 'lwc';
import predictPicture from '@salesforce/apex/VisionController.predictOcr';

import genUrl from '@salesforce/apex/VisionController.genUrl';
import createAccounts from '@salesforce/apex/VisionController.createAccounts';

const columns = [
    { label: 'Name', fieldName: 'Name' , type:'navigation',typeAttributes:
      {   
          rowid:{fieldName:'Id'},
          label:{fieldName:'Name'},
        }},
    
    { label: 'State', fieldName: 'State__c', type: 'text' },
   
   
];
export default class DetailScreen extends LightningElement {

    
    @track
    accdata = []
    @track columns = columns;
    
    @track
    isspin = false
    @track imageUrl = '';
    @track predictions =[]
    @track ocrResult=''

    handleUploadFinished = (e)=>{
        this.predictions=[]
        let doc = e.detail.files[0];
        const cntDocId = doc.documentId;
        console.log(cntDocId)
        
        this.isspin = true;
        genUrl({picId:cntDocId})
        .then(res=>{
            return predictPicture({picId:cntDocId})
        })
        .then(res=>{
          //  this.imageUrl = "/sfc/servlet.shepherd/version/download/"+res.id;
          this.imageUrl = res.id;
            console.log(res)
            let data =  JSON.parse(JSON.stringify(res.predictions));
            data.forEach(x=>{
                x.probability =  (x.probability*100).toFixed(2) + '%' 
                  
            })
            this.predictions =data;
            this.isspin=false;
        })
        .catch()

        

    }


    handleUploadFinishedOCr=(e)=>{

        this.predictions=[]
        let doc = e.detail.files[0];
        const cntDocId = doc.documentId;
        console.log(cntDocId)
        
        this.isspin = true;
        genUrl({picId:cntDocId})
        .then(res=>{
            return predictPicture({picId:cntDocId})
        })
        .then(res=>{
          //  this.imageUrl = "/sfc/servlet.shepherd/version/download/"+res.id;
            this.imageUrl = res.id;
            console.log(res)
            let names = {}
            let data = JSON.parse(res.textResult)
            let x = [317,468,709]
            let y = [77,152,236,307]
             
            data.probabilities.forEach(d=>{
                let i = 0;
                i=d.attributes.cellLocation.rowIndex;
                if(i>1) {
                let obj = {name:'',state:''}
                if(names[i] !=undefined){
                           
                    obj = names[i]
                }

                const k = d.attributes.cellLocation.colIndex;
                if(k==1){
                    obj.name = d.label;
                }
                if(k==2){
                     obj.state = d.label;
                 }
                 names[i] = obj;
                         
               }   
            
                

                
            })
            let val = []
           for (const prop in names){
               val.push(names[prop]);
           }
           this.ocrResult = JSON.stringify(names); 
            console.log(res.textResult)
            return createAccounts({json:JSON.stringify(val)});
           
        })
        .then(result=>{
            console.log(result);
            this.accdata = result;
            this.isspin=false;
        })
        .catch(err=>{console.log(err)})

    }

    compare( a, b ) {
        if ( a.boundingBox.minX < b.boundingBox.minX && a.boundingBox.minY < b.boundingBox.minY  ){
          return -1;
        }
        if (a.boundingBox.minX > a.boundingBox.minX && a.boundingBox.minY > b.boundingBox.minY   ){
          return 1;
        }
        return 0;
      }

    @api
    get hasResult(){
        return this.predictions!=undefined && this.predictions.length>0?true:false;
    }
}