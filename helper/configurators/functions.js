﻿

function strip(s) {
    return s.replace(/^\s+|\s+$/g, ''); 
}

function get_compound_id(id) {
    var _s = ':';
    return strip(id.indexOf(_s) > -1 ? id.split(_s)[0] : id);
}

function get_compound_article(id) {
    var _s = ':';
    return id.indexOf(_s) > -1 ? id.split(_s)[1] : '';
}

function initDefaultImage()
{
    for (var _i = 0; _i < imagePath.length; _i++) {
        imagePath[_i] = '';
        imageVisibility[_i] = false;
        imageX[_i] = 0;
        imageY[_i] = 0;
    }
}

function getMarkedSubstring(value, marks) {
    var m = marks.split(' ');
    if (!value || m.length < 2)
        return '';
    var start = value.indexOf(m[0]) + 1;
    var end = value.indexOf(m[1]);
    return start > -1 && end > -1 && end > start ? value.slice(start, end) : value;
}

function IsStringStartedWith(x, s) {
    return (s && x && x.substr(0, s.length) == s) ? true : false;
}

function IsStringEndedWith(x, s) {
    return (s && x && x.substr(-s.length) == s) ? true : false;
}

function getList(outer) {
    var _n = outer ? outer.indexOf(LST_INDEX_DELIMETER) : -1;
    _n = (!_n || _n < 0) ? 0 : _n + LST_INDEX_DELIMETER.length;
    var _lst = new Array();
    if (outer)
        _lst = outer.substr(_n).split(LST_VALUE_DELIMETER);
    return _lst;
}

function getListLength(outer) {
    var _lst = getList(outer);
    if (!_lst || !_lst.length || (_lst.length == 1 && !_lst[0]))
        return 0;
    return _lst.length;
}

function getListItem(outer, index) {
    if (index < 0) return null;

    var _lst = getList(outer);
    if (!_lst || !_lst.length || index > _lst.length) return null;

    var _item = _lst[index].split(LST_ITEM_DELIMETER);
    for (var _i = 0; _i < _item.length; _i++) {
        _item[_i] = strip(_item[_i]);
    }

    return _item;
}

function getListItemById(outer, id) {
    if (!id || outer.indexOf(id) == -1) return null;

    var _lst = getList(outer);
    var _item = new Array();
    
    for (var _i = 0; _i < _lst.length; _i++) {
        _item = _lst[_i].split(LST_ITEM_DELIMETER);
        if (_item) {
            var _id = get_compound_id(_item[0]);
            if (_id == id || strip(_item[0]) == id || _item[0].split(':').indexOf(id) > -1)
                break;
        }
    }

    if (_i >= _lst.length) return null;
    
    return _item;
}

function get_id_or_name(outer, id, index) {
    var _lst = getList(outer);
    for (var _i = 0; _i < _lst.length; _i++) {
        var _item = _lst[_i].split(LST_ITEM_DELIMETER);
        if (_item) {
            var _id = get_compound_id(_item[0]);
            var _article = get_compound_article(_item[0]);
            if (_id == id || _article == id || strip(_item[0]) == id || (_item.length > 1 && strip(_item[1]) == id))
                return index < 1 ? _id : strip(_item[index]);
        }
    }
    return id;
}

function getListValidId(outer, id) {
    return get_id_or_name(outer, id, 0);
}

function getListValidName(outer, id) {
    return get_id_or_name(outer, id, 1);
}

function makeOuterList(lst, selected_index) {
    if (!selected_index || selected_index < 0 || !lst || selected_index > lst.length-1)
        selected_index = 0;
    return selected_index + LST_INDEX_DELIMETER + lst.join(LST_VALUE_DELIMETER);
}

function getListMapping(outer) {
    var _lst = getList(outer);
    if (!_lst || !_lst.length) return null;
    
    var _map = new Object();
    for (var _i = 0; _i < _lst.length; _i++) {
        if (_lst[_i]) {
            var _item = _lst[_i].split(LST_ITEM_DELIMETER);
            if (_item.length >= 2 && _item[0]) {
                var _id = strip(_item[0]);
                var _value = new Array();
                for (var _k = 1; _k < _item.length; _k++) {
                    _value.push(strip(_item[_k]));
                }
                _map[_id] = _value;
            }
        }
    }

    return _map;
}

