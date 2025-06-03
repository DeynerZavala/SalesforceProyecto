trigger GameUserTrigger on Game__c (before insert, before update) {
    if(Trigger.isBefore || Trigger.isUpdate){
        GameTriggerHandler.beforeInsert(Trigger.new);
    }
}