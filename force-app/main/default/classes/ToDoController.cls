public with sharing class ToDoController {
    @AuraEnabled
    public static List<ToDo__c> getTodolistForCategory() {
        Id userId = UserInfo.getUserId();
        return [
            SELECT Id, Name, Status__c, Deadline__C, OwnerId, Category__c
            FROM ToDo__c
            WHERE OwnerId != :userId
        ];
    }
    @AuraEnabled
    public static List<ToDo__c> getCurrentUserTodolist() {
        Id userId = UserInfo.getUserId();
        return [
            SELECT Id, Name, Status__c, Deadline__C, OwnerId, Category__c
            FROM ToDo__c
            WHERE OwnerId = :userId
        ];
    }
}
