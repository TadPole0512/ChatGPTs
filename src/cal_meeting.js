var calendar  = null;
var type_list = null;

document.addEventListener('DOMContentLoaded', function () {


    type_list = gf_getComboData({
        popup_code: 'comm_mu_code',
        param     : {
            code_master: 'comm007'
        }
    });

    li_list();
    $("#all_check").on('click', function () {
        if(this.checked) {
        	$("input[type=checkbox][name=meeting_checkbox]").prop('checked', true);
        	f_meeting_list(true);
        } else {
        	$("input[type=checkbox][name=meeting_checkbox]").prop('checked', false);
        	f_meeting_list(false);
        }
    });

    // 회의실 선택 이벤트
    $('.cal_checkbox').click(function() {
        var checkedLength = $('.room_checkbox:checked').length;
        var checkboxLength = $('.room_checkbox').length;

        if(checkedLength == checkboxLength) {
            $('#all_check').prop('checked', true);
        } else if (checkedLength < checkboxLength) {
            $('#all_check').prop('checked', false);
        }

        f_meeting_list();
    });

    makeFC();
    $("#all_check").click();

    // 날짜 바뀔 때
    $('.fc-prev-button, .fc-next-button, .fc-today-button').on('click', function() {
        f_meeting_list(true);
    });

    $('.fc-license-message').hide();
});

var initialView = 'dayGridMonth';
var lastClickTime = 0;

function makeFC() {
	
    if (calendar)
        calendar.destroy();

    calendar = new FullCalendar.Calendar(document.getElementById('calendar'), {
        selectable   : true,
        editable     : true,
        dayMaxEvents : false,
        initialView  : initialView,
        contentHeight: 'auto',
        expandRows   : true,
        allDayText     : gf_word('종일'),
        headerToolbar: {
            left  : 'today',
            center: 'prev title next',
            right : 'dayGridMonth,timeGridWeek,timeGridDay',
        },
        dateClick: function(info) {
            var clickTime = new Date().getTime();
            if (clickTime - lastClickTime < 500) { // 400ms 이내에 두 번 클릭하면 더블 클릭으로 간주
                info.self = true;
                pop(info, 'select');
            }
            lastClickTime = clickTime;
        },
        // select      : function (info) {
        //     info.self = true;
        //     pop(info, 'select');
        // },
        eventClick  : function (info) {
        	console.log(info.event)
            info.self = true;
            // 2025-10-31 fix/cal/0044_02_hsg 겸직이신 분들도 법인에 상관없이 수정이나 삭제가 가능하게 하기 위해 emp_no 추가
            //if (info.event._def.extendedProps.employee != gv_login_employee_id) {
            if (info.event._def.extendedProps.emp_no != gv_emp_info.emp_no) {
                info.self = false;
            }
            pop(info, 'eventClick');
        },
        eventResize : function (info) {
            info.self = true;
            if (info.event._def.extendedProps.employee != gv_login_employee_id) {
                info.revert();
                return false;
            }
            pop(info, 'eventResize');
        },
        eventDrop   : function (info) {
            info.self = true;
            if (info.event._def.extendedProps.employee != gv_login_employee_id) {
                info.revert();
                return false;
            }
            pop(info, 'eventDrop');
        },
        eventReceive: function (info) {
            info.self = true;
            pop(info, 'eventReceive');
        },
    });
    calendar.render();
}

var pop_con = null;

