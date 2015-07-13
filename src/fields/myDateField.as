package fields
{
    // Created:      02.04.2013
    // Created by:   I.E.Kharlamov

    // ------------------
    // INPUT FIELD (DATE)
    // ------------------

    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.FocusEvent;

    import mx.controls.DateField;

    public class myDateField extends myAbstract
    {
        public function myDateField(parentObjRef:Object):void
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

        protected function update(content:String):void
        {
            this.field.text = content;
        }

        public function create(id:String, container:Object, content:Object, style:String="DateFieldArea"):DateField
        {
            var field:DateField = new DateField();

            this.initState(id, container, field);

            field.selectedDate = content[id];
            field.formatString = this.root.myDateFormat;

            this.parent.set_style(field, style);

            field.addEventListener(FocusEvent.FOCUS_OUT, onChanged);

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

            if (this.root.helperProjectVars[this.id].selectedDate != this.field.selectedDate)
            {
                this.root.helperProjectVars[this.id].selectedDate = this.field.selectedDate;
                retVal = true;
            }

            return retVal;
        }
    }
}
