@echo off
rem /S            从所有子目录删除指定文件。
echo Deleting E:\*.bak......
del /f /s /q "E:\*.bak"
echo Delete finished.
pause