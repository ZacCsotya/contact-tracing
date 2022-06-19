public with sharing class GameResultController {
    @AuraEnabled
    public static List<Word_Shuffle__c> getResults() {
        // get current user's Id
        String userId = UserInfo.getUserId();
        List<Word_Shuffle__c> results = [SELECT Id, Name, Result__c, Mode__c 
                                            FROM Word_Shuffle__c 
                                            WHERE CreatedById=:userId
                                            ORDER BY CreatedDate Desc];
        return results;
    }
}
