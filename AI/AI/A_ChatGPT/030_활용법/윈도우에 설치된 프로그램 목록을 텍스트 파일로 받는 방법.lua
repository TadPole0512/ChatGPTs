윈도우에 설치된 프로그램 목록을 텍스트 파일로 받는 방법





윈도우에 설치된 프로그램 목록을 텍스트 파일로 받는 대표적인 방법 두 가지를 소개할게.

---

## 1. WMIC 명령어 이용하기

1. **명령 프롬프트(관리자 권한)** 로 실행
   시작 메뉴에서 `cmd`를 검색한 뒤, 우클릭 → **관리자 권한으로 실행**.

2. 아래 명령어 입력 후 실행

   ```
   wmic product get Name,Version > "%USERPROFILE%\Desktop\InstalledPrograms.txt"
   ```

   * `Name,Version` 항목만 출력
   * 결과가 바탕화면의 **InstalledPrograms.txt** 로 저장

3. 텍스트 파일 열어 확인

   ```
   notepad "%USERPROFILE%\Desktop\InstalledPrograms.txt"
   ```

> ⚠️ WMIC 기반 `Win32_Product` 클래스는 모든 MSI 기반 설치 항목만 조회하므로, **MSI가 아닌 설치**(EXE 인스톨러 등)는 누락될 수 있어.

---

## 2. PowerShell로 레지스트리 직접 조회하기

MSI／EXE 가리지 않고 레지스트리에 기록된 모든 설치 항목을 뽑아낼 수 있어.

1. **PowerShell(관리자 권한)** 실행
   시작 메뉴에서 `PowerShell` 검색 → 우클릭 → **관리자 권한으로 실행**.

2. 아래 스크립트를 복사·붙여넣기 후 실행

   ```powershell
   # 64비트 시스템용 레지스트리 경로
   $paths = @(
     'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
     'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
     'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
   )

   $programs = foreach ($p in $paths) {
     Get-ItemProperty $p -ErrorAction SilentlyContinue |
     Where-Object { $_.DisplayName } |
     Select-Object DisplayName, DisplayVersion, Publisher
   }

   # 결과를 텍스트 파일로 저장
   $outFile = "$env:USERPROFILE\Desktop\InstalledPrograms_Full.txt"
   $programs |
     Sort-Object DisplayName |
     Format-Table -AutoSize |
     Out-File -FilePath $outFile -Encoding UTF8

   Write-Host "📄 InstalledPrograms_Full.txt 파일이 바탕화면에 생성되었습니다."
   ```

3. 완료 메시지가 뜨면
   바탕화면의 **InstalledPrograms\_Full.txt** 파일을 확인하면 돼.

---

### 팁

* **경로 변경**
  `"$env:USERPROFILE\Desktop\…"` 대신 원하는 절대경로를 지정할 수 있어.
* **CSV로 저장**
  나중에 엑셀로 열어 정렬·필터링하려면 `Out-File` 대신 아래처럼 사용해봐.

  ```powershell
  $programs |
    Sort-Object DisplayName |
    Export-Csv -Path "$env:USERPROFILE\Desktop\InstalledPrograms.csv" -NoTypeInformation -Encoding UTF8
  ```

이 두 방법 중 상황에 맞게 골라 사용하면 돼. WMIC는 간단하지만 누락이 있을 수 있으니, **정확한 전체 목록**이 필요하면 PowerShell 레지스트리 스캔 방식을 추천할게.



