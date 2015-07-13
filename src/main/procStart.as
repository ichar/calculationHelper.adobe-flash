package main
{
    // Created:      14.05.2015
    // Created by:   I.E.Kharlamov

    // Common Flex Classes
    import constructors.Calculator;
    import constructors.ConfirmMessageForm;
    import constructors.ErrorMessageForm;
    import constructors.OrderInfoForm;
    import constructors.ReportInfoForm;
    import constructors.UserInfoForm;
    
    import flash.display.Stage;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.external.ExternalInterface;
    import flash.system.Capabilities;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.utils.getTimer;
    
    import mx.containers.Box;
    import mx.controls.Alert;
    import mx.controls.Image;
    import mx.controls.TextArea;
    import mx.core.Application;
    import mx.core.UIComponent;
    import mx.managers.BrowserManager;
    import mx.managers.IBrowserManager;
    import mx.managers.PopUpManager;
    import mx.utils.URLUtil;
    
    import tools.myEventDispatcher;

    public class procStart
    {
        public  var product_version:String = new String("1.23.7");
        public  var isDeepDebugMode:int = 0;
        public  var isDebugMode:int = 0;
        public  var isTestMode:int = 0;
        //
        //  CONSTANTS
        //
        public  var TYPE_CONSTRUCT:String = new String('CONSTRUCT');
        public  var TYPE_PROGRESS:String = new String('PROGRESS');
        public  var TYPE_PRODUCT:String = new String('PRODUCT');
        public  var TYPE_PARAMETER:String = new String('PARAMETER');

        public  var EOL:String = new String("\n");
        public  var EOR:String = new String("<br>");
        public  var TAB:String = new String("\t");
        public  var SPLITTER:String = new String("_");
        public  var DR:String = new String(":");
        public  var n_a:String = new String("n/a");

        public  var INPUTAREA_LINE_LENGTH:Number = new Number(48);
        public  var DEFAULT_UNIT_ID:String = new String("796");
        //
        //  PUBLIC
        //
        public  var parent:Object;
        public  var dispatcher:myEventDispatcher = new myEventDispatcher();
        public  var action:Object = null;

        public  var CalculatingService:Object = new Object();
        public  var DisplayingService:Object = new Object();
        public  var RequestService:Object = new Object();
        public  var ErrorService:Object = new Object();
        public  var XmlService:Object = new Object();
        public  var LogService:Object = new Object();

        public  var formObjectListIds:Array = new Array();

        public  var formObjectList:Object = new Object();

        public  var globalAttrs:Object =
                    {
                        'input_area_max_width'      : 0,
                        'image_area_default_height' : 282,
                        'group_item_max_width'      : 0,
                        'group_item_max_height'     : 25,
                        'group_item_padding_top'    : 15,
                        'group_item_padding_left'   : 10,
                        'group_item_padding_bottom' : 5,
                        'background_color'          : '#F8FCF8' // #F4FBF4 #EFF8EF
                    };

        public  var namesOfButtons:Object = new Object();               // Список имен кнопок управления
        public  var visibleButtons:Object = new Object();               // Список видимых кнопок управления
        public  var actionButtons:Object = new Object();                // Список действий по кнопкам

        public  var isFirstTransaction:Boolean = new Boolean(true);     // Признак инициализации модуля отображения
        public  var isFirstCalculateAfterRespond:Boolean = new Boolean();
        public  var isFirstTransfer:Boolean = new Boolean();

        public  var isInternalMode:Boolean = new Boolean();
        public  var isExternalMode:Boolean = new Boolean();
        public  var isTransferMode:Boolean = new Boolean();

        public  var isWithoutRestriction:Boolean = new Boolean();       // Признак "Валидация отменена"
        public  var isWorkWithout1C:Boolean = new Boolean();            // Признак "Без 1С"
        public  var isQuitFromHelper:Boolean = new Boolean(false);      // Признак "Заказ оформлен"
        public  var isItemStyle:Boolean = new Boolean(false);           // Признак "Стили элементов формы"
        //
        //  Информация об ошибке
        //
        public  var localErrorCode:Number = new Number(0);              // Код последней ошибки (не используется)
        public  var loadingErrorCode:Number = new Number(0);            // Код ошибки инициализации
        public  var additionalErrorInfo:String = new String("");        // Текст дополнительного сообщения об ошибке
        //
        //  Текущие значения элементов экранной формы
        //
        public  var appObjectList:Array = new Array();                  // Ссылки на объекты элементов управления основной формы
        public  var reportFormPosition:Array = new Array();             // Позиционирование формы параметров заказа
        public  var confirmFormPosition:Array = new Array();            // Позиционирование формы с запросом на подтверждение
        public  var errorFormPosition:Array = new Array();              // Позиционирование формы об ошибке
        public  var infoAreaContentField:TextField = new TextField();   // Область сообщений экранной формы
        public  var helpAreaContentField:TextArea = new TextArea();     // Область подсказок
        public  var costAreaContentField:TextField = new TextField();   // Область цены заказа

        public  var costMessage:String = new String("");                // Стоимость
        public  var costUnit:String = new String("");                   // Валюта

        public  var helperKeyWords:Array = new Array();                 // Список ключевых слов-констант модели (constants.xml)
        public  var msgArray:Array = new Array();                       // Список сообщений модели (messages.xml)
        public  var errMsgArray:Array = new Array();                    // Список сообщений об ошибках модели (errors.xml)
        public  var currenciesNameList:Array = new Array();             // Массив значений кодов валют
        public  var unitsNameList:Array = new Array();                  // Массив единиц измерения

        public  var imagePath:Array = new Array();
        public  var imageVisibility:Array = new Array();
        public  var imageX:Array = new Array();
        public  var imageY:Array = new Array();
        public  var imageCurrPath:Array = new Array();

        public  var errorMessage:String = new String("");               // Текст сообщения об ошибке
        public  var errorStatus:Number = new Number(0);                 // Код ошибки

        public  var allVariableNames:Array = new Array();               // Общий глобальный список полей формы
        public  var helperProjectVars:Object = new Object();            // Главный контейнер управления данными формы
        public  var groupIDListOrder:Array = new Array();               // Порядок следования полей на форме

        public  var formXML:XML = new XML();                            // Форма (form.xml)
        public  var contentXML:XML = new XML();                         // Контент (content.xml)

        public  var repositoryXMLList:XMLList = new XMLList();          // Область справочной информации (репозитарий)

        public  var helperScriptFunction:String = new String("");       // Контент файла общих AS3-функций (functions.txt)
        public  var helperScriptContent:String = new String("");        // Контент файла скрипта модуля (scripts.txt)

        public  var queryXML:XML = new XML();                           // = REQUEST
        public  var respondXML:XML = new XML();                         // = RESPONSE

        public  var fieldGroup:Object = new Object();                   // Группа поля: ob[id]=<GroupID>
        public  var fieldSubGroup:Object = new Object();                // Подгруппа поля: ob[id]=<SubGroupID>
        public  var fieldCISID:Object = new Object();                   // ID обмена (CIS): ob[id]=<ID>
        public  var fieldTitle:Object = new Object();                   // Заголовок поля: ob[id]=<Label>
        public  var fieldDescription:Object = new Object();             // Подсказка к полю: ob[id]=<Description>
        public  var fieldIllustration:Object = new Object();            // Иллюстрация к полю: ob[id]=<Illustration>
        public  var fieldType:Object = new Object();                    // Тип поля: ob[id]=<Kind>
        public  var fieldContentType:Object = new Object();             // Тип данных поля: ob[id]=<Type>
        public  var fieldStyle:Object = new Object();                   // Стили оформления поля: ob[id]=<Style>
        public  var fieldIcon:Object = new Object();                    // Пиктограмма поля: ob[id]=<Icon>
        public  var fieldUnitID:Object = new Object();                  // Единицы измрения значения поля: ob[id]=<UnitID>

        public  var fieldStatus:Object = new Object();                  // Статусы полей: ob[id]=0/1/2
        public  var fieldCurrStatus:Object = new Object();              // Текущий статус поля: ob[id]=0/1/2
        public  var fieldIDtoCIS:Object = new Object();                 // ID обмена: ob[cis]=id
        public  var fieldCurrentContent:Object = new Object();          // Текущее значение поля: ob[id]=<current value>
        public  var fieldCalculatedContent:Object = new Object();       // Расчетное значение поля: ob[id]=<calculated value>
        public  var fieldGroupName:Object = new Object();               // Заголовки разделов: ob[id]=<label>
        public  var fieldSubGroupName:Object = new Object();            // Заголовки подразделов: ob[id]=<label>
        public  var quickRefGroupObject:Array = new Array();            // Список объектов заголовков формы: ob[id]={id, label, ref, position}

        public  var fieldFormat:Object = new Object();

        public  var styleSheetList:Object = new Object();               // Классы стилей (контент файла styles.xml, type=0)
        public  var labelsStyleList:Array = new Array();                // Именованные стили (по типам полей, контент файла styles.xml, type=1)
        public  var formSavedStage:Number = new Number(0);              // Текущее позиционирование (рисайзинг) формы
        public  var inFocusField:Object = new Object();                 // Фокус поля (последняя активность, ссылка на элемент управления)
        public  var inFocusId:String = new String("");                  // ID поля "в фокусе"
        public  var displayedImageURI:String = new String("");          // URL текущего имиджа формы
        public  var setImageURI:String = new String("");                // URL встраимого имиджа формы
        public  var currentIllustration:String = new String("");        // Имя файла текущей иллюстрации
        public  var emptyIllustration:String = new String("");          // Имя файла иллюстрации по-умолчанию (?)
        public  var myDateFormat:String = new String("");               // Формат поля даты

        public  var isCallingFunction:Boolean = new Boolean(false);     // Признак вызова функции (?)
        public  var loadingCompCount:Number = new Number(0);            // Количество этапов инициализации (число xml-файлов для загрузки)
        public  var loadedCompCount:Number = new Number(0);             // Номер текущего этапа инициализации
        public  var queryProcessingState:Number = new Number(0);        // Статус http-запроса (0-OK, 1-sent, X-error)
        //public  var mainFormPaddingLeft:Number = new Number(0);         // Значение "paddingLeft" для основного контейнера формы (?)

        public  var myModalWinRef:Image = new Image();                  // Изображение загрузчика формы ("колесо")
        public  var myBrowserManager:IBrowserManager;                   // Ссылка на экзмпляр обозревателя
        //
        //  PRIVATE
        //
        private var myContainer:UIComponent = new UIComponent();        // Контейнер приложения
        private var appContextMenu:ContextMenu = new ContextMenu();     // Контейнер всплывающего меню
        private var actionsScenario:Array = new Array();                // Сценарий операций (тестовый режим)
        private var actionsLog:Array = new Array();                     // Журнал операций
        private var isBusy:Boolean = new Boolean(false);                // Флаг "занят"

        public  var calculatorValue:Number = new Number(0);             // Текущее значение калькулятора INPUT-поля

        /* -------------------------- */
           include "../lib/utils.as";
        /* -------------------------- */
        
        // ===================
        //  Self Test Routine
        // ===================

        protected function setScenario():void
        {
            dispatcher.addEventListener(myEventDispatcher.ACTION, actionHandler);

            if (this.isExternalMode) {
                actionsScenario.push({'id':'01', 'action':'203', 'handler':this.RequestService.sendInitRequest, 'url':'', 'response':''});
                actionsScenario.push({'id':'02', 'action':'203', 'handler':this.RequestService.reset, 'url':'', 'response':''});
                actionsScenario.push({'id':'03', 'action':'203', 'handler':this.RequestService.initState, 'url':'', 'response':''});
            }
            if (this.isInternalMode || this.isTransferMode) {
                actionsScenario.push({'id':'01', 'action':'203', 'handler':this.RequestService.initState, 'url':'', 'response':''});
            }
            if (this.isTransferMode) {
                actionsScenario.push({'id':'02', 'action':'203', 'handler':this.RequestService.sendInitRequest, 'url':'', 'response':''});
                actionsScenario.push({'id':'03', 'action':'203', 'handler':this.RequestService.reset, 'url':'', 'response':''});
            }
            if (this.isInternalMode || this.isExternalMode || this.isTransferMode) {
                actionsScenario.push({'id':'10', 'action':'204', 'handler':this.executeMainAction, 'url':'', 'response':''});
            }
            if (this.isInternalMode) {
                actionsScenario.push({'id':'11', 'action':'205', 'handler':this.executeMainAction, 'url':'', 'response':''});
            }
            /*
            if (this.isExternalMode) {
                actionsScenario.push({'id':'11', 'action':'207', 'handler':this.executeMainAction, 'url':'', 'response':''});
            }
            if (this.isTransferMode) {
                actionsScenario.push({'id':'11', 'action':'207', 'handler':this.executeBeforeAction, 'url':'', 'response':''});
                actionsScenario.push({'id':'12', 'action':'208', 'handler':this.executeBeforeAction, 'url':'', 'response':''});
            }
            */
        }

        public function queryComplete():void
        {
            dispatcher.doAction();
        }

        public function actionHandler(event:Event):void
        {
            var x:String = new String("OK");
            if (this.action)
            {
                with (this.action)
                {
                    if (id) x += '-' + id;
                    if (url) x += "\n" + url;
                    if (response) x += "\n" + response;
                }
            }
            if (this.isDeepDebugMode)
                alert(x, "ActionHandler", 150, this.queryProcessingState ? null : this.run);
            else
                this.run();
        }

        public function registryActionComplete():void
        {
            var index:Number = this.actionsLog.length - 1;
            if (index > -1 && this.actionsLog[index].action == this.currentHelperActionID)
                this.actionsLog[index].error = this.queryProcessingState;
            else if (this.currentHelperActionID)
                this.registryAction(this.queryProcessingState);
        }

        public function registryAction(error:Object=null):void
        {
            var ob:Object = {
                'action' : this.currentHelperActionID,
                'state'  : this.queryProcessingState,
                'type'   : this.RequestService.requestType,
                'url'    : this.RequestService.currentURL,
                'error'  : error
            }

            this.actionsLog.push(ob);
        }

        protected function getActionsLog():String
        {
            var output:String = new String("");

            for (var i:int=this.actionsLog.length-1; i > -1; i--)
            {
                var ob:Object = this.actionsLog[i];
                var error:String = (ob.error !== null ? ob.error.toString() : '?');
                var x:String = '==> ' + ob.action + ' [' + error + '] ' + ob.type + ': ' + ob.url;
                output += x + this.EOR;
            }
            
            return output;
        }

        protected function run(event:Event=null):void
        {
            if (!this.actionsScenario.length)
            {
                dispatcher.removeEventListener(myEventDispatcher.ACTION, actionHandler);
                return;
            }

            this.action = actionsScenario.shift();
            this.currentHelperActionID = this.action.action;

            if (this.action.handler !== null)
            {
                if (startswith(this.action.id, '0'))
                    this.action.handler.call(this.RequestService);
                else
                    this.action.handler.call(this);
            }
        }

        // =========
        //  STARTER
        // =========

        public function procStart(parentObj:Object, objectsList:Array)
        {
            var myWWWPattern:RegExp = /www./;

            // Get parent objects list
            this.parent = parentObj;
            this.appObjectList = objectsList;

            // Modal window (waiting...)
            this.openBusyModalWindow();

            // Set loaded resurces control
            this.loadingCompCount = 14;
            this.loadedCompCount = 0;
            this.localErrorCode = 0;
            this.loadingErrorCode = 0;

            this.setAllUnvisible();

            this.myBrowserManager = mx.managers.BrowserManager.getInstance();
            this.myBrowserManager.init();

            // Get QueryString parameters
            with (this.appObjectList['flashVars'])
            {
                this.helperCommunicationType = type;
                this.helperWizardID = wizard;
                this.helperURI = uri;
                this.helperLoadedVersion = ver;
                this.helperLocalization = lang.toUpperCase();
                this.helperStyleID = styleID;
                
                // Check the newest items
                try
                {
                    this.helperDomain = hasOwnProperty("domain") ? domain : "";
                    this.helperPurchaseID = hasOwnProperty("purchase") ? purchase : this.n_a;
                    this.helperAuthData = {
                        "login"    : hasOwnProperty("login") ? login : "", 
                        "password" : hasOwnProperty("password") ? password : "", 
                        "_c"       : ''
                    };
                    this.helperBrowserType = hasOwnProperty("browser") ? browser : String(ExternalInterface.call("function(){return navigator.appName}"));
                    this.helperTimeout = hasOwnProperty("timeout") ? Number(timeout) : 0;
                    this.helperDetailed = hasOwnProperty("detailed") ? (detailed == "1" ? true : false) : false;
                    this.isDeepDebugMode = hasOwnProperty("deepdebug") && deepdebug == "1" ? 1 : 0;
                    this.isDebugMode = hasOwnProperty("debug") && debug == "1" ? 1 : 0;
                    this.isTestMode = hasOwnProperty("test") && test == "1" ? 1 : 0;
                    this.helperTags = {
                        "wizard"   : hasOwnProperty("tag_cp_wizard_id") && tag_cp_wizard_id == "0" ? false : true
                    };
                    this.isItemStyle = hasOwnProperty("style") ? (style == "1" ? true : false) : false;
                }
                catch(errorNum:Error) {}

                if (!this.helperDomain) this.helperDomain = this.helperURI;
            }

            this.helperPathURI = "helper/";
            this.helperInitURI = "init.php";
            this.helperExchangeURI = "communications/helper/1c_exchange.php";
            this.helperPageLocation = this.myBrowserManager.base;
            this.helperHostName = mx.utils.URLUtil.getServerName(this.helperPageLocation);
            this.helperHttpHost = this.helperHostName.replace(myWWWPattern, "");
            this.helperHttpReferer = Application.application.url;

            // Set Global Attrs
            with (this.globalAttrs)
            {
                input_area_max_width = this.appObjectList['inputArea'].width - 36; //528;
                group_item_max_width = input_area_max_width - 11;
            }

            // Manage test mode

            this.helperProductControl = {'active':false, 'enabled':false, 'type':null, 'finalize':false};

            // Load logo
            with (this.appObjectList["helperLogo"])
            {
                load(this.helperURI + this.helperPathURI + "images/logo-new.png");
            }

            // Create instances of classes
            this.LogService = new logService(this);
            this.ErrorService = new errorService(this);
            this.XmlService = new xmlService(this);

            // Activate XML loader
            this.XmlService.initState();

            // Add Event Listeners
            this.appObjectList['checkButton'].addEventListener(MouseEvent.CLICK, executeAction);
            this.appObjectList['saveButton'].addEventListener(MouseEvent.CLICK, executeAction);
            this.appObjectList['closeButton'].addEventListener(MouseEvent.CLICK, executeAction);
        }

        public function letsGo(resourceName:String, errNum:Number):void
        {
            this.loadedCompCount++;

            if (this.loadingErrorCode > errNum)
            {
                this.loadingErrorCode = errNum;
                this.ErrorService.additionalErrorMessage = this.ErrorService.additionalErrorMessage + " (" + resourceName + ")";
            }

            if (this.loadedCompCount == this.loadingCompCount)
            {
                var msg:String = new String("");

                if (this.loadingErrorCode == 0)
                {
                    this.myDateFormat = this.msgArray[9];

                    if (this.helperCommunicationType == this.helperKeyWords["ExternalField"])
                        this.helperCommunicationType = this.helperKeyWords["Internal"];

                    // Create message areas
                    this.createSystemMessageArea();
                    this.createHelpMessageArea();
                    this.createCostMessageArea();

                    // Adjust screen form
                    this.screenAdjustment();

                    // Init error service
                    this.ErrorService.initState();

                    // Create other class instances
                    this.CalculatingService = new calculatingService(this);
                    this.RequestService = new requestService(this);
                    this.DisplayingService = new displayingService(this);

                    // Init request service
                    with (this.RequestService)
                    {
                        currentType = this.helperCommunicationType;
                    }

                    // Init application script calculating class instance
                    this.loadingErrorCode = this.CalculatingService.initState();

                    // Start the service
                    if (!this.loadingErrorCode)
                    {
                        this.loadingErrorCode = this.CalculatingService.calculate();

                        if (!this.loadingErrorCode)
                        {
                            this.CalculatingService.upload();

                            this.isFirstTransaction = true;
                            this.currentHelperActionID = "203";

                            this.isInternalMode = this.helperCommunicationType == this.helperKeyWords["Internal"];
                            this.isExternalMode = this.helperCommunicationType == this.helperKeyWords["External"];
                            this.isTransferMode = this.helperCommunicationType == this.helperKeyWords["Transfer"];

                            this.setXMLRequest();

                            if (this.isTestMode)
                            {
                                this.setScenario();
                                this.run();
                            }
                            else
                                this.loadingErrorCode = this.RequestService.initState();
                        }
                    }

                    if (this.loadingErrorCode)
                    {
                        this.ErrorService.errorAnalyser(true, this.loadingErrorCode);
                        this.removeBusyModalWindow();
                        msg = this.LogService.lastLogRecord + ': type=' + this.helperCommunicationType;                        
                        alert(msg, "Init Services Error [version " + this.product_version + "]");
                    }
                }
                else
                {
                    this.removeBusyModalWindow();
                    msg = this.ErrorService.additionalErrorMessage;
                    alert(msg, "Loading Error [version " + this.product_version + "]");
                }
            }
        }

        public function initState():void
        {
            var container:Object = this.helperProjectVars;
            var keywords:Object = this.helperKeyWords;

            var i:Number = new Number(0);
            var counter:Number = this.allVariableNames.length;
            var id:String = new String("");

            for (i=0; i < counter; i++)
            {
                id = this.allVariableNames[i];
                this.fieldStatus[id] = 1;

                if (this.fieldType[id] == keywords["PROGRESS"])
                {
                    switch (this.fieldContentType[id])
                    {
                        case(keywords["NUMBER"]):
                            container[id] = 0;
                            break;

                        case(keywords["BOOLEAN"]):
                            container[id] = false;
                            break;

                        case(keywords["DATE"]):
                            container[id] = this.CalculatingService.toDate("");
                            break;

                        default:
                            container[id] = "";
                    }
                }
            }
        }
 
        // ----------------------------------
        //  Services $ Maintenance Functions
        // ----------------------------------

        public function openBusyModalWindow():void
        {
            if (this.isBusy) return;

            var ob:Image;
            var url:String = new String("");

            ob = PopUpManager.createPopUp(this.appObjectList['mxmlApplication'], Image, true) as Image

            ob.x = (Application.application.width - ob.width) / 2;
            ob.y = (Application.application.height - ob.height) / 2;

            url = this.helperURI + this.helperPathURI + "images/loader.swf";
            ob.load(url);

            this.myModalWinRef = ob;
            this.isBusy = true;
        }

        public function removeBusyModalWindow():void
        {
            if (!this.isBusy) return;
            PopUpManager.removePopUp(this.myModalWinRef);
            this.isBusy = false;
        }

        public function openCalculatorWindow():void
        {
            var ob:Calculator;

            ob = PopUpManager.createPopUp(this.appObjectList['mxmlApplication'], Calculator, true) as Calculator

            ob.x = (Application.application.width - ob.width) / 2;
            ob.y = ((Application.application.height - ob.height) / 2) - 10;
        }

        public function getNewLink():String
        {
            var high:Number = 10000;
            var low:Number = 1000;
            var x:Number = Math.floor(Math.random() * (high - low)) + low;
            return "?link=" + x.toString();
        }

        public function getMessage(index:Number):String
        {
            return this.msgArray.length > index ? this.msgArray[index] : '';
        }

        public function getTimeAndDateAsString(format:String):String
        {
            if (format == "millisecond")
                return getTimer().toString();

            function get_date(v:Number):String { return ("0" + v.toString()).substr(-2); }

            var value:String = new String("");
            var x:Date = new Date();
            var D:String = get_date(x.date);
            var M:String = get_date(x.month + 1);
            var Y:String = get_date(x.fullYear);
            var h:String = get_date(x.hours);
            var m:String = get_date(x.minutes);
            var s:String = get_date(x.seconds);

            switch(format)
            {
                case "only Date":
                    value = D + "." + M + "." + Y;
                    break;

                case "only Time":
                    value = h + ":" + m + ":" + s;
                    break;

                default:
                    value = this.helperLocalization === "RUS" ? 
                        (D + "." + M + "." + Y + " " + h + ":" + m + ":" + s):
                        (M + "." + D + "." + Y + " " + h + ":" + m + ":" + s);
            }

            return value;
        }

        public function replaceQuotedValues(message:String):String
        {
            //
            //  Замена строковых констант: %#...#%
            //
            var tmpVal:String = new String("");
            var tmpArrA:Array = new Array();
            var tmpArrB:Array = new Array();
            var arrSizeA:Number = new Number(0);
            var arrSizeB:Number = new Number(0);
            var i:Number = new Number(0);

            tmpArrA = message.split(this.helperKeyWords["stdStrOpenedSymb"]);
            arrSizeA = tmpArrA.length;

            if (arrSizeA > 1)
            {
                for (i = 0; i < arrSizeA; i++)
                {
                    tmpVal = tmpArrA[i];
                    tmpArrB = tmpVal.split(this.helperKeyWords["stdStrClosedSymb"]);
                    arrSizeB = tmpArrB.length;

                    if (arrSizeB > 1)
                    {
                        tmpVal = tmpArrB[0];
                        tmpArrB[0] = "";

                        if (this.helperProjectVars[tmpVal] != undefined)
                        {
                            tmpArrA[i] = String(this.helperProjectVars[tmpVal]) + tmpArrB.join("");
                        }
                    }
                }
            }

            return tmpArrA.join("");
        }

        // =======================
        //  Form Control Handlers
        // =======================

        public function screenAdjustment():void
        {
            var stage:Stage = this.appObjectList['mxmlApplication'].stage;
            var offset:int = 200;
            var stage_height:int = 700 - offset;
            var menu_bar_height:int = 50;
            var input_area_height:int = 589 - offset;
            var input_area_width:int = 564;
            var input_area_top:int = 43;
            var image_area_height:int = this.globalAttrs.image_area_default_height;
            var message_area_height:int = 109;
            var message_area_top:int = 633 - offset;
            var y:Number = 0;

            with (this.appObjectList)
            {
                if (!this.formSavedStage)
                {
                    inputArea.height = input_area_height;
                    imageArea.height = image_area_height;
                    messageArea.y = message_area_top;
                    repositoryArea.y = message_area_top;
                }

                if (!stage)
                    y = 0;
                else if (this.formSavedStage)
                    y = stage.stageHeight - this.formSavedStage;
                else if (stage.stageHeight > stage_height)
                    y = stage.height - (input_area_height + message_area_height + menu_bar_height);

                inputArea.x = 0;
                inputArea.y = input_area_top;
                inputArea.width = input_area_width;
                
                if (y)
                {
                    inputArea.height += y;
                    imageArea.height += y;
                    messageArea.y += y;
                    repositoryArea.y += y;
                }

                inputArea.setStyle("backgroundColor", this.globalAttrs.background_color);
                promptingContainer.setStyle("backgroundColor", this.globalAttrs.background_color);

                if (this.formSavedStage || stage.stageHeight > stage_height)
                    this.formSavedStage = stage.stageHeight;
            }

            if (!this.appObjectList.root) this.appObjectList.root = this;
        }

        public function setHelperTitle():void
        {
            var title:String = this.helperDefaultName;
            if (title) {
                with (this.appObjectList['helperTitle'])
                {
                    height = title.length > 62 ? 38 : 24;
                    htmlText = title;
                }
            }
        }

        public function setAllUnvisible():void
        {
            this.appObjectList['checkButton'].visible = false;
            this.appObjectList['saveButton'].visible = false;
            this.appObjectList['closeButton'].visible = false;

            this.appObjectList['applicationDivider'].visible = false;
            this.appObjectList['helperTitle'].visible = false;
            this.appObjectList['inputArea'].visible = false;
            this.appObjectList['imageArea'].visible = false;
            this.appObjectList['imageBox'].visible = false;
            this.appObjectList['illustrationImage'].visible = false;
            this.appObjectList['promptingArea'].visible = false;
            this.appObjectList['repositoryArea'].visible = false;
            this.appObjectList['repositoryList'].visible = false;
            this.appObjectList['messageArea'].visible = false;
            this.appObjectList['costArea'].visible = false;
        }

        public function setAllVisible():void
        {
            if (this.namesOfButtons.propertyIsEnumerable("checkButton"))
            {
                this.appObjectList['checkButton'].label = this.namesOfButtons["checkButton"];
            }

            if (this.visibleButtons["checkButton"])
            {
                this.appObjectList['checkButton'].visible = true;
            }

            if (this.namesOfButtons.propertyIsEnumerable("saveButton"))
            {
                this.appObjectList['saveButton'].label = this.namesOfButtons["saveButton"];
            }

            if (this.visibleButtons["saveButton"])
            {
                this.appObjectList['saveButton'].visible = true;
            }

            if (this.namesOfButtons.propertyIsEnumerable("closeButton"))
            {
                this.appObjectList['closeButton'].label = this.namesOfButtons["closeButton"];
            }

            if (this.visibleButtons["closeButton"])
            {
                this.appObjectList['closeButton'].visible = true;
            }

            this.appObjectList['applicationDivider'].visible = true;
            this.appObjectList['helperTitle'].visible = true;
            this.appObjectList['inputArea'].visible = true;
            this.appObjectList['imageArea'].visible = true;
            this.appObjectList['imageBox'].visible = true;
            this.appObjectList['promptingArea'].visible = true;
            this.appObjectList['illustrationImage'].visible = true;
            this.appObjectList['repositoryArea'].visible = true;
            this.appObjectList['repositoryList'].visible = true;
            this.appObjectList['messageArea'].visible = true;
            this.appObjectList['costArea'].visible = true;

            // menu
            this.appContextMenu.hideBuiltInItems();
            this.appContextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, appContextMenuSelected);
            this.appObjectList['inputArea'].contextMenu = this.appContextMenu;
        }

        public function addErrorMessage(message:String):void
        {
            if (message)
                this.ErrorService.additionalErrorMessage += message + "<br>";
            else
                this.ErrorService.additionalErrorMessage = "";
        }

        protected function createSystemMessageArea():void
        {
            var myContainer:UIComponent = new UIComponent();    // Обертка для TextField (MessageArea)

            with (this.infoAreaContentField)
            {
                type = TextFieldType.DYNAMIC;

                multiline = true;
                border = false;
                background = false;
                selectable = true;
                wordWrap = true;
                mouseWheelEnabled = true;

                x = 5;
                y = 5;
                width = 554;
                height = 102;
                text = "";
                htmlText = "";

                styleSheet = this.styleSheetList["MessageAreaText"];
            }

            myContainer.addChild(this.infoAreaContentField);
            this.appObjectList['messageArea'].addChild(myContainer);
        }

        public function cleanSystemMessage():void
        {
            this.infoAreaContentField.htmlText = "";
        }

        public function setSystemMessage(errIsSeries:Boolean, errCode:Number, message:String):void
        {
            var header:String = new String("");

            if (!message && !errIsSeries)
            {
                this.cleanSystemMessage();
            }
            else if (this.errorStatus && errCode < 0 && message)
            {
                this.errorMessage = message;
                this.openErrorMessageWindow();

                if (this.errorStatus >= 27) 
                    message = '';
                else
                    message = this.ErrorService.additionalErrorMessage ? this.ErrorService.additionalErrorMessage + EOR : "";
            }

            if (message)
            {
                if (errCode == 1) {
                    header = "<p class='attstyle'>";
                } else if (errCode != 0) {
                    header = "<p class='errstyle'>";
                } else {
                    header = "<p class='noerrstyle'>";
                    if (this.isDebugMode)
                        header += "<span class='logstyle'>" + this.getActionsLog() + "</span>" + EOR;
                }

                if (errIsSeries)
                    this.infoAreaContentField.htmlText += ""
                        + header
                        + message
                        + "</p>";
                else
                    this.infoAreaContentField.htmlText = header
                        + message
                        + "</p>";
            }
        }

        protected function createHelpMessageArea():void
        {
            var myContainer:UIComponent = new UIComponent();

            with (this.helpAreaContentField)
            {
                focusEnabled = false;
                selectable = false;
                editable = false;
                wordWrap = true;
                tabEnabled = false;

                verticalScrollPolicy = 'off';
                
                x = 5;
                y = 5;
                width = 460; //446;
                height = 50; //88;
                text = "";
                htmlText = "";

                styleName = "prompting";
                styleSheet = this.styleSheetList["HelpAreaText"];
                setStyle("backgroundColor", this.globalAttrs.background_color);
            }

            myContainer.addChild(this.helpAreaContentField);
            this.appObjectList['promptingArea'].addChild(myContainer);
        }

        public function setHelpMessage(messageContent:String):void
        {
            var s:String = new String("off");
            var p:Number = new Number(5);
            var msg:String = (messageContent ? messageContent : this.helperProjectVars["defaultPrompting"]);

            //if (this.helperProductControl.active || this.helperProjectVars["isConfirmation"])
            //    return;

            with (this.helpAreaContentField)
            {
                htmlText = "<p class='messStyle'>" + msg + "</p>";
                if (msg.length > 220) // || textHeight > 50
                {
                    s = "auto";
                }
                verticalScrollPolicy = s;
                setStyle("paddingRight", p);
            }
        }

        protected function createCostMessageArea():void
        {
            var myContainer:UIComponent = new UIComponent();

            with (this.costAreaContentField)
            {
                type = TextFieldType.DYNAMIC;

                multiline = true;
                border = false;
                background = false;
                selectable = false;
                wordWrap = false;
                mouseWheelEnabled = false;

                x = 0;
                y = 0;
                width = 128; //550
                height = 32; //25
                text = "";
                htmlText = "";

                styleSheet = this.styleSheetList["CostAreaText"];
            }

            myContainer.addChild(this.costAreaContentField);
            this.appObjectList['costArea'].addChild(myContainer);
        }

        public function setCostMessage(message:String):void
        {
            var header:String = new String("");

            if (message == "" || message == n_a || this.helperProjectVars["calculatingDisabled"] == 1)
                header = "<p class='noCostStyle'>" + this.msgArray[2] + "</p>";
            else
                header = "<p class='costStyle'>" + message + " " + this.costUnit + "</p>";

            this.costAreaContentField.htmlText = "<p class='titleStyle'>"
                + this.msgArray[1]
                + header
                + "</p>"
                + "<p class='attStyle'>"
                + this.msgArray[5]
                + "</p>";
        }

        public function setCalculatingEnabled(state:Boolean=true):void
        {
            if (state && this.helperProjectVars["calculatingDisabled"] == 1)
                state = false;
            this.appObjectList['checkButton'].enabled = state;
            this.appObjectList['saveButton'].enabled = state;
        }

        public function setFocusOn():void
        {
            if (this.helperProjectVars["helperFocusOn"])
            {
                var id:String = this.helperProjectVars["helperFocusOn"];
                var container:Object = this.DisplayingService.getContainerOfItem(id);
                this.selectContextMenuItem(container.ids.group, true);
                this.formObjectList[id].object.setFocus();
                this.helperProjectVars["helperFocusOn"] = '';
            }
        }

        // ======================
        //  XML Request Services
        // ======================

        private function IsServiceItem(id:String):Boolean
        {
            return ['constSavedImage'].indexOf(id) > -1 ? true : false;
        }

        private function IsItemShouldBeAddedToRequest(id:String):Boolean
        {
            return id && 
                (this.fieldCISID[id] || this.fieldType[id] == this.helperKeyWords["PROGRESS"]) && 
                (this.fieldStatus[id] > 0) && 
                ([this.helperKeyWords["IMAGE"], this.helperKeyWords["SWF"]].indexOf(this.fieldContentType[id]) == -1) ?
                true : false;
        }

        private function IsNotValidOption(value:String, option:String, isDefaultOption:Boolean):Boolean
        {
            var x:String = this.getCISOption(value);
            return option && ((x != option && !isDefaultOption) || (x && isDefaultOption)) ? true : false;
        }

        private function IsAttrHidden(id:String):Boolean
        {
            //
            // Параметр не доступен для просмотра (Format:HIDE)
            //
            return id !== "" 
                   && this.fieldFormat.hasOwnProperty(id) 
                   && this.fieldFormat[id].toUpperCase().indexOf('HIDE') > -1 ? 
                   true : false;
        }

        private function IsAttrVisible(id:String):Boolean
        {
            //
            // Параметр доступен для просмотра (Format:SHOW)
            //
            return id !== "" 
                   && this.fieldFormat.hasOwnProperty(id) 
                   && this.fieldFormat[id].toUpperCase().indexOf('SHOW') > -1 ? 
                   true : false;
        }
        
        private function IsTypeListOfProgress(id:String):Boolean
        {
            //
            // Список с ключевым словом PROGRESS - это наценки (margins)
            //
            return id !== "" 
                   && this.fieldContentType[id] === this.helperKeyWords["LIST"] 
                   && this.fieldType[id] === this.helperKeyWords["PROGRESS"] ?
                   true : false;
        }

        private function IsRequestValid():Boolean
        {
            if (this.isTransferMode && !this.isFirstTransaction && (
               !this.isItemValid(this.helperPurchaseID) || !this.isItemValid(this.helperRegionID))) // || this.helperPurchaseID == this.helperRegionID
                return false;
            return true;
        }
        
        private function getTypeOfItem(cis:String):String
        {
            if (!cis)
                return '';

            var id:String = this.fieldIDtoCIS[cis];
            var n:Number = cis.indexOf("construct", 0);
            var s:String = cis.length > 2 ? cis.substring(2) : cis;
            var x:Number = Number(s);
            //
            // CONSTRUCT
            //
            if (n == 0)
            {
                return this.TYPE_CONSTRUCT;
            }
            //
            // Код наценки (PROGRESS)
            //
            else if (id && this.fieldType[id] === this.helperKeyWords["PROGRESS"])
            {
                return this.TYPE_PROGRESS;
            }
            //
            // Код наценки (число, либо код 'CB<000000000>')
            //
            else if (!isNaN(x))
            {
                return this.TYPE_PRODUCT;
            }
            //
            // Параметр продукта (код обмена, но не число)
            //
            else
            {
                return this.TYPE_PARAMETER;
            }
        }

        private function getCISId(id:String, with_option:Boolean=false):String
        {
            //
            // Возвращает CIS-идентификатор параметра.
            // Формат: {<option:>}<ID|CIS>.
            //
            var cis:String = this.fieldCISID.hasOwnProperty(id) ? this.fieldCISID[id] : '';
            return !with_option && cis.indexOf(DR) > -1 ? cis.split(DR)[1] : cis;
        }

        private function getCISOption(cis:String):String
        {
            //
            // Возвращает CIS-option параметра.
            //
            return cis.indexOf(DR) > -1 ? cis.split(DR)[0] : '';
        }

        private function getCISCode(cis:String):String
        {
            //
            // Возвращает CIS-code параметра.
            //
            return cis.indexOf(DR) > -1 ? cis.split(DR)[1] : cis;
        }

        private function addToRequest(request:String, value:String):String
        {
            if (value)
                return (request ? request + this.EOL : '') + value;
            else
                return request;
        }
        
        private function getSplittedName(id:String, last_index:Number=0):String
        {
            if (id.indexOf(this.SPLITTER) == -1)
                return id;
        
            var words:Array = id.split(this.SPLITTER);
            var x:String = '';

            if (last_index > 0 && last_index < words.length)
                return words[last_index]

            for (var i:int=0; i < words.length + last_index; i++)
            {
                if (i >= words.length) break;
                if (x) x += this.SPLITTER;
                x += words[i];
            }
            
            return x;
        }
        
        private function getVisualItemAttrs(id:String, force:String=""):Object
        {
            var keywords:Object = this.helperKeyWords;
            var x:String = new String("");
            var x1:String = new String("");
            var i:Number = new Number(0);
            var a:Object = {title:'', unit:'', subgroup:'', group:'', product:''};
            var with_unit:Boolean = false;

            if (!id || id === "" || this.IsServiceItem(id))
                return a;

            var type:String = this.fieldType.hasOwnProperty(id) ? this.fieldType[id] : '';
            var format:Array = this.fieldFormat.hasOwnProperty(id) ? this.fieldFormat[id].split(this.helperKeyWords["formatParamDiv"]) : [];

            if (force == "group")
            {
                //
                // Заголовок группы/раздела
                //
                a.group = this.fieldGroup.hasOwnProperty(id) ? this.fieldGroup[id] : '';
                if (a.group)
                    a.title = this.fieldGroupName.hasOwnProperty(a.group) ? this.fieldGroupName[a.group] : '';
            }
            else if (force == "subgroup" || force == "subgroup-only")
            {
                //
                // Заголовок подгруппы/параметра
                //
                a.subgroup = this.fieldSubGroup.hasOwnProperty(id) ? this.fieldSubGroup[id] : '';
                if (a.subgroup)
                    a.title = this.fieldSubGroupName.hasOwnProperty(a.subgroup) ? this.fieldSubGroupName[a.subgroup] : '';
                if (!a.title && force != "subgroup-only")
                    a = this.getVisualItemAttrs(id, "group");
            }
            else if (force == "inherited")
            {
                //
                // Поиск однокорневого идентификатора
                //
                var key:String = this.getSplittedName(id, -1);
                var start_with:int = this.allVariableNames.indexOf(id) - 1;
                var isUp:Boolean = id.substr(-3) == '_up' ? true : false;
                var no_content:Boolean = false;

                for (var j:int=start_with; j >= 0; j--)
                {
                    if (a.title)
                    {
                        if (a.title.substr(-1) == ':')
                            a.title = a.title.substr(0, a.title.length-1)
                        break;
                    }

                    x = this.allVariableNames[j];

                    if (this.formObjectListIds.indexOf(x) == -1)
                        continue;

                    no_content = ['POP-UP MENU', 'COMBOBOX', keywords['HLIST'], keywords['HLISTBOX']].indexOf(this.fieldType[x]) > -1 ? true : false;

                    if (key == x || x.indexOf(key) == 0)
                    {
                        if (isUp) {
                            switch(this.fieldType[x]) 
                            {
                                case('DISPLAY FIELD'):
                                    a.title = this.fieldTitle.hasOwnProperty(x) && this.fieldTitle[x] ? this.fieldTitle[x] :
                                        (this.fieldCurrentContent.hasOwnProperty(x) && this.fieldCurrentContent[x] ? 
                                            this.fieldCurrentContent[x] : '');
                                    break;
                                case('POP-UP MENU'):
                                case('COMBOBOX'):
                                case(keywords['HLISTBOX']):
                                case(keywords['HLIST']):
                                case('INPUT FIELD'):
                                case('CHECKBOX'):
                                    a.title = this.fieldTitle.hasOwnProperty(x) && this.fieldTitle[x] ? 
                                        this.fieldTitle[x] : '';
                            }
                        } 
                        else if (this.fieldType[x] != this.fieldType[id])
                        {
                            a.title = this.fieldTitle.hasOwnProperty(x) && this.fieldTitle[x] ? this.fieldTitle[x] :
                                (this.fieldCurrentContent.hasOwnProperty(x) && this.fieldCurrentContent[x] && !no_content ? 
                                    this.fieldCurrentContent[x] : '');
                        }

                        if (!(a.title is String))
                            a.title = '';
                    }
                    else
                        break;
                }
            }
            else
            {
                if (!type) return a;

                if (this.getTypeOfItem(this.fieldCISID[id]) == this.TYPE_PROGRESS)
                {
                    a = this.getVisualItemAttrs(id, "subgroup");
                    if (!a.title)
                    {
                        a.title = '[' + this.fieldCISID[id] + ']';
                        return a;
                    }
                }
                else if (['POP-UP MENU', 'COMBOBOX', keywords['HLIST'], keywords['HLISTBOX'], 'INPUT AREA'].indexOf(type) > -1)
                {
                    a = this.getVisualItemAttrs(id, "inherited");
                }
                else if (type == 'RADIOBUTTON')
                {
                    a = this.getVisualItemAttrs(id, "inherited");
                }
                else if (type == 'CHECKBOX')
                {
                    a.title = this.fieldTitle.hasOwnProperty(id) ? this.fieldTitle[id] : '';
                }
                else if (['CONSTANT', 'INPUT FIELD'].indexOf(type) > -1)
                {
                    a.title = this.fieldTitle.hasOwnProperty(id) ? this.fieldTitle[id] : '';
                    //
                    // Составные имена: <идентификатор>_up/_List/_Value/_Count
                    //
                    if (!a.title && id.indexOf(this.SPLITTER) > -1)
                    {
                        if (['Count'].indexOf(this.getSplittedName(id, 1)) > -1)
                        {
                            a.title = this.getMessage(25);
                            with_unit = true;
                        }
                        else if (this.getSplittedName(id, -1) != id)
                        {
                            a = this.getVisualItemAttrs(id, "inherited");
                        }
                    }
                }
                else
                {
                    a.title = this.fieldTitle.hasOwnProperty(id) ? this.fieldTitle[id] : '';
                    if (!a.title)
                    {
                        a.title = this.fieldCurrentContent.hasOwnProperty(id) ? this.fieldCurrentContent[id].toString() : '';
                    }
                }

                if (a.title && (a.title.match(/^\(.*\)$/) || format))
                {
                    x = a.title;
                    if (format.indexOf('G') > -1) {
                        a = this.getVisualItemAttrs(id, "group");
                        a.title += " " + x;
                        x = a.title;
                    }
                    if (format.indexOf('SG') > -1 || !format) {
                        a = this.getVisualItemAttrs(id, "subgroup-only");
                        a.title += " " + x;
                    }
                }

                if (!a.title)
                {
                    a = this.getVisualItemAttrs(id, "subgroup");
                }
            }

            if ((a.title || with_unit) && a.unit === "" && this.fieldUnitID[id])
            {
                x = this.fieldUnitID[id];
                if (x && this.unitsNameList.hasOwnProperty(x))
                {
                    a.unit = this.unitsNameList[x];
                }
            }

            return a;
        }

        private function getFieldUnitID(id:String):String
        {
            return id && this.fieldUnitID[id] ? this.fieldUnitID[id] : this.DEFAULT_UNIT_ID;
        }

        private function setRequestContent(indent:String, keys:Object, option:String, isDefaultOption:Boolean, isWithConstruct:Boolean):String
        {
            var request:String = new String("");
            var id:String = new String("");
            var cis:String = new String("");
            var value:String = new String("");
            
            var parametersContent:String = new String("");
            var productsContent:String = new String("");

            var list_items:Array = new Array();
            var list_item_values:Array = new Array();
            var item:String = new String("");
            var cis_type:String = new String("");
            var content_type:String = new String("");
            var unit_id:String = new String("");
            
            for (var i:int=0; i < this.allVariableNames.length; i++)
            {
                id = this.allVariableNames[i];

                if (this.IsItemShouldBeAddedToRequest(id) || this.IsServiceItem(id))
                {
                    cis = this.getCISId(id);
                    cis_type = this.getTypeOfItem(cis);

                    if (this.IsTypeListOfProgress(id))
                    {
                        value = String(this.helperProjectVars[id]);
                        list_items = value.split(this.helperKeyWords["listIndexDelimeter"]);

                        if (list_items.length > 1)
                        {
                            list_items = list_items[1].split(this.helperKeyWords["listValueDelimeter"]);
                            //
                            // Список наценок
                            //
                            for (var j:int=0; j < list_items.length; j++)
                            {
                                item = list_items[j];
                                list_item_values = item.split(this.helperKeyWords["listItemDelimeter"]);

                                if (list_item_values.length < 4)
                                    continue;

                                var margin:String = list_item_values[0];

                                if (this.IsNotValidOption(margin, option, isDefaultOption))
                                    continue;

                                if (!list_item_values[3]) list_item_values[3] = "1";

                                productsContent = this.addToRequest(productsContent, indent
                                        + "<" 
                                        + keys.product
                                        + " id='" + this.getCISCode(margin) + "'"
                                        + " type='" + list_item_values[1] + "'"
                                        + " unit='" + list_item_values[2] + "'"
                                        + " price='n/a'"
                                        + ">"
                                        + list_item_values[3]
                                        + "</" 
                                        + keys.product 
                                        + ">"
                                    );
                            }
                        }

                        continue;
                    }

                    if (this.IsNotValidOption(this.getCISId(id, true), option, isDefaultOption))
                        continue;

                    value = this.getSelectedItemValue(id);

                    if (cis && value)
                    {
                        if (cis_type == this.TYPE_CONSTRUCT)
                        {
                            //
                            // Базовый артикул (construct)
                            //
                            if (isWithConstruct) productsContent = this.addToRequest(productsContent, indent
                                    + "<" 
                                    + keys.product
                                    + " id='" + cis + "'"
                                    + " type='" + this.fieldContentType[id] + "'"
                                    + " unit='" + this.fieldUnitID[id] + "'"
                                    + " price='n/a'"
                                    + ">"
                                    + value
                                    + "</" 
                                    + keys.product 
                                    + ">"
                                );
                        }
                        else if (cis_type == this.TYPE_PROGRESS || cis_type == this.TYPE_PRODUCT)
                        {
                            //
                            // Продукт
                            //
                            productsContent = this.addToRequest(productsContent, indent
                                    + "<" 
                                    + keys.product
                                    + " id='" + cis + "'"
                                    + " type='" + this.fieldContentType[id] + "'"
                                    + " unit='" + this.fieldUnitID[id] + "'"
                                    + " price='n/a'"
                                    + ">"
                                    + value
                                    + "</" 
                                    + keys.product 
                                    + ">"
                                );
                        }
                        else if (this.fieldContentType[id] == 'LIST')
                        {
                            //
                            // Параметр с типом поля LIST
                            //
                            parametersContent = this.addToRequest(parametersContent, indent
                                    + "<" 
                                    + keys.parameter
                                    + " id='" + cis + "_" + value + "'"
                                    + " parent='" + cis + "'"
                                    + " type='BOOLEAN'"
                                    + " unit='" + this.fieldUnitID[id] + "'"
                                    + " price='n/a'"
                                    + ">true"
                                    + "</" 
                                    + keys.parameter
                                    + ">"
                                );
                        }
                        else
                        {
                            //
                            // Параметр
                            //
                            parametersContent = this.addToRequest(parametersContent, indent
                                    + "<" 
                                    + keys.parameter
                                    + " id='" + cis + "'"
                                    + " type='" + this.fieldContentType[id] + "'"
                                    + " unit='" + this.fieldUnitID[id] + "'"
                                    + " price='n/a'"
                                    + ">"
                                    + value
                                    + "</" 
                                    + keys.parameter
                                    + ">"
                                );
                        }
                    }
                    else if (value)
                    {
                        if (this.IsServiceItem(id))
                        {
                            //
                            // Служебный параметр
                            //
                            parametersContent = this.addToRequest(parametersContent, indent
                                    + "<" 
                                    + keys.parameter
                                    + " id='" + this.getCISCode(id) + "'"
                                    + " type='" + this.fieldContentType[id] + "'"
                                    + " unit=''"
                                    + " price='n/a'"
                                    + ">"
                                    + value
                                    + "</" 
                                    + keys.parameter
                                    + ">"
                                );
                        }
                    }
                }
            }

            // -------------------------
            // Product <construct> value
            // -------------------------

            if (this.helperDefaultConstruct.length > 0 && this.helperDefaultConstructCount > 0 && isWithConstruct)
            {
                productsContent = this.addToRequest(productsContent, indent
                        + "<" 
                        + keys.product
                        + " id='" + "construct" + this.helperDefaultConstruct + "'"
                        + " type='NUMBER'"
                        + " unit=''"
                        + " price='n/a'"
                        + ">"
                        + String(this.helperDefaultConstructCount)
                        + "</" 
                        + keys.product 
                        + ">"
                    );
            }

            // -------------------------
            // Parameter wizard ID value
            // -------------------------

            if (this.helperTags.wizard)
            {
                parametersContent = this.addToRequest(parametersContent, indent
                        + "<" 
                        + keys.parameter
                        + " id='cp_wizard_id'"
                        + " type='STRING'"
                        + " unit=''"
                        + " price='n/a'"
                        + ">"
                        + this.helperWizardID
                        + "</" 
                        + keys.parameter
                        + ">"
                    );
            }

            // -------
            // Footers
            // -------

            productsContent = this.TAB + (productsContent == "" ? 
                "<" + keys.products + "/>" : "<" + keys.products + ">" + this.EOL + productsContent + this.EOL + this.TAB + "</" + keys.products + ">"
                );
            parametersContent = this.TAB + (parametersContent == "" ? 
                "<" + keys.parameters + "/>" : "<" + keys.parameters + ">" + this.EOL + parametersContent + this.EOL + this.TAB + "</" + keys.parameters + ">"
                );

            request = this.addToRequest(request, parametersContent);
            request = this.addToRequest(request, productsContent);
            
            return request;
        }

        private function setXMLRequest(actionID:String=null):void
        {
            var request:String = new String("");
            var indent:String = '';
            //
            // Make CIS header
            //
            indent = this.TAB;
            
            request = this.addToRequest(request, "<?xml version='1.0' encoding='UTF-8'?>");
            request = this.addToRequest(request, this.helperKeyWords["queryDoctypeDescription"]);
            request = this.addToRequest(request, "<document id='exchangeData' type='fieldsValue' xmlns:wms=''>");

            // --------------------
            // Common Document Area
            // --------------------

            request = this.addToRequest(request, indent + "<system id='CIS' version='" + this.helperKeyWords["CIS"] + "'/>");
            request = this.addToRequest(request, indent + "<task id='CALCHELPER' version='" + this.helperLoadedVersion + "'/>");
            request = this.addToRequest(request, indent + "<description id='ExchangeContent'" + 
                    " version='" + this.helperXMLVersion + "'" +
                    " scenario='" + (this.isInternalMode ? '1' : (this.isExternalMode ? '2' : (this.isTransferMode ? '3' : this.n_a))) + "'" +
                    (this.helperDetailed ? " detailed='1'" : "") + 
                    "/>");
            request = this.addToRequest(request, indent + "<action>" + (actionID ? actionID : this.currentHelperActionID) + "</action>");
            request = this.addToRequest(request, indent + "<countryID>" + this.helperCountryID + "</countryID>");
            request = this.addToRequest(request, indent + "<currency>" + this.helperDefaultCurrency + "</currency>");
            request = this.addToRequest(request, indent + (this.cisDocumentDate == "" ? "<documentDate/>" : "<documentDate>" + this.cisDocumentDate + "</documentDate>"));
            request = this.addToRequest(request, indent + (this.cisDocumentNumber == "" ? "<documentNumber/>" : "<documentNumber>" + this.cisDocumentNumber + "</documentNumber>"));
            request = this.addToRequest(request, indent + "<errorCode>" + this.returnedErrorCode + "</errorCode>");
            request = this.addToRequest(request, indent + "<errorDescription>" + this.returnedErrorDescr + "</errorDescription>");
            request = this.addToRequest(request, indent + "<guid>" + this.helperGUID + "</guid>");
            request = this.addToRequest(request, indent + "<httpHost>" + this.helperHttpHost + "</httpHost>");
            request = this.addToRequest(request, indent + "<httpReferer><![CDATA[" + this.helperHttpReferer + "]]></httpReferer>");
            request = this.addToRequest(request, indent + "<language id='" + this.helperLocalization + "'/>");
            request = this.addToRequest(request, indent + (this.cisDocumentPosition == "" ? "<lineNumber/>" : "<lineNumber>" + this.cisDocumentPosition + "</lineNumber>"));

            // ------------------------------------
            // Order info for client's notification
            // ------------------------------------

            request = this.addToRequest(request, indent + "<orderEmail>" + this.helperOrderEmail + "</orderEmail>");

            var items:Array = this.getXMLParametersValue();
            var orderInfo:String = new String("");
            var x:Object;

            if (items) {
                for each(x in items) {
                    orderInfo += (x["title"] + "::" + x["value"] + "||");
                }
            }

            request = this.addToRequest(request, indent + "<orderInfo>" + orderInfo + "</orderInfo>");
            request = this.addToRequest(request, indent + "<pageLocation><![CDATA[" + this.helperPageLocation + "]]></pageLocation>");
            request = this.addToRequest(request, indent + "<priceTypeID>" + this.helperPriceTypeID + "</priceTypeID>");
            request = this.addToRequest(request, indent + "<purchaseID>" + this.helperPurchaseID + "</purchaseID>");
            request = this.addToRequest(request, indent + "<regionID>" + this.helperRegionID + "</regionID>");
            request = this.addToRequest(request, indent + "<security>" + this.cisSecurityFile + "</security>");
            request = this.addToRequest(request, indent + "<sessionID>" + this.helperSessionID + "</sessionID>");
            request = this.addToRequest(request, indent + "<status>" + this.helperStatus + "</status>");
            request = this.addToRequest(request, indent + "<total>" + (this.cisCostValue ? this.cisCostValue : n_a) + "</total>");
            request = this.addToRequest(request, indent + "<userID>" + this.helperUserID + "</userID>");
            request = this.addToRequest(request, indent + "<userTypeID>" + this.helperUserTypeID + "</userTypeID>");
            request = this.addToRequest(request, indent + "<webResource>" + this.helperHostName + "</webResource>");
            request = this.addToRequest(request, indent + "<withoutDB>" + String(this.isWorkWithout1C) + "</withoutDB>");
            request = this.addToRequest(request, indent + "<withoutRestriction>" + String(this.isWithoutRestriction) + "</withoutRestriction>");
            request = this.addToRequest(request, indent + "<wizardID>" + this.helperWizardID + "</wizardID>");
            request = this.addToRequest(request, indent + "<wizardName>" + this.helperDefaultName + "</wizardName>");

            // ---------------------------------------------------
            // Items (Products & Parameters) for valid XML version
            // ---------------------------------------------------

            var keys:Object = {'products':'products', 'product':'product', 'parameters':'parameters', 'parameter':'parameter'};
            var content:String = "";
            var id:String = new String("");
            var isDefaultOption:Boolean = true;

            indent = this.TAB + this.TAB;

            switch (this.helperXMLVersion)
            {
                case '2':
                    keys.products = 'options';
                    keys.product = 'option';

                    request = this.addToRequest(request, "<products>");

                    for (var option:String in this.helperListOfOptions)
                    {
                        id = this.helperListOfOptions[option];
                        if (!id)
                            continue;
                        isDefaultOption = option.toLowerCase() == 'a' ? true : false;

                        request = this.addToRequest(request, indent
                                + "<product" 
                                + " id='" + id + "'"
                                + " type='NUMBER'"
                                + " unit=''"
                                + " price='n/a'"
                                + " value='1'"
                                + (isDefaultOption ? " default='1'" : "")
                                + ">"
                            );

                        content = this.setRequestContent(indent + indent, keys, option, isDefaultOption, false);
                        request = this.addToRequest(request, content);

                        request = this.addToRequest(request, indent
                                + "</product>" 
                            );
                    }

                    request = this.addToRequest(request, "</products>");
                    break;

                default:
                    content = this.setRequestContent(indent, keys, '', isDefaultOption, true);
                    request = this.addToRequest(request, content);
            }

            request = this.addToRequest(request, "</document>");

            this.queryXML = new XML(request);
        }

        private function getSelectedItemValue(id:String, cis_value:Boolean=true):String
        {
            var value:String = new String("");

            switch(this.fieldContentType[id])
            {
                case(this.helperKeyWords["LIST"]):
                    var a:Object = this.DisplayingService.getListSelectedItemValue(id);
                    value = cis_value ? a.id : a.label; // .toLowerCase()
                    break;

                case(this.helperKeyWords["NUMBER"]):
                    if (this.helperProjectVars[id] && parseInt(this.helperProjectVars[id]) !== 0)
                    {
                        value = String(this.helperProjectVars[id]);
                    }
                    break;

                case(this.helperKeyWords["BOOLEAN"]):
                    if (this.helperProjectVars[id])
                    {
                        value = "true"; //String(this.helperProjectVars[id]);
                    }
                    break;

                case(this.helperKeyWords["DATE"]):
                    value = String(this.helperProjectVars[id]);
                    break;

                default:
                    value = String(this.helperProjectVars[id]);
            }

            return value;
        }

        private function getValueInLines(value:String):String
        {
            var words:Array = value.split(" ");
            var line:String = new String("");
            var output:String = new String("");

            for each(var word:String in words)
            {
                word = strip(word);
                if (line.length > this.INPUTAREA_LINE_LENGTH)
                {
                    output += line + this.EOL;
                    line = "";
                }
                if (line) line += " ";
                line += word;
            }
            if (line) output += line;
            return output;
        }

        private function checkConfirmationType(id:String):String
        {
            var x:String = this.fieldType[id];
            if ((!x || x == this.helperKeyWords["CONSTANT"]) && this.fieldCISID[id].indexOf('confirmation') > -1)
                x = this.helperKeyWords["inputAREA"];
            return x;
        }

        // ===============
        //  XML GENERATOR
        // ===============

        public function getXMLParametersValue():Array
        {
            var items:Array = new Array();
            var id:String = new String("");
            var cis:String = new String("");
            var cis_type:String = new String("");
            var field_type:String = new String("");
            var value:String = new String("");
            var show:Boolean = new Boolean(false);

            var a:Object;
            var prev_a:Object = {title:'', value:''};
            
            for (var i:int=0; i < this.allVariableNames.length; i++)
            {
                id = this.allVariableNames[i];
                show = false;

                if (this.IsAttrVisible(id))
                {
                    value = strip(this.getSelectedItemValue(id, false));
                    a = this.getVisualItemAttrs(id);

                    show = true;
                }

                else if (this.IsItemShouldBeAddedToRequest(id))
                {
                    cis = this.fieldCISID[id];

                    if (!cis)
                        continue;

                    value = strip(this.getSelectedItemValue(id, false));
                    cis_type = this.getTypeOfItem(cis);

                    if (value === "" || cis_type == this.TYPE_CONSTRUCT || this.IsTypeListOfProgress(id) || this.IsAttrHidden(id))
                        continue;

                    a = this.getVisualItemAttrs(id);
                    field_type = this.checkConfirmationType(id);

                    switch(field_type)
                    {
                        case(this.helperKeyWords["CHECKBOX"]):
                            value = this.getMessage(20);
                            break;
                        case(this.helperKeyWords["inputAREA"]):
                            value = getValueInLines(value);
                    }

                    switch(value.toLowerCase()) 
                    {
                        case('true'):
                            value = this.fieldTitle.hasOwnProperty(id) ? this.fieldTitle[id] : '';
                            if (!value) value = this.getMessage(20);
                            break;
                        case('false'):
                        case('no'):
                            value = this.getMessage(21);
                            break;
                    }
                    
                    show = value ? true : false; // a.title && 
                }

                if (show)
                {
                    if (a.title == value || a.title == prev_a.title || a.title == prev_a.value)
                        a.title = '';
                    if (a.unit) // && ['INPUT FIELD', 'CONSTANT'].indexOf(field_type) > -1
                        a.title = a.title ? strip(a.title) + ', ' + a.unit : a.unit;
                    if (value && cis_type == this.TYPE_PRODUCT)
                        value += ' [' + this.getCISCode(cis) + ']';
                    if (cis_type == this.TYPE_PROGRESS)
                        value += ' (™)';
                    else if (id.substr(id.length - 3, 3).toLowerCase() == '_up')
                        value += ' (*)';

                    items.push({'id':id, 'title':a.title, 'value':value, 'field_type':field_type, 'cis_type':cis_type});

                    if (a.title) prev_a.title = a.title;
                    prev_a.value = value;
                }
            }
            
            return items;
        }

        // =====================
        //  PopUp Menu Handlers
        // =====================

        private function loadGroupPositionOnForm():void
        {
            var item:ContextMenuItem;

            for each (var ob:Object in this.quickRefGroupObject)
            {
                item = new ContextMenuItem(ob.label);
                item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, this.appContextMenuItemSelected);
                this.appContextMenu.customItems.push(item);
            }

            // ----------------------
            // Validate toolbar state
            // ----------------------

            this.appObjectList['toolbar'].validateState();
        }

        private function appContextMenuSelected(appEvent:ContextMenuEvent):void
        {
            if (this.appContextMenu.customItems.length <= 0)
            {
                this.loadGroupPositionOnForm();
            }
        }

        private function appContextMenuItemSelected(appEvent:ContextMenuEvent):void
        {
            this.selectContextMenuItem(appEvent.currentTarget.caption);
        }

        private function selectContextMenuItem(label:String, expand:Boolean=false):void
        {
            var position:Number = new Number(0);
            var offset:Number = new Number(0);

            for each(var ob:Object in this.quickRefGroupObject)
            {
                if (ob.label == label || ob.group_id == label)
                {
                    if (expand)
                        this.DisplayingService.changeGroupState(ob.group_id, true);
                    offset = this.fieldFormat[ob.group_id] == 'HIDDEN' ? 5 : 0;
                    position = ob.ref.top + offset;
                    if (position < 20) position = 0;
                    break;
                }
            }

            this.appObjectList['inputArea'].verticalScrollPosition = position;
        }

        // ===============================
        //  Communication Action Handlers
        // ===============================

        public function isItemValid(item:String):Boolean
        {
            return !item || item == n_a ? false : true;
        }

        public function isStatusValid():Boolean
        {
            return this.isItemValid(this.helperStatus);
        }

        public function isStatusNew():Boolean
        {
            return this.isItemValid(this.helperStatus) && this.helperStatus == '0' ? true : false;
        }

        public function isStatusExists():Boolean
        {
            return this.isItemValid(this.helperStatus) && this.helperStatus == '1' ? true : false;
        }

        public function IsOrderExists():Boolean
        {
            return this.isItemValid(this.helperGUID) && this.isItemValid(this.cisDocumentNumber) ? true : false;
        }

        public function executeAction(evntObj:MouseEvent):void
        {
            var buttonType:String = new String("");
            var code:Number = new Number(0);

            if (!evntObj) return;

            switch(evntObj.currentTarget)
            {
                case(this.appObjectList['checkButton']):
                    buttonType = "checkButton";
                    break;

                case(this.appObjectList['saveButton']):
                    buttonType = "saveButton";
                    break;

                default:
                    buttonType = "closeButton";
            }

            this.queryProcessingState = 0;
            this.currentHelperActionID = this.actionButtons[buttonType];
 
            this.executeBeforeAction();
        }

        public function executeBeforeAction():void
        {
            var actionID:String = this.currentHelperActionID;
            var code:Number = new Number(0);

            if (!this.queryProcessingState) switch(actionID)
            {
                case("204"):
                case("207"):
                    if (this.isTransferMode)
                    {
                        with (this.RequestService)
                        {
                            currentType = this.helperKeyWords["External"];
                            isExternalReady = false;
                        }
                        this.isFirstTransfer = true;
                    }
                    if (actionID == "204")
                    {
                        this.openReportInfoWindow();
                        code = 1;
                    }
                    break;

                case("208"):
                    if (this.isExternalMode)
                    {
                        code = this.RequestService.backByHistory();
                    }
                    else if (this.isTransferMode)
                    {
                        with (this.RequestService)
                        {
                            currentType = this.helperKeyWords["External"];
                            isExternalReady = false;
                        }
                        this.isFirstTransfer = true;
                        actionID = "204";
                    }
                    break;

                default:
                    code = 0;
            }

            if (code) return;

            this.executeMainAction(actionID);
        }

        public function executeMainAction(actionID:String=null):void
        {
            if (!actionID)
                actionID = this.currentHelperActionID;

            if (!this.IsRequestValid())
            {
                this.check(-9);
                return;
            }
                
            this.openBusyModalWindow();

            this.cisCostValue = "";

            this.setXMLRequest(actionID);

            with (this.RequestService)
            {
                sendRequest();
            }
        }

        public function executeAfterAction():void
        {
            var actionID:String = this.currentHelperActionID;
            var is_complete:Boolean = new Boolean(true);
            var code:Number = new Number(0);

            if (!this.queryProcessingState) switch(actionID)
            {
                case("203"):
                    if (this.isTransferMode && this.isFirstTransfer)
                    {
                        if (this.isFirstTransaction)
                        {
                            with (this.RequestService)
                            {
                                sendInitRequest();
                            }
                            is_complete = false;
                        } 
                        else if (this.isStatusNew())
                        {
                            with (this.RequestService)
                            {
                                currentType = this.helperKeyWords["External"];
                                isExternalReady = false;
                            }

                            this.executeMainAction();

                            this.isFirstTransfer = false;
                            is_complete = false;
                        }
                        else
                        {
                            this.isFirstTransfer = false;
                        }
                    }
                    break;

                case("204"):
                    break;

                case("207"):
                case("208"):
                    if (this.isTransferMode && this.isFirstTransfer)
                    {
                        // -------------------------------------------
                        // Копия заказа: External->Internal (Transfer)
                        // -------------------------------------------

                        this.queryXML = this.respondXML.copy();

                        with (this.queryXML)
                        {
                            if (action != actionID)
                                replace("action", "<action>" + actionID + "</action>");
                        }

                        with (this.RequestService)
                        {
                            currentType = this.helperKeyWords["Internal"];
                            isInternalReady = false;

                            sendRequest();
                        }

                        is_complete = false;
                        this.isFirstTransfer = false;
                    }
                    else if (actionID == "207")
                        this.openOrderInfoWindow();
                    break;

                default:
                    code = 0;
            }

            if (is_complete)
            {
                this.removeBusyModalWindow();
                this.currentHelperActionID = "";
            }

            this.setCalculatingEnabled(true);

            if (this.isTransferMode && this.IsOrderExists())
            {
                this.appObjectList['saveButton'].enabled = false;
            }

            this.isFirstTransaction = false;
        }

        // ==================
        //  Forms Management
        // ==================

        protected function goReportInfoWindow():void
        {
            var ob:ReportInfoForm;
            ob = PopUpManager.createPopUp(this.appObjectList['mxmlApplication'], ReportInfoForm, true) as ReportInfoForm;
        }

        protected function goOrderInfoWindow():void
        {
            var ob:OrderInfoForm;
            ob = PopUpManager.createPopUp(this.appObjectList['mxmlApplication'], OrderInfoForm, true) as OrderInfoForm;

            ob.x = (Application.application.width - ob.width) / 2;
            ob.y = (Application.application.height - ob.height) / 2;
        }

        private function openReportInfoWindow():void
        {
            if (this.helperProductControl['enabled'])
            {
                with (this.helperProductControl)
                {
                    active = true;
                    type = 1;
                }
                this.calculate(1);
            }
            else
                this.goReportInfoWindow();
        }

        private function openOrderInfoWindow():void
        {
            if (this.helperProductControl['enabled'])
            {
                with (this.helperProductControl)
                {
                    active = true;
                    type = 2;
                }
                this.calculate(1);
            }
            else
                this.goOrderInfoWindow();
        }

        private function openErrorMessageWindow():void
        {
            var ob:ErrorMessageForm;
            ob = PopUpManager.createPopUp(this.appObjectList['mxmlApplication'], ErrorMessageForm, true) as ErrorMessageForm;
        }

        private function openConfirmMessageWindow():void
        {
            var ob:ConfirmMessageForm;
            ob = PopUpManager.createPopUp(this.appObjectList['mxmlApplication'], ConfirmMessageForm, true) as ConfirmMessageForm;
        }

        private function openUserInfoWindow():void
        {
            var ob:UserInfoForm;
            ob = PopUpManager.createPopUp(this.appObjectList['mxmlApplication'], UserInfoForm, true) as UserInfoForm;

            ob.x = (Application.application.width - ob.width) / 2;
            ob.y = (Application.application.height - ob.height) / 2;
        }

        // ======
        //  MAIN
        // ======

        public function check(code:Number=0):void
        {
            this.ErrorService.errorAnalyser(false, code);
            this.LogService.setNewLogRecord(true, 1, this.helperProjectVars["attentionMessage"]);
            this.LogService.setNewLogRecord(true, 0, this.helperProjectVars["NoticeMessage"]);
        }

        public function display():void
        {
            var code:Number = new Number(0);

            code = this.DisplayingService.display();
            this.ErrorService.errorAnalyser(true, code);
        }

        public function upload(mode:Number=0):void
        {
            this.CalculatingService.upload();

            // Show default prompting
            if (!mode)
                this.setHelpMessage("");
        }

        public function calculate(mode:Number=0):void
        {
            var code:Number = new Number(0);

            if (!mode)
                this.cleanSystemMessage();

            code = this.CalculatingService.calculate();

            if (code)
            {
                this.check(code);
                this.finish();
            }
            else
            {
                this.check(this.helperProjectVars["helperErrorCode"]);

                if (this.helperProjectVars["confirmMessage"])
                {
                    this.upload(1);
                    this.openConfirmMessageWindow();
                }
                else
                    this.go(mode);
            }

            if (!this.helperProjectVars["helperErrorCode"])
                this.setFocusOn();
        }

        public function go(mode:Number=0):void
        {
            this.upload(mode);

            if (this.helperProjectVars["isAutoChanged"] || this.helperProjectVars["isConfirmation"])
                this.calculate(1);

            if (this.helperProjectVars["helperErrorCode"] == -1)
                this.helperProjectVars["helperErrorCode"] = 0;

            if (this.helperProductControl.finalize)
                this.finalize();
            else
                this.finish();
        }

        public function finish():void
        {
            this.display();
        }

        public function finalize():void
        {
            var x:Number = this.helperProductControl["type"];

            with (this.helperProductControl)
            {
                active = false;
                finalize = false;
                type = 0;
            }

            switch (x) {
                case 1:
                    this.goReportInfoWindow();
                    break;
                case 2:
                    this.goOrderInfoWindow();
            }
        }
    }
}
