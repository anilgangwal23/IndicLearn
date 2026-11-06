@echo off
rem Creates devtools\.venv, installs CUDA torch, then the project requirements.
rem Run: devtools\setup.bat
setlocal

set "DEVTOOLS=%~dp0"
set "VENV=%DEVTOOLS%.venv"
set "VENV_PY=%VENV%\Scripts\python.exe"

py -3.10 --version >nul 2>&1
if errorlevel 1 (
    echo Python 3.10 is required. Install it with the Python Launcher and rerun setup.bat.
    endlocal
    exit /b 1
)

if not exist "%VENV_PY%" (
    py -3.10 -m venv "%VENV%" || goto :fail
)

"%VENV_PY%" -m pip install --upgrade pip || goto :fail
"%VENV_PY%" -m pip install torch torchaudio --index-url https://download.pytorch.org/whl/cu124 || goto :fail
"%VENV_PY%" -m pip install -r "%DEVTOOLS%requirements.txt" || goto :fail
"%VENV_PY%" -c "import torch; print('torch', torch.__version__, 'cuda', torch.cuda.is_available())" || goto :fail

echo Setup complete.
endlocal
exit /b 0

:fail
echo Setup failed with error %errorlevel%.
endlocal
exit /b %errorlevel%
