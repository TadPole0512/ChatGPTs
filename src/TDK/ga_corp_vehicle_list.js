var masterGrid;
var masterGridDP;
var driveGrid;
var driveGridDP;
var insGrid;
var insGridDP;
var repGrid;
var repGridDP;
var picForm;

var popup;

var ga_vehicle_no;
var send_ga_vehicle_no;

$(document).ready(function () {
    $('#S_USE_YN').prop('checked', true);
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
    f_set_driveGrid();
    f_set_insGrid();
    f_set_repGrid();

    gf_tabInit();
    gf_tabFocus(0);

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
        no_disable : true
//        grid_height: $('.contents_area').height(),
    }
    masterGrid   = gf_gridInit(grid_opt);
    masterGridDP = masterGrid.getDataSource();
    
    masterGrid.onCurrentRowChanged = function (grid, oldRow, newRow) {
    	ga_vehicle_no = masterGrid.getValue(newRow, 'VEHICLE_NO')
    }
    // masterGrid.onCellDblClicked = function (grid, clickData) {
    // 	send_ga_vehicle_no = ga_vehicle_no
    //     parent.gf_addPageIframe('ga_corp_vehicle', '법인차량 등록');
    // }

    // 선택 행 변경 시
    masterGrid.onCurrentRowChanged = function(grid, oldRow, newRow){

        if (grid.getCurrent().dataRow == -1) {
            return false;
        }
        var value = grid.getDataSource().getValue(grid.getCurrent().dataRow, "GA_CORP_VEHICLE_ID");
        f_search_masterForm(value);
        f_search_drive(value);
        f_search_ins(value);
        f_search_rep(value);
        f_search_pics(value);
    }



};

var f_set_driveGrid = function () {
    var grid_opt = {
        grid_id    : 'driveGrid',
        contextMenu: 'view',
    }
    driveGrid   = gf_gridInit(grid_opt);
    driveGridDP = driveGrid.getDataSource();


};
var f_set_insGrid = function () { //마스터그리드 만들기
    var grid_opt = {
        grid_id: 'insGrid',
        contextMenu: 'view',
    }
    insGrid    = gf_gridInit(grid_opt);
    insGridDP  = insGrid.getDataSource();

};
var f_set_repGrid = function () { //마스터그리드 만들기
    var grid_opt = {
        grid_id: 'repGrid',
        contextMenu: 'view',
    }
    repGrid    = gf_gridInit(grid_opt);
    repGridDP  = repGrid.getDataSource();

};

var f_registration = function(){
    parent.gf_addPageIframe('ga_corp_vehicle', '법인차량 등록');
}

var f_update = function(){
    send_ga_vehicle_no = masterGridDP.getValue(masterGrid.getCurrent().dataRow, "VEHICLE_NO");
    parent.gf_addPageIframe('ga_corp_vehicle', '법인차량 등록');
}


/*****************************************************************************************************************************/
//
/* 												  	  조회																	 */
//
/*****************************************************************************************************************************/
var f_search = function () {
    masterGrid.cancel();
    masterGridDP.clearRows();

    var use_yn = $('#S_USE_YN').prop("checked") ? '1' : '0';

    gf_gridSearch({
        gridView: masterGrid,
        param   : {
            queryId            : 'ga.S_GA_CORP_VEHICLE_LIST_S', 		//쿼리id
            function_name      : 'f_search',
            v_vehicle_no       : $('#VEHICLE_NO').val(),					//차량번호,
            v_manage_dept_id   : $('#MANAGE_DEPARTMENT_ID').val(),			//관리부서
            v_usage_dept_id    : $('#USE_DEPARTMENT_ID').val(),				//사용부서
            v_own_division_code: $('#S_OWN_DIVISION_CODE').val(),				//소유구분
            v_use_yn           : use_yn,					//사용여부
            v_nickname          : $('#S_NICKNAME').val()
        },
        callback: function (data) {
        },
    });
}

var f_search_masterForm = function (value) {

    gf_formSearch({
        data: {
            queryId        : 'ga.S_GA_CORP_VEHICLE_LIST_S',
            function_name  : 'f_search',
            v_ga_corp_id   :  value
        }
    }, ['masterForm'], function (data) {
        if(data.length > 0){
            $('#CURRENT_MILEAGE').val(  numberWithCommas(data[0].CURRENT_MILEAGE));
        }
    });
}
var f_search_drive = function (value) {
    driveGridDP.clearRows();

    gf_gridSearch({
        gridView: driveGrid,
        param   : {
            queryId     : 'ga.S_GA_VEHICLE_LOG', //쿼리id
            function_name : 'f_search',
            v_vehicle_no: $('#VEHICLE_NO').val(),//차량번호
            v_ga_corp_id: value
        }
    });
};

