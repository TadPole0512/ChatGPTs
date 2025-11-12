// function gf_error_msg(msgCode) {
// 	if(parent.index_lang.errorMap[msgCode] == undefined || parent.index_lang.errorMap[msgCode] == null){
// 		return '[*'+msgCode+'* error_msg 등록 바람.]';
// 	}
// 	return parent.index_lang.errorMap[msgCode].ERROR_MSG;
// }
function XSSCheck(str) {
	// str = str.replace(/\"|\'|\%|\;|\(|\)|\&|\+|\-/g,"");
	str = gf_nvl(str, '');
	str = str.replace(/\</g, "&lt;");
	str = str.replace(/\>/g, "&gt;");
	str = str.replace(/\\n/g, "\n");
	return str;
}

function gf_msg(msgCode, param) {
	var index_msg;
	var result_msg;
	if (parent.index_msg != undefined) {
		index_msg = parent.index_msg[msgCode];
	} else if (window.opener && window.opener.parent.index_msg != undefined) {
		index_msg = window.opener.parent.index_msg[msgCode];
	} else {
		index_msg = window.top.index_msg[msgCode];
	}
	
	if (index_msg == undefined || index_msg == null) {
		return '[*' + msgCode + '* 다국어 메시지 등록 바람.]';
	}

	// 다국어메시지 변수적용
	result_msg = gf_nvl(index_msg.common_msg, '');
	var paramKey = Object.keys(gf_nvl(param, {}));
	for (var i = 0; i < paramKey.length; i++) {
		var chgKey = '\\[\\@;' + paramKey[i] + ';\\@\\]';
		var reg = new RegExp(chgKey, 'g');
		result_msg = result_msg.replace(reg, param[paramKey[i]]);
	}
	// 모든변수부분 삭제
	var regExp = new RegExp('\\[\\@;.*;\\@\\]', 'g');
	result_msg = result_msg.replace(regExp, '');

	return XSSCheck(result_msg);
}

function gf_word(dicCode, param) {
	var index_word;
	var result_word;
	if (parent.index_word != undefined) {
		index_word = parent.index_word[dicCode];
	} else if (parent.parent.index_word != undefined){
		index_word = parent.parent.index_word[dicCode];
	} else {
		index_word = parent.parent.parent.index_word[dicCode];
	}
	if (index_word == undefined || index_word == null) {
		return '[*' + dicCode + '* 다국어 등록 바람.]';
	}

	// 다국어 변수적용
	result_word = gf_nvl(index_word.word, '');
	var paramKey = Object.keys(gf_nvl(param, {}));
	for (var i = 0; i < paramKey.length; i++) {
		var chgKey = '\\[\\@;' + paramKey[i] + ';\\@\\]';
		var reg = new RegExp(chgKey, 'g');
		result_word = result_word.replace(reg, param[paramKey[i]]);
	}
	// 모든변수부분 삭제
	var regExp = new RegExp('\\[\\@;.*;\\@\\]', 'g');
	result_word = result_word.replace(regExp, '');

	return XSSCheck(result_word);
}

/* 공통 ajax */
// 데이터 조회.
function gf_getData(param) {
	$.ajax({
		type     : "POST",
		url      : "/getData.ajax",
		data     : param.data,
		success  : param.callback,
		complete : param.complete,
		// error : function (request, status, error) {

		// if (typeof param.error == 'function') {
		// param.error();
		// return;
		// }

		// if (!status == 9998) {
		// gf_toast(request.responseText);
		// }
		// },
		dataType : gf_nvl(param.dataType, 'json'),
		async    : gf_nvl(param.async, true)
	});
}

// 데이터 추가,삭제,변경.
function gf_setData(param) {
	$.ajax({
		type : "POST",
		url : "/setData.ajax",
		data : param.data,
		success : param.callback,
		// error : function (request, status, error) {

		// if (typeof param.error == 'function') {
		// param.error();
		// return;
		// }

		// if (!status == 9998) {
		// gf_toast(request.responseText);
		// }
		// },
		dataType : gf_nvl(param.dataType, 'json'),
		async : gf_nvl(param.async, false) // 21.12.24 lhj - ajax 중복 호출 이슈로 기본값 false로 변경
	});
}

// 프로시져 호출.
function gf_execData(param) {
	$.ajax({
		type : "POST",
		url : "/execData.ajax",
		data : param.data,
		success : param.callback,
		complete : param.complete,
		// error : function (request, status, error) {

		// if (typeof param.error == 'function') {
		// param.error();
		// return;
		// }

		// if (!status == 9998) {
		// gf_toast(request.responseText);
		// }
		// },
		dataType : gf_nvl(param.dataType, 'json'),
		async : gf_nvl(param.async, false) // 21.12.24 lhj - ajax 중복 호출 이슈로 기본값 false로 변경
	});
}

// 콤보 팝업 데이터 조회.
function gf_getComboPopupData(param) {
	$.ajax({
		type : "POST",
		url : "/comm_popup_result.ajax",
		data : param.data,
		success : param.callback,
		// error : function (request, status, error) {

		// if (typeof param.error == 'function') {
		// param.error();
		// return;
		// }

		// if (!status == 9998) {
		// gf_toast(request.responseText);
		// }
		// },
		dataType : gf_nvl(param.dataType, 'json'),
		async : gf_nvl(param.async, true)
	});
}

// new FormData 를 Json으로 변환하는 함수
function gf_formDataToJson(formData, p_key) {

	if (typeof formData != 'object') {
		return formData;
	}

	var v_resultMap = {};
	var v_key = formData.keys();

	while (true) {
		var v_iter = v_key.next();
		if (v_iter.done) {
			break;
		}

		// 그리드
		if (p_key.includes('Grid')) {
			v_resultMap[v_iter.value] = formData.get(v_iter.value);
		}
		// // 이미지 파일
		// else if (p_key.includes('ImageFile')) {
		// v_resultMap[v_iter.value] = formData.get(v_iter.value);
		// }
		// 폼데이터
		else if (p_key.includes('Form')) {

			// html <form> 이 아닌 경우 : new FormData() 로 데이터만 생성한 경우
			if ($(document.forms[p_key]).length == 0) {
				v_resultMap[v_iter.value] = formData.get(v_iter.value);
			} else {
				switch ($(document.forms[p_key][v_iter.value]).attr('data-type')) {
				case 'date':
					v_resultMap[v_iter.value] = formData.get(v_iter.value).replace(/-/g, "");
					break;
				case 'money':
					v_resultMap[v_iter.value] = formData.get(v_iter.value).replace(/,/g, "");
					break;
				default:
					v_resultMap[v_iter.value] = formData.get(v_iter.value);
					break;
				}
			}

		}

	}

	return v_resultMap;
}

