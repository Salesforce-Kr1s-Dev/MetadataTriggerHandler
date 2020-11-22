public class MetadataTriggerManager {
    private final String TRIGGER_OBJECT_REQUIRED = 'Must set trigger sobject';
    private final String SOMETHING_WENT_WRONG = 'Something went wrong. Please contact administrator.';
    private Boolean isTriggerEnabled = false;
    private String sObjectType;

    public void run() {
        if (!this.isTriggerEnabled) {
            return;
        }

        if (this.isTriggerEnabled && String.isBlank(this.sObjectType)) {
            throw new MetadataTriggerManagerException(this.TRIGGER_OBJECT_REQUIRED);
        }

        try {
            for (Trigger_Handler__mdt metadata : this.fetchTriggerHandlers()) {
                // Possible null pointer exception
                Type handler = Type.forName(metadata.Class_Name__c);
                if (this.isValid(handler)) {
                    this.executeHandler(handler);
                }
            }
        } catch (Exception ex) {
            /**
             * TODO: Implement logging framework
             * 
             */
            throw new MetadataTriggerManagerException(this.SOMETHING_WENT_WRONG);
        }
    }

    private List<Trigger_Handler__mdt> fetchTriggerHandlers() {
        return [SELECT Execution_Order__c, 
                       Class_Name__c
                FROM Trigger_Handler__mdt
                WHERE sObjectType__c = :this.sObjectType
                AND Is_Active__c = TRUE
                ORDER BY Execution_Order__c];
    }

    @TestVisible
    private Boolean isValid(Type handler) {
        Boolean isBypassed = TriggerHandler.isByPassed(handler.getName());
        Boolean isTriggerHandlerType = TriggerHandler.class.isAssignableFrom(handler);
        return !isBypassed && isTriggerHandlerType;
    }

    @TestVisible
    private void executeHandler(Type handler) {
        TriggerHandlerDispatcher.run(this.injectHandler(handler));
        TriggerHandler.clearByPasses();
    }

    private TriggerHandler injectHandler(Type handler) {
        return (TriggerHandler) handler.newInstance();
    }

    public MetadataTriggerManager enableTrigger(Boolean isTriggerEnabled) {
        this.isTriggerEnabled = isTriggerEnabled;
        return this;
    }

    public MetadataTriggerManager setSObjectType(String sObjectType) {
        this.sObjectType = sObjectType;
        return this;
    }

    public class MetadataTriggerManagerException extends Exception {}
}
