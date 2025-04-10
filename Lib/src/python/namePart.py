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
    
    def __init__(self, name="", predefinedValues=None):
        """
        NamePart 클래스 초기화
        
        Args:
            name: 이름 부분의 이름 (예: "Base", "Type", "Side" 등)
            predefinedValues: 사전 선언된 값 목록 (기본값: None, 빈 리스트로 초기화)
        """
        self._name = name
        self._predefinedValues = predefinedValues if predefinedValues is not None else []
    
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
    
    def to_dict(self):
        """
        NamePart 객체를 사전 형태로 변환합니다.
        
        Returns:
            사전 형태의 NamePart 정보
        """
        return {
            "name": self._name,
            "predefinedValues": self._predefinedValues.copy()
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
        if isinstance(data, dict) and "name" in data and "predefinedValues" in data:
            return NamePart(data["name"], data["predefinedValues"])
        return NamePart()
