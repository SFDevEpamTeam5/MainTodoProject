public class ToDoCategoriesUpdaterBatch implements Database.Batchable<SObject>{
    public Map<String,Id> todorecordtypes;
    public Map<String,Id> todoqueues;
    public Set<Id> todoQueuesIds;
    public ToDoCategoriesUpdaterBatch() {
        todorecordtypes = ToDoUtility.getToDoRecordTypes();
        todoqueues = ToDoUtility.getQueues();
        Set<Id> todoQueuesIds = new Set<Id>();
        todoQueuesIds.addAll(todoqueues.values());
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Status__c, Deadline__c, '
        +'Completion_Date__c, IsDone__c, RecordTypeId, OwnerId FROM ToDo__c '
        +'WHERE OwnerId IN :todoQueuesIds AND Status__c != \'Done\'');
    }
    public void execute(Database.BatchableContext bc,List<SObject> scope) {
        Set<Id> recordtypesIds = new Set<Id>();
        recordtypesIds.addAll(todorecordtypes.values());
        List<ToDo__c> todolistForUpdate = new List<ToDo__c>();
        for (SObject s: scope) {
            ToDo__c t = (ToDo__c)s;
            String category = ToDoUtility.getCategory(t.Deadline__c, Date.today());
            t.RecordTypeId = todorecordtypes.get(category);
            t.OwnerId = todoQueues.get(category);
            todolistForUpdate.add(t);
        }
        if (!todolistForUpdate.isEmpty()) {
            update todolistForUpdate;
        }
    }
    public void finish(Database.BatchableContext bc) {

    }
}
