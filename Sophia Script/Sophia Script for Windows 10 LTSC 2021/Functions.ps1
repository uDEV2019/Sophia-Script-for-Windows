﻿<#
	.SYNOPSIS
	The TAB completion for functions and their arguments

	Version: v5.13.2
	Date: 16.07.2022

	Copyright (c) 2014—2022 farag
	Copyright (c) 2019—2022 farag & Inestic

	Thanks to all https://forum.ru-board.com members involved

	.DESCRIPTION
	Dot source the script first: . .\Function.ps1 (with a dot at the beginning)
	Start typing any characters contained in the function's name or its arguments, and press the TAB button

	.EXAMPLE
	Sophia -Functions <tab>
	Sophia -Functions temp<tab>
	Sophia -Functions "DiagTrackService -Disable", "DiagnosticDataLevel -Minimal"

	.NOTES
	Set execution policy to be able to run scripts only in the current PowerShell session:
		Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

	.NOTES
	Use commas to separate funtions

	.LINK
	https://github.com/farag2/Sophia-Script-for-Windows
#>

#Requires -RunAsAdministrator
#Requires -Version 5.1

function Sophia
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $false)]
		[string[]]
		$Functions
	)

	foreach ($Function in $Functions)
	{
		Invoke-Expression -Command $Function
	}

	# The "RefreshEnvironment" and "Errors" functions will be executed at the end
	Invoke-Command -ScriptBlock {RefreshEnvironment; Errors}
}

Clear-Host

$Host.UI.RawUI.WindowTitle = "Sophia Script for Windows 10 LTSC 2021 v5.13.2 | Made with $([char]::ConvertFromUtf32(0x1F497)) of Windows | $([char]0x00A9) farag & Inestic, 2014$([char]0x2013)2022"

Remove-Module -Name Sophia -Force -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\Manifest\Sophia.psd1 -PassThru -Force

# Import module for modifying registry.pol files (Administrative Templates) of local GPOs
# https://www.powershellgallery.com/packages/PolicyFileEditor
Remove-Module -Name PolicyFileEditor -Force -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\bin\PolicyFileEditor\PolicyFileEditor.psd1 -PassThru -Force

Import-LocalizedData -BindingVariable Global:Localization -FileName Sophia -BaseDirectory $PSScriptRoot\Localizations

# The mandatory checkings. Please, do not comment out this function
Checkings

