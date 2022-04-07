import { LightningElement, api } from 'lwc';

export default class ConfirmDeletingModalWindow extends LightningElement {

    @api recordId;
    showModal = false;
    
    handleConfirm(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('deletetodo', {detail : this.recordId});
        this.dispatchEvent(selectEvent);        
    }

    handleCancel(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('cancledelete');
        this.dispatchEvent(selectEvent);
        this.hide();
    }

    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }
}