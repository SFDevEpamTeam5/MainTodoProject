trigger TodoFromNewCase on Case (after insert) {

    CreateTodoFromCase.createTodo(Trigger.new);
}