#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
네이밍 모듈 - 3ds Max용 이름 처리 기능 제공
원본 MAXScript의 string.ms와 name.ms를 Python으로 변환하여 통합
"""

import re
import os
from pymxs import runtime as rt


class Naming:
    """
    3ds Max 노드 이름을 관리하기 위한 클래스.
    MAXScript의 _Name 구조체와 _String 구조체를 통합하여 Python으로 재구현.
    """
    
    def __init__(self):
        """클래스 초기화 및 기본 설정값 정의"""
        # 이름 구조 관련 설정값
        self._nameParts = ["Base", "Type", "Side", "FrontBack", "RealName", "Index"]
        self._paddingNum = 3
        self._nubStr = "Nub"
        self._sideStrArray = ["L", "R"]
        self._frontBackStrArray = ["F", "B"]
        self._parentStr = "P"
        self._dummyStr = "Dum"
        self._exposeTmStr = "Exp"
        self._targetStr = "T"
        self._ikStr = "IK"
        self._typeStrArray = ["P", "Dum", "Exp", "IK", "T"]
        self._baseStrArray = ["b", "Bip001"]
        self._iniFile = ""

    # ---- String 관련 메소드들 (내부 사용 헬퍼 메소드) ----
    
    def _split_into_string_and_digit(self, inStr):
        """
        문자열을 문자부분과 숫자부분으로 분리
        
        Args:
            inStr: 분리할 문자열
            
        Returns:
            튜플 (문자부분, 숫자부분)
        """
        match = re.match(r'^(.*?)(\d*)$', inStr)
        if match:
            return match.group(1), match.group(2)
        return inStr, ""

    def _compare_string(self, inStr1, inStr2):
        """
        대소문자 구분 없이 문자열 비교
        
        Args:
            inStr1: 첫 번째 문자열
            inStr2: 두 번째 문자열
            
        Returns:
            비교 결과 (inStr1 < inStr2: 음수, inStr1 == inStr2: 0, inStr1 > inStr2: 양수)
        """
        # Python에서는 대소문자 구분 없는 비교를 위해 lower() 메서드 사용
        if inStr1.lower() < inStr2.lower():
            return -1
        elif inStr1.lower() > inStr2.lower():
            return 1
        return 0

    def _sort_by_alphabet(self, inArray):
        """
        배열 내 문자열을 알파벳 순으로 정렬
        
        Args:
            inArray: 정렬할 배열
            
        Returns:
            정렬된 배열
        """
        # Python의 sorted 함수와 lambda를 사용하여 대소문자 구분 없이 정렬
        return sorted(inArray, key=lambda x: x.lower())

    def _get_filtering_char(self, inStr):
        """
        문자열에서 사용된 구분자 문자 찾기
        
        Args:
            inStr: 확인할 문자열
            
        Returns:
            구분자 문자 (' ' 또는 '_' 또는 '')
        """
        if ' ' in inStr:
            return ' '
        if '_' in inStr:
            return '_'
        return ''

    def _filter_by_filtering_char(self, inStr):
        """
        구분자 문자로 문자열 분할
        
        Args:
            inStr: 분할할 문자열
            
        Returns:
            분할된 문자열 리스트
        """
        filChar = self._get_filtering_char(inStr)
        
        if not filChar:
            return [inStr]
            
        # 빈 문자열 제거하며 분할
        return [part for part in inStr.split(filChar) if part]

    def _filter_by_upper_case(self, inStr):
        """
        대문자로 시작하는 부분을 기준으로 문자열 분할
        
        Args:
            inStr: 분할할 문자열
            
        Returns:
            분할된 문자열 리스트
        """
        if not inStr:
            return []
            
        result = []
        currentPart = inStr[0]
        
        for i in range(1, len(inStr)):
            if inStr[i].isupper():
                result.append(currentPart)
                currentPart = inStr[i]
            else:
                currentPart += inStr[i]
                
        if currentPart:
            result.append(currentPart)
            
        return result

    def _has_digit(self, inStr):
        """
        문자열에 숫자가 포함되어 있는지 확인
        
        Args:
            inStr: 확인할 문자열
            
        Returns:
            숫자가 포함되어 있으면 True, 아니면 False
        """
        return bool(re.search(r'\d', inStr))

    def _is_digit(self, inStr):
        """
        문자열이 숫자로만 이루어져 있는지 확인
        
        Args:
            inStr: 확인할 문자열
            
        Returns:
            숫자로만 이루어져 있으면 True, 아니면 False
        """
        return bool(re.match(r'^\d+$', inStr))

    def _split_to_array(self, inStr):
        """
        문자열을 구분자 또는 대문자로 분할하고 숫자 부분도 분리
        
        Args:
            inStr: 분할할 문자열
            
        Returns:
            분할된 문자열 리스트
        """
        filChar = self._get_filtering_char(inStr)
        
        if not filChar:
            # 구분자가 없을 경우 대문자로 분할
            resultArray = self._filter_by_upper_case(inStr)
            tempArray = []
            
            for item in resultArray:
                if self._has_digit(item):
                    stringPart, digitPart = self._split_into_string_and_digit(item)
                    if stringPart:
                        tempArray.append(stringPart)
                    if digitPart:
                        tempArray.append(digitPart)
                else:
                    tempArray.append(item)
                    
            return tempArray
        else:
            # 구분자가 있을 경우 구분자로 분할
            return self._filter_by_filtering_char(inStr)

    def _remove_empty_string_in_array(self, inArray):
        """
        배열에서 빈 문자열 제거
        
        Args:
            inArray: 처리할 배열
            
        Returns:
            빈 문자열이 제거된 배열
        """
        return [item for item in inArray if item]

    def _combine(self, inArray, filChar=" "):
        """
        문자열 배열을 하나의 문자열로 결합
        
        Args:
            inArray: 결합할 문자열 배열
            filChar: 구분자 (기본값: 공백)
            
        Returns:
            결합된 문자열
        """
        refinedArray = self._remove_empty_string_in_array(inArray)
        
        if not refinedArray:
            return ""
            
        if len(refinedArray) == 1:
            return refinedArray[0]
            
        return filChar.join(refinedArray)

    def _find_and_replace(self, inStr, inTargetStr, inNewStr):
        """
        문자열 내 특정 부분을 다른 문자열로 대체
        
        Args:
            inStr: 원본 문자열
            inTargetStr: 대체할 대상 문자열
            inNewStr: 새 문자열
            
        Returns:
            대체된 문자열
        """
        return inStr.replace(inTargetStr, inNewStr)

    # ---- Name 관련 메소드들 ----
    
    def set_padding_num(self, inNum):
        """
        패딩 숫자 설정
        
        Args:
            inNum: 패딩 숫자
        """
        self._paddingNum = inNum

    def set_nub_str(self, inStr):
        """
        넙(Nub) 문자열 설정
        
        Args:
            inStr: 넙 문자열
        """
        self._nubStr = inStr

    def set_left_str(self, inStr):
        """
        왼쪽 구분자 설정
        
        Args:
            inStr: 왼쪽 구분자
        """
        self._sideStrArray[0] = inStr

    def set_right_str(self, inStr):
        """
        오른쪽 구분자 설정
        
        Args:
            inStr: 오른쪽 구분자
        """
        self._sideStrArray[1] = inStr

    def set_front_str(self, inStr):
        """
        앞 구분자 설정
        
        Args:
            inStr: 앞 구분자
        """
        self._frontBackStrArray[0] = inStr

    def set_back_str(self, inStr):
        """
        뒤 구분자 설정
        
        Args:
            inStr: 뒤 구분자
        """
        self._frontBackStrArray[1] = inStr

    def set_type_str(self, inStrArray):
        """
        타입 문자열 배열 설정
        
        Args:
            inStrArray: 타입 문자열 배열
        """
        self._typeStrArray = inStrArray.copy()

    def set_parent_str(self, inStr):
        """
        부모 문자열 설정
        
        Args:
            inStr: 부모 문자열
        """
        self._parentStr = inStr

    def set_dummy_str(self, inStr):
        """
        더미 문자열 설정
        
        Args:
            inStr: 더미 문자열
        """
        self._dummyStr = inStr

    def set_expose_tm_str(self, inStr):
        """
        변환 노출 문자열 설정
        
        Args:
            inStr: 변환 노출 문자열
        """
        self._exposeTmStr = inStr

    def set_target_str(self, inStr):
        """
        타겟 문자열 설정
        
        Args:
            inStr: 타겟 문자열
        """
        self._targetStr = inStr

    def set_ik_str(self, inStr):
        """
        IK 문자열 설정
        
        Args:
            inStr: IK 문자열
        """
        self._ikStr = inStr

    def set_base_str(self, inStrArray):
        """
        기본 문자열 배열 설정
        
        Args:
            inStrArray: 기본 문자열 배열
        """
        self._baseStrArray = inStrArray.copy()

    def get_padding_num(self):
        """
        패딩 숫자 가져오기
        
        Returns:
            패딩 숫자
        """
        return self._paddingNum

    def get_nub_str(self):
        """
        넙 문자열 가져오기
        
        Returns:
            넙 문자열
        """
        return self._nubStr

    def get_parent_str(self):
        """
        부모 문자열 가져오기
        
        Returns:
            부모 문자열
        """
        return self._parentStr

    def get_dummy_str(self):
        """
        더미 문자열 가져오기
        
        Returns:
            더미 문자열
        """
        return self._dummyStr

    def get_expose_tm_str(self):
        """
        변환 노출 문자열 가져오기
        
        Returns:
            변환 노출 문자열
        """
        return self._exposeTmStr

    def get_target_str(self):
        """
        타겟 문자열 가져오기
        
        Returns:
            타겟 문자열
        """
        return self._targetStr

    def get_ik_str(self):
        """
        IK 문자열 가져오기
        
        Returns:
            IK 문자열
        """
        return self._ikStr

    def get_left_str(self):
        """
        왼쪽 구분자 가져오기
        
        Returns:
            왼쪽 구분자
        """
        return self._sideStrArray[0]

    def get_right_str(self):
        """
        오른쪽 구분자 가져오기
        
        Returns:
            오른쪽 구분자
        """
        return self._sideStrArray[1]

    def get_front_str(self):
        """
        앞 구분자 가져오기
        
        Returns:
            앞 구분자
        """
        return self._frontBackStrArray[0]

    def get_back_str(self):
        """
        뒤 구분자 가져오기
        
        Returns:
            뒤 구분자
        """
        return self._frontBackStrArray[1]

    def get_base_part_index(self):
        """
        기본 부분 인덱스 가져오기
        
        Returns:
            기본 부분 인덱스
        """
        try:
            return self._nameParts.index("Base")
        except ValueError:
            return -1

    def get_type_part_index(self):
        """
        유형 부분 인덱스 가져오기
        
        Returns:
            유형 부분 인덱스
        """
        try:
            return self._nameParts.index("Type")
        except ValueError:
            return -1

    def get_side_part_index(self):
        """
        측면 부분 인덱스 가져오기
        
        Returns:
            측면 부분 인덱스
        """
        try:
            return self._nameParts.index("Side")
        except ValueError:
            return -1

    def get_front_back_part_index(self):
        """
        앞/뒤 부분 인덱스 가져오기
        
        Returns:
            앞/뒤 부분 인덱스
        """
        try:
            return self._nameParts.index("FrontBack")
        except ValueError:
            return -1

    def get_real_name_part_index(self):
        """
        실제 이름 부분 인덱스 가져오기
        
        Returns:
            실제 이름 부분 인덱스
        """
        try:
            return self._nameParts.index("RealName")
        except ValueError:
            return -1

    def get_index_part_index(self):
        """
        인덱스 부분 인덱스 가져오기
        
        Returns:
            인덱스 부분 인덱스
        """
        try:
            return self._nameParts.index("Index")
        except ValueError:
            return -1

    def set_name_parts_order(self, inStrArray):
        """
        이름 부분 순서 설정
        
        Args:
            inStrArray: 이름 부분 순서 배열
        """
        self._nameParts = inStrArray.copy()

    def is_side_char(self, inChar):
        """
        문자가 측면 문자인지 확인
        
        Args:
            inChar: 확인할 문자
            
        Returns:
            측면 문자이면 True, 아니면 False
        """
        return inChar in self._sideStrArray

    def is_front_back_char(self, inChar):
        """
        문자가 앞/뒤 문자인지 확인
        
        Args:
            inChar: 확인할 문자
            
        Returns:
            앞/뒤 문자이면 True, 아니면 False
        """
        return inChar in self._frontBackStrArray

    def is_type_char(self, inChar):
        """
        문자가 유형 문자인지 확인
        
        Args:
            inChar: 확인할 문자
            
        Returns:
            유형 문자이면 True, 아니면 False
        """
        return inChar in self._typeStrArray

    def is_base_char(self, inChar):
        """
        문자가 기본 문자인지 확인
        
        Args:
            inChar: 확인할 문자
            
        Returns:
            기본 문자이면 True, 아니면 False
        """
        return inChar in self._baseStrArray

    def is_index_char(self, inChar):
        """
        문자가 인덱스 문자인지 확인
        
        Args:
            inChar: 확인할 문자
            
        Returns:
            인덱스 문자이면 True, 아니면 False
        """
        return self._is_digit(inChar) or inChar == self._nubStr

    def get_char_type(self, inChar):
        """
        문자의 유형 가져오기
        
        Args:
            inChar: 확인할 문자
            
        Returns:
            문자 유형 ("Index", "Side", "FrontBack", "Type", "Base" 중 하나 또는 None)
        """
        if self.is_index_char(inChar):
            return "Index"
        if self.is_side_char(inChar):
            return "Side"
        if self.is_front_back_char(inChar):
            return "FrontBack"
        if self.is_type_char(inChar):
            return "Type"
        if self.is_base_char(inChar):
            return "Base"
        return None

    def get_side(self, inStr):
        """
        문자열에서 측면 부분 추출
        
        Args:
            inStr: 처리할 문자열
            
        Returns:
            측면 부분 문자열
        """
        fil_char = self._get_filtering_char(inStr)
        name_array = self._split_to_array(inStr)
        return_str = ""
        
        side_index = self.get_side_part_index()
        real_name_index = self.get_real_name_part_index()
        
        # 측면 문자열이 있는지 확인
        found = False
        for item in self._sideStrArray:
            if item in name_array:
                found = True
                break
                
        if found:
            if side_index < real_name_index:
                # 측면 부분이 실제 이름 앞에 있는 경우
                for i in range(min(side_index + 1, len(name_array))):
                    if self.is_side_char(name_array[i]):
                        return_str = name_array[i]
                        break
            else:
                # 측면 부분이 실제 이름 뒤에 있는 경우
                for i in range(len(name_array) - 1, max(len(name_array) - side_index - 1, -1), -1):
                    if self.is_side_char(name_array[i]):
                        return_str = name_array[i]
                        break
                        
        return return_str

    def get_base(self, inStr):
        """
        문자열에서 기본 부분 추출
        
        Args:
            inStr: 처리할 문자열
            
        Returns:
            기본 부분 문자열
        """
        fil_char = self._get_filtering_char(inStr)
        name_array = self._split_to_array(inStr)
        return_str = ""
        
        base_index = self.get_base_part_index()
        real_name_index = self.get_real_name_part_index()
        
        # 기본 문자열이 있는지 확인
        found = False
        for item in self._baseStrArray:
            if item in name_array:
                found = True
                break
                
        if found:
            if base_index < real_name_index:
                # 기본 부분이 실제 이름 앞에 있는 경우
                for i in range(min(base_index + 1, len(name_array))):
                    if self.is_base_char(name_array[i]):
                        return_str = name_array[i]
                        break
            else:
                # 기본 부분이 실제 이름 뒤에 있는 경우
                for i in range(len(name_array) - 1, max(len(name_array) - base_index - 1, -1), -1):
                    if self.is_base_char(name_array[i]):
                        return_str = name_array[i]
                        break
                        
        return return_str

    def get_type(self, inStr):
        """
        문자열에서 유형 부분 추출
        
        Args:
            inStr: 처리할 문자열
            
        Returns:
            유형 부분 문자열
        """
        fil_char = self._get_filtering_char(inStr)
        name_array = self._split_to_array(inStr)
        return_str = ""
        
        type_index = self.get_type_part_index()
        real_name_index = self.get_real_name_part_index()
        
        # 유형 문자열이 있는지 확인
        found = False
        for item in self._typeStrArray:
            if item in name_array:
                found = True
                break
                
        if found:
            if type_index < real_name_index:
                # 유형 부분이 실제 이름 앞에 있는 경우
                for i in range(min(type_index + 1, len(name_array))):
                    if self.is_type_char(name_array[i]):
                        return_str = name_array[i]
                        break
            else:
                # 유형 부분이 실제 이름 뒤에 있는 경우
                for i in range(len(name_array) - 1, max(len(name_array) - type_index - 1, -1), -1):
                    if self.is_type_char(name_array[i]):
                        return_str = name_array[i]
                        break
                        
        return return_str

    def get_front_back(self, inStr):
        """
        문자열에서 앞/뒤 부분 추출
        
        Args:
            inStr: 처리할 문자열
            
        Returns:
            앞/뒤 부분 문자열
        """
        fil_char = self._get_filtering_char(inStr)
        name_array = self._split_to_array(inStr)
        return_str = ""
        
        front_back_index = self.get_front_back_part_index()
        real_name_index = self.get_real_name_part_index()
        
        # 앞/뒤 문자열이 있는지 확인
        found = False
        for item in self._frontBackStrArray:
            if item in name_array:
                found = True
                break
                
        if found:
            if front_back_index < real_name_index:
                # 앞/뒤 부분이 실제 이름 앞에 있는 경우
                for i in range(min(front_back_index + 1, len(name_array))):
                    if self.is_front_back_char(name_array[i]):
                        return_str = name_array[i]
                        break
            else:
                # 앞/뒤 부분이 실제 이름 뒤에 있는 경우
                for i in range(len(name_array) - 1, max(len(name_array) - front_back_index - 1, -1), -1):
                    if self.is_front_back_char(name_array[i]):
                        return_str = name_array[i]
                        break
                        
        return return_str

    def get_index(self, inStr):
        """
        문자열에서 인덱스 부분 추출
        
        Args:
            inStr: 처리할 문자열
            
        Returns:
            인덱스 부분 문자열
        """
        fil_char = self._get_filtering_char(inStr)
        name_array = self._split_to_array(inStr)
        return_str = ""
        
        index_index = self.get_index_part_index()
        real_name_index = self.get_real_name_part_index()
        
        # 인덱스 문자열이 있는지 확인
        found = False
        for item in name_array:
            if self.is_index_char(item):
                found = True
                break
                
        if found:
            if index_index < real_name_index:
                # 인덱스 부분이 실제 이름 앞에 있는 경우
                for i in range(min(index_index + 1, len(name_array))):
                    if self.is_index_char(name_array[i]):
                        return_str = name_array[i]
                        break
            else:
                # 인덱스 부분이 실제 이름 뒤에 있는 경우
                for i in range(len(name_array) - 1, max(len(name_array) - index_index - 1, -1), -1):
                    if self.is_index_char(name_array[i]):
                        return_str = name_array[i]
                        break
                        
        return return_str

    def get_real_name(self, inStr):
        """
        문자열에서 실제 이름 부분 추출
        
        Args:
            inStr: 처리할 문자열
            
        Returns:
            실제 이름 부분 문자열
        """
        fil_char = self._get_filtering_char(inStr)
        name_array = self._split_to_array(inStr)
        real_name_array = []
        
        # 실제 이름을 제외한 부분 추출
        base_str = self.get_base(inStr)
        type_str = self.get_type(inStr)
        side_str = self.get_side(inStr)
        front_back_str = self.get_front_back(inStr)
        index_str = self.get_index(inStr)
        
        # 실제 이름을 제외한 부분들 목록
        non_real_name_array = [base_str, type_str, side_str, front_back_str, index_str]
        
        # 실제 이름 부분 추출 (비어있지 않은 부분 필터링)
        non_real_name_array = [item for item in non_real_name_array if item]
        
        # 이름 배열에서 실제 이름이 아닌 부분 제외
        for item in name_array:
            if item not in non_real_name_array:
                real_name_array.append(item)
                
        # 구분자로 결합
        return self._combine(real_name_array, fil_char)

    def convert_name_to_name_array(self, inStr):
        """
        문자열 이름을 이름 부분 배열로 변환
        
        Args:
            inStr: 변환할 이름 문자열
            
        Returns:
            이름 부분 배열 (Base, Type, Side, FrontBack, RealName, Index 등)
        """
        return_array = [""] * len(self._nameParts)
        fil_char = self._get_filtering_char(inStr)
        
        base_index = self.get_base_part_index()
        type_index = self.get_type_part_index()
        side_index = self.get_side_part_index()
        front_back_index = self.get_front_back_part_index()
        index_index = self.get_index_part_index()
        real_name_index = self.get_real_name_part_index()
        
        base_str = self.get_base(inStr)
        type_str = self.get_type(inStr)
        side_str = self.get_side(inStr)
        front_back_str = self.get_front_back(inStr)
        index_str = self.get_index(inStr)
        real_name_str = self.get_real_name(inStr)
        
        return_array[base_index] = base_str
        return_array[type_index] = type_str
        return_array[side_index] = side_str
        return_array[front_back_index] = front_back_str
        return_array[real_name_index] = real_name_str
        return_array[index_index] = index_str
        
        return return_array

    def is_nub(self, inStr):
        """
        이름의 인덱스 부분이 넙(Nub)인지 확인
        
        Args:
            inStr: 확인할 이름 문자열
            
        Returns:
            넙이면 True, 아니면 False
        """
        return self.get_index(inStr) == self._nubStr

    def get_index_as_digit(self, inStr):
        """
        이름의 인덱스를 숫자로 변환
        
        Args:
            inStr: 변환할 이름 문자열
            
        Returns:
            숫자로 변환된 인덱스 (넙이면 -1, 인덱스가 없으면 False)
        """
        index_str = self.get_index(inStr)
        
        if index_str == self._nubStr:
            return -1
            
        if index_str:
            try:
                return int(index_str)
            except ValueError:
                pass
                
        return False

    def get_string(self, inStr):
        """
        인덱스 부분을 제외한 이름 문자열 가져오기
        
        Args:
            inStr: 처리할 이름 문자열
            
        Returns:
            인덱스가 제외된 이름 문자열
        """
        fil_char = self._get_filtering_char(inStr)
        name_array = self.convert_name_to_name_array(inStr)
        index_order = self.get_index_part_index()
        
        # 인덱스 부분 제거
        return_name_array = name_array.copy()
        return_name_array[index_order] = ""
        
        return self._combine(return_name_array, fil_char)

    def set_index_as_nub(self, inStr):
        """
        이름의 인덱스를 넙(Nub)으로 설정
        
        Args:
            inStr: 처리할 이름 문자열
            
        Returns:
            인덱스가 넙으로 변경된 이름 문자열
        """
        fil_char = self._get_filtering_char(inStr)
        name_array = self.convert_name_to_name_array(inStr)
        index_order = self.get_index_part_index()
        
        name_array[index_order] = self._nubStr
        return self._combine(name_array, fil_char)

    def is_left(self, inStr):
        """
        이름이 왼쪽(L) 측면인지 확인
        
        Args:
            inStr: 확인할 이름 문자열
            
        Returns:
            왼쪽이면 True, 아니면 False
        """
        side_char = self.get_side(inStr)
        return side_char and side_char == self.get_left_str()

    def is_right(self, inStr):
        """
        이름이 오른쪽(R) 측면인지 확인
        
        Args:
            inStr: 확인할 이름 문자열
            
        Returns:
            오른쪽이면 True, 아니면 False
        """
        side_char = self.get_side(inStr)
        return side_char and side_char == self.get_right_str()

    def is_front(self, inStr):
        """
        이름이 앞쪽(F)인지 확인
        
        Args:
            inStr: 확인할 이름 문자열
            
        Returns:
            앞쪽이면 True, 아니면 False
        """
        front_back_char = self.get_front_back(inStr)
        return front_back_char and front_back_char == self.get_front_str()

    def is_back(self, inStr):
        """
        이름이 뒤쪽(B)인지 확인
        
        Args:
            inStr: 확인할 이름 문자열
            
        Returns:
            뒤쪽이면 True, 아니면 False
        """
        front_back_char = self.get_front_back(inStr)
        return front_back_char and front_back_char == self.get_back_str()

    def has_side(self, inStr):
        """
        이름에 측면(L/R) 정보가 있는지 확인
        
        Args:
            inStr: 확인할 이름 문자열
            
        Returns:
            측면 정보가 있으면 True, 아니면 False
        """
        return self.is_left(inStr) or self.is_right(inStr)

    def has_front_back(self, inStr):
        """
        이름에 앞/뒤(F/B) 정보가 있는지 확인
        
        Args:
            inStr: 확인할 이름 문자열
            
        Returns:
            앞/뒤 정보가 있으면 True, 아니면 False
        """
        return self.is_front(inStr) or self.is_back(inStr)

    def get_non_real_name(self, inStr):
        """
        실제 이름 부분을 제외한 이름 가져오기
        
        Args:
            inStr: 처리할 이름 문자열
            
        Returns:
            실제 이름이 제외된 이름 문자열
        """
        fil_char = self._get_filtering_char(inStr)
        name_array = self.convert_name_to_name_array(inStr)
        real_name_index = self.get_real_name_part_index()
        
        name_array[real_name_index] = ""
        return self._combine(name_array, fil_char)

    def combine(self, inBase="", inType="", inSide="", inFrontBack="", inRealName="", inIndex="", inFilChar=" "):
        """
        이름 부분들을 조합하여 완전한 이름 생성
        
        Args:
            inBase: 기본 부분 (기본값: "")
            inType: 유형 부분 (기본값: "")
            inSide: 측면 부분 (기본값: "")
            inFrontBack: 앞/뒤 부분 (기본값: "")
            inRealName: 실제 이름 부분 (기본값: "")
            inIndex: 인덱스 부분 (기본값: "")
            inFilChar: 구분자 문자 (기본값: " ")
            
        Returns:
            조합된 이름 문자열
        """
        base_index = self.get_base_part_index()
        type_index = self.get_type_part_index()
        side_index = self.get_side_part_index()
        front_back_index = self.get_front_back_part_index()
        real_name_index = self.get_real_name_part_index()
        index_index = self.get_index_part_index()
        
        parts_index_array = [base_index, type_index, side_index, front_back_index, real_name_index, index_index]
        parts_array = [inBase, inType, inSide, inFrontBack, inRealName, inIndex]
        
        combined_name_array = [""] * len(self._nameParts)
        
        for i in range(len(parts_index_array)):
            if parts_index_array[i] >= 0:
                combined_name_array[parts_index_array[i]] = parts_array[i]
                
        return self._combine(combined_name_array, inFilChar)

    def add_fix(self, inStr, inPart, inFix, pos="prefix"):
        """
        이름의 특정 부분에 접두사 또는 접미사 추가
        
        Args:
            inStr: 처리할 이름 문자열
            inPart: 수정할 부분 ("Base", "Type", "Side", "FrontBack", "RealName", "Index")
            inFix: 추가할 접두사/접미사
            pos: 위치 ("prefix" 또는 "suffix")
            
        Returns:
            수정된 이름 문자열
        """
        return_str = inStr
        
        if inFix:
            fil_char = self._get_filtering_char(inStr)
            name_array = self.convert_name_to_name_array(inStr)
            part_index = -1
            
            if inPart == "Base":
                part_index = self.get_base_part_index()
            elif inPart == "Type":
                part_index = self.get_type_part_index()
            elif inPart == "Side":
                part_index = self.get_side_part_index()
            elif inPart == "FrontBack":
                part_index = self.get_front_back_part_index()
            elif inPart == "RealName":
                part_index = self.get_real_name_part_index()
            elif inPart == "Index":
                part_index = self.get_index_part_index()
                
            if part_index >= 0:
                if pos == "prefix":
                    name_array[part_index] = inFix + name_array[part_index]
                elif pos == "suffix":
                    name_array[part_index] = name_array[part_index] + inFix
                    
                return_str = self._combine(name_array, fil_char)
                
        return return_str

    def add_prefix_to_real_name(self, inStr, inPrefix):
        """
        실제 이름 부분에 접두사 추가
        
        Args:
            inStr: 처리할 이름 문자열
            inPrefix: 추가할 접두사
            
        Returns:
            수정된 이름 문자열
        """
        return self.add_fix(inStr, "RealName", inPrefix, "prefix")

    def add_suffix_to_real_name(self, inStr, inSuffix):
        """
        실제 이름 부분에 접미사 추가
        
        Args:
            inStr: 처리할 이름 문자열
            inSuffix: 추가할 접미사
            
        Returns:
            수정된 이름 문자열
        """
        return self.add_fix(inStr, "RealName", inSuffix, "suffix")

    def convert_digit_into_padding_string(self, inDigit, inPaddingNum=None):
        """
        숫자를 패딩된 문자열로 변환
        
        Args:
            inDigit: 변환할 숫자 또는 숫자 문자열
            inPaddingNum: 패딩 자릿수 (기본값: 클래스의 _paddingNum)
            
        Returns:
            패딩된 문자열
        """
        if inPaddingNum is None:
            inPaddingNum = self._paddingNum
            
        digit_num = 0
        
        if isinstance(inDigit, int):
            digit_num = inDigit
        elif isinstance(inDigit, str):
            if self._is_digit(inDigit):
                digit_num = int(inDigit)
                
        # Python의 문자열 포맷팅을 사용하여 패딩
        return f"{digit_num:0{inPaddingNum}d}"

    def set_index_padding_num(self, inStr, inPaddingNum=None):
        """
        이름의 인덱스 부분 패딩 설정
        
        Args:
            inStr: 처리할 이름 문자열
            inPaddingNum: 설정할 패딩 자릿수 (기본값: 클래스의 _paddingNum)
            
        Returns:
            패딩이 적용된 이름 문자열
        """
        if inPaddingNum is None:
            inPaddingNum = self._paddingNum
            
        fil_char = self._get_filtering_char(inStr)
        name_array = self.convert_name_to_name_array(inStr)
        index_index = self.get_index_part_index()
        index_str = self.get_index(inStr)
        
        if index_str and index_str != self._nubStr:
            index_str = self.convert_digit_into_padding_string(index_str, inPaddingNum)
            name_array[index_index] = index_str
            
        return self._combine(name_array, fil_char)

    def get_index_padding_num(self, inStr):
        """
        이름의 인덱스 부분 패딩 자릿수 가져오기
        
        Args:
            inStr: 처리할 이름 문자열
            
        Returns:
            인덱스 패딩 자릿수
        """
        index = self.get_index(inStr)
        
        if index != self._nubStr and index:
            return len(index)
            
        return 1

    def increase_index(self, inStr, inAmount):
        """
        이름의 인덱스 부분 값 증가
        
        Args:
            inStr: 처리할 이름 문자열
            inAmount: 증가시킬 값
            
        Returns:
            인덱스가 증가된 이름 문자열
        """
        new_name = inStr
        fil_char = self._get_filtering_char(inStr)
        name_array = self.convert_name_to_name_array(inStr)
        index_index = self.get_index_part_index()
        
        if index_index >= 0:
            index_str = ""
            index_padding_num = self._paddingNum
            index_num = -9999
            
            if not name_array[index_index]:
                index_num = -1
            elif name_array[index_index] == self._nubStr:
                index_num = -9999999
            else:
                try:
                    index_num = int(name_array[index_index])
                    index_padding_num = len(name_array[index_index])
                except ValueError:
                    pass
            
            index_num += inAmount
            
            if index_num > -1:
                # Python의 문자열 포맷팅을 사용하여 패딩
                index_str = f"{index_num:0{index_padding_num}d}"
            else:
                index_str = self._nubStr
                
            name_array[index_index] = index_str
            new_name = self._combine(name_array, fil_char)
            
        return new_name

    def replace_filtering_char(self, inStr, inNewFilChar):
        """
        이름의 구분자 문자 변경
        
        Args:
            inStr: 처리할 이름 문자열
            inNewFilChar: 새 구분자 문자
            
        Returns:
            구분자가 변경된 이름 문자열
        """
        name_array = self.convert_name_to_name_array(inStr)
        return self._combine(name_array, inNewFilChar)

    def replace_base(self, inStr, inNewBase):
        """
        이름의 기본 부분 교체
        
        Args:
            inStr: 처리할 이름 문자열
            inNewBase: 새 기본 부분
            
        Returns:
            기본 부분이 교체된 이름 문자열
        """
        return_val = inStr
        fil_char = self._get_filtering_char(inStr)
        name_array = self.convert_name_to_name_array(inStr)
        base_index = self.get_base_part_index()
        
        if base_index >= 0:
            name_array[base_index] = inNewBase
            return_val = self._combine(name_array, fil_char)
            
        return return_val

    def replace_type(self, inStr, inNewType):
        """
        이름의 유형 부분 교체
        
        Args:
            inStr: 처리할 이름 문자열
            inNewType: 새 유형 부분
            
        Returns:
            유형 부분이 교체된 이름 문자열
        """
        return_val = inStr
        fil_char = self._get_filtering_char(inStr)
        name_array = self.convert_name_to_name_array(inStr)
        type_index = self.get_type_part_index()
        
        if type_index >= 0:
            name_array[type_index] = inNewType
            return_val = self._combine(name_array, fil_char)
            
        return return_val

    def replace_side(self, inStr, inNewSide):
        """
        이름의 측면 부분 교체
        
        Args:
            inStr: 처리할 이름 문자열
            inNewSide: 새 측면 부분
            
        Returns:
            측면 부분이 교체된 이름 문자열
        """
        return_val = inStr
        fil_char = self._get_filtering_char(inStr)
        name_array = self.convert_name_to_name_array(inStr)
        side_index = self.get_side_part_index()
        
        if side_index >= 0:
            name_array[side_index] = inNewSide
            return_val = self._combine(name_array, fil_char)
            
        return return_val

    def replace_front_back(self, inStr, inNewFrontBack):
        """
        이름의 앞/뒤 부분 교체
        
        Args:
            inStr: 처리할 이름 문자열
            inNewFrontBack: 새 앞/뒤 부분
            
        Returns:
            앞/뒤 부분이 교체된 이름 문자열
        """
        return_val = inStr
        fil_char = self._get_filtering_char(inStr)
        name_array = self.convert_name_to_name_array(inStr)
        front_back_index = self.get_front_back_part_index()
        
        if front_back_index >= 0:
            name_array[front_back_index] = inNewFrontBack
            return_val = self._combine(name_array, fil_char)
            
        return return_val

    def replace_index(self, inStr, inNewIndex, keepPadding=True):
        """
        이름의 인덱스 부분 교체
        
        Args:
            inStr: 처리할 이름 문자열
            inNewIndex: 새 인덱스 부분
            keepPadding: 패딩 유지 여부 (기본값: True)
            
        Returns:
            인덱스 부분이 교체된 이름 문자열
        """
        return_val = inStr
        fil_char = self._get_filtering_char(inStr)
        name_array = self.convert_name_to_name_array(inStr)
        index_index = self.get_index_part_index()
        
        if index_index >= 0:
            name_array[index_index] = inNewIndex
            return_val = self._combine(name_array, fil_char)
            
            if keepPadding:
                index_padding_num = self.get_index_padding_num(inStr)
                return_val = self.set_index_padding_num(return_val, index_padding_num)
                
        return return_val

    def replace_real_name(self, inStr, inNewRealName):
        """
        이름의 실제 이름 부분 교체
        
        Args:
            inStr: 처리할 이름 문자열
            inNewRealName: 새 실제 이름 부분
            
        Returns:
            실제 이름 부분이 교체된 이름 문자열
        """
        return_val = inStr
        fil_char = self._get_filtering_char(inStr)
        name_array = self.convert_name_to_name_array(inStr)
        real_name_index = self.get_real_name_part_index()
        
        if real_name_index >= 0:
            name_array[real_name_index] = inNewRealName
            return_val = self._combine(name_array, fil_char)
            
        return return_val

    def remove_type(self, inStr):
        """
        이름에서 유형 부분 제거
        
        Args:
            inStr: 처리할 이름 문자열
            
        Returns:
            유형 부분이 제거된 이름 문자열
        """
        return self.replace_type(inStr, "")

    def remove_side(self, inStr):
        """
        이름에서 측면 부분 제거
        
        Args:
            inStr: 처리할 이름 문자열
            
        Returns:
            측면 부분이 제거된 이름 문자열
        """
        return self.replace_side(inStr, "")

    def remove_index(self, inStr):
        """
        이름에서 인덱스 부분 제거
        
        Args:
            inStr: 처리할 이름 문자열
            
        Returns:
            인덱스 부분이 제거된 이름 문자열
        """
        return self.replace_index(inStr, "")

    def remove_base(self, inStr):
        """
        이름에서 기본 부분 제거
        
        Args:
            inStr: 처리할 이름 문자열
            
        Returns:
            기본 부분이 제거된 이름 문자열
        """
        return self.replace_base(inStr, "")

    def gen_unique_name(self, inStr):
        """
        고유한 이름 생성
        
        Args:
            inStr: 기준 이름 문자열
            
        Returns:
            고유한 이름 문자열
        """
        pattern_str = self.replace_index(inStr, "*")
        
        # pymxs를 사용하여 객체 이름을 패턴과 매칭하여 검색
        matched_objects = []
        
        # 모든 객체 중에서 패턴과 일치하는 이름 찾기
        for obj in rt.objects:
            if rt.matchPattern(obj.name, pattern=pattern_str):
                matched_objects.append(obj)
                
        return self.replace_index(inStr, str(len(matched_objects) + 1))

    def gen_mirroring_name(self, inStr, axis=1):
        """
        미러링된 이름 생성 (측면 또는 앞/뒤 변경)
        
        Args:
            inStr: 처리할 이름 문자열
            axis: 축 (1: 측면 변경, 2: 앞/뒤 변경)
            
        Returns:
            미러링된 이름 문자열
        """
        return_name = inStr
        
        if self.has_side(inStr) and axis == 1:
            if self.is_left(inStr):
                return_name = self.replace_side(inStr, self.get_right_str())
            elif self.is_right(inStr):
                return_name = self.replace_side(inStr, self.get_left_str())
                
        if self.has_front_back(inStr) and axis == 2:
            if self.is_front(inStr):
                return_name = self.replace_front_back(inStr, self.get_back_str())
            elif self.is_back(inStr):
                return_name = self.replace_front_back(inStr, self.get_front_str())
                
        # 이름이 변경되지 않았다면 고유한 이름 생성
        if return_name == inStr:
            return_name = self.gen_unique_name(inStr)
            
        return return_name

    def sort_by_index(self, inNameArray):
        """
        이름 배열을 인덱스 기준으로 정렬
        
        Args:
            inNameArray: 정렬할 이름 배열
            
        Returns:
            인덱스 기준으로 정렬된 이름 배열
        """
        if not inNameArray:
            return []
            
        # 정렬을 위한 보조 클래스 정의
        class IndexSorting:
            def __init__(self, ori_index, new_index):
                self.ori_index = ori_index
                self.new_index = new_index
                
        # 각 이름의 인덱스를 추출하여 정렬 정보 생성
        struct_array = []
        
        for i, name in enumerate(inNameArray):
            temp_index = self.get_index_as_digit(name)
            
            if temp_index is False:
                struct_array.append(IndexSorting(i, 0))
            else:
                struct_array.append(IndexSorting(i, temp_index))
                
        # 인덱스 기준으로 정렬
        struct_array.sort(key=lambda x: x.new_index)
        
        # 정렬된 순서로 결과 배열 생성
        sorted_name_array = []
        for struct in struct_array:
            sorted_name_array.append(inNameArray[struct.ori_index])
            
        return sorted_name_array

    def compare_name(self, inObjA, inObjB):
        """
        두 객체의 이름 비교 (정렬용)
        
        Args:
            inObjA: 첫 번째 객체
            inObjB: 두 번째 객체
            
        Returns:
            비교 결과 (inObjA.name < inObjB.name: 음수, inObjA.name == inObjB.name: 0, inObjA.name > inObjB.name: 양수)
        """
        # Python에서는 대소문자 구분 없는 비교를 위해 lower() 사용
        return 1 if inObjA.name.lower() > inObjB.name.lower() else -1 if inObjA.name.lower() < inObjB.name.lower() else 0

    def sort_by_name(self, inArray):
        """
        객체 배열을 이름 기준으로 정렬
        
        Args:
            inArray: 정렬할 객체 배열
            
        Returns:
            이름 기준으로 정렬된 객체 배열
        """
        # Python의 sorted 함수와 key를 사용하여 이름 기준 정렬
        return sorted(inArray, key=lambda obj: obj.name.lower())

    def get_ini_file(self):
        """
        INI 파일 경로 가져오기
        
        Returns:
            INI 파일 경로
        """
        return self._iniFile

    def load_setting_from_ini(self):
        """
        INI 파일에서 설정 로드
        """
        # 현재 스크립트 경로 기준으로 INI 파일 경로 설정
        script_dir = os.path.dirname(os.path.abspath(__file__))
        self._iniFile = os.path.join(os.path.dirname(script_dir), "NameTool.ini")
        
        # INI 파일이 존재하는지 확인
        if not os.path.exists(self._iniFile):
            return
            
        # INI 파일에서 설정 읽기
        try:
            with open(self._iniFile, 'r') as ini_file:
                lines = ini_file.readlines()
                
            # 기본 설정 섹션 찾기
            section = ""
            settings = {}
            
            for line in lines:
                line = line.strip()
                
                if line.startswith('[') and line.endswith(']'):
                    section = line[1:-1]
                    if section not in settings:
                        settings[section] = {}
                elif '=' in line and section:
                    key, value = line.split('=', 1)
                    settings[section][key.strip()] = value.strip()
            
            # 설정 적용
            if 'DefaultSetting' in settings:
                if 'NubStr' in settings['DefaultSetting']:
                    self.set_nub_str(settings['DefaultSetting']['NubStr'])
                    
                if 'NamePartsOrder' in settings['DefaultSetting']:
                    name_parts_order = settings['DefaultSetting']['NamePartsOrder'].split()
                    self.set_name_parts_order(name_parts_order)
                    
                if 'PaddingNum' in settings['DefaultSetting']:
                    try:
                        padding_num = int(settings['DefaultSetting']['PaddingNum'])
                        self.set_padding_num(padding_num)
                    except ValueError:
                        pass
            
            # 측면 설정 적용
            if 'Side' in settings:
                if 'SideStrArray' in settings['Side']:
                    side_str_array = settings['Side']['SideStrArray'].split()
                    if len(side_str_array) >= 2:
                        self.set_left_str(side_str_array[0])
                        self.set_right_str(side_str_array[1])
                        
                if 'FrontBackStrArray' in settings['Side']:
                    front_back_str_array = settings['Side']['FrontBackStrArray'].split()
                    if len(front_back_str_array) >= 2:
                        self.set_front_str(front_back_str_array[0])
                        self.set_back_str(front_back_str_array[1])
            
            # 타입 설정 적용
            if 'Type' in settings:
                type_str_array = []
                
                if 'Parent' in settings['Type']:
                    self.set_parent_str(settings['Type']['Parent'])
                    type_str_array.append(settings['Type']['Parent'])
                    
                if 'Dummy' in settings['Type']:
                    self.set_dummy_str(settings['Type']['Dummy'])
                    type_str_array.append(settings['Type']['Dummy'])
                    
                if 'ExposeTM' in settings['Type']:
                    self.set_expose_tm_str(settings['Type']['ExposeTM'])
                    type_str_array.append(settings['Type']['ExposeTM'])
                    
                if 'Target' in settings['Type']:
                    self.set_target_str(settings['Type']['Target'])
                    type_str_array.append(settings['Type']['Target'])
                    
                if 'IK' in settings['Type']:
                    self.set_ik_str(settings['Type']['IK'])
                    type_str_array.append(settings['Type']['IK'])
                    
                if type_str_array:
                    self.set_type_str(type_str_array)
            
            # 베이스 설정 적용
            if 'Base' in settings:
                base_str_array = list(settings['Base'].values())
                if base_str_array:
                    self.set_base_str(base_str_array)
                    
        except Exception as e:
            print(f"INI 파일 로드 중 오류 발생: {e}")
