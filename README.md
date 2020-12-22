# Trigger Handler using Custom Metadata
## Overview
Salesforce Triggers have been here for a couple of years now and a lot of frameworks have been popping-up. The latest I've encountered is the usage of custom metadata in constructing object triggers. This prevents the class dependencies in compile time and only run the classes on execution. 

Then, there's our old friend TriggerHandler framework which creates a generic TriggerHandler class that serves as a parent class and using it, we can override the methods as we see fit. 

Lastly, we have a lightweight trigger framework that created a trigger dispatcher that separates the logic for execution of methods per event.

With all that said and done, and with the ongoing quarantine. I've decided to create a framework which combines all three. Hope it helps and have fun! :D 

## Usage
### Creating Object Trigger Handler
To create an object trigger handler, you simply need a class that extends ```TriggerHandler.cls```. See example below for creating an object trigger handler or see the [link](./examples/classes/AccountTriggerHandler.cls) for reference.

```java
public class AccountTriggerHandler extends TriggerHandler { 
    //Override methods 
}
```

To add any logic to any of trigger events, you just need to override the methods in the parent class. See example below for overriding a method or see the [link](./examples/classes/AccountTriggerHandler.cls) for reference.
```java
public class AccountTriggerHandler extends TriggerHandler { 
    /*********************************************************************
     * @description                 Run method after update in trigger
     * 
     * @param newItems              Trigger.newMap
     * @param oldItems              Trigger.oldMap
     */
    public override void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        // Do something awesome on update
    }
}
```

**Note:** When referencing the Trigger statics within a class, SObjects are returned versus SObject subclasses like Opportunity, Account, etc. This means that you must cast when you reference them in your trigger handler. You could do this in a separate method if you wanted. 
```java
public class AccountTriggerHandler extends TriggerHandler {
    /*********************************************************************
     * @description                 Run method after update in trigger
     * 
     * @param newItems              Trigger.newMap
     * @param oldItems              Trigger.oldMap
     */
    public override void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Account> oldAccounts = this.castSObjectToAccount(oldItems));
    }

    /**
     * @description                 Cast generic SObject map to Account Map
     * 
     * @param items                 Generic SObject map
     * 
     * @return                      Map of accounts
     */
    private Map<Id, Account> castSObjectToAccount(Map<Id, SObject> items) {
        List<Account> accounts = items.values();
        return new Map<Id, Account>(accounts);
    }
}
```

### Register Trigger Handler in Custom Metadata
Once you're done creating the object trigger handler, it's time to register it in the custom metadata. It's to avoid any class dependencies in the trigger. See example below or [link](./examples/customMetadata/Trigger_Handler.Account_Trigger_Handler.md-meta.xml) for reference.
 - Label: ```Awesome label name```
 - Class Name: ```Trigger Handler class name(e.g. AccountTriggerHandler)```
 - Execution Order: ```Execution Order(e.g. 1, 2, n)```
 - sObjectType: ```Trigger Object(e.g. Account)```
 - Is Active: ```true or false```

### Constructing Object Trigger
Once we're done creating the trigger handler and registered it in the custom metadata. It's time to construct the object trigger. We just need to call the ```MetadataTriggerManager``` class to run the trigger handler in the custom metadata. See example below or the [link](./examples/triggers/AccountTrigger.trigger) for reference.
```java
trigger AccountTrigger on Account (before insert, after update) {
    new MetadataTriggerManager()
        .setSObjectType('Account')
        .run();
}
```

## Awesome stuff
### Recursion Checker
We've stored the record Ids that was processed by the trigger in a collection to prevent trigger recursion. It's much better than the traditional boolean value especially for bulk processing. See the [link](https://developer.salesforce.com/forums/?id=906F000000091mJIAQ) for more information.
### Enable/Disable object trigger
By default, the trigger is enabled for all users but for some scenarios like uploading a bulk data, we need to disable a trigger to a specific user to avoid unforeseen issues. We've added a ```setEnableTrigger``` in ```MetadataTriggerManager``` and partnered with **custom settings**, in the approach, we can disable a trigger for that specific profile/user on the fly. See example below or the [link](./examples/triggers/AccountTrigger.trigger) for reference.
```java
trigger AccountTrigger on Account (before insert, after update) {
    /**
     * Enable/Disable Trigger using custom settings
     */
    new MetadataTriggerManager()
        .enableTrigger(Trigger_Settings__c.getInstance(UserInfo.getUserId()).AccountTrigger__c)
        .setSObjectType('Account')
        .run();
}
```
### Bypass API
We still maintain the bypass API which was implemented from the trigger handler class. To bypass a trigger handler, we just need to use the ```bypass``` method in ```TriggerHandler``` class.
```java
// Bypass ContactTriggerHandler
TriggerHandler.bypass('ContactTriggerHandler');
```
By default, the ```MetadataTriggerManager``` checks if the trigger handler is bypassed and clears it after execution but if you need to check if a handler is bypassed, use the ```isBypassed``` method.
```java
if (TriggerHandler.isBypassed('AccountTriggerHandler')) {
  // do something if trigger handler bypassed
}
```
And if you want to clear all bypasses for the transaction, simple use the clearAllBypasses method, as in:
```java
// done with bypasses!
TriggerHandler.clearAllBypasses();
// now handlers won't be ignored!
```
## Overridable Methods
Below are the methods you can override.
- ```beforeInsert(List<SObject> newItems)```
- ```beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)```
- ```beforeDelete(Map<Id, SObject> oldItems)```
- ```afterInsert(Map<Id, SObject> newItems)```
- ```afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)```
- ```afterDelete(Map<Id, SObject> oldItems)```
- ```afterUndelete(Map<Id, SObject> oldItems)```
## References
- https://github.com/kevinohara80/sfdc-trigger-framework
- https://github.com/codefriar/DecouplingWithSimonGoodyear
- https://www.youtube.com/watch?v=ilZ4-UWH6n8
- https://developer.salesforce.com/forums/?id=906F000000091mJIAQ
- http://chrisaldridge.com/triggers/lightweight-apex-trigger-framework/