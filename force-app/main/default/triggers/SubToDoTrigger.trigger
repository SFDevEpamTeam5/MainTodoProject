trigger SubToDoTrigger on SubToDo__c (before insert, after insert, before update, after update, before delete, after delete) {
    if (Trigger.isInsert && Trigger.isAfter) {
        SubToDoTriggerHandler.onAfterInsert(Trigger.newMap);
    }
    if (Trigger.isUpdate && Trigger.isAfter) {
        SubToDoTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }
    if (Trigger.isDelete && Trigger.isAfter) {
        SubToDoTriggerHandler.onAfterDelete(Trigger.oldMap);
    }
}