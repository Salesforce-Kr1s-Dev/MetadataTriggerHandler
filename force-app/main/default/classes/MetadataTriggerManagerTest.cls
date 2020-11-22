@isTest
private class MetadataTriggerManagerTest {
    private static final String TRIGGER_OBJECT_REQUIRED = 'Must set trigger sobject';
    private static final String NOT_IN_TRIGGER_CONTEXT = 'Trigger handler called outside of Trigger execution';
    private static final String MOCK_TRIGGER_HANDLER_CLASS = 'MetadataTriggerManagerTest.TriggerHandlerMock';
    private static final Type HANDLER = Type.forName(MOCK_TRIGGER_HANDLER_CLASS);

    @isTest
    private static void testRunWithSObjectType() {
        Test.startTest();
            new MetadataTriggerManager()
                .enableTrigger(true)
                .setSObjectType('ObjectXXX')
                .run();
        Test.stopTest();
    }

    @isTest
    private static void testRunWithoutSObjectType() {
        String errMessage;
        Test.startTest();
            try {
                new MetadataTriggerManager()
                    .enableTrigger(true)
                    .run();
            } catch(Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(TRIGGER_OBJECT_REQUIRED, errMessage, 'Successfully executed trigger handlers');
    }

    @isTest
    private static void testRunDisabledTrigger() {
        Test.startTest();
            new MetadataTriggerManager()
                .enableTrigger(false)
                .run();
        Test.stopTest();
    }

    @isTest
    private static void testValidTriggerHandlerClass() {
        Boolean isValid;
        MetadataTriggerManager mdt = new MetadataTriggerManager();
        Test.startTest();
            isValid = mdt.isValid(MOCK_TRIGGER_HANDLER_CLASS, HANDLER);
        Test.stopTest();
        System.assert(isValid, 'TriggerHandler class is invalid');
    }

    @isTest
    private static void testInValidTriggerHandlerClass() {
        Boolean isValid;
        MetadataTriggerManager mdt = new MetadataTriggerManager();
        TriggerHandler.byPass(MOCK_TRIGGER_HANDLER_CLASS);
        Test.startTest();
            isValid = mdt.isValid(MOCK_TRIGGER_HANDLER_CLASS, HANDLER);
        Test.stopTest();
        System.assert(!isValid, 'TriggerHandler class is valid');
    }

    @isTest
    private static void testExecuteHandlerOutSideTriggerContext() {
        String errMessage;
        MetadataTriggerManager mdt = new MetadataTriggerManager();
        Test.startTest();
            try {
                mdt.executeHandler(HANDLER);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(NOT_IN_TRIGGER_CONTEXT, errMessage, 'Successfully executed trigger handlers');
    }

    public class TriggerHandlerMock extends TriggerHandler {}
}