/* 폼, 그리드 등의 모든 데이터를 한번에 저장하는 함수.도중에 프로시저를 사용하면 의미가 없다. 텍스트 , 이미지파일 나눠서 파라미터를 만들어야한다. */
function gf_allSave(p_saveOrder, p_formDataMap, callback, msg) {
	var data = new FormData();
	var saveOrderList = [];

	for (let i = 0; i < p_saveOrder.length; i++) {

		saveOrderList.push(JSON.stringify(p_saveOrder[i]));

		var key = p_saveOrder[i].saveName;
		var formDataMap = p_formDataMap[key];
		if (typeof formDataMap != 'object') {
			return;
		}

		// 첨부파일일 경우
		if (key.includes('AttachedFile')) {

			var fileList = formDataMap.getAll('attachedFile');
			for (let j = 0; j < fileList.length; j++) {
				data.append(key + '_attachedFile', fileList[j]);
			}
			// 파일 삭제데이터
			if (gf_nvl(JSON.parse(formDataMap.get('fileDelete')), []).length > 0) {
				data.append(key + '_fileDelete', formDataMap.get('fileDelete'));
			}

		}
		// 이미지파일
		else if (key.includes('ImageFile')) {
			var imgMap = {};
			var imgKey = formDataMap.keys();

			while (true) {
				var iter = imgKey.next();
				if (iter.done) {
					break;
				}
				if (typeof formDataMap.get(iter.value) == 'string') {
					imgMap[iter.value] = formDataMap.get(iter.value);
				} else {
					data.append(key + '_' + iter.value, formDataMap.get(iter.value));
				}
			}
			data.append(key, JSON.stringify(imgMap));
		}
		// 텍스트 폼데이터, 그리드
		else if (key.includes('Form') || key.includes('Grid')) {

			// var formMap = {};
			// var formKey = formDataMap.keys();
			//
			// while (true) {
			// var iter = formKey.next();
			// if (iter.done) {
			// break;
			// }
			//
			// switch ($(document.forms[key][iter.value]).attr('data-type')) {
			// case 'date':
			// formMap[iter.value] = formDataMap.get(iter.value).replace(/-/g, "");
			// break;
			// case 'money':
			// formMap[iter.value] = formDataMap.get(iter.value).replace(/,/g, "");
			// break;
			// // case 'checkbox': 개별 화면에서 직접 넣어줘야하기 불필요한 코드
			// // formMap[iter.value] = ($('#'+iter.value).is(":checked") ? '1' : '0');
			// // break;
			// default:
			// formMap[iter.value] = formDataMap.get(iter.value);
			// break;
			// }
			// }
			// data.append(key, JSON.stringify(formMap));

			data.append(key, JSON.stringify(gf_formDataToJson(formDataMap, key)));

		}
	}

	data.append('saveOrder', saveOrderList);

	$.ajax({
		type : "POST",
		enctype : 'multipart/form-data',
		url : "/allSave",
		data : data,
		async : false,
		processData : false,
		contentType : false,
		cache : false,
		timeout : 600000,
		success : function(data) {

			if (gf_nvl(data.error_msg, '') != '') {
				gf_toast((data.error_line ? data.error_line + gf_msg("row_error") : '') + data.error_msg);
				return false;
			}

			gf_toast((msg ? msg : gf_msg("saved")));

			if (typeof callback == 'function') {
				callback(data);
			}

		},
		error : function(data) {
			console.log('error', data);
		},

	});
}

function gf_excel_download(url, requestBody, fileName) {
	// Fetch API를 사용하여 파일 다운로드 요청을 서버에 전송
	fetch(url, {
		  method: 'POST',
		  headers: {
		    'Content-Type': 'application/json'
		    // Add other headers if needed
		  },
		  body: requestBody
	})
	.then(response => {
    		if (!response.ok) {
    			return response.json()
    	        	.then(data => {
    	        		// 에러 응답 데이터 처리
    	        		var error_message = data.error_msg;
    	        		throw new Error(error_message);
    	        });
    			
    		}
    		return response.blob();
    	})
    .then(blob => {
	    	// 파일 다운로드를 위한 처리
	    	var link = document.createElement('a');
	    	link.href = window.URL.createObjectURL(blob);
	    	link.download = fileName;
	
	    	// 다운로드 링크를 클릭하여 파일 다운로드 시작
	    	link.click();
    	})
    .catch(error => {
    	gf_toast(error.message, {
			type : 'danger',
			duration : 6000
		});
    });
}

/* 비밀번호 암호화 */
function gf_encrypt_pw(pw, secure_key) {
	// 객체 생성
	var crypt = new JSEncrypt();

	// 키 설정
	crypt.setPrivateKey(secure_key);

	// 암호화
	return crypt.encrypt(pw);
}

/* 비밀번호 변경 */
function gf_rePw(param) {
	$.ajax({
		type : "POST",
		url : "/login/changePw.ajax",
		data : param.data,
		success : param.callback,
		dataType : "json", // "text",
		async : false
	});
}

/* 비밀번호 확인 */
function gf_checkPw(param) {
	$.ajax({
		type : "POST",
		url : gv_corporationIni + "/login/checkPw.ajax",
		data : param.data,
		success : param.callback,
		dataType : "text",
		async : false
	});
}

/* 도움말 */
function gf_help() {
	var popup_param = {
		popup_code : 'popup_help',
		param : '',
//		popup_before_close : '',
		popup_width : 1000,
		popup_height : 800,
		title : '도움말'
	}
	gf_modal_popup(popup_param);
}

