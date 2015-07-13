package fields
{
    // Created:      01.04.2013
    // Created by:   I.E.Kharlamov

    // -----------------------------------------
    // BROAD IMAGE (ALLOCATED INSIDE INPUT AREA)
    // -----------------------------------------

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.controls.Image;

    public class myBroadImage extends myAbstract
    {
        public function myBroadImage(parentObjRef:Object):void
        {
            super(parentObjRef);
        }

        public function onClicked(evntObj:MouseEvent):void {}

        protected function update(content:String):void {}

        public function create(id:String, container:Object, content:Object, style:String="BroadImage"):Image
        {
            var field:Image = new Image();

            this.initState(id, container, field);

            this.parent.loadImageByUri(content[id], field);

            this.parent.set_item_style(null, field, id);

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
