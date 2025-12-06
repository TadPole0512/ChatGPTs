# ✅ AI 답변 품질 보증 프레임워크 v1.0

## 📋 핵심 원칙

**목적**: AI가 생성한 답변의 품질을 자동으로 평가하고 개선하는 실행 프로토콜

**적용 대상**: 모든 AI 생성 콘텐츠 (코드, 문서, 분석, 설계, 가이드 등)

**핵심 접근법**: 다차원 평가 → 자가 검증 → 개선 제안 → 재생성 루프

---

## 🎯 A. 품질 평가 차원 (6-Dimension Framework)

### 차원 1: 정확성 (Accuracy) - 가중치 25%

```yaml
평가 기준:
  사실 정확도:
    - 날짜/숫자/통계 검증
    - 기술 용어 정확성
    - API/문법 정확성
  
  논리 일관성:
    - 전제→결론 연결
    - 모순 부재
    - 인과관계 타당성

측정 방법:
  자동 검증:
    - URL HTTP 상태 확인 (200 OK)
    - 코드 구문 검사 (Linter)
    - 수식 계산 재확인
  
  수동 검증:
    - 전문가 리뷰
    - 사용자 피드백

점수 산정:
  100점 = 모든 사실 검증됨 + 논리 완벽
  80점 = 1-2개 경미한 오류
  60점 = 주요 오류 1개
  <60점 = 재작성 필요
```

**자동 검증 스크립트 예시**:

```python
def verify_accuracy(content: str, metadata: dict) -> dict:
    """정확성 자동 검증"""
    
    score = 100
    issues = []
    
    # 1. URL 검증
    urls = extract_urls(content)
    for url in urls:
        if not check_http_status(url):
            score -= 5
            issues.append(f"Dead link: {url}")
    
    # 2. 코드 검증 (Python 예시)
    code_blocks = extract_code_blocks(content, language='python')
    for code in code_blocks:
        lint_result = run_pylint(code)
        if lint_result['errors'] > 0:
            score -= 10
            issues.append(f"Syntax error in code block")
    
    # 3. 수치 검증
    formulas = extract_formulas(content)
    for formula in formulas:
        if not verify_calculation(formula):
            score -= 15
            issues.append(f"Calculation error: {formula}")
    
    return {
        'dimension': 'accuracy',
        'score': max(0, score),
        'weight': 0.25,
        'issues': issues
    }
```

---

### 차원 2: 완성도 (Completeness) - 가중치 20%

```yaml
평가 기준:
  필수 요소 포함:
    - 사용자 질문의 모든 부분 답변
    - 약속한 산출물 제공
    - 검증 단계 포함
  
  깊이:
    - 피상적 vs 상세 설명
    - 예시/샘플 제공
    - 대안 제시

체크리스트:
  - [ ] 질문의 모든 항목 다룸
  - [ ] 코드는 실행 가능
  - [ ] 검증 방법 제공
  - [ ] 트러블슈팅 포함
  - [ ] 다음 단계 안내
```

**자동 완성도 검사**:

```python
def check_completeness(content: str, user_query: str, checklist: list) -> dict:
    """완성도 검증"""
    
    score = 0
    max_score = len(checklist) * 20  # 항목당 20점
    
    completed_items = []
    missing_items = []
    
    for item in checklist:
        if is_item_addressed(content, item):
            score += 20
            completed_items.append(item)
        else:
            missing_items.append(item)
    
    # 보너스: 추가 가치 제공 시
    if has_examples(content):
        score += 10
    if has_alternatives(content):
        score += 10
    
    completeness_pct = (score / max_score) * 100
    
    return {
        'dimension': 'completeness',
        'score': min(100, completeness_pct),
        'weight': 0.20,
        'completed': completed_items,
        'missing': missing_items
    }
```

---

### 차원 3: 명확성 (Clarity) - 가중치 15%

