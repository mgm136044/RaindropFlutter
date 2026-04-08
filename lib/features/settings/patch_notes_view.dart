import 'package:flutter/material.dart';
import 'package:raindrop_flutter/core/utils/app_constants.dart';
import 'package:raindrop_flutter/shared/components/glass_container.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

class _PatchNote {
  final String version;
  final String date;
  final List<String> changes;

  const _PatchNote({
    required this.version,
    required this.date,
    required this.changes,
  });
}

class PatchNotesView extends StatelessWidget {
  const PatchNotesView({super.key});

  static const List<_PatchNote> _notes = [
    _PatchNote(version: '2.1.1', date: '2026.04.08', changes: [
      'wave 애니메이션 간헐적 멈춤 수정 (animatableData 격리)',
    ]),
    _PatchNote(version: '2.1.0', date: '2026.04.08', changes: [
      'Apple 디자인 철학 적용 — 단일 악센트 블루, 순수 검정 배경',
      'macOS 26 Liquid Glass 전면 적용 (버튼, 헤더, 필, 배너)',
      '모달 헤더 Apple 스타일 — 중앙 타이틀 + 완료 버튼',
      '양동이 탭 시 물 물리 반응 (관성 슬로싱)',
      '모든 양동이에 인터랙션 적용 (메인, 주간, 스티커 편집, 온보딩)',
      '타이머+정보 필 통합 캡슐 (세션 중 Glass.clear)',
      'deprecated onChange API 전체 마이그레이션',
      '색상 시스템 간소화 (30개 → 8개 코어 + 레거시 별칭)',
    ]),
    _PatchNote(version: '2.0.3', date: '2026.04.08', changes: [
      '업데이트 무한 루프 수정 (앱 버전 불일치 해소)',
      '업데이트 시 brew 미설치 감지 + 에러 알림',
      '업데이트 실패 시 macOS 알림으로 안내',
      '업데이트 중 로딩 오버레이 정상 표시',
    ]),
    _PatchNote(version: '2.0.2', date: '2026.04.08', changes: [
      '스티커 시스템 재구축 — 별도 편집 화면으로 분리',
      '스티커 배치: 팔레트에서 탭으로 추가',
      '스티커 삭제: 리스트에서 개별/전체 삭제',
      '스티커 위치: 프리뷰에서 드래그로 조정',
    ]),
    _PatchNote(version: '2.0.1', date: '2026.04.07', changes: [
      '타이머 UI 텍스트/버튼 크기 확대 (가독성 향상)',
    ]),
    _PatchNote(version: '2.0.0', date: '2026.04.07', changes: [
      '"채움으로 삶의 밀도를 기록한다" — 전면 UI/UX 개편',
      '양동이 중심 레이아웃 (ZStack 오버레이 구조)',
      '동적 비 강도 — 진행도에 따라 이슬비→폭우',
      '3중 사인파 물 + 수면 반사 + 물방울 튀김',
      '진행도별 하늘 변화 (새벽→흐림→폭풍→개임)',
      '양동이 넘침 연출 — 금빛 파티클 버스트',
      '밀도 캘린더 — 미니 양동이 히트맵 + 주간 뷰',
      '환경 진화 시스템 (맨땅→풀→꽃→나무→숲→호수)',
      '날씨 시스템 (연속 집중일수에 따라 흐림→무지개)',
      '체험형 온보딩 — 빗방울이 떨어지고 양동이가 채워지는 경험',
      '물 색상 자연 진화 — 집중 시간에 따라 색이 깊어짐',
    ]),
    _PatchNote(version: '1.6.0', date: '2026.04.07', changes: [
      '메인 화면에 현재 버전 표시',
      '앱 실행 시 자동 업데이트 확인 기능 추가',
      '새 버전 발견 시 업데이트 팝업 (brew upgrade 연동)',
      '패치노트 기능 추가',
    ]),
    _PatchNote(version: '1.5.0', date: '2026.04.06', changes: [
      '첫 실행 시 4단계 온보딩 페이지 추가',
      '설정에서 온보딩 다시 보기 가능',
    ]),
    _PatchNote(version: '1.4.0', date: '2026.04.06', changes: [
      '백색소음 토글 OFF 시 WebView 완전 해제',
      '토글 ON 시 WebView 재로드 (재생 버튼 표시)',
      '재생 후 하얀 화면 방지 (CSS 개선)',
    ]),
    _PatchNote(version: '1.3.0', date: '2026.04.06', changes: [
      '백색소음 기능을 독립 화면으로 분리',
      '백색소음 토글 OFF 시 오디오 즉시 정지 버그 수정',
    ]),
    _PatchNote(version: '1.2.0', date: '2026.04.06', changes: [
      '무한 모드에서 순환마다 양동이 코인 적립',
      '집중 확인 10초 타임아웃 (무응답 시 자동 일시정지)',
      '백색소음 기능 추가 (rainymood.com 연동)',
      '버튼 3개에서 2개로 통합 (상태별 전환)',
      '구름 애니메이션 가시성 향상',
      '비 파티클 양동이 폭에 맞춤',
      '앱 종료 시 알림 자동 정리',
    ]),
    _PatchNote(version: '1.1.0', date: '2026.04.06', changes: [
      '6종 양동이 스킨 추가 (나무, 철, 백금, 금, 다이아, 무지개)',
      '티어별 스킨 해금 시스템',
      '금 이상 티어에서 물 색상 커스텀 가능',
      '비 파티클 시스템 (작고 많은 빗방울)',
      '구름 애니메이션 추가',
    ]),
    _PatchNote(version: '1.0.0', date: '2026.04.06', changes: [
      'RainDrop 첫 출시',
      '집중 타이머 + 양동이 채움 시스템',
      '무한 모드 (끝없는 집중)',
      '메뉴바 타이머 상태 표시',
      '월별 달력 히스토리',
      '스티커 꾸미기 상점',
      'Homebrew 배포 지원',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      height: 500,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _notes.map((note) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.panelBackground(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.end,
                            spacing: 8,
                            children: [
                              Text(
                                'v${note.version}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText(context),
                                ),
                              ),
                              Text(
                                note.date,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      AppColors.secondaryText(context),
                                ),
                              ),
                              if (note.version ==
                                  AppConstants.appVersion)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent(context),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '현재 버전',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...note.changes.map((change) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\u00B7',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          AppColors.accent(context),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      change,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            AppColors.secondaryText(
                                                context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GlassContainer(
      borderRadius: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '패치노트',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText(context),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('닫기',
                  style: TextStyle(color: AppColors.accent(context))),
            ),
          ),
        ],
      ),
    );
  }
}
