@isTest
public class TestDataFactory {

    public static TestTodoFactory TODO = new TestTodoFactory();
    public static TestSubTodoFactory SUBTODO = new TestSubTodoFactory();

    public class TestTodoFactory {
        public Todo__c createDummyTodo(String name, Date deadline, Boolean isdone, Id anotherOrgId, Boolean needInsert){
            Todo__c todo = new Todo__c(Name = name, Deadline__c = deadline, isDone__c = isdone, Id_Todo_from_another_org__c = anotherOrgId, Create_for_test__c = true);
            if(needInsert) insert todo;
            return todo;
        }

        public List<Todo__c> createDummyListOfTodos(Integer count, String name, Date deadline, Boolean isdone, Id anotherOrgId, Boolean needInsert){
            List<Todo__c> todosList = new List<Todo__c>();
            for(Integer i = 0; i < count; i++){                
                todosList.add(createDummyTodo(name + ' ' + String.valueOf(i), deadline, isdone, anotherOrgId, needInsert));
            }
            if(needInsert) insert todosList;
            return todosList;
        }
    }

    public class TestSubTodoFactory {
        public SubTodo__c createDummySubTodo(String name, Boolean isdone, Id anotherOrgId, Id todos, Boolean needInsert){
            SubTodo__c stodo = new SubTodo__c(Name = name, isDone__c = isdone, Id_SubTodo_from_another_org__c = anotherOrgId, Todo__c = todos);
            if(needInsert) insert stodo;
            return stodo;
        }

        public List<SubTodo__c> createDummyListOfSubTodos(Integer count, String name, Boolean isdone, Id anotherOrgId, Id todos, Boolean needInsert){
            List<SubTodo__c> stodosList = new List<SubTodo__c>();
            for(Integer i = 0; i < count; i++){                
                stodosList.add(createDummySubTodo(name + ' ' + String.valueOf(i), isdone, anotherOrgId, todos, needInsert));
            }
            if(needInsert) insert stodosList;
            return stodosList;
        }
    }
}