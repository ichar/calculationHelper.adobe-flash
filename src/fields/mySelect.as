package fields
{
    // Created:      01.04.2013
    // Created by:   I.E.Kharlamov

    // ----------------------
    // SELECT (MULTIPLE LIST)
    // ----------------------

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.core.ClassFactory;
    import mx.collections.ArrayCollection;
    import mx.controls.List;

    import renderers.listItemRenderer;

    public class mySelect extends myAbstract
    {
        public function mySelect(parentObjRef:Object):void
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

        protected function update(content:String):void
        {
            var a:Object = this.parent.get_list_values(content);

            with (this.field)
            {
                dataProvider = new ArrayCollection(a.output);
                selectedIndices = a.selected_indices;
            }

            this.parent.set_item_style(null, this.field, this.id);
        }

        public function create(id:String, container:Object, content:Object, style:String="Select"):List
        {
            //  Формат данных (структура атрибутов поля, SELECT:Format):
            //      {M:W:H}
            //  где:
            //      <M> - field multiple selection
            //      <W> - field width
            //      <H> - field height

            var field:List = new List();
            var format:Array = this.root.fieldFormat.hasOwnProperty(id) ? this.root.fieldFormat[id].split(":") : [];

            this.initState(id, container, field, format);

            for (var i:int=0; i < 3; i++)
            {
                if (format.length < i + 1)
                    format.push(0);
                else
                    format[i] = Number(format[i]);
            }

            this.update(content[id]);

            with (field)
            {
                allowMultipleSelection = format[0] ? true : false;

                if (format[1] > 0) width = format[1];
                if (format[2] > 0) height = format[2];
            }

            this.parent.set_style(field, style);

            field.addEventListener(Event.CHANGE, this.onClicked);

            container[id].field.addChild(field);

            return field;
        }

        public function change():void
        {
            if (this.root.fieldCalculatedContent[this.id] != this.root.helperProjectVars[this.id])
                this.update(this.root.helperProjectVars[this.id]);
        }

        public function setValue():Boolean
        {
            var retVal:Boolean = new Boolean(true);
            var listValue:Array = new Array();
            var value:String = new String();

            value = String(this.root.helperProjectVars[this.id]);

            if (!value || value === "undefined" || value === "null")
            {
                value = "";
            }
            else
            {
                listValue = value.split(this.keywords["listIndexDelimeter"]);

                value = this.parent.set_list_selected_indices(this.field.selectedIndices)
                    + this.keywords["listIndexDelimeter"] 
                    + listValue[1];
            }
            
            this.root.helperProjectVars[this.id] = value;

            return retVal;
        }
    }
}
