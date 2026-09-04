@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title 🎵 플리 파형 영상 생성기 v2.0
color 0B

echo.
echo  ╔══════════════════════════════════════════╗
echo  ║   🎵 플리 파형 영상 생성기 v2.0          ║
echo  ║   Premium Waveform Video Generator       ║
echo  ╚══════════════════════════════════════════╝
echo.

:: ─── FFmpeg 확인 ───
where ffmpeg >nul 2>&1
if %errorlevel% neq 0 (
    echo  ❌ FFmpeg이 설치되어 있지 않습니다!
    echo     winget install Gyan.FFmpeg 으로 설치해주세요.
    pause
    exit /b
)
echo  ✅ FFmpeg 확인
echo.

:: ─── 모드 선택 ───
echo  ┌──────────────────────────────────────────┐
echo  │  모드를 선택하세요                        │
echo  │                                          │
echo  │  [1] 영상 모드 (캡컷 MP4 위에 파형)      │
echo  │  [2] 이미지 모드 (배경PNG + MP3)         │
echo  └──────────────────────────────────────────┘
echo.
set /p MODE="  선택 (1-2): "

:: ─── 파일 확인 ───
if "%MODE%"=="2" goto CHECK_IMAGE

:CHECK_VIDEO
if not exist "my_playlist.mp4" (
    echo  ❌ my_playlist.mp4 파일이 없습니다!
    echo     캡컷에서 내보낸 파일을 my_playlist.mp4 로 넣어주세요.
    pause
    exit /b
)
echo  ✅ my_playlist.mp4 확인
set INPUT_MODE=video
goto SELECT_QUALITY

:CHECK_IMAGE
if not exist "background.png" (
    echo  ❌ background.png 파일이 없습니다!
    pause
    exit /b
)
if not exist "playlist.mp3" (
    echo  ❌ playlist.mp3 파일이 없습니다!
    pause
    exit /b
)
echo  ✅ background.png 확인
echo  ✅ playlist.mp3 확인
set INPUT_MODE=image
goto SELECT_QUALITY

:: ─── 퀄리티 선택 ───
:SELECT_QUALITY
echo.
echo  ┌──────────────────────────────────────────┐
echo  │  퀄리티를 선택하세요                      │
echo  │                                          │
echo  │  [1] 기본        - 빠른 렌더링            │
echo  │  [2] ★프리미엄   - 글로우+비네팅+색보정   │
echo  │  [3] ★★풀옵션    - 프리미엄+이퀄라이저    │
echo  └──────────────────────────────────────────┘
echo.
set /p QUALITY="  선택 (1-3): "

:: ─── 스타일 선택 ───
echo.
echo  ┌──────────────────────────────────────────┐
echo  │  파형 스타일을 선택하세요                  │
echo  │                                          │
echo  │  [1] 하단 물결                           │
echo  │  [2] 중앙 대칭 물결                      │
echo  │  [3] 원형 물결                           │
echo  │  [4] 원형 + 하단 물결 콤보  ★추천        │
echo  └──────────────────────────────────────────┘
echo.
set /p STYLE="  선택 (1-4): "
if "%STYLE%"=="" set STYLE=4

:: ─── 색상 선택 ───
echo.
echo  ┌──────────────────────────────────────────┐
echo  │  파형 색상을 선택하세요                    │
echo  │                                          │
echo  │  [1] 시안 (Cyan)                         │
echo  │  [2] 핑크 (Pink)                         │
echo  │  [3] 화이트 (White)          ★영상추천   │
echo  │  [4] 골드 (Gold)                         │
echo  │  [5] 네온 그린 (Neon Green)              │
echo  │  [6] 퍼플 (Purple)                       │
echo  │  [7] 오렌지 (Sunset Orange)              │
echo  └──────────────────────────────────────────┘
echo.
set /p COLOR="  선택 (1-7): "

