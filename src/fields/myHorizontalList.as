package fields
{
    // Created:      01.04.2013
    // Created by:   I.E.Kharlamov

    // ---------------------------------
    // HORIZONTAL LIST (HLIST, HLISTBOX)
    // ---------------------------------

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.core.ClassFactory;
    import mx.collections.ArrayCollection;
    import mx.controls.HorizontalList;

    import renderers.listItemRenderer;

    public class myHorizontalList extends myAbstract
    {
        public function myHorizontalList(parentObjRef:Object):void
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
            var uri:String = this.root.helperURI + this.root.helperPathURI;
            var source:Array = new Array();

            with (this.field)
            {
                for (var i:int=0; i < a.data.length; i++) {
                    a.data[i] = uri + a.data[i];

                    var ob:listSource = new listSource();
                    ob.uri = a.data[i];
                    ob.width = columnWidth;
                    ob.height = rowHeight - (columnCount > 0 && a.data.length > columnCount ? 30 : 15);
                    source.push(ob);
                }

                dataProvider = new ArrayCollection(source);
                itemRenderer = new ClassFactory(listItemRenderer);

                selectedIndex = a.selected_index;
            }
        }

        public function create(id:String, container:Object, content:Object, style:String="HorizontalList"):HorizontalList
        {
            //  Формат данных (структура атрибутов поля, HLIST:Format):
            //      {L:W:H:C}
            //  где:
            //      <L> - container padding left
            //      <W> - field column width
            //      <H> - field row height
            //      <C> - field column count

            var field:HorizontalList = new HorizontalList();
            var format:Array = this.root.fieldFormat.hasOwnProperty(id) ? this.root.fieldFormat[id].split(":") : [];

            this.initState(id, container, field, format);

            field.id = 'hlist$' + id;
            field.setStyle("backgroundColor", this.root.globalAttrs.background_color);

            for (var i:int=0; i < 4; i++)
            {
                if (format.length < i + 1)
                    format.push(0);
                else
                    format[i] = Number(format[i]);
            }

            with (field)
            {
                columnWidth = format[1] > 0 ? format[1] : 100;
                rowHeight = format[2] > 0 ? format[2] : 110;

                if (format[3] > 0)
                    columnCount = format[3];
            }

            this.update(content[id]);
                
            with (field)
            {
                if (format[0] >= 0)
                {
                    if (format[3] > 0)
                        width = columnWidth * format[3] + 2;
                    else
                        width = this.root.globalAttrs.input_area_max_width - 26 - format[0];

                    if (format[0])
                    {
                        container[id].field.setStyle("paddingLeft", format[0] + 10);
                        container[id].field.setStyle("backgroundColor", this.root.globalAttrs.background_color);
                    }
                }
            }

            this.parent.set_item_style(null, field, id);
            this.parent.set_style(field, style);
            
            this.root.fieldCalculatedContent[id] = this.root.helperProjectVars[id] = content[id];

            field.addEventListener(MouseEvent.CLICK, this.onClicked);

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
            var value:String = new String("");

            value = String(this.root.helperProjectVars[this.id]);

            if (!value || value === "undefined" || value === "NaN" || value === "null")
            {
                this.root.helperProjectVars[this.id] = "";
            }
            else
            {
                listValue = value.split(this.keywords["listIndexDelimeter"]);

                this.root.helperProjectVars[this.id] = String(field.selectedIndex) 
                    + this.keywords["listIndexDelimeter"] 
                    + listValue[1];
            }

            return retVal;
        }
    }
}