function getListSelectedIndex(outer) {
    var _n = outer.indexOf(LST_INDEX_DELIMETER);
    return (!_n || _n < 1) ? 0 : parseInt(strip(outer.substring(0, _n)));
}

function getListSelectedIndices(outer) {
    var _n = outer.indexOf(LST_INDEX_DELIMETER);
    return strip(outer.substring(0, !_n || _n < 1 ? 0 : _n));
}

function getListSelectedId(outer) {
    return getListSelectedItem(outer, 0);
}

function setListSelectedId(outer, id) {
    return setListSelectedIndexById(outer, id);
}

function getListSelectedItem(outer, index) {
    var _item = getListItem(outer, getListSelectedIndex(outer));
    if (!_item)
        return '';
    if (index >= 0 && index < _item.length)
        return strip(_item[index]);
    return '';
}

function getListSelectedItems(outer, index, splitter) {
    var _indices = getListSelectedIndices(outer).split(LST_INDICES_DELIMETER);
    var _value = '';
    var _item;

    for (var _index=0; _index < _indices.length; _index++) {
        _item = getListItem(outer, parseInt(_indices[_index]));
        if (!_item)
            continue;
        if (index >= 0 && index < _item.length) {
            if (_value && splitter) _value += splitter;
            _value += strip(_item[index]);
        }
    }

    return _value;
}

function getListSelectedValue(outer) {
    return getListItem(outer, getListSelectedIndex(outer));
}

function setListSelectedIndex(outer, selected_index) {
    var _n = outer.indexOf(LST_INDEX_DELIMETER);
    if (_n < 0) _n = 0;
    return selected_index + LST_INDEX_DELIMETER + outer.substr(_n+LST_INDEX_DELIMETER.length);
}

function iterList(id) {
    var _outer = getSelfValue(id);
    if (!_outer)
        return false;
    var _selected_index = getListSelectedIndex(_outer);
    if (_selected_index >= getListLength(_outer) - 1)
        return false;
    else {
        _outer = setListSelectedIndex(_outer, _selected_index + 1);
        setValue(id, _outer);
        return true;
    }
}

function setListSelectedIndices(outer, selected_indices) {
    var _n = outer.indexOf(LST_INDEX_DELIMETER);
    if (_n < 0) _n = 0;
    return selected_indices.join(LST_INDICES_DELIMETER) + LST_INDEX_DELIMETER + outer.substr(_n+LST_INDEX_DELIMETER.length);
}

function setListSelectedIndexById(outer, id) {
    var _lst = getList(outer);
    if (!_lst || !_lst.length) return outer;

    for (var _i = 0; _i < _lst.length; _i++) {
        if (!_lst[_i])
            continue;
        var _item = _lst[_i].split(LST_ITEM_DELIMETER);
        if (_item) {
            var _id = get_compound_id(_item[0]);
            if (_id == id || strip(_item[0]) == id)
                break;
        }
    }

    if (_i >= _lst.length) return outer;

    return makeOuterList(_lst, _i);
}

function setListSelectedIndicesById(outer, selected_indices) {
    var _lst = getList(outer);
    if (!_lst || !_lst.length) return outer;

    var _indices = new Array();
    var _id = '';

    for (var _j = 0; _j < _lst.length; _j++) {
        id = selected_indices[_j];
        for (var _i = 0; _i < _lst.length; _i++) {
            if (!_lst[_i])
                continue;
            var _item = _lst[_i].split(LST_ITEM_DELIMETER);
            if (_item) {
                var _id = get_compound_id(_item[0]);
                if (_id == id || strip(_item[0]) == id)
                    _indices.push(_i);
            }
        }
    }

    if (!_indices) _indices.push(0);

    return setListSelectedIndices(outer, _indices);
}

function addListItem(outer, item) {
    var _lst = getList(outer);
    var _selected_index = getListSelectedIndex(outer);

    var _value = item.join(LST_ITEM_DELIMETER);
    _lst.push(_value);

    return makeOuterList(_lst, _selected_index);
}