if "%COLOR%"=="1" set WC=0x00ffff&set WC2=0x00cccc&set CR=0&set CG=255&set CB=255&set FR=0&set FG=200&set FB=200&set GLOW_COLOR=0x004444
if "%COLOR%"=="2" set WC=0xff6b9d&set WC2=0xff3366&set CR=255&set CG=107&set CB=157&set FR=255&set FG=51&set FB=102&set GLOW_COLOR=0x440022
if "%COLOR%"=="3" set WC=0xffffff&set WC2=0xcccccc&set CR=255&set CG=255&set CB=255&set FR=200&set FG=200&set FB=200&set GLOW_COLOR=0x333333
if "%COLOR%"=="4" set WC=0xffd700&set WC2=0xffaa00&set CR=255&set CG=215&set CB=0&set FR=255&set FG=170&set FB=0&set GLOW_COLOR=0x443300
if "%COLOR%"=="5" set WC=0x39ff14&set WC2=0x00cc00&set CR=57&set CG=255&set CB=20&set FR=0&set FG=204&set FB=0&set GLOW_COLOR=0x004400
if "%COLOR%"=="6" set WC=0xb44dff&set WC2=0x8800cc&set CR=180&set CG=77&set CB=255&set FR=136&set FG=0&set FB=204&set GLOW_COLOR=0x220044
if "%COLOR%"=="7" set WC=0xff6b35&set WC2=0xff4500&set CR=255&set CG=107&set CB=53&set FR=255&set FG=69&set FB=0&set GLOW_COLOR=0x441100

if not defined WC set WC=0xffffff&set WC2=0xcccccc&set CR=255&set CG=255&set CB=255&set FR=200&set FG=200&set FB=200&set GLOW_COLOR=0x333333

:: ─── 투명도 (영상 모드) ───
set OPACITY=0.5
if "%INPUT_MODE%"=="video" (
    echo.
    echo  ┌──────────────────────────────────────────┐
    echo  │  파형 투명도를 선택하세요                  │
    echo  │                                          │
    echo  │  [1] 연하게 (30%%)     - 영상 잘 보임    │
    echo  │  [2] 보통 (50%%)       ★추천             │
    echo  │  [3] 진하게 (70%%)     - 파형 강조       │
    echo  │  [4] 불투명 (100%%)    - 파형 또렷       │
    echo  └──────────────────────────────────────────┘
    echo.
    set /p OPC="  선택 (1-4): "
    if "!OPC!"=="1" set OPACITY=0.3
    if "!OPC!"=="2" set OPACITY=0.5
    if "!OPC!"=="3" set OPACITY=0.7
    if "!OPC!"=="4" set OPACITY=1.0
)

:: ─── 해상도 선택 ───
echo.
echo  ┌──────────────────────────────────────────┐
echo  │  출력 해상도를 선택하세요                  │
echo  │                                          │
echo  │  [1] 1080p (1920x1080)  ★추천            │
echo  │  [2] 1440p (2560x1440)  2K               │
echo  │  [3] 2160p (3840x2160)  4K               │
echo  └──────────────────────────────────────────┘
echo.
set /p RES="  선택 (1-3): "

set RESW=1920
set RESH=1080
if "%RES%"=="2" set RESW=2560&set RESH=1440
if "%RES%"=="3" set RESW=3840&set RESH=2160

:: 파형 크기 비례 조정
set /a WAVEH=%RESH%/6
set /a WAVE_BOTTOM=%RESH%/7
set /a CIRCLEW=%RESH%/3
set /a EQBARH=%RESH%/5

:: ─── 페이드 인/아웃 ───
echo.
echo  ┌──────────────────────────────────────────┐
echo  │  페이드 인/아웃 추가?                     │
echo  │                                          │
echo  │  [1] 없음                                │
echo  │  [2] 페이드 인/아웃 (2초)  ★추천         │
echo  │  [3] 페이드 인/아웃 (4초)                │
echo  └──────────────────────────────────────────┘
echo.
set /p FADE="  선택 (1-3): "
set FADE_SEC=0
if "%FADE%"=="2" set FADE_SEC=2
if "%FADE%"=="3" set FADE_SEC=4

echo.
echo  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  🎬 영상 생성 시작!
echo  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

:: ═══════════════════════════════════════════
:: 기본 퀄리티
:: ═══════════════════════════════════════════
if "%QUALITY%"=="1" (
    if "%INPUT_MODE%"=="video" goto BASIC_VIDEO
    goto BASIC_IMAGE
)

:: ═══════════════════════════════════════════
:: 프리미엄 / 풀옵션 → 영상 모드
:: ═══════════════════════════════════════════
if "%INPUT_MODE%"=="video" goto PREMIUM_VIDEO
goto PREMIUM_IMAGE

:: ─────────────────────────────────────
:: 기본 - 영상
:: ─────────────────────────────────────
:BASIC_VIDEO
echo  📐 기본 퀄리티 - 영상모드

