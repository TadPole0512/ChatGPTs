# 💻 도메인 2: 프로그래밍 모범 사례 지침

> **출처**: OWASP, Spring 공식 문서, 업계 표준 + 과거 대화 분석  
> **업데이트**: 2025-12-07 | **신뢰도**: [🟢 확인됨]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🧭 핵심 요약

2024-2025년 현대 소프트웨어 개발의 핵심 원칙을 Java/Spring Boot 환경에 최적화한 실전 가이드입니다. 코드 품질, 보안, 성능, 테스트, 문서화의 5대 영역을 체계적으로 다룹니다.

**3가지 핵심 원칙**:
- ✅ 타입 안전성 + 에러 처리 = 견고한 코드
- ✅ 보안 코딩 (OWASP Top 10) + 정기 감사
- ✅ 코드 리뷰 + 자동화 테스트 = 품질 보증

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📊 프로그래밍 5대 기둥

```
┌──────────────────────────────────────────────────────────┐
│  1. 코드 품질      2. 보안      3. 성능                   │
│     ↓               ↓            ↓                       │
│  [가독성]       [입력 검증]  [쿼리 최적화]               │
│  [유지보수성]   [인증/인가]  [캐싱 전략]                 │
│  [테스트성]     [암호화]     [비동기 처리]               │
│     ↓               ↓            ↓                       │
│  4. 테스트        5. 문서화                              │
│     ↓               ↓                                    │
│  [단위 테스트]  [JavaDoc]                                │
│  [통합 테스트]  [README]                                 │
│  [E2E 테스트]   [API 명세]                               │
└──────────────────────────────────────────────────────────┘
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🔧 영역별 상세 지침

### 1️⃣ 코드 품질 - Clean Code 원칙

#### 명명 규칙

```java
// ❌ 나쁜 예
public class Mgr {
    private List<String> d;
    public void proc(int x) { }
}

// ✅ 좋은 예
public class UserManager {
    private List<String> activeUserIds;
    
    /**
     * 사용자 등록 프로세스를 처리합니다.
     * @param userId 사용자 ID
     * @return 처리 결과
     */
    public Result processRegistration(int userId) { }
}
```

#### 메소드 크기 제한

```java
// ❌ 100줄 넘는 메소드
public void processOrder() {
    // 100줄의 복잡한 로직...
}

// ✅ 단일 책임 원칙
public void processOrder(Order order) {
    validateOrder(order);          // 5줄
    calculateTotal(order);          // 8줄
    applyDiscount(order);           // 6줄
    saveOrder(order);               // 4줄
    sendConfirmation(order);        // 3줄
}
```

#### 중복 코드 제거

```java
// ❌ 중복 코드
public void saveUser(User user) {
    if (user == null) throw new IllegalArgumentException();
    if (user.getName() == null) throw new IllegalArgumentException();
    // ... 저장 로직
}

public void updateUser(User user) {
    if (user == null) throw new IllegalArgumentException();
    if (user.getName() == null) throw new IllegalArgumentException();
    // ... 수정 로직
}

// ✅ 공통 메소드 추출
private void validateUser(User user) {
    Objects.requireNonNull(user, "User cannot be null");
    Objects.requireNonNull(user.getName(), "Name cannot be null");
}

public void saveUser(User user) {
    validateUser(user);
    // ... 저장 로직
}
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 2️⃣ 보안 - OWASP Top 10 기준

#### SQL Injection 방지

```java
// ❌ 위험: 직접 문자열 연결
String query = "SELECT * FROM users WHERE id = '" + userId + "'";

// ✅ 안전: PreparedStatement 또는 MyBatis #{} 사용
// MyBatis Mapper XML
<select id="selectUser" resultType="User">
    SELECT * FROM users WHERE id = #{userId}
</select>

// JPA Repository
@Query("SELECT u FROM User u WHERE u.id = :userId")
User findByUserId(@Param("userId") Long userId);
```