/* session 다국어 반영. */
function gf_setLang() {
	// 다국어가져오기
	$.ajax({
		type : "GET",
		url : "/setLang",
		data : null,
		async : false,
		success : function(data) {
			// index_lang = data;
		},
		dataType : "json"
	});
}

/* 알림 토스트 처리. */
var gf_toast = function(msg, option) {
	console.log(msg)
	msg = msg.replace(/\n/g, "<br>");
	if (option == undefined) {
		option = {
			type : 'info',
			duration : 6000
		};
	}
	$.toast(msg, option);
}

/* 숫자 입력시 , 찍기 */
function gf_inputNumberFormat(obj) {
	obj.value = gf_comma(gf_uncomma(obj.value));
}

/*  */
function gf_comma(str) {
	str = String(str);
	return str.replace(/(\d)(?=(?:\d{3})+(?!\d))/g, '$1,');
}

/* 엑셀 파일 체크 */
function gf_isExcelFile(fileName) {
    // 대소문자를 구분하지 않고 검사
    return /\.(xls|xlsx)$/i.test(fileName);
}

/*  */
function gf_uncomma(str) {
	// 마이너스 금액 입력시 - 가 없어지는 오류 발생으로 인한 수정
	// str = String(str);
	// return str.replace(/[^\d]+/g, '');

	str = String(str);
	return str.replace(/,/g, '');
}

// 숫자형식 콤마 붙이는 함수 추가
function numberWithCommas(n) {
	n = String(gf_nvl(n === 0 ? '0' : n, '')).replace(/,/g, '');
	var parts = n.toString().split(".");
	return parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",") + (parts[1] ? "." + parts[1] : "");
}

/* 숫자만 입력 가능하게 */
function gf_checkNum(e) {
	var keyVal = event.keyCode;

	if (((keyVal >= 48) && (keyVal <= 57))) {
		return true;
	} else {
		gf_toast(gf_msg("number_input"));
		return false;
	}
}

/* 현재 대상 페이지를 호출한 부모 페이지 접근 */
function gf_getParentPage(pageId) {
	var previousIframe = $(parent.document).find('#' + pageId)[0];
	return previousIframe;
}

// ========================================================================================
// Date 오늘
// ========================================================================================
/* date10. 오늘 날짜를 기준으로 유형에 맞는 Date 반환 */
function gf_getDate(condition, p_date) {
	var newDate;
	var today = new Date();
	if (p_date != null) {
		today = new Date(p_date);
	}

	if (condition == 'today') {
		newDate = new Date(today.getFullYear(), today.getMonth(), today.getDate());
	} else if (condition == 'first') {
		newDate = new Date(today.getFullYear(), today.getMonth(), 1);
	} else if (condition == 'last') {
		newDate = new Date(today.getFullYear(), today.getMonth() + 1, 0);
	} else if (condition == 'year') {
		newDate = new Date(today.getFullYear(), today.getMonth(), 1);
		return newDate.getFullYear();
	} else if (condition == 'year_first') {
		var year = today.getFullYear()
		return year + "-01-01";
	} else if (condition == 'year_last') {
		var year = today.getFullYear()
		return year + "-12-31";
	} else if (condition == 'month_first') {
		newDate = new Date(today.getFullYear(), today.getMonth(), 1);
		var year = newDate.getFullYear();
		return year + "-01";
	} else if (condition == 'month') {
		newDate = new Date(today.getFullYear(), today.getMonth(), 1);
		var year = newDate.getFullYear();
		var month = newDate.getMonth() + 1;
		if (month < 10)
			month = "0" + month;
		return year + "-" + month;
	} else if (condition == 'today_month') {
		newDate = new Date(today.getFullYear(), today.getMonth(), 1);
		var month = newDate.getMonth() + 1;
		if (month < 10)
			month = "0" + month;
		return month;
	} else if (condition == 'last_month') {
		newDate = new Date(today.getFullYear(), today.getMonth(), 1);

		var year = newDate.getMonth() == 0 ? newDate.getFullYear() - 1 : newDate.getFullYear();
		var month = newDate.getMonth() == 0 ? 12 : newDate.getMonth();
		if (month < 10)
			month = "0" + month;
		return year + "-" + month;
	} else if (condition == 'before_one_month') {
		newDate = new Date(today.getFullYear(), today.getMonth() - 1, today.getDate() + 1);
	} else if (condition == 'before_two_month') {
		newDate = new Date(today.getFullYear(), today.getMonth() - 2, today.getDate() + 1);
	} 
	else {
		newDate = condition;
	}

	var year = newDate.getFullYear();
	var month = newDate.getMonth() + 1;
	var day = newDate.getDate();

	if (month < 10)
		month = "0" + month;
	if (day < 10)
		day = "0" + day;

	return year + "-" + month + "-" + day;
}

/* date20. 날짜 계산하기 */
function gf_addDate(p_date, p_type, p_num) {
	var v_date = new Date(p_date);
	if (p_type == 'year')
		v_date.setFullYear(v_date.getFullYear() + p_num);
	else if (p_type == 'month')
		v_date.setMonth(v_date.getMonth() + p_num);
	else if (p_type == 'day')
		v_date.setDate(v_date.getDate() + p_num);
	return v_date;
}

// 두 날짜사이 일수 구하기
function gf_dateDiff(p_date1, p_date2) {

	var dateDiff;
	var startDate;
	var endDate;

	if ((typeof p_date1) == 'string') {
		endDate = new Date(p_date1);
	} else if (p_date1 instanceof Date) {
		endDate = p_date1;
	}

	if ((typeof p_date2) == 'string') {
		startDate = new Date(p_date2);
	} else if (p_date2 instanceof Date) {
		startDate = p_date2;
	}

	dateDiff = Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 3600 * 24));

	return isNaN(dateDiff) ? '' : dateDiff;
}

