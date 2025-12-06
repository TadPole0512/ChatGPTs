

=================================> AI에 질문 :


VB.NET에서 현재 스레드가 단일 스레드 아파트에 없으므로 ActiveX 컨트롤 '5da6d279-adda-4f5b-821f-b211eb09ef1a'을(를) 인스턴스화할 수 없습니다.



---===---===---===---===---===---> AI 답변 :




이 에러 메시지는 “COM/ActiveX 컨트롤은 STA(Single-Threaded Apartment)에서만 인스턴스화할 수 있는데, 현재 스레드가 MTA(Multi-Threaded Apartment)이기 때문에 실패했다”는 뜻이야. 해결책은 크게 두 가지야.

---

## 1. 애플리케이션 진입점(Entry Point)에 STA 지정하기

* **Windows Forms 프로젝트**라면, 이미 Sub Main에 `<STAThread()>`가 붙어 있거나, 프로젝트 속성에서 “\[STAThread] 사용” 옵션이 켜져 있어야 해.
* **콘솔 애플리케이션**에서 ActiveX를 사용해야 한다면, `Sub Main` 앞에 `[STAThread]` 어트리뷰트를 붙여줘.

```vbnet
Module Program
    <STAThread()> _
    Sub Main()
        ' 여기에 ActiveX 컨트롤 생성 및 사용 코드
        Dim ax As New AxMyActiveXLib.AxMyControl()
        ' …
    End Sub
End Module
```

이렇게 하면 .NET 런타임이 `CoInitializeEx(NULL, COINIT_APARTMENTTHREADED)`를 호출해서 STA 환경을 구성해 줘.

---

## 2. 백그라운드 스레드에 STA 지정하기

ThreadPool 스레드나 `Task`(TPL) 스레드는 기본적으로 MTA이기 때문에, 여기서 ActiveX를 생성할 수 없어.
이럴 땐 직접 `Thread`를 만들어서 `SetApartmentState`로 STA를 지정한 뒤 시작해야 해.

```vbnet
Imports System.Threading

Sub CreateActiveXInSTA()
    Dim ax As New AxMyActiveXLib.AxMyControl()
    ' … ActiveX 사용
End Sub

Sub 사용예()
    Dim t As New Thread(AddressOf CreateActiveXInSTA)
    t.SetApartmentState(ApartmentState.STA)   ' STA로 설정
    t.Start()
    t.Join()
End Sub
```

> **주의:** `SetApartmentState`는 스레드 시작 전에만 호출할 수 있어. 이미 시작된 스레드는 바꿀 수 없어.

---

## 3. 직접 COM 초기화 호출하기 (P/Invoke)

만약 어트리뷰트나 `Thread` 사용이 곤란하다면, `CoInitializeEx`를 직접 호출해서 현재 스레드를 STA로 바꿀 수도 있어.

```vbnet
Imports System.Runtime.InteropServices

Module ComInit
    <DllImport("ole32.dll")>
    Private Function CoInitializeEx(pvReserved As IntPtr, dwCoInit As Integer) As Integer
    End Function

    Const COINIT_APARTMENTTHREADED As Integer = &H2

    Sub Main()
        Dim hr = CoInitializeEx(IntPtr.Zero, COINIT_APARTMENTTHREADED)
        If hr = 0 OrElse hr = &H1 Then   ' S_OK or S_FALSE
            Dim ax As New AxMyActiveXLib.AxMyControl()
            ' …
        Else
            Throw New Exception("COM 초기화 실패: HR=" & hr.ToString("X"))
        End If
    End Sub
End Module
```

---

### 요약

1. **앱 시작점**에 `<STAThread()>` 추가
2. **별도 스레드**에서 ActiveX 쓸 땐 `Thread.SetApartmentState(ApartmentState.STA)`
3. 필요하면 **P/Invoke**로 `CoInitializeEx(..., COINIT_APARTMENTTHREADED)` 직접 호출

이 중 하나를 적용하면 “현재 스레드가 단일 스레드 아파트에 없으므로…” 에러는 사라질 거야.





=================================> AI에 질문 :


Module TestEntry

```
    <STAThread()> _

Public Interface IMainFrame
    Sub ReadyMainForm()
End Interface

Sub Main()
    ' 여기에 ActiveX 컨트롤 생성 및 사용 코드
    Dim ax As New AxMyActiveXLib.AxMyControl()

    InitTestEnvironment()
    Application.EnableVisualStyles()
    Application.SetCompatibleTextRenderingDefault(False)
    Application.Run(New WrapperForm())
End Sub

Private Sub InitTestEnvironment()
    ' 테스트 세션 및 파라미터 초기화
    Login.FontNm = "맑은 고딕"
    Login.FontSz = 9.0F
    MainFrame.Frame = New MockMainFrame()
End Sub
```

End Module

이렇게 추가하면 안되?



---===---===---===---===---===---> AI 답변 :




아니, 지금처럼 `<STAThread()>` 애트리뷰트를 인터페이스 위에 붙이면 전혀 효과가 없어. VB에서는 애트리뷰트를 바로 아래 오는 선언(여기서는 Interface)에만 적용되거든.

Sub Main에 정확히 붙여줘야 해. 예를 들어:

```vbnet
Module TestEntry

    <STAThread()> _
    Public Sub Main()
        ' 여기에 ActiveX 컨트롤 생성 및 사용 코드
        Dim ax As New AxMyActiveXLib.AxMyControl()

        InitTestEnvironment()
        Application.EnableVisualStyles()
        Application.SetCompatibleTextRenderingDefault(False)
        Application.Run(New WrapperForm())
    End Sub

    Private Sub InitTestEnvironment()
        ' 테스트 세션 및 파라미터 초기화
        Login.FontNm = "맑은 고딕"
        Login.FontSz = 9.0F
        MainFrame.Frame = New MockMainFrame()
    End Sub

    Public Interface IMainFrame
        Sub ReadyMainForm()
    End Interface

End Module
```

