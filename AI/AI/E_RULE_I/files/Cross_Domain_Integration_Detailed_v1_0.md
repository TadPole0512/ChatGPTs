# 🔗 도메인 간 통합 시나리오 실행 지침 v1.0

## 📋 핵심 원칙

**목적**: 여러 도메인 지식을 연결하여 종단간(End-to-End) 솔루션을 설계·구현하는 AI 실행 프로토콜

**적용 대상**: 서버+DB+웹개발, GitLab+IntelliJ+배포, 데이터 분석+시각화+보고서 등 2개 이상 도메인이 결합된 작업

**핵심 접근법**: 도메인 식별 → 인터페이스 설계 → 계층별 구현 → 통합 테스트 → 엔드투엔드 검증

---

## 🎯 A. 통합 시나리오 분류 체계

### 타입 1: 수직 통합 (Vertical Integration)
**특징**: 동일 기술 스택에서 계층별 구현 (예: Spring Boot + PostgreSQL + React)

```yaml
레이어 구조:
  L1_프론트엔드:
    - React/Vue/Angular
    - API 클라이언트
  
  L2_백엔드:
    - Spring Boot/Node.js/Django
    - 비즈니스 로직
  
  L3_데이터베이스:
    - PostgreSQL/MongoDB
    - 스키마 설계
  
  L4_인프라:
    - Docker/K8s
    - CI/CD 파이프라인

통합 포인트:
  - L1↔L2: REST API / GraphQL
  - L2↔L3: ORM / SQL
  - L3↔L4: Volume Mount / Service
```

### 타입 2: 수평 통합 (Horizontal Integration)
**특징**: 동일 계층 내 여러 시스템 연동 (예: GitLab + Jenkins + SonarQube)

```yaml
시스템 구성:
  S1_버전관리: GitLab
  S2_빌드: Jenkins
  S3_품질검사: SonarQube
  S4_배포: ArgoCD
  
통합 방식:
  - Webhook: GitLab → Jenkins (Push 이벤트)
  - API: Jenkins → SonarQube (품질 게이트)
  - GitOps: Jenkins → ArgoCD (배포 트리거)
```

### 타입 3: 데이터 파이프라인 (Data Pipeline)
**특징**: 데이터 수집→처리→분석→시각화 체인

```yaml
파이프라인 단계:
  P1_수집:
    - DB 쿼리 / API 호출
    - CSV/JSON 추출
  
  P2_정제:
    - NULL 처리
    - 타입 변환
    - 이상값 제거
  
  P3_분석:
    - 집계/통계
    - ML 모델 적용
  
  P4_시각화:
    - 차트 생성
    - 대시보드 구성
  
  P5_보고서:
    - PDF/Excel 생성
    - 자동 전송
```

---

## 🏗️ B. 통합 설계 패턴

### 패턴 1: 계약 우선 설계 (Contract-First Design)

```yaml
원칙:
  "인터페이스를 먼저 정의하고, 구현은 나중에"

단계:
  1. 도메인 간 데이터 흐름 다이어그램 작성
  2. 각 경계에서 API 계약 정의 (OpenAPI/GraphQL Schema)
  3. Mock 서버로 프론트엔드 먼저 개발
  4. 백엔드 구현 및 통합

예시 (Spring Boot ↔ React):

# Step 1: OpenAPI 스펙 정의 (api-contract.yaml)
openapi: 3.0.0
paths:
  /api/users:
    get:
      summary: 사용자 목록 조회
      responses:
        '200':
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'

components:
  schemas:
    User:
      type: object
      required: [id, name, email]
      properties:
        id: {type: integer}
        name: {type: string}
        email: {type: string, format: email}

# Step 2: Mock 서버 실행
npx @stoplight/prism-cli mock api-contract.yaml

# Step 3: React에서 Mock API 호출
const users = await fetch('http://localhost:4010/api/users').then(r => r.json());

# Step 4: Spring Boot 실제 구현
@GetMapping("/api/users")
public List<User> getUsers() {
    return userService.findAll();
}
```

### 패턴 2: 어댑터 레이어 (Adapter Layer)

