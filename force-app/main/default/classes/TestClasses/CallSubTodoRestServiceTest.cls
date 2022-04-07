@isTest 
public class CallSubTodoRestServiceTest {
    static final String responseId = 'a008c00000a9NHOAA1';
    @TestSetup
    static void makeData(){
        Date dateToday = Date.today();
        Todo__c todos = TestDataFactory.TODO.createDummyTodo('String name 1', dateToday, false, 'a054Q0000016zhjGGG', false);
        insert todos;
        List<SubToDo__c> listS = new List<SubToDo__c>();
        SubTodo__c sub1 = TestDataFactory.SUBTODO.createDummySubTodo('SubTodo 1', false, 'a008c00000a9NHOAA1', todos.Id, false);
        SubTodo__c sub2 = TestDataFactory.SUBTODO.createDummySubTodo('SubTodo 2', false, 'a008c00000a9NHOAA2', todos.Id, false);
        SubTodo__c sub3 = TestDataFactory.SUBTODO.createDummySubTodo('SubTodo wot', false, null, todos.Id, false);
        listS.add(sub1);
        listS.add(sub2);
        listS.add(sub3);
        insert listS;
    }
    @isTest static void getSubTodoTest(){
        StaticResourceCalloutMock mockCallout = new StaticResourceCalloutMock();
        mockCallout.setStaticResource('mockSubTodoResource');
        mockCallout.setStatusCode(200);
        mockCallout.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, mockCallout);
        
        Test.startTest();
        SubTodo__c res = CallSubTodoRestService.getSubTodo('0017Q000006s7AcQAI');
        Test.stopTest();  

