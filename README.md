# Virtualenv Bootstrapper for Windows

A thin stand-alone layer to execute [virtualenv](https://virtualenv.pypa.io/en/latest/user_guide.html) without having to installing Python.

The script, `virtualenv.cmd`, acts as a shim to bootstrap [virtualenv](https://virtualenv.pypa.io/en/latest/user_guide.html) in order to set up Python virtual environments with any specified Python version, without installing Python directly on your system. You can download `virtualenv.cmd`, you can install `virtualenv.cmd`, or you can even execute `virtualenv.cmd` directly from github.com in your terminal.

# Installation


# One-time use
You can directly execute `virtualenv` from github.com. To create a `venv` directory, just open _cmd_, navigate to a location where you want the `venv` directory, and run:

    powershell powershell (iwr -uri https://github.com/heetbeet/virtualenv-bootstrap/raw/main/virtualenv.cmd -outfile $env:temp/.cmd) $env:temp/.cmd venv

Furthermore, to run any `virtualenv` command, just replace the argument `venv` with arguments of your choice, e.g. `--help`

    powershell powershell (iwr -uri https://github.com/heetbeet/virtualenv-bootstrap/raw/main/virtualenv.cmd -outfile $env:temp/.cmd) $env:temp/.cmd --help

<br>

## Features

- **Python Version Specification:** Allows specifying a Python version (3.x.x format) to bootstrap the virtual environment with that specific Python version.
- **No Global Python Installation Required:** Enables the creation of Python virtual environments on Windows machines without the need for a globally installed Python.
- **Automatic Python Download:** Downloads the specified or default Python version automatically from the official Python repository.

## Usage

4. **Running virtualenv:**
   - To create a virtual environment with the default Python version, simply run virtualenv with regular arguments (see :
     ```
     virtualenv [ARGS]
     ```
   - To specify a Python version (e.g., 3.8.10), use the version as the first argument:
     ```
     virtualenv 3.8.10 [ARGS]
     ```

## How It Works

When `virtualenv.cmd` is executed, it:
- Checks if the first argument matches a Python version pattern (3.x.x).
- Downloads the specified (or default) Python version's embedded package from the official Python repository.
- Extracts the package to a temporary directory.
- Installs `pip` and `virtualenv`.
- Creates a virtual environment in the current directory or a specified path.

## License

This script is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
