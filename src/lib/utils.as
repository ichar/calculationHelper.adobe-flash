////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

import mx.controls.Alert;

protected function strip(s:String):String
{
    return s ? s.replace(/^\s+|\s+$/g, '') : ""; // trim leading/trailing spaces
}

protected function startswith(value:String, key:String):Boolean
{
    return value && value.indexOf(key) == 0 && value.substr(0, key.length) == key ? true : false;
}

protected function endswith(value:String, key:String):Boolean
{
    return value.indexOf(key) > 0 && value.substr(-key.length) == key ? true : false;
}

protected function capitalized(value:String):String
{
    return value ? (value.substr(0, 1).toUpperCase() + value.substr(1)) : "";
}

protected function uncapitalized(value:String):String
{
    return value ? (value.substr(0, 1).toLowerCase() + value.substr(1)) : "";
}

protected function alert(message:String, title:String="", button_width:Number=120, handler:Function=null):void
{
    with (Alert)
    {
        buttonWidth = button_width;
        show(message, title+'...', OK, null, handler);
    }
}
