global class ScheduledTodoCategoriesUpdating implements Schedulable {
    global void execute(SchedulableContext sc) {
        ToDoCategoriesUpdaterBatch categoriesUpdaterBatch = new ToDoCategoriesUpdaterBatch();
        Database.executeBatch(categoriesUpdaterBatch);
    }
}