function pop(info, mode) {
    var sb = {
        text   : gf_word("저장"),
        icon   : "ui-icon-heart",
        click  : function () {
            var result = $(`#${$(this).attr('id')}_iframe`)[0].contentWindow.f_result();
            if(result) {
                var call = f_save.call();
            }
            if (call) {
                $(this).dialog("destroy").remove();
                $('.popup_mask').remove();
            }
        },
        'class': 'modal_footer_btn1',
    };

    var db = {
        text   : gf_word("삭제"),
        icon   : "ui-icon-heart",
        click  : function () {
            gf_setData({
                data    : {
                    queryId                 : 'com.D_COMM_CALENDAR_MEETING',
                    COMM_CALENDAR_MEETING_ID: info.event.id
                },
                callback: function (data) {
                    initialView     = calendar.view.type;
                    // calendar.removeAllEvents();
                    f_meeting_list(true);
                },
                async   : false
            });

            $(this).dialog("destroy").remove();
            $('.popup_mask').remove();
        },
        'class': 'modal_footer_btn1',
    };

    var cb = {
        text   : gf_word("닫기"),
        icon   : "ui-icon-heart",
        click  : function () {
            if (mode == 'eventDrop' || mode == 'eventReceive')
                info.revert();
            $(this).dialog("destroy").remove();
            $('.popup_mask').remove();
        },
        'class': 'modal_footer_btn0',
    };

    var buttonList = [];

    if (info.self != true) {
        buttonList = [cb];
    } else {
        if (mode == 'eventDrop' || mode == 'eventResize' || mode == 'eventReceive' || mode == 'select') {
            buttonList = [sb, cb];
        } else if (mode == 'eventClick') {
            buttonList = [sb, db, cb];
        }
    }

    var popup_param = {
        popup_code  : 'popup_cal',
        popup_width : 500,
        popup_height: 600,
        button      : buttonList,
        param       : {
            data : info.event ? info.event.extendedProps : null
        },
        title       : gf_word('회의실예약')
    }
    gf_modal_popup(popup_param);

    $('#popup_popup_cal_iframe').load(function () {

        pop_con = $($(this).contents());

        if (info.self != true) {
            pop_con.find('#id').val(info.event.id);
            pop_con.find('#employee').val(info.event.extendedProps.employee);
            pop_con.find('#emp_name').val(info.event.extendedProps.emp_name);
            pop_con.find('input, textarea').each(function() {
                $(this).attr('readonly', true).attr('disabled', true);
            });
        }

        if (mode == 'eventClick' || mode == 'eventDrop' || mode == 'eventResize') {
            pop_con.find('#id').val(info.event.id);
            pop_con.find('#employee').val(info.event.extendedProps.employee);
            pop_con.find('#emp_name').val(info.event.extendedProps.emp_name);
            pop_con.find('#type').val(info.event.extendedProps.type);
            pop_con.find('#title').val(info.event.title);
            pop_con.find('#contents').val(info.event.extendedProps.contents);
            pop_con.find('#s_date').val(info.event.start.yyyy_mm_dd());
            pop_con.find('#s_time').val(info.event.start.hh_mm());
            pop_con.find('#e_date').val(info.event.extendedProps.end_date);
            pop_con.find('#e_time').val(info.event.extendedProps.end_time);

            // 하루
            if(info.event.allDay) {
                pop_con.find('#all_day').prop('checked', true);
                pop_con.find('#e_time, #s_time').attr('readonly', true);
            }

        } else if (mode == 'eventReceive') {
            // end값 null
            pop_con.find('#type').val(info.draggedEl.id);
            pop_con.find('#s_date').val(info.event.start.yyyy_mm_dd());
            pop_con.find('#s_time').val(info.event.start.hh_mm());
            if (calendar.view.type == 'dayGridMonth') {
                pop_con.find('#e_date').val(info.event.start.gf_addDays(1).yyyy_mm_dd());
                pop_con.find('#e_time').val(info.event.start.hh_mm());
            } else {
                if (info.event.allDay == true) {
                    pop_con.find('#e_date').val(info.event.start.gf_addDays(1).yyyy_mm_dd());
                    pop_con.find('#e_time').val(info.event.start.hh_mm());
                } else {
                    pop_con.find('#e_date').val(info.event.start.yyyy_mm_dd());
                    pop_con.find('#e_time').val(info.event.start.gf_addHours(1).hh_mm());
                }
            }
        } else if (mode == 'select') {
        	pop_con.find('#emp_name').val(gv_emp_info.emp_name);
            pop_con.find('#s_date, #e_date').val(info.start.yyyy_mm_dd());
            if(calendar.view.type == 'dayGridMonth') {  // monthly

            } else if(calendar.view.type == 'timeGridWeek') {   // weekly
                if(info.allDay) {
                    pop_con.find('#all_day').prop('checked', true);
                    pop_con.find('#s_time').val(info.start.hh_mm()).attr('readonly', true);
                    pop_con.find('#e_time').val('23:59').attr('readonly', true);
                } else {
                    pop_con.find('#s_date').val(info.start.yyyy_mm_dd());
                    pop_con.find('#s_time').val(info.start.hh_mm());
                    pop_con.find('#e_date').val(info.end.yyyy_mm_dd());
                    pop_con.find('#e_time').val(info.end.hh_mm());
                }
            } else if(calendar.view.type == 'timeGridDay') {
                if(info.allDay) {
                    pop_con.find('#all_day').prop('checked', true);
                    pop_con.find('#s_time').val(info.start.hh_mm()).attr('readonly', true);
                    pop_con.find('#e_time').val('23:59').attr('readonly', true);
                } else {
                    pop_con.find('#s_time').val(info.start.hh_mm());
                    pop_con.find('#e_time').val(info.end.hh_mm());
                }
            }
        }

    });

}

