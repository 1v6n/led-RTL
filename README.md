# LED Project - Native Installation Guide on Arch Linux

This guide details the steps to configure the development, simulation, formatting, and hardware linting environment natively on **Arch Linux**.

---

## 1. Install Base Tools (Pacman)

The official Arch Linux repositories contain most of the digital design tools ready to install. Open your terminal and run:

```bash
sudo pacman -Syu
sudo pacman -S git python build-essential yosys verilator gtkwave uv
```

### What are we installing here?
*   `yosys`: Open-source RTL synthesis tool.
*   `verilator`: Fast SystemVerilog simulator and static linter.
*   `gtkwave`: Waveform viewer to analyze simulations.
*   `uv`: Ultra-fast Python package manager written in Rust (modern replacement for pip/pipx).

---

## 2. Install Verible (Google's Linter and Formatter) from AUR

`verible` is not in the official pacman repositories, but it is available in the **AUR (Arch User Repository)**. You can install it using an AUR helper like `yay` or `paru`, or compile it manually.

### Option A: Using a helper (Recommended)
```bash
# With yay
yay -S verible-bin

# Or with paru
paru -S verible-bin
```

### Option B: Manual Installation (If you don't have an AUR helper)
```bash
git clone https://aur.archlinux.org/verible-bin.git
cd verible-bin
makepkg -si
cd .. && rm -rf verible-bin
```

---

## 3. Install and Configure `pre-commit`

To ensure all SystemVerilog code complies with style rules and passes static analysis before each commit, we use `pre-commit`.

1.  **Install `pre-commit` with `uv`**:
    ```bash
    uv tool install pre-commit
    ```

2.  **Ensure local uv tools are in your PATH**:
    By default, `uv` installs tools in `~/.local/bin`. If you do not have it in your shell configuration file (`~/.bashrc`, `~/.zshrc`, or `~/.config/fish/config.fish`), add it:
    
    *   **Bash / Zsh**:
        ```bash
        export PATH="$HOME/.local/bin:$PATH"
        ```
    *   **Fish**:
        ```fish
        fish_add_path ~/.local/bin
        ```
    *(Do not forget to reload your terminal or run `source ~/.bashrc` after saving).*

3.  **Install Git hooks in the repository**:
    Navigate to the root of `proyecto_led` and run:
    ```bash
    pre-commit install
    ```

---

## 4. Validate the Environment

To verify that the entire workflow is working natively on your system, you can force the manual execution of all linters and formatters on the project files without needing to make a commit:

```bash
pre-commit run --all-files
```

If everything is configured correctly, you should see an output similar to this indicating that everything passes or auto-formats successfully:

```text
Verible Verilog Format...................................................Passed
Verible Verilog Lint.....................................................Passed
Verilator Linting........................................................Passed
```

---

## Environment Structure

Once installed, the development workflow operates as follows:
*   **Formatter**: Uses [.verible-format](.verible-format) to maintain a consistent style.
*   **Linter Rules**: Uses [.rules.verible_lint](.rules.verible_lint) to ignore or enforce specific SystemVerilog style warnings.
*   **Compilation Linter**: [verilator_lint.sh](tools/verilator_lint.sh) compiles your code with Verilator to detect complex semantic errors (such as combinational loops, unwanted latches, etc.) using the file list [files.f](files.f).