if "%STYLE%"=="1" (
    set FILTER="[0:a]showwaves=s=%RESW%x%WAVE_BOTTOM%:mode=cline:colors=%WC%@%OPACITY%|%WC2%@%OPACITY%:rate=30[wave];[0:v]scale=%RESW%:%RESH%:force_original_aspect_ratio=decrease,pad=%RESW%:%RESH%:(ow-iw)/2:(oh-ih)/2[bg];[bg][wave]overlay=0:H-h:shortest=1[out]"
)
if "%STYLE%"=="2" (
    set FILTER="[0:a]showwaves=s=%RESW%x%WAVE_BOTTOM%:mode=cline:colors=%WC%@%OPACITY%|%WC2%@%OPACITY%:rate=30[wave];[wave]split[w1][w2];[w2]vflip[wf];[w1][wf]vstack[fullwave];[0:v]scale=%RESW%:%RESH%:force_original_aspect_ratio=decrease,pad=%RESW%:%RESH%:(ow-iw)/2:(oh-ih)/2[bg];[bg][fullwave]overlay=0:(H-h)/2:shortest=1[out]"
)
if "%STYLE%"=="3" (
    set FILTER="[0:a]avectorscope=s=%CIRCLEW%x%CIRCLEW%:draw=line:mode=lissajous:rate=30:rc=%CR%:gc=%CG%:bc=%CB%:rf=%FR%:gf=%FG%:bf=%FB%[circle];[0:v]scale=%RESW%:%RESH%:force_original_aspect_ratio=decrease,pad=%RESW%:%RESH%:(ow-iw)/2:(oh-ih)/2[bg];[bg][circle]overlay=(W-w)/2:(H-h)/2:shortest=1[out]"
)
if "%STYLE%"=="4" (
    set FILTER="[0:a]asplit[a1][a2];[a1]showwaves=s=%RESW%x%WAVE_BOTTOM%:mode=cline:colors=%WC%@%OPACITY%|%WC2%@%OPACITY%:rate=30[wave];[a2]avectorscope=s=%CIRCLEW%x%CIRCLEW%:draw=line:mode=lissajous:rate=30:rc=%CR%:gc=%CG%:bc=%CB%:rf=%FR%:gf=%FG%:bf=%FB%[circle];[0:v]scale=%RESW%:%RESH%:force_original_aspect_ratio=decrease,pad=%RESW%:%RESH%:(ow-iw)/2:(oh-ih)/2[bg];[bg][circle]overlay=(W-w)/2:(H-h)/2-50:shortest=1[tmp];[tmp][wave]overlay=0:H-h:shortest=1[out]"
)

ffmpeg -y -i "my_playlist.mp4" -filter_complex %FILTER% -map "[out]" -map 0:a -c:v libx264 -preset fast -crf 18 -c:a aac -b:a 192k -shortest "result.mp4"
goto POSTPROCESS

:: ─────────────────────────────────────
:: 기본 - 이미지
:: ─────────────────────────────────────
:BASIC_IMAGE
echo  📐 기본 퀄리티 - 이미지모드

