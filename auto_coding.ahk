#Requires AutoHotkey v2
#Include JSON.ahk

SetTitleMatchMode(2)

^q::ExitApp() ;hot key to exit

clipFilePath := "clipContent.txt"
if(FileExist(clipFilePath)){
    FileDelete clipFilePath
}
FileAppend "", clipFilePath
A_Clipboard := ""

getClassName(text) {
    if RegExMatch(text, "public\s+class\s+(\w+)\s*{?", &match) {
        return match[1]  ; Returns just the class name (e.g., "Voter")
    }
    return ""
}

copyAndAppend(){
    A_Clipboard := ""
	Send "^c"
	ClipWait(1)
    content := A_Clipboard
    className := getClassName(content)
	FileAppend content, clipFilePath
	FileAppend "`n", clipFilePath
    return className
}

copy(){
    A_Clipboard := ""
	Send "^c"
	ClipWait(1)
    content := A_Clipboard
    return content
}

pasteAppended(){
	clipContent := FileRead(clipFilePath)
	A_Clipboard := clipContent
	Send "^v"
}

; Read configuration file
configPath := "config\config.json" ;change for device
configText := FileRead(configPath)
config := JSON.Parse(configText)


ins_start_X := config["coordinates"]["instruction"]["start"]["x"]
ins_start_Y := config["coordinates"]["instruction"]["start"]["y"]
ins_end_X := config["coordinates"]["instruction"]["end"]["x"]
ins_end_Y := config["coordinates"]["instruction"]["end"]["y"]

classes_Y := config["coordinates"]["classes"]["y"]
class_1_X := config["coordinates"]["classes"]["class1"]["x"]
class_spacing := config["coordinates"]["classes"]["spacing"]

class_2_X := class_1_X + class_spacing
class_3_X := class_2_X + class_spacing
class_4_X := class_3_X + class_spacing
class_5_X := class_4_X + class_spacing

code_X := config["coordinates"]["code"]["x"]
code_Y := config["coordinates"]["code"]["y"]

run_X := config["coordinates"]["run"]["x"]
run_Y := config["coordinates"]["run"]["y"]

test_X := config["coordinates"]["test"]["x"]
test_Y := config["coordinates"]["test"]["y"]

console_start_X := config["coordinates"]["console"]["start"]["x"]
console_start_Y := config["coordinates"]["console"]["start"]["y"]

console_end_X := config["coordinates"]["console"]["end"]["x"]
console_end_Y := config["coordinates"]["console"]["end"]["y"]

clear_console_X := config["coordinates"]["clear_console"]["x"]
clear_console_Y := config["coordinates"]["clear_console"]["y"]

formatPrompt(content) {
    prompt := "Generate Java code for a Code.org project.`n`n"
    prompt .= "- Follow the exact format below, including square brackets for class names.`n"
    prompt .= "- Only write the code`n"
    prompt .= "- Do NOT write any comments or explanations`n"
    prompt .= "- Remove all existing comments`n`n"
    prompt .= "### INSTRUCTIONS:`n"
    prompt .= content
    return prompt
}

ShowLoadingScreen() {
    global loadingGui, timerText
    loadingGui := Gui()
    loadingGui.SetFont("s10")
    loadingGui.Add("Text", "w300", "DeepSeek is working on it...")  ; Made wider
    timerText := loadingGui.Add("Text", "w300", "Time: 0s")  ; Made wider
    loadingGui.Show("w300 h100")  ; Made window wider
    
    ; Start timer
    SetTimer(UpdateTimer, 1000)
}

UpdateTimer() {
    global timerText, startTime
    elapsed := (A_TickCount - startTime) // 1000  ; Convert to seconds
    timerText.Value := "Time: " elapsed "s"
}