$Parameters = @{
	CommandName   = "Sophia"
	ParameterName = "Functions"
	ScriptBlock   = {
		param
		(
			$commandName,
			$parameterName,
			$wordToComplete,
			$commandAst,
			$fakeBoundParameters
		)

		# Get functions list with arguments to complete
		$Commands = (Get-Module -Name Sophia).ExportedCommands.Keys
		foreach ($Command in $Commands)
		{
			$ParameterSets = (Get-Command -Name $Command).Parametersets.Parameters | Where-Object -FilterScript {$null -eq $_.Attributes.AliasNames}

			# If a module command is PinToStart
			if ($Command -eq "PinToStart")
			{
				# Get all command arguments, excluding defaults
				foreach ($ParameterSet in $ParameterSets.Name)
				{
					# If an argument is Tiles
					if ($ParameterSet -eq "Tiles")
					{
						$ValidValues = ((Get-Command -Name PinToStart).Parametersets.Parameters | Where-Object -FilterScript {$null -eq $_.Attributes.AliasNames}).Attributes.ValidValues
						foreach ($ValidValue in $ValidValues)
						{
							# The "PinToStart -Tiles <function>" construction
							"PinToStart" + " " + "-" + $ParameterSet + " " + $ValidValue | Where-Object -FilterScript {$_ -like "*$wordToComplete*"} | ForEach-Object -Process {"`"$_`""}
						}

						# The "PinToStart -Tiles <functions>" construction
						"PinToStart" + " " + "-" + $ParameterSet + " " + ($ValidValues -join ", ") | Where-Object -FilterScript {$_ -like "*$wordToComplete*"} | ForEach-Object -Process {"`"$_`""}
					}

					continue
				}
			}

			foreach ($ParameterSet in $ParameterSets.Name)
			{
				# The "Function -Argument" construction
				$Command + " " + "-" + $ParameterSet | Where-Object -FilterScript {$_ -like "*$wordToComplete*"} | ForEach-Object -Process {"`"$_`""}

				continue
			}

			# Get functions list without arguments to complete
			Get-Command -Name $Command | Where-Object -FilterScript {$null -eq $_.Parametersets.Parameters} | Where-Object -FilterScript {$_.Name -like "*$wordToComplete*"}

			continue
		}
	}
}
Register-ArgumentCompleter @Parameters

Write-Information -MessageData "" -InformationAction Continue
Write-Verbose -Message "Sophia -Functions <tab>" -Verbose
Write-Verbose -Message "Sophia -Functions temp<tab>" -Verbose
Write-Verbose -Message "Sophia -Functions `"DiagTrackService -Disable`", `"DiagnosticDataLevel -Minimal`"" -Verbose
Write-Information -MessageData "" -InformationAction Continue
Write-Verbose -Message "`"PinToStart -UnpinAll`"" -Verbose
Write-Verbose -Message "`"Set-Association -ProgramPath ```"%ProgramFiles%\Notepad++\notepad++.exe```" -Extension .txt -Icon ```"%ProgramFiles%\Notepad++\notepad++.exe,0```"`"" -Verbose

# SIG # Begin signature block
# MIIbvwYJKoZIhvcNAQcCoIIbsDCCG6wCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDvezW14P/qc04oK/VJGnDlXl
# 55CgghY3MIIDAjCCAeqgAwIBAgIQbPiUYMntEr9PH9C5Mau3xTANBgkqhkiG9w0B
# AQsFADAZMRcwFQYDVQQDDA5Tb3BoaWEgUHJvamVjdDAeFw0yMjA3MTYxNDM2MDda
# Fw0yNDA3MTYxNDQ2MDdaMBkxFzAVBgNVBAMMDlNvcGhpYSBQcm9qZWN0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtFM5b/hNUQPcNCKlWVisE5zIERdC
# TZWdsnkliCg98qv0qkPH08AAuZ5LOgdctfaocVX4RbygcWCLyaphktSC29aMHmP/
# T/JPBSYnLmWIJ6NbNVBn4BqqCZusjmYRj1LH+Ega9Kv4gFfF4lyCE8OnebDkWPu1
# Y+5VAoZ6BaVvHEw5rtrHcH8/W15mE1Z+uuYIKNVPg3MMGNGQ5MiLUduuCu5l+J4K
# yU/nLvx7tI3tIx8wJY2S2SYDNPf/bMOeeb0jlcD1/bVh5TNn3Z4wIXQ3r4yNxllO
# dBPidPT3Ck4+aDTzP/Y8vrFeIMLKSCYGY+cOCankPZmUCVFJxABvW5EKDQIDAQAB
# o0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0O
# BBYEFMJrBhADhZmuEvA18MvGfrBsUpDhMA0GCSqGSIb3DQEBCwUAA4IBAQCzuSeY
# YdiLsJYFPUW21r2QjSbIi7oOAa58Y2C7KM+QvAm7R6W7l3y6Zz58mBZmSCt+u6au
# HHYYxo71eCKcH6Lx/2BAeg3GBfZClCZ480nxH1+T4fobdWuT/f4Iw8ZalqcnqJQQ
# xXhK2U8sMS6oIlb8VZhzosiP68gSZwNgcBbO8P1nAVa7WXyhdmo5CTpa1CihfOT2
# a3x7runLfgPHmgDcTQpJYAl4xA1JgM+5adlGo33uDXNDgN+6MPZKCuD89wFIYbXw
# WM6i+SHOBvqACWvM5goBCiVuIq2aI/6r6jeW8UiN51L0/IIniY+P0e7ZibjiadZR
# DuMQLs5d3GLELtT3MIIFsTCCBJmgAwIBAgIQASQK+x44C4oW8UtxnfTTwDANBgkq
# hkiG9w0BAQwFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBB
# c3N1cmVkIElEIFJvb3QgQ0EwHhcNMjIwNjA5MDAwMDAwWhcNMzExMTA5MjM1OTU5
# WjBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQL
# ExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJv
# b3QgRzQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1K
# PDAiMGkz7MKnJS7JIT3yithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2r
# snnyyhHS5F/WBTxSD1Ifxp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C
# 8weE5nQ7bXHiLQwb7iDVySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBf
# sXpm7nfISKhmV1efVFiODCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGY
# QJB5w3jHtrHEtWoYOAMQjdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8
# rhsDdV14Ztk6MUSaM0C/CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaY
# dj1ZXUJ2h4mXaXpI8OCiEhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+
# wJS00mFt6zPZxd9LBADMfRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw
# ++hkpjPRiQfhvbfmQ6QYuKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+N
# P8m800ERElvlEFDrMcXKchYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7F
# wI+isX4KJpn15GkvmB0t9dmpsh3lGwIDAQABo4IBXjCCAVowDwYDVR0TAQH/BAUw
# AwEB/zAdBgNVHQ4EFgQU7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAU
# Reuir/SSy4IxLVGLp6chnfNtyA8wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MEUGA1UdHwQ+MDww
# OqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJ
# RFJvb3RDQS5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0G
# CSqGSIb3DQEBDAUAA4IBAQCaFgKlAe+B+w20WLJ4ragjGdlzN9pgnlHXy/gvQLmj
# H3xATjM+kDzniQF1hehiex1W4HG63l7GN7x5XGIATfhJelFNBjLzxdIAKicg6oku
# FTngLD74dXwsgkFhNQ8j0O01ldKIlSlDy+CmWBB8U46fRckgNxTA7Rm6fnc50lSW
# x6YR3zQz9nVSQkscnY2W1ZVsRxIUJF8mQfoaRr3esOWRRwOsGAjLy9tmiX8rnGW/
# vjdOvi3znUrDzMxHXsiVla3Ry7sqBiD5P3LqNutFcpJ6KXsUAzz7TdZIcXoQEYoI
# dM1sGwRc0oqVA3ZRUFPWLvdKRsOuECxxTLCHtic3RGBEMIIGrjCCBJagAwIBAgIQ
# BzY3tyRUfNhHrP0oZipeWzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEV
# MBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29t
# MSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAw
# MDAwWhcNMzcwMzIyMjM1OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGln
# aUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5
# NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
# MIICCgKCAgEAxoY1BkmzwT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYR
# oUQVQl+kiPNo+n3znIkLf50fng8zH1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CE
# iiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCH
# RgB720RBidx8ald68Dd5n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5K
# fc71ORJn7w6lY2zkpsUdzTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDni
# pUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2
# nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp
# 88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1C
# vwWcZklSUPRR8zZJTYsg0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+
# 0wOI/rOP015LdhJRk8mMDDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl2
# 7KtdRnXiYKNYCQEoAA6EVO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOC
# AV0wggFZMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaa
# L3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1Ud
# DwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkw
# JAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcw
# AoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJv
# b3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwB
# BAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+
# ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvX
# bYf6hCAlNDFnzbYSlm/EUExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tP
# iix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCy
# Xen/KFSJ8NWKcXZl2szwcqMj+sAngkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpF
# yd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3
# fpNTrDsdCEkPlM05et3/JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t
# 5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejx
# mF/7K9h+8kaddSweJywm228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxah
# ZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAA
# zV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vup
# L0QVSucTDh3bNzgaoSv27dZ8/DCCBsYwggSuoAMCAQICEAp6SoieyZlCkAZjOE2G
# l50wDQYJKoZIhvcNAQELBQAwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lD
# ZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYg
# U0hBMjU2IFRpbWVTdGFtcGluZyBDQTAeFw0yMjAzMjkwMDAwMDBaFw0zMzAzMTQy
# MzU5NTlaMEwxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjEk
# MCIGA1UEAxMbRGlnaUNlcnQgVGltZXN0YW1wIDIwMjIgLSAyMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAuSqWI6ZcvF/WSfAVghj0M+7MXGzj4CUu0jHk
# PECu+6vE43hdflw26vUljUOjges4Y/k8iGnePNIwUQ0xB7pGbumjS0joiUF/DbLW
# +YTxmD4LvwqEEnFsoWImAdPOw2z9rDt+3Cocqb0wxhbY2rzrsvGD0Z/NCcW5QWpF
# QiNBWvhg02UsPn5evZan8Pyx9PQoz0J5HzvHkwdoaOVENFJfD1De1FksRHTAMkcZ
# W+KYLo/Qyj//xmfPPJOVToTpdhiYmREUxSsMoDPbTSSF6IKU4S8D7n+FAsmG4dUY
# FLcERfPgOL2ivXpxmOwV5/0u7NKbAIqsHY07gGj+0FmYJs7g7a5/KC7CnuALS8gI
# 0TK7g/ojPNn/0oy790Mj3+fDWgVifnAs5SuyPWPqyK6BIGtDich+X7Aa3Rm9n3RB
# Cq+5jgnTdKEvsFR2wZBPlOyGYf/bES+SAzDOMLeLD11Es0MdI1DNkdcvnfv8zbHB
# p8QOxO9APhk6AtQxqWmgSfl14ZvoaORqDI/r5LEhe4ZnWH5/H+gr5BSyFtaBocra
# MJBr7m91wLA2JrIIO/+9vn9sExjfxm2keUmti39hhwVo99Rw40KV6J67m0uy4rZB
# Peevpxooya1hsKBBGBlO7UebYZXtPgthWuo+epiSUc0/yUTngIspQnL3ebLdhOon
# 7v59emsCAwEAAaOCAYswggGHMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAA
# MBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsG
# CWCGSAGG/WwHATAfBgNVHSMEGDAWgBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNV
# HQ4EFgQUjWS3iSH+VlhEhGGn6m8cNo/drw0wWgYDVR0fBFMwUTBPoE2gS4ZJaHR0
# cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNI
# QTI1NlRpbWVTdGFtcGluZ0NBLmNybDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYB
# BQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0
# cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5
# NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAgEADS0j
# dKbR9fjqS5k/AeT2DOSvFp3Zs4yXgimcQ28BLas4tXARv4QZiz9d5YZPvpM63io5
# WjlO2IRZpbwbmKrobO/RSGkZOFvPiTkdcHDZTt8jImzV3/ZZy6HC6kx2yqHcoSuW
# uJtVqRprfdH1AglPgtalc4jEmIDf7kmVt7PMxafuDuHvHjiKn+8RyTFKWLbfOHzL
# +lz35FO/bgp8ftfemNUpZYkPopzAZfQBImXH6l50pls1klB89Bemh2RPPkaJFmMg
# a8vye9A140pwSKm25x1gvQQiFSVwBnKpRDtpRxHT7unHoD5PELkwNuTzqmkJqIt+
# ZKJllBH7bjLx9bs4rc3AkxHVMnhKSzcqTPNc3LaFwLtwMFV41pj+VG1/calIGnjd
# RncuG3rAM4r4SiiMEqhzzy350yPynhngDZQooOvbGlGglYKOKGukzp123qlzqkhq
# WUOuX+r4DwZCnd8GaJb+KqB0W2Nm3mssuHiqTXBt8CzxBxV+NbTmtQyimaXXFWs1
# DoXW4CzM4AwkuHxSCx6ZfO/IyMWMWGmvqz3hz8x9Fa4Uv4px38qXsdhH6hyF4EVO
# EhwUKVjMb9N/y77BDkpvIJyu2XMyWQjnLZKhGhH+MpimXSuX4IvTnMxttQ2uR2M4
# RxdbbxPaahBuH0m3RFu0CAqHWlkEdhGhp3cCExwxggTyMIIE7gIBATAtMBkxFzAV
# BgNVBAMMDlNvcGhpYSBQcm9qZWN0AhBs+JRgye0Sv08f0Lkxq7fFMAkGBSsOAwIa
# BQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3
# DQEJBDEWBBT8JkagQawFhCS1VsCbUyHmLG0uRDANBgkqhkiG9w0BAQEFAASCAQAT
# 3e0ewmvIQdCOzPD0wJrZecNLrmWVDNlzV8aH23pyP7E6NXhf5wojBs17pTBIgJlN
# 56aHlt0sH8PON9xcFalvVpzBZzIXtinWqkvcHbI87a3e3Jyj2YVxHXxQB/khIvsO
# YtpKB3N//IqtHg9Lpr4gvuuG5ZzxSZhE4lvaoKQ3PRNbMSo/3agVfQiQG3XCAkZo
# 4yXjzdTeqs0GJ3bBftlZrIjOwdOu04S/oQDTYNslz7LOrR6//SAmPjzCxRPsB+4b
# RxdOsZGHsP1LRBVJjsNhzDbDcMt2PJ5XecBFLPU5AkbjKwpW3GMkTz94LZxv8oVj
# 5cOhB8OihCmF17O+XnjHoYIDIDCCAxwGCSqGSIb3DQEJBjGCAw0wggMJAgEBMHcw
# YzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQD
# EzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGlu
# ZyBDQQIQCnpKiJ7JmUKQBmM4TYaXnTANBglghkgBZQMEAgEFAKBpMBgGCSqGSIb3
# DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIyMDcxNjE0NDYxMFow
# LwYJKoZIhvcNAQkEMSIEIF0Ls78WrVNJtlL1XPeaLJ+27hYWizXIcz/jKzjbKvCC
# MA0GCSqGSIb3DQEBAQUABIICAEVx8oR6IGjAkofLvZeLACnHFFrlGzms41943Ux+
# i7ES0+bR5yb42GsZ+AAaumcWqnDGjxEHcMVPZWqmz7/XDddGHDHuBIxLSUYGcS1O
# Im0eiejT8v52gfkMgRfERJ3H7NKzoLik3y8ic+puX8S5Zt2MRoV8ow5dWi53gKn7
# qUHVgMLYGHjkRyRFywmAgIbApMgvfCB8o1VTLbo8LuGMWwInSJMNF2bl4QsNqW2m
# R8+jg/hUmM5dUkZ0mv9CqLcX2VQA6mZtmD+I5JuBiob6QDVdEjOG25sZx60I28y/
# zq+3/rIpiD9Kh3GsUmqFi5Lsoh5wz66rqLk1WE2/+Wy4pNaPKGhhodhwG6rK1c/9
# KRkUzeT0QL8Dl61hYY56lhEFhW1jcT/QsxTDRn/cwIMvvtoP21KSoaoDgykg1dG4
# 2VcjE2n1oWIOfsTIK3rJO6fPKOZlvHCSuFN5oTGBI/SVzRLfhMaTU+QnrXtGapIZ
# BajT3sjRs3QF+tw0JfRjd+WxC+vxmhwd59359HXuIaO41q7Y6lo2TolwyJetNPLy
# rI5CsiLQW2M/38AA81/P/2wpM0qIa1d5ezLTrjZlmRGAq0PtKDxmG9rI8jBLh5H5
# dhizOe43fnS5H2rX/K7d9ey+yYtuHxxFqzlA/Ir+bswv8RyW0lCouT9KPj1k/Bad
# vx1y
# SIG # End signature block
