# 🎯 프로젝트별 지침 (ga_corp_vehicle 법인차량 관리 시스템)

🎯 실행 규칙

📐 10가지 핵심 공식(변수만 해당)

| # | 공식 | 주요 변수 |
| -- | | |
| 1 | 천재적 통찰력 | GI = (관찰 × 연결 × 패턴 × 통합) / (가정 + 편견) |
| 2 | 다차원 | 5가지 차원: 시간-공간-추상화-인과관계-위계 |
| 3 | 창의적 연결 | 직접 - 간접 - 역설 - 은유 - 시스템 연결 |
| 4 | 문제 재정의 | 180° 뒤집기 - 스케일 이동 - 개념 이동 - 도메인 이동
| 5 | 혁신 솔루션 | 결합-차용-제약→우위-역발상-시스템 재설계
| 6 | 통찰력 증폭 | 5가지 이유 - 만약에 - 어떻게 할 수 있을까?
| 7 <사고의 진화> 학습-경험-성찰-교환-실패 학습
| 8 | 복잡성 해결 | 분해 → 관계 매핑 → 레버리지 포인트 |
| 9 | 직관적 도약 | (침묵 × 경험 × 신뢰) / (논리 × 합리화) |
| 10 | 통합적 지혜 | (지식 + 이해 + 지혜 + 연민 + 행동) × 겸손 × 윤리 |



## 🔧 프로젝트 전용 지침 (Project-Specific Guidelines)

### 1. RealGrid 마스터-디테일 패턴 표준

```javascript
// ✅ 필수 구조
var f_search = function(isButtonClick) {
    if (isButtonClick === true || (isButtonClick && isButtonClick.type === 'click')) {
        // 1단계: 목록 재조회
        masterGridDP.clearRows();
        gf_gridSearch({
            gridView: masterGrid,
            param: _buildSearchParam(),
            callback: function() {
                var rowCount = masterGridDP.getRowCount();
                if (rowCount > 0) {
                    // 2단계: 첫 행 선택 (시각적 + 데이터)
                    masterGrid.setCurrent({ itemIndex: 0, column: 'key_field' }, true);
                    masterId = masterGrid.getValue(0, 'key_field');
                    
                    // 3단계: 상세 즉시 로드
                    _loadDetail();
                }
            }
        });
    } else {
        // 행 선택 변경 시: 상세만 로드
        _loadDetail();
    }
};

// onCurrentRowChanged에서는 _loadDetail만 호출
masterGrid.onCurrentRowChanged = function(grid, oldRow, newRow) {
    if (newRow >= 0) {
        masterId = grid.getValue(newRow, 'key_field');
        _loadDetail();
    }
};
```

**핵심 원칙**:
- 조회 함수는 `isButtonClick` 플래그로 "목록 갱신" vs "상세만 로드" 구분
- 목록 갱신 후 `callback` 내에서 첫 행 선택(`setCurrent`) + 상세 로드(`_loadDetail`) 순차 실행
- `setCurrent` 두 번째 파라미터 `true` → 포커스 이동 + `onCurrentRowChanged` 이벤트 발생 방지

---

### 2. JSP 기반 CRUD 트랜잭션 패턴

```javascript
// ✅ 저장 전 필수 커밋
if (masterGrid && masterGrid.commit) masterGrid.commit();
if (detailGrid && detailGrid.commit) detailGrid.commit();

// ✅ FormData 정리 규칙
for(var pair of formData.entries()) {
    // *_TEXT 제거 (콤보박스 표시용 필드)
    if (pair[0].endsWith('_TEXT')) formData.delete(pair[0]);
    // 날짜 정규화 (YYYY-MM-DD → YYYYMMDD)
    else if (pair[0].endsWith('_date')) {
        formData.set(pair[0], (pair[1] || '').replaceAll('-', ''));
    }
}

// ✅ 체크박스 → '1'/'0' 변환
$("#masterForm").find("input[type=checkbox]").each(function() {
    formData.set($(this).attr('name'), $(this).is(':checked') ? '1' : '0');
});

// ✅ 저장 후 재조회 + 선택 복원
var keepId = $('#key_field').val();
gf_allSave(saveOrder, formDataMap, function() {
    masterId = keepId;
    f_search(true); // 목록 재조회 → 첫 행 선택 → 상세 로드
});
```

**핵심 원칙**:
- 저장 전 모든 그리드 `commit()` 필수
- `*_TEXT`, `*_date` 필드 정규화
- 저장 후 재조회 시 이전 선택값(`keepId`) 복원

---

### 3. 검색 파라미터 엄격 필터링

