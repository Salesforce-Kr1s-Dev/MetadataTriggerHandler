/**
 * @description                     Handles the execution of different
 *                                  trigger handlers per trigger object
 */
public class MetadataTriggerManager {
    private final String TRIGGER_OBJECT_REQUIRED = 'Must set trigger sobject';
    private final String SOMETHING_WENT_WRONG = 'Something went wrong. Please contact administrator.';
    private Boolean isTriggerEnabled = false;
    private String sObjectType;

    /*********************************************************************
     * @description                 Run trigger handlers
     * 
     * @example
     * new MetadataTriggerManager()
     *      .enableTrigger(true)
     *      .setSObjectType('ObjectXXX')
     *      .run();
     */
    public void run() {
        if (!this.isTriggerEnabled) {
            return;
        }

        if (this.isTriggerEnabled && String.isBlank(this.sObjectType)) {
            throw new MetadataTriggerManagerException(this.TRIGGER_OBJECT_REQUIRED);
        }

        try {
            for (Trigger_Handler__mdt metadata : this.fetchTriggerHandlers()) {
                Type handler = this.constructApexType(metadata.Class_Name__c);
                if (handler != null && this.isValid(handler)) {
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

    /*********************************************************************
     * @description                 Fetch all active trigger handlers
     *                              on specific object
     */
    private List<Trigger_Handler__mdt> fetchTriggerHandlers() {
        return [SELECT Execution_Order__c, 
                       Class_Name__c
                FROM Trigger_Handler__mdt
                WHERE sObjectType__c = :this.sObjectType
                AND Is_Active__c = TRUE
                ORDER BY Execution_Order__c];
    }

    /*********************************************************************
     * @description                 Validate if trigger handler class is
     *                              not included in bypass and parent class
     *                              is TriggerHandler
     * 
     * @param handler               Apex type that corresponds to an Apex class 
     * 
     */
    @TestVisible
    private Type constructApexType(String className) {
        Type apexType;
        try {
            apexType = Type.forName(className);
        } catch (Exception ex) {
            /**
             * TODO: Class doesn't exist. Implement logging framework
             * 
             */
        }
        return apexType;
    }

    /*********************************************************************
     * @description                 Validate if trigger handler class is
     *                              not included in bypass and parent class
     *                              is TriggerHandler
     * 
     * @param handler               Apex type that corresponds to an Apex class 
     * 
     */
    @TestVisible
    private Boolean isValid(Type handler) {
        Boolean isBypassed = TriggerHandler.isByPassed(handler.getName());
        Boolean isTriggerHandlerType = TriggerHandler.class.isAssignableFrom(handler);
        return !isBypassed && isTriggerHandlerType;
    }

    /*********************************************************************
     * @description                 Execute Trigger handler
     * 
     * @param handler               Apex type that corresponds to an Apex class 
     * 
     */
    @TestVisible
    private void executeHandler(Type handler) {
        TriggerHandlerDispatcher.run(this.injectHandler(handler));
        TriggerHandler.clearByPasses();
    }

    /*********************************************************************
     * @description                 Instantiate TriggerHandler class
     * 
     * @param handler               Apex type that corresponds to an Apex class 
     * 
     */
    private TriggerHandler injectHandler(Type handler) {
        return (TriggerHandler) handler.newInstance();
    }

    /*********************************************************************
     * @description                 Enable trigger manager
     * 
     * @param isTriggerEnabled      Determines if trigger is enabled
     * 
     */
    public MetadataTriggerManager enableTrigger(Boolean isTriggerEnabled) {
        this.isTriggerEnabled = isTriggerEnabled;
        return this;
    }

    /*********************************************************************
     * @description                 Set SObject Type for fetching trigger 
     *                              handlers
     * 
     * @param sObjectType           Trigger SObject
     * 
     */
    public MetadataTriggerManager setSObjectType(String sObjectType) {
        this.sObjectType = sObjectType;
        return this;
    }

    public class MetadataTriggerManagerException extends Exception {}
}
