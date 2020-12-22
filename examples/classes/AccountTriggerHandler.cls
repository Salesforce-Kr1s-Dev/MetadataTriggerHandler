public class AccountTriggerHandler extends TriggerHandler {
    private final String ACCOUNT_NAME = 'Awesome Account Name';

    /*********************************************************************
     * @description                 Run method before insert in trigger
     * 
     * @param newItems              Trigger.new
     */
    public override void beforeInsert(List<SObject> newItems) {
        this.updateAccountName(newItems);
    }

    /*********************************************************************
     * @description                 Run method after update in trigger
     * 
     * @param newItems              Trigger.newMap
     * @param oldItems              Trigger.oldMap
     */
    public override void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        this.updateContactAddress(newItems.values(), this.castSObjectToAccount(oldItems));
    }

    /**
     * @description                 Update Account Name
     * 
     * @param accounts              New accounts
     */
    private void updateAccountName(List<Account> accounts) {
        for (Account account : accounts) {
            account.Name = this.ACCOUNT_NAME;
        }
    }

    /**
     * @description                 Update Contact address
     * 
     * @param accounts              Accounts updated
     * @param oldAccounts           Old version of accounts updated
     */
    private void updateContactAddress(List<Account> accounts, Map<Id, Account> oldAccounts) {
        List<Contact> contacts = new List<Contact>();
        for (Account account : this.fetchAccountContacts(accounts)) {
            for (Contact contact : account.Contacts) {
                contact.MailingStreet = account.BillingStreet;
                contact.MailingCity = account.BillingCity;
                contact.MailingPostalCode = account.BillingState;
                contact.MailingCountry = account.BillingPostalCode;
                contact.MailingState = account.BillingCountry;
                contacts.add(contact);
            }
        }

        try {
            update contacts;
        } catch (Exception ex) {
            throw ex;
        }
    }

    /**
     * @description                 Fetch related contacts to account
     * 
     * @param accounts              Accounts updated
     * 
     * @return                      List of account with related contacts
     */
    private List<Account> fetchAccountContacts(List<Account> accounts) {
        return [SELECT Id, 
                       BillingStreet, 
                       BillingCity, 
                       BillingState, 
                       BillingPostalCode,
                       BillingCountry,
                       (SELECT Id,
                               MailingStreet, 
                               MailingCity, 
                               MailingPostalCode,
                               MailingCountry,
                               MailingState
                        FROM Contacts)
                FROM Account 
                WHERE Id IN :accounts];
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
