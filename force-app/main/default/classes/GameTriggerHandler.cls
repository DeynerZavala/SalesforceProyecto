public with sharing class GameTriggerHandler {
    private static Boolean isBeforeInsertFlag = false;
    private static Boolean isBeforeUpdateFlag = false;

    public static void beforeInsert(List<Game__c> newGamesList){
        if(!isBeforeInsertFlag){
            isBeforeInsertFlag = true;
            GameTriggerRepository.validateUniqueNamePerPlatform(newGamesList);
        }
    }
    public static void beforeUpdate(List<Game__c> newGamesList){
        if(!isBeforeUpdateFlag){
            isBeforeUpdateFlag = true;
            GameTriggerRepository.validateUniqueNamePerPlatform(newGamesList);
        }
    }
}