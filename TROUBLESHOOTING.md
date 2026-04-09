# RainDrop Windows 트러블슈팅 가이드

## 실행이 안 될 때

### 증상 1: exe를 더블클릭해도 아무 반응 없음

**원인**: Visual C++ Redistributable 미설치

Flutter Windows 앱은 `vcruntime140.dll`과 `msvcp140.dll`에 의존합니다. 이 런타임이 없으면 에러 팝업 없이 조용히 실패합니다.

**해결**:

PowerShell(관리자 권한)에서:
```powershell
winget install Microsoft.VCRedist.2015+.x64
```

또는 직접 다운로드:
- https://aka.ms/vs/17/release/vc_redist.x64.exe

설치 후 `raindrop_flutter.exe`를 다시 실행하세요.

---

### 증상 2: "VCRUNTIME140.dll을 찾을 수 없습니다" 에러

**해결**: 증상 1과 동일 — Visual C++ Redistributable 설치.

---

### 증상 3: Windows Defender가 차단

**증상**: "Windows에서 PC를 보호했습니다" 또는 SmartScreen 경고

**해결**:
1. "추가 정보" 클릭
2. "실행" 클릭

이 앱은 코드 서명이 되어있지 않아 Windows가 경고를 표시합니다. 안전한 앱입니다.

---

### 증상 4: 창은 뜨는데 검정/흰 화면만 보임

**가능한 원인**:
- GPU 드라이버 문제
- DirectX 미지원

**해결**:
```powershell
# 소프트웨어 렌더링 모드로 실행
set FLUTTER_SKIA_DETERMINISTIC_RENDERING=1
raindrop_flutter.exe
```

또는 GPU 드라이버를 최신으로 업데이트하세요.

---

### 증상 5: 창이 뜨다가 바로 꺼짐 (크래시)

**해결**:
1. 명령 프롬프트에서 실행하여 에러 로그 확인:
```powershell
cd RainDrop-Windows
.\raindrop_flutter.exe
```
2. 에러 메시지를 확인하고 GitHub Issues에 보고:
   https://github.com/mgm136044/RaindropFlutter/issues

---

### 증상 6: DLL 누락 에러 (flutter_windows.dll 등)

**원인**: exe만 복사하고 나머지 파일을 안 가져옴

**해결**: `RainDrop-Windows.zip`의 **모든 파일**을 같은 폴더에 압축 해제해야 합니다.

```
RainDrop-Windows/
├── raindrop_flutter.exe    ← 실행 파일
├── flutter_windows.dll     ← 필수!
├── data/                   ← 필수!
└── *.dll                   ← 필수!
```

---

## 설치 방법

1. [Releases 페이지](https://github.com/mgm136044/RaindropFlutter/releases)에서 `RainDrop-Windows.zip` 다운로드
2. 원하는 폴더에 **전체 압축 해제**
3. `raindrop_flutter.exe` 실행
4. 실행 안 되면 [Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe) 설치 후 재시도

## 시스템 요구사항

- Windows 10 이상 (64비트)
- Visual C++ Redistributable 2015-2022
- 약 50MB 디스크 공간

## 문제 보고

해결되지 않는 문제는 GitHub Issues에 보고해 주세요:
https://github.com/mgm136044/RaindropFlutter/issues

보고 시 포함할 정보:
- Windows 버전 (`winver` 명령어로 확인)
- 에러 메시지 (있으면)
- 스크린샷
