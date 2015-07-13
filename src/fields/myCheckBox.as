package fields
{
    // Created:      02.04.2013
    // Created by:   I.E.Kharlamov

    // --------
    // CHECKBOX
    // --------

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.controls.CheckBox;

    public class myCheckBox extends myAbstract
    {
        public function myCheckBox(parentObjRef:Object):void
        {
            super(parentObjRef);
        }

        public function onClicked(evntObj:MouseEvent):void
        {
            var target:Object = evntObj.currentTarget;
            var id:String = target.hasOwnProperty('id') && target.id ? target.id : this.id;

            if (id.substring(0, 5) == 'icon$')
            {
                id = id.split('$')[1];
            }

            if (this.setValue())
            {
                this.parent.run(id);
            }
        }

        protected function update(content:Object):void
        {
            this.field.selected = content ? true : false;
        }

        public function create(id:String, container:Object, content:Object, style:String="CheckBox"):CheckBox
        {
            var f:Object = this.root.fieldIcon;
            var label:String = f[id] && !f[id].label ? "" : (this.root.fieldTitle.hasOwnProperty(id) ? this.root.fieldTitle[id] : "");
            var field:CheckBox = new CheckBox();

            this.initState(id, container, field);

            field.label = label;
            field.selected = content[id];

            this.parent.set_style(field, style);

            if (IsDebug)
            {
                field.setStyle("borderStyle", "solid");
            }

            field.addEventListener(MouseEvent.CLICK, this.onClicked);
            if (container[id].icon && f[id].icon)
            {
                container[id].icon.addEventListener(MouseEvent.CLICK, this.onClicked);
            }

            if (container[id].title)
                container[id].title.setStyle("paddingTop", 2);

            container[id].field.addChild(field);

            return field;
        }

        public function change():void 
        {
            if (this.field.selected !== this.root.fieldCurrentContent[id])
                this.update(this.root.fieldCurrentContent[id]);
        }

        public function setValue():Boolean
        {
            var retVal:Boolean = new Boolean(true);

            if (this.root.helperProjectVars[this.id] == this.field.selected)
            {
                this.field.selected = !this.field.selected;
            }

            this.root.helperProjectVars[this.id] = this.field.selected;

            return retVal;
        }

        public override function setStatusStyle(status:Number):void
        {
            // ---------------------------------------------------------------
            // Check status (color black or gray) for CHECKBOX and RADIOBUTTON
            // ---------------------------------------------------------------

            this.parent.set_style(this.field, status == 2 ? "DisabledCheckBoxColor" : "CheckBox");
        }
    }
}
