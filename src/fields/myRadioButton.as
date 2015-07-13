package fields
{
    // Created:      16.05.2013
    // Created by:   I.E.Kharlamov

    // -----------
    // RADIOBUTTON
    // -----------

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.controls.RadioButton;

    public class myRadioButton extends myAbstract
    {
        public function myRadioButton(parentObjRef:Object):void
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

        public function create(id:String, container:Object, content:Object, style:String="RadioButton"):RadioButton
        {
            var f:Object = this.root.fieldIcon;
            var label:String = f[id] && !f[id].label ? "" : (this.root.fieldTitle.hasOwnProperty(id) ? this.root.fieldTitle[id] : "");
            var field:RadioButton = new RadioButton();

            this.initState(id, container, field);

            field.id = this.id;
            field.groupName = this.subgroup;
            field.label = label;
            field.selected = content[id];

            this.parent.set_style(field, style);

            field.addEventListener(MouseEvent.CLICK, this.onClicked);
            if (container[id].icon && f[id].icon) container[id].icon.addEventListener(MouseEvent.CLICK, this.onClicked);

            if (container[id].title)
                container[id].title.setStyle("paddingTop", 2);

            container[id].field.addChild(field);

            return field;
        }

        public function change():void 
        {
            if (this.field.selected !== this.root.fieldCurrentContent[this.id])
                this.update(this.root.fieldCurrentContent[this.id]);
        }

        public function setValue():Boolean
        {
            var retVal:Boolean = new Boolean(false);

            for each (var oid:String in this.root.formObjectListIds)
            {
                if (this.root.fieldSubGroup[oid] == this.subgroup)
                {
                    if (this.root.fieldType[oid] == this.keywords["RADIOBUTTON"])
                    {
                        var item:Object = this.root.formObjectList[oid].object;
                        item.selected = oid == this.id ? true : false;
                        this.root.helperProjectVars[oid] = item.selected;
                        retVal = true;
                    }
                }
            }

            return retVal;
        }

        public override function setObjectEnabled(enabled:Boolean):void
        {
            var isHList:Boolean = this.id && this.startswith(this.id, 'hlist$') ? true : false;
            var alpha:Number = enabled ? 1 : 0.2;

            this.field.enabled = enabled;
            this.container.item.enabled = enabled;
            this.container.item.alpha = alpha;
        }

        public override function setStatusStyle(status:Number):void
        {
            // ---------------------------------------------------------------
            // Check status (color black or gray) for CHECKBOX and RADIOBUTTON
            // ---------------------------------------------------------------

            this.parent.set_style(this.field, status == 2 ? "DisabledRadioButtonColor" : "RadioButton");
        }
    }
}