        System.assertNotEquals(null, res, 'Null response when call get todo');
        System.assertEquals('buy potato', res.Name, 'Wrong Todo__c returned');
    }

    @isTest static void getSubTodoNullResponceTest(){
        Test.setMock(HttpCalloutMock.class, new EmptyResponseBodyHttpCalloutMock());
        Test.startTest();
        SubTodo__c resS = CallSubTodoRestService.getSubTodo('a008c00000a9NHOAA2');
        Test.stopTest();
        System.assertEquals(null, resS, 'Not Null response');
    }

    @isTest static void callPostTest(){
        List<SubTodo__c> listS = fullListOfSubTodos('SubTodo wot');
        SubTodoHttpCalloutMock newCalloutMock = new SubTodoHttpCalloutMock();
        newCalloutMock.setBody(listS[0].Id);
        Test.setMock(HttpCalloutMock.class, newCalloutMock);
        
        Test.startTest();
        List<SubTodo__c> res = CallSubTodoRestService.callPost(listS);
        Test.stopTest();
    
        System.assertNotEquals(null, res, 'Null response when call post todo');
        System.assertEquals(responseId, res[0].Id_SubTodo_from_another_org__c , 'Wrong todo id from another org');
    }

    @isTest static void callPostNullResponseTest(){
        List<SubTodo__c> listS = fullListOfSubTodos('SubTodo wot');
        Test.setMock(HttpCalloutMock.class, new BadRequestCalloutMock());
        
        Test.startTest();
        List<SubTodo__c> res = CallSubTodoRestService.callPost(listS);
        Test.stopTest();
    
        System.assertEquals(null, res, 'Not Null response when call post todo bad req');
    }

    @isTest static void callDeleteTest(){
        Test.setMock(HttpCalloutMock.class, new TodoDeleteHttpCalloutMock());
        List<Id> ids = new List<Id>();
        ids.add('0017Q000006s7AcQAI');

        Test.startTest();
        List<String> res = CallSubTodoRestService.callDelete(ids);
        Test.stopTest();

        System.assertNotEquals(null, res, 'Null response when call delete todo');
        System.assertEquals('not deleted', res[0]);
    }

    @isTest static void callDeleteNullResponseTest(){
        Test.setMock(HttpCalloutMock.class, new BadRequestCalloutMock());
        List<Id> ids = new List<Id>();
        ids.add('0017Q000006s7AcQAI');

        Test.startTest();
        List<String> res = CallSubTodoRestService.callDelete(ids);
        Test.stopTest();

        System.assertEquals(null, res, 'Not Null response when call delete todo');
    }

    @isTest static void callPatchTest(){
        List<SubTodo__c> listS = fullListOfSubTodos('SubTodo 1');
        SubTodoHttpCalloutMock newCalloutMock = new SubTodoHttpCalloutMock();
        newCalloutMock.setBody(listS[0].Id);
        Test.setMock(HttpCalloutMock.class, newCalloutMock);
        
        Test.startTest();
        Map<Id, String> res = CallSubTodoRestService.callPatch(listS);
        Test.stopTest();

        List<Id> idsFromAnotherOrgList = new List<Id>(res.keySet());
        SubTodo__c std = [SELECT Id, Name, isDone__c, Id_SubTodo_from_another_org__c FROM SubTodo__c WHERE Name = 'SubTodo 1'];
    
        System.assertNotEquals(null, res, 'Null response when call patch todo');
        System.assertEquals(responseId, res.get(idsFromAnotherOrgList[0]), 'Wrong todo id from another org');
        System.assertEquals(std.Id, idsFromAnotherOrgList[0], 'Wrong todo id');
    }

    @isTest static void callPatchNullResponseTest(){
        List<SubTodo__c> listS = fullListOfSubTodos('SubTodo 1');
        Test.setMock(HttpCalloutMock.class, new BadRequestCalloutMock());
        
        Test.startTest();
        Map<Id, String> res = CallSubTodoRestService.callPatch(listS);
        Test.stopTest();
    
        System.assertEquals(null, res, 'Not Null response when call patch todo bad req');
    }

    @isTest static void callPutTest(){
        List<SubTodo__c> listS = fullListOfSubTodos('SubTodo 1');
        SubTodoHttpCalloutMock newCalloutMock = new SubTodoHttpCalloutMock();
        newCalloutMock.setBody(listS[0].Id);
        Test.setMock(HttpCalloutMock.class, newCalloutMock);
        
        Test.startTest();
        Map<Id, String> res = CallSubTodoRestService.callPut(listS);
        Test.stopTest();

        List<Id> idsFromAnotherOrgList = new List<Id>(res.keySet());
        SubTodo__c std = [SELECT Id, Name, isDone__c, Id_SubTodo_from_another_org__c FROM SubTodo__c WHERE Name = 'SubTodo 1'];
    
        System.assertNotEquals(null, res, 'Null response when call put todo');
        System.assertEquals(responseId, res.get(idsFromAnotherOrgList[0]), 'Wrong todo id from another org');
        System.assertEquals(std.Id, idsFromAnotherOrgList[0], 'Wrong todo id');
    }

    @isTest static void callPutNullResponseTest(){
        List<SubTodo__c> listS = fullListOfSubTodos('SubTodo 1');
        Test.setMock(HttpCalloutMock.class, new BadRequestCalloutMock());
        
        Test.startTest();
        Map<Id, String> res = CallSubTodoRestService.callPut(listS);
        Test.stopTest();
    
        System.assertEquals(null, res, 'Not Null response when call patch todo bad req');
    }

    @isTest static void updateSubTodosTest(){
        List<SubToDo__c> subList = [SELECT Id, Name, Id_SubTodo_from_another_org__c, IsDone__c, ToDo__c FROM SubToDo__c Where Name = 'SubTodo wot'];
        Map<Id,Id> idsMap = new Map<Id,Id>();
        for(SubTodo__c st : subList){
            idsMap.put(st.Id, 'a008c00000a9NHOAA3');
        }
        Test.startTest();
        CallSubTodoRestService.updateSubTodos(idsMap);
        List<SubToDo__c> resList = [SELECT Id, Name, Id_SubTodo_from_another_org__c, IsDone__c, ToDo__c FROM SubToDo__c Where Name = 'SubTodo wot'];
        Test.stopTest();

        System.assert(resList != null, 'Empty SubList');
        System.assertEquals('a008c00000a9NHOAA3', resList[0].Id_SubTodo_from_another_org__c, 'Wrong another Id');
    }

    private static List<SubTodo__c> fullListOfSubTodos(String sName){
        List<SubTodo__c> listS = new List<SubTodo__c>();
        SubTodo__c td = [SELECT Id, Name, isDone__c, Id_SubTodo_from_another_org__c FROM SubTodo__c WHERE Name =: sName];
        listS.add(td);
        return listS;
    }
}
