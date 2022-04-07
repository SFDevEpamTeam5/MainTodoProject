import { api, LightningElement, track } from 'lwc';
import getSubTodoList from '@salesforce/apex/SubToDoController.getSubTodoList';
import createSubTodo from '@salesforce/apex/SubToDoController.createSubTodo';
import updateSubtodo from '@salesforce/apex/SubToDoController.updateSubtodo';
import deleteSubtodo from '@salesforce/apex/SubToDoController.deleteSubtodo';


const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

export default class AddEditWindow extends LightningElement {
    @api recordid;
    @track subtodolist;
    @track error;
    @track newsubtodo;
    @track formid;
    @track subtitle;
    @track subisdone;
    @track todoisdone;
    @track completiondateid;
    connectedCallback() {
        getSubTodoList({recordid: this.recordid}).
        then(result => {
            this.subtodolist = result;
        }).
        catch(error => {
            this.error = error;
        });
    }
    renderedCallback() {
         this.newsubtodo = this.template.querySelector('.newsubtodo');
         this.formid = this.template.querySelector('.formid');
         this.subtitle = this.template.querySelector('.subtitle');
         this.subisdone = this.template.querySelectorAll('.subisdone');
         this.todoisdone = this.template.querySelector('.todoisdone');
         this.completiondateid = this.template.querySelector('.completiondateid');
    }
    handleAddSubtodo(e) {
        this.newsubtodo.hidden = false;
        this.formid.hidden = true;
    }
    handleKeyup(e) {
        if (e.code === 'Enter') {
            this.newsubtodo.hidden = true;
            this.formid.hidden = false;
            createSubTodo({todorecordid:this.recordid,title:e.target.value}).then(() => {
                getSubTodoList({recordid: this.recordid}).
                    then(result => {
                        this.subtodolist = result;
                    }).then(() => {this.handleCheckboxChange();}).
                    catch(error => {
                        this.error = error;
                    });
                    this.subtitle.value = '';
            }).catch(error => {
                this.error = error;
            })
        }
    }
    closeWindow() {
        this.dispatchEvent(new CustomEvent('closewindow',{bubbles:true}));
    }
    handleCheckboxChange(e) {
        let amountofsubtodo = this.subisdone.length;
        let count = 0;
        for(let i=0;i<amountofsubtodo;i++) {
            let chkd = this.subisdone[i].checked;
            if (chkd) {
                count++;
            }
        }
        if (count == amountofsubtodo){
            this.todoisdone.value=true;
            let d = new Date();
            let str = `${months[d.getMonth()]} ${d.getDate()}, ${d.getFullYear()}`;
            this.completiondateid.value=str;
        } else {
            this.todoisdone.value=false;
            this.completiondateid.value='';
        }
    }
    handleSave() {
        let res = [];
        let amountofsubtodo = this.subisdone.length;
        for(let i=0;i<amountofsubtodo;i++) {
            let chkd = this.subisdone[i].checked;
            res.push({
                "subid": this.subisdone[i].dataset.id,
                "isdone": this.subisdone[i].checked,
                "parentid":this.recordid
            })
        }
        updateSubtodo({subtodos:JSON.stringify(res)}).then().catch(error=>{error=this.error});
    }
    handleDelete(e) {
        deleteSubtodo({subtodoid: e.target.dataset.subtodoid})
        .then(() => {
            getSubTodoList({recordid: this.recordid}).
                then(result => {
                    this.subtodolist = result;
                }).then(() => {this.handleCheckboxChange();}).
            catch(error => {
                    this.error = error;
            });
        })
        .catch(error => {this.error = error;})
    }
}