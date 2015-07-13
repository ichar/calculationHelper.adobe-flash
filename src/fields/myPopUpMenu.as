package fields
{
    // Created:      12.09.2014
    // Created by:   I.E.Kharlamov

    // -----------
    // POP-UP MENU
    // -----------

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.core.ClassFactory;
    import mx.collections.ArrayCollection;
    import mx.controls.Menu;
    import mx.controls.PopUpButton;
    import mx.events.MenuEvent;

    import renderers.listItemRenderer;

    public class myPopUpMenu extends myAbstract
    {
        public var menu:Menu;
    
        public function myPopUpMenu(parentObjRef:Object):void
        {
            super(parentObjRef);
        }

        public function onClicked(evntObj:Event):void
        {
            if (this.setValue())
            {
                this.parent.run(this.id);
            }
        }

        protected function update(content:String):String
        {
            var a:Object = this.parent.get_list_values(content);

            with (this.menu)
            {
                dataProvider = a.output;
                selectedIndex = a.selected_index;
            }

            return a.output[a.selected_index].label;
        }

        public function create(id:String, container:Object, content:Object, style:String="MenuElements"):Object
        {
            this.menu = new Menu();

            var label:String = this.update(content[id]);
            this.parent.set_style(this.menu, style);

            var field:PopUpButton = new PopUpButton();

            this.initState(id, container, field);
            this.parent.set_style(field, "PopUpMenu");

            field.popUp = this.menu;
            field.label = this.menu.dataProvider[this.menu.selectedIndex].label;

            menu.addEventListener(MenuEvent.ITEM_CLICK, this.onClicked);

            container[id].menu = this.menu;

            if (container[id].title)
                container[id].title.setStyle("paddingTop", 5);

            container[id].field.addChild(field);

            return field;
        }

        public function change():void
        {
            if (this.root.fieldCalculatedContent[this.id] != this.root.helperProjectVars[this.id])
                field.label = this.update(this.root.helperProjectVars[this.id]);
        }

        public function setValue():Boolean
        {
            var retVal:Boolean = new Boolean(true);
            var listValue:Array = new Array();
            var value:String = new String();

            value = String(this.root.helperProjectVars[this.id]);

            if (!value || value === "undefined" || value === "NaN" || value === "null")
            {
                value = "";
                field.label = "";
            }
            else
            {
                listValue = value.split(this.keywords["listIndexDelimeter"]);

                value = String(this.menu.selectedIndex) 
                    + this.keywords["listIndexDelimeter"] 
                    + listValue[1];

                this.root.formObjectList[id].menu.selectedIndex = this.menu.selectedIndex; // XXX ?
                this.field.label = this.menu.dataProvider[this.menu.selectedIndex].label;
            }

            this.root.helperProjectVars[id] = value;

            return retVal;
        }
    }
}
