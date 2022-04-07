@isTest
public class TodoAPITest {
    static final String BASE_URI = 'https://d8c000005xepseae-dev-ed.lightning.force.com/Todo/';
    static Date todaydate = Date.today();

    @TestSetup
    static void makeData(){
        Todo__c td1 = TestDataFactory.TODO.createDummyTodo('Name 1', todaydate, false, 'a008c00000a9UHWAA2', true);
        Todo__c td2 = TestDataFactory.TODO.createDummyTodo('Name 2', todaydate, false, 'a008c00000a9UHWAA3', true);
    }
    @isTest static void getTest(){
        List<Todo__c> listT = new List<Todo__c>();
        Blob jsonListTodoString = Blob.valueOf(JSON.serialize(listT));
        Todo__c td = [SELECT Id, Name, Deadline__c, isDone__c, Id_Todo_from_another_org__c FROM Todo__c Where Id_Todo_from_another_org__c = 'a008c00000a9UHWAA2'];
        RestRequest req = createRestRequest('GET', td.Id, jsonListTodoString);
        RestContext.request = req;

        Test.startTest();
        Todo__c resultTd = TodoAPI.doGet();
        Test.stopTest();

        System.assert(resultTd != null, 'Null result!');
        System.assertEquals('Name 1', resultTd.Name, 'Wrong name');
    }
    @isTest static void getNullResultTest(){
        Id recordId = 'a008c00000a9UHWAB2';
        RestRequest req = createRestRequest('GET', recordId, null);
        RestContext.request = req;

        Test.startTest();
        Todo__c resultTd = TodoAPI.doGet();
        Test.stopTest();

        System.assert(resultTd == null, 'Not null result');
    }

    @isTest static void postTest(){
        List<Todo__c> td = new List<Todo__c>();
        Todo__c td1 = TestDataFactory.TODO.createDummyTodo('Test post', todaydate, false, null, true);
        Todo__c td2 = TestDataFactory.TODO.createDummyTodo('Test post', todaydate, false, null, true);
        td.add(td1);
        td.add(td2);

        Blob jsonListTodoString = Blob.valueOf(JSON.serialize(td));
        RestRequest req = createRestRequest('POST', null, jsonListTodoString);
        RestContext.request = req;

        Test.startTest();
        Map<String, String> resultAcc = TodoAPI.doPost();
        Test.stopTest();
        
        System.assertEquals(4, [SELECT COUNT() FROM Todo__c WHERE Name ='Test post' ], 'Wrong count of created todos');
    }

