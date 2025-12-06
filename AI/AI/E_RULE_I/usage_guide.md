
---

# 🔌 Designing Guidelines to Maximize the Use of Electronics/Home Appliances

---

## 📋 [Step 1] Problem Analysis: Core Intent of the User’s Question

### Question Type Taxonomy

```python
QUESTION_TYPES = {
    "basic_usage": {
        "patterns": ["how to use", "how it works", "how to turn on"],
        "required_info": ["model name", "manufacturer", "purchase date"],
        "verification_items": ["check actual manual", "official YouTube video", "support center FAQ"]
    },
    
    "advanced_utilization": {
        "patterns": ["hidden features", "maximize use", "like a pro", "tips and tricks"],
        "required_info": ["usage purpose", "current utilization level", "desired outcome"],
        "verification_items": ["power-user communities", "expert reviews", "experiment results"]
    },
    
    "troubleshooting": {
        "patterns": ["doesn't work", "broken", "error", "acting weird"],
        "required_info": ["symptoms", "time of occurrence", "attempted fixes"],
        "verification_items": ["service-center data", "similar cases", "official troubleshooting"]
    },
    
    "purchase_advice": {
        "patterns": ["recommend", "compare", "which is better", "vs"],
        "required_info": ["budget", "usage environment", "priorities"],
        "verification_items": ["actual price comparison", "review statistics", "expert evaluations"]
    },
    
    "optimization_settings": {
        "patterns": ["settings", "setup", "adjustment", "tuning"],
        "required_info": ["current settings", "desired outcome", "constraints"],
        "verification_items": ["optimal value experiments", "environment measurements", "comparative tests"]
    }
}
```

---

## 🏗️ [Step 2] Core Information Schema by Product Category

### A. Information Collection Framework

```python
PRODUCT_INFO_FRAMEWORK = {
    "basic_info": {
        "required": ["manufacturer", "model name", "release year", "price range"],
        "verification": "official website URL + screenshot",
        "update": "check for new models quarterly"
    },
    
    "technical_specs": {
        "required": ["key performance metrics", "power consumption", "dimensions/weight", "connectivity"],
        "verification": "download manual PDF + excerpt key pages",
        "units": "SI units + layman-friendly analogies"
    },
    
    "real_world_data": {
        "sources": ["YouTube reviews", "Naver/Danawa user reports", "communities"],
        "verification": "cross-check at least 3 sources",
        "reliability": "verified purchases + long-term usage reviews prioritized"
    },
    
    "safety_info": {
        "required": ["warnings", "prohibited actions", "warranty coverage"],
        "verification": "KC certification, energy efficiency grade, recall history",
        "update": "check recall notices monthly"
    }
}
```

### B. Specialized Checklists by Product Family

#### 🖥️ Electronics (PC/Smartphone/Tablet)

```markdown
## Must-Check Items
- [ ] **Model accuracy**: down to specific variant (e.g., iPhone 15 Pro Max 256GB)
- [ ] **OS version**: latest/minimum supported versions
- [ ] **Compatibility**: peripherals, apps, service integrations
- [ ] **Update history**: firmware/software cadence and notes

## Verification Methods
1. Provide the official site spec sheet URL
2. Actual screen capture (Settings > About)
3. Benchmark scores (Geekbench, 3DMark, etc.)

## Maximization Checklist
- [ ] Access to hidden settings menus
- [ ] Battery life extension tips (with actual measurements)
- [ ] 10 productivity shortcuts (demo GIFs)
- [ ] Cloud integration optimization
- [ ] Routine maintenance schedule
```

#### 🏠 Home Appliances (Refrigerator/Washer/Air Conditioner)

```markdown
## Must-Check Items
- [ ] **Energy efficiency grade**: Level 1–5 + annual electricity cost estimate
- [ ] **Capacity/Dimensions**: measured size + installation clearance
- [ ] **Noise level**: dB measurements + everyday comparisons
- [ ] **Service network**: nationwide centers + average dispatch time

## Verification Methods
1. Verify Energy Management Corporation certification mark
2. Use a real power meter (e.g., watt checker)
3. Measure dB with a noise meter app
4. Screenshot manufacturer service center list

## Maximization Checklist
- [ ] Seasonal optimal settings (temperature/humidity table)
- [ ] Power-saving mode combinations
- [ ] Filter/consumable replacement cycle & cost
- [ ] Three smart home integration scenarios
- [ ] Self-check list to prevent breakdowns
```

