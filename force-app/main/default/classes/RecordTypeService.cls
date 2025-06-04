public with sharing class RecordTypeService {

    public static List<Option> getRecordTypes(String sObjectName) {
        List<Option> options = new List<Option>();

        for (RecordType rt : [
            SELECT Id, Name FROM RecordType
            WHERE SObjectType = :sObjectName AND IsActive = true
        ]) {
            options.add(new Option(rt.Id, rt.Name));
        }

        return options;
    }

    public class Option {
        @AuraEnabled public String value;
        @AuraEnabled public String label;

        public Option(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
}