```python
# 도메인 간 데이터 변환 전담 레이어

class DatabaseAdapter:
    """DB 쿼리 결과를 API 응답 형식으로 변환"""
    
    @staticmethod
    def to_api_response(db_row: dict) -> dict:
        """
        DB 컬럼명 → API 필드명 매핑
        예: created_at → createdAt (카멜케이스)
        """
        return {
            "userId": db_row["user_id"],
            "userName": db_row["user_name"],
            "createdAt": db_row["created_at"].isoformat(),
            "isActive": db_row["is_active"]
        }

class ReportAdapter:
    """분석 결과를 보고서 형식으로 변환"""
    
    @staticmethod
    def to_excel_format(analysis_result: pd.DataFrame) -> dict:
        """
        DataFrame → Excel 시트 구조
        """
        return {
            "summary": analysis_result.describe().to_dict(),
            "details": analysis_result.to_dict('records'),
            "charts": generate_chart_data(analysis_result)
        }
```

---

## 🔄 C. 통합 시나리오별 실행 가이드

### 시나리오 1: Spring Boot + PostgreSQL + React 풀스택 앱

**Phase 1: 아키텍처 설계 (30분)**

```markdown
## 🏗️ 시스템 아키텍처

┌─────────────────────────────────────────┐
│          React Frontend                  │
│  ┌─────────────────────────────────┐   │
│  │ Components │ Redux │ Axios      │   │
│  └──────────────┬──────────────────┘   │
│                 │ HTTP REST API         │
├─────────────────┼─────────────────────┤
│                 ▼                       │
│       Spring Boot Backend              │
│  ┌─────────────────────────────────┐   │
│  │ Controllers │ Services │ JPA    │   │
│  └──────────────┬──────────────────┘   │
│                 │ JDBC                  │
├─────────────────┼─────────────────────┤
│                 ▼                       │
│         PostgreSQL Database            │
│  ┌─────────────────────────────────┐   │
│  │ Tables │ Indexes │ Constraints  │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘

### 통합 포인트 정의

1️⃣ React → Spring Boot
   - Endpoint: http://localhost:8080/api/*
   - 인증: JWT Bearer Token
   - 에러 처리: 통일된 에러 응답 형식

2️⃣ Spring Boot → PostgreSQL
   - 연결: JPA Hibernate
   - 트랜잭션: @Transactional
   - 성능: Connection Pool (HikariCP)
```

**Phase 2: 데이터베이스 우선 구현 (40분)**

```sql
-- Step 1: 스키마 설계
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    created_by INT REFERENCES users(id)
);

CREATE INDEX idx_products_name ON products(name);

-- Step 2: 샘플 데이터
INSERT INTO users (username, email, password_hash) VALUES
('admin', 'admin@example.com', '$2a$10$...'),
('user1', 'user1@example.com', '$2a$10$...');

-- Step 3: 검증 쿼리
SELECT u.username, COUNT(p.id) as product_count
FROM users u
LEFT JOIN products p ON u.id = p.created_by
GROUP BY u.id, u.username;
```

**Phase 3: Spring Boot 백엔드 (60분)**

```java
// Entity
@Entity
@Table(name = "products")
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name;
    
    @Column(nullable = false)
    private BigDecimal price;
    
    private Integer stock;
    
    @ManyToOne
    @JoinColumn(name = "created_by")
    private User createdBy;
}

// Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByNameContaining(String keyword);
}

// Service
@Service
@Transactional
public class ProductService {
    @Autowired
    private ProductRepository productRepository;
    
    public Page<Product> searchProducts(String keyword, Pageable pageable) {
        return productRepository.findByNameContaining(keyword, pageable);
    }
}

// Controller (API 계약 구현)
@RestController
@RequestMapping("/api/products")
public class ProductController {
    @Autowired
    private ProductService productService;
    
    @GetMapping
    public ResponseEntity<Page<ProductDTO>> getProducts(
        @RequestParam(required = false) String search,
        @PageableDefault(size = 20) Pageable pageable
    ) {
        Page<Product> products = productService.searchProducts(search, pageable);
        return ResponseEntity.ok(products.map(this::toDTO));
    }
    
    private ProductDTO toDTO(Product product) {
        // Adapter 패턴 적용
        return new ProductDTO(
            product.getId(),
            product.getName(),
            product.getPrice(),
            product.getStock()
        );
    }
}
```

