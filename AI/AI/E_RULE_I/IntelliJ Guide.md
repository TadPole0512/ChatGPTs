
---

# 🧭 Pre-Briefing Guidelines for Getting “Accurate Answers” about IntelliJ IDEA v1.0

> Goal: When asking IntelliJ-related questions, standardize what must be fixed before asking—environment details, reproducible code, and screenshot specs—so you get the **right answer in one go**.

---

## **A. Framing & Principles**

* Overview

  * ▷ Background

    * IntelliJ has many variables—OS, JDK, Gradle/Maven, plugins, keymap, project SDK—so questions **easily become ambiguous**.
    * Even with the same symptom, the solution can differ by **edition (Community/Ultimate), version, or plugins**.
    * Since the GUI is key, it matters **which exact menu you clicked**, so provide **menu paths** and **exact text**.
    * Beginners most often get stuck on mismatches among **Project SDK / Language Level / Gradle JVM**.
* Core Principles

  * Always submit a **pre-brief + reproducible example + console/build logs** together.
  * Provide GUI paths with **Korean/English dual labels** (`File > Settings(설정) > Build, Execution, Deployment > …`).
  * Specify **versions, JDK, Gradle Wrapper**, and summarize “what you expected vs. what actually happened” in 2–3 sentences.

> **Key takeaway: “Frozen environment + a minimal reproducible example + precise GUI paths” determine the accuracy of the answer.**

---

## **B. Pre-Briefing Template (paste at the top of your question)**

* How to use

  * ▷ Preparation

    * → Fill in the blanks; if unknown, mark as `TBD-<date>`.
  * ▷ Procedure

    * → Attach together with the repro project (Section E below).

```md
# [IntelliJ Pre-brief]

1) Purpose/Context
- What I want to do: (e.g., Import Gradle project, apply Lombok, Remote Debug, run JUnit5)
- Expected result vs. actual symptom: (2–3 sentences)

2) Environment
- OS: Windows 11 / CPU·RAM: (e.g., i7, 32GB)
- IntelliJ Edition/Version: (e.g., IDEA Ultimate 2024.2.2, Korean/English UI)
- JDKs: Project SDK X, Gradle JVM Y, JAVA_HOME Z
- Build: (Gradle/Maven, Wrapper version)  Node/NPM (if applicable)
- Plugins: (required list – Lombok, Kotlin, Python, Database Tools, etc.)
- VCS: (Git version, internal/external tool)

3) Project Meta
- Language/Version: (Java 21/Kotlin 2.x/Scala, etc.)
- Framework: (Spring Boot X.Y, Quarkus, etc.)
- Toolchain: (Maven or Gradle, whether Kotlin DSL)
- Code Style/Keymap: (Default/VS Code/IntelliJ)

4) GUI Reproduction Steps
- Click path: (exact menu/button/tab names, bilingual KR/EN)
- Console/Build logs: (full error excerpt 30–50 lines)
- Screenshots: (Settings / Project Structure / Gradle / Run Config tabs)

5) Security/Disclosure Scope
- Public repo/sample/masking rules (tokens·URLs·internal names)

[Question] (Limit to 1–3 specific questions)
```

> **Key takeaway:** Lock down “Edition · Version · JDK · Wrapper · Plugins” to get precise prescriptions.

---

## **C. Decision Tree (label your question first)**

* Overview

  * ▷ Classification

    * A) **Install/Initial setup**: JDK/SDK/Keymap/Localization/Plugins
    * B) **Project import/build**: Gradle/Maven, Wrapper, Annotation Processing, Lombok
    * C) **Run/Debug/Test**: Run Config, Debug, JUnit5, Code Coverage
    * D) **Editor/Code Style**: Formatter, Inspections, Live Templates
    * E) **VCS/Branching**: Git, change views, code review
    * F) **Performance/Indexing**: Memory, caches, plugin diet
    * G) **Remote/Docker/DB**: Remote Debug, Docker, Database Tools
* How to use

  * ▷ Procedure

    * → **Indicate the category** of your question on the **first line**.
    * → Attach the Section B template + Section E reproducible example.

> **Key takeaway:** Good labeling alone can shrink the search space for answers by one-third.

---

## **D. Summary of Common Gotchas**

* Overview

  * ▷ SDK/JDK

    * Keep **Project SDK** (Project Structure) and **Gradle JVM** (Settings > Gradle) on the **same major version**.
    * Align **Language level** with compile target (e.g., Java 21).
  * ▷ Gradle

    * Enforce **Wrapper (`gradlew`)** to align versions across the team.
    * Declare Gradle Daemon/JVM options in `gradle.properties`.
  * ▷ Annotation Processing

    * With Lombok: Install **Lombok plugin** and check `Settings > Build > Compiler > Annotation Processors > Enable`.
  * ▷ Run/Debug

    * Separate **Application / Test / Gradle Task** into **distinct configurations**.
  * ▷ Indexing/Performance

    * Turn off unnecessary plugins, adjust **Memory Settings**, and **Exclude** large folders (e.g., `node_modules`).

