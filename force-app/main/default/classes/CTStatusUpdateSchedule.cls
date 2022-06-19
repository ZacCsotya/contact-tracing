public with sharing class CTStatusUpdateSchedule implements Schedulable {

    public void execute(SchedulableContext SC) {
        CTUpdatePersonStatusBatch updatePersonStatusBatch = new CTUpdatePersonStatusBatch();
        Database.executeBatch(updatePersonStatusBatch, 1000);

        CTUpdateLocationStatusBatch updateLocationStatusBatch = new CTUpdateLocationStatusBatch();
        Database.executeBatch(updateLocationStatusBatch, 1000);
    }

}