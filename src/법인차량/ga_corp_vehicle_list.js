var masterGrid;
var masterGridDP;

var popup;

var ga_vehicle_no;
var send_ga_vehicle_no;

$(document).ready(function () {
    $('#use_yn').prop('checked', true);
    //엔터키 조회
    $('input[type=text]').keypress(function (e) {
        if (e.which == 13) {
            f_search();
            return false;
        }
    });

    //combo Setting
    f_formCombo();

    //grid Setting
    f_set_masterGrid();
});

/*****************************************************************************************************************************/
//
/* 												masterGrid Set																 */
//
/*****************************************************************************************************************************/

var f_set_masterGrid = function () { //마스터그리드 만들기
    var grid_opt = {
        grid_id    : 'masterGrid',
        contextMenu: 'view',
//        grid_height: $('.contents_area').height(),
    }
    masterGrid   = gf_gridInit(grid_opt);
    masterGridDP = masterGrid.getDataSource();
    
    masterGrid.onCurrentRowChanged = function (grid, oldRow, newRow) {
    	ga_vehicle_no = masterGrid.getValue(newRow, 'vehicle_no')
    }
    masterGrid.onCellDblClicked = function (grid, clickData) {
    	send_ga_vehicle_no = ga_vehicle_no
        parent.gf_addPageIframe('ga_corp_vehicle', '법인차량 등록');
    }
    //마스터그리드끝
};

/*****************************************************************************************************************************/
//
/* 												  	  조회																	 */
//
/*****************************************************************************************************************************/
var f_search = function () {
    masterGrid.cancel();
    masterGridDP.clearRows();

    var use_yn = $('#use_yn').prop("checked") ? '1' : '0';

    gf_gridSearch({
        gridView: masterGrid,
        param   : {//검색조건
            queryId            : 'ga.S_GA_CORP_VEHICLE_LIST_S', 	//쿼리id
            function_name	   : 'f_search',
            v_vehicle_no       : $('#vehicle_no').val(),			//차량번호,
            v_manage_dept_id   : $('#manage_department_id').val(),	//관리부서
            v_usage_dept_id    : $('#use_department_id').val(),		//사용부서
            v_own_division_code: $('#own_division_code').val(),		//소유구분
            v_use_yn           : use_yn								//사용여부
//            v_nickname          : $('#S_NICKNAME').val()
        },
        callback: function (data) {
        },
    });
}

/*****************************************************************************************************************************/
//
/* 													  팝업																	 */
//
/*****************************************************************************************************************************/
var FormColumn = [{
    colId       : 'manage_department_name'
    , popup_code: 'pop_dept'
    , v_title   : gf_word('부서코드')
}, {
    colId       : 'use_department_name'
    , popup_code: 'pop_dept'
    , v_title   : gf_word('사용부서')
}];

function paramReturn(object, itemIndex) {
    var param;

    if (object.dataset.pop == 'true') {
    var today = new Date().toISOString().slice(0, 10)
        param = {
            manage_department_name: {
                searchCondition: object.value,
                v_modified_date : today
            },
            use_department_name   : {
                searchCondition: object.value,
                v_modified_date : today
            }
        }
    }

    return param;
}

function vParamReturn(object, itemIndex) {
	var today = new Date().toISOString().slice(0, 10)
    var v_param;
    if (object.dataset.pop == 'true') {
        v_param = {
            manage_department_name: {
            	v_modified_date : today
            },
            use_department_name   : {
            	v_modified_date : today
            }
        }
    }
    return v_param;
}

var f_popup_callback = function (data) {//comm_popup.jsp에 가보면 이것을 콜백하라는 명령어가 있음
    if (popup == 'F_manage_department_name') {	// 폼 부분의 부서코드
        $('#manage_department_id').val(data.dept_code);
        $('#manage_department_name').val(data.dept_name);
    } else if (popup == 'F_use_department_name') {
        $('#use_department_id').val(data.dept_code);
        $('#use_department_name').val(data.dept_name);
    }
}

/*****************************************************************************************************************************/
//
/* 												  	  콤보																	 */
//
/*****************************************************************************************************************************/
var f_formCombo = function () {
    //소유구분
	gf_formCombo({
        popup_code: 'comm_mu_code',
        tag_id    : 'own_division_code_div',
        param     : {
            code_master: 'ga003',
        },
        async     : true,
        empty     : true
    });
}
/*****************************************************************************************************************************/
//
/* 												  	  그외																	 */
//
/*****************************************************************************************************************************/
var f_formChange = function (object) {			// onChange Event
    //부서
    if (object.id == 'manage_department_name' || object.id == 'use_department_name') {				// onChange가 발생한 곳이 DEPT_CODE 일 때
        popup = 'F_' + object.id
        //텍스트 지우면 그에 따른 hidden값도 지운다
        if(gf_nvl($('#'+object.id).val(),'') == ''){
        	$('#'+object.id.replace('name','id')).val('');
        	return false;
        } else {
            var param = {
                popup_code: 'pop_dept',
                param     : {
                    searchCondition: object.value,
                    v_modified_date : new Date().toISOString().slice(0, 10) 
                },
                success   : function (data) {
                    if (data.length == 1) {
                        f_popup_callback(data[0]);
                        object.blur();
                    } else {
                        gf_popup(popup, 'pop_dept', {
                            v_param             : {},
                            v_popup_cancel_close: function () {
                                if (object.id == 'manage_department_name') {
                                    $('#manage_department_id').val('');
                                    $('#manage_department_name').val('');
                                } else {
                                    $('#use_department_id').val('');
                                    $('#use_department_name').val('');
                                }

                            },
                            v_value : object.value,
                            v_title : gf_word('부서코드')
                        });
                    }
                },
            };

            gf_getPopupData(param);
        }
    }
}