> **Key takeaway:** The trio “Project SDK = Gradle JVM = Language level” plus proper Lombok config fixes 70% of chronic issues.

---

## **E. Minimal Reproducible Example (fully runnable sample)**

* How to use

  * ▷ Preparation

    * → Targeting **Gradle + Java 21** (Windows).
    * → Save the files below into a new folder → **Open** in IntelliJ (detected as a Gradle project).

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

> Run procedure (GUI):
>
> 1. `File > Open > (project folder)` → Gradle auto-detection
> 2. In the right-hand Gradle tool window, double-click `Tasks > application > run` → confirm `Hello IntelliJ!` in console
> 3. In top `Run` menu, `Edit Configurations…` → confirm an `Application` config was created
> 4. Run `Run > Run 'App'` / `Run > Debug 'App'`
> 5. Run `Run > Run Tests` or right-hand Gradle `verification > test`

> **Key takeaway:** “Wrapper + Toolchain + JUnit5” builds a consistent, reproducible environment.

---

## **F. GUI Procedures (core scenarios)**

* How to use

  * ▷ Preparation

    * → **Register Project SDK:** `File > Project Structure > SDKs > Add JDK`
    * → **Set Project SDK:** `Project Structure > Project > SDK = JDK 21`
    * → **Unify Gradle JVM:** `File > Settings > Build, Execution, Deployment > Build Tools > Gradle > Gradle JVM = JDK 21`
  * ▷ Procedure

    * → **If using Lombok**

      * Install `File > Settings > Plugins > Marketplace > Lombok`
      * Check `Settings > Build > Compiler > Annotation Processors > Enable`
    * → **Code Style/Formatter**

      * `File > Settings > Editor > Code Style > Java` → save/share a project scheme
      * Ensure `.editorconfig` is enabled (consistent on save)
    * → **Keymap/Shortcuts**

      * `File > Settings > Keymap` → choose `VS Code` or `IntelliJ`
    * → **Performance tuning**

      * `Help > Change Memory Settings` to raise IDE heap
      * If indexing is slow, use `File > Invalidate Caches…` (requires restart)
      * Mark large folders as `Mark Directory as > Excluded`

> **Note:** The **full error text** from the Gradle/Maven console is the key clue to resolution.

---

## **G. Problem Collection & Diagnostic Bundle Spec (Windows)**

* Overview

  * ▷ What to collect

    * `idea.log`, `build scans` URL (if any), Gradle console logs, and 3 screenshots (Project Structure, Gradle, Run Config)
  * ▷ PowerShell collection script (paste and run → creates a text file)

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

> **Key takeaway:** Without the “logs + versions + GUI captures” trio, resolution speed drops dramatically.

---

## **H. IntelliJ Question Prompt Template (for higher accuracy)**

```md
[Role] You are an IntelliJ IDEA expert and a build tool (Gradle/Maven) consultant.
[Goal] Reproduce the issue with my repro project and logs, and provide GUI-based fix steps.
[Environment] OS/IDE Edition/Version, Project SDK, Gradle JVM, Wrapper, plugin list
[Project] Language/Framework/Toolchain, JUnit version, Annotation Processing policy
[Symptom] Expected vs. actual (2–3 sentences), exact GUI path where it occurs
[Deliverables] 1) Root cause 2) Fix steps (with GUI paths) 3) Alternatives (both Gradle/Maven) 4) Recurrence-prevention checklist
```

> **Key takeaway:** Filling the five elements “Role · Environment · Project · Symptom · Deliverables” skyrockets answer accuracy.

---

## **I. Alternative Scenarios (2–3 options)**

* **Option A: Standardize on Gradle (Recommended)**

  * Lock Wrapper, control JDK via Toolchain, guarantee the same runtime as CI
* **Option B: Simplify with Maven**

  * Compatible with legacy in-house setups, easier configuration (beware multi-module/version alignment)
* **Option C: Community Edition + Lightweight Plugins**

  * Better performance by removing unnecessary plugins; replace Web/DB features with external tools

> **Key takeaway:** “Gradle Wrapper + Toolchain” yields the strongest team consistency and reproducibility.

---

## **Checklist (Numbered)**

1. Declare **Edition/Version/JDK/Wrapper/Plugins** in the pre-brief
2. Verify **Project SDK = Gradle JVM = Language level** consistency
3. **Import via Gradle Wrapper** (Open as Project) and capture build scan/console logs
4. Check **Annotation Processing/Lombok** settings (plugin + Enable)
5. Split and verify **Run/Debug/Test** as separate configurations
6. Apply **Code Style/Keymap**, commit `.editorconfig`
7. Ensure performance with **Memory Settings / Excluded folders / plugin diet**
8. Submit the **problem bundle** (logs + screenshots + repro project) with the question

---

