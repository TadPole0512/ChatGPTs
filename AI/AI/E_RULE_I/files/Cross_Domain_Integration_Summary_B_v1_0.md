# 🔗 도메인 통합 & 실행 패턴 핵심 가이드 v1.0 (요약판 B)

## 📋 목적
여러 도메인을 연결하여 종단간(E2E) 솔루션 구축

---

## 🎯 A. 3가지 통합 타입

### 타입 1: 수직 통합 (Full-Stack)
```yaml
구조:
  Frontend (React) 
    ↕ REST API
  Backend (Spring Boot)
    ↕ JDBC
  Database (PostgreSQL)
    ↕ Volume
  Infrastructure (Docker/K8s)

핵심 원칙:
  - 계약 우선 (API 스펙 먼저 정의)
  - 어댑터 레이어 (도메인 간 변환 분리)
  - 계층별 독립 테스트
```

### 타입 2: 수평 통합 (DevOps Pipeline)
```yaml
흐름:
  GitLab → (Webhook) → Jenkins
    → (Build) → Docker Registry
    → (Deploy) → Kubernetes
    → (Monitor) → Prometheus

연결 방식:
  - Webhook 이벤트
  - API 호출
  - GitOps (선언적 배포)
```

### 타입 3: 데이터 파이프라인
```yaml
단계:
  추출 (DB 쿼리)
    → 정제 (NULL/이상값 처리)
    → 분석 (통계/ML)
    → 시각화 (차트 생성)
    → 보고서 (Excel/PDF)

자동화:
  - 스케줄링 (daily at 09:00)
  - 이메일 전송
  - 버전 관리
```

---

## 🏗️ B. 통합 설계 패턴

### 패턴 1: 계약 우선 설계
```yaml
순서:
  1. OpenAPI/GraphQL 스펙 작성
  2. Mock 서버로 프론트 개발
  3. 백엔드 실제 구현
  4. 통합 테스트

이점:
  - 병렬 개발 가능
  - 인터페이스 안정성
  - 테스트 용이
```

### 패턴 2: 어댑터 레이어
```python
# 도메인 간 변환 전담
class DatabaseAdapter:
    @staticmethod
    def to_api_response(db_row: dict) -> dict:
        return {
            "userId": db_row["user_id"],      # snake_case → camelCase
            "createdAt": db_row["created_at"].isoformat()
        }

class ReportAdapter:
    @staticmethod
    def to_excel(df: pd.DataFrame) -> dict:
        return {
            "summary": df.describe().to_dict(),
            "details": df.to_dict('records')
        }
```

---

## 🔄 C. 실행 순서 (Full-Stack 예시)

### Step 1: 아키텍처 설계 (30분)
```markdown
## 시스템 구조
React Frontend (Port 3000)
    ↓ HTTP REST
Spring Boot (Port 8080)
    ↓ JDBC
PostgreSQL (Port 5432)

## 통합 포인트
- React → Spring: JWT 인증
- Spring → DB: JPA/Hibernate
```

### Step 2: DB 우선 구현 (40분)
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    created_by INT REFERENCES users(id)
);

-- 검증
SELECT u.username, COUNT(p.id) as product_count
FROM users u
LEFT JOIN products p ON u.id = p.created_by
GROUP BY u.id;
```

### Step 3: Backend API (60분)
```java
@RestController
@RequestMapping("/api/products")
public class ProductController {
    @GetMapping
    public ResponseEntity<Page<ProductDTO>> getProducts(
        @RequestParam(required = false) String search,
        @PageableDefault(size = 20) Pageable pageable
    ) {
        Page<Product> products = productService.searchProducts(search, pageable);
        return ResponseEntity.ok(products.map(this::toDTO));
    }
}
```

### Step 4: Frontend (50분)
```jsx
// API Client
const api = axios.create({
    baseURL: 'http://localhost:8080/api'
});