function f_save() {
    var queryId = 'com.I_COMM_CALENDAR_MEETING';
    var id      = pop_con.find('#id').val();
    if (id) {
        queryId = 'com.U_COMM_CALENDAR_MEETING';
    }

    // 2025-10-23 fix/cal/req-0142-hsg Myself - 일정 및 예약관리 - 회의실 예약 중복체크 : 주석 처리되어 있던 부분을 주석 해제함
    if (!f_meeting_chk()) {
        gf_toast("선택하신 회의실이 이미 일정이 등록되어있습니다.");
        return false;
    }

    gf_setData({
        data    : {
            queryId                 : queryId,
            COMM_CALENDAR_MEETING_ID : id,
            comm_corporation_id     : gv_login_corporation_id,
            employee_id             : gv_login_employee_id,
            title                   : pop_con.find('#title').val(),
            contents                : pop_con.find('#contents').val(),
            s_date                  : pop_con.find('#s_date').val(),
            e_date                  : pop_con.find('#e_date').val(),
            s_time                  : pop_con.find('#s_time').val(),
            e_time                  : pop_con.find('#e_time').val(),
            type                    : pop_con.find('#type').val(),
            all_day                 : pop_con.find('#all_day').is(':checked') ? '1' : '0'
        },
        callback: function (data) {
        	// calendar.removeAllEvents();
            f_meeting_list(true);
        },
        async   : false
    });

    return true;
}

// 회의실 예약 일정 조회