// 두 날짜사이 근무일수 구하기
function gf_workingDateDiff(p_start, p_end) {
	var dateDiff;
	var startDate;
	var endDate;
	var holidays = [];
	if ((typeof p_end) == 'string') {
		if(p_end.length == 8){
			p_end = gf_stringDate(p_end);
		}
		endDate = new Date(p_end);
	} else if (p_end instanceof Date) {
		endDate = p_end;
	}

	if ((typeof p_start) == 'string') {
		if(p_start.length == 8){
			p_start = gf_stringDate(p_start);
		}
		startDate = new Date(p_start);
	} else if (p_start instanceof Date) {
		startDate = p_start;
	}

	// 유휴&주휴 조회
	gf_getData({
		data : {
			queryId : 'at.S_AT_HOLIDAY_UTIL',
			v_start_year : startDate.getFullYear(),
			v_end_year : endDate.getFullYear(),
			v_start_date : startDate.yyyymmdd(),
			v_end_date : endDate.yyyymmdd()
		},
		dataType : 'text',
		async : false,
		callback : function(data) {
			holidays = JSON.parse(data);
		}
	});

	dateDiff = Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 3600 * 24));
	dateDiff = dateDiff - holidays[0].count + 1; // 날짜 - 유휴 & 주휴 + 마지막날 포함 1

	return isNaN(dateDiff) ? '' : dateDiff;
}

// 두 날짜사이 근무시간 구하기
function gf_workHourDiff(p_startTime, p_endTime, p_service_div_code, p_startDate, p_endDate) {
	var startHour;
	var endHour;

	var breakStart;
	var breakEnd;
	var breakHour;

	var diffInSec;
	var hours;
	var minutes;

	var result = 0;

	var workTime = [];

	// gf_getData({
	// 	data : {
	// 		queryId : 'at.S_AT_WORK_TIME',
	// 		v_service_div_code : p_service_div_code
	// 	},
	// 	dataType : 'text',
	// 	async : false,
	// 	callback : function(data) {
	// 		workTime = JSON.parse(data);
	// 	}
	// });

	// if(workTime.length == 0){
	// 	workTime = [{
	// 		START_TIME : "12:00"
	// 		,END_TIME: "13:00"
	// 	},{
	// 		START_TIME: "09:00"
	// 		, END_TIME: "18:00"
	// 	}]
	// }
	//
	// breakStart = new Date("01/01/2007" + " " + workTime[0].START_TIME).getHours();
	// breakEnd = new Date("01/01/2007" + " " + workTime[0].END_TIME).getHours();
	// breakHour = breakEnd - breakStart;

	startHour = new Date((p_startDate == undefined ? "01/01/2007" : p_startDate) + " " + p_startTime);
	endHour = new Date((p_endDate == undefined ? "01/01/2007" : p_endDate) + " " + p_endTime);

	//초단위
	// if (startHour < breakStart && endHour > breakEnd) {
	// 	diffInSec = Math.abs(endHour - startHour - breakHour) / 1000;
	// } else {
	// 	diffInSec = Math.abs(endHour - startHour) / 1000;
	// }

	diffInSec = Math.abs(endHour - startHour) / 1000;

	hours = Math.floor(diffInSec / 3600) % 24;
	diffInSec -= hours * 3600;
	minutes = Math.floor(diffInSec / 60) % 60;

	result += hours;
	result += (minutes === 30) ? 0.5 : 0;

	if (p_startDate !== undefined){
		var days = gf_workingDateDiff(p_startDate, p_endDate);
		result = result * days;
	}

	return result;
}
// 같은 날짜 사이 경과시간 구하기 (00:00)
function gf_HourDiff(p_startTime, p_endTime) {
	var start_hours = p_startTime.substring(0,2);
	var start_minutes = p_startTime.substring(3);
	var end_hours = p_endTime.substring(0,2);
	var end_minutes = p_endTime.substring(3);
	
	const date1 = new Date(2000, 1, 1, start_hours, start_minutes, 0);
	const date2 = new Date(2000, 1, 1, end_hours, end_minutes, 0);

	const elapsedMSec = date2 - date1; // 9004000
	const elapsedHour = elapsedMSec / 1000 / 60 / 60; 
	
	var result = elapsedHour.toFixed(2);
	
	return result;
}
//같은 날짜 사이 경과시간 구하기(분) (00:00)
function gf_minutesDiff(p_startTime, p_endTime) {
	var start_hours = p_startTime.substring(0,2);
	var start_minutes = p_startTime.substring(3);
	var end_hours = p_endTime.substring(0,2);
	var end_minutes = p_endTime.substring(3);
	
	const date1 = new Date(2000, 1, 1, start_hours, start_minutes, 0);
	const date2 = new Date(2000, 1, 1, end_hours, end_minutes, 0);

	const elapsedMSec = date2 - date1; // 9004000
	const elapsedHour = elapsedMSec / 1000 / 60; 
	
	var result = elapsedHour;
	
	return result;
}
//yyyymmdd
function gf_getFormatDate(date){
    var year = date.getFullYear();              //yyyy
    var month = (1 + date.getMonth());          //M
    month = month >= 10 ? month : '0' + month;  //month 두자리로 저장
    var day = date.getDate();                   //d
    day = day >= 10 ? day : '0' + day;          //day 두자리로 저장
    return  year + '' + month + '' + day;       //'-' 추가하여 yyyy-mm-dd 형태 생성 가능
}
//yyyy-mm-dd
function gf_getFormatDate2(date){
    var year = date.getFullYear();              //yyyy
    var month = (1 + date.getMonth());          //M
    month = month >= 10 ? month : '0' + month;  //month 두자리로 저장
    var day = date.getDate();                   //d
    day = day >= 10 ? day : '0' + day;          //day 두자리로 저장
    return  year + '-' + month + '-' + day;       //'-' 추가하여 yyyy-mm-dd 형태 생성 가능
}
// 8자리 날짜를 형식에 맞춰서 반환
function gf_stringDate(p_value) {
	return gf_nvl2(p_value, p_value.replace(/(\d{4})(\d{2})(\d{2})/g, '$1-$2-$3').substr(0, 10), '');
}

