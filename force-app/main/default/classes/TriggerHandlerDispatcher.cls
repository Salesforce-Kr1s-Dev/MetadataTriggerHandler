/**
 * @description                     Dispatch trigger handler
 */
public class TriggerHandlerDispatcher {
    /**
     *  Trigger recursion checker
     *
     *  Much better to use set of Ids 
     *
     * Credits to: https://developer.salesforce.com/forums/?id=906F000000091mJIAQ
     */
    private static Set<Id> hasBeenRunAfter = new Set<Id>();
    private static Set<Id> hasBeenRunBefore = new Set<Id>();
    @TestVisible
    private static TriggerOperation triggerContext = Trigger.operationType;

    /*********************************************************************
     * @description                 Main method to run trigger events
     * 
     * @param handler               Triggerhandler class
     * 
     * @example
     * TriggerDispatcher.run(new TriggerHandler());
     */
    public static void run(TriggerHandler handler) {
        if (!Trigger.isExecuting && !Test.isRunningTest()) {
            throw new TriggerHandlerDispatcherException('Trigger handler called outside of Trigger execution');
        }

        List<sObject> applicableSObjectsList = recursionChecker(isDeleteOrUndelete() ? Trigger.old : Trigger.new);
        if (!applicableSObjectsList.isEmpty()) {
            runEvents(handler, applicableSObjectsList);
        }
    }

    /*********************************************************************
     * @description                 Determine if trigger event is 
     *                              delete or undelete
     */
    private static Boolean isDeleteOrUndelete() {
        String context = triggerContext.name();
        return context.contains('DELETE') || context.contains('UNDELETE');
    }

    /*********************************************************************
     * @description                 Checks records if it already executed 
     *                              the process
     * 
     * @param sObjectsList          Applicable sObjects
     * 
     * @example
     * TriggerDispatcher.recursionChecker(new List<sObject>())
     */
    @TestVisible
    private static List<sObject> recursionChecker(List<sObject> sObjectsList) {
        List<sObject> applicableSObjectsList = new List<sObject>();
        if (sObjectsList != null) {
            Boolean isBefore = isBefore();
            for (sObject sobj : sObjectsList) { 
                Id objId = sObj.get('Id') != null ? (Id) sobj.get('Id') : null;
                if((isBefore && !hasBeenRunBefore.contains(objId)
                    || (!isBefore)) && !hasBeenRunAfter.contains(objId)) {
                    applicableSObjectsList.add(sobj);
                    addProcessIds(objId, isBefore);
                }
            }
        }
        return applicableSObjectsList;
    }

    /*********************************************************************
     * @description                 Determine if trigger event is 
     *                              before or after
     */
    private static Boolean isBefore() {
        String context = triggerContext.name();
        return context.contains('BEFORE');
    }

    /*********************************************************************
     * @description                 Add process records Ids to set
     *                              to avoid recursion
     * 
     * @param objId                 Record Id
     * @param isBefore              Trigger context
     * 
     */
    private static void addProcessIds(Id objId, Boolean isBefore) {
        if (objId != null) {
            if (isBefore) {
                hasBeenRunBefore.add(objId);
            } else {
                hasBeenRunAfter.add(objId);
            }
        }
    }

    /*********************************************************************
     * @description                 Execute method per trigger event 
     *                              (e.g. before insert, after, update, etc.)
     * 
     * @param handler               Triggerhandler class
     * @param isBefore              Applicable Sobjects
     */
    @TestVisible
    private static void runEvents(TriggerHandler handler, List<sObject> applicableSObjectsList) {
        switch on triggerContext {
            when BEFORE_INSERT {
                handler.beforeInsert(applicableSObjectsList);
            }
            when BEFORE_UPDATE {
                handler.beforeUpdate(new Map<Id, sObject>(applicableSObjectsList), Trigger.oldMap);
            }
            when BEFORE_DELETE {
                handler.beforeDelete(new Map<Id, sObject>(applicableSObjectsList));
            }
            when AFTER_INSERT {
                handler.afterInsert(new Map<Id, sObject>(applicableSObjectsList));
            }
            when AFTER_UPDATE {
                handler.afterUpdate(new Map<Id, sObject>(applicableSObjectsList), Trigger.oldMap);
            }
            when AFTER_DELETE {
                handler.afterDelete(new Map<Id, sObject>(applicableSObjectsList));
            }
            when AFTER_UNDELETE {
                handler.afterUndelete(new Map<Id, sObject>(applicableSObjectsList));
            }
        }
    }

    /**
     * @description                     Custom Exception
     */
    public class TriggerHandlerDispatcherException extends Exception {}
}