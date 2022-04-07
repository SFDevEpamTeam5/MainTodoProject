// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

List<ToDo__c> todolist = new List<ToDo__c>();
for (Integer i = 0; i < 5; i++) {
    ToDo__c t = new ToDo__c();
    t.CreatedDate = Date.newInstance(2021, 10, 5);
    t.Name = 'test '+i;
    t.Deadline__c = Date.newInstance(2022, 5, 30);
    todolist.add(t);
}
insert todolist;
ToDoClearingBatch todoClearBatch = new ToDoClearingBatch();
Database.executeBatch(todoClearBatch);

System.debug(Date.today().addMonths((-1)*3));

Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.ToDo__c.fields.getMap();
for(Schema.SObjectField F : Schema.SObjectType.ToDo__c.fields.getMap().values()) {
    System.debug(F.getDescribe().getName());
}
List<ToDo__c> todolist = new List<ToDo__c>();
for (Integer i = 0;i<10;i++) {
    ToDo__c t = new Todo__c(Name = 'todo test '+i+1);
    t.Deadline__c = Date.today().addDays(i+1);
    todolist.add(t);
}
insert todolist;