1. `<STAThread()>`를 `Public Sub Main()` 선언 바로 위에 놓는다.
2. 프로젝트 속성 → 시작 개체(Startup object)를 `TestEntry.Main`으로 설정해야 제대로 이 Main이 실행된다.

이렇게만 바꿔도 “단일 스레드 아파트가 아니다” 오류는 없어질 거야.





=================================> AI에 질문 :


오류	5	'AxMyActiveXLib.AxMyControl' 형식이 정의되지 않았습니다.	C:\work\A.PROJ\40.CJ4DXPlex\VB\_****TEST****\_\CJ4DPLEX\modules\IV\CJIV007\TestEntry.vb	17	23	CJIV007

소스는 아래에 첨부했어.

' TestEntry.vb
Imports System.Windows.Forms
Imports Base9.Shared
Imports Base9.Parameter

Imports System.Diagnostics

Module TestEntry

```
Public Interface IMainFrame
    Sub ReadyMainForm()
End Interface

<STAThread()> _
Sub Main()
    ' 여기에 ActiveX 컨트롤 생성 및 사용 코드
    Dim ax As New AxMyActiveXLib.AxMyControl()

    InitTestEnvironment()
    Application.EnableVisualStyles()
    Application.SetCompatibleTextRenderingDefault(False)
    Application.Run(New WrapperForm())
End Sub

Private Sub InitTestEnvironment()
    ' 테스트 세션 및 파라미터 초기화
    Login.FontNm = "맑은 고딕"
    Login.FontSz = 9.0F
    MainFrame.Frame = New MockMainFrame()
End Sub
```

End Module

' WrapperForm.vb
Public Class WrapperForm
Inherits Form

```
Public Sub New()
    Me.Text = "폼 테스트 Wrapper"
    Me.Width = 1280
    Me.Height = 800

    ' 테스트할 Form 인스턴스 지정
    Dim testForm As New CJIV007() ' ★★★★★★★★★★★★★ 테스트 대상 폼 지정 
    testForm.Dock = DockStyle.Fill
    Me.Controls.Add(testForm)
End Sub
```

End Class

' MockMainFrame.vb
Public Class MockMainFrame
Implements IMainFrame

```
Public Sub ReadyMainForm() Implements IMainFrame.ReadyMainForm
    Debug.WriteLine("MockMainFrame.ReadyMainForm 호출됨")
End Sub
```

End Class



---===---===---===---===---===---> AI 답변 :




해당 에러는 컴파일러가 `AxMyActiveXLib.AxMyControl`이라는 형식을 전혀 모른다는 뜻이야. 즉, 프로젝트에 그 ActiveX 컨트롤의 COM-interop 어셈블리가 참조로 걸려 있지 않기 때문이지. 해결 방법은 크게 두 가지야.

---

## 1. Visual Studio에서 COM 참조 추가하기

1. **솔루션 탐색기**에서 프로젝트를 우클릭 → **참조 추가…**
2. 창 상단에서 **COM** 탭을 선택하거나, **찾아보기**로 `.ocx`나 `.tlb` 파일을 직접 지정
3. 리스트에서 해당 ActiveX 컨트롤(예: “MyActiveXLib Control”)을 찾아 체크 → 확인
4. 그러면 자동으로 `Interop.MyActiveXLib.dll` 과 `AxInterop.MyActiveXLib.dll` 두 개의 래퍼 어셈블리가 생성되어 **참조**에 추가돼
5. 코드 상단에 `Imports AxMyActiveXLib` (또는 실제 생성된 네임스페이스 이름) 을 걸어 주면 `New AxMyActiveXLib.AxMyControl()` 이 인식돼

> **팁:** 만약 COM 목록에 컨트롤이 보이지 않는다면, 관리자 권한으로 Visual Studio를 띄워 보거나, 시스템에 `.ocx`/`.dll` 파일을 `regsvr32` 로 등록한 뒤 다시 시도해 봐.

---

## 2. tlbimp.exe 로 수동 래퍼 생성하기

COM 라이브러리 파일이 직접 있고, VS 참조로 못 걸 경우에는 Microsoft의 **tlbimp.exe**(Type Library Importer) 툴을 사용할 수도 있어. 예를 들어:

```bat
cd "C:\Program Files (x86)\MyActiveX"
tlbimp MyActiveXLib.ocx /out:Interop.MyActiveXLib.dll
tlbimp MyActiveXLib.ocx /out:AxInterop.MyActiveXLib.dll /namespace:AxMyActiveXLib /codebase
```

이렇게 생성된 DLL을 프로젝트에 **참조 추가 → 찾아보기** 로 걸어 주면 돼.

---

### 네임스페이스 확인하기

참조가 제대로 추가된 후에는, 솔루션 탐색기 → 참조 → Interop 또는 AxInterop 쪽을 열어 실제 네임스페이스가 어떻게 생성됐는지 확인하고, 코드 최상단에

```vbnet
Imports MyActiveXLib            ' COM 인터페이스 네임스페이스
Imports AxMyActiveXLib          ' WindowsForms 호스팅 래퍼 네임스페이스
```

를 추가해 줘. 그 뒤에

```vbnet
Dim ax As New AxMyActiveXLib.AxMyControl()
```

이 정상적으로 컴파일될 거야.

---

이 과정을 마치고 다시 빌드하면, “형식이 정의되지 않았습니다” 에러는 사라질 거야.





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










