public class ToDoUtility {
    public static Boolean isUpdateNotRecurcive = true;
    
    public static Map<String,Id> getToDoRecordTypes() {
        Map<String,Id> recordTypesMap = new Map<String,Id>();
        for (RecordType rt : [SELECT DeveloperName, Id FROM RecordType WHERE sObjectType = 'ToDo__c']) {
            recordTypesMap.put(rt.DeveloperName,rt.Id);
        }
        return recordTypesMap;
    }
    public static Map<String,Id> getQueues() {
        Map<String,Id> queuesMap = new Map<String,Id>();
        List<Group> queues = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN :getToDoRecordTypes().keySet()];
        for (Group gr : queues) {
            queuesMap.put(gr.Name,gr.Id);
        }
        return queuesMap;
    }
    public static String getCategory(Date deadline, Date completionDate) {
        if (completionDate == null) {
            completionDate = Date.today();
        }
        if (deadline > completionDate +1) {
            return 'Later';
        }
        if (deadline == completionDate + 1) {
            return 'Tomorrow';
        }
        if (deadline == completionDate) {
            return 'Today';
        }
        if (deadline < completionDate) {
            return 'Overdue';
        }
        return null;
    }
}
