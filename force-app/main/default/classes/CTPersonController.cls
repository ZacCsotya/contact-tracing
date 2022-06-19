/**
 * @Class Name:    : CTPersonController
 * @Class Purpose  : Handle logic surrounding a Person object.
 * @Author         : Zachary Csotya
 * @Developed On   : 04/25/2022
 * @Last Modified  : 06/05/2022
**/

public with sharing class CTPersonController {
    
    /**
    * @description Take in a mobile number and return a token Id
    * @author Zachary Csotya | 05/05/2022 
    * @param String mobile 
    * @return String 
    **/
    public static String getToken(String mobile) {
        Blob value = Blob.valueOf(mobile);
        Blob hash = Crypto.generateDigest('MD5', value);
        return EncodingUtil.base64Encode(hash);
    }

    /**
    * @description : Get 100 people with recent health changes
    * @author Zachary Csotya | 04/25/2022 
    * @return List<Person__c> 
    **/
    public static List<Person__c> getRecentHealthChanges() {
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
                      FROM Person__c
                      ORDER BY Status_Update_Date__c DESC LIMIT 100];
    }

    /**
    * @description : Search people by Name, Mobile, or Token
    * @author Zachary Csotya | 04/25/2022 
    * @param String searchTerm 
    * @return List<Person__c> 
    **/
    public static List<Person__c> searchPerson(String searchTerm) {
        searchTerm = searchTerm + '%';
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
                FROM Person__c
                WHERE Name LIKE :searchTerm 
                    OR Mobile__c LIKE :searchTerm 
                    OR Token__c LIKE :searchTerm
                ORDER BY Status_Update_Date__c DESC];
    }

    /**
    * @description : Search people by Id
    * @author Zachary Csotya | 04/25/2022 
    * @param String personId 
    * @return Person__c 
    **/
    public static Person__c getPersonById(String personId) {
        List<Person__c> person = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
                                  FROM Person__c
                                  WHERE Id=:personId];

        if(person != null && person.size() > 0) {
            return person[0];
        }
        return null;
    }

    /**
    * @description : Get count of people in each health status
    * @author Zachary Csotya | 05/05/2022 
    * @return Map<String, Integer> 
    **/
    public static Map<String, Integer> getHealthStatusCount() {
        
        AggregateResult[] healthStatusMap = [SELECT Health_Status__c, COUNT(Id) healthCount 
                                                FROM Person__c
                                                GROUP BY Health_Status__c];
        
        if(healthStatusMap != null && healthStatusMap.size() > 0) {
            Map<String, Integer> result = new Map<String, Integer>();
            for(AggregateResult ar : healthStatusMap) {
                String healthStatus = String.valueOf(ar.get('Health_Status__c'));
                Integer count = Integer.valueOf(ar.get('healthCount'));
                result.put(healthStatus, count);
            }
            return result;
        }
        return null;
    }

    /**
    * @description : Get cohabitant person records.
    * @author Zachary Csotya | 05/19/2022 
    * @param Set<Id> personIds 
    * @param Set<Id> alreadyProcessed 
    * @return Set<Id> 
    **/
    public static Set<Id> getCohabitants(Set<Id> personIds, Set<Id> alreadyProcessed) {
        List<String> healthStatuses = new List<String> {'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c
                                                FROM People_Tracing__c 
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                                AND Contact_Type__c = 'Cohabitant'
                                                AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)];
        Set<Id> cohabitants = new Set<Id>();
        for(People_Tracing__c pt : peopleTraces) {
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                cohabitants.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if(!alreadyProcessed.contains(pt.Person_2__c)){
                cohabitants.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return cohabitants;
    }

    /**
    * @description Get neighbour person records.
    * @author Zachary Csotya | 05/19/2022 
    * @param Set<Id> personIds 
    * @param Set<Id> alreadyProcessed 
    * @return Set<Id> 
    **/
    public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessed) {
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c
                                                FROM People_Tracing__c 
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                                AND Contact_Type__c = 'Neighbour'
                                                AND (Person_1__r.Health_Status__c='Green' OR Person_2__r.Health_Status__c='Green')];
        Set<Id> neighbour = new Set<Id>();
        for(People_Tracing__c pt : peopleTraces) {
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                neighbour.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if(!alreadyProcessed.contains(pt.Person_2__c)){
                neighbour.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return neighbour;
    }

    /**
    * @description Get primary contact person records.
    * @author Zachary Csotya | 05/19/2022 
    * @param Set<Id> personIds 
    * @param Set<Id> alreadyProcessed 
    * @return Set<Id> 
    **/
    public static Set<Id> getPrimaryContacts(Set<Id> personIds, Set<Id> alreadyProcessed) {
        List<String> healthStatuses = new List<String> {'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c
                                                FROM People_Tracing__c 
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                                AND Contact_Type__c = 'Other'
                                                AND Contact_Date__c = LAST_N_DAYS:10
                                                AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)];
        Set<Id> primaryContacts = new Set<Id>();
        for(People_Tracing__c pt : peopleTraces) {
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                primaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if(!alreadyProcessed.contains(pt.Person_2__c)){
                primaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return primaryContacts;
    }

    /**
    * @description : Get secondary contact person records.
    * @author Zachary Csotya | 05/19/2022 
    * @param Set<Id> primaryContactIds 
    * @param Set<Id> alreadyProcessed 
    * @return Set<Id> 
    **/
    public static Set<Id> getSecondaryContacts(Set<Id> primaryContactIds, Set<Id> alreadyProcessed) {
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c
                                                FROM People_Tracing__c 
                                                WHERE (Person_1__c IN :primaryContactIds OR Person_2__c IN :primaryContactIds)
                                                AND Contact_Type__c = 'Other'
                                                AND Contact_Date__c = LAST_N_DAYS:10
                                                AND (Person_1__r.Health_Status__c='Green' OR Person_2__r.Health_Status__c='Green')];
        Set<Id> secondaryContacts = new Set<Id>();
        for(People_Tracing__c pt : peopleTraces) {
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                secondaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if(!alreadyProcessed.contains(pt.Person_2__c)){
                secondaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return secondaryContacts;
    }
}
