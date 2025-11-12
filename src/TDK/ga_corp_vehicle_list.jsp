<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>법인차량 조회</title>
    <%@include file="/WEB-INF/jsp/common.jsp" %>
    <style>
		/*#masterGrid{height:744px;width: 476px;}
        .content_inner_v2{
            padding:20px 32px;
            min-height: 0;
        }*/

        .form_object_img .profile_img_section {
            width: 165px;
            height: 165px;
        }
    </style>
</head>
<body>
<div class="contents_wrap">
	<div class="contents_header_top">
        <h3 class="list_title"></h3>
    </div>
    <div class="contents_header half_header">
        <div class="content_header_inner">
            <div class="form_object w283">
                <input class="form_inp0_v2" type="text" id="VEHICLE_NO" name="VEHICLE_NO" autocomplete="off">
                <label class="label_inp0_v2" for="VEHICLE_NO">${fn:escapeXml(emax:word("차량번호"))}</label>
            </div>
            <div class="form_object w283">
                <input type="hidden" id="MANAGE_DEPARTMENT_ID" name="MANAGE_DEPARTMENT_ID">
                <input class="form_pop1_v2" type="text" id="MANAGE_DEPARTMENT_NAME" name="MANAGE_DEPARTMENT_NAME" onChange="javascript:f_formChange(this);" onfocusin="gf_focusing(this);">
                <button class="form_popup_btn_v2" type="button" data-pop="true" data-id="MANAGE_DEPARTMENT_NAME"></button>
                <label class="label_inp0_v2" for="MANAGE_DEPARTMENT_NAME">${fn:escapeXml(emax:word("관리부서"))}</label>
            </div>
            <div class="form_object w283">
                <input type="hidden" id="USE_DEPARTMENT_ID" name="USE_DEPARTMENT_ID">
                <input class="form_pop1_v2" type="text" id="USE_DEPARTMENT_NAME" name="USE_DEPARTMENT_NAME" onChange="javascript:f_formChange(this);" onfocusin="gf_focusing(this);">
                <button class="form_popup_btn_v2" type="button" data-pop="true" data-id="USE_DEPARTMENT_NAME"></button>
                <label class="label_inp0_v2" for="USE_DEPARTMENT_NAME">${fn:escapeXml(emax:word("사용부서"))}</label>
            </div>
            <div class="form_object w283 drop_box" name="S_OWN_DIVISION_CODE_DIV" id="S_OWN_DIVISION_CODE_DIV">
                <label class="label_inp0_v2" for="S_OWN_DIVISION_CODE_DIV">${fn:escapeXml(emax:word("소유구분"))}</label>
                <input type="hidden" id="S_OWN_DIVISION_CODE" name="S_OWN_DIVISION_CODE" value="" />
                <input type="text" name="S_OWN_DIVISION_CODE_DIV_TEXT" id="S_OWN_DIVISION_CODE_DIV_TEXT" value="" data-prev-val="" class="drop_box_inp" autocomplete="off" placeholder="" />
                <button type="button" class="drop_box_btn"></button>
                <ul class="drop_box_list"></ul>
            </div>
