/**
 * @Class Name     : CTPeopleTracingController
 * @Class Purpose  : Handle logic for the People Tracing Object.
 * @Author         : Zachary Csotya
 * @Developed On   : 05/19/2022
 * @Last Modified  : 05/19/2022
**/
public with sharing class CTPeopleTracingController {
    
    /**
    * @description : Get people traces by a persons record Id.
    * @author Zachary Csotya | 05/19/2022 
    * @param String recordId 
    * @return List<People_Tracing__c> 
    **/
    public static List<People_Tracing__c> getTraces(String recordId) {
        return [SELECT Id, Name, Contact_Date__c, Contact_Type__c, Person_1__c, Person_1__r.Health_Status__c, Person_1__r.Token__c, Person_2__c, Person_2__r.Health_Status__c, Person_2__r.Token__c
                FROM People_Tracing__c
                WHERE Person_1__c=:recordId OR Person_2__c=:recordId
                ORDER BY Contact_Date__c DESC];
    }

    /**
    * @description Check for duplicate people tracing records.
    * @author Zachary Csotya | 05/19/2022 
    * @param List<People_Tracing> peopleTraces 
    * @return List<People_Tracing__c> 
    **/
    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing> peopleTraces) {
        Set<Id> peopleIds = new Set<Id>();
        for(People_Tmracing__c traces : peopleTraces) {
            peopleIds.add(traces.Person_1__c);
            peopleIds.add(traces.Person_2__c);
        }

        Map<Id,Set<Id>> mapOfDupRecords = new Map<Id,Set<Id>>();
        List<People_Tracing__c> dupRecords = new List<People_Tracing__c>();

        List<People_Tracing> existingRecords = [SELECT
                                                    Id,
                                                    Name,
                                                    Contact_Date__c,
                                                    Contact_Type__c,
                                                    Person_1__c,
                                                    Person_2__c
                                                FROM
                                                    People_Tracing__c
                                                WHERE
                                                    Person_1__c IN :peopleIds OR Person_2__c IN :peopleIds];

        if(existingRecords != null && existingRecords.size() > 0) {
            for(People_Tracing__c dup : existingRecords) {
                // Map for Person 1
                if(!mapOfDupRecords.containsKey(dup.Person_1__c)) {
                    mapOfDupRecords.put(dup.Person_1__c, new Set<Id>());
                }
                mapOfDupRecords.get(dup.Person_1__c).add(Person_2__c);

                // Map for Person 2
                if(!mapOfDupRecords.containsKey(dup.Person_2__c)) {
                    mapOfDupRecords.put(dup.Person_2__c, new Set<Id>());
                }
                mapOfDupRecords.get(dup.Person_2__c).add(Person_1__c);
            }

            for(People_Tracing__c trace : peopleTraces) {
                if(
                    (mapOfDupRecords.contains(trace.Person_1__c) && mapOfDupRecords.get(trace.Person_1__c).contains(Person_2__c)) 
                    ||
                    (mapOfDupRecords.contains(trace.Person_2__c) && mapOfDupRecords.get(trace.Person_2__c).contains(Person_1x_c))
                ) {
                    dupRecords.add(trace);
                }
            }
        }
        return dupRecords;
    }
}