#### 🍳 Kitchen Appliances (Air Fryer/Rice Cooker/Blender)

```markdown
## Must-Check Items
- [ ] **Cooking performance**: temperature accuracy, heating speed, capacity
- [ ] **Ease of cleaning**: detachable parts, dishwasher-safe or not
- [ ] **Safety features**: auto-off, overheat protection, child lock
- [ ] **Power consumption**: standby + in-operation power

## Verification Methods
1. Measure actual temperature with a thermometer
2. Time the cooking duration with a stopwatch
3. Photograph the disassembly process
4. Plot a power consumption graph

## Maximization Checklist
- [ ] Top 10 recipes (table of ingredients–time–temperature)
- [ ] Time-saving batch cooking methods
- [ ] Cleaning routines (daily/weekly/monthly)
- [ ] Tips to extend lifespan of consumables (pans, filters)
- [ ] Top 5 failure cases and fixes
```

---

## 🔍 [Step 3] Information Verification Protocol

### Three-Level Verification System

#### Level 1: Basic Verification (Mandatory)

```python
def basic_verification(product_info):
    """Verification that must be included in every answer"""
    
    checklist = {
        "1. cite_sources": {
            "requirements": "official website, manual, verified reviewers",
            "format": "[Source Name](URL) - checked on: YYYY-MM-DD",
            "example": "[Samsung Official](https://samsung.com/model123) - 2025-09-30"
        },
        
        "2. physical_confirmation": {
            "methods": ["product photos", "settings screen capture", "model sticker"],
            "forbidden": "stock images, mixing photos of other models",
            "alternative": "if using official images, clearly indicate"
        },
        
        "3. numeric_validation": {
            "all_numbers": "source + measurement method + unit",
            "example": "Noise 45 dB (manufacturer) / 48 dB measured (living room, app: Decibel X)",
            "tolerance": "allow only within ±10%; flag if exceeded"
        }
    }
    
    return checklist
```

#### Level 2: Experimental Verification (Recommended)

```markdown
## Reproducible Experiment Design

### Experiment 1: Performance Measurement
- **Materials**: [specific list]
- **Environment**: temperature 23±2℃, humidity 50±10%
- **Method**: [step-by-step details]
- **Expected results**: [value ranges]
- **Sample data**: 
  | Metric | Run 1 | Run 2 | Run 3 | Avg. |
  |--------|-------|-------|-------|------|
  | Heat-up time | 3:24 | 3:18 | 3:21 | 3:21 |

### Experiment 2: Comparative Test
- **Comparators**: [Product A vs Product B]
- **Controlled variables**: [list]
- **Independent variable**: [what differs]
- **Result table**: [measured values + chart]
```

#### Level 3: Community Verification (Optional)

```markdown
## Using Crowdsourced Data

### Reliability Criteria
1. **Sample size**: at least 30 user reviews
2. **Purchase verification**: ≥70% verified buyers
3. **Usage duration**: prioritize 3+ months long-term users
4. **Rating distribution**: focus on the median, exclude extremes (1★/5★)

### Data Sources
- Naver Shopping reviews (verified purchase filter)
- Danawa experience reports
- Clien/PPOMPPU community posts
- YouTube long-term reviews (10k+ views channels)

### Statistics
- Remove outliers (outside mean±2σ)
- Weighted average (1.5× weight for recent reviews)
- Show confidence intervals (95% CI)
```

---

## 🛠️ [Step 4] Answer Structure Template

### Standard Answer Format

````markdown
# [Product Name] Maximization Guide

---

## 🎯 Key Summary (30-second read)
- **Top 3 core features**: [one-liners]
- **Top 3 quick tips**: [immediately actionable]
- **Cautions**: [safety/warranty related]

---

## 📋 [Step 1] Basic Information Check

### Product Info Card
| Item | Details | Source |
|------|---------|--------|
| Manufacturer | Samsung Electronics | [Official Website](URL) ✅ |
| Model | RR39A7 | Product label photo ✅ |
| Release date | 2024-03 | Press release ✅ |
| Price range | ~1.5M KRW | Average of 3 price sites ✅ |

