@isTest
private class TriggerHandlerDispatcherTest {
    private static final TriggerHandler MOCK_HANDLER=  new TriggerHandlerMock();
    private static final IDGenerator ID_GENERATOR = new IDGenerator();
    
    @isTest
    private static void testRun() {
        TriggerHandlerDispatcher.triggerContext = TriggerOperation.BEFORE_INSERT;
        Test.startTest();
            TriggerHandlerDispatcher.run(MOCK_HANDLER);
        Test.stopTest();
    }

    @isTest
    private static void testBeforeInsert() {
        TriggerHandlerDispatcher.triggerContext = TriggerOperation.BEFORE_INSERT;
        Test.startTest();
            TriggerHandlerDispatcher.runEvents(MOCK_HANDLER, fetchAccounts());
        Test.stopTest();
    }

    @isTest
    private static void testBeforeUpdate() {
        TriggerHandlerDispatcher.triggerContext = TriggerOperation.BEFORE_UPDATE;
        Test.startTest();
            TriggerHandlerDispatcher.runEvents(MOCK_HANDLER, fetchAccounts());
        Test.stopTest();
    }

    @isTest
    private static void testBeforeDelete() {
        TriggerHandlerDispatcher.triggerContext = TriggerOperation.BEFORE_DELETE;
        Test.startTest();
            TriggerHandlerDispatcher.runEvents(MOCK_HANDLER, fetchAccounts());
        Test.stopTest();
    }

    @isTest
    private static void testAfterInsert() {
        TriggerHandlerDispatcher.triggerContext = TriggerOperation.AFTER_INSERT;
        Test.startTest();
            TriggerHandlerDispatcher.runEvents(MOCK_HANDLER, fetchAccounts());
        Test.stopTest();
    }

    @isTest
    private static void testAfterUpdate() {
        TriggerHandlerDispatcher.triggerContext = TriggerOperation.AFTER_UPDATE;
        Test.startTest();
            TriggerHandlerDispatcher.runEvents(MOCK_HANDLER, fetchAccounts());
        Test.stopTest();
    }

    @isTest
    private static void testAfterDelete() {
        TriggerHandlerDispatcher.triggerContext = TriggerOperation.AFTER_DELETE;
        Test.startTest();
            TriggerHandlerDispatcher.runEvents(MOCK_HANDLER, fetchAccounts());
        Test.stopTest();
    }

    @isTest
    private static void testAfterUndelete() {
        TriggerHandlerDispatcher.triggerContext = TriggerOperation.AFTER_UNDELETE;
        Test.startTest();
            TriggerHandlerDispatcher.runEvents(MOCK_HANDLER, fetchAccounts());
        Test.stopTest();
    }

    @isTest
    private static void testRecursionCheckerBeforeEvent() {
        List<SObject> applicableSobjects;
        List<Account> accounts = fetchAccounts();
        TriggerHandlerDispatcher.triggerContext = TriggerOperation.BEFORE_INSERT;
        Test.startTest();
            applicableSobjects = TriggerHandlerDispatcher.recursionChecker(accounts);
        Test.stopTest();
        System.assert(!applicableSobjects.isEmpty(), 'Failed to process records');
    }
    
    @isTest
    private static void testRecursionCheckerAfterEvent() {
        List<SObject> applicableSobjects;
        List<Account> accounts = fetchAccounts();
        TriggerHandlerDispatcher.triggerContext = TriggerOperation.AFTER_INSERT;
        Test.startTest();
            applicableSobjects = TriggerHandlerDispatcher.recursionChecker(accounts);
        Test.stopTest();
        System.assert(!applicableSobjects.isEmpty(), 'Failed to process records');
    }

    private static List<Account> fetchAccounts() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Id mockId = ID_GENERATOR.generate(Account.getSObjectType());
            accounts.add(new Account( Id = mockId ));
        }
        return accounts;
    }

    public class TriggerHandlerMock extends TriggerHandler {}
    public class IDGenerator {
        private Integer fakeIdCount = 0;
        private final String ID_PATTERN = '000000000000';
        /**
         * Generate a fake Salesforce Id for the given SObjectType
         */
        public Id generate(Schema.SObjectType sobjectType) {
            String keyPrefix = sobjectType.getDescribe().getKeyPrefix();
            fakeIdCount++;
            String fakeIdPrefix = ID_PATTERN.substring(0, 12 - fakeIdCount.format().length());
            return System.Id.valueOf(keyPrefix + fakeIdPrefix + fakeIdCount);
        }
    }
}
