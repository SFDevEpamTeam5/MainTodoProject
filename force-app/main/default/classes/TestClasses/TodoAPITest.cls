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
        Todo__c td = [SELECT Id, Name, Deadline__c, isDone__c, Id_Todo_from_another_org__c FROM Todo__c Where Id_Todo_from_another_org__c = 'a008c00000a9UHWAA2'];
        RestRequest req = new RestRequest();
        req.requestURI = BASE_URI + td.Id;
        req.httpMethod = 'GET';
        RestContext.request = req;

        Test.startTest();
        Todo__c resultTd = TodoAPI.doGet();
        Test.stopTest();

        System.assert(resultTd != null);
        System.assertEquals('Name 1', resultTd.Name);
    }
    @isTest static void getNullResultTest(){
        Id recordId = 'a008c00000a9UHWAB2';
        RestRequest req = new RestRequest();
        req.requestURI = BASE_URI + recordId;
        req.httpMethod = 'GET';
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

        RestRequest req = new RestRequest();
        req.requestURI = BASE_URI;
        req.httpMethod = 'POST';       
        Blob jsonListTodoString = Blob.valueOf(JSON.serialize(td));
        req.requestBody = jsonListTodoString;
        RestContext.request = req;

        Test.startTest();
        Map<String, String> resultAcc = TodoAPI.doPost();
        Test.stopTest();
        
        System.assertEquals(4, [SELECT COUNT() FROM Todo__c WHERE Name ='Test post' ], 'Wrong count of created todos');
    }

    @isTest static void deleteTest(){
        Map<Id, Todo__c> todosMap = new Map<Id, Todo__c>([SELECT Id, Name, Deadline__c, isDone__c, Id_Todo_from_another_org__c FROM Todo__c]);
        List<Id> td = new List<Id>(todosMap.keySet());
        RestRequest req = new RestRequest();
        req.requestURI = BASE_URI;
        req.httpMethod = 'DELETE';       
        Blob jsonListTodoString = Blob.valueOf(JSON.serialize(td));
        req.requestBody = jsonListTodoString;
        RestContext.request = req;

        Test.startTest();
        Map<String, String> resMap = TodoAPI.doDelete();
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Todo__c WHERE isDone__c = false], 'Wrong count of todos');
        System.assertEquals('deleted', resMap.get('a008c00000a9UHWAA3'), 'Wrong delete status');
        
    }
    @isTest static void deleteEmptyListTest(){
        List<Id> td = new List<Id>();
        RestRequest req = new RestRequest();
        req.requestURI = BASE_URI;
        req.httpMethod = 'DELETE';       
        Blob jsonListTodoString = Blob.valueOf(JSON.serialize(td));
        req.requestBody = jsonListTodoString;
        RestContext.request = req;

        Test.startTest();
        Map<String, String> resMap = TodoAPI.doDelete();
        Test.stopTest();

        System.assertEquals(null, resMap, 'Not null map');
        
    }

    
}