// Component
function ProductList() {
    const [products, setProducts] = useState([]);
    
    useEffect(() => {
        api.get('/products')
            .then(res => setProducts(res.data.content));
    }, []);
    
    return (
        <table>
            {products.map(p => (
                <tr key={p.id}>
                    <td>{p.name}</td>
                    <td>{p.price.toLocaleString()}원</td>
                </tr>
            ))}
        </table>
    );
}
```

### Step 5: 통합 테스트 (30분)
```javascript
// E2E 테스트 (Playwright)
test('전체 플로우', async ({ page }) => {
    await page.goto('http://localhost:3000');
    await page.fill('[name="search"]', '노트북');
    await page.click('button:has-text("검색")');
    
    const response = await page.waitForResponse(
        res => res.url().includes('/api/products')
    );
    expect(response.status()).toBe(200);
});
```

---

## 🧪 D. 3단계 테스트 전략

### Level 1: 단위 테스트
```python
# 각 도메인 독립 테스트
def test_product_service():
    product = Product(name="Test", price=10000)
    assert product.calculate_discount(10) == 9000
```

### Level 2: 통합 테스트
```java
@SpringBootTest
class ProductIntegrationTest {
    @Test
    void testGetProducts() {
        mockMvc.perform(get("/api/products"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content[0].name").exists());
    }
}
```

### Level 3: E2E 테스트
```javascript
// 전체 사용자 플로우
test('검색 → 상세 → 구매', async ({ page }) => {
    // 실제 사용자 시나리오 재현
});
```

---

## 📦 E. 실전 템플릿

### GitLab + Jenkins 배포 파이프라인
```groovy
// Jenkinsfile
pipeline {
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t myapp:${GIT_COMMIT} .'
            }
        }
        stage('Test') {
            steps {
                sh 'docker run --rm myapp:${GIT_COMMIT} npm test'
            }
        }
        stage('Deploy') {
            steps {
                sh 'kubectl set image deployment/myapp myapp=registry/myapp:${GIT_COMMIT}'
                sh 'kubectl rollout status deployment/myapp'
            }
        }
    }
}
```

### 데이터 분석 자동화
```python
# 일일 보고서 파이프라인
def run_daily_report():
    # 1. 추출
    df = extract_sales_data(start_date, end_date)
    
    # 2. 분석
    df_clean, summary = clean_and_analyze(df)
    
    # 3. 시각화
    create_charts(df_clean, summary)
    
    # 4. 보고서
    generate_excel_report(df_clean, summary, 'report.xlsx')
    
    # 5. 전송
    send_email_with_attachment('report.xlsx', ['manager@example.com'])

# 스케줄링
schedule.every().day.at("09:00").do(run_daily_report)
```

---

## ✅ F. 통합 체크리스트

### 설계 단계
- [ ] 도메인 경계 정의
- [ ] API 계약 작성 (OpenAPI)
- [ ] 데이터 흐름 다이어그램
- [ ] 어댑터 레이어 설계

### 구현 단계
- [ ] 각 도메인 독립 구현
- [ ] Mock으로 먼저 테스트
- [ ] 에러 핸들링 통일
- [ ] 로깅 포인트 추가

### 테스트 단계
- [ ] 단위 테스트 (도메인별)
- [ ] 통합 테스트 (2개 도메인)
- [ ] E2E 테스트 (전체)
- [ ] 성능 테스트 (병목 식별)

### 배포 단계
- [ ] 환경별 설정 분리
- [ ] CI/CD 파이프라인
- [ ] 롤백 계획
- [ ] 모니터링 설정

---

## 🎯 핵심 요약

**통합 3타입**:
- 수직: Frontend ↔ Backend ↔ DB (계층별)
- 수평: GitLab ↔ Jenkins ↔ K8s (시스템 연동)
- 파이프라인: 추출 → 분석 → 시각화 → 보고서

**설계 2원칙**:
1. **계약 우선**: API 스펙 먼저, 구현은 나중
2. **어댑터 분리**: 도메인 간 변환 로직 격리

**테스트 3단계**:
1. 단위 (독립) → 2. 통합 (2개) → 3. E2E (전체)

**성공 기준**:
- 각 도메인 독립 교체 가능
- 에러가 경계 넘지 않음
- E2E 통과율 ≥90%

---

**적용 시기**: 2개 이상 도메인이 연결된 모든 프로젝트

**예상 효과**: 병렬 개발 가능, 유지보수 용이, 테스트 자동화

**대표 시나리오**:
- Spring Boot + PostgreSQL + React 쇼핑몰
- GitLab + Jenkins + K8s 배포 자동화
- DB 쿼리 → Pandas 분석 → Excel 보고서