```yaml
평가 기준:
  가독성:
    - Flesch-Kincaid 점수 (목표: 60-70)
    - 문장 길이 (평균 15-25 단어)
    - 전문 용어 설명 여부
  
  구조화:
    - 제목 계층 (H1-H4)
    - 리스트/테이블 활용
    - 시각적 요소 (이모지, 코드블록)

측정 도구:
  - textstat 라이브러리 (가독성 점수)
  - 문장 길이 통계
  - 구조 분석 (마크다운 파싱)
```

**가독성 자동 평가**:

```python
import textstat

def assess_clarity(content: str) -> dict:
    """명확성 평가"""
    
    # 1. 가독성 점수
    fk_score = textstat.flesch_kincaid_grade(content)
    
    # 목표: 중고등학생 수준 (8-12학년)
    if 8 <= fk_score <= 12:
        readability_score = 100
    elif fk_score < 8:
        readability_score = 80  # 너무 쉬움
    else:
        readability_score = max(0, 100 - (fk_score - 12) * 5)
    
    # 2. 구조 점수
    structure_elements = {
        'headings': len(extract_headings(content)),
        'lists': len(extract_lists(content)),
        'code_blocks': len(extract_code_blocks(content)),
        'tables': len(extract_tables(content))
    }
    
    structure_score = min(100, sum(structure_elements.values()) * 10)
    
    # 최종 점수 (가독성 70%, 구조 30%)
    final_score = readability_score * 0.7 + structure_score * 0.3
    
    return {
        'dimension': 'clarity',
        'score': final_score,
        'weight': 0.15,
        'fk_grade': fk_score,
        'structure': structure_elements
    }
```

---

### 차원 4: 실행 가능성 (Actionability) - 가중치 20%

```yaml
평가 기준:
  즉시 적용 가능:
    - 복사-붙여넣기 가능한 코드
    - 명확한 단계별 지침
    - 필수 도구/환경 명시
  
  재현 가능성:
    - 동일한 입력 → 동일한 결과
    - 환경 의존성 최소화
    - 에러 시나리오 대응

테스트 방법:
  - 코드 실행 시뮬레이션
  - 단계별 검증 가능 여부
  - 외부 의존성 확인
```

**실행 가능성 검증**:

```python
def validate_actionability(content: str, content_type: str) -> dict:
    """실행 가능성 검증"""
    
    score = 0
    issues = []
    
    if content_type == 'code':
        # 1. 코드 완전성 (import 포함, 함수 정의 완전)
        code = extract_code_blocks(content)[0]
        
        if has_all_imports(code):
            score += 30
        else:
            issues.append("Missing imports")
        
        if is_syntactically_correct(code):
            score += 30
        else:
            issues.append("Syntax errors")
        
        # 2. 실행 테스트
        try:
            exec_result = safe_execute(code, timeout=5)
            if exec_result['success']:
                score += 40
            else:
                issues.append(f"Runtime error: {exec_result['error']}")
        except Exception as e:
            issues.append(f"Execution failed: {str(e)}")
    
    elif content_type == 'guide':
        # 가이드의 경우: 단계별 검증 가능성
        steps = extract_steps(content)
        verifiable_steps = [s for s in steps if has_verification(s)]
        
        score = (len(verifiable_steps) / len(steps)) * 100 if steps else 0
    
    return {
        'dimension': 'actionability',
        'score': score,
        'weight': 0.20,
        'issues': issues
    }
```

---

### 차원 5: 안전성 (Safety) - 가중치 10%

```yaml
평가 기준:
  보안 위험:
    - 하드코딩된 비밀번호/토큰
    - SQL Injection 취약점
    - XSS/CSRF 위험
  
  운영 위험:
    - 데이터 손실 위험 작업
    - 프로덕션 영향 명령어
    - 롤백 불가능한 작업

체크 항목:
  - [ ] 민감정보 노출 없음
  - [ ] 위험 작업에 경고 포함
  - [ ] 백업/롤백 방법 제시
  - [ ] 권한 최소화 원칙
```

**보안 자동 검사**:

```python
import re

def check_safety(content: str) -> dict:
    """안전성 검증"""
    
    score = 100
    warnings = []
    critical_issues = []
    
    # 1. 민감정보 패턴 탐지
    sensitive_patterns = {
        'password': r'password\s*=\s*["\'](?!YOUR_|CHANGE_ME)[^"\']+["\']',
        'api_key': r'api[_-]?key\s*=\s*["\'][^"\']{20,}["\']',
        'token': r'token\s*=\s*["\'][^"\']{30,}["\']',
        'connection_string': r'(mongodb|postgresql|mysql)://[^@]+:[^@]+@'
    }
    
    for name, pattern in sensitive_patterns.items():
        if re.search(pattern, content, re.IGNORECASE):
            score -= 20
            critical_issues.append(f"Exposed {name}")
    
    # 2. 위험 명령어 탐지
    dangerous_commands = [
        'DROP DATABASE', 'TRUNCATE', 'rm -rf /',
        'DELETE FROM', 'sudo rm', 'chmod 777'
    ]
    
    for cmd in dangerous_commands:
        if cmd.lower() in content.lower():
            if not has_warning_near(content, cmd):
                score -= 10
                warnings.append(f"Dangerous command without warning: {cmd}")
    
    # 3. 보안 베스트 프랙티스 확인
    best_practices = {
        'parameterized_query': r'PreparedStatement|bind|placeholder',
        'input_validation': r'validate|sanitize|escape',
        'https': r'https://'
    }
    
    for practice, pattern in best_practices.items():
        if re.search(pattern, content, re.IGNORECASE):
            score += 5  # 보너스
    
    return {
        'dimension': 'safety',
        'score': max(0, min(100, score)),
        'weight': 0.10,
        'critical': critical_issues,
        'warnings': warnings
    }
```

---

### 차원 6: 효율성 (Efficiency) - 가중치 10%

```yaml
평가 기준:
  간결성:
    - 불필요한 반복 없음
    - 핵심만 전달
    - 적절한 길이 (너무 짧지도, 길지도 않음)
  
  성능:
    - 알고리즘 복잡도 (O(n) vs O(n²))
    - 리소스 사용 최적화
    - 캐싱/인덱싱 활용

측정:
  - 텍스트 길이 대비 정보 밀도
  - 코드 복잡도 (Cyclomatic Complexity)
  - 예상 실행 시간
```

**효율성 평가**:

```python
def assess_efficiency(content: str, content_type: str) -> dict:
    """효율성 평가"""
    
    if content_type == 'code':
        code = extract_code_blocks(content)[0]
        
        # 1. 복잡도 분석
        complexity = calculate_cyclomatic_complexity(code)
        
        if complexity <= 10:
            complexity_score = 100
        elif complexity <= 20:
            complexity_score = 80
        else:
            complexity_score = max(0, 100 - (complexity - 20) * 3)
        
        # 2. 성능 패턴 체크
        has_optimization = any([
            'cache' in code.lower(),
            'index' in code.lower(),
            're.compile' in code,  # 정규표현식 미리 컴파일
            'lru_cache' in code
        ])
        
        optimization_score = 100 if has_optimization else 70
        
        final_score = (complexity_score + optimization_score) / 2
    
    else:  # 텍스트 콘텐츠
        word_count = len(content.split())
        info_density = calculate_info_density(content)
        
        # 목표: 200-2000 단어, 정보 밀도 0.3 이상
        if 200 <= word_count <= 2000 and info_density >= 0.3:
            final_score = 100
        else:
            final_score = 70
    
    return {
        'dimension': 'efficiency',
        'score': final_score,
        'weight': 0.10
    }
```

---

## 📊 B. 종합 품질 점수 계산

### 가중 평균 산정

```python
def calculate_overall_quality(evaluations: list) -> dict:
    """6차원 평가 결과를 종합"""
    
    total_score = 0
    details = {}
    
    for eval_result in evaluations:
        dimension = eval_result['dimension']
        score = eval_result['score']
        weight = eval_result['weight']
        
        weighted_score = score * weight
        total_score += weighted_score
        
        details[dimension] = {
            'score': score,
            'weight': weight,
            'contribution': weighted_score
        }
    
    # 등급 부여
    if total_score >= 90:
        grade = 'A (우수)'
    elif total_score >= 80:
        grade = 'B (양호)'
    elif total_score >= 70:
        grade = 'C (보통)'
    elif total_score >= 60:
        grade = 'D (미흡)'
    else:
        grade = 'F (불합격)'
    
    return {
        'overall_score': round(total_score, 2),
        'grade': grade,
        'details': details,
        'pass': total_score >= 70
    }
```

