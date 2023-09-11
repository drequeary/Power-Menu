<#PSScriptInfo

.SYNOPSIS
An arrow driven, single and multiselect menu.

.DESCRIPTION
This script can be used to generate a single or multiselect
menu with up and down navigation then return selected item(s).

.EXAMPLE
New-Select-Menu -Options @("Option 1", "Option 2")
New-Select-Menu -Options @("Option 1", "Option 2") -Multiselect

.NOTES
CONTROLS
    UP - go up
    DOWN - go down
    ENTER - select (single select)
    SPACE - select (multiselect)
    ESC - exit menu (returns null)

.CREDITS
    This is a slightly modified version of ps-menu by chrisseroka
    https://github.com/chrisseroka/ps-menu

    Changes from original:
        Changed variable and function names.
        Added clear-host for when menu options overflow window height.
        Uses modern emojis for checkboxes instead of ugly ascii.
        Removed J and K controls.
#>

function Draw-Select-Menu
{
    param (
        $Options, 
        $POS, 
        $CurrentSelection,
        $Multiselect
    )

    for($i = 0; $i -le $Options.length; $i ++) {
        if($null -ne $Options[$i]) {
            $Option = $Options[$i]

            if ($Multiselect) {
                if ($CurrentSelection -contains $i) {
                    $Option = "[✅] " + $Option
                } else {
                    $Option = "[✖️] " + $Option
                }
            }

            if ($i -eq $POS) {
                Write-Host "➡️ $Option" -ForegroundColor Green
			} else {
				Write-Host "   $Option"
			}
        }
    }
}

function Set-Multi-Selection
{
	param (
        $POS, 
        [array] $CurrentSelection
    )

	if ($CurrentSelection -contains $POS){ 
		$Result = $CurrentSelection | where { $_ -ne $POS }
	} else {
		$CurrentSelection += $POS
		$Result = $CurrentSelection
	}

	$Result
}

function New-Select-Menu
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
            Draw-Select-Menu -Options $Options -POS $POS -CurrentSelection $CurrentSelection -Multiselect $Multiselect 

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
                    $CurrentSelection = Set-Multi-Selection -POS $POS -CurrentSelection $CurrentSelection 
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

                    Draw-Select-Menu -Options $Options -POS $POS -Multiselect $Multiselect -CurrentSelection $CurrentSelection
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

# DEMO
$Options = @()

for ($i = 0; $i -le 10; $i ++) {
    $Options = $Options + "Option $i"
}

Clear-Host

# Example 1 (single select)
New-Select-Menu $Options
Pause

#Example 2 (multiselect)
New-Select-Menu $Options -Multiselect
Pause

Return