// 날짜를 형식에 6자리맞춰서 반환
function gf_stringDateMonth(p_value) {
	return gf_nvl2(p_value, p_value.replace(/(\d{4})(\d{2})/g, '$1-$2').substr(0, 7), '');
}
/* yyyymmdd 형식의 문자열 리턴 */
Date.prototype.yyyymmdd = function() {
	var yyyy = this.getFullYear().toString();
	var mm = (this.getMonth() + 1).toString();
	var dd = this.getDate().toString();
	if (isNaN(yyyy)) {
		return '';
	}
	return yyyy + (mm[1] ? mm : '0' + mm[0]) + (dd[1] ? dd : '0' + dd[0]);
}

/* yyyy-mm-dd 형식의 문자열 리턴 */
Date.prototype.yyyy_mm_dd = function() {
	var yyyy = this.getFullYear().toString();
	var mm = (this.getMonth() + 1).toString();
	var dd = this.getDate().toString();
	if (isNaN(yyyy)) {
		return '';
	}
	return yyyy + '-' + (mm[1] ? mm : '0' + mm[0]) + '-' + (dd[1] ? dd : '0' + dd[0]);
}

/* yyyymm 형식의 문자열 리턴 */
Date.prototype.yyyymm = function() {
	var yyyy = this.getFullYear().toString();
	var mm = (this.getMonth() + 1).toString();
	if (isNaN(yyyy)) {
		return '';
	}
	return yyyy + (mm[1] ? mm : '0' + mm[0]);
}

/* yyyy-mm 형식의 문자열 리턴 */
Date.prototype.yyyy_mm = function() {
	var yyyy = this.getFullYear().toString();
	var mm = (this.getMonth() + 1).toString();
	if (isNaN(yyyy)) {
		return '';
	}
	return yyyy + '-' + (mm[1] ? mm : '0' + mm[0]);
}

function gf_leadingZeros(n, digits) {
	var zero = '';
	n = n.toString();

	if (n.length < digits) {
		for (i = 0; i < digits - n.length; i++)
			zero += '0';
	}
	return zero + n;
}

/* YYYY-MM-DD hh:mm:ss 형식의 문자열 리턴 */
Date.prototype.yyyy_mm_dd_hh_mm_ss = function() {
	var s = gf_leadingZeros(this.getFullYear(), 4) + '-' + gf_leadingZeros(this.getMonth() + 1, 2) + '-' + gf_leadingZeros(this.getDate(), 2) + ' ' + gf_leadingZeros(this.getHours(), 2) + ':' + gf_leadingZeros(this.getMinutes(), 2) + ':' + gf_leadingZeros(this.getSeconds(), 2);
	return s;
}

Date.prototype.hh_mm_ss = function() {
	return gf_leadingZeros(this.getHours(), 2) + ':' + gf_leadingZeros(this.getMinutes(), 2) + ':' + gf_leadingZeros(this.getSeconds(), 2);
}

Date.prototype.hh_mm = function() {
	return gf_leadingZeros(this.getHours(), 2) + ':' + gf_leadingZeros(this.getMinutes(), 2);
}

Date.prototype.hh_mm_am_pm = function() {
	return gf_leadingZeros(this.getHours(), 2) + ':' + gf_leadingZeros(this.getMinutes(), 2) + ' ' + (this.getHours() >= 12 ? 'PM' : 'AM');
}

Date.prototype.gf_addDays = function(d) {
	this.setTime(this.getTime() + (d * 24 * 60 * 60 * 1000));
	return this;
}

Date.prototype.gf_addHours = function(h) {
	this.setTime(this.getTime() + (h * 60 * 60 * 1000));
	return this;
}

/* form부분 calendar에서 시작일 종료일이 큰지 확인하는 함수 */
function gf_date_validation(obj) {// 시작일이 종료일보다 클 경우 true를 반환
	if ($('#' + obj.from_date).val() > gf_nvl($('#' + obj.to_date).val(), $('#' + obj.from_date).val())) {
		return true;
	}
	return false;
}
// 날짜와 날짜 사이 모든 날짜 구하기
function gf_getDatesStartToLast(startDate, lastDate) {
	var regex = RegExp(/^\d{4}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$/);
	if(!(regex.test(startDate) && regex.test(lastDate))) return "Not Date Format";
	var result = [];
	var curDate = new Date(startDate);
	while(curDate <= new Date(lastDate)) {
		result.push(curDate.toISOString().split("T")[0]);
		curDate.setDate(curDate.getDate() + 1);
	}
	return result;
}
// ========================================================================================
// Data. data가 null인 경우 치환
// ========================================================================================
/* 01. null 인경우 data2를 반환 */
function gf_nvl(p_data, p_data2) {
	var v_result = '';
	if (p_data === '' || p_data === 'null' || p_data === null || p_data === undefined || p_data === 'undefined') {
		v_result = p_data2;
	} else {
		v_result = p_data;
	}
	return v_result;
}

/* 02. null 인경우 data2 / 아닌 경우 data1을 반환 */
function gf_nvl2(p_data, p_data1, p_data2) {
	var v_result = '';
	if (p_data == '' || p_data == 'null' || p_data == null || p_data == undefined) {
		v_result = p_data2;
	} else {
		v_result = p_data1;
	}
	return v_result;
}

/* 자바스크립트 Object 복사 */
function deepClone(obj) {

	var result = obj.constructor();
	for ( var i in obj) {

		if (typeof (obj[i]) == "object" && obj[i] != null) {
			result[i] = deepClone(obj[i]);
		} else {
			result[i] = obj[i];
		}

	}

	return result;
}

// ========================================================================================
// 쿠키 설정.
// ========================================================================================
/* 쿠키 생성 */
function gf_setCookie(cName, cValue, cDay) {
	var expire = new Date();
	expire.setDate(expire.getDate() + cDay);
	cookies = cName + '=' + escape(cValue) + '; path=/ '; // 한글 깨짐을 막기위해
	// escape(cValue)를
	// 합니다.
	if (typeof cDay != 'undefined')
		cookies += ';expires=' + expire.toGMTString() + ';';
	document.cookie = cookies;
}

/* 쿠키 가져오기 */
function gf_getCookie(cName) {
	cName = cName + '=';
	var cookieData = document.cookie;
	var start = cookieData.indexOf(cName);
	var cValue = '';
	if (start != -1) {
		start += cName.length;
		var end = cookieData.indexOf(';', start);
		if (end == -1)
			end = cookieData.length;
		cValue = cookieData.substring(start, end);
	}
	return unescape(cValue);
}

