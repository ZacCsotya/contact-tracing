/**
 * @Class Name     : CTLocationTriggerHandler
 * @Class Purpose  : Location trigger logic.
 * @Author         : Zachary Csotya
 * @Developed On   : 05/19/2022
 * @Last Modified  : 05/19/2022
**/
public with sharing class CTLocationTriggerHandler {
    
    /**
    * @description : Before insert logic.
    * @author Zachary Csotya | 05/19/2022 
    * @param List<Location__c> newRecords 
    **/
    public static void beforeInsert(List<Location__c> newRecords) {
        for (Location__c location : newRecords) {
            location.Status__c = 'Green';
        }
    }

    /**
    * @description : Before update logic.
    * @author Zachary Csotya | 05/19/2022 
    * @param List<Location__c> newRecords 
    * @param Map<Id Location__c> oldRecordMap 
    **/
    public static void beforeUpdate(List<Location__c> newRecords, Map<Id,Location__c> oldRecordMap) {
        for (Location__c location : newRecords) {
            if(location.Status__c != oldRecordMap.get(location.Id).Status__c) {
                location.Status_Update_Date__c = Date.today();
            }
        }
    }

    /**
    * @description : After update logic.
    * @author Zachary Csotya | 05/19/2022 
    * @param List<Location__c> newRecords 
    * @param Map<Id Location__c> oldRecordMap 
    **/
    public static void afterUpdate(List<Location__c> newRecords, Map<Id, Location__c> oldRecordMap) {
        Set<Id> statusChange = new Set<Id>();
        for (Location__c location : newRecords) {
            if (location.Status__c == 'Red' && oldRecordMap.get(location.Id).Status__c != 'Red') {
                statusChange.add(location.Id);
            }
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByLocationId(statusChange);
        Set<Id> personIds = new Set<Id>();
        for (Location_Tracing__c trace : locationTraces) {
            personIds.add(trace.Person__c);
        }

        List<Person__c> peopleToUpdate = new List<Person__c>();
        for (Id pId : personIds) {
            peopleToUpdate.add(new Person__c(Id=pId, Health_Status__c='Yellow'));
        }

        if (peopleToUpdate.size() > 0) {
            update peopleToUpdate;
        }
    }
}
