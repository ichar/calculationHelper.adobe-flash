package main
{
    // Created:      22.01.2014
    // Created by:   I.E.Kharlamov

    public class logService
    {
        public  var lastLogRecord:String = new String(""); /* last record */
        public  var allLogRecords:String = new String(""); /* all records */

        private var parent:Object;

        public function logService(parentObjRef:Object):void
        {
            this.parent = parentObjRef;
        }

        public function setNewLogRecord(errIsSeries:Boolean, errCode:Number, errMessage:String):void
        {
            var message:String = errMessage == null ? "null" : errMessage;

            if (!message) return;

            message = this.parent.replaceQuotedValues(message);

            this.lastLogRecord = this.parent.getTimeAndDateAsString("Date and Time") + " " + message;
            this.parent.setSystemMessage(errIsSeries, errCode, message);
        }
    }
}