**Phase 4: React 프론트엔드 (50분)**

```jsx
// API Client
import axios from 'axios';

const api = axios.create({
    baseURL: 'http://localhost:8080/api',
    headers: { 'Content-Type': 'application/json' }
});

export const productApi = {
    getProducts: (page = 0, search = '') => 
        api.get(`/products?page=${page}&search=${search}`)
};

// Component
import { useState, useEffect } from 'react';
import { productApi } from './api';

function ProductList() {
    const [products, setProducts] = useState([]);
    const [loading, setLoading] = useState(true);
    
    useEffect(() => {
        productApi.getProducts()
            .then(res => {
                setProducts(res.data.content);
                setLoading(false);
            })
            .catch(err => console.error(err));
    }, []);
    
    if (loading) return <div>Loading...</div>;
    
    return (
        <table>
            <thead>
                <tr><th>이름</th><th>가격</th><th>재고</th></tr>
            </thead>
            <tbody>
                {products.map(p => (
                    <tr key={p.id}>
                        <td>{p.name}</td>
                        <td>{p.price.toLocaleString()}원</td>
                        <td>{p.stock}</td>
                    </tr>
                ))}
            </tbody>
        </table>
    );
}
```

**Phase 5: 통합 테스트 (30분)**

```javascript
// E2E 테스트 (Playwright)
import { test, expect } from '@playwright/test';

test('전체 플로우: 상품 검색 → 상세 → 구매', async ({ page }) => {
    // 1. 메인 페이지 로드
    await page.goto('http://localhost:3000');
    await expect(page.locator('h1')).toContainText('상품 목록');
    
    // 2. 검색
    await page.fill('input[name="search"]', '노트북');
    await page.click('button[type="submit"]');
    
    // 3. API 호출 확인
    const response = await page.waitForResponse(
        res => res.url().includes('/api/products') && res.status() === 200
    );
    const data = await response.json();
    expect(data.content.length).toBeGreaterThan(0);
    
    // 4. 첫 번째 상품 클릭
    await page.click('tr:first-child td:first-child');
    
    // 5. 상세 페이지 확인
    await expect(page.locator('.product-detail')).toBeVisible();
});
```

---

### 시나리오 2: GitLab + Jenkins + K8s 배포 파이프라인

**Phase 1: GitLab 저장소 구조 (20분)**

```bash
# 프로젝트 구조
project-root/
├── src/                    # 소스 코드
├── Dockerfile              # 컨테이너 이미지
├── k8s/
│   ├── deployment.yaml     # K8s 배포 매니페스트
│   └── service.yaml
├── Jenkinsfile             # 파이프라인 정의
└── .gitlab-ci.yml          # GitLab CI 설정

# .gitlab-ci.yml (GitLab CI 활용 시)
stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - docker build -t myapp:$CI_COMMIT_SHA .
    - docker push registry.example.com/myapp:$CI_COMMIT_SHA

deploy:
  stage: deploy
  script:
    - kubectl set image deployment/myapp myapp=registry.example.com/myapp:$CI_COMMIT_SHA
  only:
    - main
```

