/**
 * @Class Name     : CTLocationTracingController
 * @Class Purpose  : 
 * @Author         : Zachary Csotya
 * @Developed On   : 04/25/2022
 * @Last Modified  : 05/19/2022
**/
public with sharing class CTLocationTracingController {
   
    /**
    * @description : Get all visitors to a location.
    * @author Zachary Csotya | 04/25/2022 
    * @param String locationId 
    * @return List<Location_Tracing__c> 
    **/
    public static List<Location_Tracing__c> getVisitors(String locationId) {
        return [SELECT Id, Person__c, Location__c, Visit_Date__c 
               FROM Location_Tracing__c
               WHERE Location__c=:locationId
               ORDER BY Visit_Date__c DESC];
    }

    /**
    * @description Get location tracings by person.
    * @author Zachary Csotya | 04/25/2022 
    * @param Set<Id> personIds 
    * @return List<Location_Tracing__c> 
    **/
    public static List<Location_Tracing__c> getLocationsByPersons(Set<Id> personIds) {
        return [SELECT Id, Person__c, Location__c, Visit_Date__c 
                FROM Location_Tracing__c
                WHERE Person__c IN :personIds AND Visit_Date__c=LAST_N_Days:10];
    }

    /**
    * @description : Get location tracings by location.
    * @author Zachary Csotya | 04/25/2022 
    * @param Set<Id> locationId 
    * @return List<Location_Tracing__c> 
    **/
    public static List<Location_Tracing__c> getLocationsByLocationId(Set<Id> locationId) {
        return [SELECT Id, Person__c, Location__c, Visit_Date__c 
                FROM Location_Tracing__c
                WHERE Location__c IN :locationId AND Visit_Date__c=LAST_N_Days:10 AND Person__r.Health_Status__c='Green'];
    }

    /**
    * @description : Check for duplicate location tracing records.
    * @author Zachary Csotya | 05/19/2022 
    * @param List<Location_Tracing__c> locationTraces 
    * @return List<Location_Tracing__c> 
    **/
    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> locationTraces) {
        Set<Id> personIds = new Set<Id>();
        Set<Id> locationIds = new Set<Id>();

        for (Location_Tracing__c trace : locationTraces) {
            personIds.add(trace.Person__c);
            locationIds.add(trace.Location__c);
        }

        Map<Id, Set<Id>> mapOfDupRecords = new Map<Id, Set<Id>>();
        List<Location_Tracing__c> dupRecords = new List<Location_Tracing__c>();

        List<Location_Tracing__c> existingRecords = [SELECT Id, Person__c, Location__c, Visit_Date__c 
                                             FROM Location_Tracing__c
                                             WHERE Location__c IN :locationIds AND Person__c IN :personIds];

        if(existingRecords != null && existingRecords.size() > 0) {
            for(Location_Tracing__c dup : existingRecords) {
                    if(!mapOfDupRecords.containsKey(dup.Location__c)){
                        mapOfDupRecords.put(dup.Location__c, new Set<Id>());
                    }
                    mapOfDupRecords.get(dup.Location__c).add(dup.Person__c);
            }
        
            for (Location_Tracing__c trace : locationTraces) {
                if(mapOfDupRecords.containsKey(trace.Location__c) 
                    && mapOfDupRecords.get(trace.Location__c).contains(trace.Person__c)) {
                        dupRecords.add(trace);
                }
            }
        }

        return dupRecords;
    }
}
