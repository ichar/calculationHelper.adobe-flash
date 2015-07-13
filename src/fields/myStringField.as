package fields
{
    // Created:      02.04.2013
    // Created by:   I.E.Kharlamov

    // --------------------
    // INPUT FIELD (STRING)
    // --------------------

    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.FocusEvent;

    import mx.controls.TextInput;

    public class myStringField extends myAbstract
    {
        public function myStringField(parentObjRef:Object):void
        {
            super(parentObjRef);
        }

        public function onClicked(evntObj:MouseEvent):void {}

        public function onChanged(evntObj:FocusEvent):void
        {
            if (this.setValue())
            {
                this.parent.run(this.id);
            }
        }

        protected function update(content:Object):void
        {
            this.field.text = content.toString();
        }

        public function create(id:String, container:Object, content:Object, style:String="StrFieldContent"):TextInput
        {
            var field:TextInput = new TextInput();
            var format:Array = this.root.fieldFormat[id] ? this.root.fieldFormat[id].split(this.keywords["formatParamDiv"]) : [];

            this.initState(id, container, field, format);

            field.text = content[id];

            this.parent.set_style(field, style);
            this.parent.set_format(field, format);

            field.addEventListener(FocusEvent.FOCUS_OUT, this.onChanged);

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
