package main
{
    // Created:      14.09.2014
    // Created by:   I.E.Kharlamov

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.text.StyleSheet;

    import tools.myConstruct;

    public class xmlService
    {
        public   var currentErrorCode:Number = new Number(0);
        public   var parent:Object;

        private  var commonConfiguratorsLoader:URLLoader = new URLLoader(); /*    Common configurators list       */
        private  var localConfiguratorsLoader:URLLoader = new URLLoader();  /*    Localized configurators list    */

        private  var constantsLoader:URLLoader = new URLLoader();  /*    Constants   */
        private  var messagesLoader:URLLoader = new URLLoader();   /*    Messages    */
        private  var errorsLoader:URLLoader = new URLLoader();     /*    Errors      */
        private  var buttonsLoader:URLLoader = new URLLoader();    /*    Buttons     */
        private  var stylesLoader:URLLoader = new URLLoader();     /*    Styles      */
        private  var unitsLoader:URLLoader = new URLLoader();      /*    Units       */
        private  var currenciesLoader:URLLoader = new URLLoader(); /*    Currencies  */
        private  var scriptLoader:URLLoader = new URLLoader();     /*    Script      */
        private  var functionsLoader:URLLoader = new URLLoader();  /*    Functions   */
        private  var formLoader:URLLoader = new URLLoader();       /*    Form        */
        private  var contentLoader:URLLoader = new URLLoader();    /*    Content     */
        private  var constructLoader:URLLoader = new URLLoader();  /*    Construct   */

        private  var commonConfiguratorsRequest:URLRequest = new URLRequest();
        private  var localConfiguratorsRequest:URLRequest = new URLRequest();
        private  var constantsRequest:URLRequest = new URLRequest();
        private  var messagesRequest:URLRequest = new URLRequest();
        private  var errorsRequest:URLRequest = new URLRequest();
        private  var buttonsRequest:URLRequest = new URLRequest();
        private  var stylesRequest:URLRequest = new URLRequest();
        private  var unitsRequest:URLRequest = new URLRequest();
        private  var currenciesRequest:URLRequest = new URLRequest();
        private  var functionsRequest:URLRequest = new URLRequest();
        private  var scriptRequest:URLRequest = new URLRequest();
        private  var formRequest:URLRequest = new URLRequest();
        private  var contentRequest:URLRequest = new URLRequest();
        private  var constructRequest:URLRequest = new URLRequest();

        private  var constructLocations:Array = new Array();

        private  var stylesLocations:Array = new Array();
        private  var stylesPointer:Number = 0;

        /* -------------------------- */
           include "../lib/utils.as";
        /* -------------------------- */

        public function xmlService(parentObjRef:Object)
        {
            this.parent = parentObjRef;
            this.currentErrorCode = 0;
        }

        public function initState():void
        {
            var url:String = new String("");
            var path:String = new String("");
            var locale:String = new String("");
            var link:String = new String("");

            this.commonConfiguratorsLoader.addEventListener(Event.COMPLETE, completeCommonConfigHandler);
            this.commonConfiguratorsLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            this.commonConfiguratorsLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            this.localConfiguratorsLoader.addEventListener(Event.COMPLETE, completeLocalConfigHandler);
            this.localConfiguratorsLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            this.localConfiguratorsLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            this.constantsLoader.addEventListener(Event.COMPLETE, completeConstantsHandler);
            this.constantsLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            this.constantsLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            this.messagesLoader.addEventListener(Event.COMPLETE, completeMessagesHandler);
            this.messagesLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            this.messagesLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            this.errorsLoader.addEventListener(Event.COMPLETE, completeErrorsHandler);
            this.errorsLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            this.errorsLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            this.buttonsLoader.addEventListener(Event.COMPLETE, completeButtonsHandler);
            this.buttonsLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            this.buttonsLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            this.unitsLoader.addEventListener(Event.COMPLETE, completeUnitsHandler);
            this.unitsLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            this.unitsLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            this.currenciesLoader.addEventListener(Event.COMPLETE, completeCurrenciesHandler);
            this.currenciesLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            this.currenciesLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            this.scriptLoader.addEventListener(Event.COMPLETE, completeScriptHandler);
            this.scriptLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            this.scriptLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            this.functionsLoader.addEventListener(Event.COMPLETE, completeFunctionsHandler);
            this.functionsLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            this.functionsLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            this.formLoader.addEventListener(Event.COMPLETE, completeFormHandler);
            this.formLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            this.formLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            this.contentLoader.addEventListener(Event.COMPLETE, completeContentHandler);
            this.contentLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            this.contentLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            path = this.parent.helperURI + this.parent.helperPathURI;
            locale = this.parent.helperLocalization.toLowerCase();
            link = this.parent.getNewLink();

            url = path + "configurators/configurators_comm.xml" + link;
            this.commonConfiguratorsRequest.url = url;

            url = path + locale + "/configurators_local.xml" + link;
            this.localConfiguratorsRequest.url = url;

            url = path + "configurators/constants.xml" + link;
            this.constantsRequest.url = url;

            url = path + locale + "/messages.xml" + link;
            this.messagesRequest.url = url;

            url = path + locale + "/errors.xml" + link;
            this.errorsRequest.url = url;

            url = path + locale + "/buttons.xml" + link;
            this.buttonsRequest.url = url;

            this.parent.cisUnitsURL = this.parent.helperURI + "references/" + locale + "/units.xml" + link;
            this.unitsRequest.url = this.parent.cisUnitsURL;

            this.parent.cisCurrenciesURL = this.parent.helperURI + "references/" + locale + "/currencies.xml" + link;
            this.currenciesRequest.url = this.parent.cisCurrenciesURL;

            url = path + "configurators/functions.txt" + link;
            this.functionsRequest.url = url;

            this.currentErrorCode = 0;

            try
            {
                this.commonConfiguratorsLoader.load(commonConfiguratorsRequest);
                this.localConfiguratorsLoader.load(localConfiguratorsRequest);

                this.constantsLoader.load(constantsRequest);
                this.buttonsLoader.load(buttonsRequest);
                this.unitsLoader.load(unitsRequest);
                this.currenciesLoader.load(currenciesRequest);

                this.functionsLoader.load(functionsRequest);
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
            }
        }

        protected function loadStylesHandler():void
        {
            this.stylesLoader.addEventListener(Event.COMPLETE, completeStylesHandler);
            this.stylesLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            this.stylesLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorStyleHandler);

            this.currentErrorCode = 0;

            try
            {
                this.stylesRequest.url = this.stylesLocations[this.stylesPointer];
                this.stylesLoader.load(this.stylesRequest);
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
            }
        }

        protected function loadConstructHandler(code:Number=0):void
        {
            if (this.constructLocations.length == 0)
            {
                this.parent.letsGo("Construct", code);
                return;
            }

            this.constructLoader.addEventListener(Event.COMPLETE, completeConstructHandler);
            this.constructLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            this.constructLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorConstructHandler);

            this.currentErrorCode = 0;

            try
            {
                this.constructRequest.url = this.constructLocations.shift();
                this.constructLoader.load(this.constructRequest);
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
            }
        }

        private function completeCommonConfigHandler(myEvent:Event):void
        {
            var loader:URLLoader = URLLoader(myEvent.target);
            var content:XML = new XML();
            var code:Number = new Number(0);
            var isOk:Boolean = new Boolean(false);
            var s:String = new String("");
            var url:String = new String();

            var path:String = this.parent.helperURI + this.parent.helperPathURI;
            var locale:String = this.parent.helperLocalization.toLowerCase();
            var link:String = this.parent.getNewLink();

            try
            {
                content = new XML(loader.data);

                this.parent.helperDUSCODE = content.configurator.(@id==this.parent.helperWizardID).field.(@name=="DusCode");
                this.parent.helperScriptLocation = content.configurator.(@id==this.parent.helperWizardID).field.(@name=="URI");
                this.parent.helperModelVersion = content.configurator.(@id==this.parent.helperWizardID).field.(@name=="ModelVersion");

                s = content.configurator.(@id==this.parent.helperWizardID).field.(@name=="XMLVersion");
                this.parent.helperXMLVersion = !s ? '1' : s;

                this.parent.emptyIllustration = content.configurator.(@id=="smallEmptyImageURI").field.(@name=="URI");

                var color:String = content.configurator.(@id==this.parent.helperWizardID).field.(@name=="BackgroundColor");
                if (color)
                    this.parent.globalAttrs.background_color = color;

                this.parent.helperPathURI = content.configurator.(@id=="HelperURI").field.(@name=="URI");
                this.parent.helperExchangeURI = content.configurator.(@id=="ExternalURI").field.(@name=="URI");

                var email:String = new String("");
                s = content.configurator.(@id==this.parent.helperWizardID).field.(@name=="Cc") + ',' + content.configurator.(@id=="OrderEmail").field.(@name=="Cc");
                for each (s in s.split(','))
                {
                    s = strip(s);
                    if (s) email += (email ? ', ' : '') + s;
                }
                this.parent.helperOrderEmail = email;

                isOk = (content.system.@id.toString()=="CIS");
                isOk = ((isOk) && (content.task.@id.toString()=="CALCHELPER"));
                isOk = ((isOk) && (Number(content.task.@version.toString()) <= Number(this.parent.helperLoadedVersion)));
                isOk = ((isOk) && (content.description.@id.toString()=="Configurators"));
                isOk = ((isOk) && (content.description.@version.toString()=="1"));

                code = isOk ? 1 : -2;

                if (isOk)
                {
                    // ----------------------------
                    // Scripts/Form/Content loading
                    // ----------------------------

                    url = path + this.parent.helperScriptLocation + "script.txt" + link;
                    this.scriptRequest.url = url;

                    url = path + this.parent.helperScriptLocation + "form.xml" + link;
                    this.formRequest.url = url;

                    url = path + locale + "/" + this.parent.helperScriptLocation + "content.xml" + link;
                    this.contentRequest.url = url;

                    this.scriptLoader.load(scriptRequest);
                    this.formLoader.load(formRequest);
                    this.contentLoader.load(contentRequest);
                }
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                code = -4;
            }

            if (code < 0)
            {
                this.parent.letsGo("Script", -5);
                this.parent.letsGo("Form", -5);
                this.parent.letsGo("Content", -5);
            } 

            // --------------------------------------------
            // Construct loading (local or global location)
            // --------------------------------------------

            this.constructLocations[0] = path + "configurators/valid-construct.xml" + link;
            this.constructLocations[1] = path + this.parent.helperScriptLocation + "local-valid-construct.xml" + link;

            this.loadConstructHandler();

            // -----------------------------------------
            // Styles loading (local or global location)
            // -----------------------------------------
            
            s = "styles_" + this.parent.helperStyleID + ".xml" + link;

            this.stylesLocations[0] = path + this.parent.helperScriptLocation + s;
            this.stylesLocations[1] = path + s;
            this.stylesPointer = 0;

            this.loadStylesHandler();

            this.parent.letsGo("commonConfig", code);
        }

        private function completeLocalConfigHandler(myEvent:Event):void
        {
            var loader:URLLoader = URLLoader(myEvent.target);
            var content:XML = new XML();
            var code:Number = new Number(0);
            var isOk:Boolean = new Boolean(false);

            try
            {
                content = new XML(loader.data);
                /*
                this.parent.helperDefaultName = content.configurator.(@id=="SerialSectionalDoors").field.(@name=="HelperName");
                this.parent.helperDefaultCurrency = content.configurator.(@id=="SerialSectionalDoors").field.(@name=="defaultCurrencyID");
                */
                this.parent.helperDefaultName = content.configurator.(@id==this.parent.helperWizardID).field.(@name=="HelperName");
                this.parent.helperDefaultCurrency = content.configurator.(@id==this.parent.helperWizardID).field.(@name=="defaultCurrencyID");

				this.parent.setHelperTitle();

                isOk = (content.system.@id.toString()=="CIS");
                isOk = ((isOk) && (content.task.@id.toString()=="CALCHELPER"));
                isOk = ((isOk) && (Number(content.task.@version.toString()) <= Number(this.parent.helperLoadedVersion)));
                isOk = ((isOk) && (content.description.@id.toString()=="Configurators"));
                isOk = ((isOk) && (content.description.@version.toString()=="1"));
                isOk = ((isOk) && (content.lanquage.@id.toString().toUpperCase()==this.parent.helperLocalization));

                code = isOk ? 1 : -2;
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                code = -4;
            }

            this.parent.letsGo("localConfig", code);
        }

        private function completeConstantsHandler(myEvent:Event):void
        {
            var loader:URLLoader = URLLoader(myEvent.target);
            var content:XML = new XML();
            var code:Number = new Number(0);
            var record:XML = new XML();
            var s:String = new String();
            var isOk:Boolean = new Boolean(false);

            try
            {
                content = new XML(loader.data);

                for each (record in content.record)
                {
                    s = record.@id.toString();
                    this.parent.helperKeyWords[s] = record.toString();
                }

                isOk = (content.system.@id.toString()=="CIS");
                isOk = ((isOk) && (content.task.@id.toString()=="CALCHELPER"));
                isOk = ((isOk) && (Number(content.task.@version.toString()) <= Number(this.parent.helperLoadedVersion)));
                isOk = ((isOk) && (content.description.@id.toString()=="Constants"));
                isOk = ((isOk) && (content.description.@version.toString()=="1"));

                code = isOk ? 1 : -2;

                if (isOk)
                {
                    this.messagesLoader.load(this.messagesRequest);
                    this.errorsLoader.load(this.errorsRequest);
                }
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                code = -4;
            }

            this.parent.letsGo("Constants", code);

            if (code < 0)
            {
                this.parent.letsGo("Messages", -4);
                this.parent.letsGo("Errors", -4);
                this.parent.letsGo("Buttons", -4);
            }
        }

        private function completeMessagesHandler(myEvent:Event):void
        {
            var loader:URLLoader = URLLoader(myEvent.target);
            var content:XML = new XML();
            var code:Number = new Number(0);
            var record:XML = new XML();
            var i:Number = new Number(0);
            var s:String = new String();
            var id:String = new String();
            var items:Array = new Array();
            var isOk:Boolean = new Boolean(true);

            try
            {
                content = new XML(loader.data);

                for each (record in content.message)
                {
                    s = record.toString();
                    items = s.split(this.parent.helperKeyWords["spaceUnit"]);
                    s = items.join(" ");

                    id = record.@id.toString();
                    i = Number(id);

                    if (isNaN(i))
                    {
                        isOk = false;
                        i = 3000;
                    }

                    this.parent.msgArray[i] = s;
                }

                isOk = ((isOk) && (content.system.@id.toString()=="CIS"));
                isOk = ((isOk) && (content.task.@id.toString()=="CALCHELPER"));
                isOk = ((isOk) && (Number(content.task.@version.toString()) <= Number(this.parent.helperLoadedVersion)));
                isOk = ((isOk) && (content.description.@id.toString()=="Messages"));
                isOk = ((isOk) && (content.description.@version.toString()=="1"));
                isOk = ((isOk) && (content.lanquage.@id.toString().toUpperCase()==this.parent.helperLocalization));

                code = isOk ? 1 : -2;
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                code = -4;
            }

            this.parent.letsGo("Messages", code);
        }

        private function completeErrorsHandler(myEvent:Event):void
        {
            var loader:URLLoader = URLLoader(myEvent.target);
            var content:XML = new XML();
            var code:Number = new Number(0);
            var record:XML = new XML();
            var i:Number = new Number(0);
            var s:String = new String();
            var id:String = new String();
            var items:Array = new Array();
            var isOk:Boolean = new Boolean(true);

            try
            {
                content = new XML(loader.data);

                for each (record in content.error)
                {
                    s = record.toString();
                    items = s.split(this.parent.helperKeyWords["spaceUnit"]);
                    s = items.join(" ");

                    id = record.@id.toString();
                    i = Number(id);

                    if (isNaN(i))
                    {
                        isOk = false;
                        i = 3000;
                    }

                    this.parent.errMsgArray[i] = s;
                }

                isOk = ((isOk) && (content.system.@id.toString()=="CIS"));
                isOk = ((isOk) && (content.task.@id.toString()=="CALCHELPER"));
                isOk = ((isOk) && (Number(content.task.@version.toString()) <= Number(this.parent.helperLoadedVersion)));
                isOk = ((isOk) && (content.description.@id.toString()=="Errors"));
                isOk = ((isOk) && (content.description.@version.toString()=="1"));
                isOk = ((isOk) && (content.lanquage.@id.toString().toUpperCase()==this.parent.helperLocalization));

                code = isOk ? 1 : -2;
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                code = -4;
            }

            this.parent.letsGo("Errors", code);
        }

        private function completeButtonsHandler(myEvent:Event):void
        {
            var loader:URLLoader = URLLoader(myEvent.target);
            var content:XML = new XML();
            var code:Number = new Number(0);
            var record:XML = new XML();
            var s:String = new String();
            var id:String = new String();
            var items:Array = new Array();
            var isOk:Boolean = new Boolean(true);

            try
            {
                content = new XML(loader.data);

                for each (record in content.button)
                {
                    s = record.toString();
                    items = s.split(this.parent.helperKeyWords["spaceUnit"]);
                    s = items.join(" ");

                    id = record.@id.toString();

                    this.parent.namesOfButtons[id] = s;

                    s = record.@state.toString();
                    this.parent.visibleButtons[id] = Boolean(Number(s));

                    s = record.@actionID.toString();
                    this.parent.actionButtons[id] = s;
                }

                isOk = ((isOk) && (content.system.@id.toString()=="CIS"));
                isOk = ((isOk) && (content.task.@id.toString()=="CALCHELPER"));
                isOk = ((isOk) && (Number(content.task.@version.toString()) <= Number(this.parent.helperLoadedVersion)));
                isOk = ((isOk) && (content.description.@id.toString()=="Buttons"));
                isOk = ((isOk) && (content.description.@version.toString()=="1"));
                isOk = ((isOk) && (content.lanquage.@id.toString().toUpperCase()==this.parent.helperLocalization));

                code = isOk ? 1 : -2;
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                code = -4;
            }

            this.parent.letsGo("Buttons", code);
        }

        private function completeStylesHandler(myEvent:Event):void
        {
            var loader:URLLoader = URLLoader(myEvent.target);
            var content:XML = new XML();
            var code:Number = new Number(0);
            var record:XML = new XML();
            var s:String = new String();
            var id:String = new String();
            var isOk:Boolean = new Boolean(true);

            try
            {
                content = new XML(loader.data);

                for each (record in content.style)
                {
                    var myPatt:RegExp = new RegExp();

                    s = record.toString();
                    myPatt = /(\t|\r|\n)/g;
                    s = s.replace(myPatt, "");

                    id = record.@id.toString();

                    if (Number(record.@type.toString())==0)
                    {
                        this.parent.styleSheetList[id] = new StyleSheet();
                        this.parent.styleSheetList[id].parseCSS(s);
                    }
                    else
                    {
                        this.parent.labelsStyleList[id] = s;
                    }
                }

                isOk = ((isOk) && (content.system.@id.toString()=="CIS"));
                isOk = ((isOk) && (content.task.@id.toString()=="CALCHELPER"));
                isOk = ((isOk) && (Number(content.task.@version.toString()) <= Number(this.parent.helperLoadedVersion)));
                isOk = ((isOk) && (content.description.@id.toString()=="Styles"));
                isOk = ((isOk) && (content.description.@version.toString()=="1"));

                code = isOk ? 1 : -2;
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                code = -4;
            }

            this.parent.letsGo("Styles", code);
        }

        private function completeUnitsHandler(myEvent:Event):void
        {
            var loader:URLLoader = URLLoader(myEvent.target);
            var content:XML = new XML();
            var code:Number = new Number(0);
            var record:XML = new XML();
            var s:String = new String();
            var id:String = new String();
            var isOk:Boolean = new Boolean(true);

            try
            {
                content = new XML(loader.data);

                for each (record in content.unit)
                {
                    s = record.toString();
                    id = record.@numCode.toString();
                    this.parent.unitsNameList[id] = s;
                }

                isOk = ((isOk) && (content.system.@id.toString()=="CIS"));
                isOk = ((isOk) && (content.task.@id.toString()=="CALCHELPER"));
                isOk = ((isOk) && (Number(content.task.@version.toString()) <= Number(this.parent.helperLoadedVersion)));
                isOk = ((isOk) && (content.description.@id.toString()=="Units"));
                isOk = ((isOk) && (content.description.@version.toString()=="1"));
                isOk = ((isOk) && (content.lanquage.@id.toString().toUpperCase()==this.parent.helperLocalization));

                code = isOk ? 1 : -2;
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                code = -4;
            }

            this.parent.letsGo("Units", code);
        }

        private function completeCurrenciesHandler(myEvent:Event):void
        {
            var loader:URLLoader = URLLoader(myEvent.target);
            var content:XML = new XML();
            var code:Number = new Number(0);
            var record:XML = new XML();
            var s:String = new String();
            var id:String = new String();
            var isOk:Boolean = new Boolean(true);

            try
            {
                content = new XML(loader.data);

                for each (record in content.currency)
                {
                    s = record.toString();
                    id = record.@numCode.toString();

                    this.parent.currenciesNameList[id] = s;
                }

                isOk = ((isOk) && (content.system.@id.toString()=="CIS"));
                isOk = ((isOk) && (content.task.@id.toString()=="CALCHELPER"));
                isOk = ((isOk) && (Number(content.task.@version.toString()) <= Number(this.parent.helperLoadedVersion)));
                isOk = ((isOk) && (content.description.@id.toString()=="Currencies"));
                isOk = ((isOk) && (content.description.@version.toString()=="1"));
                isOk = ((isOk) && (content.lanquage.@id.toString().toUpperCase()==this.parent.helperLocalization));

                code = isOk ? 1 : -2;
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                code = -4;
            }

            this.parent.letsGo("Currencies", code);
        }

        private function completeScriptHandler(myEvent:Event):void
        {
            var loader:URLLoader = URLLoader(myEvent.target);
            var content:XML = new XML();
            var code:Number = new Number(0);
            var record:XML = new XML();
            var s:String = new String();
            var id:String = new String();
            var isOk:Boolean = new Boolean(true);

            try
            {
                this.parent.helperScriptContent = loader.data;
                code = 1;
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                code = -4;
            }

            this.parent.letsGo("Script", code);
        }

        private function completeFunctionsHandler(myEvent:Event):void
        {
            var loader:URLLoader = URLLoader(myEvent.target);
            var content:XML = new XML();
            var code:Number = new Number(0);
            var record:XML = new XML();
            var s:String = new String();
            var id:String = new String();
            var isOk:Boolean = new Boolean(true);

            try
            {
                this.parent.helperScriptFunction = loader.data;
                code = 1;
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                code = -4;
            }

            this.parent.letsGo("Function", code);
        }

        private function completeFormHandler(myEvent:Event):void
        {
            var loader:URLLoader = URLLoader(myEvent.target);
            var code:Number = new Number(0);
            var isOk:Boolean = new Boolean(true);

            try
            {
                this.parent.formXML = new XML(loader.data);

                isOk = (this.parent.formXML.system.@id.toString()=="CIS");
                isOk = ((isOk) && (this.parent.formXML.task.@id.toString()=="CALCHELPER"));
                isOk = ((isOk) && (Number(this.parent.formXML.task.@version.toString()) <= Number(this.parent.helperLoadedVersion)));
                isOk = ((isOk) && (this.parent.formXML.description.@id.toString()==this.parent.helperWizardID));
                /*
                isOk = ((isOk) && (this.parent.formXML.description.@version.toString()=="2"));
                */

                code = isOk ? 1 : -2;
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                code = -4;
            }

            this.parent.letsGo("Form", code);
        }

        private function completeContentHandler(myEvent:Event):void
        {
            var loader:URLLoader = URLLoader(myEvent.target);
            var code:Number = new Number(0);
            var isOk:Boolean = new Boolean(true);

            try
            {
                this.parent.contentXML = new XML(loader.data);

                isOk = (this.parent.contentXML.system.@id.toString()=="CIS");
                isOk = ((isOk) && (this.parent.contentXML.task.@id.toString()=="CALCHELPER"));
                isOk = ((isOk) && (Number(this.parent.contentXML.task.@version.toString()) <= Number(this.parent.helperLoadedVersion)));
                isOk = ((isOk) && (this.parent.contentXML.description.@id.toString()==this.parent.helperWizardID));
                /*
                isOk = ((isOk) && (this.parent.contentXML.description.@version.toString()=="2"));
                */
                isOk = ((isOk) && (this.parent.contentXML.lanquage.@id.toString().toUpperCase()==this.parent.helperLocalization));

                code = isOk ? 1 : -2;
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                code = -4;
            }

            this.parent.letsGo("Content", code);
        }

        private function completeConstructHandler(myEvent:Event):void
        {
            var loader:URLLoader = URLLoader(myEvent.target);
            var constructs:Object = this.parent.helperConstructs;
            var content:XML = new XML();
			var record:XML = new XML();
            var code:Number = new Number(0);
            var isOk:Boolean = new Boolean(true);
            var ob:Object = new Object();
            var id:String = new String("");
            var name:String = new String("");

            try
            {
                content = new XML(loader.data);

                for each (record in content.construct)
                {
                    id = record.@id.toString();
                    ob = new myConstruct(this, id);
                    ob.initState(record);

                    if (!(ob.active() && ob.enabled))
                        continue;

                    name = ob.name;

                    if (!(name in constructs))
                        constructs[name] = [];

                    constructs[name].push({'value':ob.value, 'region':ob.region, 'condition':ob.condition});
                }

                this.parent.helperConstructs = constructs;

                isOk = (content.system.@id.toString()=="CIS");
                isOk = ((isOk) && (content.task.@id.toString()=="CALCHELPER"));
                isOk = ((isOk) && (Number(content.task.@version.toString()) <= Number(this.parent.helperLoadedVersion)));

                code = isOk ? 1 : -2;

                this.loadConstructHandler(code);
            }
            catch(errorNum:Error)
            {
                this.currentErrorCode = this.parent.ErrorService.fatalErrID();
                this.parent.ErrorService.additionalErrorMessage = errorNum.message;
                code = -4;
            }
        }

        private function securityErrorHandler(myEvent:SecurityErrorEvent):void
        {
            this.currentErrorCode = this.parent.ErrorService.fatalErrID();
            this.parent.ErrorService.additionalErrorMessage = myEvent.text;

            this.parent.letsGo("All", -6);
        }

        private function ioErrorHandler(myEvent:IOErrorEvent):void
        {
            this.currentErrorCode = this.parent.ErrorService.fatalErrID();
            this.parent.ErrorService.additionalErrorMessage = myEvent.text;

            this.parent.letsGo("All", -7);
        }

        private function ioErrorConstructHandler(myEvent:IOErrorEvent):void
        {
            this.loadConstructHandler(1);
        }

        private function ioErrorStyleHandler(myEvent:IOErrorEvent):void
        {
            if (this.stylesPointer < 1)
            {
                ++this.stylesPointer;
                this.loadStylesHandler();
            }
            else
                this.ioErrorHandler(myEvent);
        }
    }
}

