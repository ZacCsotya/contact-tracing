public with sharing class CTUpdateLocationStatusBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {

        Date today = Date.today();
        Date fourteenDaysAgo = today - 14;

        List<String> status = new List<String> {'Red', 'Orange', 'Yellow'};

        return Database.getQueryLocator('SELECT Id, Status__c FROM Location__c WHERE Status_Update_Date__c = :fourteenDaysAgo Status__c IN :status');
    }

    public void execute(Database.BatchableContext BC, List<Location__c> scope) {
        for (Location__c l : scope) {
            l.Status__c = 'Green';
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC) {
    }

}