### Technical Specs (Verified)
```json
{
  "capacity": "385 L (measured 382 L, ±1%)",
  "power": "rated 150 W, 30 kWh/month (KEPCO meter ✅)",
  "noise": "45 dB (manufacturer) / 48 dB (measured, ±7%)",
  "dimensions": "595×1780×672 mm (leave +5 cm clearance on all sides)"
}
````

**Verification Log**:

* 2025-09-30 14:30 Checked official site → HTTP 200 OK
* 2025-09-30 15:00 Physical measurements completed → within ±3%
* 2025-09-30 16:00 Power measurement (watt checker) → 30-day average

````

---

## 🚀 [Step 2] Maximization Strategies

### Strategy 1: Master the Basics (Essential)

#### 1-1. Optimize Initial Setup
```markdown
⏱️ **Time required**: 15 minutes

**Step-by-step**:
1. Idle for 2 hours after power-on (refrigerant stabilization)
   - ✅ Check: alert tone when fridge reaches 5℃

2. Temperature settings
   - Fridge: 3℃ (summer 2℃, winter 4℃)
   - Freezer: -18℃ (recommended fixed)
   - 📊 Basis: Food safety guidelines + optimal electricity cost point

3. Humidity drawer settings
   - Vegetables: HIGH (90%)
   - Fruits: MID (70%)
   - 📸 [example settings image]
````

#### 1-2. Daily/Weekly/Monthly Routines

```markdown
✅ **Daily (1 min)**
- [ ] Door fully closed (magnet click)
- [ ] Temperature display within ±1℃
- [ ] Any frost buildup

📅 **Weekly (5 min)**
- [ ] Reorganize shelves (front↔back rotation)
- [ ] Check expiration dates
- [ ] Clean door gasket

📆 **Monthly (20 min)**
- [ ] Clean/replace filters
- [ ] Check drain for clogs
- [ ] Vacuum condenser dust
```

### Strategy 2: Use Hidden Features (Intermediate)

#### 2-1. Power-Cool Mode

```markdown
🎯 **Use cases**:
- After summer grocery runs (rapid cool-down for 30 min)
- Before guests arrive (quickly chill drinks)
- After power restoration (recover temperature)

⚠️ **Cautions**:
- Max continuous use: 4 hours
- Power use: +40% vs normal
- Recommended frequency: ≤5 times/month

📊 **Experiment data**:
| Mode | Time 20℃→5℃ | Power Use |
|------|--------------|-----------|
| Normal | 2 h 30 m | 0.8 kWh |
| Power Cool | 45 m | 1.2 kWh |
| Delta | -1 h 45 m (-70%) | +0.4 kWh (+50%) |

💡 **Tip**: Start 30 min before arriving home from shopping for best efficiency
```

#### 2-2. Smart Integration

```markdown
📱 **Required app**: SmartThings (Samsung account)

**Setup steps**:
1. Install app → find device → scan QR
2. Connect Wi-Fi (2.4 GHz required; 5 GHz unsupported)
3. Permissions: allow notifications + location (for Away mode)

**Three scenarios**:

🏡 **Scenario 1: Energy saving when away**
- Trigger: leave home radius 200 m (GPS)
- Action: switch to Eco (raise setpoint by +1℃)
- Effect: ~15% monthly bill reduction (measured)

🛒 **Scenario 2: Shopping reminder**
- Trigger: arrive near a supermarket (geofencing)
- Action: inventory alert (milk, eggs, etc.)
- Effect: avoids duplicate purchases

❄️ **Scenario 3: Temperature anomaly**
- Trigger: deviation beyond ±3℃ from setpoint
- Action: push + SMS
- Effect: prevents food spoilage
```

### Strategy 3: Pro-Level Optimization (Advanced)

#### 3-1. Temperature Zones by Shelf

