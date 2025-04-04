#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Animation 모듈 - 애니메이션 관련 기능
원본 MAXScript의 anim.ms에서 변환됨
pymxs 모듈을 사용하여 3DS Max에서 실행 가능하도록 구현
"""

import math
import copy
from pymxs import runtime as rt


class Anim:
    """
    애니메이션 관련 기능을 위한 클래스
    MAXScript의 _Anim 구조체를 Python 클래스로 변환
    pymxs 모듈을 통해 3ds Max 기능을 구현
    """
    
    def __init__(self):
        """초기화 함수"""
        pass
    
    def rotate_local(self, in_obj, rx, ry, rz):
        """
        객체를 로컬 좌표계에서 회전
        
        Args:
            in_obj: 회전할 객체
            rx: X축 회전 각도
            ry: Y축 회전 각도
            rz: Z축 회전 각도
        """
        current_matrix = rt.getProperty(in_obj, "transform")
        # MAXScript의 eulertoquat과 eulerAngles를 pymxs로 변환
        euler_angles = rt.eulerAngles(rx, ry, rz)
        quat_rotation = rt.eulertoquat(euler_angles)
        rt.preRotate(current_matrix, quat_rotation)
        rt.setProperty(in_obj, "transform", current_matrix)
    
    def move_local(self, in_obj, mx, my, mz):
        """
        객체를 로컬 좌표계에서 이동
        
        Args:
            in_obj: 이동할 객체
            mx: X축 이동 거리
            my: Y축 이동 거리
            mz: Z축 이동 거리
        """
        current_matrix = rt.getProperty(in_obj, "transform")
        # MAXScript의 배열 [mx, my, mz]를 rt.Point3로 변환
        translation = rt.Point3(mx, my, mz)
        rt.preTranslate(current_matrix, translation)
        rt.setProperty(in_obj, "transform", current_matrix)
    
    def reset_transform_controller(self, in_obj):
        """
        객체의 트랜스폼 컨트롤러 초기화
        
        Args:
            in_obj: 초기화할 객체
        """
        # Biped_Object가 아닌 경우에만 실행
        if rt.classOf(in_obj) != rt.Biped_Object:
            temp_transform = rt.getProperty(in_obj, "transform")
            rt.setPropertyController(in_obj.controller, "Position", rt.Position_XYZ())
            rt.setPropertyController(in_obj.controller, "Rotation", rt.Euler_XYZ())
            rt.setPropertyController(in_obj.controller, "Scale", rt.Bezier_Scale())
            in_obj.transform = temp_transform
    
    def freeze_transform(self, in_obj):
        """
        객체의 변환을 고정
        
        Args:
            in_obj: 변환을 고정할 객체
        """
        cur_obj = in_obj
        
        # 로테이션 컨트롤러 고정
        if rt.classOf(rt.getPropertyController(cur_obj.controller, "Rotation")) != rt.Rotation_list():
            # 로테이션 고정
            rt.setPropertyController(cur_obj.controller, "Rotation", rt.Euler_Xyz())
            rt.setPropertyController(cur_obj.controller, "Rotation", rt.Rotation_list())
            
            # available 컨트롤러 설정
            rot_controller = rt.getPropertyController(cur_obj.controller, "Rotation")
            rt.setPropertyController(rot_controller, "available", rt.Euler_xyz())
            
            # 컨트롤러 이름 설정
            rt.execute('$.rotation.controller.setname 1 "Frozen Rotation"')
            rt.execute('$.rotation.controller.setname 2 "Zero Euler XYZ"')
            
            # 액티브 컨트롤러 설정
            rt.execute('$.rotation.controller.SetActive 2')
        
        # 포지션 컨트롤러 고정
        if rt.classOf(rt.getPropertyController(cur_obj.controller, "position")) != rt.Position_list():
            # 포지션 고정
            rt.setPropertyController(cur_obj.controller, "position", rt.Bezier_Position())
            rt.setPropertyController(cur_obj.controller, "position", rt.Position_list())
            
            # available 컨트롤러 설정
            pos_controller = rt.getPropertyController(cur_obj.controller, "position")
            rt.setPropertyController(pos_controller, "available", rt.Position_XYZ())
            
            # 컨트롤러 이름 설정
            rt.execute('$.position.controller.setname 1 "Frozen Position"')
            rt.execute('$.position.controller.setname 2 "Zero Pos XYZ"')
            
            # 액티브 컨트롤러 설정
            rt.execute('$.position.controller.SetActive 2')
            
            # 포지션을 0으로 설정
            pos_controller2 = rt.execute("$.position.controller[2]")
            rt.setProperty(pos_controller2, "x_Position", 0)
            rt.setProperty(pos_controller2, "y_Position", 0)
            rt.setProperty(pos_controller2, "z_Position", 0)
    
    def collape_anim_transform(self, in_obj, start_frame=None, end_frame=None):
        """
        애니메이션 변환 병합
        
        Args:
            in_obj: 변환을 병합할 객체
            start_frame: 시작 프레임 (기본값: 애니메이션 범위 시작)
            end_frame: 끝 프레임 (기본값: 애니메이션 범위 끝)
        """
        # 기본값 설정
        if start_frame is None:
            start_frame = rt.animationRange.start
        if end_frame is None:
            end_frame = rt.animationRange.end
            
        # 씬 리드로우 비활성화
        rt.disableSceneRedraw()
        
        # 진행 상태 표시 시작
        progress_message = f"Collapse transform {in_obj.name}..."
        rt.progressStart(progress_message)
        
        # 포인트 객체 생성
        p = rt.Point()
        
        # 각 프레임에서 변환 정보 저장
        for k in range(start_frame, end_frame + 1):
            # 현재 시간을 k로 설정
            def save_transform_func():
                def animate_action():
                    rt.setProperty(p, "transform", rt.getProperty(in_obj, "transform"))
                rt.with_animate(on=True, code_to_run=animate_action)
            
            rt.at(rt.time(k), code_to_run=save_transform_func)
        
        # 트랜스폼 컨트롤러 설정
        rt.setProperty(in_obj, "transform.controller", rt.transform_script())
        rt.setProperty(in_obj, "transform.controller", rt.prs())
        
        # 각 프레임에서 변환 적용
        for k in range(start_frame, end_frame + 1):
            # 현재 시간을 k로 설정하고 애니메이션 적용
            def apply_transform_func():
                def animate_action():
                    # 로테이션 적용
                    rt.execute('in coordsys (transmatrix $.transform.pos) $.rotation = inverse p.transform.rotation')
                    # 포지션 적용
                    rt.execute('in coordsys world $.position = p.transform.position')
                    # 스케일 적용
                    rt.setProperty(in_obj, "scale", rt.getProperty(p, "scale"))
                
                rt.with_animate(on=True, code_to_run=animate_action)
            
            rt.at(rt.time(k), code_to_run=apply_transform_func)
            
            # 진행 상태 업데이트
            rt.progressUpdate(100 * k / end_frame)
        
        # 시작 프레임이 애니메이션 범위 시작과 다르면 불필요한 키 삭제
        if start_frame != rt.animationRange.start:
            rt.execute('deselectKeys $.transform.controller')
            rt.execute(f'selectKeys $.transform.controller {rt.animationRange.start}')
            rt.execute('deleteKeys $.transform.controller #selection')
            rt.execute('deselectKeys $.transform.controller')
        
        # 포인트 객체 삭제
        rt.delete(p)
        
        # 진행 상태 표시 종료 및 씬 리드로우 활성화
        rt.progressEnd()
        rt.enableSceneRedraw()
    
    def match_anim_transform(self, in_obj, in_target, start_frame=None, end_frame=None):
        """
        한 객체의 애니메이션 변환을 다른 객체로 일치시킴
        
        Args:
            in_obj: 변환할 객체
            in_target: 대상 객체
            start_frame: 시작 프레임 (기본값: 애니메이션 범위 시작)
            end_frame: 끝 프레임 (기본값: 애니메이션 범위 끝)
        """
        # 기본값 설정
        if start_frame is None:
            start_frame = rt.animationRange.start
        if end_frame is None:
            end_frame = rt.animationRange.end
            
        # 유효한 노드인지 확인
        if rt.isValidNode(in_obj) and rt.isValidNode(in_target):
            # 씬 리드로우 비활성화
            rt.disableSceneRedraw()
            
            # 진행 상태 표시 시작
            progress_message = f"Match transform {in_obj.name} to {in_target.name}"
            rt.progressStart(progress_message)
            
            # 포인트 객체 생성
            p = rt.Point()
            
            # 각 프레임에서 타겟 변환 저장 및 기존 키 삭제
            for k in range(start_frame, end_frame + 1):
                # 현재 시간을 k로 설정하여 타겟 트랜스폼 저장
                def save_target_transform():
                    def animate_action():
                        rt.setProperty(p, "transform", rt.getProperty(in_target, "transform"))
                    rt.with_animate(on=True, code_to_run=animate_action)
                
                rt.at(rt.time(k), code_to_run=save_target_transform)
                
                # 해당 프레임의 기존 키 삭제
                rt.execute('deselectKeys $.transform.controller')
                rt.execute(f'selectKeys $.transform.controller {k}')
                rt.execute('deleteKeys $.transform.controller #selection')
                rt.execute('deselectKeys $.transform.controller')
            
            rt.progressUpdate(20)
            
            # 시작 프레임 이전의 불필요한 키 삭제
            if start_frame != rt.animationRange.start:
                rt.execute('deselectKeys p.transform.controller')
                rt.execute(f'selectKeys p.transform.controller {rt.animationRange.start}')
                rt.execute('deleteKeys p.transform.controller #selection')
                rt.execute('deselectKeys p.transform.controller')
            
            rt.progressUpdate(25)
            
            # 키프레임 배열 가져오기
            pos_key_array = rt.getProperty(in_target, "pos.controller.keys")
            rot_key_array = rt.getProperty(in_target, "rotation.controller.keys")
            scale_key_array = rt.getProperty(in_target, "scale.controller.keys")
            
            # 시작과 끝 프레임에 키프레임 설정
            def apply_transform_at_time(time_val):
                def set_transform():
                    def animate_action():
                        rt.setProperty(in_obj, "transform", rt.getProperty(p, "transform"))
                    rt.with_animate(on=True, code_to_run=animate_action)
                rt.at(rt.time(time_val), code_to_run=set_transform)
            
            apply_transform_at_time(start_frame)
            apply_transform_at_time(end_frame)
            
            # 포지션 키프레임 적용
            for key in pos_key_array:
                key_time = rt.getProperty(key, "time")
                if key_time >= start_frame and key_time <= end_frame:
                    apply_transform_at_time(key_time)
            
            rt.progressUpdate(40)
            
            # 로테이션 키프레임 적용
            for key in rot_key_array:
                key_time = rt.getProperty(key, "time")
                if key_time >= start_frame and key_time <= end_frame:
                    apply_transform_at_time(key_time)
            
            rt.progressUpdate(60)
            
            # 스케일 키프레임 적용
            for key in scale_key_array:
                key_time = rt.getProperty(key, "time")
                if key_time >= start_frame and key_time <= end_frame:
                    apply_transform_at_time(key_time)
            
            rt.progressUpdate(80)
            
            # 포인트 객체 삭제
            rt.delete(p)
            
            # 진행 상태 표시 완료 및 업데이트
            rt.progressUpdate(100)
            rt.progressEnd()
            rt.enableSceneRedraw()
    
    def create_average_pos_transform(self, in_target_array):
        """
        여러 객체의 평균 위치 변환 생성
        
        Args:
            in_target_array: 대상 객체 배열
            
        Returns:
            평균 위치 변환
        """
        # 포인트 객체 생성
        pos_const_dum = rt.Point()
        
        # 포지션 제약 컨트롤러 생성
        target_pos_constraint = rt.Position_Constraint()
        
        # 타겟 가중치 계산
        target_weight = 100.0 / (len(in_target_array) + 1)
        
        # 포지션 컨트롤러 설정
        rt.setProperty(pos_const_dum, "position.controller", target_pos_constraint)
        
        # 각 타겟 추가
        for item in in_target_array:
            target_pos_constraint.appendTarget(item, target_weight)
        
        # 변환 정보 복사
        return_transform = rt.copy(rt.getProperty(pos_const_dum, "transform"))
        
        # 포인트 객체 삭제
        rt.delete(pos_const_dum)
        
        return return_transform
    
    def create_average_rot_transform(self, in_target_array):
        """
        여러 객체의 평균 회전 변환 생성
        
        Args:
            in_target_array: 대상 객체 배열
            
        Returns:
            평균 회전 변환
        """
        # 포인트 객체 생성
        rot_const_dum = rt.Point()
        
        # 방향 제약 컨트롤러 생성
        target_ori_constraint = rt.Orientation_Constraint()
        
        # 타겟 가중치 계산
        target_weight = 100.0 / (len(in_target_array) + 1)
        
        # 로테이션 컨트롤러 설정
        rt.setProperty(rot_const_dum, "rotation.controller", target_ori_constraint)
        
        # 각 타겟 추가
        for item in in_target_array:
            target_ori_constraint.appendTarget(item, target_weight)
        
        # 변환 정보 복사
        return_transform = rt.copy(rt.getProperty(rot_const_dum, "transform"))
        
        # 포인트 객체 삭제
        rt.delete(rot_const_dum)
        
        return return_transform
    
    def get_all_keys(self, obj=None):
        """
        모든 키프레임 가져오기
        
        Args:
            obj: 객체 (기본값: None - 모든 객체)
            
        Returns:
            키프레임 목록
        """
        # undo 기능 비활성화
        with rt.undoDisabled():
            # 객체가 지정되지 않은 경우 모든 객체 사용
            if obj is None:
                obj = rt.objects
            
            # 키 수집 함수 정의 및 실행
            # MAXScript: mapkeys obj (fn CollectKeys t k = (append k t; t)) (keys=#()) #allkeys
            # 해당 코드는 직접 실행으로 구현
            keys = rt.execute("""
            fn getKeys obj = (
                keys = #()
                mapkeys obj (fn CollectKeys t k = (append k t; t)) (keys=#()) #allkeys
                return keys
            )
            getKeys selection
            """)
            
            return keys if keys else []
    
    def get_start_end_keys(self, obj=None):
        """
        시작과 끝 키프레임 가져오기
        
        Args:
            obj: 객체 (기본값: None - 모든 객체)
            
        Returns:
            [시작 키프레임, 끝 키프레임]
        """
        # undo 기능 비활성화
        with rt.undoDisabled():
            # 모든 키 가져오기
            keys = self.get_all_keys(obj)
            
            # 키가 존재하는 경우 최소/최대값 반환
            if keys and len(keys) > 0:
                return [rt.amin(keys), rt.amax(keys)]
            else:
                return [0, 0]
    
    def delete_all_keys(self, obj=None):
        """
        모든 키프레임 삭제
        
        Args:
            obj: 객체 (기본값: None - 모든 객체)
        """
        # 객체가 지정되지 않은 경우 모든 객체 사용
        if obj is None:
            obj = rt.objects
        
        # 모든 키 삭제
        rt.deleteKeys(obj, rt.Name('allKeys'))
    
    def is_node_animated(self, node):
        """
        노드에 애니메이션이 적용되어 있는지 확인
        
        Args:
            node: 확인할 노드
            
        Returns:
            애니메이션 적용 여부 (True/False)
        """
        # MAXScript 코드를 직접 실행하여 노드 애니메이션 확인
        script = """
        fn isNodeAnimated node = (
            local animated = false
            local object = node
            
            if iskindof node SubAnim do (
                animated = (node.keys != undefined) and (node.keys.count > 0)
                object = node.object
            )
            
            if iskindof object maxwrapper do 
                for ca in object.custattributes while not animated do 
                    animated = isNodeAnimated ca
            
            for k=1 to node.numsubs while not animated do 
                animated = isNodeAnimated node[k]
            
            animated
        )
        
        isNodeAnimated $.controller
        """
        
        try:
            result = rt.execute(script)
            return result
        except:
            # 오류 발생 시 False 반환
            return False
    
    def find_animated_nodes(self, nodes=None):
        """
        애니메이션이 적용된 노드 찾기
        
        Args:
            nodes: 검색할 노드 배열 (기본값: None - 모든 객체)
            
        Returns:
            애니메이션이 적용된 노드 배열
        """
        # 객체가 지정되지 않은 경우 모든 객체 사용
        if nodes is None:
            nodes = rt.objects
        
        result = []
        # 각 노드에 대해 애니메이션 적용 여부 확인
        for node in nodes:
            if self.is_node_animated(node):
                result.append(node)
        
        return result
    
    def find_animated_material_nodes(self, nodes=None):
        """
        애니메이션이 적용된 재질을 가진 노드 찾기
        
        Args:
            nodes: 검색할 노드 배열 (기본값: None - 모든 객체)
            
        Returns:
            애니메이션이 적용된 재질을 가진 노드 배열
        """
        # 객체가 지정되지 않은 경우 모든 객체 사용
        if nodes is None:
            nodes = rt.objects
        
        result = []
        # 각 노드에 대해 재질 애니메이션 적용 여부 확인
        for node in nodes:
            mat = rt.getProperty(node, "mat")
            if mat is not None and self.is_node_animated(mat):
                result.append(node)
        
        return result
    
    def find_animated_transform_nodes(self, nodes=None):
        """
        애니메이션이 적용된 변환을 가진 노드 찾기
        
        Args:
            nodes: 검색할 노드 배열 (기본값: None - 모든 객체)
            
        Returns:
            애니메이션이 적용된 변환을 가진 노드 배열
        """
        # 객체가 지정되지 않은 경우 모든 객체 사용
        if nodes is None:
            nodes = rt.objects
        
        result = []
        # 각 노드에 대해 변환 컨트롤러 애니메이션 적용 여부 확인
        for node in nodes:
            controller = rt.getProperty(node, "controller")
            if self.is_node_animated(controller):
                result.append(node)
        
        return result
    
    def save_xform(self, in_objs):
        """
        객체의 변환 저장
        
        Args:
            in_objs: 변환을 저장할 객체
        """
        try:
            # 월드 스페이스 매트릭스 저장
            transform_string = str(rt.getProperty(in_objs, "transform"))
            rt.setUserProp(in_objs, rt.Name("WorldSpaceMatrix"), transform_string)
            
            # 부모가 있는 경우 부모 스페이스 매트릭스 저장
            parent = rt.getProperty(in_objs, "parent")
            if parent is not None:
                parent_transform = rt.getProperty(parent, "transform")
                inverse_parent = rt.inverse(parent_transform)
                obj_transform = rt.getProperty(in_objs, "transform")
                parent_space_matrix = obj_transform * inverse_parent
                rt.setUserProp(in_objs, rt.Name("ParentSpaceMatrix"), str(parent_space_matrix))
        except:
            # 오류 발생 시 무시
            pass
    
    def set_xform(self, in_objs, space="#World"):
        """
        객체의 변환 설정
        
        Args:
            in_objs: 변환을 설정할 객체
            space: 공간 (기본값: "#World")
        """
        try:
            if space == "#World":
                # 월드 스페이스 매트릭스 적용
                matrix_string = rt.getUserProp(in_objs, rt.Name("WorldSpaceMatrix"))
                transform_matrix = rt.execute(f"execute({matrix_string})")
                rt.setProperty(in_objs, "transform", transform_matrix)
            elif space == "#Parent":
                # 부모 스페이스 매트릭스 적용
                matrix_string = rt.getUserProp(in_objs, rt.Name("ParentSpaceMatrix"))
                parent_space_matrix = rt.execute(f"execute({matrix_string})")
                if parent is not None:
                    parent_transform = rt.getProperty(parent, "transform")
                    transform_matrix = parent_space_matrix * parent_transform
                    rt.setProperty(in_objs, "transform", transform_matrix)
        except:
            # 오류 발생 시 무시
            pass