function f_meeting_list(check, target) {

    calendar.removeAllEvents();
    var type = [];

    if(!$('#all_check').is('checked')) {
        for(var i=0; i < $('.room_checkbox').length; i++) {
            if($('.room_checkbox').eq(i).is(':checked')) {
                type.push($('.room_checkbox').eq(i).attr('id'));
            }
        }
    }

    $.ajax({
        url     : '/getData.ajax',
        type    : 'POST',
        dataType: 'json',
        data    : {
            queryId: 'com.S_COMM_CALENDAR_MEETING',
            p_date : calendar.getDate().yyyy_mm(),
            type   : type.toString()
        },
        success : function (data) {
        	console.log(data);
            for (date of data) {
                calendar.addEvent({
                    id             : date.comm_calendar_meeting_id,
                    employee       : date.employee_id,
                    emp_no         : date.emp_no, /* 2025-10-31 fix/cal/0044_02_hsg 겸직이신 분들도 법인에 상관없이 수정이나 삭제가 가능하게 하기 위해 emp_no 추가 */
                    emp_name       : date.emp_name,
                    type           : date.type,
                    title          : date.title,
                    contents       : date.contents,
                    start          : date.s_date + ' ' + date.s_time,
                    end            : date.e_date + ' ' + date.e_time,
                    start_time     : date.s_time,
                    end_date       : date.e_date,
                    end_time       : date.e_time,
                    allDay         : date.all_day == '1' ? true : false,
                    // display        : 'block',
                    backgroundColor: date.color,
                    borderColor    : date.color,
                    textColor      : '#444'
                });
                calendar.render();
            }
        },
        async   : false
    });

    /*if (check) {
        $.ajax({
            url     : '/getData.ajax',
            type    : 'POST',
            dataType: 'json',
            data    : {
                queryId: 'com.S_COMM_CALENDAR_MEETING',
                P_DATE : calendar.getDate().yyyy_mm(),
                TYPE   : type.toString()
            },
            success : function (data) {

                for (date of data) {
                    calendar.addEvent({
                        id             : date.COMM_CALENDAR_MEETING_ID,
                        employee       : date.EMPLOYEE_ID,
                        emp_name       : date.EMP_NAME,
                        type           : date.TYPE,
                        title          : date.TITLE,
                        contents       : date.CONTENTS,
                        start          : date.S_DATE + ' ' + date.S_TIME,
                        end            : date.E_DATE + ' ' + date.E_TIME,
                        display        : 'block',
                        backgroundColor: date.COLOR,
                        borderColor    : date.COLOR,
                        textColor      : '#444'
                    });
                    calendar.render();
                }
            },
            async   : false
        });
    } else {
        var cl_cal = calendar.getEvents();
        var checkbox = document.querySelectorAll('input[name="MEETING_CHECKBOX"]');
        for (var check in checkbox) {
        	for (var cal in cl_cal) {
        		if(!(checkbox[check].checked) && checkbox[check].id == cl_cal[cal]._def.extendedProps.type) {
        			calendar.getEventById(cl_cal[cal]._def.publicId).remove();
            	}
        	}
        }
    }*/
}

// 일정 체크
var f_meeting_chk = function () {
    var chk = true;

    gf_getData({
        data    : {
            queryId            : 'com.S_CAL_CALENDAR_MEETING_CHECK',
            comm_corporation_id: gv_login_corporation_id,
            s_date             : pop_con.find('#s_date').val(),
            s_time             : pop_con.find('#s_time').val(),
            e_time             : pop_con.find('#e_time').val(),
            type               : pop_con.find('#type').val(),
            v_id               : pop_con.find('#id').val()
        },
        callback: function (data) {
            if (data.length > 0) {
                chk = false;
            } else {
                chk = true;
            }
        },
        async   : false
    });
    return chk;
}

// 리스트 만들기
function li_list() {
	for(i = 0; i < type_list.length; i++){
		var li = $('<li></li>').addClass('cal_check');
		var input =  $('<input class="cal_checkbox room_checkbox" name="meeting_checkbox" type="checkbox" id="' + type_list[i].code_value + '"/>')
		var label= $('<label class="cal_check_label">' + type_list[i].code_name + '</label>')
		var rgb = '<span class="cal_color" style="background-color: ' + type_list[i].attribute1 + '"></span>'
		li.append(input).append(label).append(rgb);
		$('#cal_meeting').append(li);
	}
	/*$("input[name=MEETING_CHECKBOX]").on('click', function (e) {
        f_meeting_list(this.checked, e);
    })*/
}

function f_checkbox_controller(chk) {
    var all_buttons = $(".con_button:checked");
    for (var i = 0; i < all_buttons.length; i++) {
        $(all_buttons[i]).trigger('click');
    }
    if (chk) {
        $("input[type=checkbox][name=meeting_checkbox]").click();
    }
}


function f_end_time(date) {
    var hours = date.getHours();
    var mins = date.getMinutes();

    hours = hours - 1;
    if(hours < 0) hours = 23;

    mins = mins - 1;
    if(mins < 0) mins = 59;

    return hours + ':' + mins;
}