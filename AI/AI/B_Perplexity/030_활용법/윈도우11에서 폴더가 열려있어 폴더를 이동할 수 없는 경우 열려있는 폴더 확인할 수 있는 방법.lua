

=================================> AI에 질문 :


윈도우11에서 폴더가 열려있어 폴더를 이동할 수 없는 경우 열려있는 폴더 확인할 수 있는 방법



---===---===---===---===---===---> AI 답변 :




## 윈도우 11에서 폴더가 열려 있어 이동할 수 없는 경우, 열려 있는 폴더 확인 방법

윈도우 11에서 폴더를 이동·삭제하려고 할 때 "폴더가 열려 있어 작업을 완료할 수 없습니다"라는 오류가 발생하는 경우, 해당 폴더 또는 폴더 내 파일이 현재 어떤 프로그램이나 프로세스에서 사용 중인지 확인해야 합니다. 아래는 열려 있는 폴더를 확인하고 문제를 해결하는 대표적인 방법입니다.

---

**1. 리소스 모니터로 열려 있는 폴더 확인**

- 키보드에서 `Win + R`을 눌러 실행 창을 엽니다.
- `resmon`을 입력하고 Enter를 눌러 리소스 모니터를 실행합니다.
- 상단 탭에서 **CPU**를 선택합니다.
- 중간에 있는 **연결된 핸들** 검색창에 이동이 안 되는 폴더명(또는 경로 일부)을 입력합니다.
- 검색 결과에 해당 폴더를 사용 중인 프로세스가 표시됩니다. 이 프로세스가 폴더를 점유하고 있는 것입니다[13][11].

**2. PowerToys의 File Locksmith 사용**

- Microsoft의 무료 유틸리티 PowerToys를 설치합니다.
- 파일 탐색기에서 이동이 안 되는 폴더(또는 파일)를 마우스 오른쪽 버튼으로 클릭합니다.
- 메뉴에서 **File Locksmith로 잠금 해제**를 선택합니다.
- 해당 폴더(또는 파일)를 점유하고 있는 프로세스 목록이 나타납니다. 필요시 "작업 끝내기"로 프로세스를 종료할 수 있습니다[7].

**3. Microsoft Sysinternals의 Handle 도구 활용**

- Microsoft 공식 사이트에서 **Handle** 도구를 다운로드합니다.
- 압축을 풀고, 명령 프롬프트(또는 터미널)에서 해당 폴더로 이동합니다.
- 아래와 같이 명령어를 입력하여 폴더를 점유 중인 프로세스를 확인할 수 있습니다:
  ```
  handle.exe "폴더경로"
  ```
- 결과에 표시된 프로세스 ID를 확인해 작업 관리자 등에서 종료할 수 있습니다[11].

**4. 작업 관리자에서 직접 프로세스 종료**

- `Ctrl + Shift + Esc`로 작업 관리자를 엽니다.
- **프로세스** 탭에서 의심되는 프로그램(예: 탐색기, 백신, 미리보기 등)을 찾아 마우스 오른쪽 버튼으로 클릭 후 **작업 끝내기**를 선택합니다[13].

---

### 참고 사항

- 폴더가 열려 있지 않아도, 폴더 내 파일이 다른 프로그램(미리보기, 백업, 백신 등)에서 사용 중이면 동일한 오류가 발생할 수 있습니다.
- 위 방법으로도 해결되지 않으면, Windows 탐색기 자체를 다시 시작하거나 PC를 재부팅하는 것도 방법입니다[7][13].

---

이 과정을 통해 윈도우 11에서 폴더가 열려 있어 이동할 수 없는 경우, 어떤 프로세스가 폴더를 점유하고 있는지 확인하고 안전하게 해결할 수 있습니다.

Citations:
[1] https://geekorea.com/how-to-restore-previously-open-folders-windows-at-login/
[2] https://blog.naver.com/cubloc/222810497261
[3] https://blog.naver.com/toruin84/222680906672
[4] https://answers.microsoft.com/ko-kr/windows/forum/all/%EB%82%B4/51565d8b-fbd2-41d5-91af-ecb23d65b045
[5] https://bokthank.tistory.com/61
[6] https://www.youtube.com/watch?v=q2B-4FUmMqA
[7] https://www.easeus.co.kr/data-recovery-solution/action-cant-be-completed-because-file-open.html
[8] https://www.youtube.com/watch?v=QM76LvSV6ic
[9] https://support.microsoft.com/ko-kr/windows/%ED%8C%8C%EC%9D%BC-%ED%83%90%EC%83%89%EA%B8%B0-%EC%B0%BE%EA%B8%B0-%EB%B0%8F-%EC%97%B4%EA%B8%B0-ef370130-1cca-9dc5-e0df-2f7416fe1cb1
[10] https://support.microsoft.com/ko-kr/windows/windows%EC%97%90%EC%84%9C-%ED%8C%8C%EC%9D%BC-%ED%83%90%EC%83%89%EA%B8%B0-ef370130-1cca-9dc5-e0df-2f7416fe1cb1
[11] https://geekorea.com/how-to-check-which-process-using-file/
[12] https://support.microsoft.com/ko-kr/windows/windows%EC%97%90%EC%84%9C-%EB%AC%B8%EC%84%9C-%EC%B0%BE%EA%B8%B0-5c7c8cfe-c289-fae4-f5f8-6b3fdba418d2
[13] https://www.donga.com/news/It/article/all/20250410/131389589/1
[14] https://isgkorea.tistory.com/358
[15] https://answers.microsoft.com/ko-kr/windows/forum/all/%EC%9C%88%EB%8F%84%EC%9A%B0-11%EC%97%90%EC%84%9C/04a2c8fd-dac7-449c-8152-53033baf3996
[16] https://shortcuts.tistory.com/33
[17] https://blog.naver.com/doctorya/222512653658
[18] https://blog.naver.com/titil52/223531319842
[19] https://support.microsoft.com/ko-kr/topic/onenote%EB%A5%BC-%EB%8F%99%EA%B8%B0%ED%99%94%ED%95%A0-%EC%88%98-%EC%97%86%EB%8A%94-%EA%B2%BD%EC%9A%B0-%EB%AC%B8%EC%A0%9C-%ED%95%B4%EA%B2%B0-299495ef-66d1-448f-90c1-b785a6968d45
[20] https://topics.mop.kr/d/15

---
Perplexity로부터의 답변: pplx.ai/share