```markdown
🌡️ **Measured temperature distribution** (IR thermometer)

[Fridge cross-section]
┌─────────────────┐
│   Top: 1–2℃    │ ← ice cream, frozen foods
├─────────────────┤
│   Middle: 3–4℃ │ ← dairy, side dishes
├─────────────────┤
│   Bottom: 5–6℃ │ ← vegetables, fruits
└─────────────────┘
     ↑ cold air flow

**Optimal placement**:
1. **Top (coldest)**: highly perishable
   - milk, yogurt, heavy cream
   - opened ham, cheese
   
2. **Middle (mid-cold)**: general foods
   - side-dish containers, kimchi
   - beverages (avoid door shelves!)

3. **Bottom (warmest)**: produce
   - leafy greens (airtight containers)
   - root vegetables (wrap in paper)

📊 **Impact of rearrangement**:
- Shelf life extension: +2 days average
- Freshness: +25% (sensory panel)
- Electricity bill: −8% (improved airflow)
```

#### 3-2. Advanced Troubleshooting

```markdown
## Troubleshooting Flowchart

### 🚨 Symptom 1: Fridge not getting cold
```

Start
↓
Check temperature setting (≤3℃?)
├─ NO → Lower temp → Wait 2 hours
└─ YES
↓
Check door sealing (gasket tight?)
├─ NO → Remove debris → Recheck
└─ YES
↓
Check vent clearance (≥10 cm behind?)
├─ NO → Reposition
└─ YES
↓
Contact service center (1588-XXXX)

````

**Self-diagnosis Checklist**:
```markdown
- [ ] Power plug seated (no cord damage)
- [ ] Room temperature (performance drops >35℃)
- [ ] Load level (≤70% recommended)
- [ ] Recent outage history (refrigerant cycle restart)
- [ ] Filter replacement interval (replace after 6 months)

📸 **Attachments for service request**:
1. Temperature display
2. Full view of interior
3. Product label (model/serial)
4. Installation environment (rear clearance)
````

---

## 📊 [Step 3] Performance Comparison & Alternatives

### Peer Product Comparison Table

| Item                 | Current   | Competitor A | Competitor B | Notes          |
| -------------------- | --------- | ------------ | ------------ | -------------- |
| Price                | 1.5M KRW  | 1.45M KRW    | 1.6M KRW     | ±50k KRW       |
| Capacity             | 385 L     | 370 L        | 400 L        | usable basis   |
| Monthly bill         | 9,000 KRW | 9,500 KRW    | 8,500 KRW    | KEPCO rate     |
| Noise                | 48 dB     | 50 dB        | 45 dB        | measured       |
| Service satisfaction | 4.2/5.0   | 3.8/5.0      | 4.5/5.0      | 1,000+ reviews |
| Overall              | ⭐⭐⭐⭐      | ⭐⭐⭐          | ⭐⭐⭐⭐⭐        | -              |

**Verification Sources**:

* Price: averages from [Danawa](URL), [Naver Shopping](URL), [Gmarket](URL) (as of 2025-09-30)
* Electricity: each brand’s energy efficiency certificate + average of 30 user logs
* Service: Naver Shopping review statistics (last 1 year)

### Alternative Recommendation Logic

```python
def recommend_alternative(user_needs, current_product):
    """Recommend alternatives by user priority"""
    
    recommendations = []
    
    if user_needs["priority"] == "electricity_bill":
        recommendations.append({
            "product": "Competitor B model",
            "reason": "Saves ~500 KRW/month (6,000 KRW/year)",
            "extra_cost": "+100,000 KRW",
            "payback_period": "16.7 months",
            "conclusion": "Better if used ≥2 years"
        })
    
    elif user_needs["priority"] == "low_noise":
        recommendations.append({
            "product": "Competitor B model",
            "reason": "Measured 45 dB (−3 dB vs current)",
            "perceived_diff": "No TV interference in living room",
            "extra_cost": "+100,000 KRW",
            "conclusion": "Essential for studio/open-plan living rooms"
        })
    
    return recommendations
```

---

## ⚠️ [Step 4] Safety and Cautions

### Safety Checklist (Top Priority)

```markdown
## 🚫 Absolutely Do Not

1. **Fire hazards**
   - ❌ Use of extension cords (plug directly into wall)
   - ❌ Use of power strips (dedicated 15 A or higher only)
   - ❌ Objects within 10 cm of the rear (ventilation required)

2. **Electric shock**
   - ❌ Handling plugs with wet hands
   - ❌ Installing near water (avoid near sink)
   - ❌ Using damaged cables

3. **Warranty void actions**
   - ❌ Unauthorized disassembly (refrigerant leak risk)
   - ❌ Non-genuine filters
   - ❌ Modifications or out-of-scope use

