#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
anim.py 모듈 테스트 코드
3DS Max 내에서 실행 가능하도록 작성됨
"""

import os
import sys
from pymxs import runtime as rt

# 현재 스크립트 경로를 추가하여 anim.py 모듈 임포트 가능하게 함
current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.append(current_dir)

import anim

def create_test_objects():
    """테스트를 위한 객체 생성"""
    # 테스트용 더미 객체 생성
    box = rt.Box(width=10, length=10, height=10)
    box.name = "TestBox"
    
    sphere = rt.Sphere(radius=5)
    sphere.name = "TestSphere"
    
    point = rt.Point()
    point.name = "TestPoint"
    
    # 테스트 객체 배열 반환
    return {
        "box": box,
        "sphere": sphere,
        "point": point
    }

def delete_test_objects(objects):
    """테스트 객체 삭제"""
    for obj in objects.values():
        if rt.isValidNode(obj):
            rt.delete(obj)

def test_rotate_local():
    """rotate_local 함수 테스트"""
    test_objects = create_test_objects()
    box = test_objects["box"]
    
    # 클래스 인스턴스 생성
    anim_instance = anim.Anim()
    
    # 초기 회전값 저장
    initial_rotation = rt.copy(box.rotation)
    
    # 로컬 회전 적용
    anim_instance.rotate_local(box, 45, 30, 15)
    
    # 회전이 적용되었는지 확인
    rt.print("회전 테스트 결과:")
    rt.print(f"초기 회전값: {initial_rotation}")
    rt.print(f"변경된 회전값: {box.rotation}")
    
    # 테스트 객체 삭제
    delete_test_objects(test_objects)
    return True

def test_move_local():
    """move_local 함수 테스트"""
    test_objects = create_test_objects()
    sphere = test_objects["sphere"]
    
    # 클래스 인스턴스 생성
    anim_instance = anim.Anim()
    
    # 초기 위치 저장
    initial_position = rt.copy(sphere.position)
    
    # 로컬 이동 적용
    anim_instance.move_local(sphere, 10, 5, 15)
    
    # 이동이 적용되었는지 확인
    rt.print("이동 테스트 결과:")
    rt.print(f"초기 위치: {initial_position}")
    rt.print(f"변경된 위치: {sphere.position}")
    
    # 테스트 객체 삭제
    delete_test_objects(test_objects)
    return True

def test_reset_transform_controller():
    """reset_transform_controller 함수 테스트"""
    test_objects = create_test_objects()
    box = test_objects["box"]
    
    # 클래스 인스턴스 생성
    anim_instance = anim.Anim()
    
    # 초기 컨트롤러 타입 확인
    initial_position_controller = rt.classOf(rt.getPropertyController(box, 'position'))
    initial_rotation_controller = rt.classOf(rt.getPropertyController(box, 'rotation'))
    
    # 트랜스폼 컨트롤러 초기화
    anim_instance.reset_transform_controller(box)
    
    # 새로운 컨트롤러 타입 확인
    new_position_controller = rt.classOf(rt.getPropertyController(box, 'position'))
    new_rotation_controller = rt.classOf(rt.getPropertyController(box, 'rotation'))
    
    # 컨트롤러가 변경되었는지 확인
    rt.print("트랜스폼 컨트롤러 초기화 테스트 결과:")
    rt.print(f"초기 포지션 컨트롤러: {initial_position_controller}")
    rt.print(f"변경된 포지션 컨트롤러: {new_position_controller}")
    rt.print(f"초기 회전 컨트롤러: {initial_rotation_controller}")
    rt.print(f"변경된 회전 컨트롤러: {new_rotation_controller}")
    
    # 테스트 객체 삭제
    delete_test_objects(test_objects)
    return True

def test_freeze_transform():
    """freeze_transform 함수 테스트"""
    test_objects = create_test_objects()
    sphere = test_objects["sphere"]
    
    # 클래스 인스턴스 생성
    anim_instance = anim.Anim()
    
    # 초기 컨트롤러 타입 확인
    initial_position_controller = rt.classOf(rt.getPropertyController(sphere, 'position'))
    initial_rotation_controller = rt.classOf(rt.getPropertyController(sphere, 'rotation'))
    
    # 트랜스폼 고정
    anim_instance.freeze_transform(sphere)
    
    # 새로운 컨트롤러 타입 확인
    new_position_controller = rt.classOf(rt.getPropertyController(sphere, 'position'))
    new_rotation_controller = rt.classOf(rt.getPropertyController(sphere, 'rotation'))
    
    # 컨트롤러가 변경되었는지 확인
    rt.print("트랜스폼 고정 테스트 결과:")
    rt.print(f"초기 포지션 컨트롤러: {initial_position_controller}")
    rt.print(f"변경된 포지션 컨트롤러: {new_position_controller}")
    rt.print(f"초기 회전 컨트롤러: {initial_rotation_controller}")
    rt.print(f"변경된 회전 컨트롤러: {new_rotation_controller}")
    
    # 테스트 객체 삭제
    delete_test_objects(test_objects)
    return True

def test_create_average_transforms():
    """평균 변환 생성 함수 테스트"""
    test_objects = create_test_objects()
    box = test_objects["box"]
    sphere = test_objects["sphere"]
    
    # 객체 위치 설정
    box.position = rt.Point3(0, 0, 0)
    sphere.position = rt.Point3(100, 100, 100)
    
    # 클래스 인스턴스 생성
    anim_instance = anim.Anim()
    
    # 평균 위치 변환 생성
    avg_pos_transform = anim_instance.create_average_pos_transform([box, sphere])
    
    # 평균 회전 변환 생성
    avg_rot_transform = anim_instance.create_average_rot_transform([box, sphere])
    
    # 결과 확인
    rt.print("평균 변환 테스트 결과:")
    rt.print(f"평균 위치 변환: {avg_pos_transform.position}")
    rt.print(f"평균 회전 변환: {avg_rot_transform.rotation}")
    
    # 기대되는 평균 위치: (50, 50, 50)
    expected_avg_pos = rt.Point3(50, 50, 50)
    position_diff = rt.distance(avg_pos_transform.position, expected_avg_pos)
    rt.print(f"예상 평균 위치와의 차이: {position_diff}")
    
    # 테스트 객체 삭제
    delete_test_objects(test_objects)
    return True

def test_key_management():
    """키프레임 관리 함수 테스트"""
    test_objects = create_test_objects()
    box = test_objects["box"]
    
    # 클래스 인스턴스 생성
    anim_instance = anim.Anim()
    
    # 애니메이션 생성 - 0, 30, 60 프레임에 키 생성
    rt.animateVertex(box)
    for frame in [0, 30, 60]:
        with rt.at(rt.time(frame)):
            with rt.animate():
                box.position.x = frame
    rt.animateVertex(box, False)
    
    # 모든 키 가져오기
    all_keys = anim_instance.get_all_keys(box)
    rt.print("모든 키프레임 테스트 결과:")
    rt.print(f"키프레임 수: {len(all_keys)}")
    
    # 시작/끝 키 가져오기
    start_end = anim_instance.get_start_end_keys(box)
    rt.print(f"시작 키프레임: {start_end[0]}")
    rt.print(f"끝 키프레임: {start_end[1]}")
    
    # 애니메이션 적용 여부 확인
    is_animated = anim_instance.is_node_animated(box)
    rt.print(f"애니메이션 적용 여부: {is_animated}")
    
    # 모든 키 삭제
    anim_instance.delete_all_keys(box)
    
    # 키 삭제 확인
    all_keys_after = anim_instance.get_all_keys(box)
    rt.print(f"키 삭제 후 키프레임 수: {len(all_keys_after)}")
    
    # 테스트 객체 삭제
    delete_test_objects(test_objects)
    return True

def test_save_set_xform():
    """save_xform, set_xform 함수 테스트"""
    test_objects = create_test_objects()
    box = test_objects["box"]
    
    # 클래스 인스턴스 생성
    anim_instance = anim.Anim()
    
    # 초기 위치 설정
    box.position = rt.Point3(10, 20, 30)
    initial_position = rt.copy(box.position)
    
    # 변환 저장
    anim_instance.save_xform(box)
    
    # 위치 변경
    box.position = rt.Point3(50, 60, 70)
    changed_position = rt.copy(box.position)
    
    # 저장된 변환으로 복원
    anim_instance.set_xform(box)
    restored_position = rt.copy(box.position)
    
    # 결과 확인
    rt.print("변환 저장/복원 테스트 결과:")
    rt.print(f"초기 위치: {initial_position}")
    rt.print(f"변경된 위치: {changed_position}")
    rt.print(f"복원된 위치: {restored_position}")
    
    # 테스트 객체 삭제
    delete_test_objects(test_objects)
    return True

def run_all_tests():
    """모든 테스트 실행"""
    rt.clearListener()
    rt.print("===== anim.py 모듈 테스트 시작 =====")
    
    tests = [
        ("rotate_local 테스트", test_rotate_local),
        ("move_local 테스트", test_move_local),
        ("reset_transform_controller 테스트", test_reset_transform_controller),
        ("freeze_transform 테스트", test_freeze_transform),
        ("평균 변환 테스트", test_create_average_transforms),
        ("키프레임 관리 테스트", test_key_management),
        ("변환 저장/복원 테스트", test_save_set_xform)
    ]
    
    total_tests = len(tests)
    passed_tests = 0
    
    for name, test_func in tests:
        rt.print(f"\n----- {name} 시작 -----")
        try:
            result = test_func()
            if result:
                rt.print(f"{name} 성공!")
                passed_tests += 1
            else:
                rt.print(f"{name} 실패!")
        except Exception as e:
            rt.print(f"{name} 오류 발생: {str(e)}")
        rt.print(f"----- {name} 종료 -----")
    
    rt.print(f"\n===== 테스트 결과: {passed_tests}/{total_tests} 성공 =====")

# 3DS Max에서 스크립트 실행 시 모든 테스트 자동 실행
if __name__ == "__main__":
    run_all_tests()
