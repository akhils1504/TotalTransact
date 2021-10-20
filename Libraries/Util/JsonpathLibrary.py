#!/usr/bin/python
# -*- coding: utf-8 -*-
import json
import jsonpath

class JsonpathLibrary(object):

    def get_items_by_path(self, json_string, json_path):
        json_object = json.loads(json_string)
        match_object = jsonpath.jsonpath(json_object, json_path)
        match_string = json.dumps(match_object[0])
        match_string = match_string.replace('"','')
        return match_string