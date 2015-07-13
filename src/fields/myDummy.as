package fields
{
    // Created:      31.03.2013
    // Created by:   I.E.Kharlamov

    // -------------------
    // DUMMY (EMPTY IMAGE)
    // -------------------

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.controls.Image;

    public class myDummy extends myAbstract
    {
        public function myDummy(parentObjRef:Object):void
        {
            super(parentObjRef);
        }

        public function onClicked(evntObj:MouseEvent):void {}

        protected function update(content:String):void {}

        public function create(id:String, container:Object, content:Object, style:String="Dummy"):Image
        {
            var field:Image = new Image();

            this.initState(id, container, field);

            field.visible = false;

            container[id].field.addChild(field);

            return field;
        }

        public function change():void {}

        public function setValue():Boolean
        {
            return true;
        }
    }
}