callOllama(prompt) {
    global startTime, loadingGui
    url := "http://localhost:11434/api/generate"
    
    ; Better string escaping
    prompt := StrReplace(prompt, '"', '\"')
    prompt := StrReplace(prompt, "`r`n", "\n")
    prompt := StrReplace(prompt, "`n", "\n")
    prompt := StrReplace(prompt, "`r", "\n")
    prompt := StrReplace(prompt, "\", "\\")
    
    data := '{"model":"codellama:7b-instruct","prompt":"' prompt '","temperature":0.2,"top_p":0.9}'
    
    try {
        ; Show loading screen and start timer
        startTime := A_TickCount
        ShowLoadingScreen()
        
        WinHttp := ComObject("WinHttp.WinHttpRequest.5.1")
        WinHttp.Open("POST", url, true)
        WinHttp.SetRequestHeader("Content-Type", "application/json")
        WinHttp.Send(data)
        WinHttp.WaitForResponse()
        
        ; Parse the response and format properly
        response := WinHttp.ResponseText
        fullText := ""
        
       ; Split response into lines and process each chunk
       Loop Parse, response, "`n" {
        if RegExMatch(A_LoopField, '"response":"([^"]*)"', &match) {
            text := match[1]
            
            ; Fix Unicode escapes
            text := StrReplace(text, "\u003c", "<")
            text := StrReplace(text, "\u003e", ">")
            
            ; Fix newlines first
            text := StrReplace(text, "\n", "`n")
            
            ; Fix quotes and backslashes
            text := StrReplace(text, "\" Chr(34), Chr(34))  ; Replace \" with "
            text := StrReplace(text, "\\", "\")             ; Replace \\ with \
            
            fullText .= text
            }
        }
        
        ; Clean up any remaining escapes
        fullText := RegExReplace(fullText, "\\([^\\])", "$1")
        
        ; Stop timer and close loading screen
        SetTimer(UpdateTimer, 0)
        loadingGui.Destroy()
        ; Calculate and show elapsed time
        elapsedTime := (A_TickCount - startTime) / 1000  ; Convert to seconds
        ;MsgBox Format("Time taken: {:.2f} seconds", elapsedTime)
        
        return fullText
    } catch Error as e {
        ; Make sure to clean up if there's an error
        SetTimer(UpdateTimer, 0)
        if IsSet(loadingGui)
            loadingGui.Destroy()
            
        MsgBox "Ollama error: Make sure Ollama is running!`n`nTo fix:`n1. Open Command Prompt`n2. Type 'ollama serve'`n3. Try again"
        return
    }
}

ClearDeepSeekHistory() {
    if(FileExist("conversation_history.json")){
        FileDelete "conversation_history.json"
    }
}

callDeepSeek(prompt) {
    global startTime, loadingGui
    
    ; Save prompt to file
    if(FileExist("prompt.txt")){
        FileDelete "prompt.txt"
    }
    FileAppend prompt, "prompt.txt"
    
    try {
        ; Show loading screen and start timer
        startTime := A_TickCount
        ShowLoadingScreen()
        
        ; Run Python script and wait for it to finish
        RunWait('python "deepSeek.py"', , "Hide")
        
        ; Read the response
        response := FileRead("response.txt")
        
        ; Stop timer and close loading screen
        SetTimer(UpdateTimer, 0)
        loadingGui.Destroy()
        
        ; Calculate and show elapsed time
        elapsedTime := (A_TickCount - startTime) / 1000
        ;MsgBox Format("Time taken: {:.2f} seconds", elapsedTime)
        
        return response
    } catch Error as e {
        ; Make sure to clean up if there's an error
        SetTimer(UpdateTimer, 0)
        if IsSet(loadingGui)
            loadingGui.Destroy()
            
        MsgBox "DeepSeek error: " e.Message
        return
    }
}

removeComments(code) {
    ; Remove single-line comments (using 'm' option in the pattern itself)
    code := RegExReplace(code, "(?m)//.*$")
    
    ; Remove multi-line comments
    code := RegExReplace(code, "/\*[\s\S]*?\*/")
    
    ; Remove empty lines
    code := RegExReplace(code, "`n\s*`n", "`n")
    
    return code
}

ExtractClassCode(responseText, className) {
    ; Pattern matching [ClassName]: followed by code until next [ClassName]: or end
    pattern := "\[" className "\]:\R*([\s\S]*?)(?=\[\w+\]:|$)"
    if (RegExMatch(responseText, pattern, &match)) {
        return Trim(match[1])
    }
    return ""
}

fixError(){
    WinActivate "Code.org"
    Click clear_console_X, clear_console_Y

    Click test_X, test_Y
    Sleep(4000)
    ; Create a small GUI to inform the user
    runningGui := Gui("+AlwaysOnTop +ToolWindow", "Running Tests")
    runningGui.SetFont("s12 bold")
    runningGui.Add("Text", "w300 h60", "Tests are running.`nPlease don't move the mouse or keyboard.")
    runningGui.Show("NoActivate")
    
    ; Position it in a visible but non-intrusive location
    WinGetPos(&x, &y, &w, &h, "Running Tests")
    if (x && y && w && h) {
        WinMove(x, y, w, h, "Running Tests")
    }
    
    ; Set a timer to destroy the GUI after tests are done
    SetTimer(() => runningGui.Destroy(), -3000)  ; Destroy after 3 seconds

    MouseMove(console_end_X, console_end_Y, 0)
    Click "Down"
    Send("{WheelUp 10}")
    Sleep(500)
    MouseMove(console_start_X, console_start_Y, 0)
    Sleep(500)
    Click "Up"
    Send("^c")
    Sleep(500)
    Click
    
    console_content := A_Clipboard

    if (InStr(console_content, "error") || InStr(console_content, "Error") || InStr(console_content, "failed") || InStr(console_content, "Failed") || InStr(console_content, "EXCEPTION")) {
 
        ; Extract class name from console content using pattern /ClassName.java
        if RegExMatch(console_content, "/(\w+)\.java", &match) {
            prompt := "Fix this Java code error in the " match[1] " class(write the code in the class that has error with the same format as before):`n`n" console_content
        } else {
            ; If no class name found, use default prompt
            prompt := "Fix this Java code error(write the code in the class that has error with the same format as before):`n`n" console_content
        }
       
        response := callDeepSeek(prompt)
        if(response){
            ; Loop through all classes to check for fixes
            Loop 5 {
                i := A_Index
                
                if (i == 1 && is_class_1) {
                    new_code := ExtractClassCode(response, class_1_name)
                    if(new_code){
                        A_Clipboard := new_code
                        WinActivate "Code.org"
                        Click class_1_X, classes_Y
                        Click code_X, code_Y
                        Send("^a")
                        Send("^v")
                        Sleep(500)
                    }
                } else if (i == 2 && is_class_2) {
                    new_code := ExtractClassCode(response, class_2_name)
                    if(new_code){
                        A_Clipboard := new_code
                        WinActivate "Code.org"
                        Click class_2_X, classes_Y
                        Click code_X, code_Y
                        Send("^a")
                        Send("^v")
                        Sleep(500)
                    }
                } else if (i == 3 && is_class_3) {
                    new_code := ExtractClassCode(response, class_3_name)
                    if(new_code){
                        A_Clipboard := new_code
                        WinActivate "Code.org"
                        Click class_3_X, classes_Y
                        Click code_X, code_Y
                        Send("^a")
                        Send("^v")
                        Sleep(500)
                    }
                } else if (i == 4 && is_class_4) {
                    new_code := ExtractClassCode(response, class_4_name)
                    if(new_code){
                        A_Clipboard := new_code
                        WinActivate "Code.org"
                        Click class_4_X, classes_Y
                        Click code_X, code_Y
                        Send("^a")
                        Send("^v")
                        Sleep(500)
                    }
                } else if (i == 5 && is_class_5) {
                    new_code := ExtractClassCode(response, class_5_name)
                    if(new_code){
                        A_Clipboard := new_code
                        WinActivate "Code.org"
                        Click class_5_X, classes_Y
                        Click code_X, code_Y
                        Send("^a")
                        Send("^v")
                        Sleep(500)
                    }
                }
            }
            
            fixError()  ; Recursively check for more errors
        }
        else{
            MsgBox("failed to get response")
        }
    }
    else if (!InStr(console_content, "[JAVALAB] Program completed.")) {
        ; Wait a bit and try again
        Sleep(2000)
        fixError()  ; Recursively check until we see completion message
    }
    ;Click clear_console_X, clear_console_Y
}

fileAppend("", "conversation_history.json")
ClearDeepSeekHistory()
fileAppend("", "conversation_history.json")
ClearDeepSeekHistory()

WinActivate "Code.org"
MouseMove(ins_start_X, ins_start_Y, 0)
Click "Down"
MouseMove(ins_end_X, ins_end_Y, 0)
Send("{WheelDown 5}") ;increase if the instructions are too long
Click "Up"
copyAndAppend()
Click

; Initialize all variables before the loop
class_1_name := "Class1"  ; Default names that will be overwritten
; Initialize all variables before the loop
class_1_name := "Class1"  ; Default names that will be overwritten
class_2_name := "Class2"
class_3_name := "Class3"
class_4_name := "Class4"
class_5_name := "Class5"

class_1_content := ""
class_2_content := ""
class_3_content := ""
class_4_content := ""
class_5_content := ""

is_class_1 := false
is_class_2 := false
is_class_3 := false
is_class_4 := false
is_class_5 := false

Loop 5 {
    i := A_Index
    
    ; Use direct variable references instead of dynamic variables
    if (i == 1) {
        x_coord := class_1_X
        if (x_coord > 0) {
            WinActivate("Code.org")
            Click(x_coord, classes_Y)
            Click(code_X, code_Y)
            Send("^a")
            Send("^c")
            Sleep(200)
            class_1_content := A_Clipboard
            
            if (class_1_content != "") {
                class_1_name := getClassName(class_1_content)
                if(class_1_name = ""){
                    is_class_1 := false
                }   
                else{
                    is_class_1 := true
                    class_header := "`n`n[" class_1_name "]:`n"
                    FileAppend(class_header, clipFilePath)
                    fileAppend(class_1_content, clipFilePath)
                }
            }
        }
    } else if (i == 2) {
        x_coord := class_2_X
        if (x_coord > 0) {
            WinActivate("Code.org")
            Click(x_coord, classes_Y)
            Click(code_X, code_Y)
            Send("^a")
            Send("^c")
            Sleep(200)
            class_2_content := A_Clipboard
            
            if (class_2_content != "" && class_2_content != class_1_content) {
                class_2_name := getClassName(class_2_content)
                if(class_2_name = ""){
                    is_class_2 := false
                }
                else{
                    is_class_2 := true
                    class_header := "`n`n[" class_2_name "]:`n"
                    FileAppend(class_header, clipFilePath)
                    fileAppend(class_2_content, clipFilePath)
                }
            }
        }
    } else if (i == 3) {
        x_coord := class_3_X
        if (x_coord > 0) {
            WinActivate("Code.org")
            Click(x_coord, classes_Y)
            Click(code_X, code_Y)
            Send("^a")
            Send("^c")
            Sleep(200)
            class_3_content := A_Clipboard
            
            if (class_3_content != "" && class_3_content != class_1_content && class_3_content != class_2_content) {
                class_3_name := getClassName(class_3_content)
                if(class_3_name = ""){
                    is_class_3 := false
                }
                else{
                    is_class_3 := true
                    class_header := "`n`n[" class_3_name "]:`n"
                    FileAppend(class_header, clipFilePath)
                    fileAppend(class_3_content, clipFilePath)
                }
            }
        }
    } else if (i == 4) {
        x_coord := class_4_X
        if (x_coord > 0) {
            WinActivate("Code.org")
            Click(x_coord, classes_Y)
            Click(code_X, code_Y)
            Send("^a")
            Send("^c")
            Sleep(200)
            class_4_content := A_Clipboard
            
            if (class_4_content != "" && class_4_content != class_1_content && class_4_content != class_2_content && class_4_content != class_3_content) {
                class_4_name := getClassName(class_4_content)
                if(class_4_name = ""){
                    is_class_4 := false
                }
                else{
                    is_class_4 := true
                    class_header := "`n`n[" class_4_name "]:`n"
                    FileAppend(class_header, clipFilePath)
                    fileAppend(class_4_content, clipFilePath)
                }
            }
        }
    } else if (i == 5) {
        x_coord := class_5_X
        if (x_coord > 0) {
            WinActivate("Code.org")
            Click(x_coord, classes_Y)
            Click(code_X, code_Y)
            Send("^a")
            Send("^c")
            Sleep(200)
            class_5_content := A_Clipboard
            
            if (class_5_content != "" && class_5_content != class_1_content && class_5_content != class_2_content && class_5_content != class_3_content && class_5_content != class_4_content) {
                class_5_name := getClassName(class_5_content)
                if(class_5_name = ""){
                    is_class_5 := false
                }
                else{
                    is_class_5 := true
                    class_header := "`n`n[" class_5_name "]:`n"
                    FileAppend(class_header, clipFilePath)
                    fileAppend(class_5_content, clipFilePath)
                }
            }
        }
    }
}

clipContent := FileRead(clipFilePath)
formattedPrompt := formatPrompt(clipContent)
clipContent := FileRead(clipFilePath)
formattedPrompt := formatPrompt(clipContent)

response := callDeepSeek(formattedPrompt) ;if this is taking only less than 1 second, check ur internet

WinActivate "Code.org"
Loop 5 {
    i := A_Index
    
    ; Use direct variable references instead of dynamic variables
    if (i == 1) {
        if (is_class_1 && WinActive("Code.org")) {
            A_Clipboard := ExtractClassCode(response, class_1_name)
            Click class_1_X, classes_Y
            Click code_X, code_Y
            Send("^a")
            Send("^v")
            Sleep(500)
        }
    } else if (i == 2) {
        if (is_class_2 && WinActive("Code.org")) {
            A_Clipboard := ExtractClassCode(response, class_2_name)
            Click class_2_X, classes_Y
            Click code_X, code_Y
            Send("^a")
            Send("^v")
            Sleep(500)
        }
    } else if (i == 3) {
        if (is_class_3 && WinActive("Code.org")) {
            A_Clipboard := ExtractClassCode(response, class_3_name)
            Click class_3_X, classes_Y
            Click code_X, code_Y
            Send("^a")
            Send("^v")
            Sleep(500)
        }
    } else if (i == 4) {
        if (is_class_4 && WinActive("Code.org")) {
            A_Clipboard := ExtractClassCode(response, class_4_name)
            Click class_4_X, classes_Y
            Click code_X, code_Y
            Send("^a")
            Send("^v")
            Sleep(500)
        }
    } else if (i == 5) {
        if (is_class_5 && WinActive("Code.org")) {
            A_Clipboard := ExtractClassCode(response, class_5_name)
            Click class_5_X, classes_Y
            Click code_X, code_Y
            Send("^a")
            Send("^v")
            Sleep(500)
        }
    }
}

WinActivate "Code.org"
Sleep(1000)

;fixError()
click test_X, test_Y
;msgbox "done"
sleep(2000)
ExitApp()
