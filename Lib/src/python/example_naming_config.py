#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
namingConfig 사용 예제
"""

import os
from naming import Naming
from namingConfig import NamingConfig

def print_section(title):
    """섹션 제목 출력"""
    print("\n" + "="*60)
    print(f"  {title}")
    print("="*60)

def main():
    print_section("namingConfig 사용 예제")
    
    # 1. NamingConfig 객체 생성
    config = NamingConfig()
    
    # 2. 설정 수정
    print("\n설정 수정:")
    config.set_padding_num(4)
    config.set_part_dictionary("Side", ["Lt", "Rt"])
    config.set_specific_string("nubStr", "End")
    
    # 3. namePart 추가 및 순서 변경
    print("\nnamePart 추가 및 순서 변경:")
    config.add_name_part("Group")
    config.add_part_dictionary("Group", ["G1", "G2", "G3"])
    
    # namePart 순서 변경
    new_order = ["Base", "Group", "Type", "Side", "FrontBack", "RealName", "Index"]
    config.reorder_name_parts(new_order)
    print(f"  새 namePart 순서: {config.configData['nameParts']}")
    
    # 4. 설정 JSON 파일로 저장
    json_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "example_naming_config.json")
    save_result = config.save_config(json_path)
    print(f"\n설정 저장 결과: {'성공' if save_result else '실패'}")
    print(f"  저장 경로: {json_path}")
    
    # 5. Naming 클래스에 설정 적용
    print("\nNaming 클래스에 설정 적용:")
    naming = Naming()
    
    # 적용 전 설정 출력
    print("  적용 전:")
    print(f"    패딩 숫자: {naming.get_padding_num()}")
    print(f"    측면 문자열: {naming.get_left_str()}, {naming.get_right_str()}")
    print(f"    넙 문자열: {naming.get_nub_str()}")
    print(f"    nameParts: {naming._nameParts}")
    
    # 설정 적용
    config.apply_config_to_naming(naming)
    
    # 적용 후 설정 출력
    print("  적용 후:")
    print(f"    패딩 숫자: {naming.get_padding_num()}")
    print(f"    측면 문자열: {naming.get_left_str()}, {naming.get_right_str()}")
    print(f"    넙 문자열: {naming.get_nub_str()}")
    print(f"    nameParts: {naming._nameParts}")
    
    # 6. 설정 파일에서 직접 Naming 객체 생성
    print("\n설정 파일에서 직접 Naming 객체 생성:")
    naming_from_config = Naming(json_path)
    print(f"  패딩 숫자: {naming_from_config.get_padding_num()}")
    print(f"  측면 문자열: {naming_from_config.get_left_str()}, {naming_from_config.get_right_str()}")
    print(f"  넙 문자열: {naming_from_config.get_nub_str()}")
    print(f"  nameParts: {naming_from_config._nameParts}")
    
    # 7. 이름 조작 테스트
    print("\n이름 조작 테스트:")
    test_name = "b_G1_P_Lt_F_Arm_0001"
    print(f"  테스트 이름: {test_name}")
    
    # 이름 분석
    base = naming_from_config.get_base(test_name)
    group = ""  # 실제로는 구현되어 있지 않음
    type_part = naming_from_config.get_type(test_name)
    side = naming_from_config.get_side(test_name)
    front_back = naming_from_config.get_front_back(test_name)
    real_name = naming_from_config.get_real_name(test_name)
    index = naming_from_config.get_index(test_name)
    
    print(f"  분석 결과:")
    print(f"    기본(Base): {base}")
    print(f"    그룹(Group): {group}")  # 실제로는 구현되어 있지 않음
    print(f"    유형(Type): {type_part}")
    print(f"    측면(Side): {side}")
    print(f"    앞/뒤(FrontBack): {front_back}")
    print(f"    실제 이름(RealName): {real_name}")
    print(f"    인덱스(Index): {index}")
    
    # 이름 변경
    new_name = naming_from_config.replace_side(test_name, "Rt")
    print(f"  측면 변경 후: {new_name}")
    
    # 8. 설정을 현재 Naming 객체에서 새 JSON 파일로 저장
    new_json_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "new_example_config.json")
    save_result = naming_from_config.save_to_config_file(new_json_path)
    print(f"\n설정 저장 결과: {'성공' if save_result else '실패'}")
    print(f"  저장 경로: {new_json_path}")
    
    # 9. 임시 파일 삭제
    try:
        if os.path.exists(json_path):
            os.remove(json_path)
            print(f"\n테스트 설정 파일 삭제 완료: {json_path}")
        if os.path.exists(new_json_path):
            os.remove(new_json_path)
            print(f"테스트 설정 파일 삭제 완료: {new_json_path}")
    except Exception as e:
        print(f"\n테스트 설정 파일 삭제 중 오류: {e}")

if __name__ == "__main__":
    main()
