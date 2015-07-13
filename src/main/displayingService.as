package main
{
    // Created:      14.05.2015
    // Created by:   I.E.Kharlamov

    import flash.display.*;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.utils.*;

    import mx.core.ClassFactory;
    import mx.collections.ArrayCollection;
    import mx.containers.FormHeading;
    import mx.containers.FormItem;
    import mx.containers.GridRow;
    import mx.containers.GridItem;
    import mx.containers.HBox;
    import mx.containers.VBox;
    import mx.controls.Image;
    import mx.controls.Label;
    import mx.controls.Text;
    import mx.controls.Spacer;
    
    import mx.events.FlexEvent;
    import mx.formatters.NumberFormatter;

    import fields.myAlert;
    import fields.myBroadImage;
    import fields.myCheckBox;
    import fields.myComboBox;
    import fields.myDateField;
    import fields.myDisplayString;
    import fields.myDummy;
    import fields.myHorizontalList;
    import fields.myImage;
    import fields.myNumberField;
    import fields.myPopUpMenu;
    import fields.myRadioButton;
    import fields.mySelect;
    import fields.myStringField;
    import fields.myTextArea;

    import tools.myRowsContainer;

    public class displayingService
    {
        public   var lastChangedInputField:String = new String("");
        public   var parent:Object;

        internal var currLdedMClip:MovieClip = new MovieClip();
        internal var currIllustrClip:MovieClip = new MovieClip();

        private  var formContainer:Object;
        private  var rowsContainer:Object;

        internal var groups:Object = new Object();
        internal var obs:Object = new Object();

        public   var selected_item:String = new String("");

        private  var ITEM_SPLITTER:String = new String(":");
        private  var INPUTAREA_MAXCHARS:Number = 145;
        private  var IMAGE_LOADING_TIMEOUT:Number = 200;

        private  var total_loaded_images:Number = 0;
        private  var total_images:Number = new Number(0);
        private  var image_items:Array = new Array();
        private  var uid:uint = 0;
        private  var isFirstTransaction:Boolean = false;

        public   var IsDebug:int = 0;

        /* -------------------------- */
           include "../lib/utils.as";
        /* -------------------------- */

        public function displayingService(parentObjRef:Object)
        {
            this.parent = parentObjRef;
            this.isFirstTransaction = true;
        }

        public function initState():Number
        {
            var retCode:Number = new Number(0);

            if (this.isFirstTransaction)
            {
                //this.parent.appObjectList['helperTitle'].htmlText = this.parent.helperDefaultName;

                this.parent.appObjectList['repositoryList'].dataProvider = this.parent.repositoryXMLList;
                this.parent.appObjectList['repositoryList'].columns[1].headerText = this.parent.msgArray[7];

                //this.parent.LogService.setNewLogRecord(true, 0, this.parent.helperProjectVars["NoticeMessage"]);
            }

            this.formContainer = this.parent.appObjectList['inputArea'];

            this.groups.$ids = new Array();
            this.obs.$ids = new Array();

            //this.parent.appObjectList["defaultImage"].addEventListener(flash.events.Event.COMPLETE, this.onImageLoadedEvent);
            this.parent.setAllVisible();

            return retCode;
        }

        public function getListSelectedItemValue(id:String):Object
        {
            //
            //  Returns list-object selected item value (Object).
            //
            //  Arguments:
            //
            //      id -- content item name.
            //
            var a:Object = this.get_list_values(this.parent.helperProjectVars[id]);
            return a.output[a.selected_index];
        }

        public function setListSelectedItemValue(id:String, value:String):void
        {
            //
            //  Sets list-object selected item value.
            //
            //  Arguments:
            //
            //      id -- content variable name (List-item name)
            //
            //      value -- selected item id.
            //
            var keywords:Object = this.parent.helperKeyWords;

            if (!(id && value && this.parent.helperProjectVars.hasOwnProperty(id)))
                return;

            var selected_index:Number = new Number(0);
            var content:String = this.parent.helperProjectVars[id];
            var a:Object = this.get_list_values(content);
            var x:String = new String("");

            for (var i:int=0; i < a.output.length; i++)
            {
                x = a.output[i].id;
                // For compound keys with colon delimeter ':'
                if (x.indexOf(this.ITEM_SPLITTER) > -1) x = x.split(this.ITEM_SPLITTER)[1];

                if (value == x || value == a.output[i].label)
                {
                    selected_index = i;
                    break;
                }
            }

            this.parent.fieldCurrentContent[id] = 
                selected_index.toString() + keywords["listIndexDelimeter"] + content.split(keywords["listIndexDelimeter"])[1];
        }

        public function setCalculatorValue():void
        {
            var form:Object = this.parent.appObjectList['mxmlApplication'];
            var id:String = this.lastChangedInputField;
            var ob:Object = this.obs[id];

            if (!isNaN(form.calculatorValue))
            {
                form.calculatorValue = this.validate_numeric_content
                    (
                        this.parent.fieldCurrentContent[id], 
                        form.calculatorValue, 
                        ob.format
                    );

                ob.field.text = Number(form.calculatorValue);

                if (ob.setValue())
                {
                    this.run(id);
                }
            }
        }

        public function setIllustration(id:String, uri:String):void
        {
            var location:String = new String();

            location = this.parent.helperURI + this.parent.helperPathURI;

            if (!uri)
            {
                with (this.parent.appObjectList["illustrationImage"])
                {
                    visible = false;
                    height = 0;
                }
            }
            else
            {
                location = location + uri;

                if (location !== this.parent.currentIllustration)
                {
                    with (this.parent.appObjectList["illustrationImage"])
                    {
                        addEventListener(flash.events.Event.COMPLETE, this.onIllustrationLoadedEvent);
                        visible = true;
                        height = 120;

                        load(location);
                    }
                }
            }

            this.parent.currentIllustration = location;
            this.parent.setHelpMessage(this.parent.replaceQuotedValues(this.parent.fieldDescription[id]));
        }

        public function loadImageByUri(uri:String, icon:Image):void
        {
            var loader:Loader = new Loader();
            var location:String = this.parent.helperURI + this.parent.helperPathURI + uri;
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void{icon.source = e.currentTarget.content;});
            loader.load(new URLRequest(location));
        }

        public function changeGroupState(id:String, state:Object=null):void
        {
            if (this.groups.$ids.indexOf(id) > -1)
                this.groups[id].changeState(state);
        }

        public function getContainerOfItem(id:String):Object
        {
            var container:Object = parent.formObjectList;
            for each (var ob:Object in container)
            {
                if (ob.ids.id == id)
                    return ob;
            }
            return null;
        }

        // ------------------------------
        //  CONTROL HANDLERS (protected)
        // ------------------------------

        public function run(id:String):void
        {
            this.parent.fieldCalculatedContent[id] = this.parent.helperProjectVars[id];
            this.parent.helperProjectVars["changedFormFieldID"] = id;
            this.parent.costMessage = "";

            this.parent.calculate();
        }

        public function get_list_selected_indices(selected_indices:String):Array
        {
            var output:Array = selected_indices.split(this.parent.helperKeyWords["listIndicesDelimeter"]);
            for (var i:int=0; i < output.length; i++)
                output[i] = Number(output[i]);
            output.sort(Array.NUMERIC);
            return output;
        }

        public function set_list_selected_indices(selected_indices:Array):String
        {
            var output:Array = new Array();
            selected_indices.sort(Array.NUMERIC);
            for (var i:int=0; i < selected_indices.length; i++)
                output.push(selected_indices[i].toString());
            return output.join(this.parent.helperKeyWords["listIndicesDelimeter"]);
        }

        public function get_list_values(myContent:String):Object
        {
            var keywords:Object = this.parent.helperKeyWords;
            var items:Array = new Array();
            var selected_index:Number = new Number(0);
            var selected_indices:Array = new Array();
            var output:Array = new Array();
            var data:Array = new Array();
            var a:Array = new Array();
            var value:String = new String(myContent);
            var x:String = new String("");
            var i:int;

            if (!value || value === "undefined" || value === "NaN" || value === "null")
            {
                value = "0";
                value += keywords["listIndexDelimeter"];
                value += keywords["listItemDelimeter"];
                value += keywords["listValueDelimeter"];
            }

            a = value.split(keywords["listIndexDelimeter"]);
            selected_index = !a[0] || isNaN(a[0]) || parseInt(a[0]) < 0 ? 0 : Number(a[0]);
            selected_indices = this.get_list_selected_indices(a[0]);

            items = a.length > 0 ? a[1].split(keywords["listValueDelimeter"]) : [''];

            for(i=0; i < items.length; i++)
            {
                a = items[i].split(keywords["listItemDelimeter"]);
                if (a.length <= 0)
                    continue;

                x = strip(a[0]);
                // For compound keys with colon delimeter ':'
                if (x.indexOf(this.ITEM_SPLITTER) > -1) x = x.split(this.ITEM_SPLITTER)[1];

                output.push({
                    'id'    : x, 
                    'label' : strip(a[1]), 
                    'data'  : (a.length > 2 ? strip(a[2]) : '')
                });

                data.push(strip(a[a.length - 1]));
            }

            if (selected_index > items.length-1 || selected_index < 0)
                selected_index = 0;

            return {output:output, selected_index:selected_index, selected_indices:selected_indices, 'data':data}
        }

        public function set_format(ob:Object, format:Array):void
        {
            var s:String = new String("");
            var partSizeLst:Array = new Array();
            var intPart:Number = new Number();
            var fractPart:Number = new Number();

            if (format.length > 1) {
                s = format[0];

                if (s.length > 0)
                    ob.restrict = s;

                s = format[1];
                partSizeLst = s.split(this.parent.helperKeyWords["Pointer"]);

                if (partSizeLst.length > 1) {
                    intPart = Number(partSizeLst[0]);
                    fractPart = Number(partSizeLst[1]);

                    if (!(isNaN(intPart)) && !(isNaN(fractPart))) {
                        if (fractPart > 0) {
                            intPart = intPart + fractPart;
                            if (fractPart) ++intPart;
                        }

                        ob.maxChars = intPart;
                        ob.width = 
                            (intPart == 1 ? 15 : 
                            (intPart <= 2 ? 25 : 
                            (intPart <= 4 ? 40 : 
                            (intPart <= 5 ? 50 : intPart*10)))) + 10;
                        //ob.setStyle("paddingTop", 2);
                        if (intPart < 2) 
                            ob.setStyle("textAlign", "center");
                    }
                }
            }
        }

        public function set_style_value(ob:Object, value:Array):void
        {
            if (value.length < 2)
                return;

            switch(value[0])
            {
                case 'width':
                    if (!isNaN(value[1]))
                        ob.width = Number(value[1]);
                    break;

                case 'height':
                    if (!isNaN(value[1]))
                        ob.height = Number(value[1]);
                    break;

                case 'paddingTop':
                case 'paddingBottom':
                case 'paddingLeft':
                case 'paddingRight':
                    ob.setStyle(value[0], Number(value[1]));
                    break;

                default:
                    ob.setStyle(value[0], value[1]);
            }
        }

        public function set_style(ob:Object, styleName:String):void
        {
            var styleContent:String = new String();
            var value:Array = new Array();

            if (styleName.length > 0)
            {
                styleContent = this.parent.labelsStyleList[styleName];
                if (styleContent && styleContent.length > 0)
                {
                    for each (var style:String in styleContent.split(this.parent.helperKeyWords["styleStrDivider"]))
                    {
                        value = strip(style).split(this.parent.helperKeyWords["styleParamDiv"]);
                        this.set_style_value(ob, value);
                    }
                }
            }
        }

        public function set_item_style(box:Object, ob:Object, id:String):void
        {
            if (!(this.parent.fieldStyle.hasOwnProperty(id) && this.parent.fieldStyle[id]))
                return;

            for each (var style:String in this.parent.fieldStyle[id].split(this.parent.helperKeyWords["styleStrDivider"])) {
                var x:Array = style.split(this.parent.helperKeyWords["styleParamDiv"]);

                if (!x || x.length < 2)
                    continue;

                var value:Array = new Array();
                var item:Object = null;

                if (x.length == 3)
                {
                    value.push(x[1]);
                    value.push(x[2]);

                    item = x[0].toLowerCase() == 'box' && box ? box : (ob ? ob : null);
                }
                else
                {
                    value.push(x[0]);
                    value.push(x[1]);

                    item = box ? box : (ob ? ob : null);
                }

                if (item)
                    this.set_style_value(item, value);
            }
        }

        public function validate_numeric_content(oldValue:Number, currValue:Number, fieldFormat:String):Number
        {
            var formatLst:Array = new Array();
            var partSizeLst:Array = new Array();
            var retValue:Number = new Number();
            var intPart:Number = new Number();
            var fractPart:Number = new Number();
            var maxPart:Number = new Number();
            var tmpStr:String = new String();

            var myFormater:NumberFormatter = new NumberFormatter();

            retValue = currValue;

            with (myFormater)
            {
                thousandsSeparatorTo = "";
                thousandsSeparatorFrom = "";
                decimalSeparatorTo = this.parent.helperKeyWords["Pointer"];
                decimalSeparatorFrom = this.parent.helperKeyWords["Pointer"];
                rounding = "nearest";
            }

            if (fieldFormat !== "")
            {
                formatLst = fieldFormat.split(this.parent.helperKeyWords["formatParamDiv"]);

                if (formatLst.length > 1)
                {
                    tmpStr = formatLst[1];
                    partSizeLst = tmpStr.split(this.parent.helperKeyWords["Pointer"]);

                    if (partSizeLst.length > 1)
                    {
                        intPart = Number(partSizeLst[0]);
                        fractPart = Number(partSizeLst[1]);

                        if (!(isNaN(intPart)) && !(isNaN(fractPart)))
                        {
                            maxPart = intPart + fractPart + 1;
                            tmpStr = String(currValue);

                            tmpStr = String(currValue);
                            partSizeLst = tmpStr.split(this.parent.helperKeyWords["Pointer"]);
                            tmpStr = partSizeLst[0];

                            if (intPart < tmpStr.length)
                            {
                                retValue = oldValue;
                            }
                            else
                            {
                                myFormater.precision = fractPart;
                                tmpStr = String(currValue);
                                retValue = Number(myFormater.format(tmpStr));
                            }
                        }
                    }
                }
            }

            return retValue;
        }

        // ----------------
        //  EVENT HANDLERS
        // ----------------

        private function onImageLoadedEvent(e:Event):void
        {
            this.currLdedMClip = this.parent.appObjectList["defaultImage"].content as MovieClip;
            with (e.currentTarget)
            {
                height = contentHeight;
                parent.explicitHeight = height + 12;
            }
            if (this.total_images == 1)
                this.parent.appObjectList["imageBox"].setStyle("borderStyle", "solid");
            checkImageLoading(e);
        }

        private function onIllustrationLoadedEvent(e:Event):void
        {
            this.currIllustrClip = this.parent.appObjectList["illustrationImage"].content as MovieClip;
        }

        private function onRepositoryChangedEvent(evntObj:MouseEvent):void
        {
            if (evntObj.currentTarget.selectedItem != null)
            {
                var url:URLRequest = new URLRequest(evntObj.currentTarget.selectedItem.location);
                flash.net.navigateToURL(url, "_blank");
            }
        }

        private function onGroupClickEvent(evntObj:MouseEvent):void
        {
            var target:Object = evntObj.currentTarget;
            var id:String = target.hasOwnProperty('id') && target.id ? target.id : "";

            if (id && id.indexOf('$') > -1)
                id = id.split('$')[1];

            //if (this.groups.$ids.indexOf(id) > -1)
            //    this.groups[id].changeState();
            this.changeGroupState(id);

            // ----------------------
            // Validate toolbar state
            // ----------------------

            this.parent.appObjectList['toolbar'].validateState();
        }

        // ---------------------------
        //  FORM'S ITEMS CONSTRUCTION
        // ---------------------------

        private function createGroupItem(id:String, label:String, styleName:String, groupNumber:Number):Object
        {
            var myGroup:GridRow = new GridRow();
            var myItem:GridItem = new GridItem();
            var myBox:HBox = new HBox();
            var myLabel:Label = new Label();
            var has_not_label:Boolean = this.parent.fieldFormat[id] == 'HIDDEN' ? true : false;

            myLabel.text = label;

            myBox.addChild(myLabel);
            myItem.addChild(myBox);
            myGroup.addChild(myItem);

            var gid:String = 'group$' + id;

            myGroup.id = gid;
            myGroup.width = this.parent.globalAttrs.input_area_max_width;

            var iid:String = 'item$' + id;

            myItem.id = iid;
            myItem.styleName = "rowItem";

            with (myItem)
            {
                colSpan = 2;

                width = this.parent.globalAttrs.group_item_max_width;
                horizontalScrollPolicy = "off";
                useHandCursor = true;
                buttonMode = true; 
                mouseChildren = false;

                addEventListener(MouseEvent.CLICK, this.onGroupClickEvent);
            }

            myBox.styleName = "rowBox";

            with (myBox)
            {
                width = this.parent.globalAttrs.group_item_max_width;
                verticalScrollPolicy = "off";
            }

            this.set_style(myLabel, styleName);
            //this.set_item_style(myBox, myLabel, id);

            if (has_not_label)
            {
                myGroup.visible = false;
                myGroup.height = 0;

                if (!groupNumber)
                    this.formContainer.setStyle("paddingTop", 10);

                this.parent.appObjectList['toolbar'].disableGroupOptions();
            }

            this.formContainer.addChild(myGroup);

            if (this.IsDebug)
            {
                myGroup.setStyle("borderStyle", "solid");
            }

            this.groups[id] = new myRowsContainer(this, id, myGroup);
            this.groups.$ids.push(id);

            this.rowsContainer = this.groups[id];

            return {'group':myGroup, 'item':myItem, 'label':myLabel};
        }

        private function createBoxItem(id:String):Object
        {
            var myGroup:GridRow = new GridRow();
            var myItem:GridItem = new GridItem();
            var myBox:VBox = new VBox();

            var gid:String = 'row$' + id;

            myGroup.id = gid;
            myGroup.styleName = "rowImage";
            myGroup.width = this.parent.globalAttrs.input_area_max_width;

            myItem.addChild(myBox);
            myGroup.addChild(myItem);

            with (myItem)
            {
                colSpan = 2;
            }

            with (myBox)
            {
                width = this.parent.globalAttrs.group_item_max_width;
            }

            if (this.IsDebug)
            {
                myGroup.setStyle("borderStyle", "solid");
            }

            // --------------------------
            // Set item's container style
            // --------------------------
            if (this.parent.isItemStyle)
                this.set_item_style(myBox, null, id);

            this.formContainer.addChild(myGroup);
            this.rowsContainer.addRow(gid, id, myGroup);

            return {'group':myGroup, 'item':myItem, 'box':myBox};
        }

        private function createFormItem(id:String, label:String, styleName:String):Object
        {
            var myGroup:GridRow = new GridRow();
            var myTitle:GridItem = new GridItem();
            var myItem:GridItem = new GridItem();
            var myLabel:Label = new Label();
            var f:Object = this.parent.fieldIcon[id];
            var has_icon:Boolean = this.parent.fieldIcon.hasOwnProperty(id) ? true : false;
            var has_label:Boolean = !has_icon || (f.label == 1 && label) ? true : false;

            var gid:String = 'row$' + id;

            myGroup.id = gid;
            myGroup.styleName = "rowForm";
            myGroup.width = this.parent.globalAttrs.input_area_max_width;
            
            myTitle.styleName = "rowTitle";

            if (has_label)
            {
                myLabel.text = label;

                myTitle.addChild(myLabel);
                myGroup.addChild(myTitle);
                myGroup.addChild(myItem);
            }
            else
            {
                myItem.colSpan = 2;
                myGroup.addChild(myItem);
            }

            myItem.styleName = "rowField";

            with (myItem)
            {
                direction = "horizontal";
            }

            if (has_icon)
            {
                if (f.icon && f.uri)
                {
                    if (f.left)
                        myItem.setStyle("paddingLeft", f.left);
                }
            }

            this.set_style(myGroup, styleName);

            // --------------------------
            // Set item's container style
            // --------------------------
            if (this.parent.isItemStyle)
                this.set_item_style(myItem, null, id);

            if (this.IsDebug)
            {
                myTitle.setStyle("borderStyle", "solid");
                myItem.setStyle("borderStyle", "solid");
            }

            this.formContainer.addChild(myGroup);
            this.rowsContainer.addRow(gid, id, myGroup, label);

            return {'group':myGroup, 'title':myTitle, 'item':myItem};
        }

        private function createIconItem(id:String, label:String, item:Object):Object
        {
            var iconBox:HBox = new HBox();
            var icon:Image = new Image();
            var fieldBox:HBox = new HBox();
            var has_icon:Boolean = this.parent.fieldIcon.hasOwnProperty(id) ? true : false;

            if (has_icon)
            {
                var f:Object = this.parent.fieldIcon[id];

                if (f.icon && f.uri)
                {
                    icon.id = 'icon$' + id;
                    icon.smoothBitmapContent = true;

                    if (f.width)
                        icon.width = f.width;
                    if (f.height)
                        icon.height = f.height;

                    this.loadImageByUri(f.uri, icon);

                    if (f.zoom)
                    {
                        with (icon)
                        {
                            scaleX = 1
                            scaleY = 1

                            addEventListener(MouseEvent.ROLL_OVER, this.parent.appObjectList.doZoom);
                            addEventListener(MouseEvent.ROLL_OUT, this.parent.appObjectList.doZoom);
                            addEventListener(FlexEvent.CREATION_COMPLETE, this.parent.appObjectList.smoothImage);
                        }
                    }

                    iconBox.addChild(icon);
                    iconBox.addChild(fieldBox);

                    if (f.label == 2)
                    {
                        var info:Text = new Text();
                        info.htmlText = label;

                        if (f.right_label_padding_top)
                        {
                            info.setStyle("paddingTop", f.right_label_padding_top);
                        }

                        fieldBox.addChild(info);
                    }

                    if (f.top)
                        fieldBox.setStyle("paddingTop", f.top);

                    if (item) item.addChild(iconBox);

                    return {'icon':icon, 'field':fieldBox};
                }
            }

            return {'icon':null, 'field':null};
        }

        // ------------------------
        //  IMAGE SLICE CONTROLLER
        // ------------------------

        protected function checkImage(uri:String):Boolean
        {
            if (!uri || uri == '*')
                return false;
            else
                return true;
        }

        protected function checkImageLoading(e:Event):void
        {
            --total_loaded_images;
        }

        protected function loadImage(container:Object, uri:String, index:Number=0, top:Number=0):Object
        {
            var n:Number = container.numChildren;
            var request:URLRequest = new URLRequest(uri);
            var loader:Loader = new Loader();

            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
                {
                    if (top && container.height < top + e.currentTarget.height) 
                        container.height = top + e.currentTarget.height;
                    container.parent.height = container.height;
                    checkImageLoading(e);
                }
            );
            loader.load(request);

            ++this.total_loaded_images;

            if (index > 0)
            {
                container.removeChildAt(index);
                container.addChildAt(loader, index);
                n = index;
            }
            else
            {
                container.addChild(loader);
                n = container.numChildren - 1;
            }

            return container.getChildAt(n);
        }
    
        private function goImageLoading():void
        {
            if (!this.image_items || this.image_items.length == 0)
            {
                clearInterval(this.uid);
                return;
            }

            var i:Number = this.image_items.shift();

            if (!this.checkImage(this.parent.imagePath[i]))
                return;

            var container:Object = this.parent.appObjectList["defaultImage"];
            var image:Object = null;
            var IsVisible:Boolean = this.parent.imageVisibility[i];
            var IsReload:Boolean = false;
            var index:Number = i + 1;
            var uri:String = this.parent.helperURI + this.parent.helperPathURI + this.parent.imagePath[i];
            var top:Number = this.parent.imageY[i];

            if (IsVisible)
            {
                if (this.parent.imageCurrPath.length < this.parent.imagePath.length)
                {
                    //
                    // Create a new image layer
                    //
                    image = this.loadImage(container, uri, 0, top);
                    this.parent.imageCurrPath.push(this.parent.imagePath[i]);
                }
                else if (this.parent.imageCurrPath[i] != this.parent.imagePath[i])
                {
                    //
                    // If we have image URI changed, reload it
                    //
                    image = this.loadImage(container, uri, index, top);
                    this.parent.imageCurrPath[i] = this.parent.imagePath[i];

                    IsReload = true;
                }
            }
            if (!image && container.numChildren > index)
            {
                image = container.getChildAt(index);
            }
            //
            // Set positions and visibility
            //
            if (image)
            {
                if (IsReload || image.x != this.parent.imageX[i])
                {
                    image.x = this.parent.imageX[i];
                }
                if (IsReload || image.y != this.parent.imageY[i])
                {
                    image.y = this.parent.imageY[i];
                }
                if (image.visible != IsVisible)
                {
                    image.visible = IsVisible ? true : false;
                }
            }
        }

        private function displayAndOverlayImages():void
        {
            var container:Object = this.parent.appObjectList["defaultImage"];
            var image:Object = new Object();
            var imageCounter:Number = new Number(0);
            var containerChildLength:Number = new Number(0);
            var uri:String = new String('');
            var i:Number = new Number(0);
            var max_height:Number = new Number(0);

            var IsContainerChanged:Boolean = new Boolean();
            var IsBackgroundChanged:Boolean = new Boolean();

            this.total_images = 1;

            // Check container's length (background and optional image layers)
            imageCounter = this.parent.imagePath.length + this.total_images;
            containerChildLength = container.numChildren;

            // Background image URI changed
            IsBackgroundChanged = this.parent.displayedImageURI != this.parent.setImageURI ? true : false;

            // Images count changed
            IsContainerChanged = IsBackgroundChanged || imageCounter != containerChildLength ? true : false;

            // Are there any counter changes?
            if (IsContainerChanged)
            {
                this.total_loaded_images = 0;
                //
                // Yes, create a new image container
                //
                if (containerChildLength > 0)
                {
                    // Remove all image layers
                    if (IsBackgroundChanged || containerChildLength > this.total_images)
                    {
                        for (i=1; i <= this.parent.imageCurrPath.length; i++)
                        {
                            container.removeChildAt(containerChildLength - i);
                        }
                    }

                    this.parent.imageCurrPath.length = 0;

                    // Clear background image
                    if (IsBackgroundChanged && container.numChildren > 0)
                    {
                        if (container.numChildren > 0)
                            container.removeChildAt(0);
                        with (container.parent)
                        {
                            height = explicitHeight = 0;
                        }
                        this.parent.displayedImageURI = '';
                    }
                }
            }
            //
            // Create or change image layers if they are presented
            //
            if (this.parent.imagePath.length)
            {
                this.image_items = new Array();
                this.uid = 0;

                for (i=0; i < this.parent.imagePath.length; i++)
                {
                    this.image_items.push(i);
                    if (this.parent.imageVisibility[i])
                        ++this.total_images;
                }
            }
            //
            // Create a new background image
            //
            if (this.total_images > 1 || IsBackgroundChanged)
                container.parent.setStyle("borderStyle", "none");
            
            if (IsBackgroundChanged)
            {
                uri = this.parent.helperURI + this.parent.helperPathURI + this.parent.setImageURI;
                this.total_loaded_images = this.total_images;

                with (container)
                {
                    height = this.parent.globalAttrs.image_area_default_height;
                    addEventListener(flash.events.Event.COMPLETE, this.onImageLoadedEvent);

                    load(uri);
                }

                this.parent.displayedImageURI = this.parent.setImageURI;
            }

            if (this.parent.imagePath.length)
            {
                this.uid = setInterval(this.goImageLoading, this.IMAGE_LOADING_TIMEOUT);
            }
        }

        // ======
        //  MAIN
        // ======

        private function IsItemCalculated(id:String):Boolean
        {
            return (
                this.parent.fieldContentType[id] != this.parent.helperKeyWords["Alert"] && 
                this.parent.fieldContentType[id] != this.parent.helperKeyWords["broadImage"] ?
                true : false
            );
        }

        private function IsItemDisabled(id:String):Boolean
        {
            return this.parent.fieldFormat[id] == 'DISABLED' ? true : false;
        }

        private function IsBoxItem(id:String):Boolean
        {
            return this.parent.fieldFormat[id] == this.parent.helperKeyWords["HLISTBOX"] ? true : false;
        }

        public function display():Number
        {
            var parent:Object = this.parent;
            var keywords:Object = parent.helperKeyWords;
            var container:Object = parent.formObjectList;
            var content:Object = parent.fieldCurrentContent;

            var code:Number = new Number(0);
            var total_items:Number = new Number(parent.formObjectListIds.length);
            var groupNumber:Number = new Number(0);
            var i:int;

            var ob:Object = new Object();
            var id:String = new String("");
            var label:String = new String("");
            var unit_id:String = new String("");
            var unit_name:String = new String("");
            var group_id:String = new String("");
            var subgroup_id:String = new String("");

            var currGroupID:String = new String("");
            var currSubGroupID:String = new String("");

            var isBooleanObjects:Boolean = new Boolean(false);
            var isNewGroup:Boolean = new Boolean(false);
            var isNewSubGroup:Boolean = new Boolean(false);

            var groupContainer:Object = new Object();
            var itemContainer:Object = new Object();
            var iconContainer:Object = new Object();
            var titleContainer:Object = new Object();
            var fieldContainer:Object = new Object();

            var fieldObject:Object = new Object();
            var buttonObject:Object = new Object();

            var gridRowContainer:Object;

            var f:Object = parent.fieldIcon;

            //this.parent.helperProjectVars["changedFormFieldID"] = "";

            try
            {
                //--------------------------------//
                /*    BEGIN DISPLAYING MODULE     */
                //--------------------------------//

                if (this.isFirstTransaction)
                {
                    this.isFirstTransaction = false;
                    gridRowContainer = null;

                    for (i=0; i < total_items; i++)
                    {
                        id = parent.formObjectListIds[i];

                        if (!(id && parent.helperProjectVars.hasOwnProperty(id)))
                            continue;

                        unit_id = parent.fieldUnitID[id];
                        unit_name = unit_id && parent.unitsNameList.hasOwnProperty(unit_id) ? 
                            " (" + parent.unitsNameList[unit_id] + ")" : "";

                        group_id = parent.fieldGroup[id];
                        subgroup_id = parent.fieldSubGroup[id];

                        container[id] = {
                            // ids list
                            'ids':null, 
                            // containers list
                            'group':null, 'item':null, 'icon':null, 'title':null, 'field':null, 
                            // objects list
                            'object':null, 'menu':null, 'button':null
                        };

                        iconContainer = titleContainer = null; // fieldContainer = 
                        isNewGroup = false;

                        // ---------------------
                        // A new group of fields
                        // ---------------------

                        if (currGroupID != group_id)
                        {
                            label = group_id && parent.fieldGroupName.hasOwnProperty(group_id) ?
                                parent.fieldGroupName[group_id] : "";

                            if (this.IsItemCalculated(id) && !this.IsItemDisabled(group_id))
                            {
                                ob = this.createGroupItem(group_id, label, "PartTitle", groupNumber);
                                groupContainer = ob['group'];
                                ++groupNumber;

                                isNewGroup = true;

                                if (label && groupContainer)
                                {
                                    parent.quickRefGroupObject.push({
                                        'group_id':group_id, 
                                        'id':id, 
                                        'label':label, 
                                        'ref':this.rowsContainer, 
                                        'position':0
                                    });
                                }

                                if (gridRowContainer)
                                {
                                    gridRowContainer.styleName = gridRowContainer.styleName == "firstRowInGroup" ? "aloneRowInGroup" : "lastRowInGroup";
                                }

                                currGroupID = group_id;
                            }
                            else
                            {
                                currGroupID = "";
                            }
                        }

                        // -----------------
                        // Label of the item
                        // -----------------

                        isBooleanObjects = parent.fieldType[id] == keywords["RADIOBUTTON"];

                        if (this.parent.helperModelVersion < '1.15')
                        {
                            isBooleanObjects = isBooleanObjects || parent.fieldType[id] == keywords["CHECKBOX"];

                            isNewSubGroup = isBooleanObjects 
                                || parent.fieldType[id] == keywords["popupMENU"]
                                || parent.fieldType[id] == keywords["SELECT"]
                                || parent.fieldType[id] == keywords["COMBOBOX"]
                                || parent.fieldType[id] == keywords["inputFIELD"];
                        }
                        else
                        {
                            isNewSubGroup = isBooleanObjects;
                        }

                        if (isBooleanObjects)
                            label = subgroup_id && currSubGroupID != subgroup_id && parent.fieldSubGroupName.hasOwnProperty(subgroup_id) ?
                                parent.fieldSubGroupName[subgroup_id] : "";
                        else
                            label = parent.fieldTitle.hasOwnProperty(id) ? parent.fieldTitle[id] : "";

                        if (unit_name)
                            label = label + unit_name;

                        // --------------------------------
                        // A new subgroup of fields or item
                        // --------------------------------

                        if (!subgroup_id || currSubGroupID != subgroup_id || isNewSubGroup)
                        {
                            if (!this.IsItemCalculated(id))
                            {
                                ob = this.createBoxItem(id);
                                groupContainer = fieldContainer = ob['box'];
                                itemContainer = null;
                            }
                            else if (this.IsBoxItem(id))
                            {
                                ob = this.createBoxItem(id);
                                fieldContainer = ob['box'];
                                itemContainer = null;
                            }
                            else
                            {
                                ob = this.createFormItem(id, label, "FieldsContainer");
                                gridRowContainer = ob['group'];
                                fieldContainer = itemContainer = ob['item'];
                                titleContainer = ob['title'];

                                if (isNewGroup)
                                {
                                    gridRowContainer.styleName = "firstRowInGroup";
                                }
                            }

                            currSubGroupID = subgroup_id;
                        }
                        else
                        {
                            this.rowsContainer.addSearchContext(id, label);
                        }

                        // --------------------------------
                        // Check and create a new item icon
                        // --------------------------------

                        ob = this.createIconItem(id, label, itemContainer);

                        iconContainer = ob['icon'];
                        if (ob['title']) titleContainer = ob['title'];
                        if (ob['field']) fieldContainer = ob['field'];

                        // ------------------------------
                        // Register a new field container
                        // ------------------------------

                        with (container[id])
                        {
                            ids = {
                                'id':id, 
                                'group':currGroupID, 
                                'subgroup':currSubGroupID
                            };

                            group = groupContainer;

                            if (itemContainer) item = itemContainer;
                            if (iconContainer) icon = iconContainer;

                            title = titleContainer;
                            field = fieldContainer;
                        }

                        // --------------------------------------------
                        // Parse field's type and create new item field
                        // --------------------------------------------

                        fieldObject = null;
                        buttonObject = null;

                        switch (parent.fieldType[id])
                        {
                            case(keywords["HLISTBOX"]):
                            case(keywords["HLIST"]):
                                ob = new myHorizontalList(this);
                                break;

                            case(keywords["SELECT"]):
                                ob = new mySelect(this);
                                break;

                            case(keywords["COMBOBOX"]):
                                ob = new myComboBox(this);
                                break;

                            case(keywords["popupMENU"]):
                                ob = new myPopUpMenu(this);
                                break;

                            case(keywords["CHECKBOX"]):
                                ob = new myCheckBox(this);
                                break;

                            case(keywords["RADIOBUTTON"]):
                                ob = new myRadioButton(this);
                                break;

                            case(keywords["inputAREA"]):
                                ob = new myTextArea(this);
                                break;

                            case(keywords["DUMMY"]):
                                ob = new myDummy(this);
                                break;

                            case(keywords["displayFIELD"]):
                                if (parent.fieldContentType[id] == keywords["IMAGE"])
                                {
                                    ob = new myImage(this);
                                }
                                else if (parent.fieldContentType[id] == keywords["broadImage"])
                                {
                                    ob = new myBroadImage(this);
                                }
                                else if (parent.fieldContentType[id] == keywords["Alert"])
                                {
                                    ob = new myAlert(this);
                                }
                                else
                                {
                                    ob = new myDisplayString(this);
                                }
                                break;

                            default:
                                if (parent.fieldContentType[id] == keywords["NUMBER"])
                                {
                                    ob = new myNumberField(this);
                                }
                                else if (parent.fieldContentType[id] == keywords["DATE"])
                                {
                                    ob = new myDateField(this);
                                }
                                else
                                {
                                    ob = new myStringField(this);
                                }
                        }

                        if (!ob) continue;

                        fieldObject = ob.create(id, container, content);

                        // ----------------------
                        // Set item's field style
                        // ----------------------
                        if (parent.isItemStyle)
                            this.set_item_style(null, fieldObject, id);

                        // ------------------
                        // Register the field
                        // ------------------

                        if (id)
                        {
                            this.obs[id] = ob;
                            this.obs.$ids.push(id);
                        }

                        with (container[id])
                        {
                            object = fieldObject;
                        }

                        with (fieldObject)
                        {
                            addEventListener(MouseEvent.ROLL_OVER, ob.onMouseRollOver);
                            addEventListener(MouseEvent.ROLL_OUT, ob.onMouseRollOut);
                            addEventListener(FocusEvent.FOCUS_IN, ob.onFocusIn);
                        }
                    }

                    // ----------------------------------
                    // Activate repository documents area
                    // ----------------------------------

                    parent.appObjectList['repositoryList'].addEventListener(MouseEvent.CLICK, this.onRepositoryChangedEvent);

                    // ------------
                    // Show toolbar
                    // ------------

                    parent.appObjectList['toolbar'].initState(this, this.groups);
                }
                else
                {
                    // ------------------------------------------------
                    // Objects has been displayed before. Apply changes
                    // ------------------------------------------------

                    for each (id in this.obs.$ids)
                    {
                        ob = this.obs[id];

                        if (!parent.helperProjectVars.hasOwnProperty(id))
                            continue;

                        ob.change();

                        parent.fieldCalculatedContent[id] = parent.helperProjectVars[id];
                    }
                }

                // -----------------------
                // Check status of objects
                // -----------------------

                for each (id in this.obs.$ids)
                {
                    ob = this.obs[id];

                    if (!parent.helperProjectVars.hasOwnProperty(id))
                        continue;

                    ob.setStatus(parent.fieldStatus[id]);
                }

                // --------
                // Set COST
                // --------

                parent.setCostMessage(parent.costMessage);

                // ----------------
                // Image displaying
                // ----------------

                this.displayAndOverlayImages();

                //-----------------------------//
                /*    END DISPLAYING MODULE    */
                //-----------------------------//
            }
            catch(errorNum:Error)
            {
                code = parent.ErrorService.fatalErrID();
                parent.ErrorService.additionalErrorMessage = errorNum.message;
            }

            return code;
        }
    }
}

