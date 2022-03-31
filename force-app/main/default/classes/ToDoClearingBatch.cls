public class ToDoClearingBatch implements Database.Batchable<SObject> {
    public final Integer months;
    public final Date deletingDate;
    public ToDoClearingBatch() {
        months = (Integer)ToDo_Clear_Configuration__mdt.getInstance('Number_Of_Months').Month__c;
        deletingDate = Date.today().addMonths((-1)*months);
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, CreatedDate, Status__c, Deadline__c, '
        +'Completion_Date__c, IsDone__c, RecordTypeId, OwnerId FROM ToDo__c '
        +'WHERE CreatedDate <= :deletingDate');
    }
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<ToDo__c> todoListForDelete = (List<ToDo__c>)scope;
        if (todoListForDelete.size() != 0) {
            delete todoListForDelete;
        }
    }
    public void finish(Database.BatchableContext bc) {

    }
}
