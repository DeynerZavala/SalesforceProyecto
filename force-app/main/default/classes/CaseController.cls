public with sharing class CaseController {
    @AuraEnabled(cacheable=true)
    public static List<RecordTypeService.Option> getCaseRecordTypes() {
        return RecordTypeService.getRecordTypes('Case');
    }

    @AuraEnabled(cacheable=true)
    public static List<Case> getCaseByContact(
        String searchText,
        String priority,
        String status,
        String sortedBy,
        Integer offset,
        Integer limitRow,
        String sortDirection,
        String contactId,
        Boolean openedCase
    ) {
        List<String> conditions = new List<String>();
        String baseQuery = 'SELECT Id, Subject, Status, CreatedDate, ClosedDate, Priority,	SLA_Status__c, RecordType.Name FROM Case';

        if (String.isNotBlank(searchText)) {
            conditions.add('Subject LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'');
        }
        if (String.isNotBlank(priority)) {
            conditions.add('Priority = \'' + String.escapeSingleQuotes(priority) + '\'');
        }
        if (String.isNotBlank(status)) {
            conditions.add('Status = \'' + String.escapeSingleQuotes(status) + '\'');
        }
        if (String.isNotBlank(contactId)) {
            conditions.add('ContactId = \'' + String.escapeSingleQuotes(contactId) + '\'');
        }
        if (openedCase != null && openedCase) {
            conditions.add('ClosedDate = null');
        }
        if (!conditions.isEmpty()) {
            baseQuery += ' WHERE ' + String.join(conditions, ' AND ');
        }
        Set<String> allowedFields = new Set<String>{ 'Subject', 'Status', 'Priority', 'CreatedDate', 'ClosedDate' };
        Set<String> allowedDirections = new Set<String>{ 'ASC', 'DESC','asc','desc' };
        if (allowedFields.contains(sortedBy)) {
            String direction = allowedDirections.contains(sortDirection) ? sortDirection : 'ASC';
            baseQuery += ' ORDER BY ' + sortedBy + ' ' + direction;
        }

        baseQuery += ' LIMIT ' + ((limitRow != null) ? limitRow : 20);
        baseQuery += ' OFFSET ' + ((offset != null) ? offset : 0);

        return Database.query(baseQuery);
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getStatusPicklistValues() {
        List<Map<String,String>> options = new List<Map<String,String>>();
        Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
        for (Schema.PicklistEntry ple : fieldResult.getPicklistValues()) {
            Map<String,String> option = new Map<String,String>();
            option.put('label', ple.getLabel());
            option.put('value', ple.getValue());
            options.add(option);
        }
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getPriorityPicklistValues() {
        List<Map<String,String>> options = new List<Map<String,String>>();
        Schema.DescribeFieldResult priorityFieldDesc = Case.Priority.getDescribe();
        for(Schema.PicklistEntry ple : priorityFieldDesc.getPicklistValues()) {
            Map<String,String> option = new Map<String,String>();
            option.put('label', ple.getLabel());
            option.put('value', ple.getValue());
            options.add(option);
        }
        return options;
    }

}