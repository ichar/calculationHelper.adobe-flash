package fields
{
    // Created:      22.04.2013
    // Created by:   I.E.Kharlamov

    // ----------------------
    // DISPLAY STRING (LABEL)
    // ----------------------

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.controls.Text;

    public class myDisplayString extends myAbstract
    {
        public function myDisplayString(parentObjRef:Object):void
        {
            super(parentObjRef);
        }

        public function onClicked(evntObj:MouseEvent):void {}

        protected function update(content:String):void
        {
            this.field.text = content;
        }

        public function create(id:String, container:Object, content:Object, style:String="DisplayString"):Text
        {
            var field:Text = new Text();

            this.initState(id, container, field);

            field.selectable = false;
            field.htmlText = content[id];

            this.parent.set_style(field, style);
            this.parent.set_item_style(null, field, id);
            /*
            if (container[id].title)
                container[id].title.setStyle("paddingTop", 0);
            */
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
            return true;
        }
    }
}
