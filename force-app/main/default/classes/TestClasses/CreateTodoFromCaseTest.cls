@isTest
public class CreateTodoFromCaseTest {
    @isTest static void createTodoTest(){  
        Case cs = new Case(Subject = 'New case');
        insert cs;
        List<Case> caseL = new List<Case>();

        Test.startTest();
        CreateTodoFromCase.createTodo(caseL);
        Test.stopTest();

        List<Todo__c> tdL= [SELECT Id, Name FROM Todo__c];

        System.assertEquals(1, tdL.size(), 'Wrong Todos count');
        System.assertEquals('New case', tdL[0].Name, 'Wrong todo name');
    }

    @isTest static void createTodoWithDataTest(){
        Date myDate = Date.valueOf('2022-04-12');
        Case cs = new Case(Subject = 'New case 2', Description = '2022-04-12');
        insert cs;
        List<Case> caseL = new List<Case>();

        Test.startTest();
        CreateTodoFromCase.createTodo(caseL);
        Test.stopTest();

        List<Todo__c> tdL= [SELECT Id, Name, Deadline__c FROM Todo__c];

        System.assertEquals(1, tdL.size(), 'Wrong Todos count');
        System.assertEquals('New case 2', tdL[0].Name, 'Wrong todo name');
        System.assertEquals(myDate, tdL[0].Deadline__c, 'Wrong date of deadline');
    }
}
