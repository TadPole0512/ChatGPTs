# 🧭 IntelliJ IDEA 사용 가이드용 “정확한 답변” 사전 지침 v1.0

> 목표: IntelliJ 관련 질문을 했을 때 **한 번에 정확한 답**을 받도록, 질문 전에 고정해야 할 정보·재현 코드·스크린샷 규격을 표준화

---

## **A. 프레이밍 & 원칙**

* Overview

  * ▷ Background

    * IntelliJ는 OS·JDK·Gradle/Maven·플러그인·Keymap·프로젝트 SDK 등 변수가 많아 **질문이 모호**해지기 쉽다
    * 같은 증상도 **에디션(Community/Ultimate), 버전, 플러그인**에 따라 해결책이 달라진다
    * GUI 기준으로 “어디를 클릭했는지”가 중요하므로 **메뉴 경로**와 **정확한 텍스트**가 필요
    * 초보자는 “프로젝트 SDK/언어 레벨/Gradle JVM” 불일치에서 가장 많이 막힌다
* 핵심 원칙

  * **사전 브리핑 + 재현 예제 + 콘솔/빌드 로그**를 항상 함께 제출
  * GUI 경로는 “한글/영문 메뉴명” 병기 (`File > Settings(설정) > Build, Execution, Deployment > …`)
  * **버전·JDK·Gradle Wrapper**를 명시하고, “무엇을 기대했고 실제로 무엇이 발생했는지”를 2~3문장으로 요약

> **Key takeaway: “환경 고정 + 재현 가능한 최소 예제 + GUI 경로”가 정답률을 결정한다.**

---

## **B. 사전 브리핑 템플릿 (질문 맨 위에 복붙)**

* How to use

  * ▷ Preparation

    * → 빈칸을 채우고, 모르면 `TBD-날짜`로 표시
  * ▷ Procedure

    * → 재현 프로젝트(아래 E 섹션)와 함께 첨부

```md
# [IntelliJ Pre-brief]

1) 목적/문맥
- 하고 싶은 일: (예: Gradle 프로젝트 임포트, Lombok 적용, Remote Debug, JUnit5 실행)
- 기대 결과 vs 실제 증상: (2~3문장)

2) 환경
- OS: Windows 11 / CPU·RAM: (예: i7, 32GB)
- IntelliJ Edition/Version: (예: IDEA Ultimate 2024.2.2, 한글/영문 UI)
- JDKs: Project SDK X, Gradle JVM Y, JAVA_HOME Z
- Build: (Gradle/Maven, Wrapper 버전)  Node/NPM(있다면)
- 플러그인: (필수 목록 – Lombok, Kotlin, Python, Database Tools 등)
- VCS: (Git 버전, 내부/외부 툴)

3) 프로젝트 메타
- 언어/버전: (Java 21/Kotlin 2.x/Scala 등)
- 프레임워크: (Spring Boot X.Y, Quarkus 등)
- Toolchain: (Maven or Gradle, Kotlin DSL 여부)
- 코드 스타일/Keymap: (Default/VS Code/IntelliJ)

4) GUI 재현 절차
- 클릭 경로: (정확한 메뉴명/버튼명/탭명, 한국어/영어 병기)
- 콘솔/빌드 로그: (오류 전문 30~50줄)
- 스크린샷: (Settings/Project Structure/Gradle/Run Config 탭)

5) 보안/공개 범위
- 공개 가능한 리포지토리/샘플/마스킹 규칙(토큰·URL·사내명)

[질문] (구체 질문 1~3개로 제한)
```

> **Key takeaway:** “에디션·버전·JDK·Wrapper·플러그인”을 못 박아야 처방이 정확해진다.

---

## **C. 결정 트리 (질문을 먼저 라벨링)**

* Overview

  * ▷ 분류

    * A) **설치/초기세팅**: JDK/SDK/Keymap/한글화/플러그인
    * B) **프로젝트 임포트/빌드**: Gradle/Maven, Wrapper, Annotation Processing, Lombok
    * C) **실행/디버그/테스트**: Run Config, Debug, JUnit5, 코드 커버리지
    * D) **에디터/코드 스타일**: 포매터, 인스펙션, Live Template
    * E) **VCS/브랜치 전략**: Git, 변경 뷰, 코드리뷰
    * F) **성능/인덱싱**: 메모리, 캐시, 플러그인 다이어트
    * G) **원격/도커/DB**: Remote Debug, Docker, Database Tools
