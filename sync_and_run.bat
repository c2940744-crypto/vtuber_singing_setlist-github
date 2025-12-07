@echo off
set PROJECT_DIR=%~dp0
set NOTEBOOK_NAME=github同步測試版歌雜搜歌.ipynb

echo ----------------------------------------------------
echo [1] 拉取最新程式碼與快取 (Pull from GitHub)
echo ----------------------------------------------------
cd /d "%PROJECT_DIR%"
git pull origin main

if errorlevel 1 (
    echo [ERROR] 拉取 GitHub 失敗。請檢查連線或授權。
    goto :eof
)

echo ----------------------------------------------------
echo [2] 執行 Jupyter Notebook 更新數據 (Executing Notebook)
echo ----------------------------------------------------
REM 使用 jupyter execute 運行 Notebook 以更新數據
REM **注意：此命令需要在您的環境中正確設置 Jupyter 才能運行**
jupyter execute "%NOTEBOOK_NAME%" --to html --output_dir .

if errorlevel 1 (
    echo [ERROR] Jupyter Notebook 執行失敗。請檢查 Notebook 內的程式碼或 Jupyter 環境設置。
    goto :eof
)

echo ----------------------------------------------------
echo [3] 提交快取變更並推送到 GitHub (Sync to GitHub)
echo ----------------------------------------------------

REM 將 Notebook 檔案、快取檔案加入暫存區
git add "%NOTEBOOK_NAME%" setlist_cache.txt vtuber_list.txt

REM 檢查暫存區是否有實際變動
git diff --staged --quiet
if not errorlevel 1 (
    echo [SYNC] 檔案無變動，無需提交。
    goto :eof
)

REM 提交變更，使用動態時間戳作為 Commit 訊息
for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (set DATE_STR=%%k%%j%%i)
for /f "tokens=1-3 delims=:. " %%i in ("%time%") do (set TIME_STR=%%i%%j%%k)

git commit -m "DATA: Automated update via Notebook on %DATE_STR% %TIME_STR%"

REM 推送到遠端
git push origin main

if errorlevel 1 (
    echo [ERROR] 推送變更到 GitHub 失敗。請檢查授權或是否有衝突。
) else (
    echo [SUCCESS] 數據與程式碼已成功同步到 GitHub。
)