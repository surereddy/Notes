@echo off
rem /S            从所有子目录删除指定文件。
echo Deleting D:\*.bak......
del /f /s /q "D:\*.bak"
echo Delete finished.
pause