* How to use

  * ▷ Procedure

    * → 본인 질문이 어느 카테고리인지 **첫 줄에 표기**
    * → B 섹션 템플릿 + E 섹션 재현 예제 동봉

> **Key takeaway:** 라벨링만 잘 해도 답변 탐색범위를 1/3로 줄일 수 있다.

---

## **D. 헷갈리는 핵심 포인트 요약**

* Overview

  * ▷ SDK/JDK

    * **Project SDK**(Project Structure)와 **Gradle JVM**(Settings>Gradle)은 **동일 메이저**로 맞춘다
    * **Language level**은 컴파일 타깃과 일치 (예: Java 21)
  * ▷ Gradle

    * **Wrapper(gradlew)** 강제 사용 → 팀 간 버전 일치
    * Gradle Daemon/JVM 옵션은 `gradle.properties`에 명시
  * ▷ Annotation Processing

    * Lombok 사용 시: `Settings > Build > Compiler > Annotation Processors > Enable` 체크 + **Lombok 플러그인 설치**
  * ▷ Run/Debug

    * 애플리케이션/테스트/Gradle Task **각각 별도의 설정**으로 분리
  * ▷ 인덱싱/성능

    * 불필요 플러그인 OFF, **Memory Settings** 조정, 대형 폴더(ex. `node_modules`) **Excluded** 처리

> **Key takeaway:** “Project SDK = Gradle JVM = Language level” 삼박자와 Lombok 설정이 고질병의 70%를 해결한다.

---

## **E. 최소 재현 예제 (완전 실행 가능한 샘플)**

* How to use

  * ▷ Preparation

    * → **Gradle + Java 21** 기준 (Windows)
    * → 새 폴더에 아래 파일 그대로 저장 → IntelliJ로 **Open**(Gradle 프로젝트로 감지)

**`settings.gradle.kts`**

```kotlin
rootProject.name = "intellij-repro"
```

**`build.gradle.kts`**

```kotlin
plugins {
    java
    application
}

java {
    toolchain { languageVersion.set(JavaLanguageVersion.of(21)) }
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(platform("org.junit:junit-bom:5.10.2"))
    testImplementation("org.junit.jupiter:junit-jupiter")
}

application {
    mainClass.set("org.example.App")
}

tasks.test {
    useJUnitPlatform()
}
```

**`src/main/java/org/example/App.java`**

```java
package org.example;

public class App {
    public static void main(String[] args) {
        System.out.println("Hello IntelliJ!");
    }
}
```

**`src/test/java/org/example/AppTest.java`**

```java
package org.example;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class AppTest {
    @Test
    void addition() {
        assertEquals(4, 2 + 2);
    }
}
```

> 실행 절차(GUI):
>
> 1. `File > Open > (프로젝트 폴더)` → Gradle 자동 감지
> 2. 우측 Gradle 탭에서 `Tasks > application > run` 더블클릭 → 콘솔 `Hello IntelliJ!` 확인
> 3. 상단 `Run` 설정에서 `Edit Configurations…` → `Application`이 생성되었는지 확인
> 4. `Run > Run 'App'` / `Run > Debug 'App'` 실행
> 5. `Run > Run Tests` 또는 우측 Gradle `verification > test` 실행

> **Key takeaway:** “Wrapper + Toolchain + JUnit5”가 통일된 재현 환경을 만든다.

---

## **F. GUI 절차(핵심 시나리오)**

* How to use

  * ▷ Preparation

    * → **Project SDK 등록:** `File > Project Structure > SDKs > Add JDK`
    * → **Project SDK 지정:** `Project Structure > Project > SDK = JDK 21`
    * → **Gradle JVM 통일:** `File > Settings > Build, Execution, Deployment > Build Tools > Gradle > Gradle JVM = JDK 21`
  * ▷ Procedure

    * → **Lombok 사용 시**

      * `File > Settings > Plugins > Marketplace > Lombok` 설치
      * `Settings > Build > Compiler > Annotation Processors > Enable` 체크
    * → **코드 스타일/포매터**

      * `File > Settings > Editor > Code Style > Java`에서 프로젝트 스키마 저장/공유
      * `.editorconfig` 체크(저장 시 포맷 일관)
    * → **키맵/단축키**

      * `File > Settings > Keymap`에서 `VS Code` 혹은 `IntelliJ` 선택
    * → **성능 튜닝**

      * `Help > Change Memory Settings`로 IDE Heap 상향
      * 인덱싱 느릴 때 `File > Invalidate Caches…` (재시작 동반)
      * 대용량 폴더 `Mark Directory as > Excluded`

