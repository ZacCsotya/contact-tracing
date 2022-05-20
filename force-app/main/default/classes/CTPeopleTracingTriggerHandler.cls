/**
 * @Class Name     : CTPeopleTracingTriggerHandler
 * @Class Purpose  : People Tracing trigger logic.
 * @Author         : Zachary Csotya
 * @Developed On   : 05/19/2022
 * @Last Modified  : 05/19/2022
**/
public with sharing class CTPeopleTracingTriggerHandler {
    
    /**
    * @description Before update logic.
    * @author Zachary Csotya | 05/19/2022 
    * @param List<People_Tracing__c> newRecords 
    **/
    public static void beforeUpdate(List<People_Tracing__c> newRecords) {
        List<People_Tracing__c> duplicates = CTPeopleTracingController.checkDuplicates(newRecords);
        
        for (People_Tracing__c trace : duplicates) {
            trace.addError('Duplicate record found. Person 1:'+trace.Person_1__c+' Person 2:'+trace.Person_2__c);
        }
    }
}
