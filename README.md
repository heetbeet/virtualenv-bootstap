# Virtualenv Bootstrapper for Windows

This is a thin stand-alone layer to execute [virtualenv](https://virtualenv.pypa.io/en/latest/user_guide.html) without having to instal Python. It's written in Powershell and executed as a .cmd file.

The script, `virtualenv.cmd`, acts as a [shim](https://en.wikipedia.org/wiki/Shim_(computing)) to run [virtualenv](https://virtualenv.pypa.io/en/latest/user_guide.html) in a bootstrapped fashion in order to set up Python virtual environments, without having to install Python directly on your system. You can download `virtualenv.cmd`, you can install `virtualenv.cmd`, or you can execute `virtualenv.cmd` directly from github.com in your terminal.

## Install virtualenv.cmd
The easiest way to start using `virtualenv.cmd` is to run the setup script directly from github.com. Open the _run_ box `⊞+r`, or a _cmd_ window, and run the following command:

    powershell powershell (iwr -uri https://github.com/heetbeet/virtualenv-bootstrap/raw/main/extras/install-from-github.cmd -outfile $env:temp/.cmd) $env:temp/.cmd

![image](https://github.com/heetbeet/virtualenv-bootstrap/assets/4103775/1ad3be85-3458-40af-95b3-fad900cd6a0f)


## Run directly from github.com
You can directly execute `virtualenv.cmd` from github.com. For example to create a new `venv` directory, just open _cmd_, navigate to the location where you want the `venv`, and run:

    powershell powershell (iwr -uri https://github.com/heetbeet/virtualenv-bootstrap/raw/main/virtualenv.cmd -outfile $env:temp/.cmd) $env:temp/.cmd venv

Furthermore, to run any `virtualenv.cmd` command, just replace `venv` with the arguments of your choice, e.g. `--help`

    powershell powershell (iwr -uri https://github.com/heetbeet/virtualenv-bootstrap/raw/main/virtualenv.cmd -outfile $env:temp/.cmd) $env:temp/.cmd --help

<br>

## Purpose
The main driver behind `virtualenv.cmd` is to allow projects to have Python as a build dependency, without having to set up Python explicitely.
You can have a project with very complex build logic implemented in Python, that can now have a simple entry point like `build.cmd`.

## Features

- **Python Version Specification:** `virtualenv.cmd` added an extra argument to [virtualenv](https://virtualenv.pypa.io/en/latest/user_guide.html) in order to specify a Python version for your virtual environment.
- **No Global Python Installation Required:** Enables the creation of Python virtual environments on Windows machines without the need for a globally installed Python.
- **Automatic Python Download:** Downloads the specified or default Python version automatically from the official Python repository.

## Usage

4. **Running virtualenv:**
   - To create a virtual environment with the default Python version, simply run `virtualenv.cmd` with regular arguments (see [virtualenv](https://virtualenv.pypa.io/en/latest/user_guide.html)):
     ```
     virtualenv [ARGS]
     ```
   - To specify a Python version (e.g., 3.8.10), use a version tuple as the first argument to `virtualenv.cmd`:
     ```
     virtualenv 3.8.10 [ARGS]
     ```

## How It Works

When `virtualenv.cmd` is executed, it:
- Checks if the first argument matches a Python version pattern (3.x.x).
- Checks if the required version is not already in cache, otherwise:
    - Downloads the specified Python version from the the official Python repository.
    - Extracts the package to a temporary directory.
    - Installs `pip` and `virtualenv`.
- Runs virtualenv.cmd with your provided [virtualenv](https://virtualenv.pypa.io/en/latest/user_guide.html) arguments.

## License

This script is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
