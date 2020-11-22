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

    public static void run(TriggerHandler handler) {
        if (!Trigger.isExecuting && !Test.isRunningTest()) {
            throw new TriggerHandlerDispatcherException('Trigger handler called outside of Trigger execution');
        }

        List<sObject> applicableSObjectsList = Test.isRunningTest() ? 
                                                    new List<sObject>() : 
                                                    recursionChecker(Trigger.isDelete || Trigger.isUndelete ? Trigger.old : Trigger.new);
        if (!applicableSObjectsList.isEmpty()) {
            runEvents(handler, applicableSObjectsList);
        }
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
    private static List<sObject> recursionChecker(List<sObject> sObjectsList) {
        List<sObject> applicableSObjectsList = new List<sObject>();
        for (sObject sobj : sObjectsList) {
            Id objId = sObj.get('Id') != null ? (Id) sobj.get('Id') : null;
            if ((Trigger.isBefore && !hasBeenRunBefore.contains(objId))
                    || (Trigger.isAfter && !hasBeenRunAfter.contains(objId))) {
                applicableSObjectsList.add(sobj);
                if (objId != null) {
                    if (Trigger.isBefore) {
                        hasBeenRunBefore.add(objId);
                    } else {
                        hasBeenRunAfter.add(objId);
                    }
                }
            }
        }
        return applicableSObjectsList;
    }

    private static void runEvents(TriggerHandler handler, List<sObject> applicableSObjectsList) {
        // Before trigger logic
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                handler.beforeInsert(applicableSObjectsList);
            }

            if (Trigger.isUpdate) {
                handler.beforeUpdate(new Map<Id, sObject>(applicableSObjectsList), trigger.oldMap);
            }

            if (Trigger.isDelete) {
                handler.beforeDelete(new Map<Id, sObject>(applicableSObjectsList));
            }
        }
         
        // After trigger logic
        if (Trigger.isAfter) {
            if (Trigger.IsInsert) {
                handler.afterInsert(new Map<Id, sObject>(applicableSObjectsList));
            }

            if (Trigger.isUpdate) {
                handler.afterUpdate(new Map<Id, sObject>(applicableSObjectsList), trigger.oldMap);
            }

            if (Trigger.isDelete) {
                handler.afterDelete(new Map<Id, sObject>(applicableSObjectsList));
            }

            if (Trigger.isUndelete) {
                handler.afterUndelete(new Map<Id, sObject>(applicableSObjectsList));
            }
        }
    }

    public class TriggerHandlerDispatcherException extends Exception {}
}