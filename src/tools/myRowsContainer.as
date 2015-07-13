package tools
{
    // Created:      23.01.2014
    // Created by:   I.E.Kharlamov

    // -------------------------
    // GRID ROWS GROUP CONTAINER
    // -------------------------

    public class myRowsContainer
    {
        internal var SP:String = new String("||");
    
        internal var root:Object;
        internal var parentObject:Object;
        internal var keywords:Object;

        internal var group_padding_vertical:int = 0;
        internal var row_padding_vertical:int = 0;
        internal var selected_padding_vertical:Number = new Number(200);
        internal var selected_padding_offset:Number = new Number(30);

        public   var id:String = new String("");
        public   var state:Boolean = false;
        public   var top:Number = 0;
        public   var height:Number = 0;
        public   var default_height:Number = 0;

        private  var group:Object;
        private  var items:Object = new Object();

        internal var IsDebug:int = 0;

        /* -------------------------- */
           include "../lib/utils.as";
        /* -------------------------- */

        public function myRowsContainer(parentObjRef:Object, id:String, group:Object):void
        {
            this.parentObject = parentObjRef;

            this.root = this.parentObject.parent;
            this.keywords = this.root.helperKeyWords;

            if (this.parentObject.IsDebug) 
                IsDebug = 1;
            
            this.id = id;
            this.items.$ids = new Array();

            // ------------------------------------------------------
            // State of the group: true - expanded, false - collapsed
            // ------------------------------------------------------

            this.state = true;

            // ---------------------------------------
            // Header of the group - the first GridRow
            // ---------------------------------------

            this.group = group;

            this.setStyle();
        }

        protected function setStyle():void
        {
            this.group.styleName = this.state ? "rowGroupExpanded" : "rowGroupCollapsed";
        }

        protected function getTopOfSelectedItem(selected_item:String):Number
        {
            var top:Number = this.top + this.default_height;

            for each (var id:String in this.items.$ids)
            {
                if (id == selected_item)
                    break;
                top += this.items[id].item.height;
            }

            return top;
        }

        protected function setSelected(id:String):void
        {
            var ob:Object = this.items[id];
            var position:Number = new Number(0);

            if (!this.state)
            {
                this.changeState(true);
                this.root.appObjectList['toolbar'].validateState();
            }

            var top:Number = this.getTopOfSelectedItem(id);

            with (ob)
            {
                item.setStyle("borderColor", "red");
                selected = true;
            }

            this.parentObject.selected_item = id;

            if (top <= this.selected_padding_vertical + this.selected_padding_offset)
                position = top - this.selected_padding_offset;
            else
                position = top - this.selected_padding_vertical;

            this.root.appObjectList['inputArea'].verticalScrollPosition = position;
        }

        public function removeSelected():void
        {
            var selected_item:String = this.parentObject.selected_item;

            if (!selected_item || this.items.$ids.indexOf(selected_item) == -1)
                return;

            var ob:Object = this.items[selected_item];

            with (ob)
            {
                item.setStyle("borderColor", this.root.globalAttrs.background_color);
                selected = false;
            }

            this.parentObject.selected_item = "";
        }

        public function validateState(top:Number):Number
        {
            if (!this.default_height)
                this.default_height = this.group.height + this.group_padding_vertical;

            if (this.state)
            {
                this.height = 0;

                for each (var id:String in this.items.$ids)
                {
                    var ob:Object = this.items[id];

                    if (ob.item.height)
                        this.height += (ob.item.height + this.row_padding_vertical);
                }
            }

            if (top)
                this.top = top;

            return this.top + this.default_height + (this.state ? this.height : 0);
        }

        public function addRow(gid:String, id:String, item:Object, label:String=""):void
        {
            this.items[gid] = 
            {
                'item'     : item, 
                'context'  : new String(""),
                'height'   : item.height, 
                'visible'  : item.visible, 
                'top'      : item.y,
                'selected' : false
            };

            this.items.$ids.push(gid);

            this.addSearchContext(id, label);
        }

        public function addSearchContext(id:String, label:String=""):void
        {
            var gid:String = this.items.$ids[this.items.$ids.length - 1];
            var context:String = new String("");

            if (label)
                context += label + this.SP;

            if (this.root.fieldTitle.hasOwnProperty(id) && this.root.fieldTitle[id])
                context += this.root.fieldTitle[id] + this.SP;

            if (this.root.fieldSubGroupName.hasOwnProperty(id) && this.root.fieldSubGroupName[id])
                context += this.root.fieldSubGroupName[id] + this.SP;

            if (this.root.fieldCurrentContent.hasOwnProperty(id) && this.root.fieldCurrentContent[id])
                context += this.root.fieldCurrentContent[id].toString() + this.SP;

            if (this.root.fieldDescription.hasOwnProperty(id) && this.root.fieldDescription[id])
                context += this.root.fieldDescription[id] + this.SP;

            this.items[gid].context += context.toLowerCase();
        }

        public function changeState(force:Object=null):void
        {
            var visible:Boolean = force != null ? force : (this.state ? false : true);

            for each (var id:String in this.items.$ids)
            {
                var ob:Object = this.items[id];

                if (!ob.height && ob.item.height)
                    ob.height = ob.item.height;

                ob.item.visible = visible;
                ob.item.height = ob.item.minHeight = visible ? ob.height : 0;
                ob.item.explicitHeight = ob.item.explicitMinHeight = visible ? NaN : 0;
            }

            this.state = visible;
 
            this.setStyle();
        }

        public function searchItem(text:String, forward:Boolean=true):Boolean
        {
            var found:Boolean = new Boolean(false);
            var x:String = text.toLowerCase();
            var ids:Array = this.items.$ids.slice();

            if (!forward) ids.reverse();

            for each (var id:String in ids)
            {
                var ob:Object = this.items[id];
                var selected_item:String = this.parentObject.selected_item;

                if (selected_item)
                {
                    if (id == selected_item && ob.selected)
                    {
                        this.removeSelected();
                    }
                }
                else if (ob.context.indexOf(x) > -1)
                {
                    this.setSelected(id);
                    found = true;
                    break;
                }
            }

            return found;
        }
    }
}
