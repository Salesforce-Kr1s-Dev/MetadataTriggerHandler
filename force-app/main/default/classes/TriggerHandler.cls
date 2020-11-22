public virtual class TriggerHandler {

    private static Set<String> bypassHandlers = new Set<String>();

    /**
     * Trigger handler events
     */
    public virtual void beforeInsert(List<SObject> newItems) {}

    public virtual void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public virtual void beforeDelete(Map<Id, SObject> oldItems) {}

    public virtual void afterInsert(Map<Id, SObject> newItems) {}

    public virtual void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public virtual void afterDelete(Map<Id, SObject> oldItems) {}

    public virtual void afterUndelete(Map<Id, SObject> oldItems) {}

    /**
     * Bypass APIs
     */
    public static void bypass(String handlerName) {
        bypassHandlers.add(handlerName);
    }

    public static void clearByPass(String handlerName) {
        bypassHandlers.remove(handlerName);
    }

    public static Boolean isByPassed(String handlerName) {
        return bypassHandlers.contains(handlerName);
    }

    public static void clearByPasses() {
        bypassHandlers.clear();
    }
}