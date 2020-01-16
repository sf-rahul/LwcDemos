import { LightningElement ,track} from 'lwc';
import getAccounts  from '@salesforce/apex/AccountData.getAccounts'

const columns = [
    { label: 'Name', fieldName: 'Name' , type:'navigation',typeAttributes:
      {   
          rowid:{fieldName:'Id'},
          label:{fieldName:'Name'},
        }},
    { label: 'Website', fieldName: 'Website', type: 'url' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
   
];

export default class CustomNavigationDemo extends LightningElement {

    @track data
    @track columns;
    

   async connectedCallback(){
       this.columns=columns;
       this.data = await getAccounts();
      
      
    }


}