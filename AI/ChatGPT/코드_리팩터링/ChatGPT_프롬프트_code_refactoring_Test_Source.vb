Imports Base9
Imports Base9.Shared
Imports System.Reflection

Imports System.Net
Imports System.Net.Mail
Imports System.Text
Imports System
Imports System.Collections.Specialized
Imports System.Configuration
Imports System.Net.Sockets
Imports System.IO
Imports System.Text.RegularExpressions

Imports DevExpress.XtraEditors
Imports DevExpress.XtraGrid.Views.Base

Public Class CJSF023

    Dim DocId As String

    Public Property FormInfoDataSetNm As String = "cjsf023_s30"   ' 컨텐츠 Form 정보 DataSet

    Private contentsForm As Object = Nothing
    Private contentsFormCode As String
    Private contentsOpenParams As OpenParameters
    Private contents As String

    Private flyoutPanelFirstOpened = False

    Public Sub LoadAll(contentsFormCode As String, contentsParams As String, docId As String)
        ' 2025-04-29 hsg 에러 핸들링을 추가 : Try-Catch 블록을 추가하여 예상치 못한 예외 상황에서 에러 메시지를 표시. 기존 소스는 주석처리함
        'If Not String.Equals(Me.contentsFormCode, contentsFormCode) Then
        '    If contentsForm IsNot Nothing Then
        '        CType(contentsForm, Form).Dispose()
        '        SplitContainer1.Panel2.Controls.Remove(contentsForm)
        '        contentsForm = Nothing
        '    End If
        'End If

        'Me.contentsFormCode = contentsFormCode
        'Me.contents = contentsParams
        'Me.DocId = docId

        'LoadAll()

        Try
            ' 동일한 FormCode인지 확인 및 초기화
            If Not String.Equals(Me.contentsFormCode, contentsFormCode) Then
                DisposeContentsForm()
            End If

            ' 변수 설정
            Me.contentsFormCode = contentsFormCode
            Me.contents = contentsParams
            Me.DocId = docId

            ' 데이터 및 UI 초기화
            LoadAll()

        Catch ex As Exception
            ' 에러 발생 시 처리
        MessageBox.Show($"LoadAll 메서드에서 오류가 발생했습니다: {ex.Message}", "에러", MessageBoxButtons.OK, MessageBoxIcon.Error)
        End Try

    End Sub


    Public Sub LoadAll(contentsFormCode As String, contentsParams As String, prms As OpenParameters)

        Try
            ' 동일한 FormCode인지 확인 및 초기화
            If Not String.Equals(Me.contentsFormCode, contentsFormCode) Then
                DisposeContentsForm()
            End If

            ' 변수 설정
            Me.contentsFormCode = contentsFormCode
            Me.contents = contentsParams
            Me.contentsOpenParams = prms


            ' 데이터 및 UI 초기화
            LoadAll()

        Catch ex As Exception
            ' 에러 발생 시 처리
        MessageBox.Show($"LoadAll 메서드에서 오류가 발생했습니다: {ex.Message}", "에러", MessageBoxButtons.OK, MessageBoxIcon.Error)
        End Try

    End Sub


    ' 2025-04-29 hsg 동일한 FormCode이 아닐 경우 기존 contentsForm 제거
    Private Sub DisposeContentsForm()
        ' 기존 contentsForm 제거
        If contentsForm IsNot Nothing Then
            CType(contentsForm, Form).Dispose()
            SplitContainer1.Panel2.Controls.Remove(contentsForm)
            contentsForm = Nothing
        End If
    End Sub



    Public Sub LoadAll()
        ''If String.IsNullOrEmpty(contentsFormCode) Or String.IsNullOrEmpty(doc_id.Text) Then
        ''    Return
        ''End If

        '' 결재 패널 숨기기
        'SplitContainer1.Panel1Collapsed = True

        ' '' 사용자 검색 패널 화면 뒤로 숨기기
        ''user_search_pop.SendToBack()

        ' '' 문서와 관련된 기초 정보 가져오기(유형, 결재 진행 여부, 권한)
        ''LoadDocBaseInfo()

        ' '' 문서 유형 설정
        ''doc_type_cd.Text = DocTypeCode

        '' 결재 관련 폼 데이터 불러오기
        'Open()

        ' '' 결재 라인 처리 유형 Combo 재설정
        ''g900.SetCombo("dl_status_cd", allProcStatusDataSet)

        ' '' 수신/참조 처리 유형 Combo 재설정
        ''g910.SetCombo("dl_status_cd", refStatusDataSet)

        '' 그리드 Extra 이벤트 핸들러 등록
        ''Dim gridView = CType(g100.GridView, DevExpress.XtraGrid.Views.BandedGrid.BandedGridView)
        ''AddHandler gridView.ShownEditor, AddressOf g100_ShownEditor
        ''gridView = CType(g910.GridView, DevExpress.XtraGrid.Views.BandedGrid.BandedGridView)
        ''AddHandler gridView.ShownEditor, AddressOf g910_ShownEditor

        '' 컨텐츠 화면 로딩
        'LoadContentsForm()

        '' 결재 화면 타이틀 설정
        'If contentsForm IsNot Nothing Then
        '    ' 컨텐츠 Form 정보 조회
        '    Dim params As New OpenParameters()
        '    params.Add("@form_cd", contentsFormCode)
        '    Dim dataSet = OpenDataSet(FormInfoDataSetNm, params)
        '    If Not IsEmpty(dataSet) Then
        '        max_head_title_lbl.Text = "  " + DataValue(dataSet, "name") + " - " + Text
        '        min_head_title_lbl.Text = "  " + DataValue(dataSet, "name") + " - " + Text
        '    End If
        'End If

        '' 결재 패널을 슬라이딩 패널과 연결한 후 슬라이딩 패널 보이기
        'If Not FlyoutPanel.IsPopupOpen AndAlso flyoutPanelFirstOpened Then
        '    approval_pnl.Parent = FlyoutPanel
        '    FlyoutPanel.ShowPopup()
        'End If

        '' 결재 라인 Minimized 패널 Hide
        'min_head_pnl.Visible = False


        'user_search_pop.Visible = False

        ' 2025-04-29 hsg 에러 핸들링을 추가 : Try-Catch 블록을 추가하여 예상치 못한 예외 상황에서 에러 메시지를 표시. 기존 소스는 주석처리함
        Try
            ' 결재 패널 숨기기
            SplitContainer1.Panel1Collapsed = True

            ' 결재 관련 폼 데이터 불러오기
            Open()

            ' 컨텐츠 화면 로딩
            LoadContentsForm()

            ' 화면 타이틀 설정
            If contentsForm IsNot Nothing Then
                Dim params As New OpenParameters()
                params.Add("@form_cd", contentsFormCode)

                Dim dataSet = OpenDataSet(FormInfoDataSetNm, params)
                If Not IsEmpty(dataSet) Then
                    Dim title = "  " + DataValue(dataSet, "name") + " - " + Text
                    max_head_title_lbl.Text = title
                    min_head_title_lbl.Text = title
                End If
            End If

            ' 팝업 표시
            ShowFlyoutPanel()

        Catch ex As Exception
            ' 에러 발생 시 처리
        MessageBox.Show($"LoadAll 메서드에서 오류가 발생했습니다: {ex.Message}", "에러", MessageBoxButtons.OK, MessageBoxIcon.Error)
        End Try
    End Sub

    ' 2025-04-29 hsg 추가
    Private Sub ShowFlyoutPanel()
        ' 결재 패널을 슬라이딩 패널과 연결한 후 슬라이딩 패널 보이기
        If Not FlyoutPanel.IsPopupOpen AndAlso flyoutPanelFirstOpened Then
            approval_pnl.Parent = FlyoutPanel
            FlyoutPanel.ShowPopup()
        End If
        min_head_pnl.Visible = False
        user_search_pop.Visible = False

    End Sub

    Private Sub Form_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load

        min_head_title_lbl.Text = "공통알람"
        max_head_title_lbl.Text = "공통알람"

        mail_title.Text = "화면 알림 입니다."

        ' 2025-04-29 hsg contents 값 확인 및 mail_contents 초기화 추가
        If Not String.IsNullOrEmpty(contents) AndAlso mail_contents IsNot Nothing Then
            mail_contents.Text = Me.contents
            mail_contents.Refresh()

            'Debug.WriteLine(mail_contents.Text) ' 디버거를 사용해 실제 값 확인.
        Else
            MessageBox.Show("contents 값이 비어 있거나 mail_contents가 초기화되지 않았습니다.", "오류", MessageBoxButtons.OK, MessageBoxIcon.Error)
        End If

    End Sub

    Private Sub user_search_btn_Click(sender As Object, e As EventArgs) Handles user_search_btn.Click
        ' 2025-04-28 hsg 뭘 모르니 슬쩍 넣어봄.
        user_search_pop.Visible = True
        user_search_pop.TopMost = True

        ' 사용자 검색 패널 화면 앞으로
        user_search_pop.BringToFront()
    End Sub

    Private Sub mailing_list_btn_Click(sender As Object, e As EventArgs) Handles mailing_list_btn.Click

    End Sub

    ''' 컨텐츠 폼 동적 생성 및 결제 화면 컨텐츠 Panel에 폼 추가
    Public Sub LoadContentsForm()
        If contentsForm IsNot Nothing Then
            'If contentsForm.GetType().GetMethod("SetOpenParameters") IsNot Nothing Then
            '    contentsForm.SetOpenParameters(contentsOpenParams, True)
            'End If
        Else
            Dim targetAssembly As Assembly = Assembly.Load(contentsFormCode)
            If targetAssembly Is Nothing Then
                Exit Sub
            End If

            contentsForm = targetAssembly.CreateInstance([GetType]().Namespace + "." + contentsFormCode)
            If contentsForm Is Nothing Then
                Exit Sub
            End If

            SetFont(CType(contentsForm, Form).Controls, New Font(Parameter.Login.FontNm, Parameter.Login.FontSz))
            ' 2025-04-28 hsg 위. 아래 순서 변경.
            CType(contentsForm, Form).Dock = DockStyle.Fill
            CType(contentsForm, Form).AutoScaleMode = AutoScaleMode.Inherit

            'If contentsForm.GetType().GetMethod("SetOpenParameters") IsNot Nothing Then
            '    contentsForm.SetOpenParameters(contentsOpenParams)
            'End If

            SplitContainer1.Panel2.Controls.Add(contentsForm)

        End If
    End Sub

    Private Sub SetFont(targetControls As ControlCollection, font As Font)
        For Each target In targetControls
            Dim control As Control = CType(target, Control)
            If control.Controls.Count > 0 Then
                SetFont(control.Controls, font)
            End If
            control.Font = font
        Next
    End Sub

    ''' 화면 그리기(로드시 정렬 및 화면 작동 버튼 클릭시)
    Private Sub CJSF023_Paint(sender As Object, e As PaintEventArgs) Handles MyBase.Paint
        If Not flyoutPanelFirstOpened Then
            'If String.IsNullOrEmpty(contentsFormCode) OrElse String.IsNullOrEmpty(doc_id.Text) Then
            '    Return
            'End If

            approval_pnl.Parent = FlyoutPanel
            FlyoutPanel.ShowPopup()
            FlyoutPanel.ParentForm = ParentForm
            flyoutPanelFirstOpened = True
        End If
    End Sub

    ''' 최소화 화면 열기
    Private Sub open_btn_Click(sender As Object, e As EventArgs) Handles open_btn.Click
        min_head_pnl.Visible = False
        approval_pnl.Parent = FlyoutPanel
        FlyoutPanel.ShowPopup()
    End Sub

    ''' 화면 최소화
    Private Sub close_btn_Click(sender As Object, e As EventArgs) Handles close_btn.Click
        FlyoutPanel.HidePopup()
        approval_pnl.Parent = SplitContainer1.Panel1
    End Sub

    ''' 화면 최소화시 타이틀 표시
    Private Sub FlyoutPanel_Hidden(sender As Object, e As DevExpress.Utils.FlyoutPanelEventArgs) Handles FlyoutPanel.Hidden
        min_head_pnl.Visible = True
        open_btn.Visible = True
    End Sub

    ''' 화면 최소화시 타이틀 위치
    Private Sub SplitContainer1_Resize(sender As Object, e As EventArgs) Handles SplitContainer1.Resize
        Dim yCoord = Height - min_head_pnl.Height
        If yCoord < 0 Then
            yCoord = 0
        End If
        min_head_pnl.Location = New Point(0, yCoord)
    End Sub