if "%STYLE%"=="1" (
    set FILTER="[0:a]showwaves=s=%RESW%x%WAVEH%:mode=cline:colors=%WC%|%WC2%:rate=30[wave];[1:v]scale=%RESW%:%RESH%:force_original_aspect_ratio=decrease,pad=%RESW%:%RESH%:(ow-iw)/2:(oh-ih)/2[bg];[bg][wave]overlay=0:H-h:shortest=1[out]"
)
if "%STYLE%"=="2" (
    set FILTER="[0:a]showwaves=s=%RESW%x%WAVEH%:mode=cline:colors=%WC%|%WC2%:rate=30[wave];[wave]split[w1][w2];[w2]vflip[wf];[w1][wf]vstack[fullwave];[1:v]scale=%RESW%:%RESH%:force_original_aspect_ratio=decrease,pad=%RESW%:%RESH%:(ow-iw)/2:(oh-ih)/2[bg];[bg][fullwave]overlay=0:(H-h)/2:shortest=1[out]"
)
if "%STYLE%"=="3" (
    set FILTER="[0:a]avectorscope=s=%CIRCLEW%x%CIRCLEW%:draw=line:mode=lissajous:rate=30:rc=%CR%:gc=%CG%:bc=%CB%:rf=%FR%:gf=%FG%:bf=%FB%[circle];[1:v]scale=%RESW%:%RESH%:force_original_aspect_ratio=decrease,pad=%RESW%:%RESH%:(ow-iw)/2:(oh-ih)/2[bg];[bg][circle]overlay=(W-w)/2:(H-h)/2:shortest=1[out]"
)
if "%STYLE%"=="4" (
    set FILTER="[0:a]asplit[a1][a2];[a1]showwaves=s=%RESW%x%WAVEH%:mode=cline:colors=%WC%|%WC2%:rate=30[wave];[a2]avectorscope=s=%CIRCLEW%x%CIRCLEW%:draw=line:mode=lissajous:rate=30:rc=%CR%:gc=%CG%:bc=%CB%:rf=%FR%:gf=%FG%:bf=%FB%[circle];[1:v]scale=%RESW%:%RESH%:force_original_aspect_ratio=decrease,pad=%RESW%:%RESH%:(ow-iw)/2:(oh-ih)/2[bg];[bg][circle]overlay=(W-w)/2:(H-h)/2-50:shortest=1[tmp];[tmp][wave]overlay=0:H-h:shortest=1[out]"
)

ffmpeg -y -i "playlist.mp3" -loop 1 -i "background.png" -filter_complex %FILTER% -map "[out]" -map 0:a -c:v libx264 -preset fast -crf 18 -c:a aac -b:a 192k -shortest "result.mp4"
goto POSTPROCESS

:: ─────────────────────────────────────
:: 프리미엄 - 영상 (글로우 + 비네팅 + 색보정 + 이퀄라이저)
:: ─────────────────────────────────────
:PREMIUM_VIDEO
echo  ⭐ 프리미엄 퀄리티 - 영상모드

:: 풀옵션이면 이퀄라이저 포함
set EQ_FILTER=
if "%QUALITY%"=="3" (
    set EQ_FILTER=;[aeq]showfreqs=s=%RESW%x%EQBARH%:mode=bar:ascale=log:fscale=lin:win_size=2048:colors=white@0.3:averaging=4[eqbar];[premix][eqbar]overlay=0:H-h-%WAVE_BOTTOM%-10:shortest=1[premix2]
    set FINAL_LABEL=premix2
) else (
    set FINAL_LABEL=premix
)

if "%STYLE%"=="1" (
    set WAVE_GEN=[a1]showwaves=s=%RESW%x%WAVE_BOTTOM%:mode=cline:colors=%WC%@%OPACITY%|%WC2%@%OPACITY%:rate=30[wave_raw];[wave_raw]split[wv1][wv2];[wv2]gblur=sigma=12[wglow];[wv1][wglow]overlay=0:0[wave]
    set WAVE_OVERLAY=[blurred][wave]overlay=0:H-h:shortest=1[premix]
)
if "%STYLE%"=="2" (
    set WAVE_GEN=[a1]showwaves=s=%RESW%x%WAVE_BOTTOM%:mode=cline:colors=%WC%@%OPACITY%|%WC2%@%OPACITY%:rate=30[wave_raw];[wave_raw]split[wsrc1][wsrc2];[wsrc2]vflip[wflip];[wsrc1][wflip]vstack[wave_sym];[wave_sym]split[ws1][ws2];[ws2]gblur=sigma=12[wglow];[ws1][wglow]overlay=0:0[wave]
    set WAVE_OVERLAY=[blurred][wave]overlay=0:(H-h)/2:shortest=1[premix]
)
if "%STYLE%"=="3" (
    set WAVE_GEN=[a1]avectorscope=s=%CIRCLEW%x%CIRCLEW%:draw=line:mode=lissajous:rate=30:rc=%CR%:gc=%CG%:bc=%CB%:rf=%FR%:gf=%FG%:bf=%FB%[circ_raw];[circ_raw]split[cv1][cv2];[cv2]gblur=sigma=15[cglow];[cv1][cglow]overlay=0:0[wave]
    set WAVE_OVERLAY=[blurred][wave]overlay=(W-w)/2:(H-h)/2:shortest=1[premix]
)
if "%STYLE%"=="4" (
    set WAVE_GEN=[a1]asplit[wa1][wa2];[wa1]showwaves=s=%RESW%x%WAVE_BOTTOM%:mode=cline:colors=%WC%@%OPACITY%|%WC2%@%OPACITY%:rate=30[wraw];[wraw]split[wv1][wv2];[wv2]gblur=sigma=12[wglow];[wv1][wglow]overlay=0:0[wave];[wa2]avectorscope=s=%CIRCLEW%x%CIRCLEW%:draw=line:mode=lissajous:rate=30:rc=%CR%:gc=%CG%:bc=%CB%:rf=%FR%:gf=%FG%:bf=%FB%[craw];[craw]split[cv1][cv2];[cv2]gblur=sigma=15[cglow];[cv1][cglow]overlay=0:0[circle]
    set WAVE_OVERLAY=[blurred][circle]overlay=(W-w)/2:(H-h)/2-50:shortest=1[tmp];[tmp][wave]overlay=0:H-h:shortest=1[premix]
)

