public with sharing class S3Service {
    private static final Integer CHUNK_SIZE = 102400; // 100KB chunks
    
    public static void getCSVFromS3InChunks(String fileName) {
        Integer offset = 0;
        Boolean hasMoreData = true;
        String leftoverData = '';
        Integer rowsProcessed = 0;
        
        while(hasMoreData) {
            HttpResponse res = fetchChunk(fileName, offset);
            
            if(isSuccessResponse(res)) {
                String chunk = leftoverData + res.getBody();
                List<String> lines = chunk.split('\n');
                
                Integer linesToProcess = calculateLinesToProcess(lines, res.getStatusCode());
                rowsProcessed = processLines(lines, linesToProcess, rowsProcessed);
                
                leftoverData = saveLeftoverData(lines, hasMoreData && res.getStatusCode() == 206);
                
                hasMoreData = shouldContinue(res, offset);
                offset += CHUNK_SIZE;
            } else if(res.getStatusCode() == 416) {
                System.debug('Reached end of file');
                hasMoreData = false;
            } else {
                handleError(res);
                hasMoreData = false;
            }
        }
        
        System.debug('Total rows processed: ' + rowsProcessed);
    }
    
    private static HttpResponse fetchChunk(String fileName, Integer offset) {
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:AWS_S3' + '/' + fileName);
        req.setHeader('Range', 'bytes=' + offset + '-' + (offset + CHUNK_SIZE - 1));
        
        Http http = new Http();
        return http.send(req);
    }
    
    private static Boolean isSuccessResponse(HttpResponse res) {
        return res.getStatusCode() == 206 || res.getStatusCode() == 200;
    }
    
    private static Integer calculateLinesToProcess(List<String> lines, Integer statusCode) {
        if(statusCode == 200) {
            return lines.size();
        }
        return lines.size() - 1;
    }
    
    private static Integer processLines(List<String> lines, Integer linesToProcess, Integer rowsProcessed) {
        for(Integer i = 0; i < linesToProcess; i++) {
            String line = lines[i].trim();
            if(String.isNotBlank(line)) {
                processCSVRow(line, rowsProcessed);
                rowsProcessed++;
            }
        }
        return rowsProcessed;
    }
    
    private static String saveLeftoverData(List<String> lines, Boolean shouldSave) {
        if(shouldSave && lines.size() > 0) {
            return lines[lines.size() - 1];
        }
        return '';
    }
    
    private static Boolean shouldContinue(HttpResponse res, Integer currentOffset) {
        if(res.getStatusCode() == 200) {
            return false;
        }
        
        if(res.getStatusCode() == 206) {
            String contentRange = res.getHeader('Content-Range');
            if(contentRange != null && contentRange.contains('/')) {
                Integer totalSize = Integer.valueOf(contentRange.split('/')[1]);
                return (currentOffset + CHUNK_SIZE < totalSize);
            }
        }
        
        return false;
    }
    
    private static void handleError(HttpResponse res) {
        System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getBody());
    }
    
    private static void processCSVRow(String row, Integer rowIndex) {
        // Skip header row
        if(rowIndex == 0) {
            System.debug('Header: ' + row);
            return;
        }
        
        // Parse CSV row
        List<String> fields = row.split(',');
        
        // Example: Process the fields
        System.debug('Row ' + rowIndex + ': ' + fields);
        
        // TODO: Add your business logic here
        // For example, create/update Salesforce records
        // Account acc = new Account();
        // acc.Name = fields.size() > 0 ? fields[0] : '';
        // acc.Email__c = fields.size() > 1 ? fields[1] : '';
        // insert acc;
    }
}