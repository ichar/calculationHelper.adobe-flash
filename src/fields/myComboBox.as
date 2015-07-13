package fields
{
    // Created:      14.09.2014
    // Created by:   I.E.Kharlamov

    // --------
    // COMBOBOX
    // --------

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.core.ClassFactory;
    import mx.collections.ArrayCollection;
    import mx.controls.ComboBox;

    import renderers.listItemRenderer;

    public class myComboBox extends myAbstract
    {
        public function myComboBox(parentObjRef:Object):void
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
            //  Формат данных (структура атрибутов поля, COMBOBOX:Format):
            //      {R:W:H}
            //  где:
            //      <R> - field row count
            //      <W> - field width
            //      <H> - field height
            //      <L> - left adjustment, 1/0

            var a:Object = this.parent.get_list_values(content);
            var i:int;

            for (i=0; i < 4; i++)
            {
                if (this.format.length < i + 1)
                    this.format.push(0);
                else
                    this.format[i] = Number(this.format[i]);
            }

            if (this.format[3])
            {
                for (i=0; i < a.output.length; i++)
                {
                    a.output[i].label = '  ' + a.output[i].label;
                }

                this.field.setStyle("paddingLeft", 0);
            }

            with (this.field)
            {
                dataProvider = new ArrayCollection(a.output);
                selectedIndex = a.selected_index;

                rowCount = this.format[0] ? this.format[0] : 10;

                if (this.format[1] > 0) width = this.format[1];
                if (this.format[2] > 0) height = this.format[2];
            }
        }

        public function create(id:String, container:Object, content:Object, style:String="ComboBox"):ComboBox
        {
            var field:ComboBox = new ComboBox();
            var format:Array = this.root.fieldFormat.hasOwnProperty(id) ? this.root.fieldFormat[id].split(":") : [];

            this.initState(id, container, field, format);

            this.update(content[id]);

            field.id = 'combo$' + id;

            this.parent.set_style(field, style);

            field.addEventListener(Event.CHANGE, this.onClicked);
            
            if (container[id].title)
                container[id].title.setStyle("paddingTop", 6);

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

            if (!value || value === "undefined" || value === "NaN" || value === "null")
            {
                this.root.helperProjectVars[this.id] = "";
            }
            else
            {
                listValue = value.split(this.keywords["listIndexDelimeter"]);

                this.root.helperProjectVars[this.id] = String(this.field.selectedIndex) 
                    + this.keywords["listIndexDelimeter"] 
                    + listValue[1];
            }

            return retVal;
        }
    }
}
