/**
 * @Class Name     : CTLocationController
 * @Class Purpose  : Handles logic surrounding the Location Object.
 * @Author         : Zachary Csotya
 * @Developed On   : 04/25/2022
 * @Last Modified  : 05/31/2022
**/
public with sharing class CTLocationController {
    
    /**
    * @description : Get 100 locations with recent status changes
    * @author Zachary Csotya | 04/25/2022 
    * @return List<Location__c> 
    **/
    public static List<Location__c> getRecentStatusChanges() {
        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                FROM Location__c
                ORDER BY Status_Update_Date__c DESC LIMIT 100];
    }

    /**
    * @description : Search locations by Name, Pin Code, or Address
    * @author Zachary Csotya | 04/25/2022 
    * @param String searchTerm 
    * @return List<Location__c> 
    **/
    public static List<Location__c> searchLocations(String searchTerm) {
        searchTerm = searchTerm + '%';

        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                FROM Location__c
                WHERE Name LIKE :searchTerm 
                    OR PinCode__c LIKE :searchTerm
                    OR Address__c LIKE :searchTerm 
                ORDER BY Status_Update_Date__c];
    }

    /**
    * @description : Search locations by Id
    * @author Zachary Csotya | 04/25/2022 
    * @param String locationId 
    * @return Location__c 
    **/
    public static Location__c getLocationById(String locationId) {
        List<Location__c> locations = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                                       FROM Location__c
                                       WHERE Id=:locationId];

        if(locations != null && locations.size() > 0) {
            return locations[0];
        }
        return null;
    }

    /**
    * @description : Get count of locations in each status.
    * @author Zachary Csotya | 05/05/2022 
    * @return Map<String, Integer> 
    **/
    public static Map<String,Integer> getStatusCount() {
        Map<String, Integer> statusMap = new Map<String, Integer>();
        for(AggregateResult ar : [SELECT Status__c, COUNT(Id) statusCount
                                  FROM Location__c
                                  GROUP BY Status__c]) {
            String status = String.valueOf(ar.get('Status__c'));
            Integer count = Integer.valueOf(ar.get('statusCount'));
            statusMap.put(status, count);
        }
        return statusMap;
    }

    /**
    * @description : Update the red score for a list of locations.
    * @author Zachary Csotya | 05/19/2022 
    * @param Set<Id> locationIds 
    **/
    public static void updateRedScore(Set<Id> locationIds) {
        List<Location__c> locationToUpdate = new List<Location__c>();
        AggregateResult[] redPeoplePerLocation = [SELECT Location__c, COUNT(Id) total FROM Location_Tracing__c
            WHERE Person__r.Health_Status__c = 'Red'
            AND Visit_Date__c = LAST_N_DAYS:10
            AND Location__c IN :locationIds
            GROUP BY Location__c];
        for (AggregateResult ar : redPeoplePerLocation) {
            String locationID = String.valueOf(ar.get('Location__c'));
            Integer redScore = Integer.valueOf(ar.get('total'));
            String status = getStatus(redScore);
            locationToUpdate.add(new Location__c(Id=locationID, Red_Score__c=redScore, Status__c=status));
        }

        if (locationToUpdate != null && locationToUpdate.size() > 0) {
            update locationToUpdate;
        }
    }

    /**
    * @description Get the status for a red score.
    * @author Zachary Csotya | 05/19/2022 
    * @param Integer redScore 
    * @return String 
    **/
    public static String getStatus(Integer redScore) {
        if (redScore == 0) {
            return 'Green';
        } else if (redScore <= 5) {
            return 'Yellow';
        } else if (redScore <= 10) {
            return 'Orange';
        } else {
            return 'Red';
        }
    }

    public static Map<String, Integer> getHealthStatusCount() {
        AggregateResult[] healthCountMap = [SELECT Status__c, Count(Id) total
                                            FROM Location__c 
                                            GROUP BY Status__c];

        if(healthCountMap != null && healthCountMap.size() > 0) {
            Map<String, Integer> result = new Map<String, Integer>();
            for (AggregateResult ar : healthCountMap) {
                result.put(String.valueOf(ar.get('Status__c')), Integer.valueOf(ar.get('total')));
            }
            return result;
        }
        return null;
    }
}