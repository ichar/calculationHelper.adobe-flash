package fields
{
    // Created:      27.05.2013
    // Created by:   I.E.Kharlamov

    // ---------------------
    // INPUT AREA (TEXTAREA)
    // ---------------------

    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.FocusEvent;

    import mx.controls.Text;
    import mx.controls.TextArea;

    public class myTextArea extends myAbstract
    {
        private  var INPUTAREA_MAXCHARS:Number = 345;

        public function myTextArea(parentObjRef:Object):void
        {
            super(parentObjRef);
        }

        public function onChanged(evntObj:Event):void 
        {
            if (evntObj.currentTarget.text.indexOf('\r') >= 0)
            {
                var index:Number = evntObj.currentTarget.text.indexOf('\r');
                evntObj.currentTarget.text = evntObj.currentTarget.text.split('\r').join('');
                evntObj.currentTarget.setSelection(index, index);
            }

            if (evntObj.currentTarget.text.length > this.INPUTAREA_MAXCHARS)
            {
                var x:String = strip(evntObj.currentTarget.text);
                var p:Boolean = false;

                for (var i:int=x.length - 1; i > 0; --i) {
                    if (i < this.INPUTAREA_MAXCHARS && x.substr(i, 1) == " ") {
                        if (p) x += '...';
                        break;
                    }
                    x = x.substr(0, i);
                    p = true;
                }

                evntObj.currentTarget.text = x;
            }
        }

        public function onFocusOut(evntObj:FocusEvent):void
        {
            if (this.setValue())
            {
                this.parent.run(this.id);
            }
        }

        protected function update(content:String):void
        {
            this.field.text = content;
        }

        public function create(id:String, container:Object, content:Object, style:String="FieldArea"):TextArea
        {
            var field:TextArea = new TextArea();

            this.initState(id, container, field);

            field.text = content[id];
            field.maxChars = this.INPUTAREA_MAXCHARS + 5;
            field.wordWrap = true;

            this.parent.set_style(field, style);
            this.parent.set_item_style(null, field, id);

            field.addEventListener(FocusEvent.FOCUS_OUT, this.onFocusOut);
            field.addEventListener(Event.CHANGE, this.onChanged);

            container[id].field.addChild(field);

            return field;
        }

        public function change():void 
        {
            if (this.field.text != this.root.fieldCurrentContent[this.id])
                this.update(this.root.fieldCurrentContent[this.id]);
       }

        public function setValue():Boolean
        {
            var retVal:Boolean = new Boolean(false);
            var value:String = new String("");

            value = this.field.text;

            if (this.root.helperProjectVars[this.id] != value)
            {
                this.root.helperProjectVars[this.id] = value;
                retVal = true;
            }

            return retVal;
        }
    }
}
