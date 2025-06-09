public with sharing class GameUserController {
    @AuraEnabled(cacheable=true)
    public static Id getGameUserIdForCurrentUser() {
        Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
        if (contactId == null) {
            throw new AuraHandledException('El usuario actual no tiene asociado un contacto.');
        }
        Game_User__c gameUser = [ SELECT Id FROM Game_User__c WHERE Contact__c= :contactId LIMIT 1];
        return gameUser.Id;
    }
}