## ⚡ Emergency Response

### Case 1: Suspected refrigerant leak (unusual odor)
1. Cut power immediately
2. Open windows (ventilate)
3. Request emergency service dispatch (1588-XXXX)
4. Do not consume stored food

### Case 2: Electrical sparks
1. Cut power (use thick gloves)
2. Prepare extinguisher (ABC powder)
3. Call emergency services (as fire risk)

### Case 3: Power outage
1. Keep doors closed (cold retained ~4 hours)
2. After recovery, idle for 2 hours
3. Reconfirm temperature settings
```

---

## 📞 [Step 5] Support & Resources

### Official Support Channels

```markdown
## Manufacturer Contacts

### 📞 Call Center
- **Phone**: 1588-3366 (24/7, year-round)
- **Agent availability**: 
  - Weekdays: 09:00–18:00 (specialists)
  - Nights/Weekends: IVR system
- **Avg. wait time**: ~3 minutes (measured)
- **Languages**: Korean, English

### 💬 Online Support
- **KakaoTalk**: @SamsungService ([Quick Link](URL)) ✅
  - Avg. response: ~5 minutes
  - Photo upload supported (for diagnosis)
- **Website Chatbot**: [Contact Us](URL)
  - AI first response → escalate to agent as needed
- **Email**: support@samsung.com
  - Response within 24 hours

### 🏢 Service Center Visit
**Reservation required** (to reduce wait time)

#### Major Centers in Seoul
| Area | Address | Hours | Booking URL |
|------|---------|-------|-------------|
| Gangnam | 123 Teheran-ro, Gangnam-gu | Weekdays 09:00–19:00 | [Book](URL) ✅ |
| Gangbuk | 456 Sejong-daero, Jongno-gu | Weekdays 09:00–18:00 | [Book](URL) ✅ |
| Yeongdeungpo | 789 Yeoui-daero, Yeongdeungpo-gu | Weekdays 10:00–19:00 | [Book](URL) ✅ |

**Bring with you**:
- [ ] Warranty card
- [ ] Proof of purchase (date visible)
- [ ] ID
- [ ] Symptom video (optional)

### 📱 Mobile App Support
**SmartThings app features**:
- Remote diagnostics: AI auto-analysis
- Parts ordering: filters, shelves, etc.
- Usage stats: power, door opens, etc.
- Service booking: in-app request

