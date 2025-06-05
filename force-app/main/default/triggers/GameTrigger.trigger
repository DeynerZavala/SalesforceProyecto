trigger GameTrigger on Game__c (before insert, before update) {
    if(Trigger.isBefore && Trigger.isUpdate){
        GameTriggerHandler.beforeUpdate(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isInsert){
        GameTriggerHandler.beforeInsert(Trigger.new);
    }
}