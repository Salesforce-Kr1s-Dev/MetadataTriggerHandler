trigger AccountTrigger on Account (before insert, after update) {
    /**
     * Enable/Disable Trigger using custom settings
     */
    new MetadataTriggerManager()
        .enableTrigger(Trigger_Settings__c.getInstance(UserInfo.getUserId()).AccountTrigger__c) //Optional
        .setSObjectType('Account')
        .run();
}