

# 🤖 AI Execution Guidelines v1.0 for Writing GitLab Guidelines

📋 Core Principles

Purpose: Systematic thinking and structured document creation when writing GitLab guidelines
Scope: DevOps platform documentation tasks
Core Approach: Role-based + stage-based + integrated scenarios



🎯 Step 1: Problem Redefinition

Break Down the Original Question


"How should we create GitLab guidelines?"
↓
- How should we decompose GitLab’s complexity layers (infrastructure/operations/development/collaboration)?
- How should we integrate role-based perspectives (DevOps/Developer/PM/Admin)?
- How should we design stage links (Build → Operate → Use)?


Redefinition Techniques

    - Opposite Perspective: Rotate 180°
    - Scale Adjustment: Zoom 0.1x ~ 10x
    - Concept Shift: Move up/down ±1~3 levels
    - Domain Transfer: Borrow solutions from other fields
    - Time-Axis Change: Past/Present/Future perspectives



📊 Step 2: Multi-Dimensional Analysis

Essential Analysis Dimensions

| Dimension          | Description                                                         | Weight |
| ------------------ | ------------------------------------------------------------------- | ------ |
| **D1 Time**        | Initial setup → Stabilization → Scaling → Optimization              | High   |
| **D2 Space**       | Local → Team → Organization → Multi-cloud                           | Medium |
| **D3 Abstraction** | Infrastructure layer → Platform layer → User layer                  | High   |
| **D4 Causality**   | Requirements → Design → Implementation → Verification → Improvement | High   |
| **D5 Hierarchy**   | Micro → Meso → Macro                                                | Medium |

---

🏗️ Document Structure Design

3 Key Design Principles


Modularity:
  - Independent documents by role/stage
  - Each section runnable in isolation
  
Verifiability:
  - Include a verification step in every procedure
  - Pattern: "Install → Verify → Troubleshoot"
  
Actionability:
  - Copy-pasteable code/commands
  - Provide actually executable scripts




📚 Standard Document Structure (TOC)


Part 0: Getting Started
├── 0.1 What is GitLab?
├── 0.2 Glossary
├── 0.3 Architecture Overview
└── 0.4 Role-based Roadmap

Part 1: Build (Infrastructure)
├── 1.1 Requirements Analysis
│   ├── HW Sizing Calculator
│   ├── Network Requirements
│   └── Storage Design
├── 1.2 Installation Methods
│   ├── Omnibus (recommended for small/medium)
│   ├── Docker Compose (recommended for dev)
│   ├── Kubernetes (recommended for large/HA)
│   └── Cloud-managed
├── 1.3 Initial Configuration
└── 1.4 Build Verification

Part 2: Operations
├── 2.1 Backup/Restore
├── 2.2 Monitoring
├── 2.3 Upgrades
├── 2.4 User Management
└── 2.5 Incident Response

Part 3: Team Usage
├── 3.1 Project Structure
├── 3.2 Git Workflow
├── 3.3 CI/CD Pipeline
├── 3.4 Issues/Epics
└── 3.5 Security

Part 4: Advanced Topics
└── HA, Multi-Region, Performance Tuning, etc.

Appendix
├── A. Troubleshooting Index
├── B. Checklists
├── C. Script Library
└── D. References




🎨 Mandatory Authoring Patterns

Pattern 1: Before-Action-Verify


📌 Before (Preparation)
   └─ Check prerequisites

🔧 Action (Execution)
   └─ Step-by-step commands/config

✅ Verify (Validation)
   └─ Define success criteria


Pattern 2: Decision Tree


Choose Installation Method
  ├─ Fewer than 100 users? → Omnibus
  ├─ Development/Test? → Docker Compose
  ├─ Production + HA? → Kubernetes
  └─ Minimize ops burden? → Cloud-managed


Pattern 3: Progressive Disclosure


Getting Started with CI/CD (Beginner)
Basic pipeline: build only

