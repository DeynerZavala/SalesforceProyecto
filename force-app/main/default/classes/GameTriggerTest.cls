@isTest
public class GameTriggerTest {

    static final String EXISTING_NAME = 'Halo';
    static final String EXISTING_PLATFORM = 'Xbox';

    @testSetup
    static void setupData() {
        insert new Game__c(Name = EXISTING_NAME, Platform__c = EXISTING_PLATFORM);
    }

    @isTest
    static void testInsertUniqueGame() {
        Game__c game = new Game__c(Name = 'God of War', Platform__c = 'PlayStation');
        Test.startTest();
        insert game;
        Test.stopTest();
        System.assertNotEquals(null, game.Id);
        Game__c storedGame = [SELECT Name, Platform__c FROM Game__c WHERE Id = :game.Id];
        System.assertEquals('God of War', storedGame.Name);
        System.assertEquals('PlayStation', storedGame.Platform__c);
    }

    @isTest
    static void testInsertDuplicateInSameList() {
        Game__c game1 = new Game__c(Name = 'Valorant', Platform__c = 'PC');
        Game__c game2 = new Game__c(Name = 'Valorant', Platform__c = 'PC');
        Game__c game3 = new Game__c(Name = 'Valorant', Platform__c = 'XBOX');
        
        Boolean didThrow = false;
        try {
            insert new List<Game__c>{game1, game2, game3};
        } catch (DmlException e) {
            didThrow = true;
            System.assert(e.getMessage().contains('Ya existe un juego en la lista'));
        }
        System.assert(didThrow, 'Se esperaba una DmlException por duplicidad pero no se lanzó.');
    }


    @isTest
    static void testInsertDuplicateInDatabase() {
        Game__c game = new Game__c(Name = EXISTING_NAME, Platform__c = EXISTING_PLATFORM);
        Boolean didThrow = false;
        try {
            insert game;
        } catch (DmlException e) {
            didThrow = true;
            System.assert(e.getMessage().contains('Ya existe un juego'));
        }
        System.assert(didThrow, 'Se esperaba una excepción DmlException pero no ocurrió.');

        List<Game__c> uniqueGamePerPlatform = [SELECT Id FROM Game__c WHERE Name = :EXISTING_NAME AND Platform__c = :EXISTING_PLATFORM];
        System.assertEquals(1, uniqueGamePerPlatform.size());
        System.assertNotEquals(game.Id, uniqueGamePerPlatform[0].Id);
    }


    @isTest
    static void testUpdateToDuplicate() {
        Game__c game = new Game__c(Name = 'Apex', Platform__c = 'Switch');

        insert game;

        game.Name = EXISTING_NAME;
        game.Platform__c = EXISTING_PLATFORM;

        Boolean didThrow = false;
        try {
            update game;
        } catch (DmlException e) {
            didThrow = true;
            System.assert(e.getMessage().contains('Ya existe un juego con ese'));
        }
        System.assert(didThrow, 'Se esperaba una excepción DmlException pero no ocurrió.');
        List<Game__c> uniqueGamePerPlatform = [SELECT Id FROM Game__c WHERE Name = :EXISTING_NAME AND Platform__c = :EXISTING_PLATFORM];
        System.assertEquals(1, uniqueGamePerPlatform.size());
        System.assertNotEquals(game.Id, uniqueGamePerPlatform[0].Id);
    }

    @isTest
    static void testNullPlatform() {
        Game__c game1 = new Game__c(Name = 'God of War 1 La venganza', Platform__c = null);
        Game__c game2 = new Game__c(Name = 'God of War 2 Otra venganza Part I', Platform__c = null);
        Game__c game3 = new Game__c(Name = 'God of War 3 Otra venganza Part II', Platform__c = null);
        Test.startTest();
        insert new List<Game__c>{game1, game2, game3};
        Test.stopTest();

        System.assertNotEquals(null, game1.Id);
        System.assertNotEquals(null, game2.Id);
        System.assertNotEquals(null, game3.Id);
    }
    @isTest
    static void testValidateUniqueNamePerPlatformWithNullOrEmptyList() {
        Test.startTest();
        GameTriggerRepository.validateUniqueNamePerPlatform(null);
        GameTriggerRepository.validateUniqueNamePerPlatform(new List<Game__c>());
        Test.stopTest();
        System.assert(true);
    }
}