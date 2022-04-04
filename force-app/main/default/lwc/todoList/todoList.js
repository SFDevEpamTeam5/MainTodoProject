import { api, LightningElement, track } from 'lwc';

export default class TodoList extends LightningElement {
    @track isModalOpen = false;
    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    handleCloseWindow() {
        this.closeModal();
    }
}