<details>
<summary>🔽 Intermediate: Add Tests</summary>
How to add a test stage...
</details>

<details>
<summary>🔽 Advanced: Multi-stage Deployment</summary>
Separate staging/production...
</details>




✅ Required Elements per Section

Example Structure: Installation Guide


# 1. Prerequisites Checklist
- [ ] OS: Ubuntu 22.04 LTS
- [ ] CPU: min 4 cores (8 cores recommended)
- [ ] RAM: min 8GB (16GB recommended)
- [ ] Disk: min 50GB SSD
- [ ] Ports: Open 80, 443, 22

# 2. Quick Install (5 minutes)
#!/bin/bash
[Executable script]

# 3. Installation Verification (3 steps)
Step 1: Service status
sudo gitlab-ctl status

Step 2: Web UI accessibility
curl -k https://gitlab.example.com

Step 3: Health check
sudo gitlab-rake gitlab:check

# 4. Initial Security Hardening
[Enforce HTTPS, firewall, backup configuration]

# 5. Troubleshooting
| Symptom | Cause | Solution |




🔧 Applied Thinking Formulas

Selected Formulas

1. Complexity Resolution Matrix (CS)

   * Decompose the system into infrastructure/operations/usage
   * Map relationships among subcomponents
   * Identify key leverage points

2. Problem Redefinition Algorithm (PR)

   * From “how to write guidelines” → to “role-based + stage-integrated design”
   * Apply perspective rotation, scale adjustment, concept shift

3. Multi-Dimensional Analysis (MDA)

   * Structure time/space/abstraction/causality/hierarchy
   * Sum each dimension’s insight (Di) × weight (Wi) × impact (Ii)

4. Integrated Wisdom (IW)

   * Balance knowledge (K) + action (A) + ethics/security (E)



📝 Metadata Management


# Document Properties
version: "1.0.0"
last_updated: "2025-09-30"
gitlab_versions: ["16.x", "17.x"]
contributors: [DevOps Team, Security Team]
review_cycle: "quarterly"
feedback_url: "https://gitlab.example.com/docs/issues"




🎯 Final Verification Checklist


- [ ] Role-based: Can each role quickly find what they need?
- [ ] Stage-linked: Do Build → Operate → Use stages flow naturally?
- [ ] Verifiability: Does every procedure include “how to confirm it works”?
- [ ] Actionability: Are code/commands copy-paste runnable?
- [ ] Troubleshooting: Are common errors and solutions included?
- [ ] Sustainability: Is there a process to update docs on version upgrades?




💡 Additional Recommendations

1. Add Interactive Elements


🧮 Sizing Calculator
Number of users: [input]
Concurrent usage rate: [input] %
→ Recommended Spec: 16 CPU / 64GB RAM / 500GB SSD


2. Provide a Hands-on Environment


# Try GitLab in 5 minutes with Docker Compose
git clone https://gitlab.com/gitlab-org/gitlab-foss.git
cd gitlab-foss/docker
docker-compose up -d


3. Link Video Tutorials


📹 [Install GitLab in 5 Minutes](https://youtube.com/watch?v=xxx)
📹 [Create Your First CI/CD Pipeline](https://youtube.com/watch?v=yyy)




🚫 Prohibited Patterns


❌ “Consult an expert” (without concrete analysis)
❌ “It depends” (without detailed breakdown)
❌ Speculative phrasing like “maybe,” “usually,” “generally”
❌ Evasive lines like “I’m not sure,” “I’m not an expert…”




📌 Key Summary

Authoring Sequence:

1. Problem Redefinition (role/stage decomposition)
2. Multi-Dimensional Analysis (time/space/abstraction/causality/hierarchy)
3. Structure Design (modularity/verifiability/actionability)
4. Apply Patterns (Before–Action–Verify)
5. Verification & Metadata Management

Output Criteria:

    - All commands must be executable
    - Every procedure must include a verification step
    - Each section must be usable independently
    - Troubleshooting is mandatory
