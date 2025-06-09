public with sharing class ContactController {
    @AuraEnabled(cacheable=true)
    public static Id getContactIdForCurrentUser() {
        Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
        if (contactId == null) {
            throw new AuraHandledException('El usuario actual no tiene un contacto asociado.');
        }
        return contactId;
    }
}
