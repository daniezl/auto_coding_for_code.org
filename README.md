# Auto Coding Script for Code.org

This automation script helps generate and test code for Code.org projects using DeepSeek AI assistance.

## Prerequisites

1. **Python**
   - Install Python 3.x from [Python's official website](https://www.python.org/)
   - Required for DeepSeek API integration
   - Install required Python packages:
     ```bash
     pip install requests
     ```

2. **Required Files**
   - `auto_coding.exe` - The main executable (or `auto_coding.ahk` if using the script version)
   - `deepSeek.py` - Python script for DeepSeek API integration
   - `config/laptop.json` - Configuration file for screen coordinates
   - Your DeepSeek API credentials

Note: If you're using the .ahk script version instead of the .exe, you'll also need:
- AutoHotkey v2 installed from [AutoHotkey's official website](https://www.autohotkey.com/)
- `JSON.ahk` - AutoHotkey JSON library

## Configuration

1. Create a `config` folder and add a `laptop.json` file with your screen coordinates:
   ```json
   {
     "coordinates": {
       "instruction": {
         "start": {"x": 0, "y": 0},
         "end": {"x": 0, "y": 0}
       },
       "classes": {
         "y": 0,
         "class1": {"x": 0},
         "spacing": 0
       },
       "code": {"x": 0, "y": 0},
       "run": {"x": 0, "y": 0},
       "test": {"x": 0, "y": 0},
       "console": {
         "start": {"x": 0, "y": 0},
         "end": {"x": 0, "y": 0}
       },
       "clear_console": {"x": 0, "y": 0}
     }
   }
   ```
   Note: You'll need to adjust these coordinates based on your screen resolution and Code.org layout.

2. Set up your DeepSeek API credentials:
   - Create a file named `config.json` with your API key:
     ```json
     {
       "api_key": "your-deepseek-api-key-here"
     }
     ```

## Setup

1. Download all required files
2. Place them in the same directory
3. Configure your screen coordinates in the config file
4. Add your DeepSeek API credentials

## Usage

1. Open Code.org in your browser
2. Navigate to your project
3. Run `auto_coding.exe` (or the .ahk script)
4. The script will:
   - Read the instructions
   - Generate code using DeepSeek AI
   - Insert the code into appropriate classes
   - Run tests and fix errors automatically

## Important Notes

- Keep the Code.org window active while the script is running
- Don't move your mouse or keyboard during script execution
- Make sure your Code.org window is fully visible and not minimized
- Adjust sleep timers in the script if actions are happening too fast/slow for your system
- The script works best with a 1920x1080 resolution display

## Troubleshooting

- If the script isn't clicking in the right places:
  - Adjust the coordinates in your config file
  - Make sure your browser zoom is set to 100%
  - Verify your screen resolution matches the config
- If DeepSeek isn't working:
  - Check your API credentials
  - Verify your internet connection
  - Make sure the Python script has proper permissions

## Files Created by the Script

- `clipContent.txt` - Temporary storage for clipboard content
- `conversation_history.json` - History of AI interactions
- `prompt.txt` - Temporary storage for AI prompts
- `response.txt` - Temporary storage for AI responses

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

MIT License

Copyright (c) [year] [your name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.