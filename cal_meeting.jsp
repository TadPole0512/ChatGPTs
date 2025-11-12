<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>회의실예약</title>
    <link href='resources/fullcalendar/main.css' rel='stylesheet'/>
    <style>
        #calendar {
            width: 100%;
            height: 100%;
            float: left;
        }
        #external-events .fc-event {
            cursor: move;
            margin: 3px 0;
        }
        .calendar_card {
            display: inline-block;
            float: left;
            width: 300px;
            background-color: #fff;
            border: 1px solid #dcdcdc;
            border-radius: 5px;
            margin-top: 160px;
            margin-left: 50px;
        }

        .calendar_card .calendar_card_title {
            display: inline-block;
            width: 100%;
            border-bottom: 1px solid #dcdcdc;
            padding: 20px;
            font-size: 18px;
            color: #181C32;
        }

        .calendar_card .calendar_card_body {
            display: inline-block;
            width: 100%;
            padding: 20px;
            text-align: center;
        }

        .calendar_card_body .card_card_type {
            display: inline-block;
            width: 100%;
            height: 37px;
            line-height: 37px;
            padding-left: 10px;
            margin-bottom: 10px;
            border-radius: 5px;
            cursor: pointer;
            text-align: left;
            font-size: 14px;
            font-weight: 500;
        }

        .calendar_popup0 {
            display: none;
            width: 500px;
            position: relative;
            top: -622.5px;
            left: 710px;
            z-index: 9999;
            box-shadow: 3px 3px 20px 0px;
            border-radius: 4px;
            background-color: #fafafa;
        }

        .calendar_popup0 .modal_wrap {
            height: unset;
        }

        .calendar_popup0 .ui-dialog-buttonset {
            celar: both;
        }

        .calendar_popup0 .calendar_popup_table {

        }

        .calendar_popup_table .calendar_table_tr {
            display: inline-block;
            width: 100%;
            margin-bottom: 10px;
            padding-left: 10px;
        }

        .calendar_popup_table .calendar_table_tr .calendar_table_th {
            display: inline-block;
            width: 90px;
            margin-right: 10px;
            font-size: 15px;
            font-weight: 500;
            color: #222;
        }

        .calendar_popup_table .calendar_table_tr .calendar_table_td {
            display: inline-block;
            font-size: 15px;
            font-weight: 500;
            color: #222;
        }

        .calendar_popup1 {
            display: none;
            width: 500px;
            height: 500px;
            position: relative;
            top: -622.5px;
            left: 710px;
            z-index: 9999;
            box-shadow: 3px 3px 20px 0px;
            border-radius: 4px;
            background-color: #fafafa;
        }

        .calendar_popup1 .modal_wrap {
            height: unset;
        }

        .calendar_popup1 .ui-dialog-buttonset {
            celar: both;
        }

        .calendar_sorting {
            display: inline-block;
            width: 300px;
            float: left;
            margin-top: 160px;
            margin-left: 50px;
            border: 1px solid #dcdcdc;
            border-radius: 5px;
            margin-bottom: 10px;
        }

        .calendar_sorting .sorting_title {
            display: inline-block;
            width: 100%;
            border-bottom: 1px solid #dcdcdc;
            padding: 20px;
            font-size: 18px;
            color: #181C32;
        }

        .calendar_sorting .sorting_list_wrap {
            display: inline-block;
            width: 100%;
            padding: 20px;
        }

        .sorting_list_wrap .sorting_list {
            display: inline-block;
            width: 100%;
            height: 22px;
            line-height: 22px;
            margin-bottom: 8px;
        }

        .sorting_list_wrap .sorting_list .sorting {
            display: inline-block;
            font-size: 14px;
            color: #222;
            padding-left: 15px;
        }

        .sorting_list_wrap .sorting_list .sorting.on {
            font-weight: 500;
        }

        .sorting_list_wrap .sorting_list .soring_color {
            display: inline-block;
            width: 28px;
            height: 16px;
            border-radius: 3px;
            float: right;
            margin-top: 3px;
            margin-right: 20px;
            cursor: pointer;
        }

        .calendar_sorting1 {
            display: inline-block;
            width: 300px;
            position: absolute;
            top: 470px;
            left: 60px;
            border: 1px solid #dcdcdc;
            border-radius: 5px;
        }

        .calendar_sorting1 .sorting_title1 {
            display: inline-block;
            width: 100%;
            border-bottom: 1px solid #dcdcdc;
            padding: 20px;
            font-size: 18px;
            color: #181C32;
        }

        .calendar_sorting1 .sorting_title1 .sorting_add_btn {
            display: inline-block;
            font-size: 14px;
            color: #143053;
            font-weight: 500;
            float: right;
            margin-top: 2px;
        }

        .calendar_sorting1 .sorting_list_wrap1 {
            display: inline-block;
            width: 100%;
            padding: 20px;
        }

        .calendar_sorting1 .sorting_list_wrap1 .sorting_list1 {
            display: inline-block;
            width: 100%;
            height: 22px;
            line-height: 10px;
            margin-bottom: 8px;
        }

        .sorting_list1 .sorting_delete_btn {
            display: inline-block;
            width: 10px;
            height: 10px;
            margin-right: 10px;
            margin-top: 2px;
        }

        .sorting_list1 .sorting_delete_btn img {
            width: 100%;
        }

        .sorting_list1 .sorting_name {
            display: inline-block;
            font-size: 14px;
            color: #222;
            padding-left: 20px;
        }

        .sorting_list1 .sorting_color {
            display: inline-block;
            width: 28px;
            height: 16px;
            border-radius: 3px;
            float: right;
        }

        .fc .fc-event-title {
            font-size: 12px;
            padding-left: 5px;
            /*text-align: left;*/
            line-height: 150%;
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
        }

        .fc .fc-toolbar-title {
            display: inline-block;
            font-size:16px;
            font-weight:400;
            color:#444;
            margin-left:120px;
        }
        .fc-daygrid-dot-event .fc-event-title{
            font-size: 12px;
            /*color: #fff;*/
            font-weight: 400;
            line-height: 150%;
        }
        /*.fc-daygrid-event-dot{
            display:none;
        }*/
        .fc-direction-ltr .fc-daygrid-event .fc-event-time{
            font-size: 12px;
            line-height: 150%;
            font-weight: 400;
            /*min-width: 35px;*/
            text-align: center;
        }
        .fc .fc-button-group button{
            width:70px !important;
            height:34px !important;
            background-color:#fff !important;
            border:1px solid #E7E7E9 !important;
            font-size: 13px !important;
            font-weight: 400 !important;
            color: #444 !important;
        }

        .fc .fc-button-primary:not(:disabled):active,
        .fc .fc-button-primary:not(:disabled).fc-button-active {
            background-color:#7B7B7B !important;
            color: #fff !important;
        }
        .fc-today-button{
            width:55px !important;
            height:34px !important;
            background-color:#fff !important;
            border:1px solid #E7E7E9 !important;
            font-size: 13px !important;
            font-weight: 400 !important;
            color: #444 !important;
            margin-left: 0 !important;
            float: left !important;
        }

        .fc .fc-next-button,
        .fc .fc-prev-button {
            border: none !important;
            background-color: #fff !important;
            color: #444 !important;
        }

        .fc .fc-button-group .fc-next-button:focus,
        .fc .fc-button-group .fc-prev-button:focus {
            box-shadow: none !important;
            outline: none !important;
        }

        .fc .fc-scroller::-webkit-scrollbar {
            /*   width: 5px; */
            display: none;
        }
        .fc .fc-scroller::-webkit-scrollbar-track {
            background-color: transparent;
        }
        .fc .fc-scroller::-webkit-scrollbar-thumb {
            border-radius: 3px;
            background-color: #d3d7de;
        }
        .fc .fc-scroller::-webkit-scrollbar-button {
            width: 0;
            height: 0;
        }

        .fc .fc-scrollgrid-section-header {
            height: 48px !important;
            line-height: 48px;
            background: #F9F9F9;
        }

        .fc-theme-standard th{
            border-right: 1px solid #E7E7E9 !important;
            border-bottom: 1px solid #E7E7E9 !important;
        }

        .fc .fc-col-header-cell-cushion{
            font-weight:500;
        }
        .fc-day-sun .fc-scrollgrid-sync-inner a{
            color: #F45757 !important;
        }
        .fc-day-sat .fc-scrollgrid-sync-inner a {
            color: #0B7EE8 !important;
        }

        .fc .fc-daygrid .fc-daygrid-day-frame {
            min-height: 110px;
        }

        .fc .fc-timegrid-slot-minor{
            border: 1px solid #E7E7E9 !important;
        }
        .fc .fc-timegrid-slot{
            height: 29px !important;
        }
        .fc .fc-daygrid-day {
            border: 1px solid #E7E7E9;
        }
        .fc .fc-daygrid-day.fc-day-today{
            background: rgba(255, 220, 40, 0.07);
        }
        .fc-timegrid-col.fc-day.fc-day-today{
            background: rgba(255, 220, 40, 0.07);
        }
        .fc .fc-timegrid-col {
            border: 1px solid #E7E7E9;
        }
        .fc .fc-timegrid-axis-frame{
            justify-content: center;
        }
        .fc .fc-timegrid-axis-cushion{
            font-size: 14px;
            font-weight: 400;
            color: #444;
        }
        .fc .fc-timegrid-axis-cushion, .fc .fc-timegrid-slot-label-cushion{
            font-size: 14px;
            font-weight: 400;
            color: #444;
        }
        .fc-direction-ltr .fc-timegrid-slot-label-frame{
            text-align:center;
        }
        .fc .fc-timegrid-slot-label{
            border-right: 1px solid #E7E7E9;
        }
        .fc-timegrid-event .fc-event-time{
            font-size: 12px;
            font-weight: 400;
            line-height: 150%;
        }
        .fc-timegrid-event-short .fc-event-title{
            font-size: 13px;
            font-weight: 400;
        }

        /*회의실 예약*/
        .contents_wrap.cal_meeting_contents{
            /* 			width: 1360px; */
            /* 		    max-width: 1360px; */
            /* 		    min-width: 1360px; */
            /* 		    height: calc(100% - 41px) !important; */
            /* 		    padding: 0; */
            /* 		    padding-top: 30px; */

            width: 1360px;
            max-width: 1360px;
            min-width: 1360px;
            height: calc(100% - 41px) !important;
            /* overflow-y: scroll; */
            padding: 0;
            padding-top: 30px;
        }
        .cal_meeting_top{
            display: inline-block;
            width: 300px;
            min-height: 100%;
            float:left;
            margin-right:20px;
            background: #FFFFFF;
            border: 1px solid #E7E7E9;
            box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.04);
            border-radius: 4px;
            margin-bottom: 20px;
            position: relative;
        }
        .cal_meeting_title{
            display: inline-block;
            width: 100%;
            height: 62px;
            line-height: 62px;
            border-bottom: 1px solid #E7E7E9;
            padding: 0 32px;
            font-size: 16px;
            font-weight: 500;
            color: #444;
        }
        .cal_meeing_check{
            display: inline-block;
            width: 100%;
            padding:20px;
        }
        .cal_meeting_bottom{
            display: inline-block;
            width: calc(100% - 320px);
            height: 100%;
            float:left;
            background: #FFFFFF;
            border: 1px solid #E7E7E9;
            box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.04);
            border-radius: 4px;
            position: relative;
            padding:23px 32px;
        }
        .meeting_type{
            display:inline-block;
            width:24px;
            height:20px;
            border-radius:4px;
            position:absolute;
        }
        .meeting_type.type0{
            background-color:#3C8AFF;
            top:56px;
            left:170px;
        }
        .meeting_type.type1{
            background-color:#45D1B6;
            top:56px;
            left:392px;
        }
        .meeting_type.type2{
            background-color:#FF9A3C;
            top:56px;
            left:614px;
        }
        .cal_check{
            display:inline-block;
            height:24px;
            float:left;
            margin-right:30px;
            margin-bottom:15px;
        }
        .all_check{
            width:100%;
        }
        .cal_check .cal_check_label{
            display:inline-block;
            height:24px;
            line-height:24px;
            margin-left:8px;
            font-size: 13px;
            font-weight: 500;
            color: #828B97;
            float: left;
        }
        .cal_check .cal_checkbox{
            float: left;
            margin-top: 2px;
        }
        .cal_check .cal_color{
            display: inline-block;
            width: 24px;
            height: 20px;
            border-radius: 4px;
            margin-left:20px;
            margin-top: 2px;
        }
        .cal_check .cal_color.color0{
            background-color:#3C8AFF;
        }
        .cal_check .cal_color.color1{
            background-color:#45D1B6;
        }
        .cal_check .cal_color.color2{
            background-color:#FF9A3C;
        }
        .fc-daygrid-day-events {
            overflow: visible !important;  /* 이벤트 영역이 날짜 셀을 벗어나도 보이게 */
            position: relative;
            z-index: 1;                   /* 이벤트가 배경보다 위에 위치하도록 */
        }

    </style>
    <script src='resources/fullcalendar/main.js'></script>
    <script src='resources/fullcalendar/lang/ko.js'></script>
    <%@include file="/WEB-INF/jsp/common.jsp" %>
    <script>
        $(document).ready(function () {
            $(".card_type0").click(function () {
                $('body').append('<div class="popup_mask"></div>');
                $(".calendar_popup0").show();
                $(".calendar_popup1").hide();
            });
            $(".card_type1").click(function () {
                $(".calendar_popup1").show();
                $(".calendar_popup0").hide();
            });
        });
    </script>
