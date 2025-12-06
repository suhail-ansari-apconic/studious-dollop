public with sharing class S3Service {
    private static Map<String, String> getCredentials() {
        // Retrieve AWS credentials from Named Credentials or Custom Settings
        Map<String, String> creds = new Map<String, String>();
        creds.put('accessKey', 'YOUR_ACCESS_KEY');
        creds.put('secretKey', 'YOUR_SECRET_KEY');
        creds.put('region', 'us-east-1');
        creds.put('bucketName', 'YOUR_BUCKET_NAME');
        return creds;
    }

    private static String sha256Hash(String data) {
        Blob dataBlob = Blob.valueOf(data);
        Blob hashBlob = Crypto.generateDigest('SHA-256', dataBlob);
        return EncodingUtil.convertToHex(hashBlob);
    }

    private static String hmac(String key, String data) {
        Blob keyBlob = Blob.valueOf(key);
        Blob dataBlob = Blob.valueOf(data);
        Blob hmacBlob = Crypto.generateMac('HmacSHA256', dataBlob, keyBlob);
        return EncodingUtil.convertToHex(hmacBlob);
    }

    // Create Signature V4 for AWS S3
    private static String createSignatureV4(String secretKey, String dateValue, String region, String service) {
        String kDate = hmac('AWS4' + secretKey, dateValue);
        String kRegion = hmac(kDate, region);
        String kService = hmac(kRegion, service);
        String kSigning = hmac(kService, 'aws4_request');
        return kSigning;
    }
}