global class ScheduledDelitingOldTodo implements Schedulable {
    global void execute(SchedulableContext sc) {
        ToDoClearingBatch todoClearBatch = new ToDoClearingBatch();
        Database.executeBatch(todoClearBatch);
    }
}
