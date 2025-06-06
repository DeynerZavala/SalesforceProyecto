public with sharing class GameTriggerRepository {
    public static void validateUniqueNamePerPlatform(List<Game__c> newGamesList) {
        if (newGamesList == null || newGamesList.isEmpty()) {
            return;
        }

        Set<String> nameSet = new Set<String>();
        Set<String> platformSet = new Set<String>();
        Map<String, Integer> keyCountMap = new Map<String, Integer>();
         Set<Id> newGameIds = new Set<Id>();
        for (Game__c g : newGamesList) {
            if (g.Name== null || g.Platform__c == null) continue;
            String key = g.Name.trim().toLowerCase() + '###' + g.Platform__c.trim().toLowerCase();
            if (keyCountMap.containsKey(key)) {
                keyCountMap.put(key, keyCountMap.get(key) + 1);
            } else {
                keyCountMap.put(key, 1);
            }
            nameSet.add(g.Name.trim());
            platformSet.add(g.Platform__c.trim());

            if(g.Id != null) {
                newGameIds.add(g.Id);
            }
        }

        if (nameSet.isEmpty() || platformSet.isEmpty()) {
            return;
        }
        List<Game__c> existingGames = [
            SELECT Id, Name, Platform__c 
            FROM Game__c 
            WHERE Name IN :nameSet
            AND Platform__c IN :platformSet
        ];

        Set<String> existingCombinations = new Set<String>();
            for (Game__c g : existingGames) {
                String key = g.Name.trim().toLowerCase() + '###' + g.Platform__c.trim().toLowerCase();
                existingCombinations.add(key);
        }

        Set<String> seen = new Set<String>();

        for (Game__c g : newGamesList) {
            String key = g.Name.trim().toLowerCase() + '###' + g.Platform__c.trim().toLowerCase();
            
            if (existingCombinations.contains(key)) {
                g.Name.addError('Ya existe un juego con ese nombre en la plataforma de "' + g.Platform__c+'"');
            } else if (keyCountMap.get(key) > 1) {
                if (!seen.contains(key)) {
                    seen.add(key);
                } else {
                    g.Name.addError('Ya existe un juego en la lista con ese nombre en la plataforma de "'+ g.Platform__c+'"');
                }
            }
        }
    }
}