**Phase 2: Jenkins 파이프라인 (40분)**

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'registry.example.com'
        IMAGE_NAME = 'myapp'
        GIT_COMMIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    }
    
    stages {
        stage('Checkout') {
            steps {
                // GitLab에서 코드 받기
                git branch: 'main', url: 'https://gitlab.example.com/team/project.git'
            }
        }
        
        stage('Build') {
            steps {
                script {
                    docker.build("${DOCKER_REGISTRY}/${IMAGE_NAME}:${GIT_COMMIT_SHORT}")
                }
            }
        }
        
        stage('Test') {
            steps {
                sh 'docker run --rm ${IMAGE_NAME}:${GIT_COMMIT_SHORT} npm test'
            }
        }
        
        stage('Push') {
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'registry-credentials') {
                        docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${GIT_COMMIT_SHORT}").push()
                        docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${GIT_COMMIT_SHORT}").push('latest')
                    }
                }
            }
        }
        
        stage('Deploy to K8s') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh """
                        kubectl set image deployment/myapp \\
                            myapp=${DOCKER_REGISTRY}/${IMAGE_NAME}:${GIT_COMMIT_SHORT} \\
                            --record
                        kubectl rollout status deployment/myapp
                    """
                }
            }
        }
    }
    
    post {
        success {
            // GitLab에 성공 상태 보고
            updateGitlabCommitStatus name: 'build', state: 'success'
        }
        failure {
            updateGitlabCommitStatus name: 'build', state: 'failed'
        }
    }
}
```

**Phase 3: K8s 매니페스트 (30분)**

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: registry.example.com/myapp:latest
        ports:
        - containerPort: 8080
        env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: myapp-config
              key: db_host
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10

---
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  type: LoadBalancer
  selector:
    app: myapp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

**Phase 4: GitLab Webhook 설정 (10분)**

```markdown
## GitLab → Jenkins 연동

1. GitLab 프로젝트 설정
   - Settings → Webhooks
   - URL: http://jenkins.example.com/project/myapp
   - Trigger: Push events, Merge request events
   - Secret Token: [Jenkins에서 생성한 토큰]

2. Jenkins 설정
   - Project 설정 → Build Triggers
   - ☑ Build when a change is pushed to GitLab
   - GitLab webhook URL: [자동 생성된 URL 복사]
```

---

### 시나리오 3: 데이터 분석 → 시각화 → 자동 보고서

**Phase 1: 데이터 추출 (DB 쿼리)**

```python
# extract.py
import pandas as pd
from sqlalchemy import create_engine

def extract_sales_data(start_date, end_date):
    """PostgreSQL에서 판매 데이터 추출"""
    engine = create_engine('postgresql://user:pass@localhost/sales_db')
    
    query = f"""
    SELECT 
        DATE_TRUNC('day', order_date) as date,
        product_category,
        SUM(amount) as revenue,
        COUNT(*) as order_count
    FROM orders
    WHERE order_date BETWEEN '{start_date}' AND '{end_date}'
      AND status = 'COMPLETED'
    GROUP BY 1, 2
    ORDER BY 1, 2
    """
    
    df = pd.read_sql(query, engine)
    return df

# 실행
df = extract_sales_data('2025-01-01', '2025-10-18')
df.to_csv('sales_data.csv', index=False)
print(f"✅ {len(df)}행 추출 완료")
```

**Phase 2: 데이터 정제 및 분석**

```python
# analyze.py
import pandas as pd
import numpy as np

def clean_and_analyze(df):
    """데이터 정제 및 통계 분석"""
    
    # 1. 결측치 처리
    df = df.dropna(subset=['revenue', 'order_count'])
    
    # 2. 이상값 제거 (IQR 방식)
    Q1 = df['revenue'].quantile(0.25)
    Q3 = df['revenue'].quantile(0.75)
    IQR = Q3 - Q1
    df = df[(df['revenue'] >= Q1 - 1.5*IQR) & (df['revenue'] <= Q3 + 1.5*IQR)]
    
    # 3. 파생 변수 생성
    df['avg_order_value'] = df['revenue'] / df['order_count']
    df['day_of_week'] = pd.to_datetime(df['date']).dt.day_name()
    
    # 4. 집계 통계
    summary = {
        'total_revenue': df['revenue'].sum(),
        'avg_daily_revenue': df.groupby('date')['revenue'].sum().mean(),
        'top_category': df.groupby('product_category')['revenue'].sum().idxmax(),
        'growth_rate': calculate_growth_rate(df)
    }
    
    return df, summary

def calculate_growth_rate(df):
    """월별 성장률 계산"""
    monthly = df.groupby(pd.to_datetime(df['date']).dt.to_period('M'))['revenue'].sum()
    growth = ((monthly.iloc[-1] - monthly.iloc[0]) / monthly.iloc[0]) * 100
    return round(growth, 2)
```

**Phase 3: 시각화 생성**

```python
# visualize.py
import matplotlib.pyplot as plt
import seaborn as sns