// 내/외국인 주민번호검증
function gf_regisVerify(regNo) {

	regNo = regNo.replaceAll('-', '');

	var ssn2f = regNo.substr(6, 1);

	if (ssn2f == '5' || ssn2f == '6' || ssn2f == '7' || ssn2f == '8') {
		var type = 'frn';
	} else {
		var type = 'kor';
	}
	return isJumin(regNo, type);
}

function isJumin(rn, type) {

	if (rn.length !== 13) {
		gf_toast(gf_msg('not_length_reg_no'));
		return false;
	}
	var checkSum = 0;

	for (var i = 0; i < 12; i++){
		checkSum += ((rn.substr(i, 1) >> 0) * ((i % 8) + 2));
	}

	var korMatch = (11 - (checkSum % 11)) % 10 == rn.substr(12, 1);
	var frnMatch = (13 - (checkSum % 11)) % 10 == rn.substr(12, 1);

	if (type === 'kor') {
		if(korMatch == false){
			gf_toast(gf_msg('not_reg_no'));
		}
		return korMatch;
	} else if (type === 'frn') {
		if(frnMatch == false){
			gf_toast(gf_msg('not_reg_no'));
		}
		return frnMatch;
	} else {
		if(korMatch || frnMatch == false){
			gf_toast(gf_msg('not_reg_no'));
		}
		return korMatch || frnMatch;
	}
}


// 사업자등록번호 검증
var gf_BizNumValid = function (BizNum) {

	BizNum = BizNum.replaceAll('-','');

	var logicNum = [1, 3, 7, 1, 3, 7, 1, 3, 5, 1];

	if (!isNumeric(BizNum) || BizNum.length != 10) {
		gf_toast(gf_msg('not_length_biz_no'));
		return false;
	}

	var sum = 0;
	var j = -1;
	for (var i = 0; i < 9; i++) {
		j = parseInt(BizNum.charAt(i));
		sum += j * logicNum[i];
	}

	sum += parseInt((BizNum.charAt(8)) * 5 /10);

	var checkNum = (10 - sum % 10) % 10 ;
	if(checkNum == parseInt(BizNum.charAt(9))){
		return true;
	}else{
		gf_toast(gf_msg('not_biz_no'));
		return false;
	}
}

var isNumeric = function (str) {

	if (str == null) {
		return false;
	}
	var sz = str.length;
	for (var i = 0; i < sz; i++) {
		if ($.isNumeric(str.charAt(i)) == false) {
			return false;
		}
	}
	return true;
}


// 법인번호 검사
var gf_corpRegNumValid = function (corpRegNum) {

	corpRegNum = corpRegNum.replace('-','');

	if (corpRegNum.length != 13){
		gf_toast(gf_msg('not_length_corp_reg_no'));
		return false;
	}

	var arr_regno  = corpRegNum.split("");

	var arr_wt   = [1,2,1,2,1,2,1,2,1,2,1,2];
	var iSum_regno  = 0;
	var iCheck_digit = 0;

	for (var i = 0; i < 12; i++){
		iSum_regno +=  parseInt(arr_regno[i]) * arr_wt[i];
	}

	iCheck_digit = 10 - (iSum_regno % 10);

	iCheck_digit = iCheck_digit % 10;

	if (iCheck_digit != parseInt(arr_regno[12])){
		gf_toast(gf_msg('not_corp_reg_no'));
		return false;
	}else{
		return true;
	}
}

//폼 버튼팝업 셋팅
var gf_set_button_popup = function(){

	$('input[data-pop]').off('onchange');
	$('input[data-pop]').off('onfocusin');
	$('button[data-pop]').off('onclick');

	// 폼 영역의 팝업 input의 개수를 읽어와서
	// input 입력창에 단어를 입력했을때의 팝업창을 띄워주는 이벤트와 포커스 이벤트를 넣어준다.
	for (var i = 0; i < $('input[data-pop]').length; i++) {

		$('input[data-pop]')[i].addEventListener('change', gf_formChange, false);
		$('input[data-pop]')[i].addEventListener('focusin', function() {
			gf_focusing(this);
		}, false);
	}

	// 폼 영역의 팝업 button의 개수를 읽어와서
	// button 창에 버튼을 클릭할 때 팝업을 띄워주는 이벤트를 넣어준다.
	for (var i = 0; i < $('button[data-pop]').length; i++) {
		$('button[data-pop]')[i].addEventListener('click', gf_formBtnClick, false);
	}

}

var gf_isEmpty = function(value){
        
    if( value == "" || value == null || value == undefined || ( value != null && typeof value == "object" && !Object.keys(value).length ) ){

      return true
    }else{
  
      return false
    }
  };

var gf_sendMail = function(param){
	$.ajax({
		type     : "GET",
		url      : gv_corporationIni + "/sendMail",
		data     : param.data,
		success  : param.callback,
		complete : param.complete,
//		dataType : gf_nvl(param.dataType, 'json'),
		async    : gf_nvl(param.async, true)
	});
	// data양식
	//{
	//	from : { email : "" // 발신자 email - 필수값
	//			,name : "" // 발신자 이름 - 필수값
	// ,to : [] // 수신자 이메일 list - 필수값
	// ,cc : [] // 참조자 이메일 list - 빈값가능
	// ,bcc : [] // 숨은참조 이메일 list - 빈값가능
	// ,subject : "" // 메일제목 - 필수값
	// ,content : "" // 메일내용 - 필수값
	//}
}

// 파라미터 : v_comm_corporation_id, v_fi_bi_division_id, v_budget_year, v_budget_period, v_bd_type_code
//         법인id                  회계단위                           예산년도                 예산월                     투자(bd700200), 경비(bd700300)
//		  , v_bd_bi_cost_center_id, v_bd_bi_account_id, v_bd_bi_project_id, v_currency, v_budget
//          costcenter id            account id         project id           통화              체크할 금액
// 가용예산을 조회하여 예산과 비교하여 초과여부를 리턴한다.
//ex) gf_checkAvailableBudget(52, 13, "2023", "09", "bd700200", 612, 367, 4519, "KRW", 10000)

