public with sharing class ZohoAccountAdapter {
    private String name;
    private String email;
    private String phone;
    private String website;
    private Account originalAccount;

    private ZohoAccountAdapter(Account acc) {
        // Map Account fields to ZohoAccountAdapter fields as needed
        this.name = acc.Name;
        this.email = acc.Email__c;
        this.phone = acc.Phone;
        this.website = acc.Website;
        this.originalAccount = acc;
    }

    public static ZohoAccountAdapter fromAccount(Account acc) {
        ZohoAccountAdapter adapter = new ZohoAccountAdapter(acc);
        return adapter;
    }

    public String getName() {
        return this.name;
    }

    public String getEmail() {
        return this.email;
    }

    public String getPhone() {
        return this.phone;
    }

    public String getWebsite() {
        return this.website;
    }

    public Account getOriginalAccount() {
        return this.originalAccount;
    }

    public String syncToZoho() {
        // Implement the logic to sync this account to Zoho using Zoho's API
        // This is a placeholder for actual API integration code
        String jsonPayload = this.toJson();
        String zohoResponse = 'Success'; // Simulated response
        return zohoResponse;
    }

    public String toJson() {
        Map<String, Object> jsonMap = new Map<String, Object>();
        jsonMap.put('name', this.name);
        jsonMap.put('email', this.email);
        jsonMap.put('phone', this.phone);
        jsonMap.put('website', this.website);
        return JSON.serialize(jsonMap);
    }

    public String calculateChecksum() {
        String data = this.name + this.email + this.phone + this.website;
        Blob dataBlob = Blob.valueOf(data);
        Blob hashBlob = Crypto.generateDigest('SHA-256', dataBlob);
        return EncodingUtil.convertToHex(hashBlob);
    }

    public Boolean hasChanged() {
        String currentHash = this.calculateChecksum();
        return currentHash != this.originalAccount.Zoho_Checksum__c;
    }
}