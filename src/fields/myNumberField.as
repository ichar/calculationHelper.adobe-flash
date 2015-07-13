package fields
{
    // Created:      02.04.2013
    // Created by:   I.E.Kharlamov

    // --------------------
    // INPUT FIELD (NUMBER)
    // --------------------

    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.FocusEvent;

    import mx.controls.TextInput;
    import mx.controls.Button;

    public class myNumberField extends myAbstract
    {
        public function myNumberField(parentObjRef:Object):void
        {
            super(parentObjRef);
        }

        public function onClicked(evntObj:MouseEvent):void
        {
            var ob:Object = this.root.appObjectList['mxmlApplication'];

            with (ob)
            {
                calculatorEventObj = this.parent;
                calculatorValue = this.root.fieldCurrentContent[this.id];
                calcFormatValue = this.root.fieldFormat[this.id];
                calcPointValue = this.keywords["Pointer"];
                calcParamDivValue = this.keywords["formatParamDiv"];
                calcErrValue = this.root.errMsgArray[24];
            }

            this.parent.lastChangedInputField = this.id;
            this.root.openCalculatorWindow();
        }

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

        public function create(id:String, container:Object, content:Object, style:String="NumFieldContent"):TextInput
        {
            var field:TextInput = new TextInput();
            var format:Array = this.root.fieldFormat[id] ? this.root.fieldFormat[id].split(this.keywords["formatParamDiv"]) : [];

            this.initState(id, container, field, format);

            field.text = content[id];
            field.styleName = "textInput";

            this.parent.set_style(field, style);
            this.parent.set_format(field, format);

            field.addEventListener(FocusEvent.FOCUS_OUT, this.onChanged);

            var button:Button = new Button();

            with (button)
            {
                width = 33;
                height = 27;
                styleName = "callCalculatorButtons";
            }

            button.addEventListener(MouseEvent.CLICK, this.onClicked);

            if (container[id].title)
                container[id].title.setStyle("paddingTop", 5);

            container[id].button = button;

            container[id].field.addChild(field);
            container[id].field.addChild(button);

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
            var value:Number = new Number(0);

            value = Number(this.field.text);

            if (isNaN(value))
            {
                value = 0;
                field.text = "0";
            }

            if (this.root.helperProjectVars[this.id] != value)
            {
                this.root.helperProjectVars[this.id] = value;
                retVal = true;
            }

            return retVal;
        }
    }
}
