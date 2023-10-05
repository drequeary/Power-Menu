<#PSScriptInfo

.SYNOPSIS
A powershell arrow driven, single and multiselect menu.

.DESCRIPTION
This script can be used to generate a single or multiselect
menu with up and down navigation then return selected item(s).

.EXAMPLE
    EXAMPLE 1 (single select)
    New-SelectMenu @("Option 1", "Option 2", "Option 3")

    EXAMPLE 2 (multiselect)
    New-SelectMenu @("Option 1", "Option 2", "Option 3") -Multiselect

.NOTES
CONTROLS
    UP - go up
    DOWN - go down
    ENTER - select (single select)
    SPACE - select (multiselect)
    ESC - exit menu (returns null)

.CREDITS
    Developer - DeAndre Wilson @DreQueary.
    GitHub - https://github.com/drequeary
    Repository - https://github.com/drequeary/power-menu

    This is a slightly modified version of ps-menu by chrisseroka
    https://github.com/chrisseroka/ps-menu

    Changes from original:
        Changed variable and function names.
        Added clear-host for when menu options overflow window height.
        Uses modern emojis for checkboxes instead of ugly ascii.
        Removed J and K controls.
#>

$PSVersion = $Host.Version.major

<#
.SYNOPSIS
    Renders menu options.

.PARAMETER Options
    Array of options to display in menu list.

.PARAMETER POS
    Position of cursor.

.PARAMETER CurrentSelection
    Current selected menu item index number.

.PARAMETER Multiselect
    Display as multiselect menu.
#>
function Draw-Menu
{
    param (
        $Options, 
        $POS, 
        $CurrentSelection,
        $Multiselect
    )

    # Loop through options, highlighting current cursor position.
    for($i = 0; $i -le $Options.length; $i ++) {
        if($null -ne $Options[$i]) {
            $Option = $Options[$i]

            # For multiselect menus, show a checkmark for choosen items
            # or x out for non-choosen items.
            if ($Multiselect -and $PSVersion -ge 7) {
                if ($CurrentSelection -contains $i) {
                    $Option = "[✅] " + $Option
                } else {
                    $Option = "[✖️] " + $Option
                }
            } elseif ($Multiselect) {
                if ($CurrentSelection -contains $i) {
                    $Option = "[*] " + $Option
                } else {
                    $Option = "[ ] " + $Option
                }
            }

            # For single select menus, show green highlight and
            # an arrow emoji for highlighted item. Else just
            # display the option.
            if ($PSVersion -ge 7) {
                if ($i -eq $POS) {
                    Write-Host "➡️ $Option" -ForegroundColor Green
                } else {
                    Write-Host "   $Option"
                }
            } else {
                if ($i -eq $POS) {
                    Write-Host "> $Option" -ForegroundColor Green
                } else {
                    Write-Host "  $Option"
                }
            }
        }
    }
}

<#
.SYNOPSIS
    Set or multiselect option.

.PARAMETER POS
    Position of cursor.

.PARAMETER CurrentSelection
    Current selected menu item index number.
#>
function Set-MultiSelect
{
	param (
        $POS, 
        [array] $CurrentSelection
    )

	if ($CurrentSelection -contains $POS){ 
		$Result = $CurrentSelection | Where-Object { $_ -ne $POS }
	} else {
		$CurrentSelection += $POS
		$Result = $CurrentSelection
	}

	$Result
}

<#
.SYNOPSIS
    Renders select or multiselect menu.

.DESCRIPTION
    Displays menu and listens for keyboard input.
    As menu controls are pressed, menu updates selected item.
    Upon pressing enter, return selected item or item(s) as,
    an array.

    If the esc key is pressed, exit menu, returning null.

    .PARAMETER Options
        Array of options to display in menu list.

    .PARAMETER Multiselect
        Display as menu options as multiselect.

    .PARAMETER ReturnIndex
        Set whether to return selected item(s).
#>
function New-SelectMenu
{
    param (
        [array] $Options,
        [switch] $Multiselect,
        [switch] $ReturnIndex = $False
    )

    $Key = 0
    $POS = 0
    $CurrentSelection = @()

    if ($Options.length -gt 0) {
        try {
            [console]::CursorVisible = $False
            Draw-Menu -Options $Options -POS $POS -CurrentSelection $CurrentSelection -Multiselect $Multiselect 

            while ($Key -ne 13 -and $Key -ne 27) {
                $Key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode

                # UP ARROW GOES TO NEXT OPTION UP
                if ($Key -eq 38 -and $Options.length -gt 0) {            
                    $POS--
                } 
                
                # DOWN ARROW GOES TO NEXT OPTION DOWN
                if ($Key -eq 40 -and $Options.length -gt 0) {
                    $POS++
                }

                # DOWN ARROW ON LAST ITEM GOES BACK TO FIRST ITEM
                if ($POS -eq $Options.length) {
                    $POS = 0
                }

                # UP ARROW ON FIRST ITEM GOES DOWN TO LAST ITEM
                if ($POS -lt 0) {
                    $POS = $Options.length - 1
                }

                # SPACEBAR SELECTS AN OPTION IN MULTISELECT MENU
                if ($Key -eq 32) { 
                    $CurrentSelection = Set-MultiSelect -POS $POS -CurrentSelection $CurrentSelection 
                }

                # ESC QUITS MENU
                if ($Key -eq 27) {
                    $POS = $null 
                }

                if ($Key -ne 27) {
                    try {
                        $NewPOS = [System.Console]::CursorTop - $Options.length
                        [System.Console]::SetCursorPosition(0, $NewPOS)
                    } catch {
                        Clear-Host
                    }

                    Draw-Menu -Options $Options -POS $POS -Multiselect $Multiselect -CurrentSelection $CurrentSelection
                }
            }
        } finally {
            try {
			    [System.Console]::SetCursorPosition(0, $NewPOS + $Options.length)
            } catch {
                Clear-Host
            }

			[console]::CursorVisible = $True
		}
    } else {
        $POS = $null
    }

    # Return selected item.
    if ($ReturnIndex -eq $False -and $null -ne $POS) {
		if ($Multiselect) {
			Return $Options[$CurrentSelection]
		} else {
			Return $Options[$POS]
		}
	} else {
		if ($Multiselect) {
			Return $CurrentSelection
		} else {
			Return $POS
		}
	}
}