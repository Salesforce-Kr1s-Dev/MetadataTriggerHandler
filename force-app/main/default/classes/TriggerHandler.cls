/**
 * @description                     TriggerHandler parent class
 * 
 *                                  Classes utilizing the MetadataTriggerManager
 *                                  must extend this class
 */
public virtual class TriggerHandler {

    private static Set<String> bypassHandlers = new Set<String>();

    /*********************************************************************
     * @description                 Run method before insert in trigger
     * 
     * @param newItems              Trigger.new
     */
    public virtual void beforeInsert(List<SObject> newItems) {}

    /*********************************************************************
     * @description                 Run method before update in trigger
     * 
     * @param newItems              Trigger.newMap
     * @param oldItems              Trigger.oldMap
     */
    public virtual void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    /*********************************************************************
     * @description                 Run method before delete in trigger
     * 
     * @param oldItems              Trigger.oldMap
     */
    public virtual void beforeDelete(Map<Id, SObject> oldItems) {}

    /*********************************************************************
     * @description                 Run method after insert in trigger
     * 
     * @param newItems              Trigger.newMap
     */
    public virtual void afterInsert(Map<Id, SObject> newItems) {}

    /*********************************************************************
     * @description                 Run method after update in trigger
     * 
     * @param newItems              Trigger.newMap
     * @param oldItems              Trigger.oldMap
     */
    public virtual void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    /*********************************************************************
     * @description                 Run method after delete in trigger
     * 
     * @param oldItems              Trigger.oldMap
     */
    public virtual void afterDelete(Map<Id, SObject> oldItems) {}

    /*********************************************************************
     * @description                 Run method after undlete in trigger
     * 
     * @param oldItems              Trigger.oldMap
     */
    public virtual void afterUndelete(Map<Id, SObject> oldItems) {}

    /*********************************************************************
     * @description                 Bypass trigger/apex class before 
     *                              class execution
     * 
     * @param handlerName          Class name
     */
    public static void bypass(String handlerName) {
        bypassHandlers.add(handlerName);
    }

    /*********************************************************************
     * @description                 Remove/Enable apex class before class
     *                              execution
     * 
     * @param handlerName          Class name
     */
    public static void clearByPass(String handlerName) {
        bypassHandlers.remove(handlerName);
    }

    /*********************************************************************
     * @description                 Check if class was bypassed
     * 
     * @param handlerName           Class name
     */
    public static Boolean isByPassed(String handlerName) {
        return bypassHandlers.contains(handlerName);
    }

    /*********************************************************************
     * @description                 Clear all bypass classes
     */
    public static void clearByPasses() {
        bypassHandlers.clear();
    }
}