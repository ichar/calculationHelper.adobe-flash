package tools
{
    import flash.events.EventDispatcher;
    import flash.events.Event;

    public class myEventDispatcher extends EventDispatcher
    {
        public static var ACTION:String = "action";

        public function doAction():void {
            dispatchEvent(new Event(myEventDispatcher.ACTION));
        }
    }
}