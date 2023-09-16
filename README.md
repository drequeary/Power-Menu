# Powershell Power Menu
A powershell arrow driven, single and multiselect menu.

[demo](https://cdn.drequeary.me/public/assets/img/power-menu-demo.gif)

# Manual Installation
- Download zip
- Copy files to C:\Program Files\WindowsPowerShell\Modules\power-menu
- From C:\Program Files\WindowsPowerShell\Modules, open Terminal and run: `Import-Module power-menu`

# Usage
## Create Single Select Menu
`New-SelectMenu @("Option 1", "Option 2", "Option 3")`

## Creating Multiselect Menu
`New-SelectMenu @("Option 1", "Option 2", "Option 3") -Multiselect`

## Credits
This is a slightly modified version of ps-menu by chrisseroka. https://github.com/chrisseroka/ps-menu
