package main
{
    // Created:      14.05.2015
    // Created by:   I.E.Kharlamov

    import r1.deval.D;

    public class calculatingService
    {
        private  var parent:Object;
        private  var codeExecuteRetVal:Object;
        private  var myLibrary:Object;
        private  var myCommonScripts:Object;

        internal var $products:Number = 0;
        internal var $parameters:Number = 0;

        /* -------------------------- */
           include "../lib/utils.as";
        /* -------------------------- */

        public function calculatingService(parentObjRef:Object)
        {
            this.parent = parentObjRef;

            D.useCache(true, 204800);
        }

        public function initState():Number
        {
            var container:Object = this.parent.helperProjectVars;
        
            var id:String = new String("");
            var counter:Number = new Number(-1);
            var path:String = new String("");
            var s:String = new String("");
            var n:Number = new Number(0);
            
            var code:Number = new Number(0);
            var myTmpBool:Boolean = new Boolean(false);

            // Initialization
            code = 0;

            // Scripts compilation
            this.myLibrary = D.parseFunctions(this.parent.helperScriptFunction);
            this.myCommonScripts = D.parseProgram(this.parent.helperScriptContent);

            // To merge the form and the content
            // Form processing
            code = this.getFormDescription();

            if (!code)
            {
                // Content processing
                code = this.getContentDescription();

                if (!code)
                {
                    // Repository
                    code = this.getRepositoryDescription();

                    if (!code)
                    {
                        // Loading Groups and SubGroups
                        code = this.getGroupsDescription();
                    }
                }
            }

            // Get default settings
            //this.parent.mainFormPaddingLeft = this.parent.appObjectList['inputArea'].getStyle("paddingLeft");

            // Main constants and variables
            container["attentionMessage"] = "";
            container["confirmCode"] = -1;
            container["confirmMessage"] = "";
            container["helperErrorCode"] = 0;
            container["helperErrorMessage"] = "";
            container["NoticeMessage"] = "";
            container["scriptExecCount"] = 0;
            container["setCallingFunction"] = false;
            container["setImageURI"] = "";
            container["specialCalculate"] = false;
            container["defaultProduct"] = "";
            container["defaultPrompting"] = "";
            container["changedFormFieldID"] = "";
            container["calculatingDisabled"] = -1;

            container["LST_INDEX_DELIMETER"] = this.parent.helperKeyWords["listIndexDelimeter"];
            container["LST_INDICES_DELIMETER"] = this.parent.helperKeyWords["listIndicesDelimeter"];
            container["LST_VALUE_DELIMETER"] = this.parent.helperKeyWords["listValueDelimeter"];
            container["LST_ITEM_DELIMETER"] = this.parent.helperKeyWords["listItemDelimeter"];

            container["helperLoadedVersion"] = this.parent.helperLoadedVersion;
            container["helperVersion"] = this.parent.helperLoadedVersion;

            container["constructs"] = this.parent.helperConstructs;
            container["options"] = this.parent.helperListOfOptions;

            container["objectStatus"] = this.parent.fieldStatus;
            container["cisSecurityFile"] = this.parent.cisSecurityFile;
            container["cisVersion"] = this.parent.helperKeyWords["CIS"];
            container["countryID"] = this.parent.helperCountryID;
            container["currencyName"] = this.parent.helperDefaultCurrency;
            container["currentLocale"] = this.parent.helperLocalization;
            container["defaultConstruct"] = this.parent.helperDefaultConstruct;
            container["defaultConstructCount"] = this.parent.helperDefaultConstructCount;
            container["documentDate"] = this.parent.cisDocumentDate;
            container["documentNumber"] = this.parent.cisDocumentNumber;
            container["documentPosition"] = this.parent.cisDocumentPosition;
            //container["formPaddingLeft"] = this.parent.mainFormPaddingLeft;
            container["helperStyleID"] = this.parent.helperStyleID;
            container["priceTypeID"] = this.parent.helperPriceTypeID;
            container["purchaseID"] = this.parent.helperPurchaseID;
            container["regionID"] = this.parent.helperRegionID;
            container["returnedErrorCode"] = this.parent.returnedErrorCode;
            container["returnedErrorDescr"] = this.parent.returnedErrorDescr;
            container["userID"] = this.parent.helperUserID;
            container["userTypeID"] = this.parent.helperUserTypeID;
            container["withoutRestriction"] = this.parent.isWithoutRestriction;
            container["wizardName"] = this.parent.helperDefaultName;

            container["isAutoChanged"] = false;
            container["isConfirmation"] = false;
            container["isWorkWithout1C"] = this.parent.isWorkWithout1C;
            container["isItemStyle"] = this.parent.isItemStyle;

            container["imagePath"] = this.parent.imagePath;
            container["imageX"] = this.parent.imageX;
            container["imageY"] = this.parent.imageY;
            container["imageVisibility"] = this.parent.imageVisibility;

            // Return code jf deval
            container["devalRetCode"] = 0;

            return code;
        }

        protected function getItemValue(ob:Object, id:String, xml:XML, name:String):String
        {
            var code:String = new String("");

            if (ob.hasOwnProperty(id))
            {
                code = ob[id];
                if (xml.field.(@name==name).toString() != "")
                    code = xml.field.(@name==name).toString();
            }
            else
                code = xml.field.(@name==name).toString();

            return code;
        }

        protected function toNumber(myValue:String):Number
        {
            var value:Number = new Number(0);
            var num:String = new String("");
            var s:String = new String("");
            var parts:Array = new Array();

            if (myValue != "")
            {
                num = myValue;
                parts = num.split(" ");
                num = parts.join();

                parts = num.split(",");

                if (parts.length == 2)
                    num = parts.join(".");
                else
                    num = parts.join();

                value = Number(num);

                if (isNaN(value))
                    value = 0;
            }

            return value;
        }

        protected function toBoolean(myValue:String):Boolean
        {
            var value:Boolean = new Boolean(false);

            if (myValue != "" && myValue != null)
            {
                myValue = myValue.toUpperCase();
                if (myValue != "FALSE" && myValue != "0")
                    value = true;
            }

            return value;
        }

        protected function toDate(sourceVal:String):Date
        {
            var value:Date = new Date();
            var parts:Array = new Array();

            parts = sourceVal.split(".");
            if (parts.length < 3)
            {
                parts = sourceVal.split("/");
                if (parts.length < 3)
                {
                    parts = sourceVal.split("\\");
                    if (parts.length < 3)
                    {
                        parts = sourceVal.split("-");
                        if (parts.length < 3)
                        {
                            parts[0] = "1";
                            parts[1] = "1";
                            parts[2] = "1000";
                        }
                    }
                }
            }

            if (isNaN(Number(parts[0])) || isNaN(Number(parts[1])) || isNaN(Number(parts[2])))
            {
                parts[0] = "1";
                parts[1] = "1";
                parts[2] = "2009";
            }

            value.setFullYear(Number(parts[2]), (Number(parts[1]) - 1), Number(parts[0]));

            return value;
        }

        protected function dateToString(current:Date):String
        {
            var value:String = new String("");
            var D:String = new String("");
            var M:String = new String("");
            var Y:String = new String("");

            D = String(current.getDate());
            M = String(current.getMonth() + 1);
            Y = String(current.getFullYear());

            if (D.length < 2)
                D = "0" + D;

            if (M.length < 2)
                M = "0" + M;

            value = D + "." + M + "." + Y;

            return value;
        }

        protected function register_cis(id:String, cis:String):void
        {
            //
            // Register simple and compound CIS: {<option>:}<ID>
            //
            if (id && cis)
            {
                this.parent.fieldIDtoCIS[cis] = id;
                if (cis.indexOf(this.parent.DR) > -1)
                {
                    this.parent.fieldIDtoCIS[cis.split(this.parent.DR)[1]] = id;
                }
            }
        }

        // -------------------------
        //  XML Descriptions Loader
        // -------------------------

        public function getFormDescription():Number
        {
            var record:XML = new XML();
            var id:String = new String("");
            var kind:String = new String("");
            var s:String = new String("");
            var path:String = new String("");
            var n:Number = new Number(0);
            var counter:Number = new Number(-1);
            var code:Number = new Number(0);
            var myTmpBool:Boolean = new Boolean(false);

            for each (record in this.parent.formXML.record)
            {
                counter++;

                id = record.@id.toString();
                kind = record.field.(@name=="Kind").toString();

                this.parent.allVariableNames[counter] = id;

                if (kind == this.parent.helperKeyWords["GROUP"])
                {
                    s = record.field.(@name=="Style").toString();
                    if (s) this.parent.fieldStyle[id] = s;
                    continue;
                }

                this.parent.fieldStatus[id] = 1;
                this.parent.fieldType[id] = kind;
                this.parent.fieldCurrStatus[id] = this.parent.fieldStatus[id];
                this.parent.fieldCISID[id] = record.field.(@name=="ID").toString();
                this.parent.fieldTitle[id] = record.field.(@name=="Label").toString();
                this.parent.fieldDescription[id] = record.field.(@name=="Description").toString();
                this.parent.fieldContentType[id] = record.field.(@name=="Type").toString();
                this.parent.fieldFormat[id] = record.field.(@name=="Format").toString();
                this.parent.fieldGroup[id] = record.field.(@name=="GroupID").toString();
                this.parent.fieldSubGroup[id] = record.field.(@name=="SubGroupID").toString();
                this.parent.fieldUnitID[id] = record.field.(@name=="UnitID").toString();
                this.parent.fieldIllustration[id] = record.field.(@name=="Illustration").toString();
                this.parent.fieldStyle[id] = record.field.(@name=="Style").toString();

                // Communication ID
                this.register_cis(id, this.parent.fieldCISID[id]);

                // Display order
                switch (this.parent.fieldType[id])
                {
                    case(this.parent.helperKeyWords["FUNCTION"]):
                    case(this.parent.helperKeyWords["CONSTANT"]):
                    case(this.parent.helperKeyWords["PROGRESS"]):
                        break;
                    default:
                        this.parent.formObjectListIds.push(id);
                }

                // Content
                s = record.field.(@name=="CurrentValue").toString();

                switch (this.parent.fieldContentType[id])
                {
                    case(this.parent.helperKeyWords["NUMBER"]):
                        this.parent.fieldCurrentContent[id] = this.toNumber(s);
                        break;

                    case(this.parent.helperKeyWords["BOOLEAN"]):
                        this.parent.fieldCurrentContent[id] = this.toBoolean(s);
                        break;

                    case(this.parent.helperKeyWords["DATE"]):
                        this.parent.fieldCurrentContent[id] = this.toDate(s);
                        break;

                    case(this.parent.helperKeyWords["LIST"]):
                        s = s.replace(/\r/gi, "");
                        s = s.replace(/\n/gi, "");
                        s = s.replace(/\t/gi, "");
                        this.parent.fieldCurrentContent[id] = s;
                        break;

                    default:
                        this.parent.fieldCurrentContent[id] = s;
                }

                this.parent.helperProjectVars[id] = this.parent.fieldCurrentContent[id];

                //  Формат данных (структура атрибутов поля, Field Icon):
                //      {B:I:U:W:H:T:L:R:Z}
                //  где:
                //      <B> - use label: 0-no/1-left label/2-right label
                //      <I> - use icon
                //      <P> - image uri
                //      <W> - image width
                //      <H> - image height
                //      <T> - field padding top
                //      <L> - container padding left
                //      <R> - right label padding top
                //      <Z> - icon zoom

                s = record.field.(@name=="Icon").toString();
                if (s)
                {
                    var x:Array = s.split(":");
                    var f:Object;

                    f = new Object(); // {'label':false, 'icon':false, 'uri':'', 'width':0, 'height':0, 'top':0, 'left':0};

                    for (var i:int=0; i < 9; i++)
                    {
                        if (x.length < i + 1)
                            x.push(i == 2 ? '' : 0);
                        else if (i == 2)
                            x[i] = x[i].toString();
                        else
                            x[i] = Number(x[i]);

                        if (i == 0)
                            f['label'] = x[i];
                        else if (i == 1)
                            f['icon'] = x[i];
                        else if (i == 2)
                            f['uri'] = x[i];
                        else if (i == 3)
                            f['width'] = x[i];
                        else if (i == 4)
                            f['height'] = x[i];
                        else if (i == 5)
                            f['top'] = x[i];
                        else if (i == 6)
                            f['left'] = x[i];
                        else if (i == 7)
                            f['right_label_padding_top'] = x[i];
                        else
                            f['zoom'] = x[i];
                    }

                    this.parent.fieldIcon[id] = f;
                }
            }

            return code;
        }

        public function getContentDescription():Number
        {
            var record:XML = new XML();
            var id:String = new String("");
            var s:String = new String("");
            var path:String = new String("");
            var n:Number = new Number(0);
            var counter:Number = new Number(-1);
            var code:Number = new Number(0);
            var myTmpBool:Boolean = new Boolean(false);

            for each (record in this.parent.contentXML.table.(@name=="HelperTaskDescription").record)
            {
                counter++;

                id = record.@id;

                if (this.parent.allVariableNames.indexOf(id) < 0)
                {
                    counter = this.parent.allVariableNames.length;
                    this.parent.allVariableNames[counter] = id;
                }

                if (!this.parent.fieldStatus.hasOwnProperty(id))
                {
                    this.parent.fieldStatus[id] = 1;
                    this.parent.fieldCurrStatus[id] = this.parent.fieldStatus[id];
                }

                this.parent.fieldCISID[id] = this.getItemValue
                    (
                        this.parent.fieldCISID,
                        id,
                        record,
                        "ID"
                    );

                this.register_cis(id, this.parent.fieldCISID[id]);

                this.parent.fieldTitle[id] = this.getItemValue
                    (
                        this.parent.fieldTitle,
                        id,
                        record,
                        "Label"
                    );

                this.parent.fieldDescription[id] = this.getItemValue
                    (
                        this.parent.fieldDescription,
                        id,
                        record,
                        "Description"
                    );

                this.parent.fieldIllustration[id] = this.getItemValue
                    (
                        this.parent.fieldIllustration,
                        id,
                        record,
                        "Illustration"
                    );

                this.parent.fieldType[id] = this.getItemValue
                    (
                        this.parent.fieldType,
                        id,
                        record,
                        "Kind"
                    );

                this.parent.fieldContentType[id] = this.getItemValue
                    (
                        this.parent.fieldContentType,
                        id,
                        record,
                        "Type"
                    );

                this.parent.fieldFormat[id] = this.getItemValue
                    (
                        this.parent.fieldFormat,
                        id,
                        record,
                        "Format"
                    );

                this.parent.fieldGroup[id] = this.getItemValue
                    (
                        this.parent.fieldGroup,
                        id,
                        record,
                        "GroupID"
                    );

                this.parent.fieldSubGroup[id] = this.getItemValue
                    (
                        this.parent.fieldSubGroup,
                        id,
                        record,
                        "SubGroupID"
                    );

                this.parent.fieldUnitID[id] = this.getItemValue
                    (
                        this.parent.fieldUnitID,
                        id,
                        record,
                        "UnitID"
                    );

                this.parent.fieldUnitID[id] = this.getItemValue
                    (
                        this.parent.fieldUnitID,
                        id,
                        record,
                        "UnitID"
                    );

                if (!this.parent.fieldCurrentContent.hasOwnProperty(id) || record.field.(@name=="CurrentValue").toString() != "")
                {
                    s = record.field.(@name=="CurrentValue").toString();

                    switch(this.parent.fieldContentType[id])
                    {
                        case(this.parent.helperKeyWords["NUMBER"]):
                            this.parent.fieldCurrentContent[id] = this.toNumber(s);
                            break;

                        case(this.parent.helperKeyWords["BOOLEAN"]):
                            this.parent.fieldCurrentContent[id] = this.toBoolean(s);
                            break;

                        case(this.parent.helperKeyWords["DATE"]):
                            this.parent.fieldCurrentContent[id] = this.toDate(s);
                            break;

                        case(this.parent.helperKeyWords["LIST"]):
                            s = s.replace(/\r/gi, "");
                            s = s.replace(/\n/gi, "");
                            s = s.replace(/\t/gi, "");

                            this.parent.fieldCurrentContent[id] = s;
                            break;

                        default:
                            this.parent.fieldCurrentContent[id] = s;
                    }

                    this.parent.helperProjectVars[id] = this.parent.fieldCurrentContent[id];
                }
            }

            return code;
        }

        public function getRepositoryDescription():Number
        {
            var record:XML = new XML();
            var id:String = new String("");
            var s:String = new String("");
            var path:String = new String("");
            var n:Number = new Number(0);
            var counter:Number = new Number(-1);
            var code:Number = new Number(0);
            var myTmpBool:Boolean = new Boolean(false);

            // Repository
            s = "";
            path = this.parent.helperURI + this.parent.helperPathURI;
            n = 0;

            for each (record in this.parent.contentXML.table.(@name=="KnowledgeRepository").record)
            {
                n++;
                s = s + "<repositoryItem id='r" + String(n) + "'>";

                // image
                id = record.field.(@name=="image").toString();

                if (id !="")
                {
                    id = path + this.parent.helperKeyWords["mainImagePath"] + id;
                    s = s + "<image>";
                    s = s + id;
                    s = s + "</image>";
                }
                else
                {
                    s = s + "<image/>";
                }

                // Description
                id = record.field.(@name=="description").toString();

                if (id !="")
                {
                    s = s + "<description>";
                    s = s + id;
                    s = s + "</description>";
                }
                else
                {
                    s = s + "<description/>";
                }

                // location
                id = record.field.(@name=="location").toString();

                if (id !="")
                {
                    id = path + id;
                    s = s + "<location>";
                    s = s + id;
                    s = s + "</location>";
                }
                else
                {
                    s = s + "<location/>";
                }

                s = s + "</repositoryItem>";
            }

            this.parent.repositoryXMLList = new XMLList(s);

            return code;
        }

        public function getGroupsDescription():Number
        {
            var record:XML = new XML();
            var id:String = new String("");
            var s:String = new String("");
            var path:String = new String("");
            var n:Number = new Number(0);
            var counter:Number = new Number(-1);
            var code:Number = new Number(0);
            var elemCount:Number = new Number(0);
            var myTmpBool:Boolean = new Boolean(false);

            // Loading Groups and SubGroups

            for each (record in this.parent.contentXML.table.(@name=="GroupAndSubgroup").record)
            {
                id = record.@id.toString();
                n = Number(record.field.(@name=="TypeID").toString());

                if (!isNaN(n) && id != "")
                {
                    this.parent.groupIDListOrder[elemCount] = id;
                    s = record.field.(@name=="Description").toString();

                    if (n == 1)
                        this.parent.fieldGroupName[id] = s;
                    else
                        this.parent.fieldSubGroupName[id]= s;

                    elemCount++;
                }

                this.parent.fieldFormat[id] = this.getItemValue
                    (
                        this.parent.fieldFormat,
                        id,
                        record,
                        "Format"
                    );
            }

            return code;
        }

        // ----------------------------
        //  Response Service Functions
        // ----------------------------

        protected function get_id_by_cis(cis:String):String
        {
            return this.parent.fieldIDtoCIS.hasOwnProperty(cis) ? this.parent.fieldIDtoCIS[cis] : cis;
        }

        internal function setNAV(value:String):String
        {
            return !value ? this.parent.n_a : value;
        }

        protected function getCommonItems(respond:Object):void
        {
            with (respond)
            {
                this.parent.returnedErrorCode = this.setNAV(errorCode);
                this.parent.returnedErrorDescr = this.setNAV(errorDescription);

                this.parent.cisCostValue = this.setNAV(total);
                this.parent.cisSecurityFile = this.setNAV(security);
                this.parent.helperDefaultCurrency = this.setNAV(currency);
                this.parent.helperCountryID = this.setNAV(countryID);
                this.parent.helperPriceTypeID = this.setNAV(priceTypeID);
                this.parent.helperRegionID = this.setNAV(regionID);

                //alert(this.parent.currentHelperActionID+':'+this.parent.helperRegionID, "Debug = getCommonItems");

                this.parent.helperSessionID = this.setNAV(sessionID);
                this.parent.helperUserID = this.setNAV(userID);
                this.parent.helperUserTypeID = this.setNAV(userTypeID);

                if (hasOwnProperty("documentNumber"))
                    this.parent.cisDocumentNumber = this.setNAV(documentNumber);
                if (hasOwnProperty("documentDate"))
                    this.parent.cisDocumentDate = this.setNAV(documentDate);
                if (hasOwnProperty("lineNumber"))
                    this.parent.cisDocumentPosition = this.setNAV(lineNumber);
                if (hasOwnProperty("userName"))
                    this.parent.helperUserName = this.setNAV(userName);
                if (hasOwnProperty("userEmail"))
                    this.parent.helperUserEmail = this.setNAV(userEmail);
                if (hasOwnProperty("guid"))
                    this.parent.helperGUID = this.setNAV(guid);
                if (hasOwnProperty("purchaseID"))
                    this.parent.helperPurchaseID = this.setNAV(purchaseID);
                if (hasOwnProperty("status"))
                    this.parent.helperStatus = this.setNAV(status);

                this.parent.isWithoutRestriction = this.toBoolean(withoutRestriction);
            }
        }

        protected function add_product(id:String, value:String, ob:Object):void
        {
            var group:String = new String("");

            if (id)
            {
                if (!ob.defaultProduct && id !== "" && id.substring(0, 9).toLowerCase() == "construct")
                    ob.defaultProduct = id.substring(9);

                if (!ob.current_content.hasOwnProperty(id) && this.parent.fieldIDtoCIS.hasOwnProperty(id))
                    id = this.parent.fieldIDtoCIS[id];

                if (id && ob.current_content.hasOwnProperty(id))
                {
                    if (ob.names.indexOf(id) < 0)
                    {
                        ob.names.push(id);
                        ob.values.push(value); // !value || isNaN(value) ? 0 : Number(value)
                    }

                    group = this.parent.fieldSubGroup[id];

                    if (group !== "" && ob.groups.indexOf(group) == -1)
                        ob.groups.push(group);

                    ++$products;
                }
            }
        }

        protected function getResponseProductContent(respond:XML, keys:Object, ob:Object):void
        {
            for each (var record:XML in respond[keys.products][keys.product])
            {
                this.add_product(record.@id, record.toString(), ob);
            }
        }

        protected function getResponseParametersContent(respond:XML, keys:Object, ob:Object):void
        {
            var keywords:Object = this.parent.helperKeyWords;
            var i:Number = new Number(0);
            var id:String = new String("");
            var parent:String = new String("");
            var type:String = new String("");
            var value:String = new String("");
            var group:String = new String("");

            for each (var record:XML in respond[keys.parameters][keys.parameter])
            {
                id = record.@id;
                parent = record.@parent;
                type = record.@type;
                value = record.toString();

                if (parent && parent !== "undefined" && id.indexOf(parent) > -1)
                {
                    if ([ob.content_type[this.get_id_by_cis(parent)], type].indexOf(keywords["LIST"]) > -1)
                    {
                        value = id.replace(parent, '').replace('_', '');
                        id = parent;
                    }
                } 	

                if (!ob.current_content.hasOwnProperty(id))
                    id = this.get_id_by_cis(id);

                if (!id) continue;

                if (!(ob.current_content.hasOwnProperty(id) || parent))
                {
                    //
                    // Item is not found.
                    // Try to migrate it to another type, e.g. BOOLEAN -> LIST
                    //
                    if (type == keywords["BOOLEAN"] && id.indexOf('_') > 0)
                    {
                        var words:Array = id.split('_');
                        if (words.length > 2)
                        {
                            id = this.get_id_by_cis(id.replace(words[0]+'_', 'cp_').replace('_'+words[-1], ''));
                            if (ob.content_type.hasOwnProperty(id) && ob.content_type[id] == keywords["LIST"])
                                value = words[-1];
                        }
                    }
                }

                if (ob.current_content.hasOwnProperty(id))
                {
                    if (ob.names.indexOf(id) == -1)
                    {
                        ob.names.push(id);
                        ob.values.push(value);
                    }

                    group = this.parent.fieldSubGroup[id];

                    if (group !== "" && ob.groups.indexOf(group) == -1)
                        ob.groups.push(group);

                    ++$parameters;
                }
            }
        }

        protected function getResponseErrorsContent(respond:XML, keys:Object, ob:Object):void
        {
            var code:String = new String("");
            var priority:String = new String("");
            var value:String = new String("");
        
            for each (var record:XML in respond[keys.errors][keys.error])
            {
                value = record.toString();

                if (!value || value.search('id: construct') > -1)
                    continue;
                
                code = record.@code;
                priority = record.@priority;

                if (code || priority)
                    ob.errors.push("[" + code + ":" + priority + "] " + value);
                else
                    ob.errors.push(value);
            }
        }

        // =========================
        //  RESPONSE CONTENT PARSER
        // =========================

        public function getQueryResultContent():Number
        {
            var container:Object = this.parent.helperProjectVars;
            var keywords:Object = this.parent.helperKeyWords;
            var respond:XML = this.parent.respondXML;

            var code:Number = new Number(0);
            var version:Number = new Number(0);
            var isOk:Boolean = new Boolean(false);

            var group:String = new String("");
            var id:String = new String("");
            var type:String = new String("");
            var value:String = new String("");

            var ob:Object = {'names':[], 'values':[], 'groups':[], 'errors':[], 'defaultProduct':String, current_content:Object, content_type:Object};

            var s:String = new String("");
            var i:Number = new Number(0);

            ob.current_content = this.parent.fieldCurrentContent;
            ob.content_type = this.parent.fieldContentType;

            var keys:Object = {'products':'products', 'product':'product', 'parameters':'parameters', 'parameter':'parameter', 'errors':'errors', 'error':'error'};

            try
            {
                s = strip(this.parent.RequestService.respondContent);
                respond = new XML(s);

                if (!s || respond.elements('*').length() < 25)
                {
                    code = -36;
                }
                else
                {
                    isOk = (respond.system.@id == "CIS");
                    isOk = ((isOk)&&(respond.task.@id == "CALCHELPER"));
                    isOk = ((isOk)&&(Number(respond.task.@version) <= Number(this.parent.helperLoadedVersion)));
                    isOk = ((isOk)&&(respond.description.@id == "ExchangeContent"));
                
                    s = respond.description.@version;
                    version = !s || parseInt(s) <= 0 || ['undefined', 'nan', 'null'].indexOf(s.toLowerCase()) > -1 ? 1 : Number(s);

                    code = isOk ? 0 : -18;
                }

                if (isOk)
                {
                    this.parent.returnedErrorCode = this.setNAV(respond.errorCode);
                    s = strip(respond.errorCode);

                    code = Number(s);

                    if (isNaN(code))
                        code = 0;

                    isOk = respond.toString() ? true : false;

                    if ([-99, -199].indexOf(code) > -1)
                    {
                        // System is unavailable
                        isOk = false;
                    }
                    else if ([-100, -101].indexOf(code) > -1)
                    {
                        // Request is invalid
                        isOk = false;
                        code = 0;
                    }
                    else if (code == -37)
                    {
                        // Constructor message
                        this.parent.addErrorMessage(respond.errorDescription);
                    }
                    else if (code)
                    {
                        // WebService Error (1C)
                        code = -20;
                        this.parent.addErrorMessage(respond.errorDescription);
                        isOk = false;
                    }

                    if (isOk)
                    {
                        // Common information
                        this.getCommonItems(respond);

                        $products = 0;
                        $parameters = 0;

                        switch (version)
                        {
                            case 2:
                                keys.products = 'options';
                                keys.product = 'option';

                                for each (var record:XML in respond.products.product)
                                {
                                    id = record.@id;
                                    value = record.@value;

                                    this.add_product(id, value, ob);

                                    s = record.@default;
                                    if (s)
                                        ob['defaultProduct'] = id;

                                    // Make list of parameters (item changes)
                                    this.getResponseParametersContent(record, keys, ob);
                                    // Make list of products
                                    this.getResponseProductContent(record, keys, ob);
                                }

                                break;
                            default:
                                // Make list of parameters (item changes)
                                this.getResponseParametersContent(respond, keys, ob);
                                // Make list of products
                                this.getResponseProductContent(respond, keys, ob);
                        }

                        // Make list of errors
                        this.getResponseErrorsContent(respond, keys, ob);

                        // Check whether content is valid
                        if (this.parent.isStatusValid() && !(ob.names.length > 0 && ob.names.length == ob.values.length && ob.defaultProduct && $parameters > 0))
                        {
                            isOk = false;
                            code = -10;
                        }
                    }
                    else if (!code)
                    {
                        // Incorrect Response
                        code = -19;
                    }
                    
                    if (isOk)
                    {

                        // --------------------------
                        // Clean content items before
                        // --------------------------

                        for (i=0; i < this.parent.allVariableNames.length; i++)
                        {
                            id = this.parent.allVariableNames[i];

                            if (!id) continue;
                            
                            group = this.parent.fieldSubGroup[id];
                            type = this.parent.fieldType[id];

                            if (ob.groups.indexOf(group) > -1 || type != keywords["RADIOBUTTON"])
                            {
                                switch (ob.content_type[id])
                                {
                                    case(keywords["NUMBER"]):
                                        if (ob.names.indexOf(id) > -1)
                                        {
                                            ob.current_content[id] = 0;
                                            container[id] = ob.current_content[id];
                                        }
                                        break;

                                    case(keywords["BOOLEAN"]):
                                        ob.current_content[id] = false;
                                        container[id] = ob.current_content[id];
                                }
                            }
                        }

                        // -------------------
                        // Set new items value
                        // -------------------

                        for (i=0; i < ob.names.length; i++)
                        {
                            id = ob.names[i];
                            value = ob.values[i];

                            switch (ob.content_type[id])
                            {
                                case(keywords["NUMBER"]):
                                    ob.current_content[id] = this.toNumber(value);
                                    break;

                                case(keywords["BOOLEAN"]):
                                    ob.current_content[id] = this.toBoolean(value);
                                    break;

                                case(keywords["DATE"]):
                                    ob.current_content[id] = this.toDate(value);
                                    break;

                                case(keywords["LIST"]):
                                    this.parent.DisplayingService.setListSelectedItemValue(id, value);
                                    break;

                                default:
                                    ob.current_content[id] = value;
                            }

                            container[id] = ob.current_content[id];
                        }

                        container["cisSecurityFile"] = this.parent.cisSecurityFile;
                        container["cisVersion"] = keywords["CIS"];
                        container["countryID"] = this.parent.helperCountryID;
                        container["currencyName"] = this.parent.helperDefaultCurrency;
                        container["currentLocale"] = this.parent.helperLocalization;
                        container["defaultProduct"] = ob.defaultProduct;
                        container["documentDate"] = this.parent.cisDocumentDate;
                        container["documentNumber"] = this.parent.cisDocumentNumber;
                        container["documentPosition"] = this.parent.cisDocumentPosition;
                        container["helperWizardID"] = this.parent.helperWizardID;
                        container["helperURI"] = this.parent.helperURI;
                        container["helperHostName"] = this.parent.helperHostName;
                        container["helperHttpHost"] = this.parent.helperHttpHost;
                        container["helperHttpReferer"] = this.parent.helperHttpReferer;
                        container["helperPageLocation"] = this.parent.helperPageLocation;
                        container["helperPathURI"] = this.parent.helperPathURI;
                        container["helperStyleID"] = this.parent.helperStyleID;
                        container["priceTypeID"] = this.parent.helperPriceTypeID;
                        container["purchaseID"] = this.parent.helperPurchaseID;
                        container["regionID"] = this.parent.helperRegionID;
                        container["returnedErrorCode"] = this.parent.returnedErrorCode;
                        container["returnedErrorDescr"] = this.parent.returnedErrorDescr;
                        container["userID"] = this.parent.helperUserID;
                        container["userTypeID"] = this.parent.helperUserTypeID;
                        container["withoutRestriction"] = this.parent.isWithoutRestriction;
                        container["wizardName"] = this.parent.helperDefaultName;
                    }

                    if (ob.errors.length && !code)
                    {
                        // Errors recieved form responser
                        for each (var error:String in ob.errors)
                        {
                            this.parent.addErrorMessage(error);
                        }
                        code = -22;
                    }

                    if (this.parent.isDeepDebugMode && code)
                        alert(this.parent.currentHelperActionID+':'+isOk.toString()+':'+code.toString(), "Debug = getQueryResultContent");
                }
                else
                {
                    this.parent.addErrorMessage(respond.errorDescription + 
                        (code == -18 ? ("<br>region:[" + 
                            (this.parent.isTransferMode ? respond.purchaseID : respond.regionID) + "]") : "")
                    );
                }
            }
            catch(errorNum:Error)
            {
                this.parent.addErrorMessage(errorNum.message);
                code = -17;
            }

            if (!isNaN(Number(this.parent.cisCostValue)))
            {
                if (Number(this.parent.cisCostValue) == 0)
                {
                    this.parent.addErrorMessage(this.parent.msgArray[12]);
                }
            }

            return code;
        }

        // ======
        //  MAIN
        // ======

        public function calculate():Number
        {
            var container:Object = this.parent.helperProjectVars;
            var code:Number = new Number(0);

            if (this.parent.helperCalculatingVersion >= parseInt(this.parent.helperLoadedVersion))
            {
                try
                {
                    // --------------------
                    // Initialize it before
                    // --------------------

                    this.parent.initState();

                    if (container["calculatingDisabled"] != -1)
                        this.parent.setCalculatingEnabled();

                    container["isAutoChanged"] = false;
                    if (!container["isConfirmation"]) container["confirmCode"] = -1;

                    container["helperErrorCode"] = 0;
                    container["helperErrorMessage"] = "";
                    container["helperFocusOn"] = '';
                    container["attentionMessage"] = "";
                    container["confirmMessage"] = "";
                    container["NoticeMessage"] = "";
                    container["setImageURI"] = "";
                    container["self"] = container;

                    // ----------------------------
                    // EXECUTE HELPER SCRIPT (EVAL)
                    // ----------------------------

                    this.codeExecuteRetVal = D.eval(this.myCommonScripts, container, this.myLibrary);

                    this.parent.addErrorMessage(container["helperErrorMessage"]);
                }
                catch(errorNum:Error)    /*    Runing error occured    */
                {
                    code = this.parent.ErrorService.fatalErrID();
                    this.parent.addErrorMessage(errorNum.message);
                }
            }
            else
            {    
                code = -2;  /* Incorect service version */
            }

            return code;
        }

        public function upload():void
        {
            var container:Object = this.parent.helperProjectVars;
            var code:Number = new Number(0);
            var i:Number = new Number(0);
            var counter:Number = this.parent.allVariableNames.length;
            var id:String = new String("");

            // --------------
            // Check an error
            // --------------

            code = container["helperErrorCode"];

            if (!code)
            {
                this.parent.setImageURI = container["setImageURI"];
                this.parent.isCallingFunction = container["setCallingFunction"];

                this.parent.helperDefaultConstruct = container["defaultConstruct"];
                this.parent.helperDefaultConstructCount = container["defaultConstructCount"];
                this.parent.helperListOfOptions = container["options"];
                /*
                this.parent.mainFormPaddingLeft = container["formPaddingLeft"];

                // Change main form properties
                if (this.parent.appObjectList['inputArea'].getStyle("paddingLeft") != this.parent.mainFormPaddingLeft)
                    this.parent.appObjectList['inputArea'].setStyle("paddingLeft", this.parent.mainFormPaddingLeft);
                */
                if (this.parent.helperLoadedVersion != container["helperLoadedVersion"] && container["helperLoadedVersion"])
                    this.parent.helperLoadedVersion = container["helperLoadedVersion"];

                if (this.parent.helperVersion != container["helperVersion"] && container["helperVersion"])
                    this.parent.helperVersion = container["helperVersion"];
            }

            // ----------------
            // Get item changes
            // ----------------

            for (i=0; i < counter; i++)
            {
                id = this.parent.allVariableNames[i];

                if (!code)
                {
                    // -------------------------
                    // Submit a new form's state
                    // -------------------------
                    this.parent.fieldCurrentContent[id] = container[id];
                    this.parent.fieldCurrStatus[id] = this.parent.fieldStatus[id];
                }
                else
                {
                    // --------------------------------
                    // Or if it's an error, rollback it
                    // --------------------------------
                    container[id] = this.parent.fieldCurrentContent[id];
                    this.parent.fieldStatus[id] = this.parent.fieldCurrStatus[id];
                }
            }

            // Set value of variable isWorkWithoutDB
            this.parent.isWorkWithout1C = container["isWorkWithout1C"];
            // Set item's field style
            this.parent.isItemStyle = container["isItemStyle"];
        }
    }
}

