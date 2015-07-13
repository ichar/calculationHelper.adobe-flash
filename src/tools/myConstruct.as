package tools
{
    // Created:      14.09.2014
    // Created by:   I.E.Kharlamov

    // -------------------------------------
    // Construction Field Items Restrictions
    // -------------------------------------

    public class myConstruct
    {
        internal var root:Object = new Object();
        internal var parent:Object = new Object();
        internal var keywords:Object = new Object();

        private  var postfix:String = new String("");

        public   var id:String = new String("");
        public   var name:String = new String("");
        public   var enabled:Boolean = new Boolean(false);
        public   var value:String = new String("");
        public   var region:String = new String("");
        public   var condition:String = new String("");
        public   var dus:Array = new Array();

        private  var myDUSPattern:RegExp = /^DUS-([\-\w]+)$/i;

        internal var IsDebug:int = 0;

        /* -------------------------- */
           include "../lib/utils.as";
        /* -------------------------- */

        public function myConstruct(parentObjRef:Object, id:String):void 
        {
            this.parent = parentObjRef;

            this.root = this.parent.parent;
            this.keywords = this.root.helperKeyWords;
            this.id = id;

            var m:Array = this.root.helperDUSCODE.match(this.myDUSPattern);
            if (m && m.length == 2)
                this.postfix = m[1];
        }
        
        public function initState(record:XML):void
        {
            this.name = record.field.(@name=="Name").toString();
            this.enabled = record.field.(@name=="Enabled").toString() == "On" ? true : false;
            this.value = record.field.(@name=="Value").toString();
            this.region = record.field.(@name=="Region").toString();
            this.condition = record.field.(@name=="Condition").toString();

            var s:String = record.field.(@name=="DusCode").toString();
            if (s)
                this.dus = s.split(':');
        }

        public function active():Boolean
        {
            return (this.postfix && this.dus && this.dus.indexOf(this.postfix) > -1) || this.dus.length == 0 ? 
                true : false;
        }
    }
}
