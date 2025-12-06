

=================================> AI에 질문 :


아래 소스에서 첨부파일 관련된 것들을 제외하고는 전부 삭제 해줘

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.em.http.Transaction" %>
<%@ page import="com.em.http.Transaction" %>
<%@ page import="emportal.model.*" %>
<%@ page import="com.em.util.*" %>
<%@ page import="java.util.List" %>
<%
	// =========================================================================
	// 초기 변수 선언 및 데이터베이스 트랜잭션 객체 생성
	// - 메뉴 코드, 결재 관련 코드, 날짜, 사용자 정보 등 전역 변수 설정
	// - Transaction 객체를 생성하여 DB 관련 작업에 사용함
	// =========================================================================
	String menuCode = "g400";
	String menuCode2 = "g400-400";
	String menuCode3 = "g400-400-100";
	String eps_type = "JJ100800";
	String R_cur_stat = "";
 
	Transaction tr = new Transaction(pageContext);
	int len= 1;
	int detailcnt = 0;
	int detailcnt_plan = 0;
	String currentDate = "";
	
	String ccnt = "";

	ccnt ="0";
	String chdept_nm = "";
	String chemp_no = "";
	String ch_high_bc = "";
	String chemp_nm = "";
	String docId = "";
	String list_type ="";
	String eps_no = "";
	
	String acc_dt = "";

    // confirmHistoryList : 결재 진행 내역 리스트 (최종 승인 등)
	List<Object> confirmHistoryList = null;
    // 요청 파라미터 "list_type"를 정규화 처리하여 결재함 종류를 결정
	//list_type  (공백) 자기 자신 결재함, Y 받은결재함,  S 보낸결재함,  Z 참조문서함,  M 상신수정, B 배포문서함, P 복사
	list_type = StringUtil.normalizeNull(request.getParameter("list_type"));
	
	String exp_no = StringUtil.normalizeNull(request.getParameter("exp_no"));
	
    // 결재 반려나 수정 관련 처리를 위해 exp_no 값을 다시 얻음
	//이병운 20140411 반려 삭제 하기 
	String Returnexp_no = StringUtil.normalizeNull(request.getParameter("exp_no"));
	
    // 결재 수정 가능 여부 체크 (DB에서 조회)
	// 이병운 20140418  결재 수정이 가능한지 아닌지 확인 
	String  All_Modify= (String)tr.sql.selectObject("pay.selectDecide", exp_no);
	
    // 문서의 기본 정보를 저장할 해시맵 및 관련 리스트 초기화
	HashMap<String, Object> master = new HashMap<String, Object>();
	List<Object> fileList = null;
	List<Object> docList = null;
	List<Object> commentList = null;
	List<Object> referList = null;
	List<Object> referList_plan = null;
	List<Object> events = null; //20250219 gmlee 추가 // 이벤트 정보 (추가 기능용)
	
	User _user = (User)session.getAttribute("user");
	String eps_sq = "";
	
	HashMap<String, Object> event = new HashMap<String, Object>();
	HashMap<String, Object> treatment = new HashMap<String, Object>();

	String eps_dt="";
	
	List<Object> taxBcList = tr.sql.selectList("pay.selectTaxBcList");

	String current_main_sq = "";
	
	boolean isConfirm = false;
	boolean isEnd = false;
	
	HashMap<String, Object> info = (HashMap<String, Object>)tr.sql.selectObject("user.selectInfo", _user.getEmp_no()); 
	
	ch_high_bc = (String)tr.sql.selectObject("pay.selectGethigh", _user.getEmp_no());
	
	chdept_nm =_user.getDept_nm();
	chemp_nm = _user.getEmp_nm();
	
	if (!"".equals(exp_no)) { 
		docId = exp_no;
		master = (HashMap<String, Object>)tr.sql.selectObject("pay.selectPayMaster", exp_no);	

		currentDate = StringUtil.normalizeNull(String.valueOf(master.get("exp_dt")));
		chemp_nm = StringUtil.normalizeNull(String.valueOf(master.get("emp_nm")));
		chdept_nm = StringUtil.normalizeNull(String.valueOf(master.get("dept_nm")));
		ch_high_bc = StringUtil.normalizeNull(String.valueOf(master.get("sub_titie")));
		
		
		HashMap<String, Object> params_paramM = new HashMap<String, Object>();
		params_paramM.put("exp_no", exp_no);
		params_paramM.put("emp_no", _user.getEmp_no());
		HashMap<String, Object> m2 = (HashMap<String, Object>)tr.sql.selectObject("pay.selectCurConfirmEmpNo", params_paramM);
		
		eps_no = StringUtil.normalizeNull(String.valueOf(master.get("eps_no")));
		
		
		if("M".equals(list_type)) //상신수정
		{
			ccnt = "0";
			
			fileList = tr.sql.selectList("pay.selectFileList", exp_no);
			docList = tr.sql.selectList("pay.selectRelateDocList2", exp_no);
		}
		else if("P".equals(list_type)) //문서복사
		{
			//문서작성 상태
			ccnt = "0";
			//문서번호 없는 상태(반려된 문서와 같음)
			R_cur_stat ="R";
			//현재 작성일자로 변경
			currentDate = (String)tr.sql.selectObject("pay.selectGetDate");
			
		}else
		{
			ccnt = (String)tr.sql.selectObject("pay.selectccnt", exp_no);
			
			fileList = tr.sql.selectList("pay.selectFileList", exp_no);
			docList = tr.sql.selectList("pay.selectRelateDocList2", exp_no);
		}
		

		eps_dt= StringUtil.normalizeNull(String.valueOf(master.get("eps_dt")));
		if (m2 != null) { 
			String confirmEmpNo = StringUtil.normalizeNull(String.valueOf(m2.get("emp_no")));
			eps_sq = String.valueOf(m2.get("eps_sq"));

			if (_user.getEmp_no().equals(confirmEmpNo)) { 
				System.out.println("Final!!!");
				isConfirm = true;
			}
		}

		chemp_no =StringUtil.normalizeNull(String.valueOf(master.get("emp_no")));
		current_main_sq = (String)tr.sql.selectObject("pay.selectPaySq", exp_no);
			
		commentList = tr.sql.selectList("pay.selectCommentList", exp_no);	
		
		//20250219 gmlee 변경
		//event =  (HashMap<String, Object>)tr.sql.selectObject("pay.selectEvent", exp_no);
		events =  tr.sql.selectList("pay.selectEvent", exp_no);
		event = (HashMap<String, Object>)events.get(0);
		
		referList = tr.sql.selectList("pay.selectReferTempList", exp_no);
		referList_plan = tr.sql.selectList("pay.selectReferTempList_plan", exp_no);
		confirmHistoryList = tr.sql.selectList("pay.selectConfirmHistory", exp_no);
		
		//20140327 이병운 추가  반려체크 
		if ("F".equals(String.valueOf(master.get("cur_stat")))) { 
			isEnd = true;
		}
		else if ("R".equals(String.valueOf(master.get("cur_stat"))) && !("".equals(list_type) || "S".equals(list_type)))
		{
			ccnt ="1";
			R_cur_stat  = "C";
			
			
		}
		else if ("R".equals(String.valueOf(master.get("cur_stat")))) 
		{
			ccnt ="0";
			R_cur_stat  = String.valueOf(master.get("cur_stat"));
		}		else
		{
			Returnexp_no =(String)tr.sql.selectObject("pay.selectReturnexp_no", exp_no);
		}
		
		//저장상태서 인쇄할 수 있게 팝업 - 인쇄화면은 상신화면이어야 함.
		if("SP".equals(list_type)) 
		{
			ccnt ="1";
		}
		
	} else { 
		//docId = (String)tr.sql.selectObject("pay.selectDocId", _user.getEmp_no());
		currentDate = (String)tr.sql.selectObject("pay.selectGetDate");
	}
	
	acc_dt = (String)tr.sql.selectObject("pay.selectAccount_dt", exp_no);
	List<Object> curyList = tr.sql.selectList("pay.selectCuryList");
%> 
<%@ include file="/include/top_contents.jsp" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
<!--  2014년 3월 25일 추가 Title,Icon, css 관련 -->
<%@ include file="/include/top_style.jsp" %>
<%@ include file="/include/common_line.jsp" %>
<!--  2014년 3월 25일 추가 e-->

<link rel="stylesheet" type="text/css" href="/css/ui/jquery.ui.all.css">
<link rel="stylesheet" type="text/css" href="/css/ui/jquery-ui-timepicker-addon.css">

<script src="/js/jquery.js" type="text/javascript"></script>
<script src="/js/jquery.tmpl.min.js" type="text/javascript"></script>
<script src="/js/jquery-ui.js" type="text/javascript"></script>

<script src="/js/jquery.ui.datepicker.js" type="text/javascript"></script>
<script src="/js/jquery-ui-timepicker-addon.js" type="text/javascript"></script>

<script src="/js/common.js" type="text/javascript"></script>



<style type="text/css">

span.customSelect {
	font-size:11px;
	background-color: #ffffff;
	color:#7c7c7c;
	padding:5px 3px 5px 5px;
	border:1px solid #D5D5D5;
	-moz-border-radius: 0px;
	-webkit-border-radius: 0px;
	border-radius: 0px 0px;
}
span.customSelect.changed {
	background-color: #D5D5D5;
}
.customSelectInner {
	background:url(/js/customSelect-arrow.gif) no-repeat center right;
}
</style>

<script src="/js/jquery.customSelect.min.js" type="text/javascript"></script>

<!-- javascript -->
<!--[if lt IE 9]>
<script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
<script type="text/javascript" src="https://getfirebug.com/firebug-lite.js"></script>
<![endif]-->

<script src="/js/ajaxupload.js" type="text/javascript"></script>

<!-- 2014-09-11  숫자마스크 -->
<script src="/js/number.js" type="text/javascript"></script>
<!-- 2014-09-11  마스크-->
<script src="/js/inputmask.js" type="text/javascript"></script>


<script id="detailTemplate" type="text/x-jquery-tmpl"> 
     <tr index="{{html index}}" step="1">
       <td><input type="text" class="input_cal" style="width:100%; text-align:center" readOnly name="tax_dt" id="tax_dt{{html index}}"></td>
       <td>
		<input type="hidden" name="exp_cd" id="exp_cd{{html index}}" >
        <input type="text" style="width:100%;" readonly name="exp_nm" id="exp_nm{{html index}}"  class="input_pop" onclick="openFad('{{html index}}');">
        </td>
       <td>
		<select name="tax_bc" id="tax_bc{{html index}}" style="width:152px;">
		<% 
		if (taxBcList != null) { 
			for (Object o : taxBcList) {
			HashMap<String, Object> m = (HashMap<String, Object>)o; 	
		%>
			<option value="<%=String.valueOf(m.get("base_cd"))%>"><%=String.valueOf(m.get("title"))%></option>
		<%
			}
		}
		%>
       </select>


		</td>
       <td><input type="text"   style="width:100%;text-align:right;" name="tot_amt" id="tot_amt{{html index}}" value="{{html doparseInt(tot_amt)}}" maxlength="14"></td>
       <td><input type="text"   style="width:100%;text-align:right;" name="amt" id="amt{{html index}}" value="{{html doparseInt(amt)}}"  maxlength="14"></td>
       <td><input type="text"   style="width:100%;text-align:right;" name="vat" id="vat{{html index}}" value="{{html doparseInt(vat)}}"  maxlength="14"></td>
       <td rowspan="2"><input type="checkbox" name="sel_index" id="sel_index" value="{{html index}}" ></td>

     </tr>
     <tr index="{{html index}}" step="2">
       <td colspan="2">
		<input type="hidden" style="width:100%;" name="payemp_no" id="payemp_no{{html index}}" value="{{html emp_no}}" >
		<input type="text" style="width:100%;"  class="input_pop" readOnly  name="payemp_nm" id="payemp_nm{{html index}}" value="{{html emp_nm}}" onclick="openEmpClick('{{html index}}');" >
			</td>
       <td>
		<input type="hidden" name="dept_cd2" id="dept_cd2{{html index}}" >
        <input type="text" style="width:100%;" readOnly name="dept_nm2" id="dept_nm2{{html index}}">
        </td>
		</td>
       <td colspan="3"><input type="text" style="width:100%;" name="dsc" id="dsc{{html index}}" value="{{html dsc}}"></td>
     </tr>
</script>

<script id="detailTemplate2" type="text/x-jquery-tmpl"> 
     <tr index="{{html index}}" step="1">
       <td>
		<input type="hidden" name="tax_cd" id="tax_cd{{html index}}" value="FA630195">
		<input type="hidden" name="exp_cd" id="exp_cd{{html index}}" >
        <input type="text" style="width:100%;background:#ebebe4;" readonly name="exp_nm" id="exp_nm{{html index}}" >
	   </td>
       <td>
		<input type="text" style="width:100%;" class="input_pop" name="cust_nm{{html index}}" id="cust_nm{{html index}}" readonly onclick="openClient('{{html index}}');">
		<input type="hidden" name="cust_cd" id="cust_cd{{html index}}"  />
	   </td>
       <td>
		<input type="hidden" name="dept_cd2" id="dept_cd2{{html index}}" >
        <input type="text" style="width:100%;"  class="input_pop" readOnly name="dept_nm2" id="dept_nm2{{html index}}" onclick="openDept('{{html index}}');">
       </td>
       <td><input type="hidden" class="input_cal" style="width:100%; text-align:center" readOnly name="tax_dt" id="tax_dt{{html index}}">
			<%-- 2025-04-14 hsg. 행추가시 지급요청일자를 선택할 수 없어서 readonly 삭제 --%>
		   <input type="text" class="input_cal" style="width:100%; text-align:center" name="pay_due_dt" id="pay_due_dt{{html index}}">
	   </td>
	   <td>
			<select name="cury_bc" id="cury_bc{{html index}}" style="width:100%;">
			<% 
			if (curyList != null) { 
				for (Object o : curyList) {
				HashMap<String, Object> m = (HashMap<String, Object>)o; 	
			%>
			<option value="<%=String.valueOf(m.get("base_cd"))%>"><%=String.valueOf(m.get("title"))%></option>
			<%
				}
			}
			%>
       		</select>
	   </td>
       <td>
			<%-- 2025-04-14 hsg. 행추가시 지급요청일자를 선택할 수 없어서 readonly 삭제 --%>
			<input type="text"  style="width:100%;text-align:right;" name="tot_amt" id="tot_amt{{html index}}" value="{{html doparseInt(tot_amt)}}" maxlength="14">
       		<input type="hidden"   style="width:100%;text-align:right;" name="amt" id="amt{{html index}}" value="{{html doparseInt(amt)}}"  maxlength="14">
       		<input type="hidden"   style="width:100%;text-align:right;" name="vat" id="vat{{html index}}" value="{{html doparseInt(vat)}}"  maxlength="14">
	   </td>

	   <td>
		<input type="text" style="width:100%;" name="dsc" id="dsc{{html index}}" value="{{html dsc}}">
	   </td>

		<%-- 2025-04-14 hsg. 추가, 삭제 버튼 추가 요청으로 추가함. --%>
	   <td>
			<input type="checkbox" style="width:100%;" name="sel_index" id="sel_index{{html index}}" value="{{html index}}">
	   </td>

     </tr>
</script>


<%-- 20250219.gmlee 추가 --%>
<script id="detailTemplate3" type="text/x-jquery-tmpl"> 
     <tr index="{{html index}}" step="1">

       <td></td>
       <td></td>
       <td></td>

	   <td><input type="text" class="input_cal" style="width43%;" name="fr_dt" id="fr_dt{{html index}}" value="{{html fr_dt}}">
           ~ <input type="text" class="input_cal" style="width43%;" name="to_dt" id="to_dt{{html index}}" value="{{html to_dt}}">
	   <input type="checkbox" name="sel_index" id="sel_index" value="{{html index}}" ></td>			

	 </tr>
</script>


<script type="text/javascript">
// var _index = 1;
// 기존 _index 대신 지결상세용과 휴가기간용 인덱스를 분리하여 사용
var _detailIndex = 1;    // 지결상세(결재내역) 추가에 사용
var _vacationIndex = 1;  // 휴가기간 추가에 사용


function openEmp() {
	/*잠시주석  */
	/* openPopup('/pay/pop_emp.jsp', 'emp', 1000, 680); */
	
	 openPopup('/pay/pop_empSj.jsp', 'emp', 1000, 680); 
	
}

function detailEmp() { 
	openPopup('/pay/pop_detailemp.jsp?exp_no='+'<%=exp_no%>' , 'emp', 800, 673);
}

function openEmp2() { 
	openPopup('/pay/pop_empsub.jsp', 'emp', 1000, 800);
}

<%-- function openEmp1() { 
	openPopup('/print/pop_printevent.jsp?exp_no=< %=exp_no% >', 'emp', 1050, 800);
} --%>
function openEmp1() { 
	window.print();
}	

function openClient(id) { 
	openPopup('/pay/pop_client.jsp?id=' + id +'&type=emp', 'popup', 800, 600);
}

function doSetClient(id, code, name, work_dept, work_dept_nm) { 
	$("#cust_cd" + id).val(code);
	$("#cust_nm" + id).val(name);
	$("#dept_cd2" + id).val(work_dept);
	$("#dept_nm2" + id).val(work_dept_nm);
}

function openDept(id) { 
	openPopup('/pay/pop_accDept.jsp?id=' + id, 'popup', 800, 673);
}

function doSetDept(id, code, name) { 
	$("#dept_cd2" + id).val(code);
	$("#dept_nm2" + id).val(name);
}

function doSetReferEmpsub(emp_no, emp_nm, dept_nm, high_nm) { 

	$("#rec_emp_no").val(emp_no);
	$("#rec_emp_nm").val(emp_nm);
	$("#treat_place").val(dept_nm);
	$("#high_bc_name").val(high_nm);
}

function openFad(id) { 
	openPopup('/pay/pop_fad.jsp?id=' + id, 'popup', 800, 500);
}

function doSetFad(id, code, name) { 
	$("#exp_cd" + id).val(code);
	$("#exp_nm" + id).val(name);
}

function openEmpClick(id) { 
	openPopup('/pay/pop_empsub_click.jsp?id=' + id, 'popup', 800, 673);
}

function doSetReferEmpsubidx(id , emp_no, emp_nm , dept_cd, dept_nm,high_nm)
{
	$("#payemp_no" + id).val("");
	$("#payemp_nm" + id).val("");
	
	$("#payemp_no" + id).val(emp_no);
	$("#payemp_nm" + id).val(emp_nm);

	//$("#dept_cd2" + id).val(dept_cd);
	//$("#dept_nm2" + id).val(dept_nm);
	
}
	

function openDept(id) { 
	openPopup('/pay/pop_dept.jsp?id=' + id, 'popup', 800, 600);
}

function doSetDept(id, code, name) { 
	$("#dept_cd2" + id).val(code);
	$("#dept_nm2" + id).val(name);
}


var _index = 1;

// 2025-04-11 hsg. 같은 이름의 함수가 2개가 있어서 하나는 notUse를 붙여 사용안하게 함
function doAddDetail_notUse() { 
	
	AddChgiFrame();
	
	$("#detailTemplate2").tmpl({index : _index, tot_amt : '', amt : '', vat : '', dsc : ''}).appendTo("#detailTable2");
	
	$("#tax_dt" + _index).datepicker({ dateFormat : 'yy-mm-dd' });
<%-- 	$("#dept_cd2" + _index).val('< %=_user.getDept_cd()% >');
	$("#dept_nm2" + _index).val('< %=user.getDept_nm() % >'); --%>
	$("#dept_cd2" + _index).val("22000"); //사내 경조금 예산귀속부서는 경영관리팀
	$("#dept_nm2" + _index).val("경영관리팀"); //사내 경조금 예산귀속부서는 경영관리팀
	
	$("#tax_bc" + _index).val("FA630195");
	
	
	$("#tax_bc" + _index).customSelect();
	
	bindComma();
	
	_index++;
}

function doCopyDetail(ob) { 
	if ($("input[id^=sel_index]:checked").length == 0) { 
		alert('복사할 목록을 체크해주세요.');
		return;
	}
	
	//20140529 조유리  복사 여러개 가능하도록
	$("input[name=sel_index]:checked").each(function() {
		var _index_sub = $(this).val();
	
	/* var _index_sub = 1;
	_index_sub= _index-1; */
	
    $("#detailTemplate2").tmpl({index : _detailIndex, tot_amt : '', amt : '', vat : '', dsc : ''}).appendTo("#detailTable2");
    $("#tax_dt" + _detailIndex).val($("#tax_dt"+_index_sub).val());
    $("#dept_cd2" + _detailIndex).val($("#dept_cd2"+_index_sub).val());
    $("#tax_bc" + _detailIndex).val($("#tax_bc"+_index_sub).val());
    $("#tax_bc" + _detailIndex).customSelect();    
    $("#tot_amt" + _detailIndex).val($("#tot_amt"+_index_sub).val());
    $("#amt" + _detailIndex).val($("#amt"+_index_sub).val());
    $("#vat" + _detailIndex).val($("#vat"+_index_sub).val());
    $("#exp_cd" + _detailIndex).val($("#exp_cd"+_index_sub).val());
    $("#exp_nm" + _detailIndex).val($("#exp_nm"+_index_sub).val());
    $("#sel_index" + _detailIndex).val(_detailIndex);
    $("#cust_nm" + _detailIndex).val($("#cust_nm"+_index_sub).val());
    $("#cust_cd" + _detailIndex).val($("#cust_cd"+_index_sub).val());
    $("#dept_nm2" + _detailIndex).val($("#dept_nm2"+_index_sub).val());
    $("#dsc" + _detailIndex).val($("#dsc"+_index_sub).val());

    $("#payemp_no" + _detailIndex).val($("#payemp_no"+_index_sub).val());
    $("#payemp_nm" + _detailIndex).val($("#payemp_nm"+_index_sub).val());
	
	bindComma();

    // 2025-04-14 hsg. 복사된 행의 날짜 입력 필드에도 datepicker 초기화를 해줍니다.
    $("#tax_dt" + _detailIndex).datepicker({ dateFormat: 'yy-mm-dd' });
    $("#pay_due_dt" + _detailIndex).datepicker({ dateFormat: 'yy-mm-dd' });

    _detailIndex++;
	
	});
	
	testsum();
	
	
}

function doDeleteDetail() { 
    // 체크된 체크박스가 없으면 경고 메시지 출력
	if ($("input[id^=sel_index]:checked").length == 0) { 
		alert('삭제할 목록을 체크해주세요.');
		return;
	}
	
    // 모든 체크된 체크박스에 대해 해당 행을 삭제
    $("input[name=sel_index]:checked").each(function() { 
        console.log("삭제 대상 index: " + $(this).val());
        $("tr[index=" + $(this).val() + "]").remove();
    });

    _detailIndex--;
	
	testsum();
	
}


var refer_list = new Array();
var refer_list_sub = new Array();

function referEmp(emp_no, txt) { 
	this.emp_no = emp_no;
	this.txt = txt;
}

function referEmp_sub(emp_no, txt) { 
	this.emp_no = emp_no;
	this.txt = txt;
}

//참조 이병운
function doSetReferEmp(emp_no, emp_nm, dept_nm, high_nm , emp_no_sub, emp_nm_sub, dept_nm_sub, high_nm_sub) { 


	var emp_no_list = emp_no.split(',');
	var emp_nm_list = emp_nm.split(',');
	var dept_nm_list = dept_nm.split(',');
	var high_nm_list = high_nm.split(',');
	
	
	if (emp_no_list != "") {
		
		if (emp_no_list != null) { 
			for (var i=0; i<emp_no_list.length; i++) {
			
				refer_list.push(new referEmp(emp_no_list[i], (dept_nm_list[i] + "<span>" + emp_nm_list[i] + "</span>")));
			}
		}
	printReferTable();
	
	//화면 다시 조정 (이병운 2014-10-14)
	AddChgiFrame_remove();
	}
	
	doSetReferEmp_sub( emp_no_sub, emp_nm_sub, dept_nm_sub, high_nm_sub);
	
}

//배포 이병운
function doSetReferEmp_sub(emp_no, emp_nm, dept_nm, high_nm) { 

	
	var emp_no_list = emp_no.split(',');
	var emp_nm_list = emp_nm.split(',');
	var dept_nm_list = dept_nm.split(',');
	var high_nm_list = high_nm.split(',');

	if (emp_no_list != "") {
		
		
		
		
		if (emp_no_list != null) { 
			for (var i=0; i<emp_no_list.length; i++) {
			
				refer_list_sub.push(new referEmp_sub(emp_no_list[i], (dept_nm_list[i] + "<span>" + emp_nm_list[i] + "</span>")));
			}
		}

		
		printReferTable_sub();
	
		//화면 다시 조정 (이병운 2014-10-14)
		AddChgiFrame_remove();
		
	}
	
	
}

function printReferTable_sub() { 
	
	if (refer_list_sub.length > 0)
		$("#referTable_sub tr").remove();
	
	
	if (refer_list_sub.length % 4 > 0) 
		rows = (refer_list_sub.length / 4 + 1);
	else
		rows = (refer_list_sub.length / 4);
	
	
	
	//참조 추가 2014-10-01 이벼운 
	if(rows==0)
	{
		$("#referTable_sub tr").remove();
		$("#referTable_sub").append("<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>");
	}
	else
	{
		for (var j=0; j<rows; j++) { 
			$("#referTable_sub").append("<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>");
		}
		
		for (var jj=0; jj<refer_list_sub.length; jj++) { 
			var _trindex = parseInt(jj / 4);
			var _tdindex = jj % 4
			/* $("#referTable tr:eq(" + _trindex + ") td:eq(" + _tdindex + ")").html(refer_list[jj].txt);	
			$("#referTable tr:eq(" + _trindex + ") td:eq(" + _tdindex + ")").append('<input type="hidden" name="refer_emp_no" value="' + refer_list[jj].emp_no + '"/>'); */
			
			$("#referTable_sub tr:eq(" + _trindex + ") td:eq(" + _tdindex + ")").html(refer_list_sub[jj].txt);	
			
			
			<%if ("1".equals(ccnt)) { %>
			
				$("#referTable_sub tr:eq(" + _trindex + ") td:eq(" + _tdindex + ")").append('<input type="hidden" name="refer_emp_no_sub" id="refertt' +  refer_list_sub[jj].emp_no + '"  value="' +  refer_list_sub[jj].emp_no + '"/> ');
    	
  			<% }else{ %>	
  			
				$("#referTable_sub tr:eq(" + _trindex + ") td:eq(" + _tdindex + ")").append('<input type="hidden" name="refer_emp_no_sub" id="refertt' +  refer_list_sub[jj].emp_no + '"  value="' +  refer_list_sub[jj].emp_no + '"/> <a href="javascript:deletereference_sub(' + '\'' + refer_list_sub[jj].emp_no + '\'' + ',' + '\'' +refer_list_sub[jj].emp_no+ '\'' +');"><img src="/images/btn_del.gif" id="refertt' +  refer_list_sub[jj].emp_no + '" alt="삭제">');
			
			<% } %>	
			
		}
	}
	
}



function printReferTable() { 

	if (refer_list.length > 0)
		$("#referTable tr").remove();
	
	
	if (refer_list.length % 4 > 0) 
		rows = (refer_list.length / 4 + 1);
	else
		rows = (refer_list.length / 4);
	
	
	
	//참조 추가 2014-10-01 이벼운 
	if(rows==0)
	{
		$("#referTable tr").remove();
		$("#referTable").append("<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>");
	}
	else
	{
		for (var j=0; j<rows; j++) { 
			$("#referTable").append("<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>");
		}
		
		for (var jj=0; jj<refer_list.length; jj++) { 
			var _trindex = parseInt(jj / 4);
			var _tdindex = jj % 4
			/* $("#referTable tr:eq(" + _trindex + ") td:eq(" + _tdindex + ")").html(refer_list[jj].txt);	
			$("#referTable tr:eq(" + _trindex + ") td:eq(" + _tdindex + ")").append('<input type="hidden" name="refer_emp_no" value="' + refer_list[jj].emp_no + '"/>'); */
			
			$("#referTable tr:eq(" + _trindex + ") td:eq(" + _tdindex + ")").html(refer_list[jj].txt);	
			
			
			<%if ("1".equals(ccnt)) { %>
			
				$("#referTable tr:eq(" + _trindex + ") td:eq(" + _tdindex + ")").append('<input type="hidden" name="refer_emp_no" id="refertt' +  refer_list[jj].emp_no + '"  value="' +  refer_list[jj].emp_no + '"/> ');
    	
  			<% }else{ %>	
  			
				$("#referTable tr:eq(" + _trindex + ") td:eq(" + _tdindex + ")").append('<input type="hidden" name="refer_emp_no" id="refertt' +  refer_list[jj].emp_no + '"  value="' +  refer_list[jj].emp_no + '"/> <a href="javascript:deletereference(' + '\'' + refer_list[jj].emp_no + '\'' + ',' + '\'' +refer_list[jj].emp_no+ '\'' +');"><img src="/images/btn_del.gif" id="refertt' +  refer_list[jj].emp_no + '" alt="삭제">');
			
			<% } %>	
			
		}
	}
}


$(function() {
	
	<%if ("0".equals(ccnt)) { %>
		$( "#account_dt" ).datepicker({ dateFormat : 'yy-mm-dd' });
		$( "#exp_dt" ).datepicker({ dateFormat : 'yy-mm-dd' });
		$( "#edate" ).datepicker({ dateFormat : 'yy-mm-dd' });
		$( "#frdate" ).datepicker({ dateFormat : 'yy-mm-dd' });
		$( "#todate" ).datepicker({ dateFormat : 'yy-mm-dd' });
		$( "#fr_dt" ).datepicker({ dateFormat : 'yy-mm-dd' });
		/* $( "#to_dt" ).datepicker({ dateFormat : 'yy-mm-dd' }); */
	<%} %>
	
});

function openLine() { 
	openPopup('/pay/pop.jsp?eps_type=' + $("#eps_type").val(), 'line', 1000, 610);

}

function openDoc() { 
	openPopup('/pay/search_doc.jsp', 'doc', 1000, 800);
}

//병렬 합의 결재라인 수정 
function setLine(main_sq, json) {
	$("#line_main_sq").val(main_sq);
	
	$("#lineTable1 td").text('');
	$("#lineTable2 td").text('');
	$("#lineTable3 td").text('');
	
	$("#lineTable1 th").html('');
	$("#lineTable2 th").html('');
	$("#lineTable3 th").html('');
	
	if (json.list.length > 0) {
		
		var loop1 = 0;
		var loop2 = 0;
		var loop3 = 0;
		var loop4 = 0;
		var rows=1;
		var type_rows = 0;
		
		for (var iiii=0; iiii<json.list.length; iiii++) 
		{ 
			if(json.list[iiii].app_type == 'JJ200400')
			{
				type_rows++;
			}
		}
		
		if (json.list.length % 7 > 0) 
			rows = (type_rows / 7 + 1);
		else
			rows = (type_rows / 7);
		
		// 합의 칸들 지울때 사용
		$("#lineTable3 tr").remove();
		
				if(2<rows )
				{
					// 폼을 설정한다 
					AddChgiFrame_add();
					
						for (var j=0; j<rows-1; j++) 
						{
							
							var Table_str = "";
							var Table_str1 = "";
							var Table_str2 = "";
							
							
							for (var j1=1; j1<7; j1++)
							{
								if(j1==1)
								{
									Table_str=Table_str+"<tr> <th class='al'> </th>";
									Table_str1=Table_str1+"<tr class='time'> <td></td>";
									Table_str2=Table_str2+"<tr> <td></td>";
								}
								else if(j1==7)
								{
									Table_str=Table_str+ "</tr>";
									Table_str1=Table_str1+ "</tr>";
									Table_str2=Table_str2+ "</tr>";
								}
								else
								{
									Table_str=Table_str+ "<th class='al'> </th>";
									Table_str1=Table_str1+ "<td></td>";
									Table_str2=Table_str2+ "<td></td>";
								}
							}
							$("#lineTable3").append(Table_str);
							$("#lineTable3").append(Table_str1);
							$("#lineTable3").append(Table_str2);
					}
				}
				else
				{
					// 폼화면 초기화 후 다시 설정
					//AddChgiFrame_remove();
					
					var Table_str = "";
					var Table_str1 = "";
					var Table_str2 = "";
					
					for (var j1=1; j1<7; j1++)
					{
						if(j1==1)
						{
							Table_str=Table_str+"<tr> <th class='al'> </th>";
							Table_str1=Table_str1+"<tr class='time'> <td></td>";
							Table_str2=Table_str2+"<tr> <td></td>";
						}
						else if(j1==7)
						{
							Table_str=Table_str+ "</tr>";
							Table_str1=Table_str1+ "</tr>";
							Table_str2=Table_str2+ "</tr>";
						}
						else
						{
							Table_str=Table_str+ "<th class='al'> </th>";
							Table_str1=Table_str1+ "<td></td>";
							Table_str2=Table_str2+ "<td></td>";
						}
					}

					$("#lineTable3").append(Table_str);
					$("#lineTable3").append(Table_str1);
					$("#lineTable3").append(Table_str2);
				}
		
				var test1=0;
		
				for (var i=0; i<json.list.length; i++) { 
					var _json = json.list[i];
							
					
					if (_json.app_type == 'JJ200100') { 
						$("#lineTable1 tr:eq(0) th:eq(" + loop1 + ")").html("<em class='blue' id=\"em_class\"><span></span>" + _json.rownum + "</em> " + _json.high_title).attr("sq_no", _json.sq_no);
						$("#lineTable1 tr:eq(1) td:eq(" + loop1 + ")").attr("emp_no", _json.emp_no).attr("sq_no", _json.sq_no);
						$("#lineTable1 tr:eq(2) td:eq(" + loop1 + ")").text(_json.emp_nm);
						loop1++;
					}
					if (_json.app_type == 'JJ200200') { 
						$("#lineTable3 tr:eq(0) th:eq(" + loop2 + ")").html("<em class=\"blue\" id=\"em_class\"><span></span>" + _json.rownum + "</em> " + _json.high_title).attr("sq_no", _json.sq_no);
						$("#lineTable3 tr:eq(1) td:eq(" + loop2 + ")").attr("emp_no", _json.emp_no).attr("sq_no", _json.sq_no);
						$("#lineTable3 tr:eq(2) td:eq(" + loop2 + ")").text(_json.emp_nm);
						
						loop2++;
						loop4++;
					}
					if (_json.app_type == 'JJ200300') { 
						$("#lineTable2 tr:eq(0) th:eq(" + loop3 + ")").html("<em class=\"blue\" id=\"em_class\"><span></span>" + _json.rownum + "</em> " + _json.high_title).attr("sq_no", _json.sq_no);
						$("#lineTable2 tr:eq(1) td:eq(" + loop3 + ")").attr("emp_no", _json.emp_no).attr("sq_no", _json.sq_no);
						$("#lineTable2 tr:eq(2) td:eq(" + loop3 + ")").text(_json.emp_nm);
						loop3++;
					}

					
					if (_json.app_type == 'JJ200400')
					{ 
						
						if(rows>2)
						{
							// 합의 내용이 6개 미만 
							if(loop4<=5)
							{
								$("#lineTable3 tr:eq(0) th:eq(" +loop4+ ")").html("<em class=\"blue\" id=\"em_class\"><span></span>" +  _json.sq_no  + "</em> " + _json.high_title);
								$("#lineTable3 tr:eq(1) td:eq(" + loop4+ ")").attr("emp_no", _json.emp_no).attr("sq_no", _json.sq_no);
								$("#lineTable3 tr:eq(2) td:eq(" + loop4 + ")").text(_json.emp_nm);
							}
							else 
							{
								
									if(loop4%6==0)
									{
										test1=test1+3;
									}
									
									$("#lineTable3 tr:eq("+test1+") th:eq(" +(loop4%6)+ ")").html("<em class=\"blue\" id=\"em_class\"><span></span>" +  _json.sq_no  + "</em> " + _json.high_title);
									$("#lineTable3 tr:eq("+(test1+1)+") td:eq(" +(loop4%6)+ ")").attr("emp_no", _json.emp_no).attr("sq_no", _json.sq_no);
									$("#lineTable3 tr:eq("+(test1+2)+") td:eq(" + (loop4%6) + ")").text(_json.emp_nm);
							}
							
						}
						else
						{
							$("#lineTable3 tr:eq(0) th:eq(" +loop4+ ")").html("<em class=\"blue\" id=\"em_class\"><span></span>" +  _json.sq_no  + "</em> " + _json.high_title);
							$("#lineTable3 tr:eq(1) td:eq(" + loop4+ ")").attr("emp_no", _json.emp_no).attr("sq_no", _json.sq_no);
							$("#lineTable3 tr:eq(2) td:eq(" + loop4 + ")").text(_json.emp_nm);
							
							
						}
						loop2++;
						loop4++;
							
					}
					
					
				}
				
		$.each($("em[id=em_class]"), function() { 
			if ($(this).parent().attr("sq_no") == '<%=eps_sq%>') { 
				$(this).removeClass();
				$(this).addClass("red");
			}
		});
		
	}
	
	var ret4 ='<%=R_cur_stat%>';
	
	 if (ret4!="R") {
			
			<% //결재라인 사진
			if (confirmHistoryList != null) {
				for (Object o : confirmHistoryList) { 
					HashMap<String, Object> h = (HashMap<String, Object>)o; 
			%>
			//20160115 대체권자 수정
			var rep_yn = '<%=StringUtil.normalizeNull(String.valueOf(h.get("rep_yn")))%>';

				var teste ='<%=StringUtil.normalizeNull(String.valueOf(h.get("allsign")))%>';
				if ( teste == "" )
				{
					if(rep_yn == "1"){
						$("td[emp_no='<%=String.valueOf(h.get("emp_no"))%>'][sq_no='<%=String.valueOf(h.get("sq_no"))%>']").html("<span style='font-size:12px;color:black;'><b>대결 </b>"+'<%=String.valueOf(h.get("rep_emp"))%>'+"</span><br/><br/>"); 
					}
						$("td[emp_no='<%=String.valueOf(h.get("emp_no"))%>'][sq_no='<%=String.valueOf(h.get("sq_no"))%>']").append('<%=String.valueOf(h.get("cdt"))%>');	
					
				}
				else
				{
					
					if(rep_yn == "1"){
						$("td[emp_no='<%=String.valueOf(h.get("emp_no"))%>'][sq_no='<%=String.valueOf(h.get("sq_no"))%>']").html("<span style='font-size:12px;color:black;'><b>대결 </b>"+'<%=String.valueOf(h.get("rep_emp"))%>'+"</span><br/><br/>");
						$("td[emp_no='<%=String.valueOf(h.get("emp_no"))%>'][sq_no='<%=String.valueOf(h.get("sq_no"))%>']").append('<%=String.valueOf(h.get("cdt"))%>');
						
					}else{
						$("td[emp_no='<%=String.valueOf(h.get("emp_no"))%>'][sq_no='<%=String.valueOf(h.get("sq_no"))%>']").html("<img id="+'<%=String.valueOf(h.get("sq_no"))%>'+'<%=String.valueOf(h.get("emp_no"))%>'+">" );$("#"+'<%=String.valueOf(h.get("sq_no"))%>'+'<%=String.valueOf(h.get("emp_no"))%>').attr("src","/upload/"+'<%=String.valueOf(h.get("allsign"))%>');
						$("td[emp_no='<%=String.valueOf(h.get("emp_no"))%>'][sq_no='<%=String.valueOf(h.get("sq_no"))%>']").append('<%=String.valueOf(h.get("cdt"))%>');	
					}
					
					
					
					
				}
			<%
				}
			}
			%>
		
}
}


//문서복사
function doCopy(){
	
	if (confirm('복사 하시겠습니까?')) {
		location.href = '/pay/event.jsp?exp_no=<%=exp_no%>&list_type='+"P";
	}
}

function doSubmit() { 
	
	
	// 제목체크 
	if (!f.title.value)
	{
		alert('제목을 입력해주세요');
		f.title.focus();
		return; 
	}else if(!f.rec_emp_nm.value){
		alert('경조대상자를 입력해주세요');
		f.rec_emp_nm.focus();
		return; 
	}else if(!f.fel_nm.value){
		alert('경조사유를 입력해주세요');
		f.fel_nm.focus();
		return; 
	}else if(!f.edate.value){
		alert('경조일을 입력해주세요');
		f.edate.focus();
		return; 
	}else if((!f.fr_dt.value) && ($("#fel_cd").val()!='d200')) { // 20250219.gmlee d200코드조건 추가
		alert('휴가시작일을 입력해주세요');
		f.fr_dt.focus();
		return; 
	}
	
	// 20250219.gmlee d200코드일떄 추가된 시작,종료일 체크	
	if ($("#fel_cd").val()=='d200') {
		
		var D200_length = _index;
		var _index_D200_seq =1;
		
		if(D200_length > 0){
			for (var i=0; i<D200_length; i++) { 
				
				if($("#fr_dt" + (i+1)).val()==""){
					alert('시작일을 입력해주세요');
					$("#fr_dt" + (i+1)).focus();
					return;
				}
				
				if($("#to_dt" + (i+1)).val()==""){
					alert('종료일을 입력해주세요');
					$("#to_dt" + (i+1)).focus();
					return;
				}
			}			
	     }	
		_index_D200_seq++;
	}
		
	
//alert(_index);
	
	//경조금액이 0이 아니면 지결체크
	if(!(($("#fel_mo").val() == "0") || ($("#fel_mo").val() == ""))){
	
		
		if($("#account_dt").val()==""){
			alert('결의일자를 입력해주세요');
			$("#account_dt").focus();
			return;
		}else{
			//지결사원만!!!! 증빙일자넣기	
			$("input[name=tax_dt]").val($("#account_dt").val());
		}
		//20140627 사원 지결상세 공백 체크 , 삭제시 _index --;도
		var tax_length = _index;
		var _index_seq =1;
		
		if((_index == 1) || ($("#fel_mo").val()== "0")){
			alert('지결상세를 입력해주세요');
			return;
		}
		if(tax_length > 0){
		for (var i=0; i<tax_length; i++) { 
			
			
			if($("#tax_dt" + (i+1)).val()==""){
				alert('증빙일자를 입력해주세요');
				$("#tax_dt" + (i+1)).focus();
				return;
			}else if($("#exp_cd" + (i+1)).val()==""){
				alert('지출결의항목을 입력해주세요');
				$("#exp_nm" + (i+1)).focus();
				return;
			}else if($("#tot_amt" + (i+1)).val()==""){
				alert('금액를 입력해주세요');
				$("#tot_amt" + (i+1)).focus();
				return;
			}else if($("#cust_cd" + (i+1)).val()==""){
				alert('사원을 입력해주세요');
				$("#cust_nm" + (i+1)).focus();
				return; 
			}else if($("#dept_cd2" + (i+1)).val()==""){
				alert('귀속부서를 입력해주세요');
				$("#dept_nm2" + (i+1)).focus();
				return;
			}else if($("#pay_due_dt" + (i+1)).val()==""){
				alert('지급요청일자를 입력해주세요');
				$("#pay_due_dt" + (i+1)).focus();
				return;
			}else if($("#dsc" + (i+1)).val()==""){
				alert('적요를 입력해주세요');
				$("#dsc" + (i+1)).focus();
				return;
			}
			
			}
		}
		
		_index_seq++;
	}
	
	// 이병운 20140418  M값 넘기기 
	var p_list_type = '<%=list_type%>';
	
	
	$.ajax({ 
		type: "POST", 
		url: 'tr.jsp',
		data: $("#f").serialize(),
		cache: false,
		async:false
 	}).success(function(_json) { 
 		if (_json.result=="true") { 
			
			// 이병운 20140418 수정했을때 이벤트  
			if(p_list_type=="M")
			{
				/*결재라인을 탔습니다   */
				if(_json.All_Modify=="002")
				{
					alert("다음결재자가 결재를 했습니다 ");
					
				}
				else if(_json.All_Modify=="001")
				{
					alert('결재가 수정되었습니다.');
					location.href = '/pay/event.jsp?exp_no=<%=exp_no%>';
				}
				
			}
			else
			{

				//alert('저장되었습니다');
				location.href ='/pay/event.jsp?exp_no='+_json.exp_no;	
				
			}
			
		}
		else 
		{
			alert('저장이 취소 되었습니다 다시 확인 해주세요.');
			return;
		}
	}).error(function(e, e2, e3) { 
	});
	
}

//이병운 20140418 문서수정
function doModify() {
	

	if (confirm('수정 하시겠습니까?')) { 

	location.href = '/pay/event.jsp?exp_no=<%=exp_no%>&list_type='+"M";
	
	}
	
}

//이병운  20140418 열람,미열람 체크 부분 
function viewYn()
{
	
	var date_sub = '<%=eps_dt%>';
	var eps_no_sub = '<%=eps_no%>';

	var tye ='<%=list_type%>';
	
	//배포반영
	if(tye=="Z")
	{
		var __load = _loadLine('/pay/view_yn_tr.jsp', {eps_dt : date_sub ,eps_no: eps_no_sub});
		__load.success(function(_json) { 
					
		}).error(function(e, e2, e3) { 
		});
			
	}
	else
	{
		var __load2 = _loadLine('/pay/plan_yn_tr.jsp', {exp_no: '<%=exp_no%>'});
		__load2.success(function(_json) { 
					
		}).error(function(e, e2, e3) { 
		});
	}
	Return_yn(); //상신 후 다음결재자가 문서확인했는지 여부(상신수정버튼) 
}

//이병운  20140523  반려, 완료 된 내용을 확인했는지 확인  
function Return_yn()
{
	var exp_no = '<%=exp_no%>';
	
	var __load = _loadLine('/pay/Return_yn_tr.jsp', {exp_no : exp_no});
	__load.success(function(_json) { 
				
	}).error(function(e, e2, e3) { 
	});
}

//관련문서
var lenDoc = 0;

if($("#docList li").length != 0){
	lenDoc = $("#docList li").length;
// 	alert("1-----+---- " + lenDoc);
}

function setRelateDoc(exp_no, exp_title) { 
	
	AddChgiFrame();
	
	var exp_no_list = exp_no.split(',');
	var exp_title_list = exp_title.split(',');
	
	
	if ($("#docList li").length + exp_no_list.length > 10) { 
		alert('10개까지만 추가가능합니다.');
		return;
	} else { 
		for (var i=0; i<exp_no_list.length; i++) { 
			if ($("#docList input[type=text]:eq(" + i + ")").val() == '') {
				$("#docList input[type=text]:eq(" + i + ")").val(exp_title_list[i]);
				$("#docList input[type=text]:eq(" + i + ")").attr("exp_no", exp_no_list[i]);
				$("#docList input[type=text]:eq(" + i + ")").parent().parent().append('<input type="hidden"  name="relate_exp_no" value="' +exp_no_list[i] + '">');
			} else { 
				
				$("#docList").append('<li><input type="text"  name="doc" id="doc' + (lenDoc + 1) + '" value="' + exp_title_list[i] + '" relate_exp_no="' + exp_no_list[i] 
				+ '"><a href="javascript:docDelete(doc' + (lenDoc + 1) + ');"><img src="/images/btn_del.gif" id="doc' + (lenDoc + 1) 
				+ '" alt="삭제"><input type="hidden"  id="doc' + (lenDoc + 1) + '" name="relate_exp_no" value="' +exp_no_list[i] + '"></li>');
				
				lenDoc++;
			}
		}
		
	}	
}

function _loadLine(url, params) { 
	return $.ajax({ 
		type: "GET", 
		url: url,
		data: params,
		cache: false,
		async:false
 	});
}


$(document).ready(function() {
	
	<% if ("AP".equals(list_type)) { %> 
		openEmp1(); setTimeout("window.close();", 500);
	<%} %>
	
	//20250219 gmlee 추가
	test_add();
	chkCodeD200();
	
	//총액 합계 
	$('#tot_amtval').number(true);
	$('#AllAmt').number(true);
	$('#vatval').number(true);
	$("#fel_mo").number(true);
	
	$("#tot_amtval").val(function(index, value) {
  	    return value
  	      .replace(/\D/g, "")
  	      .replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  	    ;
  	  }); 
      
      $("#AllAmt").val(function(index, value) {
	  	    return value
	  	      .replace(/\D/g, "")
	  	      .replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	  	    ;
	  	  }); 
		  	
      $("#vatval").val(function(index, value) {
	  	    return value
	  	      .replace(/\D/g, "")
	  	      .replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	  	    ;
	  	  }); 
	
	//총액 합계 
	$('#tot_amtval').prop('readOnly', true);
	$('#AllAmt').attr('readOnly', true);
	$('#vatval').attr('readOnly', true);
	
	
	<%if ("1".equals(ccnt)) { %>
	 //버튼숨기기
	$("p").attr("style", "visibility: hidden");
	$("#buttonfile").attr("style", "visibility: hidden");
	$("#aa").attr("style", "visibility: hidden");
	$("#bb").attr("style", "visibility: hidden");
	$("#cc").attr("style", "visibility: hidden");
	$("#tt").attr("style", "visibility: hidden");
		

	function openLine() { }
	function openEmp() { }
	function openDoc() { }
	function doAddDetail() { }
	function doDeleteDetail() { }
	function openClient() { }
	function openDept() { }
	function openFad() { }



<%}%>

	
	<%if ("1".equals(ccnt)) { %>

			$("p").attr("style", "visibility: hidden");
			$("#buttonfile").attr("style", "visibility: hidden");
			$("#addbtn").attr("style", "visibility: hidden");
			
			$("#exp_dt").attr('readOnly', true); //작성일자
			$("#title").attr('readOnly', true); //제목
			
			
			$("#rec_emp_nm").attr('onclick', '');
			$("#rec_emp_nm").removeAttr("class");
			$("#fel_nm").attr('onclick', '');
			$("#fel_nm").removeAttr("class");
			
			
			$("#edate").datepicker("destroy");
			$("#edate").removeAttr("class");
			
			$("#frdate").datepicker("destroy");
			$("#frdate").removeAttr("class");
			$("#todate").datepicker("destroy");
			$("#todate").removeAttr("class");

			$("#frtm").prop('readOnly', true);
			$("#totm").prop('readOnly', true);
			
			$("#fel_fl1").prop('disabled', true);
			$("#fel_fl2").prop('disabled', true);
			
			$("#place").prop('readOnly', true);
			$("#tel").prop('readOnly', true);
			$("#remark").prop('readOnly', true);
			
			$("#fel_remark").prop('readOnly', true);
			
			$("#section_ex").attr("style", "visibility: show");
			$("#section_ex").attr("style", "line-height: 160%");
			
			
	<%} %>
	<% if (!"".equals(exp_no)) { %>
	var main_sq = <%=current_main_sq%>;
	
	var __load = _loadLine('/pay/payline_detail_json.jsp', {main_sq : main_sq,emp_no :'<%=chemp_no%>', exp_no :'<%=exp_no%>', ccnt:'<%=ccnt%>'});
	__load.success(function(_json) { 
		setLine(main_sq, _json);
	}).error(function(e, e2, e3) { 
	});
	
	
	//지결
	var __load2 = _loadLine('/pay/detail_list.jsp?exp_no=<%=exp_no%>', {});
	__load2.success(function(_json) { 
		if (_json && _json.list.length > 0) { 
            _detailIndex = _json.list.length;
			for (var i=0; i<_json.list.length; i++) { 
				$("#detailTemplate2").tmpl(_json.list[i]).appendTo("#detailTable2");
				
				$("#tax_dt" + (i+1)).val(_json.list[i].tax_dt);
				$("#tax_dt" + (i+1)).val(_json.list[i].tax_dt);
				$("#pay_due_dt" + (i+1)).val(_json.list[i].pay_due_dt);
				$("#tax_bc" + (i+1)).val(_json.list[i].tax_bc);
				
				//$("#payemp_no" + (i+1)).val(_json.list[i].payemp_no);
				//$("#payemp_nm" + (i+1)).val(_json.list[i].payemp_nm);
				
				$("#tax_bc"+ (i+1)).customSelect();
				$("#dept_cd2" + (i+1)).val(_json.list[i].dept_cd2);
				$("#dept_nm2" + (i+1)).val(_json.list[i].dept_nm);
				$("#tax_dt" + (i+1)).datepicker({ dateFormat : 'yy-mm-dd' });
				$("#pay_due_dt" + (i+1)).datepicker({ dateFormat : 'yy-mm-dd' });
				$("#exp_cd" + (i+1)).val(_json.list[i].exp_cd);
				$("#exp_nm" + (i+1)).val(_json.list[i].exp_nm);
				$("#amt" + (i+1)).val(_json.list[i].amt);
				$("#vat" + (i+1)).val(_json.list[i].vat);
				$("#tot_amt" + (i+1)).val(_json.list[i].tot_amt);
				
				$("#cust_cd" + (i+1)).val(_json.list[i].cust_cd);
				$("#cust_nm" + (i+1)).val(_json.list[i].cust_nm);

				$("#amt" + (i+1)).number(true);
				$("#vat" + (i+1)).number(true);
				$("#tot_amt" + (i+1)).number(true);

				$("#man_cd" + (i+1)).val(_json.list[i].cst_cd);
				$("#man_nm" + (i+1)).val(_json.list[i].cst_nm);
				$("#pro_nm" + (i+1)).val(_json.list[i].pro_nm);
				$("#pro_cd" + (i+1)).val(_json.list[i].pro_cd);
				
				$("#pay_due_dt" + (i+1)).val(_json.list[i].pay_due_dt);
				$("#pay_due_dt" + (i+1)).datepicker({ dateFormat : 'yy-mm-dd' });
				$("#cury_bc" + (i+1)).val(_json.list[i].cury_bc);
				$("#cury_bc" + (i+1)).customSelect();
 
				// 상신된 내역 수정못하게 설정 
				<% if ("1".equals(ccnt)) 
				{ %>
				
						$("#exp_dt").attr('readOnly', true); //작성일자
						$("#title").attr('readOnly', true); //제목
				
						//input tag에서만 disabled 금지!(select태그는 제외) 아이패드에서 글씨가 안보임 
						$("#account_dt").attr('readOnly', true);
						$("#account_dt").css("background", "#ebebe4");
				
						$("#tax_dt"+ (i+1)).datepicker("destroy");
						$("#tax_dt"+ (i+1)).css("background", "#ebebe4");
						$("#tax_dt"+ (i+1)).attr('readOnly', true);
						
						$("#pay_due_dt"+ (i+1)).datepicker("destroy");
						$("#pay_due_dt"+ (i+1)).attr('readOnly', true);
						$("#cury_bc"+ (i+1)).attr('disabled', true);
				
						$('#payemp_nm'+ (i+1)).attr('readOnly', true);
						$("#payemp_nm"+ (i+1)).attr('onclick', '');
						//$("#payemp_nm"+ (i+1)).css("background", "#ebebe4");
				
						$("#tax_bc"+ (i+1)).prop('disabled', true);
						$("#tax_bc"+ (i+1)).attr('readOnly', true);
				
						$('#dept_cd2'+ (i+1)).attr('readOnly', true);
						$('#dept_nm2'+ (i+1)).attr('readOnly', true);
						$("#dept_nm2"+ (i+1)).attr('onclick', '');
						//$("#dept_nm2"+ (i+1)).css("background", "#ebebe4");
				
						$('#exp_cd'+ (i+1)).attr('readOnly', true);
						$('#exp_nm'+ (i+1)).attr('readOnly', true);
						$("#exp_nm"+ (i+1)).attr('onclick', '');
						//$("#exp_nm"+ (i+1)).css("background", "#ebebe4");
				
						$('#amt'+ (i+1)).attr('readOnly', true);
						$('#vat'+ (i+1)).prop('readOnly', true);
						$('#tot_amt'+ (i+1)).prop('readOnly', true);
				
						$('#cust_cd'+ (i+1)).attr('readOnly', true);
						$('#cust_nm'+ (i+1)).attr('readOnly', true);
						$("#cust_nm"+ (i+1)).attr('onclick', '');
						//$("#cust_nm"+ (i+1)).css("background", "#ebebe4");

						$('#man_cd'+ (i+1)).prop('readOnly', true);
						$('#man_nm'+ (i+1)).attr('readOnly', true);
						$('#pro_nm'+ (i+1)).attr('readOnly', true);
						$('#pro_cd'+ (i+1)).prop('readOnly', true);
						$("#man_nm"+ (i+1)).attr('onclick', '');
						$("#pro_nm"+ (i+1)).attr('onclick', '');
						
						$('#dsc'+ (i+1)).prop('readOnly', true);
					
				
			<% } %>

			 }
		}
        _detailIndex++;
	}).error(function(e, e2, e3) { 
	});
	
	
	
	var __load3 = _loadLine('/pay/event_rsn.jsp', {cd : '<%=String.valueOf(event.get("fel_cd"))%>'});
	__load3.success(function(_json) { 
		$("#fel_nm").val(_json.title);
		$("#fel_mo").val(_json.amt);
		$("#fel_hd").val(_json.holiday);
		
		
	}).error(function(e, e2, e3) { 
	}); 
	

	<% 
	if (referList != null) {
		for (Object o : referList) { 
			HashMap<String, Object> refer = (HashMap<String, Object>)o; 
	%>
		var testview = '<%=String.valueOf(refer.get("viewyn_dt"))%>';
		if(testview=="")
		{
			refer_list.push(new referEmp('<%=String.valueOf(refer.get("emp_no"))%>', '<span><%=String.valueOf(refer.get("emp_nm"))%></span>'));
		}
		else
		{
			refer_list.push(new referEmp('<%=String.valueOf(refer.get("emp_no"))%>', '<span><%=String.valueOf(refer.get("emp_nm"))%>: <%=String.valueOf(refer.get("viewyn_dt"))%> </span>'));	
		}
		
	<%
		detailcnt+=1;
	
		}
		
		
	}
	%>
	
	//배포 설정  이병운 (배포한번에)
	<% 
	if (referList_plan != null) {
		for (Object o : referList_plan) { 
			HashMap<String, Object> refer = (HashMap<String, Object>)o; 
	%>
		var testview = '<%=String.valueOf(refer.get("viewyn_dt"))%>';
		if(testview=="")
		{
			refer_list_sub.push(new referEmp('<%=String.valueOf(refer.get("emp_no"))%>', '<span><%=String.valueOf(refer.get("emp_nm"))%></span>'));
		}
		else
		{
			refer_list_sub.push(new referEmp('<%=String.valueOf(refer.get("emp_no"))%>', '<span><%=String.valueOf(refer.get("emp_nm"))%>: <%=String.valueOf(refer.get("viewyn_dt"))%> </span>'));	
		}
		
	<%
		detailcnt_plan+=1;
	
		}
		
		
	}
	%>
	
	//참조설정
	printReferTable();
	
	//배포 설정 
	printReferTable_sub();
		

	<% }  else { %>
	
	doAddDetail();
	
	//문서저장 하기전에(문서번호없을때)  신청자를   자기자신으로 셋팅
	$("#rec_emp_no").val("<%=_user.getEmp_no()%>");
	$("#rec_emp_nm").val("<%=chemp_nm%>");
	$("#treat_place").val("<%=chdept_nm%>");
	$("#high_bc_name").val("<%=ch_high_bc%>");
	
	
	<% } %>
	
	//참조문서 확인 함수 
	viewYn();
	
	majority();
	doOpenComment();
	
	bindComma();
	
	//지결 과세구분 수정후에도 변경가능하도록~
	ChgValues();
	
	//도움말 버튼
	<%
	HashMap<String, Object> map = new HashMap<String, Object>();
	String cate_cd = "48";
	map = (HashMap<String, Object>)tr.sql.selectObject("bbs.selectHelp", cate_cd); 
	//System.out.print(map + "\n");
	
	if( map != null && map.size() > 0 ) {
	%>
		document.getElementById("btnHelp").style.visibility = "visible";
	<% } else { %>
		document.getElementById("btnHelp").style.visibility = "hidden";
	<% } %>
	
});

function majority()
{
	//상신
	var ccnrt = '<%=ccnt%>';
	//
	var list_type1='<%=list_type%>';
	
	var cur_stat = '<%=R_cur_stat%>';
	
	 if (ccnrt=="1" && (list_type1=="" || list_type1=="S") ) {
		$("#commentDiv_2").attr("style", "display: none");
	 	$("#btn_typeAll").attr("style", "visibility: hidden");
	 	
	 	
	 } else if(ccnrt=="1" && list_type1=="Y" ) {
    	
     }
	 else
	{
		 if(cur_stat=="R")
		{
				$("#commentDiv_2").attr("style", "display: none");
			 	$("#btn_typeAll").attr("style", "visibility: hidden");
			 	
		} else {
			 $("#commentDiv_2").attr("style", "display: none");	 
		}
	}
     
}



function ChgValues()
{

	//20140529 조유리 지결 과세구분 수정후에도 변경가능하도록~
	$("select[name=tax_bc]").change(function(event) { 
		var idx2 = this.id.substring(6, 8);
		var vp12 = $("#tot_amt"+idx2).val(); 
	    var vp121 = SetPriceInput($("#tot_amt"+idx2).val());
	    $("#tot_amt"+idx2).val(vp121);
	    
	    //공급가 
	    var  tt = Math.round(vp12.replace(/,/g, "")/ 1.1);
	    //공급가(면세매입, 기타)
	    var ss = Math.round(vp12.replace(/,/g, ""));
	    //부가세
	    var v_test = Math.round(vp12.replace(/,/g, "")-tt);
	    
	    var r_test_view = SetPriceInput(String(v_test));
	    var tt_view =	SetPriceInput(String(tt)); 
	    var ss_view = 	SetPriceInput(String(ss)); 
	     
		if($(this).children("option:selected").val()=="FA630195" || $(this).children("option:selected").val()=="FA630130" ){
			
			 $("#amt"+idx2).val(ss_view);
			 $("#vat"+idx2).val(0);
		}else{
			$("#amt"+idx2).val(tt_view);
			$("#vat"+idx2).val(r_test_view);
		   
		}
		testsum();
	});
	
	
    /* var va13 =  parseInt(values) - (parseInt(values)/1.1);
    var va1 = parseInt(values)*0.1;
    
    
	$("#vat" + idx).val(va1);
	$("#amt" + idx).val(va13); */
	
}


function commaNum(num) {  
    var len, point, str;  

    num = num + "";  
    point = num.length % 3  
    len = num.length;  

    str = num.substring(0, point);  
    while (point < len) {  
        if (str != "") str += ",";  
        str += num.substring(point, point + 3);  
        point += 3;  
    }  
    return str;  
}  

function testsum()
{
	var tot_amtval = 0;
	var amtval = 0;
	var vatval = 0;

	for(var row=1; row<31; row++)
	{
		if ($("#tot_amt"+row).val() != null)
		{
			tot_amtval = parseInt(tot_amtval)+parseInt($("#tot_amt"+row).val().replace(/,/g, ""));
			amtval += parseInt($("#amt"+row).val().replace(/,/g, ""));
			vatval += parseInt($("#vat"+row).val().replace(/,/g, ""));
		} 
	}
	
	
	$("#tot_amtval").val(SetPriceInput(String(tot_amtval)));
	$("#AllAmt").val(SetPriceInput(String(amtval)));
	$("#vatval").val(SetPriceInput(String(vatval)));
	
	
	
	
}
function SetPriceInput(str)
{
		str=str.replace(/,/g,'');
		var retValue = "";
        for(i=1; i<=str.length; i++)
        {
			if(i > 1 && (i%3)==1) 
	          retValue = str.charAt(str.length - i) + "," + retValue;
	          else 
	          retValue = str.charAt(str.length - i) + retValue;    
        }
        return retValue;
}


//숫자 만 적용
function bindComma() { 

	ChgValues();
	
	$("input[name=tot_amt]").keyup(function(event) { 
		
	    if(event.keyCode == 8 || (event.keyCode >= 35 && event.keyCode <= 40) || (event.keyCode >= 46 && event.keyCode <= 57) || (event.keyCode >= 96 && event.keyCode <= 105) || event.keyCode == 110 || event.keyCode == 190) 
	    {
	      
	    	
		    	//event.preventDefault();
				var idx = this.id.substring(7, 9);
			     var vp12222 = $("#tot_amt"+idx).val(); 
			    var vp122221 = SetPriceInput($("#tot_amt"+idx).val());
			    $("#tot_amt"+idx).val(vp122221);
			    
			    //20140327  이병운 부가세
			    //공급가 
			    var  ttt = Math.round(vp12222.replace(/,/g, "")/ 1.1);
			    //부가세
			    var vat_test = Math.round(vp12222.replace(/,/g, "")-ttt);
			     var rvat_test_view =SetPriceInput(String(vat_test));
			     var ttt_view =	SetPriceInput(String(ttt)); 
			    
			   
			   //20140528 조유리 면세세입, 기타 는 부가세가 0이여야 한다.
					if($("#tax_bc" + idx).val()=="FA630195" || $("#tax_bc" + idx).val()=="FA630130")
					{
						ttt = 0;
						 $("#amt"+idx).val(SetPriceInput(String(Math.round(vp12222.replace(/,/g, "")))));
						 $("#vat"+idx).val(parseInt(ttt));
					}else{
						    //20140327  이병운 부가세
							$("#vat"+idx).val(rvat_test_view);
						    $("#amt"+idx).val(ttt_view);
					}

				testsum();
				
	     }
	    else
	    {

			  $(this).val(function(index, value) {
			    return value
			      .replace(/\D/g, "");
			  }); 
			
	    }
	      
	      
	
	});
	
	$("input[name=amt]").keyup(function() { 


	      if (event.which && (event.which  > 47 && event.which  < 58 || event.which == 8 || event.which == 13) || event.which > 96 || event.which  <105) {
		    event.preventDefault();
		    
		    
		  }
	      testsum();
		  /* $(this).val(function(index, value) {
		    return value
		      .replace(/\D/g, "")
		      .replace(/\B(?=(\d{3})+(?!\d))/g, ",")
		    ;
		  }); */
	});

	$("input[name=vat]").keyup(function() { 
	      if (event.which && (event.which  > 47 && event.which  < 58 || event.which == 8 || event.which == 13) || event.which > 96 || event.which  <105) {
		    event.preventDefault();
		  }
/* 
		  $(this).val(function(index, value) {
		    return value
		      .replace(/\D/g, "")
		      .replace(/\B(?=(\d{3})+(?!\d))/g, ",")
		    ;
		  }); */
		  
	      testsum();
	});
}

var fileList = new Array();

jQuery(function ($) {
	

	$('#uploadA').ajaxUpload({
		url : "/bbs/upload.jsp",
		name: "files",

		onSubmit: function() {
		},
		onComplete: function(data) {
			var exist = false;
			console.log(data);
			data = $.parseJSON(data);
			
			console.log(data);

			for(var a = 0 ; a < data.length; a++){
				$("#fileList").append('<li>'
				+'<input type="text"  name="files"  filesize="' + data[a].filesize + '" value="' + data[a].originalFilename + '"><a href="javascript:deletetest(\'' + data[a].filename + '\',\'filename'+a+'\');"><img src="/images/btn_del.gif" id=originalFilename' + a + ' alt="삭제"></a>'
				+'<input type="hidden"  name="filename"   id="filename' + a + '" value="' + data[a].filename + '">'
				+'<input type="hidden"  name="originalFilename" value="' + data[a].originalFilename + '">'
				+'<input type="hidden"  name="filesizes" value="' + data[a].filesize + '">'
				+'</li>');
			}
			
			
	  	}
	});

});

//참조삭제 (이병운 2014-09-01)
function deletereference(obj, val)
{
	for (var i = refer_list.length - 1; i >= 0; i--) 
	{
		if(refer_list[i].emp_no==val)
		{
			refer_list.splice(i, 1);	
		}
	}
	 printReferTable();
	 
}

//배포삭제 (이병운 2014-09-01)
function deletereference_sub(obj, val)
{
	for (var i = refer_list_sub.length - 1; i >= 0; i--) 
	{
		if(refer_list_sub[i].emp_no==val)
		{
			refer_list_sub.splice(i, 1);	
		}
	}
	printReferTable_sub();
	 
}

//파일삭제
function deletetest(obj)
{
	  $(obj).parent().remove();
}


//파일삭제
function deletetest(obj,id)
{
	
	$.ajax({
		  dataType: "json",
		  url: "/bbs/deleteFile.jsp",
		  data: { file: encodeURI(obj,"UTF-8") },
		  success: function(data) {
        if(data.result === 'true'){
        	alert(data.txt);
        	
     	   $('#'+id).parent().remove();
        }
     }
	});

	  
}
//파일삭제
function deletetest_sub(obj)
{
	  $("#filest"+obj).parent().remove();

}
//참조문서삭제
function docDelete(obj)
{
	  $(obj).parent().remove();
}
//참조문서삭제
function docDelete_sub(obj)
{
	  $("#doct"+obj).parent().remove();
}

function viewPopup(exp_no) {
	//openPopup_sub('/pay/event.jsp?exp_no=' + exp_no, 'popup', 1000,800);
	
	//window.open ('/pay/index.jsp?exp_no='+ exp_no,  'toolbar=no, location=no, status=no, menubar=no, scrollbars=yes, resizable=yes,  width=1000, height=800, top=1000, left=800');

	$.ajax({ 
		type: "POST", 
		url: 'viewPopup_json.jsp',
		data: { exp_no : exp_no},
		cache: false,
		async:false
 	}).success(function(_json) {
 		 if (_json.menu_cd) { 
			
			openPopup_sub(_json.menu_cd, 'popup', 1000,800);
			
		} 
	}).error(function(e, e2, e3) { 
	});
}

//저장상태서 인쇄할 수 있게 팝업 
function viewPopPrint(exp_no) {
	
	$.ajax({ 
		type: "POST", 
		url: 'viewPopup_json.jsp',
		data: { exp_no : exp_no, eps_type : '<%=eps_type%>', mode : 'print'},
		cache: false,
		async:false
 	}).success(function(_json) {
 		 if (_json.menu_cd) { 
			
			openPopup_sub(_json.menu_cd, 'popup', 1040,800);
			
		} 
	}).error(function(e, e2, e3) { 
	});
	
}

//이병운 20140411 상신삭제 
function doReturn() {
	
	if (confirm('결재 취소하시겠습니까?')) { 
		$.ajax({ 
			type: "POST", 
			url: 'status_tr.jsp',
			data: {eps_type : '<%=eps_type%>', exp_no : '<%=exp_no%>', cur_stat : 'C', mode : 'DeleteClear'},
			cache: false,
			async:false
	 	}).success(function(_json) { 
			if (_json.result) {
				
				/* 결재라인을 탔습니다   */
				if(_json.Allcnt=="002")
				{
					alert("다음결재자가 결재를 했습니다 ");
					location.href = '/pay/event.jsp?exp_no=<%=exp_no%>';
					
				}
				else if(_json.Allcnt=="001")
				{
					alert('결재 취소되었습니다.');
					
					location.href = '/pay/event_list.jsp?exp_no=<%=exp_no%>';
					
				}
				
			}
		}).error(function(e, e2, e3) { 
		});
	}
}

//20140411 이병운 반려된값 삭제 부분
function doDelete() { 
	 
	   	if ('<%=R_cur_stat%>'=="R") 
            {
            	
            	if (confirm('반려 데이터를 삭제하시겠습니까?')) { 
            		$.ajax({ 
            			type: "POST", 
            			url: 'delete_tr.jsp',

            			data: {exp_no : '<%=Returnexp_no%>'},
            			cache: false,
            			async:false
            	 	}).success(function(_json) { 
            			if (_json.result) { 
            				alert('삭제되었습니다.');
            				location.href = '/pay/event_list.jsp';
            			}
            		}).error(function(e, e2, e3) { 
            		});
            	}
            	
            }
            else
            {
            	if (confirm('삭제하시겠습니까?')) { 
            		$.ajax({ 
            			type: "POST", 
            			url: 'delete_tr.jsp',

            			data: {exp_no : '<%=exp_no%>'},
            			cache: false,
            			async:false
            	 	}).success(function(_json) { 
            			if (_json.result) { 
            				alert('삭제되었습니다.');
            				location.href = '/pay/event_list.jsp';
            			}
            		}).error(function(e, e2, e3) { 
            		});
            	}
            } 
}

function doApply() { 

	if ($("#line_main_sq").val() == '' || $("#line_main_sq").val() == '0') {
		alert('결재 라인을 선택해주세요.');
		return;
	} 

	//삭제 후에 상신했을때 반영 
	//이병운 2014-10-14
	var work_cnt111 = "0";
	work_cnt111  = paramCk_line($("#exp_no").val(), $("#line_main_sq").val() ,  $("#eps_type").val())
	if(work_cnt111=="0")
	{
		alert("결재라인을 확인해주시기 바랍니다. \n 1. 결재라인이 없습니다. \n 2. 결재라인에 퇴직자가 있습니다.");
		location.href = '/pay/event.jsp?exp_no=<%=exp_no%>';
		return;
	}
	
    
	if($("#exp_no").val()=="")
	{
		alert("저장 후 결재상신해주세요");
	}
	else
	{
    	AlldoApply();
	}
        
}
function AlldoApply() { 

    		if (confirm('결재 상신하시겠습니까?')) { 
		//상신할때 무조건 다시 저장후 상신 
    	//doSubmit();
    			$.ajax({ 
    				type: "POST", 
    				url: 'status_tr.jsp',
    				data: {eps_type : '<%=eps_type%>', exp_no : '<%=exp_no%>', cur_stat : 'C', mode : 'update', line_main_sq : $("#line_main_sq").val(), currentDate : '<%=currentDate%>'},
    				cache: false,
    				async:false
    		 	}).success(function(_json) { 
    				if (_json.result) { 
    					alert('결재 상신되었습니다.');
    					location.href = '/pay/event_list.jsp';
    				}
    			}).error(function(e, e2, e3) { 
    			});
    		}
        	 
}

function doCancel() { 
	if (confirm('결재 취소하시겠습니까?')) { 
		$.ajax({ 
			type: "POST", 
			url: 'status_tr.jsp',
			data: {eps_type : '<%=eps_type%>', exp_no : '<%=exp_no%>', cur_stat : 'C', mode : 'clear'},
			cache: false,
			async:false
	 	}).success(function(_json) { 
			if (_json.result) { 
				alert('결재 취소되었습니다.');
				location.href = '/pay/event.jsp?exp_no=<%=exp_no%>';
			}
		}).error(function(e, e2, e3) { 
		});
	}
}

function doAction(eps_stat) { 
	if ((eps_stat == 'R'|| eps_stat =='L') && $("#epsdsc").val() == '') { 
		alert('의견을 입력해주세요.');
		$("#epsdsc").focus();
		return;
	}

if (eps_stat == 'C' && confirm('정말 결재하시겠습니까?')) {
		
		$.ajax({ 
			type: "POST", 
			url: 'status_tr.jsp?mode=confirm&eps_stat=' + eps_stat,
			data: $("#f").serialize(), 
			cache: false,
			async:false
	 	}).success(function(_json) { 
			if (_json.result) { 
				//alert('처리 되었습니다.');
				//alert('경조사비 지급 완료.');
				<%-- location.href = '/pay/holiday.jsp?exp_no=<%=exp_no%>'; --%>
				/* 이병운 결재, 반려, 보류 했을때  무조건 받은 결재함으로 이동 */
				
				/* 이승수  결재 완료 시 기안자에게 메일 발송*/
				if(_json.updated_eps_stat == 'F') {
					
					payTitle = "<%=StringUtil.normalizeNull(String.valueOf(master.get("title"))).replace("\"", "'").replaceAll("\r\n","\\\\r\\\\n")%>";
					//mailTitle = "[결재] " + payTitle + "결재가 완료되었습니다.";
					mailTitle = "[결재] " + payTitle + "결재의견 등록 알림";
					
					$.ajax({
						  dataType: "json",
						  url: "/utils/payMailSender.jsp",
						  data: { receiver: "<%=chemp_no%>", status: "pay" , title: mailTitle, contents: mailTitle, exp_no: exp_no, epsdsc: epsdsc}, <%-- 2025-04-17 hsg. 최종 결재자가 결재를 했을 경우 결재라인에 있는 사람들에게 메일 발송을 위해 exp_no: exp_no, epsdsc: epsdsc 추가 --%>
						  success: function(data) {
				      if(data.result === 'true'){
				      	alert(data.txt);
				      	
				      }
				   }
					});
					
					//alert("메일 발송 테스트");
					
				}
				
				location.href = '/pay/receive.jsp';
			}
		}).error(function(e, e2, e3) { 
		});
		
	}else if(eps_stat == 'R' && confirm('정말 반려하시겠습니까?')){
		
		$.ajax({ 
			type: "POST", 
			url: 'status_tr.jsp?mode=confirm&eps_stat=' + eps_stat,
			data: $("#f").serialize(), 
			cache: false,
			async:false
	 	}).success(function(_json) { 
			if (_json.result) { 
				//alert('처리 되었습니다.');
				location.href = '/pay/receive.jsp';
			}
		}).error(function(e, e2, e3) { 
		});
		
	}else if(eps_stat == 'L' && confirm('정말 보류하시겠습니까?')){
		
		$.ajax({ 
			type: "POST", 
			url: 'status_tr.jsp?mode=confirm&eps_stat=' + eps_stat,
			data: $("#f").serialize(), 
			cache: false,
			async:false
	 	}).success(function(_json) { 
			if (_json.result) { 
				//alert('처리 되었습니다.');
				location.href = '/pay/receive.jsp';
			}
		}).error(function(e, e2, e3) { 
		});
	}
}

function openRsn(id) { 
	openPopup('/pay/pop_event_rsn.jsp?id=' + id, 'popup', 700, 600);
}

function doRsn(id, fel_cd, fel_nm, fel_mo, fel_hd, fel_fl) { 
	$("#fel_cd").val(fel_cd);
	$("#fel_nm").val(fel_nm);
	$("#fel_mo").val(fel_mo);
	$("#fel_hd").val(fel_hd);
	
	$("#fel_fl").val(fel_fl);
	
	$("#fel_fl1").val(fel_fl);
	$("#fel_fl2").val(fel_fl);
	

	//alert(fel_fl);
	
	if(fel_fl=='1'){ //지급이면
		$("#fel_fl1").prop('disabled', false);
		$("#fel_fl2").prop('disabled', false);
		$("#fel_fl1").attr('checked', true);
		$("#fel_fl2").attr('checked', false);
		$("#fel_fl2").prop('disabled', true);
		$("#fel_fl1").prop('disabled', true);
	}else{
		$("#fel_fl1").prop('disabled', false);
		$("#fel_fl2").prop('disabled', false);
		$("#fel_fl1").attr('checked', false);
		$("#fel_fl2").attr('checked', true);
		$("#fel_fl2").prop('disabled', true);
		$("#fel_fl1").prop('disabled', true);
	}
	
	
	eventholi();
	chkCodeD200();
}

//지결상세 적용할때 사용한다 
function doSetDetail() { 
	
	if(!f.edate.value)
	{
		alert('경조일을 입력해주세요');
		f.edate.focus();
		return; 
	}
	
	//경조금액이 0이 아니면 지결체크
	if(!(($("#fel_mo").val() == "0") || ($("#fel_mo").val() == ""))){
	
		$("#detailTable2 tr td").remove();
	
		AddChgiFrame();
		
		$("#detailTemplate2").tmpl({index : 1, dsc : ''}).appendTo("#detailTable2");
		$("#tax_dt" + 1).datepicker({dateFormat : 'yy-mm-dd' });
		$("#pay_due_dt" + 1).datepicker({ dateFormat : 'yy-mm-dd' });
		$("#exp_cd" + 1).val("0007");
		$("#exp_nm" + 1).val("경조비");
		$("#tax_bc" + 1).val("FA630195");
		$("#tax_bc" + 1).customSelect();
		$("#tot_amt" + 1).val($("#fel_mo").val());
		$("#amt" + 1).val($("#fel_mo").val());
		$("#vat" + 1).val('0');
		$("#cury_bc" + 1).val($("#currency").val());
		$("#cury_bc" + 1).customSelect();
		$("#tot_amtval").val($("#fel_mo").val());
		$("#AllAmt").val($("#fel_mo").val());
		$("#vatval").val('0');
		$("#tot_amt" + 1).number(true);
		$("#dsc" + 1).val($("#rec_emp_nm").val()+"/"+$("#fel_nm").val()+"/"+$("#edate").val());
		
		
		var emp_no = $("#rec_emp_no").val();
		
		var __load7 = _loadLine('/pay/accEmpDept_json_DW.jsp', {emp_no : emp_no});
		__load7.success(function(_json) { 
		
			$("#cust_nm" + 1).val(_json.cust_nm);
			$("#cust_cd" + 1).val(_json.cust_cd);
			$("#dept_nm2" + 1).val(_json.dept_nm2);
			$("#dept_cd2" + 1).val(_json.dept_cd2);
	 		
		}).error(function(e, e2, e3) {
		}); 
		
		
		_index++;
		testsum();

	}else{
		$("#detailTable2 tr td").remove();
		$("#tot_amtval").val('');
		$("#AllAmt").val('');
		$("#vatval").val('');
		alert("신청금액을 입력해주세요");
		$("#fel_mo").focus();
		return;
	}
}

function doAddDetail() { 
    AddChgiFrame();
    $("#detailTemplate2").tmpl({index : _detailIndex, tot_amt : '', amt : '', vat : '', dsc : ''}).appendTo("#detailTable2");
    
    $("#exp_cd" + _detailIndex).val("0007");
    $("#exp_nm" + _detailIndex).val("경조비");

    $("#tax_dt" + _detailIndex).datepicker({ dateFormat : 'yy-mm-dd' });
    $("#tax_bc" + _detailIndex).val("FA630195");
    $("#tax_bc" + _detailIndex).customSelect();
    
    $("#pay_due_dt" + _detailIndex).datepicker({dateFormat : 'yy-mm-dd' });
    
    $("#cury_bc" + _detailIndex).val('FI005KRW');
    $("#cury_bc" + _detailIndex).customSelect();
    
    $("#amt" + _detailIndex).number(true);
    $("#vat" + _detailIndex).number(true);
    $("#tot_amt" + _detailIndex).number(true);
    
    bindComma();
    
    _detailIndex++;
}


//날짜 계산
function date_add(sDate, nDays) {
  var yy = parseInt(sDate.substr(0, 4), 10);
  var mm = parseInt(sDate.substr(5, 2), 10);
  var dd = parseInt(sDate.substr(8), 10);
  var nDays = parseInt(nDays) - 1;
  
  
  d = new Date(yy, mm - 1, dd + nDays);

  yy = d.getFullYear();
  mm = d.getMonth() + 1; mm = (mm < 10) ? '0' + mm : mm;
  dd = d.getDate(); dd = (dd < 10) ? '0' + dd : dd;

  return yy + '-' +  mm  + '-' + dd;
}

function eventholi(){
	
	
	if($("#fel_nm").val()==''){
		alert('경조사유를 먼저 입력하세요.');
		$("#fel_nm").focus();
		$("#fr_dt").val('');
		return;
	} 
	
	var fel_hd = $("#fel_hd").val();
	var fel_nm = $("#fel_nm").val();
	var fr_dt = $("#fr_dt").val();
	// 24.02.15 추가 - 휴일제외인 건 출산-배우자, 근속 5가지 case
	var excxept_holiday_list = ['d200', 'e250', 'e300', 'f100', 'f200', 'f300'];
		
	if(fr_dt != '') {
		if(excxept_holiday_list.indexOf($('#fel_cd').val()) == -1) {
			$("#to_dt").val(date_add(fr_dt, fel_hd));
		} else {
			//출산-배우자 이면 휴일제외 10일(2020-03-12)
			$.ajax({ 
				type: "POST", 
				url: 'holiday_EndDate.jsp?fr_dt='+fr_dt+'&fel_hd=' + fel_hd,
				cache: false,
				async:false
		 	}).success(function(_json) { 
				$("#to_dt").val(_json.result);
			}).error(function(e, e2, e3) { 
			}); 
			
		}
	}
}

//도움말
function openHelp() { 
	openPopup('HelpView_DW.jsp?cate_cd=48','emp',1025,347);
}

//20250219.gmlee 내용의 삭제버튼
function doDeleteDetail2() { 
	if ($("input[id=sel_index]:checked").length == 0) { 
		alert('삭제할 목록을 체크해주세요.');
		return;
	}
	
	$.each($("input[id=sel_index]:checked"), function() { 
		$("tr[index=" + $(this).val() + "]").remove();
		
		
	});
	
	AddChgiFrame_remove();	
	_vacationIndex--;
}


//20250219.gmlee 내용의 추가버튼
//var _index =1;
function doAddDetail2() { 

    if (_vacationIndex < 5) {
			
			AddChgiFrame();
			    
			//$("#detailTemplate3").tmpl({index : _index}).appendTo("#detailTable3");
	        $("#detailTemplate3").tmpl({index: _vacationIndex, fr_dt: "", to_dt: ""}).appendTo("#detailTable3");
	
				
	        $("#fr_dt" + _vacationIndex).datepicker({ dateFormat : 'yy-mm-dd' });
	        $("#to_dt" + _vacationIndex).datepicker({ dateFormat : 'yy-mm-dd' }); 
	
	        _vacationIndex++;
		} 
		else if (_index > 5) {
			return
		}			
		 

	//ChgValues2();
}

//20250219.gmlee 경조사유 D200에 따라 기존 기간 비활성화 및 삭제,추가버튼 숨김
function chkCodeD200() {

if ($("#fel_cd").val()=='d200') { 

	$('#fr_dt').prop('disabled',true).hide()
	$('#to_dt').prop('disabled',true).hide()
	
	$('#delete_btn').prop('disabled',false).show()
	$('#add_btn').prop('disabled',false).show()
		
	} else {
		$('#fr_dt').prop('disabled',false).show()
		$('#to_dt').prop('disabled',false).show()
		
		$('#delete_btn').prop('disabled',true).hide()
	    $('#add_btn').prop('disabled',true).hide()
	    
	    
	} 
	
}
	
//20250219.gmlee 내용의 체크
/* function ChgValues2()
{
	for(var r = 1; r<_index; r++)
 	{
		var fr_dt = $("#fr_dt"+r).val();
 		var to_dt = $("#to_dt"+r).val();
 		
 		$('#fr_dt'+r).datepicker("destroy");
 		$('#to_dt'+r).datepicker("destroy");
 	}
		
}  */



//20250219.gmlee json 사용해서 추가한 날짜 조회가능하게
function test_add()
{
	
	var tesexp_no = '<%=exp_no%>';
	
	var __load = _loadLine('/pay/event_json.jsp', {exp_no : tesexp_no });
	__load.success(function(_json) { 
		if (_json && _json.list.length > 0) { 
            _vacationIndex = _json.list.length;
			for (var i=0; i<_json.list.length; i++) { 
				
				var str="";
				
				$("#detailTemplate3").tmpl(_json.list[i]).appendTo("#detailTable3");
				$("#fel_cd" + (i+1)).val(_json.list[i].fel_cd);

				$( "#fr_dt"+ (i+1) ).datepicker({ dateFormat : 'yy-mm-dd' });
				$( "#to_dt" + (i+1)).datepicker({ dateFormat : 'yy-mm-dd' });
				
				$("#fr_dt" + (i+1)).val(_json.list[i].fr_dt);
				$("#to_dt" + (i+1)).val(_json.list[i].to_dt);

				 
				<% if ("1".equals(ccnt)) 
				{ %>
					
					$("#exp_dt").attr('readOnly', true); //작성일자
					$("#title").attr('readOnly', true); //제목
					
				//input tag에서만 disabled 금지!(select태그는 제외) 아이패드에서 글씨가 안보임 
					$("#fel_cd"+ (i+1)).prop('disabled', true);
					//$('#fr_half_cd'+ (i+1)).attr('disabled', true);
					$("#fr_dt"+ (i+1)).attr('readOnly', true);
					$("#fr_dt"+ (i+1)).datepicker("destroy");
					
					$('#to_dt'+ (i+1)).attr('readOnly', true);
					$("#to_dt"+ (i+1)).datepicker("destroy");
					
					$('#reasons').attr('disabled', true); 
					$("#reasons").css("background", "white");
					
				<% } %> 

			 	$("#fel_cd"+(i+1)).customSelect();

                _vacationIndex++;
			}
		}
		
	}).error(function(e, e2, e3) { 
		console.log('e: ' + e.toString());
		console.log('e2: ' + e2.toString());
		console.log('e3: ' + e3.toString());
	});
	
}

//20250219.gmlee 추가
 $("#click").click(function () {
    if (datepicker) datepicker.refresh();
    $("#datepicker").show();
    datepicker = new ej.calendars.DatePicker({ width: "255px" });
    datepicker.appendTo('#datepicker');
}); 



</script>
</head>
<style type="text/css">
@media print {
	.printBtn {
		display: none;
	}
	.btns {
		display: none;
	}
	.line{
		display: none;
	}
	
	.slide{
		display: none;
	}
	#commentDiv_2{
		display: none;
	}
}
</style>
<body>
<div id="con_warp" class="mins">
        	<jsp:include page="/include/Change_location.jsp">
				<jsp:param name="name" value="<%=menuCode3 %>"/>
			</jsp:include>
	<div id="titletest"></div>
            
            <form name="f" id="f" method="post">
            <input type="hidden" name="line_main_sq" id="line_main_sq"/>
            
            <!--이병운 20140418 수정인지 아닌지 확인 -->
            <input type="hidden" name="list_type" id="list_type" value="<%=list_type %>"/>
            <input type="hidden" name="Returnexp_no" id="Returnexp_no" value="<%=Returnexp_no %>"/>
            <!--20140327 이병운 추가 반려   -->
            <% if ("R".equals(R_cur_stat)) { %>
            	<input type="hidden" name="exp_no" id="exp_no" value=""/>
            <% } else { %>
            		<input type="hidden" name="exp_no" id="exp_no" value="<%=docId %>"/>
            <% } %>
            
            <%-- <input type="hidden" name="exp_no" id="exp_no" value="<%=docId %>"/> --%>
            <input type="hidden" name="eps_sq" id="eps_sq" value="<%=eps_sq %>"/>
            <input type="hidden" name="eps_dt" id="eps_dt" value="<%=eps_dt %>"/>
            <input type="hidden" name="eps_type" id="eps_type" value="<%=eps_type %>"/>
            
            <div id="section">
            	<div class="section">
                 <ul class="btns">
                    <li class="left">
                    
                    
                    <% if (!"1".equals(ccnt)) { %>
                    <a href="javascript:openLine();" class="btn_type1"><span></span><img src="/images/ico_left3.png">결재라인</a></li>
                    <% }  %>
                    
                    <li class="right">
                    
                    <a href="javascript:openHelp()" class="btn_type2" id="btnHelp" style="visibility: hidden;" ><span></span>도움말</a>
                    
                    <% if (!"1".equals(ccnt) && !"".equals(exp_no)) { %><a href="javascript:viewPopPrint('<%=exp_no%>');" class="btn_type2"><span></span>인쇄</a><% } %>
                    
                    <!--이병운 20140418 버튼 숨김-->
                    <% if ("".equals(list_type)) { %>
	                    <% if (!"1".equals(ccnt)) { %>
	                    	<a href="javascript:doApply();" class="btn_type2" ><span></span>결재상신</a>
	                    <% } else if (!"1".equals(ccnt)) { %>
	                    	<a href="javascript:doCancel();" class="btn_type2"><span></span>결재취소</a>
	                    <% }  %>
                    <% } %>
                    
                    
                    <!--이병운 2014-04-08 상신 취소한다   -->
                    <% if ("001".equals(All_Modify)) { %>
                    
	                    	<!--이병운 20140418 버튼 숨김-->
	                    	<!-- 20140708 자신결재함/보낸결재함에서 미결재일경우에만 상신수정,상신삭제 버튼 나옴-->
	                   <% if ("N".equals(String.valueOf(master.get("apr_stat"))) && "C".equals(String.valueOf(master.get("eps_stat")))) { %>
	                   
	                    <% if ("".equals(list_type) || "S".equals(list_type)) { %>
	                        <% if ("1".equals(ccnt)) { %><a href="javascript:doModify();" class="btn_type2"><span></span>상신수정</a><% } %> 
		                    <% if ("1".equals(ccnt)) { %><a href="javascript:doReturn();" class="btn_type2"><span></span>상신삭제</a><% } %>
	                    <% } %>
	                    
	                    <% } %>
	                <% } %>
                    <% if ("".equals(list_type) || "S".equals(list_type)) { %>
		                    <% if ("F".equals(String.valueOf(master.get("eps_stat")))) { %><a href="javascript:doCopy();" class="btn_type2"><span></span>복사</a><% } %>
	                <% } %> 
					<% if ("1".equals(ccnt)) { %><a href="javascript:openEmp1();" class="btn_type2"><span></span>인쇄</a><% } %>
                    <% if (!"1".equals(ccnt)) { %><a href="javascript:doSubmit();" class="btn_type2"><span></span>저장</a><% } %>
                    <% if (!"1".equals(ccnt) && !"P".equals(list_type)) { %><a href="javascript:doDelete();" class="btn_type3"><span></span>삭제</a><% } %>
                    <% if ("1".equals(ccnt)) { %>
                    
                    	<% if ("".equals(list_type)) { %>
                    		<a href="event_list.jsp" class="btn_type2"><span></span>목록</a>
                    	<% }else { 
                    		if("Z".equals(list_type)){
                    			%>
                    			<a href="reference.jsp" class="btn_type2"><span></span>목록</a>
                    		
                    		<!-- 이병운 배포반영 -->
                    		<% }else if("B".equals(list_type)){ %>
                    			
                    			<a href="reference_plan.jsp" class="btn_type2"><span></span>목록</a>
                    			
                    		<%
                    		}else if("Y".equals(list_type)){
                    			%>
                    			
                    			    <% if ("N".equals(String.valueOf(master.get("apr_stat"))) && "C".equals(String.valueOf(master.get("eps_stat")))) { %><a href="receive.jsp?Stat_sub=X" class="btn_type2"><span></span>목록</a>	<% } %> 
                    			    <% if ("Y".equals(String.valueOf(master.get("apr_stat"))) && "C".equals(String.valueOf(master.get("eps_stat")))) { %><a href="receive.jsp?Stat_sub=C" class="btn_type2"><span></span>목록</a>	<% } %>
		                           	<% if ("R".equals(String.valueOf(master.get("eps_stat")))) { %><a href="receive.jsp?Stat_sub=R" class="btn_type2"><span></span>목록</a>	<% } %>
		                           	<% if ("F".equals(String.valueOf(master.get("eps_stat")))) { %><a href="receive.jsp?Stat_sub=F" class="btn_type2"><span></span>목록</a>	<% } %>
		                           	<% if ("L".equals(String.valueOf(master.get("eps_stat")))) { %><a href="receive.jsp?Stat_sub=L" class="btn_type2"><span></span>목록</a>	<% } %>
                        		<!-- <a href="receive.jsp" class="btn_type2"><span></span>목록</a> -->
                        		<%
                    		}else{
                    			%>
                    			
                    				<% if ("C".equals(String.valueOf(master.get("eps_stat")))) { %><a href="send.jsp?Stat_sub=C" class="btn_type2"><span></span>목록</a>	<% } %>
		                           	<% if ("R".equals(String.valueOf(master.get("eps_stat")))) { %><a href="send.jsp?Stat_sub=R" class="btn_type2"><span></span>목록</a>	<% } %>
		                           	<% if ("F".equals(String.valueOf(master.get("eps_stat")))) { %><a href="send.jsp?Stat_sub=F" class="btn_type2"><span></span>목록</a>	<% } %>
		                           	<% if ("L".equals(String.valueOf(master.get("eps_stat")))) { %><a href="send.jsp?Stat_sub=L" class="btn_type2"><span></span>목록</a>	<% } %>
                    			<!-- <a href="send.jsp" class="btn_type2"><span></span>목록</a> -->
                    			<%
                    		}
                    	} %>
                    	
                    <% } %>
                    
                    
                    </li>
                    </ul>

                    <div class="table_type1">
                        <span class="lt"></span><span class="rt"></span>
                        <table>
                        <colgroup>
                        <col width="25%">
                        <col width="25%">
                        <col width="25%">
                        <col width="25%">
                        </colgroup>
                        <tr>
                            <th>문서번호 </th>
                            <th>작성일자</th>
                            <th>부서</th>
                            <th>작성자</th>
                        </tr>
                        <tr>
                            
                            
				            <% if ("R".equals(R_cur_stat)) { %>
				            <td></td>
				            <% } else { %>
				            <td><%=docId%></td>
				            
				            <% }%>
                            <td><input type="text" class="input_cal" style="width:100%;" value="<%=currentDate%>" readOnly name="exp_dt" id="exp_dt"></td>
                            <td><%=chdept_nm%></td>
                            <td>[<%=ch_high_bc%>] <%=chemp_nm%></td>
                        </tr>
                        <tr class="bn">
                            <th colspan="4">제목</th>
                        </tr>
                        <tr class="bn">
                            <td colspan="4"><input type="text" name="title" id="title" style="width:100%;" value="<%=StringUtil.normalizeNull(String.valueOf(master.get("title"))).replace("\"", "'").replaceAll("\r\n","\\\\r\\\\n")%>"></td>
                        </tr>
                        </table>
                        <span class="lb"></span><span class="c"></span><span class="rb"></span>
                    </div>
				</div>
				
    				<div class="line"></div>
    				<div class="section">	
 					<h2>내용입력</h2>
                    <div class="table_type2">
                        <table id="detailTable3"> <%-- 20250219.gmlee id 추가--%>
                        <colgroup>
                        <col width="20%">
                        <col width="24%">
                        <col width="20%">
                        <col width="*">
                        </colgroup>
                        <tr>
                            <th>경조 대상자</th>
                            <th>부서</th>
                            <th>직위</th>
                            <th>경조사유</th>
                        </tr>
                        <tr>
                        	<td>
                        		<input type="hidden" name="rec_emp_no" id="rec_emp_no" value="<%=StringUtil.normalizeNull(String.valueOf(event.get("emp_no")))%>" />
		                        <input type="text" style="width:100%;" name="rec_emp_nm" id="rec_emp_nm" class="input_pop" value="<%=StringUtil.normalizeNull(String.valueOf(event.get("emp_nm")))%>"  REQUIRED readonly onclick="openEmp2();">
                        	</td>
                        	<td>
                        		<input type="text" id = "treat_place" name = "treat_place" value="<%=StringUtil.normalizeNull(String.valueOf(event.get("dept_nm")))%>" style="width:100%;background-color:#ebebe4;" readonly>
                        	</td>
                        	<td>
                        		<input type="text" style="width:100%;background-color:#ebebe4;" name="high_bc_name" id = "high_bc_name" value="<%=StringUtil.normalizeNull(String.valueOf(event.get("high_nm")))%>" readonly >
                        	</td>
                        	<td colspan="2">
                            	<input type="hidden" name="fel_cd" id="fel_cd" value="<%=StringUtil.normalizeNull(String.valueOf(event.get("fel_cd")))%>"/>
                            	<input type="text" style="width:90%;" readonly name="fel_nm" id="fel_nm"  class="input_pop" onclick="openRsn('1');" value="<%=StringUtil.normalizeNull(String.valueOf(event.get("fel_nm")))%>">
                            </td>
                        </tr>
                         
                        <tr class="bn">
                        	<td colspan="4" style="height:10px"></td>
                        </tr>
                                                                           
                        <tr class="bn">
                            <th>화환여부</th>
                            <th>비고</th>
                        </tr>
                        
                        <tr class="bn">
                            <td>
                            		<!-- <b><font color="#2a6894">화환여부</font></b> -->
                            		<input type="hidden" name="fel_fl"  id="fel_fl" value="<%=String.valueOf(event.get("fel_fl"))%>"/>
                            		&nbsp;&nbsp;선택 <input type="radio" name="fel_fl1" id="fel_fl1" disabled  value="1" <% if ("1".equals(String.valueOf(event.get("fel_fl")))) { %> checked <% } %>/> 
                            		&nbsp;&nbsp;선택안함 <input type="radio" name="fel_fl2" id="fel_fl2" disabled  value="0" <% if ("0".equals(String.valueOf(event.get("fel_fl")))) { %> checked <% } %> />
                            </td>
                            <td colspan="3">
                            	<!-- <b><font color="#2a6894">비고</font></b> -->
                            	<input type="text" style="width:96%" name="fel_remark" id="fel_remark"  value="<%=StringUtil.normalizeNull(String.valueOf(event.get("fel_remark")))%>"/>
                            </td>
                        </tr>
                        <tr class="bn">
                        	<td colspan="4" style="height:10px"></td>
                        </tr>
                        
                        
                        <tr class="bn">
                            
                            <th>경조일</th>
                            <th>경조금</th>
                            <th>경조휴가</th>
                            <th>휴가기간</th>
                        </tr>
                        <tr class="bn">

                            <td>
                            <input type="text" class="input_cal" style="width:100%" readOnly name="edate" id="edate" value="<%=StringUtil.normalizeNull(String.valueOf(event.get("edate")))%>" /></td>
                            <td><input type="text" style="width:53%;background-color:#ebebe4;" name="fel_mo" id="fel_mo" readonly value="<%=StringUtil.normalizeNull(String.valueOf(event.get("fel_mo")))%>"/>
                            <%if (!"1".equals(ccnt)) { %> <a href="javascript:doSetDetail()" class="btn_type4">적 용 </a></td> <% } %>
                            <td><input type="text" style="width:50%;background-color:#ebebe4;" name="fel_hd" id="fel_hd" readonly value="<%=event.get("fel_hd") != null ? StringUtil.normalizeNull(String.valueOf(event.get("fel_hd"))) : ""%>"/></td>
                        	
                                  <td><input type="text" class="input_cal" readOnly name="fr_dt" id="fr_dt" OnChange="eventholi()" value="<%=StringUtil.normalizeNull(String.valueOf(event.get("fr_dt")))%>">
                                  ~
                                  
                                  <input type="text"  readOnly name="to_dt" id="to_dt"  value="<%=StringUtil.normalizeNull(String.valueOf(event.get("to_dt")))%>" style="background-color:#ebebe4;" placeholder="자동입력"></td>
                              
                        </tr>
                                                                  
<%--                         
                        <tr class="bn">
                            <th colspan="2">경조일시</th>
                            <th colspan="2">장소</th>
                        </tr>
                        <tr class="bn">
                        	<td colspan="2">
                        		<table class="bnone" style="width:100%;">
                                <colgroup>
                                  <col width="46%">
                                  <col width="8">
                                  <col width="46%">
                                </colgroup>
                        		  <tr>
                        		    <td><input type="text" placeholder="선택사항" class="input_cal" style="width:70%" name="frdate" id="frdate" readOnly value="< %=!"1900".equals(String.valueOf(event.get("frdate")).substring(0,4)) ? StringUtil.normalizeNull(String.valueOf(event.get("frdate"))) : ""% >">
                        		    <input type="text" name="frtm" id="frtm" style="width:25%" placeholder="00:00" value="< %=StringUtil.normalizeNull(String.valueOf(event.get("frtm")))% >">
                        		    </td>
                        		    <td align="center">~</td>
                        		    <td><input type="text" placeholder="선택사항" class="input_cal" style="width:70%" readOnly value="< %=!"1900".equals(String.valueOf(event.get("todate")).substring(0,4)) ? StringUtil.normalizeNull(String.valueOf(event.get("todate"))) : ""% >" name="todate" id="todate">
                      		    	<input type="text" name="totm" id="totm" style="width:25%" placeholder="00:00" value="< %=StringUtil.normalizeNull(String.valueOf(event.get("totm")))% >">
                      		    	</td>
                      		    </tr>
                      		  </table>
                        		</td>
                        	<td colspan="2">
                        	<input type="text" style="width:100%" placeholder="선택사항" name="place" id="place"  $NAME="장소" REQUIRED value="< %=StringUtil.normalizeNull(String.valueOf(event.get("place")))% >" />
                        	</td>
                        </tr>
                        <tr class="bn">
                            <th>연락처</th>
                            <th colspan="3">비고</th>
                        </tr>
                        <tr class="bn">
                        	<td>
                        	<input type="text" style="width:100%" name="tel" id="tel"  $NAME="연락처" placeholder="선택사항" REQUIRED value="< %=StringUtil.normalizeNull(String.valueOf(event.get("tel")))% >" />
                        	</td>
                        	<td colspan="3">
                        	<input type="text" style="width:100%" name="remark" id="remark" placeholder="선택사항" value="< %=StringUtil.normalizeNull(String.valueOf(event.get("dsc2")))% >" />
                        	</td> 
                        </tr>
                         --%>
                        </table>
                        <span class="b"></span>
                    </div>
                </div>
                
                 <%-- 20250219.gmlee 삭제,추가버튼 추가 --%>               
                 <div style="height:5px"></div>                         
                        <ul class="btns">         
                        <%  if (!"1".equals(ccnt))
                        {  %>
                         <li class="right"><a href="javascript:doDeleteDetail2()" class="btn_type8" id="delete_btn" type="hidden">삭 제 <img src="/images/bu_arrow.gif"></a>
                         <a href="javascript:doAddDetail2();" class="file" id="add_btn" type="hidden">추 가</a>
                         </li>
                        <% }
                        %>
                       </ul>
                       
                
                <div class="section">
                        <strong><p style="line-height: 160%;font-size:13px;" id="section_ex">
						&nbsp; * 출산(남직원)휴가 : 자녀출생후 120일이내 경조휴가 신청 후 사용가능(4회 분할가능, 휴일제외)
						<br/>
   						&nbsp; * 본인 결혼시 임직원 급여 일괄공제에 의한 추가지급은 없음
   						<br/>
   						&nbsp; * 휴가기간 중에 휴일이 있는 경우에는 그 휴일은 휴가기간에 산입한다.
   						<br/>
   						<br/>
   						&nbsp; 경조휴가 및 경조금 신청시 다음의 서류를 필히 첨부하여 주시기 바랍니다. 
   						<br/>
   						&nbsp; 1. 결혼식 : 본인(청첩장)/본인외(등본 또는 가족관계 증명원)
   						<br/>
   						&nbsp; 2. 회갑/칠순 : [주민등록등본] 또는 가족관계증명서 
   						<br/>
   						&nbsp; 3. 결혼기념일 : [혼인관계증명서]
   						</p>
   						</strong>
				</div> 
					
<!--                 <div class="line"></div> -->
                    <div class="section">	
<!--                     <h2>지결상세</h2> -->
                    
                     <div class="table_type3">
<!--                      	<table> -->
<!--                      	<tr class="bn"> -->
                     	
<!--                             <th>결의일자</th> -->
<%--                             <td><input type="text" class="input_cal" style="width:100%; text-align:center" readOnly value="< %=StringUtil.normalizeNull(acc_dt)% >" name="account_dt" id="account_dt"></td> --%>
<!--                             <th>총   액 </th> -->
<%--                             <td><input type="text" name="tot_amtval" id="tot_amtval" style="width:100%; text-align:right" value = "< %=StringUtil.normalizeNull(String.valueOf(master.get("tot_amt_sum")))% >" ></td> --%>
<!--                             <th>공급가총액 </th> -->
<%--                             <td><input type="text"  name="AllAmt" id="AllAmt" style="width:100%; text-align:right" value = "< %=StringUtil.normalizeNull(String.valueOf(master.get("amt")))% >" ></td> --%>
<!--                             <th>부가세총액 </th> -->
<%--                             <td><input type="text" name="vatval" id="vatval" style="width:100%; text-align:right" value = "< %=StringUtil.normalizeNull(String.valueOf(master.get("vat")))% >" ></td> --%>
                            
<!--                         </tr> -->
                        
<!--                         </table> -->
         			</div>
                    
                    <div class="table_type3">
<!--                       <table id="detailTable"> -->
<!--                         <colgroup> -->
<!--                           <col width="15%"> -->
<!--                           <col width="20%"> -->
<!--                           <col width="15%"> -->
<!--                           <col width="15%"> -->
<!--                           <col width="15%"> -->
<!--                           <col width="15%"> -->
<!--                           <col width="5%"> -->
<!--                         </colgroup> -->
<!--                         <tr> -->
<!--                           <th>증빙일자</th> -->
<!--                           <th>지출결의항목</th> -->
<!--                           <th>과세구분</th> -->
<!--                           <th>금액</th> -->
<!--                           <th>공급가액</th> -->
<!--                           <th>부가세</th> -->
<!--                           <th rowspan="2">선택</th> -->
<!--                         </tr> -->
<!--                         <tr> -->
<!--                           <th colspan="2">사원</th> -->
<!--                           <th>예산귀속부서</th> -->
<!--                           <th colspan="3">적요</th> -->
<!--                         </tr> -->
<!--                       </table> -->
<!--                       <span class="b"></span> -->
                    </div>
<!--                     <ul class="btns"> -->
<!--                     <li class="left"> -->
<!--                     	<p>&nbsp;&nbsp;※사내경조금의 예산귀속부서는 <b>경영관리팀</b>입니다.</p> -->
<!--                     </li> -->
<!--                    <li class="right"> -->
<!--                     <a href="javascript:doDeleteDetail()" class="btn_type8" id = "cc">삭 제 <img src="/images/bu_arrow.gif"></a> -->
<!--                     <a href="javascript:doCopyDetail($(this).parent());" class="btn_type4" id = "bb" >복 사 <img src="/images/bu_arrow.gif"></a> -->
<!--                     <a href="javascript:doAddDetail();" class="file" id = "aa">추 가</a> -->
<!--                     </li> -->
<!--                     </ul> -->
                </div>
				<div class="line"></div>
				
 			 <div class="section">
                    <h2>지결총액</h2>
					<div class="table_type2">
                     	<table>
                     	<colgroup>
                          <col width="13%">
                          <col width="20%">
                          <col width="13%">
                          <col width="20%">
                          <col width="13%">
                          <col width="20%">
                        </colgroup>
                     	<tr class="bn">
                            <th>결의일자</th>
                            <td><input type="text" class="input_cal" readOnly style="width:100%; text-align:center" value="<%=StringUtil.normalizeNull(acc_dt)%>" name="account_dt" id="account_dt"></td>
                            
                        </tr>
                        <tr>
                        	<th>총   액 </th>
                            <td><input type="text" readOnly name="tot_amtval" id="tot_amtval" style="width:100%; text-align:right;background:#ebebe4;" value = "<%=StringUtil.normalizeNull(String.valueOf(master.get("tot_amt_sum")))%>" ></td>
                            <th>공급가총액 </th>
                            <td><input type="text" readOnly name="AllAmt" id="AllAmt" style="width:100%; text-align:right;background:#ebebe4;" value = "<%=StringUtil.normalizeNull(String.valueOf(master.get("amt")))%>" ></td>
                            <th>부가세총액 </th>
                            <td><input type="text" readOnly name="vatval" id="vatval" style="width:100%; text-align:right;background:#ebebe4;" value = "<%=StringUtil.normalizeNull(String.valueOf(master.get("vat")))%>" ></td>
                        </tr>
              
                        </table>
                        <span class="b"></span>
         			</div>  

                    <h2>지결상세</h2>
                    
         			
                    <div class="table_type3">
                      <table id="detailTable2">
                        <colgroup>
                    	  <col width="135px">
                          <col width="10%">
                          <col width="16%">
                          <col width="14%">
                          <col width="7%">
                          <col width="12%">
                          <col width="*">
                          <col width="4%">
                          <col width="4%">
                        </colgroup>
                        <tr>
                     <!-- <th>증빙일자</th> -->
                          <th>지출결의항목</th>
                     <!-- <th>과세구분</th> -->
                     <!-- <th>공급가액</th>
                          <th>부가세</th> -->
                          <th>사원</th>
                          <th>예산귀속부서</th>
                          <th>지급요청일자</th>
                          <th>환종</th>
                          <th>금액</th>
                          <th>적요</th>
                     	  <th>선택</th>
                        </tr>
                        
                        
                      </table>
                      <span class="b"></span>

                      
                    </div>
                    <ul class="btns">
                    <li class="left">
                    	<p>&nbsp;&nbsp;※지결상세 작성시 <b>예산귀속부서</b>를 확인하시기 바랍니다.</p>
                    </li>
                    <!-- 2025-04-11 hsg. 그룹웨어 경조사비 및 경조휴가신청서 문서의 지결상세부분에 삭제/추가 버튼 생성 -->
                    <li class="right">
                    <a href="javascript:doDeleteDetail()" class="btn_type8" id = "cc">삭 제 <img src="/images/bu_arrow.gif"></a>
                    <a href="javascript:doCopyDetail($(this).parent());" class="btn_type4" id = "bb" >복 사 <img src="/images/bu_arrow.gif"></a>
                    <a href="javascript:doAddDetail();" class="file" id = "aa">추 가</a>
                    </li>
                    </ul>
 
                </div>
 				<div class="line"></div>
				<div class="printBtn"> 
				<div class="section">
				
                    <div class="box1">
                        <div class="fl">
                            <h2>첨부파일</h2>
                           
                            <p>10개까지 가능하며 파일 크기는 20MB이하여야 합니다. <a href="javascript:addFileInput()" class="file" id="uploadA" >+ 파일추가</a></p>
                            <ol id="fileList"><%if (!"1".equals(ccnt)) { %><p>※ 첨부파일명에 특수문자( ' + ; # & % $ ~ ` @)를 기입하지 마십시오. </p><% } %> 
                            
                            <%
                            int  fileidex=1;
                            if (fileList != null) { 
                           		for (Object o : fileList) { 
                           			HashMap<String, Object> f = (HashMap<String, Object>)o;
                            %>
	                            
	                              <%if ("1".equals(ccnt)) { %> <li><a href="/bbs/FileDownload.jsp?fileName=<%=String.valueOf(f.get("file_nm")) %>&file_allnm=<%=String.valueOf(f.get("file_nm_sub")) %>" > <%=String.valueOf(f.get("file_nm_sub")) %><span>[ <%=String.valueOf(f.get("file_size")) %>kb ]</span></a></li>
									
	                             
	                             <% } else {  %> 
	                           		<li>
	                           			<input type="text"  name="files" id="filest<%=fileidex %>"   filesize="'<%=String.valueOf(f.get("file_size")) %>'" value="<%=String.valueOf(f.get("file_nm_sub")) %>">
	                            		<input type="hidden"  name="filesizes" id="filest<%=fileidex %>"  value="<%=String.valueOf(f.get("file_size")) %>">
	                            		<input type="hidden"  name="filename" id="filest<%=fileidex %>"  value="<%=String.valueOf(f.get("file_nm")) %>">
	                            		
	                            		<input type="hidden" name="originalFilename" id="originalFilename<%=fileidex %>" value="<%=String.valueOf(f.get("originalFilename")) %>">
	                            		
	                            		<a href="javascript:deletetest('<%=String.valueOf(f.get("file_nm")) %>','filest<%=fileidex %>');"><img	src="/images/btn_del.gif" id="filest<%=fileidex %> alt="삭제"></a>
		                            	
	                            	</li>
	                            	
	                          		<% } %>	
	                            
                            <%

                            len++;
                            		fileidex++;
                            
                           		}
                           		
                           		for (int i=0; i<3 - fileList.size(); i++) { 
                           	%>
                          		<!-- 
                          		<li><input type="text"  name="files" ></li>
                          		 -->  
                           	<%
                           		}
                            } else { 
                            %>
                            <!-- 
                            <li><input type="text"  name="files" ></li>
                            <li><input type="text"  name="files" ></li>
                            <li><input type="text"  name="files" ></li>
                             -->  
                            <% 
                            }
                            %>
                            </ol>
                        </div>
                        <div class="fr">
                            <h2>관련문서</h2>
                            <p>10개까지 가능하며 파일 크기는 20MB이하여야 합니다. <a href="javascript:openDoc();" class="file">+ 문서추가</a></p>
                             <ol id="docList">
                            <%
                            int tes =1;
                            if (docList != null) { 
                           		for (Object o : docList) { 
                           			HashMap<String, Object> f = (HashMap<String, Object>)o;
                            %>
                            
                               <%if ("1".equals(ccnt)) { %>
	                                    
	                             		<li><a href="javascript:viewPopup('<%=String.valueOf(f.get("relate_doc")) %>');"><%=String.valueOf(f.get("eps_title")) %><span>[ <%=String.valueOf(f.get("relate_doc")) %>kb ]</span>
	                             		
	                             		</a> 
	                             		</li>
	                             <% } else {  %> 
	                           
		                            	<li>
		                            	
		                            	<input type="text" name="doc" id="doct<%=tes %>" value="<%=String.valueOf(f.get("eps_title")) %>" relate_exp_no="<%=String.valueOf(f.get("relate_doc")) %>">
		                            	
		                            	<input type="hidden"  name="relate_exp_no"  id="doct<%=tes %>" value="<%=String.valueOf(f.get("relate_doc")) %>">
		                            	<a href="javascript:docDelete_sub(<%=tes %>);"><img src="/images/btn_del.gif" id="doct<%=tes %>" alt="삭제"></a>
		                            	</li>
		                            	
	                          		<% } %>	
	                          		
	                          	
                            <%
                            	tes++;
                            
                           		}
                           		
                           		for (int i=0; i<3 - docList.size(); i++) { 
                           	%>
                           	<%
                           		}
                            } else { 
                            %>
                            <%
                            }
                            %>
                            </ol>
                        </div>
                    </div>
                </div>
                </div>
                
		<div class="line"></div>
		
		<div class="section box22" id="lineDiv" >
			<div class="fl" style="width:58%;">        
					<h2>결재라인</h2>
					<div class="table_type3">
						<table id="lineTable1">
							<colgroup>
								<col width="16%">
								<col width="16%">
								<col width="16%">
								<col width="16%">
								<col width="16%">
								<col width="16%">
							</colgroup>
							<tr>
								<th class="al"></th>
								<th class="al"></th>
								<th class="al"></th>
								<th class="al"></th>
								<th class="al"></th>
								<th class="al"></th>
							</tr>
							<tr class="time">
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
							<tr>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
						</table>
						<span class="b"></span>
					</div>
			</div>
                  
			<!--                     
			<div class="fl" style="width:58%;">        
				<h2>합의부서 결재</h2>
				<div class="table_type3">
					<table id="lineTable3">
						<colgroup>
							<col width="16%">
							<col width="16%">
							<col width="16%">
							<col width="16%">
							<col width="16%">
							<col width="16%">
						</colgroup>
						<tr>
							<th class="al"></th>
							<th class="al"></th>
							<th class="al"></th>
							<th class="al"></th>
							<th class="al"></th>
							<th class="al"></th>
						</tr>
						<tr class="time">
							<td></td>
							<td></td>
							<td></td>
							<td></td>
							
							<td></td>
							<td></td>
						</tr>
						<tr>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
							
							<td></td>
							<td></td>
						</tr>
					</table>
				<span class="b"></span>
				</div>
			
			</div> -->
                   
			<div class="printBtn">
				<div class="fr" style="width:38%;">        
					<h2>참조</h2>
					<ul class="btns t25">
	                       
					<% if ("1".equals(ccnt) && detailcnt>=0 ) { %>
						<li class="right"><a href="javascript:detailEmp();"  id = "detailEmp" class="file">참조상세</a>
					<% } else {%>
						<li class="right"><a href="javascript:openEmp();"  id = "btn_openEmp" class="file">참조 선택</a>
					<% } %>
	                       
					</ul>
					<div class="table_type4">
						<table id="referTable">
							<colgroup>
								<col width="25%">
								<col width="25%">
								<col width="25%">
								<col width="25%">
							</colgroup>
							<tr>
								<td id="refer_emp1_1">&nbsp;</td>
								<td id="refer_emp1_2">&nbsp;</td>
								<td id="refer_emp2_1">&nbsp;</td>
								<td id="refer_emp2_2">&nbsp;</td>
							</tr>
							<tr>
								<td id="refer_emp3_1">&nbsp;</td>
								<td id="refer_emp3_2">&nbsp;</td>
								<td id="refer_emp4_1">&nbsp;</td>
								<td id="refer_emp4_2">&nbsp;</td>
							</tr>
							<tr>
								<td id="refer_emp5_1">&nbsp;</td>
								<td id="refer_emp5_2">&nbsp;</td>
								<td id="refer_emp6_1">&nbsp;</td>
								<td id="refer_emp6_2">&nbsp;</td>
							</tr>
							<tr>
								<td id="refer_emp7_1">&nbsp;</td>
								<td id="refer_emp7_2">&nbsp;</td>
								<td id="refer_emp8_1">&nbsp;</td>
								<td id="refer_emp8_2">&nbsp;</td>
							</tr>
						</table>
					</div>
				</div>
			</div>
			<div class="fl" style="width:58%;">        
				<h2>합의 및 수신부서 결재</h2>
				<div class="table_type3">
					<table id="lineTable2">
						<colgroup>
							<col width="16%">
							<col width="16%">
							<col width="16%">
			 				<col width="16%">
							<col width="16%">
							<col width="16%">
						</colgroup>
						<tr>
							<th class="al"></th>
							<th class="al"></th>
							<th class="al"></th>
							<th class="al"></th>
							<th class="al"></th>
							<th class="al"></th>
						</tr>
						<tr class="time">
							<td></td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
						</tr>
						<tr>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
						</tr>
					</table>
					<span class="b"></span>
				</div>
			</div>
			
			<!--                     
			<div class="frr" style="width:38%;">        
			      <h2>배포</h2>
			      <div class="table_type4">
					<table id="referTable_sub">
						<colgroup>
							<col width="25%">
							<col width="25%">
							<col width="25%">
							<col width="25%">
						</colgroup>
						<tr>
						    <td id="refer_emp1_1">&nbsp;</td>
						    <td id="refer_emp1_2">&nbsp;</td>
						    <td id="refer_emp2_1">&nbsp;</td>
						    <td id="refer_emp2_2">&nbsp;</td>
						</tr>
						<tr>
						    <td id="refer_emp3_1">&nbsp;</td>
						    <td id="refer_emp3_2">&nbsp;</td>
						    <td id="refer_emp4_1">&nbsp;</td>
						    <td id="refer_emp4_2">&nbsp;</td>
						</tr>
						<tr>
						    <td id="refer_emp5_1">&nbsp;</td>
						    <td id="refer_emp5_2">&nbsp;</td>
						    <td id="refer_emp6_1">&nbsp;</td>
						    <td id="refer_emp6_2">&nbsp;</td>
						</tr>
						<tr>
						    <td id="refer_emp7_1">&nbsp;</td>
						    <td id="refer_emp7_2">&nbsp;</td>
						    <td id="refer_emp8_1">&nbsp;</td>
						    <td id="refer_emp8_2">&nbsp;</td>
						</tr>
					</table>
			      </div>
			</div> -->
		</div>
                
                <script type="text/javascript">
                function doOpenComment() { 
                		$(".reply2").show();
                }
                
                </script>
                <div  id="commentDiv"> 
               
                
              <div class="slide"  ><a href="javascript:doOpenComment();"><em class="open">결재의견 열기</em><em style="display:none;" class="close">결재의견 닫기</em></a></div>
              <div class="section">
                    <h2>결재의견 <span>[<%=commentList != null ? commentList.size() : "0" %>]</span></h2>
                    <div class="reply" id="commentDiv_2">
                    	<dl>
                        <dt><%=user.getDept_nm() %> [ <%=BaseCodeUtil.getName(request, StringUtil.normalizeNull(mm.get("high_bc")))%> ] <span><%=user.getNm() %></span></dt>
                        <dd><textarea style="resize: none;height:100px;font-size:12px;" name="epsdsc" id="epsdsc"></textarea><!-- <a href="#a">입력</a>--></dd>
                        </dl>
                        <span></span>
                    </div>
                    <div class="reply2" id="slide" style="display:none;">
                    	<% 
                    	if (commentList != null) { 
                    		for (Object o : commentList) { 
                    			HashMap<String, Object> cc = (HashMap<String, Object>)o;
                    	%>
                        <div>
                            <strong><%=StringUtil.normalizeNull(cc.get("dept_nm")) %><br/><%=StringUtil.normalizeNull(cc.get("emp_nm")) %> [ <%=StringUtil.normalizeNull(cc.get("high_nm")) %> ] </strong><%=StringUtil.normalizeNull(cc.get("dsc")).replace("\r\n","<br/>") %><em> <%=StringUtil.normalizeNull(cc.get("apr_dt")).substring(0, 16) %></em>
                            <p><a href="#a"><img src="/images/btn_del.gif" alt="삭제"></a> | <a href="#a"><img src="/images/btn_write2.gif" alt="쓰기"></a></p>
                        </div>
                        <%
                        	}
                        }
                        %>
                        <span></span>
                    </div>
                    <ul class="btns">
                    <li class="right" id="btn_typeAll" >
                    	<% if (!isEnd && isConfirm) {  %>
                    	<a href="javascript:doAction('C');" class="btn_type5">결 재</a>
                    	<a href="javascript:doAction('R');" class="btn_type6">반 려</a>
                    	<a href="javascript:doAction('L');" class="btn_type7">보 류</a></li>
                    	<% }  %>
	                    </ul>
	                </div>
	                </div>
				</div>
			<!-- ---------------------------------------- -->
				 <div class="line"></div>
				<div id="section">
            	<div class="section">
                
                    <ul class="btns">
                    <li class="left">
                    
                    <% if (!"1".equals(ccnt)) { %>
                    <a href="javascript:openLine();" class="btn_type1"><span></span><img src="/images/ico_left3.png">결재라인</a></li>
                    <% }  %>
                    
                    <li class="right">
                    
                    <!--이병운 20140418 버튼 숨김-->
                    <% if ("".equals(list_type)) { %>
	                    <% if (!"1".equals(ccnt)) { %>
	                    	<a href="javascript:doApply();" class="btn_type2" ><span></span>결재상신</a>
	                    <% } else if (!"1".equals(ccnt)) { %>
	                    	<a href="javascript:doCancel();" class="btn_type2"><span></span>결재취소</a>
	                    <% }  %>
                    
                    
                    <% } %>
                    
                    
                    
                    <!--이병운 2014-04-08 상신 취소한다   -->
                    <% if ("001".equals(All_Modify)) { %>
                    
	                    	<!--이병운 20140418 버튼 숨김-->
	                    	<!-- 20140708 자신결재함/보낸결재함에서 미결재일경우에만 상신수정,상신삭제 버튼 나옴-->
	                   <% if ("N".equals(String.valueOf(master.get("apr_stat"))) && "C".equals(String.valueOf(master.get("eps_stat")))) { %>
	                   
	                    <% if ("".equals(list_type) || "S".equals(list_type)) { %>
	                        <% if ("1".equals(ccnt)) { %><a href="javascript:doModify();" class="btn_type2"><span></span>상신수정</a><% } %> 
		                    <% if ("1".equals(ccnt)) { %><a href="javascript:doReturn();" class="btn_type2"><span></span>상신삭제</a><% } %>
	                    <% } %>
	                    
	                    <% } %>
	                <% } %>
                    <% if (!"1".equals(ccnt)) { %><a href="javascript:doSubmit();" class="btn_type2"><span></span>저장</a><% } %>
                    <% if (!"1".equals(ccnt) && !"P".equals(list_type)) { %><a href="javascript:doDelete();" class="btn_type3"><span></span>삭제</a><% } %>
                    <% if ("1".equals(ccnt)) { %>
                    
                    	<% if ("".equals(list_type)) { %>
                    		<a href="event_list.jsp" class="btn_type2"><span></span>목록</a>
                    	<% }else { 
                    		
                    		if("Z".equals(list_type)){
                    			%>
                    			<a href="reference.jsp" class="btn_type2"><span></span>목록</a>
                    		
                    		<!-- 이병운 배포반영 -->
                    		<% }else if("B".equals(list_type)){ %>
                    			
                    			<a href="reference_plan.jsp" class="btn_type2"><span></span>목록</a>
                    			
                    		<%
                    		}else if("Y".equals(list_type)){
                    			%>
                    			
                    			   <% if ("N".equals(String.valueOf(master.get("apr_stat"))) && "C".equals(String.valueOf(master.get("eps_stat")))) { %><a href="receive.jsp?Stat_sub=X" class="btn_type2"><span></span>목록</a>	<% } %> 
                    			    <% if ("Y".equals(String.valueOf(master.get("apr_stat"))) && "C".equals(String.valueOf(master.get("eps_stat")))) { %><a href="receive.jsp?Stat_sub=C" class="btn_type2"><span></span>목록</a>	<% } %>
		                           	<% if ("R".equals(String.valueOf(master.get("eps_stat")))) { %><a href="receive.jsp?Stat_sub=R" class="btn_type2"><span></span>목록</a>	<% } %>
		                           	<% if ("F".equals(String.valueOf(master.get("eps_stat")))) { %><a href="receive.jsp?Stat_sub=F" class="btn_type2"><span></span>목록</a>	<% } %>
		                           	<% if ("L".equals(String.valueOf(master.get("eps_stat")))) { %><a href="receive.jsp?Stat_sub=L" class="btn_type2"><span></span>목록</a>	<% } %>
                        		<!-- <a href="receive.jsp" class="btn_type2"><span></span>목록</a> -->
                        		<%
                    		}else{
                    			%>
                    			
                    				<% if ("C".equals(String.valueOf(master.get("eps_stat")))) { %><a href="send.jsp?Stat_sub=C" class="btn_type2"><span></span>목록</a>	<% } %>
		                           	<% if ("R".equals(String.valueOf(master.get("eps_stat")))) { %><a href="send.jsp?Stat_sub=R" class="btn_type2"><span></span>목록</a>	<% } %>
		                           	<% if ("F".equals(String.valueOf(master.get("eps_stat")))) { %><a href="send.jsp?Stat_sub=F" class="btn_type2"><span></span>목록</a>	<% } %>
		                           	<% if ("L".equals(String.valueOf(master.get("eps_stat")))) { %><a href="send.jsp?Stat_sub=L" class="btn_type2"><span></span>목록</a>	<% } %>
                    			<!-- <a href="send.jsp" class="btn_type2"><span></span>목록</a> -->
                    			<%
                    		}
                    	} %>
                    	
                    <% } %>
                    
                    </li>
                    </ul>
                    <div class="line"></div>
                   </div> 
                   
                   </div>
                   </div>
				
				
			</form>
        </div>
<!--  본문영역 -->
   
</body>
</html>




---===---===---===---===---===---> AI 답변 :





```jsp
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=Edge">

    <!-- jQuery and AJAX upload plugin -->
    <script src="/js/jquery.js" type="text/javascript"></script>
    <script src="/js/ajaxupload.js" type="text/javascript"></script>

    <script type="text/javascript">
    jQuery(function($) {
        $('#uploadA').ajaxUpload({
            url: "/bbs/upload.jsp",
            name: "files",
            onSubmit: function() {
                // 업로드 전 처리 (필요 시)
            },
            onComplete: function(data) {
                var files = $.parseJSON(data);
                for (var i = 0; i < files.length; i++) {
                    var f = files[i];
                    $("#fileList").append(
                        '<li>' +
                            '<input type="text" name="files" filesize="' + f.filesize + '" value="' + f.originalFilename + '" readonly>' +
                            '<a href="javascript:deletetest(\'' + f.filename + '\', \'file' + i + '\');">' +
                                '<img src="/images/btn_del.gif" alt="삭제">' +
                            '</a>' +
                            '<input type="hidden" name="filename" id="file' + i + '" value="' + f.filename + '">' +
                            '<input type="hidden" name="originalFilename" value="' + f.originalFilename + '">' +
                            '<input type="hidden" name="filesizes" value="' + f.filesize + '">' +
                        '</li>'
                    );
                }
            }
        });
    });

    function deletetest(filename, elementId) {
        $.ajax({
            dataType: "json",
            url: "/bbs/deleteFile.jsp",
            data: { file: encodeURI(filename, "UTF-8") },
            success: function(resp) {
                if (resp.result === 'true') {
                    alert(resp.txt);
                    $('#' + elementId).parent().remove();
                }
            }
        });
    }
    </script>
</head>
<body>
    <div class="box1">
        <h2>첨부파일</h2>
        <p>
            10개까지 가능하며 파일 크기는 20MB 이하입니다.
            <a href="javascript:void(0);" id="uploadA" class="file">+ 파일추가</a>
        </p>
        <ol id="fileList">
            <!-- 업로드된 파일 목록이 여기에 추가됩니다 -->
        </ol>
    </div>
</body>
</html>
```




=================================> AI에 질문 :


여기서 첨부파일 용량 제한에 대한 정보를 얻을 수 없지?


---===---===---===---===---===---> AI 답변 :




맞습니다. 지금 화면(자바스크립트)에는 “20MB 이하”라는 안내 문구만 있을 뿐, 실제로 허용된 최대 용량이 얼마인지 서버에서 받아오거나 클라이언트에서 검증하는 로직은 없습니다.
파일 업로드 처리는 전적으로 `/bbs/upload.jsp`(서버) 쪽에서 이뤄지기 때문에, 거기서 설정된 최대 허용 크기를 봐야 정확한 제한을 알 수 있어요.

만약 클라이언트에서 미리 용량을 체크하고 싶다면, HTML5 File API를 이용해 `onSubmit` 직전에 확인하는 식으로 코드를 추가할 수 있습니다. 예를 들어:

```javascript
$('#uploadA').ajaxUpload({
  url: "/bbs/upload.jsp",
  name: "files",
  onSubmit: function(file, extension) {
    // file.size는 바이트 단위
    if (file.size > 20 * 1024 * 1024) {
      alert('업로드 가능한 최대 용량은 20MB입니다.');
      return false; // 업로드 중단
    }
  },
  onComplete: function(data) { … }
});
```

이렇게 하면 “20MB” 제한을 클라이언트에서도 사전에 검사할 수 있습니다. 서버쪽 설정은 `/bbs/upload.jsp`나 해당 서블릿/컨트롤러, 또는 톰캣 같은 웹서버 설정을 확인해 보세요.





=================================> AI에 질문 :


upload.jsp 파일은 아래와 같아서 용량 제한에 대한 내용을 알 수 없을거 같은데. 혹시 내가 무엇을 제공해 주면 알 수 있을지 파악할 수 있어?

<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="com.em.http.Transaction"%>
<%@ page import="emportal.model.User"%>
<%
	Transaction tr = new Transaction(pageContext);

	String filename = tr.req.getParameter("files_UPLOAD");
	String filesize = tr.req.getParameter("files_SIZE");
	String originalFilename = tr.req.getParameter("files");

	String[] originalFilenameArray = originalFilename.split(";");
%>[<%
	for (int i = 0; i < originalFilenameArray.length; i++) {
%>

{"filename" : "<%=filename.split(";")[i]%>","filesize" : "<%=filesize.split(";")[i]%>","originalFilename" : "<%=originalFilenameArray[i]%>"}
<% if(i + 1< originalFilenameArray.length){ %>
,
<% }%>
<% } %>

]




---===---===---===---===---===---> AI 답변 :




JSP 쪽 코드만으로는 업로드 용량 제한이 전혀 드러나지 않아요. 용량 제한은 서버 쪽에서 Multipart 처리 라이브러리나 서블릿 설정, 혹은 톰캣-사이드 설정 등에 숨어 있습니다. 다음 중 하나를 공유해 주시면 어디에 제한이 걸려 있는지 파악하는 데 도움이 됩니다:

1. **`com.em.http.Transaction` 클래스**
   이 클래스가 내부에서 Apache Commons FileUpload 같은 라이브러리를 쓰고 있다면, `DiskFileItemFactory` 나 `ServletFileUpload` 생성 부분의 설정(`setSizeThreshold`, `setFileSizeMax`, `setSizeMax` 등)을 확인해야 합니다.

2. **`web.xml` 또는 어노테이션 기반의 Multipart 설정**
   만약 Servlet 3.0 이상 MultipartConfig를 사용 중이라면, 해당 `<multipart-config>` 섹션(또는 `@MultipartConfig`)에 `maxFileSize`/`maxRequestSize` 값이 지정되어 있을 수 있습니다.

3. **서버(Tomcat 등) 설정**
   Tomcat 사용 시 `<Connector>` 의 `maxPostSize`(기본 2MB) 나, Spring Boot 사용 시 `spring.servlet.multipart.max-file-size` 같은 프로퍼티가 용량 제한을 가합니다.

4. **프로젝트 설정 파일**
   `application.properties`, `application.yml`, 혹은 별도의 업로드 관련 프로퍼티 파일이 있을 수 있습니다.

——
위 항목 중 하나를 보내 주시면, 그 설정값을 분석해서 실제 허용 용량이 얼마인지, 혹은 어디서 조절해야 하는지 정확히 알려드릴 수 있습니다.





=================================> AI에 질문 :


처음부터 다시 물어볼게. 이 사이트 구조 및 흐름을 알려면 내가 무엇을 줘야할까? 최소한의 것만 요청해줘


---===---===---===---===---===---> AI 답변 :




사이트 전반의 구조와 흐름을 파악하려면 최소한 아래 세 가지 정보가 필요합니다:

1. **`web.xml` (또는 서블릿 매핑 설정)**

   * 어떤 URL 패턴이 어떤 JSP/서블릿으로 연결되는지 알 수 있어야 합니다.

2. **`com.em.http.Transaction` 클래스 소스**

   * HTTP 요청 처리, DB 트랜잭션, 파일 업로드 로직 등이 이 안에 숨어 있을 가능성이 큽니다.

3. **프로젝트 폴더(패키지) 구조**

   * `src/` 아래에 어떤 JSP, 서블릿, 라이브러리, 유틸 클래스들이 있는지 대략적인 디렉터리 트리 형태로 알려주시면 좋습니다.

이 세 가지만 있으면

* URL → JSP/서블릿 매핑
* 요청 처리 흐름 (Transaction 내부)
* 파일·DB·UI 모듈 간 관계

을 훨씬 쉽게 그려낼 수 있습니다. 위 세 가지만 공유 부탁드려요!





=================================> AI에 질문 :



여긴 파일 첨부가 안되. 파일 사이즈가 큰데. 일단 하나씩 보낼게.. web.xml 이야.

<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
 Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->

<web-app xmlns="http://java.sun.com/xml/ns/javaee"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"
   version="2.5">

  <display-name>Welcome to Tomcat</display-name>
  <description>
     Welcome to Tomcat
  </description>

   <session-config>  
        <session-timeout>300</session-timeout> 
        <location>/error_msg.html</location>  
    </session-config>

    <!-- 500������ ó�� ������ ���� -->  
    <error-page>  
        <error-code>500</error-code>  
        <location>/error_msg_null.html</location>  
    </error-page>  

    <!-- 404������ ó�� ������ ���� -->  
    <error-page>  
        <error-code>404</error-code>  
        <location>/error_msg_404.html</location>  
    </error-page>  
  
    <!-- NullpointException�߻��� ó�� ������ ���� -->  
    <error-page>  
        <exception-type>java.lang.NullPointerException</exception-type>  
        <location>/error_msg.html</location>  
    </error-page>  

<resource-ref>
    <description>oracle Datasource</description>
    <res-ref-name>jdbc/epportal</res-ref-name>
    <res-type>javax.sql.DataSource</res-type>
    <res-auth>Container</res-auth>
  </resource-ref>
  
  
  
<!-- UbiGateway Servlet Start -->
	<servlet>
		<servlet-name>UbiForm</servlet-name>
		<servlet-class>com.ubidcs.report.gateway.UbiForm</servlet-class>
	</servlet>
	<servlet>
		<servlet-name>UbiData</servlet-name>
		<servlet-class>com.ubidcs.report.gateway.UbiData</servlet-class>
	</servlet>
	<servlet>
		<servlet-name>UbiAdmin</servlet-name>
		<servlet-class>com.ubidcs.report.gateway.UbiAdmin</servlet-class>
	</servlet>
	<!-- Servlet for UbiDaemon -->
	<servlet>
		<servlet-name>UbiGateway</servlet-name>
		<servlet-class>com.ubidcs.report.gateway.UbiGateway</servlet-class>
	</servlet>

	<servlet-mapping>
		<servlet-name>UbiForm</servlet-name>
		<url-pattern>/UbiForm</url-pattern>
	</servlet-mapping>	
	<servlet-mapping>
		<servlet-name>UbiData</servlet-name>
		<url-pattern>/UbiData</url-pattern>
	</servlet-mapping>	
	<servlet-mapping>
		<servlet-name>UbiAdmin</servlet-name>
		<url-pattern>/UbiAdmin</url-pattern>
	</servlet-mapping>	
	<servlet-mapping>
		<servlet-name>UbiGateway</servlet-name>
		<url-pattern>/UbiGateway</url-pattern>
	</servlet-mapping>	

<!-- UbiGateway Servlet End -->
  

  

  
  </web-app>


---===---===---===---===---===---> AI 답변 :




web.xml 잘 받았습니다.
다음으로는 파일 업로드 및 요청 처리 흐름이 구현된 **`com.em.http.Transaction` 클래스** 소스를 보내주시면, 전체 구조와 흐름 파악에 큰 도움이 됩니다.
(가능하시다면 해당 클래스가 위치한 패키지 구조만 간략히 보여주셔도 좋습니다.)





=================================> AI에 질문 :


두번째는 tr.jsp 인데... 이것을 확인해보고 클래스가 필요하면 보내줄게. 

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.em.http.Transaction"%>
<%@ page import="emportal.model.*"%>
<%@ page import="java.util.*, java.text.*"%>
<%@ page import="com.em.util.*"%>

<%
	response.setContentType("application/json");
	
	Transaction tr = new Transaction(pageContext);
	
	User user = (User)session.getAttribute("user");
	String Chexp_no = tr.req.getParameter("exp_no");
	String eps_type = tr.req.getParameter("eps_type");
	String list_type = tr.req.getParameter("list_type");
	String Returnexp_no = "";
	Returnexp_no = tr.req.getParameter("Returnexp_no");
	
	String  exp_no  = "";
	String	id = "";
	String admin_no = tr.req.getParameter("admin_no");
	String outtest = "";
	String[] files = request.getParameterValues("filename");
	String[] filesizes = tr.req.getParameterValues("filesizes");

	String[] originalFilename = request.getParameterValues("originalFilename");
	
	String title = tr.req.getParameter("title");
	String content = tr.req.getParameter("contents");
	String line_main_sq = tr.req.getParameter("line_main_sq");
	
	String exp_dt = tr.req.getParameter("exp_dt");
	String[] relate_exp_no = tr.req.getParameterValues("relate_exp_no");
	String[] tax_dt_list = tr.req.getParameterValues("tax_dt");
	String[] tax_bc = tr.req.getParameterValues("tax_bc");
	String[] exp_cd = tr.req.getParameterValues("exp_cd");
	String[] tot_amt = tr.req.getParameterValues("tot_amt");
	String[] amt = tr.req.getParameterValues("amt");
	String[] vat = tr.req.getParameterValues("vat");
	String[] dept_cd2 = tr.req.getParameterValues("dept_cd2");
	String[] cust_cd = tr.req.getParameterValues("cust_cd");
	String[] cust_nm = tr.req.getParameterValues("cust_nm");
	String[] itm_dept_cd = tr.req.getParameterValues("itm_dept_cd");
	String[] Appear_dt = tr.req.getParameterValues("Appear_dt");  
	String[] Appear_to_dt = tr.req.getParameterValues("Appear_to_dt");  
	
	String[] appday = tr.req.getParameterValues("appday");  
	String[] appemp_nm = tr.req.getParameterValues("appemp_nm");  
	String[] appsche_amt = tr.req.getParameterValues("appsche_amt");
	String[] appemp_no = tr.req.getParameterValues("appemp_no");
	
	
	
	//프로젝트 
	String[] pro_cd= tr.req.getParameterValues("pro_cd");
	
	//cost center 
	String[] man_cd= tr.req.getParameterValues("man_cd");
	
	//대우 지출결의서(거래처,사원) 지급요청일자 
	String[] pay_due_dt= tr.req.getParameterValues("pay_due_dt");
	
	//대우 지출결의서(거래처)     순번 선박 항차 
	String[] row_ty= tr.req.getParameterValues("row_ty");
	String[] cd_vessel= tr.req.getParameterValues("cd_vessel");
	String[] iss_bc = tr.req.getParameterValues("iss_bc");
	
	//대우 지출결의서  환율
	String[] cury_bc= tr.req.getParameterValues("cury_bc");
	String[] card_yn= tr.req.getParameterValues("card_yn");
	
	//대우 지출결의서(사원) 협조문 첨부(시내교통비)
	String[] trans_doc= tr.req.getParameterValues("trans_doc");
	
	/*지결 중복일때  사원*/ /*성진포머 출장보고서*/
	String[] emp_tax_dt = tr.req.getParameterValues("emp_tax_dt");
	String[] emp_tax_bc = tr.req.getParameterValues("emp_tax_bc");
	String[] emp_exp_cd = tr.req.getParameterValues("emp_exp_cd");
	String[] emp_tot_amt = tr.req.getParameterValues("emp_tot_amt");
	String[] emp_amt = tr.req.getParameterValues("emp_amt");
	String[] emp_vat = tr.req.getParameterValues("emp_vat");
	String[] emp_dept_cd2 = tr.req.getParameterValues("emp_dept_cd2");
	String[] emp_man_cd = tr.req.getParameterValues("emp_man_cd");
	String[] emp_pro_cd = tr.req.getParameterValues("emp_pro_cd");
	//대우 추가
	String[] emp_cust_cd = tr.req.getParameterValues("emp_cust_cd");
	String[] emp_cury_bc= tr.req.getParameterValues("emp_cury_bc");
	String[] emp_pay_due_dt= tr.req.getParameterValues("emp_pay_due_dt");
	String[] emp_pay_type= tr.req.getParameterValues("emp_pay_type");
	
	String[] payemp_no = tr.req.getParameterValues("payemp_no");
	
	// 출장 정산 계정별 요약 카테고리 구분
	String[] category_gubun = tr.req.getParameterValues("category_gubun");
	String[] emp_category_gubun = tr.req.getParameterValues("emp_category_gubun");
	
	HashMap<String, Object> paramPaytype = new HashMap<String, Object>();
	
	// 여비지급 신청서
	String[] costemp_no = tr.req.getParameterValues("costemp_no");
	String[] costemp_nm = tr.req.getParameterValues("costemp_nm");
	String[] traffic_price  = tr.req.getParameterValues("traffic_price");
	String[] traffic_dcnt   = tr.req.getParameterValues("traffic_dcnt");
	String[] traffic_tot    = tr.req.getParameterValues("traffic_tot");
	String[] lodgment_price = tr.req.getParameterValues("lodgment_price");
	String[] lodgment_dcnt  = tr.req.getParameterValues("lodgment_dcnt");
	String[] lodgment_tot   = tr.req.getParameterValues("lodgment_tot");
	String[] food_price     = tr.req.getParameterValues("food_price");
	String[] food_dcnt      = tr.req.getParameterValues("food_dcnt");
	String[] food_tot       = tr.req.getParameterValues("food_tot");
	String[] costtot_amt        = tr.req.getParameterValues("costtot_amt");
	String[] card_no   = tr.req.getParameterValues("card_no");
	String[] dsc = request.getParameterValues("dsc");
	String[] emp_dsc = request.getParameterValues("emp_dsc");
		
	String[] acday_price = tr.req.getParameterValues("acday_price");
	String[] acday_dcnt  = tr.req.getParameterValues("acday_dcnt");
	String[] acday_tot   = tr.req.getParameterValues("acday_tot");
	String[] reverve     = tr.req.getParameterValues("reverve");

	//참조 
	String[] refer_emp_no = tr.req.getParameterValues("refer_emp_no");
	
	//배포 
	String[] refer_emp_no_sub = tr.req.getParameterValues("refer_emp_no_sub");
	
	HashMap<String, Object> params_sub = new HashMap<String, Object>();
	HashMap<String, Object> params_sub2 = new HashMap<String, Object>();
	HashMap<String, Object> params_sub3 = new HashMap<String, Object>();
	HashMap<String, Object> params_sub4 = new HashMap<String, Object>();
	HashMap<String, Object> params_sub5 = new HashMap<String, Object>();
	
	String[] half_chk = tr.req.getParameterValues("half_chk"); 
	
	//선수단일정
	String[] time = tr.req.getParameterValues("time"); 
	
	//불참자현황
	String[] passarea1 = tr.req.getParameterValues("passarea1");
	
	//차량정비 의뢰서
	String[] carma_no = tr.req.getParameterValues("carma_no");  

	//물품청구서
	String[] article_no = tr.req.getParameterValues("article_no");
	
	//휴가 신청자        //휴일근무일괄신청
	String[] rec_emp_no = tr.req.getParameterValues("rec_emp_no");

	//휴가계
	String[] base_cd = tr.req.getParameterValues("base_cd");
	String[] hol_fr_dt = tr.req.getParameterValues("hol_fr_dt");
	String[] fr_half_cd = tr.req.getParameterValues("fr_half_cd");
	String[] hol_to_dt = tr.req.getParameterValues("hol_to_dt");
	String[] to_half_cd = tr.req.getParameterValues("to_half_cd");
	String[] All_cnt = tr.req.getParameterValues("All_cnt");

	String[] STRACKNO = tr.req.getParameterValues("STRACKNO");
	String[] STRNONESEQS = tr.req.getParameterValues("STRNONESEQS");
	String[] STRBUYDATE = tr.req.getParameterValues("STRBUYDATE");
	//대우추가
	String[] BANK_CD = tr.req.getParameterValues("BANK_CD");
	
	// 휴일근무 일괄신청 배열 
	String[] holiday_start = tr.req.getParameterValues("holiday_start");
	String[] start_hh = tr.req.getParameterValues("start_hh");
	String[] start_mm = tr.req.getParameterValues("start_mm");
	String[] holiday_end = tr.req.getParameterValues("holiday_end");
	String[] end_hh = tr.req.getParameterValues("end_hh");
	String[] end_mm = tr.req.getParameterValues("end_mm");
	String[] work_type = tr.req.getParameterValues("work_type");
	String[] work_typeYN = tr.req.getParameterValues("work_typeYN");

	//결의일자
	String account_dt = tr.req.getParameter("account_dt");
	//지급요청일자 20250226 gmlee
	String p_pay_due_dt = tr.req.getParameter("p_pay_due_dt"); 
	//대우 지출결의서 거래처 사업장 추가
	String bs_cd = tr.req.getParameter("bs_cd");
	
	//json개수
	String dodelete_cnt= StringUtil.normalizeNull( tr.req.getParameter("dodelete_cnt"));
	
	/*미쯔비시=================================================================================================================================*/
			
	//교통비 사용내역 지급 신청서 
	String[] trans_dt 		= tr.req.getParameterValues("trans_dt");
	String[] trans_fee 		= tr.req.getParameterValues("trans_fee");
	String[] toll 			= tr.req.getParameterValues("toll");
	String[] parking_fee 	= tr.req.getParameterValues("parking_fee");
	String[] trans_amt 		= tr.req.getParameterValues("trans_amt");

	/* 배차신청 운행일시  	 */  /*배차사용보고서*/
	String[] form_drive_dt 	= tr.req.getParameterValues("form_drive_dt");
	String[] to_drive_dt 	= tr.req.getParameterValues("to_drive_dt");
	
	String[] drive_dt 		= tr.req.getParameterValues("drive_dt");
	
	String[] idex_seq = tr.req.getParameterValues("idex_seq");
	String[] car_gbn_car = tr.req.getParameterValues("car_gbn");
	String mrec_emp_no = tr.req.getParameter("mrec_emp_no");
	String drive_reason= tr.req.getParameter("drive_reason");
	//String dodelete_cnt= tr.req.getParameter("dodelete_cnt"); 위로옮김
	
	/* 시간외근무신청서 */
	String[] Request_work_dt = tr.req.getParameterValues("work_dt");
	String[] Request_emp_no = tr.req.getParameterValues("emp_no");
	String[] Request_Dwork_type = tr.req.getParameterValues("Dwork_type");
	
	/* 시간외수당신청서 */
	String[] allowance = tr.req.getParameterValues("allowance");
	
	/* 시간외근무화인서 */
	String[] real_time_st = tr.req.getParameterValues("real_time_st");
	String[] real_time_ed = tr.req.getParameterValues("real_time_ed");
	String[] request_exp_no = tr.req.getParameterValues("request_exp_no");
	String[] request_exp_seq = tr.req.getParameterValues("request_exp_seq");
	String[] sel_index = tr.req.getParameterValues("sel_index");
	String[] p_dept_nm = tr.req.getParameterValues("p_dept_nm");
	
	/*숙박 신청서*/
	String[] lodge_pay = tr.req.getParameterValues("lodge_pay");
	String[] lodge_place = tr.req.getParameterValues("lodge_place");
	String[] lodge_dt = tr.req.getParameterValues("lodge_dt");
	String[] lodge_cnt = tr.req.getParameterValues("lodge_cnt");
	String[] lodge_tel = tr.req.getParameterValues("lodge_tel");
	String[] lodge_pay_cnt = tr.req.getParameterValues("lodge_pay_cnt");
	String[] lodge_amt = tr.req.getParameterValues("lodge_amt");
	
	//업무용차량유지비 지원 신청서
	String[] carcost_no 		= tr.req.getParameterValues("carcost_no");
	String[] outbusi_cnt 		= tr.req.getParameterValues("outbusi_cnt");
	
	//해외 출장 신청서 출장내용
	String[] schedule 			= tr.req.getParameterValues("schedule");

	//항공권발급신청서  출장자
	String[] air_emp_no 		= tr.req.getParameterValues("air_emp_no");

	//해외 출장 신청서 해외반출 화물, 제공기술 
	String[] AppearSkill = tr.req.getParameterValues("AppearSkill");
	String  dodelete_cnt1= tr.req.getParameter("dodelete_cnt1");
	
	// 출장 신청서  
	String[] pay_dt = tr.req.getParameterValues("pay_dt");
	String[] pay_cd = tr.req.getParameterValues("pay_cd");
	String[] pay_use = tr.req.getParameterValues("pay_use");
	String[] amount = tr.req.getParameterValues("amount");
	
	/* 해외 출장 추가  */
	String[] pay_currency = tr.req.getParameterValues("pay_currency");
	String[] pay_exch = tr.req.getParameterValues("pay_exch");	
	String[] pay_money = tr.req.getParameterValues("pay_money");
	
	//증명서, 법인서류 발급신청서 요청서류 
	String[] req_doc = tr.req.getParameterValues("req_doc");
	String[] req_cnt = tr.req.getParameterValues("req_cnt");
	String[] req_use = tr.req.getParameterValues("req_use");
// 	String[] req_sub = tr.req.getParameterValues("req_sub");

	//업무분장
	String[] main_cd = tr.req.getParameterValues("main_cd");
	String[] up_cd = tr.req.getParameterValues("up_cd");
	String[] sub_cd = tr.req.getParameterValues("sub_cd");
	String[] opening_dt = tr.req.getParameterValues("opening_dt");
	
	// 명함 
	String[] E_emp_no = tr.req.getParameterValues("E_emp_no");
	String[] E_emp_nm = tr.req.getParameterValues("E_emp_nm");
	
	/* String[] chinese = tr.req.getParameterValues("Chi_char"); */
	
	String[] dept_tel = tr.req.getParameterValues("dept_tel");
	String[] mobile = tr.req.getParameterValues("mobile");
	String[] fax = tr.req.getParameterValues("fax");
	/* String[] E_dept_nm = tr.req.getParameterValues("E_dept_nm");
	String[] E_high_nm = tr.req.getParameterValues("E_high_nm"); */
	String[] E_dept_tel = tr.req.getParameterValues("E_dept_tel");
	String[] E_mobile = tr.req.getParameterValues("E_mobile");
	String[] E_fax = tr.req.getParameterValues("E_fax");
	String[] pic_yn = tr.req.getParameterValues("pic_yn");
	
	/*교육신청  */
	String[] edure_dt 				= tr.req.getParameterValues("edure_dt");
	String[] edu_start_hh 			= tr.req.getParameterValues("edu_start_hh");
	String[] edu_end_hh 			= tr.req.getParameterValues("edu_end_hh");
	
	/*성진포머=================================================================================================================================*/
	//안전화 지급 요청서 신청자
	String[] sho_emp_no 		= tr.req.getParameterValues("sho_emp_no");
	String[] shoes_size 		= tr.req.getParameterValues("shoes_size");
	String[] shoes_note 		= tr.req.getParameterValues("shoes_note");
	String[] before_dt 			= tr.req.getParameterValues("before_dt");
	
	//유류비 사용내역 지급 신청서 
	String[] oil_dt 			= tr.req.getParameterValues("oil_dt");
	String[] move 				= tr.req.getParameterValues("move");
	
	//식수신청서
	String[] water_req_dt 		= tr.req.getParameterValues("water_req_dt");
	String[] water_emp_no 		= tr.req.getParameterValues("emp_no");
	String[] water_out_seq 		= tr.req.getParameterValues("out_seq");
	
	//교육계획보고서
	String[] edu_emp_no			= tr.req.getParameterValues("emp_no");
	String[] edu_sel 		    = tr.req.getParameterValues("edu_sel");
	String[] edu_start_dt 		= tr.req.getParameterValues("edu_start_dt");
	String[] edu_end_dt			= tr.req.getParameterValues("edu_end_dt");
	String[] edu_cost 			= tr.req.getParameterValues("edu_cost");
	
	//인사발령요청서
	String[] per_dt 			= tr.req.getParameterValues("per_dt");
	String[] per_emp_no 		= tr.req.getParameterValues("emp_no");
	String[] rank 				= tr.req.getParameterValues("rank");
	String[] duty 				= tr.req.getParameterValues("duty");
	String[] before_dept 		= tr.req.getParameterValues("before_dept");
	String[] after_dept 		= tr.req.getParameterValues("after_dept");
	
	//물품의뢰서
	String[] itm_bc 			= tr.req.getParameterValues("itm_bc");
	String[] itm_cd 			= tr.req.getParameterValues("itm_cd");
	String[] itm_up 			= tr.req.getParameterValues("up");
	String[] itm_cnt 			= tr.req.getParameterValues("itm_cnt");
	String[] amt_sum 			= tr.req.getParameterValues("amt_sum");
	
	//외주공정추진보고서
	String[] release_dt 		= tr.req.getParameterValues("release_dt");
	String[] warehouse_dt 		= tr.req.getParameterValues("warehouse_dt");
	// 인력계획서/충원요청서
	String[] position = tr.req.getParameterValues("position");
	
	//외주금형제작단가결정서
	String[] out_so_cost = tr.req.getParameterValues("out_so_cost");
	
	//일근태확인서 확인 룰퇴근시간
	String[] app_time_st = tr.req.getParameterValues("app_time_st");
	String[] app_time_ed = tr.req.getParameterValues("app_time_ed");
	String[] night_duty = tr.req.getParameterValues("Dnight_duty");
	

	//대우 신규 거래처 등록 435
	String[] p_acct_no = tr.req.getParameterValues("p_acct_no");
	String[] nat_cd = tr.req.getParameterValues("nat_cd");
	String[] cls_acct = tr.req.getParameterValues("cls_acct");
	String[] crcd = tr.req.getParameterValues("crcd");
	String[] bank_cd = tr.req.getParameterValues("bank_cd");
	String[] acct_no_list = tr.req.getParameterValues("acct_no");
	String[] acct_nm = tr.req.getParameterValues("acct_nm");
	String[] bas_yn = tr.req.getParameterValues("bas_yn");
	String[] del_yn = tr.req.getParameterValues("del_yn");
	String[] rmks = tr.req.getParameterValues("rmks");
	String[] abrd_acctno = tr.req.getParameterValues("abrd_acctno");
	String[] swift = tr.req.getParameterValues("swift");
	String[] bic = tr.req.getParameterValues("bic");
	String[] iban = tr.req.getParameterValues("iban");

	String[] p_minor_place_no = tr.req.getParameterValues("p_minor_place_no");
	String[] minor_place_no = tr.req.getParameterValues("minor_place_no");
	String[] minor_place_cust_nm = tr.req.getParameterValues("minor_place_cust_nm");
	
	String[] minor_place_biz_reg_no = tr.req.getParameterValues("minor_place_biz_reg_no");
	
	
	//대우 해외출장신청서	
	String[] applodge_cnt = tr.req.getParameterValues("applodge_cnt");
	String[] apparea = tr.req.getParameterValues("apparea");
	String[] currency = tr.req.getParameterValues("currency");
	
	//경조사비 및 경조휴가신청서 20250219 gmlee
	String[] fr_dt = tr.req.getParameterValues("fr_dt");
	String[] to_dt = tr.req.getParameterValues("to_dt");
	

	
 	if("".equals(account_dt))
	{
		account_dt =  ""; 
	}
	
	boolean result = false;

	HashMap<String, Object> params = new HashMap<String, Object>();
	HashMap<String, Object> params_carsh = new HashMap<String, Object>();
	
	// 시간외 근무신청서
	HashMap<String, Object> params_work = new HashMap<String, Object>();
	HashMap<String, Object> params2 = new HashMap<String, Object>();
	
	//종사업장
	HashMap<String, Object> params3 = new HashMap<String, Object>();
	
	
	HashMap<String, Object> params_emp = new HashMap<String, Object>();
	HashMap<String, Object> appeatparams2 = new HashMap<String, Object>();
	HashMap<String, Object> appeatparams3 = new HashMap<String, Object>();
	HashMap<String, Object> costparams3 = new HashMap<String, Object>();
	
	
	/* 예산통제 -------------------------------------------------*/
	
	HashMap<String, Object> paramBudAcc = new HashMap<String, Object>();
	HashMap<String, Object> budValue = new HashMap<String, Object>();
	
	//예산통제 걸렸을때 사용하는 인덱스
	String bud_return_indx = "";

	
	//대우 예산통제 [통제]
	boolean budChk = true; 
	//대우 예산통제 [경보]
	boolean budSav = true; 
		
	/* -------------------------------------------------------*/
	String Test = "0";
	String All_Modify = "001";
	
	//---------------------------------------------------------------
	HashMap<String, Object> lineparams = new HashMap<String, Object>();
	lineparams.put("exp_no", Chexp_no);
	lineparams.put("emp_no", user.getEmp_no());
	lineparams.put("line_bc", eps_type);
	lineparams.put("co_cd", user.getCo_cd());
	lineparams.put("main_sq", line_main_sq);

	//결재라인 체크 
	String lineChk= "";
	
	if("".equals(Chexp_no)){
		lineChk = "1";
	} else {
		lineChk =(String)tr.sql.selectObject("pay.selectLineChk", lineparams);
		System.out.println("  저장된 문서 결재라인체크  ---------  "+ lineChk);
	}
	try { 
		//결재상신 했을때 상신삭제체크 테스트 까지는 주속 
		//이병운 
		lineChk ="1";
		
		if("0".equals(lineChk))
		{
				result=false;
		}
		else
		{ 
				params.put("title", title);
				params.put("emp_no", user.getEmp_no());
				
				params.put("co_cd", user.getCo_cd());	
				params.put("div_cd", user.getDiv_cd());
				params.put("exp_id", user.getReg_id());
				params.put("dept_cd", user.getDept_cd());
				params.put("reg_id", user.getReg_id());
				params.put("main_sq", line_main_sq);
				params.put("content", content);
				params.put("eps_type", eps_type);
				params.put("exp_dt", exp_dt);
				params.put("acc_dt", account_dt);
				//대우 지출결의서 거래처 사업장 추가
				params.put("bs_cd", bs_cd);

				
				if("".equals(Returnexp_no))
				{

					params.put("Returnexp_no", "");
				}
				else
				{

					params.put("Returnexp_no", Returnexp_no);
				}

		//다음결재자 확인여부 
		All_Modify= (String)tr.sql.selectObject("pay.selectDecide", exp_no);	
		if ("001".equals(All_Modify)) 
		{
				Test = "1";

				if("".equals(Chexp_no))
				{
					//test 전표번호 
					//exp_no  = (String)tr.sql.selectObject("pay.AllselectDocId", user.getEmp_no());

					params.put("gbn", "001");
					tr.sql.insert("pay.insert", params);
					
					exp_no = (String)params.get("Pmyexp_no");
					params.put("exp_no", exp_no);
					
				}
				else
				{
					params.put("gbn", "002");
					exp_no = tr.req.getParameter("exp_no");
					params.put("exp_no", exp_no);
					tr.sql.insert("pay.insert", params);
					
				}

			/* 전표번호 생성이 안되면 저장 안되게 설정  */
			
			
				if(exp_no==null)
				{
					
					

					result = false;
					Test = "오류";
					
					System.out.println("없다");
					return;
				}
				
				
				
				Test = "2";
				tr.sql.delete("pay.deleteReferTemp", exp_no);
				
				tr.sql.delete("pay.deleteReferTemp_plan", exp_no);
				
				
				tr.sql.insert("pay.insertPaySq", params);
				tr.sql.delete("pay.deletePay5", exp_no);
		
				Test = "3";
				 
				if (refer_emp_no != null) { 
					for (String s : refer_emp_no) { 
						
						//if (!"".equals(s)) { 
							params.put("refer_emp_no", s);
							System.out.println("insertReferTemp=="+s);
							
							tr.sql.insert("pay.insertReferTemp", params);
						//}
					}
					
				}
				
				
				 
				
				int pal_cnt = 1;
				if (refer_emp_no_sub != null) { 
					for (String ss : refer_emp_no_sub) { 
						if (!"".equals(ss)) {
							params.put("exp_seq", pal_cnt);
							params.put("refer_emp_no", ss);
							
							System.out.println("insertReferTemp_plan=="+ss);
							
							
							tr.sql.insert("pay.insertReferTemp_plan", params);
							pal_cnt++;
						}
					}
				}
				
				
				//첨부파일 생성 
				int i = 0;				
				
				tr.sql.delete("pay.insertFileDel", exp_no);
				
				if (files != null) { 
		
					
					for (String file_nm : files) { 
						if (!"".equals(file_nm)) { 
							params.put("file_nm",	file_nm);
							params.put("file_size", filesizes[i]);
							params.put("file_nm_sub", originalFilename[i]);
							params.put("exp_seq", i+1);
							tr.sql.insert("pay.insertFile", params);
							i++;
							
						}
					}
				}
				
				if (relate_exp_no != null) { 
					for (String relate_doc : relate_exp_no) { 
						if (!"".equals(relate_doc)) { 
							params.put("relate_doc", relate_doc);
							tr.sql.insert("pay.insertRelateDoc", params);
						}
					}
				}

				System.out.println("  시작 ---------  ");
				
				if ("JJ100500".equals(eps_type)) {
		
					tr.sql.delete("pay.DeleteHolidayRequestInfo", params);
					
					if(base_cd != null)
					{
						for(int row = 0; row<base_cd.length; row++)
						{
							
							
							if(!"".equals(base_cd[row]))
							{
								params.put("exp_seq", (row+1));
								params.put("base_cd", base_cd[row]);
								params.put("fr_dt", hol_fr_dt[row]);
								params.put("to_dt", hol_to_dt[row]);
								params.put("All_cnt", All_cnt[row]);
								params.put("emp_no", tr.req.getParameter("rec_emp_no"));
								params.put("dsc", tr.req.getParameter("contents"));
								params.put("agency", tr.req.getParameter("agency"));
								tr.sql.insert("pay.insertHolidayRequestInfo", params);
								
								
							}
							
						}
						
					}
				} else if ("JJ100600".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("holiday_start",  StringUtil.replace(tr.req.getParameter("holiday_start"), "-", ""));
					params.put("start_hh", tr.req.getParameter("start_hh"));
					params.put("start_mm", tr.req.getParameter("start_mm"));
					params.put("holiday_end", StringUtil.replace(tr.req.getParameter("holiday_end"), "-", ""));
					params.put("end_hh", tr.req.getParameter("end_hh"));
					params.put("end_mm", tr.req.getParameter("end_mm"));
		
					params.put("app_time", tr.req.getParameter("app_time"));
					params.put("work_place", tr.req.getParameter("work_place"));
					params.put("work_type", tr.req.getParameter("work_type"));
					params.put("work_story", tr.req.getParameter("work_story"));
					params.put("name", tr.req.getParameter("name"));
					tr.sql.insert("pay.insertHolidayworkapp", params);
					
		
				} else if ("JJ100700".equals(eps_type)) {
					params.put("c_cd", tr.req.getParameter("c_cd"));
					params.put("purpose", tr.req.getParameter("purpose"));
					params.put("limit_amt", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("limit_amt"), "0"), ",", ""));
					params.put("clean_yn", tr.req.getParameter("clean_yn"));
					params.put("card_no", tr.req.getParameter("card_no"));
					params.put("content", tr.req.getParameter("content"));
					params.put("exp_no", exp_no);
					
					tr.sql.insert("pay.insertCoCard", params);
				
				
				} else if ("JJ100800".equals(eps_type)) {
					//params.put("emp_no",tr.req.getParameter("rec_emp_no"));
					//params.put("fel_cd", tr.req.getParameter("fel_cd"));
					//params.put("fel_nm", tr.req.getParameter("fel_nm"));
					//params.put("fel_hd", tr.req.getParameter("fel_hd"));
					//params.put("fel_mo", tr.req.getParameter("fel_mo"));
					//params.put("fel_fl", StringUtil.normalize(tr.req.getParameter("fel_fl")));
					//params.put("edate", tr.req.getParameter("edate"));
					//params.put("frdate", tr.req.getParameter("frdate"));
					//params.put("todate", tr.req.getParameter("todate"));
					//params.put("frtm", tr.req.getParameter("frtm"));
					//params.put("totm", tr.req.getParameter("totm"));
					//params.put("place", tr.req.getParameter("place"));
					//params.put("tel", tr.req.getParameter("tel"));
					//params.put("dsc2", tr.req.getParameter("remark"));
					/* 화환 비고   미쯔비시 추가 */
					//params.put("fel_remark", tr.req.getParameter("fel_remark"));
					/* 대우 추가  경조휴가시작일, 종료일 */
					//params.put("fr_dt", tr.req.getParameter("fr_dt"));
					//params.put("to_dt", tr.req.getParameter("to_dt"));
					
					//tr.sql.insert("pay.insertEvent", params);
					
					//20250219 gmlee 변경
					if(fr_dt != null)
					{
						for(int row = 0; row<fr_dt.length; row++)
						{													
							if(!"".equals(fr_dt[row]))
							{
								params.put("emp_no",tr.req.getParameter("rec_emp_no"));
								params.put("fel_cd", tr.req.getParameter("fel_cd"));
								params.put("fel_nm", tr.req.getParameter("fel_nm"));
								params.put("fel_hd", tr.req.getParameter("fel_hd"));
								params.put("fel_mo", tr.req.getParameter("fel_mo"));
								params.put("fel_fl", StringUtil.normalize(tr.req.getParameter("fel_fl")));
								params.put("edate", tr.req.getParameter("edate"));
								params.put("frdate", tr.req.getParameter("frdate"));
								params.put("todate", tr.req.getParameter("todate"));
								params.put("frtm", tr.req.getParameter("frtm"));
								params.put("totm", tr.req.getParameter("totm"));
								params.put("place", tr.req.getParameter("place"));
								params.put("tel", tr.req.getParameter("tel"));
								params.put("dsc2", tr.req.getParameter("remark"));
								/* 화환 비고   미쯔비시 추가 */
								params.put("fel_remark", tr.req.getParameter("fel_remark"));
								/* 대우 추가  경조휴가시작일, 종료일 */
								params.put("fr_dt", fr_dt[row]);
								params.put("to_dt", to_dt[row]);
								
								tr.sql.insert("pay.insertEvent", params);
								
								
							}							
						}						
					}
					
				
				} else if ("JJ100810".equals(eps_type)) {
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("relation_cd", tr.req.getParameter("relation_cd"));
					params.put("name", tr.req.getParameter("hos_name"));
					params.put("hospital_nm", tr.req.getParameter("hospital_nm"));
					params.put("frdate", tr.req.getParameter("frdate"));
					params.put("todate", tr.req.getParameter("todate"));
					params.put("amt", tr.req.getParameter("hos_amt"));
					params.put("mix_amt", tr.req.getParameter("mix_amt"));
					
					params.put("yeardate", tr.req.getParameter("yeardate"));
					
					tr.sql.insert("pay.insertHospital", params);
				
				} else if ("JJ100820".equals(eps_type)) {
					params.put("emp_no", tr.req.getParameter("app_emp_no"));
					params.put("child_nm", tr.req.getParameter("child_nm"));
					params.put("child_ssn", tr.req.getParameter("child_ssn"));
					params.put("edu_cd", tr.req.getParameter("edu_cd"));
					params.put("edu_nm", tr.req.getParameter("edu_nm"));
					params.put("grade", tr.req.getParameter("grade"));
					params.put("term", tr.req.getParameter("term"));
					params.put("amt", tr.req.getParameter("edu_amt"));
					params.put("bank_nm", tr.req.getParameter("bank_nm"));
					params.put("acc_no", tr.req.getParameter("acc_no"));
					params.put("acc_nm", tr.req.getParameter("acc_nm"));
					params.put("yeardate", tr.req.getParameter("yeardate"));
					
					/* 성진포머 추가 */
					params.put("child_sq_no", tr.req.getParameter("child_sq_no"));
					
					tr.sql.insert("pay.insertChildEdu", params);
					
					tr.sql.delete("pay.deleteDetail", exp_no);
					
					if (tax_dt_list != null) { 
						for (int k=0; k<tax_dt_list.length; k++) { 
							if (!"".equals(tax_dt_list[k])) { 
								params2.put("tax_dt", tax_dt_list[k]);
								params2.put("tax_bc", tax_bc[k]);
								params2.put("exp_no", exp_no);
								params2.put("emp_no", payemp_no[k]);
								params2.put("exp_sq", (k+1));
								params2.put("dsc", dsc[k]);
								params2.put("exp_cd", exp_cd[k]);
								params2.put("amt", StringUtil.replace(StringUtil.normalize(amt[k], "0"), ",", ""));
								params2.put("vat", StringUtil.replace(StringUtil.normalize(vat[k], "0"), ",", ""));
								if (!"".equals(vat[k]) && !"0".equals(vat[k])) { 
									params2.put("vat_yn", "1");
								} else { 
									params2.put("vat_yn", "0");
								}
								params2.put("tot_amt", StringUtil.replace(StringUtil.normalize(tot_amt[k], "0"), ",", ""));
								params2.put("reg_id", user.getReg_id());
								params2.put("dept_cd", dept_cd2[k]);
								// 결의일자 
								//프로젝트 
								params2.put("pro_cd", pro_cd[k]);
								//cost center
								//params2.put("man_cd", man_cd[k]);
								
								System.out.println(params2);
								tr.sql.insert("pay.insertDetail", params2);
								
							}
						}
					}
				
				tr.sql.update("pay.updatePayRequestEpsType", params);
		
				} else if ("JJ100520".equals(eps_type)) {
					
					//이병운추가 20140116
					params.put("exp_no", exp_no);
					params.put("conemp_no", tr.req.getParameter("emp_no"));
					params.put("condept_nm", tr.req.getParameter("dept_nm"));
					params.put("confrom_dt",  StringUtil.replace(tr.req.getParameter("confrom_dt"), "-", ""));
					params.put("conto_dt",  StringUtil.replace(tr.req.getParameter("conto_dt"), "-", ""));
					params.put("contype_cd", tr.req.getParameter("type_cd"));
					params.put("type_cd2", tr.req.getParameter("type_cd2"));
					params.put("type_cd3", tr.req.getParameter("type_cd3"));
					
					tr.sql.insert("pay.insertemc400", params);
		
					
					
				} else if ("JJ100920".equals(eps_type)) {
					
					
					String docno = (String)tr.sql.selectObject("pay.selectDocnoId");
					
					//params.put("docno", tr.req.getParameter("docno"));
					params.put("docno", docno);
					params.put("writedt", StringUtil.replace(tr.req.getParameter("writedt"), "-", ""));
					params.put("receive", tr.req.getParameter("receive"));
					params.put("refer", tr.req.getParameter("refer"));
					params.put("sender", tr.req.getParameter("sender"));
					params.put("tel", tr.req.getParameter("tel"));
					params.put("fax", tr.req.getParameter("fax"));
					params.put("address", tr.req.getParameter("address"));
					params.put("Receiverefer", tr.req.getParameter("Receiverefer"));
					
					tr.sql.insert("pay.insertOfficial", params);
					
				} else if ("JJ100960".equals(eps_type)) {
					
					String receipt_no = (String)tr.sql.selectObject("pay.selectReceipt_noId");
					
					params.put("receipt_no", receipt_no);
					params.put("writedt", StringUtil.replace(tr.req.getParameter("writedt"), "-", ""));
					params.put("state_department", tr.req.getParameter("state_department"));
					params.put("sender", tr.req.getParameter("sender"));
					System.out.println(params);
					tr.sql.insert("pay.insertOfficialLedger", params);	
					
				 
					
				} else if ("JJ100930".equals(eps_type)) {
					//훈련일지 
					params.put("exp_no", exp_no);
					params.put("train_cd", tr.req.getParameter("base_cd"));
					params.put("train_dt",  StringUtil.replace(tr.req.getParameter("hol_fr_dt"), "-", ""));
					params.put("train_area", tr.req.getParameter("tr_area"));
					params.put("bademp_no", "");
					params.put("bad_remark", "");
					params.put("prent_remark", tr.req.getParameter("front"));
					params.put("player_remark", tr.req.getParameter("playerremark"));
					params.put("remark", tr.req.getParameter("taste_remark"));
					params.put("tomorr_remark", tr.req.getParameter("calendar"));
					tr.sql.insert("pay.inserttrainplan", params);
					
					//선수단일정
					if(time != null)
					{
						for(int row = 0; row<time.length; row ++)
						{
							if(!"".equals(time[row]))
							{
								
								params_sub.put("exp_no", exp_no);
								params_sub.put("exp_seq", (row+1));
								params_sub.put("baseman_time", tr.req.getParameter("time1"+ (row + 1)));
								params_sub.put("baseman_remark", tr.req.getParameter("timeremark1"+ (row + 1)));
								params_sub.put("pit_time", tr.req.getParameter("time2"+ (row + 1)));
								params_sub.put("pit_remark", tr.req.getParameter("timeremark2"+ (row + 1)));
								params_sub.put("reg_id", user.getReg_id());
								
								tr.sql.insert("pay.inserttrainTime", params_sub);
								
							}
							
						}
						
					}
					
					
					System.out.println(passarea1);
					
					//불참자
					if(passarea1 != null)
					{
						for(int row = 0; row<passarea1.length; row++)
						{
							if(!"".equals(passarea1[row]))
							{
								params_sub3.put("exp_no", exp_no);
								params_sub3.put("exp_seq", (row+1));
								params_sub3.put("playemp_no", passarea1[row]);
								params_sub3.put("remark", tr.req.getParameter("passarea2"+ (row + 1)));
								params_sub3.put("reg_id", user.getReg_id());
								
								tr.sql.insert("pay.insertTRANTODAYBAD", params_sub3);
								
							}
							
						}
						
					}
		
					//훈련일지 
					params_sub3.put("exp_no", exp_no);
					params_sub3.put("exp_gbn","001");
					params_sub3.put("play_cnt",  tr.req.getParameter("all_steal"));
					params_sub3.put("coach_cnt", tr.req.getParameter("all_coach"));
					params_sub3.put("emp_cnt", tr.req.getParameter("all_staff"));
					params_sub3.put("subemp_cnt", tr.req.getParameter("all_sub"));
					params_sub3.put("cnt", tr.req.getParameter("all_cnt"));
					params_sub3.put("reg_id", user.getReg_id());
					tr.sql.insert("pay.insertTRANTODAYSUB", params_sub3);
		
					
		
					params_sub4.put("exp_no", exp_no);
					params_sub4.put("exp_gbn","002");
					params_sub4.put("play_cnt",  tr.req.getParameter("pass_steal"));
					params_sub4.put("coach_cnt", tr.req.getParameter("pass_coach"));
					params_sub4.put("emp_cnt", tr.req.getParameter("pass_staff"));
					params_sub4.put("subemp_cnt", tr.req.getParameter("pass_sub"));
					params_sub4.put("cnt", tr.req.getParameter("pass_cnt"));
					params_sub4.put("reg_id", user.getReg_id());
					tr.sql.insert("pay.insertTRANTODAYSUB", params_sub4);
		
		
					params_sub5.put("exp_no", exp_no);
					params_sub5.put("exp_gbn","003");
					params_sub5.put("play_cnt",  tr.req.getParameter("now_steal"));
					params_sub5.put("coach_cnt", tr.req.getParameter("now_coach"));
					params_sub5.put("emp_cnt", tr.req.getParameter("now_staff"));
					params_sub5.put("subemp_cnt", tr.req.getParameter("now_sub"));
					params_sub5.put("cnt", tr.req.getParameter("now_cnt"));
					params_sub5.put("reg_id", user.getReg_id());
					tr.sql.insert("pay.insertTRANTODAYSUB", params_sub5);
		
				} else if ("JJ100940".equals(eps_type)) {
					params.put("exp_no", exp_no);
					params.put("treat_dt", StringUtil.replace(tr.req.getParameter("treat_dt"), "-", ""));
					params.put("treat_place", tr.req.getParameter("treat_place"));
					params.put("treat_gbn", tr.req.getParameter("treat_gbn"));
					params.put("treat_nm", tr.req.getParameter("treat_nm"));
					params.put("play_id", tr.req.getParameter("play_id"));
					params.put("play_nm", tr.req.getParameter("play_nm"));
					params.put("play_ps", tr.req.getParameter("ps_nm"));
					params.put("treat_nm", tr.req.getParameter("treat_nm"));
					params.put("treat_origin", tr.req.getParameter("treat_origin"));
					params.put("treat_result", tr.req.getParameter("treat_result"));
					params.put("partnar_remark", tr.req.getParameter("partnar_remark"));
					params.put("remark", tr.req.getParameter("contents"));
					params.put("reg_id", user.getReg_id());
					tr.sql.insert("pay.insertTreatmaentl", params);
		
				} else if ("JJ100950".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no",tr.req.getParameter("rec_emp_no"));
					params.put("trouble_dt",StringUtil.replace(tr.req.getParameter("trouble_dt"), "-", ""));
					params.put("resident_no", tr.req.getParameter("resident_no"));
					params.put("Drive_no", tr.req.getParameter("Drive_no"));
					params.put("car_no", tr.req.getParameter("car_no1"));
					params.put("car_gbn", tr.req.getParameter("car_gbn"));
					params.put("reg_id", user.getReg_id());
					params.put("trouble_remark", tr.req.getParameter("contents"));
					System.out.println(params);
					tr.sql.insert("pay.insertTrouble", params);
					
				} else if ("JJ100550".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("accid_gbn",tr.req.getParameter("accid_gbn"));
					params.put("accid_dt", StringUtil.replace(tr.req.getParameter("accid_dt"), "-", ""));
					params.put("accid_area", tr.req.getParameter("accid_area"));
					params.put("accid_emp", tr.req.getParameter("accid_emp_no"));
					params.put("accid_reason", tr.req.getParameter("accid_reason"));
					params.put("accid_inspec", tr.req.getParameter("accid_inspec"));
					params.put("victim_nm", tr.req.getParameter("victim_nm"));
					params.put("victper_remark", tr.req.getParameter("victper_remark"));
					params.put("victinjury_nm", tr.req.getParameter("victinjury_nm"));
					params.put("victobstacle_rank", tr.req.getParameter("victobstacle_rank"));
					params.put("victperiod_dt",StringUtil.replace(tr.req.getParameter("victperiod_dt"), "-", ""));
					params.put("victmedical_amt", tr.req.getParameter("victmedical_amt"));
					params.put("victproperty_remark", tr.req.getParameter("victproperty_remark"));
					params.put("victinsurance_remark", tr.req.getParameter("victinsurance_remark"));
					params.put("victaction_remark", tr.req.getParameter("victaction_remark"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertSafetyAccident", params);
					
				} else if ("JJ100551".equals(eps_type)) {
					//증명서
					
					String Warrant_no = (String)tr.sql.selectObject("pay.selectWarrant_noId");
					
					params.put("Warrant_no", Warrant_no);
					
					params.put("exp_no", exp_no);
					params.put("emp_no",tr.req.getParameter("rec_emp_no"));
					params.put("warrant_dt", StringUtil.replace(tr.req.getParameter("warrant_dt"), "-", ""));
					params.put("pay_fr_dt", StringUtil.replace(tr.req.getParameter("pay_fr_dt"), "-", ""));
					params.put("pay_to_dt", StringUtil.replace(tr.req.getParameter("pay_to_dt"), "-", ""));
					params.put("pay_ty", tr.req.getParameter("pay_ty"));
					params.put("pay_year", StringUtil.replace(tr.req.getParameter("pay_year"), "-", ""));
					if (tr.req.getParameter("warrant_yn")==null) { 
						params.put("warrant_yn", "N");
					}else{
						params.put("warrant_yn", "Y");
					}
					//params.put("warrant_gbn", tr.req.getParameter("warrant_gbn"));
					//params.put("warrant_cnt", tr.req.getParameter("warrant_cnt"));
					params.put("warrant_remark", tr.req.getParameter("warrant_remark"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertwarrant", params);
					
					int car_all_work = 0;

					car_all_work = Integer.parseInt(dodelete_cnt);

					String req_sub_String[] = new String[car_all_work];

					int car_stst11 = 0;
					for (int car_ch2 = 1; car_ch2 <= car_all_work; car_ch2++) {
						if (tr.req.getParameter("req_sub" + car_ch2) != null) {
							req_sub_String[car_stst11] = tr.req.getParameter("req_sub" + car_ch2);
							car_stst11++;
						}
					}
					
					
					//요청서류 코드
					tr.sql.delete("pay.deleteReq_doc_json", exp_no);

					if (req_doc != null) { 
						for (int k=0; k<req_doc.length; k++) { 
							if (!"".equals(req_doc[k])) { 
								appeatparams3.put("exp_no", exp_no);
								appeatparams3.put("exp_seq", (k+1));
								appeatparams3.put("req_doc", req_doc[k]);
								appeatparams3.put("req_cnt", StringUtil.normalize(req_cnt[k], "0"));
								appeatparams3.put("req_use", req_use[k]);
								appeatparams3.put("req_sub", req_sub_String[k]);
								appeatparams3.put("cid", user.getReg_id());
								tr.sql.insert("pay.insertReq_doc_json", appeatparams3);
							}
						}
					}
					
					
		
				} else if ("JJ100552".equals(eps_type)) {
					///명함
					
					
					System.out.println("E_emp_no-----"+E_emp_no);
					params.put("exp_no", exp_no);
					
					
					
					int car_all = 0;

					car_all = (E_emp_no.length+Integer.parseInt(dodelete_cnt)); 
					
					 String chineseString[] = new String[car_all];
					 String dept_nmString[]= new String[car_all];
					 String high_nmString[]= new  String[car_all];  
					 String emailString[]= new String[car_all];
					 String addrString[]= new  String[car_all];  
					 
					 String E_dept_nmString[]= new String[car_all];
					 String E_high_nmString[]= new  String[car_all];  
					 String E_emailString[]= new String[car_all];
					 String E_addrString[]= new  String[car_all]; 
					 
					 String pic_ynString[]= new  String[car_all]; 

					 int car_stst11 = 0;
			 		 for(int car_ch2= 1; car_ch2<=(E_emp_no.length+car_all); car_ch2++)
					{
			 			if(tr.req.getParameter("high_bc_name"+car_ch2) != null)
						{
			 				chineseString[car_stst11] = tr.req.getParameter("Chi_char"+car_ch2);
			 				dept_nmString[car_stst11] = tr.req.getParameter("treat_place" + car_ch2);
			 				high_nmString[car_stst11] = tr.req.getParameter("high_bc_name" + car_ch2);
			 				emailString[car_stst11] = tr.req.getParameter("email" + car_ch2);
			 				addrString[car_stst11] = tr.req.getParameter("addr1" + car_ch2);
			 				
			 				E_dept_nmString[car_stst11] = tr.req.getParameter("E_dept_nm" + car_ch2);
			 				E_high_nmString[car_stst11] = tr.req.getParameter("E_high_nm" + car_ch2);
			 				E_emailString[car_stst11] = tr.req.getParameter("E_email" + car_ch2);
			 				E_addrString[car_stst11] = tr.req.getParameter("E_addr" + car_ch2);
			 				
			 				pic_ynString[car_stst11] = tr.req.getParameter("pic_yn" + car_ch2);
			 				
							car_stst11++;
						}
					} 
					
					
					
					
					tr.sql.delete("pay.Deletebusinesscard", params);
					
						
						if (E_emp_no != null) { 
							for (int k=0; k<E_emp_no.length; k++) { 
								if (!"".equals(E_emp_no[k])) { 
									params.put("emp_no", E_emp_no[k]);
									params.put("chinese", chineseString[k]);
									params.put("dept_nm", dept_nmString[k]); 
									params.put("high_nm",  high_nmString[k]);
									params.put("dept_tel", dept_tel[k]);
									params.put("fax", fax[k]);
									params.put("mobile", mobile[k]);
									params.put("email", emailString[k]);
									params.put("addr", addrString[k]);
									
									params.put("E_emp_nm", E_emp_nm[k]);
									params.put("E_dept_nm", E_dept_nmString[k]); 
									params.put("E_high_nm",  E_high_nmString[k]);
									params.put("E_dept_tel", E_dept_tel[k]);
									params.put("E_fax", E_fax[k]);
									params.put("E_mobile", E_mobile[k]);
									params.put("E_email", E_emailString[k]);
									params.put("E_addr", E_addrString[k]);
									
									if ("on".equals(pic_ynString[k])) {
										
										params.put("pic_yn", "1");
									} else { 
										params.put("pic_yn", "0");
									}
									
									params.put("cid", user.getReg_id());
									System.out.println("E_emp_no-----"+params);
									tr.sql.insert("pay.insertbusinesscard", params);
								}
							}
						}
					
						
					
		
				} else if ("JJ100554".equals(eps_type)) {
					//554 사유서
					params.put("exp_no", exp_no);
					params.put("reasons_remark",tr.req.getParameter("contents"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertreasons", params);
					
				} else if ("JJ100555".equals(eps_type)) {
					//555 경위서(시말서)   미쯔비시
					params.put("exp_no", exp_no);
					params.put("rs1",tr.req.getParameter("rs1"));
					params.put("rs2",tr.req.getParameter("rs2"));
					params.put("rs3",tr.req.getParameter("rs3"));
					params.put("rs4",tr.req.getParameter("rs4"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertReport_Mitsubishi", params);
					
				//장암 수출출고협조전	
				} else if ("JJ100557".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no",tr.req.getParameter("rec_emp_no"));
					params.put("cust_cd",tr.req.getParameter("cust_cd"));
					params.put("itm_nm",tr.req.getParameter("itm_nm"));
					params.put("amt",StringUtil.normalize(tr.req.getParameter("amt"),"0"));
					params.put("release",tr.req.getParameter("release"));
					params.put("release_dt",tr.req.getParameter("release_dt"));
					params.put("ship",tr.req.getParameter("ship"));
					params.put("destination",tr.req.getParameter("destination"));
					params.put("note", tr.req.getParameter("contents"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertCooperExport", params);	
					
				//장암 수입입고협조전		
				} else if ("JJ100558".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no",tr.req.getParameter("rec_emp_no"));
					params.put("cust_cd",tr.req.getParameter("cust_cd"));
					params.put("itm_nm",tr.req.getParameter("itm_nm"));
					params.put("amt",StringUtil.normalize(tr.req.getParameter("amt"),"0"));
					params.put("release",tr.req.getParameter("release"));
					params.put("release_dt",tr.req.getParameter("release_dt"));
					params.put("ship",tr.req.getParameter("ship"));
					params.put("destination",tr.req.getParameter("destination"));
					params.put("note", tr.req.getParameter("contents"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertCooperImport", params);	
					
				//장암 소요금청구서
				}else if ("JJ100559".equals(eps_type)) {
					params.put("exp_no", exp_no);
					params.put("exp_seq", "1");
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("cid", user.getReg_id());
					
					System.out.println("소요금 청구서 --------- "+ params);
					tr.sql.insert("pay.insertCostCharge", params);
					
/* 
					 int car_all = 0;
					 car_all = bill_dt.length+Integer.parseInt(dodelete_cnt); 
					 
					 String noteString[]= new String[car_all];
					 String bankString[] = new String[car_all];
					 String accountString[] = new String[car_all];
					 String account_nmString[] = new String[car_all];
					 
					 int car_stst11 = 0;
			 		for(int car_ch2= 1; car_ch2<=(bill_dt.length+car_all); car_ch2++)
					{
			 			if(tr.req.getParameter("cust_nm"+car_ch2) != null)
						{
			 				noteString[car_stst11] = tr.req.getParameter("note" + car_ch2);
			 				bankString[car_stst11] = tr.req.getParameter("bank" +car_ch2);
			 				accountString[car_stst11] = tr.req.getParameter("account" +car_ch2);
			 				account_nmString[car_stst11] = tr.req.getParameter("account_nm" + car_ch2);
							
							car_stst11++;
						}
					}  
					
			 		tr.sql.delete("pay.deleteCostCharge", exp_no);
					
					if (bill_dt != null) { 
						for (int k=0; k<bill_dt.length; k++) { 
							if (!"".equals(bill_dt[k])) { 
								params.put("exp_no", exp_no);
								params.put("emp_no", tr.req.getParameter("rec_emp_no"));
								params.put("exp_seq", (k+1));
								params.put("bill_dt", bill_dt[k]);
								params.put("cust_cd", cust_cd[k]);
								params.put("note", noteString[k]);
								params.put("bank", bankString[k]);
								params.put("account", accountString[k]);
								params.put("account_nm", account_nmString[k]);
								params.put("amt", StringUtil.replace(StringUtil.normalize(amt[k], "0"), ",", ""));
								
								System.out.println("소요금 청구서 --------- "+ params);
								tr.sql.insert("pay.insertCostCharge", params);
							}
						}
					}	
				
	 */				
					
				} else if ("JJ100540".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no",tr.req.getParameter("rec_emp_no"));
					params.put("request_dt",StringUtil.replace(tr.req.getParameter("request_dt"), "-", ""));
					params.put("complete_dt",StringUtil.replace(tr.req.getParameter("complete_dt"), "-", ""));		
					params.put("purchase_item", tr.req.getParameter("purchase_item"));		
					params.put("purchase_reason", tr.req.getParameter("purchase_reason"));
					params.put("purchase_history", tr.req.getParameter("purchase_history"));
					tr.sql.insert("pay.insertArticlepurchases", params);
					
				} else if ("JJ100961".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no",tr.req.getParameter("rec_emp_no"));
					params.put("request_dt",StringUtil.replace(tr.req.getParameter("request_dt"), "-", ""));
					//params.put("request_doc",tr.req.getParameter("request_doc"));
					params.put("request_reason", tr.req.getParameter("request_reason"));
					//params.put("request_cnt", tr.req.getParameter("request_cnt"));
					System.out.println(params);
					tr.sql.insert("pay.insertCorporatedoc", params);
					
					int car_all_work = 0;

					car_all_work = Integer.parseInt(dodelete_cnt);

					String req_sub_String[] = new String[car_all_work];

					int car_stst11 = 0;
					for (int car_ch2 = 1; car_ch2 <= car_all_work; car_ch2++) {
						if (tr.req.getParameter("req_doc" + car_ch2) != null) {
							req_sub_String[car_stst11] = tr.req.getParameter("req_doc" + car_ch2);
							car_stst11++;
						}
					}
 
					//요청서류 코드
					tr.sql.delete("pay.deleteReq_doc_json", exp_no);
 

					if (time != null) { 
						for (int k=0; k<time.length; k++) { 
							if (!"".equals(time[k])) { 
								appeatparams3.put("exp_no", exp_no);
								appeatparams3.put("exp_seq", (k+1));
								appeatparams3.put("req_doc", req_sub_String[k]);
								appeatparams3.put("req_cnt", StringUtil.normalize(req_cnt[k], "0"));
								//appeatparams3.put("req_use", req_use[k]);
								//appeatparams3.put("req_sub", req_sub_String[k]);
								appeatparams3.put("cid", user.getReg_id());
								System.out.println("법인서류 ----- " + appeatparams3);
								tr.sql.insert("pay.insertReq_doc_json", appeatparams3);
							}
						}
					}
					
/* 					
					
					if (time != null) { 
						for (int k=0; k<time.length; k++) { 
							if (!"".equals(time[k])) { 
								appeatparams3.put("exp_no", exp_no);
								appeatparams3.put("exp_seq", (k+1));
								appeatparams3.put("req_doc", tr.req.getParameter("req_doc" + (k + 1)));
// 								appeatparams3.put("req_use", req_use[k]);
// 								appeatparams3.put("req_sub", tr.req.getParameter("req_sub" + (k + 1)));
								appeatparams3.put("req_cnt", StringUtil.normalize(req_cnt[k], "0"));
								appeatparams3.put("cid", user.getReg_id());
								tr.sql.insert("pay.insertReq_doc_json", appeatparams3);
							}
						}
					}
					
 */
				
					//화물감독비 신청서	
				} else if ("JJ100434".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("cargo_gbn",tr.req.getParameter("cargo_gbn"));
					params.put("cargo_cnt",tr.req.getParameter("cargo_cnt"));
					params.put("cargo_trip",tr.req.getParameter("cargo_trip"));
					params.put("cargo_note",tr.req.getParameter("cargo_note"));
					
					params.put("cid", user.getReg_id());
					//대우 추가
					params.put("emp_no",tr.req.getParameter("rec_emp_no"));
					
					System.out.println(params);
					tr.sql.insert("pay.insertsuperCargo", params); 
					
					int car_all = 0;

					car_all = (Appear_dt.length+Integer.parseInt(dodelete_cnt)); 
					
					
					 String appschefrom_nm[] = new String[car_all];
					 String appscheto_nm[]= new String[car_all];
					 String appschefrom_tm[]= new  String[car_all];  
					 String appscheto_tm[]= new  String[car_all];  
					 String appscheto_remark[]= new  String[car_all];  

					 int car_stst11 = 0;
			 		 for(int car_ch2= 1; car_ch2<=(Appear_dt.length+car_all); car_ch2++)
					{
			 			if(tr.req.getParameter("appscheto_remark"+car_ch2) != null)
						{
			 				appschefrom_nm[car_stst11] = tr.req.getParameter("appschefrom_nm"+car_ch2);
			 				appscheto_nm[car_stst11] = tr.req.getParameter("appscheto_nm" + car_ch2);
			 				appschefrom_tm[car_stst11] = tr.req.getParameter("appschefrom_tm" + car_ch2);
			 				appscheto_tm[car_stst11] = tr.req.getParameter("appscheto_tm" + car_ch2);
			 				appscheto_remark[car_stst11] = tr.req.getParameter("appscheto_remark" + car_ch2);

							
							car_stst11++;
						}
					} 
					tr.sql.delete("pay.deleteAppearschedule", exp_no);
					
					if (Appear_dt != null) { 
						for (int k=0; k<Appear_dt.length; k++) { 
							if (!"".equals(Appear_dt[k])) { 
								appeatparams2.put("exp_no", exp_no);
								appeatparams2.put("exp_seq", (k+1));
								appeatparams2.put("appsche_dt", Appear_dt[k]);
								appeatparams2.put("appsche_to_dt", Appear_to_dt[k]);
								appeatparams2.put("appschefrom_nm", appschefrom_nm[k]);
								appeatparams2.put("appscheto_nm", appscheto_nm[k]);
								appeatparams2.put("appschefrom_tm", appschefrom_tm[k]);
								appeatparams2.put("appscheto_tm", appscheto_tm[k]);
								appeatparams2.put("appscheto_remark", appscheto_remark[k]);
								appeatparams2.put("cid", user.getReg_id());
								System.out.println(appeatparams2);
								tr.sql.insert("pay.insertappearschedule", appeatparams2);
							}
						}
					}
 
 				//국내 출장신청서	//해외 출장신청서	
				} else if (("JJ100963".equals(eps_type)) || ("JJ100850".equals(eps_type))) {
					
					params.put("exp_no", exp_no);
					params.put("appfrom_dt",StringUtil.replace(tr.req.getParameter("appfrom_dt"), "-", ""));
					params.put("apptto_dt",StringUtil.replace(tr.req.getParameter("apptto_dt"), "-", ""));
					params.put("appt_cnt",tr.req.getParameter("appt_cnt"));
					params.put("appt_trip",tr.req.getParameter("appt_trip"));
					params.put("appt_fare",tr.req.getParameter("appt_fare"));
					params.put("fare_addr",tr.req.getParameter("fare_addr"));
					params.put("appt_gbn",tr.req.getParameter("appt_gbn"));
					params.put("cid", user.getReg_id());
					//대우 추가
					params.put("emp_no",tr.req.getParameter("rec_emp_no"));
					params.put("tm_yn",tr.req.getParameter("tm_yn"));
					params.put("train_yn",tr.req.getParameter("train_yn"));
					params.put("air_yn",tr.req.getParameter("air_yn"));
					params.put("bus_yn",tr.req.getParameter("bus_yn"));
					params.put("etc_yn",tr.req.getParameter("etc_yn"));
					params.put("etc_traffic",tr.req.getParameter("etc_traffic"));
					params.put("lodg_cnt",tr.req.getParameter("lodg_cnt"));
					params.put("rent_ph",tr.req.getParameter("rent_ph"));
					params.put("agency", tr.req.getParameter("agency"));
					params.put("ac_ex_yn", tr.req.getParameter("ac_ex_yn"));
					params.put("ext_yn", tr.req.getParameter("ext_yn"));
					//대우 해외연수
					params.put("study_type", tr.req.getParameter("study_type"));
					params.put("area_bc", tr.req.getParameter("area_bc"));
					params.put("emp_nm2", tr.req.getParameter("emp_nm2"));
					params.put("passport_dt", tr.req.getParameter("passport_dt"));
					
					// 출장내용 추가 2024.01.31
					params.put("detail", tr.req.getParameter("detail"));
					System.out.println(params);
					tr.sql.insert("pay.insertappearreques", params); 
					
					int car_all = 0;
					car_all = (Appear_dt.length+Integer.parseInt(dodelete_cnt)); 
					
					 String appschefrom_nm[] = new String[car_all];
					 String appscheto_nm[]= new String[car_all];
					 String appschefrom_tm[]= new  String[car_all];  
					 String appscheto_tm[]= new  String[car_all];  
					 String appscheto_remark[]= new  String[car_all];  

					 int car_stst11 = 0;
			 		 for(int car_ch2= 1; car_ch2<=(Appear_dt.length+car_all); car_ch2++)
					{
			 			if(tr.req.getParameter("appschefrom_nm"+car_ch2) != null)
						{
			 				appschefrom_nm[car_stst11] = tr.req.getParameter("appschefrom_nm"+car_ch2);
			 				appscheto_nm[car_stst11] = tr.req.getParameter("appscheto_nm" + car_ch2);
			 				appschefrom_tm[car_stst11] = tr.req.getParameter("appschefrom_tm" + car_ch2);
			 				appscheto_tm[car_stst11] = tr.req.getParameter("appscheto_tm" + car_ch2);
			 				appscheto_remark[car_stst11] = tr.req.getParameter("appscheto_remark" + car_ch2);

							
							car_stst11++;
						}
					} 
					
					tr.sql.delete("pay.deleteAppearschedule", exp_no);
					
					if (Appear_dt != null) { 
						for (int k=0; k<Appear_dt.length; k++) { 
							if (!"".equals(Appear_dt[k])) { 
								appeatparams2.put("exp_no", exp_no);
								appeatparams2.put("exp_seq", (k+1));
								appeatparams2.put("appsche_dt", Appear_dt[k]);
								appeatparams2.put("appsche_to_dt", Appear_to_dt[k]);
								appeatparams2.put("appschefrom_nm", appschefrom_nm[k]);
								appeatparams2.put("appscheto_nm", appscheto_nm[k]);
								appeatparams2.put("appschefrom_tm", appschefrom_tm[k]);
								appeatparams2.put("appscheto_tm", appscheto_tm[k]);
								appeatparams2.put("appscheto_remark", appscheto_remark[k]);
								//대우추가
								appeatparams2.put("applodge_cnt", applodge_cnt[k]);
								appeatparams2.put("appday", appday[k]);
								appeatparams2.put("apparea", apparea[k]);
								appeatparams2.put("cid", user.getReg_id());
								System.out.println(appeatparams2);
								tr.sql.insert("pay.insertappearschedule", appeatparams2);
							}
						}
					}
				
					//여비 지급신청서  
					if (costtot_amt != null) { 
						for (int k=0; k<costtot_amt.length; k++) { 
							if (!"".equals(costtot_amt[k])) { 
								 
								costparams3.put("exp_no", exp_no);
								costparams3.put("exp_seq", (k+1));
								//costparams3.put("emp_no", costemp_no[k]);
								//대우추가
								costparams3.put("emp_no", tr.req.getParameter("rec_emp_no"));
								costparams3.put("currency", currency[k]);
								costparams3.put("lodgment_price", lodgment_price[k]);
								costparams3.put("lodgment_dcnt", lodgment_dcnt[k]);
								costparams3.put("lodgment_tot", lodgment_tot[k]);
								costparams3.put("acday_price", acday_price[k]);
								costparams3.put("acday_dcnt", acday_dcnt[k]);
								costparams3.put("acday_tot", acday_tot[k]);
								costparams3.put("reverve", reverve[k]);
								costparams3.put("tot_amt", costtot_amt[k]);
								//costparams3.put("after_exp_no", tr.req.getParameter("exp_no"));
								costparams3.put("cid", user.getReg_id());
								System.out.println(costparams3);
								tr.sql.insert("pay.inserttravelexpenses", costparams3);
								
							}
						}
					}
					
					 
	 				//해외경비신청서	
					} else if ("JJ100436".equals(eps_type)) {
						
						params.put("exp_no", exp_no);
						params.put("appfrom_dt",StringUtil.replace(tr.req.getParameter("appfrom_dt"), "-", ""));
						params.put("apptto_dt",StringUtil.replace(tr.req.getParameter("apptto_dt"), "-", ""));
						params.put("appt_cnt",tr.req.getParameter("appt_cnt"));
						params.put("appt_trip",tr.req.getParameter("appt_trip"));
						params.put("appt_fare",tr.req.getParameter("appt_fare"));
						params.put("fare_addr",tr.req.getParameter("fare_addr"));
						params.put("appt_gbn",tr.req.getParameter("appt_gbn"));
						params.put("cid", user.getReg_id());
						//대우 추가
						params.put("emp_no",tr.req.getParameter("rec_emp_no"));
						params.put("tm_yn",tr.req.getParameter("tm_yn"));
						params.put("train_yn",tr.req.getParameter("train_yn"));
						params.put("air_yn",tr.req.getParameter("air_yn"));
						params.put("bus_yn",tr.req.getParameter("bus_yn"));
						params.put("etc_yn",tr.req.getParameter("etc_yn"));
						params.put("etc_traffic",tr.req.getParameter("etc_traffic"));
						params.put("lodg_cnt",tr.req.getParameter("lodg_cnt"));
						params.put("rent_ph",tr.req.getParameter("rent_ph"));
						params.put("agency", tr.req.getParameter("agency"));
						params.put("ac_ex_yn", tr.req.getParameter("ac_ex_yn"));
						params.put("ext_yn", tr.req.getParameter("ext_yn"));
						//대우 해외연수
						params.put("study_type", tr.req.getParameter("study_type"));
						params.put("area_bc", tr.req.getParameter("area_bc"));
						
						System.out.println(params);
						tr.sql.insert("pay.insertappearreques", params); 
						
						int car_all = 0;
						car_all = (Appear_dt.length+Integer.parseInt(dodelete_cnt)); 
						
						 String appschefrom_nm[] = new String[car_all];
						 String appscheto_nm[]= new String[car_all];
						 String appschefrom_tm[]= new  String[car_all];  
						 String appscheto_tm[]= new  String[car_all];  
						 String appscheto_remark[]= new  String[car_all];  

						 int car_stst11 = 0;
				 		 for(int car_ch2= 1; car_ch2<=(Appear_dt.length+car_all); car_ch2++)
						{
				 			if(tr.req.getParameter("appschefrom_nm"+car_ch2) != null)
							{
				 				appschefrom_nm[car_stst11] = tr.req.getParameter("appschefrom_nm"+car_ch2);
				 				appscheto_nm[car_stst11] = tr.req.getParameter("appscheto_nm" + car_ch2);
				 				appschefrom_tm[car_stst11] = tr.req.getParameter("appschefrom_tm" + car_ch2);
				 				appscheto_tm[car_stst11] = tr.req.getParameter("appscheto_tm" + car_ch2);
				 				appscheto_remark[car_stst11] = tr.req.getParameter("appscheto_remark" + car_ch2);

								
								car_stst11++;
							}
						} 
						
						tr.sql.delete("pay.deleteAppearschedule", exp_no);
						
						if (Appear_dt != null) { 
							for (int k=0; k<Appear_dt.length; k++) { 
								if (!"".equals(Appear_dt[k])) { 
									appeatparams2.put("exp_no", exp_no);
									appeatparams2.put("exp_seq", (k+1));
									appeatparams2.put("appsche_dt", Appear_dt[k]);
									appeatparams2.put("appsche_to_dt", Appear_to_dt[k]);
									appeatparams2.put("appschefrom_nm", appschefrom_nm[k]);
									appeatparams2.put("appscheto_nm", appscheto_nm[k]);
									appeatparams2.put("appschefrom_tm", appschefrom_tm[k]);
									appeatparams2.put("appscheto_tm", appscheto_tm[k]);
									appeatparams2.put("appscheto_remark", appscheto_remark[k]);
									//대우추가
									//appeatparams2.put("applodge_cnt", applodge_cnt[k]);
									//appeatparams2.put("appday", appday[k]);
									//appeatparams2.put("apparea", apparea[k]);
									appeatparams2.put("cid", user.getReg_id());
									System.out.println(appeatparams2);
									tr.sql.insert("pay.insertappearschedule", appeatparams2);
								}
							}
						}
					
						//여비 지급신청서  
						if (acday_tot != null) { 
							for (int k=0; k<acday_tot.length; k++) { 
								if (!"".equals(acday_tot[k])) { 
									 
									costparams3.put("exp_no", exp_no);
									costparams3.put("exp_seq", (k+1));
									//costparams3.put("emp_no", costemp_no[k]);
									//대우추가
									costparams3.put("currency", currency[k]);
									//costparams3.put("lodgment_price", lodgment_price[k]);
									//costparams3.put("lodgment_dcnt", lodgment_dcnt[k]);
									//costparams3.put("lodgment_tot", lodgment_tot[k]);
									costparams3.put("acday_price", acday_price[k]);
									costparams3.put("acday_dcnt", acday_dcnt[k]);
									costparams3.put("acday_tot", acday_tot[k]);
									//costparams3.put("reverve", reverve[k]);
									//costparams3.put("tot_amt", costtot_amt[k]);
									//costparams3.put("after_exp_no", tr.req.getParameter("exp_no"));
									costparams3.put("cid", user.getReg_id());
									System.out.println("costparams3--------" + costparams3);
									tr.sql.insert("pay.inserttravelexpenses", costparams3);
									
								}
							}
						}
						
						
						
					 //출장보고서	
				} else if ("JJ100962".equals(eps_type)) {
						
						params.put("exp_no", exp_no);
						params.put("bustart_dt",StringUtil.replace(tr.req.getParameter("bustart_dt"), "-", ""));
						params.put("buend_dt",StringUtil.replace(tr.req.getParameter("buend_dt"), "-", ""));
						params.put("bu_period",tr.req.getParameter("bu_period"));
						params.put("bu_position", tr.req.getParameter("bu_position"));
						params.put("work_content", tr.req.getParameter("work_content"));
						params.put("bu_addr", tr.req.getParameter("bu_addr"));
						params.put("bu_report", tr.req.getParameter("contents"));
						params.put("subexp_no", tr.req.getParameter("paramexp_no"));
						tr.sql.insert("pay.insertBusinesstripreport", params); 
						
						
						tr.sql.delete("pay.deleteTravelexpenses", exp_no);
						
						//여비 지급신청서 
						if (costemp_nm != null) { 
							for (int k=0; k<costemp_nm.length; k++) { 
								if (!"".equals(costemp_nm[k])) { 
									
									costparams3.put("exp_no", exp_no);
									costparams3.put("exp_seq", (k+1));
									costparams3.put("emp_no", costemp_no[k]);
									costparams3.put("traffic_price", traffic_price[k]);
									costparams3.put("traffic_dcnt", traffic_dcnt[k]);
									costparams3.put("traffic_tot", traffic_tot[k]);
									costparams3.put("lodgment_price", lodgment_price[k]);
									costparams3.put("lodgment_dcnt", lodgment_dcnt[k]);
									costparams3.put("lodgment_tot", lodgment_tot[k]);
									costparams3.put("food_price", food_price[k]);
									costparams3.put("food_dcnt", food_dcnt[k]);
									costparams3.put("food_tot", food_tot[k]);
									costparams3.put("tot_amt", costtot_amt[k]);
									costparams3.put("after_exp_no", tr.req.getParameter("exp_no"));
									costparams3.put("cid", user.getReg_id());
									System.out.println(costparams3);
									tr.sql.insert("pay.inserttravelexpenses_sub", costparams3);
								}
							}
						}
						
						
						
					//출장 변경신청서
				} else if ("JJ100717".equals(eps_type)) {

						params.put("exp_no", exp_no);
						params.put("paramexp_no", tr.req.getParameter("paramexp_no"));
						params.put("chg_gbn", tr.req.getParameter("chg_gbn"));
						params.put("chgfrom_dt", tr.req.getParameter("chgfrom_dt"));
						params.put("chgto_dt", tr.req.getParameter("chgto_dt"));
						params.put("chg_note", tr.req.getParameter("chg_note"));
						params.put("appfrom_dt",StringUtil.replace(tr.req.getParameter("appfrom_dt"), "-", ""));
						params.put("apptto_dt",StringUtil.replace(tr.req.getParameter("apptto_dt"), "-", ""));
						params.put("appt_cnt",tr.req.getParameter("appt_cnt"));
						params.put("appt_trip",tr.req.getParameter("appt_trip"));
						params.put("appt_fare",tr.req.getParameter("appt_fare"));
						params.put("fare_addr",tr.req.getParameter("fare_addr"));
						params.put("appt_gbn",tr.req.getParameter("appt_gbn"));
						params.put("cid", user.getReg_id());
						//대우 추가
						params.put("emp_no",tr.req.getParameter("rec_emp_no"));
						params.put("tm_yn",tr.req.getParameter("tm_yn"));
						params.put("train_yn",tr.req.getParameter("train_yn"));
						params.put("air_yn",tr.req.getParameter("air_yn"));
						params.put("bus_yn",tr.req.getParameter("bus_yn"));
						params.put("etc_yn",tr.req.getParameter("etc_yn"));
						params.put("etc_traffic",tr.req.getParameter("etc_traffic"));
						params.put("lodg_cnt",tr.req.getParameter("lodg_cnt"));
						params.put("rent_ph",tr.req.getParameter("rent_ph"));
						
						System.out.println(params);
						tr.sql.insert("pay.insertappearreques", params); 
						
						
						
		
				} else if ("JJ100964".equals(eps_type)) {
		
					params.put("exp_no", exp_no);
					params.put("meet_nm",tr.req.getParameter("meet_nm"));
					params.put("proposal_dt",StringUtil.replace(tr.req.getParameter("proposal_dt"), "-", ""));
					params.put("locate",tr.req.getParameter("locate"));
					params.put("member_cnt", tr.req.getParameter("member_cnt"));
					params.put("attend_cnt", tr.req.getParameter("attend_cnt"));
					params.put("proposal_amt", tr.req.getParameter("proposal_amt"));
					params.put("pay_acc", tr.req.getParameter("pay_acc"));
					params.put("deposit_nm",tr.req.getParameter("deposit_nm"));
					params.put("event_story", tr.req.getParameter("event_story"));
					params.put("attend_pep", tr.req.getParameter("attend_pep"));
					
					tr.sql.insert("pay.insertClubform", params); 
					
					tr.sql.delete("pay.deleteDetail", exp_no);		
					
					if (tax_dt_list != null) { 
						for (int k=0; k<tax_dt_list.length; k++) { 
							
							if (!"".equals(tax_dt_list[k])) { 

								System.out.println("tax_dt_list"+tax_dt_list[k]);
								
								
								params2.put("tax_dt", tax_dt_list[k]);
								params2.put("tax_bc", tax_bc[k]);
								params2.put("exp_no", exp_no);
								params2.put("card_no", card_no[k]);
								
								params2.put("exp_sq", (k+1));
								params2.put("dsc", dsc[k]);
								
								params2.put("exp_cd", exp_cd[k]);
								params2.put("amt", StringUtil.replace(StringUtil.normalize(amt[k], "0"), ",", ""));
								params2.put("vat", StringUtil.replace(StringUtil.normalize(vat[k], "0"), ",", ""));
								if (!"".equals(vat[k]) && !"0".equals(vat[k])) { 
									params2.put("vat_yn", "1");
								} else { 
									params2.put("vat_yn", "0");
								}
								params2.put("tot_amt", StringUtil.replace(StringUtil.normalize(tot_amt[k], "0"), ",", ""));
								params2.put("cust_cd", cust_cd[k]);
								params2.put("cust_nm", tr.req.getParameter("cust_nm"+ (k + 1))); 
								params2.put("reg_id", user.getReg_id());
								params2.put("dept_cd", dept_cd2[k]);
								params2.put("approve_no", STRACKNO[k]);
								params2.put("card_sq", STRNONESEQS[k]);
								// 결의일자 
								//프로젝트 
								params2.put("pro_cd", pro_cd[k]);
								//cost center
								//params2.put("man_cd", man_cd[k]);
								
								System.out.println(params2);
								tr.sql.insert("pay.insertDetail", params2);
							}
						
						}
					}
					
					tr.sql.update("pay.updatePayRequestEpsType", params);
					result = true;
		

		
					//수입결의서
				} else if ("JJ100210".equals(eps_type)) {
					
						tr.sql.delete("pay.deleteDetail", exp_no);
						System.out.println("수입결의서 : "+tax_dt_list);
						if (tax_dt_list != null) { 
							for (int k=0; k<tax_dt_list.length; k++) { 
								if (!"".equals(tax_dt_list[k])) { 
									params2.put("tax_dt", tax_dt_list[k]);
									params2.put("tax_bc", tax_bc[k]);
									params2.put("exp_sq", (k+1));
									params2.put("exp_no", exp_no);
									params2.put("dsc", dsc[k]);
									params2.put("exp_cd", exp_cd[k]);
									params2.put("row_ty", exp_cd[k]);
									params2.put("amt", StringUtil.replace(StringUtil.normalize(amt[k], "0"), ",", ""));
									params2.put("vat", StringUtil.replace(StringUtil.normalize(vat[k], "0"), ",", ""));
									if (!"".equals(vat[k]) && !"0".equals(vat[k])) { 
										params2.put("vat_yn", "1");
									} else { 
										params2.put("vat_yn", "0");
									}
									params2.put("tot_amt", StringUtil.replace(StringUtil.normalize(tot_amt[k], "0"), ",", ""));
									params2.put("cust_cd", cust_cd[k]);
									params2.put("cust_nm", tr.req.getParameter("cust_nm"+ (k + 1))); 
									params2.put("reg_id", user.getReg_id());
									params2.put("dept_cd", dept_cd2[k]);
									//프로젝트 
									params2.put("pro_cd", pro_cd[k]);
									//cost center
									//params2.put("man_cd", man_cd[k]);
									
									// 결의일자 
									System.out.println(params2);
									
									tr.sql.insert("pay.insertDetail", params2);
								}
							}
						}
				
					tr.sql.update("pay.updatePayRequestEpsType", params);
					result = true;
					
				
					
				} else if ("JJ100965".equals(eps_type)) {
		
					//여비 지급신청서 
					if (costemp_nm != null) { 
						for (int k=0; k<costemp_nm.length; k++) { 
							if (!"".equals(costemp_nm[k])) { 
								
								costparams3.put("exp_no",exp_no);
								costparams3.put("exp_seq", (k+1));
								costparams3.put("emp_no", costemp_no[k]);
								costparams3.put("traffic_price", traffic_price[k]);
								costparams3.put("traffic_dcnt", traffic_dcnt[k]);
								costparams3.put("traffic_tot", traffic_tot[k]);
								costparams3.put("lodgment_price", lodgment_price[k]);
								costparams3.put("lodgment_dcnt", lodgment_dcnt[k]);
								costparams3.put("lodgment_tot", lodgment_tot[k]);
								costparams3.put("food_price", food_price[k]);
								costparams3.put("food_dcnt", food_dcnt[k]);
								costparams3.put("food_tot", food_tot[k]);
								costparams3.put("tot_amt", costtot_amt[k]);
								costparams3.put("after_exp_no", tr.req.getParameter("paramexp_no"));
								costparams3.put("cid", user.getReg_id());
								System.out.println(costparams3);
								tr.sql.insert("pay.inserttravelexpenses", costparams3);
							}
						}
					}
					
				
							tr.sql.delete("pay.deleteDetail", exp_no);
							
				
							if (tax_dt_list != null) { 
								for (int k=0; k<tax_dt_list.length; k++) { 
									if (!"".equals(tax_dt_list[k])) { 
										params2.put("tax_dt", tax_dt_list[k]);
										params2.put("tax_bc", tax_bc[k]);
										params2.put("exp_no", exp_no);
										params2.put("card_no", card_no[k]);
										
										params2.put("exp_sq", (k+1));
										params2.put("dsc", dsc[k]);
										
										params2.put("exp_cd", exp_cd[k]);
										params2.put("amt", StringUtil.replace(StringUtil.normalize(amt[k], "0"), ",", ""));
										params2.put("vat", StringUtil.replace(StringUtil.normalize(vat[k], "0"), ",", ""));
										if (!"".equals(vat[k]) && !"0".equals(vat[k])) { 
											params2.put("vat_yn", "1");
										} else { 
											params2.put("vat_yn", "0");
										}
										params2.put("tot_amt", StringUtil.replace(StringUtil.normalize(tot_amt[k], "0"), ",", ""));
										params2.put("cust_cd", cust_cd[k]);
										params2.put("cust_nm", tr.req.getParameter("cust_nm"+ (k + 1))); 
										params2.put("reg_id", user.getReg_id());
										params2.put("dept_cd", dept_cd2[k]);
										//프로젝트 
										params2.put("pro_cd", pro_cd[k]);
										//cost center
										//params2.put("man_cd", man_cd[k]);
										
										// 결의일자 
										System.out.println(params2);
										
										tr.sql.insert("pay.insertDetail", params2);
									}
								}
							}
						
						tr.sql.update("pay.updatePayRequestEpsType", params);
						
				}else if ("JJ100610".equals(eps_type)) {
				
					params.put("exp_no", exp_no);
					params.put("sub_exp_no", tr.req.getParameter("sub_exp_no"));
					params.put("cfr_day_start",  StringUtil.replace(tr.req.getParameter("cfr_day_start"), "-", ""));
		
					params.put("cfr_start_hh", tr.req.getParameter("cfr_start_hh"));
					params.put("cfr_start_mm", tr.req.getParameter("cfr_start_mm"));
					
					params.put("cfr_day_end", StringUtil.replace(tr.req.getParameter("cfr_day_end"), "-", ""));
					params.put("cfr_end_hh", tr.req.getParameter("cfr_end_hh"));
					params.put("cfr_end_mm", tr.req.getParameter("cfr_end_mm"));
					params.put("work_type", tr.req.getParameter("work_type"));
					params.put("work_place", tr.req.getParameter("work_place"));
					params.put("work_story", tr.req.getParameter("work_story"));
					params.put("cfr_time", tr.req.getParameter("cfr_time"));
					System.out.println("============"+params);
					tr.sql.insert("pay.insertHolidayworkcfr", params);
					
				//휴일근무일괄처리
				}else if ("JJ100630".equals(eps_type)) {
					
					tr.sql.delete("pay.deleteHoliComBatch", exp_no);	
					
					System.out.println("여기"+tr.req.getParameter("holiday_start"));
					if (rec_emp_no != null) { 
						for (int k=0; k<rec_emp_no.length; k++) { 
							if (!"".equals(rec_emp_no[k])) { 
								params.put("exp_no", exp_no);
								params.put("exp_sq", (k+1));
								params.put("requester", rec_emp_no[k]);
								params.put("holiday_start", holiday_start[k]);
// 								params.put("start_hh", start_hh[k]);
// 								params.put("start_mm", start_mm[k]);
								params.put("holiday_end", holiday_end[k]);
// 								params.put("end_hh", end_hh[k]);
// 								params.put("end_mm", end_mm[k]);
								params.put("work_type", work_type[k]);
								params.put("work_typeYN", work_typeYN[k]);
								params.put("work_place", tr.req.getParameter("work_place"+ (k + 1)));
 								params.put("work_story", "일괄근무(홈경기)");
 								
								tr.sql.insert("pay.insertHolidayworkcBatch", params);
							}
						}
					} 
				
					
				//dy.kim  징계요청서
				}else if ("JJ100966".equals(eps_type)) {
				
					params.put("exp_no", exp_no);
					params.put("disciper", tr.req.getParameter("rec_emp_no"));
					params.put("discip_story", tr.req.getParameter("discip_story"));
					params.put("discip_dt",  StringUtil.replace(tr.req.getParameter("discip_dt"), "-", ""));
		
					tr.sql.insert("pay.insertDiscip", params);
					
				//dy.kim  배차신청서
				}else if ("JJ100967".equals(eps_type) || "JJ100714".equals(eps_type)) {
									//데이터 배열 합치기   
					int car_all = 0;

					car_all = (car_gbn_car.length+Integer.parseInt(dodelete_cnt)); 
					
					 String drive_typeString[] = new String[car_all];
					 String guest_cdString[]= new String[car_all];
					 String mkor_cdString[]= new  String[car_all];  

					 int car_stst11 = 0;
			 		 for(int car_ch2= 1; car_ch2<=(car_gbn_car.length+car_all); car_ch2++)
					{
			 			if(tr.req.getParameter("drive_type"+car_ch2) != null)
						{
							drive_typeString[car_stst11] = tr.req.getParameter("drive_type"+car_ch2);
							guest_cdString[car_stst11] = tr.req.getParameter("guest_cd" + car_ch2);
							mkor_cdString[car_stst11] = tr.req.getParameter("mkor_cd" + car_ch2);
							car_stst11++;
						}
					} 

			 		 int ck_carch=0;
			 		 
					// 배차가 배정되어 있는지 확인할때 사용한다 
					// 이병운 
		 			if (car_gbn_car != null) { 
						for (int k=0; k<car_gbn_car.length; k++) { 
							if (!"".equals(car_gbn_car[k])) { 


								params_carsh.put("exp_no", exp_no);
						 		params_carsh.put("requester", mrec_emp_no);
					 			params_carsh.put("drive_reason", drive_reason);

								params_carsh.put("exp_seq", (k+1));
								params_carsh.put("form_drive_dt", form_drive_dt[k]);
								params_carsh.put("to_drive_dt", to_drive_dt[k]);
								params_carsh.put("drive_dt", drive_dt[k]);
								params_carsh.put("drive_sel", drive_typeString[k]);
								params_carsh.put("car_gbn", car_gbn_car[k]);
								params_carsh.put("drive_guest",guest_cdString[k]);
								params_carsh.put("drive_mkor", mkor_cdString[k]);
								params_carsh.put("reg_id", user.getReg_id());
								System.out.println("params_carsh----"+params_carsh);
					 			
								String Carch =(String)tr.sql.selectObject("pay.Chk_selectCarch", params_carsh);
								
								System.out.println("Carch----"+Carch);
								
									if("N".equals(Carch))
									{
										ck_carch=ck_carch+1;
										
										
									}
									
								}
																
							}
						}
		 			
		 			//배차신청 내역 삭제
					tr.sql.delete("pay.deletecarsch_Mitsubishi", exp_no);
					System.out.println("ck_carch-----"+ck_carch);
					
					if(ck_carch<1)
					{
			 			params.put("exp_no", exp_no);
			 			params.put("requester", mrec_emp_no);
			 			params.put("drive_reason", drive_reason);
	
						
			 			if (car_gbn_car != null) { 
							for (int k=0; k<car_gbn_car.length; k++) { 
								if (!"".equals(car_gbn_car[k])) { 
									
									params.put("exp_seq", (k+1));
									params.put("form_drive_dt", form_drive_dt[k]);
									params.put("to_drive_dt", to_drive_dt[k]);
									params.put("drive_dt", drive_dt[k]);
									params.put("drive_sel", drive_typeString[k]);
									params.put("car_gbn", car_gbn_car[k]);
									params.put("drive_guest",guest_cdString[k]);
									params.put("drive_mkor", mkor_cdString[k]);
									params.put("reg_id", user.getReg_id());
									System.out.println("car----"+params);
									tr.sql.insert("pay.insertCarsch_M", params);
																	
								}
							}
						}
			 			else
			 			{
	
							params.put("exp_seq", "1");
							tr.sql.insert("pay.insertCarsch_M", params);
							
			 			}

			 			Test="true";
			 			
					}
					else
					{
						

						 tr.sql.delete("pay.delete_emb100", exp_no); 
						Test="배차가 중복이 됩니다. 확인후 등록해주세요.";
						
					}
					
					
				
					//조유리  배차사용보고서
				}else if ("JJ100715".equals(eps_type)) {
									
					int car_all = 0;

					car_all = (car_gbn_car.length+Integer.parseInt(dodelete_cnt)); 
					
					 String drive_typeString[] = new String[car_all];
					 String guest_cdString[]= new String[car_all];
					 String mkor_cdString[]= new  String[car_all];  

					 int car_stst11 = 0;
			 		 for(int car_ch2= 1; car_ch2<=(car_gbn_car.length+car_all); car_ch2++)
					{
			 			if(tr.req.getParameter("drive_type"+car_ch2) != null)
						{
							drive_typeString[car_stst11] = tr.req.getParameter("drive_type"+car_ch2);
							guest_cdString[car_stst11] = tr.req.getParameter("guest_cd" + car_ch2);
							mkor_cdString[car_stst11] = tr.req.getParameter("mkor_cd" + car_ch2);
							car_stst11++;
						}
					} 
		 			
			 		 
			 		 tr.sql.delete("pay.deleteCarschReport_Mitsubishi", exp_no); 
			 		 
						
			 			if (car_gbn_car != null) { 
							for (int k=0; k<car_gbn_car.length; k++) { 
								if (!"".equals(car_gbn_car[k])) { 
									params.put("exp_seq", (k+1));
									params.put("paramexp_no", tr.req.getParameter("paramexp_no"));
									params.put("form_drive_dt", form_drive_dt[k]);
									params.put("to_drive_dt", to_drive_dt[k]);
									params.put("drive_dt", drive_dt[k]);
									params.put("drive_sel", drive_typeString[k]);
									params.put("car_gbn", car_gbn_car[k]);
									params.put("drive_guest",guest_cdString[k]);
									params.put("drive_mkor", mkor_cdString[k]);
									params.put("reg_id", user.getReg_id());
									System.out.println("car----"+params);
									tr.sql.insert("pay.insertCarschReport_Mitsubishi", params);
																	
								}
							}
						}
			 			else
			 			{
	
							params.put("exp_seq", "1");
							tr.sql.insert("pay.insertCarschReport_Mitsubishi", params);
							
			 			}

					
			 			
					
				//dy.kim  차량정비의뢰서
				}else if ("JJ100968".equals(eps_type)) {
					
					tr.sql.delete("pay.deleteDetail2", exp_no);
				
		 			params.put("exp_no", exp_no);
					params.put("driver", tr.req.getParameter("rec_emp_no"));
					params.put("car_no", tr.req.getParameter("car_no1"));
					params.put("car_type", tr.req.getParameter("car_type"));
					params.put("car_distance", tr.req.getParameter("car_distance"));
					params.put("commi_dt",  StringUtil.replace(tr.req.getParameter("commi_dt"), "-", ""));
					params.put("carma_comp", tr.req.getParameter("carma_comp"));
					params.put("ma_com", tr.req.getParameter("ma_com"));		
		
					tr.sql.insert("pay.insertCarma", params); 
					
					
		 			if (carma_no != null) { 
						for (int k=0; k<carma_no.length; k++) { 
							if (!"".equals(carma_no[k])) { 
								
		
								appeatparams2.put("exp_no", exp_no);
								appeatparams2.put("exp_seq", (k+1));
								appeatparams2.put("carma_cont", tr.req.getParameter("carma_cont" + (k + 1)));
								appeatparams2.put("carma_su", tr.req.getParameter("carma_su" + (k + 1)));
								appeatparams2.put("carma_amt", tr.req.getParameter("carma_amt" + (k + 1)));
								appeatparams2.put("carma_etc", tr.req.getParameter("carma_etc" + (k + 1)));
								appeatparams2.put("cid", user.getReg_id());
								System.out.println(appeatparams2);
								tr.sql.insert("pay.insertCarmadata", appeatparams2);
							}
						}
					} 
					
		 		//dy.kim  손망실보고서	
				}else if ("JJ100969".equals(eps_type)) {
				
		 			params.put("exp_no", exp_no);
					params.put("ls_name", tr.req.getParameter("rec_emp_no"));
					params.put("division", tr.req.getParameter("division"));
					params.put("ls_item", tr.req.getParameter("ls_item"));
					params.put("ls_dt",  StringUtil.replace(tr.req.getParameter("ls_dt"), "-", ""));			
					params.put("ls_no", tr.req.getParameter("ls_no"));
					params.put("ls_content", tr.req.getParameter("ls_content"));
					params.put("action", tr.req.getParameter("action"));
					
					
					tr.sql.insert("pay.insertLossdamage", params);
					
				//dy.kim  자산불출의뢰서
				}else if ("JJ100970".equals(eps_type)) {
				
		 			params.put("exp_no", exp_no);
					params.put("requester", tr.req.getParameter("rec_emp_no"));
					params.put("ass_item", tr.req.getParameter("ass_item"));
					params.put("ass_no", tr.req.getParameter("ass_no"));
					params.put("ass_start_dt",  StringUtil.replace(tr.req.getParameter("ass_start_dt"), "-", ""));
					params.put("ass_end_dt",  StringUtil.replace(tr.req.getParameter("ass_end_dt"), "-", ""));
					
					params.put("ass_reason", tr.req.getParameter("ass_reason"));
		
					
					tr.sql.insert("pay.insertAssetno", params);
				
				//교육신청서	
				}else if ( ("JJ100972".equals(eps_type)) ||  ("JJ100711".equals(eps_type)) ) {
				
					params.put("exp_no", exp_no);
					//params.put("emp_no",tr.req.getParameter("emp_no"));
					//자신만으로 수정
					params.put("emp_no",user.getEmp_no());
					params.put("edu_sel", tr.req.getParameter("edu_sel"));
					params.put("edu_start_dt",  StringUtil.replace(tr.req.getParameter("edu_start_dt"), "-", ""));
					params.put("edu_end_dt", StringUtil.replace(tr.req.getParameter("edu_end_dt"), "-", ""));
					params.put("total_period", tr.req.getParameter("total_period"));
					params.put("edu_time", tr.req.getParameter("edu_time"));
					params.put("edu_locate", tr.req.getParameter("edu_locate"));
					params.put("edu_name", tr.req.getParameter("edu_name"));
					params.put("edu_organ", tr.req.getParameter("edu_organ"));
					params.put("edu_purpose", tr.req.getParameter("edu_purpose"));
					params.put("edu_content", tr.req.getParameter("edu_content"));
					params.put("edu_cost", tr.req.getParameter("edu_cost"));
					params.put("edu_other", tr.req.getParameter("edu_other"));
					
					params.put("edu_refund", tr.req.getParameter("edu_refund"));
					params.put("real_edu_cost", tr.req.getParameter("real_edu_cost"));
					
					params.put("group_thi", tr.req.getParameter("group_thi"));
					params.put("edu_other_thi", tr.req.getParameter("edu_other_thi"));
					params.put("group_sec", tr.req.getParameter("group_sec"));
					params.put("edu_other_sec", tr.req.getParameter("edu_other_sec"));
					
					params.put("edu_bc", tr.req.getParameter("Edubc"));
					
					if("Y".equals(tr.req.getParameter("lode_out"))){
						params.put("lode_out", tr.req.getParameter("lode_out"));
					}else{
						params.put("lode_out", "N");
					}
					
// 					if("Y".equals(tr.req.getParameter("edu_refund"))){
// 						params.put("edu_refund", tr.req.getParameter("edu_refund"));
// 					}else{
// 						params.put("edu_refund", "N");
// 					}
					
// 					if("Y".equals(tr.req.getParameter("real_edu_cost"))){
// 						params.put("real_edu_cost", tr.req.getParameter("real_edu_cost"));
// 					}else{
// 						params.put("real_edu_cost", "N");
// 					}
					
					/* 미쯔비시 컬럼추가 */
					params.put("edu_type", tr.req.getParameter("edu_type"));
					params.put("edu_effect", tr.req.getParameter("edu_effect"));
					params.put("edu_summary", tr.req.getParameter("edu_summary"));
					
					
					tr.sql.insert("pay.insertEducateForm", params);
					System.out.println("paramsparams---"+params);
					

		 			if (edure_dt != null) { 
						for (int k=0; k<edure_dt.length; k++) { 
							if (!"".equals(edure_dt[k])) { 
								
		
								appeatparams2.put("exp_no", exp_no);
								appeatparams2.put("exp_seq", (k+1));
								appeatparams2.put("carma_cont", tr.req.getParameter("carma_cont" + (k + 1)));
								appeatparams2.put("carma_su", tr.req.getParameter("carma_su" + (k + 1)));
								appeatparams2.put("carma_amt", tr.req.getParameter("carma_amt" + (k + 1)));
								appeatparams2.put("carma_etc", tr.req.getParameter("carma_etc" + (k + 1)));
								appeatparams2.put("cid", user.getReg_id());
								System.out.println(appeatparams2);
								tr.sql.insert("pay.insertCarmadata", appeatparams2);
							}
						}
					} 
		 			
		 			/* int Edu_Form = 0;
		 			Edu_Form = edure_dt.length+Integer.parseInt(dodelete_cnt); 
					
// 					System.out.println("business_Accounts---"+business_Accounts);
					
					 String edure_remark_String[] = new String[Edu_Form];
					 String edure_time_String[] = new String[Edu_Form];

					 int Edu_Form11 = 0;
			 		 for(int Edu_ch2= 1; Edu_ch2<=Edu_Form; Edu_ch2++)
					{
			 			if(tr.req.getParameter("edure_remark"+Edu_ch2) != null)
						{ 
			 				edure_remark_String[Edu_Form11] = tr.req.getParameter("edure_remark"+Edu_ch2);
			 				edure_time_String[Edu_Form11] = tr.req.getParameter("edure_time"+Edu_ch2);
			 				
			 				Edu_Form11++;
						}
					} 

		 			System.out.println("여기111----");
					tr.sql.delete("pay.deleteEdu_dt_Mitsubishi", exp_no); 
					
					if(edure_dt != null)
					{
						for(int row = 0; row<edure_dt.length; row ++)
						{
							if(!"".equals(edure_dt[row]))
							{
								params_sub.put("exp_no", exp_no);
								params_sub.put("exp_sq", (row+1));
								params_sub.put("edure_remark", edure_remark_String[row]);
								params_sub.put("edure_time", edure_time_String[row]); 
								params_sub.put("edure_dt", edure_dt[row]);
								params_sub.put("edu_start_hh", edu_start_hh[row]);
								params_sub.put("edu_end_hh", edu_end_hh[row]);
								params_sub.put("cid", user.getReg_id());
								
								System.out.println("여기11133----" + params_sub);

								tr.sql.insert("pay.insertEdu_dt_Mitsubishi", params_sub);
							}
						}
					}
					*/
					
				//교육결과보고서	
				}else if ( ("JJ100973".equals(eps_type)) ||  ("JJ100712".equals(eps_type)) ) {
					
					params.put("exp_no", exp_no);
					params.put("re_exp_no", tr.req.getParameter("re_exp_no"));
					params.put("re_content", tr.req.getParameter("re_content"));
					params.put("re_comment", tr.req.getParameter("re_comment"));
		
					System.out.print(params);
					tr.sql.insert("pay.insertEducateReuslt", params);
						
				//불참보고서
				}else if ( ("JJ100974".equals(eps_type)) ||  ("JJ100713".equals(eps_type)) ) {
						
					params.put("exp_no", exp_no);
					params.put("not_exp_no", tr.req.getParameter("not_exp_no"));
					params.put("not_reason", tr.req.getParameter("not_reason"));
					/*미쯔비시 추가*/
					params.put("not_type", tr.req.getParameter("not_type"));
					params.put("alter_dt", tr.req.getParameter("alter_dt"));
					
					
					/* 미쯔비시 컬럼추가 */
					params.put("edu_type", tr.req.getParameter("edu_type"));
					params.put("edu_effect", tr.req.getParameter("edu_effect"));
					params.put("edu_summary", tr.req.getParameter("edu_summary"));
					
					System.out.println("11111211" + params);
					
					tr.sql.insert("pay.insertEducateNotForm", params);
								
				//화환신청서
				}else if ("JJ100975".equals(eps_type)) {
						
					params.put("exp_no", exp_no);
					params.put("requester", tr.req.getParameter("rec_emp_no"));
					params.put("division", tr.req.getParameter("division"));
					params.put("request_dt",  StringUtil.replace(tr.req.getParameter("request_dt"), "-", ""));
					params.put("re_target", tr.req.getParameter("re_target"));
					params.put("recipient", tr.req.getParameter("recipient"));
					params.put("address", tr.req.getParameter("address"));
					params.put("relation", tr.req.getParameter("relation"));
					params.put("reason", tr.req.getParameter("reason"));
		
					tr.sql.insert("pay.insertGarland", params);
				
				//대우 거래처 경조금&경조화환 신청서
				}else if ("JJ100432".equals(eps_type)) {
						
					params.put("exp_no", exp_no);
					params.put("requester", tr.req.getParameter("rec_emp_no"));
					params.put("division", tr.req.getParameter("division"));
					params.put("request_dt",  StringUtil.replace(tr.req.getParameter("request_dt"), "-", ""));
					params.put("re_target", tr.req.getParameter("re_target"));
					params.put("recipient", tr.req.getParameter("recipient"));
					params.put("address", tr.req.getParameter("address"));
					params.put("relation", tr.req.getParameter("relation"));
					params.put("reason", tr.req.getParameter("reason"));
					
					if("Y".equals(tr.req.getParameter("fl_yn"))){
						params.put("fl_yn", tr.req.getParameter("fl_yn"));
					}else{
						params.put("fl_yn", "N");
					}
					if("Y".equals(tr.req.getParameter("con_yn"))){
						params.put("con_yn", tr.req.getParameter("con_yn"));
						params.put("con_cost", tr.req.getParameter("con_cost"));
					}else{
						params.put("con_yn", "N");
					}
					params.put("currency", tr.req.getParameter("currency"));
					
					tr.sql.insert("pay.insertGarland_DW", params);
					
				//신규 거래처 등록
				} else if ("JJ100435".equals(eps_type)) {

					params.put("exp_no", exp_no);
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("cust_cd", tr.req.getParameter("cust_cd"));
					params.put("cust_nm", tr.req.getParameter("cust_nm"));
					params.put("ins_upt", tr.req.getParameter("ins_upt_hid"));
					params.put("nat_cd", tr.req.getParameter("c_nat_cd"));
					params.put("nat_nm", tr.req.getParameter("c_nat_nm"));
					params.put("prt_nm", tr.req.getParameter("prt_nm"));
					params.put("addr_prt", tr.req.getParameter("addr_prt"));
					params.put("cust_enm", tr.req.getParameter("cust_enm"));
					params.put("cust_kd", tr.req.getParameter("cust_kd"));
					params.put("cust_bc", tr.req.getParameter("cust_bc"));
					params.put("pur_tax_bc", tr.req.getParameter("pur_tax_bc"));
					params.put("biz_no", tr.req.getParameter("biz_no"));
					params.put("pur_terms", tr.req.getParameter("pur_terms"));
					params.put("ceo_nm", tr.req.getParameter("ceo_nm"));
					params.put("biz_type", tr.req.getParameter("biz_type"));
					params.put("sal_tax_bc", tr.req.getParameter("sal_tax_bc"));
					params.put("sal_terms", tr.req.getParameter("sal_terms"));
					params.put("biz_kind", tr.req.getParameter("biz_kind"));
					params.put("high_cust", tr.req.getParameter("high_cust"));
					params.put("use_yn", "1");
					params.put("cid", user.getReg_id());
					params.put("tms_flag", "1".equals(tr.req.getParameter("tms_flag")) ? "1" : "0");
					params.put("truck_no", tr.req.getParameter("truck_no"));
					
					System.out.println("신규거래처 ----- "+params);
					tr.sql.insert("pay.insertNewCustomer", params);
					
					int pay_all = 0;
					int pay_sts = 0;
					pay_all =  (Integer.parseInt(dodelete_cnt)); 
					
					 String acct_nm_String[] = new String[pay_all];
					 String acct_no_String[] = new String[pay_all];
					 String rmks_String[] = new String[pay_all];

					 String abrd_acctno_String[] = new String[pay_all];
					 String swift_String[] = new String[pay_all];
					 String bic_String[] = new String[pay_all];
					 String iban_String[] = new String[pay_all];
					 
					 String p_bas_yn[] = new String[pay_all];
					 String p_del_yn[] = new String[pay_all];
					 
			 		 for(int pay_temp = 0; pay_temp<pay_all; pay_temp++)
					{
			 			if(tr.req.getParameter("acct_no"+pay_temp) != null)
						{
			 				acct_nm_String[pay_sts] = tr.req.getParameter("acct_nm"+pay_temp).toUpperCase();
			 				acct_no_String[pay_sts] = tr.req.getParameter("acct_no"+pay_temp);
			 				rmks_String[pay_sts] = tr.req.getParameter("rmks"+pay_temp);
			 				abrd_acctno_String[pay_sts] = tr.req.getParameter("abrd_acctno"+pay_temp).toUpperCase();
			 				swift_String[pay_sts] = tr.req.getParameter("swift"+pay_temp).toUpperCase();
			 				bic_String[pay_sts] = tr.req.getParameter("bic"+pay_temp).toUpperCase();
			 				iban_String[pay_sts] = tr.req.getParameter("iban"+pay_temp).toUpperCase();
			 				
			 				if(tr.req.getParameter("bas_yn"+pay_temp)==null){
			 					p_bas_yn[pay_sts] = "0";
			 				}
			 				else{
			 					p_bas_yn[pay_sts] = "1";
			 				}
			 				if(tr.req.getParameter("del_yn"+pay_temp)==null){
			 					p_del_yn[pay_sts] = "0";
			 				}
			 				else{
			 					p_del_yn[pay_sts] = "1";
			 				}
							pay_sts++;
						}
					} 
			 		tr.sql.delete("pay.deleteDetail_NewCustomer", exp_no);
 			 		
			 		if (p_acct_no != null){
			 		
						for(int k=0; k<p_acct_no.length; k++){
							if (!"".equals(p_acct_no[k])) { 
								params2.put("exp_no", exp_no); 
								params2.put("cls_acct", cls_acct[k]);
								params2.put("crcd", crcd[k]);
								params2.put("bank_cd",bank_cd[k]);
								params2.put("nat_cd", nat_cd[k]);
								
								params2.put("acct_nm", acct_nm_String[k]);
								params2.put("acct_no", acct_no_String[k]);
								params2.put("abrd_acctno",abrd_acctno_String[k]);
								params2.put("rmks", rmks_String[k]);
								params2.put("swift", swift_String[k]);
								params2.put("bic", bic_String[k]);
								params2.put("iban",iban_String[k]);
								params2.put("bas_yn",p_bas_yn[k]);
								params2.put("del_yn",p_del_yn[k]);
								
								params2.put("exp_sq", (k+1));
								params2.put("cid", user.getReg_id());
								
								System.out.println("은행계좌 ----- "+params2);
								tr.sql.insert("pay.insertNewCustomerPay", params2);
							}
						}
					} 
					 
			 // 종사업장		
			 	 	 int place_all = 0;
					int place_sts = 0;
					place_all =  (Integer.parseInt(dodelete_cnt1)); 
					
					 String minor_place_no_String[] = new String[place_all];
					 String minor_place_cust_nm_String[] = new String[place_all];
					 String minor_place_biz_reg_no_String[] = new String[place_all];

					
			 		 for(int place_temp = 0; place_temp<place_all; place_temp++)
					{
			 			 
			 			System.out.println("palace_temp : "+place_temp+"place_all : "+place_all);
			 			if(tr.req.getParameter("minor_place_no"+place_temp) != null)
						{
			 				minor_place_no_String[place_sts] = tr.req.getParameter("minor_place_no"+place_temp);
			 				minor_place_cust_nm_String[place_sts] = tr.req.getParameter("minor_place_cust_nm"+place_temp);
			 				minor_place_biz_reg_no_String[place_sts] = tr.req.getParameter("minor_place_biz_reg_no"+place_temp);
			 				place_sts++;
						}
					}  
			 		tr.sql.delete("pay.deleteDetail_NewCustomer2", exp_no);
			 		
			 		if (p_minor_place_no != null){
			 		
						for(int k=0; k<p_minor_place_no.length; k++){
							
							System.out.println(p_minor_place_no[0]+"minor_index---- ");
							if (!"".equals(p_minor_place_no[k])) { 
								
								System.out.println(exp_no+"exp_no----- ");
								
								
								System.out.println(minor_place_cust_nm_String[k]+"종사업장명String ----- ");
								
								params3.put("exp_no", exp_no); 
								params3.put("minor_place_no", minor_place_no_String[k]);
								params3.put("minor_place_cust_nm", minor_place_cust_nm_String[k]);
								params3.put("minor_place_biz_reg_no", minor_place_biz_reg_no_String[k]);
								params3.put("exp_sq", (k+1));
								params3.put("cid", user.getReg_id());
								
								System.out.println("종사업장 ----- "+params3);
								tr.sql.insert("pay.insertNewCustomerPlace", params3);
							}
						}
					} 
	
			 		
				//계약기안서
				}else if ("JJ100911".equals(eps_type)) {

					params.put("exp_no", exp_no);
					params.put("cont_dt", tr.req.getParameter("cont_dt"));
					params.put("cont_no", tr.req.getParameter("cont_no"));
					params.put("profit_no", tr.req.getParameter("profit_no"));
					params.put("cust_cd", tr.req.getParameter("p_cust_cd"));
					params.put("ins_upt", tr.req.getParameter("ins_upt"));
					params.put("cd_vessel", tr.req.getParameter("cd_vessel"));
					params.put("cid", user.getReg_id());
					params.put("cont_type", tr.req.getParameter("cont_type"));
					System.out.println("계약기안서 ----- "+params);
					tr.sql.insert("pay.insertContGian", params);
					
										 
				//회의록
				}else if ("JJ100976".equals(eps_type)) {
						
			 	params.put("exp_no", exp_no);
				params.put("meeting_dt",  StringUtil.replace(tr.req.getParameter("meeting_dt"), "-", ""));
				params.put("meeting_locate", tr.req.getParameter("meeting_locate"));
				params.put("attendee", tr.req.getParameter("rec_emp_nm"));
				params.put("oc_attendee", tr.req.getParameter("rec_emp_nm2"));
				params.put("item", tr.req.getParameter("item"));
			
				tr.sql.insert("pay.insertProceedings", params); 
								
				//자기계발비   //체력단련비	 //통신비 지원비 
				}else if ("JJ100977".equals(eps_type) || "JJ100430".equals(eps_type) || "JJ100431".equals(eps_type)) {
		
				params.put("exp_no", exp_no);
				params.put("requester", tr.req.getParameter("rec_emp_no"));
				params.put("request_dt",  StringUtil.replace(tr.req.getParameter("request_dt"), "-", ""));
				params.put("ap_amt", tr.req.getParameter("ap_amt"));
				
				tr.sql.insert("pay.insertSelfDpFee", params);
				
				//문서보안 사외반출 신청서
				}else if ("JJ100978".equals(eps_type)) {
		
				params.put("exp_no", exp_no);
				params.put("requester", tr.req.getParameter("rec_emp_no"));
				params.put("doc_start_dt",  StringUtil.replace(tr.req.getParameter("doc_start_dt"), "-", ""));
				params.put("doc_end_dt",  StringUtil.replace(tr.req.getParameter("doc_end_dt"), "-", ""));
				params.put("request_doc", tr.req.getParameter("request_doc"));
				params.put("reason", tr.req.getParameter("reason"));
				params.put("etc", tr.req.getParameter("etc"));
				
				tr.sql.insert("pay.insertDocSeEo", params);
		
								
				//대출금 신청서
				}else if ("JJ100979".equals(eps_type)) {
		
				params.put("exp_no", exp_no);
				params.put("requester", tr.req.getParameter("rec_emp_no"));
				params.put("request_dt",  StringUtil.replace(tr.req.getParameter("request_dt"), "-", ""));
				params.put("repay_mm", tr.req.getParameter("repay_mm"));
				params.put("ap_amt", tr.req.getParameter("ap_amt"));
				params.put("reason", tr.req.getParameter("reason"));
				
				tr.sql.insert("pay.insertLoans", params);
		
		
				
				//인력계획서/충원요청서
				}else if ("JJ100980".equals(eps_type)) {
		
					params.put("exp_no", exp_no);
					
					tr.sql.insert("pay.DeleteStaffDrafts", exp_no);
					System.out.println("position.length---" + position.length);
				
					String[] reason = request.getParameterValues("reason");
					String[] division = request.getParameterValues("division");
					String[] sd_pepole = request.getParameterValues("sd_pepole");
					String[] job = request.getParameterValues("job");
					String[] age = request.getParameterValues("age");
					String[] sex = request.getParameterValues("sex");
					String[] specialty = request.getParameterValues("specialty");
					String[] career = request.getParameterValues("career");
					String[] dept = request.getParameterValues("dept");
					String[] emp_type = request.getParameterValues("emp_type");
					String[] education = request.getParameterValues("education");
					String[] res_job = request.getParameterValues("res_job");
					String[] for_language = request.getParameterValues("for_language");
					String[] com_skill = request.getParameterValues("com_skill");
					String[] certification = request.getParameterValues("certification");
					String[] bs_skill = request.getParameterValues("bs_skill");
					String[] prd_location = request.getParameterValues("prd_location");
				
					for (int k = 0; k < position.length; k++) {
				
						if (position[k] != null) {
							params.put("exp_seq", (k + 1));
							params.put("reason", reason[k]);
							params.put("division", division[k]);
							params.put("sd_pepole", sd_pepole[k]);
							params.put("job", job[k]);
							params.put("position", position[k]);
							params.put("age", age[k]);
							params.put("sex", sex[k]);
							params.put("specialty", specialty[k]);
							params.put("career", career[k]);
							params.put("dept", dept[k]);
							params.put("emp_type", emp_type[k]);
							params.put("education", education[k]);
							params.put("res_job", res_job[k]);
							params.put("for_language", for_language[k]);
							params.put("com_skill", com_skill[k]);
							params.put("certification", certification[k]);
							params.put("bs_skill", bs_skill[k]);
							params.put("prd_location", prd_location[k]);
				
							System.out.println("params1---" + params);
							tr.sql.insert("pay.insertStaffDrafts", params);
						}
				
					}
				
				//윤리경영제보
				}else if ("JJ100420".equals(eps_type)) {
				params.put("exp_no", exp_no);
				params.put("eth_seq", tr.req.getParameter("eth_seq"));
				params.put("eth_exp_no", tr.req.getParameter("eth_exp_no"));
				params.put("comment", tr.req.getParameter("comment"));
				params.put("cid", user.getReg_id());
				tr.sql.insert("pay.insertEthicsReport", params);
				
				//고정자산처분
				}else if ("JJ100260".equals(eps_type)) {
				params.put("exp_no", exp_no);
				params.put("gubun", tr.req.getParameter("gubun"));
				params.put("ast_no", tr.req.getParameter("ast_no"));
				params.put("ast_nm", tr.req.getParameter("ast_nm"));
				params.put("get_dt", tr.req.getParameter("get_dt"));
				params.put("life_year", tr.req.getParameter("life_year"));
				params.put("get_amt", tr.req.getParameter("get_amt"));
				params.put("fin_date", tr.req.getParameter("fin_date"));
				params.put("unit", tr.req.getParameter("unit"));
				params.put("amt", tr.req.getParameter("amt"));
				params.put("sel_amt", tr.req.getParameter("sel_amt"));
				params.put("all_amt", tr.req.getParameter("all_amt"));
				params.put("now_amt", tr.req.getParameter("now_amt"));
				params.put("comment", tr.req.getParameter("comment"));
				params.put("cid", user.getReg_id());
				
				System.out.println("고정자산처분  ::: "+params);
				tr.sql.insert("pay.insertFixedassets", params);					
				
				//포상추천서
				}else if ("JJ100530".equals(eps_type)) {
			
				params.put("exp_no", exp_no);
				params.put("prizeemp_no", tr.req.getParameter("prizeEmp_cd"));
				params.put("prize_gbn", tr.req.getParameter("prize_gbn"));
				params.put("pize_year", tr.req.getParameter("prizeYear_cd"));
				params.put("prize_month_cd", tr.req.getParameter("prizeMonth_cd"));
				params.put("prizeemp_name", tr.req.getParameter("prizeemp_nm"));
				params.put("prizeemp_dept", tr.req.getParameter("prizedept_nm"));
				tr.sql.insert("pay.insertPrizepropose", params);
				
				
				
		
				
				//물품청구서
				}else if ("JJ100971".equals(eps_type)) {
					
					tr.sql.delete("pay.deleteDetail3", exp_no);
		
		 			if (article_no != null) { 
						for (int k=0; k<article_no.length; k++) { 
							if (!"".equals(article_no[k])) { 
								
		
								appeatparams2.put("exp_no", exp_no);
								appeatparams2.put("exp_seq", (k+1));
								appeatparams2.put("article_cd", tr.req.getParameter("itm_cd" + (k + 1)));
								appeatparams2.put("app_qa", tr.req.getParameter("app_qa" + (k + 1)));
								appeatparams2.put("note", tr.req.getParameter("note" + (k + 1)));
								appeatparams2.put("sum_qty", tr.req.getParameter("sum_qty" + (k + 1)));
								appeatparams2.put("cid", user.getReg_id());
								System.out.println(appeatparams2);
								tr.sql.insert("pay.insertArticleBill", appeatparams2);
							}
						}
					} 
		 			
					//해운성약신청서 //해운기안서
					}else if ("JJ100990".equals(eps_type) || "JJ100991".equals(eps_type)) {
						
						params.put("exp_no", exp_no);
						params.put("type", tr.req.getParameter("type"));
						params.put("start_dt", tr.req.getParameter("start_dt"));
						params.put("end_dt", tr.req.getParameter("end_dt"));
						params.put("vessel", tr.req.getParameter("vessel"));
						params.put("voyage", tr.req.getParameter("voyage"));
						params.put("region", tr.req.getParameter("region"));
						params.put("chart_cost", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("chart_cost"), "0"), ",", ""));
						params.put("start_dt_c", tr.req.getParameter("start_dt_c"));
						params.put("end_dt_c", tr.req.getParameter("end_dt_c"));
						params.put("profit", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("profit"), "0"), ",", ""));
						params.put("cost", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("cost"), "0"), ",", ""));
						params.put("pl", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("pl"), "0"), ",", ""));
						
						params.put("supply", tr.req.getParameter("supply"));
						params.put("fo_price", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("fo_price"), "0"), ",", ""));
						params.put("do_price", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("do_price"), "0"), ",", ""));
						params.put("fo_qty", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("fo_qty"), "0"), ",", ""));
						params.put("do_qty", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("do_qty"), "0"), ",", ""));
						params.put("fo_amt", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("fo_amt"), "0"), ",", ""));
						params.put("do_amt", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("do_amt"), "0"), ",", ""));
						params.put("other_amt", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("other_amt"), "0"), ",", ""));
						params.put("desc1", tr.req.getParameter("desc1"));
						params.put("desc2", tr.req.getParameter("desc2"));
						params.put("desc3", tr.req.getParameter("desc3"));
						params.put("cid", user.getReg_id());
						
						//해운기안서 추가
						params.put("doc_no", tr.req.getParameter("doc_no"));
						params.put("cost_type", tr.req.getParameter("cost_type"));
						params.put("cust_cd", tr.req.getParameter("cust_cd"));
						params.put("biz_no", tr.req.getParameter("biz_no"));
						params.put("start_dt_a", tr.req.getParameter("start_dt_a"));
						params.put("end_dt_a", tr.req.getParameter("end_dt_a"));
						params.put("usd", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("usd"), "0"), ",", ""));
						params.put("krw", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("krw"), "0"), ",", ""));
						params.put("exc_rate_dt", tr.req.getParameter("exc_rate_dt"));
						params.put("exc_rate", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("exc_rate"), "0"), ",", ""));
						
						System.out.println("해운  ::: "+params);
						tr.sql.insert("pay.insertShipDealmaking_DW", params);	
		 			
		 			
		 			
/*============================================================================================================================================*/	

				/* 미쯔비시 */
				
				
				
		 		//일반근태신청서
				}else if ("JJ100310".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("req_item", tr.req.getParameter("req_item"));
					params.put("req_start_dt", tr.req.getParameter("req_start_dt"));
					//params.put("req_end_dt", tr.req.getParameter("req_end_dt"));
					params.put("req_st_tm", tr.req.getParameter("req_st_tm"));
					params.put("req_ed_tm", tr.req.getParameter("req_ed_tm"));
					params.put("reason", tr.req.getParameter("reason"));
					params.put("reason_detail", tr.req.getParameter("reason_detail"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertAbsence_Mitsubishi", params);
					
				//사무직 석식 식대 신청서
				}else if ("JJ100989".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("meal_dt", tr.req.getParameter("meal_dt"));
					params.put("meal_rs", tr.req.getParameter("meal_rs"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertMeal_Mitsubishi", params);
		 			
				//출입카드(명찰) 발급 신청서
				}else if ("JJ100983".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("req_item", tr.req.getParameter("req_item"));
					params.put("reason", tr.req.getParameter("reason"));
					params.put("reason_detail", tr.req.getParameter("reason_detail"));
					params.put("temp_cd", tr.req.getParameter("temp_cd"));
					params.put("contacts", tr.req.getParameter("contacts"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertAccessCard_Mitsubishi", params);
				
				
					
				//상해보험신청서
				}else if ("JJ100831".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("join_dt", tr.req.getParameter("join_dt"));
					params.put("office_tel", tr.req.getParameter("office_tel"));
					params.put("hospital_nm", tr.req.getParameter("hospital_nm"));
					params.put("symptom", tr.req.getParameter("symptom"));
					params.put("treatment", tr.req.getParameter("treatment"));
					params.put("frdate", tr.req.getParameter("frdate"));
					params.put("todate", tr.req.getParameter("todate"));
					params.put("medical_Yn", tr.req.getParameter("medical_Yn"));
					params.put("total_amt", tr.req.getParameter("total_amt"));
					params.put("mix_amt", tr.req.getParameter("mix_amt"));
					params.put("my_amt", tr.req.getParameter("my_amt"));
					params.put("cid", user.getReg_id());
					
					tr.sql.insert("pay.insertHospital_Mitsubishi", params);
				
					//비자 신청서
				 }else if ("JJ100840".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("passport_cd", tr.req.getParameter("passport_cd"));
					params.put("request_obj", tr.req.getParameter("request_obj"));
					params.put("req_dt", tr.req.getParameter("req_dt"));
					params.put("nation", tr.req.getParameter("nation"));
					params.put("app_dt", tr.req.getParameter("app_dt"));
					params.put("cid", user.getReg_id());
					
					tr.sql.insert("pay.insertpassport_Mitsubishi", params);	
				
				//숙박 신청서
				}else if ("JJ100985".equals(eps_type)) {
					//내용
					params.put("exp_no", exp_no);
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("rec_dt", tr.req.getParameter("rec_dt"));
					params.put("cid", user.getReg_id());
					
					tr.sql.insert("pay.insertlodgepay_Mitsubishi", params);	
					
					
					int lodgepay_all_work = 0;

					lodgepay_all_work = (lodge_pay.length+Integer.parseInt(dodelete_cnt)); 

					 String lodge_place_String[] = new String[lodgepay_all_work];
					 String lodge_dt_String[] = new String[lodgepay_all_work];
					 String lodge_cnt_String[] = new String[lodgepay_all_work];
					 String lodge_tel_String[] = new String[lodgepay_all_work];
					 String lodge_pay_cnt_String[] = new String[lodgepay_all_work];
					 String lodge_amt_String[] = new String[lodgepay_all_work];
					 String lodge_pay_String[] = new String[lodgepay_all_work];
						
					 
					 String pay_type_String[] = new String[lodgepay_all_work];
					 String pay_nm_String[] = new String[lodgepay_all_work];
					 String mcard_yn_String[] = new String[lodgepay_all_work];
					 String rel_remark_String[] = new String[lodgepay_all_work];
					 

					 int lodgepay11 = 0;
			 		 for(int lodgepay_ch2= 1; lodgepay_ch2<=(lodge_pay.length+lodgepay_all_work); lodgepay_ch2++)
					{
			 			if(tr.req.getParameter("lodge_place"+lodgepay_ch2) != null)
						{
			 				lodge_place_String[lodgepay11] = tr.req.getParameter("lodge_place"+lodgepay_ch2);
			 				lodge_dt_String[lodgepay11] = tr.req.getParameter("lodge_dt"+lodgepay_ch2);
			 				lodge_cnt_String[lodgepay11] = tr.req.getParameter("lodge_cnt"+lodgepay_ch2);
			 				lodge_tel_String[lodgepay11] = tr.req.getParameter("lodge_tel"+lodgepay_ch2);
			 				lodge_pay_cnt_String[lodgepay11] = tr.req.getParameter("lodge_pay_cnt"+lodgepay_ch2);
			 				lodge_amt_String[lodgepay11] = tr.req.getParameter("lodge_amt"+lodgepay_ch2);
			 				pay_type_String[lodgepay11] = tr.req.getParameter("pay_type"+lodgepay_ch2);
			 				pay_nm_String[lodgepay11] = tr.req.getParameter("pay_nm"+lodgepay_ch2);
			 				mcard_yn_String[lodgepay11] = tr.req.getParameter("mcard_yn"+lodgepay_ch2);
			 				rel_remark_String[lodgepay11] = tr.req.getParameter("rel_remark"+lodgepay_ch2);
			 				lodgepay11++;
						}
					} 
					
					
					
					//숙박신청 내역 삭제
					tr.sql.delete("pay.deletelodgepay_Mitsubishi", exp_no);
		 			

					//숙박 신청내역  신청서
					if(lodge_pay != null)
					{
						for(int row = 0; row<lodge_pay.length; row ++)
						{
							if(!"".equals(lodge_pay[row]))
							{
								
								params_sub.put("exp_no", exp_no);
								params_sub.put("exp_sq", (row+1));
								params_sub.put("lodge_place", lodge_place_String[row]);
								params_sub.put("lodge_dt", lodge_dt_String[row]);
								params_sub.put("lodge_cnt", lodge_cnt_String[row]);
								params_sub.put("lodge_tel", lodge_tel_String[row]);
								params_sub.put("lodge_pay", lodge_pay[row]);
								params_sub.put("lodge_pay_cnt", lodge_pay_cnt_String[row]);
								params_sub.put("lodge_amt", lodge_amt_String[row]);
								
								
								params_sub.put("pay_type", pay_type_String[row]);
								params_sub.put("pay_nm", pay_nm_String[row]);
								
								if("on".equals(mcard_yn_String[row]))
								{
									params_sub.put("mcard_yn", "1");
								}
								else
								{
									params_sub.put("mcard_yn", "0");	
								}
								
								params_sub.put("rel_remark", rel_remark_String[row]);
								
								System.out.println("mcard----"+params_sub);
								params_sub.put("cid", user.getReg_id());
								tr.sql.insert("pay.insertlodgepayask_Mitsubishi", params_sub);
								
								
							}
							
						}
						
					}
					
				//휴직원
				}else if ("JJ100350".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("leave_start_dt", tr.req.getParameter("leave_start_dt"));
					params.put("leave_end_dt", tr.req.getParameter("leave_end_dt"));
					params.put("contacts", tr.req.getParameter("contacts"));
					params.put("leave_reason", tr.req.getParameter("leave_reason"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertLayoff_Mitsubishi", params);
					
				
				//복직원
				}else if ("JJ100360".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("paramexp_no", tr.req.getParameter("paramexp_no"));
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("leave_cnt", tr.req.getParameter("leave_cnt"));
					params.put("reinstate_dt", tr.req.getParameter("reinstate_dt"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertReinstate_Mitsubishi", params);
					
				
				//퇴직원
				}else if ("JJ100370".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("resign_dt", tr.req.getParameter("resign_dt"));
					params.put("resign_reason", tr.req.getParameter("resign_reason"));
					params.put("other_reason", tr.req.getParameter("other_reason"));
					params.put("course", tr.req.getParameter("course"));
					params.put("opinion", tr.req.getParameter("opinion"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertResign_Mitsubishi", params);
					
					
					//퇴직원 작성시 쪽지보내기
					String note_no = "";
					
					
					params.put("note_stat","S");
					params.put("emp_sd", "Admin");
					params.put("note_title",tr.req.getParameter("rec_emp_nm")+ tr.req.getParameter("high_bc_name")+"이 퇴직원을 작성중입니다.");
					params.put("note_cont",tr.req.getParameter("rec_emp_nm")+ tr.req.getParameter("high_bc_name")+"이 퇴직원을 작성중입니다.");
					params.put("note_del","N");
					params.put("note_ccnt","1");
					params.put("note_rcvs","301818");
					params.put("cid", "1");
					//301380
					tr.sql.insert("work.insertNote", params);
					note_no = (String)params.get("Pmynote_no");
					params.put("note_no", note_no);
					
					
					
					params2.put("note_no",	note_no);
					params2.put("emp_rcv",	"301818");
					params2.put("rcv_seq",	"1");
					params2.put("note_chk","N");
					params2.put("note_del","N");
					tr.sql.insert("work.insertNoteRcv", params2); 	
				
					
			  /* 	
			  
			    
					int k=1;
					if(rcv_emp_no !=null){
						for(String emp_rcv:rcv_emp_no){
							HashMap<String, Object> params2 = new HashMap<String, Object>();
							params2.put("note_no",	note_no);
							params2.put("emp_rcv",	emp_rcv.trim());
							params2.put("rcv_seq",	k);
							params2.put("note_chk","N");
							params2.put("note_del","N");
							tr.sql.insert("work.insertNoteRcv", params2); 	
							k++;
						}
					} */

				//시간외 근무신청서
				}else if ("JJ100640".equals(eps_type)) {

					int car_all_work = 0;

					car_all_work = Integer.parseInt(dodelete_cnt); 

					 String Dt_time_st_String[] = new String[car_all_work];
					 String Dt_time_ed_String[] = new String[car_all_work];
					 String Dwork_type_String[] = new String[car_all_work];
					 String Dwork_story_String[] = new String[car_all_work];
					 String Dwor_remark_String[] = new String[car_all_work];
						

					 int car_stst11 = 0;
			 		 for(int car_ch2= 1; car_ch2<=car_all_work; car_ch2++)
					{
			 			if(tr.req.getParameter("Dt_time_st"+car_ch2) != null)
						{
			 				Dt_time_st_String[car_stst11] = tr.req.getParameter("Dt_time_st"+car_ch2);
			 				Dt_time_ed_String[car_stst11] = tr.req.getParameter("Dt_time_ed"+car_ch2);
			 				Dwork_story_String[car_stst11] = tr.req.getParameter("Dwork_story"+car_ch2);
			 				Dwor_remark_String[car_stst11] = tr.req.getParameter("Dwor_remark"+car_ch2);
							car_stst11++;
						}
					} 
					
					tr.sql.delete("pay.DeleteWorkRequest_M", exp_no);
			 		
					/* 시간외근무신청서 */ /* 시간외 수당신청서 */
		 			if (Request_work_dt != null) { 
						for (int k=0; k<Request_work_dt.length; k++) { 
							if (!"".equals(Request_work_dt[k])) { 
								
								params_work.put("exp_no", exp_no);
								params_work.put("exp_seq", (k+1));
								params_work.put("work_dt", Request_work_dt[k]);
								params_work.put("emp_no", Request_emp_no[k]);
								params_work.put("work_type", Request_Dwork_type[k]);
								params_work.put("time_st", Dt_time_st_String[k]);
								params_work.put("time_ed", Dt_time_ed_String[k]);
								params_work.put("work_story", Dwork_story_String[k]);
								params_work.put("wor_remark", Dwor_remark_String[k]);
								params_work.put("cid", user.getReg_id());
								params_work.put("allowance", allowance[k]);
						
								tr.sql.insert("pay.insertWorkRequest_M", params_work);
								
							}
						}
					} 
					
					
					//시간외 수당신청서
					}else if ("JJ100433".equals(eps_type)) {

						int car_all_work = 0;

						car_all_work = Integer.parseInt(dodelete_cnt); 

						
						 String Dwor_remark_String[] = new String[car_all_work];
							

						 int car_stst11 = 0;
				 		 for(int car_ch2= 1; car_ch2<=car_all_work; car_ch2++)
						{
				 			if(tr.req.getParameter("Dwor_remark"+car_ch2) != null)
							{
				 				
				 				Dwor_remark_String[car_stst11] = tr.req.getParameter("Dwor_remark"+car_ch2);
								car_stst11++;
							}
						} 
						
						tr.sql.delete("pay.DeleteWorkRequest_M", exp_no);
				 		
						/* 시간외 수당신청서 */
			 			if (Request_work_dt != null) { 
							for (int k=0; k<Request_work_dt.length; k++) { 
								if (!"".equals(Request_work_dt[k])) { 
									
									params_work.put("exp_no", exp_no);
									params_work.put("exp_seq", (k+1));
									params_work.put("work_dt", Request_work_dt[k]);
									params_work.put("emp_no", Request_emp_no[k]);
									params_work.put("wor_remark", Dwor_remark_String[k]);
									params_work.put("allowance", allowance[k]);
									params_work.put("cid", user.getReg_id());
									
							
									tr.sql.insert("pay.insertWorkRequest_M", params_work);
									
								}
							}
						} 


		 			//일근태확인서
				}else if ("JJ100650".equals(eps_type)) {

					int car_all_work = 0;

					car_all_work = Integer.parseInt(dodelete_cnt); 
					

					String[] emp_no = tr.req.getParameterValues("emp_no");
					String dept_cd650 =  tr.req.getParameter("dept_cd");
					String[] tm_bc = tr.req.getParameterValues("tm_bc");
					
					 String Dt_time_st_String[] = new String[car_all_work];
					 String Dt_time_ed_String[] = new String[car_all_work];
					 String Dwor_remark_String[] = new String[car_all_work];

					 String base_time_st[] = new String[car_all_work];
					 String base_time_ed[] = new String[car_all_work];
					 String p_time_st[] = new String[car_all_work];
					 String p_time_ed[] = new String[car_all_work];
					 String p_all_yn[] = new String[car_all_work];
					 
					 
					 int car_stst11 = 0;
			 		 for(int car_ch2= 1; car_ch2<=car_all_work; car_ch2++)
					{
			 			 
			 			if(tr.req.getParameter("Dt_time_st"+car_ch2) != null)
						{
			 				
						
			 			 System.out.println(emp_no[car_stst11] +"   ====rrrrrrr====   "+tr.req.getParameter("Dt_time_st"+car_ch2));
			 				Dt_time_st_String[car_stst11] = tr.req.getParameter("Dt_time_st"+car_ch2);
			 				Dt_time_ed_String[car_stst11] = tr.req.getParameter("Dt_time_ed"+car_ch2);
			 				Dwor_remark_String[car_stst11] = tr.req.getParameter("Dwor_remark"+car_ch2);
			 				
			 				base_time_st[car_stst11] = tr.req.getParameter("base_time_st"+car_ch2);
			 				base_time_ed[car_stst11] = tr.req.getParameter("base_time_ed"+car_ch2);
			 				p_time_st[car_stst11] = tr.req.getParameter("p_time_st"+car_ch2);
			 				p_time_ed[car_stst11] = tr.req.getParameter("p_time_ed"+car_ch2);
			 				
			 				
			 				if(tr.req.getParameter("all_yn"+car_ch2)==null)
			 				{
			 					p_all_yn[car_stst11] =  "N";
			 				}
			 				else
			 				{
			 					p_all_yn[car_stst11] =  "Y";
			 				}
			 				
			 				//System.out.println("rrrrrrr===="+tr.req.getParameter("all_yn"+car_ch2));
			 				
			 				
							car_stst11++;
							
						}
						
					} 
					tr.sql.delete("pay.DeleteWorkDay", exp_no);
			 		
		 			if (emp_no != null) { 
						for (int k=0; k<emp_no.length; k++) { 
							if (!"".equals(emp_no[k])) { 
						 		 

								
								params_work.put("exp_no", exp_no);
								params_work.put("exp_seq", (k+1));
								params_work.put("work_dt", tr.req.getParameter("twork_dt"));
								params_work.put("emp_no", emp_no[k]);
								params_work.put("time_st", Dt_time_st_String[k]);
								params_work.put("time_ed", Dt_time_ed_String[k]);
								params_work.put("appStr_tm", app_time_st[k]);
								params_work.put("append_tm", app_time_ed[k]);
								params_work.put("allday_yn", p_all_yn[k]);

								params_work.put("tm_bc", tm_bc[k]);
								
								
								//기준시간
						 		params_work.put("base_time_st",base_time_st[k]);
								params_work.put("base_time_ed",base_time_ed[k]); 
								 
								
								//계획시간
							 	params_work.put("p_time_st", p_time_st[k]);
								params_work.put("p_time_ed", p_time_ed[k]);
								params_work.put("wor_remark", Dwor_remark_String[k]);
								
								
								//System.out.println("2222---"+night_duty[k]);
								
								if(night_duty[k]==null)
								{
									//System.out.println("11---");
									params_work.put("night_duty", 0);
								}
								else if(night_duty[k]=="")
								{
									//System.out.println("1111---");
									params_work.put("night_duty", 0);
								}
								else
								{
									//System.out.println("44---1");
									params_work.put("night_duty", night_duty[k]);	
								}
								
								
								params_work.put("dept_cd", dept_cd650);
								params_work.put("cid", user.getReg_id());
								//System.out.println("params_work---222"+params_work);
						
								tr.sql.insert("pay.insertWorkDay", params_work);
								
							}
						}
					} 
						

					/*//시간외 근무확인서
					}else if ("JJ100641".equals(eps_type)) {

						
						tr.sql.delete("pay.DeleteWorkDecision_M", exp_no);
						
			 			if (p_dept_nm != null) { 
							for (int k=0; k<p_dept_nm.length; k++) { 
								
								if (!"".equals(p_dept_nm[k])) { 
									params_work.put("exp_no", exp_no);
									params_work.put("exp_seq", (k+1));
									params_work.put("Realtime_st", real_time_st[k]);
									params_work.put("Realtime_ed", real_time_ed[k]);
									params_work.put("exp500_no", request_exp_no[k]);
									params_work.put("exp500_seq", request_exp_seq[k]);
									if(tr.req.getParameter("sel_index"+(k+1))==null)
									{
										params_work.put("realwork_yn",  "0");
									}
									else
									{
										params_work.put("realwork_yn",  "1");
									}
									
									params_work.put("realwork_remark",  tr.req.getParameter("realwork_remark"));
									params_work.put("cid", user.getReg_id());
									tr.sql.insert("pay.insertWorkDecision_M", params_work);
									
								}
							}
						} 

						*/
					
				//교통비 사용내역 지급 신청서
				}else if ("JJ100984".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertTransFee_Mitsubishi", params);

					
					int car_all = 0;
					car_all = trans_dt.length+Integer.parseInt(dodelete_cnt); 
					 String trans_purposeString[] = new String[car_all];
					 String transfrom_nmString[]= new String[car_all];
					 String transto_nmString[]= new  String[car_all]; 
					 String shuttle_ynString[]= new  String[car_all]; 
					 
					 int car_stst11 = 0;
			 		for(int car_ch2= 1; car_ch2<=(trans_dt.length+car_all); car_ch2++)
					{
			 			
			 			if(tr.req.getParameter("trans_purpose"+car_ch2) != null)
						{
			 				trans_purposeString[car_stst11] = tr.req.getParameter("trans_purpose"+car_ch2);
			 				transfrom_nmString[car_stst11] = tr.req.getParameter("transfrom_nm" + car_ch2);
			 				transto_nmString[car_stst11] = tr.req.getParameter("transto_nm" + car_ch2);
			 				shuttle_ynString[car_stst11] = tr.req.getParameter("shuttle_yn" + car_ch2);
							car_stst11++;
						}
					}
				 		
				 		
					//교통비 
					tr.sql.delete("pay.deleteTrans_pay_Mitsubishi", exp_no);
					
					if (trans_dt != null) { 
						for (int k=0; k<trans_dt.length; k++) { 
							if (!"".equals(trans_dt[k])) { 
								appeatparams3.put("exp_no", exp_no);
								appeatparams3.put("exp_seq", (k+1));
								appeatparams3.put("trans_dt", trans_dt[k]);
								appeatparams3.put("trans_purpose", trans_purposeString[k]);
								appeatparams3.put("transfrom_nm", transfrom_nmString[k]);
								appeatparams3.put("transto_nm", transto_nmString[k]);
								
								if (tr.req.getParameter("shuttle_yn"+(k+1))==null) { 
									appeatparams3.put("shuttle_yn", "N");
								}else{
									appeatparams3.put("shuttle_yn", "Y");
								}
								appeatparams3.put("trans_fee", StringUtil.replace(StringUtil.normalize(trans_fee[k], "0"), ",", ""));
								appeatparams3.put("toll", StringUtil.replace(StringUtil.normalize(toll[k], "0"), ",", ""));
								appeatparams3.put("parking_fee", StringUtil.replace(StringUtil.normalize(parking_fee[k], "0"), ",", ""));
								appeatparams3.put("trans_amt", StringUtil.replace(StringUtil.normalize(trans_amt[k], "0"), ",", ""));
								
								appeatparams3.put("cid", user.getReg_id());
								tr.sql.insert("pay.insertTrans_pay_Mitsubishi", appeatparams3);
							}
						}
					}
					
				//업무용차량유지비 지원신청서
				}else if ("JJ100986".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("car_no", tr.req.getParameter("car_no"));
					params.put("car_type", tr.req.getParameter("car_type"));
					params.put("car_place", tr.req.getParameter("car_place"));
					params.put("main_work", tr.req.getParameter("main_work"));
					params.put("work_cd", tr.req.getParameter("work_cd"));
					params.put("bf_dept", tr.req.getParameter("bf_dept"));
					params.put("bf_work", tr.req.getParameter("bf_work"));
					params.put("fund", tr.req.getParameter("fund"));
					params.put("payday", tr.req.getParameter("payday"));
					
					
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertCarCost_Mitsubishi", params);

					int car_all = 0;
					car_all = carcost_no.length+Integer.parseInt(dodelete_cnt); 
					
					 String outbusi_placeString[] = new String[car_all];
					 String outbusi_contentString[]= new String[car_all];
					 String outbusi_cntString[]= new  String[car_all]; 
					 
					 int car_stst11 = 0;
			 		for(int car_ch2= 1; car_ch2<=(carcost_no.length+car_all); car_ch2++)
					{
			 			
			 			if(tr.req.getParameter("outbusi_place"+car_ch2) != null)
						{
			 				outbusi_placeString[car_stst11] = tr.req.getParameter("outbusi_place"+car_ch2);
			 				outbusi_contentString[car_stst11] = tr.req.getParameter("outbusi_content" + car_ch2);
			 				outbusi_cntString[car_stst11] = tr.req.getParameter("outbusi_cnt" + car_ch2);
							
							car_stst11++;
						}
					}
			 		
					
					//업무용차량유지비
					tr.sql.delete("pay.deleteCarCost_json_Mitsubishi", exp_no);
					
					if (carcost_no != null) { 
						for (int k=0; k<carcost_no.length; k++) { 
							if (!"".equals(carcost_no[k])) { 
								appeatparams3.put("exp_no", exp_no);
								appeatparams3.put("exp_seq", (k+1));
								appeatparams3.put("outbusi_place", outbusi_placeString[k]);
								appeatparams3.put("outbusi_content", outbusi_contentString[k]);
								appeatparams3.put("outbusi_cnt",StringUtil.normalize(outbusi_cnt[k], "0"));
								appeatparams3.put("cid", user.getReg_id());
								tr.sql.insert("pay.insertCarCost_json_Mitsubishi", appeatparams3);
							}
						}
					}
					
					
					//항공권발권신청서
				}else if ("JJ100987".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("air_start_dt", tr.req.getParameter("air_start_dt"));
					params.put("air_end_dt", tr.req.getParameter("air_end_dt"));
					params.put("air_type", tr.req.getParameter("air_type"));
					params.put("air_purpose", tr.req.getParameter("air_purpose"));
					params.put("out_dt", tr.req.getParameter("out_dt"));
					params.put("out_time", tr.req.getParameter("out_time"));
					params.put("out_start_pt", tr.req.getParameter("out_start_pt"));
					params.put("out_end_pt", tr.req.getParameter("out_end_pt"));
					params.put("out_flight", tr.req.getParameter("out_flight"));
					params.put("out_remark", tr.req.getParameter("out_remark"));
					params.put("in_dt", tr.req.getParameter("in_dt"));
					params.put("in_time", tr.req.getParameter("in_time"));
					params.put("in_start_pt", tr.req.getParameter("in_start_pt"));
					params.put("in_end_pt", tr.req.getParameter("in_end_pt"));
					params.put("in_flight", tr.req.getParameter("in_flight"));
					params.put("in_remark", tr.req.getParameter("in_remark"));
					params.put("cid", user.getReg_id());

					
					
					tr.sql.delete("pay.deleteAirline_Mitsubishi", exp_no);
					
					//항공권발권 출장자 
					if (air_emp_no != null) { 
						for (int k=0; k<air_emp_no.length; k++) { 
							if (!"".equals(air_emp_no[k])) { 
								params.put("exp_no", exp_no);
								params.put("exp_seq", (k+1));
								params.put("air_emp_no",air_emp_no[k]);
								tr.sql.insert("pay.insertAirline_Mitsubishi", params);
							}
						}
					}
					
					
				//출장 신청서 및 정산서		// 해외 신청서 및 정산서	
				}else if (("JJ100988".equals(eps_type)) || ("JJ100851".equals(eps_type))) {
					
					
						params.put("exp_no", exp_no);
						params.put("subexp_no", tr.req.getParameter("paramexp_no"));
						params.put("currency", tr.req.getParameter("l_cur"));
						params.put("lodge_amt", tr.req.getParameter("lodge_amt"));
						params.put("daily_amt", tr.req.getParameter("daily_amt"));
						params.put("reverve_amt", tr.req.getParameter("reverve_amt"));
						params.put("card_amt", tr.req.getParameter("card_amt"));
						params.put("psn_amt", tr.req.getParameter("psn_amt"));
						
						params.put("tot_lodge", tr.req.getParameter("tot_lodge"));
						params.put("tot_daily", tr.req.getParameter("tot_daily"));
						params.put("tot_reverve", tr.req.getParameter("tot_reverve"));
						params.put("tot_card", tr.req.getParameter("tot_card"));
						params.put("tot_psn", tr.req.getParameter("tot_psn"));
						
						params.put("cid", user.getReg_id());
						
						
						
						params.put("j_currency", tr.req.getParameter("j_l_cur"));
						params.put("j_lodge_amt", tr.req.getParameter("j_lodge_amt"));
						params.put("j_daily_amt", tr.req.getParameter("j_daily_amt"));
						params.put("j_reverve_amt", tr.req.getParameter("j_reverve_amt"));
						params.put("j_tot_lodge", tr.req.getParameter("j_tot_lodge"));
						params.put("j_tot_daily", tr.req.getParameter("j_tot_daily"));
						params.put("j_tot_reverve", tr.req.getParameter("j_tot_reverve"));
						
						
						tr.sql.insert("pay.insertAccountsBusiness_DW", params);
				
					
					
					//변경내역
					params2.put("exp_no", exp_no);
					params2.put("appfrom_dt",StringUtil.replace(tr.req.getParameter("appfrom_dt"), "-", ""));
					params2.put("apptto_dt",StringUtil.replace(tr.req.getParameter("apptto_dt"), "-", ""));
					params2.put("appt_cnt",tr.req.getParameter("appt_cnt"));
					params2.put("appt_trip",tr.req.getParameter("appt_trip"));
					params2.put("appt_fare",tr.req.getParameter("appt_fare"));
					params2.put("fare_addr",tr.req.getParameter("fare_addr"));
					params2.put("appt_gbn",tr.req.getParameter("appt_gbn"));
					params2.put("cid", user.getReg_id());
					params2.put("emp_no",tr.req.getParameter("rec_emp_no"));
					params2.put("tm_yn",tr.req.getParameter("tm_yn"));
					params2.put("train_yn",tr.req.getParameter("train_yn"));
					params2.put("air_yn",tr.req.getParameter("air_yn"));
					params2.put("bus_yn",tr.req.getParameter("bus_yn"));
					params2.put("etc_yn",tr.req.getParameter("etc_yn"));
					params2.put("etc_traffic",tr.req.getParameter("etc_traffic"));
					params2.put("lodg_cnt",tr.req.getParameter("lodg_cnt"));
					params2.put("rent_ph",tr.req.getParameter("rent_ph"));
					params2.put("agency", tr.req.getParameter("agency"));
					params2.put("ac_ex_yn", tr.req.getParameter("ac_ex_yn"));
					
					// 출장내용 추가 2024.01.31
					params2.put("detail", tr.req.getParameter("detail"));
					System.out.println("변경내역 ---- " + params2);
					tr.sql.insert("pay.insertappearreques", params2); 
			
					
			 		 
					
					
					int car_all = 0;

					car_all = (Appear_dt.length+Integer.parseInt(dodelete_cnt)); 
					
					
					 String appschefrom_nm[] = new String[car_all];
					 String appscheto_nm[]= new String[car_all];
					 String appschefrom_tm[]= new  String[car_all];  
					 String appscheto_tm[]= new  String[car_all];  
					 String appscheto_remark[]= new  String[car_all];  

					 int car_stst11 = 0;
			 		 for(int car_ch2= 1; car_ch2<=(Appear_dt.length+car_all); car_ch2++)
					{
			 			if(tr.req.getParameter("appschefrom_nm"+car_ch2) != null)
						{
			 				appschefrom_nm[car_stst11] = tr.req.getParameter("appschefrom_nm"+car_ch2);
			 				appscheto_nm[car_stst11] = tr.req.getParameter("appscheto_nm" + car_ch2);
			 				appschefrom_tm[car_stst11] = tr.req.getParameter("appschefrom_tm" + car_ch2);
			 				appscheto_tm[car_stst11] = tr.req.getParameter("appscheto_tm" + car_ch2);
			 				appscheto_remark[car_stst11] = tr.req.getParameter("appscheto_remark" + car_ch2);

							
							car_stst11++;
						}
					} 
					
			 		 
			 		 
					
					tr.sql.delete("pay.deleteAppearschedule", exp_no);
					
							if (Appear_dt != null) { 
								for (int k=0; k<Appear_dt.length; k++) { 
									if (!"".equals(Appear_dt[k])) { 
										appeatparams2.put("exp_no", exp_no);
										appeatparams2.put("exp_seq", (k+1));
										appeatparams2.put("appsche_dt", Appear_dt[k]);
										appeatparams2.put("appsche_to_dt", Appear_to_dt[k]);
										appeatparams2.put("appschefrom_nm", appschefrom_nm[k]);
										appeatparams2.put("appscheto_nm", appscheto_nm[k]);
										appeatparams2.put("appschefrom_tm", appschefrom_tm[k]);
										appeatparams2.put("appscheto_tm", appscheto_tm[k]);
										appeatparams2.put("appscheto_remark", appscheto_remark[k]);
										//대우추가
										appeatparams2.put("applodge_cnt", applodge_cnt[k]);
										appeatparams2.put("appday", appday[k]);
										appeatparams2.put("apparea", apparea[k]);
										appeatparams2.put("cid", user.getReg_id());
										System.out.println(appeatparams2);
										tr.sql.insert("pay.insertappearschedule", appeatparams2);
									}
								}
							}
							
					//여비 지급신청서  
					if (costtot_amt != null) { 
						for (int k=0; k<costtot_amt.length; k++) { 
							if (!"".equals(costtot_amt[k])) { 
								 
								costparams3.put("exp_no", exp_no);
								costparams3.put("exp_seq", (k+1));
								//costparams3.put("emp_no", costemp_no[k]);
								//대우추가
								costparams3.put("emp_no", tr.req.getParameter("rec_emp_no"));
								costparams3.put("currency", currency[k]);
								costparams3.put("lodgment_price", lodgment_price[k]);
								costparams3.put("lodgment_dcnt", lodgment_dcnt[k]);
								costparams3.put("lodgment_tot", lodgment_tot[k]);
								costparams3.put("acday_price", acday_price[k]);
								costparams3.put("acday_dcnt", acday_dcnt[k]);
								costparams3.put("acday_tot", acday_tot[k]);
								costparams3.put("reverve", reverve[k]);
								costparams3.put("tot_amt", costtot_amt[k]);
								//costparams3.put("after_exp_no", tr.req.getParameter("exp_no"));
								costparams3.put("cid", user.getReg_id());
								System.out.println(costparams3);
								tr.sql.insert("pay.inserttravelexpenses", costparams3);
								
							}
						}
					}
					 

				

					
					}else if ("JJ100999".equals(eps_type)) {

						System.out.println("시작여부");
						
						params.put("emp_no", tr.req.getParameter("emp_no"));
						params.put("year", tr.req.getParameter("year"));
						params.put("appoint_dt", tr.req.getParameter("appoint_dt"));
						
						params.put("cid", user.getReg_id());

						System.out.println("JJ100999----"+params);
						tr.sql.insert("pay.insertSegregation_Mitsubishi", params);
						
						
//	 				-----------------------------------------------------------------------------------------------	
						
						int segregation_Accounts = 0;

						segregation_Accounts = opening_dt.length+Integer.parseInt(dodelete_cnt); 
						
//	 					System.out.println("business_Accounts---"+business_Accounts);
						
						 String detail_note_String[] = new String[segregation_Accounts];
						 String cycle_String[] = new String[segregation_Accounts];
						 String number_String[] = new String[segregation_Accounts];
						 String leadtime_String[] = new String[segregation_Accounts];
						 String career_String[] = new String[segregation_Accounts];
						 String relevant_String[] = new String[segregation_Accounts];
						 String note_String[] = new String[segregation_Accounts];

						 int segregation11 = 0;
				 		 for(int segregation_ch2= 1; segregation_ch2<=segregation_Accounts; segregation_ch2++)
						{
				 			 
				 			 
				 			if(tr.req.getParameter("cycle"+segregation_ch2) != null)
							{ 
				 				detail_note_String[segregation11] = tr.req.getParameter("detail_note"+segregation_ch2);
				 				cycle_String[segregation11] = tr.req.getParameter("cycle"+segregation_ch2);
				 				number_String[segregation11] = tr.req.getParameter("number"+segregation_ch2);
				 				leadtime_String[segregation11] = tr.req.getParameter("leadtime"+segregation_ch2);
				 				career_String[segregation11] = tr.req.getParameter("career"+segregation_ch2);
				 				relevant_String[segregation11] = tr.req.getParameter("relevant"+segregation_ch2);
				 				note_String[segregation11] = tr.req.getParameter("note"+segregation_ch2);
				 				
				 				
				 				segregation11++;
							}
						} 

			 			 System.out.println("여기111----");
					
						tr.sql.delete("pay.deleteSegregationDetail_Mitsubishi", exp_no);
			 			

						if(opening_dt != null)
						{
							for(int row = 0; row<opening_dt.length; row ++)
							{
								if(!"".equals(opening_dt[row]))
								{
									   
									params_sub.put("exp_sq", (row+1));
									params_sub.put("main_cd", main_cd[row]);
									params_sub.put("up_cd", up_cd[row]); 
									params_sub.put("sub_cd", sub_cd[row]);
									params_sub.put("detail_note", detail_note_String[row]);
									params_sub.put("opening_dt", opening_dt[row]);
									params_sub.put("cycle", cycle_String[row]);
									params_sub.put("number", number_String[row]);
									params_sub.put("leadtime", leadtime_String[row]);
									params_sub.put("career", career_String[row]);
									params_sub.put("relevant", relevant_String[row]);
									params_sub.put("note", note_String[row]);
									params_sub.put("cid", user.getReg_id());

									System.out.println(params_sub);
									
									tr.sql.insert("pay.insertSegregationDetail_Mitsubishi", params_sub);
									
								}
								
							}
							
						}
					 
				
					
					
					
/*============================================================================================================================================*/					
					
				/* 성진포머 */
				
				//안전화 지급 요청서
				}else if ("JJ100750".equals(eps_type)) {

					 int car_all = 0;
					 car_all = sho_emp_no.length+Integer.parseInt(dodelete_cnt); 
					 String shoes_sizeString[] = new String[car_all];
					 String shoes_noteString[]= new String[car_all];
					 
					 
					 int car_stst11 = 0;
			 		for(int car_ch2= 1; car_ch2<=(sho_emp_no.length+car_all); car_ch2++)
					{
			 			if(tr.req.getParameter("shoes_size"+car_ch2) != null)
						{
			 				shoes_sizeString[car_stst11] = tr.req.getParameter("shoes_size" +car_ch2);
			 				shoes_noteString[car_stst11] = tr.req.getParameter("shoes_note" + car_ch2);
							
							car_stst11++;
						}
					} 
					
			 		tr.sql.delete("pay.deleteSafetyShoes_Sjfoma", exp_no);
					
					if (sho_emp_no != null) { 
						for (int k=0; k<sho_emp_no.length; k++) { 
							if (!"".equals(sho_emp_no[k])) { 
								params.put("exp_no", exp_no);
								params.put("exp_seq", (k+1));
								params.put("emp_no", sho_emp_no[k]);
								params.put("shoes_size", shoes_sizeString[k]);
								params.put("shoes_note", shoes_noteString[k]);
								params.put("before_dt", before_dt[k]);
								tr.sql.insert("pay.insertSafetyShoes_Sjfoma", params);
							}
						}
					}
					
					
				//전산시스템 사용(수정) 요청서 
				}else if ("JJ100751".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("sys_reason", tr.req.getParameter("sys_reason"));
					params.put("other_reason", tr.req.getParameter("other_reason"));
					params.put("sys_req", tr.req.getParameter("sys_req"));
					params.put("agency", tr.req.getParameter("agency"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertSystemUse_Sjfoma", params);	
					
					
				//email 포워딩 요청서 
				}else if ("JJ100437".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("req_email_id", tr.req.getParameter("req_email_id"));
					params.put("for_email_id", tr.req.getParameter("for_email_id"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertemailForward_DW", params);		
					
					
				// 유류비 사용내역 지급 신청서 
				}else if ("JJ100752".equals(eps_type)) {

					 int car_all = 0;
					 car_all = oil_dt.length+Integer.parseInt(dodelete_cnt); 
					 String oil_start_tmString[] = new String[car_all];
					 String oil_end_tmString[]= new String[car_all];
					 String visitString1[] = new String[car_all];
					 String visitString2[] = new String[car_all];
					 String taskString[] = new String[car_all];
					 
					 String start_addrString[] = new String[car_all];
					 String end_addrString[] = new String[car_all];
					 
					 
					 int car_stst11 = 0;
			 		for(int car_ch2= 1; car_ch2<=(oil_dt.length+car_all); car_ch2++)
					{
			 			if(tr.req.getParameter("oil_start_tm"+car_ch2) != null)
						{
			 				oil_start_tmString[car_stst11] = tr.req.getParameter("oil_start_tm" +car_ch2);
			 				oil_end_tmString[car_stst11] = tr.req.getParameter("oil_end_tm" + car_ch2);
			 				visitString1[car_stst11] = tr.req.getParameter("visit1_" +car_ch2);
			 				visitString2[car_stst11] = tr.req.getParameter("visit2_" +car_ch2);
			 				taskString[car_stst11] = tr.req.getParameter("task" + car_ch2);
			 				
			 				start_addrString[car_stst11] = tr.req.getParameter("start_addr" +car_ch2);
			 				end_addrString[car_stst11] = tr.req.getParameter("end_addr" +car_ch2);
			 				
							car_stst11++;
						}
					}  
					
			 		tr.sql.delete("pay.deleteOilBill_json_Mitsubishi", exp_no);
					
					if (oil_dt != null) { 
						for (int k=0; k<oil_dt.length; k++) { 
							if (!"".equals(oil_dt[k])) { 
								params.put("exp_no", exp_no);
								params.put("emp_no", tr.req.getParameter("rec_emp_no"));
								params.put("fuel_no", tr.req.getParameter("fuel_no"));
								params.put("exp_seq", (k+1));
								params.put("oil_dt", oil_dt[k]);
								params.put("oil_start_tm", oil_start_tmString[k]);
								params.put("oil_end_tm", oil_end_tmString[k]);
								params.put("visit1", visitString1[k]);
								params.put("visit2", visitString2[k]);
								params.put("task", taskString[k]);
								params.put("move", move[k]);
								params.put("cid", user.getReg_id());
								
								params.put("start_addr", start_addrString[k]);
								params.put("end_addr", end_addrString[k]);
								tr.sql.insert("pay.insertOilBill_json_Mitsubishi", params);
							}
						}
					}	
				
				
				//설비이상 발생 보고서 
				}else if ("JJ100753".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("break_dept_cd", tr.req.getParameter("break_dept_cd"));
					params.put("break_dt", tr.req.getParameter("break_dt"));
					params.put("equip_no", tr.req.getParameter("equip_no"));
					params.put("equip_nm", tr.req.getParameter("equip_nm"));
					params.put("break_content", tr.req.getParameter("break_content"));
					params.put("break_cause", tr.req.getParameter("break_cause"));
					params.put("repair_content", tr.req.getParameter("repair_content"));
					params.put("repair_shop", tr.req.getParameter("repair_shop"));
					params.put("repair_amt", tr.req.getParameter("repair_amt"));
					params.put("repair_note", tr.req.getParameter("repair_note"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertEquipBreak_Sjfoma", params);	
					
					
				//측정장비 및 계측기 분실, 훼손, 변경 보고서
				}else if ("JJ100754".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("equip_nm", tr.req.getParameter("equip_nm"));
					params.put("manage_no", tr.req.getParameter("manage_no"));
					params.put("standard", tr.req.getParameter("standard"));
					params.put("buy_dt", tr.req.getParameter("buy_dt"));
					params.put("buy_shop", tr.req.getParameter("buy_shop"));
					params.put("buy_price", tr.req.getParameter("buy_price"));
					params.put("equip_use", tr.req.getParameter("equip_use"));
					params.put("equip_amt", tr.req.getParameter("equip_amt"));
					params.put("prob_dt", tr.req.getParameter("prob_dt"));
					params.put("prob_man", tr.req.getParameter("prob_man"));
					params.put("harm_st", tr.req.getParameter("harm_st"));
					params.put("harm_cau", tr.req.getParameter("harm_cau"));
					params.put("dept_opi1", tr.req.getParameter("dept_opi1"));
					params.put("dept_opi2", tr.req.getParameter("dept_opi2"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertMeasureLoss_Sjfoma", params);	
					
					
				//측정장비 T-out보고서
				}else if ("JJ100755".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("equip_nm", tr.req.getParameter("equip_nm"));
					params.put("workshop", tr.req.getParameter("workshop"));
					params.put("standard", tr.req.getParameter("standard"));
					params.put("buy_dt", tr.req.getParameter("buy_dt"));
					params.put("equip_use", tr.req.getParameter("equip_use"));
					params.put("install_pl", tr.req.getParameter("install_pl"));
					params.put("report_con", tr.req.getParameter("report_con"));
					params.put("special_con", tr.req.getParameter("special_con"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertMeasureTout_Sjfoma", params);	
					
					
				//사고발생보고서
				}else if ("JJ100756".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("acc_dt", tr.req.getParameter("acc_dt"));
					params.put("acc_pl", tr.req.getParameter("acc_pl"));
					params.put("acc_equip", tr.req.getParameter("acc_equip"));
					params.put("acc_st", tr.req.getParameter("acc_st"));
					params.put("injured_part", tr.req.getParameter("injured_part"));
					params.put("injury_degree", tr.req.getParameter("injury_degree"));
					params.put("witness", tr.req.getParameter("witness"));
					params.put("acc_emp_no", tr.req.getParameter("acc_emp_no"));
					params.put("i_damage", tr.req.getParameter("i_damage"));
					params.put("you_damage", tr.req.getParameter("you_damage"));
					params.put("action", tr.req.getParameter("action"));
					params.put("cause", tr.req.getParameter("cause"));
					params.put("prevention", tr.req.getParameter("prevention"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertAccOccur_Sjfoma", params);		
					
					
					
				//이상통보서
				}else if ("JJ100758".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("cust_nm", tr.req.getParameter("cust_nm"));
					params.put("occur_cd", tr.req.getParameter("occur_cd"));
					params.put("qrqc", tr.req.getParameter("qrqc"));
					params.put("item_no", tr.req.getParameter("item_no"));
					params.put("item_nm", tr.req.getParameter("item_nm"));
					params.put("occur_dt", tr.req.getParameter("occur_dt"));
					params.put("qrqc_notice_dt", tr.req.getParameter("qrqc_notice_dt"));
					params.put("qrqc_dt", tr.req.getParameter("qrqc_dt"));
					params.put("cause_dept", tr.req.getParameter("cause_dept"));
					params.put("d1_bad", tr.req.getParameter("d1_bad"));
					params.put("d1_good", tr.req.getParameter("d1_good"));
					params.put("d1_lot", tr.req.getParameter("d1_lot"));
					params.put("d1_worker", tr.req.getParameter("d1_worker"));
					params.put("d1_nontype", tr.req.getParameter("d1_nontype"));
					params.put("d1_badrate", tr.req.getParameter("d1_badrate"));
					params.put("d2_team", tr.req.getParameter("d2_team"));
					params.put("d2_content", tr.req.getParameter("d2_content"));
					params.put("d3_caution", tr.req.getParameter("d3_caution"));
					params.put("d3_charge", tr.req.getParameter("d3_charge"));
					params.put("d3_schedule", tr.req.getParameter("d3_schedule"));
					params.put("cid", user.getReg_id());
					tr.sql.insert("pay.insertAbnormal_Sjfoma", params);		
					
				
					//식수신청서
					}else if ("JJ100770".equals(eps_type)) {

						
						
						tr.sql.delete("pay.DeleteWater_Sjfoma", exp_no);
				 		
						
						/* 식수신청서  */
			 			if (water_emp_no != null) { 
							for (int k=0; k<water_emp_no.length; k++) { 
								if (!"".equals(water_emp_no[k])) { 
									
									params_work.put("exp_no", exp_no);
									params_work.put("emp_no", water_emp_no[k]);
									params_work.put("req_note", tr.req.getParameter("req_note"+(k+1)));
									params_work.put("cid", user.getReg_id());
									

									
									if (tr.req.getParameter("A_req_dt")!=null) {
		
										params_work.put("water_req_dt", tr.req.getParameter("A_req_dt"));
		
		
										if (tr.req.getParameter("Alunch"+(k+1))==null) { 
											params_work.put("lunch", "N");
										}else{
											params_work.put("lunch", "Y");
										}
		
										if (tr.req.getParameter("Adinner"+(k+1))==null) { 
											params_work.put("dinner", "N");
										}else{
											params_work.put("dinner", "Y");
										}
		
		
										tr.sql.insert("pay.insertWater_Sjfoma", params_work);
		
									}
  
  
	
									if (tr.req.getParameter("B_req_dt")!=null) {
		
										params_work.put("water_req_dt", tr.req.getParameter("B_req_dt"));
		
		
										if (tr.req.getParameter("Blunch"+(k+1))==null) { 
											params_work.put("lunch", "N");
										}else{
											params_work.put("lunch", "Y");
										}
		
										if (tr.req.getParameter("Bdinner"+(k+1))==null) { 
											params_work.put("dinner", "N");
										}else{
											params_work.put("dinner", "Y");
										}
		
										tr.sql.insert("pay.insertWater_Sjfoma", params_work);
		
									}
	
	
	
									if (tr.req.getParameter("C_req_dt")!=null) {
		
										params_work.put("water_req_dt", tr.req.getParameter("C_req_dt"));
		
										if (tr.req.getParameter("Clunch"+(k+1))==null) { 
											params_work.put("lunch", "N");
										}else{
											params_work.put("lunch", "Y");
										}
		
										if (tr.req.getParameter("Cdinner"+(k+1))==null) { 
											params_work.put("dinner", "N");
										}else{
											params_work.put("dinner", "Y");
										}
		
		
										tr.sql.insert("pay.insertWater_Sjfoma", params_work);
		
									}
	

									
								}
							}
						} 
						
						
						
			 			int car_all_work = 0;

						car_all_work = Integer.parseInt(dodelete_cnt); 

						 String out_nm_String[] = new String[car_all_work];
						 String Oreq_note_String[] = new String[car_all_work];
						 String Ooutside_String[] = new String[car_all_work];
							

						 int car_stst11 = 0;
				 		 for(int car_ch2= 1; car_ch2<=car_all_work; car_ch2++)
						{
				 			if(tr.req.getParameter("out_nm"+car_ch2) != null )
							{
				 				out_nm_String[car_stst11] = tr.req.getParameter("out_nm"+car_ch2);
				 				Ooutside_String[car_stst11] = tr.req.getParameter("Ooutside"+car_ch2);
				 				Oreq_note_String[car_stst11] = tr.req.getParameter("Oreq_note"+car_ch2);
								car_stst11++;
							}
						} 
				 		 
						
				 		tr.sql.delete("pay.DeleteWater_out_Sjfoma", exp_no);
						
						
						/* 식수신청서  */ /* 사외신청자 */
			 			if (water_out_seq != null) { 
							for (int k=0; k<water_out_seq.length; k++) { 
								//이름이 있어야 함
								if (!"".equals(out_nm_String[k])) { 
									
									params_work.put("exp_no", exp_no);
									params_work.put("out_seq", water_out_seq[k]);
									params_work.put("out_nm", out_nm_String[k]);
									params_work.put("outside", Ooutside_String[k]);
									params_work.put("req_note", Oreq_note_String[k]);
									params_work.put("cid", user.getReg_id());
									

									
									if (tr.req.getParameter("A_req_dt")!=null) {
		
										params_work.put("water_req_dt", tr.req.getParameter("A_req_dt"));
		
		
										if (tr.req.getParameter("Aout_lunch"+(k+1))==null) { 
											params_work.put("lunch", "N");
										}else{
											params_work.put("lunch", "Y");
										}
		
										if (tr.req.getParameter("Aout_dinner"+(k+1))==null) { 
											params_work.put("dinner", "N");
										}else{
											params_work.put("dinner", "Y");
										}
		
		
										tr.sql.insert("pay.insertWater_out_Sjfoma", params_work);
		
									}
  
  
	
									if (tr.req.getParameter("B_req_dt")!=null) {
		
										params_work.put("water_req_dt", tr.req.getParameter("B_req_dt"));
		
		
										if (tr.req.getParameter("Bout_lunch"+(k+1))==null) { 
											params_work.put("lunch", "N");
										}else{
											params_work.put("lunch", "Y");
										}
		
										if (tr.req.getParameter("Bout_dinner"+(k+1))==null) { 
											params_work.put("dinner", "N");
										}else{
											params_work.put("dinner", "Y");
										}
		
										tr.sql.insert("pay.insertWater_out_Sjfoma", params_work);
		
									}
	
	
	
									if (tr.req.getParameter("C_req_dt")!=null) {
		
										params_work.put("water_req_dt", tr.req.getParameter("C_req_dt"));
		
										if (tr.req.getParameter("Cout_lunch"+(k+1))==null) { 
											params_work.put("lunch", "N");
										}else{
											params_work.put("lunch", "Y");
										}
		
										if (tr.req.getParameter("Cout_dinner"+(k+1))==null) { 
											params_work.put("dinner", "N");
										}else{
											params_work.put("dinner", "Y");
										}
		
		
										tr.sql.insert("pay.insertWater_out_Sjfoma", params_work);
		
									}
	

									
								}
							}
						} 
						
						
						
						

				//교육계획보고서
				}else if ("JJ100771".equals(eps_type)) {
					
					
					int car_all_work = 0;

					car_all_work = Integer.parseInt(dodelete_cnt); 

					 String edu_locate_String[] = new String[car_all_work];
					 String edu_name_String[] = new String[car_all_work];
					 String edu_organ_String[] = new String[car_all_work];
					 String edu_content_String[] = new String[car_all_work];
						

					 int car_stst11 = 0;
			 		 for(int car_ch2= 1; car_ch2<=car_all_work; car_ch2++)
					{
			 			if(tr.req.getParameter("edu_name"+car_ch2) != null)
						{
			 				edu_locate_String[car_stst11] = tr.req.getParameter("edu_locate"+car_ch2);
			 				edu_name_String[car_stst11] = tr.req.getParameter("edu_name"+car_ch2);
			 				edu_organ_String[car_stst11] = tr.req.getParameter("edu_organ"+car_ch2);
			 				edu_content_String[car_stst11] = tr.req.getParameter("edu_content"+car_ch2);
							car_stst11++;
						}
					} 
					
					tr.sql.delete("pay.DeleteEduPlan_Sjfoma", exp_no);
			 		
					/* 교육계획보고서  */
		 			if (edu_emp_no != null) { 
						for (int k=0; k<edu_emp_no.length; k++) { 
							if (!"".equals(edu_emp_no[k])) { 
								
								params_work.put("exp_no", exp_no);
								params_work.put("exp_seq", (k+1));
								params_work.put("edu_emp_no", edu_emp_no[k]);
								params_work.put("edu_sel", edu_sel[k]);
								params_work.put("edu_start_dt", edu_start_dt[k]);
								params_work.put("edu_end_dt", edu_end_dt[k]);
								params_work.put("edu_locate", edu_locate_String[k]);
								params_work.put("edu_name", edu_name_String[k]);
								params_work.put("edu_organ", edu_organ_String[k]);
								params_work.put("edu_content", edu_content_String[k]);
								params_work.put("edu_cost", StringUtil.replace(StringUtil.normalize(edu_cost[k], "0"), ",", ""));
								params_work.put("cid", user.getReg_id());
						
								tr.sql.insert("pay.insertEduPlan_Sjfoma", params_work);
								
							}
						}
					} 
					
		 		//물품의뢰서
				}else if ("JJ100767".equals(eps_type)) {
					
					
					params.put("req_dept_cd", tr.req.getParameter("dept_cd"));
					params.put("req_dt", StringUtil.normalize(tr.req.getParameter("req_dt")));
					params.put("cid", user.getReg_id());
					
					tr.sql.insert("pay.insertArticleReq_Sjfoma", params);
					
					int car_all_work = 0;

					car_all_work = Integer.parseInt(dodelete_cnt); 

					 String itm_note_String[] = new String[car_all_work];
					 String itm_nm_String[] = new String[car_all_work];
					 String spec_String[] = new String[car_all_work];
					 String cust_nm_String[] = new String[car_all_work];
					 String um_bc_String[] = new String[car_all_work];
						

					 int car_stst11 = 0;
			 		 for(int car_ch2= 1; car_ch2<=car_all_work; car_ch2++)
					{
			 			if(tr.req.getParameter("itm_note"+car_ch2) != null)
						{
			 				itm_note_String[car_stst11] = tr.req.getParameter("itm_note"+car_ch2);
			 				
			 				itm_nm_String[car_stst11] = tr.req.getParameter("itm_nm"+car_ch2);
			 				spec_String[car_stst11] = tr.req.getParameter("spec"+car_ch2);
			 				cust_nm_String[car_stst11] = tr.req.getParameter("cust_nm"+car_ch2);
			 				um_bc_String[car_stst11] = tr.req.getParameter("um_bc"+car_ch2);
			 				
							car_stst11++;
						}
					} 
					
					tr.sql.delete("pay.DeleteArticleReq_json_Sjfoma", exp_no);
			 		
					/* 물품의뢰서  */
		 			if (itm_cd != null) { 
						for (int k=0; k<itm_cd.length; k++) { 
							if (!"".equals(itm_cd[k])) { 
								
								params.put("exp_no", exp_no);
								params.put("exp_seq", (k+1));
								//params.put("itm_bc", itm_bc[k]);
								params.put("itm_cd", itm_cd[k]);
								params.put("itm_nm", itm_nm_String[k]);
								//params.put("spec", spec_String[k]);
								//params.put("um_bc", um_bc_String[k]);
								//params.put("cust_cd", cust_cd[k]);
								//params.put("cust_nm", cust_nm_String[k]);
								//params.put("itm_dept_cd", itm_dept_cd[k]);
								params.put("up", StringUtil.normalize(itm_up[k], "0"));
								params.put("itm_cnt", StringUtil.normalize(itm_cnt[k], "0"));
								params.put("amt_sum", StringUtil.normalize(amt_sum[k], "0"));
								params.put("itm_note", itm_note_String[k]);
								params.put("cid", user.getReg_id());
						
								tr.sql.insert("pay.insertArticleReq_json_Sjfoma", params);
								
							}
						}
					} 
					
				
					
					
		 		//법인카드 사용신청서
				}else if ("JJ100768".equals(eps_type)) {
					
					
					params.put("emp_no", tr.req.getParameter("rec_emp_no"));
					params.put("req_reason", tr.req.getParameter("req_reason"));
					params.put("req_card_no", tr.req.getParameter("req_card_no"));
					params.put("req_start_dt", tr.req.getParameter("req_start_dt"));
					params.put("req_end_dt", tr.req.getParameter("req_end_dt"));
					params.put("cid", user.getReg_id());
					
					tr.sql.insert("pay.insertCardUse_Sjfoma", params);
					
					
					
					
		 		//인사발령요청서
				}else if ("JJ100772".equals(eps_type)) {
					
					
					int car_all_work = 0;

					car_all_work = Integer.parseInt(dodelete_cnt); 

					 String per_note_String[] = new String[car_all_work];
						

					 int car_stst11 = 0;
			 		 for(int car_ch2= 1; car_ch2<=car_all_work; car_ch2++)
					{
			 			if(tr.req.getParameter("per_note"+car_ch2) != null)
						{
			 				per_note_String[car_stst11] = tr.req.getParameter("per_note"+car_ch2);
							car_stst11++;
						}
					} 
					
					tr.sql.delete("pay.DeletePersonnel_Sjfoma", exp_no);
			 		
					/* 인사발령요청서  */
		 			if (per_emp_no != null) { 
						for (int k=0; k<per_emp_no.length; k++) { 
							if (!"".equals(per_emp_no[k])) { 
								
								params_work.put("exp_no", exp_no);
								params_work.put("exp_seq", (k+1));
								params_work.put("emp_no", per_emp_no[k]);
								params_work.put("per_dt", per_dt[k]);
								params_work.put("rank", rank[k]);
								params_work.put("before_dept", before_dept[k]);
								params_work.put("after_dept", after_dept[k]);
								params_work.put("duty", duty[k]);
								params_work.put("per_note", per_note_String[k]);
								params_work.put("cid", user.getReg_id());
						
								tr.sql.insert("pay.insertPersonnel_Sjfoma", params_work);
								
							}
						}
					} 
					
					
				//입고품 불량 통보서
				}else if ("JJ100760".equals(eps_type)) {
					
					
					params.put("exp_no", exp_no);
					params.put("names",tr.req.getParameter("names"));
					params.put("names_bn",tr.req.getParameter("names_bn"));
					params.put("business",tr.req.getParameter("business"));
					params.put("warehous_dt", tr.req.getParameter("warehous_dt"));
					params.put("occur_dt", tr.req.getParameter("occur_dt"));
					params.put("make_dt", tr.req.getParameter("make_dt"));
					params.put("birthplace", tr.req.getParameter("birthplace"));
					params.put("problem", tr.req.getParameter("problem"));
					params.put("faulty", tr.req.getParameter("faulty"));
					params.put("action", tr.req.getParameter("action"));
					params.put("action_cont", tr.req.getParameter("action_cont"));
					params.put("measure", tr.req.getParameter("measure"));
					params.put("make_cause", tr.req.getParameter("make_cause"));
					params.put("leak", tr.req.getParameter("leak"));
					params.put("effect", tr.req.getParameter("effect"));
					params.put("prevention", tr.req.getParameter("prevention"));
					params.put("standard", tr.req.getParameter("standard"));
					params.put("re_work", tr.req.getParameter("re_work"));
					params.put("improvement", tr.req.getParameter("improvement"));
					params.put("unfold", tr.req.getParameter("unfold"));
					params.put("result", tr.req.getParameter("result"));
					params.put("outcome", tr.req.getParameter("outcome"));
					params.put("cid", user.getReg_id());
					
					tr.sql.insert("pay.insertWarehousing_Sjfoma", params); 

				
				//재작업 지시서
				}else if ("JJ100761".equals(eps_type)) {
					// 신청자
					params.put("exp_no", exp_no);
					params.put("dept_nm", tr.req.getParameter("dept_nm"));
					params.put("rework_charge", tr.req.getParameter("rework_charge"));
					params.put("names_nb", tr.req.getParameter("names_nb"));
					params.put("process_dt", tr.req.getParameter("process_dt"));
					params.put("model", tr.req.getParameter("model"));
					params.put("names", tr.req.getParameter("names"));
					params.put("amount", tr.req.getParameter("amount"));
					params.put("reason", tr.req.getParameter("reason"));
					params.put("rework_way", tr.req.getParameter("rework_way"));
					params.put("process_consult", tr.req.getParameter("process_consult"));
					params.put("remark", tr.req.getParameter("remark"));
					params.put("cid", user.getReg_id());
					
					tr.sql.insert("pay.insertrework_Sjfoma", params);
				
				//재작업 보고서
				}else if ("JJ100762".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("paramexp_no", tr.req.getParameter("paramexp_no"));
					params.put("imported_cnt", tr.req.getParameter("imported_cnt"));
					params.put("poor_cnt", tr.req.getParameter("poor_cnt"));
					params.put("re_mark", tr.req.getParameter("re_mark"));
					params.put("cid", user.getReg_id());
					
					tr.sql.insert("pay.insertrework_report_Sjfoma", params);
					
				//특채 의뢰서
				}else if ("JJ100763".equals(eps_type)) {
					
					// 신청자
					params.put("exp_no", exp_no);
					params.put("model", tr.req.getParameter("model"));
					params.put("names", tr.req.getParameter("names"));
					params.put("names_nb", tr.req.getParameter("names_nb"));
					params.put("lot_no", tr.req.getParameter("lot_no"));
					params.put("production", tr.req.getParameter("production"));
					params.put("warehouse_dt", StringUtil.replace(tr.req.getParameter("warehouse_dt"), "-", ""));
					params.put("dept_nm", tr.req.getParameter("dept_nm"));
					params.put("applicant", tr.req.getParameter("applicant"));
					params.put("charger", tr.req.getParameter("charger"));
					params.put("applicant_dt", StringUtil.replace(tr.req.getParameter("applicant_dt"), "-", ""));
					params.put("applicant_cnt", tr.req.getParameter("applicant_cnt"));
					params.put("problem", tr.req.getParameter("problem"));
					params.put("henceforth", tr.req.getParameter("henceforth"));
					params.put("cid", user.getReg_id());
					
// 					System.out.println("1111111123" + params);
					
					tr.sql.insert("pay.insertspecial_Sjfoma", params);	
					
				}else if ("JJ100764".equals(eps_type)) {
					
					params.put("exp_no", exp_no);
					params.put("paramexp_no", tr.req.getParameter("paramexp_no"));
					params.put("result", tr.req.getParameter("result"));
					params.put("decision", tr.req.getParameter("decision"));
					params.put("management", tr.req.getParameter("management"));
					params.put("approve_cnt", tr.req.getParameter("approve_cnt"));
					params.put("approve_st_dt", tr.req.getParameter("approve_st_dt"));
					params.put("approve_end_dt", tr.req.getParameter("approve_end_dt"));
					params.put("cid", user.getReg_id());
					
					tr.sql.insert("pay.insertspecial_screen_Sjfoma", params);
				
				}else if ("JJ100765".equals(eps_type)) {

					 int out_all = 0;
					 
					 out_all = release_dt.length+Integer.parseInt(dodelete_cnt); 
					 
					 
					 String subcontractString[] = new String[out_all];
					 String noteString[]= new String[out_all];
					 String customerString[] = new String[out_all];
					 String namesString[]= new String[out_all];
					 String names_nbString[] = new String[out_all];
					 String gradeString[]= new String[out_all];
					 String official_nmString[] = new String[out_all];
					 String business_nmString[]= new String[out_all];
					 String amountString[] = new String[out_all];
					 String unitString[]= new String[out_all];
					 String unit_priceString[] = new String[out_all];
					 String sum_amountString[]= new String[out_all];
					 
					 
					 int out_stst11 = 0;
			 		for(int out_ch2= 1; out_ch2<=(release_dt.length+out_all); out_ch2++)
					{
			 			if(tr.req.getParameter("subcontract"+out_ch2) != null)
						{
			 				subcontractString[out_stst11] = tr.req.getParameter("subcontract" +out_ch2);
			 				noteString[out_stst11] = tr.req.getParameter("note" + out_ch2);
			 				customerString[out_stst11] = tr.req.getParameter("customer" +out_ch2);
			 				namesString[out_stst11] = tr.req.getParameter("names" + out_ch2);
			 				names_nbString[out_stst11] = tr.req.getParameter("names_nb" +out_ch2);
			 				gradeString[out_stst11] = tr.req.getParameter("grade" + out_ch2);
			 				official_nmString[out_stst11] = tr.req.getParameter("official_nm" +out_ch2);
			 				business_nmString[out_stst11] = tr.req.getParameter("business_nm" + out_ch2);
			 				amountString[out_stst11] = tr.req.getParameter("amount" +out_ch2);
			 				unitString[out_stst11] = tr.req.getParameter("unit" + out_ch2);
			 				unit_priceString[out_stst11] = tr.req.getParameter("unit_price" +out_ch2);
			 				sum_amountString[out_stst11] = tr.req.getParameter("sum_amount" + out_ch2);
							
			 				out_stst11++;
						}
					} 
					
			 		tr.sql.delete("pay.deleteoutso_Sjfoma", exp_no);
					
					if (release_dt != null) { 
						for (int k=0; k<release_dt.length; k++) { 
							if (!"".equals(release_dt[k])) { 
								params.put("exp_no", exp_no);
								params.put("exp_sq", (k+1));
								
								params.put("customer", 		customerString[k]);
								params.put("names", 		namesString[k]);
								params.put("names_nb", 		names_nbString[k]);
								params.put("grade", 		gradeString[k]);
								params.put("official_nm", 	official_nmString[k]);
								params.put("business_nm", 	business_nmString[k]);
								params.put("amount", 		amountString[k]);
								params.put("unit", 			unitString[k]);
								params.put("unit_price", 	unit_priceString[k]);
								params.put("sum_amount", 	sum_amountString[k]);
								params.put("release_dt", 	release_dt[k]);
								params.put("warehouse_dt", 	warehouse_dt[k]);
								
								params.put("subcontract", 	subcontractString[k]);
								params.put("note", 			noteString[k]);
								
								
								tr.sql.insert("pay.insertoutso_Sjfoma", params);
							}
						}
					}	
				
				}else if ("JJ100766".equals(eps_type)) {
					
					
					params.put("exp_no", exp_no);
					params.put("datetime_dt", tr.req.getParameter("datetime_dt"));
					params.put("place", tr.req.getParameter("place"));
					params.put("apply_dt", tr.req.getParameter("apply_dt"));
					params.put("apply", tr.req.getParameter("apply"));
					params.put("pay_terms", tr.req.getParameter("pay_terms"));
					params.put("deliver_place", tr.req.getParameter("deliver_place"));
					params.put("set_reason", tr.req.getParameter("set_reason"));
					params.put("sjfoma", tr.req.getParameter("sjfoma"));
					params.put("cooperativefirm", tr.req.getParameter("cooperativefirm"));
					params.put("cid", user.getReg_id());
					
					tr.sql.insert("pay.insertoutso_cost_Sjfoma", params);	
					

					/*-------------------------------------------------------------------------  */
					
					int out_cost = 0;

					out_cost = (out_so_cost.length+Integer.parseInt(dodelete_cnt)); 

					
					 String production_String[] = new String[out_cost];
					 String guest_nm_String[] = new String[out_cost];
					 String names_String[] = new String[out_cost];
					 String names_nb_String[] = new String[out_cost];
					 String names_sub_String[] = new String[out_cost];
					 String metallic_nm_String[] = new String[out_cost];
					 String amount_String[] = new String[out_cost];
					 String estimatedcost_String[] = new String[out_cost];
					 String decidecost_String[] = new String[out_cost];
					 String note_String[] = new String[out_cost];
					 String out_so_cost_String[] = new String[out_cost];

					 int out_cost11 = 0;
			 		 for(int out_cos_ch2= 1; out_cos_ch2<=out_cost; out_cos_ch2++)
					{
			 			 
			 			 
			 			if(tr.req.getParameter("metallic_nm"+out_cos_ch2) != null)
						{ 
			 				
			 				production_String[out_cost11] = tr.req.getParameter("production"+out_cos_ch2);
			 				guest_nm_String[out_cost11] = tr.req.getParameter("guest_nm"+out_cos_ch2);
			 				names_String[out_cost11] = tr.req.getParameter("names"+out_cos_ch2);
			 				names_nb_String[out_cost11] = tr.req.getParameter("names_nb"+out_cos_ch2);
			 				names_sub_String[out_cost11] = tr.req.getParameter("names_sub"+out_cos_ch2);
			 				metallic_nm_String[out_cost11] = tr.req.getParameter("metallic_nm"+out_cos_ch2);
			 				amount_String[out_cost11] = tr.req.getParameter("amount"+out_cos_ch2);
			 				estimatedcost_String[out_cost11] = tr.req.getParameter("estimatedcost"+out_cos_ch2);
			 				decidecost_String[out_cost11] = tr.req.getParameter("decidecost"+out_cos_ch2);
			 				note_String[out_cost11] = tr.req.getParameter("note"+out_cos_ch2);
			 				
			 				out_cost11++;
						}
					} 

		 			 System.out.println("여기111----");
					//출장 내용 삭제
					tr.sql.delete("pay.deleteout_cost_Sjfoma", exp_no);
		 			

					//출장 내용  신청서
					if(out_so_cost != null)
					{
						for(int row = 0; row<out_so_cost.length; row ++)
						{
							if(!"".equals(out_so_cost[row]))
							{
								
								
								params_sub.put("exp_no", exp_no);
								params_sub.put("exp_sq", (row+1));
								params_sub.put("production",  production_String[row]); 
								params_sub.put("guest_nm", guest_nm_String[row]);
								params_sub.put("names", 	names_String[row]); 
								params_sub.put("names_nb", names_nb_String[row]);
								params_sub.put("names_sub", names_sub_String[row]); 
								params_sub.put("metallic_nm", metallic_nm_String[row]);
								params_sub.put("amount", amount_String[row]);
								params_sub.put("estimatedcost", estimatedcost_String[row]);
								params_sub.put("decidecost", decidecost_String[row]);
								params_sub.put("note", note_String[row]);
	
								
								params_sub.put("cid", user.getReg_id());

								System.out.println(params_sub);
								
								tr.sql.insert("pay.insertout_so_costnm", params_sub);
								
							}
							
						}
						
					}	
					
					
					
				}else{
					
				}
				
				result = true;
				
				
				
				
				/* 
					예산통제 해당 문서들 --------------------------------------------------------------------------------------------------------------------------
				*/

				
				
				
				/* 예산통제 */
				
				String BudRst = ""; 
				String BudSave_yn = ""; 
				
				
					//tr.sql.delete("pay.deleteDetail", exp_no);
				
					
					if (exp_cd != null) { 
							for (int k=0; k<exp_cd.length; k++) { 
								if (!"".equals(exp_cd[k])) { 
									paramBudAcc.put("exp_no", exp_no);
									paramBudAcc.put("seq", (k+1));
									paramBudAcc.put("co_cd", user.getCo_cd());
									paramBudAcc.put("dept_cd", dept_cd2[k]);
									paramBudAcc.put("exp_cd",  exp_cd[k]);
									paramBudAcc.put("tot_amt", StringUtil.replace(StringUtil.normalize(tot_amt[k], "0"), ",", ""));
									paramBudAcc.put("acc_dt", account_dt);
									if ("JJ100100".equals(eps_type)) {
										paramBudAcc.put("cury_bc", tr.req.getParameter("p_cury_bc"));
									}else{
										paramBudAcc.put("cury_bc", cury_bc[k]);
									}
									
									
									
									//System.out.println("예산현황(지결금액 param)"+(k+1)+"  -------------   "+paramBudAcc);
									
									//통제 체크
									budValue = (HashMap<String, Object>)tr.sql.selectObject("pay.selectBudAcc", paramBudAcc);	
									//통제 결과 Y:통과, N:통제
									BudRst = StringUtil.normalizeNull(String.valueOf(budValue.get("result")));
									//저장 여부 Y:경보, N:통제
									BudSave_yn = StringUtil.normalizeNull(String.valueOf(budValue.get("save_yn")));
									
									bud_return_indx= String.valueOf(k+1);
									
									//System.out.println("예산"+ (k+1)+ "번째-----------   " + budValue);
									//System.out.println("통제 결과 Y:통과, N:통제 ---------   " + BudRst);
									//System.out.println("저장 여부 Y:경보, N:통제----------   " + BudSave_yn);
									
									
									//통제,  통제(저장안됨)
									if("N".equals(BudRst) && "N".equals(BudSave_yn)){
										break;
									}
									
								
									
								}
							}	
					} 
					
					
					
						
					if("N".equals(BudSave_yn)){//저장안됨
						
						result = false;
					
						//예산통제 
						//"N"
						if("N".equals(BudRst)){
							budChk = false;
						//"Y"
						}else{
							budChk = true;
						}
						
						System.out.println(" 예산 초과 ㅜㅜ ");
					}
					else
					{
						
						if("N".equals(BudRst)){
							budChk = false;
						//"Y"
						}else{
							budChk = true;
						}
						
						
						//System.out.println(" 예산 통과 ^^ ");
						
							//지출결의서 거래처
						if ("JJ100100".equals(eps_type)) {
							
							int car_all = 0;
							car_all = exp_cd.length+Integer.parseInt(dodelete_cnt); 
							 
							String voyageString[]= new String[car_all];
							String car_noString[]= new String[car_all];
							 
							int car_stst11 = 0;
					 		for(int car_ch2= 1; car_ch2<=(exp_cd.length+car_all); car_ch2++)
							{
					 			if(tr.req.getParameter("voyage"+car_ch2) != null || tr.req.getParameter("car_no"+car_ch2) != null)
								{
					 				voyageString[car_stst11] = tr.req.getParameter("voyage" + car_ch2);
					 				car_noString[car_stst11] = tr.req.getParameter("car_no" + car_ch2);
									
									car_stst11++;
								}
							} 
								
					 		
							tr.sql.delete("pay.deleteDetail", exp_no);
								
								if (exp_cd != null) { 
									for (int k=0; k<exp_cd.length; k++) { 
										if (!"".equals(exp_cd[k])) { 
											params2.put("tax_dt", tr.req.getParameter("p_tax_dt"));
											params2.put("tax_bc", tr.req.getParameter("p_tax_bc"));
											params2.put("exp_no", exp_no);
											params2.put("exp_sq", (k+1));
											params2.put("dsc", dsc[k]);
											params2.put("exp_cd", exp_cd[k]);
											params2.put("amt", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("AllAmt"), "0"), ",", ""));
											params2.put("vat", StringUtil.replace(StringUtil.normalize(tr.req.getParameter("vatval"), "0"), ",", ""));
											if (!"FA630195".equals(tr.req.getParameter("p_tax_bc"))) { 
												params2.put("vat_yn", "1");
											} else { 
												params2.put("vat_yn", "0");
											}
											params2.put("tot_amt", StringUtil.replace(StringUtil.normalize(tot_amt[k], "0"), ",", ""));
											params2.put("cust_cd", tr.req.getParameter("p_cust_cd"));
											params2.put("cust_nm", tr.req.getParameter("p_cust_nm")); 
											params2.put("reg_id", user.getReg_id());
											params2.put("dept_cd", dept_cd2[k]);
											// 환종
											params2.put("cury_bc", tr.req.getParameter("p_cury_bc"));
											// 지급요청일자 
											params2.put("pay_dt", tr.req.getParameter("p_pay_due_dt"));
											// 순번
											//params2.put("row_ty", row_ty[k]);
											// 선박
											params2.put("cd_vessel", cd_vessel[k]);
											// 항차
											params2.put("voyage", voyageString[k]);
											// E-tax/Other
											params2.put("iss_bc", tr.req.getParameter("p_iss_bc"));
											//차량
											params2.put("car_no", car_noString[k]);
											
											params2.put("biz_no", tr.req.getParameter("p_biz_no"));
											
											tr.sql.insert("pay.insertDetail", params2);
										}
									}
								}
								
/* 								
								
							
							int car_all = 0;
							car_all = tax_dt_list.length+Integer.parseInt(dodelete_cnt); 
							 
							String voyageString[]= new String[car_all];
							 
							 
							int car_stst11 = 0;
					 		for(int car_ch2= 1; car_ch2<=(tax_dt_list.length+car_all); car_ch2++)
							{
					 			if(tr.req.getParameter("voyage"+car_ch2) != null)
								{
					 				voyageString[car_stst11] = tr.req.getParameter("voyage" + car_ch2);
									
									car_stst11++;
								}
							} 
								
					 		
								tr.sql.delete("pay.deleteDetail", exp_no);
								
								
								if (tax_dt_list != null) { 
									for (int k=0; k<tax_dt_list.length; k++) { 
										if (!"".equals(tax_dt_list[k])) { 
											params2.put("tax_dt", tax_dt_list[k]);
											params2.put("tax_bc", tax_bc[k]);
											params2.put("exp_no", exp_no);
											params2.put("exp_sq", (k+1));
											params2.put("dsc", dsc[k]);
											params2.put("exp_cd", exp_cd[k]);
											params2.put("amt", StringUtil.replace(StringUtil.normalize(amt[k], "0"), ",", ""));
											params2.put("vat", StringUtil.replace(StringUtil.normalize(vat[k], "0"), ",", ""));
											if (!"".equals(vat[k]) && !"0".equals(vat[k])) { 
												params2.put("vat_yn", "1");
											} else { 
												params2.put("vat_yn", "0");
											}
											params2.put("tot_amt", StringUtil.replace(StringUtil.normalize(tot_amt[k], "0"), ",", ""));
											params2.put("cust_cd", cust_cd[k]);
											params2.put("cust_nm", tr.req.getParameter("cust_nm"+ (k + 1))); 
											params2.put("reg_id", user.getReg_id());
											params2.put("dept_cd", dept_cd2[k]);
											//프로젝트 
											//params2.put("pro_cd", pro_cd[k]);
											//cost center
											//params2.put("man_cd", man_cd[k]);
											// 환종
											params2.put("cury_bc", cury_bc[k]);
											// 지급요청일자 
											params2.put("pay_dt", pay_due_dt[k]);
											// 순번
											//params2.put("row_ty", row_ty[k]);
											// 선박
											params2.put("cd_vessel", cd_vessel[k]);
											// 항차
											params2.put("voyage", voyageString[k]);
											// E-tax/Other
											params2.put("iss_bc", iss_bc[k]);
											
											tr.sql.insert("pay.insertDetail", params2);
										}
									}
								}
							 */
							tr.sql.update("pay.updatePayRequestEpsType", params);
							
							result = true;
								
								
							//지출결의서 카드신청   //지출결의서 체크카드신청
						} else if (("JJ100200".equals(eps_type)) || ("JJ100201".equals(eps_type))) {
							
							int car_all = 0;
							car_all = tax_dt_list.length+Integer.parseInt(dodelete_cnt); 
							 
							String cust_nmString[]= new String[car_all];
							String car_noString[]= new String[car_all];
							 
							int car_stst11 = 0;
					 		for(int car_ch2= 1; car_ch2<=(tax_dt_list.length+car_all); car_ch2++)
							{
					 			if(tr.req.getParameter("cust_nm"+car_ch2) != null || tr.req.getParameter("car_no"+car_ch2) != null)
								{
					 				cust_nmString[car_stst11] = tr.req.getParameter("cust_nm" + car_ch2);
					 				car_noString[car_stst11] = tr.req.getParameter("car_no" + car_ch2);
					 				
									car_stst11++;
								}
							}  
							
					 		
					 		
								tr.sql.delete("pay.deleteDetail", exp_no);
		
								if (tax_dt_list != null) { 
									for (int k=0; k<tax_dt_list.length; k++) { 
										
										if (!"".equals(tax_dt_list[k])) { 
		
											//System.out.println("tax_dt_list"+tax_dt_list[k]);
											params2.put("tax_dt", tax_dt_list[k]);
											//params2.put("tax_bc", tax_bc[k]);
											params2.put("exp_no", exp_no);
											params2.put("card_no", card_no[k]);
											params2.put("exp_sq", (k+1));
											params2.put("dsc", dsc[k]);
											params2.put("exp_cd", exp_cd[k]);
											/* 
											params2.put("amt", StringUtil.replace(StringUtil.normalize(amt[k], "0"), ",", ""));
											params2.put("vat", StringUtil.replace(StringUtil.normalize(vat[k], "0"), ",", ""));
											if (!"".equals(vat[k]) && !"0".equals(vat[k])) { 
												params2.put("vat_yn", "1");
											} else { 
												params2.put("vat_yn", "0");
											}
											 */
											params2.put("tot_amt", StringUtil.replace(StringUtil.normalize(tot_amt[k], "0"), ",", ""));
											//params2.put("cust_cd", cust_cd[k]);
											params2.put("cust_nm", cust_nmString[k]); 
											params2.put("reg_id", user.getReg_id());
											params2.put("dept_cd", dept_cd2[k]);
											//params2.put("approve_no", STRACKNO[k]);
											//params2.put("card_sq", STRNONESEQS[k]);
											
											params2.put("APPR_DATE", StringUtil.replace(tax_dt_list[k],"-",""));
											params2.put("APPR_SEQ", StringUtil.normalize(STRNONESEQS[k], "0"));
											params2.put("APPR_DATE", STRBUYDATE[k]);
											params2.put("BANK_CD", BANK_CD[k]);
											
											//프로젝트 
											//params2.put("pro_cd", pro_cd[k]);
											//cost center
											//params2.put("man_cd", man_cd[k]);
											// 환종
											params2.put("cury_bc", cury_bc[k]);
											//차량
											params2.put("car_no", car_noString[k]);
											
											
											System.out.println(params2);
											tr.sql.insert("pay.insertDetail", params2);
										}
									
									}
								}
							
							tr.sql.update("pay.updatePayRequestEpsType", params);
							result = true;
							
							//지출결의서 사원
						} else if ("JJ100250".equals(eps_type)) {
							
							int car_all = 0;
							car_all = tax_dt_list.length+Integer.parseInt(dodelete_cnt); 
							
							String car_noString[]= new String[car_all];
							 
							 int car_stst11 = 0;
					 		 for(int car_ch2= 1; car_ch2<=(tax_dt_list.length+car_all); car_ch2++)
							 {
					 			
					 			if(tr.req.getParameter("car_no"+car_ch2) != null)
								{	
					 				car_noString[car_stst11] = tr.req.getParameter("car_no" + car_ch2);
					 				
								}
					 			
					 			car_stst11++;
					 			
							 }
							
					 		 
							
								tr.sql.delete("pay.deleteDetail", exp_no);
					
								if (tax_dt_list != null) { 
									
									
									for (int k=0; k<tax_dt_list.length; k++) { 
										if (!"".equals(tax_dt_list[k])) { 
											params2.put("tax_dt", tax_dt_list[k]);
											//params2.put("tax_bc", tax_bc[k]);
											params2.put("tax_bc", "FA630195");
											params2.put("exp_no", exp_no);
											//params2.put("emp_no", payemp_no[k]);
											params2.put("cust_cd", cust_cd[k]);
											params2.put("cust_nm", tr.req.getParameter("cust_nm"+ (k + 1))); 
											params2.put("exp_sq", (k+1));
											params2.put("dsc", dsc[k]);
											params2.put("exp_cd", exp_cd[k]);
											params2.put("amt", StringUtil.replace(StringUtil.normalize(amt[k], "0"), ",", ""));
											params2.put("vat", StringUtil.replace(StringUtil.normalize(vat[k], "0"), ",", ""));
											if (!"".equals(vat[k]) && !"0".equals(vat[k])) { 
												params2.put("vat_yn", "1");
											} else { 
												params2.put("vat_yn", "0");
											}
											params2.put("tot_amt", StringUtil.replace(StringUtil.normalize(tot_amt[k], "0"), ",", ""));
											params2.put("reg_id", user.getReg_id());
											params2.put("dept_cd", dept_cd2[k]);
											//프로젝트 
											//params2.put("pro_cd", pro_cd[k]);
											//cost center
											//params2.put("man_cd", man_cd[k]);
											// 환종
											params2.put("cury_bc", cury_bc[k]);
											// 지급요청일자 
											//params2.put("pay_dt", pay_due_dt[k]); 20250226 gmlee
											params2.put("pay_dt", p_pay_due_dt);
											//시내교통비 협조문
											params2.put("trans_doc", trans_doc[k]);
											//차량
											params2.put("car_no", car_noString[k]);
											// 카드여부
											params2.put("card_yn", card_yn[k]);
											
											tr.sql.insert("pay.insertDetail", params2);
											
										}
									}
								}
							
							tr.sql.update("pay.updatePayRequestEpsType", params);
							result = true;

							//지출결의서 시내교통비
						} else if ("JJ100255".equals(eps_type)) {
				
							int car_all = 0;
							car_all = tax_dt_list.length+Integer.parseInt(dodelete_cnt); 
							String trans_tmString[] = new String[car_all];
							
							 
							 int car_stst11 = 0;
					 		 for(int car_ch2= 1; car_ch2<=(tax_dt_list.length+car_all); car_ch2++)
							 {
					 			
					 			if(tr.req.getParameter("trans_tm"+car_ch2) != null)
								{
					 				trans_tmString[car_stst11] = tr.req.getParameter("trans_tm"+car_ch2);
									car_stst11++;
								}
							 }
							
					 		 
					 		 
								tr.sql.delete("pay.deleteDetail", exp_no);
								
					
								if (tax_dt_list != null) { 
									
									
									for (int k=0; k<tax_dt_list.length; k++) { 
										if (!"".equals(tax_dt_list[k])) { 
											params2.put("tax_dt", tax_dt_list[k]);
											//params2.put("tax_bc", tax_bc[k]);
											params2.put("tax_bc", "FA630195");
											params2.put("exp_no", exp_no);
											//params2.put("emp_no", payemp_no[k]);
											params2.put("cust_cd", cust_cd[k]);
											params2.put("cust_nm", tr.req.getParameter("cust_nm"+ (k + 1))); 
											params2.put("exp_sq", (k+1));
											params2.put("dsc", dsc[k]);
											params2.put("exp_cd", exp_cd[k]);
											params2.put("amt", StringUtil.replace(StringUtil.normalize(amt[k], "0"), ",", ""));
											params2.put("vat", StringUtil.replace(StringUtil.normalize(vat[k], "0"), ",", ""));
											if (!"".equals(vat[k]) && !"0".equals(vat[k])) { 
												params2.put("vat_yn", "1");
											} else { 
												params2.put("vat_yn", "0");
											}
											params2.put("tot_amt", StringUtil.replace(StringUtil.normalize(tot_amt[k], "0"), ",", ""));
											params2.put("reg_id", user.getReg_id());
											params2.put("dept_cd", dept_cd2[k]);
											//프로젝트 
											//params2.put("pro_cd", pro_cd[k]);
											//cost center
											//params2.put("man_cd", man_cd[k]);
											
											
											params2.put("trans_tm", trans_tmString[k]);
											params2.put("trans_doc", trans_doc[k]);
											// 결의일자 
											System.out.println("params2----"+params2);
											tr.sql.insert("pay.insertDetail", params2);
											
										}
									}
								}
							
							tr.sql.update("pay.updatePayRequestEpsType", params);
							result = true;

						//자기계발비   				JJ100977
						//체력단련비				JJ100430
						//통신비 지원비				JJ100431
						//거래처 경조금&경조화환 신청서	JJ100432	
						//경조사비 및 경조휴가신청서		JJ100800
						//의료비지원신청서 			JJ100810
						//교육신청서				JJ100972 제외시키기로 함
						//국내 출장신청서			JJ100963
						//해외 출장신청서			JJ100850
						//해외경비신청서				JJ100436
						//화물감독비신청서			JJ100434
						}else if ( ("JJ100977".equals(eps_type)) || ("JJ100430".equals(eps_type)) || ("JJ100431".equals(eps_type)) || ("JJ100432".equals(eps_type)) || ("JJ100800".equals(eps_type)) || ("JJ100810".equals(eps_type)) || ("JJ100963".equals(eps_type)) || ("JJ100850".equals(eps_type)) || ("JJ100436".equals(eps_type)) || ("JJ100434".equals(eps_type))) {
							
							tr.sql.delete("pay.deleteDetail", exp_no);		
										
							if (tax_dt_list != null) { 
								for (int k=0; k<tax_dt_list.length; k++) { 
									if (!"".equals(tax_dt_list[k])) { 
										//System.out.println("tax_dt_list"+tax_dt_list[k]);
										
										params2.put("tax_dt", tax_dt_list[k]);
										//params2.put("tax_bc", tax_bc[k]);
										params2.put("tax_bc", "FA630195");
										params2.put("exp_no", exp_no);
										params2.put("cust_cd", cust_cd[k]);
										params2.put("cust_nm", tr.req.getParameter("cust_nm"+ (k + 1))); 
										
										params2.put("exp_sq", (k+1));
										params2.put("dsc", dsc[k]);
										
										params2.put("exp_cd", exp_cd[k]);
										params2.put("amt", StringUtil.replace(StringUtil.normalize(amt[k], "0"), ",", ""));
										params2.put("vat", StringUtil.replace(StringUtil.normalize(vat[k], "0"), ",", ""));
										if (!"".equals(vat[k]) && !"0".equals(vat[k])) { 
											params2.put("vat_yn", "1");
										} else { 
											params2.put("vat_yn", "0");
										}
										params2.put("tot_amt", StringUtil.replace(StringUtil.normalize(tot_amt[k], "0"), ",", ""));
										params2.put("reg_id", user.getReg_id());
										params2.put("dept_cd", dept_cd2[k]);
										//프로젝트 
										//params2.put("pro_cd", pro_cd[k]);
										//cost center
										//params2.put("man_cd", man_cd[k]);
										// 환종
										params2.put("cury_bc", cury_bc[k]);
										// 지급요청일자 
										params2.put("pay_dt", pay_due_dt[k]);
										
										System.out.println(params2);
										tr.sql.insert("pay.insertDetail", params2);
									}
								}
							}
							tr.sql.update("pay.updatePayRequestEpsType", params);
							result = true;
							

							
						  //출장보고서				JJ100988
						  //해외출장보고서			JJ100851
						} else if (("JJ100988".equals(eps_type)) || ("JJ100851".equals(eps_type))) {
							
 
							
							String[] card_index = tr.req.getParameterValues("exp_sq");
							String[] emp_index = tr.req.getParameterValues("emp_exp_sq");
							//tr.sql.delete("pay.deleteDetail", exp_no);
							
							System.out.println("출장보고서 card_index ----" + card_index);
							System.out.println("출장보고서 emp_index ----" + emp_index);
							
							params.put("pay_type","JJ100200");
							
							tr.sql.delete("pay.deleteDetail_paytype", params);
							
							//지결 카드
							if (tax_dt_list != null) { 
								
								
								int car_all = 0;
								
								System.out.println("출장보고서 지결 ----" + tax_dt_list);	 
								car_all = tax_dt_list.length+Integer.parseInt(dodelete_cnt); 
								
								String cust_nmString[]= new String[car_all];
								 
								int car_stst11 = 0;
						 		for(int car_ch2= 1; car_ch2<=(tax_dt_list.length+car_all); car_ch2++)
								{
						 			if(tr.req.getParameter("cust_nm"+car_ch2) != null)
									{
						 				cust_nmString[car_stst11] = tr.req.getParameter("cust_nm" + car_ch2);
										
										car_stst11++;
									}
								} 
								
								for (int k=0; k<tax_dt_list.length; k++) { 
									
									if (!"".equals(tax_dt_list[k])) { 
										params2.put("tax_dt", tax_dt_list[k]);
										//params2.put("tax_bc", tax_bc[k]);
										params2.put("exp_no", exp_no);
										params2.put("card_no", card_no[k]);
										params2.put("exp_sq", card_index[k]);
										params2.put("dsc", dsc[k]);
										params2.put("category_gubun", category_gubun[k]);
										params2.put("exp_cd", exp_cd[k]);
										/* params2.put("amt", StringUtil.replace(StringUtil.normalize(amt[k], "0"), ",", ""));
										params2.put("vat", StringUtil.replace(StringUtil.normalize(vat[k], "0"), ",", ""));
										if (!"".equals(vat[k]) && !"0".equals(vat[k])) { 
											params2.put("vat_yn", "1");
										} else { 
											params2.put("vat_yn", "0");
										} */
										params2.put("tot_amt", StringUtil.replace(StringUtil.normalize(tot_amt[k], "0"), ",", ""));
										//params2.put("cust_cd", cust_cd[k]);
										params2.put("cust_nm", cust_nmString[k]); 
										params2.put("reg_id", user.getReg_id());
										params2.put("dept_cd", dept_cd2[k]);
										
										params2.put("APPR_DATE", StringUtil.replace(tax_dt_list[k],"-",""));
										params2.put("APPR_SEQ", StringUtil.normalize(STRNONESEQS[k], "0"));
										params2.put("APPR_DATE", STRBUYDATE[k]);
										params2.put("BANK_CD", BANK_CD[k]);
										
										
										//params2.put("approve_no", STRACKNO[k]);
										//params2.put("card_sq", STRNONESEQS[k]);
										/*구분값 추가 - 카드 */
										params2.put("pay_type", "JJ100200");
										//프로젝트 
										//params2.put("pro_cd", pro_cd[k]);
										//cost center
										//params2.put("man_cd", man_cd[k]);
										// 환종
										params2.put("cury_bc", cury_bc[k]);
									
										System.out.println("출장보고서 카드  --------  "+params2);
										tr.sql.insert("pay.insertDetail", params2);
									}
								
								}
							}
							
							
							
							
							/*지결 중복일때  사원*/ /*성진포머 출장보고서*/ /*지결 사원 비고*/
							/* 
							 String dscEmpString[] ;
							 dscEmpString = new String[30]; 
							int stst22 = 0;
							for(int ch2= 1; ch2<=30; ch2++)
							{
								if(tr.req.getParameter("emp_dsc"+ch2) != null)
								{
									dscEmpString[stst22] = tr.req.getParameter("emp_dsc"+ch2);
									System.out.println("emp_dsc"+dscEmpString[stst22]);
									stst22++;
								}
							}
							 */
							
							
 							
							 
							String emp_BudRst = ""; 
							String emp_BudSave_yn = ""; 
							
							
						 	
								if (emp_exp_cd != null) { 
										for (int k=0; k<emp_exp_cd.length; k++) { 
											if (!"".equals(emp_exp_cd[k])) { 
												paramBudAcc.put("exp_no", exp_no);
												paramBudAcc.put("seq", emp_index[k]);
												paramBudAcc.put("co_cd", user.getCo_cd());
												paramBudAcc.put("dept_cd", emp_dept_cd2[k]);
												paramBudAcc.put("exp_cd",  emp_exp_cd[k]);
												paramBudAcc.put("tot_amt", StringUtil.replace(StringUtil.normalize(emp_tot_amt[k], "0"), ",", ""));
												paramBudAcc.put("acc_dt", account_dt);
												//출장 통화
												params_emp.put("cury_bc", emp_cury_bc[k]);
												
												
												System.out.println("예산현황(지결금액 param)"+(k+1)+"  -------------   "+paramBudAcc);
												

												//통제 체크
												budValue = (HashMap<String, Object>)tr.sql.selectObject("pay.selectBudAcc", paramBudAcc);	
												//통제 결과 Y:통과, N:통제
												emp_BudRst = StringUtil.normalizeNull(String.valueOf(budValue.get("result")));
												//저장 여부 Y:경보, N:통제
												emp_BudSave_yn = StringUtil.normalizeNull(String.valueOf(budValue.get("save_yn")));
												
												bud_return_indx= String.valueOf(k+1);
												
												//System.out.println("예산"+ (k+1)+ "번째-----------   " + budValue);
												//System.out.println("통제 결과 Y:통과, N:통제 ---------   " + emp_BudRst);
												//System.out.println("저장 여부 Y:경보, N:통제----------   " + emp_BudSave_yn);
												
												
												//통제,  통제(저장안됨)
												if("N".equals(emp_BudRst) && "N".equals(emp_BudSave_yn)){
													break;
												}
												
												
												
											}
										}	
								} 
								
								
								
								
									
							if("N".equals(emp_BudSave_yn)){//저장안됨
							
								result = false;
							
								//예산통제 
								//"N"
								if("N".equals(emp_BudRst)){
									budChk = false;
								//"Y"
								}else{
									budChk = true;
								}
								
								System.out.println(" 예산 초과 ㅜㅜ ");
							}
							else
							{
								
								if("N".equals(emp_BudRst)){
									budChk = false;
								//"Y"
								}else{
									budChk = true;
								}
								
								
								
								
									//출장비
									params.put("pay_type","JJ100250");
									tr.sql.delete("pay.deleteDetail_paytype", params); 
									
									//개인비용
									params.put("pay_type","JJ100251");
									tr.sql.delete("pay.deleteDetail_paytype", params); 
									
									
									System.out.println("출장보고서 지결사원  emp_tax_dt.length ----- " + emp_tax_dt.length);
									
									//지결 사원
									if (emp_tax_dt != null) { 
										for (int k=0; k<emp_tax_dt.length; k++) { 
											if (!"".equals(emp_tax_dt[k])) { 
												
												params_emp.put("tax_dt", emp_tax_dt[k]);
												//params_emp.put("tax_bc", emp_tax_bc[k]);
												params_emp.put("tax_bc", "FA630195");
												params_emp.put("exp_no", exp_no);
												params_emp.put("exp_sq", 100 + Integer.parseInt(emp_index[k]));
												//params_emp.put("exp_sq", emp_index[k]);
												/* if(tax_dt_list != null){
													//System.out.println("tax_dt_list.length---------"+tax_dt_list.length);
													params_emp.put("exp_sq", (tax_dt_list.length+k+1));
												}else{
													params_emp.put("exp_sq", (k+1));
												} */
												params_emp.put("dsc", emp_dsc[k]);
												params_emp.put("category_gubun", emp_category_gubun[k]);
												//params_emp.put("emp_no", payemp_no[k]);
												params_emp.put("cust_cd", emp_cust_cd[k]);
												params_emp.put("cust_nm", tr.req.getParameter("emp_cust_nm"+ (k + 1))); 
												params_emp.put("exp_cd", emp_exp_cd[k]);												
												params_emp.put("amt", StringUtil.replace(StringUtil.normalize(emp_amt[k], "0"), ",", ""));
												params_emp.put("vat", StringUtil.replace(StringUtil.normalize(emp_vat[k], "0"), ",", ""));
												if (!"".equals(emp_vat[k]) && !"0".equals(emp_vat[k])) { 
													params_emp.put("vat_yn", "1");
												} else { 
													params_emp.put("vat_yn", "0");
												}
												params_emp.put("dept_cd", emp_dept_cd2[k]);
												params_emp.put("tot_amt", StringUtil.replace(StringUtil.normalize(emp_tot_amt[k], "0"), ",", ""));
												params_emp.put("reg_id", user.getReg_id());
												/*구분값 추가 - 사원*/ 
												params_emp.put("pay_type", emp_pay_type[k]);
												//프로젝트 
												//params_emp.put("pro_cd", emp_pro_cd[k]);
												//cost center
												//params_emp.put("man_cd", emp_man_cd[k]);
												// 환종
												params_emp.put("cury_bc", emp_cury_bc[k]);
												// 지급요청일자 
												params_emp.put("pay_dt", emp_pay_due_dt[k]);
												// 환종
												params_emp.put("card_yn", card_yn[k]);
												System.out.println("출장보고서 사원  params_emp--------  "+params_emp);
												tr.sql.insert("pay.insertDetail", params_emp);
											}
										}
									}
									
										 
								
								tr.sql.update("pay.updatePayRequestEpsType", params);
								result = true;
								
								
								 } 
							
						
					//사직서				 JJ100832 
					}else if ("JJ100832".equals(eps_type)){
							params.put("exp_no", exp_no);
							params.put("emp_no", tr.req.getParameter("rec_emp_no"));
							params.put("resignation_dt", tr.req.getParameter("resignation_dt"));
							params.put("last_dt", tr.req.getParameter("last_dt"));
							params.put("address", tr.req.getParameter("address"));
							params.put("reason", tr.req.getParameter("reason"));
							params.put("cid", user.getReg_id());
							
							tr.sql.insert("pay.insertResignationLetter", params);
						
					}else{
						
					}
							

			 	
				} 
					
		
			}			
					/*
						이병운 20140418 전표 를 수정했을때 사용한다
						ema200, ema210 을 변경한다 
					 */
					 
					 System.out.println("result -------- " + result);
				//if(budChk){ 
				if(result){ 
				
					if ("M".equals(list_type)) 
					 {
				 		tr.sql.update("pay.updateModify", params);
				 		
				 		result = true;
					 } 
					
				}else{
					System.out.println("budChk : " + budChk + "-- 예산초과로 결재수정 안됨~!");
					// 예산통제 걸릴경우 결재수정 안됨 
					result= false;
				}
					
					
		}			
		
	 	
	} catch (Exception e) 
	{ 
		e.printStackTrace();
		//String msg = e.getMessage();
		//System.out.println("msg ---" +e.getMessage());
		Test = "오류";
		
	}
	
	
	
	

%>
{"result" : "<%=result %>" , "exp_no": "<%=exp_no%>", "test": "<%=Test%>","All_Modify":
"<%=All_Modify %>" , "admin_no": "<%=admin_no%>" , "budChk" : "<%=budChk %>","bud_return_indx":"<%=bud_return_indx %>"}






---===---===---===---===---===---> AI 답변 :




tr.jsp를 살펴보니, 단순히 파라미터(파일명·크기 등)를 받아서 DB에 INSERT 하는 로직뿐이고, “실제 업로드”나 “용량 제한” 처리는 이 JSP가 아니라 `com.em.http.Transaction` 클래스나 그 아래에서 쓰는 multipart 처리 라이브러리(commons-fileupload 등) 설정에 들어 있을 가능성이 큽니다.

**따라서, 흐름과 용량 제한을 파악하려면 최소한 아래 두 가지만 공유해 주시면 됩니다.**

1. **`com/em/http/Transaction.java`** (파일 업로드를 어떻게 처리하는지)
2. 만약 Transaction이 프로퍼티나 XML 설정에서 최대 크기를 읽어온다면, 그 설정이 담긴 **properties/XML** (예: Spring `multipartResolver` 설정, `web.xml`의 filter·servlet 설정, 혹은 별도 프로퍼티 파일)

이 두 가지만 있으면 전체 업로드 흐름과 용량 제한 로직을 빠르게 파악할 수 있습니다.





=================================> AI에 질문 :


그럼 클래스도 보내줄게. 이건 별로 소스가 없는데.. 

package com.em.http;

import com.em.http.worker.CtxWorker;
import com.em.http.worker.ReqWorker;
import com.em.http.worker.ResWorker;
import javax.servlet.jsp.PageContext;

public class Transaction extends com.em.sql.Transaction
{
    public ReqWorker req;
    public ResWorker res;
    public CtxWorker ctx;
    private boolean isTransactionClosed;

    public Transaction()
    {
        isTransactionClosed = false;
    }

    public Transaction(PageContext pageContext)
    {
        isTransactionClosed = false;
        ctx = new CtxWorker(pageContext, this);
        res = new ResWorker(pageContext, this);
        req = new ReqWorker(pageContext, this);
        setHeaderNoCaching();
    }

    public void setHeaderNoCaching()
    {
        res.setHeaderNoCaching();
    }

    public void error(Exception e)
        throws Exception
    {
        ctx.forward("/error.jsp", e);
    }

    public void close()
        throws Exception
    {
        setTransactionClosed(true);
        if(req != null)
            req.close();
        if(res != null)
            try
            {
                res.flushJspWriter();
            }
            catch(Exception exception) { }
    }

    private void setTransactionClosed(boolean _isTransactionClosed)
    {
        isTransactionClosed = _isTransactionClosed;
    }

    public boolean isTransactionClosed()
    {
        return isTransactionClosed;
    }

}



---===---===---===---===---===---> AI 답변 :




업로드 용량 제한 로직은 이 `Transaction` 자체가 아니라, 이 안에서 실제 파일 처리를 담당하는 `ReqWorker` 쪽(또는 그 아래 Commons-FileUpload 같은 라이브러리 설정)에서 나오게 됩니다.

**다음 두 가지만 공유해 주시면 전체 흐름과 용량 제한을 파악할 수 있습니다.**

1. **`com/em/http/worker/ReqWorker.java`**
   – JSP에서 넘어온 multipart 요청을 파싱하고 파일을 저장하는 부분이 여기 있을 거예요.
2. **(만약 있다면) `web.xml` 또는 프로퍼티/XML 설정 중 multipart 관련 설정**
   – `<multipart-config>` 요소나, Spring의 `multipartResolver` 설정, Commons-FileUpload 최대 크기 프로퍼티 등이 해당합니다.

이 두 가지만 살펴보면 어디서 얼마만큼 제한하는지 바로 알 수 있습니다.





=================================> AI에 질문 :


ReqWorker

package com.em.http.worker;

import com.em.config.Configuration;
import com.em.http.Transaction;
import com.em.http.UploadFile;
import com.em.util.HttpUtil;
import com.em.util.StringUtil;
import com.oreilly.servlet.multipart.*;

import java.io.File;
import java.io.IOException;
import java.util.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.PageContext;

public class ReqWorker {

	private static int MAX_UPLOAD_SIZE = 20000000;
	private static final int MAX_MEMORY_SIZE = 0;
	private static final String UPLOAD_PATH = Configuration.getInitParameter("uploadPath");
	private HttpServletRequest m_request;
	private Transaction m_tr;
	private HashMap m_parameters;
	private HashMap m_files;
	
	
	
	private String mimeValue;

	public ReqWorker(PageContext pageContext, Transaction transaction) {
		m_request = (HttpServletRequest) pageContext.getRequest();
		try {
			m_request.setCharacterEncoding("UTF-8");
		} catch (Exception e) {
			e.printStackTrace();
		}
		m_tr = transaction;
		m_parameters = new HashMap();
		m_files = new HashMap();
		//String uploadPath = "C:\\workspace\\Cals\\upload";
		//String uploadPath = "D:\\Tomcat6\\webapps\\ROOT\\upload";
		String uploadPath = "C:\\Tomcat6\\webapps\\ROOT\\upload\\";
		
		String eps_type = (String)m_request.getAttribute("eps_type");
		
		
		    
		
		
		File tempDirectory = new File(uploadPath);
		if (!tempDirectory.exists())
			tempDirectory.mkdirs();
		if (isMultipart())
			try {
				MultipartParser multipartparser = new MultipartParser(m_request, MAX_UPLOAD_SIZE, true, true, "UTF-8");
String files = "";
String file = "";

String file_upload_key = "_UPLOAD";
String file_upload_value = "";

String file_size_key = "_SIZE";
String file_size_value = "";
				for (Part part = multipartparser.readNextPart(); part != null; part = multipartparser.readNextPart()) {
					if (part.isFile()) {
						FilePart filepart = (FilePart) part;
						UploadFile uploadfile = new UploadFile(filepart, tempDirectory);
						System.out.println(uploadfile+"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
						uploadfile.bind(pageContext);
						putFile(part.getName(), uploadfile);
						if (files.equals("")){
							file = part.getName();
							files = StringUtil.getLast(uploadfile.getFilename(), "\\");
							
							file_upload_value = StringUtil.getLast(uploadfile.getWriteFilename(), "/");
							//2016-08-17 수정 (Tomcat 폴더안에 쌓이지 않도록 함)
							file_upload_value = file_upload_value.replace(uploadPath, "");
							file_size_value = (new Long(uploadfile.getSize())).toString();
						}else{

							file = part.getName();
							files = files + ";" + StringUtil.getLast(uploadfile.getFilename(), "\\");
							
							//2016-08-17 수정 (Tomcat 폴더안에 쌓이지 않도록 함)
							file_upload_value = file_upload_value + ';' + StringUtil.getLast(uploadfile.getWriteFilename(), "/").replace(uploadPath, "");
							file_size_value = file_size_value + ";" + (new Long(uploadfile.getSize())).toString();
						}
						// setParameter(part.getName(), StringUtil.getLast(uploadfile.getFilename(), "\\"));
//						if (getParameter(part.getName()) != null) {
//							String before = getParameter(part.getName());
//							System.out.println("before"+before);
//							setParameter(part.getName(), before + "," + StringUtil.getLast(uploadfile.getFilename(), "\\"));
//							String after = getParameter(part.getName());
//							System.out.println("after"+after);
//						} else {
//							setParameter(part.getName(), StringUtil.getLast(uploadfile.getFilename(), "\\"));
//						}
//						setParameter((new StringBuilder(String.valueOf(part.getName()))).append("_UPLOAD").toString(), StringUtil.getLast(uploadfile.getWriteFilename(), "/"));
//						setParameter((new StringBuilder(String.valueOf(part.getName()))).append("_SIZE").toString(), (new Long(uploadfile.getSize())).toString());
					} else {
						ParamPart parampart = (ParamPart) part;
						String s = parampart.getStringValue();
						setParameter(part.getName(), s);
					}
				}
				setParameter(file, files);
				setParameter(file+file_upload_key, file_upload_value);
				setParameter(file+file_size_key, file_size_value);
				m_request.setAttribute("mparams", m_parameters);
				m_request.setAttribute("mparamsF", m_files);
				
			} catch (Exception exception) {
				if (exception instanceof IOException) {
					JspWriter out = pageContext.getOut();
					try {
						out.write("<script>alert('\uCCA8\uBD80\uD30C\uC77C \uC6A9\uB7C9\uC774 \uCD08\uACFC\uD558\uC600\uC2B5\uB2C8\uB2E4.'); history.back(-1);</script>");
						out.flush();
					} catch (Exception e2) {
						e2.printStackTrace();
					}
				}
				exception.printStackTrace();
			}
	}

	private boolean isMultipart() {
		String s = getContentType();
		if (s == null)
			return false;
		else
			return s.toLowerCase().startsWith("multipart/form-data");
	}

	private String getContentType() {
		String s = m_request.getHeader("Content-Type");
		String s1 = m_request.getContentType();
		if (s == null)
			return s1;
		if (s1 == null)
			return s;
		else
			return s.length() > s1.length() ? s : s1;
	}

	public void setParameter(String s, String s1) {
		setParameter(s, s1, false);
	}

	public void setParameter(String s, String s1, boolean flag) {
		if (s == null)
			throw new IllegalArgumentException("setParameter() called with null name.");
		String s2 = s.toUpperCase();
		if (m_parameters.containsKey(s2)) {
			HashMap hashmap = (HashMap) m_parameters.get(s2);
			if (flag)
				hashmap.put(StringUtil.toString(0), s1);
			else
				hashmap.put(StringUtil.toString(hashmap.size()), s1);
		} else {
			HashMap hashmap1 = new HashMap();
			hashmap1.put(StringUtil.toString(0), s1);
			m_parameters.put(s2, hashmap1);
		}
	}

	public String getParameter(String s) {
		if (s == null)
			return null;
		String s1 = s.toUpperCase();
		String s2 = null;
		HashMap hashmap = (HashMap) m_parameters.get(s1);
		if (hashmap != null)
			s2 = (String) hashmap.get(StringUtil.toString(0));
		if (!StringUtil.isDefined(s2))
			s2 = m_request.getParameter(s);
		return s2;
	}

	public String[] getParameterValues(String s) {
		if (s == null)
			return null;
		String s1 = s.toUpperCase();
		String as[] = null;
		HashMap hashmap = (HashMap) m_parameters.get(s1);
		if (hashmap == null) {
			as = m_request.getParameterValues(s);
		} else {
			as = new String[hashmap.size()];
			for (int i = 0; i < hashmap.size(); i++)
				as[i] = (String) hashmap.get(new Integer(i));

		}
		return StringUtil.decode(as);
	}

	private void putFile(String s, UploadFile uploadfile) {
		if (s == null)
			throw new IllegalArgumentException("putFile() called with null name.");
		String s1 = s.toUpperCase();
		if (m_files.containsKey(s1)) {
			HashMap hashmap = (HashMap) m_files.get(s1);
			hashmap.put(StringUtil.toString(hashmap.size()), uploadfile);
		} else {
			HashMap hashmap1 = new HashMap();
			hashmap1.put(StringUtil.toString(0), uploadfile);
			m_files.put(s1, hashmap1);
		}
	}

	public void close() throws Exception {
		Set set = getFileNames();
		if (set == null)
			return;
		else
			return;
	}

	public UploadFile[] getFiles(String s) {
		if (s == null)
			return null;
		HashMap hashmap = (HashMap) m_files.get(s);
		if (hashmap == null)
			return null;
		UploadFile auploadfile[] = new UploadFile[hashmap.size()];
		for (int i = 0; i < hashmap.size(); i++)
			auploadfile[i] = (UploadFile) hashmap.get(new Integer(i));

		return auploadfile;
	}

	public UploadFile[] getFiles() {
		if (m_files == null)
			return null;
		UploadFile auploadfile[] = new UploadFile[m_files.size()];
		for (int i = 0; i < m_files.size(); i++)
			auploadfile[i] = (UploadFile) m_files.get(new Integer(i));

		return auploadfile;
	}

	public Set getFileNames() {
		return m_files.keySet();
	}

	public void setAttribute(String s, Object obj) {
		if (StringUtil.isDefined(s) && obj != null)
			m_request.setAttribute(s.toUpperCase(), obj);
	}

	public void setAttribute(String s, int i) {
		setAttribute(s, Integer.toString(i));
	}

	public String getAttribute(String s) {
		return (String) getAttributeObject(s);
	}

	public Object getAttributeObject(String s) {
		if (StringUtil.isDefined(s))
			return m_request.getAttribute(s.toUpperCase());
		else
			return null;
	}

	public String getRequestURI() {
		return m_request.getRequestURI();
	}

	public void removeAttribute(String s) {
		if (StringUtil.isDefined(s))
			m_request.removeAttribute(s.toUpperCase());
	}

	public Enumeration getAttributeNames() {
		return m_request.getAttributeNames();
	}

	public boolean isMultipleRequested() {
		boolean isMultiple = false;
		if (HttpUtil.isTokenValid(m_request)) {
			m_request.setAttribute("tokenN", m_request.getParameter("token"));
			HttpUtil.setToken(m_request);
		} else {
			m_request.setAttribute("tokenN", "MULTIPLE_REQUEST");
			isMultiple = true;
		}
		return isMultiple;
	}

	public boolean isDirectRequested() {
		return !StringUtil.isDefined(m_request.getParameter("token"));
	}

	public void setToken() {
		HttpUtil.setToken(m_request);
	}

	public String getToken() {
		return (String) m_request.getAttribute("token");
	}

	public void clearToken() {
		HttpUtil.clearToken(m_request);
	}

}



---===---===---===---===---===---> AI 답변 :




`ReqWorker`를 살펴보면, 파일 업로드 용량 한계는 이 부분에서 정해집니다:

```java
// 최대 업로드 크기 (바이트)
private static int MAX_UPLOAD_SIZE = 20000000;
…
MultipartParser multipartparser = new MultipartParser(
    m_request,
    MAX_UPLOAD_SIZE,    // ← 여기에 설정된 크기(20,000,000B ≒ 19.1MB)
    true, true, "UTF-8"
);
```

* **현재 제한**: 20,000,000바이트 (약 19.1MB)
* **변경 방법**:

  1. `MAX_UPLOAD_SIZE` 값을 원하는 크기로 수정
  2. (더 나아가) 이 값을 직접 하드코딩하지 않고 `Configuration.getInitParameter("…")` 등으로 꺼내 쓰도록 리팩토링

예를 들어, `web.xml` 또는 별도 프로퍼티 파일에 `upload.max.size` 같은 이름으로 설정을 추가하고, `Configuration`에서 읽어오게 하면 배포 환경별로 유연하게 조정할 수 있습니다.





=================================> AI에 질문 :


몇 라인이야?


---===---===---===---===---===---> AI 답변 :





`ReqWorker.java`에서 파일 크기 제한을 설정하는 부분은 다음 두 곳입니다.

1. **선언부**

   ```java
   // ReqWorker.java, 20번째 줄
   private static int MAX_UPLOAD_SIZE = 20000000;
   ```
2. **사용부** (MultipartParser 생성자 호출)

   ```java
   // ReqWorker.java, 약 37번째 줄
   MultipartParser multipartparser =
       new MultipartParser(m_request,
                           MAX_UPLOAD_SIZE,  // ← 여기서 제한값을 사용
                           true, true, "UTF-8");
   ```

— 선언부(20행)에서 원하는 크기로 바꾸시면 됩니다.




=================================> AI에 질문 :


톰캣 없이 이클립스만으로 컴파일을 할 수 있지? 보통 어디에 class 파일이 생기지?


---===---===---===---===---===---> AI 답변 :



네, 이클립스만으로도 자바 소스(.java)는 바로 컴파일이 가능합니다.

1. **일반 자바 프로젝트**

   * 프로젝트 생성 시 기본 빌드 출력 폴더가 `bin/` 으로 설정되어 있어요.
   * 예를 들어 `MyProject/src/com/example/Foo.java` 를 컴파일하면

     ```
     MyProject/bin/com/example/Foo.class
     ```

     형태로 .class 파일이 생깁니다.
   * (Window → Preferences → Java → Build Path → Default output folder)에서 바꿀 수 있고, 프로젝트 속성에서도 개별적으로 조정 가능합니다.

2. **Dynamic Web Project (WTP)**

   * 웹 어플리케이션이라면, 실제 톰캣에 배포될 때는

     ```
     WebContent/WEB-INF/classes/
     ```

     폴더 아래로 복사·배포 되지만,
   * 이클립스 내부 빌드 시에도 역시

     ```
     MyWebProject/bin/             ←(실제 컴파일 산출물)
     MyWebProject/WebContent/WEB-INF/classes/  ←(배포용 복사본)
     ```

     이렇게 두 곳에 생성이 돼요.
   * (프로젝트 우클릭 → Properties → Java Build Path → Source 탭에서 “Default output folder” 확인)

3. **JSP 파일은 톰캣(혹은 다른 서블릿 컨테이너)이 런타임에 .java → .class 로 변환**

   * 이클립스만으론 JSP 컴파일(=서블릿 생성)을 못 하고, 톰캣이 구동될 때 `work/Catalina/localhost/프로젝트명/...` 안에 생성됩니다.

요약하면, **순수 자바 클래스 파일은**

```
프로젝트/bin/…
```

(혹은 설정한 output folder)
에,
**웹용 클래스는**

```
WebContent/WEB-INF/classes/…
```

(또는 배포 시 이 폴더로 복사)
에 각각 만들어집니다.






=================================> AI에 질문 :


이클립스에서 컴파일된 classs 파일 위치 확인하는 방법 알려줘


---===---===---===---===---===---> AI 답변 :




이클립스에서 “어디에 .class 파일이 생성되고 있는지” 보려면 아래 두 가지 방법이 있어요.

---

## 1. 패키지 탐색기에서 바로 확인하기

1. **Package Explorer** 뷰에 가서
2. 프로젝트를 펼치면 보통 `src/` 옆에 `bin/` (혹은 `target/classes/`) 폴더가 보여요.

   * 여기에 소스 폴더(`src/...`) 아래 구조 그대로 `.class` 파일이 들어갑니다.
   * 폴더가 보이지 않는다면 뷰 우측 상단의 햄버거 메뉴(“View Menu” ▶ “Filters…”)에서 **“.* resources”*\* 나 **“Derived resources”** 필터를 꺼 보세요.

---

## 2. 프로젝트 설정에서 출력 폴더(Output Folder) 확인하기

1. 프로젝트에서 우클릭 ▶ **Properties**
2. 좌측에서 **Java Build Path** 선택
3. 상단 탭 중 **Source** 클릭
4. 화면 중간에

   ```
   Source folder     |   Default output folder
   -------------------------------------------
   MyProject/src     |   MyProject/bin
   ```

   와 같이 각 소스 폴더에 대응하는 출력 폴더(Output folder) 칼럼이 나옵니다.

   * 기본 출력 폴더는 맨 위 “Default output folder” 항목으로 지정되어 있어요.
   * 여기서 더블클릭하거나 “Edit…” 버튼으로 다른 폴더(`WebContent/WEB-INF/classes` 등)로 바꿀 수도 있습니다.

---

### 팁

* **전역 기본값**을 바꾸고 싶다면
  `Window` ▶ `Preferences` ▶ `Java` ▶ `Build Path` ▶ `Default output folder` 에서 워크스페이스 전체에 적용될 기본 출력 폴더를 지정할 수 있습니다.
* **Dynamic Web Project** 의 경우, Eclipse 빌드 시엔 `bin/` 에 컴파일된 뒤, 서버(or WTP)가 배포 과정에서 `WebContent/WEB-INF/classes/` 로 복사해 줍니다.

이렇게 확인하시면, 지금 내 프로젝트에서 `.class` 파일이 어디에 생성되는지 바로 알 수 있습니다.





=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :









=================================> AI에 질문 :





---===---===---===---===---===---> AI 답변 :










