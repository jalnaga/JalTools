#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
namingConfig 모듈 - Naming 클래스의 설정을 관리하는 기능 제공
JSON 파일을 통해 네이밍 설정을 저장하고 불러오는 기능 구현
"""

import json
import os
import copy
from typing import List, Dict, Any, Optional, Union


class NamingConfig:
    """
    Naming 클래스의 설정을 관리하는 클래스.
    설정을 JSON 파일로 저장하고 불러오며, namePart와 사전 문자열을 관리합니다.
    """
    
    def __init__(self):
        """클래스 초기화 및 기본 설정값 정의"""
        # 기본 설정값 정의 (프로퍼티는 카멜 케이스 사용)
        self.configData = {
            "nameParts": ["Base", "Type", "Side", "FrontBack", "RealName", "Index", "Nub"],
            "paddingNum": 2,
            "typeStrArray": ["P", "Dum", "Exp", "IK", "T"],
            "baseStrArray": ["b", "Bip001"],
            "sideStrArray": ["L", "R"],
            "frontBackStrArray": ["F", "B"],
            "nubStr": "Nub",
            # 의미론적 매핑 및 가중치 정보 추가
            "baseSemantics": {"b": 10, "Bip001": 5},
            "typeSemantics": {"P": 10, "Dum": 8, "Exp": 6, "IK": 4, "T": 2},
            "sideSemantics": {"L": "left", "R": "right", "L": 10, "R": 5},
            "frontBackSemantics": {"F": "front", "B": "back", "F": 10, "B": 5}
        }
        
        # 필수 namePart 정의 (삭제 불가능)
        self.requiredParts = ["Base", "Type", "Side", "FrontBack", "RealName", "Index", "Nub"]
        
        # 설정 파일 경로 및 기본 파일명
        self.configFilePath = ""
        self.defaultFileName = "namingConfig.json"
        
        # 스크립트 디렉토리 기준 기본 경로 설정
        scriptDir = os.path.dirname(os.path.abspath(__file__))
        self.defaultFilePath = os.path.join(scriptDir, self.defaultFileName)
    
    def save_config(self, inFilePath: Optional[str] = None) -> bool:
        """
        현재 설정을 JSON 파일로 저장
        
        Args:
            inFilePath: 저장할 파일 경로 (기본값: self.defaultFilePath)
            
        Returns:
            저장 성공 여부 (True/False)
        """
        savePath = inFilePath or self.defaultFilePath
        
        try:
            with open(savePath, 'w', encoding='utf-8') as f:
                json.dump(self.configData, f, indent=4, ensure_ascii=False)
            
            self.configFilePath = savePath
            return True
        except Exception as e:
            print(f"설정 저장 중 오류 발생: {e}")
            return False
    
    def load_config(self, inFilePath: Optional[str] = None) -> bool:
        """
        JSON 파일에서 설정 불러오기
        
        Args:
            inFilePath: 불러올 파일 경로 (기본값: self.defaultFilePath)
            
        Returns:
            로드 성공 여부 (True/False)
        """
        loadPath = inFilePath or self.defaultFilePath
        
        try:
            if os.path.exists(loadPath):
                with open(loadPath, 'r', encoding='utf-8') as f:
                    loadedData = json.load(f)
                
                # 필수 키가 있는지 확인
                requiredKeys = ["nameParts", "paddingNum"]
                for key in requiredKeys:
                    if key not in loadedData:
                        print(f"경고: 설정 파일에 필수 키 '{key}'가 없습니다.")
                        return False
                
                # 필수 namePart가 포함되어 있는지 확인
                for part in self.requiredParts:
                    if part not in loadedData["nameParts"]:
                        print(f"경고: 필수 namePart '{part}'가 설정에 포함되어 있지 않습니다.")
                        return False
                
                self.configData = loadedData
                self.configFilePath = loadPath
                return True
            else:
                print(f"설정 파일을 찾을 수 없습니다: {loadPath}")
                return False
        except Exception as e:
            print(f"설정 로드 중 오류 발생: {e}")
            return False
    
    def add_name_part(self, inPartName: str) -> bool:
        """
        새로운 namePart 추가
        
        Args:
            inPartName: 추가할 namePart 이름
            
        Returns:
            추가 성공 여부 (True/False)
        """
        if not inPartName:
            print("오류: 유효한 namePart 이름을 입력하세요.")
            return False
        
        # 이미 존재하는지 확인
        if inPartName in self.configData["nameParts"]:
            print(f"오류: '{inPartName}' namePart가 이미 존재합니다.")
            return False
        
        # namePart 추가
        self.configData["nameParts"].append(inPartName)
        
        # 해당 namePart에 대한 사전 배열도 추가 (빈 배열로 초기화)
        dictKey = f"{inPartName.lower()}StrArray"
        if dictKey not in self.configData:
            self.configData[dictKey] = []
            
        # 의미론적 매핑 또는 가중치도 추가 (빈 딕셔너리로 초기화)
        semanticsKey = f"{inPartName.lower()}Semantics"
        if semanticsKey not in self.configData:
            self.configData[semanticsKey] = {}
        
        return True
    
    def remove_name_part(self, inPartName: str) -> bool:
        """
        namePart 제거 (필수 부분은 제거 불가)
        
        Args:
            inPartName: 제거할 namePart 이름
            
        Returns:
            제거 성공 여부 (True/False)
        """
        # 필수 부분은 제거 불가능
        if inPartName in self.requiredParts:
            print(f"오류: 필수 namePart '{inPartName}'는 제거할 수 없습니다.")
            return False
        
        # 존재하는지 확인
        if inPartName not in self.configData["nameParts"]:
            print(f"오류: '{inPartName}' namePart가 존재하지 않습니다.")
            return False
        
        # namePart 제거
        self.configData["nameParts"].remove(inPartName)
        
        # 관련 사전 배열도 제거
        dictKey = f"{inPartName.lower()}StrArray"
        if dictKey in self.configData:
            del self.configData[dictKey]
            
        # 의미론적 매핑 또는 가중치도 제거
        semanticsKey = f"{inPartName.lower()}Semantics"
        if semanticsKey in self.configData:
            del self.configData[semanticsKey]
        
        return True
    
    def reorder_name_parts(self, inNewOrder: List[str]) -> bool:
        """
        namePart 순서 변경
        
        Args:
            inNewOrder: 새로운 namePart 순서 배열
            
        Returns:
            변경 성공 여부 (True/False)
        """
        # 배열 길이 확인
        if len(inNewOrder) != len(self.configData["nameParts"]):
            print("오류: 새 순서의 항목 수가 기존 nameParts와 일치하지 않습니다.")
            return False
        
        # 모든 필수 부분이 포함되어 있는지 확인
        for part in self.requiredParts:
            if part not in inNewOrder:
                print(f"오류: 필수 namePart '{part}'가 새 순서에 포함되어 있지 않습니다.")
                return False
        
        # 모든 요소가 동일한지 확인 (순서만 다른지)
        currentSet = set(self.configData["nameParts"])
        newSet = set(inNewOrder)
        
        if currentSet != newSet:
            print("오류: 새 순서에 기존 nameParts와 다른 항목이 포함되어 있습니다.")
            return False
        
        # 순서 변경
        self.configData["nameParts"] = inNewOrder
        return True
    
    def set_padding_num(self, inPaddingNum: int) -> bool:
        """
        인덱스 자릿수 설정
        
        Args:
            inPaddingNum: 설정할 패딩 자릿수
            
        Returns:
            설정 성공 여부 (True/False)
        """
        if not isinstance(inPaddingNum, int) or inPaddingNum < 1:
            print("오류: 패딩 자릿수는 1 이상의 정수여야 합니다.")
            return False
        
        self.configData["paddingNum"] = inPaddingNum
        return True
    
    def _get_part_dictionary_key(self, inPartName: str) -> Union[str, None]:
        """
        부분 이름에 해당하는 사전 키 반환하는 내부 헬퍼 메서드
        
        Args:
            inPartName: 부분 이름 ("Base", "Type", "Side" 등)
            
        Returns:
            사전 키 문자열, 존재하지 않으면 None
        """
        if inPartName == "RealName":
            print("오류: RealName 부분은 사전 문자열이 없습니다.")
            return None
        
        if inPartName == "Base":
            return "baseStrArray"
        elif inPartName == "Type":
            return "typeStrArray"
        elif inPartName == "Side":
            return "sideStrArray"
        elif inPartName == "FrontBack":
            return "frontBackStrArray"
        elif inPartName == "Index":
            return "nubStr"  # 특수 케이스: 단일 문자열
        else:
            return f"{inPartName.lower()}StrArray"
    
    def _get_part_semantics_key(self, inPartName: str) -> Union[str, None]:
        """
        부분 이름에 해당하는 의미론적 매핑 키 반환하는 내부 헬퍼 메서드
        
        Args:
            inPartName: 부분 이름 ("Base", "Type", "Side" 등)
            
        Returns:
            의미론적 매핑 키 문자열, 존재하지 않으면 None
        """
        if inPartName == "RealName":
            print("오류: RealName 부분은 의미론적 매핑이 없습니다.")
            return None
        
        if inPartName == "Base":
            return "baseSemantics"
        elif inPartName == "Type":
            return "typeSemantics"
        elif inPartName == "Side":
            return "sideSemantics"
        elif inPartName == "FrontBack":
            return "frontBackSemantics"
        elif inPartName == "Nub":
            return "nubSemantics"
        else:
            return f"{inPartName.lower()}Semantics"
    
    def add_part_dictionary(self, inPartName: str, inValue: Union[str, List[str]]) -> bool:
        """
        특정 부분의 사전 문자열에 값 추가
        
        Args:
            inPartName: 편집할 부분 이름 ("Base", "Type", "Side" 등)
            inValue: 추가할 문자열 또는 문자열 배열
                   
        Returns:
            추가 성공 여부 (True/False)
        """
        dictKey = self._get_part_dictionary_key(inPartName)
        if dictKey is None:
            return False
        
        # 인덱스가 특수 케이스인지 확인
        if inPartName == "Index":
            print("오류: Index 부분은 추가 동작을 지원하지 않습니다.")
            return False
        
        valuesToAdd = [inValue] if isinstance(inValue, str) else inValue
        
        for val in valuesToAdd:
            if val not in self.configData[dictKey]:
                self.configData[dictKey].append(val)
        
        return True
    
    def remove_part_dictionary(self, inPartName: str, inValue: Union[str, List[str]]) -> bool:
        """
        특정 부분의 사전 문자열에서 값 제거
        
        Args:
            inPartName: 편집할 부분 이름 ("Base", "Type", "Side" 등)
            inValue: 제거할 문자열 또는 문자열 배열
                   
        Returns:
            제거 성공 여부 (True/False)
        """
        dictKey = self._get_part_dictionary_key(inPartName)
        if dictKey is None:
            return False
        
        # 인덱스가 특수 케이스인지 확인
        if inPartName == "Index":
            print("오류: Index 부분은 제거 동작을 지원하지 않습니다.")
            return False
        
        valuesToRemove = [inValue] if isinstance(inValue, str) else inValue
        
        newArray = [item for item in self.configData[dictKey] if item not in valuesToRemove]
        
        if not newArray:
            print(f"오류: 모든 항목을 제거할 수 없습니다. {inPartName} 부분의 사전 문자열은 적어도 하나 이상 있어야 합니다.")
            return False
        
        self.configData[dictKey] = newArray
        return True
    
    def modify_part_dictionary(self, inPartName: str, inOldValue: str, inNewValue: str) -> bool:
        """
        특정 부분의 사전 문자열 수정
        
        Args:
            inPartName: 편집할 부분 이름 ("Base", "Type", "Side" 등)
            inOldValue: 기존 값
            inNewValue: 새 값
                   
        Returns:
            수정 성공 여부 (True/False)
        """
        dictKey = self._get_part_dictionary_key(inPartName)
        if dictKey is None:
            return False
        
        # 인덱스가 특수 케이스인지 확인
        isIndexCase = (inPartName == "Index")
        
        if isIndexCase:
            if inOldValue == self.configData[dictKey]:
                self.configData[dictKey] = inNewValue
                return True
            else:
                print(f"오류: 현재 '{dictKey}' 값과 일치하지 않습니다.")
                return False
        else:
            if inOldValue in self.configData[dictKey]:
                idx = self.configData[dictKey].index(inOldValue)
                self.configData[dictKey][idx] = inNewValue
                return True
            else:
                print(f"오류: '{inOldValue}'을(를) 찾을 수 없습니다.")
                return False
    
    def set_part_dictionary(self, inPartName: str, inValue: Union[str, List[str]]) -> bool:
        """
        특정 부분의 사전 문자열 설정 (기존 값 교체)
        
        Args:
            inPartName: 편집할 부분 이름 ("Base", "Type", "Side" 등)
            inValue: 새로 설정할 문자열 또는 문자열 배열
                   
        Returns:
            설정 성공 여부 (True/False)
        """
        dictKey = self._get_part_dictionary_key(inPartName)
        if dictKey is None:
            return False
        
        # 인덱스가 특수 케이스인지 확인
        isIndexCase = (inPartName == "Index")
        
        if isIndexCase:
            if isinstance(inValue, str):
                self.configData[dictKey] = inValue
                return True
            else:
                print("오류: Index의 nubStr 설정은 문자열이어야 합니다.")
                return False
        else:
            if isinstance(inValue, list):
                if not inValue:
                    print(f"오류: {inPartName} 부분의 사전 문자열은 적어도 하나 이상 있어야 합니다.")
                    return False
                
                self.configData[dictKey] = copy.deepcopy(inValue)
                return True
            else:
                print("오류: set 동작은 문자열 배열이 필요합니다.")
                return False
    
    def get_part_dictionary(self, inPartName: str) -> Union[List[str], str, None]:
        """
        특정 부분의 사전 문자열 배열 반환
        
        Args:
            inPartName: 문자열 배열을 조회할 부분 이름 ("Base", "Type", "Side" 등)
            
        Returns:
            사전 문자열 배열 또는 문자열, 존재하지 않으면 None
        """
        if inPartName == "RealName":
            print("정보: RealName 부분은 사전 문자열이 없습니다.")
            return None
        
        dictKey = ""
        if inPartName == "Base":
            dictKey = "baseStrArray"
        elif inPartName == "Type":
            dictKey = "typeStrArray"
        elif inPartName == "Side":
            dictKey = "sideStrArray"
        elif inPartName == "FrontBack":
            dictKey = "frontBackStrArray"
        elif inPartName == "Index":
            dictKey = "nubStr"  # 특수 케이스: 단일 문자열
            return self.configData.get(dictKey)
        else:
            dictKey = f"{inPartName.lower()}StrArray"
        
        return self.configData.get(dictKey, None)
    
    def set_semantic_mapping(self, inPartName: str, inValueToMappingDict: Dict[str, Union[str, int, float]]) -> bool:
        """
        특정 부분의 값에 대한 의미론적 매핑 설정
        
        Args:
            inPartName: 부분 이름 ("Side", "FrontBack" 등)
            inValueToMappingDict: 값-매핑 쌍의 딕셔너리 (예: {"L": "left", "R": "right"})
            
        Returns:
            설정 성공 여부 (True/False)
        """
        # 해당 부분이 존재하는지 확인
        if inPartName not in self.configData["nameParts"]:
            print(f"오류: '{inPartName}' namePart가 존재하지 않습니다.")
            return False
            
        # 매핑 키 생성
        mappingKey = self._get_part_semantics_key(inPartName)
        if mappingKey is None:
            return False
            
        # 이미 매핑이 있으면 병합
        if mappingKey in self.configData:
            self.configData[mappingKey].update(inValueToMappingDict)
        else:
            # 새 매핑 설정
            self.configData[mappingKey] = inValueToMappingDict.copy()
            
        return True
    
    def get_semantic_mapping(self, inPartName: str) -> Dict[str, Union[str, int, float]]:
        """
        특정 부분의 의미론적 매핑 가져오기
        
        Args:
            inPartName: 부분 이름 ("Side", "FrontBack" 등)
            
        Returns:
            의미론적 매핑 딕셔너리
        """
        semanticsKey = self._get_part_semantics_key(inPartName)
        if semanticsKey is None:
            return {}
            
        return self.configData.get(semanticsKey, {})
    
    def apply_config_to_naming(self, inNamingInstance) -> bool:
        """
        설정을 Naming 인스턴스에 적용
        
        Args:
            inNamingInstance: 설정을 적용할 Naming 클래스 인스턴스
            
        Returns:
            적용 성공 여부 (True/False)
        """
        try:
            # 필요한 모듈 임포트
            try:
                from .namePart import NamePart
            except ImportError:
                # 직접 실행할 때는 상대 경로 임포트가 작동하지 않음
                import namePart
                from namePart import NamePart
            
            # 설정 적용을 위해 새로운 NamePart 객체 배열 생성
            if "nameParts" in self.configData:
                nameParts = []
                
                # paddingNum 설정
                if "paddingNum" in self.configData:
                    inNamingInstance._paddingNum = self.configData["paddingNum"]
                
                # 사전 정의 값들 준비
                baseStrArray = self.configData.get("baseStrArray", ["b", "Bip001"])
                typeStrArray = self.configData.get("typeStrArray", ["P", "Dum", "Exp", "IK", "T"])
                sideStrArray = self.configData.get("sideStrArray", ["L", "R"])
                frontBackStrArray = self.configData.get("frontBackStrArray", ["F", "B"])
                
                # 의미론적 매핑 또는 가중치 준비
                baseSemantics = self.configData.get("baseSemantics", {})
                typeSemantics = self.configData.get("typeSemantics", {})
                sideSemantics = self.configData.get("sideSemantics", {})
                frontBackSemantics = self.configData.get("frontBackSemantics", {})
                
                # 기본 의미론적 매핑 설정 (없는 경우)
                if not sideSemantics and len(sideStrArray) >= 2:
                    sideSemantics = {
                        sideStrArray[0]: "left",
                        sideStrArray[1]: "right",
                        sideStrArray[0]: 10,
                        sideStrArray[1]: 5
                    }
                    
                if not frontBackSemantics and len(frontBackStrArray) >= 2:
                    frontBackSemantics = {
                        frontBackStrArray[0]: "front",
                        frontBackStrArray[1]: "back",
                        frontBackStrArray[0]: 10,
                        frontBackStrArray[1]: 5
                    }
                    
                # 각 NamePart 객체 생성 및 설정
                for name in self.configData["nameParts"]:
                    if name == "Base":
                        nameParts.append(NamePart(name, baseStrArray, baseSemantics))
                    elif name == "Type":
                        nameParts.append(NamePart(name, typeStrArray, typeSemantics))
                    elif name == "Side":
                        nameParts.append(NamePart(name, sideStrArray, sideSemantics))
                    elif name == "FrontBack":
                        nameParts.append(NamePart(name, frontBackStrArray, frontBackSemantics))
                    elif name == "RealName":
                        nameParts.append(NamePart(name))
                    elif name == "Index":
                        nameParts.append(NamePart(name))
                    elif name == "Nub":
                        # Nub는 nubStr 값을 사용
                        nubStr = self.configData.get("nubStr", "Nub")
                        nubSemantics = self.configData.get("nubSemantics", {nubStr: 10})
                        nameParts.append(NamePart(name, [nubStr], nubSemantics))
                    else:
                        # 기타 사용자 정의 부분
                        dictKey = f"{name.lower()}StrArray"
                        semanticsKey = f"{name.lower()}Semantics"
                        
                        values = self.configData.get(dictKey, [])
                        semantics = self.configData.get(semanticsKey, {})
                        
                        nameParts.append(NamePart(name, values, semantics))
                
                # 모든 NamePart 객체 설정 완료 후 inNamingInstance._nameParts에 할당
                inNamingInstance._nameParts = nameParts
            
            return True
        except Exception as e:
            print(f"설정 적용 중 오류 발생: {e}")
            return False
    
    def set_specific_string(self, inStrType: str, inValue: str) -> bool:
        """
        특정 문자열 설정 (parentStr, dummyStr 등)
        
        Args:
            inStrType: 설정할 문자열 타입 ("parentStr", "dummyStr", "exposeTmStr", "targetStr", "ikStr", "nubStr")
            inValue: 설정할 값
            
        Returns:
            설정 성공 여부 (True/False)
        """
        validTypes = ["parentStr", "dummyStr", "exposeTmStr", "targetStr", "ikStr", "nubStr"]
        
        if inStrType not in validTypes:
            print(f"오류: 잘못된 문자열 타입입니다. {validTypes} 중 하나를 사용하세요.")
            return False
        
        if not isinstance(inValue, str):
            print("오류: 값은 문자열이어야 합니다.")
            return False
        
        self.configData[inStrType] = inValue
        
        # Type 관련 문자열인 경우 typeStrArray도 업데이트
        if inStrType in ["parentStr", "dummyStr", "exposeTmStr", "targetStr", "ikStr"]:
            typeStrArray = self.configData.get("typeStrArray", [])
            
            # 이전 값 찾기
            oldValue = None
            for t in ["parentStr", "dummyStr", "exposeTmStr", "targetStr", "ikStr"]:
                if t == inStrType and t in self.configData:
                    oldValue = self.configData[t]
                    break
            
            # typeStrArray 업데이트
            if oldValue and oldValue in typeStrArray:
                idx = typeStrArray.index(oldValue)
                typeStrArray[idx] = inValue
            elif inValue not in typeStrArray:
                typeStrArray.append(inValue)
            
            self.configData["typeStrArray"] = typeStrArray
        
        return True


# 메인 함수: namingConfig.json 파일 생성 예제
def main():
    """namingConfig.json 파일 생성 예제"""
    config = NamingConfig()
    
    # 설정 예시 (필요에 따라 수정)
    config.set_padding_num(3)
    config.set_part_dictionary("Base", ["b", "Bip001"])
    config.set_part_dictionary("Type", ["P", "Dum", "Exp", "IK", "T"])
    config.set_part_dictionary("Side", ["L", "R"])
    config.set_part_dictionary("FrontBack", ["F", "B"])
    config.set_specific_string("nubStr", "Nub")
    
    # 의미론적 매핑 설정
    config.set_semantic_mapping("Side", {"L": "left", "R": "right", "L": 10, "R": 5})
    config.set_semantic_mapping("FrontBack", {"F": "front", "B": "back", "F": 10, "B": 5})
    config.set_semantic_mapping("Base", {"b": 10, "Bip001": 5})
    config.set_semantic_mapping("Type", {"P": 10, "Dum": 8, "Exp": 6, "IK": 4, "T": 2})
    
    # JSON 파일 저장
    success = config.save_config()
    if success:
        print(f"namingConfig.json 파일이 성공적으로 생성되었습니다: {config.configFilePath}")
    else:
        print("namingConfig.json 파일 생성에 실패했습니다.")


# 스크립트가 직접 실행될 때만 메인 함수 호출
if __name__ == "__main__":
    main()