var gf_checkAvailableBudget = function(v_comm_corporation_id, v_fi_bi_division_id, v_budget_year, v_budget_period, v_bd_type_code, v_bd_bi_cost_center_id, v_bd_bi_account_id, v_bd_bi_project_id, v_currency, v_budget){
	console.log("budget: " + v_budget);
	var result = "";
    $.ajax({
        type : "POST",
        url : "/bd/checkAvailableBudget",
        dataType : "json",
        async : false,
        data : {
			 v_comm_corporation_id	: v_comm_corporation_id,
			 v_fi_bi_division_id	: v_fi_bi_division_id,
			 v_budget_year			: v_budget_year,
			 v_budget_period		: v_budget_period,
			 v_bd_type_code			: v_bd_type_code,
			 v_bi_cost_center_id    : v_bd_bi_cost_center_id,
			 v_bi_account_id		: v_bd_bi_account_id,
			 v_bi_project_id		: v_bd_bi_project_id,
			 v_currency				: v_currency,
        },
        success : function(data) {
        	
        	if ( !gf_isEmpty(data.error)){
        		alert(data.error);
        		return false;
        	}
        	
        	result = data.available_budget;
        	console.log("available_budget : " + result);
        },
        error : function (request, status, error) {
            console.log("error : " + request.responseText, status, error);
        }
    });
    
//    console.log('result : ', result);
//    var resultList = {};
//	if ( (gf_uncomma(v_budget) <= gf_uncomma(result)) || result == -1  ) {
//		return resultList = {
//			result : true,
//			available_budget : result
//		};
//	} else {
//		return resultList = {
//				result : false,
//				available_budget : result
//			};
//	}
	
	if ( (gf_uncomma(v_budget) <= gf_uncomma(result)) || result == -1  ) {
		return true;
	} else {
		return false;
	}
}

//자동분개 생성
//parameter : keyList -> 원천의 ID
//return : true, false
function gf_autoAccountingGenerate(param) {
	$.ajax({
		type : "POST",
		url : "/auto/autoAccountingGenerate",
		data : param.data,
		success : param.callback,
		dataType : gf_nvl(param.dataType, 'json'),
		async : gf_nvl(param.async, false) 
	});
}

function gf_budgetAppr(param) {
	$.ajax({
		type     : "POST",
		url      : "/bd/budgetAppr",
		data     : param.data,
		success  : param.callback,
		complete : param.complete,
		dataType : gf_nvl(param.dataType, 'json'),
		async    : gf_nvl(param.async, false)
	});
}


/*************** 
 * OZ레포트 관련 * 
 */
var _ozPath = "";
if (location.hostname.includes('localhost')) _ozPath = "http://10.10.11.72:28088";
else if (location.hostname.includes('dev')) _ozPath = "https://sbmdev.samjoomaritime.com";
else _ozPath = "https://sbm.samjoomaritime.com";

var _ozReportDivId = "OZViewer"; // 고정값.
var _bMulti = false;
var _ozParameters = [];
var _ozParameters2 = [];
/* 
 * OZ레포트 로드
 * 
 * @param ozReportDivId 오즈리포트 div id  , ozReportViewer
 * @param ozParams 오즈리포트에 넘길 파라미터
 * @param bMulti 멀티리포트 여부
 * @example 
			  const json = {
			        "Category": [
			            {"CategoryID": 1, "CategoryName": "테스트", "Description": "오즈리포트"},
			            {"CategoryID": 2, "CategoryName": "설치과정", "Description": "오즈파일을호출"}
			        ], 
			        "Product": [
			            {"ProductID": 75, "ProductName": "테스트제품", "CategoryID": 1, "QuantityPerUnit": "24 - 0.5 l bottles", "UnitPrice": 24000.0000, "UnitsInStock": 125},
			            {"ProductID": 39, "ProductName": "OK 제품", "CategoryID": 1, "QuantityPerUnit": "750 cc per bottle", "UnitPrice": 28000.0000, "UnitsInStock": 69},
			            {"ProductID": 34, "ProductName": "기타 제품", "CategoryID": 1, "QuantityPerUnit": "24 - 12 oz bottles", "UnitPrice": 34000.0000, "UnitsInStock": 111},
			            {"ProductID": 65, "ProductName": "음료", "CategoryID": 2, "QuantityPerUnit": "32 - 8 oz bottles", "UnitPrice": 21000.0000, "UnitsInStock": 76},
			            {"ProductID": 61, "ProductName": "스낵", "CategoryID": 2, "QuantityPerUnit": "24 - 500 ml bottles", "UnitPrice": 28000.0000, "UnitsInStock": 92},
			            {"ProductID": 6, "ProductName": "기타 제품", "CategoryID": 2, "QuantityPerUnit": "12 - 8 oz jars", "UnitPrice": 25000.0000, "UnitsInStock": 120}
			        ]
			    };
			    var ozReportDivId = "ozReportViewer";			    
			    var ozParams = [
			    	{"connection.args1": "jsondata=" + JSON.stringify(json)},
			    	{"connection.args2": "viewerType=HTML5 Canvas Viewer"}];
			    gf_loadOzreportAsync(ozReportDivId, ozParams);
    
 */
var gf_loadOzreportAsync = async function (ozReportDivId, ozParams, bMulti) {
    try {
    	
        const ozReportViewer = document.getElementById(ozReportDivId);
        if (ozReportViewer && ozReportViewer.innerHTML.trim() !== "") {
            ozReportViewer.innerHTML = "";
        }

        // 스크립트 호출 
//        await loadScript(_ozPath + '/oz90/ozhviewer/jquery-2.0.3.min.js');
//        await loadCSS(_ozPath + '/oz90/ozhviewer/jquery-ui.css');
//        await loadScript(_ozPath + '/oz90/ozhviewer/jquery-ui.min.js');
        
        await loadCSS(_ozPath + '/oz90/ozhviewer/ui.dynatree.css');
        await loadScript(_ozPath + '/oz90/ozhviewer/jquery.dynatree.js');
        await loadScript(_ozPath + '/oz90/ozhviewer/OZJSViewer.js');
        if(bMulti){
        	await loadScript(_ozPath + '/oz90/ozhviewer/OZJSSVGViewer.js');
        }

        // 오즈레포트 초기설정
        initOzViewer(ozReportDivId, ozParams, bMulti);

    } catch (error) {
        console.error("ozviewer 오류 발생:", error);
    }
};


