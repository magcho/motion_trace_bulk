#!/bin/bash
echo ---
echo ---  映像データからOpenposeで姿勢推定する
echo ---


echo ------------------------------------------
echo Openpose 解析
echo ------------------------------------------

echo ---  入力対象映像ファイルパス
echo 解析対象となる映像のファイルのフルパスを入力して下さい。
echo 1フレーム目に必ず人物が映っている事を確認してください。（映ってないと次でコケます）
echo この設定は半角英数字のみ設定可能で、必須項目です。
printf ■解析対象映像ファイルパス:
INPUT_VIDEO=
read INPUT_VIDEO
echo INPUT_VIDEO：$INPUT_VIDEO

if [ -z "$INPUT_VIDEO" ]; then
  echo "解析対象映像ファイルパスが設定されていないため、処理を中断します。"
  exit
fi

echo "---  解析を開始するフレーム"

echo --------------
echo "解析を開始するフレームNoを入力して下さい。(0始まり)"
echo 最初にロゴが表示されている等、人体が正確にトレースできない場合に、
echo 冒頭のフレームをスキップできます。
echo 何も入力せず、ENTERを押下した場合、0F目からの解析になります。
printf 解析開始フレームNo:
FRAME_FIRST=0
read FRAME_FIRST

echo "---  映像に映っている最大人数"

echo --------------
echo 映像に映っている最大人数を入力して下さい。
echo 何も入力せず、ENTERを押下した場合、1人分の解析になります。
echo 複数人数が同程度の大きさで映っている映像で1人だけ指定した場合、解析対象が飛ぶ場合があります。
printf 映像に映っている最大人数:
NUMBER_PEOPLE_MAX=1
read NUMBER_PEOPLE_MAX

echo "---  反転フレームリスト"
echo --------------
REVERSE_FRAME_LIST=
echo "Openposeが誤認識して反転しているフレーム番号(0始まり)を指定してください。"
echo ここで指定された番号のフレームに対して、反転判定を行い、反転認定された場合、関節位置が反転されます。
echo カンマで複数件指定可能です。また、ハイフンで範囲が指定可能です。
echo "例）4,10-12 … 4,10,11,12 が反転判定対象フレームとなります。"
printf ■反転フレームリスト:
read REVERSE_FRAME_LIST

echo "---  順番指定リスト"
echo --------------
ORDER_SPECIFIC_LIST=
echo 複数人数トレースで、交差後の人物INDEX順番を指定してください。
echo 0F目の立ち位置左から順番に0番目、1番目、と数えます。
echo 'フォーマット：［＜フレーム番号＞:左から0番目にいる人物のインデックス,左から1番目…］'
echo '例）[10:1,0]　…　10F目は、左から1番目の人物、0番目の人物の順番に並べ替えます。'
echo [10:1,0][30:0,1]のように、カッコ単位で複数件指定可能です。
set /P ORDER_SPECIFIC_LIST="■順番指定リスト: "

echo ---  詳細ログ有無

echo --------------
echo 詳細なログを出すか、yes か no を入力して下さい。
echo 何も入力せず、ENTERを押下した場合、通常ログと各種アニメーションGIFを出力します。
echo '詳細ログの場合、各フレームごとのデバッグ画像も追加出力されます。（その分時間がかかります）'
echo 'warn と指定すると、アニメーションGIFも出力しません。（その分早いです）'
VERBOSE=2
IS_DEBUG=no
printf 詳細ログ[yes/no/warn]:
read IS_DEBUG

if [ $IS_DEBUG = "yes" ] ; then
  VERBOSE=3
fi

if [ $IS_DEBUG = "warn" ] ; then
  VERBOSE=1
fi

echo --echo "NUMBER_PEOPLE_MAX: $NUMBER_PEOPLE_MAX"

echo -----------------------------------
echo --- 入力映像パス
FOR %%1 IN (%INPUT_VIDEO%) DO (
  echo -- 入力映像パスの親ディレクトリと、ファイル名+_jsonでパス生成
  set INPUT_VIDEO_DIR=%%‾dp1
  set INPUT_VIDEO_FILENAME=%%‾n1
  set INPUT_VIDEO_FILENAME_EXT=%%‾nx1
)

echo -- 実行日付
set DT=%date%
echo -- 実行時間
set TM=%time%
echo -- 時間の空白を0に置換
set TM2=%TM: =0%
echo -- 実行日時をファイル名用に置換
set DTTM=%dt:‾0,4%%dt:‾5,2%%dt:‾8,2%_%TM2:‾0,2%%TM2:‾3,2%%TM2:‾6,2%

echo --------------

echo ------------------------------------------------
echo -- JSON出力ディレクトリ
set OUTPUT_JSON_DIR=%INPUT_VIDEO_DIR%%INPUT_VIDEO_FILENAME%_%DTTM%¥%INPUT_VIDEO_FILENAME%_json
echo echo %OUTPUT_JSON_DIR%

echo -- JSON出力ディレクトリ生成
mkdir %OUTPUT_JSON_DIR%
echo 解析結果JSONディレクトリ：%OUTPUT_JSON_DIR%

echo ------------------------------------------------
echo -- 映像出力ディレクトリ
set OUTPUT_VIDEO_PATH=%INPUT_VIDEO_DIR%%INPUT_VIDEO_FILENAME%_%DTTM%¥%INPUT_VIDEO_FILENAME%_openpose.avi
echo 解析結果aviファイル：%OUTPUT_VIDEO_PATH%

echo --------------
echo Openpose解析を開始します。
echo 解析を中断したい場合、ESCキーを押下して下さい。
echo --------------

echo -- exe実行
set C_INPUT_VIDEO=/data/%INPUT_VIDEO_FILENAME_EXT%
set C_JSON_DIR=/data/%INPUT_VIDEO_FILENAME%_%DTTM%/%INPUT_VIDEO_FILENAME%_json
set C_OUTPUT_VIDEO=/data/%INPUT_VIDEO_FILENAME%_%DTTM%/%INPUT_VIDEO_FILENAME%_openpose.avi
set OPENPOSE_ARG=--video %C_INPUT_VIDEO% --model_pose COCO --write_json %C_JSON_DIR% --write_video %C_OUTPUT_VIDEO% --number_people_max %NUMBER_PEOPLE_MAX% --frame_first %FRAME_FIRST% --display 0
docker container run --rm -v %INPUT_VIDEO_DIR:¥=/%:/data -it errnommd/autotracevmd bash -c "cd /openpose && ./build/examples/openpose/openpose.bin %OPENPOSE_ARG%"

echo --------------
echo Done!!
echo Openpose解析終了

exit /b