:: 이퀄라이저용 오디오 분기
if "%QUALITY%"=="3" (
    set AUDIO_SPLIT=[0:a]asplit=3[a1][a2][aeq]
) else (
    set AUDIO_SPLIT=[0:a]asplit[a1][a2]
)

:: 비네팅 + 색보정
set POST_FX=[!FINAL_LABEL!]vignette=PI/4:mode=forward,eq=contrast=1.05:brightness=0.02:saturation=1.15[out]

ffmpeg -y -i "my_playlist.mp4" ^
  -filter_complex ^
    "!AUDIO_SPLIT!; ^
     [0:v]scale=%RESW%:%RESH%:force_original_aspect_ratio=decrease,pad=%RESW%:%RESH%:(ow-iw)/2:(oh-ih)/2,gblur=sigma=3[blurred]; ^
     !WAVE_GEN!; ^
     !WAVE_OVERLAY! ^
     !EQ_FILTER!; ^
     !POST_FX!" ^
  -map "[out]" -map "[a2]" ^
  -c:v libx264 -preset medium -crf 16 -c:a aac -b:a 256k -shortest ^
  "result.mp4"
goto POSTPROCESS

:: ─────────────────────────────────────
:: 프리미엄 - 이미지
:: ─────────────────────────────────────
:PREMIUM_IMAGE
echo  ⭐ 프리미엄 퀄리티 - 이미지모드

set EQ_FILTER=
if "%QUALITY%"=="3" (
    set EQ_FILTER=;[aeq]showfreqs=s=%RESW%x%EQBARH%:mode=bar:ascale=log:fscale=lin:win_size=2048:colors=white@0.5:averaging=4[eqbar];[premix][eqbar]overlay=0:H-h-%WAVEH%-10:shortest=1[premix2]
    set FINAL_LABEL=premix2
) else (
    set FINAL_LABEL=premix
)

if "%STYLE%"=="1" (
    set WAVE_GEN=[a1]showwaves=s=%RESW%x%WAVEH%:mode=cline:colors=%WC%|%WC2%:rate=30[wave_raw];[wave_raw]split[wv1][wv2];[wv2]gblur=sigma=12[wglow];[wv1][wglow]overlay=0:0[wave]
    set WAVE_OVERLAY=[bg][wave]overlay=0:H-h:shortest=1[premix]
)
if "%STYLE%"=="2" (
    set WAVE_GEN=[a1]showwaves=s=%RESW%x%WAVEH%:mode=cline:colors=%WC%|%WC2%:rate=30[wave_raw];[wave_raw]split[wsrc1][wsrc2];[wsrc2]vflip[wflip];[wsrc1][wflip]vstack[wave_sym];[wave_sym]split[ws1][ws2];[ws2]gblur=sigma=12[wglow];[ws1][wglow]overlay=0:0[wave]
    set WAVE_OVERLAY=[bg][wave]overlay=0:(H-h)/2:shortest=1[premix]
)
if "%STYLE%"=="3" (
    set WAVE_GEN=[a1]avectorscope=s=%CIRCLEW%x%CIRCLEW%:draw=line:mode=lissajous:rate=30:rc=%CR%:gc=%CG%:bc=%CB%:rf=%FR%:gf=%FG%:bf=%FB%[circ_raw];[circ_raw]split[cv1][cv2];[cv2]gblur=sigma=15[cglow];[cv1][cglow]overlay=0:0[wave]
    set WAVE_OVERLAY=[bg][wave]overlay=(W-w)/2:(H-h)/2:shortest=1[premix]
)
if "%STYLE%"=="4" (
    set WAVE_GEN=[a1]asplit[wa1][wa2];[wa1]showwaves=s=%RESW%x%WAVEH%:mode=cline:colors=%WC%|%WC2%:rate=30[wraw];[wraw]split[wv1][wv2];[wv2]gblur=sigma=12[wglow];[wv1][wglow]overlay=0:0[wave];[wa2]avectorscope=s=%CIRCLEW%x%CIRCLEW%:draw=line:mode=lissajous:rate=30:rc=%CR%:gc=%CG%:bc=%CB%:rf=%FR%:gf=%FG%:bf=%FB%[craw];[craw]split[cv1][cv2];[cv2]gblur=sigma=15[cglow];[cv1][cglow]overlay=0:0[circle]
    set WAVE_OVERLAY=[bg][circle]overlay=(W-w)/2:(H-h)/2-50:shortest=1[tmp];[tmp][wave]overlay=0:H-h:shortest=1[premix]
)

