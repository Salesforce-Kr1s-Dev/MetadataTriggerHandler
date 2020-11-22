@isTest
private class TriggerHandlerTest {
    private static final String BYPASS_CLASS = 'MockClass';
    private static final List<SObject> TRIGGER_NEW = new List<SObject>();
    private static final Map<Id, SObject> TRIGGER_OLD = new Map<Id, SObject>();

    @isTest
    private static void testVirtualMethods() {
        TriggerHandler handler = new TriggerHandler();
        Map<Id, SObject> newMap = new Map<Id, SObject>(TRIGGER_NEW);
        Test.startTest();
            handler.beforeInsert(TRIGGER_NEW);
            handler.beforeUpdate(newMap, TRIGGER_OLD);
            handler.beforeDelete(TRIGGER_OLD);
            handler.afterInsert(newMap);
            handler.afterUpdate(newMap, TRIGGER_OLD);
            handler.afterDelete(TRIGGER_OLD);
            handler.afterUndelete(TRIGGER_OLD);
        Test.stopTest();
    }

    @isTest
    private static void testByPass() {
        Test.startTest();
            TriggerHandler.bypass(BYPASS_CLASS);
        Test.stopTest();
        System.assert(TriggerHandler.isByPassed(BYPASS_CLASS), 'Failed to bypass class');
    }

    @isTest
    private static void testClearByPass() {
        TriggerHandler.bypass(BYPASS_CLASS);
        Test.startTest();
            TriggerHandler.clearByPass(BYPASS_CLASS);
        Test.stopTest();
        System.assert(!TriggerHandler.isByPassed(BYPASS_CLASS), 'Failed to remove bypass class');
    }

    @isTest
    private static void testClearByPasses() {
        TriggerHandler.bypass(BYPASS_CLASS);
        Test.startTest();
            TriggerHandler.clearByPasses();
        Test.stopTest();
        System.assert(!TriggerHandler.isByPassed(BYPASS_CLASS), 'Failed to clear all bypass classes');
    }
}
