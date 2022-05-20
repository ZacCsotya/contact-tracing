/**
 * @Class Name     : CTLocationTracingTriggerHandler
 * @Class Purpose  : Handle the trigger logic for the Location Tracing Object.
 * @Author         : Zachary Csotya
 * @Developed On   : 05/19/2022
 * @Last Modified  : 05/19/2022
**/
public with sharing class CTLocationTracingTriggerHandler {

    /**
    * @description : Before insert trigger logic.
    * @author Zachary Csotya | 05/19/2022 
    * @param List<Location_Tracing__c> newRecords 
    **/
    public static void beforeInsert(List<Location_Tracing__c> newRecords) {
        List<Location_Tracing__c> duplicates = CTLocationTracingController.checkDuplicates(newRecords);

        for (Location_Tracing__c trace : duplicates) {
            trace.addError('Duplicate record found. Location Id:'+trace.Location__c+' Person Id:'+trace.Person__c);
        }
    }
}
