#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
NamePart 클래스 모듈 - 3ds Max 이름의 각 부분을 관리하기 위한 클래스 제공
"""

class NamePart:
    """
    이름 부분(name part)을 관리하기 위한 클래스.
    이름과 해당 부분에 대한 사전 선언된 값들을 관리합니다.
    """
    
    def __init__(self, name="", predefinedValues=None, semanticMapping=None):
        """
        NamePart 클래스 초기화
        
        Args:
            name: 이름 부분의 이름 (예: "Base", "Type", "Side" 등)
            predefinedValues: 사전 선언된 값 목록 (기본값: None, 빈 리스트로 초기화)
            semanticMapping: 의미론적 매핑 또는 가중치 딕셔너리
                           (예: {"L": "left", "R": "right"}, {"P": 10, "Dum": 5})
        """
        self._name = name
        self._predefinedValues = predefinedValues if predefinedValues is not None else []
        self._semanticMappings = semanticMapping if semanticMapping is not None else 5
    
    def set_name(self, name):
        """
        이름 부분의 이름을 설정합니다.
        
        Args:
            name: 설정할 이름
        """
        self._name = name
    
    def get_name(self):
        """
        이름 부분의 이름을 반환합니다.
        
        Returns:
            이름 부분의 이름
        """
        return self._name
    
    def add_predefined_value(self, value):
        """
        사전 선언된 값 목록에 새 값을 추가합니다.
        
        Args:
            value: 추가할 값
            
        Returns:
            추가 성공 여부 (이미 존재하는 경우 False)
        """
        if value not in self._predefinedValues:
            self._predefinedValues.append(value)
            return True
        return False
    
    def remove_predefined_value(self, value):
        """
        사전 선언된 값 목록에서 값을 제거합니다.
        
        Args:
            value: 제거할 값
            
        Returns:
            제거 성공 여부 (존재하지 않는 경우 False)
        """
        if value in self._predefinedValues:
            self._predefinedValues.remove(value)
            return True
        return False
    
    def set_predefined_values(self, values):
        """
        사전 선언된 값 목록을 설정합니다.
        
        Args:
            values: 설정할 값 목록
        """
        self._predefinedValues = values.copy() if values else []
    
    def get_predefined_values(self):
        """
        사전 선언된 값 목록을 반환합니다.
        
        Returns:
            사전 선언된 값 목록
        """
        return self._predefinedValues.copy()
    
    def contains_value(self, value):
        """
        특정 값이 사전 선언된 값 목록에 있는지 확인합니다.
        
        Args:
            value: 확인할 값
            
        Returns:
            값이 존재하면 True, 아니면 False
        """
        return value in self._predefinedValues
    
    def get_value_at_index(self, index):
        """
        지정된 인덱스의 사전 선언된 값을 반환합니다.
        
        Args:
            index: 값의 인덱스
            
        Returns:
            값 (인덱스가 범위를 벗어나면 None)
        """
        if 0 <= index < len(self._predefinedValues):
            return self._predefinedValues[index]
        return None
    
    def get_value_count(self):
        """
        사전 선언된 값의 개수를 반환합니다.
        
        Returns:
            값 개수
        """
        return len(self._predefinedValues)
    
    def clear_predefined_values(self):
        """
        모든 사전 선언된 값을 제거합니다.
        """
        self._predefinedValues.clear()
    
    # 새로 추가된 메서드들 - 시맨틱 매핑 관련
    
    def set_semantic_mapping(self, mapping):
        """
        의미론적 매핑 또는 가중치를 설정합니다.
        
        Args:
            mapping: 의미 또는 가중치의 딕셔너리
                   (예: {"L": "left", "R": "right"} 또는 {"P": 10, "Dum": 5})
        """
        self._semanticMappings = mapping.copy() if mapping else {}
    
    def get_semantic_mapping(self):
        """
        의미론적 매핑 또는 가중치를 반환합니다.
        
        Returns:
            의미론적 매핑 또는 가중치 딕셔너리
        """
        return self._semanticMappings.copy()
    
    def add_semantic_mapping(self, key, value):
        """
        의미론적 매핑 또는 가중치에 항목을 추가합니다.
        
        Args:
            key: 매핑할 값 또는 이름
            value: 의미 또는 가중치 값
            
        Returns:
            추가 성공 여부
        """
        if key:
            self._semanticMappings[key] = value
            return True
        return False
    
    def get_value_by_semantic(self, semantic):
        """
        특정 의미에 해당하는 값을 반환합니다.
        
        Args:
            semantic: 찾고자 하는 의미 (예: "left", "right", "primary")
            
        Returns:
            해당 의미에 매핑된 값, 없으면 빈 문자열
        """
        for key, value in self._semanticMappings.items():
            if value == semantic and key in self._predefinedValues:
                return key
        return ""
    
    def get_value_by_weight(self, rank=0):
        """
        가중치 순위에 따른 값을 반환합니다.
        
        Args:
            rank: 가중치 순위 (0: 가장 높은 가중치, 1: 두 번째 가중치, 등)
            
        Returns:
            해당 순위의 가중치를 가진 값, 없으면 빈 문자열
        """
        weighted_values = []
        
        # 가중치가 숫자인 항목만 처리
        for value in self._predefinedValues:
            if value in self._semanticMappings and isinstance(self._semanticMappings[value], (int, float)):
                weighted_values.append((value, self._semanticMappings[value]))
        
        # 가중치가 없는 값들에는 기본 가중치 0 할당
        for value in self._predefinedValues:
            if value not in self._semanticMappings or not isinstance(self._semanticMappings[value], (int, float)):
                weighted_values.append((value, 0))
        
        # 가중치 내림차순 정렬 (높은 값이 더 중요)
        weighted_values.sort(key=lambda x: x[1], reverse=True)
        
        if 0 <= rank < len(weighted_values):
            return weighted_values[rank][0]
        return ""
    
    def get_sorted_values_by_weight(self):
        """
        가중치에 따라 정렬된 값 목록을 반환합니다.
        
        Returns:
            가중치 내림차순으로 정렬된 값 목록
        """
        weighted_values = []
        
        # 가중치가 숫자인 항목만 처리
        for value in self._predefinedValues:
            if value in self._semanticMappings and isinstance(self._semanticMappings[value], (int, float)):
                weighted_values.append((value, self._semanticMappings[value]))
        
        # 가중치가 없는 값들에는 기본 가중치 0 할당
        for value in self._predefinedValues:
            if value not in self._semanticMappings or not isinstance(self._semanticMappings[value], (int, float)):
                weighted_values.append((value, 0))
        
        # 가중치 내림차순 정렬 (높은 값이 더 중요)
        weighted_values.sort(key=lambda x: x[1], reverse=True)
        
        # 값만 반환
        return [item[0] for item in weighted_values]
    
    def to_dict(self):
        """
        NamePart 객체를 사전 형태로 변환합니다.
        
        Returns:
            사전 형태의 NamePart 정보
        """
        return {
            "name": self._name,
            "predefinedValues": self._predefinedValues.copy(),
            "semanticMapping": self._semanticMappings.copy()
        }
    
    @staticmethod
    def from_dict(data):
        """
        사전 형태의 데이터로부터 NamePart 객체를 생성합니다.
        
        Args:
            data: 사전 형태의 NamePart 정보
            
        Returns:
            NamePart 객체
        """
        if isinstance(data, dict) and "name" in data:
            return NamePart(
                data["name"],
                data.get("predefinedValues", []),
                data.get("semanticMapping", {})
            )
        return NamePart()