<%--                 <div class="form_object w283">
                <input class="form_inp0_v2" type="text" id="S_NICKNAME" name="S_NICKNAME">
                <label class="label_inp0_v2" for="S_NICKNAME">${fn:escapeXml(emax:word("닉네임"))}</label>

            </div> --%>
            <div class="form_object w283">
                <input class="form_check0" type="checkbox" id="S_USE_YN" name="S_USE_YN" autocomplete="off">
                <label class="label_checkbox0_v2" for="S_USE_YN">${fn:escapeXml(emax:word("사용여부"))}</label>
            </div>

        </div>
    </div>
    <div class="contents_area half_h_contents">
    	<%--<div class="h100 grid_inner_wrap0" id="masterGrid"></div>--%>
        <div class="grid_inner_wrap h100" id="masterGrid" style="width: calc(30% - 10px);"></div>
        <%--<div class="w75 floatR grid_inner_wrap0 h100" id="detailGrid"></div>--%>
        <div class="h100 mgl20" style="display: inline-block; width: calc(70% - 10px);">
            <div class="content_inner_v2" style="height: calc(55% - 10px);">
                <form id="masterForm" class="grid_layout narrow_row_gap">
                    <div class="form_object drop_box" name="OWN_DIVISION_CODE_DIV" id="OWN_DIVISION_CODE_DIV" style="position: relative;">
                        <label class="label_inp0_v2" for="OWN_DIVISION_CODE_DIV_TEXT">${fn:escapeXml(emax:word("소유구분"))}</label>
                        <input type="hidden" name="OWN_DIVISION_CODE" id="OWN_DIVISION_CODE" value=""/>
                        <input type="text" name="OWN_DIVISION_CODE_DIV_TEXT" id="OWN_DIVISION_CODE_DIV_TEXT" value="" disabled class="drop_box_inp" autocomplete="off" placeholder=""/>
                        <button type="button" class="drop_box_btn">
                        </button>
                        <ul class="drop_box_list"></ul>
                    </div>
                    <div class="form_object">
                        <input type="hidden" id="MANAGE_DEPT_CODE" name="MANAGE_DEPT_CODE">
                        <input class="form_pop1_v2" type="text" id="MANAGE_DEPT_NAME" name="MANAGE_DEPT_NAME" onChange="javascript:f_formChange(this);" onfocusin="gf_focusing(this);" disabled>
                        <button class="form_popup_btn_v2" type="button" data-pop="true" data-id="MANAGE_DEPT_NAME"></button>
                        <label class="label_inp0_v2" for="MANAGE_DEPT_NAME">${fn:escapeXml(emax:word("관리부서"))}</label>
                    </div>
                    <div class="form_object">
                        <input class="form_inp0_v2" type="text" id="MAKER" name="MAKER" maxlength="50" disabled>
                        <label class="label_inp0_v2" for="MAKER">${fn:escapeXml(emax:word("제조사"))}</label>
                    </div>
                    <div  class="form_object">
                        <input class="form_inp0_v2" type="text" id="RECEIVE_COST" name="RECEIVE_COST" data-type="money" style="text-align: right;" disabled>
                        <label class="label_inp0_v2" for="RECEIVE_COST">${fn:escapeXml(emax:word("취득가격"))}</label>
                    </div>
                    <div class="form_object drop_box" name="RENT_DIVISION_CODE_DIV" id="RENT_DIVISION_CODE_DIV">
                        <label class="label_inp0_v2" for="RENT_DIVISION_CODE_DIV_TEXT">${fn:escapeXml(emax:word("렌탈구분"))}</label>
                        <input type="hidden" name="RENT_DIVISION_CODE" id="RENT_DIVISION_CODE" value=""/>
                        <input type="text" name="RENT_DIVISION_CODE_DIV_TEXT" id="RENT_DIVISION_CODE_DIV_TEXT" value="" disabled class="drop_box_inp" autocomplete="off" placeholder=""/>
                        <button type="button" class="drop_box_btn">
                        </button>
                        <ul class="drop_box_list"></ul>
                    </div>
                    <div class="form_object mgr0">
                        <input type="hidden" id="MANAGE_HR_EMPLOYEE_MASTER_ID" name="MANAGE_HR_EMPLOYEE_MASTER_ID">
                        <input class="form_pop4" type="text" id="MANAGE_EMP_NAME" name="MANAGE_EMP_NAME" data-id=MANAGE_EMP_NAME data-pop="true" disabled>
                        <button class="form_popup_btn_v2" type="button" data-id=MANAGE_EMP_NAME data-pop="true"></button>
                        <label class="label_inp0_v2" for="MANAGE_EMP_NAME">${fn:escapeXml(emax:word("관리자"))}</label>
                    </div>
                    <div class="form_object " >
                        <input class="form_inp0_v2" type="text" id="CURRENT_MILEAGE" name="CURRENT_MILEAGE" maxlength="50" disabled>
                        <label class="label_inp0_v2" for="CURRENT_MILEAGE">${fn:escapeXml(emax:word("현재주행거리"))}</label>
                    </div>
                    <div class="form_object">
                        <input class="form_inp0_v2" type="text" id="MODEL" name="MODEL" maxlength="50" disabled>
                        <label class="label_inp0_v2" for="MODEL">${fn:escapeXml(emax:word("모델"))}</label>
                    </div>
                    <div class="form_object datepicker">
                        <input class="form_date0_v2 form_datepicker" type="text" id="DISPOSAL_DATE" name="DISPOSAL_DATE" data-type="date" disabled>
                        <label class="label_inp0_v2" for="DISPOSAL_DATE">${fn:escapeXml(emax:word("매각일자"))}</label>
                    </div>
                    <div class="form_object drop_box" name="WORK_DIVISION_CODE_DIV" id="WORK_DIVISION_CODE_DIV">
                        <label class="label_inp0_v2" for="WORK_DIVISION_CODE_DIV_TEXT">${fn:escapeXml(emax:word("업무구분"))}</label>
                        <input type="hidden" name="WORK_DIVISION_CODE" id="WORK_DIVISION_CODE" value=""/>
                        <input type="text" name="WORK_DIVISION_CODE_DIV_TEXT" id="WORK_DIVISION_CODE_DIV_TEXT" value="" disabled class="drop_box_inp" autocomplete="off" placeholder=""/>
                        <button type="button" class="drop_box_btn">
                        </button>
                        <ul class="drop_box_list"></ul>
                    </div>
                    <div class="form_object">
                        <input type="hidden" id="DEPT_CODE" name="DEPT_CODE">
                        <input class="form_pop4" type="text" id=DEPT_NAME name="DEPT_NAME" data-id="DEPT_NAME" data-pop="true" disabled>
                        <button class="form_popup_btn_v2" type="button" data-id="DEPT_NAME" data-pop="true"></button>
                        <label class="label_inp0_v2" for="DEPT_NAME">${fn:escapeXml(emax:word("사용부서"))}</label>
                    </div>
                    <div class="form_object mgr0">
                        <input class="form_inp0_v2" type="text" id="VEHICLE_YEAR" name="VEHICLE_YEAR" disabled>
                        <label class="label_inp0_v2" for="VEHICLE_YEAR">${fn:escapeXml(emax:word("년식"))}</label>
                    </div>
                    <div class="form_object  ">
                        <input class="form_inp0_v2" type="text" id="CC" name="CC" disabled>
                        <label class="label_inp0_v2" for="CC">${fn:escapeXml(emax:word("배기량"))}</label>
                    </div>
                    <div class="form_object datepicker">
                        <input class="form_date0_v2 form_datepicker" type="text" id="INSPECTION_DATE" name="INSPECTION_DATE" disabled>
                        <label class="label_inp0_v2" for="INSPECTION_DATE">${fn:escapeXml(emax:word("정기검사일"))}</label>
                    </div>
                    <div class="form_object drop_box"  name="USE_TYPE_CODE_DIV" id="USE_TYPE_CODE_DIV" style="position: relative;">
                        <label class="label_inp0_v2" for="USE_TYPE_CODE_DIV_TEXT">${fn:escapeXml(emax:word("취득상태"))}</label>
                        <input type="hidden" name="USE_TYPE_CODE" id="USE_TYPE_CODE" value=""/>
                        <input type="text" name="USE_TYPE_CODE_DIV_TEXT" id="USE_TYPE_CODE_DIV_TEXT" value="" data-prev-val="" class="drop_box_inp" autocomplete="off" disabled/>
                        <button type="button" class="drop_box_btn">
                        </button>
                        <ul class="drop_box_list"></ul>
                    </div>
                    <div class="form_object">
                        <input type="hidden" id="HR_EMPLOYEE_MASTER_ID" name="HR_EMPLOYEE_MASTER_ID">
                        <input class="form_pop4" type="text" id="EMP_NAME" name="EMP_NAME" data-id="EMP_NAME" data-pop="true" disabled>
                        <button class="form_popup_btn_v2" type="button" data-id="EMP_NAME" data-pop="true"></button>
                        <label class="label_inp0_v2" for="EMP_NAME">${fn:escapeXml(emax:word("운전자"))}</label>
                    </div>
                    <div class="form_object drop_box" name="FUEL_DIVISION_CODE_DIV" id="FUEL_DIVISION_CODE_DIV">
                        <label class="label_inp0_v2" for="FUEL_DIVISION_CODE_DIV_TEXT">${fn:escapeXml(emax:word("연료구분"))}</label>
                        <input type="hidden" name="FUEL_DIVISION_CODE" id="FUEL_DIVISION_CODE" value=""/>
                        <input type="text" name="FUEL_DIVISION_CODE_DIV_TEXT" id="FUEL_DIVISION_CODE_DIV_TEXT" value="" data-prev-val="" class="drop_box_inp" autocomplete="off" disabled/>
                        <button type="button" class="drop_box_btn">
                        </button>
                        <ul class="drop_box_list"></ul>
                    </div>
                    <div class="form_object mgr0">
                        <input class="form_inp0_v2" type="text" id="KM_H" name='KM_H' disabled>
                        <label class="label_inp0_v2" for="KM_H">${fn:escapeXml(emax:word("연비"))}</label>
                    </div>
                    <div class="form_object drop_box" name="COMM_BUSINESS_ID_DIV" id="COMM_BUSINESS_ID_DIV">
                        <label class="label_inp0_v2" for="COMM_BUSINESS_ID_DIV_TEXT">${fn:escapeXml(emax:word("사용사업장"))}</label>
                        <input type="hidden" name="COMM_BUSINESS_ID" id="COMM_BUSINESS_ID" value=""/>
                        <input type="text" name="COMM_BUSINESS_ID_DIV_TEXT" id="COMM_BUSINESS_ID_DIV_TEXT" value="" data-prev-val="" class="drop_box_inp" autocomplete="off" disabled/>
                        <button type="button" class="drop_box_btn">
                        </button>
                        <ul class="drop_box_list"></ul>
                    </div>
                    <div class="form_object">
                        <input class="form_check0" type="checkbox" id="WORK_USE_YN" name="WORK_USE_YN" disabled>
                        <label class="label_checkbox2_v2" for="WORK_USE_YN">${fn:escapeXml(emax:word("업무용승용차"))}</label>
                        <input class="form_check2" type="checkbox" id="USE_YN" name="USE_YN" disabled>
                        <label class="label_checkbox3_v2" for="USE_YN">${fn:escapeXml(emax:word("사용여부"))}</label>
                    </div>
                    <div class="form_object drop_box" name="CREATE_CHANNEL_CODE_DIV" id="CREATE_CHANNEL_CODE_DIV">
                        <label class="label_inp0_v2 blue" for="COMM_BUSINESS_ID_DIV_TEXT">${fn:escapeXml(emax:word("법인차량생성"))}</label>
                        <input type="hidden" name="CREATE_CHANNEL_CODE" id="CREATE_CHANNEL_CODE" value=""/>
                        <input type="text" name="CREATE_CHANNEL_CODE_DIV_TEXT" id="CREATE_CHANNEL_CODE_DIV_TEXT" value="" data-vldt="notNull" data-prev-val="" class="drop_box_inp" autocomplete="off"disabled/>
                        <button type="button" class="drop_box_btn">
                        </button>
                        <ul class="drop_box_list"></ul>
                    </div>
                    <div class="form_object">
                        <input class="form_inp0_v2" type="text" id="CRTBY" name="CRTBY" readOnly>
                        <label class="label_inp0_v2" for="CRTBY">${fn:escapeXml(emax:word("등록자"))}</label>
                    </div>
                </form>
            </div>

            <%--탭--%>
            <div class="inner_tab_wrap2" id="inner_tab_wrap" style="height: calc(45% - 10px);">
                <div class="grid_wrap">
                    <ul class="inner_tabs">
                        <li class="inner_tab">
                            <a class="tab_link" href="#inner_tab0" title="">${fn:escapeXml(emax:word("운행일지"))}</a>
                        </li>
                        <li class="inner_tab">
                            <a class="tab_link" href="#inner_tab1" title="">${fn:escapeXml(emax:word("보험이력"))}</a>
                        </li>
                        <li class="inner_tab">
                            <a class="tab_link" href="#inner_tab2" title="">${fn:escapeXml(emax:word("수리내역"))}</a>
                        </li>
                        <li class="inner_tab">
                            <a class="tab_link" href="#inner_tab3" title="">${fn:escapeXml(emax:word("사진정보"))}</a>
                        </li>
                    </ul>
                    <div class="inner_panel" id="inner_tab0" style="">
                        <div class="h100" id="driveGrid" style=""></div>
                    </div>

                    <div class="inner_panel" id="inner_tab1"  style="">
                        <div class="h100" id="insGrid" style=""></div>
                    </div>

                    <div class="inner_panel" id="inner_tab2"  style="">
                        <div class="h100" id="repGrid" style=""></div>
                    </div>

                    <div class="inner_panel form_panel" id="inner_tab3"  style="">
                        <input type="hidden" id="GA_DRIVE_PIC_ID" name="GA_DRIVE_PIC_ID">
                        <div class="form_object_img">
                            <p class="profile_img_section" id="pic1"></p>
                            <%--<input class="form_pop" type="file" id="picture1" name="picture1">--%>
                        </div>
                        <div class="form_object_img">
                            <p class="profile_img_section" id="pic2"></p>
                           <%-- <input class="form_pop" type="file" id="picture2" name="picture2">--%>
                        </div>
                        <div class="form_object_img">
                            <p class="profile_img_section" id="pic3"></p>
                           <%-- <input class="form_pop" type="file" id="picture3" name="picture3">--%>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>