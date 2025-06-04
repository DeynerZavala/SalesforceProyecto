public with sharing class CaseController {
    @AuraEnabled(cacheable=true)
    public static List<RecordTypeService.Option> getCaseRecordTypes() {
        return RecordTypeService.getRecordTypes('Case');
    }
}