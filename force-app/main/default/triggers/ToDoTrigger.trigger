trigger ToDoTrigger on ToDo__c (before insert, before update, after insert, after update, after delete) {
    if (Trigger.isInsert && Trigger.isBefore) {
        ToDoTriggerHandler.onBeforeInsert(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        ToDoTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    if (Trigger.isInsert && Trigger.isAfter) {
        ToDoTriggerHandler.onAfterInsert(Trigger.newMap);
    }
    if (Trigger.isDelete && Trigger.isAfter) {
        ToDoTriggerHandler.onAfterDelete(Trigger.oldMap);
    }
    if (Trigger.isUpdate && Trigger.isAfter) {
        ToDoTriggerHandler.onAfterUpdate(Trigger.oldMap,Trigger.newMap);
    }
}