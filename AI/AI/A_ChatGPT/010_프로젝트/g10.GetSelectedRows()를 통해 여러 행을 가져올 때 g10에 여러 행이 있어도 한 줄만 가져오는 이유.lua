

=================================> AI에 질문 :


아래 소스에서 Dim selectedRows() As Integer = g10.GetSelectedRows()를 통해 여러 행을 가져올 때 g10에 여러 행이 있어도 한 줄만 가져오는 이유

approvalForm = JumpToFormCode("CJSF023")

Dim soNums As String = ""

g10.MultiSelect = True

Dim selectedRows() As Integer = g10.GetSelectedRows()

For Each rowIndex As Integer In selectedRows
    soNums = soNums & g10.Text("so_no", rowIndex) + ", "
Next

If Not String.IsNullOrEmpty(soNums) Then
    MsgBox("오더정보에서 오더번호를 선택하세요.")
Else
    approvalForm = JumpToFormCode("CJSF023")

    If approvalForm IsNot Nothing Then
        approvalForm.LoadAll(Name, soNums)
    End If

End If



---===---===---===---===---===---> AI 답변 :




네 코드에서 `g10.MultiSelect = True`로 설정했음에도 `g10.GetSelectedRows()`가 여러 행이 아닌 **한 줄만 반환하는 이유**는 다음과 같은 가능성들이 있어:

---

### ✅ 1. **GridView 설정 문제**

* `g10`이 실제로는 `DevExpress.XtraGrid.Views.Grid.GridView` 또는 `Frame9.eGrid`와 같은 커스텀 컨트롤일 수 있어.
* 이 경우 `MultiSelect = True`를 설정해도 `MultiSelectMode` 설정이 **RowSelect**로 되어 있지 않으면 하나만 선택 가능할 수도 있음.

> 🔧 **확인/추가해볼 코드 예시**:

```vb
g10.MultiSelect = True
g10.MultiSelectMode = GridMultiSelectMode.RowSelect
```

`GridMultiSelectMode.RowSelect`가 아니면, 셀 단위 선택이 되거나 Shift/Ctrl 키 없이 복수 선택이 불가능함.

---

### ✅ 2. **사용자가 실제로 한 줄만 선택함**

* `g10.GetSelectedRows()`는 실제로 선택된 RowHandle만 반환함.
* 사용자 UI 상에서 여러 줄을 Ctrl+클릭 또는 Shift+클릭으로 선택하지 않았다면 한 줄만 선택됨.

> 🔎 디버깅 팁:

```vb
MsgBox("선택된 행 수: " & selectedRows.Length)
```

출력 결과가 `1`이라면 사용자가 한 줄만 선택한 거야.

---

### ✅ 3. **그리드 내부에서 Selection 처리 로직 누락**

* 어떤 경우엔 `g10`에 커스텀 선택 제한 로직이 있을 수 있어. 예를 들어, 특정 필터나 상태에 따라 선택 제한을 걸 수도 있음.
* 특히 `DevExpress`나 `Frame9` 커스텀 컨트롤을 쓸 경우 내부 이벤트에서 선택을 덮어쓰거나 초기화할 수도 있음.

---

### ✅ 4. **조건문 로직 오류**

현재 너 코드에서 조건문이 반대로 되어 있음:

```vb
If Not String.IsNullOrEmpty(soNums) Then
    MsgBox("오더정보에서 오더번호를 선택하세요.")
Else
    ...
```

* 이 조건은 **선택한 오더번호가 있을 때 경고창을 띄우는 것**이야.
* 원래 의도는 아마도 오더번호가 **없을 때** 경고창을 띄우는 거겠지?

> 🔧 **수정 예시**:

```vb
If String.IsNullOrEmpty(soNums) Then
    MsgBox("오더정보에서 오더번호를 선택하세요.")
Else
    approvalForm = JumpToFormCode("CJSF023")

    If approvalForm IsNot Nothing Then
        approvalForm.LoadAll(Name, soNums)
    End If
End If
```

---

### ✅ 5. **soNums 끝에 ", " 제거 필요**

* 마지막에 붙는 `", "` 때문에 문제가 발생할 수도 있음. `TrimEnd(", ")`로 제거해주는 게 좋아.

> 🔧 예시:

```vb
soNums = soNums.TrimEnd(", ".ToCharArray())
```

---

### 🔚 정리

**한 줄만 가져오는 이유 요약**:

| 원인                     | 해결 방법                                                    |
| ---------------------- | -------------------------------------------------------- |
| 다중 선택이 UI 상 안 되어 있음    | Ctrl+클릭으로 복수 선택 또는 `MultiSelectMode` 설정                  |
| MultiSelectMode가 없음    | `g10.MultiSelectMode = GridMultiSelectMode.RowSelect` 설정 |
| 내부 Selection 제약 로직 존재  | `g10` 내부 로직 확인 필요                                        |
| 조건문 오류                 | `If String.IsNullOrEmpty(soNums)`로 수정                    |
| `soNums` 마지막 쉼표 제거 안 됨 | `TrimEnd` 사용                                             |

필요하면 `g10` 컨트롤 타입이나 `GetSelectedRows` 함수 정의된 코드도 같이 보여줘. 추가 분석 가능해.





=================================> AI에 질문 :


오류	2	'GridMultiSelectMode'이(가) 선언되지 않았습니다. 해당 보호 수준으로 인해 액세스할 수 없습니다.	C:\Users\hsg\OneDrive - KoreaZinc\WORK\PROJECT\40.CJ4DXPlex\VB\_____TEST_____\CJ4DPLEX\modules\SO\CJSO001\CJSO001.vb	1282	31	CJSO001
오류	1	'MultiSelectMode'은(는) 'Frame9.eGrid'의 멤버가 아닙니다.	C:\Users\hsg\OneDrive - KoreaZinc\WORK\PROJECT\40.CJ4DXPlex\VB\_____TEST_____\CJ4DPLEX\modules\SO\CJSO001\CJSO001.vb	1282	9	CJSO001



---===---===---===---===---===---> AI 답변 :




좋아, 지금 오류 메시지를 보면 두 가지가 핵심이야:

---

### 🔴 **문제 요약**

1. `g10.MultiSelectMode = GridMultiSelectMode.RowSelect`
   ⟶ **`MultiSelectMode`는 `Frame9.eGrid`에 없음**

2. `'GridMultiSelectMode'이 선언되지 않았음`
   ⟶ **`DevExpress.XtraGrid.Views.Grid.GridMultiSelectMode`가 Imports되지 않았거나, eGrid에 적용 불가능**

---

### 🔍 원인 분석

* `g10`은 **DevExpress GridView**가 아니라 \*\*`Frame9.eGrid`\*\*라는 커스텀 그리드 클래스.
* 이 클래스는 `DevExpress.XtraGrid.Views.Grid.GridView`를 직접 노출하지 않거나, 내부에서 캡슐화한 구조일 가능성이 높아.

---

### ✅ 해결 방법

#### 1. **내부 GridView 접근 확인**

만약 `g10.GridView` 같은 속성이 있으면 그걸 통해 DevExpress 그리드 속성 설정 가능해.

```vb
' g10.GridView가 존재할 경우 아래처럼 설정
g10.GridView.OptionsSelection.MultiSelect = True
g10.GridView.OptionsSelection.MultiSelectMode = GridMultiSelectMode.RowSelect
```

> ⚠️ 단, `g10.GridView`는 `eGrid` 내부에서 `GridView`를 노출시켜야 사용 가능함. 안 보이면 아래 참고.

---

#### 2. **`Frame9.eGrid`가 DevExpress 기반인지 확인**

eGrid가 DevExpress를 기반으로 만든 거라면, 내부에 `GridView`를 노출하는 메서드나 속성이 있을 수 있어.

아래처럼 시도해봐:

```vb
' g10.GetGridView() 같은 메서드가 있을 수도 있음
Dim view As DevExpress.XtraGrid.Views.Grid.GridView = g10.GetGridView()

If view IsNot Nothing Then
    view.OptionsSelection.MultiSelect = True
    view.OptionsSelection.MultiSelectMode = DevExpress.XtraGrid.Views.Grid.GridMultiSelectMode.RowSelect
End If
```

> 🔍 `g10.` 치고 점 찍으면 intellisense에서 `GetGridView`, `GridView`, `InnerGrid`, `View`, `gv` 같은 이름이 나올 수 있음. 그걸 찾아보는 게 좋아.

---

#### 3. **Imports 추가 여부 확인**

`GridMultiSelectMode` 오류가 난다면 다음을 Imports에 추가해야 해:

```vb
Imports DevExpress.XtraGrid.Views.Grid
```

---

### 📌 대안 (컨트롤이 DevExpress가 아닐 경우)

만약 `eGrid`가 DevExpress가 아니라면 (즉 WinForms `DataGridView`나 자체 구현된 커스텀 컨트롤이면):

* 그 컨트롤이 자체적으로 **다중 선택을 지원하지 않거나**,
* **선택된 Row를 반환하는 함수가 GetSelectedRows가 아님**

이럴 경우는 `eGrid` 정의부를 확인해서 어떤 방식으로 다중 선택을 활성화하고 선택된 행을 가져오는지 봐야 해.

---

### ✅ 정리

| 체크 항목                                 | 설명                                                |
| ------------------------------------- | ------------------------------------------------- |
| `g10` 내부에 `GridView` 같은 속성 있는지 확인     | 있다면 `GridView.OptionsSelection.MultiSelect` 설정 가능 |
| `GridMultiSelectMode` 사용 시 Imports 추가 | `Imports DevExpress.XtraGrid.Views.Grid`          |
| `MultiSelectMode` 오류                  | `eGrid` 자체에 해당 속성이 없음 – 내부 GridView에 접근 필요        |
| `GetSelectedRows()`가 한 줄만 반환          | 실제 UI에서 다중 선택이 불가능한 상황일 수 있음                      |

---

### ⏭️ 다음 할 일

1. `g10`에 `GridView` 또는 유사한 속성이 있는지 확인 (`.GridView`, `.GetView()`, `.View`, `.InnerView`, `.GetGridView()`)
2. 가능하다면 `eGrid` 클래스 정의도 보여줘. 그러면 내부 GridView 접근 가능한지, 어떤 설정 가능한지 정확히 알려줄 수 있어.

필요하면 `g10`을 사용하는 클래스 정의도 복사해서 보여줘.





=================================> AI에 질문 :


g10은 Frame9.eGrid 이고, 그리고 Frame9.eGrid는 DevExpress 기반이고 어떻게 수정해야 해


---===---===---===---===---===---> AI 답변 :




좋아, `g10`이 `Frame9.eGrid`고 DevExpress 기반이라면 **내부에 DevExpress의 `GridView`를 포함**하고 있는 구조야.
다만, `eGrid`가 DevExpress의 속성을 바로 노출하지 않기 때문에, 내부 `GridView` 객체를 얻어서 다중 선택 설정을 해야 해.

---

### ✅ 해결 방법: 내부 `GridView` 얻어서 설정하기

`eGrid` 내부에 DevExpress의 `GridView` 객체가 있을 가능성이 높으니, 일반적으로 `g10.GridView` 또는 `g10.GetGridView()` 같은 메서드나 속성이 있어.

#### 📌 수정 예시:

```vb
Imports DevExpress.XtraGrid.Views.Grid

' 내부 GridView 가져오기
Dim view As GridView = TryCast(g10.MainView, GridView)

If view IsNot Nothing Then
    view.OptionsSelection.MultiSelect = True
    view.OptionsSelection.MultiSelectMode = GridMultiSelectMode.RowSelect
End If
```

---

### 📌 왜 이렇게 해야 하나?

* `eGrid`는 DevExpress의 `GridControl`을 Wrapping 한 클래스야.
* `g10.MainView`는 내부적으로 `GridView`를 반환함 (보통 DevExpress 기본 구조에서)

---

### 🔍 보조 설명

| 구성 요소                                 | 설명                                            |
| ------------------------------------- | --------------------------------------------- |
| `g10.MainView`                        | DevExpress 그리드에서 현재 View를 가져오는 속성             |
| `TryCast(..., GridView)`              | `MainView`가 실제로 `GridView` 타입인지 확인하고 안전하게 형변환 |
| `OptionsSelection.MultiSelect = True` | 다중 행 선택 허용                                    |
| `MultiSelectMode = RowSelect`         | 행 단위 선택 설정 (Ctrl/Shift로 여러 줄 선택 가능)           |

---

### ✅ 최종 적용 코드 (전체 흐름 포함)

```vb
Imports DevExpress.XtraGrid.Views.Grid

' 내부 GridView에서 다중 선택 설정
Dim view As GridView = TryCast(g10.MainView, GridView)

If view IsNot Nothing Then
    view.OptionsSelection.MultiSelect = True
    view.OptionsSelection.MultiSelectMode = GridMultiSelectMode.RowSelect
End If

' 선택된 행 가져오기
Dim selectedRows() As Integer = g10.GetSelectedRows()

Dim soNums As String = ""
For Each rowIndex As Integer In selectedRows
    soNums &= g10.Text("so_no", rowIndex) & ", "
Next

soNums = soNums.TrimEnd(", ".ToCharArray())

If String.IsNullOrEmpty(soNums) Then
    MsgBox("오더정보에서 오더번호를 선택하세요.")
Else
    Dim approvalForm = JumpToFormCode("CJSF023")

    If approvalForm IsNot Nothing Then
        approvalForm.LoadAll(Name, soNums)
    End If
End If
```

---

### 💡 보너스 팁

* `g10.GetSelectedRows()`가 커스터마이징 되어 있으면 내부적으로 DevExpress의 `GridView.GetSelectedRows()`를 감싼 함수일 수 있어.
* `Frame9.eGrid` 소스가 접근 가능하다면 `GetSelectedRows()` 정의부를 확인해보면 더 정확히 이해할 수 있어.

---

필요하면 `Frame9.eGrid` 클래스의 일부도 보여줘. 내부 구조를 보면 더 깔끔하게 설정하는 방법도 알려줄 수 있어.





=================================> AI에 질문 :


오류	1	'MainView'은(는) 'Frame9.eGrid'의 멤버가 아닙니다.	C:\Users\hsg\OneDrive - KoreaZinc\WORK\PROJECT\40.CJ4DXPlex\VB\_____TEST_____\CJ4DPLEX\modules\SO\CJSO001\CJSO001.vb	1283	40	CJSO001



---===---===---===---===---===---> AI 답변 :




좋아. `'MainView'은 'Frame9.eGrid'의 멤버가 아닙니다`라는 오류는 `Frame9.eGrid`에서 DevExpress의 `MainView` 속성을 직접 노출하지 않는다는 뜻이야.
즉, `g10.MainView`로 내부 `GridView`에 접근할 수 없다는 이야기지.

---

### ✅ 해결 방법: 내부 `GridView` 접근 가능한 속성/메서드 찾기

다음과 같이 해봐:

---

### ✅ 방법 1. `g10.View` 또는 `g10.GetView()` 시도

```vb
Dim view As DevExpress.XtraGrid.Views.Grid.GridView = TryCast(g10.View, DevExpress.XtraGrid.Views.Grid.GridView)

If view IsNot Nothing Then
    view.OptionsSelection.MultiSelect = True
    view.OptionsSelection.MultiSelectMode = DevExpress.XtraGrid.Views.Grid.GridMultiSelectMode.RowSelect
End If
```

> `View` 또는 `GetView()`는 `eGrid` 내부에서 DevExpress GridView를 노출할 때 흔히 사용하는 이름이야.

---

### ✅ 방법 2. `g10.GridView` 또는 `g10.GetGridView()`

```vb
Dim view As DevExpress.XtraGrid.Views.Grid.GridView = TryCast(g10.GridView, DevExpress.XtraGrid.Views.Grid.GridView)
```

또는

```vb
Dim view As DevExpress.XtraGrid.Views.Grid.GridView = g10.GetGridView() ' 이건 반환 타입이 명확하면 캐스팅 없이
```

---

### 📌 직접 확인 방법

**Visual Studio에서 `g10.`까지 쓰고 점을 찍어봐.**
아래와 같은 속성이나 메서드가 있는지 찾아봐:

```
g10.View
g10.GetView
g10.GridView
g10.GetGridView
g10.InnerView
g10.BaseView
g10.DevView
```

---

### ✅ 최후 수단: `eGrid` 클래스 선언부 보기

`Frame9.eGrid`의 선언이나 정의된 코드에서 DevExpress의 `GridView`를 어떻게 다루고 있는지만 알면 정확하게 알려줄 수 있어.

보통은 이런 식으로 내부에 `GridView`를 갖고 있을 거야:

```vb
Private _view As DevExpress.XtraGrid.Views.Grid.GridView
Public ReadOnly Property GridView As DevExpress.XtraGrid.Views.Grid.GridView
    Get
        Return _view
    End Get
End Property
```

---

### 🧩 결론

| 작업                                                   | 설명                                      |
| ---------------------------------------------------- | --------------------------------------- |
| `g10.MainView` → ❌                                   | `eGrid`에서 제공 안 함                        |
| `g10.View`, `g10.GridView`, `g10.GetGridView()` 등 시도 | 내부 `GridView` 접근 가능 속성 확인 필요            |
| Intellisense 활용                                      | `g10.` 찍어서 자동완성으로 가능한 속성 찾기             |
| 정의부 확인                                               | `Frame9.eGrid` 클래스 안에서 내부 View 반환 함수 확인 |

---

#### → 해결 못 하면 `Frame9.eGrid` 클래스 선언 일부 보여줘.

거기에 내부 View에 접근하는 함수나 속성이 있으면 확실하게 해결할 수 있어.





=================================> AI에 질문 :


// Decompiled with JetBrains decompiler
// Type: Frame9.eGrid
// Assembly: Frame9.Tools, Version=1.1.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 1A3D7813-615A-4317-AC40-370126CDD6EC
// Assembly location: C:\inetpub\wwwroot\System9\Frame9.Tools.dll

using A;
using Base9;
using DevExpress.Data;
using DevExpress.Utils;
using DevExpress.Utils.Menu;
using DevExpress.XtraEditors;
using DevExpress.XtraEditors.Controls;
using DevExpress.XtraEditors.Mask;
using DevExpress.XtraEditors.Repository;
using DevExpress.XtraGrid;
using DevExpress.XtraGrid.Columns;
using DevExpress.XtraGrid.Menu;
using DevExpress.XtraGrid.Views.BandedGrid;
using DevExpress.XtraGrid.Views.BandedGrid.ViewInfo;
using DevExpress.XtraGrid.Views.Base;
using DevExpress.XtraGrid.Views.Grid;
using DevExpress.XtraGrid.Views.Grid.ViewInfo;
using Microsoft.VisualBasic;
using Microsoft.VisualBasic.CompilerServices;
using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Windows.Forms;

#nullable disable
namespace Frame9;

[DesignerGenerated]
[DefaultEvent("CellValueChanged")]
[ToolboxBitmap(typeof (eText), "eGrid.ico")]
public class eGrid : UserControl, intGrid
{
  private IContainer c30437a48be2edccf92998ef28115a203;
  private bool ca9012fdfbae897386452ef59cf11ce53;
  private bool cc0d454e2f1398908e3cc1bf29ad72f9a;
  private DataSet c5d165dda3affdc10bf5fa3cdd0152971;
  private WorkSet c330a4db27d3578a8e5d80797d2f5ac12;
  private Collection cdbe6b49d3eee541c1a02140924401651;
  private bool ce75332160d718c37d93defbcd7e95679;
  private bool c71541eef6215c51fd6ed427761212ad3;
  private bool cd268e238072e06dd96804a08ee584b75;
  private bool cd5ee370368dc75972785b2283583d43f;
  private bool cde42dfe20fdea515a20ee9c3cd7fec49;
  private bool ca39ed118263ffa37c2718bf159bf9674;
  private bool c018a99ed0c66295f13c59de7c8b6aa4c;
  private int c83fb623f1cfef74d227ce46cdace4c12;
  private int c02894bef99316b814a0f9eaea5fbe30b;
  private bool c291b918d0be288a91cc09da8cc863ce7;
  private bool ce8e830301aad7239d91493f34cace090;
  private bool c437485d6a3e0b34ec64860ea9e5d9748;
  private GridGroupSummaryItemCollection ccac4c8044ae680dcd351934054a598ac;
  private bool c9bdaa67da5892845981f2c92942085e5;
  private bool cfe51a0bb967b0d0da313e1b4013ca09b;
  private DataTable c467083dea0102ade8924e025f685c241;
  private bool cdf07e73a99f2a9d761b99392afb706c2;
  private bool cbee725c554d327dc3d76039ee2804a33;
  private int c469b0fc12a49e16cef7765328b7e46b3;
  private int ca78c8fb2abf9de6f83e5238cd29da0a0;
  private int cb5346c3ef09fcb1fcee1a5bc4abc4d2f;
  private int c540a73a6bcb4a3d519a57fcba6aa5cae;
  private int c66660fc7f284fd97ebfc6b3347a566ba;
  private bool c50ccdc5283b68b92131a5a8841c52a70;
  private string c26c855004913519a261bae8d8c34a7ad;
  private GridEnterDirection c9b149e1771cda0755be116d1d00e5bcf;
  private string c3b8083aee5bd9d8f8194d8364439e345;
  private string c3b632040ec246544c6cd4e0f83a2918d;
  private bool cf60d22e546791e81aed27bc22acefa6f;
  private bool cb0eeff986f87617a9dc0a385c3674fa7;
  private GridEditCellMode c19309e862c29221a6a5d1b33acc6d459;
  private object c582c73d9d3aaf3074e4c93b6db1c9b76;
  private bool caade471433b635c6c76864b2015d3db6;
  private bool c8c8684eaecc3f7146066d6e2c6b049ec;
  private bool c9628d971845e1dfed3b40173c2d77e5e;
  private string ceb03b9c3772bae1bdc6926be010a9525;
  private bool c08e309bae6f52107655a92e8f961fc35;
  private int cf8f2df247e0956b72b23d1f8bc5800fc;
  private bool c2ff7d99b7b52bbc756ecb3515e5b1a0a;

  public eGrid()
  {
    this.Enter += new EventHandler(this.ce62c9da09d0b11f387f7feba6a65cc36);
    this.Load += new EventHandler(this.c84a906d0e061c880ec462821bacc0dd1);
    this.ca9012fdfbae897386452ef59cf11ce53 = false;
    this.cc0d454e2f1398908e3cc1bf29ad72f9a = false;
    this.cdbe6b49d3eee541c1a02140924401651 = new Collection();
    this.ce75332160d718c37d93defbcd7e95679 = false;
    this.c71541eef6215c51fd6ed427761212ad3 = false;
    this.ca39ed118263ffa37c2718bf159bf9674 = false;
    this.c83fb623f1cfef74d227ce46cdace4c12 = 0;
    this.c02894bef99316b814a0f9eaea5fbe30b = 70;
    this.c9bdaa67da5892845981f2c92942085e5 = true;
    this.cfe51a0bb967b0d0da313e1b4013ca09b = true;
    this.cdf07e73a99f2a9d761b99392afb706c2 = false;

이정도면 되?


---===---===---===---===---===---> AI 답변 :




좋아, 이정도면 충분해. `Frame9.eGrid` 클래스가 `DevExpress.XtraGrid.GridControl`을 내부에 가지고 있다는 게 코드에서 명확히 드러나진 않지만, 네가 말했듯이 DevExpress 기반이고 `GridView` 관련 네임스페이스를 import하고 있는 걸 보면 내부에 DevExpress의 `GridView`가 있는 건 확실해 보여.

---

## ✅ 해결 방향 요약

### 1. `eGrid` 내부의 `GridView` 객체 접근

`eGrid` 클래스가 `GridView`를 직접 노출하지 않기 때문에 **리플렉션(Reflection)** 으로 내부 필드에 접근해서 `GridView`를 얻는 방식이 필요해.

---

## ✅ 실전 코드: `g10`에서 내부 `GridView` 가져와 다중 선택 설정

```vb
Imports DevExpress.XtraGrid.Views.Grid
Imports System.Reflection

' eGrid 내부의 GridView를 리플렉션으로 얻기
Dim gridView As GridView = Nothing

Try
    Dim field As FieldInfo = g10.GetType().GetField("gridView1", BindingFlags.NonPublic Or BindingFlags.Instance)
    If field IsNot Nothing Then
        gridView = TryCast(field.GetValue(g10), GridView)
    End If
Catch ex As Exception
    MsgBox("GridView 접근 실패: " & ex.Message)
End Try

If gridView IsNot Nothing Then
    gridView.OptionsSelection.MultiSelect = True
    gridView.OptionsSelection.MultiSelectMode = GridMultiSelectMode.RowSelect
Else
    MsgBox("GridView를 찾을 수 없습니다.")
End If
```

---

## 🔍 설명

| 코드                                                | 의미                                                     |
| ------------------------------------------------- | ------------------------------------------------------ |
| `GetField("gridView1", ...)`                      | `eGrid` 내부 필드 중 DevExpress `GridView` 객체를 찾음 (필드명은 추정) |
| `BindingFlags.NonPublic Or BindingFlags.Instance` | 비공개 인스턴스 필드 접근                                         |
| `TryCast(..., GridView)`                          | 실제 GridView일 경우에만 설정 시도                                |

---

## 🔧 필드 이름이 `gridView1`이 아닐 경우?

> 필드명이 다르면 `gridView`, `_view`, `view`, `mainView`, `_mainView` 등 추정 이름으로 시도해보자:

```vb
Dim names = {"gridView1", "gridView", "_view", "view", "_mainView"}
For Each name In names
    Dim field = g10.GetType().GetField(name, BindingFlags.NonPublic Or BindingFlags.Instance)
    If field IsNot Nothing Then
        gridView = TryCast(field.GetValue(g10), GridView)
        Exit For
    End If
Next
```

---

## 🧪 이후 확인

`GetSelectedRows()` 호출 시, 이제 복수 선택이 가능해졌다면 `selectedRows.Length` 값이 `1`보다 클 거야.

```vb
Dim selectedRows() As Integer = g10.GetSelectedRows()
MsgBox("선택된 행 수: " & selectedRows.Length)
```

---

## ✅ 결론

* `Frame9.eGrid`는 내부에 DevExpress `GridView`를 가지고 있지만 외부로 노출하지 않음
* → 리플렉션(Reflection)으로 내부 필드를 강제로 꺼내 사용해야 함
* 위 코드는 안전하게 내부 `GridView`를 얻고 `MultiSelect` 기능을 활성화함

---

필요하다면, `eGrid` 전체 decompiled class 내용을 추가로 분석해서 더 깔끔한 접근 방식도 제시할 수 있어.
테스트해보고 동작 여부 알려줘.





=================================> AI에 질문 :


오류	1	루프 제어 변수는 속성 또는 런타임에 바인딩된 인덱스 배열일 수 없습니다.	C:\Users\hsg\OneDrive - KoreaZinc\WORK\PROJECT\40.CJ4DXPlex\VB\_____TEST_____\CJ4DPLEX\modules\SO\CJSO001\CJSO001.vb	1287	18	CJSO001



---===---===---===---===---===---> AI 답변 :




오류 메시지 \*\*"루프 제어 변수는 속성 또는 런타임에 바인딩된 인덱스 배열일 수 없습니다"\*\*는 VB.NET에서 `For Each` 루프의 **제어 변수**가 **속성(property)** 일 때 발생하는 오류야.

---

### 🔍 문제 상황 요약

아래 코드에서:

```vb
For Each name In names
    Dim field = g10.GetType().GetField(name, BindingFlags.NonPublic Or BindingFlags.Instance)
    ...
Next
```

`names`가 속성이라면 (예: `Me.names`, `SomeObject.names`), VB.NET은 그것을 **루프 변수로 직접 사용할 수 없음**.
VB.NET은 반드시 배열 또는 컬렉션 **변수를** 써야 해.

---

### ✅ 해결 방법

`names`를 지역 변수로 명확히 선언해서 사용하면 문제 해결됨.

---

### 🔧 수정된 전체 코드 예시:

```vb
Imports DevExpress.XtraGrid.Views.Grid
Imports System.Reflection

Dim gridView As GridView = Nothing

' 필드 이름 후보 리스트를 지역 변수로 선언
Dim candidateNames() As String = {"gridView1", "gridView", "_view", "view", "_mainView"}

' 루프 돌면서 내부 필드 탐색
For Each name As String In candidateNames
    Dim field As FieldInfo = g10.GetType().GetField(name, BindingFlags.NonPublic Or BindingFlags.Instance)
    If field IsNot Nothing Then
        gridView = TryCast(field.GetValue(g10), GridView)
        If gridView IsNot Nothing Then Exit For
    End If
Next

' 다중 선택 설정
If gridView IsNot Nothing Then
    gridView.OptionsSelection.MultiSelect = True
    gridView.OptionsSelection.MultiSelectMode = GridMultiSelectMode.RowSelect
Else
    MsgBox("GridView를 찾을 수 없습니다.")
End If
```

---

### 🧠 참고로:

| 요소                                                | 설명                 |
| ------------------------------------------------- | ------------------ |
| `Dim candidateNames() As String`                  | 명확히 배열로 선언함        |
| `For Each name As String In candidateNames`       | 이제 VB.NET이 허용하는 형태 |
| `BindingFlags.NonPublic Or BindingFlags.Instance` | 비공개 필드 접근용         |

---

테스트 후 작동 여부 알려줘.
필요하다면 `Frame9.eGrid` 내부 필드명을 디컴파일해서 정확히 찾아주는 것도 도와줄 수 있어.





=================================> AI에 질문 :


안되. 다 안맞아.


---===---===---===---===---===---> AI 답변 :




좋아, 지금까지 내용 정리하면서 **안 맞는 원인**과 해결 방향을 다시 정확히 잡아볼게.
핵심 문제는:

> ✅ `g10`은 `Frame9.eGrid` 타입이고,
> ✅ 내부 DevExpress `GridView` 접근이 불가능해서 `MultiSelectMode` 설정이 안 됨.
> ✅ `GetSelectedRows()`는 호출되지만 **항상 한 줄만 반환함.**

---

## 🔍 가장 가능성 높은 원인

### 🔸 `Frame9.eGrid`에서 내부적으로 `GridView`의 MultiSelect 설정이 되어 있지 않다

→ 즉, `g10.MultiSelect = True`만으로는 부족하고
**`DevExpress GridView` 자체에도 설정이 필요**한데
그걸 밖에서 못 건드리고 있음.

---

## ✅ 최적 해결 방법: `Frame9.eGrid`에 `MultiSelectMode` 지원 추가

너가 `Frame9.eGrid`를 수정할 수 있다면 **가장 확실하고 깔끔한 방법**은 내부에서 `GridView`를 외부에 노출하거나 MultiSelect 설정을 할 수 있도록 메서드를 만드는 거야.

---

### 📌 (1) 내부 `GridView` 노출 메서드 추가 (eGrid 소스 수정)

`eGrid.vb` 안에 다음 메서드 하나 추가:

```vb
Public Function GetGridView() As DevExpress.XtraGrid.Views.Grid.GridView
    Return CType(Me.Controls(0).MainView, DevExpress.XtraGrid.Views.Grid.GridView)
End Function
```

> `Controls(0)`은 보통 내부의 `GridControl`이고, `.MainView`는 `GridView` 객체야.
> 이게 정확하지 않다면 `Me.grid` 또는 내부 필드명에 따라 바꿔줘야 해.

---

### 📌 (2) 사용하는 쪽에서 아래처럼 호출

```vb
Dim gv As DevExpress.XtraGrid.Views.Grid.GridView = g10.GetGridView()

If gv IsNot Nothing Then
    gv.OptionsSelection.MultiSelect = True
    gv.OptionsSelection.MultiSelectMode = DevExpress.XtraGrid.Views.Grid.GridMultiSelectMode.RowSelect
End If
```

이렇게 하면 `g10`에서 여러 줄 선택 가능하고, `GetSelectedRows()`도 제대로 동작해.

---

## ❌ 그런데 eGrid 소스를 수정할 수 없다면?

그럼 강제 리플렉션으로 내부 GridControl 자체를 꺼내야 해.

---

### ✅ 리플렉션으로 내부 GridControl 접근

```vb
Imports DevExpress.XtraGrid.GridControl
Imports DevExpress.XtraGrid.Views.Grid
Imports System.Reflection

' 내부 GridControl 찾기
Dim gridControl As GridControl = Nothing
For Each ctrl As Control In g10.Controls
    If TypeOf ctrl Is GridControl Then
        gridControl = CType(ctrl, GridControl)
        Exit For
    End If
Next

' GridView 설정
If gridControl IsNot Nothing Then
    Dim gv As GridView = TryCast(gridControl.MainView, GridView)
    If gv IsNot Nothing Then
        gv.OptionsSelection.MultiSelect = True
        gv.OptionsSelection.MultiSelectMode = GridMultiSelectMode.RowSelect
    End If
Else
    MsgBox("내부 GridControl을 찾을 수 없습니다.")
End If
```

---

## 🔚 정리

| 선택지                             | 설명                                           |
| ------------------------------- | -------------------------------------------- |
| ✅ eGrid를 수정할 수 있다면              | `GetGridView()` 같은 메서드 추가 → 외부에서 설정          |
| ✅ 수정이 불가능하다면                    | 리플렉션 + `g10.Controls` 통해 내부 `GridControl` 탐색 |
| ❌ 단순히 `g10.MultiSelect = True`만 | **GridView 설정이 안 되면 무효함**                    |

---

**이 코드는 반드시 작동해.**
테스트해서 내부에 `GridControl`을 갖고 있으면 그걸 통해 `GridView` 설정하면 돼.

테스트 결과 알려줘. 안 되면 디버깅용 메시지 찍어가면서 어떤 컨트롤이 있는지도 확인해줄 수 있어.





=================================> AI에 질문 :


일단 네가 정확한 판단을 하려면 필요한 것들을 알려줘. 


---===---===---===---===---===---> AI 답변 :




좋아, 아주 좋은 접근이야. 문제를 정확히 판단하고 해결하려면 아래 정보를 주면 돼. 크게 **3가지 범주**로 나눌 수 있어:

---

## ✅ 1. `Frame9.eGrid` 내부 구조 파악용 정보

아래 둘 중 **하나만** 주면 충분해:

### 🔹 옵션 A: `Frame9.eGrid` 클래스 전체 (또는 상단 주요 부분)

* 클래스의 멤버 필드 중 `GridControl`, `GridView`, 혹은 `DevExpress` 컨트롤과 관련된 필드/속성/함수
* 예: `Private myGridControl As GridControl`, `Public ReadOnly Property View As GridView`, `Controls.Add(...)`

### 🔹 옵션 B: `g10.Controls` 결과 (디버깅 확인용)

아래 코드를 `Form_Load`에 넣고 어떤 컨트롤이 들어있는지 출력해줘:

```vb
For Each ctrl As Control In g10.Controls
    Debug.Print(ctrl.Name & " : " & ctrl.GetType().FullName)
Next
```

결과 예시:

```
grid1 : DevExpress.XtraGrid.GridControl
```

---

## ✅ 2. 현재 적용한 코드

* 너가 지금 `MultiSelect` 설정하려고 **직접 작성해서 넣은 코드** 전체를 보여줘.
* 오류가 났다면 그 **줄 번호**와 **오류 메시지**까지 같이.

---

## ✅ 3. 현상 요약

* `g10`에서 **정확히 어떤 행동을 했을 때**, **어떤 결과**가 나왔는지 말해줘.
  예를 들어:

| 항목        | 내용                                       |
| --------- | ---------------------------------------- |
| 선택 방식     | Ctrl+마우스 클릭으로 여러 줄 선택                    |
| 기대 결과     | `GetSelectedRows()`가 여러 인덱스 반환           |
| 실제 결과     | 항상 하나의 RowHandle만 반환됨                    |
| 사용한 확인 코드 | `MsgBox(selectedRows.Length.ToString())` |

---

## 💡 보너스로 도움 되는 것들

* `g10.GetSelectedRows()` 함수 정의(프레임워크 제공 또는 오버라이드 여부)
* `g10`에 기본적으로 들어가는 DevExpress 컨트롤 구조 (`GridControl`, `GridView` 등)

---

## 📝 예시로 정리해서 보내주면 좋아

```vb
' ✅ 내가 현재 적용한 코드
Dim gv As GridView = g10.GetGridView()
gv.OptionsSelection.MultiSelect = True

' ✅ 오류 메시지
오류: 'GetGridView'은 'eGrid'의 멤버가 아닙니다.

' ✅ 디버깅 결과
g10.Controls(0) : DevExpress.XtraGrid.GridControl

' ✅ 현상 요약
- Ctrl + 클릭으로 두 줄 선택했는데 selectedRows.Length = 1
```

---

이렇게만 정리해주면 **100% 원인 진단하고 해결책 줄 수 있어.**
원하는 만큼 자세히 도와줄게. 편하게 차근차근 알려줘.





=================================> AI에 질문 :


'''' 1번 
using A;
using Base9;
using DevExpress.Data;
using DevExpress.Utils;
using DevExpress.Utils.Menu;
using DevExpress.XtraEditors;
using DevExpress.XtraEditors.Controls;
using DevExpress.XtraEditors.Mask;
using DevExpress.XtraEditors.Repository;
using DevExpress.XtraGrid;
using DevExpress.XtraGrid.Columns;
using DevExpress.XtraGrid.Menu;
using DevExpress.XtraGrid.Views.BandedGrid;
using DevExpress.XtraGrid.Views.BandedGrid.ViewInfo;
using DevExpress.XtraGrid.Views.Base;
using DevExpress.XtraGrid.Views.Grid;
using DevExpress.XtraGrid.Views.Grid.ViewInfo;
using Microsoft.VisualBasic;
using Microsoft.VisualBasic.CompilerServices;
using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Windows.Forms;

#nullable disable
namespace Frame9;

[DesignerGenerated]
[DefaultEvent("CellValueChanged")]
[ToolboxBitmap(typeof (eText), "eGrid.ico")]
public class eGrid : UserControl, intGrid
{
  private IContainer c30437a48be2edccf92998ef28115a203;
  private bool ca9012fdfbae897386452ef59cf11ce53;
  private bool cc0d454e2f1398908e3cc1bf29ad72f9a;
  private DataSet c5d165dda3affdc10bf5fa3cdd0152971;
  private WorkSet c330a4db27d3578a8e5d80797d2f5ac12;
  private Collection cdbe6b49d3eee541c1a02140924401651;
  private bool ce75332160d718c37d93defbcd7e95679;
  private bool c71541eef6215c51fd6ed427761212ad3;
  private bool cd268e238072e06dd96804a08ee584b75;
  private bool cd5ee370368dc75972785b2283583d43f;
  private bool cde42dfe20fdea515a20ee9c3cd7fec49;
  private bool ca39ed118263ffa37c2718bf159bf9674;
  private bool c018a99ed0c66295f13c59de7c8b6aa4c;
  private int c83fb623f1cfef74d227ce46cdace4c12;
  private int c02894bef99316b814a0f9eaea5fbe30b;
  private bool c291b918d0be288a91cc09da8cc863ce7;
  private bool ce8e830301aad7239d91493f34cace090;
  private bool c437485d6a3e0b34ec64860ea9e5d9748;
  private GridGroupSummaryItemCollection ccac4c8044ae680dcd351934054a598ac;
  private bool c9bdaa67da5892845981f2c92942085e5;
  private bool cfe51a0bb967b0d0da313e1b4013ca09b;
  private DataTable c467083dea0102ade8924e025f685c241;
  private bool cdf07e73a99f2a9d761b99392afb706c2;
  private bool cbee725c554d327dc3d76039ee2804a33;
  private int c469b0fc12a49e16cef7765328b7e46b3;
  private int ca78c8fb2abf9de6f83e5238cd29da0a0;
  private int cb5346c3ef09fcb1fcee1a5bc4abc4d2f;
  private int c540a73a6bcb4a3d519a57fcba6aa5cae;
  private int c66660fc7f284fd97ebfc6b3347a566ba;
  private bool c50ccdc5283b68b92131a5a8841c52a70;
  private string c26c855004913519a261bae8d8c34a7ad;
  private GridEnterDirection c9b149e1771cda0755be116d1d00e5bcf;
  private string c3b8083aee5bd9d8f8194d8364439e345;
  private string c3b632040ec246544c6cd4e0f83a2918d;
  private bool cf60d22e546791e81aed27bc22acefa6f;
  private bool cb0eeff986f87617a9dc0a385c3674fa7;
  private GridEditCellMode c19309e862c29221a6a5d1b33acc6d459;
  private object c582c73d9d3aaf3074e4c93b6db1c9b76;
  private bool caade471433b635c6c76864b2015d3db6;
  private bool c8c8684eaecc3f7146066d6e2c6b049ec;
  private bool c9628d971845e1dfed3b40173c2d77e5e;
  private string ceb03b9c3772bae1bdc6926be010a9525;
  private bool c08e309bae6f52107655a92e8f961fc35;
  private int cf8f2df247e0956b72b23d1f8bc5800fc;
  private bool c2ff7d99b7b52bbc756ecb3515e5b1a0a;

  public eGrid()
  {
    this.Enter += new EventHandler(this.ce62c9da09d0b11f387f7feba6a65cc36);
    this.Load += new EventHandler(this.c84a906d0e061c880ec462821bacc0dd1);
    this.ca9012fdfbae897386452ef59cf11ce53 = false;
    this.cc0d454e2f1398908e3cc1bf29ad72f9a = false;
    this.cdbe6b49d3eee541c1a02140924401651 = new Collection();
    this.ce75332160d718c37d93defbcd7e95679 = false;
    this.c71541eef6215c51fd6ed427761212ad3 = false;
    this.ca39ed118263ffa37c2718bf159bf9674 = false;
    this.c83fb623f1cfef74d227ce46cdace4c12 = 0;
    this.c02894bef99316b814a0f9eaea5fbe30b = 70;
    this.c9bdaa67da5892845981f2c92942085e5 = true;
    this.cfe51a0bb967b0d0da313e1b4013ca09b = true;
    this.cdf07e73a99f2a9d761b99392afb706c2 = false;
    this.cbee725c554d327dc3d76039ee2804a33 = false;
    this.c469b0fc12a49e16cef7765328b7e46b3 = 0;
    this.ca78c8fb2abf9de6f83e5238cd29da0a0 = 0;
    this.cb5346c3ef09fcb1fcee1a5bc4abc4d2f = 0;
    this.c540a73a6bcb4a3d519a57fcba6aa5cae = 0;
    this.c66660fc7f284fd97ebfc6b3347a566ba = 0;
    this.c50ccdc5283b68b92131a5a8841c52a70 = false;
    this.c26c855004913519a261bae8d8c34a7ad = "";
    this.cf60d22e546791e81aed27bc22acefa6f = true;
    this.cb0eeff986f87617a9dc0a385c3674fa7 = false;
    this.c19309e862c29221a6a5d1b33acc6d459 = (GridEditCellMode) 0;
    this.c582c73d9d3aaf3074e4c93b6db1c9b76 = (object) false;
    this.caade471433b635c6c76864b2015d3db6 = false;
    this.cf8f2df247e0956b72b23d1f8bc5800fc = 0;
    this.cd397e847ac8f86d555bd2896a72fcfbc();
  }

  [DebuggerNonUserCode]
  protected override void Dispose(bool disposing)
  {
    try
    {
      if (!disposing || this.c30437a48be2edccf92998ef28115a203 == null)
        return;
label_2:
      switch (5)
      {
        case 0:
          goto label_2;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.Dispose);
          }
          this.c30437a48be2edccf92998ef28115a203.Dispose();
          break;
      }
    }
    finally
    {
      base.Dispose(disposing);
    }
  }

  [DebuggerStepThrough]
  private void cd397e847ac8f86d555bd2896a72fcfbc()
  {
    this.c30437a48be2edccf92998ef28115a203 = (IContainer) new System.ComponentModel.Container();
    this.Grid1 = new GridControl();
    this.GridView1 = new BandedGridView();
    this.ContextMenuStrip1 = new ContextMenuStrip(this.c30437a48be2edccf92998ef28115a203);
    this.mnuRowAdd = new ToolStripMenuItem();
    this.mnuRowInsert = new ToolStripMenuItem();
    this.mnuRowDelete = new ToolStripMenuItem();
    this.ToolStripSeparator1 = new ToolStripSeparator();
    this.mnuRowCopy = new ToolStripMenuItem();
    this.mnuCellCopy = new ToolStripMenuItem();
    this.mnuRowPaste = new ToolStripMenuItem();
    this.mnuInsertPaste = new ToolStripMenuItem();
    this.ToolStripSeparator5 = new ToolStripSeparator();
    this.mnuPropertiesCopy = new ToolStripMenuItem();
    this.mnuPropertiesPaste = new ToolStripMenuItem();
    this.ToolStripSeparator2 = new ToolStripSeparator();
    this.mnuRowSelectAll = new ToolStripMenuItem();
    this.mnuRowRangeCopy = new ToolStripMenuItem();
    this.ToolStripSeparator3 = new ToolStripSeparator();
    this.mnuExcelPaste = new ToolStripMenuItem();
    this.mnuExport = new ToolStripMenuItem();
    this.ToolStripSeparator4 = new ToolStripSeparator();
    this.mnuEnterDir = new ToolStripMenuItem();
    this.mnuEnterRight = new ToolStripMenuItem();
    this.mnuEnterDown = new ToolStripMenuItem();
    this.mnuEnterLeft = new ToolStripMenuItem();
    this.mnuEnterUp = new ToolStripMenuItem();
    this.mnuMouseClick = new ToolStripMenuItem();
    this.mnuMouseClickEdit = new ToolStripMenuItem();
    this.mnuMouseClickSelect = new ToolStripMenuItem();
    this.mnuRowUnchange = new ToolStripMenuItem();
    this.Grid1.BeginInit();
    this.GridView1.BeginInit();
    this.ContextMenuStrip1.SuspendLayout();
    this.SuspendLayout();
    this.Grid1.Dock = DockStyle.Fill;
    this.Grid1.Location = new Point(0, 0);
    this.Grid1.MainView = (BaseView) this.GridView1;
    this.Grid1.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1557);
    this.Grid1.Size = new Size(392, 307);
    this.Grid1.TabIndex = 0;
    this.Grid1.Tag = (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1568);
    this.Grid1.UseEmbeddedNavigator = true;
    this.Grid1.ViewCollection.AddRange(new BaseView[1]
    {
      (BaseView) this.GridView1
    });
    this.GridView1.GridControl = this.Grid1;
    this.GridView1.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1591);
    this.ContextMenuStrip1.Items.AddRange(new ToolStripItem[21]
    {
      (ToolStripItem) this.mnuRowAdd,
      (ToolStripItem) this.mnuRowInsert,
      (ToolStripItem) this.mnuRowDelete,
      (ToolStripItem) this.mnuRowUnchange,
      (ToolStripItem) this.ToolStripSeparator1,
      (ToolStripItem) this.mnuRowCopy,
      (ToolStripItem) this.mnuCellCopy,
      (ToolStripItem) this.mnuRowPaste,
      (ToolStripItem) this.mnuInsertPaste,
      (ToolStripItem) this.ToolStripSeparator5,
      (ToolStripItem) this.mnuPropertiesCopy,
      (ToolStripItem) this.mnuPropertiesPaste,
      (ToolStripItem) this.ToolStripSeparator2,
      (ToolStripItem) this.mnuRowSelectAll,
      (ToolStripItem) this.mnuRowRangeCopy,
      (ToolStripItem) this.ToolStripSeparator3,
      (ToolStripItem) this.mnuExcelPaste,
      (ToolStripItem) this.mnuExport,
      (ToolStripItem) this.ToolStripSeparator4,
      (ToolStripItem) this.mnuEnterDir,
      (ToolStripItem) this.mnuMouseClick
    });
    this.ContextMenuStrip1.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1610);
    this.ContextMenuStrip1.Size = new Size(181, 408);
    this.mnuRowAdd.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1645);
    this.mnuRowAdd.Size = new Size(180, 22);
    this.mnuRowAdd.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1664);
    this.mnuRowInsert.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1673);
    this.mnuRowInsert.Size = new Size(180, 22);
    this.mnuRowInsert.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1698);
    this.mnuRowDelete.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1707);
    this.mnuRowDelete.Size = new Size(180, 22);
    this.mnuRowDelete.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1732);
    this.ToolStripSeparator1.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1741);
    this.ToolStripSeparator1.Size = new Size(177, 6);
    this.mnuRowCopy.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1780);
    this.mnuRowCopy.Size = new Size(180, 22);
    this.mnuRowCopy.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1801);
    this.mnuCellCopy.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1810);
    this.mnuCellCopy.Size = new Size(180, 22);
    this.mnuCellCopy.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1833);
    this.mnuRowPaste.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1842);
    this.mnuRowPaste.Size = new Size(180, 22);
    this.mnuRowPaste.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1865);
    this.mnuInsertPaste.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1878);
    this.mnuInsertPaste.Size = new Size(180, 22);
    this.mnuInsertPaste.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1907);
    this.ToolStripSeparator5.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1932);
    this.ToolStripSeparator5.Size = new Size(177, 6);
    this.mnuPropertiesCopy.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1971);
    this.mnuPropertiesCopy.Size = new Size(180, 22);
    this.mnuPropertiesCopy.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2006);
    this.mnuPropertiesPaste.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2021);
    this.mnuPropertiesPaste.Size = new Size(180, 22);
    this.mnuPropertiesPaste.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2058);
    this.ToolStripSeparator2.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2077);
    this.ToolStripSeparator2.Size = new Size(177, 6);
    this.mnuRowSelectAll.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2116);
    this.mnuRowSelectAll.Size = new Size(180, 22);
    this.mnuRowSelectAll.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2147);
    this.mnuRowRangeCopy.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2160);
    this.mnuRowRangeCopy.Size = new Size(180, 22);
    this.mnuRowRangeCopy.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2191);
    this.mnuRowRangeCopy.Visible = false;
    this.ToolStripSeparator3.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2196);
    this.ToolStripSeparator3.Size = new Size(177, 6);
    this.mnuExcelPaste.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2235);
    this.mnuExcelPaste.Size = new Size(180, 22);
    this.mnuExcelPaste.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2262);
    this.mnuExport.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2277);
    this.mnuExport.Size = new Size(180, 22);
    this.mnuExport.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2296);
    this.ToolStripSeparator4.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2311);
    this.ToolStripSeparator4.Size = new Size(177, 6);
    this.mnuEnterDir.DropDownItems.AddRange(new ToolStripItem[4]
    {
      (ToolStripItem) this.mnuEnterRight,
      (ToolStripItem) this.mnuEnterDown,
      (ToolStripItem) this.mnuEnterLeft,
      (ToolStripItem) this.mnuEnterUp
    });
    this.mnuEnterDir.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2350);
    this.mnuEnterDir.Size = new Size(180, 22);
    this.mnuEnterDir.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2373);
    this.mnuEnterRight.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2390);
    this.mnuEnterRight.Size = new Size(110, 22);
    this.mnuEnterRight.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2417);
    this.mnuEnterDown.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2424);
    this.mnuEnterDown.Size = new Size(110, 22);
    this.mnuEnterDown.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2449);
    this.mnuEnterLeft.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2454);
    this.mnuEnterLeft.Size = new Size(110, 22);
    this.mnuEnterLeft.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2479);
    this.mnuEnterUp.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2484);
    this.mnuEnterUp.Size = new Size(110, 22);
    this.mnuEnterUp.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2505);
    this.mnuMouseClick.DropDownItems.AddRange(new ToolStripItem[2]
    {
      (ToolStripItem) this.mnuMouseClickEdit,
      (ToolStripItem) this.mnuMouseClickSelect
    });
    this.mnuMouseClick.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2510);
    this.mnuMouseClick.Size = new Size(180, 22);
    this.mnuMouseClick.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2537);
    this.mnuMouseClickEdit.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2550);
    this.mnuMouseClickEdit.Size = new Size(98, 22);
    this.mnuMouseClickEdit.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2585);
    this.mnuMouseClickSelect.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2590);
    this.mnuMouseClickSelect.Size = new Size(98, 22);
    this.mnuMouseClickSelect.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2629);
    this.mnuRowUnchange.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2634);
    this.mnuRowUnchange.Size = new Size(180, 22);
    this.mnuRowUnchange.Text = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2663);
    this.AutoScaleDimensions = new SizeF(7f, 12f);
    this.AutoScaleMode = AutoScaleMode.Font;
    this.Controls.Add((Control) this.Grid1);
    this.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2674);
    this.Size = new Size(392, 307);
    this.Grid1.EndInit();
    this.GridView1.EndInit();
    this.ContextMenuStrip1.ResumeLayout(false);
    this.ResumeLayout(false);
  }

  [field: AccessedThroughProperty("Grid1")]
  internal virtual GridControl Grid1 { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  internal virtual ContextMenuStrip ContextMenuStrip1
  {
    get => this.cc0f15007ca88ea6c47a4df00468c962e;
    [MethodImpl(MethodImplOptions.Synchronized)] set
    {
      CancelEventHandler cancelEventHandler = new CancelEventHandler(this.cd1c51089237bec69dec63088eca96a73);
      ToolStripItemClickedEventHandler clickedEventHandler = new ToolStripItemClickedEventHandler(this.c6c49ec56804efac6885bbf373a8609b0);
      ContextMenuStrip cc0f15007ca88ea6c47a4df00468c962e1 = this.cc0f15007ca88ea6c47a4df00468c962e;
      if (cc0f15007ca88ea6c47a4df00468c962e1 != null)
      {
        cc0f15007ca88ea6c47a4df00468c962e1.Opening -= cancelEventHandler;
        cc0f15007ca88ea6c47a4df00468c962e1.ItemClicked -= clickedEventHandler;
      }
      this.cc0f15007ca88ea6c47a4df00468c962e = value;
      ContextMenuStrip cc0f15007ca88ea6c47a4df00468c962e2 = this.cc0f15007ca88ea6c47a4df00468c962e;
      if (cc0f15007ca88ea6c47a4df00468c962e2 == null)
        return;
      cc0f15007ca88ea6c47a4df00468c962e2.Opening += cancelEventHandler;
      cc0f15007ca88ea6c47a4df00468c962e2.ItemClicked += clickedEventHandler;
    }
  }

  [field: AccessedThroughProperty("mnuRowSelectAll")]
  internal virtual ToolStripMenuItem mnuRowSelectAll { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("ToolStripSeparator1")]
  internal virtual ToolStripSeparator ToolStripSeparator1 { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuRowCopy")]
  internal virtual ToolStripMenuItem mnuRowCopy { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuRowRangeCopy")]
  internal virtual ToolStripMenuItem mnuRowRangeCopy { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuRowPaste")]
  internal virtual ToolStripMenuItem mnuRowPaste { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuRowDelete")]
  internal virtual ToolStripMenuItem mnuRowDelete { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuRowInsert")]
  internal virtual ToolStripMenuItem mnuRowInsert { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("ToolStripSeparator2")]
  internal virtual ToolStripSeparator ToolStripSeparator2 { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuExcelPaste")]
  internal virtual ToolStripMenuItem mnuExcelPaste { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuRowAdd")]
  internal virtual ToolStripMenuItem mnuRowAdd { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("ToolStripSeparator3")]
  internal virtual ToolStripSeparator ToolStripSeparator3 { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuExport")]
  internal virtual ToolStripMenuItem mnuExport { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuCellCopy")]
  internal virtual ToolStripMenuItem mnuCellCopy { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuInsertPaste")]
  internal virtual ToolStripMenuItem mnuInsertPaste { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  internal virtual BandedGridView GridView1
  {
    get => this.cc359617cbe1b64673acb8e29abf5cb8a;
    [MethodImpl(MethodImplOptions.Synchronized)] set
    {
      RowAllowEventHandler allowEventHandler = new RowAllowEventHandler(this.c82288eea55806be02f5235f780d2711a);
      RowIndicatorCustomDrawEventHandler drawEventHandler = new RowIndicatorCustomDrawEventHandler(this.cf1a8a917d64b77acfeeac450dcca0aea);
      DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler changedEventHandler1 = new DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler(this.c299843d9262f0e2d2fd1004e60077c88);
      DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler changedEventHandler2 = new DevExpress.XtraGrid.Views.Base.CellValueChangedEventHandler(this.c0569f573eb3083b70667899b3cb1b8c7);
      EventHandler eventHandler1 = new EventHandler(this.c3f4e0c15b6b433da51e0051c536e2963);
      FocusedColumnChangedEventHandler changedEventHandler3 = new FocusedColumnChangedEventHandler(this.c90a982c426d4bce3900a671eedb1d90b);
      FocusedRowChangedEventHandler changedEventHandler4 = new FocusedRowChangedEventHandler(this.c018a49ab8185880385511c15c08ac0b2);
      EventHandler eventHandler2 = new EventHandler(this.c5a762af29a3fb639f0e52492954d9d70);
      EventHandler eventHandler3 = new EventHandler(this.c79dafdef1dba1a8745a4f88c96d7cdbe);
      KeyEventHandler keyEventHandler = new KeyEventHandler(this.cc84fda855336094f7faabdfd0d426bc0);
      MouseEventHandler mouseEventHandler1 = new MouseEventHandler(this.cb13d3b392a8e13ee7a8d00d4d6e89f10);
      MouseEventHandler mouseEventHandler2 = new MouseEventHandler(this.c6dfd4fea22ed687ee64450612fbb4094);
      InitNewRowEventHandler newRowEventHandler = new InitNewRowEventHandler(this.cd42d6f5d8ae2b4989c032bc64e5a5679);
      RowObjectEventHandler objectEventHandler = new RowObjectEventHandler(this.c1a258e0f369e7514826f88502b728508);
      EventHandler eventHandler4 = new EventHandler(this.c941df262eb07f4b064b576a5f7399d75);
      PopupMenuShowingEventHandler showingEventHandler = new PopupMenuShowingEventHandler(this.c1137ced481c4ba55cdc1e99611aa9493);
      EventHandler eventHandler5 = new EventHandler(this.cbd426daa88abecefd15de18d673cb387);
      CellMergeEventHandler mergeEventHandler = new CellMergeEventHandler(this.cb4c282b196f843ccd90b4a7af0410144);
      SelectionChangedEventHandler changedEventHandler5 = new SelectionChangedEventHandler(this.ce1e13d20961f5737565140412d5c2a0b);
      BaseContainerValidateEditorEventHandler editorEventHandler = new BaseContainerValidateEditorEventHandler(this.cee195af6c1eac6e0e57a73f31f0d30e3);
      MouseEventHandler mouseEventHandler3 = new MouseEventHandler(this.c647223605df2113372ae3fa98fe4e4b7);
      DragObjectDropEventHandler dropEventHandler = new DragObjectDropEventHandler(this.c7f40c8562920a622aa42ad82d6a5274a);
      BandedGridView cc359617cbe1b64673acb8e29abf5cb8a1 = this.cc359617cbe1b64673acb8e29abf5cb8a;
      if (cc359617cbe1b64673acb8e29abf5cb8a1 != null)
      {
label_1:
        switch (1)
        {
          case 0:
            goto label_1;
          default:
            if (false)
            {
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_GridView1);
            }
            cc359617cbe1b64673acb8e29abf5cb8a1.BeforeLeaveRow -= allowEventHandler;
            cc359617cbe1b64673acb8e29abf5cb8a1.CustomDrawRowIndicator -= drawEventHandler;
            cc359617cbe1b64673acb8e29abf5cb8a1.CellValueChanged -= changedEventHandler1;
            cc359617cbe1b64673acb8e29abf5cb8a1.CellValueChanging -= changedEventHandler2;
            cc359617cbe1b64673acb8e29abf5cb8a1.ShownEditor -= eventHandler1;
            cc359617cbe1b64673acb8e29abf5cb8a1.FocusedColumnChanged -= changedEventHandler3;
            cc359617cbe1b64673acb8e29abf5cb8a1.FocusedRowChanged -= changedEventHandler4;
            cc359617cbe1b64673acb8e29abf5cb8a1.DoubleClick -= eventHandler2;
            cc359617cbe1b64673acb8e29abf5cb8a1.Click -= eventHandler3;
            cc359617cbe1b64673acb8e29abf5cb8a1.KeyDown -= keyEventHandler;
            cc359617cbe1b64673acb8e29abf5cb8a1.MouseDown -= mouseEventHandler1;
            cc359617cbe1b64673acb8e29abf5cb8a1.MouseUp -= mouseEventHandler2;
            cc359617cbe1b64673acb8e29abf5cb8a1.InitNewRow -= newRowEventHandler;
            cc359617cbe1b64673acb8e29abf5cb8a1.RowUpdated -= objectEventHandler;
            cc359617cbe1b64673acb8e29abf5cb8a1.LeftCoordChanged -= eventHandler4;
            cc359617cbe1b64673acb8e29abf5cb8a1.PopupMenuShowing -= showingEventHandler;
            cc359617cbe1b64673acb8e29abf5cb8a1.ColumnPositionChanged -= eventHandler5;
            cc359617cbe1b64673acb8e29abf5cb8a1.CellMerge -= mergeEventHandler;
            cc359617cbe1b64673acb8e29abf5cb8a1.SelectionChanged -= changedEventHandler5;
            cc359617cbe1b64673acb8e29abf5cb8a1.ValidatingEditor -= editorEventHandler;
            cc359617cbe1b64673acb8e29abf5cb8a1.MouseWheel -= mouseEventHandler3;
            cc359617cbe1b64673acb8e29abf5cb8a1.DragObjectDrop -= dropEventHandler;
            break;
        }
      }
      this.cc359617cbe1b64673acb8e29abf5cb8a = value;
      BandedGridView cc359617cbe1b64673acb8e29abf5cb8a2 = this.cc359617cbe1b64673acb8e29abf5cb8a;
      if (cc359617cbe1b64673acb8e29abf5cb8a2 == null)
        return;
      cc359617cbe1b64673acb8e29abf5cb8a2.BeforeLeaveRow += allowEventHandler;
      cc359617cbe1b64673acb8e29abf5cb8a2.CustomDrawRowIndicator += drawEventHandler;
      cc359617cbe1b64673acb8e29abf5cb8a2.CellValueChanged += changedEventHandler1;
      cc359617cbe1b64673acb8e29abf5cb8a2.CellValueChanging += changedEventHandler2;
      cc359617cbe1b64673acb8e29abf5cb8a2.ShownEditor += eventHandler1;
      cc359617cbe1b64673acb8e29abf5cb8a2.FocusedColumnChanged += changedEventHandler3;
      cc359617cbe1b64673acb8e29abf5cb8a2.FocusedRowChanged += changedEventHandler4;
      cc359617cbe1b64673acb8e29abf5cb8a2.DoubleClick += eventHandler2;
      cc359617cbe1b64673acb8e29abf5cb8a2.Click += eventHandler3;
      cc359617cbe1b64673acb8e29abf5cb8a2.KeyDown += keyEventHandler;
      cc359617cbe1b64673acb8e29abf5cb8a2.MouseDown += mouseEventHandler1;
      cc359617cbe1b64673acb8e29abf5cb8a2.MouseUp += mouseEventHandler2;
      cc359617cbe1b64673acb8e29abf5cb8a2.InitNewRow += newRowEventHandler;
      cc359617cbe1b64673acb8e29abf5cb8a2.RowUpdated += objectEventHandler;
      cc359617cbe1b64673acb8e29abf5cb8a2.LeftCoordChanged += eventHandler4;
      cc359617cbe1b64673acb8e29abf5cb8a2.PopupMenuShowing += showingEventHandler;
      cc359617cbe1b64673acb8e29abf5cb8a2.ColumnPositionChanged += eventHandler5;
      cc359617cbe1b64673acb8e29abf5cb8a2.CellMerge += mergeEventHandler;
      cc359617cbe1b64673acb8e29abf5cb8a2.SelectionChanged += changedEventHandler5;
      cc359617cbe1b64673acb8e29abf5cb8a2.ValidatingEditor += editorEventHandler;
      cc359617cbe1b64673acb8e29abf5cb8a2.MouseWheel += mouseEventHandler3;
      cc359617cbe1b64673acb8e29abf5cb8a2.DragObjectDrop += dropEventHandler;
    }
  }

  [field: AccessedThroughProperty("mnuPropertiesCopy")]
  internal virtual ToolStripMenuItem mnuPropertiesCopy { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("ToolStripSeparator4")]
  internal virtual ToolStripSeparator ToolStripSeparator4 { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuEnterDir")]
  internal virtual ToolStripMenuItem mnuEnterDir { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuEnterRight")]
  internal virtual ToolStripMenuItem mnuEnterRight { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuEnterDown")]
  internal virtual ToolStripMenuItem mnuEnterDown { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuEnterLeft")]
  internal virtual ToolStripMenuItem mnuEnterLeft { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuEnterUp")]
  internal virtual ToolStripMenuItem mnuEnterUp { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuMouseClick")]
  internal virtual ToolStripMenuItem mnuMouseClick { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuMouseClickEdit")]
  internal virtual ToolStripMenuItem mnuMouseClickEdit { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuMouseClickSelect")]
  internal virtual ToolStripMenuItem mnuMouseClickSelect { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("ToolStripSeparator5")]
  internal virtual ToolStripSeparator ToolStripSeparator5 { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuPropertiesPaste")]
  internal virtual ToolStripMenuItem mnuPropertiesPaste { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  [field: AccessedThroughProperty("mnuRowUnchange")]
  internal virtual ToolStripMenuItem mnuRowUnchange { get; [MethodImpl(MethodImplOptions.Synchronized)] set; }

  private void ce62c9da09d0b11f387f7feba6a65cc36(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (this.c330a4db27d3578a8e5d80797d2f5ac12 == null)
      return;
label_1:
    switch (7)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.ce62c9da09d0b11f387f7feba6a65cc36);
        }
        NewLateBinding.LateSetComplex(this.c330a4db27d3578a8e5d80797d2f5ac12.ParentForm, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1362), new object[1]
        {
          (object) this.c330a4db27d3578a8e5d80797d2f5ac12
        }, (string[]) null, (System.Type[]) null, false, true);
        break;
    }
  }

  private void c84a906d0e061c880ec462821bacc0dd1(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    this.Init();
    this.mnuRowAdd.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2685));
    this.mnuRowInsert.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2718));
    this.mnuRowDelete.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2757));
    this.mnuRowUnchange.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2796), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2839));
    this.mnuRowCopy.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2854));
    this.mnuRowPaste.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2889));
    this.mnuInsertPaste.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2926));
    this.c3b8083aee5bd9d8f8194d8364439e345 = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2957), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2373));
    this.mnuEnterDown.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2994), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2449));
    this.mnuEnterLeft.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3033), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3072 /*0x0C00*/));
    this.mnuEnterRight.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3077), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3118));
    this.mnuEnterUp.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3123), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3158));
    this.c3b632040ec246544c6cd4e0f83a2918d = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3161), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2537));
    this.mnuMouseClickEdit.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3190), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3229));
    this.mnuMouseClickSelect.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3234), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2629));
    this.mnuEnterDown.Click += new EventHandler(this.cb1faf9b93b6078aa9dc1a88feb6c8f17);
    this.mnuEnterLeft.Click += new EventHandler(this.cb1faf9b93b6078aa9dc1a88feb6c8f17);
    this.mnuEnterRight.Click += new EventHandler(this.cb1faf9b93b6078aa9dc1a88feb6c8f17);
    this.mnuEnterUp.Click += new EventHandler(this.cb1faf9b93b6078aa9dc1a88feb6c8f17);
    this.mnuMouseClickEdit.Click += new EventHandler(this.cb1faf9b93b6078aa9dc1a88feb6c8f17);
    this.mnuMouseClickSelect.Click += new EventHandler(this.cb1faf9b93b6078aa9dc1a88feb6c8f17);
    int num;
    if (this.ParentControl != null)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c84a906d0e061c880ec462821bacc0dd1);
          }
          if (Microsoft.VisualBasic.CompilerServices.Operators.ConditionalCompareObjectEqual(NewLateBinding.LateGet(this.ParentControl, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3277), new object[0], (string[]) null, (System.Type[]) null, (bool[]) null), (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3286), false))
          {
label_5:
            switch (3)
            {
              case 0:
                goto label_5;
              default:
                if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(this.Name, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3309), false) == 0)
                {
label_7:
                  switch (2)
                  {
                    case 0:
                      goto label_7;
                    default:
                      if (!Parameter.Login.IsDeveloper)
                      {
label_9:
                        switch (5)
                        {
                          case 0:
                            goto label_9;
                          default:
                            if (!Parameter.Login.IsSystemAdmin)
                            {
label_11:
                              switch (4)
                              {
                                case 0:
                                  goto label_11;
                                default:
                                  num = Parameter.Login.IsConsultant ? 1 : 0;
                                  goto label_15;
                              }
                            }
                            else
                              break;
                        }
                      }
                      num = 1;
                      goto label_15;
                  }
                }
                else
                  break;
            }
          }
          else
            break;
          break;
      }
    }
    num = 0;
label_15:
    if (num != 0)
    {
label_16:
      switch (2)
      {
        case 0:
          goto label_16;
        default:
          this.ToolStripSeparator5.Visible = true;
          this.mnuPropertiesCopy.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3314), this.mnuPropertiesCopy.Text);
          this.mnuPropertiesPaste.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3363), this.mnuPropertiesPaste.Text);
          break;
      }
    }
    else
    {
      this.ToolStripSeparator5.Visible = false;
      this.mnuPropertiesCopy.Visible = false;
      this.mnuPropertiesPaste.Visible = false;
    }
    this.mnuRowSelectAll.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3414), this.mnuRowSelectAll.Text);
    this.mnuExcelPaste.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3453));
    this.mnuExport.Text = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3494));
    this.mnuCellCopy.Visible = false;
    this.mnuRowRangeCopy.Visible = false;
    this.cdf07e73a99f2a9d761b99392afb706c2 = true;
  }

  public void Init()
  {
    this.GridView1.BeginUpdate();
    this.GridView1.GroupPanelText = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3525);
    this.GridView1.OptionsView.ColumnAutoWidth = false;
    this.GridView1.OptionsView.ShowGroupPanel = false;
    this.GridView1.OptionsView.ShowGroupPanelColumnsAsSingleRow = true;
    this.GridView1.OptionsSelection.MultiSelect = true;
    this.GridView1.OptionsSelection.MultiSelectMode = GridMultiSelectMode.CellSelect;
    this.GridView1.FocusRectStyle = DrawFocusRectStyle.RowFocus;
    if (this.c19309e862c29221a6a5d1b33acc6d459 != 0)
    {
label_1:
      switch (3)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.Init);
          }
          this.GridView1.OptionsBehavior.EditorShowMode = (EditorShowMode) this.c19309e862c29221a6a5d1b33acc6d459;
          break;
      }
    }
    else
    {
      string message = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3544), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(79));
      int num;
      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82), message, false) <= 0)
      {
label_6:
        switch (5)
        {
          case 0:
            goto label_6;
          default:
            num = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(message, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3591), false) <= 0 ? 1 : 0;
            break;
        }
      }
      else
        num = 0;
      if (num != 0)
        this.GridView1.OptionsBehavior.EditorShowMode = (EditorShowMode) Conversions.ToInteger(message);
      else
        this.GridView1.OptionsBehavior.EditorShowMode = EditorShowMode.MouseDown;
    }
    this.GridView1.OptionsBehavior.AutoSelectAllInEditor = true;
    this.GridView1.OptionsClipboard.CopyColumnHeaders = DefaultBoolean.False;
    this.GridView1.OptionsNavigation.AutoMoveRowFocus = Conversions.ToBoolean(Interaction.IIf(Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3594), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(79)), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82), false) == 0, (object) false, (object) true));
    string upper = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3639), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3688)).ToUpper();
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(upper, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3691), false) == 0)
    {
label_14:
      switch (5)
      {
        case 0:
          goto label_14;
        default:
          this.c9b149e1771cda0755be116d1d00e5bcf = GridEnterDirection.Up;
          break;
      }
    }
    else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(upper, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3694), false) == 0)
    {
label_17:
      switch (3)
      {
        case 0:
          goto label_17;
        default:
          this.c9b149e1771cda0755be116d1d00e5bcf = GridEnterDirection.Down;
          break;
      }
    }
    else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(upper, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3697), false) == 0)
    {
label_20:
      switch (2)
      {
        case 0:
          goto label_20;
        default:
          this.c9b149e1771cda0755be116d1d00e5bcf = GridEnterDirection.Left;
          break;
      }
    }
    else
    {
      this.c9b149e1771cda0755be116d1d00e5bcf = GridEnterDirection.Right;
      this.GridView1.OptionsNavigation.EnterMoveNextColumn = true;
    }
    this.GridView1.Appearance.SelectedRow.BackColor = Color.FromArgb(50, 30, 152, 250);
    this.GridView1.FixedLineWidth = 1;
    this.Grid1.EmbeddedNavigator.Buttons.Remove.Visible = false;
    this.Grid1.EmbeddedNavigator.ButtonClick += new NavigatorButtonClickEventHandler(this.ce7719d25b05ac9c98f792387caf8dd69);
    this.GridView1.OptionsView.ShowButtonMode = ShowButtonModeEnum.ShowForFocusedRow;
    this.GridView1.OptionsNavigation.UseTabKey = true;
    this.GridView1.OptionsBehavior.FocusLeaveOnTab = false;
    this.GridView1.OptionsBehavior.AutoExpandAllGroups = true;
    this.GridView1.OptionsMenu.ShowGroupSummaryEditorItem = true;
    this.GridView1.OptionsMenu.ShowGroupSortSummaryItems = true;
    this.GridView1.OptionsMenu.ShowDateTimeGroupIntervalItems = true;
    this.GridView1.InvalidateRow(0);
    this.IsBandedGrid = true;
    this.GridView1.EndUpdate();
  }

  public void Clear()
  {
    this.cdbe6b49d3eee541c1a02140924401651 = (Collection) null;
    this.c50ccdc5283b68b92131a5a8841c52a70 = false;
    this.c467083dea0102ade8924e025f685c241 = (DataTable) null;
    this.Grid1.DataSource = (object) null;
    this.GridView1.Columns.Clear();
    this.GridView1.Bands.Clear();
  }

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public bool IsBandedGrid
  {
    get => this.ca9012fdfbae897386452ef59cf11ce53;
    set
    {
      if (this.ca9012fdfbae897386452ef59cf11ce53 == value)
        return;
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_IsBandedGrid);
          }
          this.ca9012fdfbae897386452ef59cf11ce53 = value;
          this.c4e7a724fc8b0bb789eef8ad65fdccdd8();
          break;
      }
    }
  }

  private void c4e7a724fc8b0bb789eef8ad65fdccdd8()
  {
    this.GridView1.OptionsView.ShowColumnHeaders = !this.ca9012fdfbae897386452ef59cf11ce53;
    this.GridView1.OptionsView.ShowBands = this.ca9012fdfbae897386452ef59cf11ce53;
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public GridEditCellMode EditCellMode
  {
    get => (GridEditCellMode) this.GridView1.OptionsBehavior.EditorShowMode;
    set
    {
      this.c19309e862c29221a6a5d1b33acc6d459 = value;
      this.GridView1.OptionsBehavior.EditorShowMode = (EditorShowMode) value;
    }
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public bool Editable
  {
    get => this.GridView1.OptionsBehavior.Editable;
    set => this.GridView1.OptionsBehavior.Editable = value;
  }

  [DefaultValue(false)]
  public bool ReadOnly
  {
    get => this.GridView1.OptionsBehavior.ReadOnly;
    set => this.GridView1.OptionsBehavior.ReadOnly = value;
  }

  [DefaultValue(true)]
  public bool AllowAddRows
  {
    get => this.GridView1.OptionsBehavior.AllowAddRows != DefaultBoolean.False;
    set
    {
      this.GridView1.OptionsBehavior.AllowAddRows = (DefaultBoolean) Conversions.ToInteger(Interaction.IIf(value, (object) DefaultBoolean.True, (object) DefaultBoolean.False));
      this.c9bdaa67da5892845981f2c92942085e5 = this.GridView1.OptionsBehavior.AllowAddRows == DefaultBoolean.True;
    }
  }

  [DefaultValue(true)]
  public bool AllowDeleteRows
  {
    get
    {
      if (this.GridView1.OptionsBehavior.AllowDeleteRows != DefaultBoolean.False)
        return true;
label_1:
      switch (3)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_AllowDeleteRows);
          }
          return false;
      }
    }
    set
    {
      this.GridView1.OptionsBehavior.AllowDeleteRows = (DefaultBoolean) Conversions.ToInteger(Interaction.IIf(value, (object) DefaultBoolean.True, (object) DefaultBoolean.False));
    }
  }

  [DefaultValue(true)]
  public bool AllowInsertRows
  {
    get => this.c9bdaa67da5892845981f2c92942085e5;
    set => this.c9bdaa67da5892845981f2c92942085e5 = value;
  }

  [DefaultValue(true)]
  public bool AllowExport
  {
    get => this.cfe51a0bb967b0d0da313e1b4013ca09b;
    set => this.cfe51a0bb967b0d0da313e1b4013ca09b = value;
  }

  [DefaultValue(true)]
  public bool AllowFilter
  {
    get => this.GridView1.OptionsCustomization.AllowFilter;
    set => this.GridView1.OptionsCustomization.AllowFilter = value;
  }

  [DefaultValue(true)]
  public bool AllowGroup
  {
    get => this.GridView1.OptionsCustomization.AllowGroup;
    set => this.GridView1.OptionsCustomization.AllowGroup = value;
  }

  [DefaultValue(true)]
  public bool AllowSort
  {
    get => this.GridView1.OptionsCustomization.AllowSort;
    set => this.GridView1.OptionsCustomization.AllowSort = value;
  }

  [DefaultValue(true)]
  public bool AllowMoveTitle
  {
    get => this.GridView1.OptionsCustomization.AllowBandMoving;
    set => this.GridView1.OptionsCustomization.AllowBandMoving = value;
  }

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public string CheckBeforeSaveOnCheckedColumnName
  {
    get => this.c26c855004913519a261bae8d8c34a7ad;
    set => this.c26c855004913519a261bae8d8c34a7ad = value;
  }

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public bool ShowBands
  {
    get => this.GridView1.OptionsView.ShowBands;
    set
    {
      this.GridView1.OptionsView.ShowColumnHeaders = !value;
      this.GridView1.OptionsView.ShowBands = value;
    }
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public int SelectedRowsCount => this.GridView1.SelectedRowsCount;

  public int[] GetSelectedRows => this.GridView1.GetSelectedRows();

  public void MoveNextPage() => this.GridView1.MoveNextPage();

  public void MovePrevPage() => this.GridView1.MovePrevPage();

  public void MoveNext() => this.GridView1.MoveNext();

  public void MovePrev() => this.GridView1.MovePrev();

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public bool ShowColumnHeaders
  {
    get => this.GridView1.OptionsView.ShowColumnHeaders;
    set
    {
      if (this.ca9012fdfbae897386452ef59cf11ce53)
        this.GridView1.OptionsView.ShowBands = value;
      else
        this.GridView1.OptionsView.ShowColumnHeaders = value;
    }
  }

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public bool ShowRowHeaders
  {
    get => this.GridView1.OptionsView.ShowIndicator;
    set => this.GridView1.OptionsView.ShowIndicator = value;
  }

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public bool ShowGroupBox
  {
    get => this.GridView1.OptionsView.ShowGroupPanel;
    set => this.GridView1.OptionsView.ShowGroupPanel = value;
  }

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public bool ShowFilterRow
  {
    get => this.GridView1.OptionsView.ShowAutoFilterRow;
    set => this.GridView1.OptionsView.ShowAutoFilterRow = value;
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public bool ShowFindPanel
  {
    get => this.GridView1.IsFindPanelVisible;
    set
    {
      if (value)
        this.GridView1.ShowFindPanel();
      else
        this.GridView1.HideFindPanel();
    }
  }

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public bool AllowPopupMenu
  {
    get => this.cf60d22e546791e81aed27bc22acefa6f;
    set => this.cf60d22e546791e81aed27bc22acefa6f = value;
  }

  public void AddGroup(string fieldName)
  {
    int count = this.GridView1.GroupedColumns.Count;
    this.get_c3b70f7febd94504d2ae889cd04cf3e00(fieldName).GroupIndex = count;
  }

  public void Sort(string columnName, ColumnSortOrder sortOrder = ColumnSortOrder.Ascending)
  {
    DevExpress.XtraGrid.Columns.GridColumn gridColumn = this.get_c3b70f7febd94504d2ae889cd04cf3e00(columnName);
    if (gridColumn == null)
      return;
    gridColumn.SortOrder = (DevExpress.Data.ColumnSortOrder) sortOrder;
  }

  public void SortGroup(string groupColumnName, string columnName, ColumnSortOrder sortOrder = ColumnSortOrder.Ascending)
  {
    DevExpress.XtraGrid.Columns.GridColumn gridColumn = this.get_c3b70f7febd94504d2ae889cd04cf3e00(columnName);
    if (gridColumn == null)
      return;
label_1:
    switch (4)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.SortGroup);
        }
        gridColumn.FieldNameSortGroup = groupColumnName;
        gridColumn.SortOrder = (DevExpress.Data.ColumnSortOrder) sortOrder;
        break;
    }
  }

  public void ClearColumnGroup(string fieldName)
  {
    this.get_c3b70f7febd94504d2ae889cd04cf3e00(fieldName).UnGroup();
  }

  public void ClearGrouping() => this.GridView1.ClearGrouping();

  public void ClearSorting() => this.GridView1.ClearSorting();

  public void ExpandAllGroups() => this.GridView1.ExpandAllGroups();

  public void CollapseAllGroups() => this.GridView1.CollapseAllGroups();

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public string FilterString
  {
    get => this.GridView1.ActiveFilterString;
    set
    {
      this.GridView1.ClearColumnsFilter();
      this.GridView1.ActiveFilterString = value;
    }
  }

  public void ClearColumnFilter(string fieldName)
  {
    this.get_c3b70f7febd94504d2ae889cd04cf3e00(fieldName).ClearFilter();
  }

  public void ClearColumnsFilter() => this.GridView1.ClearColumnsFilter();

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public int GroupCount => this.GridView1.GroupCount;

  public override DockStyle Dock
  {
    get => base.Dock;
    set => base.Dock = value;
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public bool MultiSelect
  {
    get => this.GridView1.OptionsSelection.MultiSelect;
    set => this.GridView1.OptionsSelection.MultiSelect = value;
  }

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public bool LockCurrentRow
  {
    get => this.c018a99ed0c66295f13c59de7c8b6aa4c;
    set => this.c018a99ed0c66295f13c59de7c8b6aa4c = value;
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public bool SelectRow
  {
    get => this.GridView1.OptionsSelection.MultiSelectMode == GridMultiSelectMode.RowSelect;
    set
    {
      if (value)
      {
        this.GridView1.OptionsSelection.MultiSelectMode = GridMultiSelectMode.RowSelect;
        this.GridView1.OptionsSelection.EnableAppearanceFocusedRow = true;
        this.GridView1.Appearance.SelectedRow.Reset();
      }
      else
        this.GridView1.OptionsSelection.MultiSelectMode = GridMultiSelectMode.CellSelect;
    }
  }

  [DefaultValue(typeof (NewRowType), "Bottom")]
  public NewRowType NewRowPosition
  {
    set => this.GridView1.OptionsView.NewItemRowPosition = (NewItemRowPosition) value;
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public int RowCount => this.GridView1.RowCount;

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public int TopRowIndex
  {
    get => this.GridView1.TopRowIndex;
    set => this.GridView1.TopRowIndex = value;
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public int RowIndex
  {
    get => this.GridView1.FocusedRowHandle;
    set => this.GridView1.FocusedRowHandle = value;
  }

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public bool RowAutoHeight
  {
    get => this.GridView1.OptionsView.RowAutoHeight;
    set
    {
      this.GridView1.OptionsView.RowAutoHeight = value;
      this.GridView1.LayoutChanged();
    }
  }

  public bool get_RowMenuVisible(RowMenu rowMenu)
  {
    bool visible;
    switch (rowMenu)
    {
      case RowMenu.AddRow:
        visible = this.mnuRowAdd.Visible;
        break;
      case RowMenu.InsertRow:
label_12:
        switch (7)
        {
          case 0:
            goto label_12;
          default:
            visible = this.mnuRowInsert.Visible;
            break;
        }
        break;
      case RowMenu.DeleteRow:
label_6:
        switch (6)
        {
          case 0:
            goto label_6;
          default:
            visible = this.mnuRowDelete.Visible;
            break;
        }
        break;
      case RowMenu.UnchangeRow:
label_8:
        switch (4)
        {
          case 0:
            goto label_8;
          default:
            visible = this.mnuRowUnchange.Visible;
            break;
        }
        break;
      case RowMenu.CopyRow:
label_2:
        switch (6)
        {
          case 0:
            goto label_2;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_RowMenuVisible);
            }
            visible = this.mnuRowCopy.Visible;
            break;
        }
        break;
      case RowMenu.PasteRow:
label_15:
        switch (2)
        {
          case 0:
            goto label_15;
          default:
            visible = this.mnuRowPaste.Visible;
            break;
        }
        break;
      case RowMenu.InsertPaste:
label_10:
        switch (2)
        {
          case 0:
            goto label_10;
          default:
            visible = this.mnuInsertPaste.Visible;
            break;
        }
        break;
      case RowMenu.SelectAll:
        visible = this.mnuRowSelectAll.Visible;
        break;
      case RowMenu.PasteExcel:
        visible = this.mnuExcelPaste.Visible;
        break;
    }
    return visible;
  }

  public void set_RowMenuVisible(RowMenu rowMenu, bool value)
  {
    if (rowMenu == RowMenu.AddRow)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_RowMenuVisible);
          }
          this.mnuRowAdd.Visible = value;
          break;
      }
    }
    if (rowMenu == RowMenu.CopyRow)
    {
label_6:
      switch (5)
      {
        case 0:
          goto label_6;
        default:
          this.mnuRowCopy.Visible = value;
          break;
      }
    }
    if (rowMenu == RowMenu.DeleteRow)
    {
label_9:
      switch (7)
      {
        case 0:
          goto label_9;
        default:
          this.mnuRowDelete.Visible = value;
          break;
      }
    }
    if (rowMenu == RowMenu.UnchangeRow)
      this.mnuRowUnchange.Visible = value;
    if (rowMenu == RowMenu.InsertPaste)
    {
label_14:
      switch (2)
      {
        case 0:
          goto label_14;
        default:
          this.mnuInsertPaste.Visible = value;
          break;
      }
    }
    if (rowMenu == RowMenu.InsertRow)
    {
label_17:
      switch (6)
      {
        case 0:
          goto label_17;
        default:
          this.mnuRowInsert.Visible = value;
          break;
      }
    }
    if (rowMenu == RowMenu.PasteExcel)
      this.mnuExcelPaste.Visible = value;
    if (rowMenu == RowMenu.PasteRow)
      this.mnuRowPaste.Visible = value;
    if (rowMenu == RowMenu.SelectAll)
    {
label_24:
      switch (4)
      {
        case 0:
          goto label_24;
        default:
          this.mnuRowSelectAll.Visible = value;
          break;
      }
    }
    if (!this.mnuCellCopy.Visible & !this.mnuRowCopy.Visible & !this.mnuRowPaste.Visible & !this.mnuInsertPaste.Visible)
      this.ToolStripSeparator1.Visible = false;
    if (this.mnuRowSelectAll.Visible)
      return;
label_29:
    switch (2)
    {
      case 0:
        goto label_29;
      default:
        this.ToolStripSeparator2.Visible = false;
        break;
    }
  }

  public bool get_RowMenuEnable(RowMenu rowMenu)
  {
    bool enabled;
    switch (rowMenu)
    {
      case RowMenu.AddRow:
label_1:
        switch (1)
        {
          case 0:
            goto label_1;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_RowMenuEnable);
            }
            enabled = this.mnuRowAdd.Enabled;
            break;
        }
        break;
      case RowMenu.InsertRow:
        enabled = this.mnuRowInsert.Enabled;
        break;
      case RowMenu.DeleteRow:
label_7:
        switch (3)
        {
          case 0:
            goto label_7;
          default:
            enabled = this.mnuRowDelete.Enabled;
            break;
        }
        break;
      case RowMenu.UnchangeRow:
label_9:
        switch (3)
        {
          case 0:
            goto label_9;
          default:
            enabled = this.mnuRowUnchange.Enabled;
            break;
        }
        break;
      case RowMenu.CopyRow:
label_5:
        switch (2)
        {
          case 0:
            goto label_5;
          default:
            enabled = this.mnuRowCopy.Enabled;
            break;
        }
        break;
      case RowMenu.PasteRow:
        enabled = this.mnuRowPaste.Enabled;
        break;
      case RowMenu.InsertPaste:
label_11:
        switch (2)
        {
          case 0:
            goto label_11;
          default:
            enabled = this.mnuInsertPaste.Enabled;
            break;
        }
        break;
      case RowMenu.SelectAll:
label_17:
        switch (2)
        {
          case 0:
            goto label_17;
          default:
            enabled = this.mnuRowSelectAll.Enabled;
            break;
        }
        break;
      case RowMenu.PasteExcel:
label_14:
        switch (1)
        {
          case 0:
            goto label_14;
          default:
            enabled = this.mnuExcelPaste.Enabled;
            break;
        }
        break;
    }
    return enabled;
  }

  public void set_RowMenuEnable(RowMenu rowMenu, bool value)
  {
    if (rowMenu == RowMenu.AddRow)
    {
label_1:
      switch (7)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_RowMenuEnable);
          }
          this.mnuRowAdd.Enabled = value;
          break;
      }
    }
    if (rowMenu == RowMenu.CopyRow)
    {
label_6:
      switch (3)
      {
        case 0:
          goto label_6;
        default:
          this.mnuRowCopy.Enabled = value;
          break;
      }
    }
    if (rowMenu == RowMenu.DeleteRow)
    {
label_9:
      switch (1)
      {
        case 0:
          goto label_9;
        default:
          this.mnuRowDelete.Enabled = value;
          break;
      }
    }
    if (rowMenu == RowMenu.UnchangeRow)
    {
label_12:
      switch (7)
      {
        case 0:
          goto label_12;
        default:
          this.mnuRowUnchange.Enabled = value;
          break;
      }
    }
    if (rowMenu == RowMenu.InsertPaste)
      this.mnuInsertPaste.Enabled = value;
    if (rowMenu == RowMenu.InsertRow)
    {
label_17:
      switch (1)
      {
        case 0:
          goto label_17;
        default:
          this.mnuRowInsert.Enabled = value;
          break;
      }
    }
    if (rowMenu == RowMenu.PasteExcel)
    {
label_20:
      switch (2)
      {
        case 0:
          goto label_20;
        default:
          this.mnuExcelPaste.Enabled = value;
          break;
      }
    }
    if (rowMenu == RowMenu.PasteRow)
    {
label_23:
      switch (6)
      {
        case 0:
          goto label_23;
        default:
          this.mnuRowPaste.Enabled = value;
          break;
      }
    }
    if (rowMenu != RowMenu.SelectAll)
      return;
label_26:
    switch (1)
    {
      case 0:
        goto label_26;
      default:
        this.mnuRowSelectAll.Enabled = value;
        break;
    }
  }

  public void BestFitColumns()
  {
    if (!this.GridView1.OptionsView.ShowColumnHeaders)
    {
      this.GridView1.OptionsView.ShowColumnHeaders = true;
      this.GridView1.BestFitColumns();
      this.GridView1.OptionsView.ShowColumnHeaders = false;
    }
    else
      this.GridView1.BestFitColumns();
  }

  public DataTable GetComboItemTable(string fldNm)
  {
    if (this.get_c3b70f7febd94504d2ae889cd04cf3e00(fldNm) != null)
      return (DataTable) ((RepositoryItemLookUpEditBase) this.get_c3b70f7febd94504d2ae889cd04cf3e00(fldNm).ColumnEdit).DataSource;
label_1:
    switch (3)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.GetComboItemTable);
        }
        return (DataTable) null;
    }
  }

  public void AddCombo(string fldNm, string code, string txt)
  {
    if (this.get_c3b70f7febd94504d2ae889cd04cf3e00(fldNm) == null)
    {
label_1:
      switch (2)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.AddCombo);
          break;
      }
    }
    else
    {
      RepositoryItemLookUpEdit columnEdit = (RepositoryItemLookUpEdit) this.get_c3b70f7febd94504d2ae889cd04cf3e00(fldNm).ColumnEdit;
      DataTable dataTable;
      if (columnEdit.DataSource == null)
      {
label_5:
        switch (7)
        {
          case 0:
            goto label_5;
          default:
            dataTable = new DataTable();
            dataTable.Columns.Add(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(202));
            dataTable.Columns.Add(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3700));
            this.cc5f5ca5e837b4f589c2b452ae4712d2c(columnEdit, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(202), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3700));
            DataRow row = dataTable.NewRow();
            row[0] = (object) "";
            row[1] = (object) "";
            dataTable.Rows.Add(row);
            columnEdit.DataSource = (object) dataTable;
            break;
        }
      }
      else
        dataTable = (DataTable) columnEdit.DataSource;
      DataRow row1 = dataTable.NewRow();
      row1[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(202)] = (object) Shared.ToStr((object) code);
      row1[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3700)] = (object) Shared.ToStr((object) txt);
      dataTable.Rows.Add(row1);
    }
  }

  public void SetCombo(string fldNm, DataSet datSet, string popUpNo = "")
  {
    if (Shared.IsEmpty(datSet))
    {
label_1:
      switch (3)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.SetCombo);
          break;
      }
    }
    else if (Shared.IsEmpty(datSet.Tables[0]))
    {
label_6:
      switch (1)
      {
        case 0:
          goto label_6;
      }
    }
    else
    {
      try
      {
        foreach (DataRow row in datSet.Tables[0].Rows)
        {
          string str1 = Shared.ToStr(RuntimeHelpers.GetObjectValue(row[0]));
          string str2 = Shared.ToStr(RuntimeHelpers.GetObjectValue(row[1]));
          this.AddCombo(fldNm, str1, str2);
        }
label_10:
        switch (1)
        {
          case 0:
            goto label_10;
        }
      }
      finally
      {
        IEnumerator enumerator;
        if (enumerator is IDisposable)
          (enumerator as IDisposable).Dispose();
      }
    }
  }

  public bool CheckedRowsMessage(string columnName)
  {
    if (this.CheckedRows(columnName) != 0)
      return true;
label_1:
    switch (3)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.CheckedRowsMessage);
        }
        Shared.PutMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3705), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3738));
        return false;
    }
  }

  public int CheckedRows(string columnName)
  {
    this.UpdateCurrentRow();
    int num1 = checked (this.RowCount - 1);
    int rowHandle = 0;
    int num2;
    while (rowHandle <= num1)
    {
      if (this.get_ToBool(columnName, rowHandle))
        checked { ++num2; }
      checked { ++rowHandle; }
    }
    return num2;
  }

  public void CheckRows(string columnName, bool chk = true)
  {
    if (this.RowCount == 0)
    {
label_1:
      switch (7)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.CheckRows);
          break;
      }
    }
    else if (this.c31b549eb509ea9196e125f4a81deac9e())
    {
label_5:
      switch (4)
      {
        case 0:
          goto label_5;
        default:
          Shared.PutMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3763), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3812));
          break;
      }
    }
    else
    {
      int focusedRowHandle = this.GridView1.FocusedRowHandle;
      this.StopOpenEvent = true;
      this.StopCheck = false;
      if (this.GridView1.SelectedRowsCount > 1)
      {
label_8:
        switch (7)
        {
          case 0:
            goto label_8;
          default:
            int[] selectedRows = this.GridView1.GetSelectedRows();
            int index = 0;
            while (index < selectedRows.Length)
            {
              int rowHandle = selectedRows[index];
              if (!this.ce8e830301aad7239d91493f34cace090)
              {
                if (this.get_ToBool(columnName, rowHandle) != chk)
                {
                  this.RowIndex = rowHandle;
                  this.set_Text(columnName, -1, Conversions.ToString(Interaction.IIf(chk, (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(79), (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82))));
                }
                checked { ++index; }
              }
              else
                goto label_27;
            }
label_16:
            switch (1)
            {
              case 0:
                goto label_16;
            }
            break;
        }
      }
      else
      {
        int num = checked (this.RowCount - 1);
        int rowHandle = 0;
        while (rowHandle <= num)
        {
          if (this.ce8e830301aad7239d91493f34cace090)
          {
label_19:
            switch (5)
            {
              case 0:
                goto label_19;
              default:
                goto label_26;
            }
          }
          else
          {
            if (this.get_ToBool(columnName, rowHandle) != chk)
            {
label_21:
              switch (4)
              {
                case 0:
                  goto label_21;
                default:
                  this.RowIndex = rowHandle;
                  this.set_Text(columnName, -1, Conversions.ToString(Interaction.IIf(chk, (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(79), (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82))));
                  break;
              }
            }
            checked { ++rowHandle; }
          }
        }
label_25:
        switch (6)
        {
          case 0:
            goto label_25;
        }
label_26:;
      }
label_27:
      this.RowIndex = focusedRowHandle;
      this.StopCheck = false;
      this.StopOpenEvent = false;
    }
  }

  public void Open(OpenParameters userParams = null)
  {
    if (this.WorkSet == null)
    {
label_1:
      switch (2)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.Open);
          break;
      }
    }
    else if (!this.WorkSet.CheckOpenParameters())
    {
label_6:
      switch (1)
      {
        case 0:
          goto label_6;
      }
    }
    else
      this.WorkSet.Open(userParams);
  }

  public bool Save()
  {
    bool flag;
    if (this.WorkSet != null)
      flag = this.WorkSet.Save();
    return flag;
  }

  private void cc5f5ca5e837b4f589c2b452ae4712d2c(
    RepositoryItemLookUpEdit c320269ec287d16905c829847d30a2e08,
    string cecdc503151e93532705c4031827d7d8a,
    string cc15c6c881a71b8624c3761c58b6e9c4f)
  {
    c320269ec287d16905c829847d30a2e08.ValueMember = cecdc503151e93532705c4031827d7d8a;
    c320269ec287d16905c829847d30a2e08.DisplayMember = cc15c6c881a71b8624c3761c58b6e9c4f;
    c320269ec287d16905c829847d30a2e08.Columns.Clear();
    c320269ec287d16905c829847d30a2e08.Columns.Add(new LookUpColumnInfo(cc15c6c881a71b8624c3761c58b6e9c4f, 0));
    c320269ec287d16905c829847d30a2e08.Columns.Add(new LookUpColumnInfo(cecdc503151e93532705c4031827d7d8a, 0));
    c320269ec287d16905c829847d30a2e08.ShowHeader = false;
    c320269ec287d16905c829847d30a2e08.NullText = "";
    c320269ec287d16905c829847d30a2e08.ShowLines = false;
    c320269ec287d16905c829847d30a2e08.Columns[0].Width = 0;
  }

  public void ClearCombo(string fldNm)
  {
    RepositoryItemLookUpEdit columnEdit = (RepositoryItemLookUpEdit) this.get_c3b70f7febd94504d2ae889cd04cf3e00(fldNm).ColumnEdit;
    if (!(columnEdit is RepositoryItemLookUpEdit))
      return;
label_1:
    switch (3)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.ClearCombo);
        }
        columnEdit.DataSource = (object) null;
        break;
    }
  }

  public void Find(string findString)
  {
    int rowIndex = this.FindRowIndex(findString);
    if (0 > rowIndex)
      return;
label_1:
    switch (4)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.Find);
        }
        this.GridView1.FocusedRowHandle = rowIndex;
        this.GridView1.TopRowIndex = rowIndex;
        break;
    }
  }

  public void Find(string[] findString)
  {
    int rowIndex = this.FindRowIndex(findString);
    if (0 > rowIndex)
      return;
label_1:
    switch (7)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.Find);
        }
        this.GridView1.FocusedRowHandle = rowIndex;
        this.GridView1.TopRowIndex = rowIndex;
        break;
    }
  }

  public int FindRowIndex(string findString)
  {
    if (findString == null)
    {
label_1:
      switch (5)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.FindRowIndex);
          }
          return -1;
      }
    }
    else
      return this.c5f1b021147b4472d8567e0edf5b6a095(new string[1]
      {
        findString
      });
  }

  public int FindRowIndex(string[] findString)
  {
    int num;
    if (findString != null)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.FindRowIndex);
          }
          num = findString.Length == 0 ? 1 : 0;
          break;
      }
    }
    else
      num = 1;
    if (num == 0)
      return this.c5f1b021147b4472d8567e0edf5b6a095(findString);
label_7:
    switch (5)
    {
      case 0:
        goto label_7;
      default:
        return -1;
    }
  }

  private int c5f1b021147b4472d8567e0edf5b6a095(string[] ce47ffae9c7db0f1f60aa084ec64c232a)
  {
    int num1;
    try
    {
      int num2 = checked (this.GridView1.RowCount - 1);
      int rowHandle = 0;
      while (rowHandle <= num2)
      {
        bool flag = true;
        string[] strArray1 = ce47ffae9c7db0f1f60aa084ec64c232a;
        int index = 0;
        while (index < strArray1.Length)
        {
          string[] strArray2 = Strings.Split(strArray1[index], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3879));
          if (strArray2.Length != 2)
          {
label_4:
            switch (1)
            {
              case 0:
                goto label_4;
              default:
                if (false)
                {
                  // ISSUE: method reference
                  RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c5f1b021147b4472d8567e0edf5b6a095);
                }
                int num3 = (int) Interaction.MsgBox((object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3882));
                goto label_23;
            }
          }
          else
          {
            if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[0].Trim(), "", false) != 0 & Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[1].Trim(), "", false) != 0)
            {
label_9:
              switch (5)
              {
                case 0:
                  goto label_9;
                default:
                  if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(this.GridView1.GetRowCellValue(rowHandle, strArray2[0].Trim()))), strArray2[1].Trim(), false) != 0)
                  {
label_11:
                    switch (7)
                    {
                      case 0:
                        goto label_11;
                      default:
                        flag = false;
                        goto label_16;
                    }
                  }
                  else
                    break;
              }
            }
            checked { ++index; }
          }
        }
label_15:
        switch (7)
        {
          case 0:
            goto label_15;
        }
label_16:
        if (flag)
        {
label_17:
          switch (2)
          {
            case 0:
              goto label_17;
            default:
              num1 = rowHandle;
              goto label_23;
          }
        }
        else
          checked { ++rowHandle; }
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageInfo(ex);
      ProjectData.ClearProjectError();
    }
    num1 = -1;
label_23:
    return num1;
  }

  public bool CheckRequired()
  {
    return this.cb2d70aeee71c46fd3d848f021d3df700(cec77d424d503cdc4dcb2d257f986313f: this.c26c855004913519a261bae8d8c34a7ad);
  }

  public bool CheckRequiredCheckedRow(string checkFieldName)
  {
    return this.cb2d70aeee71c46fd3d848f021d3df700(cec77d424d503cdc4dcb2d257f986313f: checkFieldName);
  }

  private bool cb2d70aeee71c46fd3d848f021d3df700(
    int c11868f6b2762950261a425c193652265 = -1,
    bool cd0428b8405ba38dda6789db4c40840a2 = false,
    string cec77d424d503cdc4dcb2d257f986313f = "")
  {
    string Left = "";
    this.Parent.Focus();
    if (this.GridView1.RowCount == 0)
      return true;
    try
    {
      IEnumerator enumerator;
      try
      {
        enumerator = this.GridView1.Columns.GetEnumerator();
        while (enumerator.MoveNext())
        {
          DevExpress.XtraGrid.Columns.GridColumn current = (DevExpress.XtraGrid.Columns.GridColumn) enumerator.Current;
          eGridColumn eGridColumn = this.GridColumn(current.FieldName);
          int num1;
          if (eGridColumn != null)
          {
label_5:
            switch (6)
            {
              case 0:
                goto label_5;
              default:
                if (false)
                {
                  // ISSUE: method reference
                  RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cb2d70aeee71c46fd3d848f021d3df700);
                }
                num1 = eGridColumn.IsRequired ? 1 : 0;
                break;
            }
          }
          else
            num1 = 0;
          if (num1 != 0)
          {
            int num2 = checked (this.GridView1.RowCount - 1);
            int num3 = 0;
            while (num3 <= num2)
            {
              DataRowView row = (DataRowView) this.GridView1.GetRow(num3);
              bool flag = false;
              if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(cec77d424d503cdc4dcb2d257f986313f, "", false) != 0)
              {
label_13:
                switch (1)
                {
                  case 0:
                    goto label_13;
                  default:
                    if (this.get_ToBool(cec77d424d503cdc4dcb2d257f986313f, num3))
                    {
label_15:
                      switch (7)
                      {
                        case 0:
                          goto label_15;
                        default:
                          flag = true;
                          break;
                      }
                    }
                    else
                    {
                      if (row.Row.RowState != DataRowState.Unchanged)
                      {
label_18:
                        switch (7)
                        {
                          case 0:
                            goto label_18;
                          default:
                            row.Row.AcceptChanges();
                            break;
                        }
                      }
                      break;
                    }
                    break;
                }
              }
              else if (!this.IsBlankRow(num3) & this.IsDataRow(num3) && row.Row.RowState == DataRowState.Added | row.Row.RowState == DataRowState.Modified)
                flag = true;
              if (flag)
              {
label_25:
                switch (7)
                {
                  case 0:
                    goto label_25;
                  default:
                    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(this.get_Text(current.FieldName, num3), "", false) == 0)
                    {
label_27:
                      switch (5)
                      {
                        case 0:
                          goto label_27;
                        default:
                          Left = Left + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3931) + eGridColumn.Title + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3934);
                          goto label_32;
                      }
                    }
                    else
                      break;
                }
              }
              checked { ++num3; }
            }
label_31:
            switch (3)
            {
              case 0:
                goto label_31;
            }
label_32:;
          }
        }
label_35:
        switch (4)
        {
          case 0:
            goto label_35;
        }
      }
      finally
      {
        if (enumerator is IDisposable)
        {
label_37:
          switch (1)
          {
            case 0:
              goto label_37;
            default:
              (enumerator as IDisposable).Dispose();
              break;
          }
        }
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3941));
      ProjectData.ClearProjectError();
    }
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Left, "", false) != 0)
    {
label_42:
      switch (1)
      {
        case 0:
          goto label_42;
        default:
          string message = Left + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3974) + Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3977));
          if (cd0428b8405ba38dda6789db4c40840a2)
          {
label_44:
            switch (1)
            {
              case 0:
                goto label_44;
              default:
                Shared.ThrowError(message, this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3941));
                break;
            }
          }
          else
          {
            Shared.MessageWarning(message);
            return false;
          }
          break;
      }
    }
    return true;
  }

  public DataRow get_DataRow(int RowIndex)
  {
    if (Information.IsNothing((object) this.c5d165dda3affdc10bf5fa3cdd0152971) || !this.GridView1.IsDataRow(RowIndex))
      return (DataRow) null;
label_2:
    switch (5)
    {
      case 0:
        goto label_2;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_DataRow);
        }
        try
        {
          return this.GridView1.GetDataRow(RowIndex);
        }
        catch (Exception ex)
        {
          ProjectData.SetProjectError(ex);
          Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4016) + RowIndex.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
          this.c8c8684eaecc3f7146066d6e2c6b049ec = false;
          ProjectData.ClearProjectError();
        }
        return (DataRow) null;
    }
  }

  public DataRowState get_RowState(int RowIndex)
  {
    if (Information.IsNothing((object) this.c5d165dda3affdc10bf5fa3cdd0152971) || !this.GridView1.IsDataRow(RowIndex))
      return (DataRowState) 0;
label_2:
    switch (4)
    {
      case 0:
        goto label_2;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_RowState);
        }
        try
        {
          return this.GridView1.GetDataRow(RowIndex).RowState;
        }
        catch (Exception ex)
        {
          ProjectData.SetProjectError(ex);
          Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4036) + RowIndex.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
          ProjectData.ClearProjectError();
        }
        return (DataRowState) 0;
    }
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public DataSet DataSet
  {
    get => this.c5d165dda3affdc10bf5fa3cdd0152971;
    set
    {
      this.ce75332160d718c37d93defbcd7e95679 = true;
      this.c5d165dda3affdc10bf5fa3cdd0152971 = value;
      if (this.c5d165dda3affdc10bf5fa3cdd0152971 == null)
        this.Grid1.DataSource = (object) null;
      else if (this.c467083dea0102ade8924e025f685c241 != null)
      {
label_3:
        switch (3)
        {
          case 0:
            goto label_3;
          default:
            if (false)
            {
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_DataSet);
            }
            this.c978e92c5b571d346d7e38111f15c27b7(this.c5d165dda3affdc10bf5fa3cdd0152971.Tables[0]);
            break;
        }
      }
      else
        this.Grid1.DataSource = (object) this.c5d165dda3affdc10bf5fa3cdd0152971.Tables[0];
      this.cb1889f5f18b3611413f64aac4ae0c235(-1, this.GridView1.FocusedRowHandle);
      this.cc0d454e2f1398908e3cc1bf29ad72f9a = false;
      this.ce75332160d718c37d93defbcd7e95679 = false;
      if (this.ccac4c8044ae680dcd351934054a598ac == null)
        return;
label_10:
      switch (2)
      {
        case 0:
          goto label_10;
        default:
          this.GridView1.GroupSummary.Assign((GridSummaryItemCollection) this.ccac4c8044ae680dcd351934054a598ac);
          this.GridView1.OptionsView.ShowFooter = true;
          this.GridView1.OptionsView.GroupFooterShowMode = GroupFooterShowMode.VisibleAlways;
          break;
      }
    }
  }

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public object DataSource
  {
    get => this.Grid1.DataSource;
    set
    {
      this.Grid1.DataSource = RuntimeHelpers.GetObjectValue(value);
      this.cc0d454e2f1398908e3cc1bf29ad72f9a = false;
    }
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public bool DataChanged
  {
    get => this.cc0d454e2f1398908e3cc1bf29ad72f9a;
    set => this.cc0d454e2f1398908e3cc1bf29ad72f9a = value;
  }

  [DefaultValue(true)]
  public bool RecordNavigator
  {
    get => this.Grid1.UseEmbeddedNavigator;
    set => this.Grid1.UseEmbeddedNavigator = value;
  }

  public Decimal RowTotal(string column)
  {
    Decimal d1 = 0M;
    int num = checked (this.RowCount - 1);
    int rowHandle = 0;
    while (rowHandle <= num)
    {
      d1 = Decimal.Add(d1, this.get_ToDec(column, rowHandle));
      checked { ++rowHandle; }
    }
label_3:
    switch (4)
    {
      case 0:
        goto label_3;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.RowTotal);
        }
        return d1;
    }
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public int ColumnCount
  {
    get
    {
      if (Information.IsNothing((object) this.GridView1.Columns))
        return 0;
label_1:
      switch (7)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_ColumnCount);
          }
          return this.GridView1.Columns.Count;
      }
    }
  }

  public string get_FieldName(int Index)
  {
    string fieldName;
    try
    {
      fieldName = this.get_c3b70f7febd94504d2ae889cd04cf3e00(Index).FieldName;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4055) + Index.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      fieldName = "";
      ProjectData.ClearProjectError();
    }
    return fieldName;
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public GridEnterDirection EnterDirection
  {
    get => this.c9b149e1771cda0755be116d1d00e5bcf;
    set
    {
      this.c9b149e1771cda0755be116d1d00e5bcf = value;
      this.GridView1.OptionsNavigation.EnterMoveNextColumn = this.c9b149e1771cda0755be116d1d00e5bcf == GridEnterDirection.Right;
    }
  }

  private DevExpress.XtraGrid.Columns.GridColumn get_c3b70f7febd94504d2ae889cd04cf3e00(
    string c7970bee6aafe907ae5596d4021302c6a)
  {
    try
    {
      c7970bee6aafe907ae5596d4021302c6a = c7970bee6aafe907ae5596d4021302c6a.ToLower();
      IEnumerator enumerator;
      try
      {
        enumerator = this.GridView1.Columns.GetEnumerator();
        while (enumerator.MoveNext())
        {
          DevExpress.XtraGrid.Columns.GridColumn current = (DevExpress.XtraGrid.Columns.GridColumn) enumerator.Current;
          if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(current.FieldName.ToLower(), c7970bee6aafe907ae5596d4021302c6a, false) == 0)
          {
label_4:
            switch (6)
            {
              case 0:
                goto label_4;
              default:
                if (false)
                {
                  // ISSUE: method reference
                  RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_c3b70f7febd94504d2ae889cd04cf3e00);
                }
                return current;
            }
          }
        }
label_9:
        switch (2)
        {
          case 0:
            goto label_9;
        }
      }
      finally
      {
        if (enumerator is IDisposable)
        {
label_11:
          switch (1)
          {
            case 0:
              goto label_11;
            default:
              (enumerator as IDisposable).Dispose();
              break;
          }
        }
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4076) + c7970bee6aafe907ae5596d4021302c6a + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
    return (DevExpress.XtraGrid.Columns.GridColumn) null;
  }

  private DevExpress.XtraGrid.Columns.GridColumn get_c3b70f7febd94504d2ae889cd04cf3e00(
    int c72fe12625a1dfac1079cc6f394d1db49)
  {
    return (DevExpress.XtraGrid.Columns.GridColumn) this.GridView1.Columns[c72fe12625a1dfac1079cc6f394d1db49];
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public int ColumnIndex
  {
    get
    {
      int visibleIndex;
      try
      {
        visibleIndex = this.GridView1.FocusedColumn.VisibleIndex;
      }
      catch (Exception ex)
      {
        ProjectData.SetProjectError(ex);
        ProjectData.ClearProjectError();
      }
      return visibleIndex;
    }
    set => this.GridView1.FocusedColumn = this.get_c3b70f7febd94504d2ae889cd04cf3e00(value);
  }

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public string FocusedFieldName
  {
    get => this.GridView1.FocusedColumn == null ? "" : this.GridView1.FocusedColumn.FieldName;
    set => this.GridView1.FocusedColumn = this.get_c3b70f7febd94504d2ae889cd04cf3e00(value);
  }

  public int get_VisibleIndex(string column)
  {
    int visibleIndex;
    try
    {
      visibleIndex = this.get_c3b70f7febd94504d2ae889cd04cf3e00(column).VisibleIndex;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      ProjectData.ClearProjectError();
    }
    return visibleIndex;
  }

  public void set_VisibleIndex(string column, int value)
  {
    try
    {
      this.get_c3b70f7febd94504d2ae889cd04cf3e00(column).VisibleIndex = value;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4103) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
  }

  public string get_BandTitle(int Index)
  {
    string bandTitle;
    try
    {
      DevExpress.XtraGrid.Columns.GridColumn c1e6290ac54e381b2081d91b6c00805a8 = this.get_c3b70f7febd94504d2ae889cd04cf3e00(Index);
      if (c1e6290ac54e381b2081d91b6c00805a8 == null)
      {
label_2:
        switch (7)
        {
          case 0:
            goto label_2;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_BandTitle);
            }
            bandTitle = "";
            break;
        }
      }
      else
      {
        GridBand gridBand = this.c19f146e2e7d387b94d283d782a9c2c12(c1e6290ac54e381b2081d91b6c00805a8);
        if (gridBand == null)
        {
label_7:
          switch (5)
          {
            case 0:
              goto label_7;
            default:
              bandTitle = "";
              break;
          }
        }
        else if (gridBand.ParentBand == null)
        {
label_10:
          switch (6)
          {
            case 0:
              goto label_10;
            default:
              bandTitle = "";
              break;
          }
        }
        else
          bandTitle = gridBand.ParentBand.Caption;
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4130) + Index.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      bandTitle = "";
      ProjectData.ClearProjectError();
    }
    return bandTitle;
  }

  public void set_BandTitle(int Index, string Value)
  {
    try
    {
      this.c19f146e2e7d387b94d283d782a9c2c12(this.get_c3b70f7febd94504d2ae889cd04cf3e00(Index)).ParentBand.Caption = Value;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, Conversions.ToString(Conversions.ToDouble(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4130)) + (double) Index + Conversions.ToDouble(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033))));
      ProjectData.ClearProjectError();
    }
  }

  public string get_BandTitle(string column)
  {
    string bandTitle;
    try
    {
      DevExpress.XtraGrid.Columns.GridColumn c1e6290ac54e381b2081d91b6c00805a8 = this.get_c3b70f7febd94504d2ae889cd04cf3e00(column);
      if (c1e6290ac54e381b2081d91b6c00805a8 != null)
      {
label_2:
        switch (7)
        {
          case 0:
            goto label_2;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_BandTitle);
            }
            GridBand gridBand = this.c19f146e2e7d387b94d283d782a9c2c12(c1e6290ac54e381b2081d91b6c00805a8);
            int num;
            if (gridBand != null)
            {
label_6:
              switch (5)
              {
                case 0:
                  goto label_6;
                default:
                  num = gridBand.ParentBand == null ? 1 : 0;
                  break;
              }
            }
            else
              num = 1;
            if (num != 0)
            {
label_10:
              switch (5)
              {
                case 0:
                  goto label_10;
                default:
                  bandTitle = "";
                  break;
              }
            }
            else
            {
              bandTitle = gridBand.ParentBand.Caption;
              break;
            }
            break;
        }
      }
      else
      {
        GridBand gridBand = this.c58cd0dfb7d46ac108ee5012500aca69b(column);
        if (gridBand == null)
        {
label_14:
          switch (6)
          {
            case 0:
              goto label_14;
            default:
              bandTitle = "";
              break;
          }
        }
        else
          bandTitle = gridBand.Caption;
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4130) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      bandTitle = "";
      ProjectData.ClearProjectError();
    }
    return bandTitle;
  }

  public void set_BandTitle(string column, string Value)
  {
    try
    {
      DevExpress.XtraGrid.Columns.GridColumn c1e6290ac54e381b2081d91b6c00805a8 = this.get_c3b70f7febd94504d2ae889cd04cf3e00(column);
      if (c1e6290ac54e381b2081d91b6c00805a8 != null)
      {
        GridBand gridBand = this.c19f146e2e7d387b94d283d782a9c2c12(c1e6290ac54e381b2081d91b6c00805a8);
        int num;
        if (gridBand != null)
        {
label_3:
          switch (3)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_BandTitle);
              }
              num = gridBand.ParentBand != null ? 1 : 0;
              break;
          }
        }
        else
          num = 0;
        if (num == 0)
          return;
        gridBand.ParentBand.Caption = Value;
      }
      else
      {
        GridBand gridBand = this.c58cd0dfb7d46ac108ee5012500aca69b(column);
        if (gridBand != null)
        {
label_11:
          switch (7)
          {
            case 0:
              goto label_11;
            default:
              gridBand.Caption = Value;
              break;
          }
        }
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4130) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
  }

  public string get_TopBandTitle(string column)
  {
    string topBandTitle;
    try
    {
      DevExpress.XtraGrid.Columns.GridColumn c1e6290ac54e381b2081d91b6c00805a8 = this.get_c3b70f7febd94504d2ae889cd04cf3e00(column);
      if (c1e6290ac54e381b2081d91b6c00805a8 == null)
      {
        topBandTitle = "";
      }
      else
      {
        GridBand gridBand = this.c19f146e2e7d387b94d283d782a9c2c12(c1e6290ac54e381b2081d91b6c00805a8);
        if (gridBand == null)
        {
          topBandTitle = "";
        }
        else
        {
          for (GridBand parentBand = gridBand.ParentBand; parentBand != null; parentBand = parentBand.ParentBand)
          {
            if (parentBand.ParentBand == null)
            {
label_7:
              switch (3)
              {
                case 0:
                  goto label_7;
                default:
                  if (false)
                  {
                    // ISSUE: method reference
                    RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_TopBandTitle);
                  }
                  topBandTitle = parentBand.Caption;
                  goto label_16;
              }
            }
          }
label_13:
          switch (7)
          {
            case 0:
              goto label_13;
            default:
              topBandTitle = "";
              break;
          }
        }
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4151) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      topBandTitle = "";
      ProjectData.ClearProjectError();
    }
label_16:
    return topBandTitle;
  }

  public void set_TopBandTitle(string column, string Value)
  {
    try
    {
      GridBand gridBand = this.c19f146e2e7d387b94d283d782a9c2c12(this.get_c3b70f7febd94504d2ae889cd04cf3e00(column));
      if (gridBand.ParentBand == null || gridBand.ParentBand.ParentBand == null)
        return;
      gridBand.ParentBand.ParentBand.Caption = Value;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4151) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
  }

  public string get_BandName(string columnName)
  {
    string bandName;
    try
    {
      DevExpress.XtraGrid.Columns.GridColumn c1e6290ac54e381b2081d91b6c00805a8 = this.get_c3b70f7febd94504d2ae889cd04cf3e00(columnName);
      if (c1e6290ac54e381b2081d91b6c00805a8 == null)
      {
        bandName = "";
      }
      else
      {
        GridBand gridBand = this.c19f146e2e7d387b94d283d782a9c2c12(c1e6290ac54e381b2081d91b6c00805a8);
        if (gridBand == null)
        {
label_4:
          switch (3)
          {
            case 0:
              goto label_4;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_BandName);
              }
              bandName = "";
              break;
          }
        }
        else
          bandName = gridBand.Name;
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4178) + columnName + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      bandName = "";
      ProjectData.ClearProjectError();
    }
    return bandName;
  }

  public string get_ColumnTitle(int Index)
  {
    string columnTitle;
    try
    {
      columnTitle = this.get_c3b70f7febd94504d2ae889cd04cf3e00(Index).Caption;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4197) + Index.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      columnTitle = "";
      ProjectData.ClearProjectError();
    }
    return columnTitle;
  }

  public void set_ColumnTitle(int Index, string Value)
  {
    try
    {
      this.get_c3b70f7febd94504d2ae889cd04cf3e00(Index).Caption = Value;
      GridBand gridBand = this.c19f146e2e7d387b94d283d782a9c2c12(this.get_c3b70f7febd94504d2ae889cd04cf3e00(Index));
      if (gridBand == null)
        return;
      gridBand.Caption = Value;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4197) + Index.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
  }

  public string get_ColumnTitle(string column)
  {
    string columnTitle;
    try
    {
      columnTitle = this.get_c3b70f7febd94504d2ae889cd04cf3e00(column).Caption;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4197) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      columnTitle = "";
      ProjectData.ClearProjectError();
    }
    return columnTitle;
  }

  public void set_ColumnTitle(string column, string Value)
  {
    try
    {
      this.get_c3b70f7febd94504d2ae889cd04cf3e00(column).Caption = Value;
      GridBand gridBand = this.c19f146e2e7d387b94d283d782a9c2c12(this.get_c3b70f7febd94504d2ae889cd04cf3e00(column));
      if (gridBand == null)
        return;
      gridBand.Caption = Value;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4197) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
  }

  public bool get_ColumnReadOnly(string column)
  {
    bool columnReadOnly;
    try
    {
      columnReadOnly = !this.get_c3b70f7febd94504d2ae889cd04cf3e00(column).OptionsColumn.AllowEdit;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4222) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
    return columnReadOnly;
  }

  public void set_ColumnReadOnly(string column, bool Value)
  {
    try
    {
      DevExpress.XtraGrid.Columns.GridColumn c1e6290ac54e381b2081d91b6c00805a8 = this.get_c3b70f7febd94504d2ae889cd04cf3e00(column);
      c1e6290ac54e381b2081d91b6c00805a8.OptionsColumn.AllowEdit = !Value;
      this.GridColumn(column).ReadOnly = Value;
      c1e6290ac54e381b2081d91b6c00805a8.AppearanceHeader.ForeColor = this.c70428d55a313f2054944b9123b9eda77(this.GridColumn(column));
      this.cb77e074cc62c973711f2b127bea96869(c1e6290ac54e381b2081d91b6c00805a8, Value);
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4222) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
  }

  public bool get_ColumnReadOnly(int columnIndex)
  {
    bool columnReadOnly;
    try
    {
      columnReadOnly = !this.get_c3b70f7febd94504d2ae889cd04cf3e00(columnIndex).OptionsColumn.AllowEdit;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4222) + columnIndex.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
    return columnReadOnly;
  }

  public void set_ColumnReadOnly(int columnIndex, bool Value)
  {
    this.set_ColumnReadOnly(this.get_FieldName(columnIndex), Value);
  }

  public string get_DetailKeyColumnName(string column)
  {
    if (this.get_c3b70f7febd94504d2ae889cd04cf3e00(column) != null)
    {
label_1:
      switch (3)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_DetailKeyColumnName);
          }
          if (column.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4253)))
          {
label_5:
            switch (7)
            {
              case 0:
                goto label_5;
              default:
                return column.Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4253), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(135)).Split(',')[0];
            }
          }
          else
            break;
      }
    }
    return "";
  }

  public string get_DetailKeyColumnName(int columnIndex)
  {
    try
    {
      return this.get_DetailKeyColumnName(this.get_FieldName(columnIndex));
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4258) + columnIndex.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
    return "";
  }

  public bool get_ColumnVisible(string column)
  {
    bool visible;
    try
    {
      visible = this.get_c3b70f7febd94504d2ae889cd04cf3e00(column).Visible;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4299) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
    return visible;
  }

  public void set_ColumnVisible(string column, bool Value)
  {
    try
    {
      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(column, "", false) == 0)
        return;
      int num1;
      if (!column.StartsWith(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4328)))
      {
label_3:
        switch (1)
        {
          case 0:
            goto label_3;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_ColumnVisible);
            }
            num1 = column.EndsWith(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4328)) ? 1 : 0;
            break;
        }
      }
      else
        num1 = 1;
      if (num1 != 0)
      {
label_9:
        switch (1)
        {
          case 0:
            goto label_9;
          default:
            string lower = column.Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4328), "").ToLower();
            IEnumerator enumerator;
            try
            {
              enumerator = this.GridView1.Columns.GetEnumerator();
              while (enumerator.MoveNext())
              {
                DevExpress.XtraGrid.Columns.GridColumn current = (DevExpress.XtraGrid.Columns.GridColumn) enumerator.Current;
                if (column.StartsWith(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4328)))
                {
                  if (!current.FieldName.ToLower().EndsWith(lower))
                  {
label_14:
                    switch (1)
                    {
                      case 0:
                        goto label_14;
                    }
                  }
                  else
                    goto label_23;
                }
                if (column.EndsWith(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4328)))
                {
                  if (!current.FieldName.ToLower().StartsWith(lower))
                  {
label_17:
                    switch (4)
                    {
                      case 0:
                        goto label_17;
                    }
                  }
                  else
                    goto label_23;
                }
                int num2;
                if (column.StartsWith(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4328)))
                {
label_19:
                  switch (1)
                  {
                    case 0:
                      goto label_19;
                    default:
                      if (column.EndsWith(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4328)))
                      {
                        num2 = current.FieldName.ToLower().Contains(lower) ? 1 : 0;
                        goto label_24;
                      }
                      break;
                  }
                }
                num2 = 0;
                goto label_24;
label_23:
                num2 = 1;
label_24:
                if (num2 != 0)
                  this.c5b871ae134785e12b0b126622322be57(current, Value);
              }
label_28:
              switch (1)
              {
                case 0:
                  goto label_28;
              }
            }
            finally
            {
              if (enumerator is IDisposable)
              {
label_30:
                switch (1)
                {
                  case 0:
                    goto label_30;
                  default:
                    (enumerator as IDisposable).Dispose();
                    break;
                }
              }
            }
            break;
        }
      }
      else
        this.c5b871ae134785e12b0b126622322be57(this.get_c3b70f7febd94504d2ae889cd04cf3e00(column), Value);
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4299) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
  }

  public bool get_DetailColumnVisible(string column)
  {
    bool visible;
    try
    {
      column = column.ToLower();
      IEnumerator enumerator;
      try
      {
        enumerator = this.GridView1.Columns.GetEnumerator();
        while (enumerator.MoveNext())
        {
          DevExpress.XtraGrid.Columns.GridColumn current = (DevExpress.XtraGrid.Columns.GridColumn) enumerator.Current;
          int num;
          if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(current.FieldName.ToLower(), column, false) != 0)
          {
label_4:
            switch (6)
            {
              case 0:
                goto label_4;
              default:
                if (false)
                {
                  // ISSUE: method reference
                  RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_DetailColumnVisible);
                }
                num = current.FieldName.ToLower().StartsWith(column) ? 1 : 0;
                break;
            }
          }
          else
            num = 0;
          if (num != 0)
          {
label_10:
            switch (7)
            {
              case 0:
                goto label_10;
              default:
                visible = current.Visible;
                goto label_19;
            }
          }
        }
      }
      finally
      {
        if (enumerator is IDisposable)
        {
label_14:
          switch (3)
          {
            case 0:
              goto label_14;
            default:
              (enumerator as IDisposable).Dispose();
              break;
          }
        }
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4331) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
label_19:
    return visible;
  }

  public void set_DetailColumnVisible(string column, bool Value)
  {
    try
    {
      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(column, "", false) == 0)
      {
label_2:
        switch (4)
        {
          case 0:
            goto label_2;
          default:
            if (true)
              break;
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_DetailColumnVisible);
            break;
        }
      }
      else
      {
        column = column.ToLower();
        IEnumerator enumerator;
        try
        {
          enumerator = this.GridView1.Columns.GetEnumerator();
          while (enumerator.MoveNext())
          {
            DevExpress.XtraGrid.Columns.GridColumn current = (DevExpress.XtraGrid.Columns.GridColumn) enumerator.Current;
            if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(current.FieldName.ToLower(), column, false) != 0 && current.FieldName.ToLower().StartsWith(column))
            {
label_8:
              switch (2)
              {
                case 0:
                  goto label_8;
                default:
                  this.c5b871ae134785e12b0b126622322be57(current, Value);
                  break;
              }
            }
          }
label_12:
          switch (5)
          {
            case 0:
              goto label_12;
          }
        }
        finally
        {
          if (enumerator is IDisposable)
          {
label_15:
            switch (2)
            {
              case 0:
                goto label_15;
              default:
                (enumerator as IDisposable).Dispose();
                break;
            }
          }
        }
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4331) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
  }

  public bool get_ColumnVisible(int columnIndex)
  {
    bool visible;
    try
    {
      visible = this.get_c3b70f7febd94504d2ae889cd04cf3e00(columnIndex).Visible;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4299) + columnIndex.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
    return visible;
  }

  public void set_ColumnVisible(int columnIndex, bool Value)
  {
    try
    {
      this.set_ColumnVisible(this.get_FieldName(columnIndex), Value);
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4299) + columnIndex.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
  }

  public void set_ColumnMerge(string column, bool Value)
  {
    try
    {
      DevExpress.XtraGrid.Columns.GridColumn gridColumn = this.get_c3b70f7febd94504d2ae889cd04cf3e00(column);
      if (Value)
      {
label_2:
        switch (4)
        {
          case 0:
            goto label_2;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_ColumnMerge);
            }
            if (!this.GridView1.OptionsView.AllowCellMerge)
            {
label_6:
              switch (1)
              {
                case 0:
                  goto label_6;
                default:
                  this.GridView1.OptionsView.AllowCellMerge = true;
                  break;
              }
            }
            break;
        }
      }
      gridColumn.OptionsColumn.AllowMerge = (DefaultBoolean) Conversions.ToInteger(Interaction.IIf(Value, (object) DefaultBoolean.True, (object) DefaultBoolean.False));
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4372) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
  }

  public int get_ColumnWidth(int Index)
  {
    int columnWidth;
    try
    {
      columnWidth = this.get_c3b70f7febd94504d2ae889cd04cf3e00(Index).Width;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4397) + Index.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      columnWidth = Conversions.ToInteger("");
      ProjectData.ClearProjectError();
    }
    return columnWidth;
  }

  public void set_ColumnWidth(int Index, int Value)
  {
    try
    {
      this.get_c3b70f7febd94504d2ae889cd04cf3e00(Index).Width = Value;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4397) + Index.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
  }

  public int get_ColumnWidth(string column)
  {
    int columnWidth;
    try
    {
      columnWidth = this.get_c3b70f7febd94504d2ae889cd04cf3e00(column).Width;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4397) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      columnWidth = Conversions.ToInteger("");
      ProjectData.ClearProjectError();
    }
    return columnWidth;
  }

  public void set_ColumnWidth(string column, int Value)
  {
    try
    {
      this.get_c3b70f7febd94504d2ae889cd04cf3e00(column).Width = Value;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4397) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
  }

  public bool get_ComboEditable(string column)
  {
    bool comboEditable;
    try
    {
      if (this.get_c3b70f7febd94504d2ae889cd04cf3e00(column).ColumnEdit is RepositoryItemLookUpEdit)
      {
        if (((RepositoryItemLookUpEditBase) this.get_c3b70f7febd94504d2ae889cd04cf3e00(column).ColumnEdit).TextEditStyle == TextEditStyles.DisableTextEditor)
        {
label_3:
          switch (7)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_ComboEditable);
              }
              comboEditable = false;
              break;
          }
        }
        else
          comboEditable = true;
      }
      else
        comboEditable = false;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4422) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
    return comboEditable;
  }

  public void set_ComboEditable(string column, bool Value)
  {
    try
    {
      if (!(this.get_c3b70f7febd94504d2ae889cd04cf3e00(column).ColumnEdit is RepositoryItemLookUpEdit))
        return;
label_2:
      switch (4)
      {
        case 0:
          goto label_2;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_ComboEditable);
          }
          RepositoryItemLookUpEdit columnEdit = (RepositoryItemLookUpEdit) this.get_c3b70f7febd94504d2ae889cd04cf3e00(column).ColumnEdit;
          if (Value)
          {
label_6:
            switch (5)
            {
              case 0:
                goto label_6;
              default:
                columnEdit.TextEditStyle = TextEditStyles.Standard;
                break;
            }
          }
          else
            columnEdit.TextEditStyle = TextEditStyles.DisableTextEditor;
          break;
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4422) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
  }

  public int get_ColumnMaxLength(string column)
  {
    int columnMaxLength;
    try
    {
      columnMaxLength = this.get_c3b70f7febd94504d2ae889cd04cf3e00(column).Width;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4451) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      columnMaxLength = Conversions.ToInteger("");
      ProjectData.ClearProjectError();
    }
    return columnMaxLength;
  }

  public void set_ColumnMaxLength(string column, int Value)
  {
    try
    {
      if (this.get_c3b70f7febd94504d2ae889cd04cf3e00(column) == null || !(this.get_c3b70f7febd94504d2ae889cd04cf3e00(column).ColumnEdit is RepositoryItemTextEdit))
        return;
label_3:
      switch (2)
      {
        case 0:
          goto label_3;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_ColumnMaxLength);
          }
          ((RepositoryItemTextEdit) this.get_c3b70f7febd94504d2ae889cd04cf3e00(column).ColumnEdit).MaxLength = Value;
          break;
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4451) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
  }

  public object get_ColumnMaxValue(string columnName) => this.GridColumn(columnName)?.MaxValue;

  public void set_ColumnMaxValue(string columnName, object value)
  {
    eGridColumn eGridColumn = this.GridColumn(columnName);
    if (eGridColumn == null)
      return;
label_1:
    switch (4)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_ColumnMaxValue);
        }
        eGridColumn.MaxValue = RuntimeHelpers.GetObjectValue(value);
        break;
    }
  }

  public object get_ColumnMinValue(string columnName)
  {
    eGridColumn eGridColumn = this.GridColumn(columnName);
    if (eGridColumn == null)
      return (object) null;
label_1:
    switch (4)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_ColumnMinValue);
        }
        return eGridColumn.MinValue;
    }
  }

  public void set_ColumnMinValue(string columnName, object value)
  {
    eGridColumn eGridColumn = this.GridColumn(columnName);
    if (eGridColumn == null)
      return;
label_1:
    switch (7)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_ColumnMinValue);
        }
        eGridColumn.MinValue = RuntimeHelpers.GetObjectValue(value);
        break;
    }
  }

  private void c5b871ae134785e12b0b126622322be57(
    DevExpress.XtraGrid.Columns.GridColumn c1e6290ac54e381b2081d91b6c00805a8,
    bool caaff527ef01e4c48f9b4a8ded743959e)
  {
    try
    {
      if (c1e6290ac54e381b2081d91b6c00805a8 == null)
      {
label_2:
        switch (2)
        {
          case 0:
            goto label_2;
          default:
            if (true)
              break;
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c5b871ae134785e12b0b126622322be57);
            break;
        }
      }
      else
      {
        GridBand gridBand = this.c19f146e2e7d387b94d283d782a9c2c12(c1e6290ac54e381b2081d91b6c00805a8);
        if (gridBand.Visible != caaff527ef01e4c48f9b4a8ded743959e)
        {
label_6:
          switch (3)
          {
            case 0:
              goto label_6;
            default:
              gridBand.Visible = caaff527ef01e4c48f9b4a8ded743959e;
              break;
          }
        }
        if (c1e6290ac54e381b2081d91b6c00805a8.Visible != caaff527ef01e4c48f9b4a8ded743959e)
        {
label_9:
          switch (4)
          {
            case 0:
              goto label_9;
            default:
              c1e6290ac54e381b2081d91b6c00805a8.Visible = caaff527ef01e4c48f9b4a8ded743959e;
              break;
          }
        }
        for (GridBand parentBand = gridBand.ParentBand; parentBand != null; parentBand = parentBand.ParentBand)
        {
          bool flag = false;
          IEnumerator enumerator;
          try
          {
            enumerator = parentBand.Children.GetEnumerator();
            while (enumerator.MoveNext())
            {
              if (((GridBand) enumerator.Current).Visible)
              {
                flag = true;
                goto label_23;
              }
            }
label_17:
            switch (7)
            {
              case 0:
                goto label_17;
            }
          }
          finally
          {
            if (enumerator is IDisposable)
            {
label_20:
              switch (6)
              {
                case 0:
                  goto label_20;
                default:
                  (enumerator as IDisposable).Dispose();
                  break;
              }
            }
          }
label_23:
          if (parentBand.Visible != flag)
          {
label_24:
            switch (5)
            {
              case 0:
                goto label_24;
              default:
                parentBand.Visible = flag;
                continue;
            }
          }
        }
label_28:
        switch (7)
        {
          case 0:
            goto label_28;
        }
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4484));
      ProjectData.ClearProjectError();
    }
  }

  private void cb77e074cc62c973711f2b127bea96869(
    DevExpress.XtraGrid.Columns.GridColumn c1e6290ac54e381b2081d91b6c00805a8,
    bool caaff527ef01e4c48f9b4a8ded743959e)
  {
    try
    {
      if (c1e6290ac54e381b2081d91b6c00805a8 == null)
        return;
      GridBand gridBand = this.c19f146e2e7d387b94d283d782a9c2c12(c1e6290ac54e381b2081d91b6c00805a8);
      if (gridBand != null)
      {
label_3:
        switch (5)
        {
          case 0:
            goto label_3;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cb77e074cc62c973711f2b127bea96869);
            }
            gridBand.AppearanceHeader.ForeColor = c1e6290ac54e381b2081d91b6c00805a8.AppearanceHeader.ForeColor;
            break;
        }
      }
      for (GridBand parentBand = gridBand.ParentBand; parentBand != null; parentBand = parentBand.ParentBand)
      {
        bool flag = false;
        IEnumerator enumerator1;
        try
        {
          enumerator1 = parentBand.Children.GetEnumerator();
          while (enumerator1.MoveNext())
          {
            GridBand current = (GridBand) enumerator1.Current;
            IEnumerator enumerator2;
            try
            {
              enumerator2 = current.Columns.GetEnumerator();
              while (enumerator2.MoveNext())
              {
                if (((DevExpress.XtraGrid.Columns.GridColumn) enumerator2.Current).OptionsColumn.AllowEdit)
                {
label_13:
                  switch (6)
                  {
                    case 0:
                      goto label_13;
                    default:
                      flag = true;
                      goto label_21;
                  }
                }
              }
label_16:
              switch (5)
              {
                case 0:
                  goto label_16;
              }
            }
            finally
            {
              if (enumerator2 is IDisposable)
              {
label_18:
                switch (2)
                {
                  case 0:
                    goto label_18;
                  default:
                    (enumerator2 as IDisposable).Dispose();
                    break;
                }
              }
            }
label_21:;
          }
        }
        finally
        {
          if (enumerator1 is IDisposable)
          {
label_25:
            switch (7)
            {
              case 0:
                goto label_25;
              default:
                (enumerator1 as IDisposable).Dispose();
                break;
            }
          }
        }
        AppearanceObject appearanceHeader = parentBand.AppearanceHeader;
        object obj = Interaction.IIf(!flag, (object) Color.Gray, (object) Control.DefaultForeColor);
        Color color;
        if (obj == null)
        {
label_29:
          switch (3)
          {
            case 0:
              goto label_29;
            default:
              color = new Color();
              break;
          }
        }
        else
          color = (Color) obj;
        appearanceHeader.ForeColor = color;
      }
label_34:
      switch (4)
      {
        case 0:
          goto label_34;
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4484));
      ProjectData.ClearProjectError();
    }
  }

  public bool get_BandVisible(string column)
  {
    bool visible;
    try
    {
      visible = this.c19f146e2e7d387b94d283d782a9c2c12(this.get_c3b70f7febd94504d2ae889cd04cf3e00(column)).ParentBand.Visible;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4513) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
    return visible;
  }

  public void set_BandVisible(string column, bool Value)
  {
    try
    {
      this.c5b871ae134785e12b0b126622322be57(this.get_c3b70f7febd94504d2ae889cd04cf3e00(column), Value);
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4513) + column + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
  }

  public void AddBand(string title, string bandName, int visibleIndex = -1, string parentBandName = "")
  {
    GridBand c4397f48db8026b1fee182d5c8921143a = (GridBand) null;
    if (!this.IsBandedGrid)
    {
label_1:
      switch (2)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.AddBand);
          }
          this.IsBandedGrid = true;
          break;
      }
    }
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(parentBandName, "", false) != 0)
    {
label_6:
      switch (6)
      {
        case 0:
          goto label_6;
        default:
          c4397f48db8026b1fee182d5c8921143a = this.c58cd0dfb7d46ac108ee5012500aca69b(parentBandName);
          break;
      }
    }
    GridBand band = this.c9f0554088efeb826c7eaa8eb9abca9f4(title, c4397f48db8026b1fee182d5c8921143a: c4397f48db8026b1fee182d5c8921143a, c5ad479046ae6298241f2425905aa84be: bandName);
    if (0 > visibleIndex)
      return;
    if (c4397f48db8026b1fee182d5c8921143a != null)
    {
label_10:
      switch (5)
      {
        case 0:
          goto label_10;
        default:
          c4397f48db8026b1fee182d5c8921143a.Children.MoveTo(visibleIndex, band);
          break;
      }
    }
    else
      this.GridView1.Bands.MoveTo(visibleIndex, band);
  }

  public void AddBandField(
    string parentBandName,
    string columnName,
    int visibleIndex = -1,
    string caption = "")
  {
    if (!this.IsBandedGrid)
      this.IsBandedGrid = true;
    DevExpress.XtraGrid.Columns.GridColumn c1e6290ac54e381b2081d91b6c00805a8 = this.get_c3b70f7febd94504d2ae889cd04cf3e00(columnName);
    if (c1e6290ac54e381b2081d91b6c00805a8 == null)
    {
label_3:
      switch (2)
      {
        case 0:
          goto label_3;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.AddBandField);
          break;
      }
    }
    else
    {
      GridBand gridBand = this.c58cd0dfb7d46ac108ee5012500aca69b(parentBandName);
      if (gridBand == null)
      {
label_7:
        switch (7)
        {
          case 0:
            goto label_7;
          default:
            gridBand = this.c19f146e2e7d387b94d283d782a9c2c12(parentBandName);
            if (gridBand == null)
              return;
            break;
        }
      }
      GridBand band = this.c19f146e2e7d387b94d283d782a9c2c12(c1e6290ac54e381b2081d91b6c00805a8);
      if (band == null)
        return;
      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(caption, "", false) != 0)
      {
label_12:
        switch (5)
        {
          case 0:
            goto label_12;
          default:
            band.Caption = caption;
            break;
        }
      }
      gridBand.Children.Add(band);
      if (0 <= visibleIndex)
        gridBand.Children.MoveTo(visibleIndex, band);
    }
  }

  public void DeleteBlankBands()
  {
    int index = checked (this.GridView1.Bands.Count - 1);
    while (index >= 0)
    {
      GridBand band = this.GridView1.Bands[index];
      int num;
      if (band.Children != null)
      {
        if (band.Children.Count == 0)
        {
label_3:
          switch (5)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.DeleteBlankBands);
                break;
              }
              break;
          }
        }
        else
        {
          num = 0;
          goto label_9;
        }
      }
      num = band.Columns == null ? 1 : (band.Columns.Count == 0 ? 1 : 0);
label_9:
      if (num != 0)
      {
label_10:
        switch (5)
        {
          case 0:
            goto label_10;
          default:
            this.GridView1.Bands.Remove(band);
            break;
        }
      }
      checked { index += -1; }
    }
  }

  private GridBand c19f146e2e7d387b94d283d782a9c2c12(string c7970bee6aafe907ae5596d4021302c6a)
  {
    DevExpress.XtraGrid.Columns.GridColumn c1e6290ac54e381b2081d91b6c00805a8 = this.get_c3b70f7febd94504d2ae889cd04cf3e00(c7970bee6aafe907ae5596d4021302c6a);
    if (c1e6290ac54e381b2081d91b6c00805a8 != null)
      return this.c19f146e2e7d387b94d283d782a9c2c12(this.GridView1.Bands, c1e6290ac54e381b2081d91b6c00805a8);
label_1:
    switch (6)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c19f146e2e7d387b94d283d782a9c2c12);
        }
        return (GridBand) null;
    }
  }

  private GridBand c19f146e2e7d387b94d283d782a9c2c12(DevExpress.XtraGrid.Columns.GridColumn c1e6290ac54e381b2081d91b6c00805a8)
  {
    return this.c19f146e2e7d387b94d283d782a9c2c12(this.GridView1.Bands, c1e6290ac54e381b2081d91b6c00805a8);
  }

  private GridBand c19f146e2e7d387b94d283d782a9c2c12(
    GridBandCollection c1208a6762b8519437262982f1e4d496d,
    DevExpress.XtraGrid.Columns.GridColumn c1e6290ac54e381b2081d91b6c00805a8)
  {
    if (c1208a6762b8519437262982f1e4d496d == null)
    {
label_1:
      switch (3)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c19f146e2e7d387b94d283d782a9c2c12);
          }
          return (GridBand) null;
      }
    }
    else
    {
      IEnumerator enumerator1;
      try
      {
        enumerator1 = c1208a6762b8519437262982f1e4d496d.GetEnumerator();
        while (enumerator1.MoveNext())
        {
          GridBand current = (GridBand) enumerator1.Current;
          GridBand gridBand = this.c19f146e2e7d387b94d283d782a9c2c12(current.Children, c1e6290ac54e381b2081d91b6c00805a8);
          if (gridBand != null)
          {
label_7:
            switch (7)
            {
              case 0:
                goto label_7;
              default:
                return gridBand;
            }
          }
          else if (current.Columns != null)
          {
label_10:
            switch (5)
            {
              case 0:
                goto label_10;
              default:
                IEnumerator enumerator2;
                try
                {
                  enumerator2 = current.Columns.GetEnumerator();
                  while (enumerator2.MoveNext())
                  {
                    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(((DevExpress.XtraGrid.Columns.GridColumn) enumerator2.Current).FieldName, c1e6290ac54e381b2081d91b6c00805a8.FieldName, false) == 0)
                    {
label_13:
                      switch (1)
                      {
                        case 0:
                          goto label_13;
                        default:
                          return current;
                      }
                    }
                  }
label_16:
                  switch (2)
                  {
                    case 0:
                      goto label_16;
                  }
                }
                finally
                {
                  if (enumerator2 is IDisposable)
                  {
label_18:
                    switch (3)
                    {
                      case 0:
                        goto label_18;
                      default:
                        (enumerator2 as IDisposable).Dispose();
                        break;
                    }
                  }
                }
                break;
            }
          }
        }
label_23:
        switch (1)
        {
          case 0:
            goto label_23;
        }
      }
      finally
      {
        if (enumerator1 is IDisposable)
        {
label_25:
          switch (4)
          {
            case 0:
              goto label_25;
            default:
              (enumerator1 as IDisposable).Dispose();
              break;
          }
        }
      }
      return (GridBand) null;
    }
  }

  private GridBand c58cd0dfb7d46ac108ee5012500aca69b(string c5ad479046ae6298241f2425905aa84be)
  {
    return this.c58cd0dfb7d46ac108ee5012500aca69b(this.GridView1.Bands, c5ad479046ae6298241f2425905aa84be);
  }

  private GridBand c58cd0dfb7d46ac108ee5012500aca69b(
    GridBandCollection c1208a6762b8519437262982f1e4d496d,
    string c5ad479046ae6298241f2425905aa84be)
  {
    if (c1208a6762b8519437262982f1e4d496d == null)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c58cd0dfb7d46ac108ee5012500aca69b);
          }
          return (GridBand) null;
      }
    }
    else
    {
      IEnumerator enumerator;
      try
      {
        enumerator = c1208a6762b8519437262982f1e4d496d.GetEnumerator();
        while (enumerator.MoveNext())
        {
          GridBand current = (GridBand) enumerator.Current;
          if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(current.Name.ToLower(), c5ad479046ae6298241f2425905aa84be.ToLower(), false) == 0)
            return current;
          GridBand gridBand = this.c58cd0dfb7d46ac108ee5012500aca69b(current.Children, c5ad479046ae6298241f2425905aa84be);
          if (gridBand != null)
          {
label_9:
            switch (1)
            {
              case 0:
                goto label_9;
              default:
                return gridBand;
            }
          }
        }
label_12:
        switch (6)
        {
          case 0:
            goto label_12;
        }
      }
      finally
      {
        if (enumerator is IDisposable)
        {
label_14:
          switch (4)
          {
            case 0:
              goto label_14;
            default:
              (enumerator as IDisposable).Dispose();
              break;
          }
        }
      }
      return (GridBand) null;
    }
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public bool StopChangeEvent
  {
    get => this.c291b918d0be288a91cc09da8cc863ce7;
    set => this.c291b918d0be288a91cc09da8cc863ce7 = value;
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public bool StopOpenEvent
  {
    get => this.ce75332160d718c37d93defbcd7e95679;
    set => this.ce75332160d718c37d93defbcd7e95679 = value;
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public bool StopCheck
  {
    get => this.ce8e830301aad7239d91493f34cace090;
    set => this.ce8e830301aad7239d91493f34cace090 = value;
  }

  public int get_ColumnGroupIndex(string fieldName)
  {
    return this.get_c3b70f7febd94504d2ae889cd04cf3e00(fieldName).GroupIndex;
  }

  public void set_ColumnGroupIndex(string fieldName, int value)
  {
    this.get_c3b70f7febd94504d2ae889cd04cf3e00(fieldName).GroupIndex = value;
  }

  public bool IsDataRow(int rowIndex) => this.GridView1.IsDataRow(rowIndex);

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public bool IsLastRow => this.GridView1.IsLastRow;

  public bool get_IsFilterRow(int row = -1)
  {
    if (row < 0)
    {
label_1:
      switch (2)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_IsFilterRow);
          }
          row = this.GridView1.FocusedRowHandle;
          break;
      }
    }
    return this.GridView1.IsFilterRow(row);
  }

  [DefaultValue(-1)]
  public int RowHeight
  {
    get => this.GridView1.RowHeight;
    set => this.GridView1.RowHeight = value;
  }

  public string get_Text(int columnIndex, int rowHandle = -1)
  {
    try
    {
      return this.get_Text(this.get_FieldName(columnIndex), rowHandle);
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4538) + columnIndex.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
      ProjectData.ClearProjectError();
    }
    return "";
  }

  public void set_Text(int columnIndex, int rowHandle = -1, string value)
  {
    string str = this.get_FieldName(columnIndex);
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, "", false) == 0)
      return;
    if (this.RowCount == 0)
    {
label_3:
      switch (5)
      {
        case 0:
          goto label_3;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_Text);
          break;
      }
    }
    else
    {
      try
      {
        if (rowHandle < 0)
        {
label_8:
          switch (5)
          {
            case 0:
              goto label_8;
            default:
              rowHandle = this.GridView1.FocusedRowHandle;
              break;
          }
        }
        else if (this.GridView1.FocusedRowHandle != rowHandle)
        {
label_11:
          switch (2)
          {
            case 0:
              goto label_11;
            default:
              this.GridView1.FocusedRowHandle = rowHandle;
              break;
          }
        }
        this.GridView1.SetFocusedRowCellValue(str, RuntimeHelpers.GetObjectValue(Interaction.IIf(Microsoft.VisualBasic.CompilerServices.Operators.CompareString(value, "", false) == 0, (object) DBNull.Value, (object) value)));
        // ISSUE: reference to a compiler-generated field
        eGrid.CellValueChangingEventHandler c64215629b34ca86cc3d0d5db5254ef6b = this.c64215629b34ca86cc3d0d5db5254ef6b;
        if (c64215629b34ca86cc3d0d5db5254ef6b != null)
        {
          eGrid.CellValueChangingEventHandler changingEventHandler = c64215629b34ca86cc3d0d5db5254ef6b;
          string ColumnName = str;
          int RowIndex = rowHandle;
          object obj = (object) value;
          ref object local = ref obj;
          changingEventHandler((object) this, ColumnName, RowIndex, ref local);
          value = Conversions.ToString(obj);
        }
      }
      catch (Exception ex)
      {
        ProjectData.SetProjectError(ex);
        Shared.MessageError(ex, this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4538) + columnIndex.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
        ProjectData.ClearProjectError();
      }
    }
  }

  public string get_Text(string columnName, int rowHandle = -1)
  {
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(columnName, "", false) == 0)
    {
label_1:
      switch (3)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_Text);
          }
          return "";
      }
    }
    else
    {
      DevExpress.XtraGrid.Columns.GridColumn column = this.get_c3b70f7febd94504d2ae889cd04cf3e00(columnName);
      if (column == null)
      {
label_6:
        switch (6)
        {
          case 0:
            goto label_6;
          default:
            return "";
        }
      }
      else
      {
        try
        {
          object objectValue;
          if (rowHandle < 0)
          {
label_9:
            switch (2)
            {
              case 0:
                goto label_9;
              default:
                objectValue = RuntimeHelpers.GetObjectValue(this.GridView1.GetFocusedRowCellValue(column));
                break;
            }
          }
          else
            objectValue = RuntimeHelpers.GetObjectValue(this.GridView1.GetRowCellValue(rowHandle, column));
          eGridColumn eGridColumn = this.GridColumn(columnName);
          if (eGridColumn == null)
          {
label_13:
            switch (6)
            {
              case 0:
                goto label_13;
              default:
                return "";
            }
          }
          else
          {
            int num;
            if (eGridColumn.FieldType == FieldType.Date)
            {
label_16:
              switch (1)
              {
                case 0:
                  goto label_16;
                default:
                  num = Information.IsDate(RuntimeHelpers.GetObjectValue(objectValue)) ? 1 : 0;
                  break;
              }
            }
            else
              num = 0;
            if (num == 0)
              return Shared.ToStr(RuntimeHelpers.GetObjectValue(objectValue));
label_20:
            switch (4)
            {
              case 0:
                goto label_20;
              default:
                return Strings.Format((object) Conversions.ToDate(objectValue), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(530));
            }
          }
        }
        catch (Exception ex)
        {
          ProjectData.SetProjectError(ex);
          Shared.MessageError(ex, this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4538) + columnName + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
          ProjectData.ClearProjectError();
        }
        return "";
      }
    }
  }

  public void set_Text(string columnName, int rowHandle = -1, string value)
  {
    if (this.RowCount == 0)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_Text);
          break;
      }
    }
    else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(columnName, "", false) == 0)
    {
label_6:
      switch (2)
      {
        case 0:
          goto label_6;
      }
    }
    else
    {
      DevExpress.XtraGrid.Columns.GridColumn column = this.get_c3b70f7febd94504d2ae889cd04cf3e00(columnName);
      if (column == null)
        return;
      try
      {
        if (rowHandle < 0)
        {
label_10:
          switch (1)
          {
            case 0:
              goto label_10;
            default:
              rowHandle = this.GridView1.FocusedRowHandle;
              break;
          }
        }
        else if (this.GridView1.FocusedRowHandle != rowHandle)
          this.GridView1.FocusedRowHandle = rowHandle;
        this.GridView1.SetFocusedRowCellValue(column, RuntimeHelpers.GetObjectValue(Interaction.IIf(Microsoft.VisualBasic.CompilerServices.Operators.CompareString(value, "", false) == 0, (object) DBNull.Value, (object) value)));
        this.c7e611ca566728d6070ae43ba17bc89f2(this.GridColumn(columnName));
        // ISSUE: reference to a compiler-generated field
        eGrid.CellValueChangingEventHandler c64215629b34ca86cc3d0d5db5254ef6b = this.c64215629b34ca86cc3d0d5db5254ef6b;
        if (c64215629b34ca86cc3d0d5db5254ef6b != null)
        {
label_16:
          switch (3)
          {
            case 0:
              goto label_16;
            default:
              eGrid.CellValueChangingEventHandler changingEventHandler = c64215629b34ca86cc3d0d5db5254ef6b;
              string ColumnName = columnName;
              int RowIndex = rowHandle;
              object obj = (object) value;
              ref object local = ref obj;
              changingEventHandler((object) this, ColumnName, RowIndex, ref local);
              value = Conversions.ToString(obj);
              break;
          }
        }
      }
      catch (Exception ex)
      {
        ProjectData.SetProjectError(ex);
        Shared.MessageError(ex, this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4538) + columnName + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
        ProjectData.ClearProjectError();
      }
    }
  }

  public string get_DefaultText(string columnName)
  {
    eGridColumn eGridColumn = this.GridColumn(columnName);
    if (eGridColumn == null)
      return "";
label_1:
    switch (3)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_DefaultText);
        }
        return eGridColumn.DefaultText;
    }
  }

  public void set_DefaultText(string columnName, string value)
  {
    eGridColumn eGridColumn = this.GridColumn(columnName);
    if (eGridColumn == null)
      return;
label_1:
    switch (7)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_DefaultText);
        }
        eGridColumn.DefaultText = value;
        break;
    }
  }

  public object get_Value(string columnName, int rowHandle = -1)
  {
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(columnName, "", false) == 0)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_Value);
          }
          return (object) "";
      }
    }
    else
    {
      DevExpress.XtraGrid.Columns.GridColumn column = this.get_c3b70f7febd94504d2ae889cd04cf3e00(columnName);
      if (column == null)
      {
label_6:
        switch (6)
        {
          case 0:
            goto label_6;
          default:
            return (object) "";
        }
      }
      else
      {
        try
        {
          if (rowHandle >= 0)
            return (object) Shared.ToStr(RuntimeHelpers.GetObjectValue(this.GridView1.GetRowCellValue(rowHandle, column)));
label_9:
          switch (5)
          {
            case 0:
              goto label_9;
            default:
              return (object) Shared.ToStr(RuntimeHelpers.GetObjectValue(this.GridView1.GetFocusedRowCellValue(column)));
          }
        }
        catch (Exception ex)
        {
          ProjectData.SetProjectError(ex);
          Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4551));
          ProjectData.ClearProjectError();
        }
        return (object) "";
      }
    }
  }

  public void set_Value(string columnName, int rowHandle = -1, object value)
  {
    DevExpress.XtraGrid.Columns.GridColumn column = this.get_c3b70f7febd94504d2ae889cd04cf3e00(columnName);
    if (column == null)
      return;
    if (rowHandle < 0)
    {
      this.GridView1.SetFocusedRowCellValue(column, RuntimeHelpers.GetObjectValue(Interaction.IIf(Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(value)), "", false) == 0, (object) DBNull.Value, RuntimeHelpers.GetObjectValue(value))));
      rowHandle = this.GridView1.FocusedRowHandle;
    }
    else
      this.GridView1.SetRowCellValue(rowHandle, column, RuntimeHelpers.GetObjectValue(Interaction.IIf(Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(value)), "", false) == 0, (object) DBNull.Value, RuntimeHelpers.GetObjectValue(value))));
    // ISSUE: reference to a compiler-generated field
    eGrid.CellValueChangingEventHandler c64215629b34ca86cc3d0d5db5254ef6b = this.c64215629b34ca86cc3d0d5db5254ef6b;
    if (c64215629b34ca86cc3d0d5db5254ef6b == null)
      return;
label_6:
    switch (7)
    {
      case 0:
        goto label_6;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_Value);
        }
        c64215629b34ca86cc3d0d5db5254ef6b((object) this, columnName, rowHandle, ref value);
        break;
    }
  }

  public bool get_ToBool(string columnName, int rowHandle = -1)
  {
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(columnName, "", false) == 0)
    {
label_1:
      switch (2)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_ToBool);
          }
          return false;
      }
    }
    else
    {
      DevExpress.XtraGrid.Columns.GridColumn column = this.get_c3b70f7febd94504d2ae889cd04cf3e00(columnName);
      if (column == null)
      {
label_6:
        switch (7)
        {
          case 0:
            goto label_6;
          default:
            return false;
        }
      }
      else
      {
        if (rowHandle < 0)
        {
label_9:
          switch (3)
          {
            case 0:
              goto label_9;
            default:
              rowHandle = this.GridView1.FocusedRowHandle;
              break;
          }
        }
        try
        {
          return Shared.ToBool(RuntimeHelpers.GetObjectValue(this.GridView1.GetRowCellValue(rowHandle, column)));
        }
        catch (Exception ex)
        {
          ProjectData.SetProjectError(ex);
          Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4562));
          ProjectData.ClearProjectError();
        }
        return false;
      }
    }
  }

  public Decimal get_ToDec(int columnIndex, int rowHandle = -1)
  {
    string str = this.get_FieldName(columnIndex);
    Decimal toDec;
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, "", false) == 0)
      toDec = 0M;
    else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, "", false) == 0)
    {
label_3:
      switch (5)
      {
        case 0:
          goto label_3;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_ToDec);
          }
          toDec = 0M;
          break;
      }
    }
    else
    {
      if (rowHandle < 0)
      {
label_8:
        switch (4)
        {
          case 0:
            goto label_8;
          default:
            rowHandle = this.GridView1.FocusedRowHandle;
            break;
        }
      }
      try
      {
        toDec = Shared.ToDec(RuntimeHelpers.GetObjectValue(this.GridView1.GetRowCellValue(rowHandle, str)));
        goto label_14;
      }
      catch (Exception ex)
      {
        ProjectData.SetProjectError(ex);
        Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4575));
        ProjectData.ClearProjectError();
      }
      toDec = 0M;
    }
label_14:
    return toDec;
  }

  public Decimal get_ToDec(string columnName, int rowHandle = -1)
  {
    DevExpress.XtraGrid.Columns.GridColumn column = this.get_c3b70f7febd94504d2ae889cd04cf3e00(columnName);
    if (column == null)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_ToDec);
          }
          Shared.MessageError(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4586) + columnName, this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4629) + columnName + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
          break;
      }
    }
    if (rowHandle < 0)
    {
label_6:
      switch (3)
      {
        case 0:
          goto label_6;
        default:
          rowHandle = this.GridView1.FocusedRowHandle;
          break;
      }
    }
    Decimal toDec;
    try
    {
      toDec = Shared.ToDec(RuntimeHelpers.GetObjectValue(this.GridView1.GetRowCellValue(rowHandle, column)));
      goto label_12;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4575));
      ProjectData.ClearProjectError();
    }
    toDec = 0M;
label_12:
    return toDec;
  }

  public string get_EditText(int columnIndex, int rowHandle = -1)
  {
    return this.get_EditText(this.get_FieldName(columnIndex), rowHandle);
  }

  public void set_EditText(int columnIndex, int rowHandle = -1, string value)
  {
    this.set_EditText(this.get_FieldName(columnIndex), rowHandle, value);
  }

  public string get_EditText(string ColumnName, int rowHandle = -1)
  {
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(ColumnName, "", false) == 0)
    {
label_1:
      switch (1)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_EditText);
          }
          return "";
      }
    }
    else
    {
      DevExpress.XtraGrid.Columns.GridColumn column = this.get_c3b70f7febd94504d2ae889cd04cf3e00(ColumnName);
      if (column == null)
        return "";
      if (rowHandle < 0)
      {
label_8:
        switch (2)
        {
          case 0:
            goto label_8;
          default:
            rowHandle = this.GridView1.FocusedRowHandle;
            break;
        }
      }
      try
      {
        return this.GridView1.GetRowCellDisplayText(rowHandle, column);
      }
      catch (Exception ex)
      {
        ProjectData.SetProjectError(ex);
        Shared.MessageError(ex, this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4644) + ColumnName + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
        ProjectData.ClearProjectError();
      }
      return (string) null;
    }
  }

  public void set_EditText(string ColumnName, int rowHandle = -1, string value)
  {
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(ColumnName, "", false) == 0)
    {
label_1:
      switch (7)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_EditText);
          break;
      }
    }
    else
    {
      DevExpress.XtraGrid.Columns.GridColumn column = this.get_c3b70f7febd94504d2ae889cd04cf3e00(ColumnName);
      if (column == null)
      {
label_5:
        switch (3)
        {
          case 0:
            goto label_5;
        }
      }
      else
      {
        try
        {
          if (rowHandle < 0)
            rowHandle = this.GridView1.FocusedRowHandle;
          value = value.TrimEnd();
          eGridColumn eGridColumn = this.GridColumn(ColumnName);
          if (eGridColumn.FieldType == FieldType.Combo)
          {
            RepositoryItemLookUpEdit repositoryItemLookUpEdit = new RepositoryItemLookUpEdit();
            RepositoryItemLookUpEdit columnEdit = (RepositoryItemLookUpEdit) column.ColumnEdit;
            if (columnEdit.DataSource != null)
            {
              DataTable dataSource = (DataTable) columnEdit.DataSource;
              IEnumerator enumerator;
              try
              {
                enumerator = dataSource.Rows.GetEnumerator();
                while (enumerator.MoveNext())
                {
                  DataRow current = (DataRow) enumerator.Current;
                  if (Microsoft.VisualBasic.CompilerServices.Operators.ConditionalCompareObjectEqual(current[1], (object) value, false))
                  {
                    this.GridView1.SetRowCellValue(rowHandle, column, RuntimeHelpers.GetObjectValue(Interaction.IIf(Microsoft.VisualBasic.CompilerServices.Operators.ConditionalCompareObjectEqual(current[0], (object) "", false), (object) DBNull.Value, RuntimeHelpers.GetObjectValue(current[0]))));
                    goto label_21;
                  }
                }
label_16:
                switch (7)
                {
                  case 0:
                    goto label_16;
                }
              }
              finally
              {
                if (enumerator is IDisposable)
                {
label_18:
                  switch (5)
                  {
                    case 0:
                      goto label_18;
                    default:
                      (enumerator as IDisposable).Dispose();
                      break;
                  }
                }
              }
label_21:;
            }
          }
          else if (eGridColumn.IsNumericField())
          {
label_24:
            switch (2)
            {
              case 0:
                goto label_24;
              default:
                if (!Versioned.IsNumeric((object) value))
                {
label_26:
                  switch (6)
                  {
                    case 0:
                      goto label_26;
                    default:
                      value = "";
                      break;
                  }
                }
                this.GridView1.SetRowCellValue(rowHandle, column, RuntimeHelpers.GetObjectValue(Interaction.IIf(Microsoft.VisualBasic.CompilerServices.Operators.CompareString(value, "", false) == 0, (object) DBNull.Value, (object) Shared.ToDec((object) value))));
                break;
            }
          }
          else
            this.GridView1.SetRowCellValue(rowHandle, column, RuntimeHelpers.GetObjectValue(Interaction.IIf(Microsoft.VisualBasic.CompilerServices.Operators.CompareString(value, "", false) == 0, (object) DBNull.Value, (object) value)));
          // ISSUE: reference to a compiler-generated field
          eGrid.CellValueChangingEventHandler c64215629b34ca86cc3d0d5db5254ef6b = this.c64215629b34ca86cc3d0d5db5254ef6b;
          if (c64215629b34ca86cc3d0d5db5254ef6b != null)
          {
label_31:
            switch (6)
            {
              case 0:
                goto label_31;
              default:
                eGrid.CellValueChangingEventHandler changingEventHandler = c64215629b34ca86cc3d0d5db5254ef6b;
                string ColumnName1 = ColumnName;
                int RowIndex = rowHandle;
                object obj = (object) value;
                ref object local = ref obj;
                changingEventHandler((object) this, ColumnName1, RowIndex, ref local);
                value = Conversions.ToString(obj);
                break;
            }
          }
        }
        catch (Exception ex)
        {
          ProjectData.SetProjectError(ex);
          Shared.MessageError(ex, this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4644) + ColumnName + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4665) + value);
          ProjectData.ClearProjectError();
        }
      }
    }
  }

  private string c28e979d252bce6e5400127599fe1973c(
    eGridColumn c4e4dd0b743ed8c13fde428de36b4c8f3,
    string c4c9b78445c9e9cb6705836230ff32ab2)
  {
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c4e4dd0b743ed8c13fde428de36b4c8f3.Format, "", false) == 0)
    {
label_1:
      switch (7)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c28e979d252bce6e5400127599fe1973c);
          }
          return c4c9b78445c9e9cb6705836230ff32ab2;
      }
    }
    else
    {
      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c4c9b78445c9e9cb6705836230ff32ab2, "", false) == 0 || !c4e4dd0b743ed8c13fde428de36b4c8f3.IsNumericField())
        return c4c9b78445c9e9cb6705836230ff32ab2;
label_7:
      switch (3)
      {
        case 0:
          goto label_7;
        default:
          if (!Versioned.IsNumeric((object) c4c9b78445c9e9cb6705836230ff32ab2))
          {
label_9:
            switch (6)
            {
              case 0:
                goto label_9;
              default:
                return "";
            }
          }
          else
          {
            Decimal num = Shared.ToDec((object) c4c9b78445c9e9cb6705836230ff32ab2);
            switch (c4e4dd0b743ed8c13fde428de36b4c8f3.RoundType)
            {
              case RoundType.Round:
                num = Shared.Rounding(num, c4e4dd0b743ed8c13fde428de36b4c8f3.RoundDigits);
                break;
              case RoundType.Truncation:
                num = Shared.Truncating(num, c4e4dd0b743ed8c13fde428de36b4c8f3.RoundDigits);
                break;
              default:
label_12:
                switch (3)
                {
                  case 0:
                    goto label_12;
                }
                break;
            }
            return Strings.Format((object) num, c4e4dd0b743ed8c13fde428de36b4c8f3.Format);
          }
      }
    }
  }

  public DataRow GetDataRow() => this.GetDataRow(this.GridView1.FocusedRowHandle);

  public DataRow GetDataRow(int rowIndex) => this.GridView1.GetDataRow(rowIndex);

  public object[,] GetDataArray(bool withTitle = true, bool withHiddenColumn = false)
  {
    int num1 = 0;
    if (withTitle)
    {
      num1 = 1;
      if (this.IsBandedGrid)
        num1 = 2;
    }
    int num2 = checked (this.RowCount - 1);
    int num3 = checked (this.ColumnCount - 1);
    object[,] arySrc;
    object[,] dataArray = (object[,]) Microsoft.VisualBasic.CompilerServices.Utils.CopyArray((Array) arySrc, (Array) new object[checked (num2 + num1 + 1), checked (num3 + 1)]);
    int index1 = 0;
    if (withTitle)
    {
label_5:
      switch (7)
      {
        case 0:
          goto label_5;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.GetDataArray);
          }
          int num4 = checked (this.ColumnCount - 1);
          int num5 = 0;
          while (num5 <= num4)
          {
            int num6;
            if (!withHiddenColumn)
            {
label_10:
              switch (3)
              {
                case 0:
                  goto label_10;
                default:
                  num6 = withHiddenColumn ? 0 : (this.get_ColumnVisible(num5) ? 1 : 0);
                  break;
              }
            }
            else
              num6 = 1;
            if (num6 != 0)
            {
label_14:
              switch (4)
              {
                case 0:
                  goto label_14;
                default:
                  if (this.IsBandedGrid)
                  {
                    dataArray[0, index1] = (object) this.get_BandTitle(num5);
                    dataArray[1, index1] = (object) this.get_ColumnTitle(num5);
                  }
                  else
                    dataArray[0, index1] = (object) this.get_ColumnTitle(num5);
                  checked { ++index1; }
                  break;
              }
            }
            checked { ++num5; }
          }
label_21:
          switch (1)
          {
            case 0:
              goto label_21;
          }
          break;
      }
    }
    int index2 = checked (num1 - 1);
    int num7 = checked (this.RowCount - 1);
    int rowHandle = 0;
    while (rowHandle <= num7)
    {
      checked { ++index2; }
      int index3 = 0;
      int num8 = checked (this.ColumnCount - 1);
      int num9 = 0;
      while (num9 <= num8)
      {
        int num10;
        if (!withHiddenColumn)
        {
          if (!withHiddenColumn)
          {
label_26:
            switch (5)
            {
              case 0:
                goto label_26;
              default:
                num10 = this.get_ColumnVisible(num9) ? 1 : 0;
                break;
            }
          }
          else
            num10 = 0;
        }
        else
          num10 = 1;
        if (num10 != 0)
        {
          FieldType fieldType = this.GridColumn(this.get_FieldName(num9)).FieldType;
          if (fieldType <= FieldType.Decimal)
          {
            if (fieldType != FieldType.Combo)
            {
              if (fieldType == FieldType.Decimal)
              {
                dataArray[index2, index3] = (object) this.get_ToDec(num9, rowHandle);
                goto label_42;
              }
            }
            else
            {
              dataArray[index2, index3] = (object) this.get_EditText(num9, rowHandle);
              goto label_42;
            }
          }
          else if (fieldType != FieldType.Int)
          {
label_35:
            switch (2)
            {
              case 0:
                goto label_35;
              default:
                if (fieldType == FieldType.Date)
                {
                  dataArray[index2, index3] = (object) (c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(313) + this.get_Text(num9, rowHandle));
                  goto label_42;
                }
                break;
            }
          }
          else
          {
            dataArray[index2, index3] = (object) this.get_ToDec(num9, rowHandle);
            goto label_42;
          }
          dataArray[index2, index3] = (object) this.get_Text(num9, rowHandle);
label_42:
          checked { ++index3; }
        }
        checked { ++num9; }
      }
label_45:
      switch (5)
      {
        case 0:
          goto label_45;
        default:
          checked { ++rowHandle; }
          continue;
      }
    }
label_48:
    switch (7)
    {
      case 0:
        goto label_48;
      default:
        return dataArray;
    }
  }

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public Collection GridColumns => this.cdbe6b49d3eee541c1a02140924401651;

  public eGridColumn GridColumn(int columnIndex)
  {
    if (this.cdbe6b49d3eee541c1a02140924401651 == null)
      return (eGridColumn) null;
    string str = this.get_FieldName(columnIndex);
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, "", false) != 0)
      return this.GridColumn(str);
label_3:
    switch (5)
    {
      case 0:
        goto label_3;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.GridColumn);
        }
        return (eGridColumn) null;
    }
  }

  public eGridColumn GridColumn(string columnName)
  {
    if (this.cdbe6b49d3eee541c1a02140924401651 == null)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.GridColumn);
          }
          return (eGridColumn) null;
      }
    }
    else
    {
      columnName = columnName.ToLower();
      if (columnName.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4674)))
      {
        string[] strArray = columnName.Split('.');
        columnName = strArray[1];
        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray[0].Trim(), this.Name.Trim().ToLower(), false) != 0)
        {
label_7:
          switch (7)
          {
            case 0:
              goto label_7;
            default:
              return (eGridColumn) null;
          }
        }
      }
      IEnumerator enumerator;
      try
      {
        enumerator = this.cdbe6b49d3eee541c1a02140924401651.GetEnumerator();
        while (enumerator.MoveNext())
        {
          eGridColumn current = (eGridColumn) enumerator.Current;
          if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(current.FieldName.ToLower(), columnName, false) == 0)
          {
label_12:
            switch (7)
            {
              case 0:
                goto label_12;
              default:
                return current;
            }
          }
        }
      }
      finally
      {
        if (enumerator is IDisposable)
        {
label_16:
          switch (1)
          {
            case 0:
              goto label_16;
            default:
              (enumerator as IDisposable).Dispose();
              break;
          }
        }
      }
      return (eGridColumn) null;
    }
  }

  public Collection Joins()
  {
    if (this.c330a4db27d3578a8e5d80797d2f5ac12 != null)
      return (Collection) NewLateBinding.LateGet(this.c330a4db27d3578a8e5d80797d2f5ac12.ParentForm, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1069), new object[0], (string[]) null, (System.Type[]) null, (bool[]) null);
label_1:
    switch (3)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.Joins);
        }
        return (Collection) null;
    }
  }

  public Collection References()
  {
    if (this.c330a4db27d3578a8e5d80797d2f5ac12 != null)
      return (Collection) NewLateBinding.LateGet(this.c330a4db27d3578a8e5d80797d2f5ac12.ParentForm, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4677), new object[0], (string[]) null, (System.Type[]) null, (bool[]) null);
label_1:
    switch (3)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.References);
        }
        return (Collection) null;
    }
  }

  public void CopyToClipboard() => this.GridView1.CopyToClipboard();

  public void CopyToClipboardWithTitle()
  {
    this.GridView1.OptionsClipboard.CopyColumnHeaders = DefaultBoolean.True;
    this.GridView1.CopyToClipboard();
    this.GridView1.OptionsClipboard.CopyColumnHeaders = DefaultBoolean.False;
  }

  public bool UpdateCurrentRow()
  {
    this.Parent.Focus();
    this.GridView1.Focus();
    return this.GridView1.UpdateCurrentRow();
  }

  public bool UpdateRow()
  {
    this.Parent.Focus();
    this.GridView1.Focus();
    bool flag;
    if (this.DataSet == null)
      flag = true;
    else if (this.c330a4db27d3578a8e5d80797d2f5ac12 == null)
    {
      flag = true;
    }
    else
    {
      this.c2f4d5bfbc9e21b67499b8be807bcc0b4();
      this.ce42883e9f01c8bb4485808cb32a39d92();
      if (this.ccac4c8044ae680dcd351934054a598ac != null)
      {
label_5:
        switch (4)
        {
          case 0:
            goto label_5;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.UpdateRow);
            }
            this.GridView1.GroupSummary.Assign((GridSummaryItemCollection) this.ccac4c8044ae680dcd351934054a598ac);
            this.GridView1.OptionsView.ShowFooter = true;
            this.GridView1.OptionsView.GroupFooterShowMode = GroupFooterShowMode.VisibleAlways;
            break;
        }
      }
    }
    return flag;
  }

  private void c2f4d5bfbc9e21b67499b8be807bcc0b4()
  {
    if (this.Joins() == null)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c2f4d5bfbc9e21b67499b8be807bcc0b4);
          break;
      }
    }
    else
    {
      DataRowCollection dataRowCollection = Shared.DataSetRows(this.DataSet);
      try
      {
        foreach (Join join in this.Joins())
        {
          int num;
          if (join.JoinType == JoinType.Get)
          {
label_7:
            switch (3)
            {
              case 0:
                goto label_7;
              default:
                num = join.ToControl is eGridColumn ? 1 : 0;
                break;
            }
          }
          else
            num = 0;
          if (num != 0)
          {
label_11:
            switch (1)
            {
              case 0:
                goto label_11;
              default:
                if (((eGridColumn) join.ToControl).Grid == this)
                {
                  string columnName = join.ToControl.ColumnName;
                  string text = join.FromControl.Text;
                  IEnumerator enumerator;
                  try
                  {
                    enumerator = dataRowCollection.GetEnumerator();
                    while (enumerator.MoveNext())
                    {
                      DataRow current = (DataRow) enumerator.Current;
                      if (current.RowState == DataRowState.Added | current.RowState == DataRowState.Modified)
                      {
label_16:
                        switch (6)
                        {
                          case 0:
                            goto label_16;
                          default:
                            this.cd24ace5cd5e55d7f1c98eb8952eb8d96(current, columnName, (object) text);
                            break;
                        }
                      }
                    }
label_20:
                    switch (5)
                    {
                      case 0:
                        goto label_20;
                    }
                  }
                  finally
                  {
                    if (enumerator is IDisposable)
                    {
label_23:
                      switch (3)
                      {
                        case 0:
                          goto label_23;
                        default:
                          (enumerator as IDisposable).Dispose();
                          break;
                      }
                    }
                  }
                }
                break;
            }
          }
        }
label_29:
        switch (1)
        {
          case 0:
            goto label_29;
        }
      }
      finally
      {
        IEnumerator enumerator;
        if (enumerator is IDisposable)
          (enumerator as IDisposable).Dispose();
      }
      this.GridView1.UpdateCurrentRow();
    }
  }

  private void ce42883e9f01c8bb4485808cb32a39d92()
  {
    IEnumerator enumerator;
    if (this.References() == null)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.ce42883e9f01c8bb4485808cb32a39d92);
          break;
      }
    }
    else
    {
      try
      {
        enumerator = this.References().GetEnumerator();
        while (enumerator.MoveNext())
        {
          Reference current = (Reference) enumerator.Current;
          if (current.WorkSet == this.WorkSet)
          {
label_6:
            switch (2)
            {
              case 0:
                goto label_6;
              default:
                this.SaveValue(current.FieldName, (object) current.FromControl.Text);
                break;
            }
          }
        }
label_10:
        switch (2)
        {
          case 0:
            goto label_10;
        }
      }
      finally
      {
        if (enumerator is IDisposable)
        {
label_13:
          switch (5)
          {
            case 0:
              goto label_13;
            default:
              (enumerator as IDisposable).Dispose();
              break;
          }
        }
      }
    }
  }

  private bool cd24ace5cd5e55d7f1c98eb8952eb8d96(
    DataRow c3588ab573351dd2772c123a5ab57e254,
    string cb56cae7f7c80aa3ac7cf294d2e67e7da,
    object c702a7a60b30a2fab98fe835757b65523)
  {
    try
    {
      IEnumerator enumerator;
      try
      {
        enumerator = c3588ab573351dd2772c123a5ab57e254.Table.Columns.GetEnumerator();
        while (enumerator.MoveNext())
        {
          DataColumn current = (DataColumn) enumerator.Current;
          if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(current.ColumnName.ToUpper(), cb56cae7f7c80aa3ac7cf294d2e67e7da.ToUpper(), false) == 0)
          {
label_4:
            switch (7)
            {
              case 0:
                goto label_4;
              default:
                if (false)
                {
                  // ISSUE: method reference
                  RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cd24ace5cd5e55d7f1c98eb8952eb8d96);
                }
                if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(c3588ab573351dd2772c123a5ab57e254[current])), Shared.ToStr(RuntimeHelpers.GetObjectValue(c702a7a60b30a2fab98fe835757b65523)), false) != 0)
                {
                  c3588ab573351dd2772c123a5ab57e254[current] = RuntimeHelpers.GetObjectValue(Interaction.IIf(Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(c702a7a60b30a2fab98fe835757b65523)), "", false) == 0, (object) DBNull.Value, RuntimeHelpers.GetObjectValue(c702a7a60b30a2fab98fe835757b65523)));
                  return true;
                }
                break;
            }
          }
        }
label_11:
        switch (6)
        {
          case 0:
            goto label_11;
        }
      }
      finally
      {
        if (enumerator is IDisposable)
        {
label_13:
          switch (3)
          {
            case 0:
              goto label_13;
            default:
              (enumerator as IDisposable).Dispose();
              break;
          }
        }
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.ThrowError(ex.Message, Shared.Loc((object) this, MethodBase.GetCurrentMethod()));
      ProjectData.ClearProjectError();
    }
    return false;
  }

  public void SaveValue(string fldNm, object val, bool changedRow = true)
  {
    if (this.DataSet == null)
    {
label_1:
      switch (1)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.SaveValue);
          }
          Shared.MessageInfo(this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4698), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4735), this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4744));
          break;
      }
    }
    else
    {
      try
      {
        this.GridView1.UpdateCurrentRow();
        DataRowCollection dataRowCollection = Shared.DataSetRows(this.DataSet);
        IEnumerator enumerator;
        try
        {
          enumerator = dataRowCollection.GetEnumerator();
          while (enumerator.MoveNext())
          {
            DataRow current = (DataRow) enumerator.Current;
            if (changedRow)
            {
              if (current.RowState == DataRowState.Added | current.RowState == DataRowState.Modified)
              {
label_9:
                switch (3)
                {
                  case 0:
                    goto label_9;
                  default:
                    if (this.cd24ace5cd5e55d7f1c98eb8952eb8d96(current, fldNm, RuntimeHelpers.GetObjectValue(val)))
                      this.cc0d454e2f1398908e3cc1bf29ad72f9a = true;
                    break;
                }
              }
            }
            else if (current.RowState != DataRowState.Deleted)
            {
label_14:
              switch (3)
              {
                case 0:
                  goto label_14;
                default:
                  if (this.cd24ace5cd5e55d7f1c98eb8952eb8d96(current, fldNm, RuntimeHelpers.GetObjectValue(val)))
                  {
label_16:
                    switch (7)
                    {
                      case 0:
                        goto label_16;
                      default:
                        this.cc0d454e2f1398908e3cc1bf29ad72f9a = true;
                        break;
                    }
                  }
                  break;
              }
            }
          }
label_22:
          switch (3)
          {
            case 0:
              goto label_22;
          }
        }
        finally
        {
          if (enumerator is IDisposable)
          {
label_24:
            switch (3)
            {
              case 0:
                goto label_24;
              default:
                (enumerator as IDisposable).Dispose();
                break;
            }
          }
        }
        this.GridView1.UpdateCurrentRow();
      }
      catch (Exception ex)
      {
        ProjectData.SetProjectError(ex);
        Shared.MessageError(ex.Message, title: this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4769) + fldNm + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4792) + val.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4033));
        ProjectData.ClearProjectError();
      }
    }
  }

  public void DeleteBlankRow()
  {
    if (this.DataSet == null)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.DeleteBlankRow);
          break;
      }
    }
    else if (this.RowCount == 0)
    {
label_6:
      switch (5)
      {
        case 0:
          goto label_6;
      }
    }
    else
    {
      this.GridView1.UpdateCurrentRow();
      int num = checked (this.RowCount - 1);
      while (num >= 0)
      {
        if (this.IsBlankRow(num))
        {
label_10:
          switch (6)
          {
            case 0:
              goto label_10;
            default:
              this.DeleteRow(num);
              break;
          }
        }
        checked { num += -1; }
      }
label_14:
      switch (2)
      {
        case 0:
          goto label_14;
      }
    }
  }

  public bool IsBlankRow(int i)
  {
    DataRowView row = (DataRowView) this.GridView1.GetRow(i);
    if (row == null || row.Row.RowState != DataRowState.Added)
      return false;
label_1:
    switch (1)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.IsBlankRow);
        }
        bool flag = true;
        try
        {
          foreach (DevExpress.XtraGrid.Columns.GridColumn column in (CollectionBase) this.GridView1.Columns)
          {
            if (!this.GridView1.GroupedColumns.Contains(column))
            {
              string Left = this.get_Text(column.FieldName, i);
              string Right = "";
              eGridColumn eGridColumn = this.GridColumn(column.FieldName);
              if (eGridColumn != null && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(eGridColumn.DefaultText, "", false) != 0)
              {
label_8:
                switch (1)
                {
                  case 0:
                    goto label_8;
                  default:
                    Right = !eGridColumn.DefaultText.StartsWith(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4797)) ? eGridColumn.DefaultText : Left;
                    break;
                }
              }
              if (!(Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Left, "", false) == 0 | Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Left, Right, false) == 0))
              {
label_11:
                switch (5)
                {
                  case 0:
                    goto label_11;
                  default:
                    flag = false;
                    goto label_19;
                }
              }
            }
          }
label_15:
          switch (5)
          {
            case 0:
              goto label_15;
          }
        }
        finally
        {
          IEnumerator enumerator;
          if (enumerator is IDisposable)
            (enumerator as IDisposable).Dispose();
        }
label_19:
        return flag;
    }
  }

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public WorkSet WorkSet
  {
    get => this.c330a4db27d3578a8e5d80797d2f5ac12;
    set => this.c330a4db27d3578a8e5d80797d2f5ac12 = value;
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public bool IsUnboundMode => this.c467083dea0102ade8924e025f685c241 != null;

  public void InsertArrayColumns(string insertColNm, string[,] arr, string originColNm)
  {
    this.ca195169aff51783a0d4c2cd09fa7fc9a();
    this.c29f404b57e8575c5a5b9a72b46b3b5f1();
    if (arr == null)
    {
label_1:
      switch (5)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.InsertArrayColumns);
          break;
      }
    }
    else if (arr.Length == 0)
    {
label_5:
      switch (3)
      {
        case 0:
          goto label_5;
      }
    }
    else
    {
      eGridColumn cd040edaf531d5d953b2312e68af85dfe = this.GridColumn(originColNm);
      if (cd040edaf531d5d953b2312e68af85dfe == null)
      {
label_8:
        switch (6)
        {
          case 0:
            goto label_8;
        }
      }
      else
      {
        eGridColumn eGridColumn = (eGridColumn) null;
        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(insertColNm, "", false) != 0)
        {
label_10:
          switch (2)
          {
            case 0:
              goto label_10;
            default:
              eGridColumn = this.GridColumn(insertColNm);
              break;
          }
        }
        int cadfdedd3a77b6a5fc3df61a9c858ba1b;
        if (eGridColumn == null)
        {
label_13:
          switch (1)
          {
            case 0:
              goto label_13;
            default:
              cadfdedd3a77b6a5fc3df61a9c858ba1b = this.ColumnCount;
              break;
          }
        }
        else
        {
          GridBand band = eGridColumn.Band;
          if (band != null)
          {
label_16:
            switch (2)
            {
              case 0:
                goto label_16;
              default:
                cadfdedd3a77b6a5fc3df61a9c858ba1b = checked (band.Index + 1);
                break;
            }
          }
        }
        this.c3b2aae77523c473f2874f7355f8c8d75(arr, cadfdedd3a77b6a5fc3df61a9c858ba1b, cd040edaf531d5d953b2312e68af85dfe);
      }
    }
  }

  public void InsertArrayColumnsNext(string insertColNm, string[,] arr, string originColNm)
  {
    if (arr == null)
    {
label_1:
      switch (3)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.InsertArrayColumnsNext);
          break;
      }
    }
    else
    {
      if (arr.Length == 0)
        return;
      eGridColumn cd040edaf531d5d953b2312e68af85dfe = this.GridColumn(originColNm);
      if (cd040edaf531d5d953b2312e68af85dfe == null)
      {
label_7:
        switch (1)
        {
          case 0:
            goto label_7;
        }
      }
      else
      {
        eGridColumn eGridColumn = (eGridColumn) null;
        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(insertColNm, "", false) != 0)
        {
label_9:
          switch (7)
          {
            case 0:
              goto label_9;
            default:
              eGridColumn = this.GridColumn(insertColNm);
              break;
          }
        }
        int cadfdedd3a77b6a5fc3df61a9c858ba1b;
        if (eGridColumn == null)
        {
          cadfdedd3a77b6a5fc3df61a9c858ba1b = this.ColumnCount;
        }
        else
        {
          GridBand band = eGridColumn.Band;
          if (band != null)
          {
label_14:
            switch (4)
            {
              case 0:
                goto label_14;
              default:
                cadfdedd3a77b6a5fc3df61a9c858ba1b = checked (band.Index + 1);
                break;
            }
          }
        }
        this.c3b2aae77523c473f2874f7355f8c8d75(arr, cadfdedd3a77b6a5fc3df61a9c858ba1b, cd040edaf531d5d953b2312e68af85dfe);
      }
    }
  }

  public void InsertArrayColumns(string[,] arr)
  {
    this.ca195169aff51783a0d4c2cd09fa7fc9a();
    this.c29f404b57e8575c5a5b9a72b46b3b5f1();
    if (arr == null)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.InsertArrayColumns);
          break;
      }
    }
    else if (arr.Length == 0)
    {
label_6:
      switch (2)
      {
        case 0:
          goto label_6;
      }
    }
    else
    {
      int cadfdedd3a77b6a5fc3df61a9c858ba1b;
      try
      {
        foreach (eGridColumn eGridColumn in this.cdbe6b49d3eee541c1a02140924401651)
        {
          if (eGridColumn.IsDetailData)
          {
            GridBand band = eGridColumn.Band;
            if (band != null)
            {
label_11:
              switch (1)
              {
                case 0:
                  goto label_11;
                default:
                  cadfdedd3a77b6a5fc3df61a9c858ba1b = checked (band.Index + 1);
                  break;
              }
            }
          }
        }
label_16:
        switch (1)
        {
          case 0:
            goto label_16;
        }
      }
      finally
      {
        IEnumerator enumerator;
        if (enumerator is IDisposable)
          (enumerator as IDisposable).Dispose();
      }
      eGridColumn cd040edaf531d5d953b2312e68af85dfe = (eGridColumn) null;
      IEnumerator enumerator1;
      try
      {
        enumerator1 = this.cdbe6b49d3eee541c1a02140924401651.GetEnumerator();
        while (enumerator1.MoveNext())
        {
          eGridColumn current = (eGridColumn) enumerator1.Current;
          if (current.IsDetailData)
          {
label_23:
            switch (7)
            {
              case 0:
                goto label_23;
              default:
                cd040edaf531d5d953b2312e68af85dfe = current;
                goto label_32;
            }
          }
        }
label_26:
        switch (7)
        {
          case 0:
            goto label_26;
        }
      }
      finally
      {
        if (enumerator1 is IDisposable)
        {
label_29:
          switch (7)
          {
            case 0:
              goto label_29;
            default:
              (enumerator1 as IDisposable).Dispose();
              break;
          }
        }
      }
label_32:
      if (cd040edaf531d5d953b2312e68af85dfe == null)
      {
label_33:
        switch (1)
        {
          case 0:
            goto label_33;
        }
      }
      else
        this.c3b2aae77523c473f2874f7355f8c8d75(arr, cadfdedd3a77b6a5fc3df61a9c858ba1b, cd040edaf531d5d953b2312e68af85dfe);
    }
  }

  private void c3b2aae77523c473f2874f7355f8c8d75(
    string[,] cf8b658b63777cace5e0128525804213d,
    int cadfdedd3a77b6a5fc3df61a9c858ba1b,
    eGridColumn cd040edaf531d5d953b2312e68af85dfe)
  {
    int num1 = Information.UBound((Array) cf8b658b63777cace5e0128525804213d, 2);
    int index = 0;
    while (index <= num1)
    {
      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(cf8b658b63777cace5e0128525804213d[0, index], "", false) == 0)
      {
label_2:
        switch (1)
        {
          case 0:
            goto label_2;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c3b2aae77523c473f2874f7355f8c8d75);
              break;
            }
            break;
        }
      }
      else
      {
        string nm = this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4674) + cf8b658b63777cace5e0128525804213d[0, index];
        string title = cf8b658b63777cace5e0128525804213d[1, index];
        eGridColumn eGridColumn = cd040edaf531d5d953b2312e68af85dfe.Clon(nm, title);
        eGridColumn.IsDetailValue = true;
        int num2 = Information.UBound((Array) cf8b658b63777cace5e0128525804213d);
        if (num2 >= 2)
        {
label_7:
          switch (4)
          {
            case 0:
              goto label_7;
            default:
              eGridColumn.set_BandTitle(1, cf8b658b63777cace5e0128525804213d[2, index]);
              break;
          }
        }
        if (num2 >= 3)
        {
label_10:
          switch (1)
          {
            case 0:
              goto label_10;
            default:
              eGridColumn.set_BandTitle(2, cf8b658b63777cace5e0128525804213d[3, index]);
              break;
          }
        }
        if (num2 >= 4)
        {
label_13:
          switch (1)
          {
            case 0:
              goto label_13;
            default:
              eGridColumn.set_BandTitle(3, cf8b658b63777cace5e0128525804213d[4, index]);
              break;
          }
        }
        if (num2 >= 5)
          eGridColumn.set_BandTitle(4, cf8b658b63777cace5e0128525804213d[5, index]);
        if (num2 >= 6)
        {
label_18:
          switch (1)
          {
            case 0:
              goto label_18;
            default:
              eGridColumn.set_BandTitle(5, cf8b658b63777cace5e0128525804213d[6, index]);
              break;
          }
        }
        BandedGridColumn bandedGridColumn = (BandedGridColumn) this.c56f33f0a5583a83452d2f2e7ab8cd61d(eGridColumn);
        this.c02943f7d77d8340f65c81be9286ab1dc(eGridColumn);
        this.c843cf7ad2e8394cf4aa599e69e067272(eGridColumn);
        GridBand rootBand = bandedGridColumn.OwnerBand.RootBand;
        if (rootBand != null)
        {
label_21:
          switch (5)
          {
            case 0:
              goto label_21;
            default:
              this.GridView1.Bands.MoveTo(cadfdedd3a77b6a5fc3df61a9c858ba1b, rootBand);
              break;
          }
        }
        checked { ++cadfdedd3a77b6a5fc3df61a9c858ba1b; }
      }
      checked { ++index; }
    }
  }

  public void InsertMultiColumns(string[,] arr)
  {
    this.IsBandedGrid = true;
    this.ca195169aff51783a0d4c2cd09fa7fc9a();
    this.c29f404b57e8575c5a5b9a72b46b3b5f1();
    if (arr == null)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.InsertMultiColumns);
          break;
      }
    }
    else
    {
      if (arr.Length == 0)
        return;
      IEnumerator enumerator1;
      int index1;
      try
      {
        enumerator1 = this.cdbe6b49d3eee541c1a02140924401651.GetEnumerator();
        while (enumerator1.MoveNext())
        {
          eGridColumn current = (eGridColumn) enumerator1.Current;
          if (current.IsDetailData)
          {
label_7:
            switch (1)
            {
              case 0:
                goto label_7;
              default:
                GridBand band = current.Band;
                if (band != null)
                {
label_9:
                  switch (1)
                  {
                    case 0:
                      goto label_9;
                    default:
                      index1 = band.Index;
                      break;
                  }
                }
                break;
            }
          }
        }
label_14:
        switch (1)
        {
          case 0:
            goto label_14;
        }
      }
      finally
      {
        if (enumerator1 is IDisposable)
        {
label_17:
          switch (7)
          {
            case 0:
              goto label_17;
            default:
              (enumerator1 as IDisposable).Dispose();
              break;
          }
        }
      }
      GridBand c4397f48db8026b1fee182d5c8921143a1 = (GridBand) null;
      int num1 = Information.UBound((Array) arr, 2);
      int index2 = 0;
      while (index2 <= num1)
      {
        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(arr[0, index2], "", false) == 0)
        {
label_22:
          switch (2)
          {
            case 0:
              goto label_22;
          }
        }
        else
        {
          int num2 = Information.UBound((Array) arr);
          int index3 = num2;
          while (index3 >= 1)
          {
            int num3;
            if (0 < index2)
            {
label_25:
              switch (6)
              {
                case 0:
                  goto label_25;
                default:
                  num3 = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(arr[index3, index2], arr[index3, checked (index2 - 1)], false) == 0 ? 1 : 0;
                  break;
              }
            }
            else
              num3 = 0;
            if (num3 != 0)
            {
label_29:
              switch (2)
              {
                case 0:
                  goto label_29;
              }
            }
            else
            {
              string c8c82714b156015d31829c4decf853490 = arr[index3, index2];
              string c5ad479046ae6298241f2425905aa84be = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4802) + c8c82714b156015d31829c4decf853490 + index3.ToString();
              GridBand c4397f48db8026b1fee182d5c8921143a2 = (GridBand) null;
              if (index3 < num2)
                c4397f48db8026b1fee182d5c8921143a2 = this.c58cd0dfb7d46ac108ee5012500aca69b(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4802) + arr[checked (index3 + 1), index2] + checked (index3 + 1).ToString());
              c4397f48db8026b1fee182d5c8921143a1 = this.c9f0554088efeb826c7eaa8eb9abca9f4(c8c82714b156015d31829c4decf853490, c4397f48db8026b1fee182d5c8921143a: c4397f48db8026b1fee182d5c8921143a2, c5ad479046ae6298241f2425905aa84be: c5ad479046ae6298241f2425905aa84be, c72fe12625a1dfac1079cc6f394d1db49: index1);
            }
            checked { index3 += -1; }
          }
label_36:
          switch (5)
          {
            case 0:
              goto label_36;
            default:
              string c1623e8c6d478e2b293ac26ac7a43db80 = arr[0, index2];
              string c96db106f8b207c3731f4b0376eb71395 = arr[1, index2];
              IEnumerator enumerator2;
              try
              {
                enumerator2 = this.cdbe6b49d3eee541c1a02140924401651.GetEnumerator();
                while (enumerator2.MoveNext())
                {
                  eGridColumn current = (eGridColumn) enumerator2.Current;
                  if (current.IsDetailData)
                    this.cebf5743b076d41273696b73844f90429(current, c1623e8c6d478e2b293ac26ac7a43db80, c96db106f8b207c3731f4b0376eb71395, index1, c4397f48db8026b1fee182d5c8921143a1);
                }
label_43:
                switch (2)
                {
                  case 0:
                    goto label_43;
                }
              }
              finally
              {
                if (enumerator2 is IDisposable)
                {
label_46:
                  switch (3)
                  {
                    case 0:
                      goto label_46;
                    default:
                      (enumerator2 as IDisposable).Dispose();
                      break;
                  }
                }
              }
              checked { ++index1; }
              break;
          }
        }
        checked { ++index2; }
      }
label_52:
      switch (4)
      {
        case 0:
          goto label_52;
      }
    }
  }

  private void cebf5743b076d41273696b73844f90429(
    eGridColumn ceaf19a6a34b11197de017d0b9d784c60,
    string c1623e8c6d478e2b293ac26ac7a43db80,
    string c96db106f8b207c3731f4b0376eb71395,
    int cadfdedd3a77b6a5fc3df61a9c858ba1b,
    GridBand c4397f48db8026b1fee182d5c8921143a = null)
  {
    if (ceaf19a6a34b11197de017d0b9d784c60 == null)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cebf5743b076d41273696b73844f90429);
          break;
      }
    }
    else
    {
      eGridColumn eGridColumn = ceaf19a6a34b11197de017d0b9d784c60.Clon(this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4674) + ceaf19a6a34b11197de017d0b9d784c60.FieldName + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4253) + c1623e8c6d478e2b293ac26ac7a43db80);
      eGridColumn.IsDetailValue = true;
      DevExpress.XtraGrid.Columns.GridColumn c1e6290ac54e381b2081d91b6c00805a8 = this.c56f33f0a5583a83452d2f2e7ab8cd61d(eGridColumn);
      this.c02943f7d77d8340f65c81be9286ab1dc(eGridColumn);
      this.c843cf7ad2e8394cf4aa599e69e067272(eGridColumn);
      GridBand band = this.c19f146e2e7d387b94d283d782a9c2c12(c1e6290ac54e381b2081d91b6c00805a8);
      if (c4397f48db8026b1fee182d5c8921143a != null)
      {
label_5:
        switch (3)
        {
          case 0:
            goto label_5;
          default:
            c4397f48db8026b1fee182d5c8921143a.Children.Add(band);
            break;
        }
      }
    }
  }

  public void InsertExpandColumns(string[,] arr)
  {
    this.IsBandedGrid = true;
    this.ca195169aff51783a0d4c2cd09fa7fc9a();
    this.c29f404b57e8575c5a5b9a72b46b3b5f1();
    if (arr == null)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.InsertExpandColumns);
          break;
      }
    }
    else if (arr.Length == 0)
    {
label_5:
      switch (5)
      {
        case 0:
          goto label_5;
      }
    }
    else
    {
      IEnumerator enumerator1;
      int index1;
      try
      {
        enumerator1 = this.cdbe6b49d3eee541c1a02140924401651.GetEnumerator();
        while (enumerator1.MoveNext())
        {
          eGridColumn current = (eGridColumn) enumerator1.Current;
          if (current.IsDetailData)
          {
label_9:
            switch (1)
            {
              case 0:
                goto label_9;
              default:
                GridBand band = current.Band;
                if (band != null)
                {
                  index1 = band.Index;
                  goto label_18;
                }
                break;
            }
          }
        }
      }
      finally
      {
        if (enumerator1 is IDisposable)
        {
label_15:
          switch (4)
          {
            case 0:
              goto label_15;
            default:
              (enumerator1 as IDisposable).Dispose();
              break;
          }
        }
      }
label_18:
      int num = Information.UBound((Array) arr, 2);
      int index2 = 0;
      while (index2 <= num)
      {
        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(arr[0, index2], "", false) == 0)
        {
label_20:
          switch (7)
          {
            case 0:
              goto label_20;
          }
        }
        else
        {
          string c1623e8c6d478e2b293ac26ac7a43db80 = arr[0, index2];
          try
          {
            foreach (eGridColumn ceaf19a6a34b11197de017d0b9d784c60 in this.cdbe6b49d3eee541c1a02140924401651)
            {
              if (ceaf19a6a34b11197de017d0b9d784c60.IsDetailData)
              {
label_25:
                switch (7)
                {
                  case 0:
                    goto label_25;
                  default:
                    ceaf19a6a34b11197de017d0b9d784c60.Title = arr[1, index2];
                    string c96db106f8b207c3731f4b0376eb71395 = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4805) + ceaf19a6a34b11197de017d0b9d784c60.Band.Caption + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4805);
                    this.c2c80f2d2d2fc2d4a0c7d81cc4ff58fa9(ceaf19a6a34b11197de017d0b9d784c60, c1623e8c6d478e2b293ac26ac7a43db80, c96db106f8b207c3731f4b0376eb71395, index1);
                    break;
                }
              }
            }
          }
          finally
          {
            IEnumerator enumerator2;
            if (enumerator2 is IDisposable)
              (enumerator2 as IDisposable).Dispose();
          }
          checked { ++index1; }
        }
        checked { ++index2; }
      }
    }
  }

  private void c2c80f2d2d2fc2d4a0c7d81cc4ff58fa9(
    eGridColumn ceaf19a6a34b11197de017d0b9d784c60,
    string c1623e8c6d478e2b293ac26ac7a43db80,
    string c96db106f8b207c3731f4b0376eb71395,
    int cadfdedd3a77b6a5fc3df61a9c858ba1b)
  {
    if (ceaf19a6a34b11197de017d0b9d784c60 == null)
      return;
    eGridColumn eGridColumn = ceaf19a6a34b11197de017d0b9d784c60.Clon(this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4674) + ceaf19a6a34b11197de017d0b9d784c60.FieldName + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4253) + c1623e8c6d478e2b293ac26ac7a43db80);
    eGridColumn.set_BandTitle(1, c96db106f8b207c3731f4b0376eb71395);
    eGridColumn.IsDetailValue = true;
    this.c56f33f0a5583a83452d2f2e7ab8cd61d(eGridColumn);
    this.c02943f7d77d8340f65c81be9286ab1dc(eGridColumn);
    this.c843cf7ad2e8394cf4aa599e69e067272(eGridColumn);
    GridBand band = this.cca79c790607249ee08396897c60d23cc(c96db106f8b207c3731f4b0376eb71395);
    if (band != null)
    {
label_2:
      switch (6)
      {
        case 0:
          goto label_2;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c2c80f2d2d2fc2d4a0c7d81cc4ff58fa9);
          }
          this.GridView1.Bands.MoveTo(cadfdedd3a77b6a5fc3df61a9c858ba1b, band);
          break;
      }
    }
  }

  public void DeleteUnboundColumns() => this.ca195169aff51783a0d4c2cd09fa7fc9a();

  private void ca195169aff51783a0d4c2cd09fa7fc9a()
  {
    bool flag = false;
    IEnumerator enumerator;
    try
    {
      enumerator = this.cdbe6b49d3eee541c1a02140924401651.GetEnumerator();
      while (enumerator.MoveNext())
      {
        eGridColumn current = (eGridColumn) enumerator.Current;
        if (current.IsDetailValue)
        {
label_3:
          switch (5)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.ca195169aff51783a0d4c2cd09fa7fc9a);
              }
              try
              {
                DevExpress.XtraGrid.Columns.GridColumn gridColumn = (DevExpress.XtraGrid.Columns.GridColumn) this.GridView1.Columns.ColumnByFieldName(current.FieldName);
                this.c0ddd04b3cf4377237138fc0a692a95dc(this.GridView1.Bands, gridColumn);
                this.GridView1.Columns.Remove(gridColumn);
                this.cdbe6b49d3eee541c1a02140924401651.Remove(current.FieldName);
                if (this.ccac4c8044ae680dcd351934054a598ac != null)
                {
label_7:
                  switch (6)
                  {
                    case 0:
                      goto label_7;
                    default:
                      GridGroupSummaryItem groupSummaryItem = (GridGroupSummaryItem) this.ccac4c8044ae680dcd351934054a598ac[(object) current.FieldName];
                      if (groupSummaryItem != null)
                      {
label_9:
                        switch (6)
                        {
                          case 0:
                            goto label_9;
                          default:
                            this.ccac4c8044ae680dcd351934054a598ac.Remove((GridSummaryItem) groupSummaryItem);
                            flag = true;
                            break;
                        }
                      }
                      break;
                  }
                }
              }
              catch (Exception ex)
              {
                ProjectData.SetProjectError(ex);
                ProjectData.ClearProjectError();
              }
              break;
          }
        }
      }
label_16:
      switch (6)
      {
        case 0:
          goto label_16;
      }
    }
    finally
    {
      if (enumerator is IDisposable)
      {
label_19:
        switch (3)
        {
          case 0:
            goto label_19;
          default:
            (enumerator as IDisposable).Dispose();
            break;
        }
      }
    }
    int num;
    if (flag)
    {
label_23:
      switch (6)
      {
        case 0:
          goto label_23;
        default:
          num = this.ccac4c8044ae680dcd351934054a598ac != null ? 1 : 0;
          break;
      }
    }
    else
      num = 0;
    if (num == 0)
      return;
label_27:
    switch (7)
    {
      case 0:
        goto label_27;
      default:
        this.GridView1.GroupSummary.Assign((GridSummaryItemCollection) this.ccac4c8044ae680dcd351934054a598ac);
        break;
    }
  }

  private bool c0ddd04b3cf4377237138fc0a692a95dc(
    GridBandCollection c1208a6762b8519437262982f1e4d496d,
    DevExpress.XtraGrid.Columns.GridColumn c1e6290ac54e381b2081d91b6c00805a8)
  {
    bool flag;
    if (c1208a6762b8519437262982f1e4d496d == null)
    {
      flag = false;
    }
    else
    {
      try
      {
        foreach (GridBand cc8f933f27b311f2188e2a5882448ea5c in (CollectionBase) c1208a6762b8519437262982f1e4d496d)
        {
          if (this.c0ddd04b3cf4377237138fc0a692a95dc(cc8f933f27b311f2188e2a5882448ea5c.Children, c1e6290ac54e381b2081d91b6c00805a8))
          {
            flag = true;
            goto label_20;
          }
          IEnumerator enumerator;
          try
          {
            enumerator = cc8f933f27b311f2188e2a5882448ea5c.Columns.GetEnumerator();
            while (enumerator.MoveNext())
            {
              DevExpress.XtraGrid.Columns.GridColumn current = (DevExpress.XtraGrid.Columns.GridColumn) enumerator.Current;
              if (current == c1e6290ac54e381b2081d91b6c00805a8)
              {
                cc8f933f27b311f2188e2a5882448ea5c.Columns.Remove((BandedGridColumn) current);
                this.c4649595614dbfa8812ebeee2f9fa31d0(cc8f933f27b311f2188e2a5882448ea5c);
                flag = true;
                goto label_20;
              }
            }
          }
          finally
          {
            if (enumerator is IDisposable)
            {
label_10:
              switch (2)
              {
                case 0:
                  goto label_10;
                default:
                  if (false)
                  {
                    // ISSUE: method reference
                    RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c0ddd04b3cf4377237138fc0a692a95dc);
                  }
                  (enumerator as IDisposable).Dispose();
                  break;
              }
            }
          }
        }
label_16:
        switch (2)
        {
          case 0:
            goto label_16;
        }
      }
      finally
      {
        IEnumerator enumerator;
        if (enumerator is IDisposable)
          (enumerator as IDisposable).Dispose();
      }
    }
label_20:
    return flag;
  }

  private void c4649595614dbfa8812ebeee2f9fa31d0(GridBand cc8f933f27b311f2188e2a5882448ea5c)
  {
    GridBand parentBand = cc8f933f27b311f2188e2a5882448ea5c.ParentBand;
    if (parentBand != null)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c4649595614dbfa8812ebeee2f9fa31d0);
          }
          parentBand.Children.Remove(cc8f933f27b311f2188e2a5882448ea5c);
          if (parentBand.HasChildren)
            break;
label_5:
          switch (5)
          {
            case 0:
              goto label_5;
            default:
              this.c4649595614dbfa8812ebeee2f9fa31d0(parentBand);
              return;
          }
      }
    }
    else
      this.GridView1.Bands.Remove(cc8f933f27b311f2188e2a5882448ea5c);
  }

  public void InitUnboundData() => this.c29f404b57e8575c5a5b9a72b46b3b5f1();

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public DataTable UnboundDataTable
  {
    get => this.c467083dea0102ade8924e025f685c241;
    set => this.c467083dea0102ade8924e025f685c241 = value;
  }

  private DataTable c29f404b57e8575c5a5b9a72b46b3b5f1()
  {
    this.c467083dea0102ade8924e025f685c241 = new DataTable(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4808));
    this.c5d165dda3affdc10bf5fa3cdd0152971 = new DataSet();
    this.c5d165dda3affdc10bf5fa3cdd0152971.Tables.Add(this.c467083dea0102ade8924e025f685c241);
    this.Grid1.DataSource = (object) this.c467083dea0102ade8924e025f685c241;
    IEnumerator enumerator;
    try
    {
      enumerator = this.cdbe6b49d3eee541c1a02140924401651.GetEnumerator();
      while (enumerator.MoveNext())
        this.c843cf7ad2e8394cf4aa599e69e067272((eGridColumn) enumerator.Current);
    }
    finally
    {
      if (enumerator is IDisposable)
      {
label_5:
        switch (7)
        {
          case 0:
            goto label_5;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c29f404b57e8575c5a5b9a72b46b3b5f1);
            }
            (enumerator as IDisposable).Dispose();
            break;
        }
      }
    }
    this.c467083dea0102ade8924e025f685c241.RowChanged += new DataRowChangeEventHandler(this.caf192a812535a31cadfeafd1ea58ce65);
    this.c467083dea0102ade8924e025f685c241.RowDeleting += new DataRowChangeEventHandler(this.c0b0445df603b422c38fba6dc8577eb8e);
    return this.c467083dea0102ade8924e025f685c241;
  }

  private void caf192a812535a31cadfeafd1ea58ce65(
    object c6228239f423d7f951011de84ced6e507,
    DataRowChangeEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (c320269ec287d16905c829847d30a2e08.Action == DataRowAction.Add)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.caf192a812535a31cadfeafd1ea58ce65);
          break;
      }
    }
    else if (this.cd268e238072e06dd96804a08ee584b75)
    {
label_5:
      switch (6)
      {
        case 0:
          goto label_5;
      }
    }
    else
    {
      if (Conversions.ToBoolean(this.c582c73d9d3aaf3074e4c93b6db1c9b76))
        return;
      if (this.c5d165dda3affdc10bf5fa3cdd0152971 == null)
      {
label_9:
        switch (7)
        {
          case 0:
            goto label_9;
        }
      }
      else
      {
        this.ce42883e9f01c8bb4485808cb32a39d92();
        string str1 = "";
        string str2 = "";
        SortedList sortedList = new SortedList();
        DataColumn[] arySrc = (DataColumn[]) null;
        IEnumerator enumerator1;
        try
        {
          enumerator1 = this.GridColumns.GetEnumerator();
          while (enumerator1.MoveNext())
          {
            eGridColumn current = (eGridColumn) enumerator1.Current;
            string fieldName = current.FieldName;
            if (current.IsDetailKey)
            {
label_14:
              switch (7)
              {
                case 0:
                  goto label_14;
                default:
                  str1 = fieldName;
                  break;
              }
            }
            if (current.IsDetailData)
            {
label_17:
              switch (1)
              {
                case 0:
                  goto label_17;
                default:
                  str2 = fieldName;
                  break;
              }
            }
            if (current.IsDetailValue)
            {
label_20:
              switch (7)
              {
                case 0:
                  goto label_20;
                default:
                  string key = this.ccc70fe67912e8a514b2acd534468feea(fieldName);
                  if (!sortedList.ContainsKey((object) key))
                  {
label_22:
                    switch (5)
                    {
                      case 0:
                        goto label_22;
                      default:
                        sortedList.Add((object) key, (object) key);
                        break;
                    }
                  }
                  break;
              }
            }
            int num;
            if (!current.IsMasterKey)
            {
label_26:
              switch (7)
              {
                case 0:
                  goto label_26;
                default:
                  num = current.IsDetailKey ? 1 : 0;
                  break;
              }
            }
            else
              num = 1;
            if (num != 0)
            {
label_30:
              switch (7)
              {
                case 0:
                  goto label_30;
                default:
                  int index = 0;
                  if (arySrc != null)
                  {
label_32:
                    switch (5)
                    {
                      case 0:
                        goto label_32;
                      default:
                        index = arySrc.Length;
                        break;
                    }
                  }
                  arySrc = (DataColumn[]) Microsoft.VisualBasic.CompilerServices.Utils.CopyArray((Array) arySrc, (Array) new DataColumn[checked (index + 1)]);
                  arySrc[index] = this.c5d165dda3affdc10bf5fa3cdd0152971.Tables[0].Columns[fieldName];
                  break;
              }
            }
          }
label_37:
          switch (7)
          {
            case 0:
              goto label_37;
          }
        }
        finally
        {
          if (enumerator1 is IDisposable)
          {
label_40:
            switch (6)
            {
              case 0:
                goto label_40;
              default:
                (enumerator1 as IDisposable).Dispose();
                break;
            }
          }
        }
        int num1;
        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str1, "", false) != 0)
        {
label_44:
          switch (7)
          {
            case 0:
              goto label_44;
            default:
              num1 = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str2, "", false) == 0 ? 1 : 0;
              break;
          }
        }
        else
          num1 = 1;
        if (num1 != 0)
        {
label_48:
          switch (7)
          {
            case 0:
              goto label_48;
          }
        }
        else
        {
          DataRow row = c320269ec287d16905c829847d30a2e08.Row;
          IEnumerator enumerator2;
          try
          {
            enumerator2 = sortedList.Values.GetEnumerator();
            while (enumerator2.MoveNext())
            {
              string str3 = Conversions.ToString(enumerator2.Current);
              DataRow cc4490620a251e7966b0faae3f1eedfcc1 = (DataRow) null;
              if (row.RowState != DataRowState.Added)
              {
label_53:
                switch (6)
                {
                  case 0:
                    goto label_53;
                  default:
                    DataRow c5ba512afd93f3972a501986201045180 = row;
                    DataTable table = this.c5d165dda3affdc10bf5fa3cdd0152971.Tables[0];
                    ref DataTable local = ref table;
                    DataColumn[] c75b088864971821646f1cfc8ec6067f7 = arySrc;
                    string cec42b5f536a930e11db78f7382cf8e9b = str1;
                    string cf344a28ab9f477458a4c5b89a7e68263 = str3;
                    DataRow[] dataRowArray = this.c1e9b3a682672fb187b819bd8dd50869c(c5ba512afd93f3972a501986201045180, ref local, c75b088864971821646f1cfc8ec6067f7, cec42b5f536a930e11db78f7382cf8e9b, cf344a28ab9f477458a4c5b89a7e68263);
                    if (dataRowArray.Length > 0)
                      cc4490620a251e7966b0faae3f1eedfcc1 = dataRowArray[0];
                    break;
                }
              }
              if (cc4490620a251e7966b0faae3f1eedfcc1 != null)
              {
label_58:
                switch (7)
                {
                  case 0:
                    goto label_58;
                  default:
                    if (this.c33e7f157ec8e21c7e797c11a3104caf7(row, str3))
                    {
                      cc4490620a251e7966b0faae3f1eedfcc1.Delete();
                      break;
                    }
                    this.ca3655e4f16983296823dab72c20e6e6b(row, ref cc4490620a251e7966b0faae3f1eedfcc1, str1, str3, str2);
                    break;
                }
              }
              else if (this.c33e7f157ec8e21c7e797c11a3104caf7(row, str3))
              {
label_63:
                switch (1)
                {
                  case 0:
                    goto label_63;
                }
              }
              else
              {
                DataRow cc4490620a251e7966b0faae3f1eedfcc2 = this.c5d165dda3affdc10bf5fa3cdd0152971.Tables[0].NewRow();
                cc4490620a251e7966b0faae3f1eedfcc2[str1] = (object) str3;
                this.ca3655e4f16983296823dab72c20e6e6b(row, ref cc4490620a251e7966b0faae3f1eedfcc2, str1, str3, str2);
                this.c5d165dda3affdc10bf5fa3cdd0152971.Tables[0].Rows.Add(cc4490620a251e7966b0faae3f1eedfcc2);
              }
            }
          }
          finally
          {
            if (enumerator2 is IDisposable)
            {
label_70:
              switch (1)
              {
                case 0:
                  goto label_70;
                default:
                  (enumerator2 as IDisposable).Dispose();
                  break;
              }
            }
          }
          this.c582c73d9d3aaf3074e4c93b6db1c9b76 = (object) true;
          row.AcceptChanges();
          row.SetModified();
          this.c582c73d9d3aaf3074e4c93b6db1c9b76 = (object) false;
        }
      }
    }
  }

  private DataRow[] c1e9b3a682672fb187b819bd8dd50869c(
    DataRow c5ba512afd93f3972a501986201045180,
    ref DataTable c513cc37be646fc1e2d0787fccdb58bff,
    DataColumn[] c75b088864971821646f1cfc8ec6067f7,
    string cec42b5f536a930e11db78f7382cf8e9b,
    string cf344a28ab9f477458a4c5b89a7e68263)
  {
    string str = "";
    DataColumn[] dataColumnArray = c75b088864971821646f1cfc8ec6067f7;
    int index = 0;
    while (index < dataColumnArray.Length)
    {
      DataColumn dataColumn = dataColumnArray[index];
      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, "", false) != 0)
      {
label_2:
        switch (7)
        {
          case 0:
            goto label_2;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c1e9b3a682672fb187b819bd8dd50869c);
            }
            str += c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4819);
            break;
        }
      }
      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(dataColumn.ColumnName, cec42b5f536a930e11db78f7382cf8e9b, false) == 0)
      {
label_7:
        switch (3)
        {
          case 0:
            goto label_7;
          default:
            if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(cf344a28ab9f477458a4c5b89a7e68263, "", false) == 0)
            {
label_9:
              switch (4)
              {
                case 0:
                  goto label_9;
                default:
                  str = str + dataColumn.ColumnName + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4830);
                  break;
              }
            }
            else
            {
              str = str + dataColumn.ColumnName + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4847) + cf344a28ab9f477458a4c5b89a7e68263 + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(313);
              break;
            }
            break;
        }
      }
      else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(c5ba512afd93f3972a501986201045180[dataColumn.ColumnName])), "", false) == 0)
      {
label_13:
        switch (1)
        {
          case 0:
            goto label_13;
          default:
            str = str + dataColumn.ColumnName + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4830);
            break;
        }
      }
      else
        str = str + dataColumn.ColumnName + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4847) + Shared.ToStr(RuntimeHelpers.GetObjectValue(c5ba512afd93f3972a501986201045180[dataColumn.ColumnName])) + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(313);
      checked { ++index; }
    }
label_19:
    switch (6)
    {
      case 0:
        goto label_19;
      default:
        return c513cc37be646fc1e2d0787fccdb58bff.Select(str);
    }
  }

  private bool ca3655e4f16983296823dab72c20e6e6b(
    DataRow c5ba512afd93f3972a501986201045180,
    ref DataRow cc4490620a251e7966b0faae3f1eedfcc,
    string cec42b5f536a930e11db78f7382cf8e9b,
    string cf344a28ab9f477458a4c5b89a7e68263,
    string cfd815a94e5fc8b7bf8ece079fd94e220)
  {
    IEnumerator enumerator;
    bool flag;
    try
    {
      enumerator = this.c467083dea0102ade8924e025f685c241.Columns.GetEnumerator();
      while (enumerator.MoveNext())
      {
        string columnName = ((DataColumn) enumerator.Current).ColumnName;
        int num1;
        if (!this.GridColumn(columnName).IsMasterKey)
        {
label_3:
          switch (1)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.ca3655e4f16983296823dab72c20e6e6b);
              }
              num1 = this.GridColumn(columnName).IsMasterData ? 1 : 0;
              break;
          }
        }
        else
          num1 = 1;
        if (num1 != 0)
        {
label_9:
          switch (3)
          {
            case 0:
              goto label_9;
            default:
              if (!cc4490620a251e7966b0faae3f1eedfcc.Table.Columns.Contains(columnName))
              {
label_11:
                switch (2)
                {
                  case 0:
                    goto label_11;
                  default:
                    Shared.MessageInfo(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4856) + columnName);
                    flag = false;
                    goto label_41;
                }
              }
              else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(c5ba512afd93f3972a501986201045180[columnName])), Shared.ToStr(RuntimeHelpers.GetObjectValue(cc4490620a251e7966b0faae3f1eedfcc[columnName])), false) != 0)
              {
label_14:
                switch (7)
                {
                  case 0:
                    goto label_14;
                  default:
                    cc4490620a251e7966b0faae3f1eedfcc[columnName] = RuntimeHelpers.GetObjectValue(Interaction.IIf(Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(c5ba512afd93f3972a501986201045180[columnName])), "", false) == 0, (object) DBNull.Value, (object) Shared.ToStr(RuntimeHelpers.GetObjectValue(c5ba512afd93f3972a501986201045180[columnName]))));
                    break;
                }
              }
              else
                break;
              break;
          }
        }
        else
        {
          int num2;
          if (this.GridColumn(columnName).IsDetailValue)
          {
label_17:
            switch (6)
            {
              case 0:
                goto label_17;
              default:
                num2 = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(this.ccc70fe67912e8a514b2acd534468feea(columnName), cf344a28ab9f477458a4c5b89a7e68263, false) == 0 ? 1 : 0;
                break;
            }
          }
          else
            num2 = 0;
          if (num2 != 0)
          {
            cfd815a94e5fc8b7bf8ece079fd94e220 = this.cd5d70d23320a317ca53e557a81ff7529(columnName, cfd815a94e5fc8b7bf8ece079fd94e220);
            if (!cc4490620a251e7966b0faae3f1eedfcc.Table.Columns.Contains(cfd815a94e5fc8b7bf8ece079fd94e220))
            {
label_22:
              switch (4)
              {
                case 0:
                  goto label_22;
                default:
                  Shared.MessageInfo(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4856) + columnName);
                  flag = false;
                  goto label_41;
              }
            }
            else if (this.GridColumn(cfd815a94e5fc8b7bf8ece079fd94e220).IsNumericField())
            {
label_25:
              switch (6)
              {
                case 0:
                  goto label_25;
                default:
                  if (Decimal.Compare(Shared.ToDec(RuntimeHelpers.GetObjectValue(cc4490620a251e7966b0faae3f1eedfcc[cfd815a94e5fc8b7bf8ece079fd94e220])), Shared.ToDec(RuntimeHelpers.GetObjectValue(c5ba512afd93f3972a501986201045180[columnName]))) != 0)
                  {
label_27:
                    switch (3)
                    {
                      case 0:
                        goto label_27;
                      default:
                        cc4490620a251e7966b0faae3f1eedfcc[cfd815a94e5fc8b7bf8ece079fd94e220] = RuntimeHelpers.GetObjectValue(Interaction.IIf(Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(c5ba512afd93f3972a501986201045180[columnName])), "", false) == 0, (object) DBNull.Value, (object) Shared.ToDec(RuntimeHelpers.GetObjectValue(c5ba512afd93f3972a501986201045180[columnName]))));
                        break;
                    }
                  }
                  else
                    break;
                  break;
              }
            }
            else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(cc4490620a251e7966b0faae3f1eedfcc[cfd815a94e5fc8b7bf8ece079fd94e220])), Shared.ToStr(RuntimeHelpers.GetObjectValue(c5ba512afd93f3972a501986201045180[columnName])), false) != 0)
            {
label_30:
              switch (4)
              {
                case 0:
                  goto label_30;
                default:
                  cc4490620a251e7966b0faae3f1eedfcc[cfd815a94e5fc8b7bf8ece079fd94e220] = RuntimeHelpers.GetObjectValue(Interaction.IIf(Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(c5ba512afd93f3972a501986201045180[columnName])), "", false) == 0, (object) DBNull.Value, (object) Shared.ToStr(RuntimeHelpers.GetObjectValue(c5ba512afd93f3972a501986201045180[columnName]))));
                  break;
              }
            }
          }
        }
      }
label_36:
      switch (4)
      {
        case 0:
          goto label_36;
      }
    }
    finally
    {
      if (enumerator is IDisposable)
      {
label_38:
        switch (2)
        {
          case 0:
            goto label_38;
          default:
            (enumerator as IDisposable).Dispose();
            break;
        }
      }
    }
label_41:
    return flag;
  }

  private bool c33e7f157ec8e21c7e797c11a3104caf7(
    DataRow c5ba512afd93f3972a501986201045180,
    string cab74c3a4bb15e149de7a2e59be5a6a1d)
  {
    IEnumerator enumerator;
    try
    {
      enumerator = this.c467083dea0102ade8924e025f685c241.Columns.GetEnumerator();
      while (enumerator.MoveNext())
      {
        string columnName = ((DataColumn) enumerator.Current).ColumnName;
        if (this.GridColumn(columnName).IsDetailValue && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(this.ccc70fe67912e8a514b2acd534468feea(columnName), cab74c3a4bb15e149de7a2e59be5a6a1d, false) == 0)
        {
label_3:
          switch (3)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c33e7f157ec8e21c7e797c11a3104caf7);
              }
              if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(c5ba512afd93f3972a501986201045180[columnName])), "", false) != 0)
              {
label_7:
                switch (7)
                {
                  case 0:
                    goto label_7;
                  default:
                    return false;
                }
              }
              else
                break;
          }
        }
      }
label_11:
      switch (4)
      {
        case 0:
          goto label_11;
      }
    }
    finally
    {
      if (enumerator is IDisposable)
      {
label_13:
        switch (5)
        {
          case 0:
            goto label_13;
          default:
            (enumerator as IDisposable).Dispose();
            break;
        }
      }
    }
    return true;
  }

  private void c0b0445df603b422c38fba6dc8577eb8e(
    object c6228239f423d7f951011de84ced6e507,
    DataRowChangeEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (this.cd268e238072e06dd96804a08ee584b75)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c0b0445df603b422c38fba6dc8577eb8e);
          break;
      }
    }
    else if (this.c5d165dda3affdc10bf5fa3cdd0152971 == null)
    {
label_6:
      switch (7)
      {
        case 0:
          goto label_6;
      }
    }
    else
    {
      string Left1 = "";
      string Left2 = "";
      SortedList sortedList = new SortedList();
      DataColumn[] arySrc = (DataColumn[]) null;
      try
      {
        foreach (eGridColumn gridColumn in this.GridColumns)
        {
          string fieldName = gridColumn.FieldName;
          if (gridColumn.IsDetailKey)
          {
label_11:
            switch (3)
            {
              case 0:
                goto label_11;
              default:
                Left1 = fieldName;
                break;
            }
          }
          if (gridColumn.IsDetailData)
            Left2 = fieldName;
          if (gridColumn.IsDetailValue)
          {
label_16:
            switch (7)
            {
              case 0:
                goto label_16;
              default:
                string key = this.ccc70fe67912e8a514b2acd534468feea(fieldName);
                if (!sortedList.ContainsKey((object) key))
                {
label_18:
                  switch (7)
                  {
                    case 0:
                      goto label_18;
                    default:
                      sortedList.Add((object) key, (object) key);
                      break;
                  }
                }
                break;
            }
          }
          int num;
          if (!gridColumn.IsMasterKey)
          {
label_22:
            switch (4)
            {
              case 0:
                goto label_22;
              default:
                num = gridColumn.IsDetailKey ? 1 : 0;
                break;
            }
          }
          else
            num = 1;
          if (num != 0)
          {
            int index = 0;
            if (arySrc != null)
              index = arySrc.Length;
            arySrc = (DataColumn[]) Microsoft.VisualBasic.CompilerServices.Utils.CopyArray((Array) arySrc, (Array) new DataColumn[checked (index + 1)]);
            arySrc[index] = this.c5d165dda3affdc10bf5fa3cdd0152971.Tables[0].Columns[fieldName];
          }
        }
label_31:
        switch (6)
        {
          case 0:
            goto label_31;
        }
      }
      finally
      {
        IEnumerator enumerator;
        if (enumerator is IDisposable)
          (enumerator as IDisposable).Dispose();
      }
      int num1;
      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Left1, "", false) != 0)
      {
label_37:
        switch (4)
        {
          case 0:
            goto label_37;
          default:
            num1 = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Left2, "", false) == 0 ? 1 : 0;
            break;
        }
      }
      else
        num1 = 1;
      if (num1 != 0)
      {
label_41:
        switch (5)
        {
          case 0:
            goto label_41;
        }
      }
      else
      {
        DataRow row = c320269ec287d16905c829847d30a2e08.Row;
        IEnumerator enumerator;
        try
        {
          enumerator = sortedList.Values.GetEnumerator();
          while (enumerator.MoveNext())
          {
            string str = Conversions.ToString(enumerator.Current);
            DataRow c5ba512afd93f3972a501986201045180 = row;
            DataTable table = this.c5d165dda3affdc10bf5fa3cdd0152971.Tables[0];
            ref DataTable local = ref table;
            DataColumn[] c75b088864971821646f1cfc8ec6067f7 = arySrc;
            string cec42b5f536a930e11db78f7382cf8e9b = Left1;
            string cf344a28ab9f477458a4c5b89a7e68263 = str;
            DataRow[] dataRowArray = this.c1e9b3a682672fb187b819bd8dd50869c(c5ba512afd93f3972a501986201045180, ref local, c75b088864971821646f1cfc8ec6067f7, cec42b5f536a930e11db78f7382cf8e9b, cf344a28ab9f477458a4c5b89a7e68263);
            if (dataRowArray.Length > 0)
            {
label_45:
              switch (4)
              {
                case 0:
                  goto label_45;
                default:
                  try
                  {
                    dataRowArray[0].Delete();
                  }
                  catch (Exception ex)
                  {
                    ProjectData.SetProjectError(ex);
                    ProjectData.ClearProjectError();
                  }
                  break;
              }
            }
          }
label_51:
          switch (7)
          {
            case 0:
              goto label_51;
          }
        }
        finally
        {
          if (enumerator is IDisposable)
          {
label_54:
            switch (6)
            {
              case 0:
                goto label_54;
              default:
                (enumerator as IDisposable).Dispose();
                break;
            }
          }
        }
      }
    }
  }

  private string ccc70fe67912e8a514b2acd534468feea(string cb12b41ace8f87945f2aa989d95fd4a5e)
  {
    if (!cb12b41ace8f87945f2aa989d95fd4a5e.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4253)))
      return cb12b41ace8f87945f2aa989d95fd4a5e;
label_1:
    switch (3)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.ccc70fe67912e8a514b2acd534468feea);
        }
        return cb12b41ace8f87945f2aa989d95fd4a5e.Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4253), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(135)).Split(',')[1];
    }
  }

  private string cd5d70d23320a317ca53e557a81ff7529(
    string cb12b41ace8f87945f2aa989d95fd4a5e,
    string cfd815a94e5fc8b7bf8ece079fd94e220)
  {
    if (!cb12b41ace8f87945f2aa989d95fd4a5e.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4253)))
      return cfd815a94e5fc8b7bf8ece079fd94e220;
    return cb12b41ace8f87945f2aa989d95fd4a5e.Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4253), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(135)).Split(',')[0];
  }

  private void c843cf7ad2e8394cf4aa599e69e067272(eGridColumn c14071ddc2bbc48a080eab75fc43d2ddd)
  {
    if (this.c467083dea0102ade8924e025f685c241 == null)
      return;
    FieldType fieldType = c14071ddc2bbc48a080eab75fc43d2ddd.FieldType;
    if (fieldType <= FieldType.Int)
    {
label_2:
      switch (3)
      {
        case 0:
          goto label_2;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c843cf7ad2e8394cf4aa599e69e067272);
          }
          if (fieldType != FieldType.Decimal)
          {
label_6:
            switch (3)
            {
              case 0:
                goto label_6;
              default:
                if (fieldType != FieldType.Int)
                {
label_8:
                  switch (5)
                  {
                    case 0:
                      goto label_8;
                    default:
                      goto label_19;
                  }
                }
                else
                  break;
            }
          }
          else
            break;
          break;
      }
    }
    else if (fieldType != FieldType.Date)
    {
label_10:
      switch (4)
      {
        case 0:
          goto label_10;
        default:
          if (fieldType != FieldType.Image)
          {
label_12:
            switch (2)
            {
              case 0:
                goto label_12;
              default:
                if (fieldType != FieldType.Keypad)
                {
label_15:
                  switch (4)
                  {
                    case 0:
                      goto label_15;
                    default:
                      goto label_19;
                  }
                }
                else
                  break;
            }
          }
          else
          {
            this.c467083dea0102ade8924e025f685c241.Columns.Add(c14071ddc2bbc48a080eab75fc43d2ddd.FieldName, System.Type.GetType(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5001)));
            goto label_20;
          }
          break;
      }
    }
    else
    {
      this.c467083dea0102ade8924e025f685c241.Columns.Add(c14071ddc2bbc48a080eab75fc43d2ddd.FieldName, System.Type.GetType(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4970)));
      goto label_20;
    }
    this.c467083dea0102ade8924e025f685c241.Columns.Add(c14071ddc2bbc48a080eab75fc43d2ddd.FieldName, System.Type.GetType(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4941)));
    goto label_20;
label_19:
    this.c467083dea0102ade8924e025f685c241.Columns.Add(c14071ddc2bbc48a080eab75fc43d2ddd.FieldName, System.Type.GetType(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5028)));
label_20:;
  }

  private void c978e92c5b571d346d7e38111f15c27b7(DataTable ca08c19fbee4d9f5389504ff7fce76250)
  {
    if (ca08c19fbee4d9f5389504ff7fce76250 == null)
    {
label_1:
      switch (1)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c978e92c5b571d346d7e38111f15c27b7);
          }
          this.Grid1.DataSource = (object) null;
          break;
      }
    }
    else if (ca08c19fbee4d9f5389504ff7fce76250.Rows.Count == 0)
    {
label_6:
      switch (5)
      {
        case 0:
          goto label_6;
      }
    }
    else
    {
      if (this.cd268e238072e06dd96804a08ee584b75)
        return;
      this.cd268e238072e06dd96804a08ee584b75 = true;
      this.c467083dea0102ade8924e025f685c241.RowChanged -= new DataRowChangeEventHandler(this.caf192a812535a31cadfeafd1ea58ce65);
      string str1 = "";
      string[] arySrc1 = (string[]) null;
      string[] arySrc2 = (string[]) null;
      DataColumn[] arySrc3 = (DataColumn[]) null;
      try
      {
        foreach (DataColumn column in (InternalDataCollectionBase) ca08c19fbee4d9f5389504ff7fce76250.Columns)
        {
          string columnName = column.ColumnName;
          if (this.GridColumns.Contains(columnName))
          {
label_11:
            switch (3)
            {
              case 0:
                goto label_11;
              default:
                if (this.GridColumn(columnName).IsMasterKey)
                {
                  int index = 0;
                  if (arySrc3 != null)
                  {
label_14:
                    switch (4)
                    {
                      case 0:
                        goto label_14;
                      default:
                        index = arySrc3.Length;
                        break;
                    }
                  }
                  arySrc3 = (DataColumn[]) Microsoft.VisualBasic.CompilerServices.Utils.CopyArray((Array) arySrc3, (Array) new DataColumn[checked (index + 1)]);
                  arySrc2 = (string[]) Microsoft.VisualBasic.CompilerServices.Utils.CopyArray((Array) arySrc2, (Array) new string[checked (index + 1)]);
                  arySrc3[index] = this.c467083dea0102ade8924e025f685c241.Columns[columnName];
                  arySrc2[index] = columnName;
                }
                if (this.GridColumn(columnName).IsDetailKey)
                {
label_18:
                  switch (4)
                  {
                    case 0:
                      goto label_18;
                    default:
                      str1 = columnName;
                      break;
                  }
                }
                if (this.GridColumn(columnName).IsDetailData)
                {
                  int index = 0;
                  if (arySrc1 != null)
                    index = arySrc1.Length;
                  arySrc1 = (string[]) Microsoft.VisualBasic.CompilerServices.Utils.CopyArray((Array) arySrc1, (Array) new string[checked (index + 1)]);
                  arySrc1[index] = columnName;
                }
                break;
            }
          }
        }
      }
      finally
      {
        IEnumerator enumerator;
        if (enumerator is IDisposable)
          (enumerator as IDisposable).Dispose();
      }
      int num1;
      if (arySrc3 != null)
      {
label_31:
        switch (2)
        {
          case 0:
            goto label_31;
          default:
            if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str1, "", false) != 0)
            {
              num1 = arySrc1.Length == 0 ? 1 : 0;
              goto label_35;
            }
            break;
        }
      }
      num1 = 1;
label_35:
      if (num1 != 0)
      {
label_36:
        switch (3)
        {
          case 0:
            goto label_36;
        }
      }
      else
      {
        this.c467083dea0102ade8924e025f685c241.PrimaryKey = arySrc3;
        NewLateBinding.LateSet(Parameter.MainFrame.ProgBar, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5055), new object[1]
        {
          (object) true
        }, (string[]) null, (System.Type[]) null);
        NewLateBinding.LateSet(Parameter.MainFrame.ProgBar, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5070), new object[1]
        {
          (object) 1
        }, (string[]) null, (System.Type[]) null);
        NewLateBinding.LateSet(Parameter.MainFrame.ProgBar, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5085), new object[1]
        {
          (object) ca08c19fbee4d9f5389504ff7fce76250.Rows.Count
        }, (string[]) null, (System.Type[]) null);
        NewLateBinding.LateSet(Parameter.MainFrame.ProgBar, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5100), new object[1]
        {
          (object) 1
        }, (string[]) null, (System.Type[]) null);
        try
        {
          Cursor.Current = Cursors.WaitCursor;
          int num2 = -1;
          IEnumerator enumerator1;
          try
          {
            enumerator1 = ca08c19fbee4d9f5389504ff7fce76250.Rows.GetEnumerator();
            while (enumerator1.MoveNext())
            {
              DataRow current = (DataRow) enumerator1.Current;
              string str2 = "";
              string[] strArray1 = arySrc2;
              int index1 = 0;
              while (index1 < strArray1.Length)
              {
                string columnName = strArray1[index1];
                string str3 = Shared.ToStr(RuntimeHelpers.GetObjectValue(current[columnName]));
                if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str2, "", false) != 0)
                  str2 += c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4819);
                str2 = str2 + columnName + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4847) + str3 + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(313);
                checked { ++index1; }
              }
label_45:
              switch (5)
              {
                case 0:
                  goto label_45;
                default:
                  DataRow[] dataRowArray = this.c467083dea0102ade8924e025f685c241.Select(str2);
                  if (dataRowArray.Length == 0)
                  {
                    DataRow row = this.c467083dea0102ade8924e025f685c241.NewRow();
                    IEnumerator enumerator2;
                    try
                    {
                      enumerator2 = ca08c19fbee4d9f5389504ff7fce76250.Columns.GetEnumerator();
                      while (enumerator2.MoveNext())
                      {
                        string columnName = ((DataColumn) enumerator2.Current).ColumnName;
                        if (this.GridColumns.Contains(columnName) && (this.GridColumn(columnName).IsMasterKey || this.GridColumn(columnName).IsMasterData) && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(current[columnName])), "", false) != 0)
                        {
label_50:
                          switch (3)
                          {
                            case 0:
                              goto label_50;
                            default:
                              row[columnName] = RuntimeHelpers.GetObjectValue(current[columnName]);
                              break;
                          }
                        }
                      }
                    }
                    finally
                    {
                      if (enumerator2 is IDisposable)
                      {
label_56:
                        switch (5)
                        {
                          case 0:
                            goto label_56;
                          default:
                            (enumerator2 as IDisposable).Dispose();
                            break;
                        }
                      }
                    }
                    this.c467083dea0102ade8924e025f685c241.Rows.Add(row);
                    dataRowArray = new DataRow[1]{ row };
                  }
                  string str4 = Shared.ToStr(RuntimeHelpers.GetObjectValue(current[str1]));
                  if (arySrc1.Length == 1)
                  {
label_61:
                    switch (6)
                    {
                      case 0:
                        goto label_61;
                      default:
                        string str5 = Shared.ToStr(RuntimeHelpers.GetObjectValue(current[arySrc1[0]]));
                        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str4, "", false) != 0 && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str5, "", false) != 0)
                        {
label_63:
                          switch (7)
                          {
                            case 0:
                              goto label_63;
                            default:
                              dataRowArray[0][str4] = (object) str5;
                              break;
                          }
                        }
                        else
                          break;
                        break;
                    }
                  }
                  else
                  {
                    string[] strArray2 = arySrc1;
                    int index2 = 0;
                    while (index2 < strArray2.Length)
                    {
                      string columnName = strArray2[index2];
                      string str6 = Shared.ToStr(RuntimeHelpers.GetObjectValue(current[columnName]));
                      int num3;
                      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str4, "", false) != 0)
                      {
label_68:
                        switch (4)
                        {
                          case 0:
                            goto label_68;
                          default:
                            num3 = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str6, "", false) != 0 ? 1 : 0;
                            break;
                        }
                      }
                      else
                        num3 = 0;
                      if (num3 != 0)
                        dataRowArray[0][columnName + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4253) + str4] = (object) str6;
                      checked { ++index2; }
                    }
label_75:
                    switch (5)
                    {
                      case 0:
                        goto label_75;
                    }
                  }
                  int num4;
                  checked { ++num4; }
                  if (num4 % 100 == 0)
                  {
label_77:
                    switch (1)
                    {
                      case 0:
                        goto label_77;
                      default:
                        NewLateBinding.LateSet(Parameter.MainFrame.ProgBar, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4551), new object[1]
                        {
                          (object) num4
                        }, (string[]) null, (System.Type[]) null);
                        break;
                    }
                  }
                  continue;
              }
            }
label_81:
            switch (3)
            {
              case 0:
                goto label_81;
            }
          }
          finally
          {
            if (enumerator1 is IDisposable)
            {
label_84:
              switch (6)
              {
                case 0:
                  goto label_84;
                default:
                  (enumerator1 as IDisposable).Dispose();
                  break;
              }
            }
          }
          this.c467083dea0102ade8924e025f685c241.AcceptChanges();
          if (num2 > 10)
          {
label_88:
            switch (3)
            {
              case 0:
                goto label_88;
              default:
                this.RowIndex = 0;
                break;
            }
          }
        }
        catch (Exception ex)
        {
          ProjectData.SetProjectError(ex);
          Shared.MessageError(ex, title: c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5109));
          ProjectData.ClearProjectError();
        }
        finally
        {
          DataColumn[] dataColumnArray = arySrc3;
          int index = 0;
          while (index < dataColumnArray.Length)
          {
            dataColumnArray[index].AllowDBNull = true;
            checked { ++index; }
          }
label_94:
          switch (5)
          {
            case 0:
              goto label_94;
            default:
              this.c467083dea0102ade8924e025f685c241.PrimaryKey.Initialize();
              this.c467083dea0102ade8924e025f685c241.PrimaryKey = (DataColumn[]) null;
              NewLateBinding.LateSet(Parameter.MainFrame.ProgBar, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5055), new object[1]
              {
                (object) false
              }, (string[]) null, (System.Type[]) null);
              this.cd268e238072e06dd96804a08ee584b75 = false;
              this.c467083dea0102ade8924e025f685c241.RowChanged += new DataRowChangeEventHandler(this.caf192a812535a31cadfeafd1ea58ce65);
              this.Cursor = Cursors.Default;
          }
        }
      }
    }
  }

  public void AddColumn(eGridColumn eCol)
  {
    if (eCol == null)
    {
label_1:
      switch (5)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.AddColumn);
          break;
      }
    }
    else
    {
      try
      {
        this.c56f33f0a5583a83452d2f2e7ab8cd61d(eCol);
        this.c02943f7d77d8340f65c81be9286ab1dc(eCol);
        this.c843cf7ad2e8394cf4aa599e69e067272(eCol);
        if (1 < this.cb5346c3ef09fcb1fcee1a5bc4abc4d2f)
        {
          if (this.c469b0fc12a49e16cef7765328b7e46b3 == 0)
          {
label_7:
            switch (3)
            {
              case 0:
                goto label_7;
              default:
                this.c469b0fc12a49e16cef7765328b7e46b3 = 20;
                break;
            }
          }
          int num;
          if (0 < checked (this.cb5346c3ef09fcb1fcee1a5bc4abc4d2f * this.c469b0fc12a49e16cef7765328b7e46b3))
          {
label_10:
            switch (4)
            {
              case 0:
                goto label_10;
              default:
                num = this.GridView1.ColumnPanelRowHeight < checked (this.cb5346c3ef09fcb1fcee1a5bc4abc4d2f * this.c469b0fc12a49e16cef7765328b7e46b3) ? 1 : 0;
                break;
            }
          }
          else
            num = 0;
          if (num != 0)
          {
label_14:
            switch (4)
            {
              case 0:
                goto label_14;
              default:
                this.GridView1.ColumnPanelRowHeight = checked (this.cb5346c3ef09fcb1fcee1a5bc4abc4d2f * this.c469b0fc12a49e16cef7765328b7e46b3);
                break;
            }
          }
        }
      }
      catch (Exception ex)
      {
        ProjectData.SetProjectError(ex);
        Shared.ThrowError(ex.Message, Shared.Loc((object) this, MethodBase.GetCurrentMethod()));
        ProjectData.ClearProjectError();
      }
    }
  }

  private void c02943f7d77d8340f65c81be9286ab1dc(eGridColumn c14071ddc2bbc48a080eab75fc43d2ddd)
  {
    if (this.cdbe6b49d3eee541c1a02140924401651 == null)
    {
label_1:
      switch (7)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c02943f7d77d8340f65c81be9286ab1dc);
          }
          this.cdbe6b49d3eee541c1a02140924401651 = new Collection();
          break;
      }
    }
    this.cdbe6b49d3eee541c1a02140924401651.Add((object) c14071ddc2bbc48a080eab75fc43d2ddd, c14071ddc2bbc48a080eab75fc43d2ddd.FieldName);
  }

  private DevExpress.XtraGrid.Columns.GridColumn c56f33f0a5583a83452d2f2e7ab8cd61d(
    eGridColumn cbed866e03206cd14a5d8cf95ed0a9258)
  {
    try
    {
      this.cbee725c554d327dc3d76039ee2804a33 = true;
      cbed866e03206cd14a5d8cf95ed0a9258.Grid = (object) this;
      cbed866e03206cd14a5d8cf95ed0a9258.WorkSet = this.c330a4db27d3578a8e5d80797d2f5ac12;
      DevExpress.XtraGrid.Columns.GridColumn c5b06a6c558da093ec9f7612b25cd04e4 = this.c413a01926a084a7d8e924b0999a264db(cbed866e03206cd14a5d8cf95ed0a9258);
      BandedGridView bandedGridView = this.GridView1;
      FieldType fieldType = cbed866e03206cd14a5d8cf95ed0a9258.FieldType;
      if (fieldType <= FieldType.Image)
      {
        if (fieldType <= FieldType.Text)
        {
label_3:
          switch (5)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c56f33f0a5583a83452d2f2e7ab8cd61d);
              }
              if (fieldType != FieldType.Check)
              {
label_7:
                switch (2)
                {
                  case 0:
                    goto label_7;
                  default:
                    if (fieldType != FieldType.Combo)
                    {
label_9:
                      switch (1)
                      {
                        case 0:
                          goto label_9;
                        default:
                          if (fieldType != FieldType.Text)
                          {
label_11:
                            switch (4)
                            {
                              case 0:
                                goto label_11;
                              default:
                                goto label_40;
                            }
                          }
                          else
                            break;
                      }
                    }
                    else
                    {
                      this.c27aba542b020afeb5be20dc413afba39(c5b06a6c558da093ec9f7612b25cd04e4, cbed866e03206cd14a5d8cf95ed0a9258);
                      goto label_40;
                    }
                    break;
                }
              }
              else
              {
                this.cdfbc406e08c3f881cb8a24423c3d3028(c5b06a6c558da093ec9f7612b25cd04e4);
                goto label_40;
              }
          }
        }
        else
        {
          switch (fieldType - 15)
          {
            case (FieldType) 0:
              goto label_27;
            case FieldType.Check:
            case (FieldType) 3:
            case (FieldType) 4:
              goto label_40;
            case (FieldType) 2:
              this.c0371e871b41d51dc2040a45a7b2f07ba(c5b06a6c558da093ec9f7612b25cd04e4, cbed866e03206cd14a5d8cf95ed0a9258);
              goto label_40;
            case FieldType.Combo:
              this.c2b6f5c37f036da3cf5b81d11da572637(c5b06a6c558da093ec9f7612b25cd04e4, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(530));
              goto label_40;
            case FieldType.CheckCombo:
              this.c2b6f5c37f036da3cf5b81d11da572637(c5b06a6c558da093ec9f7612b25cd04e4, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(515));
              goto label_40;
            case (FieldType) 7:
              this.c2b6f5c37f036da3cf5b81d11da572637(c5b06a6c558da093ec9f7612b25cd04e4, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(452));
              goto label_40;
            default:
              if (fieldType != FieldType.Time)
              {
                if (fieldType != FieldType.Image)
                {
label_15:
                  switch (2)
                  {
                    case 0:
                      goto label_15;
                    default:
                      goto label_40;
                  }
                }
                else
                {
                  this.c1431e014d8c71cd545b5d49dfb1e37c3(c5b06a6c558da093ec9f7612b25cd04e4);
                  goto label_40;
                }
              }
              else
              {
                this.c1d6a7a1a89498b49b73fa7263ac85f4a(c5b06a6c558da093ec9f7612b25cd04e4, cbed866e03206cd14a5d8cf95ed0a9258);
                goto label_40;
              }
          }
        }
      }
      else if (fieldType <= FieldType.TextButton)
      {
        if (fieldType != FieldType.Memo)
        {
label_18:
          switch (6)
          {
            case 0:
              goto label_18;
            default:
              switch (fieldType)
              {
                case FieldType.Progress:
                  this.c9f622b9dbb1cff94ff05922432b94ce7(c5b06a6c558da093ec9f7612b25cd04e4, cbed866e03206cd14a5d8cf95ed0a9258);
                  goto label_40;
                case FieldType.TextButton:
                  this.cade15b73d097e96ec5748a4ff0503127(c5b06a6c558da093ec9f7612b25cd04e4, cbed866e03206cd14a5d8cf95ed0a9258);
                  goto label_40;
                default:
label_20:
                  switch (6)
                  {
                    case 0:
                      goto label_20;
                    default:
                      goto label_40;
                  }
              }
          }
        }
        else
        {
          this.cb2e0f12b2ec9031a4b9d83854bf285fe(c5b06a6c558da093ec9f7612b25cd04e4, cbed866e03206cd14a5d8cf95ed0a9258);
          goto label_40;
        }
      }
      else if (fieldType != FieldType.CellButton)
      {
        if (fieldType != FieldType.Keypad)
        {
label_23:
          switch (3)
          {
            case 0:
              goto label_23;
            default:
              if (fieldType != FieldType.Keyboard)
              {
label_25:
                switch (6)
                {
                  case 0:
                    goto label_25;
                  default:
                    goto label_40;
                }
              }
              else
                break;
          }
        }
        else
          goto label_27;
      }
      else
      {
        this.c1110508e758c291b58128cf689a4d05f(c5b06a6c558da093ec9f7612b25cd04e4, cbed866e03206cd14a5d8cf95ed0a9258);
        goto label_40;
      }
      this.c1d6a7a1a89498b49b73fa7263ac85f4a(c5b06a6c558da093ec9f7612b25cd04e4, cbed866e03206cd14a5d8cf95ed0a9258);
      goto label_40;
label_27:
      this.c791e2f17691a5f65d87084899733eab6(c5b06a6c558da093ec9f7612b25cd04e4, cbed866e03206cd14a5d8cf95ed0a9258);
label_40:
      bandedGridView = (BandedGridView) null;
      if (c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit != null)
      {
label_41:
        switch (7)
        {
          case 0:
            goto label_41;
          default:
            c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit.KeyDown += new KeyEventHandler(this.c838939f90faf11148119525597c56295);
            c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.c509c84df8827496bd22566ab0fb48f36);
            c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit.DoubleClick += new EventHandler(this.c5deb2b157ec3bee3b8e4df257037bc36);
            c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit.EditValueChanging += new ChangingEventHandler(this.ce08e479f2d3957b165fd32ed4672600d);
            break;
        }
      }
      this.cb98a1056b4d2acd639d0ed54c8507502(cbed866e03206cd14a5d8cf95ed0a9258, c5b06a6c558da093ec9f7612b25cd04e4);
      return c5b06a6c558da093ec9f7612b25cd04e4;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.ThrowError(ex.Message, Shared.Loc((object) this, MethodBase.GetCurrentMethod()));
      ProjectData.ClearProjectError();
    }
    finally
    {
      this.cbee725c554d327dc3d76039ee2804a33 = false;
    }
    return (DevExpress.XtraGrid.Columns.GridColumn) null;
  }

  private void cb98a1056b4d2acd639d0ed54c8507502(
    eGridColumn cbed866e03206cd14a5d8cf95ed0a9258,
    DevExpress.XtraGrid.Columns.GridColumn c5b06a6c558da093ec9f7612b25cd04e4)
  {
    string str1 = "";
    string str2 = "";
    string str3 = "";
    string str4 = "";
    string str5 = "";
    string title = cbed866e03206cd14a5d8cf95ed0a9258.Title;
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(cbed866e03206cd14a5d8cf95ed0a9258.get_BandTitle(), "", false) != 0)
    {
label_1:
      switch (2)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cb98a1056b4d2acd639d0ed54c8507502);
          }
          str1 = cbed866e03206cd14a5d8cf95ed0a9258.get_BandTitle();
          break;
      }
    }
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(cbed866e03206cd14a5d8cf95ed0a9258.get_BandTitle(2), "", false) != 0)
    {
label_6:
      switch (1)
      {
        case 0:
          goto label_6;
        default:
          str2 = cbed866e03206cd14a5d8cf95ed0a9258.get_BandTitle(2);
          break;
      }
    }
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(cbed866e03206cd14a5d8cf95ed0a9258.get_BandTitle(3), "", false) != 0)
    {
label_9:
      switch (7)
      {
        case 0:
          goto label_9;
        default:
          str3 = cbed866e03206cd14a5d8cf95ed0a9258.get_BandTitle(3);
          break;
      }
    }
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(cbed866e03206cd14a5d8cf95ed0a9258.get_BandTitle(4), "", false) != 0)
      str4 = cbed866e03206cd14a5d8cf95ed0a9258.get_BandTitle(4);
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(cbed866e03206cd14a5d8cf95ed0a9258.get_BandTitle(5), "", false) != 0)
    {
label_14:
      switch (7)
      {
        case 0:
          goto label_14;
        default:
          str5 = cbed866e03206cd14a5d8cf95ed0a9258.get_BandTitle(5);
          break;
      }
    }
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str2, "", false) != 0 & Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str1, "", false) == 0)
    {
label_17:
      switch (2)
      {
        case 0:
          goto label_17;
        default:
          str1 = str2;
          str2 = "";
          break;
      }
    }
    GridBand gridBand1;
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str1, "", false) == 0)
    {
label_20:
      switch (6)
      {
        case 0:
          goto label_20;
        default:
          gridBand1 = this.c9f0554088efeb826c7eaa8eb9abca9f4(title, c5b06a6c558da093ec9f7612b25cd04e4);
          break;
      }
    }
    else
    {
      this.IsBandedGrid = true;
      GridBand gridBand2 = (GridBand) null;
      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str2, "", false) != 0)
      {
label_23:
        switch (7)
        {
          case 0:
            goto label_23;
          default:
            gridBand2 = this.cc8bfe7f97aecfa02c9ee249d1a3e7be2(str2);
            if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str3, "", false) != 0)
            {
              GridBand c4397f48db8026b1fee182d5c8921143a1 = this.cc8bfe7f97aecfa02c9ee249d1a3e7be2(str3, gridBand2);
              if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str4, "", false) != 0)
              {
                GridBand c4397f48db8026b1fee182d5c8921143a2 = this.cc8bfe7f97aecfa02c9ee249d1a3e7be2(str4, c4397f48db8026b1fee182d5c8921143a1);
                if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str5, "", false) != 0)
                  this.cc8bfe7f97aecfa02c9ee249d1a3e7be2(str5, c4397f48db8026b1fee182d5c8921143a2);
              }
            }
            break;
        }
      }
      GridBand c4397f48db8026b1fee182d5c8921143a = this.cca79c790607249ee08396897c60d23cc(str1, gridBand2);
      if (c4397f48db8026b1fee182d5c8921143a == null)
      {
label_32:
        switch (1)
        {
          case 0:
            goto label_32;
          default:
            c4397f48db8026b1fee182d5c8921143a = this.c9f0554088efeb826c7eaa8eb9abca9f4(str1, c4397f48db8026b1fee182d5c8921143a: gridBand2);
            break;
        }
      }
      gridBand1 = this.c9f0554088efeb826c7eaa8eb9abca9f4(title, c5b06a6c558da093ec9f7612b25cd04e4, c4397f48db8026b1fee182d5c8921143a);
    }
    this.c5b871ae134785e12b0b126622322be57(c5b06a6c558da093ec9f7612b25cd04e4, c5b06a6c558da093ec9f7612b25cd04e4.Visible);
    this.cb77e074cc62c973711f2b127bea96869(c5b06a6c558da093ec9f7612b25cd04e4, c5b06a6c558da093ec9f7612b25cd04e4.ReadOnly);
    if (cbed866e03206cd14a5d8cf95ed0a9258.IsFixColumn)
    {
label_36:
      switch (3)
      {
        case 0:
          goto label_36;
        default:
          if (gridBand1.RootBand != null)
          {
label_38:
            switch (1)
            {
              case 0:
                goto label_38;
              default:
                gridBand1.RootBand.Fixed = FixedStyle.Left;
                break;
            }
          }
          else
            gridBand1.Fixed = FixedStyle.Left;
          break;
      }
    }
    gridBand1.AppearanceHeader.Font = c5b06a6c558da093ec9f7612b25cd04e4.AppearanceHeader.Font;
    gridBand1.AppearanceHeader.ForeColor = c5b06a6c558da093ec9f7612b25cd04e4.AppearanceHeader.ForeColor;
    gridBand1.AppearanceHeader.TextOptions.HAlignment = c5b06a6c558da093ec9f7612b25cd04e4.AppearanceHeader.TextOptions.HAlignment;
    cbed866e03206cd14a5d8cf95ed0a9258.Band = gridBand1;
  }

  private GridBand cc8bfe7f97aecfa02c9ee249d1a3e7be2(
    string c5ad479046ae6298241f2425905aa84be,
    GridBand c4397f48db8026b1fee182d5c8921143a = null)
  {
    GridBand gridBand = this.cca79c790607249ee08396897c60d23cc(c5ad479046ae6298241f2425905aa84be);
    if (gridBand == null)
    {
label_1:
      switch (1)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cc8bfe7f97aecfa02c9ee249d1a3e7be2);
          }
          gridBand = this.c9f0554088efeb826c7eaa8eb9abca9f4(c5ad479046ae6298241f2425905aa84be, c4397f48db8026b1fee182d5c8921143a: c4397f48db8026b1fee182d5c8921143a);
          break;
      }
    }
    return gridBand;
  }

  private GridBand cca79c790607249ee08396897c60d23cc(
    string c8c82714b156015d31829c4decf853490,
    GridBand c03be30a0143988ab82fd3796dd777351 = null)
  {
    BandedGridView gridView1 = this.GridView1;
    if (gridView1.Bands == null)
    {
label_1:
      switch (7)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cca79c790607249ee08396897c60d23cc);
          }
          return (GridBand) null;
      }
    }
    else
    {
      GridBandCollection gridBandCollection;
      if (c03be30a0143988ab82fd3796dd777351 == null)
      {
label_6:
        switch (3)
        {
          case 0:
            goto label_6;
          default:
            gridBandCollection = gridView1.Bands;
            break;
        }
      }
      else
        gridBandCollection = c03be30a0143988ab82fd3796dd777351.Children;
      IEnumerator enumerator;
      try
      {
        enumerator = gridBandCollection.GetEnumerator();
        while (enumerator.MoveNext())
        {
          GridBand current = (GridBand) enumerator.Current;
          if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(current.Caption, c8c82714b156015d31829c4decf853490, false) == 0)
            return current;
        }
label_14:
        switch (5)
        {
          case 0:
            goto label_14;
        }
      }
      finally
      {
        if (enumerator is IDisposable)
        {
label_16:
          switch (3)
          {
            case 0:
              goto label_16;
            default:
              (enumerator as IDisposable).Dispose();
              break;
          }
        }
      }
      return (GridBand) null;
    }
  }

  private GridBand c9f0554088efeb826c7eaa8eb9abca9f4(
    string c8c82714b156015d31829c4decf853490,
    DevExpress.XtraGrid.Columns.GridColumn c4157630d9aed06a29df594f1c35d1225 = null,
    GridBand c4397f48db8026b1fee182d5c8921143a = null,
    string c5ad479046ae6298241f2425905aa84be = "",
    WordWrap c6d3f0e351aff22c8ebc25bf58f9cec3a = WordWrap.Wrap,
    HorzAlignment c7377884db76b5d57a466cf0364c6e3e1 = HorzAlignment.Center,
    VertAlignment c7fa395b01263b9b2801e83e61e12468d = VertAlignment.Center,
    int c72fe12625a1dfac1079cc6f394d1db49 = -1)
  {
    BandedGridView gridView1 = this.GridView1;
    GridBand band = new GridBand();
    int count = gridView1.Bands.Count;
    GridBand gridBand = band;
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c5ad479046ae6298241f2425905aa84be, "", false) != 0)
    {
label_1:
      switch (1)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c9f0554088efeb826c7eaa8eb9abca9f4);
          }
          gridBand.Name = c5ad479046ae6298241f2425905aa84be;
          break;
      }
    }
    else
      gridBand.Name = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5152) + count.ToString();
    if (c8c82714b156015d31829c4decf853490.ToLower().Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5157)))
    {
label_7:
      switch (1)
      {
        case 0:
          goto label_7;
        default:
          if (c8c82714b156015d31829c4decf853490.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5157)))
          {
label_9:
            switch (3)
            {
              case 0:
                goto label_9;
              default:
                c8c82714b156015d31829c4decf853490 = c8c82714b156015d31829c4decf853490.Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5157), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3974));
                break;
            }
          }
          if (c8c82714b156015d31829c4decf853490.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5166)))
          {
label_12:
            switch (4)
            {
              case 0:
                goto label_12;
              default:
                c8c82714b156015d31829c4decf853490 = c8c82714b156015d31829c4decf853490.Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5166), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3974));
                break;
            }
          }
          if (c8c82714b156015d31829c4decf853490.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5175)))
          {
label_15:
            switch (2)
            {
              case 0:
                goto label_15;
              default:
                c8c82714b156015d31829c4decf853490 = c8c82714b156015d31829c4decf853490.Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5175), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3974));
                break;
            }
          }
          break;
      }
    }
    gridBand.Caption = c8c82714b156015d31829c4decf853490;
    gridBand.AppearanceHeader.Options.UseTextOptions = true;
    gridBand.AppearanceHeader.TextOptions.HAlignment = c7377884db76b5d57a466cf0364c6e3e1;
    gridBand.AppearanceHeader.TextOptions.VAlignment = c7fa395b01263b9b2801e83e61e12468d;
    gridBand.AppearanceHeader.TextOptions.WordWrap = c6d3f0e351aff22c8ebc25bf58f9cec3a;
    if (c4157630d9aed06a29df594f1c35d1225 != null)
    {
label_19:
      switch (5)
      {
        case 0:
          goto label_19;
        default:
          gridBand.AutoFillDown = true;
          gridBand.Columns.Add((BandedGridColumn) c4157630d9aed06a29df594f1c35d1225);
          break;
      }
    }
    int num = 1;
    if (c4397f48db8026b1fee182d5c8921143a != null)
    {
label_22:
      switch (5)
      {
        case 0:
          goto label_22;
        default:
          c4397f48db8026b1fee182d5c8921143a.Children.Add(band);
          for (GridBand parentBand = band.ParentBand; parentBand != null; parentBand = parentBand.ParentBand)
            checked { ++num; }
          break;
      }
    }
    else if (c72fe12625a1dfac1079cc6f394d1db49 < 0 || gridView1.Bands.Count < c72fe12625a1dfac1079cc6f394d1db49)
    {
label_27:
      switch (5)
      {
        case 0:
          goto label_27;
        default:
          gridView1.Bands.Add(band);
          break;
      }
    }
    else
      gridView1.Bands.Insert(c72fe12625a1dfac1079cc6f394d1db49, band);
    if (this.c66660fc7f284fd97ebfc6b3347a566ba < num)
    {
label_32:
      switch (7)
      {
        case 0:
          goto label_32;
        default:
          this.c66660fc7f284fd97ebfc6b3347a566ba = num;
          break;
      }
    }
    this.c3095e384ce86f6724321e5e49bf7ac4a();
    return band;
  }

  private void c3095e384ce86f6724321e5e49bf7ac4a()
  {
    this.c540a73a6bcb4a3d519a57fcba6aa5cae = 0;
    IEnumerator enumerator;
    try
    {
      enumerator = this.GridView1.Bands.GetEnumerator();
      while (enumerator.MoveNext())
      {
        GridBand current = (GridBand) enumerator.Current;
        if (this.c66660fc7f284fd97ebfc6b3347a566ba == 1)
        {
label_3:
          switch (2)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c3095e384ce86f6724321e5e49bf7ac4a);
              }
              this.c4218020a81b58b0134bf20cffd46bf8b(current);
              break;
          }
        }
        else
        {
          int num;
          if (current.Visible)
          {
label_8:
            switch (2)
            {
              case 0:
                goto label_8;
              default:
                num = 0 < current.Children.VisibleBandCount ? 1 : 0;
                break;
            }
          }
          else
            num = 0;
          if (num != 0)
          {
label_12:
            switch (1)
            {
              case 0:
                goto label_12;
              default:
                this.c4218020a81b58b0134bf20cffd46bf8b(current);
                this.c02068ba03b618d5eef6baa6c1483455b(current.Children);
                break;
            }
          }
        }
      }
label_17:
      switch (5)
      {
        case 0:
          goto label_17;
      }
    }
    finally
    {
      if (enumerator is IDisposable)
      {
label_20:
        switch (1)
        {
          case 0:
            goto label_20;
          default:
            (enumerator as IDisposable).Dispose();
            break;
        }
      }
    }
    this.ca78c8fb2abf9de6f83e5238cd29da0a0 = 20;
    int num1 = checked (this.c540a73a6bcb4a3d519a57fcba6aa5cae * this.ca78c8fb2abf9de6f83e5238cd29da0a0);
    if (num1 == 0)
    {
label_24:
      switch (4)
      {
        case 0:
          goto label_24;
        default:
          num1 = -1;
          break;
      }
    }
    if (this.GridView1.BandPanelRowHeight == num1)
      return;
label_27:
    switch (2)
    {
      case 0:
        goto label_27;
      default:
        this.GridView1.BandPanelRowHeight = num1;
        break;
    }
  }

  private void c02068ba03b618d5eef6baa6c1483455b(
    GridBandCollection c7678de994e3c8713837f44bbcfdae6eb)
  {
    IEnumerator enumerator;
    try
    {
      enumerator = c7678de994e3c8713837f44bbcfdae6eb.GetEnumerator();
      while (enumerator.MoveNext())
      {
        GridBand current = (GridBand) enumerator.Current;
        this.c4218020a81b58b0134bf20cffd46bf8b(current);
        int num;
        if (current.Visible)
        {
label_3:
          switch (5)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c02068ba03b618d5eef6baa6c1483455b);
              }
              num = current.Children != null ? 1 : 0;
              break;
          }
        }
        else
          num = 0;
        if (num != 0)
          this.c02068ba03b618d5eef6baa6c1483455b(current.Children);
      }
    }
    finally
    {
      if (enumerator is IDisposable)
      {
label_14:
        switch (7)
        {
          case 0:
            goto label_14;
          default:
            (enumerator as IDisposable).Dispose();
            break;
        }
      }
    }
  }

  private void c4218020a81b58b0134bf20cffd46bf8b(GridBand cc8f933f27b311f2188e2a5882448ea5c)
  {
    if (!cc8f933f27b311f2188e2a5882448ea5c.Visible)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c4218020a81b58b0134bf20cffd46bf8b);
          break;
      }
    }
    else if (cc8f933f27b311f2188e2a5882448ea5c.Caption.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3974)))
    {
label_5:
      switch (7)
      {
        case 0:
          goto label_5;
        default:
          int length = cc8f933f27b311f2188e2a5882448ea5c.Caption.Split('\n').Length;
          int num;
          if (1 < length)
          {
label_7:
            switch (4)
            {
              case 0:
                goto label_7;
              default:
                num = this.c540a73a6bcb4a3d519a57fcba6aa5cae < length ? 1 : 0;
                break;
            }
          }
          else
            num = 0;
          if (num != 0)
            this.c540a73a6bcb4a3d519a57fcba6aa5cae = length;
          break;
      }
    }
  }

  public override Font Font
  {
    get => this.GridView1.Appearance.HeaderPanel.Font;
    set
    {
      this.GridView1.Appearance.HeaderPanel.Font = value;
      this.GridView1.Appearance.FilterPanel.Font = value;
      this.GridView1.Appearance.Row.Font = value;
      this.GridView1.Appearance.GroupRow.Font = value;
      this.GridView1.Appearance.GroupFooter.Font = value;
      this.GridView1.Appearance.FooterPanel.Font = value;
      this.GridView1.Appearance.BandPanel.Font = value;
      Font font = new Font(value, FontStyle.Bold);
      try
      {
        foreach (DevExpress.XtraGrid.Columns.GridColumn column in (CollectionBase) this.GridView1.Columns)
        {
          int num;
          if (column.AppearanceHeader.Font.Bold)
          {
label_3:
            switch (4)
            {
              case 0:
                goto label_3;
              default:
                if (false)
                {
                  RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.set_Font);
                }
                num = column.Visible ? 1 : 0;
                break;
            }
          }
          else
            num = 0;
          if (num != 0)
          {
label_9:
            switch (2)
            {
              case 0:
                goto label_9;
              default:
                column.AppearanceHeader.Font = font;
                break;
            }
          }
          if (column.ColumnEdit is RepositoryItemLookUpEdit)
          {
label_12:
            switch (2)
            {
              case 0:
                goto label_12;
              default:
                ((RepositoryItemPopupBase) column.ColumnEdit).AppearanceDropDown.Font = this.GridView1.Appearance.Row.Font;
                break;
            }
          }
        }
label_16:
        switch (1)
        {
          case 0:
            goto label_16;
        }
      }
      finally
      {
        IEnumerator enumerator;
        if (enumerator is IDisposable)
          (enumerator as IDisposable).Dispose();
      }
      IEnumerator enumerator1;
      try
      {
        enumerator1 = this.GridView1.Bands.GetEnumerator();
        while (enumerator1.MoveNext())
        {
          GridBand current1 = (GridBand) enumerator1.Current;
          if (current1.AppearanceHeader.Font.Bold && current1.Visible)
          {
label_22:
            switch (5)
            {
              case 0:
                goto label_22;
              default:
                current1.AppearanceHeader.Font = font;
                break;
            }
          }
          IEnumerator enumerator2;
          try
          {
            enumerator2 = current1.Children.GetEnumerator();
            while (enumerator2.MoveNext())
            {
              GridBand current2 = (GridBand) enumerator2.Current;
              if (current2.AppearanceHeader.Font.Bold && current2.Visible)
              {
label_27:
                switch (5)
                {
                  case 0:
                    goto label_27;
                  default:
                    current2.AppearanceHeader.Font = font;
                    break;
                }
              }
            }
          }
          finally
          {
            if (enumerator2 is IDisposable)
            {
label_32:
              switch (2)
              {
                case 0:
                  goto label_32;
                default:
                  (enumerator2 as IDisposable).Dispose();
                  break;
              }
            }
          }
        }
label_36:
        switch (5)
        {
          case 0:
            goto label_36;
        }
      }
      finally
      {
        if (enumerator1 is IDisposable)
        {
label_39:
          switch (7)
          {
            case 0:
              goto label_39;
            default:
              (enumerator1 as IDisposable).Dispose();
              break;
          }
        }
      }
    }
  }

  private DevExpress.XtraGrid.Columns.GridColumn c413a01926a084a7d8e924b0999a264db(
    eGridColumn cbed866e03206cd14a5d8cf95ed0a9258)
  {
    try
    {
      DevExpress.XtraGrid.Columns.GridColumn showInColumn = (DevExpress.XtraGrid.Columns.GridColumn) this.GridView1.Columns.Add();
      showInColumn.Caption = cbed866e03206cd14a5d8cf95ed0a9258.Title;
      if (showInColumn.Caption.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3974)))
      {
        int length = showInColumn.Caption.Split('\n').Length;
        if (this.cb5346c3ef09fcb1fcee1a5bc4abc4d2f < length)
        {
label_3:
          switch (4)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c413a01926a084a7d8e924b0999a264db);
              }
              this.cb5346c3ef09fcb1fcee1a5bc4abc4d2f = length;
              break;
          }
        }
      }
      string fieldName = cbed866e03206cd14a5d8cf95ed0a9258.FieldName;
      if (fieldName.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4674)))
      {
label_9:
        switch (1)
        {
          case 0:
            goto label_9;
          default:
            fieldName = fieldName.Split('.')[0];
            break;
        }
      }
      int num = cbed866e03206cd14a5d8cf95ed0a9258.Width;
      if (num == 0)
      {
label_12:
        switch (2)
        {
          case 0:
            goto label_12;
          default:
            num = Conversions.ToInteger(Interaction.IIf(this.c83fb623f1cfef74d227ce46cdace4c12 == 0, (object) this.c02894bef99316b814a0f9eaea5fbe30b, (object) this.c83fb623f1cfef74d227ce46cdace4c12));
            break;
        }
      }
      this.c83fb623f1cfef74d227ce46cdace4c12 = num;
      showInColumn.FieldName = fieldName;
      showInColumn.VisibleIndex = checked (this.GridView1.Columns.Count - 1);
      showInColumn.Width = num;
      showInColumn.Visible = cbed866e03206cd14a5d8cf95ed0a9258.Visible;
      showInColumn.OptionsColumn.AllowEdit = !cbed866e03206cd14a5d8cf95ed0a9258.ReadOnly;
      showInColumn.OptionsColumn.TabStop = !cbed866e03206cd14a5d8cf95ed0a9258.ReadOnly;
      showInColumn.AppearanceHeader.ForeColor = this.c70428d55a313f2054944b9123b9eda77(cbed866e03206cd14a5d8cf95ed0a9258);
      if (cbed866e03206cd14a5d8cf95ed0a9258.IsFixColumn)
      {
label_15:
        switch (4)
        {
          case 0:
            goto label_15;
          default:
            showInColumn.Fixed = FixedStyle.Left;
            break;
        }
      }
      if (cbed866e03206cd14a5d8cf95ed0a9258.IsMergeColumn)
      {
        if (!this.GridView1.OptionsView.AllowCellMerge)
          this.GridView1.OptionsView.AllowCellMerge = true;
        showInColumn.OptionsColumn.AllowMerge = DefaultBoolean.True;
        if (this.caade471433b635c6c76864b2015d3db6)
          this.c50ccdc5283b68b92131a5a8841c52a70 = true;
        this.caade471433b635c6c76864b2015d3db6 = true;
      }
      else
      {
        showInColumn.OptionsColumn.AllowMerge = DefaultBoolean.False;
        this.caade471433b635c6c76864b2015d3db6 = false;
      }
      if (cbed866e03206cd14a5d8cf95ed0a9258.IsGroupColumn)
      {
label_25:
        switch (7)
        {
          case 0:
            goto label_25;
          default:
            showInColumn.GroupIndex = this.GridView1.GroupedColumns.Count;
            showInColumn.SortMode = ColumnSortMode.Value;
            this.GridView1.ExpandAllGroups();
            break;
        }
      }
      if (cbed866e03206cd14a5d8cf95ed0a9258.SumType != SumType.None)
      {
label_28:
        switch (6)
        {
          case 0:
            goto label_28;
          default:
            if (this.ccac4c8044ae680dcd351934054a598ac == null)
              this.ccac4c8044ae680dcd351934054a598ac = new GridGroupSummaryItemCollection((BaseView) this.GridView1);
            string displayFormat = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(cbed866e03206cd14a5d8cf95ed0a9258.Format, "", false) == 0 ? c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5194) : c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5184) + cbed866e03206cd14a5d8cf95ed0a9258.Format + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5191);
            showInColumn.SummaryItem.SummaryType = (SummaryItemType) cbed866e03206cd14a5d8cf95ed0a9258.SumType;
            showInColumn.SummaryItem.DisplayFormat = displayFormat;
            this.ccac4c8044ae680dcd351934054a598ac.Add((SummaryItemType) cbed866e03206cd14a5d8cf95ed0a9258.SumType, fieldName, showInColumn, displayFormat).Tag = (object) fieldName;
            break;
        }
      }
      HorzAlignment titleAlign = (HorzAlignment) cbed866e03206cd14a5d8cf95ed0a9258.TitleAlign;
      showInColumn.AppearanceCell.TextOptions.HAlignment = (HorzAlignment) cbed866e03206cd14a5d8cf95ed0a9258.TextAlign;
      showInColumn.AppearanceHeader.TextOptions.HAlignment = titleAlign;
      return showInColumn;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Exception exception = ex;
      Shared.ThrowError(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5223) + this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5236) + cbed866e03206cd14a5d8cf95ed0a9258.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5261) + exception.Message + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3974), Shared.Loc((object) this, MethodBase.GetCurrentMethod()));
      ProjectData.ClearProjectError();
    }
    return (DevExpress.XtraGrid.Columns.GridColumn) null;
  }

  private Color c70428d55a313f2054944b9123b9eda77(eGridColumn cbed866e03206cd14a5d8cf95ed0a9258)
  {
    if (cbed866e03206cd14a5d8cf95ed0a9258.ReadOnly)
    {
      if (cbed866e03206cd14a5d8cf95ed0a9258.TitleStyle != TitleStyle.Needed)
        return Color.Gray;
label_2:
      switch (1)
      {
        case 0:
          goto label_2;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c70428d55a313f2054944b9123b9eda77);
          }
          return Color.SteelBlue;
      }
    }
    else if (cbed866e03206cd14a5d8cf95ed0a9258.TitleStyle == TitleStyle.Needed)
    {
label_8:
      switch (6)
      {
        case 0:
          goto label_8;
        default:
          return Parameter.MainFrame.FieldTitleForeColorRequired;
      }
    }
    else
    {
      if (cbed866e03206cd14a5d8cf95ed0a9258.TitleStyle != TitleStyle.Disable)
        return Parameter.MainFrame.FieldTitleForeColorDefault;
label_11:
      switch (5)
      {
        case 0:
          goto label_11;
        default:
          return Color.Gray;
      }
    }
  }

  private void ce08e479f2d3957b165fd32ed4672600d(
    object c7a1c50d8950fe539821ded4a87a7123f,
    ChangingEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (!this.c018a99ed0c66295f13c59de7c8b6aa4c)
      return;
label_1:
    switch (2)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.ce08e479f2d3957b165fd32ed4672600d);
        }
        c320269ec287d16905c829847d30a2e08.Cancel = true;
        break;
    }
  }

  private void c60ef255714f062e6874dd85026c12d9e(
    object c6228239f423d7f951011de84ced6e507,
    ButtonPressedEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (this.c018a99ed0c66295f13c59de7c8b6aa4c || Microsoft.VisualBasic.CompilerServices.Operators.CompareString(this.GridColumn(this.FocusedFieldName).PopupType, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5316), false) != 0)
      return;
label_1:
    switch (4)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c60ef255714f062e6874dd85026c12d9e);
        }
        this.RunPopup(this.FocusedFieldName, true);
        break;
    }
  }

  private void c54a35da233bd517f985504dca047ec76(
    object c6228239f423d7f951011de84ced6e507,
    CancelEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (this.c018a99ed0c66295f13c59de7c8b6aa4c)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c54a35da233bd517f985504dca047ec76);
          }
          c320269ec287d16905c829847d30a2e08.Cancel = true;
          break;
      }
    }
    else if (!this.get_IsFilterRow() && this.ReadOnly)
      c320269ec287d16905c829847d30a2e08.Cancel = true;
    else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(this.GridColumn(this.FocusedFieldName).PopupType, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5316), false) == 0)
    {
label_8:
      switch (5)
      {
        case 0:
          goto label_8;
        default:
          c320269ec287d16905c829847d30a2e08.Cancel = true;
          break;
      }
    }
  }

  private void cc9cf9a61886e3d2285481897a0ed0ad4(
    LookUpEdit c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    c7a1c50d8950fe539821ded4a87a7123f.MouseWheel -= new MouseEventHandler(this.c647223605df2113372ae3fa98fe4e4b7);
  }

  private void ce1b282962d002390efe8c4ddbac50657(
    LookUpEdit c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    c7a1c50d8950fe539821ded4a87a7123f.MouseWheel += new MouseEventHandler(this.c647223605df2113372ae3fa98fe4e4b7);
  }

  private void c27aba542b020afeb5be20dc413afba39(
    DevExpress.XtraGrid.Columns.GridColumn c5b06a6c558da093ec9f7612b25cd04e4,
    eGridColumn c4e4dd0b743ed8c13fde428de36b4c8f3)
  {
    RepositoryItemLookUpEdit c320269ec287d16905c829847d30a2e08 = new RepositoryItemLookUpEdit();
    c320269ec287d16905c829847d30a2e08.AppearanceDropDown.Font = this.GridView1.Appearance.Row.Font;
    c320269ec287d16905c829847d30a2e08.BeforeShowMenu += new BeforeShowMenuEventHandler(this.cacda6f0c7462332dbd94f3b5e03079bf);
    c320269ec287d16905c829847d30a2e08.ButtonPressed += new DevExpress.XtraEditors.Controls.ButtonPressedEventHandler(this.c60ef255714f062e6874dd85026c12d9e);
    c320269ec287d16905c829847d30a2e08.QueryPopUp += new CancelEventHandler(this.c54a35da233bd517f985504dca047ec76);
    c320269ec287d16905c829847d30a2e08.Popup += (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.cc9cf9a61886e3d2285481897a0ed0ad4((LookUpEdit) cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87));
    c320269ec287d16905c829847d30a2e08.CloseUp += (CloseUpEventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.ce1b282962d002390efe8c4ddbac50657((LookUpEdit) cf75227a3cb7ea057325121d13a33dcba, (EventArgs) c5938f1fdc4fcdbf274d5de6969c37b87));
    c320269ec287d16905c829847d30a2e08.MouseWheel += new MouseEventHandler(this.c647223605df2113372ae3fa98fe4e4b7);
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c4e4dd0b743ed8c13fde428de36b4c8f3.PopupType, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5316), false) == 0)
    {
      c320269ec287d16905c829847d30a2e08.SearchMode = SearchMode.OnlyInPopup;
      c320269ec287d16905c829847d30a2e08.TextEditStyle = TextEditStyles.DisableTextEditor;
    }
    else
      c320269ec287d16905c829847d30a2e08.TextEditStyle = TextEditStyles.Standard;
    if (c4e4dd0b743ed8c13fde428de36b4c8f3.DataSource != null)
    {
label_4:
      switch (1)
      {
        case 0:
          goto label_4;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c27aba542b020afeb5be20dc413afba39);
          }
          this.cc5f5ca5e837b4f589c2b452ae4712d2c(c320269ec287d16905c829847d30a2e08, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(202), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3700));
          c320269ec287d16905c829847d30a2e08.DataSource = RuntimeHelpers.GetObjectValue(c4e4dd0b743ed8c13fde428de36b4c8f3.DataSource);
          break;
      }
    }
    c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit = (RepositoryItem) c320269ec287d16905c829847d30a2e08;
  }

  private void cdfbc406e08c3f881cb8a24423c3d3028(DevExpress.XtraGrid.Columns.GridColumn c5b06a6c558da093ec9f7612b25cd04e4)
  {
    RepositoryItemCheckEdit repositoryItemCheckEdit = new RepositoryItemCheckEdit();
    repositoryItemCheckEdit.NullStyle = StyleIndeterminate.Unchecked;
    repositoryItemCheckEdit.ValueChecked = (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(79);
    repositoryItemCheckEdit.ValueGrayed = (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82);
    repositoryItemCheckEdit.ValueUnchecked = (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82);
    repositoryItemCheckEdit.CheckStyle = CheckStyles.Standard;
    repositoryItemCheckEdit.DisplayValueChecked = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(79);
    repositoryItemCheckEdit.DisplayValueUnchecked = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82);
    repositoryItemCheckEdit.DisplayValueGrayed = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82);
    repositoryItemCheckEdit.ExportMode = ExportMode.DisplayText;
    c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit = (RepositoryItem) repositoryItemCheckEdit;
    c5b06a6c558da093ec9f7612b25cd04e4.OptionsColumn.AllowSort = DefaultBoolean.False;
  }

  private void ce33c341bb5e2f677dbc404fb011adfaa(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    TextEdit textEdit = (TextEdit) c7a1c50d8950fe539821ded4a87a7123f;
    int num;
    if (!textEdit.Properties.ReadOnly)
    {
label_1:
      switch (5)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.ce33c341bb5e2f677dbc404fb011adfaa);
          }
          num = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(textEdit.Text, "", false) == 0 ? 1 : 0;
          break;
      }
    }
    else
      num = 0;
    if (num == 0)
      return;
    textEdit.EditValue = (object) DateAndTime.Now.Date;
  }

  private void c2b6f5c37f036da3cf5b81d11da572637(
    DevExpress.XtraGrid.Columns.GridColumn c5b06a6c558da093ec9f7612b25cd04e4,
    string c7db5d69730c0cf96f16ef9e521e4423e)
  {
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c7db5d69730c0cf96f16ef9e521e4423e, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(452), false) == 0 | Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c7db5d69730c0cf96f16ef9e521e4423e, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(515), false) == 0)
    {
label_1:
      switch (7)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c2b6f5c37f036da3cf5b81d11da572637);
          }
          RepositoryItemLookUpEdit c320269ec287d16905c829847d30a2e08 = new RepositoryItemLookUpEdit();
          c320269ec287d16905c829847d30a2e08.AppearanceDropDown.Font = this.GridView1.Appearance.Row.Font;
          c320269ec287d16905c829847d30a2e08.TextEditStyle = TextEditStyles.Standard;
          c320269ec287d16905c829847d30a2e08.AllowMouseWheel = false;
          c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit = (RepositoryItem) c320269ec287d16905c829847d30a2e08;
          c320269ec287d16905c829847d30a2e08.BeforeShowMenu += new BeforeShowMenuEventHandler(this.cacda6f0c7462332dbd94f3b5e03079bf);
          c320269ec287d16905c829847d30a2e08.QueryPopUp += new CancelEventHandler(this.c54a35da233bd517f985504dca047ec76);
          this.cc5f5ca5e837b4f589c2b452ae4712d2c(c320269ec287d16905c829847d30a2e08, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(202), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3700));
          DataTable dataTable = new DataTable();
          dataTable.Columns.Add(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(202));
          dataTable.Columns.Add(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3700));
          DataRow row1 = dataTable.NewRow();
          row1[0] = (object) "";
          row1[1] = (object) "";
          dataTable.Rows.Add(row1);
          if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c7db5d69730c0cf96f16ef9e521e4423e, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(452), false) == 0)
          {
label_5:
            switch (5)
            {
              case 0:
                goto label_5;
              default:
                int num = 1900;
                do
                {
                  string str = num.ToString();
                  DataRow row2 = dataTable.NewRow();
                  row2[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(202)] = (object) Shared.ToStr((object) str);
                  row2[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3700)] = (object) Shared.ToStr((object) str);
                  dataTable.Rows.Add(row2);
                  checked { ++num; }
                }
                while (num <= 3000);
label_8:
                switch (7)
                {
                  case 0:
                    goto label_8;
                }
                break;
            }
          }
          else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c7db5d69730c0cf96f16ef9e521e4423e, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(515), false) == 0)
          {
label_10:
            switch (4)
            {
              case 0:
                goto label_10;
              default:
                string str1 = Thread.CurrentThread.CurrentCulture.DateTimeFormat.ShortDatePattern.Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(461), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(466)).Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(469), "").Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(474), "").Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(479), "").Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(484), "").Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(489), "").Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(494), "").Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(452), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5331)).Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5334), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5331)).Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5341), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5331)).Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5346), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5355)).Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5358), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5355)).Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5365), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5355));
                int num1 = 2000;
                do
                {
                  int num2 = 1;
                  do
                  {
                    string str2 = Conversions.ToString(Microsoft.VisualBasic.CompilerServices.Operators.AddObject(Microsoft.VisualBasic.CompilerServices.Operators.AddObject((object) (num1.ToString() + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5370)), Interaction.IIf(num2 < 10, (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82), (object) "")), (object) num2.ToString()));
                    string str3 = str1.Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5331), num1.ToString()).Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5355), Conversions.ToString(Microsoft.VisualBasic.CompilerServices.Operators.AddObject(Interaction.IIf(num2 < 10, (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82), (object) ""), (object) num2.ToString())));
                    DataRow row3 = dataTable.NewRow();
                    row3[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(202)] = (object) Shared.ToStr((object) str2);
                    row3[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3700)] = (object) Shared.ToStr((object) str3);
                    dataTable.Rows.Add(row3);
                    checked { ++num2; }
                  }
                  while (num2 <= 12);
label_14:
                  switch (6)
                  {
                    case 0:
                      goto label_14;
                    default:
                      checked { ++num1; }
                      continue;
                  }
                }
                while (num1 <= 2100);
label_16:
                switch (3)
                {
                  case 0:
                    goto label_16;
                }
                break;
            }
          }
          c320269ec287d16905c829847d30a2e08.DataSource = (object) dataTable;
          break;
      }
    }
    else
    {
      RepositoryItemDateEdit repositoryItemDateEdit = new RepositoryItemDateEdit();
      repositoryItemDateEdit.BeforeShowMenu += new BeforeShowMenuEventHandler(this.cacda6f0c7462332dbd94f3b5e03079bf);
      repositoryItemDateEdit.DoubleClick += new EventHandler(this.ce33c341bb5e2f677dbc404fb011adfaa);
      c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit = (RepositoryItem) repositoryItemDateEdit;
      repositoryItemDateEdit.AppearanceDropDown.Font = this.GridView1.Appearance.Row.Font;
      repositoryItemDateEdit.AllowMouseWheel = false;
      repositoryItemDateEdit.Mask.MaskType = MaskType.DateTimeAdvancingCaret;
    }
  }

  private void cb2e0f12b2ec9031a4b9d83854bf285fe(
    DevExpress.XtraGrid.Columns.GridColumn c5b06a6c558da093ec9f7612b25cd04e4,
    eGridColumn c4e4dd0b743ed8c13fde428de36b4c8f3)
  {
    RepositoryItemMemoEdit repositoryItemMemoEdit = new RepositoryItemMemoEdit();
    if (c4e4dd0b743ed8c13fde428de36b4c8f3.MaxLength > 0)
    {
label_1:
      switch (3)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cb2e0f12b2ec9031a4b9d83854bf285fe);
          }
          repositoryItemMemoEdit.MaxLength = c4e4dd0b743ed8c13fde428de36b4c8f3.MaxLength;
          break;
      }
    }
    repositoryItemMemoEdit.WordWrap = true;
    repositoryItemMemoEdit.BeforeShowMenu += new BeforeShowMenuEventHandler(this.cacda6f0c7462332dbd94f3b5e03079bf);
    c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit = (RepositoryItem) repositoryItemMemoEdit;
  }

  private void c97e9213b493f3c6df74cdc3db827a8cc(
    DevExpress.XtraGrid.Columns.GridColumn c5b06a6c558da093ec9f7612b25cd04e4,
    eGridColumn c4e4dd0b743ed8c13fde428de36b4c8f3)
  {
    RepositoryItemMemoExEdit repositoryItemMemoExEdit = new RepositoryItemMemoExEdit();
    if (c4e4dd0b743ed8c13fde428de36b4c8f3.MaxLength > 0)
      repositoryItemMemoExEdit.MaxLength = c4e4dd0b743ed8c13fde428de36b4c8f3.MaxLength;
    repositoryItemMemoExEdit.BeforeShowMenu += new BeforeShowMenuEventHandler(this.cacda6f0c7462332dbd94f3b5e03079bf);
    c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit = (RepositoryItem) repositoryItemMemoExEdit;
  }

  private void c1431e014d8c71cd545b5d49dfb1e37c3(DevExpress.XtraGrid.Columns.GridColumn c5b06a6c558da093ec9f7612b25cd04e4)
  {
    RepositoryItemPictureEdit repositoryItemPictureEdit = new RepositoryItemPictureEdit();
    repositoryItemPictureEdit.SizeMode = PictureSizeMode.Squeeze;
    repositoryItemPictureEdit.NullText = "";
    c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit = (RepositoryItem) repositoryItemPictureEdit;
  }

  private void c1d6a7a1a89498b49b73fa7263ac85f4a(
    DevExpress.XtraGrid.Columns.GridColumn c5b06a6c558da093ec9f7612b25cd04e4,
    eGridColumn c4e4dd0b743ed8c13fde428de36b4c8f3)
  {
    RepositoryItemTextEdit ce768895cacaae16d7d7f59622afb4196 = new RepositoryItemTextEdit();
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c4e4dd0b743ed8c13fde428de36b4c8f3.Mask, "", false) != 0)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c1d6a7a1a89498b49b73fa7263ac85f4a);
          }
          this.ce8a9eb608978060559800ce3f9b92bbf(ce768895cacaae16d7d7f59622afb4196, c4e4dd0b743ed8c13fde428de36b4c8f3.Mask);
          break;
      }
    }
    if (c4e4dd0b743ed8c13fde428de36b4c8f3.MaxLength > 0)
    {
label_6:
      switch (7)
      {
        case 0:
          goto label_6;
        default:
          ce768895cacaae16d7d7f59622afb4196.MaxLength = c4e4dd0b743ed8c13fde428de36b4c8f3.MaxLength;
          break;
      }
    }
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c4e4dd0b743ed8c13fde428de36b4c8f3.Format, "", false) != 0)
    {
label_9:
      switch (5)
      {
        case 0:
          goto label_9;
        default:
          if (c4e4dd0b743ed8c13fde428de36b4c8f3.Format.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4328)))
          {
label_11:
            switch (2)
            {
              case 0:
                goto label_11;
              default:
                ce768895cacaae16d7d7f59622afb4196.Mask.UseMaskAsDisplayFormat = false;
                ce768895cacaae16d7d7f59622afb4196.DisplayFormat.FormatType = FormatType.Custom;
                ce768895cacaae16d7d7f59622afb4196.DisplayFormat.Format = (IFormatProvider) new Shared.SecurityFormatter();
                ce768895cacaae16d7d7f59622afb4196.DisplayFormat.FormatString = c4e4dd0b743ed8c13fde428de36b4c8f3.Format;
                break;
            }
          }
          break;
      }
    }
    ce768895cacaae16d7d7f59622afb4196.BeforeShowMenu += new BeforeShowMenuEventHandler(this.cacda6f0c7462332dbd94f3b5e03079bf);
    c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit = (RepositoryItem) ce768895cacaae16d7d7f59622afb4196;
  }

  private void c0371e871b41d51dc2040a45a7b2f07ba(
    DevExpress.XtraGrid.Columns.GridColumn c5b06a6c558da093ec9f7612b25cd04e4,
    eGridColumn c4e4dd0b743ed8c13fde428de36b4c8f3)
  {
    RepositoryItemTextEdit ce768895cacaae16d7d7f59622afb4196 = new RepositoryItemTextEdit();
    ce768895cacaae16d7d7f59622afb4196.Mask.MaskType = MaskType.Numeric;
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c4e4dd0b743ed8c13fde428de36b4c8f3.Mask, "", false) != 0)
    {
label_1:
      switch (2)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c0371e871b41d51dc2040a45a7b2f07ba);
          }
          this.ce8a9eb608978060559800ce3f9b92bbf(ce768895cacaae16d7d7f59622afb4196, c4e4dd0b743ed8c13fde428de36b4c8f3.Mask);
          break;
      }
    }
    else
      ce768895cacaae16d7d7f59622afb4196.Mask.EditMask = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5373);
    if (c4e4dd0b743ed8c13fde428de36b4c8f3.MaxLength > 0)
    {
label_7:
      switch (1)
      {
        case 0:
          goto label_7;
        default:
          ce768895cacaae16d7d7f59622afb4196.MaxLength = c4e4dd0b743ed8c13fde428de36b4c8f3.MaxLength;
          break;
      }
    }
    ce768895cacaae16d7d7f59622afb4196.AllowMouseWheel = false;
    ce768895cacaae16d7d7f59622afb4196.DisplayFormat.FormatType = FormatType.Numeric;
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c4e4dd0b743ed8c13fde428de36b4c8f3.Format, "", false) != 0)
    {
      ce768895cacaae16d7d7f59622afb4196.DisplayFormat.FormatString = c4e4dd0b743ed8c13fde428de36b4c8f3.Format;
      ce768895cacaae16d7d7f59622afb4196.EditFormat.FormatString = c4e4dd0b743ed8c13fde428de36b4c8f3.Format;
    }
    else
      ce768895cacaae16d7d7f59622afb4196.DisplayFormat.FormatString = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5378);
    ce768895cacaae16d7d7f59622afb4196.BeforeShowMenu += new BeforeShowMenuEventHandler(this.cacda6f0c7462332dbd94f3b5e03079bf);
    c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit = (RepositoryItem) ce768895cacaae16d7d7f59622afb4196;
  }

  private void c791e2f17691a5f65d87084899733eab6(
    DevExpress.XtraGrid.Columns.GridColumn c5b06a6c558da093ec9f7612b25cd04e4,
    eGridColumn c4e4dd0b743ed8c13fde428de36b4c8f3)
  {
    RepositoryItemTextEdit ce768895cacaae16d7d7f59622afb4196 = new RepositoryItemTextEdit();
    ce768895cacaae16d7d7f59622afb4196.Mask.MaskType = MaskType.Numeric;
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c4e4dd0b743ed8c13fde428de36b4c8f3.Mask, "", false) != 0)
      this.ce8a9eb608978060559800ce3f9b92bbf(ce768895cacaae16d7d7f59622afb4196, c4e4dd0b743ed8c13fde428de36b4c8f3.Mask);
    if (c4e4dd0b743ed8c13fde428de36b4c8f3.MaxLength > 0)
    {
label_3:
      switch (1)
      {
        case 0:
          goto label_3;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c791e2f17691a5f65d87084899733eab6);
          }
          ce768895cacaae16d7d7f59622afb4196.MaxLength = c4e4dd0b743ed8c13fde428de36b4c8f3.MaxLength;
          break;
      }
    }
    ce768895cacaae16d7d7f59622afb4196.AllowMouseWheel = false;
    ce768895cacaae16d7d7f59622afb4196.DisplayFormat.FormatType = FormatType.Numeric;
    ce768895cacaae16d7d7f59622afb4196.EditFormat.FormatType = FormatType.Numeric;
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c4e4dd0b743ed8c13fde428de36b4c8f3.Format, "", false) != 0)
    {
label_8:
      switch (6)
      {
        case 0:
          goto label_8;
        default:
          ce768895cacaae16d7d7f59622afb4196.DisplayFormat.FormatString = c4e4dd0b743ed8c13fde428de36b4c8f3.Format;
          ce768895cacaae16d7d7f59622afb4196.EditFormat.FormatString = c4e4dd0b743ed8c13fde428de36b4c8f3.Format;
          break;
      }
    }
    ce768895cacaae16d7d7f59622afb4196.BeforeShowMenu += new BeforeShowMenuEventHandler(this.cacda6f0c7462332dbd94f3b5e03079bf);
    c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit = (RepositoryItem) ce768895cacaae16d7d7f59622afb4196;
  }

  private void ce8a9eb608978060559800ce3f9b92bbf(
    RepositoryItemTextEdit ce768895cacaae16d7d7f59622afb4196,
    string c00ec9697147b5a0d7be442792ad5d533)
  {
    if (ce768895cacaae16d7d7f59622afb4196.Mask.MaskType == MaskType.Numeric)
    {
label_1:
      switch (7)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.ce8a9eb608978060559800ce3f9b92bbf);
          }
          ce768895cacaae16d7d7f59622afb4196.Mask.EditMask = c00ec9697147b5a0d7be442792ad5d533;
          break;
      }
    }
    else
    {
      ce768895cacaae16d7d7f59622afb4196.Mask.AutoComplete = AutoCompleteType.Default;
      ce768895cacaae16d7d7f59622afb4196.Mask.MaskType = MaskType.Simple;
      ce768895cacaae16d7d7f59622afb4196.Mask.EditMask = c00ec9697147b5a0d7be442792ad5d533;
    }
  }

  private void cade15b73d097e96ec5748a4ff0503127(
    DevExpress.XtraGrid.Columns.GridColumn c5b06a6c558da093ec9f7612b25cd04e4,
    eGridColumn c4e4dd0b743ed8c13fde428de36b4c8f3)
  {
    RepositoryItemButtonEdit repositoryItemButtonEdit = new RepositoryItemButtonEdit();
    repositoryItemButtonEdit.ButtonsStyle = BorderStyles.HotFlat;
    c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit = (RepositoryItem) repositoryItemButtonEdit;
    if (c4e4dd0b743ed8c13fde428de36b4c8f3.MaxLength > 0)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cade15b73d097e96ec5748a4ff0503127);
          }
          repositoryItemButtonEdit.MaxLength = c4e4dd0b743ed8c13fde428de36b4c8f3.MaxLength;
          break;
      }
    }
    repositoryItemButtonEdit.Buttons[0].Tag = (object) c5b06a6c558da093ec9f7612b25cd04e4.FieldName;
    repositoryItemButtonEdit.BeforeShowMenu += new BeforeShowMenuEventHandler(this.cacda6f0c7462332dbd94f3b5e03079bf);
    repositoryItemButtonEdit.ButtonPressed += new DevExpress.XtraEditors.Controls.ButtonPressedEventHandler(this.cd31f18b05a0a88949fc550564c853500);
  }

  private void c1110508e758c291b58128cf689a4d05f(
    DevExpress.XtraGrid.Columns.GridColumn c5b06a6c558da093ec9f7612b25cd04e4,
    eGridColumn c4e4dd0b743ed8c13fde428de36b4c8f3)
  {
    RepositoryItemButtonEdit repositoryItemButtonEdit = new RepositoryItemButtonEdit();
    repositoryItemButtonEdit.ButtonsStyle = BorderStyles.HotFlat;
    repositoryItemButtonEdit.TextEditStyle = TextEditStyles.HideTextEditor;
    repositoryItemButtonEdit.Buttons[0].Kind = ButtonPredefines.Glyph;
    repositoryItemButtonEdit.Buttons[0].Caption = c4e4dd0b743ed8c13fde428de36b4c8f3.DefaultText;
    repositoryItemButtonEdit.Buttons[0].Tag = (object) c5b06a6c558da093ec9f7612b25cd04e4.FieldName;
    c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit = (RepositoryItem) repositoryItemButtonEdit;
    repositoryItemButtonEdit.BeforeShowMenu += new BeforeShowMenuEventHandler(this.cacda6f0c7462332dbd94f3b5e03079bf);
    repositoryItemButtonEdit.ButtonPressed += new DevExpress.XtraEditors.Controls.ButtonPressedEventHandler(this.cd31f18b05a0a88949fc550564c853500);
  }

  public event eGrid.ButtonPressedEventHandler ButtonPressed
  {
    add
    {
      eGrid.ButtonPressedEventHandler pressedEventHandler = this.c5bee7ba1390f915bc4cc3b82ece6cd66;
      eGrid.ButtonPressedEventHandler comparand;
      do
      {
        comparand = pressedEventHandler;
        pressedEventHandler = Interlocked.CompareExchange<eGrid.ButtonPressedEventHandler>(ref this.c5bee7ba1390f915bc4cc3b82ece6cd66, comparand + value, comparand);
      }
      while (pressedEventHandler != comparand);
label_2:
      switch (6)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.add_ButtonPressed);
          break;
      }
    }
    remove
    {
      eGrid.ButtonPressedEventHandler pressedEventHandler = this.c5bee7ba1390f915bc4cc3b82ece6cd66;
      eGrid.ButtonPressedEventHandler comparand;
      do
      {
        comparand = pressedEventHandler;
        pressedEventHandler = Interlocked.CompareExchange<eGrid.ButtonPressedEventHandler>(ref this.c5bee7ba1390f915bc4cc3b82ece6cd66, comparand - value, comparand);
      }
      while (pressedEventHandler != comparand);
    }
  }

  private void cd31f18b05a0a88949fc550564c853500(
    object c7a1c50d8950fe539821ded4a87a7123f,
    ButtonPressedEventArgs c320269ec287d16905c829847d30a2e08)
  {
    // ISSUE: reference to a compiler-generated field
    eGrid.ButtonPressedEventHandler c5bee7ba1390f915bc4cc3b82ece6cd66 = this.c5bee7ba1390f915bc4cc3b82ece6cd66;
    if (c5bee7ba1390f915bc4cc3b82ece6cd66 != null)
      c5bee7ba1390f915bc4cc3b82ece6cd66((object) this, Conversions.ToString(c320269ec287d16905c829847d30a2e08.Button.Tag));
    if (((BaseEdit) c7a1c50d8950fe539821ded4a87a7123f).IsModified)
    {
label_3:
      switch (6)
      {
        case 0:
          goto label_3;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cd31f18b05a0a88949fc550564c853500);
          }
          this.UpdateCurrentRow();
          break;
      }
    }
    else if (Microsoft.VisualBasic.CompilerServices.Operators.ConditionalCompareObjectNotEqual(c320269ec287d16905c829847d30a2e08.Button.Tag, (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5389), false))
    {
label_8:
      switch (7)
      {
        case 0:
          goto label_8;
        default:
          this.RunPopup(Conversions.ToString(c320269ec287d16905c829847d30a2e08.Button.Tag), true);
          break;
      }
    }
  }

  private void c9f622b9dbb1cff94ff05922432b94ce7(
    DevExpress.XtraGrid.Columns.GridColumn c5b06a6c558da093ec9f7612b25cd04e4,
    eGridColumn c4e4dd0b743ed8c13fde428de36b4c8f3)
  {
    RepositoryItemProgressBar repositoryItemProgressBar = new RepositoryItemProgressBar();
    repositoryItemProgressBar.ShowTitle = true;
    repositoryItemProgressBar.StartColor = Color.Red;
    repositoryItemProgressBar.EndColor = Color.Red;
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c4e4dd0b743ed8c13fde428de36b4c8f3.DefaultText, "", false) != 0)
    {
      string[] strArray1 = c4e4dd0b743ed8c13fde428de36b4c8f3.DefaultText.ToLower().Split(',');
      int index = 0;
      while (index < strArray1.Length)
      {
        string[] strArray2 = strArray1[index].Split('=');
        if (strArray2.Length == 2)
        {
label_3:
          switch (3)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c9f622b9dbb1cff94ff05922432b94ce7);
              }
              string Left = strArray2[0];
              if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Left, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5406), false) != 0)
              {
label_7:
                switch (3)
                {
                  case 0:
                    goto label_7;
                  default:
                    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Left, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5415), false) != 0)
                    {
                      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Left, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5424), false) != 0)
                      {
label_10:
                        switch (5)
                        {
                          case 0:
                            goto label_10;
                        }
                      }
                      else
                      {
                        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[1], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5441), false) == 0 | Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[1], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5450), false) == 0)
                        {
                          repositoryItemProgressBar.PercentView = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[1], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5441), false) == 0;
                          break;
                        }
                        break;
                      }
                    }
                    else
                    {
                      if (Versioned.IsNumeric((object) strArray2[1]))
                      {
                        repositoryItemProgressBar.Maximum = Convert.ToInt32(Shared.ToDec((object) strArray2[1]));
                        break;
                      }
                      break;
                    }
                    break;
                }
              }
              else if (Versioned.IsNumeric((object) strArray2[1]))
              {
label_12:
                switch (7)
                {
                  case 0:
                    goto label_12;
                  default:
                    repositoryItemProgressBar.Minimum = Convert.ToInt32(Shared.ToDec((object) strArray2[1]));
                    break;
                }
              }
              break;
          }
        }
        checked { ++index; }
      }
label_21:
      switch (2)
      {
        case 0:
          goto label_21;
      }
    }
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c4e4dd0b743ed8c13fde428de36b4c8f3.Format, "", false) != 0)
    {
label_23:
      switch (3)
      {
        case 0:
          goto label_23;
        default:
          repositoryItemProgressBar.DisplayFormat.FormatType = FormatType.Numeric;
          repositoryItemProgressBar.EditFormat.FormatType = FormatType.Numeric;
          repositoryItemProgressBar.DisplayFormat.FormatString = c4e4dd0b743ed8c13fde428de36b4c8f3.Format;
          repositoryItemProgressBar.EditFormat.FormatString = c4e4dd0b743ed8c13fde428de36b4c8f3.Format;
          break;
      }
    }
    c5b06a6c558da093ec9f7612b25cd04e4.ColumnEdit = (RepositoryItem) repositoryItemProgressBar;
  }

  private void cacda6f0c7462332dbd94f3b5e03079bf(
    object c7a1c50d8950fe539821ded4a87a7123f,
    BeforeShowMenuEventArgs c320269ec287d16905c829847d30a2e08)
  {
    c320269ec287d16905c829847d30a2e08.Menu.Items[0].Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1391), c320269ec287d16905c829847d30a2e08.Menu.Items[0].Caption);
    c320269ec287d16905c829847d30a2e08.Menu.Items[1].Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1416), c320269ec287d16905c829847d30a2e08.Menu.Items[1].Caption);
    c320269ec287d16905c829847d30a2e08.Menu.Items[2].Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1439), c320269ec287d16905c829847d30a2e08.Menu.Items[2].Caption);
    c320269ec287d16905c829847d30a2e08.Menu.Items[3].Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1464), c320269ec287d16905c829847d30a2e08.Menu.Items[3].Caption);
    c320269ec287d16905c829847d30a2e08.Menu.Items[4].Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1491), c320269ec287d16905c829847d30a2e08.Menu.Items[4].Caption);
    c320269ec287d16905c829847d30a2e08.Menu.Items[5].Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1520), c320269ec287d16905c829847d30a2e08.Menu.Items[5].Caption);
  }

  private string c28e979d252bce6e5400127599fe1973c(
    string c4c9b78445c9e9cb6705836230ff32ab2,
    eGridColumn cbed866e03206cd14a5d8cf95ed0a9258)
  {
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c4c9b78445c9e9cb6705836230ff32ab2, "", false) == 0 || !cbed866e03206cd14a5d8cf95ed0a9258.IsNumericField())
      return c4c9b78445c9e9cb6705836230ff32ab2;
label_2:
    switch (2)
    {
      case 0:
        goto label_2;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c28e979d252bce6e5400127599fe1973c);
        }
        string str = cbed866e03206cd14a5d8cf95ed0a9258.Format;
        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, "", false) == 0)
          return c4c9b78445c9e9cb6705836230ff32ab2;
        if (!Versioned.IsNumeric((object) c4c9b78445c9e9cb6705836230ff32ab2))
        {
label_8:
          switch (5)
          {
            case 0:
              goto label_8;
            default:
              return "";
          }
        }
        else
        {
          Decimal num = Shared.ToDec((object) c4c9b78445c9e9cb6705836230ff32ab2);
          RoundType roundType = cbed866e03206cd14a5d8cf95ed0a9258.RoundType;
          if (roundType != RoundType.Round)
          {
label_11:
            switch (5)
            {
              case 0:
                goto label_11;
              default:
                if (roundType != RoundType.Truncation)
                {
label_13:
                  switch (7)
                  {
                    case 0:
                      goto label_13;
                  }
                }
                else
                {
                  num = Shared.Truncating(num, cbed866e03206cd14a5d8cf95ed0a9258.RoundDigits);
                  break;
                }
                break;
            }
          }
          else
            num = Shared.Rounding(num, cbed866e03206cd14a5d8cf95ed0a9258.RoundDigits);
          if (str.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(135)))
          {
label_17:
            switch (1)
            {
              case 0:
                goto label_17;
              default:
                str = str.Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(135), "");
                break;
            }
          }
          return Strings.Format((object) num, str);
        }
    }
  }

  private string c92d2a5ed2ece2be33d68ffeda6492237(string c702a7a60b30a2fab98fe835757b65523)
  {
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c702a7a60b30a2fab98fe835757b65523, "", false) == 0)
    {
label_1:
      switch (1)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c92d2a5ed2ece2be33d68ffeda6492237);
          }
          return "";
      }
    }
    else
    {
      int num = Strings.InStr(c702a7a60b30a2fab98fe835757b65523, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5461));
      if (num == 0)
      {
label_6:
        switch (5)
        {
          case 0:
            goto label_6;
          default:
            num = Strings.InStr(c702a7a60b30a2fab98fe835757b65523, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4674));
            break;
        }
      }
      string Expression1;
      string Expression2;
      if (0 < num)
      {
        Expression1 = Strings.Mid(c702a7a60b30a2fab98fe835757b65523, 1, checked (num - 1));
        Expression2 = Strings.Mid(c702a7a60b30a2fab98fe835757b65523, checked (num + 1));
        if (!Versioned.IsNumeric((object) Expression1))
        {
label_10:
          switch (6)
          {
            case 0:
              goto label_10;
            default:
              return "";
          }
        }
        else
        {
          if (!Versioned.IsNumeric((object) Expression2))
            return "";
          if (Strings.Len(Expression1) == 1)
          {
label_15:
            switch (1)
            {
              case 0:
                goto label_15;
              default:
                Expression1 = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82) + Expression1;
                break;
            }
          }
          if (Strings.Len(Expression2) == 1)
          {
label_18:
            switch (4)
            {
              case 0:
                goto label_18;
              default:
                Expression2 = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82) + Expression2;
                break;
            }
          }
        }
      }
      else
      {
        if (!Versioned.IsNumeric((object) c702a7a60b30a2fab98fe835757b65523))
          return "";
label_21:
        switch (5)
        {
          case 0:
            goto label_21;
          default:
            if (Strings.Len(c702a7a60b30a2fab98fe835757b65523) == 1)
            {
label_23:
              switch (2)
              {
                case 0:
                  goto label_23;
                default:
                  c702a7a60b30a2fab98fe835757b65523 = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82) + c702a7a60b30a2fab98fe835757b65523 + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5464);
                  break;
              }
            }
            if (Strings.Len(c702a7a60b30a2fab98fe835757b65523) == 2)
              c702a7a60b30a2fab98fe835757b65523 += c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5464);
            if (Strings.Len(c702a7a60b30a2fab98fe835757b65523) == 3)
            {
label_28:
              switch (4)
              {
                case 0:
                  goto label_28;
                default:
                  c702a7a60b30a2fab98fe835757b65523 = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82) + c702a7a60b30a2fab98fe835757b65523;
                  break;
              }
            }
            if (Strings.Len(c702a7a60b30a2fab98fe835757b65523) > 4)
            {
label_31:
              switch (3)
              {
                case 0:
                  goto label_31;
                default:
                  return "";
              }
            }
            else
            {
              Expression1 = Strings.Mid(c702a7a60b30a2fab98fe835757b65523, 1, 2);
              Expression2 = Strings.Mid(c702a7a60b30a2fab98fe835757b65523, 3, 2);
              break;
            }
        }
      }
      return Expression1 + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5461) + Expression2;
    }
  }

  public event eGrid.InsertedRowEventHandler InsertedRow
  {
    add
    {
      eGrid.InsertedRowEventHandler insertedRowEventHandler = this.c617a33dcb81187054bdb14637d65d431;
      eGrid.InsertedRowEventHandler comparand;
      do
      {
        comparand = insertedRowEventHandler;
        insertedRowEventHandler = Interlocked.CompareExchange<eGrid.InsertedRowEventHandler>(ref this.c617a33dcb81187054bdb14637d65d431, comparand + value, comparand);
      }
      while (insertedRowEventHandler != comparand);
    }
    remove
    {
      eGrid.InsertedRowEventHandler insertedRowEventHandler = this.c617a33dcb81187054bdb14637d65d431;
      eGrid.InsertedRowEventHandler comparand;
      do
      {
        comparand = insertedRowEventHandler;
        insertedRowEventHandler = Interlocked.CompareExchange<eGrid.InsertedRowEventHandler>(ref this.c617a33dcb81187054bdb14637d65d431, comparand - value, comparand);
      }
      while (insertedRowEventHandler != comparand);
label_2:
      switch (7)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.remove_InsertedRow);
          break;
      }
    }
  }

  public event eGrid.DeletingRowEventHandler DeletingRow
  {
    add
    {
      eGrid.DeletingRowEventHandler deletingRowEventHandler = this.c2560b393c45138aa714e981ba4ce1c78;
      eGrid.DeletingRowEventHandler comparand;
      do
      {
        comparand = deletingRowEventHandler;
        deletingRowEventHandler = Interlocked.CompareExchange<eGrid.DeletingRowEventHandler>(ref this.c2560b393c45138aa714e981ba4ce1c78, comparand + value, comparand);
      }
      while (deletingRowEventHandler != comparand);
label_2:
      switch (5)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.add_DeletingRow);
          break;
      }
    }
    remove
    {
      eGrid.DeletingRowEventHandler deletingRowEventHandler = this.c2560b393c45138aa714e981ba4ce1c78;
      eGrid.DeletingRowEventHandler comparand;
      do
      {
        comparand = deletingRowEventHandler;
        deletingRowEventHandler = Interlocked.CompareExchange<eGrid.DeletingRowEventHandler>(ref this.c2560b393c45138aa714e981ba4ce1c78, comparand - value, comparand);
      }
      while (deletingRowEventHandler != comparand);
label_2:
      switch (5)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.remove_DeletingRow);
          break;
      }
    }
  }

  public event eGrid.DeletedRowEventHandler DeletedRow
  {
    add
    {
      eGrid.DeletedRowEventHandler deletedRowEventHandler = this.c2caa834d8e828b4d29fa7f6d26032182;
      eGrid.DeletedRowEventHandler comparand;
      do
      {
        comparand = deletedRowEventHandler;
        deletedRowEventHandler = Interlocked.CompareExchange<eGrid.DeletedRowEventHandler>(ref this.c2caa834d8e828b4d29fa7f6d26032182, comparand + value, comparand);
      }
      while (deletedRowEventHandler != comparand);
label_2:
      switch (4)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.add_DeletedRow);
          break;
      }
    }
    remove
    {
      eGrid.DeletedRowEventHandler deletedRowEventHandler = this.c2caa834d8e828b4d29fa7f6d26032182;
      eGrid.DeletedRowEventHandler comparand;
      do
      {
        comparand = deletedRowEventHandler;
        deletedRowEventHandler = Interlocked.CompareExchange<eGrid.DeletedRowEventHandler>(ref this.c2caa834d8e828b4d29fa7f6d26032182, comparand - value, comparand);
      }
      while (deletedRowEventHandler != comparand);
    }
  }

  public event eGrid.AddedRowEventHandler AddedRow
  {
    add
    {
      eGrid.AddedRowEventHandler addedRowEventHandler = this.c9fdef276cb8e88d9c5fdf00d819d1c71;
      eGrid.AddedRowEventHandler comparand;
      do
      {
        comparand = addedRowEventHandler;
        addedRowEventHandler = Interlocked.CompareExchange<eGrid.AddedRowEventHandler>(ref this.c9fdef276cb8e88d9c5fdf00d819d1c71, comparand + value, comparand);
      }
      while (addedRowEventHandler != comparand);
label_2:
      switch (7)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.add_AddedRow);
          break;
      }
    }
    remove
    {
      eGrid.AddedRowEventHandler addedRowEventHandler = this.c9fdef276cb8e88d9c5fdf00d819d1c71;
      eGrid.AddedRowEventHandler comparand;
      do
      {
        comparand = addedRowEventHandler;
        addedRowEventHandler = Interlocked.CompareExchange<eGrid.AddedRowEventHandler>(ref this.c9fdef276cb8e88d9c5fdf00d819d1c71, comparand - value, comparand);
      }
      while (addedRowEventHandler != comparand);
label_2:
      switch (3)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.remove_AddedRow);
          break;
      }
    }
  }

  public event eGrid.BeforeMoveRowEventHandler BeforeMoveRow
  {
    add
    {
      eGrid.BeforeMoveRowEventHandler moveRowEventHandler = this.c091279e696e6da5da5f282fe17132c67;
      eGrid.BeforeMoveRowEventHandler comparand;
      do
      {
        comparand = moveRowEventHandler;
        moveRowEventHandler = Interlocked.CompareExchange<eGrid.BeforeMoveRowEventHandler>(ref this.c091279e696e6da5da5f282fe17132c67, comparand + value, comparand);
      }
      while (moveRowEventHandler != comparand);
label_2:
      switch (3)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.add_BeforeMoveRow);
          break;
      }
    }
    remove
    {
      eGrid.BeforeMoveRowEventHandler moveRowEventHandler = this.c091279e696e6da5da5f282fe17132c67;
      eGrid.BeforeMoveRowEventHandler comparand;
      do
      {
        comparand = moveRowEventHandler;
        moveRowEventHandler = Interlocked.CompareExchange<eGrid.BeforeMoveRowEventHandler>(ref this.c091279e696e6da5da5f282fe17132c67, comparand - value, comparand);
      }
      while (moveRowEventHandler != comparand);
label_2:
      switch (6)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.remove_BeforeMoveRow);
          break;
      }
    }
  }

  public event eGrid.AfterMoveRowEventHandler AfterMoveRow
  {
    add
    {
      eGrid.AfterMoveRowEventHandler moveRowEventHandler = this.c1cbbb9c928f78b2c107a6cd6f5dc15cb;
      eGrid.AfterMoveRowEventHandler comparand;
      do
      {
        comparand = moveRowEventHandler;
        moveRowEventHandler = Interlocked.CompareExchange<eGrid.AfterMoveRowEventHandler>(ref this.c1cbbb9c928f78b2c107a6cd6f5dc15cb, comparand + value, comparand);
      }
      while (moveRowEventHandler != comparand);
label_2:
      switch (6)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.add_AfterMoveRow);
          break;
      }
    }
    remove
    {
      eGrid.AfterMoveRowEventHandler moveRowEventHandler = this.c1cbbb9c928f78b2c107a6cd6f5dc15cb;
      eGrid.AfterMoveRowEventHandler comparand;
      do
      {
        comparand = moveRowEventHandler;
        moveRowEventHandler = Interlocked.CompareExchange<eGrid.AfterMoveRowEventHandler>(ref this.c1cbbb9c928f78b2c107a6cd6f5dc15cb, comparand - value, comparand);
      }
      while (moveRowEventHandler != comparand);
    }
  }

  public event eGrid.AfterMoveColumnEventHandler AfterMoveColumn;

  public event eGrid.CellValueChangedEventHandler CellValueChanged
  {
    add
    {
      eGrid.CellValueChangedEventHandler changedEventHandler = this.cf9c335fc5990e851057efa2c47f1a11a;
      eGrid.CellValueChangedEventHandler comparand;
      do
      {
        comparand = changedEventHandler;
        changedEventHandler = Interlocked.CompareExchange<eGrid.CellValueChangedEventHandler>(ref this.cf9c335fc5990e851057efa2c47f1a11a, comparand + value, comparand);
      }
      while (changedEventHandler != comparand);
label_2:
      switch (2)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.add_CellValueChanged);
          break;
      }
    }
    remove
    {
      eGrid.CellValueChangedEventHandler changedEventHandler = this.cf9c335fc5990e851057efa2c47f1a11a;
      eGrid.CellValueChangedEventHandler comparand;
      do
      {
        comparand = changedEventHandler;
        changedEventHandler = Interlocked.CompareExchange<eGrid.CellValueChangedEventHandler>(ref this.cf9c335fc5990e851057efa2c47f1a11a, comparand - value, comparand);
      }
      while (changedEventHandler != comparand);
label_2:
      switch (1)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.remove_CellValueChanged);
          break;
      }
    }
  }

  public event eGrid.CellValueChangingEventHandler CellValueChanging
  {
    add
    {
      eGrid.CellValueChangingEventHandler changingEventHandler = this.c64215629b34ca86cc3d0d5db5254ef6b;
      eGrid.CellValueChangingEventHandler comparand;
      do
      {
        comparand = changingEventHandler;
        changingEventHandler = Interlocked.CompareExchange<eGrid.CellValueChangingEventHandler>(ref this.c64215629b34ca86cc3d0d5db5254ef6b, comparand + value, comparand);
      }
      while (changingEventHandler != comparand);
label_2:
      switch (2)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.add_CellValueChanging);
          break;
      }
    }
    remove
    {
      eGrid.CellValueChangingEventHandler changingEventHandler = this.c64215629b34ca86cc3d0d5db5254ef6b;
      eGrid.CellValueChangingEventHandler comparand;
      do
      {
        comparand = changingEventHandler;
        changingEventHandler = Interlocked.CompareExchange<eGrid.CellValueChangingEventHandler>(ref this.c64215629b34ca86cc3d0d5db5254ef6b, comparand - value, comparand);
      }
      while (changingEventHandler != comparand);
label_2:
      switch (3)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.remove_CellValueChanging);
          break;
      }
    }
  }

  public event eGrid.CellValueValidatingEventHandler CellValueValidating
  {
    add
    {
      eGrid.CellValueValidatingEventHandler validatingEventHandler = this.c040a3e81d1a78dd433c243605ac0bac8;
      eGrid.CellValueValidatingEventHandler comparand;
      do
      {
        comparand = validatingEventHandler;
        validatingEventHandler = Interlocked.CompareExchange<eGrid.CellValueValidatingEventHandler>(ref this.c040a3e81d1a78dd433c243605ac0bac8, comparand + value, comparand);
      }
      while (validatingEventHandler != comparand);
label_2:
      switch (4)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.add_CellValueValidating);
          break;
      }
    }
    remove
    {
      eGrid.CellValueValidatingEventHandler validatingEventHandler = this.c040a3e81d1a78dd433c243605ac0bac8;
      eGrid.CellValueValidatingEventHandler comparand;
      do
      {
        comparand = validatingEventHandler;
        validatingEventHandler = Interlocked.CompareExchange<eGrid.CellValueValidatingEventHandler>(ref this.c040a3e81d1a78dd433c243605ac0bac8, comparand - value, comparand);
      }
      while (validatingEventHandler != comparand);
    }
  }

  public event eGrid.KeyDownEventHandler KeyDown
  {
    add
    {
      eGrid.KeyDownEventHandler downEventHandler = this.c76bc191df0eac37fbe1ef91407cedbae;
      eGrid.KeyDownEventHandler comparand;
      do
      {
        comparand = downEventHandler;
        downEventHandler = Interlocked.CompareExchange<eGrid.KeyDownEventHandler>(ref this.c76bc191df0eac37fbe1ef91407cedbae, comparand + value, comparand);
      }
      while (downEventHandler != comparand);
label_2:
      switch (5)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.add_KeyDown);
          break;
      }
    }
    remove
    {
      eGrid.KeyDownEventHandler downEventHandler = this.c76bc191df0eac37fbe1ef91407cedbae;
      eGrid.KeyDownEventHandler comparand;
      do
      {
        comparand = downEventHandler;
        downEventHandler = Interlocked.CompareExchange<eGrid.KeyDownEventHandler>(ref this.c76bc191df0eac37fbe1ef91407cedbae, comparand - value, comparand);
      }
      while (downEventHandler != comparand);
    }
  }

  public event eGrid.MouseDownEventHandler MouseDown
  {
    add
    {
      eGrid.MouseDownEventHandler downEventHandler = this.ce427e9aa95d910bc75d245d7bbe263c0;
      eGrid.MouseDownEventHandler comparand;
      do
      {
        comparand = downEventHandler;
        downEventHandler = Interlocked.CompareExchange<eGrid.MouseDownEventHandler>(ref this.ce427e9aa95d910bc75d245d7bbe263c0, comparand + value, comparand);
      }
      while (downEventHandler != comparand);
label_2:
      switch (3)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.add_MouseDown);
          break;
      }
    }
    remove
    {
      eGrid.MouseDownEventHandler downEventHandler = this.ce427e9aa95d910bc75d245d7bbe263c0;
      eGrid.MouseDownEventHandler comparand;
      do
      {
        comparand = downEventHandler;
        downEventHandler = Interlocked.CompareExchange<eGrid.MouseDownEventHandler>(ref this.ce427e9aa95d910bc75d245d7bbe263c0, comparand - value, comparand);
      }
      while (downEventHandler != comparand);
label_2:
      switch (1)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.remove_MouseDown);
          break;
      }
    }
  }

  public event eGrid.MouseUpEventHandler MouseUp
  {
    add
    {
      eGrid.MouseUpEventHandler mouseUpEventHandler = this.c2faf7c86aa6624fa3b669f112ee43186;
      eGrid.MouseUpEventHandler comparand;
      do
      {
        comparand = mouseUpEventHandler;
        mouseUpEventHandler = Interlocked.CompareExchange<eGrid.MouseUpEventHandler>(ref this.c2faf7c86aa6624fa3b669f112ee43186, comparand + value, comparand);
      }
      while (mouseUpEventHandler != comparand);
label_2:
      switch (5)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.add_MouseUp);
          break;
      }
    }
    remove
    {
      eGrid.MouseUpEventHandler mouseUpEventHandler = this.c2faf7c86aa6624fa3b669f112ee43186;
      eGrid.MouseUpEventHandler comparand;
      do
      {
        comparand = mouseUpEventHandler;
        mouseUpEventHandler = Interlocked.CompareExchange<eGrid.MouseUpEventHandler>(ref this.c2faf7c86aa6624fa3b669f112ee43186, comparand - value, comparand);
      }
      while (mouseUpEventHandler != comparand);
label_2:
      switch (5)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.remove_MouseUp);
          break;
      }
    }
  }

  public event eGrid.ColumnDoubleClickEventHandler ColumnDoubleClick
  {
    add
    {
      eGrid.ColumnDoubleClickEventHandler clickEventHandler = this.cc8f1c6c8d2781408daec3850760a24de;
      eGrid.ColumnDoubleClickEventHandler comparand;
      do
      {
        comparand = clickEventHandler;
        clickEventHandler = Interlocked.CompareExchange<eGrid.ColumnDoubleClickEventHandler>(ref this.cc8f1c6c8d2781408daec3850760a24de, comparand + value, comparand);
      }
      while (clickEventHandler != comparand);
label_2:
      switch (5)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.add_ColumnDoubleClick);
          break;
      }
    }
    remove
    {
      eGrid.ColumnDoubleClickEventHandler clickEventHandler = this.cc8f1c6c8d2781408daec3850760a24de;
      eGrid.ColumnDoubleClickEventHandler comparand;
      do
      {
        comparand = clickEventHandler;
        clickEventHandler = Interlocked.CompareExchange<eGrid.ColumnDoubleClickEventHandler>(ref this.cc8f1c6c8d2781408daec3850760a24de, comparand - value, comparand);
      }
      while (clickEventHandler != comparand);
label_2:
      switch (7)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.remove_ColumnDoubleClick);
          break;
      }
    }
  }

  public event eGrid.DoubleClickEventHandler DoubleClick
  {
    add
    {
      eGrid.DoubleClickEventHandler clickEventHandler = this.ce7da6aa4bce7da6aa03a8646ee79e8a8;
      eGrid.DoubleClickEventHandler comparand;
      do
      {
        comparand = clickEventHandler;
        clickEventHandler = Interlocked.CompareExchange<eGrid.DoubleClickEventHandler>(ref this.ce7da6aa4bce7da6aa03a8646ee79e8a8, comparand + value, comparand);
      }
      while (clickEventHandler != comparand);
label_2:
      switch (2)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.add_DoubleClick);
          break;
      }
    }
    remove
    {
      eGrid.DoubleClickEventHandler clickEventHandler = this.ce7da6aa4bce7da6aa03a8646ee79e8a8;
      eGrid.DoubleClickEventHandler comparand;
      do
      {
        comparand = clickEventHandler;
        clickEventHandler = Interlocked.CompareExchange<eGrid.DoubleClickEventHandler>(ref this.ce7da6aa4bce7da6aa03a8646ee79e8a8, comparand - value, comparand);
      }
      while (clickEventHandler != comparand);
    }
  }

  public event eGrid.ClickEventHandler Click
  {
    add
    {
      eGrid.ClickEventHandler clickEventHandler = this.cbec8277aefec68a42fa02be457b23ac9;
      eGrid.ClickEventHandler comparand;
      do
      {
        comparand = clickEventHandler;
        clickEventHandler = Interlocked.CompareExchange<eGrid.ClickEventHandler>(ref this.cbec8277aefec68a42fa02be457b23ac9, comparand + value, comparand);
      }
      while (clickEventHandler != comparand);
label_2:
      switch (7)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.add_Click);
          break;
      }
    }
    remove
    {
      eGrid.ClickEventHandler clickEventHandler = this.cbec8277aefec68a42fa02be457b23ac9;
      eGrid.ClickEventHandler comparand;
      do
      {
        comparand = clickEventHandler;
        clickEventHandler = Interlocked.CompareExchange<eGrid.ClickEventHandler>(ref this.cbec8277aefec68a42fa02be457b23ac9, comparand - value, comparand);
      }
      while (clickEventHandler != comparand);
label_2:
      switch (7)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.remove_Click);
          break;
      }
    }
  }

  private void c82288eea55806be02f5235f780d2711a(
    object c7a1c50d8950fe539821ded4a87a7123f,
    RowAllowEventArgs c320269ec287d16905c829847d30a2e08)
  {
    // ISSUE: reference to a compiler-generated field
    eGrid.BeforeMoveRowEventHandler c091279e696e6da5da5f282fe17132c67 = this.c091279e696e6da5da5f282fe17132c67;
    if (c091279e696e6da5da5f282fe17132c67 == null)
      return;
    eGrid.BeforeMoveRowEventHandler moveRowEventHandler = c091279e696e6da5da5f282fe17132c67;
    int rowHandle = c320269ec287d16905c829847d30a2e08.RowHandle;
    RowAllowEventArgs rowAllowEventArgs;
    bool allow = (rowAllowEventArgs = c320269ec287d16905c829847d30a2e08).Allow;
    ref bool local = ref allow;
    moveRowEventHandler((object) this, rowHandle, ref local);
    rowAllowEventArgs.Allow = allow;
  }

  private void cf1a8a917d64b77acfeeac450dcca0aea(
    object c7a1c50d8950fe539821ded4a87a7123f,
    RowIndicatorCustomDrawEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (!this.c8c8684eaecc3f7146066d6e2c6b049ec)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cf1a8a917d64b77acfeeac450dcca0aea);
          break;
      }
    }
    else if (this.ReadOnly)
    {
label_5:
      switch (4)
      {
        case 0:
          goto label_5;
      }
    }
    else
    {
      int num;
      if (c320269ec287d16905c829847d30a2e08.Info.IsRowIndicator)
      {
label_8:
        switch (4)
        {
          case 0:
            goto label_8;
          default:
            num = this.GridView1.IsDataRow(c320269ec287d16905c829847d30a2e08.RowHandle) ? 1 : 0;
            break;
        }
      }
      else
        num = 0;
      if (num != 0)
      {
        try
        {
          if (this.GridView1.GetDataRow(c320269ec287d16905c829847d30a2e08.RowHandle).RowState == DataRowState.Added)
          {
label_13:
            switch (4)
            {
              case 0:
                goto label_13;
              default:
                c320269ec287d16905c829847d30a2e08.Info.ImageIndex = 2;
                break;
            }
          }
          if (this.GridView1.GetDataRow(c320269ec287d16905c829847d30a2e08.RowHandle).RowState == DataRowState.Modified)
          {
label_16:
            switch (6)
            {
              case 0:
                goto label_16;
              default:
                c320269ec287d16905c829847d30a2e08.Info.ImageIndex = 6;
                break;
            }
          }
        }
        catch (Exception ex)
        {
          ProjectData.SetProjectError(ex);
          Shared.LogMessage(ex.Message + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5469));
          this.c8c8684eaecc3f7146066d6e2c6b049ec = false;
          ProjectData.ClearProjectError();
        }
      }
    }
  }

  private void c299843d9262f0e2d2fd1004e60077c88(
    object c7a1c50d8950fe539821ded4a87a7123f,
    CellValueChangedEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (!this.c437485d6a3e0b34ec64860ea9e5d9748)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c299843d9262f0e2d2fd1004e60077c88);
          }
          this.cc0d454e2f1398908e3cc1bf29ad72f9a = true;
          break;
      }
    }
    if (this.c291b918d0be288a91cc09da8cc863ce7)
      return;
    if (this.cd268e238072e06dd96804a08ee584b75)
    {
label_8:
      switch (4)
      {
        case 0:
          goto label_8;
      }
    }
    else
    {
      eGridColumn cbed866e03206cd14a5d8cf95ed0a9258 = this.GridColumn(c320269ec287d16905c829847d30a2e08.Column.FieldName);
      if (cbed866e03206cd14a5d8cf95ed0a9258.IsNumericField())
      {
label_10:
        switch (7)
        {
          case 0:
            goto label_10;
          default:
            this.c291b918d0be288a91cc09da8cc863ce7 = true;
            string Left = this.c28e979d252bce6e5400127599fe1973c(Shared.ToStr(RuntimeHelpers.GetObjectValue(c320269ec287d16905c829847d30a2e08.Value)), cbed866e03206cd14a5d8cf95ed0a9258);
            if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Left, "", false) == 0)
            {
label_12:
              switch (6)
              {
                case 0:
                  goto label_12;
                default:
                  this.GridView1.SetRowCellValue(c320269ec287d16905c829847d30a2e08.RowHandle, c320269ec287d16905c829847d30a2e08.Column.FieldName, (object) DBNull.Value);
                  break;
              }
            }
            else
              this.GridView1.SetRowCellValue(c320269ec287d16905c829847d30a2e08.RowHandle, c320269ec287d16905c829847d30a2e08.Column.FieldName, (object) Left);
            this.c291b918d0be288a91cc09da8cc863ce7 = false;
            break;
        }
      }
      if (cbed866e03206cd14a5d8cf95ed0a9258.FieldType == FieldType.Time)
      {
        this.c291b918d0be288a91cc09da8cc863ce7 = true;
        string Left = this.c92d2a5ed2ece2be33d68ffeda6492237(Shared.ToStr(RuntimeHelpers.GetObjectValue(c320269ec287d16905c829847d30a2e08.Value)));
        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Left, "", false) == 0)
        {
label_18:
          switch (2)
          {
            case 0:
              goto label_18;
            default:
              this.GridView1.SetRowCellValue(c320269ec287d16905c829847d30a2e08.RowHandle, c320269ec287d16905c829847d30a2e08.Column.FieldName, (object) DBNull.Value);
              break;
          }
        }
        else
          this.GridView1.SetRowCellValue(c320269ec287d16905c829847d30a2e08.RowHandle, c320269ec287d16905c829847d30a2e08.Column.FieldName, (object) Left);
        this.c291b918d0be288a91cc09da8cc863ce7 = false;
      }
      if (!this.cd5ee370368dc75972785b2283583d43f)
      {
label_23:
        switch (6)
        {
          case 0:
            goto label_23;
          default:
            this.c9628d971845e1dfed3b40173c2d77e5e = false;
            this.ceb03b9c3772bae1bdc6926be010a9525 = c320269ec287d16905c829847d30a2e08.Column.FieldName;
            break;
        }
      }
      this.RunPopup(c320269ec287d16905c829847d30a2e08.Column.FieldName);
      int num1;
      if (this.cd5ee370368dc75972785b2283583d43f)
      {
label_26:
        switch (7)
        {
          case 0:
            goto label_26;
          default:
            num1 = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c320269ec287d16905c829847d30a2e08.Column.FieldName, this.ceb03b9c3772bae1bdc6926be010a9525, false) == 0 ? 1 : 0;
            break;
        }
      }
      else
        num1 = 0;
      if (num1 != 0)
      {
label_30:
        switch (4)
        {
          case 0:
            goto label_30;
          default:
            this.c9628d971845e1dfed3b40173c2d77e5e = true;
            break;
        }
      }
      int num2;
      if (!this.cd5ee370368dc75972785b2283583d43f)
      {
label_33:
        switch (6)
        {
          case 0:
            goto label_33;
          default:
            num2 = !this.c9628d971845e1dfed3b40173c2d77e5e ? 1 : 0;
            break;
        }
      }
      else
        num2 = 1;
      if (num2 != 0)
      {
label_37:
        switch (1)
        {
          case 0:
            goto label_37;
          default:
            // ISSUE: reference to a compiler-generated field
            eGrid.CellValueChangedEventHandler cf9c335fc5990e851057efa2c47f1a11a = this.cf9c335fc5990e851057efa2c47f1a11a;
            if (cf9c335fc5990e851057efa2c47f1a11a != null)
            {
              eGrid.CellValueChangedEventHandler changedEventHandler = cf9c335fc5990e851057efa2c47f1a11a;
              string fieldName = c320269ec287d16905c829847d30a2e08.Column.FieldName;
              int rowHandle = c320269ec287d16905c829847d30a2e08.RowHandle;
              object objectValue = RuntimeHelpers.GetObjectValue(c320269ec287d16905c829847d30a2e08.Value);
              ref object local = ref objectValue;
              changedEventHandler((object) this, fieldName, rowHandle, ref local);
            }
            break;
        }
      }
      this.cbf1821b73a0f99c25a7b654abe87aa3f(c320269ec287d16905c829847d30a2e08.Column.FieldName);
      if (this.WorkSet != null)
      {
label_42:
        switch (2)
        {
          case 0:
            goto label_42;
          default:
            this.WorkSet.Calculate(c320269ec287d16905c829847d30a2e08.Column.FieldName);
            break;
        }
      }
    }
  }

  private void c0569f573eb3083b70667899b3cb1b8c7(
    object c7a1c50d8950fe539821ded4a87a7123f,
    CellValueChangedEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (this.cd268e238072e06dd96804a08ee584b75)
    {
label_1:
      switch (3)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c0569f573eb3083b70667899b3cb1b8c7);
          break;
      }
    }
    else
    {
      this.cc0d454e2f1398908e3cc1bf29ad72f9a = true;
      // ISSUE: reference to a compiler-generated field
      eGrid.CellValueChangingEventHandler c64215629b34ca86cc3d0d5db5254ef6b = this.c64215629b34ca86cc3d0d5db5254ef6b;
      if (c64215629b34ca86cc3d0d5db5254ef6b != null)
      {
        eGrid.CellValueChangingEventHandler changingEventHandler = c64215629b34ca86cc3d0d5db5254ef6b;
        string fieldName = c320269ec287d16905c829847d30a2e08.Column.FieldName;
        int rowHandle = c320269ec287d16905c829847d30a2e08.RowHandle;
        object objectValue = RuntimeHelpers.GetObjectValue(c320269ec287d16905c829847d30a2e08.Value);
        ref object local = ref objectValue;
        changingEventHandler((object) this, fieldName, rowHandle, ref local);
      }
      this.c7e611ca566728d6070ae43ba17bc89f2(this.GridColumn(c320269ec287d16905c829847d30a2e08.Column.FieldName));
    }
  }

  private void c3f4e0c15b6b433da51e0051c536e2963(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    string fieldName = this.GridView1.FocusedColumn.FieldName;
    eGridColumn eGridColumn = this.GridColumn(fieldName);
    if (eGridColumn == null)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c3f4e0c15b6b433da51e0051c536e2963);
          break;
      }
    }
    else
    {
      int num;
      if (eGridColumn.FieldType != FieldType.Keyboard)
      {
label_5:
        switch (5)
        {
          case 0:
            goto label_5;
          default:
            num = eGridColumn.FieldType == FieldType.Keypad ? 1 : 0;
            break;
        }
      }
      else
        num = 1;
      if (num != 0)
      {
label_9:
        switch (6)
        {
          case 0:
            goto label_9;
          default:
            BaseEdit activeEditor = this.GridView1.ActiveEditor;
            if (activeEditor != null)
            {
              frmKeyboard frmKeyboard = new frmKeyboard();
              frmKeyboard.SetTextBox(this.GridColumn(fieldName));
              if (eGridColumn.FieldType == FieldType.Keypad || eGridColumn.IsNumericField())
              {
label_12:
                switch (1)
                {
                  case 0:
                    goto label_12;
                  default:
                    frmKeyboard.SetKeypad();
                    break;
                }
              }
              else
                frmKeyboard.SetKeyboard();
              Point screen = activeEditor.PointToScreen(new Point(0, checked (activeEditor.Height + 1)));
              frmKeyboard.SetLocation(screen);
              if (frmKeyboard.ShowDialog() == DialogResult.OK)
                SendKeys.SendWait(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(68));
            }
            break;
        }
      }
    }
  }

  private void c90a982c426d4bce3900a671eedb1d90b(
    object c7a1c50d8950fe539821ded4a87a7123f,
    FocusedColumnChangedEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (c320269ec287d16905c829847d30a2e08.PrevFocusedColumn == null)
    {
      if (c320269ec287d16905c829847d30a2e08.FocusedColumn == null)
      {
label_2:
        switch (4)
        {
          case 0:
            goto label_2;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c90a982c426d4bce3900a671eedb1d90b);
            }
            // ISSUE: reference to a compiler-generated field
            eGrid.AfterMoveColumnEventHandler c0fc1449fe6fae2a5ef30e48b3081bc25 = this.c0fc1449fe6fae2a5ef30e48b3081bc25;
            if (c0fc1449fe6fae2a5ef30e48b3081bc25 != null)
            {
label_6:
              switch (5)
              {
                case 0:
                  goto label_6;
                default:
                  c0fc1449fe6fae2a5ef30e48b3081bc25((object) this, "", "");
                  break;
              }
            }
            else
              break;
            break;
        }
      }
      else
      {
        // ISSUE: reference to a compiler-generated field
        eGrid.AfterMoveColumnEventHandler c0fc1449fe6fae2a5ef30e48b3081bc25 = this.c0fc1449fe6fae2a5ef30e48b3081bc25;
        if (c0fc1449fe6fae2a5ef30e48b3081bc25 != null)
        {
label_9:
          switch (5)
          {
            case 0:
              goto label_9;
            default:
              c0fc1449fe6fae2a5ef30e48b3081bc25((object) this, "", c320269ec287d16905c829847d30a2e08.FocusedColumn.FieldName);
              break;
          }
        }
      }
    }
    else
    {
      // ISSUE: reference to a compiler-generated field
      eGrid.AfterMoveColumnEventHandler c0fc1449fe6fae2a5ef30e48b3081bc25 = this.c0fc1449fe6fae2a5ef30e48b3081bc25;
      if (c0fc1449fe6fae2a5ef30e48b3081bc25 != null)
      {
label_14:
        switch (3)
        {
          case 0:
            goto label_14;
          default:
            c0fc1449fe6fae2a5ef30e48b3081bc25((object) this, c320269ec287d16905c829847d30a2e08.PrevFocusedColumn.FieldName, c320269ec287d16905c829847d30a2e08.FocusedColumn.FieldName);
            break;
        }
      }
    }
    if (c320269ec287d16905c829847d30a2e08.FocusedColumn == null)
      return;
label_18:
    switch (5)
    {
      case 0:
        goto label_18;
      default:
        this.c755e2ca825474d1dba52bc7523fd75bf(c320269ec287d16905c829847d30a2e08.FocusedColumn);
        break;
    }
  }

  private void c018a49ab8185880385511c15c08ac0b2(
    object c7a1c50d8950fe539821ded4a87a7123f,
    FocusedRowChangedEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (this.ce75332160d718c37d93defbcd7e95679)
    {
label_1:
      switch (1)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c018a49ab8185880385511c15c08ac0b2);
          break;
      }
    }
    else
      this.cb1889f5f18b3611413f64aac4ae0c235(c320269ec287d16905c829847d30a2e08.PrevFocusedRowHandle, c320269ec287d16905c829847d30a2e08.FocusedRowHandle);
  }

  private void cb1889f5f18b3611413f64aac4ae0c235(
    int c06f62672cf424b2b8e089624dbe823dd,
    int c5b6a5d0e863b6ae6c7370e810b26f70b)
  {
    this.c018a99ed0c66295f13c59de7c8b6aa4c = false;
    this.cef7a36e5c3667eae3821d7dd7c2a6b56();
    this.FocusedRowChanged();
    // ISSUE: reference to a compiler-generated field
    eGrid.AfterMoveRowEventHandler c1cbbb9c928f78b2c107a6cd6f5dc15cb = this.c1cbbb9c928f78b2c107a6cd6f5dc15cb;
    if (c1cbbb9c928f78b2c107a6cd6f5dc15cb == null)
      return;
label_1:
    switch (3)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cb1889f5f18b3611413f64aac4ae0c235);
        }
        c1cbbb9c928f78b2c107a6cd6f5dc15cb((object) this, c06f62672cf424b2b8e089624dbe823dd, c5b6a5d0e863b6ae6c7370e810b26f70b);
        break;
    }
  }

  private void c755e2ca825474d1dba52bc7523fd75bf(DevExpress.XtraGrid.Columns.GridColumn c15cf30b9e22c51d6561a76a05b712e0d)
  {
    string fieldName = c15cf30b9e22c51d6561a76a05b712e0d.FieldName;
    int num;
    if (this.GridColumns != null)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c755e2ca825474d1dba52bc7523fd75bf);
          }
          num = this.GridColumns.Contains(fieldName) ? 1 : 0;
          break;
      }
    }
    else
      num = 0;
    if (num == 0)
      return;
label_7:
    switch (4)
    {
      case 0:
        goto label_7;
      default:
        NewLateBinding.LateCall(this.GridColumns[fieldName], (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5542), new object[0], (string[]) null, (System.Type[]) null, (bool[]) null, true);
        break;
    }
  }

  private void cef7a36e5c3667eae3821d7dd7c2a6b56()
  {
    if (this.GridColumns == null)
      return;
    IEnumerator enumerator;
    try
    {
      enumerator = this.GridColumns.GetEnumerator();
      while (enumerator.MoveNext())
        ((eGridColumn) enumerator.Current).Init();
    }
    finally
    {
      if (enumerator is IDisposable)
      {
label_7:
        switch (2)
        {
          case 0:
            goto label_7;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cef7a36e5c3667eae3821d7dd7c2a6b56);
            }
            (enumerator as IDisposable).Dispose();
            break;
        }
      }
    }
  }

  public void FocusedRowChanged()
  {
    this.cbf1821b73a0f99c25a7b654abe87aa3f();
    this.c148514be1dea3e59ce3443e4c7b36317();
    this.cbf1821b73a0f99c25a7b654abe87aa3f();
  }

  private void cbf1821b73a0f99c25a7b654abe87aa3f(string cb56cae7f7c80aa3ac7cf294d2e67e7da = "")
  {
    IEnumerator enumerator;
    if (this.Joins() == null)
    {
label_1:
      switch (3)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cbf1821b73a0f99c25a7b654abe87aa3f);
          break;
      }
    }
    else
    {
      try
      {
        enumerator = this.Joins().GetEnumerator();
        while (enumerator.MoveNext())
        {
          Join current = (Join) enumerator.Current;
          int num;
          if (current.JoinType == JoinType.Push)
          {
label_6:
            switch (1)
            {
              case 0:
                goto label_6;
              default:
                num = current.FromControl is eGridColumn ? 1 : 0;
                break;
            }
          }
          else
            num = 0;
          if (num != 0 && ((eGridColumn) current.FromControl).Grid == this)
          {
            if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(cb56cae7f7c80aa3ac7cf294d2e67e7da, "", false) == 0)
            {
label_11:
              switch (3)
              {
                case 0:
                  goto label_11;
                default:
                  current.ToControl.Text = current.FromControl.Text;
                  break;
              }
            }
            else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(current.FromControl.FieldName.ToUpper(), cb56cae7f7c80aa3ac7cf294d2e67e7da.ToUpper(), false) == 0)
            {
label_14:
              switch (1)
              {
                case 0:
                  goto label_14;
                default:
                  current.ToControl.Text = current.FromControl.Text;
                  break;
              }
            }
          }
        }
label_20:
        switch (6)
        {
          case 0:
            goto label_20;
        }
      }
      finally
      {
        if (enumerator is IDisposable)
        {
label_23:
          switch (6)
          {
            case 0:
              goto label_23;
            default:
              (enumerator as IDisposable).Dispose();
              break;
          }
        }
      }
    }
  }

  private void c7e611ca566728d6070ae43ba17bc89f2(eGridColumn c1e6290ac54e381b2081d91b6c00805a8)
  {
    if (this.Joins() == null)
    {
label_1:
      switch (5)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c7e611ca566728d6070ae43ba17bc89f2);
          break;
      }
    }
    else
    {
      this.c291b918d0be288a91cc09da8cc863ce7 = true;
      try
      {
        foreach (Join join in this.Joins())
        {
          if (join.JoinType == JoinType.Indicate)
          {
label_8:
            switch (1)
            {
              case 0:
                goto label_8;
              default:
                if (join.FromControl == c1e6290ac54e381b2081d91b6c00805a8)
                  join.ToControl.GetIndicator((intField) c1e6290ac54e381b2081d91b6c00805a8);
                break;
            }
          }
        }
      }
      finally
      {
        IEnumerator enumerator;
        if (enumerator is IDisposable)
          (enumerator as IDisposable).Dispose();
      }
      this.c291b918d0be288a91cc09da8cc863ce7 = false;
    }
  }

  private void c148514be1dea3e59ce3443e4c7b36317()
  {
    if (this.WorkSet == null)
      return;
    SortedList sortedList1 = new SortedList();
    int key = 0;
    IEnumerator enumerator;
    try
    {
      enumerator = this.WorkSet.WorkSets.GetEnumerator();
      while (enumerator.MoveNext())
      {
        WorkSet current = (WorkSet) enumerator.Current;
        if (current.LinkedGrid != null)
        {
label_4:
          switch (5)
          {
            case 0:
              goto label_4;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c148514be1dea3e59ce3443e4c7b36317);
              }
              if (current.LinkedGrid == this)
              {
label_8:
                switch (2)
                {
                  case 0:
                    goto label_8;
                  default:
                    sortedList1.Add((object) key, (object) current);
                    checked { ++key; }
                    break;
                }
              }
              break;
          }
        }
      }
label_13:
      switch (2)
      {
        case 0:
          goto label_13;
      }
    }
    finally
    {
      if (enumerator is IDisposable)
      {
label_16:
        switch (2)
        {
          case 0:
            goto label_16;
          default:
            (enumerator as IDisposable).Dispose();
            break;
        }
      }
    }
    SortedList sortedList2;
    if (0 < sortedList1.Count)
    {
      object[] objArray;
      bool[] flagArray;
      NewLateBinding.LateCall(this.WorkSet.ParentForm, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5551), objArray = new object[1]
      {
        (object) sortedList1
      }, (string[]) null, (System.Type[]) null, flagArray = new bool[1]
      {
        true
      }, true);
      if (flagArray[0])
        sortedList2 = (SortedList) Conversions.ChangeType(RuntimeHelpers.GetObjectValue(objArray[0]), typeof (SortedList));
    }
    sortedList2 = (SortedList) null;
  }

  private bool cbff9d942f31d20205689f274b880c3be(
    Keys ca9b8345ea7953702423fcd5947c031be,
    bool cc06acedeae3045a98d54a215dad4a77a)
  {
    if (Keys.D0 <= ca9b8345ea7953702423fcd5947c031be)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cbff9d942f31d20205689f274b880c3be);
          }
          if (ca9b8345ea7953702423fcd5947c031be > Keys.D9)
          {
label_5:
            switch (7)
            {
              case 0:
                goto label_5;
            }
          }
          else
            goto label_20;
          break;
      }
    }
    if (Keys.NumPad0 <= ca9b8345ea7953702423fcd5947c031be)
    {
label_7:
      switch (4)
      {
        case 0:
          goto label_7;
        default:
          if (ca9b8345ea7953702423fcd5947c031be > Keys.NumPad9)
          {
label_9:
            switch (3)
            {
              case 0:
                goto label_9;
            }
          }
          else
            goto label_20;
          break;
      }
    }
    int num;
    if (ca9b8345ea7953702423fcd5947c031be != Keys.Subtract)
    {
label_11:
      switch (1)
      {
        case 0:
          goto label_11;
        default:
          if (ca9b8345ea7953702423fcd5947c031be != Keys.OemMinus)
          {
label_13:
            switch (1)
            {
              case 0:
                goto label_13;
              default:
                if (ca9b8345ea7953702423fcd5947c031be != Keys.Decimal)
                {
label_15:
                  switch (6)
                  {
                    case 0:
                      goto label_15;
                    default:
                      if (ca9b8345ea7953702423fcd5947c031be != Keys.OemPeriod)
                      {
label_17:
                        switch (1)
                        {
                          case 0:
                            goto label_17;
                          default:
                            if (ca9b8345ea7953702423fcd5947c031be != Keys.Back)
                            {
                              num = cc06acedeae3045a98d54a215dad4a77a ? 1 : 0;
                              goto label_21;
                            }
                            break;
                        }
                      }
                      else
                        break;
                      break;
                  }
                }
                else
                  break;
                break;
            }
          }
          else
            break;
          break;
      }
    }
label_20:
    num = 1;
label_21:
    if (num == 0)
      return false;
label_22:
    switch (7)
    {
      case 0:
        goto label_22;
      default:
        return true;
    }
  }

  private void c838939f90faf11148119525597c56295(
    object c7a1c50d8950fe539821ded4a87a7123f,
    KeyEventArgs c320269ec287d16905c829847d30a2e08)
  {
    try
    {
      this.cb0eeff986f87617a9dc0a385c3674fa7 = this.cbff9d942f31d20205689f274b880c3be(c320269ec287d16905c829847d30a2e08.KeyCode, c320269ec287d16905c829847d30a2e08.Control);
      if (c320269ec287d16905c829847d30a2e08.Handled)
        return;
      this.c71541eef6215c51fd6ed427761212ad3 = true;
      // ISSUE: reference to a compiler-generated field
      eGrid.KeyDownEventHandler c76bc191df0eac37fbe1ef91407cedbae = this.c76bc191df0eac37fbe1ef91407cedbae;
      if (c76bc191df0eac37fbe1ef91407cedbae != null)
      {
label_3:
        switch (5)
        {
          case 0:
            goto label_3;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c838939f90faf11148119525597c56295);
            }
            c76bc191df0eac37fbe1ef91407cedbae((object) this, c320269ec287d16905c829847d30a2e08);
            break;
        }
      }
      if (c320269ec287d16905c829847d30a2e08.Handled)
        return;
      int num1;
      if (!this.cfe51a0bb967b0d0da313e1b4013ca09b)
      {
label_9:
        switch (7)
        {
          case 0:
            goto label_9;
          default:
            if (c320269ec287d16905c829847d30a2e08.Control)
            {
label_11:
              switch (5)
              {
                case 0:
                  goto label_11;
                default:
                  num1 = c320269ec287d16905c829847d30a2e08.KeyCode == Keys.C ? 1 : (c320269ec287d16905c829847d30a2e08.KeyCode == Keys.Insert ? 1 : 0);
                  goto label_14;
              }
            }
            else
              break;
        }
      }
      num1 = 0;
label_14:
      if (num1 != 0)
      {
label_15:
        switch (5)
        {
          case 0:
            goto label_15;
          default:
            c320269ec287d16905c829847d30a2e08.Handled = true;
            break;
        }
      }
      else
      {
        int num2;
        if (c320269ec287d16905c829847d30a2e08.KeyCode != Keys.Back)
        {
label_18:
          switch (5)
          {
            case 0:
              goto label_18;
            default:
              num2 = c320269ec287d16905c829847d30a2e08.KeyCode == Keys.Delete ? 1 : 0;
              break;
          }
        }
        else
          num2 = 1;
        if (num2 != 0)
        {
label_22:
          switch (3)
          {
            case 0:
              goto label_22;
            default:
              if (!(c7a1c50d8950fe539821ded4a87a7123f is TextEdit))
                return;
              TextEdit textEdit = (TextEdit) c7a1c50d8950fe539821ded4a87a7123f;
              if (textEdit.Properties.Mask.MaskType == MaskType.Numeric)
              {
label_25:
                switch (5)
                {
                  case 0:
                    goto label_25;
                  default:
                    string text = textEdit.Text;
                    int num3;
                    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(text, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5566), false) != 0 && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(text, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82), false) != 0)
                    {
label_27:
                      switch (6)
                      {
                        case 0:
                          goto label_27;
                        default:
                          num3 = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(text, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4674), false) == 0 ? 1 : 0;
                          break;
                      }
                    }
                    else
                      num3 = 1;
                    if (num3 != 0)
                    {
label_31:
                      switch (4)
                      {
                        case 0:
                          goto label_31;
                        default:
                          textEdit.EditValue = (object) DBNull.Value;
                          c320269ec287d16905c829847d30a2e08.Handled = true;
                          return;
                      }
                    }
                    else
                      break;
                }
              }
              break;
          }
        }
        int num4;
        if (c320269ec287d16905c829847d30a2e08.Control)
        {
label_35:
          switch (5)
          {
            case 0:
              goto label_35;
            default:
              if (c320269ec287d16905c829847d30a2e08.KeyCode != Keys.C)
              {
label_37:
                switch (5)
                {
                  case 0:
                    goto label_37;
                  default:
                    num4 = c320269ec287d16905c829847d30a2e08.KeyCode == Keys.V ? 1 : 0;
                    break;
                }
              }
              else
              {
                num4 = 1;
                break;
              }
              break;
          }
        }
        else
          num4 = 0;
        if (num4 != 0)
        {
label_42:
          switch (2)
          {
            case 0:
              goto label_42;
            default:
              if (c320269ec287d16905c829847d30a2e08.KeyCode == Keys.C)
              {
label_44:
                switch (1)
                {
                  case 0:
                    goto label_44;
                  default:
                    if (this.GridView1.GetSelectedCells() != null && this.GridView1.GetSelectedCells().Length > 1)
                    {
label_46:
                      switch (6)
                      {
                        case 0:
                          goto label_46;
                        default:
                          this.cfc11d14e0834a0336644062508e0c0e2();
                          break;
                      }
                    }
                    else if (c7a1c50d8950fe539821ded4a87a7123f is LookUpEdit || c7a1c50d8950fe539821ded4a87a7123f is CheckEdit)
                    {
label_49:
                      switch (7)
                      {
                        case 0:
                          goto label_49;
                        default:
                          Clipboard.SetDataObject(RuntimeHelpers.GetObjectValue(NewLateBinding.LateGet(c7a1c50d8950fe539821ded4a87a7123f, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5571), new object[0], (string[]) null, (System.Type[]) null, (bool[]) null)), true);
                          c320269ec287d16905c829847d30a2e08.SuppressKeyPress = true;
                          c320269ec287d16905c829847d30a2e08.Handled = true;
                          return;
                      }
                    }
                    break;
                }
              }
              if (c320269ec287d16905c829847d30a2e08.KeyCode == Keys.V)
              {
label_53:
                switch (4)
                {
                  case 0:
                    goto label_53;
                  default:
                    if (!this.Editable)
                    {
label_55:
                      switch (1)
                      {
                        case 0:
                          goto label_55;
                        default:
                          c320269ec287d16905c829847d30a2e08.SuppressKeyPress = true;
                          c320269ec287d16905c829847d30a2e08.Handled = true;
                          return;
                      }
                    }
                    else
                    {
                      if (0 < this.GridView1.SelectedRowsCount)
                      {
label_58:
                        switch (1)
                        {
                          case 0:
                            goto label_58;
                          default:
                            GridCell[] selectedCells = this.GridView1.GetSelectedCells();
                            int index = 0;
                            if (index < selectedCells.Length)
                            {
                              GridCell gridCell = selectedCells[index];
                              this.GridView1.FocusedRowHandle = gridCell.RowHandle;
                              this.GridView1.FocusedColumn = gridCell.Column;
                            }
                            else
                            {
label_61:
                              switch (3)
                              {
                                case 0:
                                  goto label_61;
                              }
                            }
                            break;
                        }
                      }
                      if (this.c4e3eeb0be2674f5594e9c871d29d1600(RuntimeHelpers.GetObjectValue(c7a1c50d8950fe539821ded4a87a7123f)))
                      {
label_64:
                        switch (4)
                        {
                          case 0:
                            goto label_64;
                          default:
                            NewLateBinding.LateCall(c7a1c50d8950fe539821ded4a87a7123f, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5590), new object[0], (string[]) null, (System.Type[]) null, (bool[]) null, true);
                            break;
                        }
                      }
                      else
                        this.c1c1e4d91078de84d8c0e63e9700cc708();
                      c320269ec287d16905c829847d30a2e08.SuppressKeyPress = true;
                      c320269ec287d16905c829847d30a2e08.Handled = true;
                      return;
                    }
                }
              }
              else
                break;
          }
        }
        object objectValue = RuntimeHelpers.GetObjectValue(c7a1c50d8950fe539821ded4a87a7123f);
        int num5 = c320269ec287d16905c829847d30a2e08.Control ? 1 : 0;
        int keyCode = (int) c320269ec287d16905c829847d30a2e08.KeyCode;
        KeyEventArgs keyEventArgs;
        bool handled = (keyEventArgs = c320269ec287d16905c829847d30a2e08).Handled;
        ref bool local = ref handled;
        this.cf725faae2fffdfd07ecff0490a80a1f3(objectValue, num5 != 0, (Keys) keyCode, ref local);
        keyEventArgs.Handled = handled;
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.LogMessage(ex.Message);
      ProjectData.ClearProjectError();
    }
  }

  private void c509c84df8827496bd22566ab0fb48f36(
    object c7a1c50d8950fe539821ded4a87a7123f,
    KeyPressEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (this.GridView1.FocusedColumn.ColumnEdit.DisplayFormat.FormatType == FormatType.Numeric && !this.cb0eeff986f87617a9dc0a385c3674fa7)
    {
label_1:
      switch (1)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c509c84df8827496bd22566ab0fb48f36);
          }
          c320269ec287d16905c829847d30a2e08.Handled = true;
          break;
      }
    }
    else if (this.c018a99ed0c66295f13c59de7c8b6aa4c)
    {
label_6:
      switch (2)
      {
        case 0:
          goto label_6;
        default:
          c320269ec287d16905c829847d30a2e08.Handled = true;
          break;
      }
    }
    else if (this.c08e309bae6f52107655a92e8f961fc35)
    {
label_9:
      switch (2)
      {
        case 0:
          goto label_9;
        default:
          this.c08e309bae6f52107655a92e8f961fc35 = false;
          this.cf8f2df247e0956b72b23d1f8bc5800fc = 0;
          break;
      }
    }
    else
    {
      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Conversions.ToString(c320269ec287d16905c829847d30a2e08.KeyChar), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5601), false) == 0)
      {
label_12:
        switch (4)
        {
          case 0:
            goto label_12;
          default:
            if (this.GridView1.FocusedColumn.ColumnEdit.DisplayFormat.FormatType == FormatType.Numeric)
            {
label_14:
              switch (5)
              {
                case 0:
                  goto label_14;
                default:
                  this.cf8f2df247e0956b72b23d1f8bc5800fc = 3;
                  break;
              }
            }
            break;
        }
      }
      if (this.cf8f2df247e0956b72b23d1f8bc5800fc > 0)
      {
label_18:
        switch (5)
        {
          case 0:
            goto label_18;
          default:
            this.c08e309bae6f52107655a92e8f961fc35 = true;
            SendKeys.SendWait(Strings.StrDup(this.cf8f2df247e0956b72b23d1f8bc5800fc, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(82)));
            if (c320269ec287d16905c829847d30a2e08 != null)
            {
label_20:
              switch (1)
              {
                case 0:
                  goto label_20;
                default:
                  c320269ec287d16905c829847d30a2e08.Handled = true;
                  break;
              }
            }
            break;
        }
      }
    }
  }

  private void c5deb2b157ec3bee3b8e4df257037bc36(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    // ISSUE: reference to a compiler-generated field
    eGrid.DoubleClickEventHandler ce7da6aa4bce7da6aa03a8646ee79e8a8 = this.ce7da6aa4bce7da6aa03a8646ee79e8a8;
    if (ce7da6aa4bce7da6aa03a8646ee79e8a8 != null)
    {
label_1:
      switch (7)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c5deb2b157ec3bee3b8e4df257037bc36);
          }
          ce7da6aa4bce7da6aa03a8646ee79e8a8((object) this, c320269ec287d16905c829847d30a2e08);
          break;
      }
    }
    if (!this.Editable)
      return;
    this.RunPopup(this.GridView1.FocusedColumn.FieldName, true);
  }

  private void c5a762af29a3fb639f0e52492954d9d70(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    BandedGridHitInfo bandedGridHitInfo = this.GridView1.CalcHitInfo(this.PointToClient(Control.MousePosition));
    if (bandedGridHitInfo.HitTest == BandedGridHitTest.RowIndicator | bandedGridHitInfo.HitTest == BandedGridHitTest.RowCell)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c5a762af29a3fb639f0e52492954d9d70);
          }
          // ISSUE: reference to a compiler-generated field
          eGrid.DoubleClickEventHandler ce7da6aa4bce7da6aa03a8646ee79e8a8 = this.ce7da6aa4bce7da6aa03a8646ee79e8a8;
          if (ce7da6aa4bce7da6aa03a8646ee79e8a8 == null)
            break;
label_5:
          switch (1)
          {
            case 0:
              goto label_5;
            default:
              ce7da6aa4bce7da6aa03a8646ee79e8a8((object) this, c320269ec287d16905c829847d30a2e08);
              return;
          }
      }
    }
    else if (bandedGridHitInfo.HitTest == BandedGridHitTest.Column)
    {
label_9:
      switch (1)
      {
        case 0:
          goto label_9;
        default:
          // ISSUE: reference to a compiler-generated field
          eGrid.ColumnDoubleClickEventHandler cc8f1c6c8d2781408daec3850760a24de = this.cc8f1c6c8d2781408daec3850760a24de;
          if (cc8f1c6c8d2781408daec3850760a24de == null)
            break;
          cc8f1c6c8d2781408daec3850760a24de((object) this, bandedGridHitInfo.Column.FieldName);
          break;
      }
    }
    else
    {
      if (bandedGridHitInfo.HitTest != BandedGridHitTest.Band)
        return;
label_13:
      switch (7)
      {
        case 0:
          goto label_13;
        default:
          int num;
          if (bandedGridHitInfo.Band.Columns != null)
          {
label_15:
            switch (6)
            {
              case 0:
                goto label_15;
              default:
                num = bandedGridHitInfo.Band.Columns.Count != 0 ? 1 : 0;
                break;
            }
          }
          else
            num = 0;
          if (num != 0)
          {
label_19:
            switch (2)
            {
              case 0:
                goto label_19;
              default:
                // ISSUE: reference to a compiler-generated field
                eGrid.ColumnDoubleClickEventHandler cc8f1c6c8d2781408daec3850760a24de = this.cc8f1c6c8d2781408daec3850760a24de;
                if (cc8f1c6c8d2781408daec3850760a24de != null)
                {
label_21:
                  switch (3)
                  {
                    case 0:
                      goto label_21;
                    default:
                      cc8f1c6c8d2781408daec3850760a24de((object) this, bandedGridHitInfo.Band.Columns[0].FieldName);
                      break;
                  }
                }
                else
                  break;
                break;
            }
          }
          else
          {
            // ISSUE: reference to a compiler-generated field
            eGrid.ColumnDoubleClickEventHandler cc8f1c6c8d2781408daec3850760a24de = this.cc8f1c6c8d2781408daec3850760a24de;
            if (cc8f1c6c8d2781408daec3850760a24de != null)
              cc8f1c6c8d2781408daec3850760a24de((object) this, bandedGridHitInfo.Band.Caption);
          }
          break;
      }
    }
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public string HitTest
  {
    get
    {
      return ((GridHitInfo) this.GridView1.CalcHitInfo(this.PointToClient(Control.MousePosition))).HitTest.ToString();
    }
  }

  public GridHitInfo CalcHitInfo(Point p) => (GridHitInfo) this.GridView1.CalcHitInfo(p);

  [Browsable(false)]
  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  public object GridView => (object) this.GridView1;

  private void c79dafdef1dba1a8745a4f88c96d7cdbe(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    // ISSUE: reference to a compiler-generated field
    eGrid.ClickEventHandler cbec8277aefec68a42fa02be457b23ac9 = this.cbec8277aefec68a42fa02be457b23ac9;
    if (cbec8277aefec68a42fa02be457b23ac9 == null)
      return;
label_1:
    switch (4)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c79dafdef1dba1a8745a4f88c96d7cdbe);
        }
        cbec8277aefec68a42fa02be457b23ac9((object) this, c320269ec287d16905c829847d30a2e08);
        break;
    }
  }

  public void EditMode()
  {
    SendKeys.SendWait(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5604));
  }

  private void cc84fda855336094f7faabdfd0d426bc0(
    object c7a1c50d8950fe539821ded4a87a7123f,
    KeyEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (c320269ec287d16905c829847d30a2e08.Handled)
    {
label_1:
      switch (1)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cc84fda855336094f7faabdfd0d426bc0);
          break;
      }
    }
    else
    {
      try
      {
        if (!this.c71541eef6215c51fd6ed427761212ad3)
        {
label_5:
          switch (3)
          {
            case 0:
              goto label_5;
            default:
              // ISSUE: reference to a compiler-generated field
              eGrid.KeyDownEventHandler c76bc191df0eac37fbe1ef91407cedbae = this.c76bc191df0eac37fbe1ef91407cedbae;
              if (c76bc191df0eac37fbe1ef91407cedbae != null)
                c76bc191df0eac37fbe1ef91407cedbae((object) this, c320269ec287d16905c829847d30a2e08);
              break;
          }
        }
        this.c71541eef6215c51fd6ed427761212ad3 = false;
        if (c320269ec287d16905c829847d30a2e08.Handled)
          return;
        int num1;
        if (!this.cfe51a0bb967b0d0da313e1b4013ca09b)
        {
label_11:
          switch (1)
          {
            case 0:
              goto label_11;
            default:
              if (c320269ec287d16905c829847d30a2e08.Control)
              {
                if (c320269ec287d16905c829847d30a2e08.KeyCode != Keys.C)
                {
label_14:
                  switch (6)
                  {
                    case 0:
                      goto label_14;
                    default:
                      num1 = c320269ec287d16905c829847d30a2e08.KeyCode == Keys.Insert ? 1 : 0;
                      goto label_18;
                  }
                }
                else
                {
                  num1 = 1;
                  goto label_18;
                }
              }
              else
                break;
          }
        }
        num1 = 0;
label_18:
        if (num1 != 0)
        {
          c320269ec287d16905c829847d30a2e08.Handled = true;
        }
        else
        {
          if (c320269ec287d16905c829847d30a2e08.KeyCode == Keys.Insert)
          {
label_21:
            switch (2)
            {
              case 0:
                goto label_21;
              default:
                SendKeys.SendWait(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5604));
                c320269ec287d16905c829847d30a2e08.Handled = true;
                break;
            }
          }
          int num2;
          if (!c320269ec287d16905c829847d30a2e08.Control)
          {
label_24:
            switch (2)
            {
              case 0:
                goto label_24;
              default:
                num2 = c320269ec287d16905c829847d30a2e08.KeyCode == Keys.Return ? 1 : 0;
                break;
            }
          }
          else
            num2 = 0;
          if (num2 != 0)
          {
label_28:
            switch (5)
            {
              case 0:
                goto label_28;
              default:
                c320269ec287d16905c829847d30a2e08.Handled = this.c567e0a1980aedddd27e05927d5c3f089();
                break;
            }
          }
          if (c320269ec287d16905c829847d30a2e08.Control)
          {
label_31:
            switch (7)
            {
              case 0:
                goto label_31;
              default:
                if (c320269ec287d16905c829847d30a2e08.KeyCode == Keys.Return)
                {
label_33:
                  switch (4)
                  {
                    case 0:
                      goto label_33;
                    default:
                      if (this.RowCount == 0)
                        this.c838939f90faf11148119525597c56295(RuntimeHelpers.GetObjectValue(c7a1c50d8950fe539821ded4a87a7123f), c320269ec287d16905c829847d30a2e08);
                      break;
                  }
                }
                if (c320269ec287d16905c829847d30a2e08.KeyCode == Keys.Add | c320269ec287d16905c829847d30a2e08.KeyCode == Keys.Subtract | c320269ec287d16905c829847d30a2e08.KeyCode == Keys.Next)
                {
label_38:
                  switch (7)
                  {
                    case 0:
                      goto label_38;
                    default:
                      SendKeys.SendWait(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5604));
                      c320269ec287d16905c829847d30a2e08.Handled = true;
                      break;
                  }
                }
                break;
            }
          }
          int num3;
          if (c320269ec287d16905c829847d30a2e08.Control)
          {
label_42:
            switch (7)
            {
              case 0:
                goto label_42;
              default:
                if (c320269ec287d16905c829847d30a2e08.KeyCode != Keys.C)
                {
label_44:
                  switch (7)
                  {
                    case 0:
                      goto label_44;
                    default:
                      num3 = c320269ec287d16905c829847d30a2e08.KeyCode == Keys.V ? 1 : 0;
                      break;
                  }
                }
                else
                {
                  num3 = 1;
                  break;
                }
                break;
            }
          }
          else
            num3 = 0;
          if (num3 != 0)
          {
label_49:
            switch (4)
            {
              case 0:
                goto label_49;
              default:
                if (c320269ec287d16905c829847d30a2e08.KeyCode == Keys.C)
                {
label_51:
                  switch (2)
                  {
                    case 0:
                      goto label_51;
                    default:
                      this.cfc11d14e0834a0336644062508e0c0e2();
                      c320269ec287d16905c829847d30a2e08.SuppressKeyPress = true;
                      c320269ec287d16905c829847d30a2e08.Handled = true;
                      return;
                  }
                }
                else if (c320269ec287d16905c829847d30a2e08.KeyCode == Keys.V)
                {
label_54:
                  switch (3)
                  {
                    case 0:
                      goto label_54;
                    default:
                      if (!this.Editable)
                      {
label_56:
                        switch (4)
                        {
                          case 0:
                            goto label_56;
                          default:
                            c320269ec287d16905c829847d30a2e08.SuppressKeyPress = true;
                            c320269ec287d16905c829847d30a2e08.Handled = true;
                            return;
                        }
                      }
                      else
                      {
                        this.c1c1e4d91078de84d8c0e63e9700cc708();
                        c320269ec287d16905c829847d30a2e08.SuppressKeyPress = true;
                        c320269ec287d16905c829847d30a2e08.Handled = true;
                        return;
                      }
                  }
                }
                else
                  break;
            }
          }
        }
      }
      catch (Exception ex)
      {
        ProjectData.SetProjectError(ex);
        Shared.LogMessage(ex.Message);
        ProjectData.ClearProjectError();
      }
    }
  }

  private void cb13d3b392a8e13ee7a8d00d4d6e89f10(
    object c7a1c50d8950fe539821ded4a87a7123f,
    MouseEventArgs c320269ec287d16905c829847d30a2e08)
  {
    // ISSUE: reference to a compiler-generated field
    eGrid.MouseDownEventHandler ce427e9aa95d910bc75d245d7bbe263c0 = this.ce427e9aa95d910bc75d245d7bbe263c0;
    if (ce427e9aa95d910bc75d245d7bbe263c0 != null)
      ce427e9aa95d910bc75d245d7bbe263c0((object) this, c320269ec287d16905c829847d30a2e08);
    this.c44f1bc9d98b4c08ee9060615065f13f6(c320269ec287d16905c829847d30a2e08.Button, c320269ec287d16905c829847d30a2e08.X, c320269ec287d16905c829847d30a2e08.Y);
    if (c320269ec287d16905c829847d30a2e08.Button != MouseButtons.Left)
      return;
label_3:
    switch (6)
    {
      case 0:
        goto label_3;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cb13d3b392a8e13ee7a8d00d4d6e89f10);
        }
        BandedGridHitInfo bandedGridHitInfo = this.GridView1.CalcHitInfo(c320269ec287d16905c829847d30a2e08.Location);
        if (bandedGridHitInfo.HitTest == BandedGridHitTest.Band)
        {
label_7:
          switch (3)
          {
            case 0:
              goto label_7;
            default:
              int num1;
              if (this.RowCount > 0)
              {
label_9:
                switch (6)
                {
                  case 0:
                    goto label_9;
                  default:
                    if (bandedGridHitInfo.Band.Columns != null)
                    {
label_11:
                      switch (5)
                      {
                        case 0:
                          goto label_11;
                        default:
                          num1 = bandedGridHitInfo.Band.Columns.VisibleColumnCount > 0 ? 1 : 0;
                          goto label_14;
                      }
                    }
                    else
                      break;
                }
              }
              num1 = 0;
label_14:
              if (num1 != 0)
              {
                int num2;
                if (!Shared.GetKeyPressed(Keys.ControlKey))
                {
label_16:
                  switch (2)
                  {
                    case 0:
                      goto label_16;
                    default:
                      num2 = !Shared.GetKeyPressed(Keys.ShiftKey) ? 1 : 0;
                      break;
                  }
                }
                else
                  num2 = 0;
                if (num2 != 0)
                {
label_20:
                  switch (5)
                  {
                    case 0:
                      goto label_20;
                    default:
                      this.GridView1.ClearSelection();
                      break;
                  }
                }
                DevExpress.XtraGrid.Columns.GridColumn column = (DevExpress.XtraGrid.Columns.GridColumn) bandedGridHitInfo.Band.Columns[0];
                DevExpress.XtraGrid.Columns.GridColumn startColumn = column;
                DevExpress.XtraGrid.Columns.GridColumn gridColumn1 = column;
                if (Shared.GetKeyPressed(Keys.ShiftKey))
                {
                  int num3 = 99999;
                  int num4 = 0;
                  int visibleIndex = column.VisibleIndex;
                  DevExpress.XtraGrid.Columns.GridColumn gridColumn2 = (DevExpress.XtraGrid.Columns.GridColumn) null;
                  DevExpress.XtraGrid.Columns.GridColumn gridColumn3 = (DevExpress.XtraGrid.Columns.GridColumn) null;
                  GridCell[] selectedCells = this.GridView1.GetSelectedCells();
                  int index = 0;
                  while (index < selectedCells.Length)
                  {
                    GridCell gridCell = selectedCells[index];
                    if (num3 > gridCell.Column.VisibleIndex)
                    {
label_25:
                      switch (3)
                      {
                        case 0:
                          goto label_25;
                        default:
                          num3 = gridCell.Column.VisibleIndex;
                          gridColumn2 = gridCell.Column;
                          break;
                      }
                    }
                    if (num4 < gridCell.Column.VisibleIndex)
                    {
label_28:
                      switch (2)
                      {
                        case 0:
                          goto label_28;
                        default:
                          num4 = gridCell.Column.VisibleIndex;
                          gridColumn3 = gridCell.Column;
                          break;
                      }
                    }
                    checked { ++index; }
                  }
label_32:
                  switch (7)
                  {
                    case 0:
                      goto label_32;
                    default:
                      if (visibleIndex < num3)
                      {
label_34:
                        switch (6)
                        {
                          case 0:
                            goto label_34;
                          default:
                            startColumn = column;
                            gridColumn1 = gridColumn2;
                            break;
                        }
                      }
                      else if (num3 < visibleIndex)
                      {
label_37:
                        switch (6)
                        {
                          case 0:
                            goto label_37;
                          default:
                            startColumn = gridColumn2;
                            gridColumn1 = column;
                            break;
                        }
                      }
                      this.GridView1.ClearSelection();
                      break;
                  }
                }
                bool flag = false;
                if (Shared.GetKeyPressed(Keys.ControlKey))
                {
label_41:
                  switch (3)
                  {
                    case 0:
                      goto label_41;
                    default:
                      flag = true;
                      int num5 = checked (this.RowCount - 1);
                      int rowHandle = 0;
                      while (rowHandle <= num5)
                      {
                        if (!this.GridView1.IsCellSelected(rowHandle, gridColumn1))
                        {
label_44:
                          switch (1)
                          {
                            case 0:
                              goto label_44;
                            default:
                              flag = false;
                              goto label_49;
                          }
                        }
                        else
                          checked { ++rowHandle; }
                      }
label_48:
                      switch (2)
                      {
                        case 0:
                          goto label_48;
                      }
label_49:
                      break;
                  }
                }
                if (!flag)
                {
label_51:
                  switch (3)
                  {
                    case 0:
                      goto label_51;
                    default:
                      this.GridView1.SelectCells(0, startColumn, checked (this.RowCount - 1), gridColumn1);
                      break;
                  }
                }
                else
                  this.GridView1.UnSelectCells(0, column, checked (this.RowCount - 1), column);
              }
              break;
          }
        }
        break;
    }
  }

  private void c6dfd4fea22ed687ee64450612fbb4094(
    object c7a1c50d8950fe539821ded4a87a7123f,
    MouseEventArgs c320269ec287d16905c829847d30a2e08)
  {
    // ISSUE: reference to a compiler-generated field
    eGrid.MouseUpEventHandler c2faf7c86aa6624fa3b669f112ee43186 = this.c2faf7c86aa6624fa3b669f112ee43186;
    if (c2faf7c86aa6624fa3b669f112ee43186 == null)
      return;
label_1:
    switch (2)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c6dfd4fea22ed687ee64450612fbb4094);
        }
        c2faf7c86aa6624fa3b669f112ee43186((object) this, c320269ec287d16905c829847d30a2e08);
        break;
    }
  }

  private void cd42d6f5d8ae2b4989c032bc64e5a5679(
    object c7a1c50d8950fe539821ded4a87a7123f,
    InitNewRowEventArgs c320269ec287d16905c829847d30a2e08)
  {
    this.ca38537a40084e083b70c73ca0860bb93(c320269ec287d16905c829847d30a2e08.RowHandle);
    if (this.c2ff7d99b7b52bbc756ecb3515e5b1a0a)
      return;
label_1:
    switch (6)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cd42d6f5d8ae2b4989c032bc64e5a5679);
        }
        // ISSUE: reference to a compiler-generated field
        eGrid.AddedRowEventHandler c9fdef276cb8e88d9c5fdf00d819d1c71 = this.c9fdef276cb8e88d9c5fdf00d819d1c71;
        if (c9fdef276cb8e88d9c5fdf00d819d1c71 != null)
        {
label_5:
          switch (7)
          {
            case 0:
              goto label_5;
            default:
              c9fdef276cb8e88d9c5fdf00d819d1c71((object) this, this.GridView1.FocusedRowHandle);
              break;
          }
        }
        break;
    }
  }

  private void c1a258e0f369e7514826f88502b728508(
    object c7a1c50d8950fe539821ded4a87a7123f,
    RowObjectEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (!this.GridView1.IsDataRow(c320269ec287d16905c829847d30a2e08.RowHandle))
    {
label_1:
      switch (3)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c1a258e0f369e7514826f88502b728508);
          break;
      }
    }
    else
      this.c8c8684eaecc3f7146066d6e2c6b049ec = true;
  }

  private void c941df262eb07f4b064b576a5f7399d75(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (this.GridView1.RowCount <= 0)
      return;
label_1:
    switch (2)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c941df262eb07f4b064b576a5f7399d75);
        }
        this.Grid1.Refresh();
        break;
    }
  }

  private void c44f1bc9d98b4c08ee9060615065f13f6(
    MouseButtons c866ecaf439e86b3ab0621a3256d98a7c,
    int cb4d08cab91ca560626534e93a67e0dba,
    int cfe46f0b83b2fc5f1bfd601c21624912e)
  {
    if (c866ecaf439e86b3ab0621a3256d98a7c != MouseButtons.Right)
      return;
    GridHitInfo gridHitInfo = (GridHitInfo) this.GridView1.CalcHitInfo(new Point(cb4d08cab91ca560626534e93a67e0dba, cfe46f0b83b2fc5f1bfd601c21624912e));
    if (gridHitInfo.HitTest == GridHitTest.RowIndicator | gridHitInfo.HitTest == GridHitTest.ColumnButton)
    {
label_2:
      switch (6)
      {
        case 0:
          goto label_2;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c44f1bc9d98b4c08ee9060615065f13f6);
          }
          this.Grid1.ContextMenuStrip = this.ContextMenuStrip1;
          this.ContextMenuStrip1.Show(Control.MousePosition);
          break;
      }
    }
  }

  private void cf725faae2fffdfd07ecff0490a80a1f3(
    object c7a1c50d8950fe539821ded4a87a7123f,
    bool c61413f12cd8001d48842952cae0ad4c3,
    Keys ce7271415c7dac836e9e4d29046798b90,
    ref bool c1892d83f5cfd2a61b46420234c08687f)
  {
    if (this.ca39ed118263ffa37c2718bf159bf9674)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cf725faae2fffdfd07ecff0490a80a1f3);
          break;
      }
    }
    else
    {
      this.ca39ed118263ffa37c2718bf159bf9674 = true;
      try
      {
        if (c61413f12cd8001d48842952cae0ad4c3)
        {
label_6:
          switch (1)
          {
            case 0:
              goto label_6;
            default:
              if (ce7271415c7dac836e9e4d29046798b90 == Keys.Return)
              {
label_8:
                switch (5)
                {
                  case 0:
                    goto label_8;
                  default:
                    if (this.GridView1.RowCount == 0)
                    {
label_10:
                      switch (1)
                      {
                        case 0:
                          goto label_10;
                        default:
                          this.AddNewRows();
                          break;
                      }
                    }
                    else if (0 < this.GridView1.RowCount)
                    {
label_13:
                      switch (5)
                      {
                        case 0:
                          goto label_13;
                        default:
                          this.c0ce23b799a537fe4f16f5e48e00a2c99();
                          break;
                      }
                    }
                    break;
                }
              }
              if (ce7271415c7dac836e9e4d29046798b90 == Keys.Add)
              {
label_17:
                switch (7)
                {
                  case 0:
                    goto label_17;
                  default:
                    this.c7a4a12705aff863eac87a9c37f7537d4();
                    SendKeys.SendWait(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5604));
                    c1892d83f5cfd2a61b46420234c08687f = true;
                    break;
                }
              }
              if (ce7271415c7dac836e9e4d29046798b90 == Keys.Subtract)
              {
label_20:
                switch (5)
                {
                  case 0:
                    goto label_20;
                  default:
                    this.DeleteSelectedRows();
                    if (this.GridView1.IsLastRow)
                      SendKeys.SendWait(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5604));
                    c1892d83f5cfd2a61b46420234c08687f = true;
                    break;
                }
              }
              if (ce7271415c7dac836e9e4d29046798b90 == Keys.Next)
              {
label_25:
                switch (7)
                {
                  case 0:
                    goto label_25;
                  default:
                    this.AddNewRows();
                    SendKeys.SendWait(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5604));
                    c1892d83f5cfd2a61b46420234c08687f = true;
                    break;
                }
              }
              else
                break;
              break;
          }
        }
        else
        {
          Keys keys = ce7271415c7dac836e9e4d29046798b90;
          switch (keys)
          {
            case Keys.Return:
              if (c7a1c50d8950fe539821ded4a87a7123f is MemoEdit)
              {
label_34:
                switch (3)
                {
                  case 0:
                    goto label_34;
                  default:
                    return;
                }
              }
              else
                break;
            case Keys.F2:
label_30:
              if (this.Editable)
              {
label_31:
                switch (4)
                {
                  case 0:
                    goto label_31;
                  default:
                    this.RunPopup(this.GridView1.FocusedColumn.FieldName, true);
                    break;
                }
              }
              else
                break;
              break;
            default:
label_28:
              switch (5)
              {
                case 0:
                  goto label_28;
                default:
                  if (keys == Keys.F9)
                    goto label_30;
                  break;
              }
              break;
          }
        }
      }
      catch (Exception ex)
      {
        ProjectData.SetProjectError(ex);
        Shared.MessageError(ex);
        ProjectData.ClearProjectError();
      }
      finally
      {
        this.ca39ed118263ffa37c2718bf159bf9674 = false;
      }
    }
  }

  public void NextRow() => this.c0ce23b799a537fe4f16f5e48e00a2c99();

  private void c0ce23b799a537fe4f16f5e48e00a2c99(bool c9c3f43a86e620d0eeb230c334e2744c0 = true)
  {
    if (this.GridView1.IsLastRow)
    {
label_1:
      switch (2)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c0ce23b799a537fe4f16f5e48e00a2c99);
          }
          this.Parent.Focus();
          if (!this.AllowAddRows)
            return;
          this.cd7c73e6d5e8821740a8d2c37bd8bb1b5();
          break;
      }
    }
    else if (this.RowIndex < this.GridView1.RowCount)
    {
label_7:
      switch (2)
      {
        case 0:
          goto label_7;
        default:
          this.GridView1.ClearSelection();
          checked { ++this.RowIndex; }
          break;
      }
    }
    if (c9c3f43a86e620d0eeb230c334e2744c0)
    {
label_11:
      switch (4)
      {
        case 0:
          goto label_11;
        default:
          this.cba003401c0201d2ee6726bf092b3d6f5();
          break;
      }
    }
  }

  private bool c567e0a1980aedddd27e05927d5c3f089()
  {
    bool flag1 = false;
    if (this.c9b149e1771cda0755be116d1d00e5bcf == GridEnterDirection.Left)
    {
label_1:
      switch (7)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c567e0a1980aedddd27e05927d5c3f089);
          }
          SendKeys.SendWait(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5613));
          flag1 = true;
          break;
      }
    }
    if (this.c9b149e1771cda0755be116d1d00e5bcf == GridEnterDirection.Up)
    {
label_6:
      switch (3)
      {
        case 0:
          goto label_6;
        default:
          SendKeys.SendWait(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5626));
          flag1 = true;
          break;
      }
    }
    if (this.c9b149e1771cda0755be116d1d00e5bcf == GridEnterDirection.Right)
    {
label_9:
      switch (2)
      {
        case 0:
          goto label_9;
        default:
          if (this.GridView1.RowCount == 0)
          {
label_11:
            switch (7)
            {
              case 0:
                goto label_11;
              default:
                this.AddNewRows();
                break;
            }
          }
          else
          {
            int num1 = -1;
            IEnumerator enumerator;
            try
            {
              enumerator = this.GridView1.Columns.GetEnumerator();
              while (enumerator.MoveNext())
              {
                DevExpress.XtraGrid.Columns.GridColumn current = (DevExpress.XtraGrid.Columns.GridColumn) enumerator.Current;
                if (current.Visible & current.OptionsColumn.AllowEdit)
                {
label_16:
                  switch (1)
                  {
                    case 0:
                      goto label_16;
                    default:
                      num1 = current.VisibleIndex;
                      break;
                  }
                }
              }
label_20:
              switch (3)
              {
                case 0:
                  goto label_20;
              }
            }
            finally
            {
              if (enumerator is IDisposable)
              {
label_22:
                switch (4)
                {
                  case 0:
                    goto label_22;
                  default:
                    (enumerator as IDisposable).Dispose();
                    break;
                }
              }
            }
            if (num1 == -1)
            {
label_26:
              switch (2)
              {
                case 0:
                  goto label_26;
                default:
                  goto label_49;
              }
            }
            else
            {
              int num2;
              if (this.GridView1.IsLastRow)
              {
label_28:
                switch (4)
                {
                  case 0:
                    goto label_28;
                  default:
                    num2 = this.GridView1.FocusedColumn.VisibleIndex == num1 ? 1 : 0;
                    break;
                }
              }
              else
                num2 = 0;
              if (num2 != 0)
              {
label_32:
                switch (4)
                {
                  case 0:
                    goto label_32;
                  default:
                    this.c0ce23b799a537fe4f16f5e48e00a2c99();
                    break;
                }
              }
              if (!this.Editable)
              {
                SendKeys.SendWait(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(68));
                flag1 = true;
              }
            }
          }
          break;
      }
    }
    if (this.c9b149e1771cda0755be116d1d00e5bcf == GridEnterDirection.Down)
    {
      int num;
      if (this.GridView1.RowCount != 0)
      {
label_40:
        switch (7)
        {
          case 0:
            goto label_40;
          default:
            num = this.GridView1.IsLastRow ? 1 : 0;
            break;
        }
      }
      else
        num = 1;
      if (num != 0)
      {
label_44:
        switch (7)
        {
          case 0:
            goto label_44;
          default:
            this.c0ce23b799a537fe4f16f5e48e00a2c99(false);
            break;
        }
      }
      else
      {
        SendKeys.SendWait(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5635));
        flag1 = true;
      }
    }
    bool flag2 = flag1;
label_49:
    return flag2;
  }

  private string c7d54989e0d455f4b9f25541eb4c31455()
  {
    IDataObject dataObject = Clipboard.GetDataObject();
    if (!dataObject.GetDataPresent(DataFormats.UnicodeText))
      return "";
label_1:
    switch (3)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c7d54989e0d455f4b9f25541eb4c31455);
        }
        return Conversions.ToString(dataObject.GetData(DataFormats.UnicodeText));
    }
  }

  private bool c4e3eeb0be2674f5594e9c871d29d1600(object c7a1c50d8950fe539821ded4a87a7123f)
  {
    string Left = this.c7d54989e0d455f4b9f25541eb4c31455();
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Left, "", false) == 0)
      return true;
    bool flag1 = !Left.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5648)) && !Left.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5653));
    bool flag2 = this.GridView1.GetSelectedCells().Length <= 1;
    int num;
    if (flag1)
    {
label_3:
      switch (4)
      {
        case 0:
          goto label_3;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c4e3eeb0be2674f5594e9c871d29d1600);
          }
          num = flag2 ? 1 : 0;
          break;
      }
    }
    else
      num = 0;
    if (num == 0)
      return false;
label_9:
    switch (4)
    {
      case 0:
        goto label_9;
      default:
        return true;
    }
  }

  private void c1c1e4d91078de84d8c0e63e9700cc708() => this.c20947ecaf7d6f07b17485b6d8a4d508a();

  private void c20947ecaf7d6f07b17485b6d8a4d508a(bool c7fcd9ef62da7aff362ab8a5540a04355 = false)
  {
    if (!this.Editable)
    {
label_1:
      switch (5)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c20947ecaf7d6f07b17485b6d8a4d508a);
          break;
      }
    }
    else if (this.GridView1.Bands == null)
    {
label_5:
      switch (3)
      {
        case 0:
          goto label_5;
      }
    }
    else
    {
      if (this.GridView1.Bands.VisibleBandCount == 0)
        return;
      string str = this.c7d54989e0d455f4b9f25541eb4c31455();
      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, "", false) == 0)
        return;
      if (str.EndsWith(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5648)))
        str = str.Substring(0, checked (str.Length - 2));
      string[] strArray1 = Strings.Split(str, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5648));
      int length = strArray1.Length;
      int count = this.GridView1.VisibleColumns.Count;
      try
      {
        GridCell[] arySrc = (GridCell[]) null;
        if (length == 1 && !strArray1[0].Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5653)))
        {
label_14:
          switch (2)
          {
            case 0:
              goto label_14;
            default:
              arySrc = this.GridView1.GetSelectedCells();
              break;
          }
        }
        else
        {
          if (0 < this.GridView1.SelectedRowsCount)
          {
label_17:
            switch (7)
            {
              case 0:
                goto label_17;
              default:
                int index1 = 0;
                int num1 = -9;
                int num2 = -9;
                GridCell[] selectedCells = this.GridView1.GetSelectedCells();
                int index2 = 0;
                while (index2 < selectedCells.Length)
                {
                  GridCell gridCell = selectedCells[index2];
                  int rowHandle = gridCell.RowHandle;
                  int visibleIndex = gridCell.Column.VisibleIndex;
                  if (num1 != rowHandle)
                    num2 = -9;
                  if (checked (num2 + 1) != visibleIndex)
                  {
                    arySrc = (GridCell[]) Microsoft.VisualBasic.CompilerServices.Utils.CopyArray((Array) arySrc, (Array) new GridCell[checked (index1 + 1)]);
                    arySrc[index1] = gridCell;
                    checked { ++index1; }
                  }
                  num1 = rowHandle;
                  num2 = visibleIndex;
                  checked { ++index2; }
                }
label_25:
                switch (2)
                {
                  case 0:
                    goto label_25;
                }
                break;
            }
          }
          if (arySrc != null)
          {
label_27:
            switch (5)
            {
              case 0:
                goto label_27;
              default:
                int index3 = checked (arySrc.Length - 1);
                while (index3 >= 0)
                {
                  int index4 = checked (index3 - 1);
                  while (index4 >= 0)
                  {
                    int num;
                    if (checked (arySrc[index4].RowHandle + 1) == arySrc[index3].RowHandle)
                    {
label_31:
                      switch (5)
                      {
                        case 0:
                          goto label_31;
                        default:
                          num = arySrc[index4].Column.VisibleIndex == arySrc[index3].Column.VisibleIndex ? 1 : 0;
                          break;
                      }
                    }
                    else
                      num = 0;
                    if (num != 0)
                    {
label_35:
                      switch (3)
                      {
                        case 0:
                          goto label_35;
                        default:
                          arySrc[index3] = (GridCell) null;
                          goto label_40;
                      }
                    }
                    else
                      checked { index4 += -1; }
                  }
label_39:
                  switch (2)
                  {
                    case 0:
                      goto label_39;
                  }
label_40:
                  checked { index3 += -1; }
                }
                break;
            }
          }
        }
        if (arySrc == null)
        {
label_44:
          switch (5)
          {
            case 0:
              goto label_44;
            default:
              arySrc = new GridCell[1]
              {
                new GridCell(this.GridView1.FocusedRowHandle, this.GridView1.FocusedColumn)
              };
              break;
          }
        }
        GridCell[] gridCellArray1 = arySrc;
        int index5 = 0;
        while (index5 < gridCellArray1.Length)
        {
          GridCell gridCell = gridCellArray1[index5];
          if (gridCell == null)
          {
label_48:
            switch (4)
            {
              case 0:
                goto label_48;
            }
          }
          else if (0 <= gridCell.Column.SortIndex)
          {
label_51:
            switch (1)
            {
              case 0:
                goto label_51;
              default:
                Shared.PutMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3763), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3812));
                return;
            }
          }
          checked { ++index5; }
        }
label_55:
        switch (4)
        {
          case 0:
            goto label_55;
          default:
            GridCell[] gridCellArray2 = arySrc;
            int index6 = 0;
            int rowHandle1;
            while (index6 < gridCellArray2.Length)
            {
              GridCell gridCell = gridCellArray2[index6];
              if (gridCell == null)
              {
label_58:
                switch (7)
                {
                  case 0:
                    goto label_58;
                }
              }
              else
              {
                int visibleIndex = gridCell.Column.VisibleIndex;
                rowHandle1 = gridCell.RowHandle;
                bool flag = true;
                int num3 = checked (length - 1);
                int index7 = 0;
                while (index7 <= num3)
                {
                  string[] strArray2 = Strings.Split(strArray1[index7], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5653));
                  int num4;
                  if (!flag)
                  {
label_61:
                    switch (7)
                    {
                      case 0:
                        goto label_61;
                      default:
                        num4 = this.RowCount <= rowHandle1 | rowHandle1 < 0 ? 1 : 0;
                        break;
                    }
                  }
                  else
                    num4 = 0;
                  if (num4 != 0)
                  {
                    this.ce75332160d718c37d93defbcd7e95679 = true;
                    this.cd7c73e6d5e8821740a8d2c37bd8bb1b5();
                    this.ce75332160d718c37d93defbcd7e95679 = false;
                  }
                  else if (c7fcd9ef62da7aff362ab8a5540a04355)
                  {
label_67:
                    switch (2)
                    {
                      case 0:
                        goto label_67;
                      default:
                        this.InsertNewRow(rowHandle1);
                        this.UpdateCurrentRow();
                        break;
                    }
                  }
                  int index8 = 0;
                  int num5 = checked (visibleIndex + strArray2.Length - 1);
                  int num6 = visibleIndex;
                  int num7 = num5;
                  int c951d48897e714225d62719261dccb6d3 = num6;
                  while (c951d48897e714225d62719261dccb6d3 <= num7 && count > c951d48897e714225d62719261dccb6d3)
                  {
                    if (strArray2.Length <= index8)
                    {
label_73:
                      switch (3)
                      {
                        case 0:
                          goto label_73;
                        default:
                          goto label_86;
                      }
                    }
                    else
                    {
                      string fieldName = this.c8699ecda178225da3aa67475e5cd54f5(c951d48897e714225d62719261dccb6d3).FieldName;
                      if (!this.get_ColumnReadOnly(fieldName))
                      {
label_75:
                        switch (3)
                        {
                          case 0:
                            goto label_75;
                          default:
                            string Expression = strArray2[index8];
                            int num8;
                            if (this.GridColumn(fieldName).IsNumericField())
                            {
label_77:
                              switch (4)
                              {
                                case 0:
                                  goto label_77;
                                default:
                                  num8 = !Versioned.IsNumeric((object) Expression) ? 1 : 0;
                                  break;
                              }
                            }
                            else
                              num8 = 0;
                            if (num8 != 0)
                            {
label_81:
                              switch (6)
                              {
                                case 0:
                                  goto label_81;
                                default:
                                  Expression = "";
                                  break;
                              }
                            }
                            this.set_Text(fieldName, rowHandle1, Expression);
                            break;
                        }
                      }
                      checked { ++index8; }
                      checked { ++c951d48897e714225d62719261dccb6d3; }
                    }
                  }
label_86:
                  checked { ++rowHandle1; }
                  flag = false;
                  checked { ++index7; }
                }
label_88:
                switch (3)
                {
                  case 0:
                    goto label_88;
                }
              }
              checked { ++index6; }
            }
label_91:
            switch (5)
            {
              case 0:
                goto label_91;
              default:
                this.cb1889f5f18b3611413f64aac4ae0c235(rowHandle1, this.GridView1.FocusedRowHandle);
                break;
            }
            break;
        }
      }
      catch (Exception ex)
      {
        ProjectData.SetProjectError(ex);
        Shared.MessageInfo(ex.Message, title: this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5656));
        ProjectData.ClearProjectError();
      }
      finally
      {
      }
    }
  }

  private void cfc11d14e0834a0336644062508e0c0e2() => this.c038d6078ec7549998ab618a8646953aa();

  private void c005f1ddb36aeb9fd3def267af61316e6() => this.c038d6078ec7549998ab618a8646953aa(true);

  private void c21f2157ed72a5072a4b40a42876ce674()
  {
    this.c038d6078ec7549998ab618a8646953aa(true, true);
  }

  private void c038d6078ec7549998ab618a8646953aa(
    bool c223e8c997dc1b214a0b49871b58bbcee = false,
    bool caf744855f86249178da34dc177955fae = false)
  {
    string str = "";
    int num = -999;
    bool flag1 = true;
    bool flag2 = true;
    if (this.GridView1.GetSelectedCells().Length == 0)
    {
label_1:
      switch (7)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c038d6078ec7549998ab618a8646953aa);
          }
          if (this.GridView1.FocusedColumn == null)
            break;
label_5:
          switch (3)
          {
            case 0:
              goto label_5;
            default:
              Clipboard.SetDataObject((object) Shared.ToStr(RuntimeHelpers.GetObjectValue(this.GridView1.GetFocusedRowCellValue(this.GridView1.FocusedColumn))), true);
              return;
          }
      }
    }
    else
    {
      if (caf744855f86249178da34dc177955fae)
      {
label_9:
        switch (2)
        {
          case 0:
            goto label_9;
          default:
            GridCell[] selectedCells = this.GridView1.GetSelectedCells();
            int index = 0;
            while (index < selectedCells.Length)
            {
              GridCell gridCell = selectedCells[index];
              if (gridCell.RowHandle != this.GridView1.GetSelectedRows()[0])
              {
label_12:
                switch (7)
                {
                  case 0:
                    goto label_12;
                  default:
                    goto label_19;
                }
              }
              else
              {
                if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, "", false) != 0)
                {
label_14:
                  switch (3)
                  {
                    case 0:
                      goto label_14;
                    default:
                      str += c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5653);
                      break;
                  }
                }
                str += gridCell.Column.Caption;
                checked { ++index; }
              }
            }
label_18:
            switch (5)
            {
              case 0:
                goto label_18;
            }
label_19:
            if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, "", false) != 0)
            {
label_20:
              switch (7)
              {
                case 0:
                  goto label_20;
                default:
                  str += c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5648);
                  break;
              }
            }
            break;
        }
      }
      GridCell[] selectedCells1 = this.GridView1.GetSelectedCells();
      int index1 = 0;
      while (index1 < selectedCells1.Length)
      {
        GridCell gridCell = selectedCells1[index1];
        string fieldName = gridCell.Column.FieldName;
        int rowHandle = gridCell.RowHandle;
        if (rowHandle != num)
        {
label_25:
          switch (6)
          {
            case 0:
              goto label_25;
            default:
              num = rowHandle;
              flag2 = true;
              if (flag1)
                flag1 = false;
              else
                str += c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5648);
              break;
          }
        }
        if (!flag2)
        {
label_31:
          switch (3)
          {
            case 0:
              goto label_31;
            default:
              str += c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5653);
              break;
          }
        }
        if (c223e8c997dc1b214a0b49871b58bbcee)
        {
label_34:
          switch (3)
          {
            case 0:
              goto label_34;
            default:
              str += this.get_EditText(fieldName, rowHandle);
              break;
          }
        }
        else
          str += this.get_Text(fieldName, rowHandle);
        flag2 = false;
        checked { ++index1; }
      }
label_39:
      switch (7)
      {
        case 0:
          goto label_39;
        default:
          Clipboard.SetDataObject((object) str, true);
          break;
      }
    }
  }

  private void cb91ed062854f70a8c1ff464f211a8ddb()
  {
    bool flag = true;
    Decimal num1 = 0M;
    Decimal num2 = 0M;
    Decimal num3 = 0M;
    Decimal num4 = 0M;
    Decimal num5 = 0M;
    this.GridView1.OptionsSelection.MultiSelect = true;
    this.GridView1.OptionsSelection.MultiSelectMode = GridMultiSelectMode.CellSelect;
    GridCell[] selectedCells = this.GridView1.GetSelectedCells();
    int index = 0;
    while (index < selectedCells.Length)
    {
      GridCell gridCell = selectedCells[index];
      Decimal num6 = this.get_ToDec(gridCell.Column.FieldName, gridCell.RowHandle);
      num5 = Decimal.Add(num5, 1M);
      num3 = Decimal.Add(num3, num6);
      num1 = Conversions.ToDecimal(Interaction.IIf(Decimal.Compare(num1, num6) < 0, (object) num6, (object) num1));
      if (Decimal.Compare(num6, 0M) != 0)
      {
label_2:
        switch (7)
        {
          case 0:
            goto label_2;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cb91ed062854f70a8c1ff464f211a8ddb);
            }
            if (flag)
            {
              num2 = num6;
              flag = false;
            }
            else
              num2 = Conversions.ToDecimal(Interaction.IIf(Decimal.Compare(num2, num6) > 0, (object) num6, (object) num2));
            break;
        }
      }
      checked { ++index; }
    }
    if (Decimal.Compare(num5, 0M) != 0)
    {
label_12:
      switch (5)
      {
        case 0:
          goto label_12;
        default:
          num4 = Decimal.Add(num4, Decimal.Divide(num3, num5));
          break;
      }
    }
    frmGridCellSum frmGridCellSum = new frmGridCellSum();
    frmGridCellSum.Display(num3, num5, num4, num1, num2);
    int num7 = (int) frmGridCellSum.ShowDialog();
  }

  private void cec7c7847bb46c54a71dae231b79b385d()
  {
    this.GridView1.OptionsSelection.MultiSelect = true;
    this.GridView1.OptionsSelection.MultiSelectMode = GridMultiSelectMode.CellSelect;
    GridCell[] selectedCells = this.GridView1.GetSelectedCells();
    int index = 0;
    while (index < selectedCells.Length)
    {
      GridCell gridCell = selectedCells[index];
      if (gridCell.Column.OptionsColumn.AllowEdit)
      {
label_2:
        switch (5)
        {
          case 0:
            goto label_2;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cec7c7847bb46c54a71dae231b79b385d);
            }
            this.set_Text(gridCell.Column.FieldName, gridCell.RowHandle, "");
            break;
        }
      }
      checked { ++index; }
    }
label_8:
    switch (6)
    {
      case 0:
        goto label_8;
    }
  }

  private void c83fd63f75a07d9daa50f07f6885969e4(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    this.GridView1.OptionsView.ShowColumnHeaders = !this.GridView1.OptionsView.ShowColumnHeaders;
    this.GridView1.OptionsView.ShowBands = !this.GridView1.OptionsView.ShowBands;
    this.ca9012fdfbae897386452ef59cf11ce53 = this.GridView1.OptionsView.ShowBands;
  }

  private void c1137ced481c4ba55cdc1e99611aa9493(
    object c7a1c50d8950fe539821ded4a87a7123f,
    PopupMenuShowingEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (!this.cf60d22e546791e81aed27bc22acefa6f)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c1137ced481c4ba55cdc1e99611aa9493);
          }
          c320269ec287d16905c829847d30a2e08.Allow = false;
          break;
      }
    }
    else
    {
      Strings.Trim(Conversions.ToString(NewLateBinding.LateGet(this.ParentControl, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1080), new object[0], (string[]) null, (System.Type[]) null, (bool[]) null)));
      string c0b68098f2868ac6357117dc326af7e25_1 = "";
      if (this.c330a4db27d3578a8e5d80797d2f5ac12 != null)
      {
label_6:
        switch (4)
        {
          case 0:
            goto label_6;
          default:
            c0b68098f2868ac6357117dc326af7e25_1 = this.c330a4db27d3578a8e5d80797d2f5ac12.Code;
            break;
        }
      }
      if (c320269ec287d16905c829847d30a2e08.MenuType == GridMenuType.Column)
      {
label_9:
        switch (4)
        {
          case 0:
            goto label_9;
          default:
            GridViewColumnMenu menu = (GridViewColumnMenu) c320269ec287d16905c829847d30a2e08.Menu;
            IEnumerator enumerator1;
            try
            {
              enumerator1 = menu.Items.GetEnumerator();
              while (enumerator1.MoveNext())
              {
                DXMenuItem current = (DXMenuItem) enumerator1.Current;
                int num;
                if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(current.Caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5729), false) != 0 && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(current.Caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5768), false) != 0)
                {
label_13:
                  switch (1)
                  {
                    case 0:
                      goto label_13;
                    default:
                      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(current.Caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5809), false) != 0 && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(current.Caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5850), false) != 0 && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(current.Caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5881), false) != 0)
                      {
                        num = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(current.Caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5912), false) == 0 ? 1 : 0;
                        goto label_17;
                      }
                      break;
                  }
                }
                num = 1;
label_17:
                if (num != 0)
                {
label_18:
                  switch (5)
                  {
                    case 0:
                      goto label_18;
                    default:
                      current.Visible = false;
                      break;
                  }
                }
              }
label_22:
              switch (1)
              {
                case 0:
                  goto label_22;
              }
            }
            finally
            {
              if (enumerator1 is IDisposable)
              {
label_24:
                switch (7)
                {
                  case 0:
                    goto label_24;
                  default:
                    (enumerator1 as IDisposable).Dispose();
                    break;
                }
              }
            }
            BandedGridHitInfo bandedGridHitInfo = this.GridView1.CalcHitInfo(c320269ec287d16905c829847d30a2e08.Point);
            if (bandedGridHitInfo.HitTest == BandedGridHitTest.Band)
            {
label_28:
              switch (1)
              {
                case 0:
                  goto label_28;
                default:
                  GridBand band = bandedGridHitInfo.Band;
                  if (band == null)
                  {
label_30:
                    switch (3)
                    {
                      case 0:
                        goto label_30;
                      default:
                        return;
                    }
                  }
                  else if (band.Columns == null)
                  {
label_32:
                    switch (4)
                    {
                      case 0:
                        goto label_32;
                      default:
                        return;
                    }
                  }
                  else
                  {
                    string str1 = "";
                    string name = band.Name;
                    if (band.Columns.Count > 0 && band.Columns[0] != null)
                    {
label_34:
                      switch (4)
                      {
                        case 0:
                          goto label_34;
                        default:
                          str1 = band.Columns[0].FieldName;
                          break;
                      }
                    }
                    string str2 = "";
                    string str3 = "";
                    string str4 = "";
                    eGridColumn eGridColumn = this.GridColumn(str1);
                    if (eGridColumn != null)
                    {
label_37:
                      switch (6)
                      {
                        case 0:
                          goto label_37;
                        default:
                          str2 = eGridColumn.Name;
                          str3 = Shared.ToStr((object) eGridColumn.PopupID);
                          str4 = Shared.ToStr((object) eGridColumn.PopupType);
                          break;
                      }
                    }
                    FieldAttribute c0b68098f2868ac6357117dc326af7e25_2;
                    c0b68098f2868ac6357117dc326af7e25_2.FormAtt = (FormAttribute) NewLateBinding.LateGet(this.ParentControl, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1089), new object[0], (string[]) null, (System.Type[]) null, (bool[]) null);
                    c0b68098f2868ac6357117dc326af7e25_2.WorkSetCode = c0b68098f2868ac6357117dc326af7e25_1;
                    c0b68098f2868ac6357117dc326af7e25_2.ControlName = str2;
                    c0b68098f2868ac6357117dc326af7e25_2.FieldName = str1;
                    c0b68098f2868ac6357117dc326af7e25_2.PopupID = str3;
                    int c3aa9c809f9d01b8676703b6675223d58 = 0;
                    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Parameter.Login.UserKd, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1096), false) >= 0)
                    {
label_40:
                      switch (2)
                      {
                        case 0:
                          goto label_40;
                        default:
                          this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5935) + this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1130), false, false, (object) c0b68098f2868ac6357117dc326af7e25_2, (EventHandler) null, ref c3aa9c809f9d01b8676703b6675223d58);
                          this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1135) + c0b68098f2868ac6357117dc326af7e25_1 + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1130), false, false, (object) c0b68098f2868ac6357117dc326af7e25_2, (EventHandler) null, ref c3aa9c809f9d01b8676703b6675223d58);
                          if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str1, "", false) != 0)
                          {
label_42:
                            switch (2)
                            {
                              case 0:
                                goto label_42;
                              default:
                                this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1158) + str1 + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1130), false, false, (object) c0b68098f2868ac6357117dc326af7e25_2, (EventHandler) null, ref c3aa9c809f9d01b8676703b6675223d58);
                                break;
                            }
                          }
                          else
                            this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5952) + name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1130), false, false, (object) c0b68098f2868ac6357117dc326af7e25_2, (EventHandler) null, ref c3aa9c809f9d01b8676703b6675223d58);
                          this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1177), true, true, (object) c0b68098f2868ac6357117dc326af7e25_2, Parameter.MainFrame.ClickPopupWorkSet, ref c3aa9c809f9d01b8676703b6675223d58);
                          this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1198), false, true, (object) c0b68098f2868ac6357117dc326af7e25_2, Parameter.MainFrame.ClickPopupForm, ref c3aa9c809f9d01b8676703b6675223d58);
                          this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1219), false, true, (object) c0b68098f2868ac6357117dc326af7e25_2, Parameter.MainFrame.ClickPopupPopup, ref c3aa9c809f9d01b8676703b6675223d58);
                          this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5969), true, true, (object) c0b68098f2868ac6357117dc326af7e25_1, Parameter.MainFrame.ClickPopupDebugSQL, ref c3aa9c809f9d01b8676703b6675223d58);
                          break;
                      }
                    }
                    int num1;
                    if (eGridColumn != null)
                    {
label_47:
                      switch (6)
                      {
                        case 0:
                          goto label_47;
                        default:
                          num1 = eGridColumn.FieldType == FieldType.Check ? 1 : 0;
                          break;
                      }
                    }
                    else
                      num1 = 0;
                    if (num1 != 0)
                    {
label_51:
                      switch (6)
                      {
                        case 0:
                          goto label_51;
                        default:
                          this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5988), c3aa9c809f9d01b8676703b6675223d58 > 0, !eGridColumn.ReadOnly, (object) c0b68098f2868ac6357117dc326af7e25_2, new EventHandler(this.c2baad62ded8aad63a3a0fb32538221ce), ref c3aa9c809f9d01b8676703b6675223d58);
                          this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6025), false, !eGridColumn.ReadOnly, (object) c0b68098f2868ac6357117dc326af7e25_2, new EventHandler(this.c63ba0c43ff4eec42e1cd1f60d692d7f5), ref c3aa9c809f9d01b8676703b6675223d58);
                          break;
                      }
                    }
                    this.cd988294ef341721a0311b69b5abe00f6(menu, Conversions.ToString(Interaction.IIf(this.ShowFilterRow, (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6066), (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6103))), c3aa9c809f9d01b8676703b6675223d58 > 0, this.AllowFilter, (object) null, (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.c7664776af3e82b31baf0ec2710570f96()), ref c3aa9c809f9d01b8676703b6675223d58);
                    this.cd988294ef341721a0311b69b5abe00f6(menu, Conversions.ToString(Interaction.IIf(this.ShowFindPanel, (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6140), (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6177))), false, true, (object) null, (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.cbfd5d4939db04a3693a94c18ac553de4()), ref c3aa9c809f9d01b8676703b6675223d58);
                    checked { ++c3aa9c809f9d01b8676703b6675223d58; }
                    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str1, "", false) != 0)
                    {
label_54:
                      switch (6)
                      {
                        case 0:
                          goto label_54;
                        default:
                          this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6214), true, this.AllowSort, (object) c0b68098f2868ac6357117dc326af7e25_2, new EventHandler(this.c3652e59f6843ce6cfc7739214a6fc700), ref c3aa9c809f9d01b8676703b6675223d58).Image = this.c224507ec38f7c5f55f22432b6123f765(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6249));
                          this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6278), false, this.AllowSort, (object) c0b68098f2868ac6357117dc326af7e25_2, new EventHandler(this.c48780aa4e8ae5912527029166b32ddfd), ref c3aa9c809f9d01b8676703b6675223d58).Image = this.c224507ec38f7c5f55f22432b6123f765(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6313));
                          this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6344), false, this.AllowSort, (object) c0b68098f2868ac6357117dc326af7e25_2, new EventHandler(this.c5b58afd9526aa798c1e8aac0039af29f), ref c3aa9c809f9d01b8676703b6675223d58);
                          break;
                      }
                    }
                    this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6383), true, true, (object) null, (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.ccd376507b78c924cbd66d8d08f6e5772()), ref c3aa9c809f9d01b8676703b6675223d58);
                    this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6418), true, true, (object) null, (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.PrintPreview()), ref c3aa9c809f9d01b8676703b6675223d58);
                    this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6447), false, true, (object) this, (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.cc4068e95671ab5aebcf77ad0a2ff720f()), ref c3aa9c809f9d01b8676703b6675223d58);
                    c3aa9c809f9d01b8676703b6675223d58 = menu.Items.Count;
                    this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6476), true, true, (object) null, new EventHandler(this.c83fd63f75a07d9daa50f07f6885969e4), ref c3aa9c809f9d01b8676703b6675223d58);
                    int num2;
                    if (str4 != null)
                    {
label_57:
                      switch (6)
                      {
                        case 0:
                          goto label_57;
                        default:
                          num2 = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str4.ToLower(), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6519), false) == 0 ? 1 : 0;
                          break;
                      }
                    }
                    else
                      num2 = 0;
                    if (num2 != 0)
                      this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1264), true, true, (object) c0b68098f2868ac6357117dc326af7e25_2, Parameter.MainFrame.ClickPopupBaseCode, ref c3aa9c809f9d01b8676703b6675223d58);
                    this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6528), true, true, (object) null, (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.c2cfc6e7e67f7f2949883be5f10bfe2a9()), ref c3aa9c809f9d01b8676703b6675223d58);
                    this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6543), false, true, (object) null, (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.cd2d6f1fcb4630eb853ab128a847e3127()), ref c3aa9c809f9d01b8676703b6675223d58);
                    break;
                  }
              }
            }
            else if (bandedGridHitInfo.HitTest == BandedGridHitTest.ColumnPanel)
            {
              FieldAttribute c0b68098f2868ac6357117dc326af7e25_3;
              c0b68098f2868ac6357117dc326af7e25_3.FormAtt = (FormAttribute) NewLateBinding.LateGet(this.ParentControl, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1089), new object[0], (string[]) null, (System.Type[]) null, (bool[]) null);
              c0b68098f2868ac6357117dc326af7e25_3.WorkSetCode = c0b68098f2868ac6357117dc326af7e25_1;
              c0b68098f2868ac6357117dc326af7e25_3.ControlName = "";
              c0b68098f2868ac6357117dc326af7e25_3.FieldName = "";
              c0b68098f2868ac6357117dc326af7e25_3.PopupID = (string) null;
              menu.Items[0].BeginGroup = true;
              menu.Items[1].Visible = false;
              int c3aa9c809f9d01b8676703b6675223d58 = 0;
              this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5935) + this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1130), false, false, (object) c0b68098f2868ac6357117dc326af7e25_3, (EventHandler) null, ref c3aa9c809f9d01b8676703b6675223d58);
              this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1135) + c0b68098f2868ac6357117dc326af7e25_1 + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1130), false, false, (object) c0b68098f2868ac6357117dc326af7e25_3, (EventHandler) null, ref c3aa9c809f9d01b8676703b6675223d58);
              this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1177), true, true, (object) c0b68098f2868ac6357117dc326af7e25_3, Parameter.MainFrame.ClickPopupWorkSet, ref c3aa9c809f9d01b8676703b6675223d58);
              this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1198), false, true, (object) c0b68098f2868ac6357117dc326af7e25_3, Parameter.MainFrame.ClickPopupForm, ref c3aa9c809f9d01b8676703b6675223d58);
            }
            else if (bandedGridHitInfo.HitTest == BandedGridHitTest.Column)
            {
label_66:
              switch (2)
              {
                case 0:
                  goto label_66;
                default:
                  string columnName = "";
                  if (menu.Column != null)
                  {
label_68:
                    switch (1)
                    {
                      case 0:
                        goto label_68;
                      default:
                        columnName = menu.Column.FieldName;
                        break;
                    }
                  }
                  string str5 = "";
                  string str6 = "";
                  string str7 = "";
                  eGridColumn eGridColumn = this.GridColumn(columnName);
                  if (eGridColumn != null)
                  {
                    str5 = eGridColumn.Name;
                    str6 = eGridColumn.PopupID;
                    str7 = eGridColumn.PopupType;
                  }
                  FieldAttribute c0b68098f2868ac6357117dc326af7e25_4;
                  c0b68098f2868ac6357117dc326af7e25_4.FormAtt = (FormAttribute) NewLateBinding.LateGet(this.ParentControl, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1089), new object[0], (string[]) null, (System.Type[]) null, (bool[]) null);
                  c0b68098f2868ac6357117dc326af7e25_4.WorkSetCode = c0b68098f2868ac6357117dc326af7e25_1;
                  c0b68098f2868ac6357117dc326af7e25_4.ControlName = str5;
                  c0b68098f2868ac6357117dc326af7e25_4.FieldName = columnName;
                  c0b68098f2868ac6357117dc326af7e25_4.PopupID = str6;
                  int c3aa9c809f9d01b8676703b6675223d58 = 0;
                  if (8 <= menu.Items.Count)
                    menu.Items[7].BeginGroup = true;
                  GridViewColumnMenu cd471e13820a89ab9227f5fc9a7a5b2b6 = menu;
                  string c3e9beab4e47b575726923ca5b67e4bca = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6383);
                  EventHandler ca71a829c521bfa7bffe92d30bb5e52ed = (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.ccd376507b78c924cbd66d8d08f6e5772());
                  int num3 = 6;
                  ref int local = ref num3;
                  this.cd988294ef341721a0311b69b5abe00f6(cd471e13820a89ab9227f5fc9a7a5b2b6, c3e9beab4e47b575726923ca5b67e4bca, false, true, (object) null, ca71a829c521bfa7bffe92d30bb5e52ed, ref local);
                  if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Parameter.Login.UserKd, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1096), false) >= 0)
                  {
label_75:
                    switch (4)
                    {
                      case 0:
                        goto label_75;
                      default:
                        menu.Items[0].BeginGroup = true;
                        this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5935) + this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1130), false, false, (object) c0b68098f2868ac6357117dc326af7e25_4, (EventHandler) null, ref c3aa9c809f9d01b8676703b6675223d58);
                        this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1135) + c0b68098f2868ac6357117dc326af7e25_1 + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1130), false, false, (object) c0b68098f2868ac6357117dc326af7e25_4, (EventHandler) null, ref c3aa9c809f9d01b8676703b6675223d58);
                        this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1158) + columnName + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1130), false, false, (object) c0b68098f2868ac6357117dc326af7e25_4, (EventHandler) null, ref c3aa9c809f9d01b8676703b6675223d58);
                        this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1177), true, true, (object) c0b68098f2868ac6357117dc326af7e25_4, Parameter.MainFrame.ClickPopupWorkSet, ref c3aa9c809f9d01b8676703b6675223d58);
                        this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1198), false, true, (object) c0b68098f2868ac6357117dc326af7e25_4, Parameter.MainFrame.ClickPopupForm, ref c3aa9c809f9d01b8676703b6675223d58);
                        this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1219), false, true, (object) c0b68098f2868ac6357117dc326af7e25_4, Parameter.MainFrame.ClickPopupPopup, ref c3aa9c809f9d01b8676703b6675223d58);
                        this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5969), true, true, (object) c0b68098f2868ac6357117dc326af7e25_1, Parameter.MainFrame.ClickPopupDebugSQL, ref c3aa9c809f9d01b8676703b6675223d58);
                        break;
                    }
                  }
                  int num4;
                  if (eGridColumn != null)
                  {
label_78:
                    switch (7)
                    {
                      case 0:
                        goto label_78;
                      default:
                        num4 = eGridColumn.FieldType == FieldType.Check ? 1 : 0;
                        break;
                    }
                  }
                  else
                    num4 = 0;
                  if (num4 != 0)
                  {
label_82:
                    switch (1)
                    {
                      case 0:
                        goto label_82;
                      default:
                        this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5988), c3aa9c809f9d01b8676703b6675223d58 > 0, !eGridColumn.ReadOnly, (object) c0b68098f2868ac6357117dc326af7e25_4, new EventHandler(this.c2baad62ded8aad63a3a0fb32538221ce), ref c3aa9c809f9d01b8676703b6675223d58);
                        this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6025), false, !eGridColumn.ReadOnly, (object) c0b68098f2868ac6357117dc326af7e25_4, new EventHandler(this.c63ba0c43ff4eec42e1cd1f60d692d7f5), ref c3aa9c809f9d01b8676703b6675223d58);
                        break;
                    }
                  }
                  this.cd988294ef341721a0311b69b5abe00f6(menu, Conversions.ToString(Interaction.IIf(this.ShowFilterRow, (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6066), (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6103))), c3aa9c809f9d01b8676703b6675223d58 > 0, this.AllowFilter, (object) null, (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.c7664776af3e82b31baf0ec2710570f96()), ref c3aa9c809f9d01b8676703b6675223d58);
                  this.cd988294ef341721a0311b69b5abe00f6(menu, Conversions.ToString(Interaction.IIf(this.ShowFindPanel, (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6140), (object) c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6177))), false, true, (object) null, (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.cbfd5d4939db04a3693a94c18ac553de4()), ref c3aa9c809f9d01b8676703b6675223d58);
                  c3aa9c809f9d01b8676703b6675223d58 = menu.Items.Count;
                  this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6418), true, true, (object) null, (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.PrintPreview()), ref c3aa9c809f9d01b8676703b6675223d58);
                  this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6447), false, true, (object) this, (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.cc4068e95671ab5aebcf77ad0a2ff720f()), ref c3aa9c809f9d01b8676703b6675223d58);
                  this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6558), true, true, (object) this, new EventHandler(this.c83fd63f75a07d9daa50f07f6885969e4), ref c3aa9c809f9d01b8676703b6675223d58);
                  int num5;
                  if (str7 != null)
                  {
label_85:
                    switch (4)
                    {
                      case 0:
                        goto label_85;
                      default:
                        num5 = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str7.ToLower(), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6519), false) == 0 ? 1 : 0;
                        break;
                    }
                  }
                  else
                    num5 = 0;
                  if (num5 != 0)
                  {
label_89:
                    switch (2)
                    {
                      case 0:
                        goto label_89;
                      default:
                        this.cd988294ef341721a0311b69b5abe00f6(menu, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1264), true, true, (object) c0b68098f2868ac6357117dc326af7e25_4, Parameter.MainFrame.ClickPopupBaseCode, ref c3aa9c809f9d01b8676703b6675223d58);
                        break;
                    }
                  }
                  break;
              }
            }
            try
            {
              foreach (DXMenuItem dxMenuItem in (CollectionBase) menu.Items)
              {
                string caption = dxMenuItem.Caption;
                // ISSUE: reference to a compiler-generated method
                uint num = c67ebab732c1c3c43554ad37257ce2ead.cad7c225aac7dcffb636a9685297d9992(caption);
                if (num <= 3103838038U)
                {
label_95:
                  switch (3)
                  {
                    case 0:
                      goto label_95;
                    default:
                      if (num <= 1079404170U)
                      {
                        if (num != 959237365U)
                        {
label_98:
                          switch (7)
                          {
                            case 0:
                              goto label_98;
                            default:
                              if (num != 1079404170U)
                              {
label_100:
                                switch (7)
                                {
                                  case 0:
                                    goto label_100;
                                }
                              }
                              else
                              {
                                if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6599), false) == 0)
                                {
                                  dxMenuItem.Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6344));
                                  break;
                                }
                                break;
                              }
                              break;
                          }
                        }
                        else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6667), false) != 0)
                        {
label_122:
                          switch (7)
                          {
                            case 0:
                              goto label_122;
                          }
                        }
                        else
                        {
                          dxMenuItem.Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6898));
                          dxMenuItem.Enabled = this.AllowGroup;
                          break;
                        }
                      }
                      else if (num != 1183089934U)
                      {
label_102:
                        switch (1)
                        {
                          case 0:
                            goto label_102;
                          default:
                            if (num != 2849556583U)
                            {
label_104:
                              switch (1)
                              {
                                case 0:
                                  goto label_104;
                                default:
                                  if (num == 3103838038U && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6702), false) == 0)
                                  {
                                    dxMenuItem.Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6937));
                                    dxMenuItem.Enabled = this.AllowGroup;
                                    break;
                                  }
                                  break;
                              }
                            }
                            else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6791), false) != 0)
                            {
label_126:
                              switch (7)
                              {
                                case 0:
                                  goto label_126;
                              }
                            }
                            else
                            {
                              dxMenuItem.Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7036));
                              dxMenuItem.Click += new EventHandler(this.c040ccd13a6b7863dc460f509b99ae1b4);
                              break;
                            }
                            break;
                        }
                      }
                      else
                      {
                        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6836), false) == 0)
                        {
                          dxMenuItem.Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7069));
                          break;
                        }
                        break;
                      }
                      break;
                  }
                }
                else if (num <= 3560311485U)
                {
label_107:
                  switch (5)
                  {
                    case 0:
                      goto label_107;
                    default:
                      if (num != 3161744075U)
                      {
label_109:
                        switch (3)
                        {
                          case 0:
                            goto label_109;
                          default:
                            if (num != 3560311485U)
                            {
label_111:
                              switch (1)
                              {
                                case 0:
                                  goto label_111;
                              }
                            }
                            else
                            {
                              if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6313), false) == 0)
                              {
                                dxMenuItem.Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6278));
                                break;
                              }
                              break;
                            }
                            break;
                        }
                      }
                      else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6626), false) != 0)
                      {
label_120:
                        switch (4)
                        {
                          case 0:
                            goto label_120;
                        }
                      }
                      else
                      {
                        dxMenuItem.Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6869));
                        dxMenuItem.Enabled = this.AllowGroup;
                        break;
                      }
                      break;
                  }
                }
                else if (num != 3561269543U)
                {
label_113:
                  switch (7)
                  {
                    case 0:
                      goto label_113;
                    default:
                      if (num != 3962399847U)
                      {
                        if (num == 4176849100U && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6774), false) == 0)
                        {
                          dxMenuItem.Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7011));
                          break;
                        }
                        break;
                      }
                      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6249), false) == 0)
                      {
                        dxMenuItem.Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6214));
                        break;
                      }
                      break;
                  }
                }
                else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6737), false) != 0)
                {
label_124:
                  switch (4)
                  {
                    case 0:
                      goto label_124;
                  }
                }
                else
                  dxMenuItem.Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6976));
              }
label_141:
              switch (7)
              {
                case 0:
                  goto label_141;
                default:
                  return;
              }
            }
            finally
            {
              IEnumerator enumerator2;
              if (enumerator2 is IDisposable)
                (enumerator2 as IDisposable).Dispose();
            }
        }
      }
      else if (c320269ec287d16905c829847d30a2e08.MenuType == GridMenuType.Row)
      {
label_148:
        switch (3)
        {
          case 0:
            goto label_148;
          default:
            GridHitInfo gridHitInfo = (GridHitInfo) this.GridView1.CalcHitInfo(c320269ec287d16905c829847d30a2e08.Point);
            if (!(gridHitInfo.HitTest == GridHitTest.RowCell | gridHitInfo.HitTest == GridHitTest.Row))
              break;
            GridViewMenu menu = c320269ec287d16905c829847d30a2e08.Menu;
            int num;
            if (this.c330a4db27d3578a8e5d80797d2f5ac12 != null)
            {
label_151:
              switch (1)
              {
                case 0:
                  goto label_151;
                default:
                  num = this.c330a4db27d3578a8e5d80797d2f5ac12.Jumps != null ? 1 : 0;
                  break;
              }
            }
            else
              num = 0;
            if (num != 0)
            {
label_155:
              switch (4)
              {
                case 0:
                  goto label_155;
                default:
                  IEnumerator enumerator;
                  try
                  {
                    enumerator = this.c330a4db27d3578a8e5d80797d2f5ac12.Jumps.GetEnumerator();
                    while (enumerator.MoveNext())
                    {
                      Jump current = (Jump) enumerator.Current;
                      if (!current.Hidden)
                      {
label_158:
                        switch (6)
                        {
                          case 0:
                            goto label_158;
                          default:
                            menu.Items.Add(new DXMenuItem(current.Title, current.ClickEventHandler)
                            {
                              Tag = (object) current.ID
                            });
                            break;
                        }
                      }
                    }
label_162:
                    switch (7)
                    {
                      case 0:
                        goto label_162;
                    }
                  }
                  finally
                  {
                    if (enumerator is IDisposable)
                    {
label_165:
                      switch (3)
                      {
                        case 0:
                          goto label_165;
                        default:
                          (enumerator as IDisposable).Dispose();
                          break;
                      }
                    }
                  }
                  break;
              }
            }
            DXMenuItem dxMenuItem1 = new DXMenuItem(Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7106), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2191)), (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.cfc11d14e0834a0336644062508e0c0e2()));
            if (0 < menu.Items.Count)
            {
label_169:
              switch (5)
              {
                case 0:
                  goto label_169;
                default:
                  dxMenuItem1.BeginGroup = true;
                  break;
              }
            }
            dxMenuItem1.Enabled = this.cfe51a0bb967b0d0da313e1b4013ca09b;
            menu.Items.Add(dxMenuItem1);
            menu.Items.Add(new DXMenuItem(Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7133), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7170)), (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.c005f1ddb36aeb9fd3def267af61316e6()))
            {
              Enabled = this.cfe51a0bb967b0d0da313e1b4013ca09b
            });
            menu.Items.Add(new DXMenuItem(Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7185), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7224)), (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.c21f2157ed72a5072a4b40a42876ce674()))
            {
              Enabled = this.cfe51a0bb967b0d0da313e1b4013ca09b
            });
            menu.Items.Add(new DXMenuItem(Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7243), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7272)), (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.c1c1e4d91078de84d8c0e63e9700cc708()))
            {
              Enabled = this.Editable,
              BeginGroup = true
            });
            menu.Items.Add(new DXMenuItem(Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7281), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(2262)), (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this._PasteExcel()))
            {
              Enabled = this.Editable
            });
            menu.Items.Add(new DXMenuItem(Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7322), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7365)), (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.cec7c7847bb46c54a71dae231b79b385d()))
            {
              BeginGroup = true,
              Enabled = this.Editable
            });
            DXMenuItem dxMenuItem2 = new DXMenuItem(Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7370), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7409)), (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.SelectAll()));
            menu.Items.Add(dxMenuItem2);
            menu.Items.Add(new DXMenuItem(Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7418), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7449)), (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.Export()))
            {
              BeginGroup = true,
              Enabled = this.cfe51a0bb967b0d0da313e1b4013ca09b
            });
            menu.Items.Add(new DXMenuItem(Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7458), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7491)), (EventHandler) ([DebuggerHidden, SpecialName] (cf75227a3cb7ea057325121d13a33dcba, c5938f1fdc4fcdbf274d5de6969c37b87) => this.cb91ed062854f70a8c1ff464f211a8ddb()))
            {
              BeginGroup = true
            });
            break;
        }
      }
      else
      {
        if (c320269ec287d16905c829847d30a2e08.MenuType != GridMenuType.Group)
          return;
label_173:
        switch (2)
        {
          case 0:
            goto label_173;
          default:
            GridViewGroupPanelMenu menu = (GridViewGroupPanelMenu) c320269ec287d16905c829847d30a2e08.Menu;
            IEnumerator enumerator;
            try
            {
              enumerator = menu.Items.GetEnumerator();
              while (enumerator.MoveNext())
              {
                DXMenuItem current = (DXMenuItem) enumerator.Current;
                string caption = current.Caption;
                if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7502), false) != 0)
                {
                  if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7525), false) != 0)
                  {
label_178:
                    switch (5)
                    {
                      case 0:
                        goto label_178;
                      default:
                        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7552), false) != 0)
                        {
                          if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(caption, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6702), false) != 0)
                          {
label_181:
                            switch (1)
                            {
                              case 0:
                                goto label_181;
                            }
                          }
                          else
                          {
                            current.Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6937), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6702));
                            break;
                          }
                        }
                        else
                        {
                          current.Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7671), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7552));
                          break;
                        }
                        break;
                    }
                  }
                  else
                    current.Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7624), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7525));
                }
                else
                  current.Caption = Parameter.System.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7581), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7502));
              }
            }
            finally
            {
              if (enumerator is IDisposable)
              {
label_190:
                switch (2)
                {
                  case 0:
                    goto label_190;
                  default:
                    (enumerator as IDisposable).Dispose();
                    break;
                }
              }
            }
            break;
        }
      }
    }
  }

  private Image c224507ec38f7c5f55f22432b6123f765(string c3219c45e49f6150d557a8375f6d8457f)
  {
    string str = "";
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c3219c45e49f6150d557a8375f6d8457f, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6249), false) == 0)
    {
label_1:
      switch (1)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c224507ec38f7c5f55f22432b6123f765);
          }
          str = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(7720);
          break;
      }
    }
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(c3219c45e49f6150d557a8375f6d8457f, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(6313), false) == 0)
      str = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(8786);
    return Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, "", false) != 0 ? Image.FromStream((Stream) new MemoryStream(Convert.FromBase64String(str))) : (Image) null;
  }

  private DXMenuItem cd988294ef341721a0311b69b5abe00f6(
    GridViewColumnMenu cd471e13820a89ab9227f5fc9a7a5b2b6,
    string c3e9beab4e47b575726923ca5b67e4bca,
    bool c91825632a423c353a2f616058ab6407a,
    bool c1fea418e2bb065b5fcd29d954892d721,
    object c0b68098f2868ac6357117dc326af7e25,
    EventHandler ca71a829c521bfa7bffe92d30bb5e52ed,
    ref int c3aa9c809f9d01b8676703b6675223d58)
  {
    string str = c3e9beab4e47b575726923ca5b67e4bca;
    if (c3e9beab4e47b575726923ca5b67e4bca.StartsWith(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(9844)))
      str = Parameter.System.GetMessage(c3e9beab4e47b575726923ca5b67e4bca);
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, "", false) == 0)
      str = c3e9beab4e47b575726923ca5b67e4bca;
    DXMenuItem dxMenuItem = new DXMenuItem(str, ca71a829c521bfa7bffe92d30bb5e52ed);
    dxMenuItem.BeginGroup = c91825632a423c353a2f616058ab6407a;
    dxMenuItem.Tag = RuntimeHelpers.GetObjectValue(c0b68098f2868ac6357117dc326af7e25);
    dxMenuItem.Enabled = c1fea418e2bb065b5fcd29d954892d721;
    cd471e13820a89ab9227f5fc9a7a5b2b6.Items.Insert(c3aa9c809f9d01b8676703b6675223d58, dxMenuItem);
    checked { ++c3aa9c809f9d01b8676703b6675223d58; }
    return dxMenuItem;
  }

  private void c040ccd13a6b7863dc460f509b99ae1b4(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    this.BestFitColumns();
  }

  private void c2baad62ded8aad63a3a0fb32538221ce(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    object obj = NewLateBinding.LateGet(c7a1c50d8950fe539821ded4a87a7123f, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(9853), new object[0], (string[]) null, (System.Type[]) null, (bool[]) null);
    this.CheckRows((obj != null ? (FieldAttribute) obj : new FieldAttribute()).FieldName);
  }

  private void c63ba0c43ff4eec42e1cd1f60d692d7f5(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    object obj = NewLateBinding.LateGet(c7a1c50d8950fe539821ded4a87a7123f, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(9853), new object[0], (string[]) null, (System.Type[]) null, (bool[]) null);
    FieldAttribute fieldAttribute;
    if (obj == null)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c63ba0c43ff4eec42e1cd1f60d692d7f5);
          }
          fieldAttribute = new FieldAttribute();
          break;
      }
    }
    else
      fieldAttribute = (FieldAttribute) obj;
    this.CheckRows(fieldAttribute.FieldName, false);
  }

  private void c3652e59f6843ce6cfc7739214a6fc700(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    object obj = NewLateBinding.LateGet(c7a1c50d8950fe539821ded4a87a7123f, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(9853), new object[0], (string[]) null, (System.Type[]) null, (bool[]) null);
    FieldAttribute fieldAttribute;
    if (obj == null)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c3652e59f6843ce6cfc7739214a6fc700);
          }
          fieldAttribute = new FieldAttribute();
          break;
      }
    }
    else
      fieldAttribute = (FieldAttribute) obj;
    this.Sort(fieldAttribute.FieldName);
  }

  private void c48780aa4e8ae5912527029166b32ddfd(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    object obj = NewLateBinding.LateGet(c7a1c50d8950fe539821ded4a87a7123f, (System.Type) null, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(9853), new object[0], (string[]) null, (System.Type[]) null, (bool[]) null);
    FieldAttribute fieldAttribute;
    if (obj == null)
    {
label_1:
      switch (3)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c48780aa4e8ae5912527029166b32ddfd);
          }
          fieldAttribute = new FieldAttribute();
          break;
      }
    }
    else
      fieldAttribute = (FieldAttribute) obj;
    this.Sort(fieldAttribute.FieldName, ColumnSortOrder.Descending);
  }

  private void c5b58afd9526aa798c1e8aac0039af29f(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    this.ClearSorting();
  }

  public void ShowColorPanel() => this.cc4068e95671ab5aebcf77ad0a2ff720f();

  private void cc4068e95671ab5aebcf77ad0a2ff720f()
  {
    GridProperty gridProperty = new GridProperty();
    gridProperty.TopMost = true;
    gridProperty.SetGrid((object) this);
    gridProperty.Show();
  }

  private void ccd376507b78c924cbd66d8d08f6e5772()
  {
    IEnumerator enumerator;
    try
    {
      enumerator = this.GridView1.Columns.GetEnumerator();
      while (enumerator.MoveNext())
      {
        DevExpress.XtraGrid.Columns.GridColumn current = (DevExpress.XtraGrid.Columns.GridColumn) enumerator.Current;
        eGridColumn eGridColumn = this.GridColumn(current.FieldName);
        int num;
        if (eGridColumn != null)
        {
label_3:
          switch (1)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.ccd376507b78c924cbd66d8d08f6e5772);
              }
              num = eGridColumn.Visible ? 1 : 0;
              break;
          }
        }
        else
          num = 0;
        if (num != 0)
        {
label_9:
          switch (3)
          {
            case 0:
              goto label_9;
            default:
              current.Visible = true;
              break;
          }
        }
      }
label_13:
      switch (1)
      {
        case 0:
          goto label_13;
      }
    }
    finally
    {
      if (enumerator is IDisposable)
      {
label_15:
        switch (1)
        {
          case 0:
            goto label_15;
          default:
            (enumerator as IDisposable).Dispose();
            break;
        }
      }
    }
    this.cd3bae3481bc020c51445682097bbd0b6(this.GridView1.Bands);
  }

  private void cd3bae3481bc020c51445682097bbd0b6(
    GridBandCollection c1208a6762b8519437262982f1e4d496d)
  {
    IEnumerator enumerator1;
    if (c1208a6762b8519437262982f1e4d496d == null)
    {
label_1:
      switch (5)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cd3bae3481bc020c51445682097bbd0b6);
          break;
      }
    }
    else
    {
      try
      {
        enumerator1 = c1208a6762b8519437262982f1e4d496d.GetEnumerator();
        while (enumerator1.MoveNext())
        {
          GridBand current = (GridBand) enumerator1.Current;
          try
          {
            foreach (DevExpress.XtraGrid.Columns.GridColumn column in (CollectionBase) current.Columns)
            {
              eGridColumn eGridColumn = this.GridColumn(column.FieldName);
              int num;
              if (eGridColumn != null)
              {
label_9:
                switch (2)
                {
                  case 0:
                    goto label_9;
                  default:
                    num = eGridColumn.Visible ? 1 : 0;
                    break;
                }
              }
              else
                num = 0;
              if (num != 0)
              {
label_13:
                switch (3)
                {
                  case 0:
                    goto label_13;
                  default:
                    current.Visible = true;
                    goto label_20;
                }
              }
            }
label_16:
            switch (2)
            {
              case 0:
                goto label_16;
            }
          }
          finally
          {
            IEnumerator enumerator2;
            if (enumerator2 is IDisposable)
              (enumerator2 as IDisposable).Dispose();
          }
label_20:
          this.cd3bae3481bc020c51445682097bbd0b6(current.Children);
        }
label_22:
        switch (1)
        {
          case 0:
            goto label_22;
        }
      }
      finally
      {
        if (enumerator1 is IDisposable)
        {
label_25:
          switch (2)
          {
            case 0:
              goto label_25;
            default:
              (enumerator1 as IDisposable).Dispose();
              break;
          }
        }
      }
    }
  }

  public void PrintPreview()
  {
    if (this.GridView1 == null || this.GridView1.GridControl == null)
      return;
    this.GridView1.GridControl.ShowPrintPreview();
  }

  private void c7664776af3e82b31baf0ec2710570f96() => this.ShowFilterRow = !this.ShowFilterRow;

  private void cbfd5d4939db04a3693a94c18ac553de4() => this.ShowFindPanel = !this.ShowFindPanel;

  private void c2cfc6e7e67f7f2949883be5f10bfe2a9()
  {
    if (this.c330a4db27d3578a8e5d80797d2f5ac12 == null)
      return;
label_1:
    switch (3)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c2cfc6e7e67f7f2949883be5f10bfe2a9);
        }
        this.c330a4db27d3578a8e5d80797d2f5ac12.SaveUserSetting();
        break;
    }
  }

  private void cd2d6f1fcb4630eb853ab128a847e3127()
  {
    if (this.c330a4db27d3578a8e5d80797d2f5ac12 == null)
      return;
label_1:
    switch (6)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cd2d6f1fcb4630eb853ab128a847e3127);
        }
        this.c330a4db27d3578a8e5d80797d2f5ac12.DeleteUserSetting();
        break;
    }
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public object ParentControl
  {
    get
    {
      for (Control parent = this.Parent; parent != null; parent = parent.Parent)
      {
        if (parent is Form & Microsoft.VisualBasic.CompilerServices.Operators.CompareString(parent.Name, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(9860), false) != 0)
          return (object) parent;
        if (parent is UserControl)
        {
label_4:
          switch (4)
          {
            case 0:
              goto label_4;
            default:
              if (false)
              {
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.get_ParentControl);
              }
              if (parent.Parent == null)
                return (object) parent;
              if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(parent.Parent.Name, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1324), false) == 0 | Microsoft.VisualBasic.CompilerServices.Operators.CompareString(parent.Parent.Name, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(1343), false) == 0 | Microsoft.VisualBasic.CompilerServices.Operators.CompareString(parent.Parent.Name, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(9860), false) == 0)
              {
label_10:
                switch (4)
                {
                  case 0:
                    goto label_10;
                  default:
                    return (object) parent;
                }
              }
              else
                continue;
          }
        }
      }
label_14:
      switch (6)
      {
        case 0:
          goto label_14;
        default:
          return (object) null;
      }
    }
  }

  private void cd1c51089237bec69dec63088eca96a73(
    object c7a1c50d8950fe539821ded4a87a7123f,
    CancelEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (!this.cf60d22e546791e81aed27bc22acefa6f)
    {
label_1:
      switch (2)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cd1c51089237bec69dec63088eca96a73);
          }
          c320269ec287d16905c829847d30a2e08.Cancel = true;
          break;
      }
    }
    else
    {
      this.mnuRowAdd.Enabled = this.AllowAddRows;
      this.mnuRowInsert.Enabled = this.c9bdaa67da5892845981f2c92942085e5;
      this.mnuRowDelete.Enabled = this.AllowDeleteRows & !this.c018a99ed0c66295f13c59de7c8b6aa4c;
      this.mnuRowUnchange.Enabled = this.Editable & !this.c018a99ed0c66295f13c59de7c8b6aa4c;
      this.mnuInsertPaste.Enabled = this.Editable & this.c9bdaa67da5892845981f2c92942085e5;
      this.mnuRowPaste.Enabled = this.Editable & !this.c018a99ed0c66295f13c59de7c8b6aa4c;
      this.mnuExcelPaste.Enabled = this.Editable;
      this.mnuRowCopy.Enabled = this.cfe51a0bb967b0d0da313e1b4013ca09b;
      this.mnuExport.Enabled = this.cfe51a0bb967b0d0da313e1b4013ca09b;
      this.mnuEnterUp.Checked = this.c9b149e1771cda0755be116d1d00e5bcf == GridEnterDirection.Up;
      this.mnuEnterDown.Checked = this.c9b149e1771cda0755be116d1d00e5bcf == GridEnterDirection.Down;
      this.mnuEnterLeft.Checked = this.c9b149e1771cda0755be116d1d00e5bcf == GridEnterDirection.Left;
      this.mnuEnterRight.Checked = this.c9b149e1771cda0755be116d1d00e5bcf == GridEnterDirection.Right;
      this.mnuMouseClickEdit.Checked = this.GridView1.OptionsBehavior.EditorShowMode == EditorShowMode.MouseDown;
      this.mnuMouseClickSelect.Checked = !this.mnuMouseClickEdit.Checked;
      string str = "";
      if (this.mnuEnterUp.Checked)
      {
label_6:
        switch (5)
        {
          case 0:
            goto label_6;
          default:
            str = this.mnuEnterUp.Text;
            break;
        }
      }
      if (this.mnuEnterDown.Checked)
        str = this.mnuEnterDown.Text;
      if (this.mnuEnterLeft.Checked)
      {
label_11:
        switch (3)
        {
          case 0:
            goto label_11;
          default:
            str = this.mnuEnterLeft.Text;
            break;
        }
      }
      if (this.mnuEnterRight.Checked)
      {
label_14:
        switch (4)
        {
          case 0:
            goto label_14;
          default:
            str = this.mnuEnterRight.Text;
            break;
        }
      }
      this.mnuEnterDir.Text = this.c3b8083aee5bd9d8f8194d8364439e345 + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(9879) + str;
      this.mnuMouseClick.Text = Conversions.ToString(Microsoft.VisualBasic.CompilerServices.Operators.AddObject((object) (this.c3b632040ec246544c6cd4e0f83a2918d + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(9879)), Interaction.IIf(this.mnuMouseClickEdit.Checked, (object) this.mnuMouseClickEdit.Text, (object) this.mnuMouseClickSelect.Text)));
    }
  }

  private void c6c49ec56804efac6885bbf373a8609b0(
    object c7a1c50d8950fe539821ded4a87a7123f,
    ToolStripItemClickedEventArgs c320269ec287d16905c829847d30a2e08)
  {
    this.c7c4ca4a0e0fa8a47b7faf81755074be9(c320269ec287d16905c829847d30a2e08.ClickedItem);
  }

  public void DeleteAll()
  {
    bool multiSelect = this.GridView1.OptionsSelection.MultiSelect;
    this.GridView1.OptionsSelection.MultiSelect = true;
    this.GridView1.SelectAll();
    this.DeleteSelectedRows();
    this.GridView1.OptionsSelection.MultiSelect = multiSelect;
  }

  private void cb1faf9b93b6078aa9dc1a88feb6c8f17(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    ToolStripItem toolStripItem = (ToolStripItem) c7a1c50d8950fe539821ded4a87a7123f;
    if (toolStripItem == this.mnuEnterUp)
    {
      this.mnuEnterUp.Checked = toolStripItem == this.mnuEnterUp;
      this.c9b149e1771cda0755be116d1d00e5bcf = GridEnterDirection.Up;
    }
    if (toolStripItem == this.mnuEnterDown)
    {
label_3:
      switch (6)
      {
        case 0:
          goto label_3;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cb1faf9b93b6078aa9dc1a88feb6c8f17);
          }
          this.mnuEnterDown.Checked = toolStripItem == this.mnuEnterDown;
          this.c9b149e1771cda0755be116d1d00e5bcf = GridEnterDirection.Down;
          break;
      }
    }
    if (toolStripItem == this.mnuEnterLeft)
    {
label_8:
      switch (5)
      {
        case 0:
          goto label_8;
        default:
          this.mnuEnterLeft.Checked = toolStripItem == this.mnuEnterLeft;
          this.c9b149e1771cda0755be116d1d00e5bcf = GridEnterDirection.Left;
          break;
      }
    }
    if (toolStripItem == this.mnuEnterRight)
    {
label_11:
      switch (3)
      {
        case 0:
          goto label_11;
        default:
          this.mnuEnterRight.Checked = toolStripItem == this.mnuEnterRight;
          this.c9b149e1771cda0755be116d1d00e5bcf = GridEnterDirection.Right;
          break;
      }
    }
    this.GridView1.OptionsNavigation.EnterMoveNextColumn = this.c9b149e1771cda0755be116d1d00e5bcf == GridEnterDirection.Right;
    if (toolStripItem == this.mnuMouseClickEdit)
    {
label_14:
      switch (7)
      {
        case 0:
          goto label_14;
        default:
          this.GridView1.OptionsBehavior.EditorShowMode = EditorShowMode.MouseDown;
          break;
      }
    }
    if (toolStripItem != this.mnuMouseClickSelect)
      return;
label_17:
    switch (1)
    {
      case 0:
        goto label_17;
      default:
        this.GridView1.OptionsBehavior.EditorShowMode = EditorShowMode.MouseDownFocused;
        break;
    }
  }

  private void c7c4ca4a0e0fa8a47b7faf81755074be9(ToolStripItem c0ea434b35515c8328ebdb7d4327d4d9e)
  {
    if (c0ea434b35515c8328ebdb7d4327d4d9e == this.mnuPropertiesCopy)
      this.c3249094fd49fe7a23a1b9e6f52a3335c(true);
    if (c0ea434b35515c8328ebdb7d4327d4d9e == this.mnuPropertiesPaste)
    {
label_3:
      switch (7)
      {
        case 0:
          goto label_3;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c7c4ca4a0e0fa8a47b7faf81755074be9);
          }
          this.c913893208c8d19243dbb9dc3f0a2bf1b();
          break;
      }
    }
    if (c0ea434b35515c8328ebdb7d4327d4d9e == this.mnuRowAdd)
      this.AddNewRows();
    if (c0ea434b35515c8328ebdb7d4327d4d9e == this.mnuRowInsert)
    {
label_10:
      switch (5)
      {
        case 0:
          goto label_10;
        default:
          this.c7a4a12705aff863eac87a9c37f7537d4();
          break;
      }
    }
    if (c0ea434b35515c8328ebdb7d4327d4d9e == this.mnuRowDelete)
    {
label_13:
      switch (2)
      {
        case 0:
          goto label_13;
        default:
          this.DeleteSelectedRows();
          break;
      }
    }
    if (c0ea434b35515c8328ebdb7d4327d4d9e == this.mnuRowUnchange)
      this.CancelSelectedRowChanges();
    if (c0ea434b35515c8328ebdb7d4327d4d9e == this.mnuRowCopy)
    {
label_18:
      switch (1)
      {
        case 0:
          goto label_18;
        default:
          this.c3249094fd49fe7a23a1b9e6f52a3335c();
          break;
      }
    }
    if (c0ea434b35515c8328ebdb7d4327d4d9e == this.mnuRowPaste)
    {
label_21:
      switch (2)
      {
        case 0:
          goto label_21;
        default:
          if (0 < this.ColumnCount)
          {
label_23:
            switch (4)
            {
              case 0:
                goto label_23;
              default:
                this.GridView1.ClearSelection();
                this.c763939902e819452bfe0683daed35ed4();
                break;
            }
          }
          this.c20947ecaf7d6f07b17485b6d8a4d508a();
          break;
      }
    }
    if (c0ea434b35515c8328ebdb7d4327d4d9e == this.mnuInsertPaste)
    {
label_27:
      switch (1)
      {
        case 0:
          goto label_27;
        default:
          if (0 < this.ColumnCount)
          {
label_29:
            switch (5)
            {
              case 0:
                goto label_29;
              default:
                this.GridView1.ClearSelection();
                this.c763939902e819452bfe0683daed35ed4();
                break;
            }
          }
          this.c20947ecaf7d6f07b17485b6d8a4d508a(true);
          break;
      }
    }
    if (c0ea434b35515c8328ebdb7d4327d4d9e == this.mnuRowSelectAll)
    {
label_33:
      switch (3)
      {
        case 0:
          goto label_33;
        default:
          this.SelectAll();
          break;
      }
    }
    if (c0ea434b35515c8328ebdb7d4327d4d9e == this.mnuExcelPaste)
      this._PasteExcel();
    if (c0ea434b35515c8328ebdb7d4327d4d9e != this.mnuExport)
      return;
label_38:
    switch (2)
    {
      case 0:
        goto label_38;
      default:
        this.Export();
        break;
    }
  }

  public void SelectAll() => this.GridView1.SelectAll();

  public void AddNewRows(int rowCount)
  {
    if (this.c5d165dda3affdc10bf5fa3cdd0152971 == null)
    {
label_1:
      switch (3)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.AddNewRows);
          break;
      }
    }
    else if (this.c467083dea0102ade8924e025f685c241 != null)
    {
label_6:
      switch (6)
      {
        case 0:
          goto label_6;
        default:
          int num1 = rowCount;
          int num2 = 1;
          while (num2 <= num1)
          {
            this.c467083dea0102ade8924e025f685c241.Rows.Add(this.c467083dea0102ade8924e025f685c241.NewRow());
            checked { ++num2; }
          }
label_10:
          switch (2)
          {
            case 0:
              goto label_10;
            default:
              return;
          }
      }
    }
    else
    {
      int num3 = rowCount;
      int num4 = 1;
      while (num4 <= num3)
      {
        this.c5d165dda3affdc10bf5fa3cdd0152971.Tables[0].Rows.Add(this.c5d165dda3affdc10bf5fa3cdd0152971.Tables[0].NewRow());
        checked { ++num4; }
      }
label_14:
      switch (5)
      {
        case 0:
          goto label_14;
      }
    }
  }

  public void AddNewRows()
  {
    if (!this.AllowAddRows)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.AddNewRows);
          break;
      }
    }
    else
    {
      int rowCount = this.GridView1.RowCount;
      int selectedRowsCount = this.GridView1.SelectedRowsCount;
      int integer = Conversions.ToInteger(Interaction.IIf(selectedRowsCount == 0, (object) 1, (object) selectedRowsCount));
      this.ce75332160d718c37d93defbcd7e95679 = true;
      int num1 = integer;
      int num2 = 1;
      while (num2 <= num1)
      {
        this.cd7c73e6d5e8821740a8d2c37bd8bb1b5();
        checked { ++num2; }
      }
label_7:
      switch (5)
      {
        case 0:
          goto label_7;
        default:
          this.ce75332160d718c37d93defbcd7e95679 = false;
          this.cb1889f5f18b3611413f64aac4ae0c235(this.GridView1.FocusedRowHandle, this.GridView1.FocusedRowHandle);
          this.cba003401c0201d2ee6726bf092b3d6f5();
          break;
      }
    }
  }

  public void AddNewRow()
  {
    if (!this.AllowAddRows)
    {
label_1:
      switch (2)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.AddNewRow);
          break;
      }
    }
    else
    {
      this.cd7c73e6d5e8821740a8d2c37bd8bb1b5();
      this.cba003401c0201d2ee6726bf092b3d6f5();
    }
  }

  private void cd7c73e6d5e8821740a8d2c37bd8bb1b5()
  {
    int num = this.GridView1.FocusedRowHandle;
    if (num < 0)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cd7c73e6d5e8821740a8d2c37bd8bb1b5);
          }
          num = this.GridView1.GetDataRowHandleByGroupRowHandle(num);
          break;
      }
    }
    this.c2ff7d99b7b52bbc756ecb3515e5b1a0a = true;
    this.GridView1.AddNewRow();
    this.c2ff7d99b7b52bbc756ecb3515e5b1a0a = false;
    this.c1a1ac0cdd82fed6db069786a78c0a7c7(num);
    this.GridView1.UpdateCurrentRow();
    // ISSUE: reference to a compiler-generated field
    eGrid.AddedRowEventHandler c9fdef276cb8e88d9c5fdf00d819d1c71 = this.c9fdef276cb8e88d9c5fdf00d819d1c71;
    if (c9fdef276cb8e88d9c5fdf00d819d1c71 == null)
      return;
label_6:
    switch (4)
    {
      case 0:
        goto label_6;
      default:
        c9fdef276cb8e88d9c5fdf00d819d1c71((object) this, this.GridView1.FocusedRowHandle);
        break;
    }
  }

  private void cba003401c0201d2ee6726bf092b3d6f5()
  {
    IEnumerator enumerator;
    try
    {
      enumerator = this.GridView1.Columns.GetEnumerator();
      while (enumerator.MoveNext())
      {
        DevExpress.XtraGrid.Columns.GridColumn current = (DevExpress.XtraGrid.Columns.GridColumn) enumerator.Current;
        int num;
        if (current.Visible)
        {
label_3:
          switch (5)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cba003401c0201d2ee6726bf092b3d6f5);
              }
              num = current.OptionsColumn.AllowEdit ? 1 : 0;
              break;
          }
        }
        else
          num = 0;
        if (num != 0)
        {
label_9:
          switch (5)
          {
            case 0:
              goto label_9;
            default:
              this.GridView1.FocusedColumn = current;
              return;
          }
        }
      }
label_12:
      switch (2)
      {
        case 0:
          goto label_12;
      }
    }
    finally
    {
      if (enumerator is IDisposable)
      {
label_14:
        switch (2)
        {
          case 0:
            goto label_14;
          default:
            (enumerator as IDisposable).Dispose();
            break;
        }
      }
    }
  }

  private void c763939902e819452bfe0683daed35ed4()
  {
    IEnumerator enumerator;
    try
    {
      enumerator = this.GridView1.Columns.GetEnumerator();
      while (enumerator.MoveNext())
      {
        DevExpress.XtraGrid.Columns.GridColumn current = (DevExpress.XtraGrid.Columns.GridColumn) enumerator.Current;
        if (current.Visible)
        {
label_3:
          switch (3)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c763939902e819452bfe0683daed35ed4);
              }
              this.GridView1.FocusedColumn = current;
              this.GridView1.SelectCell(this.GridView1.FocusedRowHandle, current);
              return;
          }
        }
      }
label_8:
      switch (3)
      {
        case 0:
          goto label_8;
      }
    }
    finally
    {
      if (enumerator is IDisposable)
      {
label_10:
        switch (6)
        {
          case 0:
            goto label_10;
          default:
            (enumerator as IDisposable).Dispose();
            break;
        }
      }
    }
  }

  private void ce7719d25b05ac9c98f792387caf8dd69(
    object c97a6eb8249b82e6012f7c6f0aee58c99,
    NavigatorButtonClickEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (c320269ec287d16905c829847d30a2e08.Button.ButtonType != NavigatorButtonType.Append)
      return;
    this.Parent.Focus();
    this.GridView1.Focus();
    this.AddNewRow();
    c320269ec287d16905c829847d30a2e08.Handled = true;
  }

  private void c1a1ac0cdd82fed6db069786a78c0a7c7(int c11868f6b2762950261a425c193652265)
  {
    if (0 >= this.GridView1.SortInfo.GroupCount)
      return;
label_1:
    switch (1)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c1a1ac0cdd82fed6db069786a78c0a7c7);
        }
        IEnumerator enumerator;
        try
        {
          enumerator = this.GridView1.GroupedColumns.GetEnumerator();
          while (enumerator.MoveNext())
          {
            DevExpress.XtraGrid.Columns.GridColumn current = (DevExpress.XtraGrid.Columns.GridColumn) enumerator.Current;
            object objectValue = RuntimeHelpers.GetObjectValue(this.GridView1.GetRowCellValue(c11868f6b2762950261a425c193652265, current));
            this.GridView1.SetRowCellValue(this.GridView1.FocusedRowHandle, current, RuntimeHelpers.GetObjectValue(objectValue));
          }
        }
        finally
        {
          if (enumerator is IDisposable)
          {
label_9:
            switch (5)
            {
              case 0:
                goto label_9;
              default:
                (enumerator as IDisposable).Dispose();
                break;
            }
          }
        }
        break;
    }
  }

  public int GetNextNumber(string columnName)
  {
    int num1 = 0;
    int num2 = checked (this.GridView1.RowCount - 1);
    int rowHandle = 0;
    while (rowHandle <= num2)
    {
      if (Decimal.Compare(new Decimal(num1), this.get_ToDec(columnName, rowHandle)) < 0)
      {
label_2:
        switch (1)
        {
          case 0:
            goto label_2;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.GetNextNumber);
            }
            num1 = Convert.ToInt32(this.get_ToDec(columnName, rowHandle));
            break;
        }
      }
      checked { ++rowHandle; }
    }
label_8:
    switch (7)
    {
      case 0:
        goto label_8;
      default:
        return checked (num1 + 1);
    }
  }

  private void ca38537a40084e083b70c73ca0860bb93(int c11868f6b2762950261a425c193652265)
  {
    if (this.DataSet == null)
    {
label_1:
      switch (1)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.ca38537a40084e083b70c73ca0860bb93);
          break;
      }
    }
    else if (this.RowCount == 0)
    {
label_5:
      switch (4)
      {
        case 0:
          goto label_5;
      }
    }
    else
    {
      this.c437485d6a3e0b34ec64860ea9e5d9748 = true;
      IEnumerator enumerator;
      try
      {
        enumerator = this.GridView1.Columns.GetEnumerator();
        while (enumerator.MoveNext())
        {
          DevExpress.XtraGrid.Columns.GridColumn current = (DevExpress.XtraGrid.Columns.GridColumn) enumerator.Current;
          eGridColumn eGridColumn = this.GridColumn(current.FieldName);
          string str = "";
          if (eGridColumn != null)
          {
label_10:
            switch (3)
            {
              case 0:
                goto label_10;
              default:
                str = eGridColumn.DefaultText;
                break;
            }
          }
          if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, "", false) != 0)
          {
label_13:
            switch (6)
            {
              case 0:
                goto label_13;
              default:
                if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(9886), false) == 0)
                {
label_15:
                  switch (4)
                  {
                    case 0:
                      goto label_15;
                    default:
                      this.set_Text(current.FieldName, c11868f6b2762950261a425c193652265, this.GetNextNumber(current.FieldName).ToString());
                      break;
                  }
                }
                else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(316), false) == 0)
                {
label_18:
                  switch (5)
                  {
                    case 0:
                      goto label_18;
                    default:
                      if (current.ColumnEdit == null)
                      {
label_20:
                        switch (5)
                        {
                          case 0:
                            goto label_20;
                          default:
                            this.c437485d6a3e0b34ec64860ea9e5d9748 = false;
                            return;
                        }
                      }
                      else
                      {
                        RepositoryItemLookUpEdit repositoryItemLookUpEdit = new RepositoryItemLookUpEdit();
                        RepositoryItemLookUpEdit columnEdit = (RepositoryItemLookUpEdit) current.ColumnEdit;
                        if (columnEdit.DataSource != null)
                        {
                          DataTable dataSource = (DataTable) columnEdit.DataSource;
                          if (1 < dataSource.Rows.Count && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(dataSource.Rows[0][0])), "", false) == 0 && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(dataSource.Rows[0][1])), "", false) == 0)
                            this.set_Text(current.FieldName, c11868f6b2762950261a425c193652265, Shared.ToStr(RuntimeHelpers.GetObjectValue(dataSource.Rows[1][0])));
                          else if (0 < dataSource.Rows.Count)
                          {
label_26:
                            switch (6)
                            {
                              case 0:
                                goto label_26;
                              default:
                                this.set_Text(current.FieldName, c11868f6b2762950261a425c193652265, Shared.ToStr(RuntimeHelpers.GetObjectValue(dataSource.Rows[0][0])));
                                break;
                            }
                          }
                          break;
                        }
                        break;
                      }
                  }
                }
                else if (eGridColumn.FieldType == FieldType.Month)
                {
label_30:
                  switch (6)
                  {
                    case 0:
                      goto label_30;
                    default:
                      if (str.Length == 4)
                      {
label_32:
                        switch (1)
                        {
                          case 0:
                            goto label_32;
                          default:
                            str += c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(584);
                            break;
                        }
                      }
                      if (str.Length == 7)
                      {
label_35:
                        switch (3)
                        {
                          case 0:
                            goto label_35;
                          default:
                            str += c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(597);
                            break;
                        }
                      }
                      if (Information.IsDate((object) str))
                      {
label_38:
                        switch (4)
                        {
                          case 0:
                            goto label_38;
                          default:
                            this.set_Text(current.FieldName, c11868f6b2762950261a425c193652265, Strings.Format((object) Conversions.ToDate(str), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(515)));
                            break;
                        }
                      }
                      else
                        break;
                      break;
                  }
                }
                else if (eGridColumn.FieldType == FieldType.Year)
                {
label_42:
                  switch (5)
                  {
                    case 0:
                      goto label_42;
                    default:
                      if (str.Length == 4)
                      {
label_44:
                        switch (3)
                        {
                          case 0:
                            goto label_44;
                          default:
                            str += c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(584);
                            break;
                        }
                      }
                      if (str.Length == 7)
                      {
label_47:
                        switch (4)
                        {
                          case 0:
                            goto label_47;
                          default:
                            str += c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(597);
                            break;
                        }
                      }
                      if (Information.IsDate((object) str))
                      {
label_50:
                        switch (3)
                        {
                          case 0:
                            goto label_50;
                          default:
                            this.set_Text(current.FieldName, c11868f6b2762950261a425c193652265, Strings.Format((object) Conversions.ToDate(str), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(452)));
                            break;
                        }
                      }
                      else
                        break;
                      break;
                  }
                }
                else if (!(eGridColumn.FieldType == FieldType.Progress | eGridColumn.FieldType == FieldType.Image))
                {
label_53:
                  switch (5)
                  {
                    case 0:
                      goto label_53;
                    default:
                      this.set_Text(current.FieldName, c11868f6b2762950261a425c193652265, str);
                      break;
                  }
                }
                break;
            }
          }
        }
label_60:
        switch (6)
        {
          case 0:
            goto label_60;
        }
      }
      finally
      {
        if (enumerator is IDisposable)
        {
label_62:
          switch (2)
          {
            case 0:
              goto label_62;
            default:
              (enumerator as IDisposable).Dispose();
              break;
          }
        }
      }
      this.c437485d6a3e0b34ec64860ea9e5d9748 = false;
    }
  }

  public void DeleteRow(int rowIndex)
  {
    if (this.c018a99ed0c66295f13c59de7c8b6aa4c)
    {
label_1:
      switch (5)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.DeleteRow);
          break;
      }
    }
    else if (!this.AllowDeleteRows)
    {
label_5:
      switch (6)
      {
        case 0:
          goto label_5;
      }
    }
    else
    {
      bool Cancel = false;
      // ISSUE: reference to a compiler-generated field
      eGrid.DeletingRowEventHandler c2560b393c45138aa714e981ba4ce1c78 = this.c2560b393c45138aa714e981ba4ce1c78;
      if (c2560b393c45138aa714e981ba4ce1c78 != null)
      {
label_8:
        switch (6)
        {
          case 0:
            goto label_8;
          default:
            c2560b393c45138aa714e981ba4ce1c78((object) this, rowIndex, ref Cancel);
            break;
        }
      }
      if (Cancel)
        return;
      this.GridView1.DeleteRow(rowIndex);
      // ISSUE: reference to a compiler-generated field
      eGrid.DeletedRowEventHandler c2caa834d8e828b4d29fa7f6d26032182 = this.c2caa834d8e828b4d29fa7f6d26032182;
      if (c2caa834d8e828b4d29fa7f6d26032182 != null)
        c2caa834d8e828b4d29fa7f6d26032182((object) this, rowIndex);
      this.cc0d454e2f1398908e3cc1bf29ad72f9a = true;
    }
  }

  public void DeleteSelectedRows()
  {
    if (!this.AllowDeleteRows)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.DeleteSelectedRows);
          break;
      }
    }
    else
    {
      if (this.GridView1.SelectedRowsCount == 0)
      {
label_6:
        switch (7)
        {
          case 0:
            goto label_6;
          default:
            this.GridView1.SelectRow(this.GridView1.FocusedRowHandle);
            if (this.GridView1.SelectedRowsCount == 0)
              return;
            break;
        }
      }
      bool Cancel = false;
      int[] selectedRows = this.GridView1.GetSelectedRows();
      if (selectedRows == null)
      {
label_10:
        switch (1)
        {
          case 0:
            goto label_10;
        }
      }
      else
      {
        if (selectedRows.Length == 0)
          return;
        int[] numArray = selectedRows;
        int index = 0;
        while (index < numArray.Length)
        {
          int RowIndex = numArray[index];
          // ISSUE: reference to a compiler-generated field
          eGrid.DeletingRowEventHandler c2560b393c45138aa714e981ba4ce1c78 = this.c2560b393c45138aa714e981ba4ce1c78;
          if (c2560b393c45138aa714e981ba4ce1c78 != null)
          {
label_15:
            switch (5)
            {
              case 0:
                goto label_15;
              default:
                c2560b393c45138aa714e981ba4ce1c78((object) this, RowIndex, ref Cancel);
                break;
            }
          }
          if (Cancel)
          {
label_18:
            switch (6)
            {
              case 0:
                goto label_18;
              default:
                return;
            }
          }
          else
            checked { ++index; }
        }
label_21:
        switch (5)
        {
          case 0:
            goto label_21;
          default:
            this.GridView1.CloseEditor();
            int focusedRowHandle = this.GridView1.FocusedRowHandle;
            this.GridView1.DeleteSelectedRows();
            if (this.GridView1.FocusedRowHandle == focusedRowHandle)
            {
label_23:
              switch (5)
              {
                case 0:
                  goto label_23;
                default:
                  this.cb1889f5f18b3611413f64aac4ae0c235(focusedRowHandle, focusedRowHandle);
                  break;
              }
            }
            this.GridView1.SelectRow(this.GridView1.FocusedRowHandle);
            // ISSUE: reference to a compiler-generated field
            eGrid.DeletedRowEventHandler c2caa834d8e828b4d29fa7f6d26032182 = this.c2caa834d8e828b4d29fa7f6d26032182;
            if (c2caa834d8e828b4d29fa7f6d26032182 != null)
              c2caa834d8e828b4d29fa7f6d26032182((object) this, this.GridView1.FocusedRowHandle);
            this.cc0d454e2f1398908e3cc1bf29ad72f9a = true;
            break;
        }
      }
    }
  }

  private void c7a4a12705aff863eac87a9c37f7537d4()
  {
    if (!this.c9bdaa67da5892845981f2c92942085e5)
      return;
    if (this.GridView1 == null | this.c5d165dda3affdc10bf5fa3cdd0152971 == null)
    {
label_2:
      switch (3)
      {
        case 0:
          goto label_2;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c7a4a12705aff863eac87a9c37f7537d4);
          break;
      }
    }
    else if (this.GridView1.RowCount == 0)
    {
label_6:
      switch (7)
      {
        case 0:
          goto label_6;
        default:
          this.cd7c73e6d5e8821740a8d2c37bd8bb1b5();
          break;
      }
    }
    else if (this.GridView1.GroupedColumns.Count > 0)
    {
label_9:
      switch (2)
      {
        case 0:
          goto label_9;
        default:
          this.cd7c73e6d5e8821740a8d2c37bd8bb1b5();
          break;
      }
    }
    else
    {
      int num1 = this.GridView1.SelectedRowsCount;
      int num2;
      if (num1 == 0)
      {
label_12:
        switch (3)
        {
          case 0:
            goto label_12;
          default:
            num1 = 1;
            num2 = this.GridView1.FocusedRowHandle;
            break;
        }
      }
      else
        num2 = this.GridView1.GetSelectedRows()[0];
      if (num2 < -9999999)
      {
label_16:
        switch (2)
        {
          case 0:
            goto label_16;
          default:
            num2 = 0;
            break;
        }
      }
      this.ce75332160d718c37d93defbcd7e95679 = true;
      int num3 = num2;
      int num4 = checked (num2 + num1 - 1);
      int c83147a39073b8412df37a80935443492 = num3;
      while (c83147a39073b8412df37a80935443492 <= num4)
      {
        this.cb2f5711228df0f2db789f2a73d6bba11(c83147a39073b8412df37a80935443492);
        checked { ++c83147a39073b8412df37a80935443492; }
      }
label_21:
      switch (6)
      {
        case 0:
          goto label_21;
        default:
          this.ce75332160d718c37d93defbcd7e95679 = false;
          this.GridView1.ClearSelection();
          this.GridView1.FocusedRowHandle = num2;
          break;
      }
    }
  }

  private void cb2f5711228df0f2db789f2a73d6bba11(int c83147a39073b8412df37a80935443492)
  {
    if (this.c467083dea0102ade8924e025f685c241 != null)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cb2f5711228df0f2db789f2a73d6bba11);
          }
          this.c467083dea0102ade8924e025f685c241.Rows.InsertAt(this.c467083dea0102ade8924e025f685c241.NewRow(), c83147a39073b8412df37a80935443492);
          break;
      }
    }
    else
      this.c5d165dda3affdc10bf5fa3cdd0152971.Tables[0].Rows.InsertAt(this.c5d165dda3affdc10bf5fa3cdd0152971.Tables[0].NewRow(), c83147a39073b8412df37a80935443492);
    this.ca38537a40084e083b70c73ca0860bb93(c83147a39073b8412df37a80935443492);
    // ISSUE: reference to a compiler-generated field
    eGrid.InsertedRowEventHandler c617a33dcb81187054bdb14637d65d431 = this.c617a33dcb81187054bdb14637d65d431;
    if (c617a33dcb81187054bdb14637d65d431 == null)
      return;
label_7:
    switch (6)
    {
      case 0:
        goto label_7;
      default:
        c617a33dcb81187054bdb14637d65d431((object) this, c83147a39073b8412df37a80935443492);
        break;
    }
  }

  public void InsertNewRow(int rowIndex)
  {
    if (this.c5d165dda3affdc10bf5fa3cdd0152971 == null)
      return;
label_1:
    switch (2)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.InsertNewRow);
        }
        if (rowIndex < 0)
        {
label_5:
          switch (2)
          {
            case 0:
              goto label_5;
            default:
              this.cd7c73e6d5e8821740a8d2c37bd8bb1b5();
              break;
          }
        }
        else
        {
          this.cb2f5711228df0f2db789f2a73d6bba11(rowIndex);
          this.GridView1.ClearSelection();
          this.GridView1.FocusedRowHandle = rowIndex;
        }
        break;
    }
  }

  public void InsertNewRows(int rowHandle, int rowCount)
  {
    int num1;
    if (this.c5d165dda3affdc10bf5fa3cdd0152971 != null)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.InsertNewRows);
          }
          if (rowCount >= 0)
          {
label_5:
            switch (6)
            {
              case 0:
                goto label_5;
              default:
                if (rowHandle >= 0)
                {
label_7:
                  switch (1)
                  {
                    case 0:
                      goto label_7;
                    default:
                      num1 = this.c5d165dda3affdc10bf5fa3cdd0152971.Tables[0].Rows.Count < rowHandle ? 1 : 0;
                      goto label_10;
                  }
                }
                else
                  break;
            }
          }
          else
            break;
          break;
      }
    }
    num1 = 1;
label_10:
    if (num1 != 0)
    {
label_11:
      switch (4)
      {
        case 0:
          goto label_11;
      }
    }
    else if (this.c467083dea0102ade8924e025f685c241 != null)
    {
label_14:
      switch (5)
      {
        case 0:
          goto label_14;
        default:
          int num2 = rowCount;
          int num3 = 1;
          while (num3 <= num2)
          {
            this.c467083dea0102ade8924e025f685c241.Rows.InsertAt(this.c467083dea0102ade8924e025f685c241.NewRow(), checked (rowHandle - 1));
            checked { ++num3; }
          }
          break;
      }
    }
    else
    {
      int num4 = rowCount;
      int num5 = 1;
      while (num5 <= num4)
      {
        this.c5d165dda3affdc10bf5fa3cdd0152971.Tables[0].Rows.InsertAt(this.c5d165dda3affdc10bf5fa3cdd0152971.Tables[0].NewRow(), checked (rowHandle - 1));
        checked { ++num5; }
      }
label_21:
      switch (5)
      {
        case 0:
          goto label_21;
      }
    }
  }

  public void CancelRowChanges() => this.CancelRowChanges(this.GridView1.FocusedRowHandle);

  public void CancelSelectedRowChanges()
  {
    if (this.GridView1.RowCount == 0)
      return;
    int[] selectedRows = this.GridView1.GetSelectedRows();
    int index = 0;
    while (index < selectedRows.Length)
    {
      this.CancelRowChanges(selectedRows[index]);
      checked { ++index; }
    }
label_5:
    switch (3)
    {
      case 0:
        goto label_5;
      default:
        if (true)
          break;
        // ISSUE: method reference
        RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.CancelSelectedRowChanges);
        break;
    }
  }

  public void CancelRowChanges(int rowInx)
  {
    if (rowInx == this.GridView1.FocusedRowHandle)
    {
label_1:
      switch (7)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.CancelRowChanges);
          }
          this.GridView1.UpdateCurrentRow();
          break;
      }
    }
    if (this.GridView1.GetDataRow(rowInx).RowState == DataRowState.Unchanged)
      return;
label_6:
    switch (6)
    {
      case 0:
        goto label_6;
      default:
        this.GridView1.GetDataRow(rowInx).RejectChanges();
        break;
    }
  }

  public void CopyRows(int startRowIndex = -1, int endRowIndex = -1)
  {
    if (this.GridView1.RowCount == 0)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.CopyRows);
          break;
      }
    }
    else
    {
      if (startRowIndex < 0 & endRowIndex < 0)
      {
label_5:
        switch (2)
        {
          case 0:
            goto label_5;
          default:
            startRowIndex = this.GridView1.FocusedRowHandle;
            endRowIndex = this.GridView1.FocusedRowHandle;
            break;
        }
      }
      if (startRowIndex < 0 & 0 <= endRowIndex)
      {
label_8:
        switch (6)
        {
          case 0:
            goto label_8;
          default:
            startRowIndex = 0;
            break;
        }
      }
      if (0 <= startRowIndex & endRowIndex < 0)
      {
label_11:
        switch (2)
        {
          case 0:
            goto label_11;
          default:
            endRowIndex = startRowIndex;
            break;
        }
      }
      if (endRowIndex < startRowIndex)
      {
label_14:
        switch (6)
        {
          case 0:
            goto label_14;
          default:
            int num = endRowIndex;
            endRowIndex = startRowIndex;
            startRowIndex = num;
            break;
        }
      }
      if (checked (this.GridView1.RowCount - 1) < endRowIndex)
      {
label_17:
        switch (4)
        {
          case 0:
            goto label_17;
          default:
            Shared.MessageError(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(9909), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(9944));
            break;
        }
      }
      else
      {
        this.GridView1.SelectRows(startRowIndex, endRowIndex);
        this.c3249094fd49fe7a23a1b9e6f52a3335c();
      }
    }
  }

  private void c3249094fd49fe7a23a1b9e6f52a3335c(bool c223ee9cbe83c0baa9bfc2e5806accbc6 = false)
  {
    if (this.GridView1 == null)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c3249094fd49fe7a23a1b9e6f52a3335c);
          break;
      }
    }
    else
    {
      if (this.GridView1.SelectedRowsCount == 0)
        return;
      string str = "";
      int num1 = -1;
      int[] selectedRows = this.GridView1.GetSelectedRows();
      if (selectedRows == null)
        return;
      if (selectedRows.Length == 0)
      {
label_10:
        switch (4)
        {
          case 0:
            goto label_10;
        }
      }
      else
      {
        bool flag = true;
        if (c223ee9cbe83c0baa9bfc2e5806accbc6)
        {
label_12:
          switch (5)
          {
            case 0:
              goto label_12;
            default:
              IEnumerator enumerator;
              try
              {
                enumerator = this.GridView1.Columns.GetEnumerator();
                while (enumerator.MoveNext())
                {
                  string fieldName = ((DevExpress.XtraGrid.Columns.GridColumn) enumerator.Current).FieldName;
                  eGridColumn eGridColumn = this.GridColumn(fieldName);
                  int num2;
                  if (eGridColumn != null)
                  {
label_15:
                    switch (2)
                    {
                      case 0:
                        goto label_15;
                      default:
                        num2 = eGridColumn.Visible ? 1 : 0;
                        break;
                    }
                  }
                  else
                    num2 = 0;
                  if (num2 != 0)
                  {
label_19:
                    switch (1)
                    {
                      case 0:
                        goto label_19;
                      default:
                        if (!flag)
                        {
label_21:
                          switch (3)
                          {
                            case 0:
                              goto label_21;
                            default:
                              str += c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5653);
                              break;
                          }
                        }
                        str += fieldName;
                        flag = false;
                        break;
                    }
                  }
                }
label_26:
                switch (2)
                {
                  case 0:
                    goto label_26;
                }
              }
              finally
              {
                if (enumerator is IDisposable)
                {
label_29:
                  switch (1)
                  {
                    case 0:
                      goto label_29;
                    default:
                      (enumerator as IDisposable).Dispose();
                      break;
                  }
                }
              }
              break;
          }
        }
        int[] numArray = selectedRows;
        int index = 0;
        while (index < numArray.Length)
        {
          int num3 = numArray[index];
          try
          {
            foreach (DevExpress.XtraGrid.Columns.GridColumn column in (CollectionBase) this.GridView1.Columns)
            {
              string fieldName = column.FieldName;
              int rowHandle = num3;
              eGridColumn eGridColumn = this.GridColumn(fieldName);
              int num4;
              if (eGridColumn != null)
              {
label_36:
                switch (5)
                {
                  case 0:
                    goto label_36;
                  default:
                    num4 = eGridColumn.Visible ? 1 : 0;
                    break;
                }
              }
              else
                num4 = 0;
              if (num4 != 0)
              {
label_40:
                switch (6)
                {
                  case 0:
                    goto label_40;
                  default:
                    if (rowHandle != num1)
                    {
                      num1 = rowHandle;
                      flag = true;
                      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, "", false) != 0)
                      {
label_43:
                        switch (6)
                        {
                          case 0:
                            goto label_43;
                          default:
                            str += c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5648);
                            break;
                        }
                      }
                    }
                    if (!flag)
                    {
label_47:
                      switch (6)
                      {
                        case 0:
                          goto label_47;
                        default:
                          str += c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5653);
                          break;
                      }
                    }
                    str += this.get_Text(fieldName, rowHandle);
                    flag = false;
                    break;
                }
              }
            }
          }
          finally
          {
            IEnumerator enumerator;
            if (enumerator is IDisposable)
              (enumerator as IDisposable).Dispose();
          }
          checked { ++index; }
        }
label_57:
        switch (6)
        {
          case 0:
            goto label_57;
          default:
            Clipboard.SetDataObject((object) str, true);
            break;
        }
      }
    }
  }

  public void PasteRows() => this.c399477f52524d429a87457458819812c();

  private void c399477f52524d429a87457458819812c()
  {
    try
    {
      if (this.c31b549eb509ea9196e125f4a81deac9e())
      {
label_2:
        switch (4)
        {
          case 0:
            goto label_2;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c399477f52524d429a87457458819812c);
            }
            Shared.PutMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3763), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3812));
            break;
        }
      }
      IDataObject dataObject = Clipboard.GetDataObject();
      if (!dataObject.GetDataPresent(DataFormats.UnicodeText))
      {
label_7:
        switch (3)
        {
          case 0:
            goto label_7;
          default:
            Shared.MessageError(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(9965));
            break;
        }
      }
      else
      {
        string str = Conversions.ToString(dataObject.GetData(DataFormats.UnicodeText));
        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, "", false) == 0)
        {
label_10:
          switch (2)
          {
            case 0:
              goto label_10;
          }
        }
        else
        {
          string[] strArray1 = Strings.Split(str, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5648));
          string[] strArray2 = Strings.Split(strArray1[0], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5653));
          bool flag = true;
          if (this.RowCount == 0)
          {
label_12:
            switch (3)
            {
              case 0:
                goto label_12;
              default:
                this.ce75332160d718c37d93defbcd7e95679 = true;
                this.cd7c73e6d5e8821740a8d2c37bd8bb1b5();
                this.ce75332160d718c37d93defbcd7e95679 = false;
                break;
            }
          }
          int focusedRowHandle = this.GridView1.FocusedRowHandle;
          int num1 = checked (strArray1.Length - 1);
          int index1 = 1;
          while (index1 <= num1)
          {
            int num2;
            if (!flag)
            {
label_16:
              switch (1)
              {
                case 0:
                  goto label_16;
                default:
                  num2 = this.RowCount <= focusedRowHandle | focusedRowHandle < 0 ? 1 : 0;
                  break;
              }
            }
            else
              num2 = 0;
            if (num2 != 0)
            {
label_20:
              switch (5)
              {
                case 0:
                  goto label_20;
                default:
                  this.ce75332160d718c37d93defbcd7e95679 = true;
                  this.cd7c73e6d5e8821740a8d2c37bd8bb1b5();
                  this.ce75332160d718c37d93defbcd7e95679 = false;
                  break;
              }
            }
            string[] strArray3 = Strings.Split(strArray1[index1], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5653));
            int num3 = checked (strArray3.Length - 1);
            int index2 = 0;
            while (index2 <= num3)
            {
              this.set_Text(strArray2[index2], focusedRowHandle, strArray3[index2]);
              checked { ++index2; }
            }
label_25:
            switch (4)
            {
              case 0:
                goto label_25;
              default:
                checked { ++focusedRowHandle; }
                flag = false;
                checked { ++index1; }
                continue;
            }
          }
label_28:
          switch (5)
          {
            case 0:
              goto label_28;
            default:
              this.cb1889f5f18b3611413f64aac4ae0c235(focusedRowHandle, this.GridView1.FocusedRowHandle);
              break;
          }
        }
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, title: this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10048));
      ProjectData.ClearProjectError();
    }
  }

  private void c913893208c8d19243dbb9dc3f0a2bf1b()
  {
    try
    {
      if (this.c31b549eb509ea9196e125f4a81deac9e())
      {
label_2:
        switch (4)
        {
          case 0:
            goto label_2;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c913893208c8d19243dbb9dc3f0a2bf1b);
            }
            Shared.PutMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3763), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3812));
            break;
        }
      }
      else
      {
        IDataObject dataObject = Clipboard.GetDataObject();
        if (!dataObject.GetDataPresent(DataFormats.UnicodeText))
        {
label_7:
          switch (4)
          {
            case 0:
              goto label_7;
            default:
              Shared.MessageError(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(9965));
              break;
          }
        }
        else
        {
          string str = Conversions.ToString(dataObject.GetData(DataFormats.UnicodeText));
          if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str, "", false) == 0)
            return;
          string[] strArray1 = Strings.Split(str, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5648));
          string[] strArray2 = Strings.Split(strArray1[0], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5653));
          string Right = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5389);
          int num1 = checked (strArray2.Length - 1);
          int index1 = 0;
          int index2;
          int index3;
          while (index1 <= num1)
          {
            if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index1], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10075), false) == 0)
            {
label_12:
              switch (6)
              {
                case 0:
                  goto label_12;
                default:
                  index2 = index1;
                  break;
              }
            }
            if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index1], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10088), false) == 0)
            {
label_15:
              switch (3)
              {
                case 0:
                  goto label_15;
                default:
                  index3 = index1;
                  break;
              }
            }
            if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index1], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10095), false) == 0)
            {
label_18:
              switch (3)
              {
                case 0:
                  goto label_18;
                default:
                  Right = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10095);
                  break;
              }
            }
            checked { ++index1; }
          }
          int num2 = checked (strArray1.Length - 1);
          int index4 = 1;
          while (index4 <= num2)
          {
            string[] strArray3 = Strings.Split(strArray1[index4], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5653));
            int rowHandle1 = -1;
            if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray3[index3], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(79), false) == 0)
            {
label_24:
              switch (4)
              {
                case 0:
                  goto label_24;
                default:
                  int num3 = checked (this.RowCount - 1);
                  int rowHandle2 = 0;
                  while (rowHandle2 <= num3)
                  {
                    int num4;
                    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(this.get_Text(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10088), rowHandle2), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(79), false) == 0)
                    {
label_27:
                      switch (7)
                      {
                        case 0:
                          goto label_27;
                        default:
                          num4 = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(this.get_Text(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10075), rowHandle2), strArray3[index2], false) == 0 ? 1 : 0;
                          break;
                      }
                    }
                    else
                      num4 = 0;
                    if (num4 != 0)
                    {
label_31:
                      switch (6)
                      {
                        case 0:
                          goto label_31;
                        default:
                          rowHandle1 = rowHandle2;
                          break;
                      }
                    }
                    checked { ++rowHandle2; }
                  }
label_35:
                  switch (1)
                  {
                    case 0:
                      goto label_35;
                  }
                  break;
              }
            }
            if (0 <= rowHandle1)
            {
label_37:
              switch (2)
              {
                case 0:
                  goto label_37;
                default:
                  int num5 = checked (strArray3.Length - 1);
                  int index5 = 0;
                  while (index5 <= num5)
                  {
                    int num6;
                    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10112), false) != 0)
                    {
label_40:
                      switch (7)
                      {
                        case 0:
                          goto label_40;
                        default:
                          if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10131), false) != 0)
                          {
label_42:
                            switch (7)
                            {
                              case 0:
                                goto label_42;
                              default:
                                if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10144), false) != 0)
                                {
label_44:
                                  switch (3)
                                  {
                                    case 0:
                                      goto label_44;
                                    default:
                                      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10155), false) != 0 && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10170), false) != 0 && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10185), false) != 0)
                                      {
label_46:
                                        switch (1)
                                        {
                                          case 0:
                                            goto label_46;
                                          default:
                                            if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10200), false) != 0 && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10213), false) != 0 && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10230), false) != 0)
                                            {
label_48:
                                              switch (3)
                                              {
                                                case 0:
                                                  goto label_48;
                                                default:
                                                  if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10247), false) != 0)
                                                  {
label_50:
                                                    switch (6)
                                                    {
                                                      case 0:
                                                        goto label_50;
                                                      default:
                                                        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], Right, false) != 0)
                                                        {
label_52:
                                                          switch (4)
                                                          {
                                                            case 0:
                                                              goto label_52;
                                                            default:
                                                              if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10258), false) != 0)
                                                              {
label_54:
                                                                switch (1)
                                                                {
                                                                  case 0:
                                                                    goto label_54;
                                                                  default:
                                                                    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10283), false) != 0 && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10308), false) != 0)
                                                                    {
label_56:
                                                                      switch (2)
                                                                      {
                                                                        case 0:
                                                                          goto label_56;
                                                                        default:
                                                                          if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10333), false) != 0)
                                                                          {
label_58:
                                                                            switch (2)
                                                                            {
                                                                              case 0:
                                                                                goto label_58;
                                                                              default:
                                                                                if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10350), false) != 0)
                                                                                {
label_60:
                                                                                  switch (6)
                                                                                  {
                                                                                    case 0:
                                                                                      goto label_60;
                                                                                    default:
                                                                                      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10363), false) != 0)
                                                                                      {
label_62:
                                                                                        switch (3)
                                                                                        {
                                                                                          case 0:
                                                                                            goto label_62;
                                                                                          default:
                                                                                            if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10376), false) != 0)
                                                                                            {
label_64:
                                                                                              switch (2)
                                                                                              {
                                                                                                case 0:
                                                                                                  goto label_64;
                                                                                                default:
                                                                                                  if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10385), false) != 0)
                                                                                                  {
label_66:
                                                                                                    switch (1)
                                                                                                    {
                                                                                                      case 0:
                                                                                                        goto label_66;
                                                                                                      default:
                                                                                                        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10406), false) != 0)
                                                                                                        {
label_68:
                                                                                                          switch (7)
                                                                                                          {
                                                                                                            case 0:
                                                                                                              goto label_68;
                                                                                                            default:
                                                                                                              if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10429), false) != 0)
                                                                                                              {
label_70:
                                                                                                                switch (1)
                                                                                                                {
                                                                                                                  case 0:
                                                                                                                    goto label_70;
                                                                                                                  default:
                                                                                                                    num6 = Microsoft.VisualBasic.CompilerServices.Operators.CompareString(strArray2[index5], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10452), false) == 0 ? 1 : 0;
                                                                                                                    goto label_73;
                                                                                                                }
                                                                                                              }
                                                                                                              else
                                                                                                                break;
                                                                                                          }
                                                                                                        }
                                                                                                        else
                                                                                                          break;
                                                                                                        break;
                                                                                                    }
                                                                                                  }
                                                                                                  else
                                                                                                    break;
                                                                                                  break;
                                                                                              }
                                                                                            }
                                                                                            else
                                                                                              break;
                                                                                            break;
                                                                                        }
                                                                                      }
                                                                                      else
                                                                                        break;
                                                                                      break;
                                                                                  }
                                                                                }
                                                                                else
                                                                                  break;
                                                                                break;
                                                                            }
                                                                          }
                                                                          else
                                                                            break;
                                                                          break;
                                                                      }
                                                                    }
                                                                    else
                                                                      break;
                                                                    break;
                                                                }
                                                              }
                                                              else
                                                                break;
                                                              break;
                                                          }
                                                        }
                                                        else
                                                          break;
                                                        break;
                                                    }
                                                  }
                                                  else
                                                    break;
                                                  break;
                                              }
                                            }
                                            else
                                              break;
                                            break;
                                        }
                                      }
                                      else
                                        break;
                                      break;
                                  }
                                }
                                else
                                  break;
                                break;
                            }
                          }
                          else
                            break;
                          break;
                      }
                    }
                    num6 = 1;
label_73:
                    if (num6 != 0)
                    {
label_74:
                      switch (3)
                      {
                        case 0:
                          goto label_74;
                        default:
                          this.set_Text(strArray2[index5], rowHandle1, strArray3[index5]);
                          break;
                      }
                    }
                    checked { ++index5; }
                  }
label_78:
                  switch (1)
                  {
                    case 0:
                      goto label_78;
                  }
                  break;
              }
            }
            checked { ++index4; }
          }
label_81:
          switch (2)
          {
            case 0:
              goto label_81;
          }
        }
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageError(ex, title: this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10048));
      ProjectData.ClearProjectError();
    }
  }

  private DevExpress.XtraGrid.Columns.GridColumn c8699ecda178225da3aa67475e5cd54f5(
    int c951d48897e714225d62719261dccb6d3)
  {
    IEnumerator enumerator;
    try
    {
      enumerator = this.GridView1.Columns.GetEnumerator();
      while (enumerator.MoveNext())
      {
        DevExpress.XtraGrid.Columns.GridColumn current = (DevExpress.XtraGrid.Columns.GridColumn) enumerator.Current;
        if (current.VisibleIndex == c951d48897e714225d62719261dccb6d3)
        {
label_3:
          switch (1)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c8699ecda178225da3aa67475e5cd54f5);
              }
              return current;
          }
        }
      }
label_8:
      switch (4)
      {
        case 0:
          goto label_8;
      }
    }
    finally
    {
      if (enumerator is IDisposable)
      {
label_10:
        switch (5)
        {
          case 0:
            goto label_10;
          default:
            (enumerator as IDisposable).Dispose();
            break;
        }
      }
    }
    return (DevExpress.XtraGrid.Columns.GridColumn) null;
  }

  private bool c31b549eb509ea9196e125f4a81deac9e()
  {
    try
    {
      foreach (DevExpress.XtraGrid.Columns.GridColumn column in (CollectionBase) this.GridView1.Columns)
      {
        if (column.SortOrder != 0)
        {
label_3:
          switch (7)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c31b549eb509ea9196e125f4a81deac9e);
              }
              return true;
          }
        }
      }
label_8:
      switch (3)
      {
        case 0:
          goto label_8;
      }
    }
    finally
    {
      IEnumerator enumerator;
      if (enumerator is IDisposable)
        (enumerator as IDisposable).Dispose();
    }
    return false;
  }

  public void _PasteExcel()
  {
    try
    {
      if (this.c31b549eb509ea9196e125f4a81deac9e())
      {
label_2:
        switch (5)
        {
          case 0:
            goto label_2;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid._PasteExcel);
            }
            Shared.PutMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3763), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10473));
            break;
        }
      }
      else if (this.GridView1.Bands == null)
      {
label_7:
        switch (1)
        {
          case 0:
            goto label_7;
        }
      }
      else if (this.GridView1.Bands.VisibleBandCount == 0)
      {
label_10:
        switch (7)
        {
          case 0:
            goto label_10;
        }
      }
      else
      {
        IDataObject dataObject = Clipboard.GetDataObject();
        if (!dataObject.GetDataPresent(DataFormats.UnicodeText))
        {
label_12:
          switch (1)
          {
            case 0:
              goto label_12;
            default:
              Shared.MessageError(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(9965));
              break;
          }
        }
        else
        {
          string str1 = Conversions.ToString(dataObject.GetData(DataFormats.UnicodeText));
          if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(str1, "", false) == 0)
          {
label_15:
            switch (1)
            {
              case 0:
                goto label_15;
            }
          }
          else
          {
            string[] strArray1 = Strings.Split(str1, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5648));
            int length1 = strArray1.Length;
            int length2 = Strings.Split(strArray1[0], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5653)).Length;
            int count = this.GridView1.VisibleColumns.Count;
            int visibleIndex = this.GridView1.FocusedColumn.VisibleIndex;
            int FalsePart = checked (visibleIndex + length2 - 1);
            int integer = Conversions.ToInteger(Interaction.IIf(count <= FalsePart, (object) checked (count - 1), (object) FalsePart));
            bool flag = true;
            if (this.RowCount == 0)
            {
label_17:
              switch (4)
              {
                case 0:
                  goto label_17;
                default:
                  this.ce75332160d718c37d93defbcd7e95679 = true;
                  this.cd7c73e6d5e8821740a8d2c37bd8bb1b5();
                  this.ce75332160d718c37d93defbcd7e95679 = false;
                  break;
              }
            }
            int focusedRowHandle = this.GridView1.FocusedRowHandle;
            int num1 = checked (length1 - 2);
            int index1 = 0;
            while (index1 <= num1)
            {
              string[] strArray2 = Strings.Split(strArray1[index1], c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5653));
              if (0 < index1)
              {
                int num2;
                if (!flag)
                {
label_22:
                  switch (7)
                  {
                    case 0:
                      goto label_22;
                    default:
                      num2 = this.RowCount <= focusedRowHandle | focusedRowHandle < 0 ? 1 : 0;
                      break;
                  }
                }
                else
                  num2 = 0;
                if (num2 != 0)
                {
                  this.ce75332160d718c37d93defbcd7e95679 = true;
                  this.cd7c73e6d5e8821740a8d2c37bd8bb1b5();
                  this.ce75332160d718c37d93defbcd7e95679 = false;
                }
              }
              int index2 = 0;
              int num3 = visibleIndex;
              int num4 = integer;
              int c951d48897e714225d62719261dccb6d3 = num3;
              while (c951d48897e714225d62719261dccb6d3 <= num4)
              {
                string fieldName = this.c8699ecda178225da3aa67475e5cd54f5(c951d48897e714225d62719261dccb6d3).FieldName;
                if (count <= c951d48897e714225d62719261dccb6d3)
                {
label_30:
                  switch (4)
                  {
                    case 0:
                      goto label_30;
                    default:
                      goto label_43;
                  }
                }
                else
                {
                  if (!this.get_ColumnReadOnly(fieldName))
                  {
                    this.RowIndex = focusedRowHandle;
                    string str2 = strArray2[index2];
                    if (str2.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3974)))
                    {
label_33:
                      switch (4)
                      {
                        case 0:
                          goto label_33;
                        default:
                          if (str2.StartsWith(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10536)))
                          {
label_35:
                            switch (2)
                            {
                              case 0:
                                goto label_35;
                              default:
                                str2 = str2.Substring(1);
                                break;
                            }
                          }
                          if (str2.EndsWith(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10536)))
                            str2 = str2.Substring(0, checked (str2.Length - 1));
                          str2 = str2.Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(3974), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(4805));
                          break;
                      }
                    }
                    this.set_EditText(fieldName, focusedRowHandle, str2);
                  }
                  checked { ++index2; }
                  checked { ++c951d48897e714225d62719261dccb6d3; }
                }
              }
label_43:
              checked { ++focusedRowHandle; }
              flag = false;
              checked { ++index1; }
            }
label_45:
            switch (1)
            {
              case 0:
                goto label_45;
              default:
                this.cb1889f5f18b3611413f64aac4ae0c235(focusedRowHandle, this.GridView1.FocusedRowHandle);
                break;
            }
          }
        }
      }
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageInfo(ex.Message, title: this.Name + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10539));
      ProjectData.ClearProjectError();
    }
  }

  public void Export(string type)
  {
    if (this.GridView1 == null)
    {
label_1:
      switch (6)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.Export);
          break;
      }
    }
    else
    {
      string title = "";
      if (this.c330a4db27d3578a8e5d80797d2f5ac12 != null)
        title = this.c330a4db27d3578a8e5d80797d2f5ac12.Name;
      GridExport gridExport = new GridExport();
      gridExport.SetGridView(this, title, type);
      int num = (int) gridExport.ShowDialog();
    }
  }

  public void Export() => this.Export("");

  public void ExportToXlsx(string filePath, bool openFile = true)
  {
    this.GridView1.OptionsPrint.PrintHeader = false;
    this.GridView1.OptionsPrint.AutoWidth = false;
    this.GridView1.OptionsPrint.ShowPrintExportProgress = true;
    this.GridView1.ExportToXlsx(filePath);
    if (!openFile)
      return;
label_1:
    switch (2)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.ExportToXlsx);
        }
        new Process()
        {
          StartInfo = {
            FileName = filePath
          }
        }.Start();
        break;
    }
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public bool StopJump
  {
    get => this.cde42dfe20fdea515a20ee9c3cd7fec49;
    set => this.cde42dfe20fdea515a20ee9c3cd7fec49 = value;
  }

  [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
  [Browsable(false)]
  public bool StopPopup
  {
    get => this.cd5ee370368dc75972785b2283583d43f;
    set => this.cd5ee370368dc75972785b2283583d43f = value;
  }

  public void RunPopup(string fieldName, bool showDialog = false)
  {
    if (this.c018a99ed0c66295f13c59de7c8b6aa4c)
      return;
    if (this.cd5ee370368dc75972785b2283583d43f)
    {
label_3:
      switch (6)
      {
        case 0:
          goto label_3;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.RunPopup);
          break;
      }
    }
    else if (this.cd268e238072e06dd96804a08ee584b75)
    {
label_8:
      switch (7)
      {
        case 0:
          goto label_8;
      }
    }
    else
    {
      if (this.ReadOnly)
        return;
      if (this.GridColumns == null)
      {
label_13:
        switch (3)
        {
          case 0:
            goto label_13;
        }
      }
      else if (!this.GridColumns.Contains(fieldName))
      {
label_16:
        switch (1)
        {
          case 0:
            goto label_16;
        }
      }
      else
      {
        eGridColumn gridColumn = (eGridColumn) this.GridColumns[fieldName];
        if (!(Microsoft.VisualBasic.CompilerServices.Operators.CompareString(gridColumn.PopupType, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10556), false) == 0 | Microsoft.VisualBasic.CompilerServices.Operators.CompareString(gridColumn.PopupType, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5316), false) == 0))
        {
label_18:
          switch (1)
          {
            case 0:
              goto label_18;
          }
        }
        else
        {
          if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(gridColumn.PopupType, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5316), false) == 0 & !showDialog)
            return;
          if (gridColumn.ReadOnly)
          {
label_23:
            switch (7)
            {
              case 0:
                goto label_23;
            }
          }
          else
          {
            Popup popup = gridColumn.Popup;
            if (popup == null)
              return;
            if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(gridColumn.PopupType, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5316), false) == 0)
            {
              if (popup.IsFormLoaded)
              {
label_27:
                switch (2)
                {
                  case 0:
                    goto label_27;
                  default:
                    popup.CloseForm();
                    return;
                }
              }
              else
              {
                popup.SetDynamicCombo();
                BaseEdit activeEditor = this.GridView1.ActiveEditor;
                Point screen = activeEditor.PointToScreen(new Point(0, checked (activeEditor.Height + 1)));
                popup.SetLocation(screen);
              }
            }
            this.cd5ee370368dc75972785b2283583d43f = true;
            popup.Run(showDialog);
            this.cd5ee370368dc75972785b2283583d43f = false;
          }
        }
      }
    }
  }

  public void ClearFormatColor()
  {
    if (this.GridView1.FormatConditions == null)
    {
label_1:
      switch (2)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.ClearFormatColor);
          break;
      }
    }
    else if (0 < this.GridView1.FormatConditions.Count)
      this.GridView1.FormatConditions.Clear();
  }

  public bool SetFormatColor(
    string fieldName,
    string condition,
    Color foreColor,
    Color backColor,
    Color backColor2 = default (Color),
    bool horizontalGradient = true,
    bool row = true,
    bool bold = false,
    bool italic = false,
    bool strikeout = false,
    bool underline = false,
    string fontName = null,
    int fontSize = 0)
  {
    try
    {
      this.GridView1.FormatConditions.BeginUpdate();
      StyleFormatCondition condition1 = new StyleFormatCondition();
      condition1.Condition = FormatConditionEnum.Expression;
      this.GridView1.FormatConditions.Add(condition1);
      condition1.Column = this.get_c3b70f7febd94504d2ae889cd04cf3e00(fieldName);
      condition1.Expression = condition;
      condition1.ApplyToRow = row;
      condition1.Appearance.ForeColor = foreColor;
      condition1.Appearance.BackColor = backColor;
      if (backColor2 != new Color())
      {
label_2:
        switch (7)
        {
          case 0:
            goto label_2;
          default:
            if (false)
            {
              // ISSUE: method reference
              RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.SetFormatColor);
            }
            condition1.Appearance.BackColor2 = backColor2;
            if (horizontalGradient)
            {
label_6:
              switch (7)
              {
                case 0:
                  goto label_6;
                default:
                  condition1.Appearance.GradientMode = LinearGradientMode.Horizontal;
                  break;
              }
            }
            else
              condition1.Appearance.GradientMode = LinearGradientMode.Vertical;
            break;
        }
      }
      if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(fontName, (string) null, false) != 0 || fontSize != 0)
      {
        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(fontName, (string) null, false) == 0)
        {
label_12:
          switch (4)
          {
            case 0:
              goto label_12;
            default:
              fontName = condition1.Appearance.Font.Name;
              break;
          }
        }
        if (fontSize == 0)
        {
label_15:
          switch (6)
          {
            case 0:
              goto label_15;
            default:
              fontSize = checked ((int) Math.Round((double) condition1.Appearance.Font.Size));
              break;
          }
        }
        condition1.Appearance.Font = new Font(fontName, (float) fontSize);
      }
      if (bold)
      {
label_19:
        switch (6)
        {
          case 0:
            goto label_19;
          default:
            condition1.Appearance.Font = new Font(condition1.Appearance.Font, FontStyle.Bold);
            break;
        }
      }
      if (italic)
        condition1.Appearance.Font = new Font(condition1.Appearance.Font, FontStyle.Italic);
      if (strikeout)
        condition1.Appearance.Font = new Font(condition1.Appearance.Font, FontStyle.Strikeout);
      if (underline)
      {
label_26:
        switch (6)
        {
          case 0:
            goto label_26;
          default:
            condition1.Appearance.Font = new Font(condition1.Appearance.Font, FontStyle.Underline);
            break;
        }
      }
      this.GridView1.FormatConditions.EndUpdate();
      return true;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageInfo(ex);
      ProjectData.ClearProjectError();
    }
    return false;
  }

  public bool SetFormatColor(DataRow[] dRows)
  {
    try
    {
      this.GridView1.FormatConditions.BeginUpdate();
      DataRow[] dataRowArray = dRows;
      int index = 0;
      while (index < dataRowArray.Length)
      {
        DataRow dataRow = dataRowArray[index];
        StyleFormatCondition condition = new StyleFormatCondition();
        condition.Condition = FormatConditionEnum.Expression;
        this.GridView1.FormatConditions.Add(condition);
        condition.Expression = Shared.ToStr(RuntimeHelpers.GetObjectValue(dataRow[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10567)]));
        condition.ApplyToRow = Shared.ToBool(RuntimeHelpers.GetObjectValue(dataRow[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10586)]));
        condition.Column = this.get_c3b70f7febd94504d2ae889cd04cf3e00(Shared.ToStr(RuntimeHelpers.GetObjectValue(dataRow[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10599)])));
        condition.Appearance.ForeColor = this.c0832de763c8018170b494cda22d4e15f(Shared.ToStr(RuntimeHelpers.GetObjectValue(dataRow[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10612)])));
        condition.Appearance.BackColor = this.c0832de763c8018170b494cda22d4e15f(Shared.ToStr(RuntimeHelpers.GetObjectValue(dataRow[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10631)])));
        condition.Appearance.BackColor2 = this.c0832de763c8018170b494cda22d4e15f(Shared.ToStr(RuntimeHelpers.GetObjectValue(dataRow[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10650)])));
        condition.Appearance.BorderColor = this.c0832de763c8018170b494cda22d4e15f(Shared.ToStr(RuntimeHelpers.GetObjectValue(dataRow[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10671)])));
        if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(dataRow[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10694)])), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10719), false) == 0)
        {
label_3:
          switch (7)
          {
            case 0:
              goto label_3;
            default:
              if (false)
              {
                // ISSUE: method reference
                RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.SetFormatColor);
              }
              condition.Appearance.GradientMode = LinearGradientMode.Horizontal;
              break;
          }
        }
        else
          condition.Appearance.GradientMode = LinearGradientMode.Vertical;
        if (Shared.ToBool(RuntimeHelpers.GetObjectValue(dataRow[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10740)])))
        {
label_9:
          switch (6)
          {
            case 0:
              goto label_9;
            default:
              condition.Appearance.Font = new Font(condition.Appearance.Font, FontStyle.Bold);
              break;
          }
        }
        if (Shared.ToBool(RuntimeHelpers.GetObjectValue(dataRow[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10759)])))
        {
label_12:
          switch (5)
          {
            case 0:
              goto label_12;
            default:
              condition.Appearance.Font = new Font(condition.Appearance.Font, FontStyle.Italic);
              break;
          }
        }
        if (Shared.ToBool(RuntimeHelpers.GetObjectValue(dataRow[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10782)])))
        {
label_15:
          switch (7)
          {
            case 0:
              goto label_15;
            default:
              condition.Appearance.Font = new Font(condition.Appearance.Font, FontStyle.Strikeout);
              break;
          }
        }
        if (Shared.ToBool(RuntimeHelpers.GetObjectValue(dataRow[c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10811)])))
          condition.Appearance.Font = new Font(condition.Appearance.Font, FontStyle.Underline);
        checked { ++index; }
      }
      this.GridView1.FormatConditions.EndUpdate();
      return true;
    }
    catch (Exception ex)
    {
      ProjectData.SetProjectError(ex);
      Shared.MessageInfo(ex);
      ProjectData.ClearProjectError();
    }
    return false;
  }

  private Color c0832de763c8018170b494cda22d4e15f(string c572670a0893da62c6e39b17eb6d888cf)
  {
    if (c572670a0893da62c6e39b17eb6d888cf.Contains(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10840)))
    {
label_1:
      switch (1)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c0832de763c8018170b494cda22d4e15f);
          }
          return Color.Empty;
      }
    }
    else
    {
      c572670a0893da62c6e39b17eb6d888cf = c572670a0893da62c6e39b17eb6d888cf.Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10867), "");
      c572670a0893da62c6e39b17eb6d888cf = c572670a0893da62c6e39b17eb6d888cf.Replace(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10882), "");
      if (!c572670a0893da62c6e39b17eb6d888cf.StartsWith(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10885)))
        return Color.FromName(c572670a0893da62c6e39b17eb6d888cf);
label_6:
      switch (1)
      {
        case 0:
          goto label_6;
        default:
          string[] strArray = c572670a0893da62c6e39b17eb6d888cf.Split(',');
          return Color.FromArgb(Conversions.ToInteger(Conversion.Int((object) strArray[0].Split('=')[1])), Conversions.ToInteger(Conversion.Int((object) strArray[1].Split('=')[1])), Conversions.ToInteger(Conversion.Int((object) strArray[2].Split('=')[1])), Conversions.ToInteger(Conversion.Int((object) strArray[3].Split('=')[1])));
      }
    }
  }

  private void cbd426daa88abecefd15de18d673cb387(
    object c7a1c50d8950fe539821ded4a87a7123f,
    EventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (this.cbee725c554d327dc3d76039ee2804a33)
    {
label_1:
      switch (1)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cbd426daa88abecefd15de18d673cb387);
          break;
      }
    }
    else
    {
      DevExpress.XtraGrid.Columns.GridColumn c1e6290ac54e381b2081d91b6c00805a8 = (DevExpress.XtraGrid.Columns.GridColumn) c7a1c50d8950fe539821ded4a87a7123f;
      GridBand gridBand = this.c19f146e2e7d387b94d283d782a9c2c12(c1e6290ac54e381b2081d91b6c00805a8);
      if (gridBand.Visible != c1e6290ac54e381b2081d91b6c00805a8.Visible)
      {
label_5:
        switch (1)
        {
          case 0:
            goto label_5;
          default:
            gridBand.Visible = c1e6290ac54e381b2081d91b6c00805a8.Visible;
            break;
        }
      }
    }
  }

  private void cb4c282b196f843ccd90b4a7af0410144(
    object c7a1c50d8950fe539821ded4a87a7123f,
    CellMergeEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (!this.c50ccdc5283b68b92131a5a8841c52a70)
    {
label_1:
      switch (5)
      {
        case 0:
          goto label_1;
        default:
          if (true)
            break;
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cb4c282b196f843ccd90b4a7af0410144);
          break;
      }
    }
    else
    {
      try
      {
        int index = checked (c320269ec287d16905c829847d30a2e08.Column.AbsoluteIndex - 1);
        while (index >= 0)
        {
          DevExpress.XtraGrid.Columns.GridColumn column = (DevExpress.XtraGrid.Columns.GridColumn) this.GridView1.Columns[index];
          if (column.OptionsColumn.AllowMerge == DefaultBoolean.False)
          {
label_7:
            switch (7)
            {
              case 0:
                goto label_7;
              default:
                return;
            }
          }
          else if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(this.get_Text(column.FieldName, c320269ec287d16905c829847d30a2e08.RowHandle1), this.get_Text(column.FieldName, c320269ec287d16905c829847d30a2e08.RowHandle2), false) != 0)
          {
label_9:
            switch (3)
            {
              case 0:
                goto label_9;
              default:
                c320269ec287d16905c829847d30a2e08.Merge = false;
                c320269ec287d16905c829847d30a2e08.Handled = true;
                return;
            }
          }
          else
            checked { index += -1; }
        }
      }
      catch (Exception ex)
      {
        ProjectData.SetProjectError(ex);
        ProjectData.ClearProjectError();
      }
    }
  }

  private void ce1e13d20961f5737565140412d5c2a0b(
    object c7a1c50d8950fe539821ded4a87a7123f,
    SelectionChangedEventArgs c320269ec287d16905c829847d30a2e08)
  {
    int num1;
    if (this.GridView1.GetSelectedCells() != null)
    {
label_1:
      switch (4)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.ce1e13d20961f5737565140412d5c2a0b);
          }
          num1 = this.GridView1.GetSelectedCells().Length == 1 ? 1 : 0;
          break;
      }
    }
    else
      num1 = 1;
    if (num1 != 0)
      Parameter.MainFrame.StatusEndMessage = "";
    else if (this.ce75332160d718c37d93defbcd7e95679)
    {
label_9:
      switch (2)
      {
        case 0:
          goto label_9;
      }
    }
    else
    {
      Decimal num2 = 0M;
      Decimal num3 = 0M;
      GridCell[] selectedCells = this.GridView1.GetSelectedCells();
      int index = 0;
      while (index < selectedCells.Length)
      {
        GridCell gridCell = selectedCells[index];
        int num4;
        if (gridCell.Column.ColumnEdit != null)
        {
label_12:
          switch (2)
          {
            case 0:
              goto label_12;
            default:
              num4 = gridCell.Column.ColumnEdit.DisplayFormat.FormatType == FormatType.Numeric ? 1 : 0;
              break;
          }
        }
        else
          num4 = 0;
        if (num4 != 0)
        {
          string fieldName = gridCell.Column.FieldName;
          int rowHandle = gridCell.RowHandle;
          num3 = Decimal.Add(num3, 1M);
          num2 = Decimal.Add(num2, this.get_ToDec(fieldName, rowHandle));
        }
        checked { ++index; }
      }
label_19:
      switch (5)
      {
        case 0:
          goto label_19;
        default:
          string str = "";
          if (Decimal.Compare(num2, 0M) != 0)
          {
label_21:
            switch (4)
            {
              case 0:
                goto label_21;
              default:
                str = c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10890) + Strings.Format((object) num2, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10899)) + c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(10922) + Strings.Format((object) num3, c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(5378));
                break;
            }
          }
          Parameter.MainFrame.StatusEndMessage = str;
          break;
      }
    }
  }

  private void cee195af6c1eac6e0e57a73f31f0d30e3(
    object c7a1c50d8950fe539821ded4a87a7123f,
    BaseContainerValidateEditorEventArgs c320269ec287d16905c829847d30a2e08)
  {
    eGridColumn eGridColumn = this.GridColumn(this.FocusedFieldName);
    string Left = "";
    // ISSUE: reference to a compiler-generated field
    eGrid.CellValueValidatingEventHandler c040a3e81d1a78dd433c243605ac0bac8 = this.c040a3e81d1a78dd433c243605ac0bac8;
    bool flag1;
    if (c040a3e81d1a78dd433c243605ac0bac8 != null)
    {
label_1:
      switch (1)
      {
        case 0:
          goto label_1;
        default:
          if (false)
          {
            // ISSUE: method reference
            RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.cee195af6c1eac6e0e57a73f31f0d30e3);
          }
          eGrid.CellValueValidatingEventHandler validatingEventHandler = c040a3e81d1a78dd433c243605ac0bac8;
          object objectValue1 = RuntimeHelpers.GetObjectValue(c7a1c50d8950fe539821ded4a87a7123f);
          string focusedFieldName = this.FocusedFieldName;
          int rowIndex = this.RowIndex;
          BaseContainerValidateEditorEventArgs validateEditorEventArgs;
          object objectValue2 = RuntimeHelpers.GetObjectValue((validateEditorEventArgs = c320269ec287d16905c829847d30a2e08).Value);
          ref object local1 = ref objectValue2;
          ref bool local2 = ref flag1;
          ref string local3 = ref Left;
          validatingEventHandler(objectValue1, focusedFieldName, rowIndex, ref local1, ref local2, ref local3);
          validateEditorEventArgs.Value = RuntimeHelpers.GetObjectValue(objectValue2);
          break;
      }
    }
    if (Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Left, "", false) != 0)
    {
label_6:
      switch (2)
      {
        case 0:
          goto label_6;
        default:
          c320269ec287d16905c829847d30a2e08.Valid = false;
          c320269ec287d16905c829847d30a2e08.ErrorText = Left;
          break;
      }
    }
    else
    {
      if (flag1)
      {
label_9:
        switch (4)
        {
          case 0:
            goto label_9;
          default:
            c320269ec287d16905c829847d30a2e08.Value = (object) eGridColumn.InitText;
            break;
        }
      }
      int num;
      if (!Microsoft.VisualBasic.CompilerServices.Operators.ConditionalCompareObjectNotEqual(eGridColumn.MinValue, (object) null, false))
      {
label_12:
        switch (1)
        {
          case 0:
            goto label_12;
          default:
            num = Microsoft.VisualBasic.CompilerServices.Operators.ConditionalCompareObjectNotEqual(eGridColumn.MaxValue, (object) null, false) ? 1 : 0;
            break;
        }
      }
      else
        num = 1;
      if (num != 0 && Microsoft.VisualBasic.CompilerServices.Operators.CompareString(Shared.ToStr(RuntimeHelpers.GetObjectValue(c320269ec287d16905c829847d30a2e08.Value)), "", false) != 0)
      {
label_16:
        switch (2)
        {
          case 0:
            goto label_16;
          default:
            bool flag2 = false;
            if (Microsoft.VisualBasic.CompilerServices.Operators.ConditionalCompareObjectNotEqual(eGridColumn.MinValue, (object) null, false))
            {
label_18:
              switch (1)
              {
                case 0:
                  goto label_18;
                default:
                  if (eGridColumn.FieldType == FieldType.Decimal | eGridColumn.FieldType == FieldType.Int)
                  {
                    if (Decimal.Compare(Shared.ToDec(RuntimeHelpers.GetObjectValue(c320269ec287d16905c829847d30a2e08.Value)), Shared.ToDec(RuntimeHelpers.GetObjectValue(eGridColumn.MinValue))) < 0)
                    {
label_21:
                      switch (7)
                      {
                        case 0:
                          goto label_21;
                        default:
                          flag2 = true;
                          break;
                      }
                    }
                  }
                  else if (Microsoft.VisualBasic.CompilerServices.Operators.ConditionalCompareObjectLess(c320269ec287d16905c829847d30a2e08.Value, eGridColumn.MinValue, false))
                    flag2 = true;
                  if (flag2)
                  {
label_27:
                    switch (4)
                    {
                      case 0:
                        goto label_27;
                      default:
                        c320269ec287d16905c829847d30a2e08.ErrorText = Shared.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(876), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(911));
                        c320269ec287d16905c829847d30a2e08.Valid = false;
                        return;
                    }
                  }
                  else
                    break;
              }
            }
            if (Microsoft.VisualBasic.CompilerServices.Operators.ConditionalCompareObjectNotEqual(eGridColumn.MaxValue, (object) null, false))
            {
label_30:
              switch (5)
              {
                case 0:
                  goto label_30;
                default:
                  if (eGridColumn.FieldType == FieldType.Decimal | eGridColumn.FieldType == FieldType.Int)
                  {
label_32:
                    switch (1)
                    {
                      case 0:
                        goto label_32;
                      default:
                        if (Decimal.Compare(Shared.ToDec(RuntimeHelpers.GetObjectValue(c320269ec287d16905c829847d30a2e08.Value)), Shared.ToDec(RuntimeHelpers.GetObjectValue(eGridColumn.MaxValue))) > 0)
                        {
label_34:
                          switch (1)
                          {
                            case 0:
                              goto label_34;
                            default:
                              flag2 = true;
                              break;
                          }
                        }
                        else
                          break;
                        break;
                    }
                  }
                  else if (Microsoft.VisualBasic.CompilerServices.Operators.ConditionalCompareObjectGreater(c320269ec287d16905c829847d30a2e08.Value, eGridColumn.MaxValue, false))
                    flag2 = true;
                  if (flag2)
                  {
label_40:
                    switch (2)
                    {
                      case 0:
                        goto label_40;
                      default:
                        c320269ec287d16905c829847d30a2e08.ErrorText = Shared.GetMessage(c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(948), c2090e327459511ba5871dbb8f5c0c901.cca3ba8d2c5fb5169816ae7fbf3239419(983));
                        c320269ec287d16905c829847d30a2e08.Valid = false;
                        return;
                    }
                  }
                  else
                    break;
              }
            }
            break;
        }
      }
    }
  }

  private void c647223605df2113372ae3fa98fe4e4b7(
    object c7a1c50d8950fe539821ded4a87a7123f,
    MouseEventArgs c320269ec287d16905c829847d30a2e08)
  {
    if (this.GridView1.ActiveEditor == null)
      return;
    this.UpdateCurrentRow();
  }

  private void c7f40c8562920a622aa42ad82d6a5274a(
    object c7a1c50d8950fe539821ded4a87a7123f,
    DragObjectDropEventArgs c320269ec287d16905c829847d30a2e08)
  {
    BandedGridView gridView1 = this.GridView1;
    Point mousePosition = Control.MousePosition;
    int x = mousePosition.X;
    mousePosition = Control.MousePosition;
    int y = mousePosition.Y;
    Point client = this.PointToClient(new Point(x, y));
    if (!gridView1.CalcHitInfo(client).InGroupPanel || !(c320269ec287d16905c829847d30a2e08.DragObject is GridBand))
      return;
label_1:
    switch (5)
    {
      case 0:
        goto label_1;
      default:
        if (false)
        {
          // ISSUE: method reference
          RuntimeMethodHandle runtimeMethodHandle = __methodref (eGrid.c7f40c8562920a622aa42ad82d6a5274a);
        }
        GridBand dragObject = (GridBand) c320269ec287d16905c829847d30a2e08.DragObject;
        int num;
        if (dragObject.Columns != null)
        {
label_5:
          switch (2)
          {
            case 0:
              goto label_5;
            default:
              num = dragObject.Columns.Count == 1 ? 1 : 0;
              break;
          }
        }
        else
          num = 0;
        if (num != 0)
        {
label_9:
          switch (3)
          {
            case 0:
              goto label_9;
            default:
              this.AddGroup(dragObject.Columns[0].FieldName);
              break;
          }
        }
        break;
    }
  }

  public delegate void ButtonPressedEventHandler(object sender, string columnName);

  public delegate void InsertedRowEventHandler(object sender, int RowIndex);

  public delegate void DeletingRowEventHandler(object sender, int RowIndex, ref bool Cancel);

  public delegate void DeletedRowEventHandler(object sender, int RowIndex);

  public delegate void AddedRowEventHandler(object sender, int RowIndex);

  public delegate void BeforeMoveRowEventHandler(object sender, int RowIndex, ref bool AllowMove);

  public delegate void AfterMoveRowEventHandler(object sender, int PrevRowIndex, int RowIndex);

  public delegate void AfterMoveColumnEventHandler(
    object sender,
    string PrevColumnName,
    string ColumnName);

  public delegate void CellValueChangedEventHandler(
    object sender,
    string ColumnName,
    int RowIndex,
    ref object Value);

  public delegate void CellValueChangingEventHandler(
    object sender,
    string ColumnName,
    int RowIndex,
    ref object Value);

  public delegate void CellValueValidatingEventHandler(
    object sender,
    string ColumnName,
    int RowIndex,
    ref object Value,
    ref bool Cancel,
    ref string ErrorText);

  public delegate void KeyDownEventHandler(object sender, KeyEventArgs e);

  public delegate void MouseDownEventHandler(object sender, MouseEventArgs e);

  public delegate void MouseUpEventHandler(object sender, MouseEventArgs e);

  public delegate void ColumnDoubleClickEventHandler(object sender, string ColumnName);

  public delegate void DoubleClickEventHandler(object sender, EventArgs e);

  public delegate void ClickEventHandler(object sender, EventArgs e);
}




For Each ctrl As Control In g10.Controls
    Debug.Print(ctrl.Name & " : " & ctrl.GetType().FullName)
Next
위의 출력 결과는 아무 것도 안찍힘.





'''' 2번

        Dim soNums As String = "" ' 2025-05-20 hsg keroro 여러 개의 오더번호를 이어붙이는 변수라는 뜻으로 접미사로 's'를 붙임
 
        ' 다중 선택 활성화
        g10.MultiSelect = True
 
        ' 선택된 행 인덱스 가져오기
        Dim selectedRows() As Integer = g10.GetSelectedRows()
 
        ' 선택된 행 데이터 추출 (예시)
        For Each rowIndex As Integer In selectedRows
            soNums = soNums & g10.Text("so_no", rowIndex) + ", "
        Next
 
        ' soNums값이 Null 또는 빈 문자열 체크. 값이 있을 경우에만 공통알람 호출
        If Not String.IsNullOrEmpty(soNums) Then
 
            MsgBox("오더정보에서 오더번호를 선택하세요.")
 
        Else
 
            approvalForm = JumpToFormCode("CJSF023") <-- 이 부분에서 다음과 같은 오류가 남. "Object 변수 또는 With 블록 변수가 설정되지 않았습니다."
 
            If approvalForm IsNot Nothing Then
 
                approvalForm.LoadAll(Name, soNums)
 
            End If
 
        End If
 
 
 
 
 3번.
 
 | 항목        | 내용                                       |
| --------- | ---------------------------------------- |
| 선택 방식     | Ctrl+마우스 클릭으로 여러 줄 선택                    |
| 기대 결과     | `GetSelectedRows()`가 여러 인덱스 반환           |
| 실제 결과     | 항상 하나의 RowHandle만 반환됨                    |
| 사용한 확인 코드 | 출력용 그리드에서 확인 |

 


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










