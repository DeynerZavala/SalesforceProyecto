public with sharing class CaseTriggerHandler {
    private static Boolean isBeforeInsertFlag = false;
    private static Boolean isBeforeUpdateFlag = false;

    public static void beforeInsert(List<Case> newCaseList){
        if(!isBeforeInsertFlag){
            isBeforeInsertFlag = true;
            CaseTriggerRepository.validateUniqueSubjectPerUser(newCaseList);
        }
    }
    public static void beforeUpdate(List<Case> newCaseList){
        if(!isBeforeUpdateFlag){
            isBeforeUpdateFlag = true;
            CaseTriggerRepository.validateUniqueSubjectPerUser(newCaseList);
        }
    }
    
}