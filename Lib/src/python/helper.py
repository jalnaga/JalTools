#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Helper 모듈 - 헬퍼 객체 생성 및 관리 기능
원본 MAXScript의 helper.ms에서 변환됨
"""


class Helper:
    """
    헬퍼 객체 관련 기능을 위한 클래스
    MAXScript의 _Helper 구조체를 Python 클래스로 변환
    
    참고: 일부 3ds Max 고유 기능은 Python에서 동등한 구현이 불가능하므로,
    해당 메서드들은 패스 함수로 구현되거나 주석으로 처리되었습니다.
    """
    
    def __init__(self):
        """초기화 함수"""
        # name 속성은 외부에서 주입됨 (JalLib 초기화 시)
        self.name = None
    
    def create_point(self, in_name, size=2, box_toggle=False, cross_toggle=True, point_color=(14, 255, 2), pos=(0, 0, 0)):
        """
        포인트 헬퍼 생성
        
        Args:
            in_name: 헬퍼 이름
            size: 헬퍼 크기
            box_toggle: 박스 표시 여부
            cross_toggle: 십자 표시 여부
            point_color: 색상
            pos: 위치
            
        Returns:
            생성된 포인트 헬퍼
        """
        # 3ds Max 전용 기능 - Python에서는 구현 생략
        # MAXScript 원본:
        # local returnPoint
        # returnPoint = point()
        # returnPoint.size = size
        # returnPoint.box = boxToggle
        # returnPoint.cross = crossToggle
        # returnPoint.wireColor = pointColor
        # returnPoint.name = inName
        # returnPoint.pos = pos
        # returnPoint.centermarker = off
        # returnPoint.axistripod = off
        # return returnPoint
        
        # Python 더미 구현:
        class DummyPoint:
            def __init__(self):
                self.name = in_name
                self.size = size
                self.box = box_toggle
                self.cross = cross_toggle
                self.wireColor = point_color
                self.pos = pos
                self.centermarker = False
                self.axistripod = False
                self.transform = None
        
        return DummyPoint()
    
    def create_empty_point(self, in_name):
        """
        빈 포인트 헬퍼 생성
        
        Args:
            in_name: 헬퍼 이름
            
        Returns:
            생성된 빈 포인트 헬퍼
        """
        # MAXScript 원본:
        # local returnPoint = create_point inName size:0 crossToggle:off
        # returnPoint.centermarker = off
        # returnPoint.axistripod = off
        # freeze returnPoint
        # return returnPoint
        
        return_point = self.create_point(in_name, size=0, cross_toggle=False)
        return_point.centermarker = False
        return_point.axistripod = False
        # freeze 함수는 Python에서는 생략
        
        return return_point
    
    def gen_helper_name_from_obj(self, in_obj, make_two=False, is_exp=False):
        """
        객체로부터 헬퍼 이름 생성
        
        Args:
            in_obj: 원본 객체
            make_two: 두 개의 이름 생성 여부
            is_exp: ExposeTM 타입 여부
            
        Returns:
            생성된 헬퍼 이름 배열 [포인트 이름, 타겟 이름]
        """
        point_name = ""
        target_name = ""
        
        # 타입 설정
        type_name = self.name.get_dummy_str()
        if is_exp:
            type_name = self.name.get_expose_tm_str()
        
        # 이름 생성
        temp_name = self.name.replace_type(in_obj.name, type_name)
        if self.name.get_type(in_obj.name) == type_name:
            temp_name = self.name.increase_index(temp_name, 1)
        
        point_name = temp_name
        
        # 타겟 이름 생성
        if make_two:
            target_name = self.name.add_sufix_to_real_name(temp_name, "Tgt")
        
        return [point_name, target_name]
    
    def gen_helper_shape_from_obj(self, in_obj):
        """
        객체로부터 헬퍼 형태 생성
        
        Args:
            in_obj: 원본 객체
            
        Returns:
            [헬퍼 크기, 십자 표시 여부, 박스 표시 여부]
        """
        # 3ds Max 전용 기능 - Python에서는 일부 구현 생략
        # MAXScript 원본:
        # local helperSize = 2.0
        # local crossToggle = false
        # local boxToggle = true
        # if (classOf inObj) == BoneGeometry then helperSize = amax #(inObj.width, inObj.height)
        # if ((classOf inObj) == Point) or ((classOf inObj) == ExposeTm) then (
        #     ...
        # )
        
        helper_size = 2.0
        cross_toggle = False
        box_toggle = True
        
        # 클래스 체크는 Python에서 다르게 구현해야 함
        # 여기서는 간단하게 속성 검사로 구현
        
        # Point나 ExposeTm 타입 처리
        if hasattr(in_obj, 'size') and hasattr(in_obj, 'cross') and hasattr(in_obj, 'box'):
            helper_size = in_obj.size + 0.5
            if in_obj.cross:
                cross_toggle = False
                box_toggle = True
            if in_obj.box:
                cross_toggle = True
                box_toggle = False
        
        return [helper_size, cross_toggle, box_toggle]
    
    def create_helper(self, make_two=False):
        """
        헬퍼 생성
        
        Args:
            make_two: 두 개의 헬퍼 생성 여부
            
        Returns:
            생성된 헬퍼 배열
        """
        # 3ds Max 전용 기능 - Python에서는 구현 생략
        # MAXScript 원본:
        # local createdHelperArray = #()
        # if selection.count > 0 then (
        #     ...
        # )
        # else (
        #     local genPoint = Point wirecolor:(color 14 255 2)
        #     append createdHelperArray genPoint
        # )
        # select createdHelperArray
        # return createdHelperArray
        
        # Python 더미 구현:
        created_helper_array = []
        # 실제 구현은 생략
        return created_helper_array
    
    def create_parent_helper(self):
        """
        부모 헬퍼 생성
        """
        # 3ds Max 전용 기능 - Python에서는 구현 생략
        # MAXScript 원본:
        # if selection.count > 0 then (
        #     local selArray = getCurrentSelection()
        #     ...
        # )
        pass
    
    def create_exp_tm(self):
        """
        ExposeTM 헬퍼 생성
        
        Returns:
            생성된 ExposeTM 헬퍼 배열
        """
        # 3ds Max 전용 기능 - Python에서는 구현 생략
        # MAXScript 원본:
        # local createdHelperArray = #()
        # if selection.count > 0 then (
        #     ...
        # )
        # else (
        #     local genPoint = exposeTM wirecolor:(color 14 255 2)
        #     append createdHelperArray genPoint
        # )
        # select createdHelperArray
        # return createdHelperArray
        
        # Python 더미 구현:
        created_helper_array = []
        # 실제 구현은 생략
        return created_helper_array
    
    def set_size(self, in_obj, in_new_size):
        """
        헬퍼 크기 설정
        
        Args:
            in_obj: 대상 객체
            in_new_size: 새 크기
            
        Returns:
            설정된 객체
        """
        # 3ds Max 전용 기능 - Python에서는 구현 생략
        # MAXScript 원본:
        # if superClassOf inObj == helper then (
        #     inObj.size = inNewSize
        #     inObj
        # )
        
        # Python 더미 구현:
        if hasattr(in_obj, 'size'):
            in_obj.size = in_new_size
        return in_obj
    
    def add_size(self, in_obj, in_add_size):
        """
        헬퍼 크기 증가
        
        Args:
            in_obj: 대상 객체
            in_add_size: 증가할 크기
            
        Returns:
            설정된 객체
        """
        # 3ds Max 전용 기능 - Python에서는 구현 생략
        # MAXScript 원본:
        # if superClassOf inObj == helper then (
        #     inObj.size += inAddSize
        #     inObj
        # )
        
        # Python 더미 구현:
        if hasattr(in_obj, 'size'):
            in_obj.size += in_add_size
        return in_obj
    
    def set_shape_to_center(self, in_obj):
        """
        형태를 센터 마커로 설정
        
        Args:
            in_obj: 대상 객체
        """
        # 3ds Max 전용 기능 - Python에서는 구현 생략
        # MAXScript 원본:
        # if (classOf inObj == ExposeTm) or (classOf inObj == Point) then (
        #     inObj.centermarker = true
        #     inObj.box = true
        #     inObj.axistripod = false
        #     inObj.cross = false
        # )
        
        # Python 더미 구현:
        if hasattr(in_obj, 'centermarker') and hasattr(in_obj, 'box'):
            in_obj.centermarker = True
            in_obj.box = True
            in_obj.axistripod = False
            in_obj.cross = False
    
    def set_shape_to_axis(self, in_obj):
        """
        형태를 축 마커로 설정
        
        Args:
            in_obj: 대상 객체
        """
        # 3ds Max 전용 기능 - Python에서는 구현 생략
        # MAXScript 원본:
        # if (classOf inObj == ExposeTm) or (classOf inObj == Point) then (
        #     inObj.axistripod = true
        #     inObj.centermarker = false
        #     inObj.box = false
        #     inObj.cross = false
        # )
        
        # Python 더미 구현:
        if hasattr(in_obj, 'axistripod'):
            in_obj.axistripod = True
            in_obj.centermarker = False
            in_obj.box = False
            in_obj.cross = False
    
    def set_shape_to_cross(self, in_obj):
        """
        형태를 십자 마커로 설정
        
        Args:
            in_obj: 대상 객체
        """
        # 3ds Max 전용 기능 - Python에서는 구현 생략
        # MAXScript 원본:
        # if (classOf inObj == ExposeTm) or (classOf inObj == Point) then (
        #     inObj.cross = true
        #     inObj.box = false
        #     inObj.centermarker = false
        #     inObj.axistripod = false
        # )
        
        # Python 더미 구현:
        if hasattr(in_obj, 'cross'):
            in_obj.cross = True
            in_obj.box = False
            in_obj.centermarker = False
            in_obj.axistripod = False
    
    def set_shape_to_box(self, in_obj):
        """
        형태를 박스 마커로 설정
        
        Args:
            in_obj: 대상 객체
        """
        # 3ds Max 전용 기능 - Python에서는 구현 생략
        # MAXScript 원본:
        # if (classOf inObj == ExposeTm) or (classOf inObj == Point) then (
        #     inObj.box = true
        #     inObj.centermarker = false
        #     inObj.axistripod = false
        #     inObj.cross = false
        # )
        
        # Python 더미 구현:
        if hasattr(in_obj, 'box'):
            in_obj.box = True
            in_obj.centermarker = False
            in_obj.axistripod = False
            in_obj.cross = False
