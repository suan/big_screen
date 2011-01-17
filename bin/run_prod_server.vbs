Set objShell = CreateObject("WScript.Shell")
objShell.CurrentDirectory = ".."
objShell.Run("mongrel_rails start -e production -p 3333")