```javascript
// ✅ undefined/null/''/공백 제거
function _clean(obj) {
    var out = {};
    Object.keys(obj).forEach(function(k) {
        var v = obj[k];
        if (v === undefined || v === null) return;
        if (typeof v === 'string' && v.trim() === '') return;
        out[k] = (typeof v === 'string') ? v.trim() : v;
    });
    return out;
}

// ✅ 체크박스 → undefined 처리 (서버 전체조회 방지)
var useYn = $('#s_use_yn').is(':checked') ? '1' : undefined;

var param = _clean({
    queryId: 'S_GA_CORP_VEHICLE_LIST_S',
    v_corporation_id: $('#comm_corporation_id').val(),
    v_vehicle_no: $('#s_vehicle_no').val(),
    v_use_yn: useYn // ← 체크 안 하면 key 자체를 제거
});
```

**핵심 원칙**:
- 빈 값 파라미터는 서버로 전송하지 않음
- 체크박스 미선택 시 `undefined` → key 제거 (서버에서 전체조회 방지)

---

### 4. 탭 그리드 초기화 규칙

```javascript
// ✅ 신규 버튼: 상세만 초기화, 목록 유지
var f_add = function() {
    if (confirm(gf_msg('new_reset_confirm'))) {
        masterId = '';
        $('#btn_delete').attr("disabled", true).addClass('disabled');
        f_clear_detail(); // 목록은 그대로
    }
};

var f_clear_detail = function() {
    if (driveGridDP) driveGridDP.clearRows();
    if (insGridDP) insGridDP.clearRows();
    if (repGridDP) repGridDP.clearRows();
    
    $('#ga_corp_vehicle_id').val('');
    $('#vehicle_no').attr('readOnly', false);
    gf_formClear(['masterForm']);
    
    // 기본값 재설정
    $('#comm_corporation_id').val(gv_login_corporation_id);
    $('#create_channel_code').val('ga006100');
    $('#use_yn').prop('checked', true);
    
    // 사진 초기화
    $('#ga_drive_pic_id').val('');
    $('#pic1,#pic2,#pic3').attr('style', '');
};
```

**핵심 원칙**:
- 신규: 상세만 초기화, 좌측 목록은 유지
- 삭제: 상세 초기화 + 목록 재조회
- 탭 그리드는 상세 ID(`ga_corp_vehicle_id`) 기준으로 연동

---

### 5. 디버깅 체크포인트

```javascript
// ✅ 조회 흐름 검증
console.log('[1] f_search 진입:', isButtonClick);
console.log('[2] 목록 조회 완료, rowCount:', masterGridDP.getRowCount());
console.log('[3] setCurrent 실행, itemIndex:', 0);
console.log('[4] masterId 갱신:', masterId);
console.log('[5] _loadDetail 호출');

// ✅ 상세 로드 검증
function _loadDetail() {
    console.log('[Detail] masterId:', masterId);
    if (!masterId) { 
        console.warn('[Detail] masterId 없음 → f_clear_detail');
        f_clear_detail(); 
        return; 
    }
    f_search_header();
    f_search_drive();
    f_search_ins();
    f_search_rep();
    f_search_pics();
}

// ✅ 이벤트 핸들러 검증
masterGrid.onCurrentRowChanged = function(grid, oldRow, newRow) {
    console.log('[Event] onCurrentRowChanged:', oldRow, '→', newRow);
    if (newRow >= 0) {
        masterId = grid.getValue(newRow, 'vehicle_no');
        console.log('[Event] masterId 갱신:', masterId);
        _loadDetail();
    }
};
```

**핵심 원칙**:
- 조회 → 선택 → 상세 로드 전 과정에 로그 삽입
- `masterId` 값 변화 추적
- 이벤트 핸들러 호출 여부 확인

---

## 📊 프로젝트 전용 체크리스트

### A. 코드 리뷰 시
- [ ] `f_search` 함수에 `isButtonClick` 플래그 있는가?
- [ ] 목록 조회 `callback` 내에서 `setCurrent` + `_loadDetail` 순차 호출하는가?
- [ ] `onCurrentRowChanged`에서 `_loadDetail`만 호출하는가?
- [ ] 저장 전 모든 그리드 `commit()` 호출하는가?
- [ ] `_clean()` 함수로 빈 파라미터 제거하는가?
- [ ] 체크박스 미선택 시 `undefined` 처리하는가?
- [ ] 저장 후 `keepId` 복원 로직 있는가?

### B. 디버깅 시
- [ ] 조회 버튼 클릭 → `f_search(true)` 호출 확인
- [ ] `masterGridDP.getRowCount()` 값 확인 (0이면 데이터 없음)
- [ ] `setCurrent` 호출 후 `masterId` 값 갱신 확인
- [ ] `_loadDetail` 진입 시 `masterId` 값 존재 확인
- [ ] 네트워크 탭에서 상세 조회 API 호출 확인
- [ ] 콘솔 에러/경고 메시지 확인

### C. 성능 개선 시
- [ ] 목록 조회 시 불필요한 컬럼 제거 (`SELECT *` 지양)
- [ ] 상세 조회 시 탭별 병렬 요청 고려 (`Promise.all`)
- [ ] 이미지 로드 시 Base64 → URL 방식 전환 고려
- [ ] 그리드 행 수 1,000+ 시 페이징/가상 스크롤 적용

---
