public with sharing class GameController {
    @AuraEnabled(cacheable=true)
    public static List<Game__c> getGames(
        String searchText,
        String platform,
        String genre,
        String sortedBy,
        Integer offset,
        Integer limitRow,
        String sortDirection
    ) {
        List<String> conditions = new List<String>();
        String baseQuery = 'SELECT Id, Name, Genre__c, Release_Date__c, Platform__c, Age_Rating__c FROM Game__c';

        if (String.isNotBlank(searchText)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'');
        }
        if (String.isNotBlank(platform)) {
            conditions.add('Platform__c = \'' + String.escapeSingleQuotes(platform) + '\'');
        }
        if (String.isNotBlank(genre)) {
            conditions.add('Genre__c = \'' + String.escapeSingleQuotes(genre) + '\'');
        }

        if (!conditions.isEmpty()) {
            baseQuery += ' WHERE ' + String.join(conditions, ' AND ');
        }

        Set<String> allowedDirections = new Set<String>{ 'ASC', 'DESC','asc','desc' };
        
        if (String.isNotBlank(sortedBy)) {
            String direction = allowedDirections.contains(sortDirection) ? sortDirection : 'ASC';
            baseQuery += ' ORDER BY ' + String.escapeSingleQuotes(sortedBy) + ' ' + direction;
        }

        limitRow = (limitRow != null) ? limitRow : 20;
        offset = (offset != null) ? offset : 0;

        baseQuery += ' LIMIT ' + limitRow + ' OFFSET ' + offset;

        return Database.query(baseQuery);
    }
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getGenrePicklistValues() {
        List<Map<String,String>> options = new List<Map<String,String>>();
        Schema.DescribeFieldResult fieldResult = Game__c.Genre__c.getDescribe();
        for (Schema.PicklistEntry ple : fieldResult.getPicklistValues()) {
            Map<String,String> option = new Map<String,String>();
            option.put('label', ple.getLabel());
            option.put('value', ple.getValue());
            options.add(option);
        }
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getPlatformPicklistValues() {
        List<Map<String,String>> options = new List<Map<String,String>>();
        Schema.DescribeFieldResult platformFieldDesc = Game__c.Platform__c.getDescribe();
        for(Schema.PicklistEntry ple : platformFieldDesc.getPicklistValues()) {
            Map<String,String> option = new Map<String,String>();
            option.put('label', ple.getLabel());
            option.put('value', ple.getValue());
            options.add(option);
        }
        return options;
    }

}