#Region "Email 발송"
    Private Sub send_email_btn_Click(sender As Object, e As EventArgs) Handles send_email_btn.Click

        'Dim custName As String = "홍길동"
        'Dim salDate As String = "2025-04-18"
        'Dim subject As String = "[XX제강] {custName} {salDate} 납품확인서"
        'Dim body As String = "<h3>{custName} 고객님</h3><p>납품 내용을 확인 부탁드립니다.</p>"
        'Dim email As String = "customer@example.com"

        'Dim fileName As String = EmailService.MakeSafeFileName(subject) & ".pdf"

        '' PDF는 DevExpress 리포트로 Export 후 지정된 Temp 폴더에 저장한다고 가정
        '' 실제 ExportToPdf(filePath)는 따로 처리 필요

        'If EmailService.SendEmail(subject, body, email, fileName) Then
        '    MessageBox.Show("메일이 성공적으로 전송되었습니다.")
        'Else
        '    MessageBox.Show("메일 전송에 실패했습니다.")
        'End If

        Try
            Dim mailMessage As MailMessage = New MailMessage()

            mailMessage.From = New MailAddress("gm.lee9@cj.net", "이광민", Encoding.UTF8)
            ' 받는이 메일 주소
            mailMessage.[To].Add("gm.lee9@cj.net")
            '' 참조 메일 주소
            'mailMessage.CC.Add("zzz@naver.com")
            '' 비공개 참조 메일 주소
            'mailMessage.Bcc.Add("kkk@naver.com")
            ' 제목
            mailMessage.Subject = "메일 제목"
            ' 메일 제목 인코딩 타입(UTF-8) 선택
            mailMessage.SubjectEncoding = Encoding.UTF8
            ' 본문
            mailMessage.Body = "메일 본문"
            ' 본문의 포맷에 따라 선택
            mailMessage.IsBodyHtml = False
            ' 본문 인코딩 타입(UTF-8) 선택
            mailMessage.BodyEncoding = Encoding.UTF8
            '' 파일 첨부
            'mailMessage.Attachments.Add(New Attachment(New FileStream("D:\test.zip", FileMode.Open, FileAccess.Read), "test.zip"))
            ' SMTP 서버 주소
            'Dim SmtpServer As SmtpClient = New SmtpClient("smtp.cj.net")
            Dim SmtpServer As SmtpClient = New SmtpClient("172.16.80.62")

            'properties.put("mail.transport.protocol", "smtp");
            'properties.put("mail.smtp.host", "172.16.80.62");
            'properties.put("mail.smtp.auth", "true");

            ' SMTP 포트
            SmtpServer.Port = 25
            ' SSL 사용 여부
            SmtpServer.EnableSsl = True
            SmtpServer.UseDefaultCredentials = False
            SmtpServer.DeliveryMethod = Net.Mail.SmtpDeliveryMethod.Network
            SmtpServer.Credentials = New Net.NetworkCredential("gmlee9", "rhkdals5*")

            SmtpServer.Send(mailMessage)
        Catch exc As Exception
            MessageBox.Show(exc.Message)
        End Try

    End Sub

    '전송함수 호출
    Private Function EmailSend(ByVal SubJect As String, ByVal Body As String, ByVal Email As String) As Boolean

        'Try
        '    ' 설정 읽기
        '    Dim smtpServer As String = ConfigurationManager.AppSettings("SmtpServer")

        '    Dim smtpServer2 As String = Configuration("SmtpServer")

        '    Dim smtpPort As Integer = Integer.Parse(ConfigurationManager.AppSettings("SmtpPort"))
        '    Dim fromEmail As String = ConfigurationManager.AppSettings("MailFrom")
        '    Dim fromName As String = ConfigurationManager.AppSettings("MailFromName")
        '    Dim useSsl As Boolean = Boolean.Parse(ConfigurationManager.AppSettings("SmtpUseSsl"))
        '    Dim tempFolder As String = ConfigurationManager.AppSettings("TempFolder") ' 예: C:\Temp

        '    ' 전체 파일 경로 구성
        '    Dim fullFilePath As String = Path.Combine(tempFolder, attachmentFileName)

        '    ' 메일 구성
        '    Using mail As New MailMessage()
        '        mail.From = New MailAddress(fromEmail, fromName)
        '        'mail.To.Add(toEmail)
        '        mail.To.Add("gm.lee9@cj.net")
        '        mail.Subject = SubJect
        '        mail.Body = Body
        '        mail.SubjectEncoding = Encoding.UTF8
        '        mail.BodyEncoding = Encoding.UTF8
        '        mail.IsBodyHtml = True ' HTML 메일 허용

        '        If File.Exists(fullFilePath) Then
        '            mail.Attachments.Add(New Attachment(fullFilePath))
        '        End If

        '        ' SMTP 클라이언트 구성 및 전송
        '        Using client As New SmtpClient(smtpServer, smtpPort)
        '            client.UseDefaultCredentials = True
        '            client.EnableSsl = useSsl
        '            client.Send(mail)
        '        End Using
        '    End Using

        '    Return True
        'Catch ex As Exception
        '    ' 오류 로그 기록
        '    Dim logPath As String = ConfigurationManager.AppSettings("ErrorLogPath") ' 예: C:\Temp\mail_error.log
        '    File.AppendAllText(logPath, DateTime.Now & " - " & ex.ToString() & Environment.NewLine)
        '    Return False
        'End Try

    End Function

    ' 파일 이름으로 사용 가능한 문자열로 변환 (특수문자 제거)
    Public Shared Function MakeSafeFileName(input As String) As String
        Return Regex.Replace(input, "[\\/:*?""<>|]", "_")
    End Function

#End Region

End Class