/**
 * @Class Name     : CTPersonTriggerHandler
 * @Class Purpose  : Person trigger logic.
 * @Author         : Zachary Csotya
 * @Developed On   : 05/19/2022
 * @Last Modified  : 05/19/2022
**/
public with sharing class CTPersonTriggerHandler {
    
    /**
    * @description : Before insert logic.
    * @author Zachary Csotya | 05/19/2022 
    * @param List<Person__c> newRecords 
    **/
    public static void beforeInsert(List<Person__c> newRecords) {
        for(Person__c person : newRecords) {
            person.Health_Status__c = 'Green';
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
        }
    }

    /**
    * @description Before update logic.
    * @author Zachary Csotya | 05/19/2022 
    * @param List<Person__c> newRecords 
    * @param Map<Id Person__c> oldRecordsMap 
    **/
    public static void beforeUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecordsMap) {
        for(Person__c person : newRecords) {
            if(person.Health_Status__c != oldRecordsMap.get(person.Id).Health_Status__c) {
                person.Status_Update_Date__c = Date.today();  
            }
        }
    }

    /**
    * @description After update logic.
    * @author Zachary Csotya | 05/19/2022 
    * @param List<Person__c> newRecords 
    * @param Map<Id Person__c> oldRecordsMap 
    **/
    public static void afterUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecordsMap) {
        Set<Id> statusChange = new Set<Id>();
        Set<Id> resStatus = new Set<Id>();
        for(Person__c person : newRecords) {
            if(person.Health_Status__c != oldRecordsMap.get(person.Id).Health_Status__c) {
                statusChange.add(person.Id);
            }
            if(person.Health_Status__c == 'Red' && oldRecordsMap.get(person.Id).Health_Status__c != 'Red') {
                redStatus.add(person.Id);
            }
        }

        Set<Id> alreadyProcessed = new Set<Id>();
        alreadyProcessed.addAll(redStatus);

        Set<Id> orangeStatus = new Set<Id>();
        Set<Id> yellowStatus = new Set<Id>();

        List<Person__c> personToUpdate = new List<Person__c>();

        orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, alreadyProcessed));
        Set<Id> primaryContacts = CTPersonController.getPrimaryContacts(redStatus, alreadyProcessed);
        orangeStatus.addAll(primaryContacts);
        yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, alreadyProcessed));
        yellowStatus.addAll(CTPersonController.getSecondaryContacts(primaryContacts, alreadyProcessed));

        for (Id pId : orangeStatus) {
            personToUpdate.add(new Person__c(Id=pId, Health_Status__c = 'Orange'));
        }

        for (Id pId : yellowStatus) {
            personToUpdate.add(new Person__c(Id=pId, Health_Status__c = 'Yellow'));
        }

        if(personToUpdate.size() > 0) {
            update personToUpdate;
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByPersons(statusChange);
        if(locationTraces.size() > 0 && locationTraces != null) {
            Set<Id> locationIds = new Set<Id>();
            for(Location_Tracing__c trace : locationTraces) {
                locationIds.add(trace.Location__c);
            }
            CTLocationController.updateRedScore(locationIds);  
        }
    }
}
