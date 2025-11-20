public with sharing class AccountTriggerHandler {
  public static void handleAfterInsert(List<Account> newAccounts) {
    System.enqueueJob(new ZohoAccountSyncQueueable(newAccounts));
  }

  public static void handleAfterUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
    List<Account> accountsToSync = new List<Account>();
    for(Account acc : newAccounts) {
      Account oldAcc = oldAccountMap.get(acc.Id);
      ZohoAccountAdapter adapter = ZohoAccountAdapter.fromAccount(acc);
      if(adapter.hasChanged()) {
        accountsToSync.add(acc);
      }
    }

    if(!accountsToSync.isEmpty()) {
      System.enqueueJob(new ZohoAccountSyncQueueable(accountsToSync));
    }
  }
}