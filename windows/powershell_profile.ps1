oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\catppuccin_frappe.omp.json" | Invoke-Expression
function Set-PoshTheme {
    param([string]$Theme)
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\$Theme.omp.json" | Invoke-Expression
}