def create_charts(df, summary):
    """차트 생성 (PNG 파일로 저장)"""
    
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    
    # 차트 1: 일별 매출 추이
    daily_revenue = df.groupby('date')['revenue'].sum()
    axes[0, 0].plot(daily_revenue.index, daily_revenue.values, marker='o')
    axes[0, 0].set_title('일별 매출 추이')
    axes[0, 0].set_xlabel('날짜')
    axes[0, 0].set_ylabel('매출액 (원)')
    
    # 차트 2: 카테고리별 매출 비율
    category_revenue = df.groupby('product_category')['revenue'].sum()
    axes[0, 1].pie(category_revenue, labels=category_revenue.index, autopct='%1.1f%%')
    axes[0, 1].set_title('카테고리별 매출 비율')
    
    # 차트 3: 요일별 평균 주문액
    dow_avg = df.groupby('day_of_week')['avg_order_value'].mean()
    axes[1, 0].bar(dow_avg.index, dow_avg.values, color='skyblue')
    axes[1, 0].set_title('요일별 평균 주문액')
    
    # 차트 4: 월별 성장 추이
    monthly = df.groupby(pd.to_datetime(df['date']).dt.to_period('M'))['revenue'].sum()
    axes[1, 1].plot(monthly.index.astype(str), monthly.values, marker='s', color='green')
    axes[1, 1].set_title(f'월별 성장률: {summary["growth_rate"]}%')
    
    plt.tight_layout()
    plt.savefig('sales_charts.png', dpi=300, bbox_inches='tight')
    print("✅ 차트 생성 완료: sales_charts.png")
```

**Phase 4: 자동 보고서 생성 (Excel)**

```python
# report.py
from openpyxl import Workbook
from openpyxl.drawing.image import Image
from openpyxl.styles import Font, Alignment, PatternFill

def generate_excel_report(df, summary, output_file='sales_report.xlsx'):
    """Excel 보고서 생성"""
    
    wb = Workbook()
    
    # 시트 1: 요약
    ws1 = wb.active
    ws1.title = "요약"
    
    # 헤더
    ws1['A1'] = '판매 실적 보고서'
    ws1['A1'].font = Font(size=18, bold=True)
    ws1.merge_cells('A1:D1')
    
    # 핵심 지표
    metrics = [
        ['총 매출액', f"{summary['total_revenue']:,.0f} 원"],
        ['일평균 매출', f"{summary['avg_daily_revenue']:,.0f} 원"],
        ['최고 카테고리', summary['top_category']],
        ['성장률', f"{summary['growth_rate']}%"]
    ]
    
    for i, (label, value) in enumerate(metrics, start=3):
        ws1[f'A{i}'] = label
        ws1[f'B{i}'] = value
        ws1[f'A{i}'].font = Font(bold=True)
    
    # 차트 이미지 삽입
    img = Image('sales_charts.png')
    ws1.add_image(img, 'A8')
    
    # 시트 2: 상세 데이터
    ws2 = wb.create_sheet("상세 데이터")
    
    # 데이터프레임을 시트에 쓰기
    for r_idx, row in enumerate(df.itertuples(index=False), start=1):
        for c_idx, value in enumerate(row, start=1):
            cell = ws2.cell(row=r_idx, column=c_idx, value=value)
            if r_idx == 1:  # 헤더
                cell.font = Font(bold=True)
                cell.fill = PatternFill(start_color="DDDDDD", fill_type="solid")
    
    # 저장
    wb.save(output_file)
    print(f"✅ Excel 보고서 생성 완료: {output_file}")
```

**Phase 5: 전체 파이프라인 자동화**

```python
# pipeline.py
from datetime import datetime, timedelta
import schedule
import time

def run_daily_report():
    """일일 보고서 생성 파이프라인"""
    
    print("📊 보고서 생성 시작...")
    
    # 1. 데이터 추출
    end_date = datetime.now().date()
    start_date = end_date - timedelta(days=30)
    df = extract_sales_data(start_date, end_date)
    
    # 2. 분석
    df_clean, summary = clean_and_analyze(df)
    
    # 3. 시각화
    create_charts(df_clean, summary)
    
    # 4. 보고서 생성
    report_filename = f"sales_report_{end_date.strftime('%Y%m%d')}.xlsx"
    generate_excel_report(df_clean, summary, report_filename)
    
    # 5. 이메일 전송 (선택)
    send_email_with_attachment(report_filename, ['manager@example.com'])
    
    print("✅ 보고서 생성 완료!")

