/**
 * @description       :
 * @author            : Amit Singh
 * @group             :
 * @last modified on  : 01-11-2022
 * @last modified by  : Amit Singh
**/
public class AWSS3_PutAttachments extends AWS{

    public String fileName;
    public String folderName;
    public Blob fileBody;
    public String contentType;
    public Id recordId;
    public Map<Id, Id> parentIdsMap;

    public override void init() {

        ContentVersion versionData = [ SELECT Id, Title, FileExtension, ContentDocumentId, VersionData FROM ContentVersion Where Id =: recordId];

        String Name = versionData.Title.substringBeforeLast('.');

        folderName = System.Label.S3FolderName;
        // this is not required but if you want to upload file to specific folder then create a folder inside S3 bucket
        // and then put the name inside Folder
        fileName = Name;
        fileBody = versionData.VersionData;

        contentType = ContentType(versionData.FileExtension);
        endpoint = new Url(System.Label.S3_Bucket_Url);
        /*
        * Value for S3_Bucket_Url is -
        * https - default
        * amit-fdsx - Name of the bucket in S3
        * s3 - Service Name
        * amazonaws.com - default value
        */
        if(String.isBlank(folderName)){
            resource = this.fileName+'.'+versionData.FileExtension;
        }else{
            resource = this.folderName+'/'+this.fileName+'.'+versionData.FileExtension;
        }
        region = System.Label.S3Region; // Your Amazon Region my value is - us-east-1
        service = 's3';
        accessKey = System.Label.AWSAccessKeyId; //AWSAccessKeyId
        method = HttpMethod.XPUT;
        //  Remember to set "payload" here if you need to specify a body
        //  payload = Blob.valueOf('some-text-i-want-to-send');
        //  This method helps prevent leaking secret key,
        //  as it is never serialized
        payload = this.fileBody;
        // Call this method from Abstract Class "AWS"
        createSigningKey(System.Label.AWSSecretKey);  //AWSSecretKey

        /*if(!Test.isRunningTest()){*/
        // Call this method from Abstract Class "AWS"
        HttpRequest req = createRequest(contentType);
        try{
            // Send the Request and get the response
            HttpResponse res = (new Http()).send(req);
            //System.debug('Content-Type \n '+ res.getHeader('Content-Type') );
            //System.debug('Response From Aws \n '+ res.getBody() );
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                String awsUrl = req.getEndpoint();
                //String imageURL = '<a href="'+awsUrl+'">'+versionData.Title+'</a>&nbsp;';
                //System.debug('awsUrl \n '+ awsUrl);
                AWS_Attachment__c att = new AWS_Attachment__c();
                att.FileUrl__c  = awsUrl;
                att.ParentId__c = parentIdsMap.get(versionData.ContentDocumentId);
                att.Title__c    = versionData.Title;
                att.VersionId__c = recordId;
                insert att;
            }else{
                /* !-- Handle the error if there is any error while uploading the file to Amazon --! */
                /*
                    <?xml version="1.0" encoding="UTF-8"?>
                    <Error>
                        <Code>AccessDenied</Code>
                        <Message>Access Denied</Message>
                        <RequestId>BJ2VG02H83VJJYTR</RequestId>
                        <HostId>LZtlgTIaF3YOwaurOs0WZz4sphx6OCzMGluGNjExifNpApcptWbsFVuOF8W8SmqU/ytykejHW+g=</HostId>
                    </Error>
                */
                /* Parse the Error from AWS */
                Dom.Document doc      = res.getBodyDocument();
                Dom.XMLNode errorNode = doc.getRootElement();
                AWS.ServiceException ex = new AWS.ServiceException( errorNode );
                /*System.debug('Error Code \n '+ ex.Code );
                System.debug('Error Message \n '+ ex.Message );
                System.debug('Error Resource \n '+ ex.Resource );
                System.debug('Error RequestId \n '+ ex.RequestId );
                */
                AWS_Exception__c exceptionRecord = new AWS_Exception__c();
                exceptionRecord.ErrorCode__c = ex.Code;
                exceptionRecord.Message__c   = ex.Message;
                exceptionRecord.Resource__c  = ex.Resource;
                exceptionRecord.RecordId__c  = recordId;
                exceptionRecord.FileId__c    = versionData.Id;
                exceptionRecord.FileTitle__c = versionData.Title;
                insert exceptionRecord;
            }
        }catch(System.CalloutException ex){
            // catch the Exception here
            String errorMessage = ex.getStackTraceString();
            System.debug('errorMessage \n '+ errorMessage);
        }
    }

    public string ContentType(String fileType) {
        switch on fileType.toLowerCase() {
            when 'aac' {
                return 'audio/aac';
            }
            when 'abw' {
                return 'application/x-abiword';
            }
            when 'arc' {
                return 'application/x-freearc';
            }
            when 'avi' {
                return 'video/x-msvideo';
            }
            when 'azw' {
                return 'application/vnd.amazon.ebook';
            }
            when 'bin' {
                return 'application/octet-stream';
            }
            when 'bmp' {
                return 'image/bmp';
            }
            when 'bz' {
                return 'application/x-bzip';
            }
            when 'bz2' {
                return 'application/x-bzip2';
            }
            when 'cda' {
                return 'application/x-cdf';
            }
            when 'csh' {
                return 'application/x-csh';
            }
            when 'css' {
                return 'text/css';
            }
            when 'csv' {
                return 'text/csv';
            }
            when 'doc' {
                return 'application/msword';
            }
            when 'docx' {
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            }
            when 'eot' {
                return 'application/vnd.ms-fontobject';
            }
            when 'epub' {
                return 'application/epub+zip';
            }
            when 'gz' {
                return 'application/gzip';
            }
            when 'gif' {
                return 'image/gif';
            }
            when 'htm', 'html' {
                return 'application/x-csh';
            }
            when 'ico' {
                return 'image/vnd.microsoft.icon';
            }
            when 'ics' {
                return 'text/calendar';
            }
            when 'jar' {
                return 'application/java-archive';
            }
            when 'jpeg', 'jpg' {
                return 'image/jpeg';
            }
            when 'js' {
                return 'text/javascript';
            }
            when 'json' {
                return 'application/json';
            }
            when 'jsonld' {
                return 'application/ld+json';
            }
            when 'mjs' {
                return 'text/javascript';
            }
            when 'mp3' {
                return 'audio/mpeg';
            }
            when 'mp4' {
                return 'video/mp4';
            }
            when 'mpeg' {
                return 'video/mpeg';
            }
            when 'mpkg' {
                return 'application/vnd.apple.installer+xml';
            }
            when 'odp' {
                return 'application/vnd.oasis.opendocument.presentation';
            }
            when 'ods' {
                return 'application/vnd.oasis.opendocument.spreadsheet';
            }
            when 'odt' {
                return 'application/vnd.oasis.opendocument.text';
            }
            when 'png' {
                return 'image/png';
            }
            when 'pdf' {
                return 'application/pdf';
            }
            when 'php' {
                return 'application/x-httpd-php';
            }
            when 'ppt' {
                return 'application/vnd.ms-powerpoint';
            }
            when 'pptx' {
                return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
            }
            when 'rar' {
                return 'application/vnd.rar';
            }
            when 'rtf' {
                return 'application/rtf';
            }
            when 'sh' {
                return 'application/x-sh';
            }
            when 'svg' {
                return 'image/svg+xml';
            }
            when 'swf' {
                return 'application/x-shockwave-flash';
            }
            when 'tar' {
                return 'application/x-tar';
            }
            when 'tif', 'tiff' {
                return 'image/tiff';
            }
            when 'ts' {
                return 'video/mp2t';
            }
            when 'ttf' {
                return 'font/ttf';
            }
            when 'txt' {
                return 'text/plain';
            }
            when 'vsd' {
                return 'application/vnd.visio';
            }
            when 'wav' {
                return 'audio/wav';
            }
            when 'weba' {
                return 'audio/webm';
            }
            when 'webm' {
                return 'video/webm';
            }
            when 'xls' {
                return 'application/vnd.ms-excel';
            }
            when 'xlsx' {
                return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
            }
            when 'xml' {
                return 'application/xml';
            }
            when 'zip' {
                return 'application/zip';
            }
            when '7z' {
                return 'application/x-7z-compressed';
            }
            when else {
                return 'image/jpeg';
            }
        }
    }


    @TestVisible
    private void contentTypeTest(){
        List<String> mimeTypeList = new List<String>{ 'aac', 'abw', 'arc', 'avi', 'azw', 'bin', 'bmp', 'bz', 'bz2',
            'cda', 'csh', 'css', 'csv', 'doc', 'docx', 'eot', 'epub', 'gz', 'gif', 'htm', 'ico', 'ics', 'jar', 'jpeg',
            'js', 'json', 'jsonld', 'mid', 'mjs', 'mp3', 'mp4', 'mpeg', 'mpkg', 'odp', 'ods', 'odt', 'oga', 'ogv', 'ogx',
            'opus', 'otf', 'png', 'pdf', 'php', 'ppt', 'pptx', 'rar', 'rtf', 'sh', 'svg', 'swf', 'tar', 'tif', 'ts', 'ttf',
            'txt', 'vsd', 'wav', 'weba', 'webm', 'webp', 'woff', 'woff2', 'xhtml', 'xls', 'xlsx', 'xml', 'xul', 'zip', '3gp',
            '3g2', '7z'
        };
        for(String mimeType : mimeTypeList){
            ContentType(mimeType);
        }
    }
}