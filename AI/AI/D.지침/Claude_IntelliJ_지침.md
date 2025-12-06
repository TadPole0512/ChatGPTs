# IntelliJ Development Guide Project Guidelines

## 📋 Table of Contents
1. [Project Initial Setup] (#Project-Initial-Setup)
2. [Optimize your development environment] (#development-environment-optimization)
3. [Instructions for writing code](#code-writing-instructions)
4. [Debugging and testing] (#Debugging-and-testing)
5. [Version control integration](#version-management-integration)
6. [Performance optimization](#performance-optimization)
7. [Set up team collaboration] (#Team-Collaboration-Setup)

## 🚀 Project initialization

### 1. Create a new project


```
File → New → Project
├── Java (Spring Boot, Maven/Gradle)
├── Web (React, Vue, Angular)
└── Database (SQL Script Project)
```

### 2. Project Structure Template
```
project-root/
├── src/
│   ├── main/
│   │   ├── java/
│   │   ├── resources/
│   │   └── webapp/
│   └── test/
├── docs/
├── scripts/
└── config/
```

### 3. Install the required plugins
- Lombok Plugin**: Reduce boilerplate code
- **SonarLint**: Real-time code quality analysis
- GitToolBox: Enhance Git integration
- Database Navigator: DB management
- Rainbow Brackets**: Code readability
- Key Promoter X: Learn shortcuts

## ⚙️ Optimize your development environment

### 1. IDE Performance Tuning
```
Help → Edit Custom VM Options
-Xmx4096m
-XX:ReservedCodeCacheSize=512m
-XX:+UseG1GC
```

### 2. Set the code style
```
Settings → Editor → Code Style
├── Java: Google Java Style Guide
├── JavaScript: Airbnb Style Guide
└── SQL: Knauf-SQL-Style v1.1
```

### 3. Create a live template
```java
// psvm - public static void main
public static void main(String[] args) {
    $END$
}

// logd - 디버그 로그
private static final Logger log = LoggerFactory.getLogger($CLASS$.class);
log.debug("$MESSAGE$", $PARAMS$);
```

## 💻 Instructions for writing code

### 1. Smart coding techniques

Utilize #### autocomplete
- Ctrl + Space: Basic completion
- Ctrl + Shift + Space`: Smart type completion
- `Ctrl + Shift + Enter`: Syntax completion

#### code generation shortcut
```
Alt + Insert: Generate 메뉴
├── Constructor, Getter/Setter
├── equals(), hashCode()
├── toString()
└── Test Methods
```

### 2. Refactoring Patterns
```
Ctrl + Alt + Shift + T: Refactoring menu
├── Extract Method (Ctrl + Alt + M)
├── Extract Variable (Ctrl + Alt + V)
├── Extract Constant (Ctrl + Alt + C)
└── Inline (Ctrl + Alt + N)
```

### 3. Code Quality Control

#### live check
- Error**: red - compilation error
- Warning**: Yellow - Improvement recommended
- Weak Warning**: gray - can be optimized

#### Run code inspection
```
Code → Inspect Code
├── Analyze the entire project
├── Set up custom scopes
└── Manage inspection profiles
```

## 🐛 Debugging and Testing

### 1. Debugging strategy

#### Breakpoint Types
- Line Breakpoint**: Basic breakpoint
- **Conditional Breakpoint**: Conditional breakpoint
- Exception Breakpoint: Breaks when an exception occurs
- Method Breakpoint**: Breaks on method entry/exit



#### Debugging shortcuts
```
F8: Step Over
F7: Step Into  
Shift + F8: Step Out
F9: Resume Program
Ctrl + F8: Toggle Breakpoint
```

### 2. Test Automation

#### JUnit 5 templates
```java
@ExtendWith(MockitoExtension.class)
class ServiceTest {
    
    @Mock
    private Repository repository;
    
    @InjectMocks
    private Service service;
    
    @Test
    @DisplayName("테스트 케이스 설명")
    void testMethod() {
        // Given
        given(repository.findById(1L))
            .willReturn(Optional.of(entity));
        
        // When
        Result result = service.process(1L);
        
        // Then
        assertThat(result).isNotNull();
        then(repository).should().findById(1L);
    }
}
```

#### Test Coverage
```
Run → Run 'Tests' with Coverage
├── Check coverage by class
├── Highlight untested code
└── Generate HTML Report
```

## 📊 Version Control Integration

### 1. Git workflow

#### Branching strategy
```
main (master)
├── develop
│   ├── feature/user-auth
│   ├── feature/api-integration
│   └── hotfix/critical-bug
└── release/v1.2.0
```

#### commit convention
```
type(scope): Short description

- feat: New feature
- fix: Bug fix
- docs: Documentation changes
- style: Code style changes
- refactor: Refactor
- test: Add/modify tests
- chore: Build/setup changes
```

### 2. IntelliJ Git Features

#### Manage changes
```
Alt + 9: Version Control window
├── Local Changes: Local changes
├── Repository: Remote repository status  
├── Log: Commit history
└── Console: Git command logs
```

#### resolve merge conflict
```
VCS → Git → Resolve Conflicts
├── Use the 3-way merge tool
├── Attempt automatic merge
└── Manual edit mode
```

## 🚀 Performance Optimization

### 1. Monitor memory usage
```
Help → Find Action → "Memory"
├── Enable Memory Indicator
├── Create a Heap Dump
└── Analyze GC Logs
```



### 2. Optimize indexing
```
File → Invalidate Caches and Restart
├── Invalidate Caches
├── Reorganize indexes
└── Restart the IDE
```

### 3. Manage Plugins
```
Settings → Plugins
├── Deactivate unnecessary plugins
├── Check for plugin updates
└── Monitor memory usage
```

## 👥 Set up team collaboration

### 1. Share code styles
```
Create a .editorconfig file:
root = true



[*.java]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 4
max_line_length = 120

[*.{js,ts,jsx,tsx}]
indent_size = 2
```

### 2. Share scan profiles
```
Settings → Editor → Inspections
├── Click the Export button
├── Export to XML file
└── Share with team members
```

### 3. Synchronize live templates
```
Settings → Editor → Live Templates
├── Create a custom template group
├── Share with Export Settings
└── Define a team standard template
```

## 🛠️ Database Development

### 1. Set up Database Tool Window
```
View → Tool Windows → Database
├── Datasource Connection Settings
├── Browse Schema
└── Run SQL Console
```

### 2. SQL Writing Guide (Knauf-SQL-Style v1.1)


```sql
SELECT 
    u.user_id,
    u.username,
    COUNT(o.order_id) AS order_count
FROM users u
    LEFT JOIN orders o ON u.user_id = o.user_id
WHERE u.created_date >= '2024-01-01'
    AND u.status = 'ACTIVE'
GROUP BY 
    u.user_id,
    u.username
HAVING COUNT(o.order_id) > 0
ORDER BY 
    order_count DESC,
    u.username ASC;
```

### 3. Analyze query performance
```
Database Tool Window → Console → Explain Plan
├── Check the execution plan
├── Check index usage
└── Identify performance bottlenecks
```

## 📈 Productivity Tips

### 1. Master essential shortcuts
```
Lookup/Navigation:
- Ctrl + N: Find Classes
- Ctrl + Shift + N: Find a file  
- Ctrl + F12: View file structure
- Ctrl + H: Type hierarchy

Edit:
- Ctrl + D: Duplicate line
- Ctrl + Y: Delete line
- Alt + J: Multiple selections
- Ctrl + /: Toggle line comments
```

### 2. Utilizing Macros
```
Edit → Macros → Start Macro Recording
├── Automate repetitive tasks
├── Assign custom keyboard shortcuts
└── Share macros within your team


```

### 3. Manage Workspaces
```
Window → Store Current Layout as Default
├── Save project-specific layout
├── Optimize Tool Window Placement
└── Multi-Monitor Setup
```

## ⚡ Troubleshooting

### 1. Troubleshooting common problems
```
Problem: IDE is slow
Solution: 
1. increase Memory Heap (-Xmx option)
2. disable unnecessary plugins
3. run indexing optimizations

Problem: Autocomplete not working
Solution:
1. reorganize indexes (Invalidate Caches)
2. check to disable Power Save Mode
3. check project SDK settings
```

### 2. Analyze the logs
```
Help → Show Log in Explorer
├── idea.log: General log
├── gc.log: GC performance log
└── threadDumps: Thread dumps
```

---]

## 📚 Additional Resources

- Official documentation for InTelliJ IDEA: https://www.jetbrains.com/help/idea/
- Keymap reference: Settings → Keymap → Download printable keymap
- Plugin Development: https://plugins.jetbrains.com/docs/intellij/
- Community forum: https://intellij-support.jetbrains.com/



---