function removeListItem(outer, index) {
    if (index < 0)
        return outer;

    var _selected_index = getListSelectedIndex(outer);
    var _lst = getList(outer);

    if (index > _lst.length - 1) return outer;

    var _new_lst = new Array();
    for (var _i = 0; _i < _lst.length; _i++) {
        if (_i == index)
            continue;
        _new_lst.push(_lst[_i]);
    }
    if (_selected_index == index)
        _selected_index = 0;

    return makeOuterList(_new_lst, _selected_index);
}

function removeListItemById(outer, id) {
    if (!id) return outer;

    var _lst = getList(outer);
    var _new_lst = new Array();
    
    for (var _r = 0; _r < _lst.length; _r++) {
        var _item = _lst[_r].split(LST_ITEM_DELIMETER);
        if (!_item || _item.length == 0)
            continue;
        if (strip(_item[0]) != id)
            _new_lst.push(_lst[_r]);
    }
    
    return makeOuterList(_new_lst, 0);
}

function blockItems(id, items, source) {
    var _selected_id = getListSelectedId(getSelfValue(id));
   
    setValue(id, source);

    blockListItems(id, items);

    return setListSelectedId(getValue(id), _selected_id);
}

function blockListItems(id, items) {
    if (!id || !items || items.length == 0)
        return;

    var _outer = getSelfValue(id);

    for (var _b = 0; _b < items.length; _b++) {
        var _item = getListItemById(_outer, items[_b]);
        if (_item && _item.length > 0) {
            _outer = removeListItemById(_outer, strip(_item[0]));
        }
    }

    setValue(id, _outer);
}

function blockListItem(id, item) {
    if (!id || !item)
        return;

    var _outer = getSelfValue(id);
    var _item = getListItemById(_outer, item);

    if (_item && _item.length > 0) {
        var _rid = strip(_item[0]);
        var _id = getListSelectedId(_outer);
        _outer = removeListItemById(_outer, _rid);
        if (_id)
            _outer = setListSelectedIndexById(_outer, _id);
        setValue(id, _outer);
    }
}

