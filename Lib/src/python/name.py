#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Name 모듈 - 이름 처리 기능
원본 MAXScript의 name.ms에서 변환됨
"""

import re
import os


class Name:
    """
    이름 처리를 위한 클래스
    MAXScript의 _Name 구조체를 Python 클래스로 변환
    
    Default name structure:
    [Base] [Type] [Side] [RealName] [Index]
    ex) Bip001 Dummy L SpineA 001
    """
    
    def __init__(self):
        """초기화 함수"""
        # MAXScript 원본 변수들을 Python 스타일로 변환
        self.__name_parts = ["Base", "Type", "Side", "FrontBack", "RealName", "Index"]
        self.__padding_num = 3
        self.__nub_str = "Nub"
        self.__side_str_array = ["L", "R"]
        self.__front_back_str_array = ["F", "B"]
        self.__parent_str = "P"
        self.__dummy_str = "Dum"
        self.__expose_tm_str = "Exp"
        self.__target_str = "T"
        self.__ik_str = "IK"
        self.__type_str_array = ["P", "Dum", "Exp", "IK", "T"]
        self.__base_str_array = ["b", "Bip001"]
        self.__ini_file = ""
    
    # Python 도우미 함수 - string.ms 함수들을 대체
    def _split_into_string_and_digit(self, in_str):
        """문자열과 숫자 부분을 분리"""
        match = re.search(r'(.*?)(\d*)$', in_str)
        if match:
            return [match.group(1), match.group(2)]
        return [in_str, ""]
    
    def _get_filtering_char(self, in_str):
        """문자열 분리에 사용할 문자 찾기"""
        if " " in in_str:
            return " "
        if "_" in in_str:
            return "_"
        return ""
    
    def _is_digit(self, in_str):
        """문자열이 숫자인지 확인"""
        if not in_str:
            return False
        return in_str.isdigit()
    
    def _has_digit(self, in_str):
        """문자열에 숫자가 포함되어 있는지 확인"""
        return bool(re.search(r'\d', in_str))
    
    def _is_upper_case(self, in_char):
        """문자가 대문자인지 확인"""
        return in_char.isupper()
    
    def _is_lower_case(self, in_char):
        """문자가 소문자인지 확인"""
        return in_char.islower()
    
    def _filter_by_filtering_char(self, in_str):
        """필터링 문자로 문자열 분리"""
        fil_char = self._get_filtering_char(in_str)
        if fil_char:
            return in_str.split(fil_char)
        return []
    
    def _filter_by_upper_case(self, in_str):
        """대문자로 문자열 분리"""
        result = []
        split_part = in_str[0] if in_str else ""
        
        for i in range(1, len(in_str)):
            if self._is_upper_case(in_str[i]):
                result.append(split_part)
                split_part = in_str[i]
            else:
                split_part += in_str[i]
        
        if split_part:
            result.append(split_part)
            
        return result
    
    def _split_to_array(self, in_str):
        """문자열을 배열로 분리"""
        fil_char = self._get_filtering_char(in_str)
        if not fil_char:
            result = self._filter_by_upper_case(in_str)
            temp_array = []
            
            for item in result:
                if self._has_digit(item):
                    split_str_array = self._split_into_string_and_digit(item)
                    if split_str_array[0]:
                        temp_array.append(split_str_array[0])
                    if split_str_array[1]:
                        temp_array.append(split_str_array[1])
                else:
                    temp_array.append(item)
            
            return temp_array
        else:
            return [x for x in in_str.split(fil_char) if x]
    
    def _remove_empty_string_in_array(self, in_array):
        """배열에서 빈 문자열 제거"""
        return [item for item in in_array if item]
    
    def _combine(self, in_array, fil_char=" "):
        """배열을 문자열로 결합"""
        refined_array = self._remove_empty_string_in_array(in_array)
        
        if len(refined_array) < 1:
            return ""
        if len(refined_array) == 1:
            return refined_array[0]
        
        return fil_char.join(refined_array)
    
    # 원본 함수들
    def set_padding_num(self, in_num):
        """패딩 자릿수 설정"""
        self.__padding_num = in_num
    
    def set_nub_str(self, in_str):
        """Nub 문자열 설정"""
        self.__nub_str = in_str
    
    def set_left_str(self, in_str):
        """왼쪽 문자열 설정"""
        self.__side_str_array[0] = in_str
    
    def set_right_str(self, in_str):
        """오른쪽 문자열 설정"""
        self.__side_str_array[1] = in_str
    
    def set_front_str(self, in_str):
        """앞쪽 문자열 설정"""
        self.__front_back_str_array[0] = in_str
    
    def set_back_str(self, in_str):
        """뒤쪽 문자열 설정"""
        self.__front_back_str_array[1] = in_str
    
    def set_type_str(self, in_str_array):
        """타입 문자열 배열 설정"""
        self.__type_str_array = list(in_str_array)
    
    def set_parent_str(self, in_str):
        """부모 문자열 설정"""
        self.__parent_str = in_str
    
    def set_dummy_str(self, in_str):
        """더미 문자열 설정"""
        self.__dummy_str = in_str
    
    def set_expose_tm_str(self, in_str):
        """Expose TM 문자열 설정"""
        self.__expose_tm_str = in_str
    
    def set_target_str(self, in_str):
        """타겟 문자열 설정"""
        self.__target_str = in_str
    
    def set_ik_str(self, in_str):
        """IK 문자열 설정"""
        self.__ik_str = in_str
    
    def set_base_str(self, in_str_array):
        """베이스 문자열 배열 설정"""
        self.__base_str_array = list(in_str_array)
    
    def get_padding_num(self):
        """패딩 자릿수 반환"""
        return self.__padding_num
    
    def get_nub_str(self):
        """Nub 문자열 반환"""
        return self.__nub_str
    
    def get_parent_str(self):
        """부모 문자열 반환"""
        return self.__parent_str
    
    def get_dummy_str(self):
        """더미 문자열 반환"""
        return self.__dummy_str
    
    def get_expose_tm_str(self):
        """Expose TM 문자열 반환"""
        return self.__expose_tm_str
    
    def get_target_str(self):
        """타겟 문자열 반환"""
        return self.__target_str
    
    def get_ik_str(self):
        """IK 문자열 반환"""
        return self.__ik_str
    
    def get_left_str(self):
        """왼쪽 문자열 반환"""
        return self.__side_str_array[0]
    
    def get_right_str(self):
        """오른쪽 문자열 반환"""
        return self.__side_str_array[1]
    
    def get_front_str(self):
        """앞쪽 문자열 반환"""
        return self.__front_back_str_array[0]
    
    def get_back_str(self):
        """뒤쪽 문자열 반환"""
        return self.__front_back_str_array[1]
    
    def get_base_part_index(self):
        """Base 파트 인덱스 반환"""
        try:
            return self.__name_parts.index("Base")
        except ValueError:
            return -1
    
    def get_type_part_index(self):
        """Type 파트 인덱스 반환"""
        try:
            return self.__name_parts.index("Type")
        except ValueError:
            return -1
    
    def get_side_part_index(self):
        """Side 파트 인덱스 반환"""
        try:
            return self.__name_parts.index("Side")
        except ValueError:
            return -1
    
    def get_front_back_part_index(self):
        """FrontBack 파트 인덱스 반환"""
        try:
            return self.__name_parts.index("FrontBack")
        except ValueError:
            return -1
    
    def get_real_name_part_index(self):
        """RealName 파트 인덱스 반환"""
        try:
            return self.__name_parts.index("RealName")
        except ValueError:
            return -1
    
    def get_index_part_index(self):
        """Index 파트 인덱스 반환"""
        try:
            return self.__name_parts.index("Index")
        except ValueError:
            return -1
    
    def set_name_parts_order(self, in_str_array):
        """이름 파트 순서 설정"""
        self.__name_parts = list(in_str_array)
    
    def is_side_char(self, in_char):
        """Side 문자인지 확인"""
        return in_char in self.__side_str_array
    
    def is_front_back_char(self, in_char):
        """FrontBack 문자인지 확인"""
        return in_char in self.__front_back_str_array
    
    def is_type_char(self, in_char):
        """Type 문자인지 확인"""
        return in_char in self.__type_str_array
    
    def is_base_char(self, in_char):
        """Base 문자인지 확인"""
        return in_char in self.__base_str_array
    
    def is_index_char(self, in_char):
        """Index 문자인지 확인"""
        return self._is_digit(in_char) or in_char == self.__nub_str
    
    def get_char_type(self, in_char):
        """문자 타입 반환"""
        if self.is_index_char(in_char):
            return "Index"
        if self.is_side_char(in_char):
            return "Side"
        if self.is_front_back_char(in_char):
            return "FrontBack"
        if self.is_type_char(in_char):
            return "Type"
        if self.is_base_char(in_char):
            return "Base"
        return None
    
    def get_base(self, in_str):
        """Base 파트 반환"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self._split_to_array(in_str)
        base_index = self.get_base_part_index()
        real_name_index = self.get_real_name_part_index()
        
        # Base 문자 찾기
        found_result = sum(1 for item in name_array if item in self.__base_str_array)
        
        if found_result > 0:
            if base_index < real_name_index:
                for i in range(base_index):
                    if i < len(name_array) and self.is_base_char(name_array[i]):
                        return name_array[i]
            else:
                for i in range(len(name_array) - 1, len(name_array) - base_index - 1, -1):
                    if i >= 0 and self.is_base_char(name_array[i]):
                        return name_array[i]
        
        return ""
    
    def get_type(self, in_str):
        """Type 파트 반환"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self._split_to_array(in_str)
        type_index = self.get_type_part_index()
        real_name_index = self.get_real_name_part_index()
        
        # Type 문자 찾기
        found_result = sum(1 for item in name_array if item in self.__type_str_array)
        
        if found_result > 0:
            if type_index < real_name_index:
                for i in range(type_index):
                    if i < len(name_array) and self.is_type_char(name_array[i]):
                        return name_array[i]
            else:
                for i in range(len(name_array) - 1, len(name_array) - type_index - 1, -1):
                    if i >= 0 and self.is_type_char(name_array[i]):
                        return name_array[i]
        
        return ""
    
    def get_side(self, in_str):
        """Side 파트 반환"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self._split_to_array(in_str)
        side_index = self.get_side_part_index()
        real_name_index = self.get_real_name_part_index()
        
        # Side 문자 찾기
        found_result = sum(1 for item in name_array if item in self.__side_str_array)
        
        if found_result > 0:
            if side_index < real_name_index:
                for i in range(side_index):
                    if i < len(name_array) and self.is_side_char(name_array[i]):
                        return name_array[i]
            else:
                for i in range(len(name_array) - 1, len(name_array) - side_index - 1, -1):
                    if i >= 0 and self.is_side_char(name_array[i]):
                        return name_array[i]
        
        return ""
    
    def get_front_back(self, in_str):
        """FrontBack 파트 반환"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self._split_to_array(in_str)
        front_back_index = self.get_front_back_part_index()
        real_name_index = self.get_real_name_part_index()
        
        # FrontBack 문자 찾기
        found_result = sum(1 for item in name_array if item in self.__front_back_str_array)
        
        if found_result > 0:
            if front_back_index < real_name_index:
                for i in range(front_back_index):
                    if i < len(name_array) and self.is_front_back_char(name_array[i]):
                        return name_array[i]
            else:
                for i in range(len(name_array) - 1, len(name_array) - front_back_index - 1, -1):
                    if i >= 0 and self.is_front_back_char(name_array[i]):
                        return name_array[i]
        
        return ""
    
    def get_index(self, in_str):
        """Index 파트 반환"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self._split_to_array(in_str)
        index_index = self.get_index_part_index()
        real_name_index = self.get_real_name_part_index()
        
        # Index 문자 찾기
        found_result = sum(1 for item in name_array if self.is_index_char(item))
        
        if found_result > 0:
            if index_index < real_name_index:
                for i in range(index_index):
                    if i < len(name_array) and self.is_index_char(name_array[i]):
                        return name_array[i]
            else:
                for i in range(len(name_array) - 1, len(name_array) - index_index - 1, -1):
                    if i >= 0 and self.is_index_char(name_array[i]):
                        return name_array[i]
        
        return ""
    
    def get_real_name(self, in_str):
        """RealName 파트 반환"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self._split_to_array(in_str)
        
        # 다른 파트들 구하기
        base_str = self.get_base(in_str)
        type_str = self.get_type(in_str)
        side_str = self.get_side(in_str)
        front_back_str = self.get_front_back(in_str)
        index_str = self.get_index(in_str)
        
        # 다른 파트들을 제외한 나머지가 RealName
        non_real_name_array = [base_str, type_str, side_str, front_back_str, index_str]
        
        for item in non_real_name_array:
            if item and item in name_array:
                name_array.remove(item)
        
        return self._combine(name_array, fil_char=fil_char if fil_char else " ")
    
    def convert_name_to_name_array(self, in_str):
        """이름을 이름 배열로 변환"""
        return_array = [""] * len(self.__name_parts)
        fil_char = self._get_filtering_char(in_str)
        
        base_index = self.get_base_part_index()
        type_index = self.get_type_part_index()
        side_index = self.get_side_part_index()
        front_back_index = self.get_front_back_part_index()
        index_index = self.get_index_part_index()
        real_name_index = self.get_real_name_part_index()
        
        base_str = self.get_base(in_str)
        type_str = self.get_type(in_str)
        side_str = self.get_side(in_str)
        front_back_str = self.get_front_back(in_str)
        index_str = self.get_index(in_str)
        real_name_str = self.get_real_name(in_str)
        
        return_array[base_index] = base_str
        return_array[type_index] = type_str
        return_array[side_index] = side_str
        return_array[front_back_index] = front_back_str
        return_array[real_name_index] = real_name_str
        return_array[index_index] = index_str
        
        return return_array
    
    def is_nub(self, in_str):
        """Nub인지 확인"""
        return self.get_index(in_str) == self.__nub_str
    
    def get_index_as_digit(self, in_str):
        """Index를 숫자로 반환"""
        index_str = self.get_index(in_str)
        
        if index_str == self.__nub_str:
            return -1
        
        if index_str:
            try:
                return int(index_str)
            except ValueError:
                return False
        
        return False
    
    def get_string(self, in_str):
        """Index를 제외한 문자열 반환"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self.convert_name_to_name_array(in_str)
        index_order = self.get_index_part_index()
        
        # Index를 제외한 배열
        return_name_array = name_array[:index_order] + name_array[index_order+1:]
        
        return self._combine(return_name_array, fil_char=fil_char if fil_char else " ")
    
    def set_index_as_nub(self, in_str):
        """Index를 Nub로 설정"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self.convert_name_to_name_array(in_str)
        index_order = self.get_index_part_index()
        
        name_array[index_order] = self.__nub_str
        
        return self._combine(name_array, fil_char=fil_char if fil_char else " ")
    
    def is_left(self, in_str):
        """왼쪽인지 확인"""
        side_char = self.get_side(in_str)
        return side_char and side_char == self.get_left_str()
    
    def is_right(self, in_str):
        """오른쪽인지 확인"""
        side_char = self.get_side(in_str)
        return side_char and side_char == self.get_right_str()
    
    def is_front(self, in_str):
        """앞쪽인지 확인"""
        front_back_char = self.get_front_back(in_str)
        return front_back_char and front_back_char == self.get_front_str()
    
    def is_back(self, in_str):
        """뒤쪽인지 확인"""
        front_back_char = self.get_front_back(in_str)
        return front_back_char and front_back_char == self.get_back_str()
    
    def has_side(self, in_str):
        """Side가 있는지 확인"""
        return self.is_left(in_str) or self.is_right(in_str)
    
    def has_front_back(self, in_str):
        """FrontBack이 있는지 확인"""
        return self.is_front(in_str) or self.is_back(in_str)
    
    def get_non_real_name(self, in_str):
        """RealName을 제외한 문자열 반환"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self.convert_name_to_name_array(in_str)
        real_name_index = self.get_real_name_part_index()
        
        name_array[real_name_index] = ""
        
        return self._combine(name_array, fil_char=fil_char if fil_char else " ")
    
    def combine(self, in_base="", in_type="", in_side="", in_front_back="", in_real_name="", in_index="", in_fil_char=" "):
        """각 파트를 결합하여 이름 생성"""
        base_index = self.get_base_part_index()
        type_index = self.get_type_part_index()
        side_index = self.get_side_part_index()
        front_back_index = self.get_front_back_part_index()
        real_name_index = self.get_real_name_part_index()
        index_index = self.get_index_part_index()
        
        parts_index_array = [base_index, type_index, side_index, front_back_index, real_name_index, index_index]
        parts_array = [in_base, in_type, in_side, in_front_back, in_real_name, in_index]
        combined_name_array = [""] * len(self.__name_parts)
        
        for i in range(len(parts_index_array)):
            if parts_index_array[i] != -1:
                combined_name_array[parts_index_array[i]] = parts_array[i]
        
        return self._combine(combined_name_array, fil_char=in_fil_char)
    
    def add_fix(self, in_str, in_part, in_fix, pos="#npPosPrefix"):
        """접두/접미사 추가"""
        if not in_fix:
            return in_str
        
        fil_char = self._get_filtering_char(in_str)
        name_array = self.convert_name_to_name_array(in_str)
        part_index = -1
        
        if in_part == "Base":
            part_index = self.get_base_part_index()
        elif in_part == "Type":
            part_index = self.get_type_part_index()
        elif in_part == "Side":
            part_index = self.get_side_part_index()
        elif in_part == "FrontBack":
            part_index = self.get_front_back_part_index()
        elif in_part == "RealName":
            part_index = self.get_real_name_part_index()
        elif in_part == "Index":
            part_index = self.get_index_part_index()
        
        if part_index != -1:
            if pos == "#npPosPrefix":
                name_array[part_index] = in_fix + name_array[part_index]
            elif pos == "#npPosSufix":
                name_array[part_index] = name_array[part_index] + in_fix
        
        return self._combine(name_array, fil_char=fil_char if fil_char else " ")
    
    def add_prefix_to_real_name(self, in_str, in_prefix):
        """RealName에 접두사 추가"""
        return self.add_fix(in_str, "RealName", in_prefix, pos="#npPosPrefix")
    
    def add_sufix_to_real_name(self, in_str, in_sufix):
        """RealName에 접미사 추가"""
        return self.add_fix(in_str, "RealName", in_sufix, pos="#npPosSufix")
    
    def convert_digit_into_padding_string(self, in_digit, in_padding_num=None):
        """숫자를 패딩된 문자열로 변환"""
        if in_padding_num is None:
            in_padding_num = self.__padding_num
        
        digit_num = 0
        
        if isinstance(in_digit, int):
            digit_num = in_digit
        elif isinstance(in_digit, str):
            if in_digit.isdigit():
                digit_num = int(in_digit)
        
        return f"{digit_num:0{in_padding_num}d}"
    
    def set_index_padding_num(self, in_str, in_padding_num=None):
        """Index 패딩 자릿수 설정"""
        if in_padding_num is None:
            in_padding_num = self.__padding_num
        
        fil_char = self._get_filtering_char(in_str)
        name_array = self.convert_name_to_name_array(in_str)
        index_index = self.get_index_part_index()
        index_str = self.get_index(in_str)
        
        if index_str and index_str != self.__nub_str:
            index_str = self.convert_digit_into_padding_string(index_str, in_padding_num)
            name_array[index_index] = index_str
        
        return self._combine(name_array, fil_char=fil_char if fil_char else " ")
    
    def get_index_padding_num(self, in_str):
        """Index 패딩 자릿수 반환"""
        index = self.get_index(in_str)
        
        if index != self.__nub_str and index:
            return len(index)
        
        return 1
    
    def increase_index(self, in_str, in_amount):
        """Index 증가"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self.convert_name_to_name_array(in_str)
        index_index = self.get_index_part_index()
        
        if index_index != -1:
            index_str = ""
            index_padding_num = self.__padding_num
            index_num = -9999
            
            if not name_array[index_index]:
                index_num = -1
            elif name_array[index_index] == self.__nub_str:
                index_num = -9999999
            else:
                try:
                    index_num = int(name_array[index_index])
                    index_padding_num = len(name_array[index_index])
                except ValueError:
                    pass
            
            index_num = index_num + in_amount
            
            if index_num > -1:
                index_str = f"{index_num:0{index_padding_num}d}"
            else:
                index_str = self.__nub_str
            
            name_array[index_index] = index_str
        
        return self._combine(name_array, fil_char=fil_char if fil_char else " ")
    
    def replace_filtering_char(self, in_str, in_new_fil_char):
        """필터링 문자 교체"""
        name_array = self.convert_name_to_name_array(in_str)
        return self._combine(name_array, fil_char=in_new_fil_char)
    
    def replace_base(self, in_str, in_new_base):
        """Base 파트 교체"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self.convert_name_to_name_array(in_str)
        base_index = self.get_base_part_index()
        
        if base_index != -1:
            name_array[base_index] = in_new_base
        
        return self._combine(name_array, fil_char=fil_char if fil_char else " ")
    
    def replace_type(self, in_str, in_new_type):
        """Type 파트 교체"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self.convert_name_to_name_array(in_str)
        type_index = self.get_type_part_index()
        
        if type_index != -1:
            name_array[type_index] = in_new_type
        
        return self._combine(name_array, fil_char=fil_char if fil_char else " ")
    
    def replace_side(self, in_str, in_new_side):
        """Side 파트 교체"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self.convert_name_to_name_array(in_str)
        side_index = self.get_side_part_index()
        
        if side_index != -1:
            name_array[side_index] = in_new_side
        
        return self._combine(name_array, fil_char=fil_char if fil_char else " ")
    
    def replace_front_back(self, in_str, in_new_front_back):
        """FrontBack 파트 교체"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self.convert_name_to_name_array(in_str)
        front_back_index = self.get_front_back_part_index()
        
        if front_back_index != -1:
            name_array[front_back_index] = in_new_front_back
        
        return self._combine(name_array, fil_char=fil_char if fil_char else " ")
    
    def replace_index(self, in_str, in_new_index, keep_padding=True):
        """Index 파트 교체"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self.convert_name_to_name_array(in_str)
        index_index = self.get_index_part_index()
        
        if index_index != -1:
            name_array[index_index] = in_new_index
            result = self._combine(name_array, fil_char=fil_char if fil_char else " ")
            
            if keep_padding:
                index_padding_num = self.get_index_padding_num(in_str)
                result = self.set_index_padding_num(result, index_padding_num)
            
            return result
        
        return in_str
    
    def replace_real_name(self, in_str, in_new_real_name):
        """RealName 파트 교체"""
        fil_char = self._get_filtering_char(in_str)
        name_array = self.convert_name_to_name_array(in_str)
        real_name_index = self.get_real_name_part_index()
        
        if real_name_index != -1:
            name_array[real_name_index] = in_new_real_name
        
        return self._combine(name_array, fil_char=fil_char if fil_char else " ")
    
    def remove_type(self, in_str):
        """Type 파트 제거"""
        return self.replace_type(in_str, "")
    
    def remove_side(self, in_str):
        """Side 파트 제거"""
        return self.replace_side(in_str, "")
    
    def remove_index(self, in_str):
        """Index 파트 제거"""
        return self.replace_index(in_str, "")
    
    def remove_base(self, in_str):
        """Base 파트 제거"""
        return self.replace_base(in_str, "")
    
    def gen_unique_name(self, in_str):
        """고유한 이름 생성"""
        # MAXScript 원본의 objects 컬렉션은 Python으로 직접 변환하기 어려움
        # 여기서는 임의의 숫자를 반환하는 것으로 대체
        import random
        return self.replace_index(in_str, str(random.randint(1, 100)))
    
    def gen_mirroring_name(self, in_str, axis=1):
        """미러링된 이름 생성"""
        return_name = in_str
        
        if self.has_side(in_str) and axis == 1:
            if self.is_left(in_str):
                return_name = self.replace_side(in_str, self.get_right_str())
            elif self.is_right(in_str):
                return_name = self.replace_side(in_str, self.get_left_str())
        
        if self.has_front_back(in_str) and axis == 2:
            if self.is_front(in_str):
                return_name = self.replace_front_back(in_str, self.get_back_str())
            elif self.is_back(in_str):
                return_name = self.replace_front_back(in_str, self.get_front_str())
        
        if return_name == in_str:
            return_name = self.gen_unique_name(in_str)
        
        return return_name
    
    def sort_by_index(self, in_name_array):
        """인덱스 기준으로 정렬"""
        if not in_name_array:
            return []
        
        # 인덱스와 원래 위치를 저장하는 리스트 생성
        index_info = []
        for i, name in enumerate(in_name_array):
            index_val = self.get_index_as_digit(name)
            if index_val is False:
                index_val = 0
            index_info.append((i, index_val))
        
        # 인덱스 값으로 정렬
        index_info.sort(key=lambda x: x[1])
        
        # 정렬된 순서로 이름 배열 반환
        return [in_name_array[idx] for idx, _ in index_info]
    
    def compare_name(self, in_obj_a, in_obj_b):
        """이름 비교"""
        return in_obj_a.name.lower() < in_obj_b.name.lower()
    
    def sort_by_name(self, in_array):
        """이름 기준으로 정렬"""
        import copy
        return_array = copy.deepcopy(in_array)
        return_array.sort(key=lambda x: x.name.lower())
        return return_array
    
    def find_and_replace(self, in_str, in_target_str, in_new_str):
        """문자열 찾아 바꾸기"""
        if in_target_str in in_str:
            return in_str.replace(in_target_str, in_new_str)
        return in_str
    
    def get_ini_file(self):
        """INI 파일 경로 반환"""
        return self.__ini_file
    
    def load_setting_from_ini(self):
        """INI 파일에서 설정 불러오기"""
        # Python에서는 INI 파일 처리를 ConfigParser로 할 수 있지만,
        # 여기서는 기본 경로만 설정하고 실제 구현은 생략
        script_dir = os.path.dirname(os.path.abspath(__file__))
        self.__ini_file = os.path.join(script_dir, "NameTool.ini")
        
        # 실제 구현은 생략됨 (필요시 ConfigParser 사용)