    @isTest static void deleteTest(){
        Map<Id, Todo__c> todosMap = new Map<Id, Todo__c>([SELECT Id, Name, Deadline__c, isDone__c, Id_Todo_from_another_org__c FROM Todo__c]);
        List<Id> td = new List<Id>(todosMap.keySet());

        Blob jsonListTodoString = Blob.valueOf(JSON.serialize(td));
        RestRequest req = createRestRequest('DELETE', null, jsonListTodoString);
        RestContext.request = req;

        Test.startTest();
        Map<String, String> resMap = TodoAPI.doDelete();
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Todo__c WHERE isDone__c = false], 'Wrong count of todos');
        System.assertEquals('deleted', resMap.get('a008c00000a9UHWAA3'), 'Wrong delete status');
        
    }
    @isTest static void deleteEmptyListTest(){
        List<Id> td = new List<Id>();

        Blob jsonListTodoString = Blob.valueOf(JSON.serialize(td));
        RestRequest req = createRestRequest('DELETE', null, jsonListTodoString);
        RestContext.request = req;

        Test.startTest();
        Map<String, String> resMap = TodoAPI.doDelete();
        Test.stopTest();

        System.assertEquals(null, resMap, 'Not null map');   
    }
    @isTest static void patchTest(){
        List<Todo__c> tdList = new List<Todo__c>();
        Todo__c td = [SELECT Id, Name, Deadline__c, isDone__c, Id_Todo_from_another_org__c FROM Todo__c Where Id_Todo_from_another_org__c = 'a008c00000a9UHWAA2'];
        String tId = td.Id_Todo_from_another_org__c;
        td.Name = 'Patch name';
        td.Id_Todo_from_another_org__c = td.Id;
        td.Id = tId;
        tdList.add(td);
        Blob jsonListTodoString = Blob.valueOf(JSON.serialize(tdList));
        RestRequest req = createRestRequest('PATCH', null, jsonListTodoString);
        
        RestContext.request = req;

        Test.startTest();
        Map<String, String> resMap = TodoAPI.doPatch();
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Todo__c WHERE Id_Todo_from_another_org__c =: tId], 'Wrong count updated todos');
        System.assertEquals('updating succses', resMap.get(tId), 'Wrong saveresult msg');
    }

    @isTest static void patchNullResponseTest(){
        List<Todo__c> tdList = new List<Todo__c>();
        Blob jsonListTodoString = Blob.valueOf(JSON.serialize(tdList));
        RestRequest req = createRestRequest('PATCH', null, jsonListTodoString);
        
        RestContext.request = req;

        Test.startTest();
        Map<String, String> resMap = TodoAPI.doPatch();
        Test.stopTest();

        System.assert(resMap == null, 'Not Null result!');
    }


    @isTest static void putTest(){
        List<Todo__c> tdList = new List<Todo__c>();
        Todo__c td = [SELECT Id, Name, Deadline__c, isDone__c, Id_Todo_from_another_org__c FROM Todo__c Where Id_Todo_from_another_org__c = 'a008c00000a9UHWAA2'];
        String tId = td.Id_Todo_from_another_org__c;
        td.Name = 'Patch name';
        td.Id_Todo_from_another_org__c = td.Id;
        td.Id = tId;
        tdList.add(td);
        Blob jsonListTodoString = Blob.valueOf(JSON.serialize(tdList));
        RestRequest req = createRestRequest('PUT', null, jsonListTodoString);
        
        RestContext.request = req;

        Test.startTest();
        Map<String, String> resMap = TodoAPI.doPut();
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Todo__c WHERE Id_Todo_from_another_org__c =: tId], 'Wrong count updated todos');
        System.assertEquals(true, resMap.get(tId).contains('record created'), 'Wrong saveresult msg');
    }

    @isTest static void putNullResponseTest(){
        List<Todo__c> tdList = new List<Todo__c>();
        Blob jsonListTodoString = Blob.valueOf(JSON.serialize(tdList));
        RestRequest req = createRestRequest('PUT', null, jsonListTodoString);
        
        RestContext.request = req;

        Test.startTest();
        Map<String, String> resMap = TodoAPI.doPut();
        Test.stopTest();

        System.assert(resMap == null, 'Not Null result!');
    }

    @isTest static void createNewTodoTest(){
        Todo__c td = [SELECT Id, Name, Deadline__c, isDone__c, Id_Todo_from_another_org__c FROM Todo__c Where Id_Todo_from_another_org__c = 'a008c00000a9UHWAA2'];
        String Idt = td.id;
        td.id = td.Id_Todo_from_another_org__c;
        td.Id_Todo_from_another_org__c = Idt;
        Test.startTest();
        Todo__c resTodo = TodoAPI.createNewTodo(td);
        Todo__c td1 = [SELECT Id, Name, Deadline__c, isDone__c, Id_Todo_from_another_org__c FROM Todo__c Where Id_Todo_from_another_org__c = 'a008c00000a9UHWAA2'];
        Test.stopTest();
        System.assertEquals(td1.Name, resTodo.Name, 'Wrong todo name from another org');
        System.assertEquals(td1.Id_Todo_from_another_org__c, resTodo.Id_Todo_from_another_org__c, 'Wrong todo Id_Todo_from_another_org__c');
    }

    @isTest static void getListFromBodyTest(){
        List<Todo__c> listT = [SELECT Id, Name, Deadline__c, isDone__c, Id_Todo_from_another_org__c FROM Todo__c Where Id_Todo_from_another_org__c = 'a008c00000a9UHWAA2'];
        Blob jsonListTodoString = Blob.valueOf(JSON.serialize(listT));
        RestRequest req = createRestRequest('POST', null, jsonListTodoString);
        Test.startTest();
        List<Todo__c> resTodo = TodoAPI.getListFromBody(req);
        Test.stopTest();

        System.assertEquals(1, resTodo.size(), 'wrong list size');
        System.assertEquals('Name 1', resTodo[0].Name, 'Wrong name!');
    }

    @isTest static void getIdTest(){
        List<Todo__c> listT = new List<Todo__c>();
        Blob jsonListTodoString = Blob.valueOf(JSON.serialize(listT));
        RestRequest req = createRestRequest('GET', 'a008c00000a9UHWAA2', jsonListTodoString);
        Test.startTest();
        String resId = TodoAPI.getId(req);
        Test.stopTest();

        System.assertEquals('a008c00000a9UHWAA2', resId, 'Wron executed Id');
    }

    public static RestRequest createRestRequest(String methodName, String recordId, Blob reqBody){
        RestRequest req = new RestRequest();
        req.requestURI = BASE_URI + recordId;
        req.httpMethod = methodName;       
        req.requestBody = reqBody;
        return req;
    }

    
}
