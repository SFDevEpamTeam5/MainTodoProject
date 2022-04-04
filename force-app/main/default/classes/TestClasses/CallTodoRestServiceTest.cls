@isTest class CallTodoRestServiceTest {
    static final String responseId = 'a008c00000a9UHWAA2';
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
        StaticResourceCalloutMock mockCallout = new StaticResourceCalloutMock();
        mockCallout.setStaticResource('NullCallout');
        mockCallout.setStatusCode(200);
        mockCallout.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, mockCallout);
        
        Test.startTest();
        Todo__c res = CallTodoRestService.getTodo('a008c00000a9NHMSD2');
        Test.stopTest();
        System.debug(res);    
        System.assertEquals(null, res.Name, 'Not null response');
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

        System.assertNotEquals(null, res, 'Null response');
        System.assertEquals('buy tomatos', res.Name, 'Wrong Todo__c returned');
    }

    @isTest static void callPostTest(){
        List<Todo__c> listT = new List<Todo__c>();
        Todo__c td = [SELECT Id, Name, isDone__c, Id_Todo_from_another_org__c FROM Todo__c WHERE Name = 'String name 3'];
        listT.add(td);
        TodoHttpCalloutMock newCalloutMock = new TodoHttpCalloutMock();
        newCalloutMock.setBody(td.Id);
        Test.setMock(HttpCalloutMock.class, newCalloutMock);
        
        Test.startTest();
        List<Todo__c> res = CallTodoRestService.callPost(listT);
        Test.stopTest();

        Todo__c td1 = [SELECT Id, Name, isDone__c, Id_Todo_from_another_org__c FROM Todo__c WHERE Name = 'String name 3'];
    
        System.assertNotEquals(null, res, 'Null response');
        System.assertEquals(td1.Id_Todo_from_another_org__c, responseId, 'Wrong id from another org');
    }
}