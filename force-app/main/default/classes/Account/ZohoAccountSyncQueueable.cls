public with sharing class ZohoAccountSyncQueueable implements Queueable{
  List<Id> accountIds;
  public ZohoAccountSyncQueueable(List<Account> accounts){
    this.accountIds = new List<Id>(new Map<Id, Account>(accounts).keySet());
  }

  public void execute(QueueableContext context) {
    // Logic to sync accounts to Zoho
    if (accountIds.isEmpty()) {
      return;
    }

    List<Account> accountsToSync = [SELECT Id, Name, Email__c, Phone, Website, Zoho_Checksum__c, External_Id__c FROM Account WHERE Id IN :accountIds];
    for(Account acc : accountsToSync){
      if (acc.External_Id__c == null) {
        // New account so generate External Id usually from Zoho response after creation
        acc.External_Id__c = 'Zoho_' + acc.Id;
      }

      ZohoAccountAdapter adapter = ZohoAccountAdapter.fromAccount(acc);
      String checkSum = adapter.calculateChecksum();
      acc.Zoho_Checksum__c = checkSum;
    }

    update(accountsToSync);
  }
}