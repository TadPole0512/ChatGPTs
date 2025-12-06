

=================================> AI에 질문 :


생성 시 호출되는 함수와 자동 호출되는 함수 두 종류만 추출
JAVADOC 스타일로 주석 추가
함수 내부 로직은 줄 단위로 자세하고 상세히 생성
출력 시 추출되는 함수의 기존 소스는 유지
추가, 수정, 삭제 시 주석으로 강조하여 눈에 띄게 생성하고,
기존 주석이 필요없어 삭제 시 주석으로 기존 로직 처리하고 설명 달기



---===---===---===---===---===---> AI 답변 :



Imports Base9
Imports Base9.Shared
Imports System.Reflection
Imports DevExpress.XtraEditors
Imports DevExpress.XtraGrid.Views.Base

Public Class CJSF013

    Public Property DocProcessDataSetNm As String = "CJ_DocProcessYn"
    Public Property ApprovalLineIdDataSetNm As String = "CJ_DocGetLineId"
    Public Property ApprovalReqCnlAuthDataSetNm As String = "CJ_DocReqCnlYn"
    Public Property ApprovalAuthDataSetNm As String = "CJ_DocApvRejYn"
    Public Property ApprovalLineChkDataSetNm As String = "CJ_DocLineChk"
    Public Property ApprovalRquestCancelDataSetNm As String = "CJ_DocReqCnl"
    Public Property ApprovalRejectDataSetNm As String = "CJ_DocApvRejCm"

    Public Property ProcStatusDataSetNm As String = "cjsf013_s10"
    Public Property RefStatusDataSetNm As String = "cjsf013_s20"
    Public Property FormInfoDataSetNm As String = "cjsf013_s30"
    Public Property ApprovalStatus As String = "cjsf013_s40"
    Public Property RerequestDataSetNm As String = "cjsf013_s50"

    Public Property SavedDocStatusCode As String = "SF109100"
    Public Property ApprovalRequestDocStatusCode As String = "SF109200"

    Public Property RequestStatusCode As String = "SF111000"
    Public Property AgreeStatusCode As String = "SF111100"
    Public Property AdjustStatusCode As String = "SF111200"
    Public Property ApprovalStatusCode As String = "SF111300"
    Public Property ReferStatusCode As String = "SF111400"
    Public Property RecvStatusCode As String = "SF111500"

    Public Property ApprovalProcCode As String = "SF114100"
    Public Property RejectProcCode As String = "SF114200"

    Public Property DocId As String
    Public Property DocTypeCode As String
    Public Property ApprovalProcFlag As String
    Public Property HasRequestAuth As Boolean = False
    Public Property HasRequestCancelAuth As Boolean = False
    Public Property HasApprovalAndRejectAuth As Boolean = False
    Public Property HasRequestAgain As Boolean

    Private contentsForm As Object = Nothing
    Private contentsFormCode As String
    Private contentsOpenParams As OpenParameters
    Private allProcStatusDataSet As DataSet
    Private procStatusDataSet As DataSet
    Private refStatusDataSet As DataSet

    Private flyoutPanelFirstOpened = False

    ''' <summary>
    ''' 폼이 Paint 될 때 최초 FlyoutPanel 초기화 및 연결 처리
    ''' </summary>
    ''' <param name="sender">폼</param>
    ''' <param name="e">Paint 이벤트 인자</param>
    Private Sub CJSF013_Paint(sender As Object, e As PaintEventArgs) Handles MyBase.Paint
        ' 최초 1회만 동작하도록 플래그 체크
        If Not flyoutPanelFirstOpened Then
            ' 필수 값이 비어있으면 처리하지 않음
            If String.IsNullOrEmpty(contentsFormCode) OrElse String.IsNullOrEmpty(doc_id.Text) Then
                Return
            End If

            '▼ 최초 로드 시 슬라이딩 패널 초기화 연결 처리
            approval_pnl.Parent = FlyoutPanel
            FlyoutPanel.ShowPopup()
            FlyoutPanel.ParentForm = ParentForm
            flyoutPanelFirstOpened = True
        End If
    End Sub

    ''' <summary>
    ''' 폼이 로드될 때 다국어 텍스트 설정 등 초기화 처리
    ''' </summary>
    ''' <param name="sender">폼 객체</param>
    ''' <param name="e">이벤트 인자</param>
    Private Sub Form_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
        '▼ 언어별 다국어 처리
        Select Case Parameter.Login.LangNo
            Case "1"
                approval_line_lbl.Text = "결재선"
                ref_line_lbl.Text = "수신/참조"
                min_head_title_lbl.Text = "결재요청 및 승인"
                max_head_title_lbl.Text = "결재요청 및 승인"
            Case "2"
                approval_line_lbl.Text = "The approval line"
                ref_line_lbl.Text = "Receive/Reference"
                min_head_title_lbl.Text = "Request for approval"
                max_head_title_lbl.Text = "Request for approval"
            Case "3"
                approval_line_lbl.Text = "审批流程"
                ref_line_lbl.Text = "收件人/抄送人"
                min_head_title_lbl.Text = "审批申请"
                max_head_title_lbl.Text = "审批申请"
        End Select
    End Sub

    ''' <summary>
    ''' 화면 크기 변경 시 하단 패널 위치 재계산
    ''' </summary>
    ''' <param name="sender">SplitContainer1 컨트롤</param>
    ''' <param name="e">이벤트 인자</param>
    Private Sub SplitContainer1_Resize(sender As Object, e As EventArgs) Handles SplitContainer1.Resize
        '▼ 화면 높이에 따라 하단 패널 위치 조정
        Dim yCoord = Height - min_head_pnl.Height
        If yCoord < 0 Then
            yCoord = 0
        End If
        min_head_pnl.Location = New Point(0, yCoord)
    End Sub

    ''' <summary>
    ''' FlyoutPanel 숨겨질 때 하단 열기 버튼 표시
    ''' </summary>
    ''' <param name="sender">FlyoutPanel</param>
    ''' <param name="e">이벤트 인자</param>
    Private Sub FlyoutPanel_Hidden(sender As Object, e As DevExpress.Utils.FlyoutPanelEventArgs) Handles FlyoutPanel.Hidden
        min_head_pnl.Visible = True
        open_btn.Visible = True
    End Sub

    ''' <summary>
    ''' 결재 화면 열기 버튼 클릭 시 FlyoutPanel 팝업 표시
    ''' </summary>
    ''' <param name="sender">버튼</param>
    ''' <param name="e">이벤트 인자</param>
    Private Sub open_btn_Click(sender As Object, e As EventArgs) Handles open_btn.Click
        min_head_pnl.Visible = False
        approval_pnl.Parent = FlyoutPanel
        FlyoutPanel.ShowPopup()
    End Sub

    ''' <summary>
    ''' 결재 화면 닫기 버튼 클릭 시 FlyoutPanel 숨기기
    ''' </summary>
    ''' <param name="sender">버튼</param>
    ''' <param name="e">이벤트 인자</param>
    Private Sub close_btn_Click(sender As Object, e As EventArgs) Handles close_btn.Click
        FlyoutPanel.HidePopup()
        approval_pnl.Parent = SplitContainer1.Panel1
    End Sub

End Class






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










