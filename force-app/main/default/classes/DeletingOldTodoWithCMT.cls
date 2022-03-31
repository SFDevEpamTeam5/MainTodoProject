global without sharing class DeletingOldTodoWithCMT implements Database.Batchable<Todo__c>{
    global Iterable<Todo__c> start(Database.BatchableContext bc) { 

        Date myDate = setCreationDateForQuering('Three');
        List<Todo__c> listTodos= [SELECT Id, Name, Category__c, Completion_Date__c, Deadline__c,
        Id_Todo_from_another_org__c, CreatedDate FROM Todo__c WHERE CreatedDate <=: myDate];
        return listTodos;
    }

    global void execute(Database.BatchableContext bc, List<Todo__c> scope){
        
        List<SubTodo__c> subTodoForDelete = new List<SubTodo__c>();
        
         
        Map<Id,Todo__c> todoMap = new Map<Id,Todo__c>(scope);
        if(scope.size() > 0){
            subTodoForDelete = [SELECT Id, Name FROM SubTodo__c WHERE Todo__c IN: todoMap.keySet()];
        } 
        if(subTodoForDelete.size() > 0) delete subTodoForDelete;
        if(scope.size() > 0) delete scope;
    }

    global void finish(Database.BatchableContext bc){
        System.debug('Batch Ok ' + bc.getJobId());
    }

    private static Date setCreationDateForQuering(String nameCMT){
        Map<String, Frequency_of_Todo_deletion__mdt> mapCMD = Frequency_of_Todo_deletion__mdt.getAll();
        Integer countMonth = (Integer)mapCMD.get(nameCMT).Month__c;
        Date todayDay = date.today();
        Date myDate = todayDay.addMonths(-countMonth);
        return myDate;
    }
}