function checkConstruct(ob) {
    var _re_region = /(!?)\(?([\w\:]+)\)?/i;
    var _re_condition = /([\w]+)([=#])\(?([\w\:]+)\)?/i;
    var _m = new Array();
    var _is_valid = true;
    var _is_break = false;

    if (ob) {
        if ('region' in ob) {
            if (ob['region'] && regionID && regionID != 'n/a') {
                _m = ob['region'].match(_re_region);
                if (_m && _m.length == 3) {
                    var _is_not = _m[1] == '!' ? true : false;
                    var _regions = _m[2].split(':');
                    if (_regions && _regions.length) {
                        _is_valid = false;
                        _is_break = false;
                        for (var _r = 0; _r < _regions.length; _r++) {
                            if ([regionID, countryID].indexOf(_regions[_r]) > -1 || IsCountry(_regions[_r])) {
                                _is_valid = _is_not ? false : true;
                                _is_break = true;
                                break;
                            }
                        }
                        if (_is_not && !_is_break && !_is_valid)
                            _is_valid = true;
                    }
                }
            }
        }
        
        if (_is_valid && 'condition' in ob) {
            if (ob['condition']) {
                _m = ob['condition'].match(_re_condition);
                if (_m && _m.length == 4) {
                    var _id = _m[1];
                    var _is_not = _m[2] == '#' ? true : false;
                    var _values = _m[3].split(':');
                    if (_id && _values && _values.length) {
                        _is_valid = false;
                        if (_values.indexOf(getListSelectedItem(getValue(_id), 0)) > -1) {
                            _is_valid = _is_not ? false : true;
                        }
                    }
                }
            }
        }
    }
    
    return _is_valid;
}

function blockConstructListItems(id) {

    if (!(id && IsExist('constructs') && IsExist(id)))
        return;

    var _ob;
    var _items;
    
    if (id in constructs) {
        var _selected_id = getListSelectedId(self[id]);
        for (var _i = 0; _i < constructs[id].length; _i++) {
            _ob = constructs[id][_i];

            if (!checkConstruct(_ob))
                continue;

            _items = _ob['value'].split(':');
            if (_items && _items.length)
                blockListItems(id, _items);
        }
        self[id] = setListSelectedId(self[id], _selected_id);
    }
}

function blockConstructStatus(id, splitter) {

    if (!id || !IsExist('constructs'))
        return;

    var _ob;
    var _items;
    
    if (id in constructs) {
        for (var _i = 0; _i < constructs[id].length; _i++) {
            _ob = constructs[id][_i];

            if (!checkConstruct(_ob))
                continue;

            _items = _ob['value'].split(':');
            if (_items && _items.length) {
                var prefix = id + splitter;
                for (var _n = 0; _n < _items.length; _n++) {
                    var _id = prefix + _items[_n];
                    if (IsEnabled(_id)) {
                        objectStatus[_id] = 0;
                    }
                }
                setValidBooleanItemByKey(prefix);
            }
        }
    }
}

function blockConstructConstants(ids) {

    if (!ids || !ids.length || !IsExist('constructs'))
        return;

    var _ob;
    var _items;
    var _id;
    var _v;

    for (var _c = 0; _c < ids.length; _c++) {
        _id = ids[_c];

        if (IsExist(_id) && _id in constructs) {
            for (var _i = 0; _i < constructs[_id].length; _i++) {
                _ob = constructs[_id][_i];

                if (!checkConstruct(_ob))
                    continue;

                _items = _ob['value'].split(':');
                if (_items && _items.length == 1) {
                    _v = _items[0];
                    setValue(id, isNaN(_v) ? _v : Number(_v));
                }
            }
        }
    }
}

function blockConstructSquare()
{

    if (!IsExist('constructs'))
        return;

    var _id = 'Square';
    var _ids = new Array('minSquareWidth', 'maxSquareWidth', 'minSquareHeight', 'maxSquareHeight');

    var _ob;
    var _items;
    var _v;

    if (_id in constructs) {
        for (var _i = 0; _i < constructs[_id].length; _i++) {
            _ob = constructs[_id][_i];

            if (!checkConstruct(_ob))
                continue;

            _items = _ob['value'].split(':');
            if (_items && _items.length == 4) {
                for (var _c = 0; _c < 4; _c++) {
                    if (!IsExist(_ids[_c]))
                        continue;
                    _v = _items[_c];
                    if (IsExist(_ids[_c]) && !isNaN(_v))
                        setValue(_ids[_c], Number(_v));
                }
            }
        }
    }
}

function initListState(sid, source, filter) {
    if (!sid || !source)
        return;

    var _outer = getSelfValue(sid);
    var _selected_id = getListSelectedIndex(_outer) > 0 ? getListSelectedId(_outer) : '';
    var _lst = getList(source);
    var _new_lst = new Array();
    var _selected_index = 0;
    var _index = -1;

    for (var _i = 0; _i < _lst.length; _i++) {
        var _item = _lst[_i].split(LST_ITEM_DELIMETER);
        if (!(_item && _item.length))
            continue;
        var _x = get_compound_id(_item[0]);
        if (filter.indexOf(_x) > -1)
            continue;
        ++_index;
        _new_lst.push(_lst[_i]);
        if (!_selected_id)
            continue;
        if (_selected_id == _item[0] || _selected_id == _x)
            _selected_index = _index;
    }

    setValue(sid, makeOuterList(_new_lst, _selected_index));
}

function cloneListItem(destination, source, id) {
    if (destination && getListItemById(destination, id))
        return destination;

    var _lst = getList(source);
    var _item = new Array();

    for (var _i = 0; _i < _lst.length; _i++) {
        if (!_lst[_i])
            continue;
        _item = _lst[_i].split(LST_ITEM_DELIMETER);
        if (_item) {
            var _id = get_compound_id(_item[0]);
            if (_id == id || strip(_item[0]) == id)
                break;
        }
    }

    if (_item && _i < _lst.length)
        return addListItem(destination, _item); 
    else
        return destination;
}

function applyFilter(outer, filter, selected_id) {
    var LOCAL_LIST_DELIMETER = ':';

    if (filter && filter.length > 1 && filter[1]) {
        var values = filter[1].split(LOCAL_LIST_DELIMETER);
        var s = '';

        for (var _k = 0; _k < values.length; _k++) {
            var id = strip(values[_k]);
            if (!id)
                continue;
            s = cloneListItem(s, outer, id);
        }

        if (selected_id)
        {
            s = setListSelectedIndexById(s, selected_id);
        }
        return s;
    } else {
        return outer;
    }
}

function getFilter(filter1) {
    if (filter1 && filter1.length > 1)
        return [strip(filter1[0]), filter1[1]];
    else
        return ['', ''];
}

function getFilterByIntersection(filter1, filter2) {
    if (!filter1 || filter1.length < 1)
        return filter2;
    if (!filter2 || filter2.length < 1)
        return filter1;

    var _new_lst = new Array();

    _new_lst.push(strip(filter1[0]) + '&' + strip(filter2[0]));

    var LOCAL_LIST_DELIMETER = ':';

    var _x1 = filter1[1].split(LOCAL_LIST_DELIMETER);
    var _x2 = filter2[1].split(LOCAL_LIST_DELIMETER);

    var _value = '';

    for (var _i = 0; _i < _x1.length; _i++) {
        if (_x2.indexOf(_x1[_i]) > -1) {
            if (_value) 
                _value += LOCAL_LIST_DELIMETER;
            _value += _x1[_i];
        }
    }

    _new_lst.push(_value);

    return _new_lst;
}

function makeDecimal(s, win) {
    return win ? s.toString().replace(/\./g, ',') : s.toString();
}

function roundNumber(value, index, win) {
    var _d = 1;
    var _s = '';

    for (var _i = 0; _i < index; _i++) { 
        _d = _d * 10;
        _s += '0';
    }

    var _v = Math.floor(value);
    var _x = value - _v;

    if (_x) _s = (strip(_x.toString().substr(2, index+2)) + _s).substr(0, index);
    _s = strip(int(_v).toString()) + (index ? '.' + _s : '');

    return win ? _s.replace(/\./g, ',') : _s;
}

function roundDecimal(value, index) {
    return roundNumber(value, index, true);
}

function roundInteger(value, index) {
    if (value <= 0)
        return '0';

    var _x = int(value);
    var _v = Math.floor(value);

    if (index > 0 && value - _v > 0) {
        _x += 1;
    }

    return _x.toString();
}

function addMargin(outer, item) {
    var _x = parseInt(item[0]);

    if (!isNaN(_x) && _x > 0 && item.length > 3) {
        var _v = new Array('', 'NUMBER', '', 0);
        _v[0] = item[0];
        _v[2] = ('000' + item[2].toString()).substr(-3);
        _v[3] = item[3];
        return addListItem(outer, _v);
    }
    else if (isNaN(_x) && item.length == 4 && item[1].toUpperCase() == 'NUMBER') {
        var _v = new Array('', 'STRING', '', 0);
        _v[0] = item[0];
        _v[2] = ('000' + item[2].toString()).substr(-3);
        _v[3] = item[3];
        return addListItem(outer, _v);
    }
    else
        return outer;
}

function addExtraMargin(outer, item) {
    
    return addListItem(outer, item);
}

function addListOfMargins(ob, prices, count) {

    if (!count || count < 0 || !ob)
        return margins;

    for (_id in ob) 
    {
        var _item = getListItemById(prices, _id);
        if (_item && _item.length > 2)
        {
            var _code = _item[2];
            var _n = ob[_id];
            if (_code && _n)
                margins = addExtraMargin(margins, [_code, 'STRING', 796, _n*count]);
        }
    }

    return margins;
}

function makeDefaultRAL(value, default_value) {
    var _x = makeRAL(value);
    return _x ? _x : (default_value ? default_value : '');
}

function makeRAL(value) {
    if (value < 1000 || value > 9999)
        return '';
    var _x = '0000' + (value > 0 ? value.toString() : '0');
    return _x.substr(_x.length - 4, 4);
}

function arange2Values(value) {
    if (value[0] > value[1])
    {
        value[0] = value[0] + value[1];
        value[1] = value[0] - value[1];
        value[0] = value[0] - value[1];
    }
    return value;
}

function getSystemOption(option, locale) {
    var _x = "!!! system: option<br>";
    var _messages = {
        'system': "Caution:Предупреждение"
    };
    var _options = {
        'Debug'             : "DEBUG (Only For Testing Purposes): ТОЛЬКО ДЛЯ ЦЕЛЕЙ ТЕСТИРОВАНИЯ",
        'withoutRestriction': "Without Restrictions             : БЕЗ КОНТРОЛЯ ОГРАНИЧЕНИЙ",
        'prices_disable'    : "No Prices Calculation            : БЕЗ РАСЧЁТА СТОИМОСТИ",
        'validation_disable': "Validation Disabled              : БЕЗ ОГРАНИЧЕНИЙ",
        'isWorkWithout1C'   : "Without 1C                       : БЕЗ 1С"
    };

    var _index = locale.toLowerCase() == 'rus' ? 1 : 0;
    return strip(_x.replace('system', _messages['system'].split(':')[_index]).replace('option', _options[option].split(':')[_index].toUpperCase()));
}

function IsExist(item) { 
    return item in self ? true : false;
}

function IsEnabled(item) { 
    return item in self && objectStatus[item] ? true : false;
}

function IsDisabled(item) { 
    return item in self && !objectStatus[item] ? true : false;
}

function IsFormFieldSelected(item) {
    return IsEnabled(item) && self[item] ? true : false;
}

function IsTrue(item) { 
    return IsFormFieldSelected(item); 
}

function IsFalse(item) { 
    return !IsFormFieldSelected(item);
}

function getFormFieldValue(item) {
    return IsEnabled(item) ? self[item] : null;
}

function getValue(item) { 
    return getFormFieldValue(item); 
}

function getSelfValue(item) { 
    return item in self ? self[item] : null; 
}

function setFormFieldValue(item, value) {
    if (item in self) 
        self[item] = value;
}

function setValue(item, value) { 
    setFormFieldValue(item, value); 
}

function setValidBooleanItem(items) {
    var _item = '';
    var _valid = '';
    var _changed = true;
    var _should_be_changed = true;

    for (var _i = 0; _i < items.length; _i++) {
        _item = items[_i];
        if (objectStatus[_item] && !_valid)
            _valid = _item;
        if (getSelfValue(_item)) {
            if (!objectStatus[_item]) {
                setValue(_item, false);
                _changed = true;
            } else {
                _should_be_changed = false;
            }
        }
    }
    
    if (_should_be_changed && _valid)
        setValue(_valid, true);
    return _changed;
}

function setValidBooleanItemByKey(key) {
    var _items = new Array();
    var _item = '';

    for (_item in self) {
        if (IsStringStartedWith(_item, key))
            _items.push(_item);
    }

    return setValidBooleanItem(_items);
}

function setStatus(items, status) {
    var _item = '';

    for (var _i = 0; _i < items.length; _i++) {
        _item = items[_i];

        objectStatus[_item] = status;
    }
}

function checkItemsIsValid(items) {
    var _item = '';

    for (var _i = 0; _i < items.length; _i++) {
        _item = items[_i];
        if (!(self.hasOwnProperty(_item) && objectStatus[_item]))
            return false;
    }

    return true;
}

function change2Items(items) {
    var _item = getSelfValue(items[0]);
    setValue(items[0], getSelfValue(items[1]));
    setValue(items[1], _item);
}

function setObjectStatus(items, status) {
    var _item = '';
    var _count_keyword = '_Count';

    for (var _i = 0; _i < items.length; _i++) {
        _item = items[_i];

        objectStatus[_item] = status;
        if (IsStringEndedWith(_item, _count_keyword)) {
            _item = _item.substr(0, _item.length-6);
            if (!(self.hasOwnProperty(_item)))
                continue;
            objectStatus[_item] = status;
        }
    }
}

function setStatusByKey(key, status) {
    var _item = '';
    var _reserved = new Array('_up', '_Code');
    var _valid;

    for (_item in self) {
        if (IsStringStartedWith(_item, key)) {
            _valid = true;
            for (var _i = 0; _i < _reserved.length; _i++) {
                var _x = _reserved[_i];
                if (IsStringEndedWith(_item, _x)) {
                    _valid = false;
                    break;
                }
            }
            if (_valid)
                objectStatus[_item] = status;
        }
    }
}

function setStatusByKeys(keys, status, sensitive) {
    if (!(keys && keys.length))
        return;

    var _item = '';

    for (item in self) {
        var _item = !sensitive ? item.toLowerCase() : item;
        for (var _i = 0; _i < keys.length; _i++) {
            var _key = !sensitive ? keys[_i].toLowerCase() : keys[_i];
            if (IsStringStartedWith(_item, _key) && objectStatus.hasOwnProperty(item)) {
                objectStatus[item] = status;
                break;
            }
        }
    }
}

function getObjectAsString(ob) {
    var _value = '';
    for (_id in ob) {
        if (_value) _value += ',';
        _value += _id + ':' + ob[_id].toString();
    }
    return _value;
}

function getObjectItemsCount(ob) {
    var _value = 0;
    for (_id in ob) {
        if (_id && ob[_id]) _value += ob[_id];
    }
    return _value;
}

function incValueInObject(ob, value) {
    if (!(value in ob)) ob[value] = 0;
    ob[value] += 1;
    return ob;
}

function IsCountry(country) {
    var _c = country.toLowerCase();
    if (!_c)
        return false;
    else if (_c == 'германия' || _c == 'germany')
        return countryID == 'DE' && regionID == 'CB0000009';
    else if (_c == 'латвия' || _c == 'latvija' || _c == 'latvia')
        return countryID == 'LV' && regionID == 'CB0000007';
    else if (_c == 'польша' || _c == 'poland')
        return countryID == 'PL' && regionID == 'CB0000008';
    else if (_c == 'финляндия' || _c == 'finland')
        return countryID == 'FI' && regionID == 'CB0000006';
    else if (_c == 'чехия' || _c == 'czech')
        return countryID == 'CZ' && regionID == '000000027';
    else if (_c == 'европа' || _c == 'europe')
        return IsCountry('германия') || IsCountry('латвия') || IsCountry('польша') || IsCountry('финляндия') || IsCountry('чехия');
    else if (_c == 'китай' || _c == 'china')
        return countryID == 'CH' && regionID == '000000026';
    else if (_c == 'снг')
        return !IsCountry('европа') && !IsCountry('китай');
    else if (_c == 'белоруссия' || _c == 'belorus')
        return countryID == 'BY';
    else if (_c == 'украина' || _c == 'ukraine')
        return countryID == 'UA' && ['000000024','000000023','000000022','000000019','000000002'].indexOf(regionID) > -1;
    else if (_c == 'казахстан' || _c == 'kazakhstan')
        return countryID == 'KZ';
    else if (_c == 'азия' || _c == 'asia')
        return IsCountry('китай') || IsCountry('казахстан');
    else if (_c == 'россия' || _c == 'russia')
        return countryID == 'RU';
    else if (_c == 'москва' || _c == 'moscow')
        return regionID == '000000001' || regionID == 'n/a';
    else
        return false;
}

function IsPriceType(code) {
    if (isNaN(code))
        return priceTypeID == code ? true : false;
    else
        return int(priceTypeID) == int(code) ? true : false;
}

function getListCurrIndex(listContent, listStrDivider) {
    var retVal = new Number(0);
    var myArr = new Array();
    
    myArr = listContent.split(listStrDivider);
    retVal = Number(myArr[0]);
    
    if(isNaN(retVal))
    {
        retVal = -1;
    }
    
    return retVal;
}

function getListCurrValue(listContent,listStrDivider) {
    var retVal = new String('');
    var currN = new Number(0);
    var myArr = new Array();
    
    myArr = listContent.split(listStrDivider);
    currN = Number(myArr[0]);
    
    if(isNaN(currN))
    {
        retVal = '';
    }
    else
    {
        retVal = myArr[currN+1];
    }
    
    return retVal;
}

function setNoticeMessage(oldStr, newStr) {
    var retStr = new String("");
    
    if(oldStr != "")
    {
        retStr = oldStr + "<br>";
    }
    
    retStr = retStr + newStr;
    
    return retStr;
}

function myRound(number, n) {
    var kof = Math.pow (10, n || 1);
    return Math.round(number*kof)/kof;
}


