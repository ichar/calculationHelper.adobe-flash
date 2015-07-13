package fields
{
    // Created:      01.04.2013
    // Created by:   I.E.Kharlamov

    // -----
    // IMAGE
    // -----

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.controls.Image;

    public class myImage extends myAbstract
    {
        public function myImage(parentObjRef:Object):void
        {
            super(parentObjRef);
        }

        public function onClicked(evntObj:MouseEvent):void {}

        protected function update(content:String):void {}

        public function create(id:String, container:Object, content:Object, style:String="DisplayImage"):Image
        {
            var field:Image = new Image();

            this.initState(id, container, field);

            this.parent.loadImageByUri(content[id], field); //field.load(content);

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
