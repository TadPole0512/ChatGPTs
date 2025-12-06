# 📋 Claude Collaboration Project Guidelines

## A. Steps to prepare questions

### Checklist of contextual information needed

**Basic information about the project:**
```
✅ Technology stack used: "JAVA backend + JavaScript frontend + RealGrid + MySQL"
✅ Project size: "Number of users, data volume, expected traffic"
✅ Browser support coverage: "IE11 support required", etc.
✅ Performance requirements: "10,000 data loads in 1 second", etc.
```

**RealGrid-specific information:** **RealGrid-specific information
```javascript
// Sharing the current grid settings
const gridConfig = {
    version: "RealGrid2 2.x.x",
    columns: [...], // define columns
    dataSource: {...}, // Set data source
    displayOptions: {...} // display options

};
```

Cautions for sharing code/settings:** ** Provide full context
- Provide full context: all relevant functions rather than fragmented code
- Original error message: don't translate, just the original
- Execution conditions: if "only occurs under certain conditions", specify them

## B. Templates by question type

### 🔧 For implementation requests.

**Effective questions:**
```
"I want to implement the following feature in RealGrid:

Goal: When the user double-clicks on a cell, it becomes an inline edit and, 
      AJAX save to server immediately when value changes.

Current situation: 
- Grid is set up
- Server API is ready in the form of PUT /api/data/{id}

Restrictions:
- Certain columns (status) are not editable
- Must be cancelable with ESC during editing
- Rollback to original values on save failure

Current grid settings:
[code attached].
"

```

### 🐛 When troubleshooting

Effective questions to ask:** **When troubleshooting
```
"I'm having this problem in RealGrid:

Symptom: Refreshing grid data resets selected rows.

Conditions under which it occurs:
- After refreshing the data with setRows().
- User-selected row information disappears

Expected behavior: The same rows should remain selected after the refresh

Current code:
```javascript.
// Data refresh code
gridView.setRows(newData);
```

Error message: (none, simply unchecked)

Environment: RealGrid2 2.8.0, Chrome latest
"
```

### ⚡ When optimization is requested


**Effective questions to ask:**
```
"I want to improve the performance of this RealGrid code:

Current situation:
- Takes 3-4 seconds to load 50k data.
- Stuttering when scrolling

Goal: Loading in 1 second, smooth scrolling

Current code:
[full grid setup and data loading code].

Suspicion point:
- Loading all data at once
- Using a complex custom renderer

Constraint:
- Users need the ability to search the entire data
- Maintain existing UI layout
"
```

### 🏗️ for architecture advice

**Effective questions to ask:**
```
"Please review the overall RealGrid architecture:


Project structure:
```
📁 frontend/
  📁 js/
    📄 grid-config.js // Grid configuration
    📄 data-service.js // API communication
    📄 grid-events.js // Event handlers
  📁 css/ // CSS
    📄 custom-grid.css // custom styles
```

Main concerns:
1. code reusability: use similar grid on multiple screens
2. maintainability: Minimize impact when changing column definitions
3. testability: unit testing grid functionality

Current Concerns:
- Should we externalize grid settings to JSON?
- Should we create a common grid class?
- How to structure event handling
"
```

## C. How to communicate effectively

### Step-by-step approach vs. integrated approach

Step-by-step approach (recommended):** **.
```
Step 1: "Help me set up the RealGrid basics"
Step 2: "Now add the ability to load data"
Step 3: "Let's add editing functionality"
Step 4: "Optimize the whole thing"

```

Integrated approach (for complex cases):** ** **Integrated approach (for complex cases)
```
"I need to create an order management screen for my ERP system with RealGrid.
Let's break down the required functionality into steps:
[list all requirements]"
```

### How to request a code review.

**Effective requests:**
```
"Please review this RealGrid code:

Review perspective:
✅ Room for performance optimization
✅ Code structure improvements
✅ Adherence to RealGrid best practices
✅ Potential bugs
✅ Browser compatibility

[full code attached].

In particular, the dataProvider settings and the 
event handler structure.
```

### How to request an alternative solution

```
"I'd like to know what you think about implementing this in RealGrid. 
different approaches to implementing this feature in RealGrid:

Feature: real-time updating of grid data.


Considerations:
- Performance (high priority)
- Implementation complexity (medium priority)
- Maintainability (high priority)

Explain the pros and cons of each method, as well as recommended scenarios.
```

## D. Quality Improvement Checkpoints

### How to verify code completeness

```javascript
// Checklist to ask Claude
"Please verify that the following RealGrid code is suitable for production:

Checkpoints:
✅ Completeness of error handling.
✅ Possible memory leaks  
✅ Event listener cleanup
Browser compatibility
Performance optimization
User experience (loading, feedback)

[code attached].
"
```

### How to request test cases


```
"Create a test case for this RealGrid feature:

Function: edit and save grid data.

Test types:
1. unit tests (Jest)
2. integration tests (API integration)
3. E2E tests (user scenarios)

Please provide specific code examples for each test.
"
```

### Documentation and commenting guide

```javascript
/**.
 * Claude, please write a JSDoc comment for this function:
 * - Include a RealGrid-specific description.
 * - Parameter types and descriptions
 * - Return value descriptions
 * - Usage examples
 * - Caveats
 */
function setupGrid(container, options) {
    // Code...
}
```

## E. Project-specific customization

### RealGrid-specific question patterns

**Performance related:**
```
"Analyze RealGrid performance issues:
- Amount of data: X million.
- Number of columns: Y.
- Estimated concurrent users: Z users
- Current loading time: N seconds


Analyze bottlenecks and suggest ways to improve."
```

**UI/UX related:**
```
"I want to improve the RealGrid UI:
- Current user pain points: [Specific].
- Target users: [job characteristics].
- Design constraints: [consistency with existing systems].

Suggest ways to improve the user experience."
```

### Variations when applying other libraries/frameworks.

**React Environment:**
```
"Modify these RealGrid guidelines for the React environment:
- How to structure your components
- State management (useState, useEffect)
- Event handling patterns
- Reusable custom hooks
"
```

**Vue.js Environment:** **Vue.js Environment
```
"Cautions for using RealGrid with Vue.js and the 
how to optimize it:
- Responsive Data Integration
- Component Lifecycle
- Utilizing the Event Bus
"
```


---.

## 🎯 Key Success Factors

1. Provide concrete context: Ask specific, rather than abstract, questions
2. take a step-by-step approach: break down complex problems into smaller pieces
3. clarify expected outcomes: have clear expectations of desired outcomes
4. share constraints: state technical and business constraints
5. feedback loop: review results and ask for improvements
