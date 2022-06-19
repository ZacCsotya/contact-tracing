public with sharing class CTPeopleTracingDataCleanupBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Contact_Date__c FROM People_Tracing__c WHERE Contact_Date__c < LAST_N_DAYS:30');
    }

    public void execute(Database.BatchableContext BC, List<People_Tracing__c> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext BC) {
        system.debug('Batch is complete');
    }

}