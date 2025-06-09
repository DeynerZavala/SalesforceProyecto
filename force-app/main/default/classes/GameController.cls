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
        Set<String> allowedFields = new Set<String>{ 'Ranking__c', 'Game__r.Age_Rating__c', 'Game__r.Release_Date__c'};
        if (allowedFields.contains(sortedBy)) {
            String direction = allowedDirections.contains(sortDirection) ? sortDirection : 'ASC';
            baseQuery += ' ORDER BY ' + String.escapeSingleQuotes(sortedBy) + ' ' + direction;
        }

        limitRow = (limitRow != null) ? limitRow : 20;
        offset = (offset != null) ? offset : 0;

        baseQuery += ' LIMIT ' + limitRow + ' OFFSET ' + offset;

        return Database.query(baseQuery);
    }

    
    @AuraEnabled(cacheable=true)
    public static List<GameUserGameWrapper> getUserGameRelations(
        String searchText,
        String platform,
        String genre,
        String sortedBy,
        Integer offset,
        Integer limitRow,
        String sortDirection
    ) {
        List<GameUserGameWrapper> result = new List<GameUserGameWrapper>();

        Id gameUserId;
        try {
            gameUserId = GameUserController.getGameUserIdForCurrentUser();
        } catch (Exception e) {
            return result;
        }

        List<String> conditions = new List<String>{
            'Game_User__c = \'' + gameUserId + '\''
        };

        if (String.isNotBlank(searchText)) {
            conditions.add('Game__r.Name LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'');
        }
        if (String.isNotBlank(platform)) {
            conditions.add('Game__r.Platform__c = \'' + String.escapeSingleQuotes(platform) + '\'');
        }
        if (String.isNotBlank(genre)) {
            conditions.add('Game__r.Genre__c = \'' + String.escapeSingleQuotes(genre) + '\'');
        }

        String baseQuery = 'SELECT Id, Game__c, Game__r.Name, Game__r.Platform__c, Game__r.Genre__c, ' +
                        'Game__r.Release_Date__c, Game__r.Age_Rating__c, ' +
                        'Game_User__c, Game_User__r.Name, Ranking__c ' +
                        'FROM Game_User_Relation_With_Game__c';

        if (!conditions.isEmpty()) {
            baseQuery += ' WHERE ' + String.join(conditions, ' AND ');
        }
        Set<String> allowedFields = new Set<String>{ 'Ranking__c', 'Game__r.Age_Rating__c', 'Game__r.Release_Date__c'};
        Set<String> allowedDirections = new Set<String>{ 'ASC', 'DESC','asc','desc' };
        if (allowedFields.contains(sortedBy)) {
            String direction = allowedDirections.contains(sortDirection) ? sortDirection : 'ASC';
            baseQuery += ' ORDER BY ' + String.escapeSingleQuotes(sortedBy) + ' ' + direction;
        }

        limitRow = (limitRow != null) ? limitRow : 20;
        offset = (offset != null) ? offset : 0;
        baseQuery += ' LIMIT ' + limitRow + ' OFFSET ' + offset;

        List<Game_User_Relation_With_Game__c> rawResults = Database.query(baseQuery);

        for (Game_User_Relation_With_Game__c relation : rawResults) {
            GameUserGameWrapper wrapper = new GameUserGameWrapper();
            wrapper.relationId = relation.Id;
            wrapper.gameId = relation.Game__c;
            wrapper.gameName = relation.Game__r?.Name;
            wrapper.platform = relation.Game__r?.Platform__c;
            wrapper.genre = relation.Game__r?.Genre__c;
            wrapper.releaseDate = relation.Game__r?.Release_Date__c;
            wrapper.ageRating = relation.Game__r?.Age_Rating__c;
            wrapper.gameUserId = relation.Game_User__c;
            wrapper.gameUserName = relation.Game_User__r?.Name;
            wrapper.ranking = (relation.Ranking__c != null) ? Integer.valueOf(relation.Ranking__c) : null;
            result.add(wrapper);
        }

        return result;
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
