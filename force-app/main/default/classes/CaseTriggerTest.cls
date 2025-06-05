@isTest
public class CaseTriggerTest {
    static final String EXISTING_SUBJECT = 'Problema técnico';
    
    @testSetup
    static void setupData() {
        Contact con = new Contact(FirstName = 'Test', LastName = 'User');
        insert con;
        Case existingCase = new Case(Subject = 'Problema técnico', ContactId = con.Id, Status = 'New');
        insert existingCase;
    }

    @isTest
    static void testInsertUniqueCases() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Case case1 = new Case(Subject = 'Consulta general', ContactId = con.Id, Status = 'New');
        Case case2 = new Case(Subject = 'Solicitud de soporte', ContactId = con.Id, Status = 'New');

        Test.startTest();
        insert new List<Case>{case1, case2};
        Test.stopTest();

        System.assertNotEquals(null, case1.Id);
        System.assertNotEquals(null, case2.Id);
    }

    @isTest
    static void testInsertDuplicateInSameList() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Case case1 = new Case(Subject = 'Problema duplicado', ContactId = con.Id, Status = 'New');
        Case case2 = new Case(Subject = 'problema duplicado', ContactId = con.Id, Status = 'New');

        Boolean didThrow = false;
        try {
            insert new List<Case>{case1, case2};
        } catch (DmlException e) {
            didThrow = true;
            System.assert(e.getMessage().contains('Ya existe un caso en la lista'));
        }
        System.assert(didThrow, 'Se esperaba error por caso duplicado en la misma lista.');
    }

    @isTest
    static void testInsertDuplicateInDatabase() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Case caseDup = new Case(Subject = 'Problema técnico', ContactId = con.Id, Status = 'New');

        Boolean didThrow = false;
        try {
            insert caseDup;
        } catch (DmlException e) {
            didThrow = true;
            System.assert(e.getMessage().contains('Ya existe un caso con ese asunto para este usuario.'));
        }
        System.assert(didThrow, 'Se esperaba error por duplicado contra base de datos.');
    }

    @isTest
    static void testUpdateToDuplicate() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Case case1 = new Case(Subject = 'Asunto original', ContactId = con.Id, Status = 'New');
        insert case1;
        case1.Subject = EXISTING_SUBJECT;

        Boolean didThrow = false;
        try {
            update case1;
        } catch (DmlException e) {
            didThrow = true;
            System.assert(e.getMessage().contains('Ya existe un caso con ese asunto para este usuario.'));
        }
        System.assert(didThrow, 'Se esperaba error por duplicado en update.');
    }

    @isTest
    static void testNullSubjectOrContact() {
        Case case1 = new Case(Subject = null, ContactId = null, Status = 'New');
        Case case2 = new Case(Subject = 'Asunto sin contacto', ContactId = null, Status = 'New');
        Case case3 = new Case(Subject = null, ContactId = [SELECT Id FROM Contact LIMIT 1].Id, Status = 'New');

        Test.startTest();
        insert new List<Case>{case1, case2, case3};
        Test.stopTest();

        System.assertNotEquals(null, case1.Id);
        System.assertNotEquals(null, case2.Id);
        System.assertNotEquals(null, case3.Id);
    }
    @isTest
    static void testValidateUniqueSubjectPerUserWithNullOrEmptyList() {
        Test.startTest();
        CaseTriggerRepository.validateUniqueSubjectPerUser(null);
        CaseTriggerRepository.validateUniqueSubjectPerUser(new List<Case>());
        Test.stopTest();
        System.assert(true);
    }
}