#### XSS (Cross-Site Scripting) 방지

```java
// ❌ 위험: 사용자 입력 그대로 출력
@GetMapping("/search")
public String search(@RequestParam String query, Model model) {
    model.addAttribute("query", query);  // 위험!
    return "search";
}

// ✅ 안전: Escape 처리
@GetMapping("/search")
public String search(@RequestParam String query, Model model) {
    String safeQuery = HtmlUtils.htmlEscape(query);
    model.addAttribute("query", safeQuery);
    return "search";
}
```

#### 인증/인가

```java
// Spring Security 설정
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/public/**").permitAll()
                .requestMatchers("/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .csrf(csrf -> csrf.csrfTokenRepository(
                CookieCsrfTokenRepository.withHttpOnlyFalse()
            ))
            .headers(headers -> headers
                .contentSecurityPolicy(csp -> 
                    csp.policyDirectives("default-src 'self'")
                )
            );
        return http.build();
    }
}
```

#### 민감 정보 암호화

```java
// application.yml (절대 평문 저장 금지)
spring:
  datasource:
    password: ${DB_PASSWORD}  // 환경 변수 사용
    
// Jasypt 암호화 (권장)
@Configuration
@EnableEncryptableProperties
public class JasyptConfig {
    
    @Bean("jasyptStringEncryptor")
    public StringEncryptor stringEncryptor() {
        PooledPBEStringEncryptor encryptor = new PooledPBEStringEncryptor();
        SimpleStringPBEConfig config = new SimpleStringPBEConfig();
        config.setPassword(System.getenv("JASYPT_PASSWORD"));
        config.setAlgorithm("PBEWithMD5AndDES");
        config.setPoolSize("1");
        encryptor.setConfig(config);
        return encryptor;
    }
}
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 3️⃣ 성능 - 최적화 전략

#### N+1 문제 해결

```java
// ❌ N+1 문제
@Entity
public class Post {
    @OneToMany(mappedBy = "post")
    private List<Comment> comments;  // LAZY Loading
}

// Controller에서
List<Post> posts = postRepository.findAll();
for (Post post : posts) {
    System.out.println(post.getComments().size());  // N번 추가 쿼리!
}

// ✅ Fetch Join 사용
@Query("SELECT p FROM Post p LEFT JOIN FETCH p.comments")
List<Post> findAllWithComments();
```

#### 쿼리 최적화

```xml
<!-- ❌ 비효율: 전체 조회 후 애플리케이션 필터링 -->
<select id="findRecentUsers" resultType="User">
    SELECT * FROM users ORDER BY create_dt DESC
</select>
// Java에서 .limit(10) 적용

<!-- ✅ 효율: DB에서 제한 -->
<select id="findRecentUsers" resultType="User">
    SELECT * FROM users 
    ORDER BY create_dt DESC 
    LIMIT 10
</select>
```

#### 캐싱 전략

```java
// Spring Cache 활용
@Configuration
@EnableCaching
public class CacheConfig {
    
    @Bean
    public CacheManager cacheManager() {
        SimpleCacheManager cacheManager = new SimpleCacheManager();
        cacheManager.setCaches(Arrays.asList(
            new ConcurrentMapCache("users"),
            new ConcurrentMapCache("products")
        ));
        return cacheManager;
    }
}

@Service
public class UserService {
    
    @Cacheable(value = "users", key = "#userId")
    public User getUser(Long userId) {
        // DB 조회 (캐시 미스 시에만 실행)
        return userRepository.findById(userId).orElse(null);
    }
    
    @CacheEvict(value = "users", key = "#user.id")
    public void updateUser(User user) {
        userRepository.save(user);
    }
}
```

#### 비동기 처리

```java
@Configuration
@EnableAsync
public class AsyncConfig implements AsyncConfigurer {
    
    @Override
    public Executor getAsyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("async-");
        executor.initialize();
        return executor;
    }
}

@Service
public class EmailService {
    
