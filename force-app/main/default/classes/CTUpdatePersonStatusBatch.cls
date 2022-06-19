public with sharing class CTUpdatePersonStatusBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        Date today = Date.today();
        Date fourteenDaysAgo = today - 14;

        List<String> healthStatus = new List<String> {'Red', 'Orange', 'Yellow'};

        return Database.getQueryLocator('SELECT Id, Health_Status__c FROM Person__c WHERE Status_Update_Date__c = :fourteenDaysAgo Health_Status__c IN :healthStatus');
    }

    public void execute(Database.BatchableContext BC, List<Person__c> scope) {
        for (Person__c p : scope) {
            p.Health_Status__c = 'Green';
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC) {
    }

}