public with sharing class GameUserGameWrapper {
    @AuraEnabled public Id relationId;
    @AuraEnabled public Id gameId;
    @AuraEnabled public String gameName;
    @AuraEnabled public String platform;
    @AuraEnabled public String genre;
    @AuraEnabled public Date releaseDate;
    @AuraEnabled public String ageRating;
    @AuraEnabled public Id gameUserId;
    @AuraEnabled public String gameUserName;
    @AuraEnabled public Integer ranking;
}