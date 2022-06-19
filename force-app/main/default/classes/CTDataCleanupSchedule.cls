public with sharing class CTDataCleanupSchedule implements Schedulable {

    public static final String CRON = '00 00 2 * * ?';

    public void execute(SchedulableContext SC) {
        CTPeopleTracingDataCleanupBatch ptBatch = new CTPeopleTracingDataCleanupBatch();
        Database.executeBatch(ptBatch, 1000);

        CTLocationTracingDataCleanupBatch ltBatch = new CTLocationTracingDataCleanupBatch();
        Database.executeBatch(ltBatch, 1000);
    }

}