if "%QUALITY%"=="3" (
    set AUDIO_SPLIT=[0:a]asplit=3[a1][a2][aeq]
) else (
    set AUDIO_SPLIT=[0:a]asplit[a1][a2]
)

set POST_FX=[!FINAL_LABEL!]vignette=PI/4:mode=forward,eq=contrast=1.05:brightness=0.02:saturation=1.15[out]

ffmpeg -y -i "playlist.mp3" -loop 1 -i "background.png" ^
  -filter_complex ^
    "!AUDIO_SPLIT!; ^
     [1:v]scale=%RESW%:%RESH%:force_original_aspect_ratio=decrease,pad=%RESW%:%RESH%:(ow-iw)/2:(oh-ih)/2[bg]; ^
     !WAVE_GEN!; ^
     !WAVE_OVERLAY! ^
     !EQ_FILTER!; ^
     !POST_FX!" ^
  -map "[out]" -map "[a2]" ^
  -c:v libx264 -preset medium -crf 16 -c:a aac -b:a 256k -shortest ^
  "result.mp4"
goto POSTPROCESS

:: ─────────────────────────────────────
:: 후처리 (페이드 인/아웃)
:: ─────────────────────────────────────
:POSTPROCESS
if %errorlevel% neq 0 goto ERROR

if "%FADE_SEC%"=="0" goto FINISH

echo.
echo  🎞️ 페이드 인/아웃 적용 중...

:: 영상 길이 구하기
for /f "tokens=*" %%a in ('ffprobe -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "result.mp4" 2^>nul') do set DURATION=%%a

:: 페이드 아웃 시작 시간 계산 (소수점 처리)
for /f "tokens=1 delims=." %%a in ("%DURATION%") do set /a FADE_OUT_START=%%a-%FADE_SEC%

ffmpeg -y -i "result.mp4" ^
  -vf "fade=t=in:st=0:d=%FADE_SEC%,fade=t=out:st=%FADE_OUT_START%:d=%FADE_SEC%" ^
  -af "afade=t=in:st=0:d=%FADE_SEC%,afade=t=out:st=%FADE_OUT_START%:d=%FADE_SEC%" ^
  -c:v libx264 -preset fast -crf 18 -c:a aac -b:a 256k ^
  "result_final.mp4"

if %errorlevel% equ 0 (
    move /y "result_final.mp4" "result.mp4" >nul
    echo  ✅ 페이드 적용 완료
)
goto FINISH

:: ─────────────────────────────────────
:FINISH
echo.
echo  ══════════════════════════════════════════
echo  ✅ 완성! result.mp4
echo  ══════════════════════════════════════════
echo.
for %%A in ("result.mp4") do (
    set SIZE=%%~zA
    set /a SIZEMB=%%~zA/1048576
)
echo  📦 파일 크기: !SIZEMB! MB
echo.
echo  👉 result.mp4 를 확인해보세요!
echo.
pause
exit /b

:ERROR
echo.
echo  ══════════════════════════════════════════
echo  ❌ 오류가 발생했습니다.
echo  ══════════════════════════════════════════
echo.
echo  확인해주세요:
echo  - 파일 이름이 정확한지
echo  - 영상/이미지가 깨지지 않았는지
echo  - FFmpeg이 최신 버전인지 (winget upgrade Gyan.FFmpeg)
echo.
pause
exit /b
