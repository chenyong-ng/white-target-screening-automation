# white-target-screening-automation
1. The text file is batch of Telnet commands that works in Putty/SSH in batches, and the text line ending or End-of-line is encoded/saved in LF, which is common encoding format in GNU/Linux. (1)
The previous unmodified version was saved in Excel format and porbably encoded in CR/LF which is default in Windows environment, thus never worked in Putty/terminal emulator if copied and paste in batch.
I've added various command that found in iBright telnet commands that support "wait", and folder creation which greatly reduce labor time and typos.

[1] https://en.wikipedia.org/wiki/Newline

2. Notepad++ is recommended to edit this text file, it's enhanced version of default notepad application found in Windows OS, and it's free. Although some text editors found in Windows app store works too.
