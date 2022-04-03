public with sharing class SubToDoTriggerHandler {
    public static void onAfterInsert(Map<Id,SubToDo__c> subtodoMap) {
        Set<Id> subtodoIds = new Set<Id>();
        for (Id key : subtodoMap.keySet()) {
            if (!subtodoMap.get(key).Insert_from_remote_org__c) {
                subtodoIds.add(key);
            }
        }
        uploadSubTodoToRemoteOrg(subtodoIds);
    }
    public static void onAfterUpdate(Map<Id,SubToDo__c> oldSubtodoMap, Map<Id,SubToDo__c> newSubtodoMap) {
        Map<String, Schema.SObjectField> fieldmap = new Map<String,Schema.SObjectField>();
        Set<String> fieldExcludeList = new Set<String>{'LastModifiedDate', 'LastActivityDate', 'SystemModstamp', 'LastViewedDate', 'LastReferencedDate',  'RecordTypeId', 'Id_SubTodo_from_another_org__c', 'Insert_from_remote_org__c'};
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.SubToDo__c.fields.getMap();

        for(Schema.SObjectField F : Schema.SObjectType.SubToDo__c.fields.getMap().values()) {
            if (!fieldExcludeList.contains(F.getDescribe().getName())) {
                fieldmap.put(f.getDescribe().getName(), F);
            }
        }

        Set<Id> subtodosForUpdateIds = new Set<Id>();
        for(SubToDo__c st: newSubtodoMap.values() ){
            for(String fieldApiName : fieldmap.keySet()){
                if(st.get(fieldApiName) != oldSubtodoMap.get(st.Id).get(fieldApiName) ){
                    System.debug('field '+fieldApiName);
                    subtodosForUpdateIds.add(st.Id);
                }
            }
        }
        System.debug('call from subtodo handler '+subtodosForUpdateIds.size());
        if (!System.isFuture()) {
            updateSubTodoFromRemoteOrg(subtodosForUpdateIds);
        }
    }
    public static void onAfterDelete(Map<Id,SubToDo__c> oldSubtodoMap) {
        Map<Id, SubToDo__c> subtodoForDelete = new Map<Id,SubToDo__c>(getSubtodoList(oldSubtodoMap.keySet()));
        if (!subtodoForDelete.isEmpty()) {
            List<Id> remoteSubTodoIds = new List<Id>();
            for (SubToDo__c subt: subtodoForDelete.values()) {
                remoteSubTodoIds.add(subt.Id_SubTodo_from_another_org__c);
            }
            removeSubTodoFromRemoteOrg(remoteSubTodoIds);
        }   
    }
    //future methods
    @future(callout=true)
    public static void uploadSubTodoToRemoteOrg(Set<Id> subtodoIds) {
        List<SubToDo__c> subtodoListForUpload =  getSubtodoList(subtodoIds);
        List<SubToDo__c> uploadedSubTodoList = CallSubTodoRestService.callPost(subtodoListForUpload);
        update uploadedSubTodoList;
    }
    @future(callout=true)
    public static void updateSubTodoFromRemoteOrg(Set<Id> subtodoIds) {
        List<SubToDo__c> subtodoListForUpdate = getSubtodoList(subtodoIds);
        CallSubTodoRestService.callPatch(subtodoListForUpdate);
    }
    @future(callout=true)
    public static void removeSubTodoFromRemoteOrg (List<Id> subtodoIds) {
        CallSubTodoRestService.callDelete(subtodoIds);
    }
    private static List<SubToDo__c> getSubtodoList(Set<Id> subtodoIds) {
        return [
            SELECT Id, Name, SubToDo__c.ToDo__c, IsDone__c, Insert_from_remote_org__c, Id_SubTodo_from_another_org__c
            FROM SubToDo__c
            WHERE Id IN :subtodoIds
        ];
    }
}
