trigger GameUserTrigger on SOBJECT (before insert, before update) {
    if(Trigger.isBefore && Trigger.isUpdate){
        GameHandler.validatePercentQuantity(Trigger.new);
    }
}