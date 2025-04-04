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
    
    def rotate_local(self, inObj, rx, ry, rz):
        """
        객체를 로컬 좌표계에서 회전
        
        Args:
            inObj: 회전할 객체
            rx: X축 회전 각도
            ry: Y축 회전 각도
            rz: Z축 회전 각도
        """
        currentMatrix = rt.getProperty(inObj, "transform")
        # MAXScript의 eulertoquat과 eulerAngles를 pymxs로 변환
        eulerAngles = rt.eulerAngles(rx, ry, rz)
        quatRotation = rt.eulertoquat(eulerAngles)
        rt.preRotate(currentMatrix, quatRotation)
        rt.setProperty(inObj, "transform", currentMatrix)
    
    def move_local(self, inObj, mx, my, mz):
        """
        객체를 로컬 좌표계에서 이동
        
        Args:
            inObj: 이동할 객체
            mx: X축 이동 거리
            my: Y축 이동 거리
            mz: Z축 이동 거리
        """
        currentMatrix = rt.getProperty(inObj, "transform")
        # MAXScript의 배열 [mx, my, mz]를 rt.Point3로 변환
        translation = rt.Point3(mx, my, mz)
        rt.preTranslate(currentMatrix, translation)
        rt.setProperty(inObj, "transform", currentMatrix)
    
    def reset_transform_controller(self, inObj):
        """
        객체의 트랜스폼 컨트롤러 초기화
        
        Args:
            inObj: 초기화할 객체
        """
        # Biped_Object가 아닌 경우에만 실행
        if rt.classOf(inObj) != rt.Biped_Object:
            tempTransform = rt.getProperty(inObj, "transform")
            rt.setPropertyController(inObj.controller, "Position", rt.Position_XYZ())
            rt.setPropertyController(inObj.controller, "Rotation", rt.Euler_XYZ())
            rt.setPropertyController(inObj.controller, "Scale", rt.Bezier_Scale())
            inObj.transform = tempTransform
    
    def freeze_transform(self, inObj):
        """
        객체의 변환을 고정
        
        Args:
            inObj: 변환을 고정할 객체
        """
        curObj = inObj
        
        # 로테이션 컨트롤러 고정
        if rt.classOf(rt.getPropertyController(curObj.controller, "Rotation")) != rt.Rotation_list():
            # 로테이션 고정
            rt.setPropertyController(curObj.controller, "Rotation", rt.Rotation_list())
            
            # available 컨트롤러 설정
            rotList = rt.getPropertyController(curObj.controller, "Rotation")
            frozenRotListSlot = rt.getSubAnim(rotList, 1)
            zeroEulerSlot = rt.getSubAnim(rotList, 2)
            
            rt.setPropertyController(frozenRotListSlot, "controller", rt.Euler_xyz())
            rt.setPropertyController(zeroEulerSlot, "controller", rt.Euler_xyz())
            
            # 컨트롤러 이름 설정
            rotList.setname(1, "Frozen Rotation")
            rotList.setname(2, "Zero Euler XYZ")
            
            # 액티브 컨트롤러 설정
            rotList.setActive(2)
        
        # 포지션 컨트롤러 고정
        if rt.classOf(rt.getPropertyController(curObj.controller, "position")) != rt.Position_list():
            # 포지션 고정
            rt.setPropertyController(curObj.controller, "position", rt.Position_list())
            
            # available 컨트롤러 설정
            posList = rt.getPropertyController(curObj.controller, "position")
            frozenPosListSlot = rt.getSubAnim(posList, 1)
            zeroPosSlot = rt.getSubAnim(posList, 2)
            
            rt.setpropertyController(frozenPosListSlot, "controller", rt.Position_XYZ())
            rt.setpropertyController(zeroPosSlot, "controller", rt.Position_XYZ())
            
            # 컨트롤러 이름 설정
            posList.setname(1, "Frozen Position")
            posList.setname(2, "Zero Position XYZ")
            
            # 액티브 컨트롤러 설정
            posList.setActive(2)
            
            # 포지션을 0으로 설정
            zeroPosController = rt.getPropertyController(posList.controller, "Zero Position XYZ")
            rt.setProperty(zeroPosController, "x_Position", 0)
            rt.setProperty(zeroPosController, "y_Position", 0)
            rt.setProperty(zeroPosController, "z_Position", 0)
    
    def collape_anim_transform(self, inObj, startFrame=None, endFrame=None):
        """
        애니메이션 변환 병합
        
        Args:
            inObj: 변환을 병합할 객체
            startFrame: 시작 프레임 (기본값: 애니메이션 범위 시작)
            endFrame: 끝 프레임 (기본값: 애니메이션 범위 끝)
        """
        # 기본값 설정
        if startFrame is None:
            startFrame = rt.animationRange.start
        if endFrame is None:
            endFrame = rt.animationRange.end
            
        # 씬 리드로우 비활성화
        rt.disableSceneRedraw()
        
        # 진행 상태 표시 시작
        progressMessage = f"Collapse transform {inObj.name}..."
        rt.progressStart(progressMessage)
        
        # 포인트 객체 생성
        p = rt.Point()
        
        # 각 프레임에서 변환 정보 저장
        for k in range(startFrame, endFrame + 1):
            # 현재 시간을 k로 설정
            def saveTransformFunc():
                def animateAction():
                    rt.setProperty(p, "transform", rt.getProperty(inObj, "transform"))
                rt.with_animate(on=True, code_to_run=animateAction)
            
            rt.at(rt.time(k), code_to_run=saveTransformFunc)
        
        # 트랜스폼 컨트롤러 설정
        rt.setProperty(inObj, "transform.controller", rt.transformScript())
        rt.setProperty(inObj, "transform.controller", rt.prs())
        
        # 각 프레임에서 변환 적용
        for k in range(startFrame, endFrame + 1):
            # 현재 시간을 k로 설정하고 애니메이션 적용
            def applyTransformFunc():
                def animateAction():
                    # 로테이션 적용
                    rt.execute('in coordsys (transmatrix $.transform.pos) $.rotation = inverse p.transform.rotation')
                    # 포지션 적용
                    rt.execute('in coordsys world $.position = p.transform.position')
                    # 스케일 적용
                    rt.setProperty(inObj, "scale", rt.getProperty(p, "scale"))
                
                rt.with_animate(on=True, code_to_run=animateAction)
            
            rt.at(rt.time(k), code_to_run=applyTransformFunc)
            
            # 진행 상태 업데이트
            rt.progressUpdate(100 * k / endFrame)
        
        # 시작 프레임이 애니메이션 범위 시작과 다르면 불필요한 키 삭제
        if startFrame != rt.animationRange.start:
            rt.execute('deselectKeys $.transform.controller')
            rt.execute(f'selectKeys $.transform.controller {rt.animationRange.start}')
            rt.execute('deleteKeys $.transform.controller #selection')
            rt.execute('deselectKeys $.transform.controller')
        
        # 포인트 객체 삭제
        rt.delete(p)
        
        # 진행 상태 표시 종료 및 씬 리드로우 활성화
        rt.progressEnd()
        rt.enableSceneRedraw()
    
    def match_anim_transform(self, inObj, inTarget, startFrame=None, endFrame=None):
        """
        한 객체의 애니메이션 변환을 다른 객체로 일치시킴
        
        Args:
            inObj: 변환할 객체
            inTarget: 대상 객체
            startFrame: 시작 프레임 (기본값: 애니메이션 범위 시작)
            endFrame: 끝 프레임 (기본값: 애니메이션 범위 끝)
        """
        # 기본값 설정
        if startFrame is None:
            startFrame = rt.animationRange.start
        if endFrame is None:
            endFrame = rt.animationRange.end
            
        # 유효한 노드인지 확인
        if rt.isValidNode(inObj) and rt.isValidNode(inTarget):
            # 씬 리드로우 비활성화
            rt.disableSceneRedraw()
            
            # 진행 상태 표시 시작
            progressMessage = f"Match transform {inObj.name} to {inTarget.name}"
            rt.progressStart(progressMessage)
            
            # 포인트 객체 생성
            p = rt.Point()
            
            # 각 프레임에서 타겟 변환 저장 및 기존 키 삭제
            for k in range(startFrame, endFrame + 1):
                # 현재 시간을 k로 설정하여 타겟 트랜스폼 저장
                def saveTargetTransform():
                    def animateAction():
                        rt.setProperty(p, "transform", rt.getProperty(inTarget, "transform"))
                    rt.with_animate(on=True, code_to_run=animateAction)
                
                rt.at(rt.time(k), code_to_run=saveTargetTransform)
                
                # 해당 프레임의 기존 키 삭제
                rt.execute('deselectKeys $.transform.controller')
                rt.execute(f'selectKeys $.transform.controller {k}')
                rt.execute('deleteKeys $.transform.controller #selection')
                rt.execute('deselectKeys $.transform.controller')
            
            rt.progressUpdate(20)
            
            # 시작 프레임 이전의 불필요한 키 삭제
            if startFrame != rt.animationRange.start:
                rt.execute('deselectKeys p.transform.controller')
                rt.execute(f'selectKeys p.transform.controller {rt.animationRange.start}')
                rt.execute('deleteKeys p.transform.controller #selection')
                rt.execute('deselectKeys p.transform.controller')
            
            rt.progressUpdate(25)
            
            # 키프레임 배열 가져오기
            posKeyArray = rt.getProperty(inTarget, "pos.controller.keys")
            rotKeyArray = rt.getProperty(inTarget, "rotation.controller.keys")
            scaleKeyArray = rt.getProperty(inTarget, "scale.controller.keys")
            
            # 시작과 끝 프레임에 키프레임 설정
            def applyTransformAtTime(timeVal):
                def setTransform():
                    def animateAction():
                        rt.setProperty(inObj, "transform", rt.getProperty(p, "transform"))
                    rt.with_animate(on=True, code_to_run=animateAction)
                rt.at(rt.time(timeVal), code_to_run=setTransform)
            
            applyTransformAtTime(startFrame)
            applyTransformAtTime(endFrame)
            
            # 포지션 키프레임 적용
            for key in posKeyArray:
                keyTime = rt.getProperty(key, "time")
                if keyTime >= startFrame and keyTime <= endFrame:
                    applyTransformAtTime(keyTime)
            
            rt.progressUpdate(40)
            
            # 로테이션 키프레임 적용
            for key in rotKeyArray:
                keyTime = rt.getProperty(key, "time")
                if keyTime >= startFrame and keyTime <= endFrame:
                    applyTransformAtTime(keyTime)
            
            rt.progressUpdate(60)
            
            # 스케일 키프레임 적용
            for key in scaleKeyArray:
                keyTime = rt.getProperty(key, "time")
                if keyTime >= startFrame and keyTime <= endFrame:
                    applyTransformAtTime(keyTime)
            
            rt.progressUpdate(80)
            
            # 포인트 객체 삭제
            rt.delete(p)
            
            # 진행 상태 표시 완료 및 업데이트
            rt.progressUpdate(100)
            rt.progressEnd()
            rt.enableSceneRedraw()
    
    def create_average_pos_transform(self, inTargetArray):
        """
        여러 객체의 평균 위치 변환 생성
        
        Args:
            inTargetArray: 대상 객체 배열
            
        Returns:
            평균 위치 변환
        """
        # 포인트 객체 생성
        posConstDum = rt.Point()
        
        # 포지션 제약 컨트롤러 생성
        targetPosConstraint = rt.Position_Constraint()
        
        # 타겟 가중치 계산
        targetWeight = 100.0 / (len(inTargetArray) + 1)
        
        # 포지션 컨트롤러 설정
        rt.setPropertyController(posConstDum.controller, "Position", targetPosConstraint)
        
        # 각 타겟 추가
        for item in inTargetArray:
            targetPosConstraint.appendTarget(item, targetWeight)
        
        # 변환 정보 복사
        returnTransform = rt.copy(rt.getProperty(posConstDum, "transform"))
        
        # 포인트 객체 삭제
        rt.delete(posConstDum)
        
        return returnTransform
    
    def create_average_rot_transform(self, inTargetArray):
        """
        여러 객체의 평균 회전 변환 생성
        
        Args:
            inTargetArray: 대상 객체 배열
            
        Returns:
            평균 회전 변환
        """
        # 포인트 객체 생성
        rotConstDum = rt.Point()
        
        # 방향 제약 컨트롤러 생성
        targetOriConstraint = rt.Orientation_Constraint()
        
        # 타겟 가중치 계산
        targetWeight = 100.0 / (len(inTargetArray) + 1)
        
        # 로테이션 컨트롤러 설정
        rt.setPropertyController(rotConstDum.controller, "Rotation", targetOriConstraint)
        
        # 각 타겟 추가
        for item in inTargetArray:
            targetOriConstraint.appendTarget(item, targetWeight)
        
        # 변환 정보 복사
        returnTransform = rt.copy(rt.getProperty(rotConstDum, "transform"))
        
        # 포인트 객체 삭제
        rt.delete(rotConstDum)
        
        return returnTransform
    
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
    
    def save_xform(self, inObjs):
        """
        객체의 변환 저장
        
        Args:
            inObjs: 변환을 저장할 객체
        """
        try:
            # 월드 스페이스 매트릭스 저장
            transformString = str(rt.getProperty(inObjs, "transform"))
            rt.setUserProp(inObjs, rt.Name("WorldSpaceMatrix"), transformString)
            
            # 부모가 있는 경우 부모 스페이스 매트릭스 저장
            parent = rt.getProperty(inObjs, "parent")
            if parent is not None:
                parentTransform = rt.getProperty(parent, "transform")
                inverseParent = rt.inverse(parentTransform)
                objTransform = rt.getProperty(inObjs, "transform")
                parentSpaceMatrix = objTransform * inverseParent
                rt.setUserProp(inObjs, rt.Name("ParentSpaceMatrix"), str(parentSpaceMatrix))
        except:
            # 오류 발생 시 무시
            pass
    
    def set_xform(self, inObjs, space="#World"):
        """
        객체의 변환 설정
        
        Args:
            inObjs: 변환을 설정할 객체
            space: 공간 (기본값: "#World")
        """
        try:
            if space == "#World":
                # 월드 스페이스 매트릭스 적용
                matrixString = rt.getUserProp(inObjs, rt.Name("WorldSpaceMatrix"))
                transformMatrix = rt.execute(f"execute({matrixString})")
                rt.setProperty(inObjs, "transform", transformMatrix)
            elif space == "#Parent":
                # 부모 스페이스 매트릭스 적용
                matrixString = rt.getUserProp(inObjs, rt.Name("ParentSpaceMatrix"))
                parentSpaceMatrix = rt.execute(f"execute({matrixString})")
                if parent is not None:
                    parentTransform = rt.getProperty(parent, "transform")
                    transformMatrix = parentSpaceMatrix * parentTransform
                    rt.setProperty(inObjs, "transform", transformMatrix)
        except:
            # 오류 발생 시 무시
            pass
