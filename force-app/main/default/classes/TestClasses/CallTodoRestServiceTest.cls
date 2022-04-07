@isTest class CallTodoRestServiceTest {
    static final String responseId = 'a008c00000a9UHWAA2';
    static final String BODY_DELETECALL = 'a008c00000a9NHOAA2';
    @TestSetup
    static void makeData(){
        Date dateToday = Date.today();
        List<Todo__c> listTodos = new List<Todo__c>();
        Todo__c todo1 = TestDataFactory.TODO.createDummyTodo('String name 1', dateToday, false, 'a054Q0000016zhjGGG', false);
        Todo__c todo2 = TestDataFactory.TODO.createDummyTodo('String name 2', dateToday, false, 'a068Q0000016zhjDDD', false);
        Todo__c todo3 = TestDataFactory.TODO.createDummyTodo('String name 3', dateToday, false, 'a091Q0000016zhjSSS', false);
        listTodos.add(todo1);
        listTodos.add(todo2);
        listTodos.add(todo3);
        insert listTodos;
    }

    @isTest static void updateTodosTest(){
        Todo__c todo2 = [SELECT Id, Name FROM Todo__c WHERE Name = 'String name 2'];
        Map<Id, Id> todosWereCreated = new Map<Id, Id>();
        todosWereCreated.put(todo2.Id, 'a027Q0000016zhjQAA');

        Test.startTest();
        CallTodoRestService.updateTodos(todosWereCreated);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Todo__c WHERE Id_Todo_from_another_org__c = 'a027Q0000016zhjQAA']);
        System.assertEquals(3, [SELECT COUNT() FROM Todo__c]);
    }

    @isTest static void callGetCallNullTest(){     
        Test.setMock(HttpCalloutMock.class, new EmptyResponseBodyHttpCalloutMock());
        
        Test.startTest();
        Todo__c res = CallTodoRestService.getTodo('a008c00000a9NHMSD2');
        Test.stopTest();
        System.debug(res);    
        System.assertEquals(null, res, 'Not null response');
    }

    @isTest static void callGetTest(){
        StaticResourceCalloutMock mockCallout = new StaticResourceCalloutMock();
        mockCallout.setStaticResource('mockTodoResource');
        mockCallout.setStatusCode(200);
        mockCallout.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, mockCallout);
        
        Test.startTest();
        Todo__c res = CallTodoRestService.getTodo('a008c00000a9NHOAA2');
        Test.stopTest();  

        System.assertNotEquals(null, res, 'Null response when call get todo');
        System.assertEquals('buy tomatos', res.Name, 'Wrong Todo__c returned');
    }

    @isTest static void callPostTest(){
        List<Todo__c> listT = fullListOfTodos();
        TodoHttpCalloutMock newCalloutMock = new TodoHttpCalloutMock();
        newCalloutMock.setBody(listT[0].Id);
        Test.setMock(HttpCalloutMock.class, newCalloutMock);
        
        Test.startTest();
        List<Todo__c> res = CallTodoRestService.callPost(listT);
        Test.stopTest();

        Todo__c td1 = [SELECT Id, Name, isDone__c, Id_Todo_from_another_org__c FROM Todo__c WHERE Name = 'String name 3'];
    
        System.assertNotEquals(null, res, 'Null response when call post todo');
        System.assertEquals(td1.Id_Todo_from_another_org__c, responseId, 'Wrong todo id from another org');
    }

    @isTest static void callPostBadRequestTest(){
        List<Todo__c> listT = fullListOfTodos();
        Test.setMock(HttpCalloutMock.class, new BadRequestCalloutMock());
        
        Test.startTest();
        List<Todo__c> res = CallTodoRestService.callPost(listT);
        Test.stopTest();
    
        System.assertEquals(null, res, 'Not Null response when call post todo bad req');
    }

    @isTest static void callDeleteTest(){
        Test.setMock(HttpCalloutMock.class, new TodoDeleteHttpCalloutMock());
        List<Id> ids = new List<Id>();
        ids.add('0017Q000006s7AcQAI');

        Test.startTest();
        List<String> res = CallTodoRestService.callDelete(ids);
        Test.stopTest();

        System.assertNotEquals(null, res, 'Null response when call delete todo');
        System.assertEquals('not deleted', res[0]);
    }
    @isTest static void callDeleteBadRequestTest(){
        Test.setMock(HttpCalloutMock.class, new BadRequestCalloutMock());
        List<Id> ids = new List<Id>();
        ids.add('0017Q000006s7AcQAI');

        Test.startTest();
        List<String> res = CallTodoRestService.callDelete(ids);
        Test.stopTest();

        System.assertEquals(null, res, 'Not Null response when call delete todo');
    }
    @isTest static void callDeleteEmptyResponseTest(){
        Test.setMock(HttpCalloutMock.class, new EmptyResponseBodyHttpCalloutMock());
        List<Id> ids = new List<Id>();
        ids.add('0017Q000006s7AcQAI');

        Test.startTest();
        List<String> res = CallTodoRestService.callDelete(ids);
        Test.stopTest();

        System.assertEquals(null, res, 'Not null response when call delete todo');
    }
    @isTest static void callPutTest(){
        List<Todo__c> listT = fullListOfTodos();
        TodoHttpCalloutMock newCalloutMock = new TodoHttpCalloutMock();
        newCalloutMock.setBody(listT[0].Id);
        Test.setMock(HttpCalloutMock.class, newCalloutMock);
        
        Test.startTest();
        Map<Id, String> res = CallTodoRestService.callPut(listT);
        Test.stopTest();

        List<Id> idsFromAnotherOrgList = new List<Id>(res.keySet());
        Todo__c td1 = [SELECT Id, Name, isDone__c, Id_Todo_from_another_org__c FROM Todo__c WHERE Name = 'String name 3'];
    
        System.assertNotEquals(null, res, 'Null response when call put todo');
        System.assertEquals(responseId, res.get(idsFromAnotherOrgList[0]), 'Wrong todo id from another org');
        System.assertEquals(td1.Id, idsFromAnotherOrgList[0], 'Wrong todo id');
    }
    @isTest static void callPutBadRequestTest(){
        List<Todo__c> listT = fullListOfTodos();
        Test.setMock(HttpCalloutMock.class, new BadRequestCalloutMock());
        
        Test.startTest();
        Map<Id, String> res = CallTodoRestService.callPatch(listT);
        Test.stopTest();
    
        System.assertEquals(null, res, 'Not Null response when call patch todo bad req');
    }
    @isTest static void callPutRecordCreatedTest(){
        List<Todo__c> listT = fullListOfTodos();
        TodoPutRecordCreatedHttpCalloutMock newCalloutMock = new TodoPutRecordCreatedHttpCalloutMock();
        newCalloutMock.setBody(listT[0].Id);
        Test.setMock(HttpCalloutMock.class, newCalloutMock);
        
        Test.startTest();
        Map<Id, String> res = CallTodoRestService.callPut(listT);
        Test.stopTest();

        List<Id> idsFromAnotherOrgList = new List<Id>(res.keySet());
        Todo__c td1 = [SELECT Id, Name, isDone__c, Id_Todo_from_another_org__c FROM Todo__c WHERE Name = 'String name 3'];
    
        System.assertNotEquals(null, res, 'Null response when call put todo');
        System.assertEquals(td1.Id, idsFromAnotherOrgList[0], 'Wrong todo id');
        System.assertEquals(responseId, td1.Id_Todo_from_another_org__c, 'Wrong todo id');
    }
    @isTest static void callPatchTest(){
        List<Todo__c> listT = fullListOfTodos();
        TodoHttpCalloutMock newCalloutMock = new TodoHttpCalloutMock();
        newCalloutMock.setBody(listT[0].Id);
        Test.setMock(HttpCalloutMock.class, newCalloutMock);
        
        Test.startTest();
        Map<Id, String> res = CallTodoRestService.callPatch(listT);
        Test.stopTest();

        List<Id> idsFromAnotherOrgList = new List<Id>(res.keySet());
        Todo__c td1 = [SELECT Id, Name, isDone__c, Id_Todo_from_another_org__c FROM Todo__c WHERE Name = 'String name 3'];
    
        System.assertNotEquals(null, res, 'Null response when call patch todo');
        System.assertEquals(responseId, res.get(idsFromAnotherOrgList[0]), 'Wrong todo id from another org');
        System.assertEquals(td1.Id, idsFromAnotherOrgList[0], 'Wrong todo id');
    }
    @isTest static void callPatchBadRequestTest(){
        List<Todo__c> listT = fullListOfTodos();
        Test.setMock(HttpCalloutMock.class, new BadRequestCalloutMock());
        
        Test.startTest();
        Map<Id, String> res = CallTodoRestService.callPut(listT);
        Test.stopTest();
    
        System.assertEquals(null, res, 'Not Null response when call put todo bad req');
    }
    @TestVisible
    private static List<Todo__c> fullListOfTodos(){
        List<Todo__c> listT = new List<Todo__c>();
        Todo__c td = [SELECT Id, Name, isDone__c, Id_Todo_from_another_org__c FROM Todo__c WHERE Name = 'String name 3'];
        listT.add(td);
        return listT;
    }
}