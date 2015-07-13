package main
{
    // Created:      12.06.2014
    // Created by:   I.E.Kharlamov

    public class errorService
    {
        //
        // The errorService class need the progStart reference.
        //

        public  var additionalErrorMessage:String = new String("");
        /*
        private var ERRORS_DESCRIPTION:Object =
        {
             '-1' : 'ConfirmMessageForm.rejectButtonPressed',
             '-2' : 'CalculatingService.calculate = Incorect service version',
             '-3' : 'CalculatingService.calculate = Script's helperErrorCode',
             '-4' : 'XmlService = ',
             '-5' : 'XmlService = ',
             '-6' : 'XmlService = ',
             '-7' : 'XmlService = ',
             '-8' : 'RequestService.initState = ',
             '-9' : 'Main.setXMLRequest = Invalid request items',
            '-10' : 'CalculatingService.getQueryResultContent = Invalid response content',
            '-11' : 'RequestService.sendRequest = Incorrect request type',
            '-12' : 'RequestService.queryInitCompleteHandler = Exception',
            '-13' : 'RequestService.queryInitCompleteHandler = Empty AuthCode',
            '-14' : 'RequestService.queryXMLCompleteHandler = Exception',
            '-15' : 'RequestService.securityErrorHandler = SecurityErrorEvent',
            '-16' : 'RequestService.ioErrorHandler = IOErrorEvent',
            '-17' : 'CalculatingService.getQueryResultContent = Exception',
            '-18' : 'CalculatingService.getQueryResultContent = Invalid Helper Exchange Declaration',
            '-19' : 'CalculatingService.getQueryResultContent = Incorrect Response',
            '-20' : 'CalculatingService.getQueryResultContent = WebService Error (1C)',
            '-21' : '',
            '-22' : 'CalculatingService.getQueryResultContent = Errors recieved form responser',
            '-34' : '',
            '-36' : 'CalculatingService.getQueryResultContent = Response is empty',
            '-90' : 'RequestService.expired_loading_timeout = Timeout is expired',
           '-299' : 'RequestService.queryXMLCompleteHandler = System Event error',
          '-1000' : 'CalculatingService.calculate = D.eval exception (Fatal Error)'
        };
        */
        private var parent:Object;
        private var initMessage:String = new String("");

        /* -------------------------- */
           include "../lib/utils.as";
        /* -------------------------- */

        public function errorService(parentObjRef:Object)
        {
            this.parent = parentObjRef;
        }

        public function initState():void
        {
            this.initMessage = this.parent.msgArray[8];
        }

        public function errorAnalyser(errIsSeries:Boolean, errCode:Number):void
        {
            var message:String = new String("");
            var code:Number = new Number(0);

            if (!errCode)
            {
                this.parent.setSystemMessage(errIsSeries, 0, "");
            }
            else
            {
                code = Math.abs(errCode);

                message = code < this.parent.errMsgArray.length ? 
                    (code > 3 ? "(" + code.toString() + ") " : "") + this.parent.errMsgArray[code] : 
                    this.initMessage;

                if (code > 0)
                {
                    if ([90, 99, 199, 299].indexOf(code) > -1)
                    {
                        this.parent.errorStatus = code;
                        message = this.parent.errMsgArray[21];
                    }
                    else if ([27, 28, 29].indexOf(code) > -1)
                    {
                        this.parent.errorStatus = code;
                        message = this.additionalErrorMessage;
                    }
                    else if (this.additionalErrorMessage)
                    {
                        message = strip(message);
                        if (code == 3 && !message)
                            message = this.parent.msgArray[18];
                        if (code == 22 && !message)
                            message = this.parent.msgArray[18] + this.parent.msgArray[13];
                        if (message)
                            message += "<br>";
                        message += this.additionalErrorMessage;
                    }

                    this.parent.LogService.setNewLogRecord(errIsSeries, errCode, message);
                }
            }

            this.additionalErrorMessage = "";
        }

        public function fatalErrID():Number
        {
            return -1000;
        }
    }
}

