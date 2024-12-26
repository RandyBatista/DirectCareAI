# Server Setup Guide

Follow these steps to set up and run the server.

---

## Prerequisites

Ensure you have the following installed on your system before starting:

- **Python 3.x** (Check with `python --version` or `python3 --version`)
- **Terminal**:
  - **Windows**: PowerShell or Command Prompt
  - **Linux/macOS**: Bash or compatible terminal

---

## 1. Clone the Repository

Run the following commands:

```bash
git clone <repository-url>
cd <repository-directory>
```

## 2. Set Up Python Virtual Environment

### For Windows

Open Command Prompt or PowerShell.

Navigate to your project directory.

Create the virtual environment:

```bash
python -m venv server/.venv
```

Activate the virtual environment:

```bash
./server/.venv/Scripts/activate
```

You should now see (venv) at the start of your command prompt.

### For Linux/macOS

Open a terminal.

Navigate to your project directory.

Create the virtual environment:

```bash
python3 -m venv server/.venv
```

Activate the virtual environment:

```bash
source server/.venv/bin/activate
```

You should now see (venv) at the start of your terminal prompt.

## 3. Install Project Dependencies

With the virtual environment activated, install dependencies:

```bash
pip install -r requirements.txt
```

Optionally run the following command to update the dependencies

```bash
python.exe -m pip install --upgrade pip
```

## 4. Run the Server

For Windows
Run the following command in PowerShell or Command Prompt:

```bash
./start.ps1
```

For Linux/macOS
Run the following command in the terminal:

```bash
bash start.sh
```

## 5. Access the Server

Open the following URL in your browser:

```bash
http://localhost:8000
http://127.0.0.1:8000
```

Troubleshooting

Virtual Environment Issues
Ensure the virtual environment activation script path is correct.
On Windows, run PowerShell as Administrator if permission issues occur.
Server Startup Issues
Check server logs for error messages.

Run the following to verify dependencies:

```bash
pip freeze
```

Permission Errors (Linux/macOS)
Adjust file permissions if needed:

```bash
chmod +x start.sh
```

Conclusion
The server should now be running. If issues persist, refer to the documentation or contact support.
