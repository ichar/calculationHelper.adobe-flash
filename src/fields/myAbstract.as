package fields
{
    // Created:      14.05.2015
    // Created by:   I.E.Kharlamov

    // -------------------------
    // ABSTRACT FIELD SUPERCLASS
    // -------------------------

    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.FocusEvent;

    public class myAbstract
    {
        internal var root:Object = new Object();
        internal var parent:Object = new Object();
        internal var keywords:Object = new Object();

        public   var id:String = new String("");
        public   var kind:String = new String("");
        public   var type:String = new String("");
        public   var group:String = new String("");
        public   var subgroup:String = new String("");
        
        internal var container:Object = new Object();
        
        public   var field:Object = new Object();
        public   var format:Array = new Array();

        internal var IsDebug:int = 0;

        /* -------------------------- */
           include "../lib/utils.as";
        /* -------------------------- */

        public function myAbstract(parentObjRef:Object):void
        {
            this.parent = parentObjRef;

            this.root = this.parent.parent;
            this.keywords = this.root.helperKeyWords;

            if (this.parent.IsDebug) 
                IsDebug = 1;
        }
        
        protected function initState(id:String, container:Object, field:Object, format:Array=null):void
        {
            this.id = id;
            this.kind = this.root.fieldType[id];
            this.type = this.root.fieldContentType[id];

            this.group = container[id].ids.group;
            this.subgroup = container[id].ids.subgroup;

            this.field = field;
            if (format) this.format = format;

            this.container = container[id];
        }

        public function onMouseRollOver(evntObj:MouseEvent):void
        {
            this.parent.setIllustration(this.id, this.root.fieldIllustration[this.id]);
        }

        public function onMouseRollOut(evntObj:MouseEvent):void
        {
            if (this.root.inFocusId)
                return;
            this.parent.setIllustration(this.id, '');
        }

        public function onFocusIn(evntObj:FocusEvent):void
        {
            this.root.inFocusField = this.field;
            this.root.inFocusId = this.id;
        }

        public function setObjectEnabled(enabled:Boolean):void
        {
            var isHList:Boolean = this.id && this.startswith(this.id, 'hlist$') ? true : false;
            var alpha:Number = enabled ? 1 : 0.2;

            if (this.field.enabled != enabled) this.field.enabled = enabled;

            if (!isHList) return;

            for (var i:int=0; i < this.field.numChildren; i++)
            {
                var ob:Object = this.field.getChildAt(i);
                if (ob)
                    ob.alpha = alpha;
            }
        }

        public function setStatus(status:Number):void
        {
            var visible:Boolean = status == -1 ? false : true;
            var enabled:Boolean = status > 0 ? true : false;
            var alpha:Number = status == -1 ? 0 : (status == 0 ? 0.2 : 1);

            if (this.container.item)
                this.container.item.visible = visible;

            if (this.container.icon)
            {
                this.container.icon.enabled = enabled;
                this.container.icon.alpha = alpha;
            }

            this.setObjectEnabled(enabled);

            // Calculator button, if it's an INPUT FIELD
            if (this.type === this.keywords["NUMBER"] && this.container.button)
            {
                this.container.button.enabled = enabled;
            }

            this.setStatusStyle(status);
        }

        public function setFocus():void
        {
            this.field.setFocus();
        }

        public function setStatusStyle(status:Number):void {}
    }
}