</head>
<body>

<div class="contents_wrap <%--cal_meeting_contents--%>">
    <div class="contents_area content_area_expend" style="height: unset; margin-bottom: 41px;">
        <div class="cal_meeting_top">
            <div class="cal_meeting_title">회의실</div>
            <ul class="cal_meeing_check" id="cal_meeting">
                <li class="cal_check all_check">
                    <input type="checkbox" class="cal_checkbox" id="all_check">
                    <label class="cal_check_label">전체선택</label>
                </li>
                <!-- 				<li class="cal_check"> -->
                <!-- 					<input type="checkbox" class="cal_checkbox"> -->
                <!-- 					<label class="cal_check_label">3층 소회의실3</label> -->
                <!-- 					<span class="cal_color color0"></span> -->
                <!-- 				</li> -->
                <!-- 				<li class="cal_check"> -->
                <!-- 					<input type="checkbox" class="cal_checkbox"> -->
                <!-- 					<label class="cal_check_label">4층 소회의실1</label> -->
                <!-- 					<span class="cal_color color1"></span> -->
                <!-- 				</li> -->
                <!-- 				<li class="cal_check"> -->
                <!-- 					<input type="checkbox" class="cal_checkbox"> -->
                <!-- 					<label class="cal_check_label">4층 소회의실2</label> -->
                <!-- 					<span class="cal_color color2"></span> -->
                <!-- 				</li> -->
            </ul>
        </div>
        <div class="cal_meeting_bottom">
            <div id='calendar'></div>
        </div>

        <%--<div class="inner_tab_wrap" style="display:none;">
            &lt;%&ndash;            <div class="calendar_card">&ndash;%&gt;
            &lt;%&ndash;                <div class="calendar_card_title">${fn:escapeXml(emax:word("회의실"))}</div>&ndash;%&gt;
            &lt;%&ndash;                <ul class="calendar_card_body" id="external-events">&ndash;%&gt;
            &lt;%&ndash;                </ul>&ndash;%&gt;
            &lt;%&ndash;            </div>&ndash;%&gt;
            <div class="calendar_sorting sorting0">
                <p class="sorting_title">회의실</p>
                <ul class="sorting_list_wrap" id="sorting_list">
                    <li class="sorting_list">
                        <input type="checkbox" id="ALL_CHECK"/>
                        <span class="sorting on">전체선택</span>
                    </li>
                </ul>
            </div>
            <div id='calendar'></div>
        </div>--%>
    </div>
</div>
</body>