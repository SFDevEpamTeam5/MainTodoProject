trigger ToDoTrigger on ToDo__c (before insert, before update) {
    if (Trigger.isInsert && Trigger.isBefore) {
        ToDoTriggerHandler.onBeforeInsert(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        ToDoTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
}