// 보험조회
var f_search_ins = function (value) {
    insGridDP.clearRows();

    gf_gridSearch({
        gridView: insGrid,
        param   : {
            queryId     : 'ga.S_GA_DRIVE_INS', //쿼리id
            function_name : 'f_search',
            v_vehicle_id: $('#GA_CORP_VEHICLE_ID').val(),//법인차량ID
            v_ga_corp_id: value,
            v_corporation_ini : gv_corporationIni
        }
    });
};
// 수리내역
var f_search_rep = function (value) {
    repGridDP.clearRows();

    gf_gridSearch({
        gridView: repGrid,
        param   : {
            queryId     : 'ga.S_GA_DRIVE_REP', //쿼리id
            function_name : 'f_search',
            v_vehicle_id: $('#GA_CORP_VEHICLE_ID').val(),//법인차량ID
            v_ga_corp_id: value
        }
    });
};
//사진조회
var f_search_pics = function (value) {
    gf_getData({
        data    : {
            queryId     : 'ga.S_GA_DRIVE_PIC',
            function_name : 'f_search',
            v_vehicle_id: $('#GA_CORP_VEHICLE_ID').val(),//법인차량ID
            v_ga_corp_id: value
        },
        callback: function (data) {
            if (data.length > 0) {
                //이미지 초기화
                $('#pic1').attr('style', '');
                $('#pic2').attr('style', '');
                $('#pic3').attr('style', '');
                $('#GA_DRIVE_PIC_ID').val(data[0].GA_DRIVE_PIC_ID);
                Object.keys(data[0]).forEach(function(key) {
                    var p;

                    switch (key){
                        case 'PICTURE1' : p = 'pic1'; break;
                        case 'PICTURE2' : p = 'pic2'; break;
                        case 'PICTURE3' : p = 'pic3'; break;
                    };

                    $('#' + p).css({
                        'background'           : 'url(' + 'data:image/jpg;base64,' + data[0][key] + ')'
                        , 'background-repeat'  : 'no-repeat'
                        , 'background-size'    : 'contain'
                        , 'background-position': 'center'
                    });
                });
            }else{
                $('#pic1').attr('style', '');
                $('#pic2').attr('style', '');
                $('#pic3').attr('style', '');

            }
        }
    });
};

/*****************************************************************************************************************************/
/* 													  팝업																	 */
//
/*****************************************************************************************************************************/
var FormColumn = [{
    colId       : 'MANAGE_DEPARTMENT_NAME'
    , popup_code: 'pop_dept'
    , v_title   : gf_word('부서코드')
}, {
    colId       : 'USE_DEPARTMENT_NAME'
    , popup_code: 'pop_dept'
    , v_title   : gf_word('사용부서')
}];

function paramReturn(object, itemIndex) {
    var param;

    if (object.dataset.pop == 'true') {
    var today = new Date().toISOString().slice(0, 10)
        param = {
            MANAGE_DEPARTMENT_NAME: {
                searchCondition: object.value,
                v_modified_date : today
            },
            USE_DEPARTMENT_NAME   : {
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
            MANAGE_DEPARTMENT_NAME: {
            	v_modified_date : today
            },
            USE_DEPARTMENT_NAME   : {
            	v_modified_date : today
            }
        }
    }
    return v_param;
}

var f_popup_callback = function (data) {//comm_popup.jsp에 가보면 이것을 콜백하라는 명령어가 있음
    if (popup == 'F_MANAGE_DEPARTMENT_NAME') {	// 폼 부분의 부서코드
        $('#MANAGE_DEPARTMENT_ID').val(data.DEPT_CODE);
        $('#MANAGE_DEPARTMENT_NAME').val(data.DEPT_NAME);
    } else if (popup == 'F_USE_DEPARTMENT_NAME') {
        $('#USE_DEPARTMENT_ID').val(data.DEPT_CODE);
        $('#USE_DEPARTMENT_NAME').val(data.DEPT_NAME);
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
        tag_id    : 'S_OWN_DIVISION_CODE_DIV',
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
    if (object.id == 'MANAGE_DEPARTMENT_NAME' || object.id == 'USE_DEPARTMENT_NAME') {				// onChange가 발생한 곳이 DEPT_CODE 일 때
        popup = 'F_' + object.id
        //텍스트 지우면 그에 따른 hidden값도 지운다
        if(gf_nvl($('#'+object.id).val(),'') == ''){
        	$('#'+object.id.replace('NAME','ID')).val('');
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
                                if (object.id == 'MANAGE_DEPARTMENT_NAME') {
                                    $('#MANAGE_DEPARTMENT_ID').val('');
                                    $('#MANAGE_DEPARTMENT_NAME').val('');
                                } else {
                                    $('#USE_DEPARTMENT_ID').val('');
                                    $('#USE_DEPARTMENT_NAME').val('');
                                }

                            },
                            v_value             : object.value,
                            v_title             : gf_word('부서코드')
                        });
                    }
                },
            };

            gf_getPopupData(param);
        }
    }
}