> **Note:** Gradle/Maven 콘솔의 **오류 메시지 전문**이 해결의 핵심 단서다.

---

## **G. 문제 수집·진단 번들 규격 (Windows)**

* Overview

  * ▷ 수집물

    * `idea.log`, `build scans` URL(있다면), Gradle 콘솔 로그, 스크린샷 3장(Project Structure, Gradle, Run Config)
  * ▷ PowerShell 수집 스크립트 (붙여넣어 실행 → 텍스트 파일 생성)

```powershell
# Collect-IntelliJ-Diag.ps1
$Out = "$env:USERPROFILE\Desktop\ide-diagnosis.txt"
"=== System ===" | Out-File $Out
systeminfo | Out-File $Out -Append
"=== Java ===" | Out-File $Out -Append
java -version 2>> $Out
"=== Gradle ===" | Out-File $Out -Append
.\gradlew -v 2>> $Out
"=== Env ===" | Out-File $Out -Append
Get-ChildItem Env:JAVA_HOME | Out-File $Out -Append
"Saved to: $Out"
```

> **Key takeaway:** “로그+버전+GUI 캡처” 3종 세트가 없으면 해결 속도가 급격히 떨어진다.

---

## **H. IntelliJ 질문 프롬프트 템플릿 (정확도 강화)**

```md
[역할] 당신은 IntelliJ IDEA 전문가이자 빌드툴(Gradle/Maven) 컨설턴트다.
[목표] 내가 올린 재현 프로젝트와 로그로 문제를 재현하고, GUI 기준의 수정 절차를 제시하라.
[환경] OS/IDE Edition/Version, Project SDK, Gradle JVM, Wrapper, 플러그인 목록
[프로젝트] 언어/프레임워크/Toolchain, JUnit 버전, Annotation Processing 정책
[증상] 기대 vs 실제 (2~3문장), 발생 단계의 정확한 GUI 경로
[산출물] 1) 원인 2) 해결 절차(GUI 경로 병기) 3) 대안(Gradle/Maven 둘 다) 4) 재발 방지 체크리스트
```

> **Key takeaway:** “역할·환경·프로젝트·증상·산출물” 5요소를 채우면 정답률이 급상승한다.

---

## **I. 대안 시나리오(2~3가지)**

* **옵션 A: Gradle 표준화(권장)**

  * Wrapper 고정, Toolchain로 JDK 통제, CI와 동일 런타임 보장
* **옵션 B: Maven 단순화**

  * 사내 레거시 호환, 설정 난이도↓ (단, 멀티모듈/버전 정합성은 주의)
* **옵션 C: Community Edition + 경량 플러그인**

  * 불필요 플러그인 제거로 성능↑, 웹/DB 기능은 외부 툴로 대체

> **Key takeaway:** “Gradle Wrapper + Toolchain”이 팀 일관성과 재현성을 가장 높인다.

---

## **Checklist (Numbered)**

1. **Edition/Version/JDK/Wrapper/플러그인**을 Pre-brief에 명시
2. **Project SDK = Gradle JVM = Language level** 정합성 확인
3. **Gradle Wrapper로 임포트**(Open as Project) 및 빌드 스캔/콘솔 로그 확보
4. **Annotation Processing/Lombok** 설정 점검(플러그인 + Enable)
5. **Run/Debug/Test**를 별도 설정으로 분리하고 실행 확인
6. **Code Style/Keymap** 적용, `.editorconfig` 커밋
7. **Memory Settings/Excluded 폴더/플러그인 다이어트**로 성능 확보
8. **문제 수집 번들**(로그+스크린샷+재현 프로젝트) 포함해 질문 등록

---

원하면 위 **재현 프로젝트 템플릿(Gradle/Java 21)**을 **Spring Boot, Kotlin DSL, Maven 버전**으로도 바로 만들어 줄게.
지금 쓰는 IntelliJ 에디션/버전, JDK 버전, 빌드 툴(Gradle/Maven)만 알려주면 **당신 환경 맞춤 스타터**를 즉시 제공하겠다.
