global class sceduledDeleteTodos implements Schedulable{
    global void execute(SchedulableContext ctx) {
        DeletingOldTodoWithCMT deleteTodos = new DeletingOldTodoWithCMT();
        Id batch1Id = Database.executeBatch(deleteTodos);
    }
}
