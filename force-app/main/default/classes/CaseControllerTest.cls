@isTest
public class CaseControllerTest {
    @isTest
    static void testGetCaseRecordTypes() {
        RecordType rt = [
            SELECT Id, Name
            FROM RecordType
            WHERE SObjectType = 'Case' AND IsActive = true
            LIMIT 1
        ];

        Test.startTest();
        List<RecordTypeService.Option> options = CaseController.getCaseRecordTypes();
        Test.stopTest();

        System.assertNotEquals(0, options.size(), 'Se esperaba al menos un RecordType');

        Boolean found = false;
        for (RecordTypeService.Option opt : options) {
            if (opt.value == rt.Id) {
                found = true;
                System.assertEquals(rt.Name, opt.label);
            }
        }
        System.assert(found, 'El RecordType existente debe estar en la lista');
    }
}