//오즈레포트 OZJSViewer.js 내부에서 호출함.
function SetOZParamters_OZViewer () {
    var oz = document.getElementById(_ozReportDivId);
    oz.sendToActionScript("connection.servlet", _ozPath + "/oz90/server");
    oz.sendToActionScript("information.debug", "true");
    oz.sendToActionScript("viewer.pagedisplay", "continuous");
    oz.sendToActionScript("viewer.pagenavigate_by_scroll", "true");
    oz.sendToActionScript("information.debug", "true");
    
    if(_bMulti){
    	  // 멀티보고서 공통 패러미터
    	  oz.sendToActionScript("viewer.childcount","2"); // 멀티보고서의 child 개수 (전체개수-1)
    	  oz.sendToActionScript("viewer.focus_doc_index","0"); // 처음 보여지는 보고서 번호(0부터 시작)
    	  oz.sendToActionScript("viewer.showtree","true"); // 트리창 표시
    	  oz.sendToActionScript("print.alldocument","true"); // 멀티 보고서 한번에 인쇄
    	  oz.sendToActionScript("global.concatpage","true"); // 멀티 보고서를 하나의 보고서처럼 보여줌. 페이지 이어짐
    	  oz.sendToActionScript("global.inheritparameter","true"); // 첫번째 보고서의 파라미터 값을 상속 받음
    }

    if (Array.isArray(_ozParameters) && _ozParameters.length > 0) {
        _ozParameters.forEach(function (item) {
            for (let key in item) {
                oz.sendToActionScript(key, item[key]);
            }
        });
    }
    
    
     //콘솔 이모지 ✅ → \u2705 ❌ → \u274C ⚠️ → \u26A0
    console.log("\u2705 레포트 로딩 성공!", "ozParams=", _ozParameters);
    return true;
}

// OZ viewer 초기화 설정. start_ozjs 호출
async function initOzViewer(ozReportDivId, ozParams, bMulti) {
    try {
    	if( ozReportDivId ){
	        console.log("_ozload .... ", ozReportDivId, ozParams, bMulti);
	        var ozReportDiv = document.getElementById(ozReportDivId);
	        var $existOzReport = $('#' + ozReportDivId).find('#'+_ozReportDivId);
	        if ($existOzReport.length) {
	        	$existOzReport.remove();  // 기존 요소 삭제
	        }
	    	$('#'+ ozReportDivId).append('<div id="'+_ozReportDivId+'" style="width:99%;height:99%;"></div>');
            $('#'+ ozReportDivId).data("ozParams", ozParams);
            _ozParameters = ozParams;
	    	_bMulti = bMulti;
    	}    	
    	start_ozjs(_ozReportDivId, _ozPath + "/oz90/ozhviewer/");
        
    } catch (error) {
        console.error(" ⚠️ 오즈 호출 발생:", error.message);
    }
}

var gf_popup_ozreport_full = function (ozParam) {
	console.log('gf_popup_ozreport_full: ', ozParam);
	if(gf_isEmpty(ozParam) && gf_isEmpty(_ozParameters) && _ozParameters.length == 0){
		//gf_toast(gf_msg("popup_invoice_budget_2")); // 예산유형이 없습니다.
		gf_toast("오즈레포트 파라미터가 없습니다."); // 예산유형이 없습니다.
		return;
	}
	var	ozParameter = ozParam?ozParam:_ozParameters;
//    var arg = 'comm_corporation_id' + ',' + gv_login_corporation_id
//        + ',lang_code' + ',' + gv_login_user_lang
//        + ',doc_id' + ',' + docInfo.EA_DOC_ID
//    ;
//    window.open('/resources/oz90/ozviewer.jsp?ozFileName=' + ozFileName + '&ozParamsStr=' + encodeURI(_ozParameters));

	$.ajax({
		url: '/resources/oz90/ozviewer.jsp',
		type: "POST", // 또는 "POST"
		data: { // data 속성에 파라미터들을 객체 형태로 정의합니다.
			ozUrl:_ozPath,
			ozParamsStr: encodeURIComponent(JSON.stringify(ozParameter))
		},
		success: function(data) {
			var newWindow = window.open("", "리포트 미리보기"); // 새 창 열기
			newWindow.document.write(data); // JSP 파일의 내용을 새 창에 씁니다.
			newWindow.document.close(); // 문서 작성을 완료합니다.
		},
		error: function(xhr, status, error) {
			console.log(" \u26A0\u26A0\u26A0\u26A0\u26A0 OZReport AJAX 요청 실패:", status, error);
			gf_toast("새로운 창을 여는 데 실패했습니다.");
		}
	});
}

// 외부 Script 로드
async function loadScript(src) {
    return new Promise((resolve, reject) => {
        var script = document.createElement('script');
        script.type = 'text/javascript';
        script.src = src;
        script.onload = () => resolve();
        script.onerror = () => reject(new Error('Failed to load script: ' + src));
        document.head.appendChild(script);
    });
}

// 외부  Link 로드
async function loadCSS(href) {
    return new Promise((resolve, reject) => {
        var link = document.createElement('link');
        link.rel = 'stylesheet';
        link.type = 'text/css';
        link.href = href;
        link.onload = () => resolve();
        link.onerror = () => reject(new Error('Failed to load CSS: ' + href));
        document.head.appendChild(link);
    });
}

// 로그인 환경 가져오기 [ local, dev, prod ]
function gf_getLoginEnv(param) {
    var r = "";
    $.ajax({
        type     : "GET",
        url      : "/getLoginEnv",
        async    : false,
        success: function(data) {
            if(data)
                r = data.login_env;
        }
    });
    return r;
}

