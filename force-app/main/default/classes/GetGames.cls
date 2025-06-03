public with sharing class GetGames {
    @AuraEnabled(cacheable = true)
    public static List<Game__c> getGames(){
        return [SELECT Id, Name, Genre__c, Release_Date__c, Platform__c, Age_Rating__c FROM Game__c];
    }
}