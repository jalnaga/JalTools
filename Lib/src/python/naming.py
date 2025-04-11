#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
네이밍 모듈
"""

import re
import os
import json

# 모듈 임포트
try:
    from . import namingConfig
    from .namePart import NamePart
except ImportError:
    # 직접 실행할 때는 상대 경로 임포트가 작동하지 않음
    import namingConfig
    import namePart
    from namePart import NamePart


class Naming:
    """
    3ds Max 노드 이름을 관리하기 위한 클래스.
    MAXScript의 _Name 구조체와 _String 구조체를 통합하여 Python으로 재구현.
    namingConfig.py와 연동하여 JSON 설정 파일을 통한 설정 관리 지원.
    """
    
    def __init__(self, configPath=None):
        """
        클래스 초기화 및 기본 설정값 정의
        
        Args:
            configPath: 설정 파일 경로 (기본값: None)
                        설정 파일이 제공되면 해당 파일에서 설정을 로드함
        """
        # 기본 설정값
        self._paddingNum = 2
        self._configPath = configPath
        
        # 기본 namePart 초기화 (각 부분에 사전 정의 값 직접 설정)
        self._nameParts = []
        
        # Base 부분 - "b"는 기본값으로 더 높은 가중치 부여
        base_part = NamePart("Base", ["b", "Bip001"], {"b": 10, "Bip001": 5})
        
        # Type 부분 - 각 유형에 가중치 부여
        type_part = NamePart("Type", ["P", "Dum", "Exp", "IK", "T"], 
                          {"P": 10, "Dum": 8, "Exp": 6, "IK": 4, "T": 2})
        
        # Side 부분 - 의미론적 매핑 및 가중치
        side_part = NamePart("Side", ["L", "R"], {"L": "left", "R": "right", "L": 10, "R": 5})
        
        # FrontBack 부분 - 의미론적 매핑 및 가중치
        front_back_part = NamePart("FrontBack", ["F", "B"], {"F": "front", "B": "back", "F": 10, "B": 5})
        
        real_name_part = NamePart("RealName")
        index_part = NamePart("Index")
        nub_part = NamePart("Nub", ["Nub"], {"Nub": 10})
        
        # 기본 순서대로 설정
        self._nameParts = [base_part, type_part, side_part, front_back_part, real_name_part, index_part, nub_part]
        
        # 설정 파일이 제공된 경우 로드
        if configPath:
            self.load_from_config_file(configPath)
        else:
            # 기본 JSON 설정 파일 로드 시도
            self.load_default_config()

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

    # ---- Name 관련 메서드들 ----
    
    # 사전 정의 값 편집 메서드 제거 (namingConfig를 통해서만 변경 가능)

    def get_padding_num(self):
        """
        패딩 숫자 가져오기
        
        Returns:
            패딩 숫자
        """
        return self._paddingNum

    def get_name_part(self, namePart):
        """
        namePart 이름으로 NamePart 객체 가져오기
        
        Args:
            namePart: 가져올 NamePart의 이름 ("Base", "Type", "Side" 등)
            
        Returns:
            해당 NamePart 객체, 존재하지 않으면 None
        """
        for part in self._nameParts:
            if part.get_name() == namePart:
                return part
        return None
        
    def get_name_part_index(self, namePart):
        """
        namePart 이름으로 인덱스 가져오기
        
        Args:
            namePart: 가져올 NamePart의 이름 ("Base", "Type", "Side" 등)
            
        Returns:
            해당 NamePart의 인덱스, 존재하지 않으면 -1
        """
        for i, part in enumerate(self._nameParts):
            if part.get_name() == namePart:
                return i
        return -1
    
    def get_nub_str(self):
        """
        넙 문자열 가져오기
        
        Returns:
            넙 문자열
        """
        nub_part = self.get_name_part("Nub")
        if nub_part:
            values = nub_part.get_predefined_values()
            if values and len(values) > 0:
                return values[0]
        return ""

    def get_left_str(self):
        """
        왼쪽 구분자 가져오기
        
        Returns:
            왼쪽 구분자
        """
        side_part = self.get_name_part("Side")
        if side_part:
            return side_part.get_value_by_semantic("left")
        return ""

    def get_right_str(self):
        """
        오른쪽 구분자 가져오기
        
        Returns:
            오른쪽 구분자
        """
        side_part = self.get_name_part("Side")
        if side_part:
            return side_part.get_value_by_semantic("right")
        return ""

    def get_front_str(self):
        """
        앞 구분자 가져오기
        
        Returns:
            앞 구분자
        """
        front_back_part = self.get_name_part("FrontBack")
        if front_back_part:
            return front_back_part.get_value_by_semantic("front")
        return ""

    def get_back_str(self):
        """
        뒤 구분자 가져오기
        
        Returns:
            뒤 구분자
        """
        front_back_part = self.get_name_part("FrontBack")
        if front_back_part:
            return front_back_part.get_value_by_semantic("back")
        return ""

    def get_base_part_index(self):
        """
        기본 부분 인덱스 가져오기
        
        Returns:
            기본 부분 인덱스
        """
        return self.get_name_part_index("Base")

    def get_type_part_index(self):
        """
        유형 부분 인덱스 가져오기
        
        Returns:
            유형 부분 인덱스
        """
        return self.get_name_part_index("Type")

    def get_side_part_index(self):
        """
        측면 부분 인덱스 가져오기
        
        Returns:
            측면 부분 인덱스
        """
        return self.get_name_part_index("Side")

    def get_front_back_part_index(self):
        """
        앞/뒤 부분 인덱스 가져오기
        
        Returns:
            앞/뒤 부분 인덱스
        """
        return self.get_name_part_index("FrontBack")

    def get_real_name_part_index(self):
        """
        실제 이름 부분 인덱스 가져오기
        
        Returns:
            실제 이름 부분 인덱스
        """
        return self.get_name_part_index("RealName")

    def get_index_part_index(self):
        """
        인덱스 부분 인덱스 가져오기
        
        Returns:
            인덱스 부분 인덱스
        """
        return self.get_name_part_index("Index")
    
    def get_nub_part_index(self):
        """
        넙(Nub) 부분 인덱스 가져오기
        
        Returns:
            넙 부분 인덱스
        """
        return self.get_name_part_index("Nub")

    def is_side_char(self, inChar):
        """
        문자가 측면 문자인지 확인
        
        Args:
            inChar: 확인할 문자
            
        Returns:
            측면 문자이면 True, 아니면 False
        """
        side_part = self.get_name_part("Side")
        if side_part:
            return inChar in side_part.get_predefined_values()
        return False

    def is_front_back_char(self, inChar):
        """
        문자가 앞/뒤 문자인지 확인
        
        Args:
            inChar: 확인할 문자
            
        Returns:
            앞/뒤 문자이면 True, 아니면 False
        """
        front_back_part = self.get_name_part("FrontBack")
        if front_back_part:
            return inChar in front_back_part.get_predefined_values()
        return False

    def is_type_char(self, inChar):
        """
        문자가 유형 문자인지 확인
        
        Args:
            inChar: 확인할 문자
            
        Returns:
            유형 문자이면 True, 아니면 False
        """
        type_part = self.get_name_part("Type")
        if type_part:
            return inChar in type_part.get_predefined_values()
        return False

    def is_base_char(self, inChar):
        """
        문자가 기본 문자인지 확인
        
        Args:
            inChar: 확인할 문자
            
        Returns:
            기본 문자이면 True, 아니면 False
        """
        base_part = self.get_name_part("Base")
        if base_part:
            return inChar in base_part.get_predefined_values()
        return False

    def is_index_char(self, inChar):
        """
        문자가 인덱스 문자인지 확인
        
        Args:
            inChar: 확인할 문자
            
        Returns:
            인덱스 문자이면 True, 아니면 False
        """
        return self._is_digit(inChar)
        
    def is_nub_char(self, inChar):
        """
        문자가 넙 문자인지 확인
        
        Args:
            inChar: 확인할 문자
            
        Returns:
            넙 문자이면 True, 아니면 False
        """
        nub_part = self.get_name_part("Nub")
        if nub_part:
            return inChar in nub_part.get_predefined_values()
        return False

    def get_char_type(self, inChar):
        """
        문자의 유형 가져오기
        
        Args:
            inChar: 확인할 문자
            
        Returns:
            문자 유형 ("Index", "Nub", "Side", "FrontBack", "Type", "Base" 중 하나)
        """
        # 인덱스 문자는 특별하게 처리 (숫자 여부 확인)
        if self.is_index_char(inChar):
            return "Index"
            
        # _nameParts에서 문자 유형 찾기
        for part in self._nameParts:
            part_name = part.get_name()
            if part_name != "Index" and part_name != "RealName":  # Index는 이미 처리
                if inChar in part.get_predefined_values():
                    return part_name
        
        return None

    def get_side(self, inStr):
        """
        문자열에서 측면 부분 추출
        
        Args:
            inStr: 처리할 문자열
            
        Returns:
            측면 부분 문자열
        """
        return self.get_name("Side", inStr)

    def get_base(self, inStr):
        """
        문자열에서 기본 부분 추출
        
        Args:
            inStr: 처리할 문자열
            
        Returns:
            기본 부분 문자열
        """
        return self.get_name("Base", inStr)

    def get_type(self, inStr):
        """
        문자열에서 유형 부분 추출
        
        Args:
            inStr: 처리할 문자열
            
        Returns:
            유형 부분 문자열
        """
        return self.get_name("Type", inStr)

    def get_front_back(self, inStr):
        """
        문자열에서 앞/뒤 부분 추출
        
        Args:
            inStr: 처리할 문자열
            
        Returns:
            앞/뒤 부분 문자열
        """
        return self.get_name("FrontBack", inStr)
        
    def get_name(self, namePart, inStr):
        """
        지정된 namePart에 해당하는 부분을 문자열에서 추출
        
        Args:
            namePart: 추출할 namePart 이름 ("Base", "Type", "Side" 등)
            inStr: 처리할 문자열
            
        Returns:
            지정된 namePart에 해당하는 문자열
        """
        name_array = self._split_to_array(inStr)
        return_str = ""
        
        # namePart 인덱스와 RealName 인덱스 가져오기
        part_index = self.get_name_part_index(namePart)
        real_name_index = self.get_real_name_part_index()
        
        # namePart가 유효하지 않으면 빈 문자열 반환
        if part_index < 0:
            return return_str
        
        # namePart 문자열 목록 가져오기
        part_obj = self.get_name_part(namePart)
        part_values = part_obj.get_predefined_values() if part_obj else []
                
        # namePart 문자열이 있는지 확인
        found = False
        for item in name_array:
            if item in part_values:
                found = True
                break
                
        if found:
            if part_index < real_name_index:
                # namePart가 실제 이름 앞에 있는 경우 - 앞에서부터 검색
                for i in range(len(name_array)):
                    if name_array[i] in part_values:
                        return_str = name_array[i]
                        break
            else:
                # namePart가 실제 이름 뒤에 있는 경우 - 뒤에서부터 검색
                for i in range(len(name_array) - 1, -1, -1):
                    if name_array[i] in part_values:
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
        return self.get_name("Index", inStr)

    def get_nub(self, inStr):
        """
        문자열에서 넙 부분 추출
        
        Args:
            inStr: 처리할 문자열
            
        Returns:
            넙 부분 문자열
        """
        return self.get_name("Nub", inStr)

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
        
        # 모든 nameParts 중 RealName이 아닌 것들의 값을 수집
        non_real_name_array = []
        for part in self._nameParts:
            partName = part.get_name()
            if partName != "RealName":
                foundName = self.get_name(partName, inStr)
                non_real_name_array.append(foundName)
        
        # 이름 배열에서 실제 이름이 아닌 부분 제외
        for item in name_array:
            if item not in non_real_name_array:
                real_name_array.append(item)
                
        # 구분자로 결합
        return self._combine(real_name_array, fil_char)

    def convert_name_to_array(self, inStr):
        """
        문자열 이름을 이름 부분 배열로 변환
        
        Args:
            inStr: 변환할 이름 문자열
            
        Returns:
            이름 부분 배열 (Base, Type, Side, FrontBack, RealName, Index, Nub 등)
        """
        return_array = [""] * len(self._nameParts)
        
        # 각 namePart에 대해 처리
        for i, part in enumerate(self._nameParts):
            part_name = part.get_name()
            
            # 특수 케이스인 RealName은 마지막에 처리하기 위해 저장
            if part_name == "RealName":
                real_name_index = i
                continue
                
            # get_name 메소드를 사용하여 해당 부분 추출
            part_value = self.get_name(part_name, inStr)
            return_array[i] = part_value
        
        # 마지막으로 RealName 처리 (다른 모든 부분을 찾은 후에 수행해야 함)
        if 'real_name_index' in locals():
            real_name_str = self.get_real_name(inStr)
            return_array[real_name_index] = real_name_str
        
        return return_array
        
    def convert_to_dictionary(self, inStr):
        """
        문자열 이름을 이름 부분 딕셔너리로 변환
        
        Args:
            inStr: 변환할 이름 문자열
            
        Returns:
            이름 부분 딕셔너리 (키: namePart 이름, 값: 추출된 값)
            예: {"Base": "b", "Type": "P", "Side": "L", "RealName": "Arm", ...}
        """
        return_dict = {}
        
        # 각 namePart에 대해 처리
        for part in self._nameParts:
            part_name = part.get_name()
            
            # 특수 케이스인 RealName은 마지막에 처리하기 위해 저장
            if part_name == "RealName":
                continue
                
            # get_name 메소드를 사용하여 해당 부분 추출
            part_value = self.get_name(part_name, inStr)
            return_dict[part_name] = part_value
        
        # 마지막으로 RealName 처리 (다른 모든 부분을 찾은 후에 수행해야 함)
        real_name_str = self.get_real_name(inStr)
        return_dict["RealName"] = real_name_str
        
        return return_dict

    def is_nub(self, inStr):
        """
        이름에 넙(Nub) 부분이 있는지 확인
        
        Args:
            inStr: 확인할 이름 문자열
            
        Returns:
            넙이 있으면 True, 아니면 False
        """
        return bool(self.get_nub(inStr))

    def get_index_as_digit(self, inStr):
        """
        이름의 인덱스를 숫자로 변환
        
        Args:
            inStr: 변환할 이름 문자열
            
        Returns:
            숫자로 변환된 인덱스 (넙이 있으면 -1, 인덱스가 없으면 False)
        """
        if self.is_nub(inStr):
            return -1
            
        index_str = self.get_index(inStr)
            
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
        name_array = self.convert_name_to_array(inStr)
        index_order = self.get_index_part_index()
        
        # 인덱스 부분 제거
        return_name_array = name_array.copy()
        return_name_array[index_order] = ""
        
        return self._combine(return_name_array, fil_char)

    def set_index_as_nub(self, inStr):
        """
        이름에 넙(Nub) 부분을 추가하고 인덱스를 제거
        
        Args:
            inStr: 처리할 이름 문자열
            
        Returns:
            넙이 추가되고 인덱스가 제거된 이름 문자열
        """
        fil_char = self._get_filtering_char(inStr)
        name_array = self.convert_name_to_array(inStr)
        nub_order = self.get_nub_part_index()
        index_order = self.get_index_part_index()
        
        # 인덱스 제거하고 넙 추가
        name_array[index_order] = ""
        name_array[nub_order] = self.get_nub_str()
        
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
        name_array = self.convert_name_to_array(inStr)
        real_name_index = self.get_real_name_part_index()
        
        name_array[real_name_index] = ""
        return self._combine(name_array, fil_char)

    def combine(self, parts_dict={}, inFilChar=" "):
        """
        namingConfig에서 정의된 nameParts와 그 순서에 따라 이름 부분들을 조합하여 완전한 이름 생성
        
        Args:
            parts_dict: namePart 이름과 값의 딕셔너리 (예: {"Base": "b", "Type": "P", "Side": "L"})
            inFilChar: 구분자 문자 (기본값: " ")
            
        Returns:
            조합된 이름 문자열
        """
        # 결과 배열 초기화 (빈 문자열로)
        combined_name_array = [""] * len(self._nameParts)
        
        # 각 namePart에 대해
        for i, part in enumerate(self._nameParts):
            part_name = part.get_name()
            # 딕셔너리에서 해당 부분의 값 가져오기 (없으면 빈 문자열 사용)
            if part_name in parts_dict:
                combined_name_array[i] = parts_dict[part_name]
                
        # 배열을 문자열로 결합
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
            name_array = self.convert_name_to_array(inStr)
            part_index = self.get_name_part_index(inPart)
                
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
        name_array = self.convert_name_to_array(inStr)
        index_index = self.get_index_part_index()
        index_str = self.get_index(inStr)
        
        if index_str and not self.is_nub(inStr):
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
        
        if not self.is_nub(inStr) and index:
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
        name_array = self.convert_name_to_array(inStr)
        index_index = self.get_index_part_index()
        nub_index = self.get_nub_part_index()
        
        if index_index >= 0:
            index_str = ""
            index_padding_num = self._paddingNum
            index_num = -9999
            
            if not name_array[index_index]:
                index_num = -1
            elif self.is_nub(inStr):
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
                name_array[index_index] = index_str
                name_array[nub_index] = ""
            else:
                name_array[index_index] = ""
                name_array[nub_index] = self.get_nub_str()
                
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
        name_array = self.convert_name_to_array(inStr)
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
        name_array = self.convert_name_to_array(inStr)
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
        name_array = self.convert_name_to_array(inStr)
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
        name_array = self.convert_name_to_array(inStr)
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
        name_array = self.convert_name_to_array(inStr)
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
        name_array = self.convert_name_to_array(inStr)
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
        name_array = self.convert_name_to_array(inStr)
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

    def load_default_config(self):
        """
        기본 JSON 설정 파일 로드
        기본 파일은 현재 스크립트 디렉토리의 namingConfig.json 파일입니다.
        파일이 없는 경우 기본 설정값을 유지합니다.
        """
        try:
            # 현재 스크립트 경로 기준으로 기본 설정 파일 경로 설정
            script_dir = os.path.dirname(os.path.abspath(__file__))
            default_config_path = os.path.join(script_dir, "namingConfig.json")
            
            # 설정 파일이 존재하는지 확인
            if os.path.exists(default_config_path):
                self.load_from_config_file(default_config_path)
            else:
                # 부모 디렉토리에서 설정 파일 확인 (기존 INI 파일이 저장되는 위치)
                parent_config_path = os.path.join(os.path.dirname(script_dir), "namingConfig.json")
                if os.path.exists(parent_config_path):
                    self.load_from_config_file(parent_config_path)
                else:
                    print("기본 설정 파일을 찾을 수 없습니다. 기본 설정값을 사용합니다.")
        except Exception as e:
            print(f"기본 설정 파일 로드 중 오류 발생: {e}")
            
    def load_from_config_file(self, configPath):
        """
        JSON 설정 파일에서 설정 로드
        
        Args:
            configPath: 설정 파일 경로
            
        Returns:
            로드 성공 여부 (True/False)
        """
        try:
            config = namingConfig.NamingConfig()
            
            if config.load_config(configPath):
                config.apply_config_to_naming(self)
                self._configPath = configPath
                return True
            else:
                print(f"설정 파일 로드 실패: {configPath}")
                return False
                
        except Exception as e:
            print(f"설정 파일 로드 중 오류 발생: {e}")
            return False
    
    def save_to_config_file(self, configPath=None):
        """
        현재 설정을 JSON 설정 파일로 저장
        
        Args:
            configPath: 저장할 파일 경로 (기본값: None, 이전에 로드한 파일 경로 사용)
            
        Returns:
            저장 성공 여부 (True/False)
        """
        # 저장 경로가 지정되지 않은 경우 이전 경로 사용
        savePath = configPath or self._configPath
        
        if not savePath:
            print("저장할 설정 파일 경로가 지정되지 않았습니다.")
            return False
        
        try:
            # 현재 설정으로 NamingConfig 객체 생성
            config = namingConfig.NamingConfig()
            
            # NamePart 객체에서 데이터 추출
            namePartsArray = []
            sideStrArray = []
            frontBackStrArray = []
            typeStrArray = []
            baseStrArray = []
            
            # 의미론적 매핑 또는 가중치 정보 추출
            sideSemantics = {}
            frontBackSemantics = {}
            typeSemantics = {}
            baseSemantics = {}
            
            for part in self._nameParts:
                name = part.get_name()
                namePartsArray.append(name)
                
                if name == "Side":
                    sideStrArray = part.get_predefined_values()
                    sideSemantics = part.get_semantic_mapping()
                elif name == "FrontBack":
                    frontBackStrArray = part.get_predefined_values()
                    frontBackSemantics = part.get_semantic_mapping()
                elif name == "Type":
                    typeStrArray = part.get_predefined_values()
                    typeSemantics = part.get_semantic_mapping()
                elif name == "Base":
                    baseStrArray = part.get_predefined_values()
                    baseSemantics = part.get_semantic_mapping()
            
            # 현재 설정 반영
            config.configData["nameParts"] = namePartsArray
            config.configData["paddingNum"] = self._paddingNum
            config.configData["sideStrArray"] = sideStrArray
            config.configData["frontBackStrArray"] = frontBackStrArray
            config.configData["typeStrArray"] = typeStrArray
            config.configData["baseStrArray"] = baseStrArray
            
            # 의미론적 매핑 또는 가중치 정보 저장
            config.configData["sideSemantics"] = sideSemantics
            config.configData["frontBackSemantics"] = frontBackSemantics
            config.configData["typeSemantics"] = typeSemantics
            config.configData["baseSemantics"] = baseSemantics
            
            # 각 유형 문자열 설정
            if len(typeStrArray) > 0:
                config.configData["parentStr"] = typeStrArray[0]
            else:
                config.configData["parentStr"] = ""
                
            if len(typeStrArray) > 1:
                config.configData["dummyStr"] = typeStrArray[1]
            else:
                config.configData["dummyStr"] = ""
                
            if len(typeStrArray) > 2:
                config.configData["exposeTmStr"] = typeStrArray[2]
            else:
                config.configData["exposeTmStr"] = ""
                
            if len(typeStrArray) > 3:
                config.configData["ikStr"] = typeStrArray[3]
            else:
                config.configData["ikStr"] = ""
                
            if len(typeStrArray) > 4:
                config.configData["targetStr"] = typeStrArray[4]
            else:
                config.configData["targetStr"] = ""
            
            # 설정 저장
            save_result = config.save_config(savePath)
            
            if save_result:
                self._configPath = savePath
                
            return save_result
            
        except Exception as e:
            print(f"설정 저장 중 오류 발생: {e}")
            return False
    
    def get_config_path(self):
        """
        현재 설정 파일 경로 가져오기
        
        Returns:
            설정 파일 경로 (없으면 빈 문자열)
        """
        return self._configPath or ""
    
    def create_config_object(self):
        """
        현재 설정으로 NamingConfig 객체 생성
        
        Returns:
            NamingConfig 객체
        """
        config = namingConfig.NamingConfig()
        
        # NamePart 객체에서 데이터 추출
        namePartsArray = []
        sideStrArray = []
        frontBackStrArray = []
        typeStrArray = []
        baseStrArray = []
        
        # 의미론적 매핑 또는 가중치 정보 추출
        sideSemantics = {}
        frontBackSemantics = {}
        typeSemantics = {}
        baseSemantics = {}
        
        for part in self._nameParts:
            name = part.get_name()
            namePartsArray.append(name)
            
            if name == "Side":
                sideStrArray = part.get_predefined_values()
                sideSemantics = part.get_semantic_mapping()
            elif name == "FrontBack":
                frontBackStrArray = part.get_predefined_values()
                frontBackSemantics = part.get_semantic_mapping()
            elif name == "Type":
                typeStrArray = part.get_predefined_values()
                typeSemantics = part.get_semantic_mapping()
            elif name == "Base":
                baseStrArray = part.get_predefined_values()
                baseSemantics = part.get_semantic_mapping()
        
        # 현재 설정 반영
        config.configData["nameParts"] = namePartsArray
        config.configData["paddingNum"] = self._paddingNum
        config.configData["sideStrArray"] = sideStrArray
        config.configData["frontBackStrArray"] = frontBackStrArray
        config.configData["typeStrArray"] = typeStrArray
        config.configData["baseStrArray"] = baseStrArray
        
        # 의미론적 매핑 또는 가중치 정보 저장
        config.configData["sideSemantics"] = sideSemantics
        config.configData["frontBackSemantics"] = frontBackSemantics
        config.configData["typeSemantics"] = typeSemantics
        config.configData["baseSemantics"] = baseSemantics
        
        # 각 유형 문자열 설정
        if len(typeStrArray) > 0:
            config.configData["parentStr"] = typeStrArray[0]
        else:
            config.configData["parentStr"] = ""
            
        if len(typeStrArray) > 1:
            config.configData["dummyStr"] = typeStrArray[1]
        else:
            config.configData["dummyStr"] = ""
            
        if len(typeStrArray) > 2:
            config.configData["exposeTmStr"] = typeStrArray[2]
        else:
            config.configData["exposeTmStr"] = ""
            
        if len(typeStrArray) > 3:
            config.configData["ikStr"] = typeStrArray[3]
        else:
            config.configData["ikStr"] = ""
            
        if len(typeStrArray) > 4:
            config.configData["targetStr"] = typeStrArray[4]
        else:
            config.configData["targetStr"] = ""
        
        return config
        
    # 새로 추가된 유틸리티 메서드들
        
    def get_primary_value(self, partName):
        """
        특정 부분의 가장 중요한 값(가중치가 가장 높은 값)을 가져옵니다.
        
        Args:
            partName: 부분 이름 ("Base", "Type", "Side" 등)
            
        Returns:
            가장 중요한 값, 없으면 빈 문자열
        """
        part = self.get_name_part(partName)
        if part:
            return part.get_value_by_weight(0)
        return ""
        
    def get_sorted_values(self, partName):
        """
        특정 부분의 값을 가중치 순으로 정렬하여 가져옵니다.
        
        Args:
            partName: 부분 이름 ("Base", "Type", "Side" 등)
            
        Returns:
            가중치 순으로 정렬된 값 목록
        """
        part = self.get_name_part(partName)
        if part:
            return part.get_sorted_values_by_weight()
        return []
