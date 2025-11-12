<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>법인차량 조회</title>
    <%@include file="/WEB-INF/jsp/common.jsp" %>
    <style>
		#masterGrid{height:100%;}    
    </style>
</head>
<body>
<div class="contents_wrap">
	<div class="contents_header_top">
        <h3 class="list_title"></h3>
    </div>
    <div class="contents_header half_header">
        <div class="content_header_inner">
			<form id="masterForm">
                <div class="form_object w283">
                    <input class="form_inp0_v2" type="text" id="vehicle_no" name="vehicle_no" autocomplete="off">
                    <label class="label_inp0_v2" for="vehicle_no">${fn:escapeXml(emax:word("차량번호"))}</label>
                </div>
                <div class="form_object w283">
                    <input type="hidden" id="manage_department_id" name="manage_department_id">
                    <input class="form_pop1_v2" type="text" id="manage_department_name" name="manage_department_name" onChange="javascript:f_formChange(this);" onfocusin="gf_focusing(this);">
                    <button class="form_popup_btn_v2" type="button" data-pop="true" data-id="manage_department_name"></button>
                    <label class="label_inp0_v2" for="manage_department_name">${fn:escapeXml(emax:word("관리부서"))}</label>
                </div>
                <div class="form_object w283">
                    <input type="hidden" id="use_department_id" name="use_department_id">
                    <input class="form_pop1_v2" type="text" id="use_department_name" name="use_department_name" onChange="javascript:f_formChange(this);" onfocusin="gf_focusing(this);">
                    <button class="form_popup_btn_v2" type="button" data-pop="true" data-id="use_department_name"></button>
                    <label class="label_inp0_v2" for="use_department_name">${fn:escapeXml(emax:word("사용부서"))}</label>
                </div>
                <div class="form_object w283 drop_box" name="own_division_code_div" id="own_division_code_div">
					<label class="label_inp0_v2" for="own_division_code_div">${fn:escapeXml(emax:word("소유구분"))}</label>
					<input type="hidden" id="own_division_code" name="own_division_code" value="" />
					<input type="text" name="own_division_code_div_TEXT" id="own_division_code_div_TEXT" value="" data-prev-val="" class="drop_box_inp" autocomplete="off" placeholder="" />
					<button type="button" class="drop_box_btn"></button>
					<ul class="drop_box_list"></ul>
				</div>
<%--                 <div class="form_object w283">
               		<input class="form_inp0_v2" type="text" id="S_NICKNAME" name="S_NICKNAME">
               		<label class="label_inp0_v2" for="S_NICKNAME">${fn:escapeXml(emax:word("닉네임"))}</label>
                	
            	</div> --%>
                <div class="form_object w283">
                    <input class="form_check0" type="checkbox" id="use_yn" name="use_yn" autocomplete="off">
                    <label class="label_checkbox0_v2" for="use_yn">${fn:escapeXml(emax:word("사용여부"))}</label>
                </div>
            </form>
        </div>
    </div>
    <div class="contents_area half_h_contents">
    	<div class="w100 grid_inner_wrap0" id="masterGrid"></div>
    </div>
</div>
</body>
</html>