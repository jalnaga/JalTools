#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
JalLib - Python version
원본 MAXScript 라이브러리에서 변환됨
"""

# 모듈 임포트
from .name import Name
from .anim import Anim
from .helper import Helper
from .constraint import Constraint
from .bone import Bone

class JalLib:
    """JalLib 메인 클래스 - 모든 모듈 기능을 통합"""
    
    def __init__(self):
        """각 모듈 초기화 및 참조 설정"""
        # 모든 모듈 인스턴스 생성
        self.name = Name()
        self.anim = Anim()
        self.helper = Helper()
        self.const = Constraint()
        self.bone = Bone()
        
        # 모듈 간 참조 설정 (원본 MAXScript 구조와 동일하게)
        # name에 대한 참조 설정 필요 없음
        
        # helper에 대한 참조
        self.helper.name = self.name
        
        # constraint에 대한 참조
        self.const.str = None  # string 클래스는 Python 내장 기능으로 대체됨
        self.const.name = self.name
        self.const.helper = self.helper
        
        # bone에 대한 참조
        self.bone.str = None  # string 클래스는 Python 내장 기능으로 대체됨
        self.bone.name = self.name
        self.bone.anim = self.anim
        self.bone.helper = self.helper
        self.bone.const = self.const