**Download**:
- [iOS](https://apps.apple.com/...) ✅ HTTP 200
- [Android](https://play.google.com/...) ✅ HTTP 200
```

요청하신 부분을 **영문으로 완전 번역**했어요. 원문 구조·이모지·코드블록·체크리스트 표기를 그대로 유지했습니다.

---

### Community Resources

```markdown
## 👥 User Communities

### Top 3 Recommended Communities
1. **Clien – Home Appliances Board**
   - URL: https://www.clien.net/service/board/jirum ✅
   - Features: Expert answers, real-world tips
   - Activity: ~50 posts per day
   - Reliability: ⭐⭐⭐⭐⭐

2. **PPOMPPU – Refrigerator Gallery**
   - URL: https://www.ppomppu.co.kr/... ✅
   - Features: Price intel, deal alerts
   - Activity: ~10 comments per hour
   - Reliability: ⭐⭐⭐⭐

3. **Naver Cafe – Queen of Housekeeping**
   - URL: https://cafe.naver.com/... ✅
   - Features: Practical know-how from household pros
   - Members: 500K+
   - Reliability: ⭐⭐⭐⭐

### 📺 Recommended YouTube Channels
1. **Review King** (1.2M subscribers)
   - Professional reviewer, experimental content
   - [Refrigerator comparison video](URL) 5M views
   
2. **Appliance Encyclopedia** (800K subscribers)
   - Run by a service engineer; repair tips
   - [Troubleshooting series](URL) 30 episodes

3. **Housekeeping Know-how** (500K subscribers)
   - Home creator, practical tips
   - [Fridge organizing guide](URL) 2M views
```

---

## 📚 [Step 6] Additional Learning Materials

### Official Manuals & Documents

```markdown
## 📖 Must-Read Materials

### 1. User Manual (Korean)
- **Download**: [Direct PDF link](https://samsung.com/manual/RR39A7_KR.pdf) ✅
- **File size**: 15 MB
- **Pages**: 48
- **Key Sections**:
  - p.5–12: Installation guide
  - p.13–25: Feature descriptions
  - p.26–35: Usage tips
  - p.36–45: Troubleshooting
  - p.46–48: Specifications

**Key Page Excerpt**:
```

[p.18] Quick Freeze Function

* Operation: Press and hold the freezer button for 3+ seconds
* Duration: Auto-off after 4 hours
* Power Consumption: ~+30% vs normal
* Recommended Use: Preserving fresh foods

```

### 2. Energy Efficiency Certificate
- **Issuing body**: Korea Energy Agency
- **Grade**: Level 1 (best of 5 levels)
- **Annual consumption**: 350 kWh/year
- **How to verify**: [Certificate lookup](URL) ✅

### 3. Safety Certification (KC Mark)
- **Certification No.**: KC-XXXXX
- **Validity**: 2024-03 ~ 2029-03
- **Testing org**: Korea Testing Certification (KTC)
- **Verification**: Rear product label or [online search](URL) ✅
```

### Advanced Learning Track

```markdown
## 🎓 Step-by-Step Learning Roadmap

### Level 1: Beginner (Week 1)
**Goal**: Safe, basic operation

- [ ] Day 1–2: Read the manual once
- [ ] Day 3–4: Initial setup and temperature check
- [ ] Day 5–6: Daily checklist practice
- [ ] Day 7: Weekly cleaning routine

**Quick Quiz**:
1. Recommended fridge temperature? (A: 3℃)
2. How to check if the door is sealed properly?
3. Why keep the door closed during a power outage?

### Level 2: Intermediate (Weeks 2–4)
**Goal**: Efficient use & power saving

- [ ] Week 2: Connect and use the mobile app
- [ ] Week 3: Measure shelf temperatures & optimize placement
- [ ] Week 4: Monitor power consumption

**Hands-on Tasks**:
1. Compare current vs optimized electricity costs
2. Before/After photos of food placement
3. One-month usage report

### Level 3: Advanced (Weeks 5–8)
**Goal**: Pro-level optimization

- [ ] Weeks 5–6: Master preventive maintenance
- [ ] Week 7: Automate seasonal settings
- [ ] Week 8: Engage community (share experiences)

**Master Project**:
- Write your own maximization guide
- Post a review (Naver/Danawa)
- Be able to teach others confidently
```

---

## 🔄 [Step 7] Continuous Improvement Framework

### Update Tracking System

```markdown
## 📅 Keeping Information Fresh

### Auto Checkpoints
- **Quarterly (3 months)**:
  - [ ] New model releases
  - [ ] Firmware updates
  - [ ] Price changes
  
- **Semiannually (6 months)**:
  - [ ] User review trend analysis
  - [ ] Competitor new product comparison
  - [ ] Changes in service policies
  
- **Annually (12 months)**:
  - [ ] Full guide revision
  - [ ] Incorporate community feedback
  - [ ] Reevaluate energy efficiency grade

### Change Log
| Date | Item | Change | Source |
|------|------|--------|--------|
| 2025-09-30 | Price | 1.5M → 1.45M KRW | [Danawa](URL) ✅ |
| 2025-08-15 | Firmware | v2.1 → v2.2 | [Official notice](URL) ✅ |
| 2025-07-01 | Service | Warranty 1y → 2y | [Support Center](URL) ✅ |
```

### User Feedback Loop

```markdown
## 💬 Improvement Suggestion System

### How to Submit Feedback
1. **Error Report**:
   - Format: "Page location + error details + correct info"
   - Example: "Step 2 says 5℃, but manual p.18 says 3℃."
   - Verification: review and fix within 24 hours

2. **Share Usage Tips**:
   - Format: "Scenario + method + effect + evidence"
   - Example: "Power Cool 30 min before shopping → +1 day freshness (photos)"
   - If adopted: included in the guide + credit

3. **Submit Questions**:
   - Topics not covered in the FAQ
   - Community response within 24 hours
   - Verified answers added to the guide

### Prioritization
1. 🔴 **Critical (Immediate)**: Safety-related errors
2. 🟡 **Important (1 week)**: Major feature description errors
3. 🟢 **Normal (1 month)**: Usability improvements
```

---

## ✅ [Step 8] Final Checklist

### Self-Assessment for Answer Quality

```markdown
## 🎯 Completion Score (out of 100)

### Mandatory (60 pts)
- [ ] (10) Product info accuracy — ≥3 sources
- [ ] (10) Numbers/specs verified — measured or official
- [ ] (10) URL validity — HTTP 200 confirmed
- [ ] (10) Safety info — warnings/prohibitions included
- [ ] (10) Media — ≥5 images/videos
- [ ] (10) Structured steps — complete Step 1–8

### Bonus (40 pts)
- [ ] (10) Experimental/measurement data — reproducible
- [ ] (10) Comparative analysis — ≥3 peer products
- [ ] (10) Community validation — analyze ≥30 reviews
- [ ] (10) Learning materials — staged roadmap

### Deductions
- (−5) Claims without sources
- (−10) Unverified numbers
- (−20) Missing safety info
- (−30) Critical misinformation

**Passing Score**: ≥80
```

### Final Pre-Submission Check

```python
def final_check_before_submit(answer):
    """Last validation before submission"""
    
    checklist = {
        "1. accuracy": {
            "Click-test all URLs": "✅ done",
            "Recalculate numbers": "✅ done",
            "Date format unified": "YYYY-MM-DD ✅"
        },
        
        "2. safety": {
            "Prohibitions listed": "✅ ≥3 items",
            "Emergency responses": "✅ by scenario",
            "Warranty-void warnings": "✅ included"
        },
        
        "3. readability": {
            "Heading hierarchy": "✅ H1–H3",
            "Tables/lists used": "✅ ≥10",
            "Code block formatting": "✅ indentation checked",
            "Emoji usage": "✅ one per section"
        },
        
        "4. completeness": {
            "All Steps 1–8 covered": "✅",
            "Checklist completed": "✅",
            "Reference links": "✅ ≥10",
            "Update date": "✅ 2025-09-30"
        }
    }
    
    # Auto validation script
    errors = []
    
    # URL validation
    urls = extract_urls(answer)
    for url in urls:
        if not check_url_status(url) == 200:
            errors.append(f"Invalid URL: {url}")
    
    # Required sections
    required_sections = ["Basic Information", "Maximization", "Safety Notes"]
    for section in required_sections:
        if section not in answer:
            errors.append(f"Missing section: {section}")
    
    return {
        "ready_to_submit": len(errors) == 0,
        "errors": errors,
        "checklist": checklist
    }
```

---

## 🎯 TL;DR

### Three Core Principles of This Guideline

```markdown
1. **Verify First**
   - Every piece of info needs sources + a verification log
   - Avoid guessy language like “probably,” “usually”
   - URLs must return HTTP 200; numbers must be measured or official

2. **Safety First**
   - Always include a safety section
   - State prohibitions and emergency responses
   - Warn about warranty-void actions

3. **Actionable**
   - Provide step-by-step checklists
   - Design reproducible experiments
   - Prioritize immediately applicable tips
```

### Quick-Reference Answer Template

```markdown
# [Product Name] Ultimate Utilization Guide

## 🎯 30-Second Summary
- Three core features
- Top 3 tips
- One key caution

## 📋 [Step 1] Product Info (Verified)
- Manufacturer/model/release date + sources
- Spec table + measured values
- Price comparison (3-site average)

## 🚀 [Step 2] Utilization Strategies
- Basic mastery (beginner)
- Hidden features (intermediate)
- Pro optimization (advanced)

## ⚠️ [Step 3] Safety Notes
- Strict prohibitions
- Emergency procedures
- Warranty guidance

## 📞 [Step 4] Support Channels
- Official support
- Communities
- Learning materials

## ✅ [Verification Log]
- 2025-09-30 14:00 Data collected
- 2025-09-30 16:00 Experiments completed
- 2025-09-30 18:00 Cross-checked
```

---

## 📎 Appendix: Practical Example

### Case Study 1: Air Fryer Utilization Guide

````markdown
# Philips Air Fryer XXL (HD9650) Ultimate Utilization Guide

## 🎯 30-Second Summary
- **Key features**: 200℃ high-temp circulation, 1.4 kg capacity, 7 auto menus
- **Tips**: ① 3-minute preheat ② Flip halfway ③ Use oil spray
- **Caution**: Do not use plastic containers (melting risk)

## 📋 [Step 1] Product Info Verification

### Product Info Card
| Item | Details | Verified |
|------|---------|----------|
| Manufacturer | Philips | [Official site](https://philips.co.kr) ✅ |
| Model | HD9650/91 | Bottom label photo ✅ |
| Capacity | 1.4 kg (basket measured 1.38 kg) | Scale measurement ✅ |
| Power | 2000 W (measured 1950 W, −2.5%) | Watt checker ✅ |
| Price | ~230K KRW | [Avg. of 3 price sites](URL) ✅ |

### Temperature Accuracy Test
**When**: 2025-09-30 15:00  
**Instrument**: K-type thermocouple (±1℃)  
**Env**: 23℃ room, 55% RH

| Set Temp | Actual | Error | Time-to-temp |
|---------|--------|-------|--------------|
| 160℃ | 158℃ | −1.3% | 3m 45s |
| 180℃ | 177℃ | −1.7% | 4m 10s |
| 200℃ | 196℃ | −2.0% | 4m 30s |

**Conclusion**: Excellent; within ±2% ✅

## 🚀 [Step 2] Maximization

### Recipe Optimization (Experiment-Backed)

#### 🍗 Recipe 1: Perfect Chicken Wings

**Ingredients (4 servings)**:
- 1 kg chicken wings
- 1 tbsp cooking oil (spray preferred)
- 1 tsp salt, pinch of pepper

**Step-by-step**:
```markdown
⏱️ Total: 25 minutes

1. Prep (5 min)
   - Dry wings completely (paper towel)
   - Season with salt & pepper
   - Light oil spray

2. Cook 1 (12 min)
   - Temp: 180℃
   - Time: 12 min
   - Flip at 6 min ⚠️ mandatory

3. Cook 2 (8 min)
   - Temp: 200℃
   - Time: 8 min
   - Crisp the skin

4. Rest (2 min)
   - Remove and rest
   - Residual heat finishes cooking
````

**Results** (3 runs):

| Run | Exterior Crisp | Interior Juiciness | Overall    |
| --- | -------------- | ------------------ | ---------- |
| 1   | 8/10           | 9/10               | 8.5/10     |
| 2   | 9/10           | 8/10               | 8.5/10     |
| 3   | 9/10           | 9/10               | 9.0/10     |
| Avg | **8.7**        | **8.7**            | **8.7/10** |

**Common Failures & Fixes**:

* ❌ No flipping → one side burns, other undercooked
* ✅ Flip at 6 min → even doneness
* ❌ No oil → tough skin
* ✅ Use spray → crisp yet moist

### 10 Pro Tips

```markdown
💡 **Tip 1: Preheating is non-negotiable**
- Why: reduces temp variance; accurate timing
- How: 3 min at 180℃ with empty basket
- Effect: −50% failure rate (verified)

💡 **Tip 2: No overloading (70% rule)**
- Fill only up to 70% of basket capacity
- Ensure airflow space
- Before/After:
  [100% load: undercooked inside] vs [70%: perfect]

💡 **Tip 3: Mid-cook check**
- Open at halfway point
- Flip + optional oil respray
- Adjust temp/time if needed

💡 **Tip 4: Optimal temps by ingredient**
| Item | Temp | Time | Notes |
|------|------|------|------|
| Fries | 200℃ | 15 min | Shake midway |
| Pork belly | 180℃ | 12 min | High fat → fire caution |
| Bread warm-up | 160℃ | 3 min | Cover with foil |
| Frozen foods | 200℃ | Label + 2 min | Preheat required |
```


---

## 🏁 Final Takeaway

By following this guideline:

✅ **Accuracy**: All information verified  
✅ **Safety**: Risks mitigated in advance  
✅ **Actionability**: Step-by-step, immediately usable  
✅ **Sustainability**: Built-in update system  

**Implementation Checklist**:
- [ ] Collect product info (≥3 sources)
- [ ] Run experiments/measurements (reproducible)
- [ ] Write safety section (with prohibitions)
- [ ] Validate URLs (HTTP 200)
- [ ] Complete final checklist (≥80 points)

**May this guideline help you unlock the full value of your electronics and appliances!** 🚀

---