---

## 🔄 C. 자가 개선 루프

### 자동 개선 제안 생성

```python
def generate_improvement_suggestions(quality_report: dict) -> list:
    """품질 보고서 기반 개선 제안"""
    
    suggestions = []
    details = quality_report['details']
    
    # 차원별 개선 제안
    for dimension, metrics in details.items():
        if metrics['score'] < 80:
            if dimension == 'accuracy':
                suggestions.append({
                    'priority': 'HIGH',
                    'dimension': '정확성',
                    'issue': f"정확성 점수 {metrics['score']}점",
                    'action': '모든 URL/코드/수식 검증 필요',
                    'steps': [
                        'URL HTTP 상태 확인',
                        'Linter로 코드 검증',
                        '수치 계산 재확인'
                    ]
                })
            
            elif dimension == 'completeness':
                suggestions.append({
                    'priority': 'HIGH',
                    'dimension': '완성도',
                    'issue': f"완성도 점수 {metrics['score']}점",
                    'action': '누락된 항목 추가',
                    'steps': [
                        '사용자 질문의 모든 부분 다룸',
                        '검증 단계 포함',
                        '예시/샘플 추가'
                    ]
                })
            
            elif dimension == 'clarity':
                suggestions.append({
                    'priority': 'MEDIUM',
                    'dimension': '명확성',
                    'issue': f"가독성 점수 {metrics['score']}점",
                    'action': '구조화 및 시각 요소 강화',
                    'steps': [
                        '제목 계층 명확히 (H1-H4)',
                        '리스트/테이블로 정보 정리',
                        '코드블록에 언어 명시'
                    ]
                })
            
            elif dimension == 'actionability':
                suggestions.append({
                    'priority': 'HIGH',
                    'dimension': '실행 가능성',
                    'issue': f"실행 가능성 {metrics['score']}점",
                    'action': '코드 완전성 확보',
                    'steps': [
                        '모든 import 포함',
                        '전체 실행 가능한 예제 제공',
                        '검증 명령어 추가'
                    ]
                })
            
            elif dimension == 'safety':
                suggestions.append({
                    'priority': 'CRITICAL',
                    'dimension': '안전성',
                    'issue': f"안전성 점수 {metrics['score']}점",
                    'action': '보안 취약점 제거',
                    'steps': [
                        '하드코딩된 비밀번호 제거',
                        '위험 명령어에 경고 추가',
                        '권한 최소화 적용'
                    ]
                })
    
    # 우선순위 정렬
    priority_order = {'CRITICAL': 0, 'HIGH': 1, 'MEDIUM': 2, 'LOW': 3}
    suggestions.sort(key=lambda x: priority_order[x['priority']])
    
    return suggestions
```

---

## 📋 D. 사용자 친화적 품질 보고서

### 보고서 템플릿

