public with sharing class ContactController {
    @AuraEnabled(cacheable=true)
    public static Id getContactIdForCurrentUser() {
        User currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return currentUser.ContactId;
    }
}
