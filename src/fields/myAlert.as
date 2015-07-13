package fields
{
    // Created:      02.04.2013
    // Created by:   I.E.Kharlamov

    // -----
    // ALERT
    // -----

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.controls.Text;

    public class myAlert extends myAbstract
    {
        public function myAlert(parentObjRef:Object):void
        {
            super(parentObjRef);
        }

        public function onClicked(evntObj:MouseEvent):void {}

        protected function update(content:String):void
        {
            this.field.text = content;
        }

        public function create(id:String, container:Object, content:Object, style:String="Alert"):Text
        {
            var field:Text = new Text();

            this.initState(id, container, field);

            field.htmlText = content[id];

            this.parent.set_item_style(null, field, id);

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
