#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
naming.py 모듈을 테스트하는 코드
제공된 이름들을 사용하여 Naming 클래스의 다양한 기능 테스트
"""

import sys
import os

# 상위 디렉토리 경로 추가하여 naming 모듈 임포트 가능하게 설정
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from naming import Naming

def print_header(message):
    """테스트 섹션 헤더 출력"""
    print("\n" + "="*50)
    print(f"  {message}")
    print("="*50)

def test_name_components():
    """이름 구성 요소 분석 테스트"""
    print_header("이름 구성 요소 분석 테스트")
    
    # 테스트할 이름 목록
    test_names = [
        "Bip001 R UpperArm",
        "Bip001 Spine1",
        "Bip001 Dum Thigh 001",
        "b_P_L_R_SkirtA_02",
        "b_Exp_R_F_SkirtArmor_A",
        "Box001",
        "Sphere"
    ]
    
    naming = Naming()
    
    for name in test_names:
        print(f"\n테스트 이름: {name}")
        
        # 이름 구성 요소 분석
        base = naming.get_base(name)
        type_part = naming.get_type(name)
        side = naming.get_side(name)
        front_back = naming.get_front_back(name)
        real_name = naming.get_real_name(name)
        index = naming.get_index(name)
        
        # 결과 출력
        print(f"  기본(Base): '{base}'")
        print(f"  유형(Type): '{type_part}'")
        print(f"  측면(Side): '{side}'")
        print(f"  앞/뒤(FrontBack): '{front_back}'")
        print(f"  실제 이름(RealName): '{real_name}'")
        print(f"  인덱스(Index): '{index}'")
        
        # 이름 문자열을 배열로 분할
        name_array = naming.convert_name_to_name_array(name)
        print(f"  이름 배열: {name_array}")
        
        # 측면/앞뒤 검증
        if side:
            print(f"  왼쪽?: {naming.is_left(name)}")
            print(f"  오른쪽?: {naming.is_right(name)}")
        
        if front_back:
            print(f"  앞쪽?: {naming.is_front(name)}")
            print(f"  뒤쪽?: {naming.is_back(name)}")

def test_name_transformations():
    """이름 변환 기능 테스트"""
    print_header("이름 변환 기능 테스트")
    
    # 테스트할 이름 목록
    test_names = [
        "Bip001 R UpperArm",
        "b_P_L_R_SkirtA_02",
        "b_Exp_R_F_SkirtArmor_A"
    ]
    
    naming = Naming()
    
    for name in test_names:
        print(f"\n테스트 이름: {name}")
        
        # 측면 변경
        if naming.has_side(name):
            mirrored_side = naming.replace_side(name, "L" if naming.is_right(name) else "R")
            print(f"  측면 변경: {mirrored_side}")
        
        # 앞/뒤 변경
        if naming.has_front_back(name):
            mirrored_fb = naming.replace_front_back(name, "B" if naming.is_front(name) else "F")
            print(f"  앞/뒤 변경: {mirrored_fb}")
        
        # 인덱스 변경
        if naming.get_index(name):
            new_index = naming.replace_index(name, "999")
            print(f"  인덱스 변경: {new_index}")
        
        # 실제 이름 변경
        new_real_name = naming.replace_real_name(name, "NewName")
        print(f"  실제 이름 변경: {new_real_name}")
        
        # 인덱스 증가
        increased_index = naming.increase_index(name, 1)
        print(f"  인덱스 증가(+1): {increased_index}")
        
        # 필터링 문자 변경
        new_fil_char = naming.replace_filtering_char(name, "_" if " " in name else " ")
        print(f"  필터링 문자 변경: {new_fil_char}")

def test_name_generation():
    """이름 생성 기능 테스트"""
    print_header("이름 생성 기능 테스트")
    
    # 테스트할 이름 목록
    test_names = [
        "Bip001 R UpperArm",
        "Bip001 Spine1",
        "b_P_L_R_SkirtA_02"
    ]
    
    naming = Naming()
    
    for name in test_names:
        print(f"\n테스트 이름: {name}")
        
        # 미러링된 이름 생성 (테스트 용으로만 출력, pymxs가 없어서 실제로는 작동하지 않을 수 있음)
        print(f"  미러링된 이름(축 1): (실제 환경에서만 작동)")
        print(f"  미러링된 이름(축 2): (실제 환경에서만 작동)")
        
        # 접두사/접미사 추가
        prefixed_name = naming.add_prefix_to_real_name(name, "Prefix_")
        print(f"  접두사 추가: {prefixed_name}")
        
        suffixed_name = naming.add_suffix_to_real_name(name, "_Suffix")
        print(f"  접미사 추가: {suffixed_name}")
        
        # 이름 결합 테스트
        real_name = naming.get_real_name(name)
        side = naming.get_side(name)
        index = naming.get_index(name)
        
        combined_name = naming.combine(
            inBase="NewBase",
            inType="NewType",
            inSide=side if side else "C",
            inFrontBack="M",
            inRealName=real_name,
            inIndex=index if index else "001",
            inFilChar="_"
        )
        print(f"  결합된 이름: {combined_name}")

def test_special_functions():
    """특수 기능 테스트"""
    print_header("특수 기능 테스트")
    
    # 테스트할 이름 목록
    test_names = [
        "Bip001 R UpperArm",
        "Bip001 Spine1",
        "Bip001 Dum Thigh 001",
        "b_P_L_R_SkirtA_02",
        "b_Exp_R_F_SkirtArmor_A",
        "Box001",
        "Sphere"
    ]
    
    naming = Naming()
    
    # 인덱스로 이름 정렬
    print("\n이름 정렬 테스트:")
    sorted_names = naming.sort_by_index(test_names)
    print("  인덱스 기준 정렬 결과:")
    for i, name in enumerate(sorted_names):
        print(f"    {i+1}. {name}")
    
    # 문자열 패턴 분할 테스트
    print("\n문자열 분할 테스트:")
    for name in test_names:
        split_array = naming._split_to_array(name)
        print(f"  '{name}' 분할 결과: {split_array}")
    
    # 각 이름의 문자 유형 검사
    print("\n문자 유형 검사:")
    for name in test_names:
        first_char = name[0] if name else ""
        char_type = naming.get_char_type(first_char)
        print(f"  '{name}'의 첫 글자 '{first_char}'의 유형: {char_type}")
        
        # 인덱스가 있는 경우, 인덱스를 숫자로 변환
        index = naming.get_index(name)
        if index:
            index_as_digit = naming.get_index_as_digit(name)
            print(f"  인덱스 '{index}'를 숫자로: {index_as_digit}")

def main():
    """메인 테스트 함수"""
    print("\n*** naming.py 모듈 테스트 ***\n")
    
    # 각 테스트 실행
    test_name_components()
    test_name_transformations()
    test_name_generation()
    test_special_functions()
    
    print("\n*** 테스트 완료 ***\n")

if __name__ == "__main__":
    main()