    @Async
    public CompletableFuture<String> sendEmail(String to, String subject) {
        // 시간 소모적 작업
        try {
            Thread.sleep(2000);
            // 이메일 발송 로직
            return CompletableFuture.completedFuture("Success");
        } catch (InterruptedException e) {
            return CompletableFuture.failedFuture(e);
        }
    }
}
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 4️⃣ 테스트 - 품질 보증

#### 단위 테스트 (JUnit 5)

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    @DisplayName("사용자 조회 성공")
    void getUserSuccess() {
        // Given
        Long userId = 1L;
        User mockUser = new User(userId, "테스트");
        when(userRepository.findById(userId)).thenReturn(Optional.of(mockUser));
        
        // When
        User result = userService.getUser(userId);
        
        // Then
        assertNotNull(result);
        assertEquals("테스트", result.getName());
        verify(userRepository, times(1)).findById(userId);
    }
    
    @Test
    @DisplayName("존재하지 않는 사용자 조회 시 예외 발생")
    void getUserNotFound() {
        // Given
        Long userId = 999L;
        when(userRepository.findById(userId)).thenReturn(Optional.empty());
        
        // When & Then
        assertThrows(UserNotFoundException.class, () -> {
            userService.getUser(userId);
        });
    }
}
```

#### 통합 테스트 (Spring Boot Test)

```java
@SpringBootTest
@AutoConfigureMockMvc
class UserControllerIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @Test
    @DisplayName("사용자 생성 API 통합 테스트")
    void createUserIntegration() throws Exception {
        // Given
        UserCreateRequest request = new UserCreateRequest("새사용자", "test@example.com");
        
        // When & Then
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.name").value("새사용자"))
            .andExpect(jsonPath("$.email").value("test@example.com"));
    }
}
```

#### 테스트 커버리지

```xml
<!-- pom.xml: JaCoCo 플러그인 -->
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.11</version>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
        <execution>
            <id>jacoco-check</id>
            <goals>
                <goal>check</goal>
            </goals>
            <configuration>
                <rules>
                    <rule>
                        <element>PACKAGE</element>
                        <limits>
                            <limit>
                                <counter>LINE</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.80</minimum>
                            </limit>
                        </limits>
                    </rule>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 5️⃣ 문서화 - 지속 가능한 코드

#### JavaDoc 작성

```java
/**
 * 사용자 관리를 위한 서비스 클래스입니다.
 * 
 * <p>이 클래스는 사용자 CRUD 작업과 인증/인가 로직을 처리합니다.
 * 모든 메소드는 트랜잭션 관리가 적용됩니다.</p>
 * 
 * @author 올챙이
 * @since 1.0.0
 * @see UserRepository
 */
@Service
@Transactional
public class UserService {
    
    /**
     * 사용자 ID로 사용자 정보를 조회합니다.
     * 
     * @param userId 조회할 사용자 ID (null 불가)
     * @return 사용자 정보
     * @throws UserNotFoundException 사용자가 존재하지 않을 경우
     * @throws IllegalArgumentException userId가 null일 경우
     */
    public User getUser(@NonNull Long userId) {
        Objects.requireNonNull(userId, "userId cannot be null");
        return userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException(userId));
    }
}
```

#### README 구조

