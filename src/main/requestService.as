package main
{
    // Created:      14.05.2015
    // Created by:   I.E.Kharlamov

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.external.ExternalInterface;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.utils.*;

    public class requestService
    {
        //
        // The requestService class need the progStart reference.
        //
        public   var currentType:String = new String("");        // Communication type (scenario)
        public   var currentURL:String = new String("");         // Request URL (only for http and https)
        public   var requestContent:String = new String("");     // Request content (request XML)
        public   var respondContent:String = new String("");     // Respond content (respond XML)
        public   var requestType:String = new String("");        // Current request type

        private  var queryLoader:URLLoader = new URLLoader();    // QUERY
        private  var queryRequest:URLRequest = new URLRequest();

        private  var isInternalReady:Boolean = new Boolean(false);
        private  var isExternalReady:Boolean = new Boolean(false);

        private  var parent:Object = new Object();
        private  var uid:uint = 0;

        private  var query_is_expired:Boolean = new Boolean(false);
        private  var QUERY_LOADING_TIMEOUT:Number = 30*1000;

        /* -------------------------- */
           include "../lib/utils.as";
        /* -------------------------- */

        public function requestService(parentObjRef:Object)
        {
            this.parent = parentObjRef;
        }

        public function initState():Number
        {
            var code:Number = new Number(0);
            var mode:String = this.currentType;
            var timeout:Number = this.parent.helperTimeout;

            if (timeout > 0)
                this.QUERY_LOADING_TIMEOUT = timeout*1000;

            switch(this.currentType)
            {
                case(this.parent.helperKeyWords["Internal"]):
                    code = this.initInternalService();
                    break;

                case(this.parent.helperKeyWords["External"]):
                    break;

                case(this.parent.helperKeyWords["Transfer"]):
                    code = this.initInternalService();
                    mode = this.parent.helperKeyWords["Internal"];
                    this.parent.isFirstTransfer = true;
                    break;

                default:
                    code = -8;
            }

            if (!code)
                code = this.sendRequest(mode);

            switch(this.currentType)
            {
                case(this.parent.helperKeyWords["Internal"]):
                    this.isInternalReady = (code == 0);
                case(this.parent.helperKeyWords["External"]):
                    this.isExternalReady = (code == 0);
            }

            return code;
        }

        public function reset():void
        {
            if (!this.parent.isTestMode)
                return;

            this.parent.isFirstCalculateAfterRespond = false;
            this.parent.currentHelperActionID = this.parent.action.action;
            this.parent.isFirstTransaction = true;

            this.parent.queryComplete();
        }

        // ---------------------------
        //  Request Service Functions
        // ---------------------------

        private function term_query_loading():void
        {
            clearInterval(this.uid);
            this.uid = 0;

            if (this.isExternalReady)
                this.termExternalService(queryInitCompleteHandler);
        }

        private function expired_loading_timeout():void
        {
            if (this.parent.queryProcessingState == 1)
            {
                this.query_is_expired = true;
                this.parent.ErrorService.additionalErrorMessage = this.parent.errMsgArray[25];
                this.processRequest(-90);
            }
        }

        private function is_auth_valid():Boolean
        {
            return this.parent.helperAuthData.hasOwnProperty('_c') && this.parent.helperAuthData._c ? true : false;
        }

        private function get_property(value:String):String
        {
            return value && value !== this.parent.n_a ? value : "";
        }

        private function complete_request():void
        {
            this.parent.executeAfterAction();

            if (this.parent.isTestMode)
                this.parent.queryComplete();
        }

        // ======
        //  MAIN
        // ======

        public function sendInitRequest():Number
        {
            var code:Number = new Number(0);
            var s:URLVariables = new URLVariables();

            if (this.is_auth_valid())
            {
                this.parent.queryProcessingState = code;
                this.complete_request();
                return code;
            }

            s.agent = "";
            s.ip = "";
            s.locale = this.get_property(this.parent.helperLocalization.toLowerCase());
            s.login = this.get_property(this.parent.helperAuthData.login);
            s.password = this.get_property(this.parent.helperAuthData.password);
            s.region = this.get_property(this.parent.helperPurchaseID);

            this.currentURL = this.parent.helperDomain + this.parent.helperInitURI;
            this.isExternalReady = false;

            this.initExternalService(queryInitCompleteHandler);

            this.requestType = 'InitRequest.' + this.currentType;
            this.parent.registryAction();

            with (this.queryRequest)
            {
                url = this.currentURL + this.parent.getNewLink();
                method = URLRequestMethod.POST;
                data = s;
            }

            this.parent.queryProcessingState = 1;
            this.queryLoader.load(this.queryRequest);

            if (this.parent.isTestMode)
                this.parent.action.url = this.queryRequest.url;

            return code;
        }

        public function sendRequest(mode:String=null):Number
        {
            var code:Number = new Number(0);
            var value:String = new String("");

            if (!mode)
                mode = this.currentType;
            value = this.parent.queryXML.toString();

            this.parent.errorStatus = 0;
            this.respondContent = '';
            this.query_is_expired = false;

            this.parent.helperProjectVars["changedFormFieldID"] = "";
            this.parent.setCalculatingEnabled(false);

            switch(mode)
            {
                case(this.parent.helperKeyWords["Internal"]):
                    this.currentURL = "callExchangeEvnt";
                    break;
                case(this.parent.helperKeyWords["External"]):
                    this.currentURL = this.parent.helperDomain + this.parent.helperExchangeURI;
                    break;
                default:
                    this.currentURL = '...';
            }
            
            this.requestType = 'Request.' + mode;
            this.parent.registryAction();

            switch(mode)
            {
                case(this.parent.helperKeyWords["Internal"]):
                    code = initInternalService();
                    if (code)
                        return code;

                    this.isInternalReady = true;

                    value = "<![CDATA[" + value + "]]>";

                    this.parent.queryProcessingState = 1;
                    ExternalInterface.call(this.currentURL, value);
                    break;

                case(this.parent.helperKeyWords["External"]):
                    code = initExternalService(queryXMLCompleteHandler);
                    if (code)
                        return code;

                    this.isExternalReady = true;

                    var s:URLVariables = new URLVariables();
                    s.queryDocument = value;

                    if (this.is_auth_valid())
                        s._c = this.parent.helperAuthData._c;

                    with (this.queryRequest)
                    {
                        url = this.currentURL + this.parent.getNewLink();
                        method = URLRequestMethod.POST;
                        data = s;
                    }

                    this.parent.queryProcessingState = 1;
                    this.queryLoader.load(this.queryRequest);
                    break;

                default:
                    code = -11;
            }

            if (this.parent.isTestMode)
                this.parent.action.url = this.currentURL;

            if (!code)
                this.uid = setInterval(this.expired_loading_timeout, this.QUERY_LOADING_TIMEOUT);

            return code;
        }

        public function backByHistory():Number
        {
            var code:Number = new Number(0);
            try
            {
                code = ExternalInterface.call("goBack");
            }
            catch(errorNum:Error)
            {
                code = -1;
            }
            return -1; //!isNaN(code) ? code : -1;
        }

        // =========================
        //  Query Response Handlers
        // =========================

        private function setCostValue():void
        {
            if (this.parent.cisCostValue && !isNaN(this.parent.cisCostValue))
                this.parent.costMessage = this.parent.cisCostValue + " " +
                    this.parent.currenciesNameList[this.parent.helperDefaultCurrency];
        }

        private function checkRequestError(code:Number):void
        {
            this.parent.queryProcessingState = code;
            this.parent.registryActionComplete();
            this.parent.ErrorService.errorAnalyser(false, code);
            this.parent.LogService.setNewLogRecord(true, 0, this.parent.helperProjectVars["NoticeMessage"]);
        }

        private function processRequest(code:Number):void
        {
            this.term_query_loading();

            this.checkRequestError(code);

            this.parent.respondXML = new XML(this.respondContent);

            if (!this.parent.isFirstCalculateAfterRespond)
            {
                this.parent.DisplayingService.initState();
                this.parent.isFirstCalculateAfterRespond = true;
            }

            this.setCostValue();

            if (this.parent.queryProcessingState == 0)
            {
                this.parent.calculate();
            }
            else
            {
                this.parent.display();
            }

            this.parent.executeAfterAction();

            if (this.parent.isTestMode)
                this.parent.queryComplete();
        }

        private function initInternalService():Number
        {
            var code:Number = new Number(0);
            var isOk:Boolean = new Boolean(false);
            var value:String = new String();
            var millisecafterStart:uint = 0;

            isOk = ExternalInterface.call("isJSReady");

            if (isOk && this.isInternalReady)
                return code;

            if (!isOk)
            {
                value = this.parent.getTimeAndDateAsString("millisecond");
                millisecafterStart = Number(value) + 1000;

                while(!isOk && millisecafterStart >= Number(value))
                {
                    isOk = ExternalInterface.call("isJSReady");
                    value = this.parent.getTimeAndDateAsString("millisecond");
                }
            }

            if (isOk)
                ExternalInterface.addCallback("sendFromJS", loadValueFromJSHandler);

            code = isOk ? 0 : -1;
            return code;
        }

        private function initExternalService(handler:Function=null):Number
        {
            var code:Number = new Number(0);

            if (!this.isExternalReady && handler !== null)
            {
                with (this.queryLoader)
                {
                    addEventListener(Event.COMPLETE, handler);
                    addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
                    addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
                }
            }

            return code;
        }

        private function termExternalService(handler:Function=null):void
        {
            if (handler !== null)
            {
                with (this.queryLoader)
                {
                    removeEventListener(Event.COMPLETE, handler);
                    removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
                    removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
                }
            }
        }

        private function queryInitCompleteHandler(myEvent:Event):void
        {
            var myLoader:URLLoader = URLLoader(myEvent.target);
            var code:Number = new Number(0);

            this.termExternalService(queryInitCompleteHandler);

            if (this.parent.queryProcessingState > 0)
            {
                try
                {
                    this.respondContent = myLoader.data;
                    if (this.respondContent)
                        this.parent.helperAuthData._c = strip(this.respondContent);
                    if (this.parent.isTestMode)
                        this.parent.action.response = "[" + this.parent.helperAuthData._c + "]";
                }
                catch(errorNum:Error)
                {
                    this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                    alert(errorNum.message, "Error = InitCompleteHandler");
                    code = -12;
                }
            }

            if (!(code || this.parent.helperAuthData._c)) {
                alert("[" + this.respondContent + "]", "Empty AuthCode = InitCompleteHandler");
                code = -13;
            }

            this.checkRequestError(code);

            this.complete_request();
        }

        private function queryXMLCompleteHandler(myEvent:Event):void
        {
            var myLoader:URLLoader = URLLoader(myEvent.target);
            var code:Number = new Number(0);
            var isOk:Boolean = new Boolean(true);
            var n:Number = new Number(0);

            if (this.parent.queryProcessingState > 0 || this.parent.queryProcessingState < -24)
            {
                try
                {
                    this.respondContent = myLoader.data;
                    n = this.respondContent.indexOf("<?xml");
                    if (n > 0) this.respondContent = this.respondContent.substr(n);

                    code = this.parent.CalculatingService.getQueryResultContent();
                }
                catch(errorNum:Error)
                {
                    this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                    code = -14;
                }
            } 
            else 
            {
                code = -299;

                var url:RegExp = /(URL:)\s+(http)/gi;
                this.parent.ErrorService.additionalErrorMessage = "[RequestService.queryXMLCompleteHandler:" + this.parent.queryProcessingState + "] " + 
                    this.parent.ErrorService.additionalErrorMessage.replace(url, "$1\n$2");
            }

            this.processRequest(code);
        }

        private function loadValueFromJSHandler(value:String):void
        {
            var code:Number = new Number(0);

            if (this.query_is_expired)
                return;

            this.respondContent = value;

            if (this.respondContent.length > 11)
            {
                this.respondContent = this.respondContent.substr(9);
                this.respondContent = this.respondContent.substr(0, (this.respondContent.length - 3));
            }

            code = this.parent.CalculatingService.getQueryResultContent();

            this.processRequest(code);
        }

        private function securityErrorHandler(myEvent:SecurityErrorEvent):void
        {
            var reload:Boolean = this.parent.queryProcessingState == 1 && this.isExternalReady;

            this.parent.ErrorService.additionalErrorMessage = myEvent.text;
            this.parent.queryProcessingState = -15;

            if (this.parent.isDebugMode)
                alert("[" + this.parent.queryProcessingState.toString() + "]" + myEvent.text, "SecurityErrorHandler");

            if (reload)
                this.queryXMLCompleteHandler(myEvent);
            else
                this.parent.executeAfterAction();
        }

        private function ioErrorHandler(myEvent:IOErrorEvent):void
        {
            var reload:Boolean = this.parent.queryProcessingState == 1 && this.isExternalReady;

            this.parent.ErrorService.additionalErrorMessage = myEvent.text;
            this.parent.queryProcessingState = -16;

            if (this.parent.isDebugMode)
                alert("[" + this.parent.queryProcessingState.toString() + "]" + myEvent.text, "IOErrorHandler");

            if (reload)
                this.queryXMLCompleteHandler(myEvent);
            else
                this.parent.executeAfterAction();
        }
    }
}