# 스케줄링: 매일 오전 9시 실행
schedule.every().day.at("09:00").do(run_daily_report)

if __name__ == '__main__':
    print("🤖 보고서 자동화 시스템 시작")
    while True:
        schedule.run_pending()
        time.sleep(60)
```

---

## 🧪 D. 통합 테스트 전략

### 레벨 1: 단위 테스트 (각 도메인 독립)
```python
# 백엔드 단위 테스트
def test_product_service():
    product = Product(name="테스트", price=10000)
    assert product.calculate_discount(10) == 9000

# 프론트엔드 단위 테스트
test('API 호출 성공', () => {
    const data = { id: 1, name: 'Test' };
    expect(productApi.parse(data)).toEqual({ userId: 1, userName: 'Test' });
});
```

### 레벨 2: 통합 테스트 (2개 도메인 연결)
```java
@SpringBootTest
@AutoConfigureMockMvc
class ProductIntegrationTest {
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    void testGetProducts() throws Exception {
        mockMvc.perform(get("/api/products"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content[0].name").exists());
    }
}
```

### 레벨 3: E2E 테스트 (전체 플로우)
```javascript
// Playwright E2E
test('전체 구매 플로우', async ({ page }) => {
    await page.goto('http://localhost:3000');
    await page.click('text=상품 검색');
    await page.fill('[name=search]', '노트북');
    await page.click('button:has-text("검색")');
    
    // API 응답 대기 및 검증
    const response = await page.waitForResponse(
        res => res.url().includes('/api/products') && res.status() === 200
    );
    
    await page.click('tr:first-child');
    await page.click('button:has-text("장바구니 담기")');
    await expect(page.locator('.cart-badge')).toContainText('1');
});
```

---

## ✅ E. 통합 체크리스트

### 설계 단계
- [ ] 도메인 경계 명확히 정의
- [ ] 각 경계의 API 계약 작성 (OpenAPI/GraphQL)
- [ ] 데이터 흐름 다이어그램 작성
- [ ] 어댑터 레이어 설계

### 구현 단계
- [ ] 각 도메인 독립 구현 후 Mock으로 테스트
- [ ] 인터페이스 우선 연결 (실제 구현은 나중)
- [ ] 에러 핸들링 통일 (HTTP 상태 코드, 에러 응답 형식)
- [ ] 로깅/모니터링 포인트 추가

### 테스트 단계
- [ ] 단위 테스트 (각 도메인)
- [ ] 통합 테스트 (2개 도메인)
- [ ] E2E 테스트 (전체 플로우)
- [ ] 성능 테스트 (병목 지점 식별)

### 배포 단계
- [ ] 환경별 설정 분리 (dev/staging/prod)
- [ ] CI/CD 파이프라인 구성
- [ ] 롤백 계획 수립
- [ ] 모니터링/알람 설정

---

## 🎯 F. 핵심 요약

**도메인 간 통합 3원칙**:
1. **계약 우선**: 인터페이스부터 정의하고 Mock으로 검증
2. **어댑터 분리**: 도메인 간 변환 로직을 전담 레이어로 격리
3. **단계적 테스트**: 단위 → 통합 → E2E 순서로 검증

**통합 시나리오 타입**:
- 수직 통합: 프론트↔백↔DB (계층별 구현)
- 수평 통합: GitLab↔Jenkins↔K8s (시스템 간 연동)
- 데이터 파이프라인: 추출→분석→시각화→보고서

**성공 기준**:
- 각 도메인이 독립적으로 교체 가능
- 에러가 도메인 경계를 넘지 않음
- E2E 테스트 통과율 ≥90%

이 지침을 따르면 **복잡한 다중 도메인 프로젝트도 체계적으로 통합**할 수 있습니다! 🔗
