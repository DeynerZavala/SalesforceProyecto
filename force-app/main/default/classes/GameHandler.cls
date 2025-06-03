public with sharing class GameHandler {
    public void validateUniqueNamePerPlataform(List<Game__c> newGameslist){
        List<Game__c> insertGameList = new List<Game__c>();
        List<Game__c> errorGameslist = new List<Game__c>();

        if (newGamesList == null || newGamesList.isEmpty()) {
            return;
        }

        Set<String> combinacionesNuevas = new Set<String>();

        for(Game__c g : newGamesList){
                combinacionesNuevas.add(g.Name + g.Platform__c);
            }
        
        Set<String> nameSet = new Set<String>();
        Set<String> platformSet = new Set<String>();
        for (Game__c g : newGamesList) {
            nameSet.add(g.Name);
            platformSet.add(g.Platform__c);
        }

        List<Game__c> juegosExistentes = [SELECT Id, Name, Platform__c FROM Game__c WHERE Name IN :nameSet AND Platform__c IN :platformSet];
        
        Set<String> combinacionesExistentes = new Set<String>();
        for(Game__c g : juegosExistentes){
                combinacionesExistentes.add(g.Name + g.Platform__c);
            }

        for(Game__c g : newGamesList){
            String key = g.Name + g.Platform__c;
            if(!combinacionesExistentes.contains(key) && !combinacionesNuevas.contains(key)){
                insertGameList.add(g);
                combinacionesNuevas.add(key);
            } else {
                errorGameslist.add(g);
                System.debug('El juego con nombre "' + g.Name + '" ya existe en la plataforma "' + g.Platform__c + '".');
            }
        }
        
    }        
}