```python
def generate_quality_report(content: str, evaluations: list) -> str:
    """Markdown 형식 품질 보고서 생성"""
    
    overall = calculate_overall_quality(evaluations)
    suggestions = generate_improvement_suggestions(overall)
    
    report = f"""
# ✅ AI 답변 품질 보고서

## 📊 종합 점수

**총점**: {overall['overall_score']}/100 ({overall['grade']})

{'✅ **합격** (70점 이상)' if overall['pass'] else '⚠️ **재작성 권장** (70점 미만)'}

---

## 📈 차원별 평가

| 차원 | 점수 | 가중치 | 기여도 | 상태 |
|------|------|--------|--------|------|
"""
    
    for dim, metrics in overall['details'].items():
        status = '✅' if metrics['score'] >= 80 else '⚠️' if metrics['score'] >= 70 else '❌'
        report += f"| {dim} | {metrics['score']:.1f} | {metrics['weight']*100:.0f}% | {metrics['contribution']:.1f} | {status} |\n"
    
    report += "\n---\n\n## 🔍 개선 제안\n\n"
    
    if not suggestions:
        report += "🎉 **개선 사항 없음** - 모든 차원에서 우수한 품질입니다!\n"
    else:
        for i, sug in enumerate(suggestions, 1):
            priority_emoji = {
                'CRITICAL': '🚨',
                'HIGH': '⚠️',
                'MEDIUM': '💡',
                'LOW': 'ℹ️'
            }[sug['priority']]
            
            report += f"""
### {i}. {priority_emoji} {sug['dimension']} ({sug['priority']})

**문제**: {sug['issue']}

**조치**: {sug['action']}

**단계**:
"""
            for step in sug['steps']:
                report += f"- [ ] {step}\n"
            
            report += "\n"
    
    report += """
---

## 📌 다음 단계

"""
    
    if overall['pass']:
        report += """
✅ **승인 권장** - 사용자에게 제공 가능한 품질입니다.

선택 사항:
- 개선 제안 사항을 반영하면 더욱 우수한 품질 달성 가능
- 사용자 피드백 수집 후 지속 개선
"""
    else:
        report += """
⚠️ **재작성 필요** - 다음 항목을 개선한 후 재평가하세요.

필수 조치:
1. 위의 HIGH/CRITICAL 개선 사항 모두 반영
2. 품질 검증 다시 실행
3. 70점 이상 달성 시 승인
"""
    
    return report
```

---

## 🤖 E. 자동화된 품질 보증 파이프라인

### 전체 워크플로우

```python
class QualityAssurancePipeline:
    """AI 답변 품질 보증 파이프라인"""
    
    def __init__(self):
        self.evaluators = [
            verify_accuracy,
            check_completeness,
            assess_clarity,
            validate_actionability,
            check_safety,
            assess_efficiency
        ]
    
    def run(self, content: str, metadata: dict) -> dict:
        """전체 품질 검증 실행"""
        
        print("🔍 품질 검증 시작...")
        
        # 1. 6차원 평가 실행
        evaluations = []
        for evaluator in self.evaluators:
            try:
                result = evaluator(content, **metadata)
                evaluations.append(result)
                print(f"  ✓ {result['dimension']}: {result['score']:.1f}점")
            except Exception as e:
                print(f"  ✗ {evaluator.__name__} 실패: {e}")
        
        # 2. 종합 점수 계산
        overall = calculate_overall_quality(evaluations)
        
        # 3. 보고서 생성
        report_md = generate_quality_report(content, evaluations)
        
        # 4. 자동 개선 (점수 70 미만 시)
        improved_content = content
        if not overall['pass']:
            print("\n⚠️ 품질 기준 미달 - 자동 개선 시도...")
            improved_content = self.auto_improve(content, overall)
        
        print(f"\n✅ 최종 점수: {overall['overall_score']:.1f}/100 ({overall['grade']})")
        
        return {
            'original_score': overall['overall_score'],
            'report': report_md,
            'improved_content': improved_content,
            'pass': overall['pass']
        }
    
    def auto_improve(self, content: str, quality_report: dict) -> str:
        """자동 개선 시도"""
        
        suggestions = generate_improvement_suggestions(quality_report)
        improved = content
        
        for sug in suggestions:
            if sug['dimension'] == '정확성':
                # URL 수정, 코드 Linting 등
                improved = fix_urls(improved)
                improved = fix_code_syntax(improved)
            
            elif sug['dimension'] == '완성도':
                # 누락 섹션 추가
                improved = add_missing_sections(improved, sug['steps'])
            
            elif sug['dimension'] == '명확성':
                # 구조화 개선
                improved = improve_structure(improved)
            
            elif sug['dimension'] == '안전성':
                # 민감정보 마스킹
                improved = mask_sensitive_info(improved)
        
        return improved

# 사용 예시
if __name__ == '__main__':
    pipeline = QualityAssurancePipeline()
    
    ai_response = """
    [AI가 생성한 답변 텍스트]
    """
    
    result = pipeline.run(
        content=ai_response,
        metadata={
            'content_type': 'code',
            'user_query': '...',
            'checklist': [...]
        }
    )
    
    # 보고서 저장
    with open('quality_report.md', 'w') as f:
        f.write(result['report'])
    
    # 개선된 답변 저장
    if not result['pass']:
        with open('improved_response.md', 'w') as f:
            f.write(result['improved_content'])
```

