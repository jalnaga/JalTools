#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
namingConfig.py 모듈을 테스트하는 코드
NamingConfig 클래스의 기능 테스트 및 Naming 클래스와의 연동 테스트
"""

import sys
import os

# 상위 디렉토리 경로 추가하여 모듈 임포트 가능하게 설정
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from naming import Naming
from namingConfig import NamingConfig

def print_header(message):
    """테스트 섹션 헤더 출력"""
    print("\n" + "="*60)
    print(f"  {message}")
    print("="*60)

def test_basic_config():
    """기본 설정 테스트"""
    print_header("기본 NamingConfig 설정 테스트")
    
    config = NamingConfig()
    
    # 기본 설정값 출력
    print("\n기본 설정값:")
    print(f"  nameParts: {config.configData['nameParts']}")
    print(f"  paddingNum: {config.configData['paddingNum']}")
    print(f"  typeStrArray: {config.configData['typeStrArray']}")
    print(f"  baseStrArray: {config.configData['baseStrArray']}")
    print(f"  sideStrArray: {config.configData['sideStrArray']}")
    print(f"  frontBackStrArray: {config.configData['frontBackStrArray']}")
    print(f"  nubStr: {config.configData['nubStr']}")
    
    # 설정 변경 테스트
    print("\n설정 변경 테스트:")
    
    # 패딩 숫자 변경
    config.set_padding_num(5)
    print(f"  패딩 숫자 변경 후: {config.configData['paddingNum']}")
    
    # Side 사전 배열 편집
    config.set_part_dictionary("Side", ["Left", "Right"])
    print(f"  Side 배열 변경 후: {config.configData['sideStrArray']}")
    
    # FrontBack 사전 배열에 항목 추가
    config.add_part_dictionary("FrontBack", "M")
    print(f"  FrontBack 배열 추가 후: {config.configData['frontBackStrArray']}")
    
    # nubStr 변경
    config.set_specific_string("nubStr", "EndTip")
    print(f"  nubStr 변경 후: {config.configData['nubStr']}")
    
    # 새 namePart 추가
    config.add_name_part("Custom")
    print(f"  새 namePart 추가 후: {config.configData['nameParts']}")
    print(f"  새 사전 배열: {config.configData.get('customStrArray', [])}")
    
    # 새로 추가한 namePart에 사전 문자열 추가
    config.add_part_dictionary("Custom", ["C1", "C2", "C3"])
    print(f"  Custom 사전 배열 설정 후: {config.configData.get('customStrArray', [])}")
    
    # nameParts 순서 변경
    new_order = ["Base", "Type", "Custom", "Side", "FrontBack", "RealName", "Index"]
    config.reorder_name_parts(new_order)
    print(f"  nameParts 순서 변경 후: {config.configData['nameParts']}")
    
    return config

def test_config_save_load(config):
    """설정 저장 및 로드 테스트"""
    print_header("설정 저장 및 로드 테스트")
    
    # 테스트용 임시 파일 경로
    test_config_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "test_config.json")
    
    # 설정 저장
    save_result = config.save_config(test_config_path)
    print(f"\n설정 저장 결과: {'성공' if save_result else '실패'}")
    print(f"  저장 경로: {test_config_path}")
    
    # 새 설정 객체 생성
    new_config = NamingConfig()
    
    # 기본 설정값 출력
    print("\n새 설정 객체 기본 설정값:")
    print(f"  nameParts: {new_config.configData['nameParts']}")
    print(f"  paddingNum: {new_config.configData['paddingNum']}")
    
    # 저장된 설정 로드
    load_result = new_config.load_config(test_config_path)
    print(f"\n설정 로드 결과: {'성공' if load_result else '실패'}")
    
    # 로드된 설정값 출력
    print("\n로드된 설정값:")
    print(f"  nameParts: {new_config.configData['nameParts']}")
    print(f"  paddingNum: {new_config.configData['paddingNum']}")
    print(f"  sideStrArray: {new_config.configData['sideStrArray']}")
    print(f"  nubStr: {new_config.configData['nubStr']}")
    print(f"  customStrArray: {new_config.configData.get('customStrArray', [])}")
    
    # 임시 파일 삭제
    try:
        os.remove(test_config_path)
        print(f"\n테스트 설정 파일 삭제 완료: {test_config_path}")
    except Exception as e:
        print(f"\n테스트 설정 파일 삭제 중 오류: {e}")
    
    return new_config

def test_config_with_naming(config):
    """NamingConfig와 Naming 연동 테스트"""
    print_header("NamingConfig와 Naming 연동 테스트")
    
    # Naming 인스턴스 생성
    naming = Naming()
    
    # 기본 Naming 설정 출력
    print("\n기본 Naming 설정:")
    print(f"  nameParts: {naming._nameParts}")
    print(f"  paddingNum: {naming._paddingNum}")
    print(f"  sideStrArray: {naming._sideStrArray}")
    print(f"  nubStr: {naming._nubStr}")
    
    # 설정 적용
    apply_result = config.apply_config_to_naming(naming)
    print(f"\n설정 적용 결과: {'성공' if apply_result else '실패'}")
    
    # 적용된 설정 출력
    print("\n적용된 Naming 설정:")
    print(f"  nameParts: {naming._nameParts}")
    print(f"  paddingNum: {naming._paddingNum}")
    print(f"  sideStrArray: {naming._sideStrArray}")
    print(f"  nubStr: {naming._nubStr}")
    
    # 테스트 이름을 이용한 기능 테스트
    test_names = [
        "Bip001 Right Arm",
        "b_Custom_Left_F_Leg_001"
    ]
    
    print("\n이름 분석 테스트 (변경된 설정 적용):")
    for name in test_names:
        print(f"\n테스트 이름: {name}")
        
        # 이름 구성 요소 분석
        base = naming.get_base(name)
        type_part = naming.get_type(name)
        side = naming.get_side(name)
        front_back = naming.get_front_back(name)
        custom = ""  # 새로 추가된 Custom 파트
        real_name = naming.get_real_name(name)
        index = naming.get_index(name)
        
        # 결과 출력
        print(f"  기본(Base): '{base}'")
        print(f"  유형(Type): '{type_part}'")
        print(f"  Custom: '{custom}'")  # 아직 Custom 파트는 구현되지 않음
        print(f"  측면(Side): '{side}'")
        print(f"  앞/뒤(FrontBack): '{front_back}'")
        print(f"  실제 이름(RealName): '{real_name}'")
        print(f"  인덱스(Index): '{index}'")
        
        # 측면 확인
        if side:
            print(f"  왼쪽?: {naming.is_left(name)}")
            print(f"  오른쪽?: {naming.is_right(name)}")
        
        # 앞/뒤 확인
        if front_back:
            print(f"  앞쪽?: {naming.is_front(name)}")
            print(f"  뒤쪽?: {naming.is_back(name)}")
            
        # 이름 생성 테스트
        new_name = naming.replace_side(name, "Left" if naming.is_right(name) else "Right")
        print(f"  측면 변경: {new_name}")
        
        new_index = naming.replace_index(name, "999")
        print(f"  인덱스 변경: {new_index}")

def main():
    """메인 테스트 함수"""
    print("\n*** namingConfig.py 모듈 테스트 ***\n")
    
    # 기본 설정 테스트
    config = test_basic_config()
    
    # 설정 저장 및 로드 테스트
    loaded_config = test_config_save_load(config)
    
    # Naming 클래스와 연동 테스트
    test_config_with_naming(loaded_config)
    
    print("\n*** 테스트 완료 ***\n")

if __name__ == "__main__":
    main()
