import { LightningElement, api } from 'lwc';

export default class ConfirmDeletingModalWindow extends LightningElement {

    @api recordId;
    
    handleConfirm(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('deletetodo', {detail : this.recordId});
        this.dispatchEvent(selectEvent);        
    }

    handleCancel(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('cancledelete');
        this.dispatchEvent(selectEvent);
    }
}