---

## 📊 F. 품질 메트릭 대시보드

### 시계열 추적

```python
import pandas as pd
import matplotlib.pyplot as plt

def track_quality_over_time(history: list):
    """품질 점수 시계열 추적"""
    
    df = pd.DataFrame(history)
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    
    dimensions = ['accuracy', 'completeness', 'clarity', 
                  'actionability', 'safety', 'efficiency']
    
    for i, dim in enumerate(dimensions):
        ax = axes[i // 3, i % 3]
        ax.plot(df['timestamp'], df[dim], marker='o')
        ax.axhline(y=80, color='g', linestyle='--', label='목표 (80점)')
        ax.set_title(f'{dim.capitalize()}')
        ax.set_ylabel('점수')
        ax.legend()
    
    plt.tight_layout()
    plt.savefig('quality_trends.png')
    print("✅ 품질 트렌드 차트 저장: quality_trends.png")
```

---

## ✅ G. 최종 체크리스트

### 답변 제출 전 필수 확인

```markdown
## 🔍 품질 보증 체크리스트

### 1️⃣ 정확성 (25%)
- [ ] 모든 URL이 접근 가능 (HTTP 200)
- [ ] 코드가 Linter 통과
- [ ] 수치/날짜가 검증됨
- [ ] 논리적 모순 없음

### 2️⃣ 완성도 (20%)
- [ ] 질문의 모든 부분 답변
- [ ] 검증 단계 포함
- [ ] 예시/샘플 제공
- [ ] 대안 제시 (2개 이상)

### 3️⃣ 명확성 (15%)
- [ ] Flesch-Kincaid 점수 60-70
- [ ] 제목 계층 명확 (H1-H4)
- [ ] 시각 요소 활용 (리스트/테이블/코드블록)
- [ ] 전문 용어 설명

### 4️⃣ 실행 가능성 (20%)
- [ ] 코드가 복사-붙여넣기 가능
- [ ] 모든 import/의존성 포함
- [ ] 검증 명령어 제공
- [ ] 실제 실행 테스트 완료

### 5️⃣ 안전성 (10%)
- [ ] 민감정보 노출 없음
- [ ] 위험 명령어에 경고 표시
- [ ] 보안 베스트 프랙티스 적용
- [ ] 롤백 방법 제시

### 6️⃣ 효율성 (10%)
- [ ] 불필요한 반복 없음
- [ ] 적절한 길이 (200-2000 단어)
- [ ] 코드 복잡도 낮음 (≤20)
- [ ] 성능 최적화 고려

---

## 📌 최종 승인

**총점**: _____ / 100
**등급**: _____
**합격 여부**: [ ] 합격 (≥70) / [ ] 불합격 (<70)

**승인자**: _____
**날짜**: _____
```

---

## 🎯 H. 핵심 요약

**품질 보증 6차원**:
1. **정확성** (25%): 사실 검증 + 논리 일관성
2. **완성도** (20%): 모든 요소 포함 + 깊이
3. **명확성** (15%): 가독성 + 구조화
4. **실행 가능성** (20%): 즉시 적용 가능 + 재현 가능
5. **안전성** (10%): 보안 + 운영 위험 최소화
6. **효율성** (10%): 간결성 + 성능

**자동화 파이프라인**:
- 6차원 자동 평가 → 종합 점수 계산 → 개선 제안 생성 → 자동 개선 시도

**합격 기준**:
- 총점 ≥70점
- 안전성 ≥60점 (필수)
- 정확성 ≥70점 (필수)

**개선 루프**:
1. 품질 검증 실행
2. 미달 시 자동 개선
3. 재검증
4. 합격 시 승인, 불합격 시 반복

이 프레임워크를 활용하면 **AI 답변 품질을 객관적으로 측정하고 지속적으로 개선**할 수 있습니다! ✅
