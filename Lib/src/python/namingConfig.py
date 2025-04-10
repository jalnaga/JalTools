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
            "nameParts": ["Base", "Type", "Side", "FrontBack", "RealName", "Index"],
            "paddingNum": 2,
            "typeStrArray": ["P", "Dum", "Exp", "IK", "T"],
            "baseStrArray": ["b", "Bip001"],
            "sideStrArray": ["L", "R"],
            "frontBackStrArray": ["F", "B"],
            "nubStr": "Nub",
            "parentStr": "P",
            "dummyStr": "Dum",
            "exposeTmStr": "Exp",
            "targetStr": "T",
            "ikStr": "IK"
        }
        
        # 필수 namePart 정의 (삭제 불가능)
        self.requiredParts = ["Base", "Type", "Side", "FrontBack", "RealName", "Index"]
        
        # 설정 파일 경로 및 기본 파일명
        self.configFilePath = ""
        self.defaultFileName = "namingConfig.json"
        
        # 스크립트 디렉토리 기준 기본 경로 설정
        scriptDir = os.path.dirname(os.path.abspath(__file__))
        self.defaultFilePath = os.path.join(scriptDir, self.defaultFileName)
    
    def save_config(self, filePath: Optional[str] = None) -> bool:
        """
        현재 설정을 JSON 파일로 저장
        
        Args:
            filePath: 저장할 파일 경로 (기본값: self.defaultFilePath)
            
        Returns:
            저장 성공 여부 (True/False)
        """
        savePath = filePath or self.defaultFilePath
        
        try:
            with open(savePath, 'w', encoding='utf-8') as f:
                json.dump(self.configData, f, indent=4, ensure_ascii=False)
            
            self.configFilePath = savePath
            return True
        except Exception as e:
            print(f"설정 저장 중 오류 발생: {e}")
            return False
    
    def load_config(self, filePath: Optional[str] = None) -> bool:
        """
        JSON 파일에서 설정 불러오기
        
        Args:
            filePath: 불러올 파일 경로 (기본값: self.defaultFilePath)
            
        Returns:
            로드 성공 여부 (True/False)
        """
        loadPath = filePath or self.defaultFilePath
        
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
    
    def add_name_part(self, partName: str) -> bool:
        """
        새로운 namePart 추가
        
        Args:
            partName: 추가할 namePart 이름
            
        Returns:
            추가 성공 여부 (True/False)
        """
        if not partName:
            print("오류: 유효한 namePart 이름을 입력하세요.")
            return False
        
        # 이미 존재하는지 확인
        if partName in self.configData["nameParts"]:
            print(f"오류: '{partName}' namePart가 이미 존재합니다.")
            return False
        
        # namePart 추가
        self.configData["nameParts"].append(partName)
        
        # 해당 namePart에 대한 사전 배열도 추가 (빈 배열로 초기화)
        dictKey = f"{partName.lower()}StrArray"
        if dictKey not in self.configData:
            self.configData[dictKey] = []
        
        return True
    
    def remove_name_part(self, partName: str) -> bool:
        """
        namePart 제거 (필수 부분은 제거 불가)
        
        Args:
            partName: 제거할 namePart 이름
            
        Returns:
            제거 성공 여부 (True/False)
        """
        # 필수 부분은 제거 불가능
        if partName in self.requiredParts:
            print(f"오류: 필수 namePart '{partName}'는 제거할 수 없습니다.")
            return False
        
        # 존재하는지 확인
        if partName not in self.configData["nameParts"]:
            print(f"오류: '{partName}' namePart가 존재하지 않습니다.")
            return False
        
        # namePart 제거
        self.configData["nameParts"].remove(partName)
        
        # 관련 사전 배열도 제거
        dictKey = f"{partName.lower()}StrArray"
        if dictKey in self.configData:
            del self.configData[dictKey]
        
        return True
    
    def reorder_name_parts(self, newOrder: List[str]) -> bool:
        """
        namePart 순서 변경
        
        Args:
            newOrder: 새로운 namePart 순서 배열
            
        Returns:
            변경 성공 여부 (True/False)
        """
        # 배열 길이 확인
        if len(newOrder) != len(self.configData["nameParts"]):
            print("오류: 새 순서의 항목 수가 기존 nameParts와 일치하지 않습니다.")
            return False
        
        # 모든 필수 부분이 포함되어 있는지 확인
        for part in self.requiredParts:
            if part not in newOrder:
                print(f"오류: 필수 namePart '{part}'가 새 순서에 포함되어 있지 않습니다.")
                return False
        
        # 모든 요소가 동일한지 확인 (순서만 다른지)
        currentSet = set(self.configData["nameParts"])
        newSet = set(newOrder)
        
        if currentSet != newSet:
            print("오류: 새 순서에 기존 nameParts와 다른 항목이 포함되어 있습니다.")
            return False
        
        # 순서 변경
        self.configData["nameParts"] = newOrder
        return True
    
    def set_padding_num(self, paddingNum: int) -> bool:
        """
        인덱스 자릿수 설정
        
        Args:
            paddingNum: 설정할 패딩 자릿수
            
        Returns:
            설정 성공 여부 (True/False)
        """
        if not isinstance(paddingNum, int) or paddingNum < 1:
            print("오류: 패딩 자릿수는 1 이상의 정수여야 합니다.")
            return False
        
        self.configData["paddingNum"] = paddingNum
        return True
    
    def _get_part_dictionary_key(self, partName: str) -> Union[str, None]:
        """
        부분 이름에 해당하는 사전 키 반환하는 내부 헬퍼 메서드
        
        Args:
            partName: 부분 이름 ("Base", "Type", "Side" 등)
            
        Returns:
            사전 키 문자열, 존재하지 않으면 None
        """
        if partName == "RealName":
            print("오류: RealName 부분은 사전 문자열이 없습니다.")
            return None
        
        if partName == "Base":
            return "baseStrArray"
        elif partName == "Type":
            return "typeStrArray"
        elif partName == "Side":
            return "sideStrArray"
        elif partName == "FrontBack":
            return "frontBackStrArray"
        elif partName == "Index":
            return "nubStr"  # 특수 케이스: 단일 문자열
        else:
            return f"{partName.lower()}StrArray"
    
    def add_part_dictionary(self, partName: str, value: Union[str, List[str]]) -> bool:
        """
        특정 부분의 사전 문자열에 값 추가
        
        Args:
            partName: 편집할 부분 이름 ("Base", "Type", "Side" 등)
            value: 추가할 문자열 또는 문자열 배열
                   
        Returns:
            추가 성공 여부 (True/False)
        """
        dictKey = self._get_part_dictionary_key(partName)
        if dictKey is None:
            return False
        
        # 인덱스가 특수 케이스인지 확인
        if partName == "Index":
            print("오류: Index 부분은 추가 동작을 지원하지 않습니다.")
            return False
        
        valuesToAdd = [value] if isinstance(value, str) else value
        
        for val in valuesToAdd:
            if val not in self.configData[dictKey]:
                self.configData[dictKey].append(val)
        
        return True
    
    def remove_part_dictionary(self, partName: str, value: Union[str, List[str]]) -> bool:
        """
        특정 부분의 사전 문자열에서 값 제거
        
        Args:
            partName: 편집할 부분 이름 ("Base", "Type", "Side" 등)
            value: 제거할 문자열 또는 문자열 배열
                   
        Returns:
            제거 성공 여부 (True/False)
        """
        dictKey = self._get_part_dictionary_key(partName)
        if dictKey is None:
            return False
        
        # 인덱스가 특수 케이스인지 확인
        if partName == "Index":
            print("오류: Index 부분은 제거 동작을 지원하지 않습니다.")
            return False
        
        valuesToRemove = [value] if isinstance(value, str) else value
        
        newArray = [item for item in self.configData[dictKey] if item not in valuesToRemove]
        
        if not newArray:
            print(f"오류: 모든 항목을 제거할 수 없습니다. {partName} 부분의 사전 문자열은 적어도 하나 이상 있어야 합니다.")
            return False
        
        self.configData[dictKey] = newArray
        return True
    
    def modify_part_dictionary(self, partName: str, oldValue: str, newValue: str) -> bool:
        """
        특정 부분의 사전 문자열 수정
        
        Args:
            partName: 편집할 부분 이름 ("Base", "Type", "Side" 등)
            oldValue: 기존 값
            newValue: 새 값
                   
        Returns:
            수정 성공 여부 (True/False)
        """
        dictKey = self._get_part_dictionary_key(partName)
        if dictKey is None:
            return False
        
        # 인덱스가 특수 케이스인지 확인
        isIndexCase = (partName == "Index")
        
        if isIndexCase:
            if oldValue == self.configData[dictKey]:
                self.configData[dictKey] = newValue
                return True
            else:
                print(f"오류: 현재 '{dictKey}' 값과 일치하지 않습니다.")
                return False
        else:
            if oldValue in self.configData[dictKey]:
                idx = self.configData[dictKey].index(oldValue)
                self.configData[dictKey][idx] = newValue
                return True
            else:
                print(f"오류: '{oldValue}'을(를) 찾을 수 없습니다.")
                return False
    
    def set_part_dictionary(self, partName: str, value: Union[str, List[str]]) -> bool:
        """
        특정 부분의 사전 문자열 설정 (기존 값 교체)
        
        Args:
            partName: 편집할 부분 이름 ("Base", "Type", "Side" 등)
            value: 새로 설정할 문자열 또는 문자열 배열
                   
        Returns:
            설정 성공 여부 (True/False)
        """
        dictKey = self._get_part_dictionary_key(partName)
        if dictKey is None:
            return False
        
        # 인덱스가 특수 케이스인지 확인
        isIndexCase = (partName == "Index")
        
        if isIndexCase:
            if isinstance(value, str):
                self.configData[dictKey] = value
                return True
            else:
                print("오류: Index의 nubStr 설정은 문자열이어야 합니다.")
                return False
        else:
            if isinstance(value, list):
                if not value:
                    print(f"오류: {partName} 부분의 사전 문자열은 적어도 하나 이상 있어야 합니다.")
                    return False
                
                self.configData[dictKey] = copy.deepcopy(value)
                return True
            else:
                print("오류: set 동작은 문자열 배열이 필요합니다.")
                return False
    
    def get_part_dictionary(self, partName: str) -> Union[List[str], str, None]:
        """
        특정 부분의 사전 문자열 배열 반환
        
        Args:
            partName: 문자열 배열을 조회할 부분 이름 ("Base", "Type", "Side" 등)
            
        Returns:
            사전 문자열 배열 또는 문자열, 존재하지 않으면 None
        """
        if partName == "RealName":
            print("정보: RealName 부분은 사전 문자열이 없습니다.")
            return None
        
        dictKey = ""
        if partName == "Base":
            dictKey = "baseStrArray"
        elif partName == "Type":
            dictKey = "typeStrArray"
        elif partName == "Side":
            dictKey = "sideStrArray"
        elif partName == "FrontBack":
            dictKey = "frontBackStrArray"
        elif partName == "Index":
            dictKey = "nubStr"  # 특수 케이스: 단일 문자열
            return self.configData.get(dictKey)
        else:
            dictKey = f"{partName.lower()}StrArray"
        
        return self.configData.get(dictKey, None)
    
    def apply_config_to_naming(self, namingInstance) -> bool:
        """
        설정을 Naming 인스턴스에 적용
        
        Args:
            namingInstance: 설정을 적용할 Naming 클래스 인스턴스
            
        Returns:
            적용 성공 여부 (True/False)
        """
        try:
            # 설정 적용을 위해 새로운 NamePart 객체 배열 생성
            if "nameParts" in self.configData:
                nameParts = []
                
                # paddingNum 설정
                if "paddingNum" in self.configData:
                    namingInstance._paddingNum = self.configData["paddingNum"]
                
                # nubStr 설정
                if "nubStr" in self.configData:
                    namingInstance._nubStr = self.configData["nubStr"]
                
                # 사전 정의 값들 준비
                baseStrArray = self.configData.get("baseStrArray", ["b", "Bip001"])
                
                # typeStrArray 설정
                if "typeStrArray" in self.configData:
                    typeStrArray = self.configData["typeStrArray"]
                else:
                    # typeStrArray가 없지만 개별 설정이 있는 경우
                    typeStrArray = []
                    
                    if "parentStr" in self.configData:
                        typeStrArray.append(self.configData["parentStr"])
                    else:
                        typeStrArray.append("")
                        
                    if "dummyStr" in self.configData:
                        typeStrArray.append(self.configData["dummyStr"])
                    if "exposeTmStr" in self.configData:
                        typeStrArray.append(self.configData["exposeTmStr"])
                    if "ikStr" in self.configData:
                        typeStrArray.append(self.configData["ikStr"])
                    if "targetStr" in self.configData:
                        typeStrArray.append(self.configData["targetStr"])
                
                sideStrArray = self.configData.get("sideStrArray", ["L", "R"])
                frontBackStrArray = self.configData.get("frontBackStrArray", ["F", "B"])
                
                # 각 NamePart 객체 생성 및 설정
                for name in self.configData["nameParts"]:
                    if name == "Base":
                        nameParts.append(namePart.NamePart(name, baseStrArray))
                    elif name == "Type":
                        nameParts.append(namePart.NamePart(name, typeStrArray))
                    elif name == "Side":
                        nameParts.append(namePart.NamePart(name, sideStrArray))
                    elif name == "FrontBack":
                        nameParts.append(namePart.NamePart(name, frontBackStrArray))
                    elif name == "RealName":
                        nameParts.append(namePart.NamePart(name))
                    elif name == "Index":
                        nameParts.append(namePart.NamePart(name))
                    elif name == "Nub":
                        # Nub는 nubStr 값을 사용
                        nubStr = self.configData.get("nubStr", "Nub")
                        nameParts.append(namePart.NamePart(name, [nubStr]))
                    else:
                        # 기타 사용자 정의 부분
                        dictKey = f"{name.lower()}StrArray"
                        if dictKey in self.configData:
                            nameParts.append(namePart.NamePart(name, self.configData[dictKey]))
                        else:
                            nameParts.append(namePart.NamePart(name))
                
                # 모든 NamePart 객체 설정 완료 후 namingInstance._nameParts에 할당
                namingInstance._nameParts = nameParts
            
            return True
        except Exception as e:
            print(f"설정 적용 중 오류 발생: {e}")
            return False
    
    def set_specific_string(self, strType: str, value: str) -> bool:
        """
        특정 문자열 설정 (parentStr, dummyStr 등)
        
        Args:
            strType: 설정할 문자열 타입 ("parentStr", "dummyStr", "exposeTmStr", "targetStr", "ikStr", "nubStr")
            value: 설정할 값
            
        Returns:
            설정 성공 여부 (True/False)
        """
        validTypes = ["parentStr", "dummyStr", "exposeTmStr", "targetStr", "ikStr", "nubStr"]
        
        if strType not in validTypes:
            print(f"오류: 잘못된 문자열 타입입니다. {validTypes} 중 하나를 사용하세요.")
            return False
        
        if not isinstance(value, str):
            print("오류: 값은 문자열이어야 합니다.")
            return False
        
        self.configData[strType] = value
        
        # Type 관련 문자열인 경우 typeStrArray도 업데이트
        if strType in ["parentStr", "dummyStr", "exposeTmStr", "targetStr", "ikStr"]:
            typeStrArray = self.configData.get("typeStrArray", [])
            
            # 이전 값 찾기
            oldValue = None
            for t in ["parentStr", "dummyStr", "exposeTmStr", "targetStr", "ikStr"]:
                if t == strType and t in self.configData:
                    oldValue = self.configData[t]
                    break
            
            # typeStrArray 업데이트
            if oldValue and oldValue in typeStrArray:
                idx = typeStrArray.index(oldValue)
                typeStrArray[idx] = value
            elif value not in typeStrArray:
                typeStrArray.append(value)
            
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
    config.set_specific_string("parentStr", "P")
    config.set_specific_string("dummyStr", "Dum")
    config.set_specific_string("exposeTmStr", "Exp")
    config.set_specific_string("targetStr", "T")
    config.set_specific_string("ikStr", "IK")
    
    # JSON 파일 저장
    success = config.save_config()
    if success:
        print(f"namingConfig.json 파일이 성공적으로 생성되었습니다: {config.configFilePath}")
    else:
        print("namingConfig.json 파일 생성에 실패했습니다.")


# 스크립트가 직접 실행될 때만 메인 함수 호출
if __name__ == "__main__":
    main()
