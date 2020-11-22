public class MetadataTriggerManager {
    private Boolean isTriggerEnabled = false;
    private String sObjectType;

    public void run() {
        if (this.isTriggerEnabled && String.isBlank(this.sObjectType)) {
            throw new MetadataTriggerManagerException('Must set trigger sobject');
        }

        try {
            for (Trigger_Handler__mdt metadata : this.fetchTriggerHandlers()) {
                // Possible null pointer exception
                Type handler = Type.forName(metadata.Class_Name__c);
                if (this.isValid(metadata.Class_Name__c, handler)) {
                    this.executeHandler(handler);
                }
            }
        } catch (Exception ex) {
            /**
             * TODO: Implement logging framework
             * 
             * Do not use the generic error message label
             * to avoid any dependencies
             */
            throw new MetadataTriggerManagerException('Something went wrong. Please contact administrator.');
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
    private Boolean isValid(String className, Type handler) {
        Boolean isBypassed = TriggerHandler.isByPassed(className);
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