```markdown
# 프로젝트명

## 📋 개요
- 목적: 경조금 관리 시스템
- 기술 스택: Java 8, Spring Boot 2.7, MyBatis, PostgreSQL 14
- 개발 기간: 2025-01 ~ 2025-03

## 🚀 빠른 시작

### 1. 환경 요구사항
- JDK 8 이상
- Maven 3.6+
- PostgreSQL 14+

### 2. 설치 및 실행
\```bash
git clone https://gitlab.com/project/sbm.git
cd sbm
mvn clean install
mvn spring-boot:run
\```

### 3. 설정
\```yaml
# application.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/sbm
    username: ${DB_USER}
    password: ${DB_PASSWORD}
\```

## 📁 프로젝트 구조
\```
src/
├─ main/
│  ├─ java/com/koreazinc/sbm/
│  │  ├─ controller/  # REST API
│  │  ├─ service/     # 비즈니스 로직
│  │  ├─ repository/  # DB 접근
│  │  └─ domain/      # 도메인 모델
│  └─ resources/
│     ├─ mybatis/     # SQL Mapper
│     └─ application.yml
└─ test/              # 테스트 코드
\```

## 📚 API 문서
Swagger UI: http://localhost:8080/swagger-ui.html

## 🧪 테스트
\```bash
mvn test
mvn jacoco:report  # 커버리지 리포트
\```

## 📝 기여 가이드
1. Feature 브랜치 생성
2. 커밋 (`git commit -m 'Add feature'`)
3. Push (`git push origin feature/AmazingFeature`)
4. Pull Request 생성

## 📄 라이선스
MIT License
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ✅ 품질 체크리스트

### 코드 품질

- [ ] 변수/메소드명이 명확하고 의미있는가?
- [ ] 메소드 길이가 30줄 이하인가?
- [ ] 중복 코드가 제거되었는가?
- [ ] 주석이 적절하게 작성되었는가?
- [ ] 매직 넘버가 상수로 정의되었는가?

### 보안

- [ ] 모든 입력이 검증되는가?
- [ ] SQL Injection 방지가 적용되었는가?
- [ ] XSS 방지가 적용되었는가?
- [ ] 인증/인가가 적절히 구현되었는가?
- [ ] 민감 정보가 암호화되어 있는가?

### 성능

- [ ] N+1 문제가 해결되었는가?
- [ ] 적절한 인덱스가 생성되었는가?
- [ ] 캐싱이 적용되었는가?
- [ ] 쿼리에 LIMIT이 설정되었는가?
- [ ] 비동기 처리가 적절히 사용되었는가?

### 테스트

- [ ] 단위 테스트가 작성되었는가?
- [ ] 통합 테스트가 작성되었는가?
- [ ] 테스트 커버리지가 80% 이상인가?
- [ ] 예외 케이스가 테스트되었는가?
- [ ] CI에서 테스트가 자동 실행되는가?

### 문서화

- [ ] README가 최신 상태인가?
- [ ] API 문서가 자동 생성되는가?
- [ ] JavaDoc이 public 메소드에 작성되었는가?
- [ ] ERD가 최신 스키마를 반영하는가?
- [ ] 배포 가이드가 작성되었는가?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📖 참고 자료

### 공식 문서 [🟢 확인됨]

- Spring Boot Reference: https://spring.io/projects/spring-boot
- OWASP Top 10: https://owasp.org/www-project-top-ten/
- Java Code Conventions: https://www.oracle.com/java/technologies/javase/codeconventions-introduction.html

### 한국어 자료 [🟢 확인됨]

- 소프트웨어 개발 모범 사례: https://scopicsoftware.com/ko/blog/software-development-best-practices/
- 웹 개발 트렌드 2025: https://www.codetree.ai/blog/2025-웹-개발-트렌드

### 도구 [🟢 확인됨]

- JUnit 5: https://junit.org/junit5/
- Mockito: https://site.mockito.org/
- SonarQube: https://www.sonarqube.org/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 💡 추가 개선 제안

1. **AI 코드 어시스턴트 도입**
   - GitHub Copilot 또는 Claude Code 활용
   - 코드 리뷰 자동화 (CodeRabbit)
   - 테스트 케이스 자동 생성

2. **모니터링 강화**
   - APM 도구 도입 (New Relic, Datadog)
   - 로그 중앙화 (ELK Stack)
   - 알림 자동화 (Slack 통합)

3. **개발 문화 개선**
   - 페어 프로그래밍 도입
   - 코드 리뷰 문화 정착
   - 기술 세미나 정기 개최

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**📌 이 지침서를 팀 전체가 공유하고, 코드 리뷰 시 체크리스트로 활용하세요!**
