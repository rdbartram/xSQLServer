# Suppressing this rule because PlainText is required for one of the functions used in this test
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param()

$script:DSCModuleName      = 'xSQLServer'
$script:DSCResourceName    = 'MSFT_xSQLServerSetup'

#region HEADER

# Unit Test Template Version: 1.2.0
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit

#endregion HEADER

function Invoke-TestSetup {
}

function Invoke-TestCleanup {
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}

# Begin Testing
try
{
    Invoke-TestSetup

    InModuleScope $script:DSCResourceName {
        # Testing each supported SQL Server version
        $testProductVersion = @(
            13, # SQL Server 2016
            12, # SQL Server 2014
            11, # SQL Server 2012
            10  # SQL Server 2008 and 2008 R2
        )

        $mockSqlDatabaseEngineName = 'MSSQL'
        $mockSqlAgentName = 'SQLAgent'
        $mockSqlFullTextName = 'MSSQLFDLauncher'
        $mockSqlReportingName = 'ReportServer'
        $mockSqlIntegrationName = 'MsDtsServer{0}0' # {0} will be replaced by SQL major version in runtime
        $mockSqlAnalysisName = 'MSOLAP'

        $mockSqlCollation = 'Finnish_Swedish_CI_AS'
        $mockSqlLoginMode = 'Integrated'

        $mockSqlSharedDirectory = 'C:\Program Files\Microsoft SQL Server'
        $mockSqlSharedWowDirectory = 'C:\Program Files (x86)\Microsoft SQL Server'
        $mockSqlProgramDirectory = 'C:\Program Files\Microsoft SQL Server'
        $mockSqlSystemAdministrator = 'COMPANY\Stacy'

        $mockSqlAnalysisCollation = 'Finnish_Swedish_CI_AS'
        $mockSqlAnalysisAdmins = @('COMPANY\Stacy','COMPANY\SSAS Administrators')
        $mockSqlAnalysisDataDirectory = 'C:\Program Files\Microsoft SQL Server\OLAP\Data'
        $mockSqlAnalysisTempDirectory= 'C:\Program Files\Microsoft SQL Server\OLAP\Temp'
        $mockSqlAnalysisLogDirectory = 'C:\Program Files\Microsoft SQL Server\OLAP\Log'
        $mockSqlAnalysisBackupDirectory = 'C:\Program Files\Microsoft SQL Server\OLAP\Backup'
        $mockSqlAnalysisConfigDirectory = 'C:\Program Files\Microsoft SQL Server\OLAP\Config'

        $mockDefaultInstance_InstanceName = 'MSSQLSERVER'
        $mockDefaultInstance_DatabaseServiceName = $mockDefaultInstance_InstanceName
        $mockDefaultInstance_AgentServiceName = 'SQLSERVERAGENT'
        $mockDefaultInstance_FullTextServiceName = $mockSqlFullTextName
        $mockDefaultInstance_ReportingServiceName = $mockSqlReportingName
        $mockDefaultInstance_IntegrationServiceName = $mockSqlIntegrationName
        $mockDefaultInstance_AnalysisServiceName = 'MSSQLServerOLAPService'

        $mockNamedInstance_InstanceName = 'TEST'
        $mockNamedInstance_DatabaseServiceName = "$($mockSqlDatabaseEngineName)`$$($mockNamedInstance_InstanceName)"
        $mockNamedInstance_AgentServiceName = "$($mockSqlAgentName)`$$($mockNamedInstance_InstanceName)"
        $mockNamedInstance_FullTextServiceName = "$($mockSqlFullTextName)`$$($mockNamedInstance_InstanceName)"
        $mockNamedInstance_ReportingServiceName = "$($mockSqlReportingName)`$$($mockNamedInstance_InstanceName)"
        $mockNamedInstance_IntegrationServiceName = $mockSqlIntegrationName
        $mockNamedInstance_AnalysisServiceName = "$($mockSqlAnalysisName)`$$($mockNamedInstance_InstanceName)"

        $mockmockSetupCredentialUserName = "COMPANY\sqladmin"
        $mockmockSetupCredentialPassword = "dummyPassw0rd" | ConvertTo-SecureString -asPlainText -Force
        $mockSetupCredential = New-Object System.Management.Automation.PSCredential( $mockmockSetupCredentialUserName, $mockmockSetupCredentialPassword )

        $mockSqlServiceAccount = 'COMPANY\SqlAccount'
        $mockAgentServiceAccount = 'COMPANY\AgentAccount'

        $mockSourceFolder = 'Source' #  The parameter SourceFolder has a default value of 'Source', so lets mock that as well.

        #region Function mocks
        $mockGetSQLVersion = {
            return $mockSqlMajorVersion
        }

        $mockEmptyHashtable = {
            return @()
        }

        $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber = '{72AB7E6F-BC24-481E-8C45-1AB5B3DD795D}'
        $mockSqlServerManagementStudio2012_ProductIdentifyingNumber = '{A7037EB2-F953-4B12-B843-195F4D988DA1}'
        $mockSqlServerManagementStudio2014_ProductIdentifyingNumber = '{75A54138-3B98-4705-92E4-F619825B121F}'
        $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber = '{B5FE23CC-0151-4595-84C3-F1DE6F44FE9B}'
        $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber = '{7842C220-6E9A-4D5A-AE70-0E138271F883}'
        $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber = '{B5ECFA5C-AC4F-45A4-A12E-A76ABDD9CCBA}'

        $mockRegistryUninstallProductsPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall'

        $mockGetItemProperty_UninstallProducts2008R2 = {
            return @(
                $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber,  # Mock product SSMS 2008 and SSMS 2008 R2
                $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber  # Mock product ADV_SSMS 2012
            )
        }

        $mockGetItemProperty_UninstallProducts2012 = {
            return @(
                $mockSqlServerManagementStudio2012_ProductIdentifyingNumber,    # Mock product ADV_SSMS 2008 and ADV_SSMS 2008 R2
                $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber    # Mock product SSMS 2014
            )
        }

        $mockGetItemProperty_UninstallProducts2014 = {
            return @(
                $mockSqlServerManagementStudio2014_ProductIdentifyingNumber,    # Mock product SSMS 2012
                $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber     # Mock product ADV_SSMS 2014
            )
        }

        $mockGetItemProperty_UninstallProducts = {
            return @(
                $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber,  # Mock product SSMS 2008 and SSMS 2008 R2
                $mockSqlServerManagementStudio2012_ProductIdentifyingNumber,    # Mock product ADV_SSMS 2008 and ADV_SSMS 2008 R2
                $mockSqlServerManagementStudio2014_ProductIdentifyingNumber,    # Mock product SSMS 2012
                $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber,  # Mock product ADV_SSMS 2012
                $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber,    # Mock product SSMS 2014
                $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber     # Mock product ADV_SSMS 2014
            )
        }

        $mockGetCimInstance_DefaultInstance_DatabaseService = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockDefaultInstance_DatabaseServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                )
            )
        }

        $mockGetCimInstance_DefaultInstance_AgentService = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockDefaultInstance_AgentServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockAgentServiceAccount -PassThru -Force
                )
            )
        }

        $mockGetCimInstance_DefaultInstance_FullTextService = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockDefaultInstance_FullTextServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                )
            )
        }

        $mockGetCimInstance_DefaultInstance_ReportingService = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockDefaultInstance_ReportingServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                )
            )
        }

        $mockGetCimInstance_DefaultInstance_IntegrationService = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value ($mockDefaultInstance_IntegrationServiceName -f $mockSqlMajorVersion) -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                )
            )
        }

        $mockGetCimInstance_DefaultInstance_AnalysisService = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockDefaultInstance_AnalysisServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                )
            )
        }

        $mockGetService_DefaultInstance = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockDefaultInstance_DatabaseServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                ),
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockDefaultInstance_AgentServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockAgentServiceAccount -PassThru -Force
                ),
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockDefaultInstance_FullTextServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                ),
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockDefaultInstance_ReportingServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                ),
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value ($mockDefaultInstance_IntegrationServiceName -f $mockSqlMajorVersion) -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                ),
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockDefaultInstance_AnalysisServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                )
            )
        }

        $mockGetCimInstance_NamedInstance_DatabaseService = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockNamedInstance_DatabaseServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                )
            )
        }

        $mockGetCimInstance_NamedInstance_AgentService = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockNamedInstance_AgentServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockAgentServiceAccount -PassThru -Force
                )
            )
        }

        $mockGetCimInstance_NamedInstance_FullTextService = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockNamedInstance_FullTextServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                )
            )
        }

        $mockGetCimInstance_NamedInstance_ReportingService = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockNamedInstance_ReportingServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                )
            )
        }

        $mockGetCimInstance_NamedInstance_IntegrationService = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value ($mockNamedInstance_IntegrationServiceName -f $mockSqlMajorVersion) -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                )
            )
        }

        $mockGetCimInstance_NamedInstance_AnalysisService = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockNamedInstance_AnalysisServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                )
            )
        }

        $mockGetService_NamedInstance = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockNamedInstance_DatabaseServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                ),
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockNamedInstance_AgentServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockAgentServiceAccount -PassThru -Force
                ),
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockNamedInstance_FullTextServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                ),
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockNamedInstance_ReportingServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                ),
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value ($mockNamedInstance_IntegrationServiceName -f $mockSqlMajorVersion) -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                ),
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockNamedInstance_AnalysisServiceName -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'StartName' -Value $mockSqlServiceAccount -PassThru -Force
                )
            )
        }

        $mockGetItemProperty_ConfigurationState = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'SQL_Replication_Core_Inst' -Value 1 -PassThru -Force
                )
            )
        }

        $mockGetItemProperty_SQL = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name $mockDefaultInstance_InstanceName -Value $mockDefaultInstance_InstanceId -PassThru -Force
                ),
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name $mockNamedInstance_InstanceName -Value $mockNamedInstance_InstanceId -PassThru -Force
                )
            )
        }

        $mockGetItemProperty_SharedDirectory = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name '28A1158CDF9ED6B41B2B7358982D4BA8' -Value $mockSqlSharedDirectory -PassThru -Force
                )
            )
        }

        $mockGetItem_SharedDirectory = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Property' -Value '28A1158CDF9ED6B41B2B7358982D4BA8' -PassThru -Force
                )
            )
        }

        $mockGetItemProperty_SharedWowDirectory = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name '28A1158CDF9ED6B41B2B7358982D4BA8' -Value $mockSqlSharedWowDirectory -PassThru -Force
                )
            )
        }

        $mockGetItem_SharedWowDirectory = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'Property' -Value '28A1158CDF9ED6B41B2B7358982D4BA8' -PassThru -Force
                )
            )
        }

        $mockGetItemProperty_Setup = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'SqlProgramDir' -Value $mockSqlProgramDirectory -PassThru -Force
                )
            )
        }

        $mockGetItemProperty_ServicesAnalysis = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'ImagePath' -Value ('"C:\Program Files\Microsoft SQL Server\OLAP\bin\msmdsrv.exe" -s "{0}"' -f $mockSqlAnalysisConfigDirectory) -PassThru -Force
                )
            )
        }

        $mockConnectSQL = {
            return @(
                (
                    New-Object Object |
                        Add-Member -MemberType NoteProperty -Name 'LoginMode' -Value $mockSqlLoginMode -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'Collation' -Value $mockSqlCollation -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'InstallDataDirectory' -Value $mockSqlInstallPath -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'BackupDirectory' -Value $mockSqlBackupPath -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'SQLTempDBDir' -Value $mockSqlTempDatabasePath -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'SQLTempDBLogDir' -Value $mockSqlTempDatabaseLogPath -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'DefaultFile' -Value $mockSqlDefaultDatabaseFilePath -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'DefaultLog' -Value $mockSqlDefaultDatabaseLogPath -PassThru |
                        Add-Member ScriptProperty Logins {
                            return @( ( New-Object Object |
                                    Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockSqlSystemAdministrator -PassThru |
                                    Add-Member ScriptMethod ListMembers {
                                        return @('sysadmin')
                                    } -PassThru -Force
                                ) )
                        } -PassThru -Force
                )
            )
        }

        $mockConnectSQLAnalysis = {
            return @(
                (
                    New-Object Object |
                        Add-Member ScriptProperty ServerProperties  {
                            return @{
                                'CollationName' = @( New-Object Object | Add-Member NoteProperty -Name 'Value' -Value $mockSqlAnalysisCollation -PassThru -Force )
                                'DataDir' = @( New-Object Object | Add-Member NoteProperty -Name 'Value' -Value $mockSqlAnalysisDataDirectory -PassThru -Force )
                                'TempDir' = @( New-Object Object | Add-Member NoteProperty -Name 'Value' -Value $mockSqlAnalysisTempDirectory -PassThru -Force )
                                'LogDir' = @( New-Object Object | Add-Member NoteProperty -Name 'Value' -Value $mockSqlAnalysisLogDirectory -PassThru -Force )
                                'BackupDir' = @( New-Object Object | Add-Member NoteProperty -Name 'Value' -Value $mockSqlAnalysisBackupDirectory -PassThru -Force )
                            }
                        } -PassThru |
                        Add-Member ScriptProperty Roles  {
                            return @{
                                'Administrators' = @( New-Object Object |
                                    Add-Member ScriptProperty Members {
                                        return New-Object Object |
                                            Add-Member ScriptProperty Name {
                                                return $mockSqlAnalysisAdmins
                                            } -PassThru -Force
                                    } -PassThru -Force
                                ) }
                        } -PassThru -Force
                )
            )
        }

        $mockGetTemporaryFolder = {
            return $mockSourcePathUNC
        }

        <#
        Needed a way to see into the Set-method for the arguments the Set-method is building and sending to 'setup.exe', and fail
        the test if the arguments is diffentent from the expected arguments.
        Solved this by dynamically set the expected arguments before each It-block. If the arguments differs the mock of
        StartWin32Process throws an error message, similiar to what Pester would have reported (expected -> but was).
        #>
        $mockStartWin32ProcessExpectedArgument = ''
        $mockStartWin32Process = {
            if ( $Arguments -ne $mockStartWin32ProcessExpectedArgument )
            {
                throw "Expected arguments was not the same as the arguments in the function call.`nExpected: '$mockStartWin32ProcessExpectedArgument' `n But was: '$Arguments'"
            }

            return 'Process started'
        }
        #endregion Function mocks

        # Default parameters that are used for the It-blocks
        $mockDefaultParameters = @{
            SetupCredential = $mockSetupCredential
            # These are written with both lower-case and upper-case to make sure we support that.
            Features = 'SQLEngine,Replication,FullText,Rs,Is,As'
        }

        Describe "xSQLServerSetup\Get-TargetResource" -Tag 'Get' {
            #region Setting up TestDrive:\

            # Local path to TestDrive:\
            $mockSourcePath = $TestDrive.FullName
            $mockSqlMediaPath = Join-Path -Path $mockSourcePath -ChildPath $mockSourceFolder

            # UNC path to TestDrive:\
            $testDrive_DriveShare = (Split-Path -Path $mockSourcePath -Qualifier) -replace ':','$'
            $mockSourcePathUNC = Join-Path -Path "\\localhost\$testDrive_DriveShare" -ChildPath (Split-Path -Path $mockSourcePath -NoQualifier)
            $mockSqlMediaPathUNC = Join-Path -Path $mockSourcePathUNC -ChildPath $mockSourceFolder

            # Mocking folder structure and mocking setup.exe
            New-Item -Path $mockSqlMediaPath -ItemType Directory
            Set-Content (Join-Path -Path $mockSqlMediaPath -ChildPath 'setup.exe') -Value 'Mock exe file'

            #endregion Setting up TestDrive:\

            BeforeEach {
                # General mocks
                Mock -CommandName GetSQLVersion -MockWith $mockGetSQLVersion -Verifiable
                Mock -CommandName Connect-SQL -MockWith $mockConnectSQL -Verifiable
                Mock -CommandName Connect-SQLAnalysis -MockWith $mockConnectSQLAnalysis -Verifiable
                Mock -CommandName Get-ItemProperty -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' -and
                    ($Name -eq $mockDefaultInstance_InstanceName -or $Name -eq $mockNamedInstance_InstanceName)
                } -MockWith $mockGetItemProperty_SQL -Verifiable

                Mock -CommandName Get-ItemProperty -ParameterFilter {
                    (
                        $Path -eq "HKLM:\SYSTEM\CurrentControlSet\Services\$mockDefaultInstance_AnalysisServiceName" -or
                        $Path -eq "HKLM:\SYSTEM\CurrentControlSet\Services\$mockNamedInstance_AnalysisServiceName"
                    ) -and
                    $Name -eq 'ImagePath'
                } -MockWith $mockGetItemProperty_ServicesAnalysis -Verifiable

                # Mocking SharedDirectory
                Mock -CommandName Get-ItemProperty -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\0D1F366D0FE0E404F8C15EE4F1C15094' -or
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\FEE2E540D20152D4597229B6CFBC0A69'
                } -MockWith $mockGetItemProperty_SharedDirectory -Verifiable

                Mock -CommandName Get-Item -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\0D1F366D0FE0E404F8C15EE4F1C15094' -or
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\FEE2E540D20152D4597229B6CFBC0A69'
                } -MockWith $mockGetItem_SharedDirectory -Verifiable

                # Mocking SharedWowDirectory
                Mock -CommandName Get-ItemProperty -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\C90BFAC020D87EA46811C836AD3C507F' -or
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\A79497A344129F64CA7D69C56F5DD8B4'
                } -MockWith $mockGetItemProperty_SharedWowDirectory -Verifiable

                Mock -CommandName Get-Item -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\C90BFAC020D87EA46811C836AD3C507F' -or
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\A79497A344129F64CA7D69C56F5DD8B4'
                } -MockWith $mockGetItem_SharedWowDirectory -Verifiable
            }

            $testProductVersion | ForEach-Object -Process {
                $mockSqlMajorVersion = $_

                $mockDefaultInstance_InstanceId = "$($mockSqlDatabaseEngineName)$($mockSqlMajorVersion).$($mockDefaultInstance_InstanceName)"

                $mockSqlInstallPath = "C:\Program Files\Microsoft SQL Server\$($mockDefaultInstance_InstanceId)\MSSQL"
                $mockSqlBackupPath = "C:\Program Files\Microsoft SQL Server\$($mockDefaultInstance_InstanceId)\MSSQL\Backup"
                $mockSqlTempDatabasePath = ''
                $mockSqlTempDatabaseLogPath = ''
                $mockSqlDefaultDatabaseFilePath = "C:\Program Files\Microsoft SQL Server\$($mockDefaultInstance_InstanceId)\MSSQL\DATA\"
                $mockSqlDefaultDatabaseLogPath = "C:\Program Files\Microsoft SQL Server\$($mockDefaultInstance_InstanceId)\MSSQL\DATA\"

                Context "When SQL Server version is $mockSqlMajorVersion and the system is not in the desired state for default instance" {
                    BeforeEach {
                        $testParameters = $mockDefaultParameters.Clone()
                        $testParameters.Remove('Features')
                        $testParameters += @{
                            InstanceName = $mockDefaultInstance_InstanceName
                            SourceCredential = $null
                            SourcePath = $mockSourcePath
                        }

                        if ($mockSqlMajorVersion -eq 13) {
                            # Mock all SSMS products here to make sure we don't return any when testing SQL Server 2016
                            Mock -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -MockWith $mockGetItemProperty_UninstallProducts -Verifiable
                        } else {
                            Mock -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -MockWith $mockEmptyHashtable -Verifiable
                        }

                        Mock -CommandName NetUse -Verifiable
                        Mock -CommandName Get-Service -MockWith $mockEmptyHashtable -Verifiable
                        Mock -CommandName Get-CimInstance -MockWith $mockEmptyHashtable
                        Mock -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\ConfigurationState"
                        } -MockWith $mockGetItemProperty_ConfigurationState -Verifiable

                        Mock -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                        } -MockWith $mockGetItemProperty_Setup -Verifiable
                    }

                    It 'Should return the same values as passed as parameters' {
                        $result = Get-TargetResource @testParameters
                        $result.InstanceName | Should Be $testParameters.InstanceName

                        Assert-MockCalled -CommandName NetUse -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\ConfigurationState"
                        } -Exactly -Times 0 -Scope It

                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                        } -Exactly -Times 0 -Scope It

                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                        } -Exactly -Times 6 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 0 -Scope It
                    }

                    It 'Should not return any names of installed features' {
                        $result = Get-TargetResource @testParameters
                        $result.Features | Should Be ''
                    }

                    It 'Should return the correct values in the hash table' {
                        $result = Get-TargetResource @testParameters
                        $result.SourcePath | Should Be $mockSourcePath
                        $result.SourceFolder | Should Be $mockSourceFolder
                        $result.InstanceName | Should Be $mockDefaultInstance_InstanceName
                        $result.InstanceID | Should BeNullOrEmpty
                        $result.InstallSharedDir | Should BeNullOrEmpty
                        $result.InstallSharedWOWDir | Should BeNullOrEmpty
                        $result.SQLSvcAccountUsername | Should BeNullOrEmpty
                        $result.AgtSvcAccountUsername | Should BeNullOrEmpty
                        $result.SqlCollation | Should BeNullOrEmpty
                        $result.SQLSysAdminAccounts | Should BeNullOrEmpty
                        $result.SecurityMode | Should BeNullOrEmpty
                        $result.InstallSQLDataDir | Should BeNullOrEmpty
                        $result.SQLUserDBDir | Should BeNullOrEmpty
                        $result.SQLUserDBLogDir | Should BeNullOrEmpty
                        $result.SQLBackupDir | Should BeNullOrEmpty
                        $result.FTSvcAccountUsername | Should BeNullOrEmpty
                        $result.RSSvcAccountUsername | Should BeNullOrEmpty
                        $result.ASSvcAccountUsername | Should BeNullOrEmpty
                        $result.ASCollation | Should BeNullOrEmpty
                        $result.ASSysAdminAccounts | Should BeNullOrEmpty
                        $result.ASDataDir | Should BeNullOrEmpty
                        $result.ASLogDir | Should BeNullOrEmpty
                        $result.ASBackupDir | Should BeNullOrEmpty
                        $result.ASTempDir | Should BeNullOrEmpty
                        $result.ASConfigDir | Should BeNullOrEmpty
                        $result.ISSvcAccountUsername | Should BeNullOrEmpty
                    }
                }

                Context "When using SourceCredential parameter and SQL Server version is $mockSqlMajorVersion and the system is not in the desired state for default instance" {
                    BeforeEach {
                        $testParameters = $mockDefaultParameters.Clone()
                        $testParameters.Remove('Features')
                        $testParameters += @{
                            InstanceName = $mockDefaultInstance_InstanceName
                            SourceCredential = $mockSetupCredential
                            SourcePath = $mockSourcePathUNC
                        }

                        if ($mockSqlMajorVersion -eq 13) {
                            # Mock all SSMS products here to make sure we don't return any when testing SQL Server 2016
                            Mock -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -MockWith $mockGetItemProperty_UninstallProducts -Verifiable
                        } else {
                            Mock -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -MockWith $mockEmptyHashtable -Verifiable
                        }

                        Mock -CommandName NetUse -Verifiable
                        Mock -CommandName Get-Service -MockWith $mockEmptyHashtable -Verifiable
                        Mock -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\ConfigurationState"
                        } -MockWith $mockGetItemProperty_ConfigurationState -Verifiable

                        Mock -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                        } -MockWith $mockGetItemProperty_Setup -Verifiable
                    }

                    It 'Should return the same values as passed as parameters' {
                        $result = Get-TargetResource @testParameters
                        $result.InstanceName | Should Be $testParameters.InstanceName

                        Assert-MockCalled -CommandName NetUse -Exactly -Times 2 -Scope It
                        Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\ConfigurationState"
                        } -Exactly -Times 0 -Scope It

                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                        } -Exactly -Times 0 -Scope It

                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                        } -Exactly -Times 6 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 0 -Scope It
                    }

                    It 'Should not return any names of installed features' {
                        $result = Get-TargetResource @testParameters
                        $result.Features | Should Be ''
                    }

                    It 'Should return the correct values in the hash table' {
                        $result = Get-TargetResource @testParameters
                        $result.SourcePath | Should Be $mockSourcePathUNC
                        $result.SourceFolder | Should Be $mockSourceFolder
                        $result.InstanceName | Should Be $mockDefaultInstance_InstanceName
                        $result.InstanceID | Should BeNullOrEmpty
                        $result.InstallSharedDir | Should BeNullOrEmpty
                        $result.InstallSharedWOWDir | Should BeNullOrEmpty
                        $result.SQLSvcAccountUsername | Should BeNullOrEmpty
                        $result.AgtSvcAccountUsername | Should BeNullOrEmpty
                        $result.SqlCollation | Should BeNullOrEmpty
                        $result.SQLSysAdminAccounts | Should BeNullOrEmpty
                        $result.SecurityMode | Should BeNullOrEmpty
                        $result.InstallSQLDataDir | Should BeNullOrEmpty
                        $result.SQLUserDBDir | Should BeNullOrEmpty
                        $result.SQLUserDBLogDir | Should BeNullOrEmpty
                        $result.SQLBackupDir | Should BeNullOrEmpty
                        $result.FTSvcAccountUsername | Should BeNullOrEmpty
                        $result.RSSvcAccountUsername | Should BeNullOrEmpty
                        $result.ASSvcAccountUsername | Should BeNullOrEmpty
                        $result.ASCollation | Should BeNullOrEmpty
                        $result.ASSysAdminAccounts | Should BeNullOrEmpty
                        $result.ASDataDir | Should BeNullOrEmpty
                        $result.ASLogDir | Should BeNullOrEmpty
                        $result.ASBackupDir | Should BeNullOrEmpty
                        $result.ASTempDir | Should BeNullOrEmpty
                        $result.ASConfigDir | Should BeNullOrEmpty
                        $result.ISSvcAccountUsername | Should BeNullOrEmpty
                    }
                }

                Context "When SQL Server version is $mockSqlMajorVersion and the system is in the desired state for default instance" {
                    BeforeEach {
                        $testParameters = $mockDefaultParameters.Clone()
                        $testParameters.Remove('Features')
                        $testParameters += @{
                            InstanceName = $mockDefaultInstance_InstanceName
                            SourceCredential = $null
                            SourcePath = $mockSourcePath
                        }

                        if ($mockSqlMajorVersion -eq 10) {
                            Mock -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber)
                            } -MockWith $mockGetItemProperty_UninstallProducts2008R2 -Verifiable
                        }

                        if ($mockSqlMajorVersion -eq 11) {
                            Mock -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber)
                            } -MockWith $mockGetItemProperty_UninstallProducts2012 -Verifiable
                        }

                        if ($mockSqlMajorVersion -eq 12) {
                            Mock -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -MockWith $mockGetItemProperty_UninstallProducts2014 -Verifiable
                        }

                        Mock -CommandName NetUse -Verifiable
                        Mock -CommandName Get-Service -MockWith $mockGetService_DefaultInstance -Verifiable

                        #region Mock Get-CimInstance
                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_DatabaseServiceName'"
                        } -MockWith $mockGetCimInstance_DefaultInstance_DatabaseService -Verifiable

                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_AgentServiceName'"
                        } -MockWith $mockGetCimInstance_DefaultInstance_AgentService -Verifiable

                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_FullTextServiceName'"
                        } -MockWith $mockGetCimInstance_DefaultInstance_FullTextService -Verifiable

                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_ReportingServiceName'"
                        } -MockWith $mockGetCimInstance_DefaultInstance_ReportingService -Verifiable

                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$(($mockDefaultInstance_IntegrationServiceName -f $mockSqlMajorVersion))'"
                        } -MockWith $mockGetCimInstance_DefaultInstance_IntegrationService -Verifiable

                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_AnalysisServiceName'"
                        } -MockWith $mockGetCimInstance_DefaultInstance_AnalysisService -Verifiable

                        # If Get-CimInstance is used in any other way than those mocks with a ParameterFilter, then throw and error
                        Mock -CommandName Get-CimInstance -MockWith {
                            throw "Mock Get-CimInstance was called with unexpected parameters. ClassName=$ClassName, Filter=$Filter"
                        }
                        #endregion Mock Get-CimInstance

                        Mock -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\ConfigurationState"
                        } -MockWith $mockGetItemProperty_ConfigurationState -Verifiable

                        Mock -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                        } -MockWith $mockGetItemProperty_Setup -Verifiable
                    }

                    It 'Should return the same values as passed as parameters' {
                        $result = Get-TargetResource @testParameters
                        $result.InstanceName | Should Be $testParameters.InstanceName

                        Assert-MockCalled -CommandName NetUse -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\ConfigurationState"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                        } -Exactly -Times 1 -Scope It

                        if ($mockSqlMajorVersion -eq 13) {
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -Exactly -Times 0 -Scope It
                        } else {
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -Exactly -Times 2 -Scope It
                        }

                        #region Assert Get-CimInstance
                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_DatabaseServiceName'"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_AgentServiceName'"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_FullTextServiceName'"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_ReportingServiceName'"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$(($mockDefaultInstance_IntegrationServiceName -f $mockSqlMajorVersion))'"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_AnalysisServiceName'"
                        } -Exactly -Times 1 -Scope It
                        #endregion Assert Get-CimInstance
                    }

                    It 'Should return correct names of installed features' {
                        $result = Get-TargetResource @testParameters
                        if ($mockSqlMajorVersion -eq 13) {
                            $result.Features | Should Be 'SQLENGINE,REPLICATION,FULLTEXT,RS,AS,IS'
                        } else {
                            $result.Features | Should Be 'SQLENGINE,REPLICATION,FULLTEXT,RS,AS,IS,SSMS,ADV_SSMS'
                        }
                    }

                    It 'Should return the correct values in the hash table' {
                        $result = Get-TargetResource @testParameters
                        $result.SourcePath | Should Be $mockSourcePath
                        $result.SourceFolder | Should Be $mockSourceFolder
                        $result.InstanceName | Should Be $mockDefaultInstance_InstanceName
                        $result.InstanceID | Should Be $mockDefaultInstance_InstanceName
                        $result.InstallSharedDir | Should Be $mockSqlSharedDirectory
                        $result.InstallSharedWOWDir | Should Be $mockSqlSharedWowDirectory
                        $result.SQLSvcAccountUsername | Should Be $mockSqlServiceAccount
                        $result.AgtSvcAccountUsername | Should Be $mockAgentServiceAccount
                        $result.SqlCollation | Should Be $mockSqlCollation
                        $result.SQLSysAdminAccounts | Should Be $mockSqlSystemAdministrator
                        $result.SecurityMode | Should Be 'Windows'
                        $result.InstallSQLDataDir | Should Be $mockSqlInstallPath
                        $result.SQLUserDBDir | Should Be $mockSqlDefaultDatabaseFilePath
                        $result.SQLUserDBLogDir | Should Be $mockSqlDefaultDatabaseLogPath
                        $result.SQLBackupDir | Should Be $mockSqlBackupPath
                        $result.FTSvcAccountUsername | Should Be $mockSqlServiceAccount
                        $result.RSSvcAccountUsername | Should Be $mockSqlServiceAccount
                        $result.ASSvcAccountUsername | Should Be $mockSqlServiceAccount
                        $result.ASCollation | Should Be $mockSqlAnalysisCollation
                        $result.ASSysAdminAccounts | Should Be $mockSqlAnalysisAdmins
                        $result.ASDataDir | Should Be $mockSqlAnalysisDataDirectory
                        $result.ASLogDir | Should Be $mockSqlAnalysisLogDirectory
                        $result.ASBackupDir | Should Be $mockSqlAnalysisBackupDirectory
                        $result.ASTempDir | Should Be $mockSqlAnalysisTempDirectory
                        $result.ASConfigDir | Should Be $mockSqlAnalysisConfigDirectory
                        $result.ISSvcAccountUsername | Should Be $mockSqlServiceAccount
                    }
                }

                Context "When using SourceCredential parameter and SQL Server version is $mockSqlMajorVersion and the system is in the desired state for default instance" {
                    BeforeEach {
                        $testParameters = $mockDefaultParameters.Clone()
                        $testParameters.Remove('Features')
                        $testParameters += @{
                            InstanceName = $mockDefaultInstance_InstanceName
                            SourceCredential = $mockSetupCredential
                            SourcePath = $mockSourcePathUNC
                        }

                        if ($mockSqlMajorVersion -eq 10) {
                            Mock -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber)
                            } -MockWith $mockGetItemProperty_UninstallProducts2008R2 -Verifiable
                        }

                        if ($mockSqlMajorVersion -eq 11) {
                            Mock -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber)
                            } -MockWith $mockGetItemProperty_UninstallProducts2012 -Verifiable
                        }

                        if ($mockSqlMajorVersion -eq 12) {
                            Mock -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -MockWith $mockGetItemProperty_UninstallProducts2014 -Verifiable
                        }

                        Mock -CommandName NetUse -Verifiable
                        Mock -CommandName Get-Service -MockWith $mockGetService_DefaultInstance -Verifiable

                        #region Mock Get-CimInstance
                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_DatabaseServiceName'"
                        } -MockWith $mockGetCimInstance_DefaultInstance_DatabaseService -Verifiable

                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_AgentServiceName'"
                        } -MockWith $mockGetCimInstance_DefaultInstance_AgentService -Verifiable

                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_FullTextServiceName'"
                        } -MockWith $mockGetCimInstance_DefaultInstance_FullTextService -Verifiable

                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_ReportingServiceName'"
                        } -MockWith $mockGetCimInstance_DefaultInstance_ReportingService -Verifiable

                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$(($mockDefaultInstance_IntegrationServiceName -f $mockSqlMajorVersion))'"
                        } -MockWith $mockGetCimInstance_DefaultInstance_IntegrationService -Verifiable

                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_AnalysisServiceName'"
                        } -MockWith $mockGetCimInstance_DefaultInstance_AnalysisService -Verifiable

                        # If Get-CimInstance is used in any other way than those mocks with a ParameterFilter, then throw and error
                        Mock -CommandName Get-CimInstance -MockWith {
                            throw "Mock Get-CimInstance was called with unexpected parameters. ClassName=$ClassName, Filter=$Filter"
                        }
                        #endregion Mock Get-CimInstance

                        Mock -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\ConfigurationState"
                        } -MockWith $mockGetItemProperty_ConfigurationState -Verifiable

                        Mock -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                        } -MockWith $mockGetItemProperty_Setup -Verifiable
                    }

                    It 'Should return the same values as passed as parameters' {
                        $result = Get-TargetResource @testParameters
                        $result.InstanceName | Should Be $testParameters.InstanceName

                        Assert-MockCalled -CommandName NetUse -Exactly -Times 2 -Scope It
                        Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\ConfigurationState"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                        } -Exactly -Times 1 -Scope It

                        if ($mockSqlMajorVersion -eq 13) {
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -Exactly -Times 0 -Scope It
                        } else {
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -Exactly -Times 2 -Scope It
                        }

                        #region Assert Get-CimInstance
                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_DatabaseServiceName'"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_AgentServiceName'"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_FullTextServiceName'"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_ReportingServiceName'"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$(($mockDefaultInstance_IntegrationServiceName -f $mockSqlMajorVersion))'"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockDefaultInstance_AnalysisServiceName'"
                        } -Exactly -Times 1 -Scope It
                        #endregion Assert Get-CimInstance
                    }

                    It 'Should return correct names of installed features' {
                        $result = Get-TargetResource @testParameters
                        if ($mockSqlMajorVersion -eq 13) {
                            $result.Features | Should Be 'SQLENGINE,REPLICATION,FULLTEXT,RS,AS,IS'
                        } else {
                            $result.Features | Should Be 'SQLENGINE,REPLICATION,FULLTEXT,RS,AS,IS,SSMS,ADV_SSMS'
                        }
                    }

                    It 'Should return the correct values in the hash table' {
                        $result = Get-TargetResource @testParameters
                        $result.SourcePath | Should Be $mockSourcePathUNC
                        $result.SourceFolder | Should Be $mockSourceFolder
                        $result.InstanceName | Should Be $mockDefaultInstance_InstanceName
                        $result.InstanceID | Should Be $mockDefaultInstance_InstanceName
                        $result.InstallSharedDir | Should Be $mockSqlSharedDirectory
                        $result.InstallSharedWOWDir | Should Be $mockSqlSharedWowDirectory
                        $result.SQLSvcAccountUsername | Should Be $mockSqlServiceAccount
                        $result.AgtSvcAccountUsername | Should Be $mockAgentServiceAccount
                        $result.SqlCollation | Should Be $mockSqlCollation
                        $result.SQLSysAdminAccounts | Should Be $mockSqlSystemAdministrator
                        $result.SecurityMode | Should Be 'Windows'
                        $result.InstallSQLDataDir | Should Be $mockSqlInstallPath
                        $result.SQLUserDBDir | Should Be $mockSqlDefaultDatabaseFilePath
                        $result.SQLUserDBLogDir | Should Be $mockSqlDefaultDatabaseLogPath
                        $result.SQLBackupDir | Should Be $mockSqlBackupPath
                        $result.FTSvcAccountUsername | Should Be $mockSqlServiceAccount
                        $result.RSSvcAccountUsername | Should Be $mockSqlServiceAccount
                        $result.ASSvcAccountUsername | Should Be $mockSqlServiceAccount
                        $result.ASCollation | Should Be $mockSqlAnalysisCollation
                        $result.ASSysAdminAccounts | Should Be $mockSqlAnalysisAdmins
                        $result.ASDataDir | Should Be $mockSqlAnalysisDataDirectory
                        $result.ASLogDir | Should Be $mockSqlAnalysisLogDirectory
                        $result.ASBackupDir | Should Be $mockSqlAnalysisBackupDirectory
                        $result.ASTempDir | Should Be $mockSqlAnalysisTempDirectory
                        $result.ASConfigDir | Should Be $mockSqlAnalysisConfigDirectory
                        $result.ISSvcAccountUsername | Should Be $mockSqlServiceAccount
                    }
                }

                $mockNamedInstance_InstanceId = "$($mockSqlDatabaseEngineName)$($mockSqlMajorVersion).$($mockNamedInstance_InstanceName)"

                $mockSqlInstallPath = "C:\Program Files\Microsoft SQL Server\$($mockNamedInstance_InstanceId)\MSSQL"
                $mockSqlBackupPath = "C:\Program Files\Microsoft SQL Server\$($mockNamedInstance_InstanceId)\MSSQL\Backup"
                $mockSqlTempDatabasePath = ''
                $mockSqlTempDatabaseLogPath = ''
                $mockSqlDefaultDatabaseFilePath = "C:\Program Files\Microsoft SQL Server\$($mockNamedInstance_InstanceId)\MSSQL\DATA\"
                $mockSqlDefaultDatabaseLogPath = "C:\Program Files\Microsoft SQL Server\$($mockNamedInstance_InstanceId)\MSSQL\DATA\"

                Context "When SQL Server version is $mockSqlMajorVersion and the system is not in the desired state for named instance" {
                    BeforeEach {
                        $testParameters = $mockDefaultParameters.Clone()
                        $testParameters.Remove('Features')
                        $testParameters += @{
                            InstanceName = $mockNamedInstance_InstanceName
                            SourceCredential = $null
                            SourcePath = $mockSourcePath
                        }

                        if ($mockSqlMajorVersion -eq 13) {
                            # Mock this here to make sure we don't return any older components (<=2014) when testing SQL Server 2016
                            Mock -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -MockWith $mockGetItemProperty_UninstallProducts -Verifiable
                        } else {
                            Mock -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -MockWith $mockEmptyHashtable -Verifiable
                        }

                        Mock -CommandName Get-Service -MockWith $mockEmptyHashtable -Verifiable
                        Mock -CommandName Get-CimInstance -MockWith $mockEmptyHashtable
                        Mock -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockNamedInstance_InstanceId\ConfigurationState"
                        } -MockWith $mockGetItemProperty_ConfigurationState -Verifiable

                        Mock -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockNamedInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                        } -MockWith $mockGetItemProperty_Setup -Verifiable
                    }

                    It 'Should return the same values as passed as parameters' {
                        $result = Get-TargetResource @testParameters
                        $result.InstanceName | Should Be $testParameters.InstanceName

                        Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockNamedInstance_InstanceId\ConfigurationState"
                        } -Exactly -Times 0 -Scope It

                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockNamedInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                        } -Exactly -Times 0 -Scope It

                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                        } -Exactly -Times 6 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 0 -Scope It
                    }

                    It 'Should not return any names of installed features' {
                        $result = Get-TargetResource @testParameters
                        $result.Features | Should Be ''
                    }

                    It 'Should return the correct values in the hash table' {
                        $result = Get-TargetResource @testParameters
                        $result.SourcePath | Should Be $mockSourcePath
                        $result.SourceFolder | Should Be $mockSourceFolder
                        $result.InstanceName | Should Be $mockNamedInstance_InstanceName
                        $result.InstanceID | Should BeNullOrEmpty
                        $result.InstallSharedDir | Should BeNullOrEmpty
                        $result.InstallSharedWOWDir | Should BeNullOrEmpty
                        $result.SQLSvcAccountUsername | Should BeNullOrEmpty
                        $result.AgtSvcAccountUsername | Should BeNullOrEmpty
                        $result.SqlCollation | Should BeNullOrEmpty
                        $result.SQLSysAdminAccounts | Should BeNullOrEmpty
                        $result.SecurityMode | Should BeNullOrEmpty
                        $result.InstallSQLDataDir | Should BeNullOrEmpty
                        $result.SQLUserDBDir | Should BeNullOrEmpty
                        $result.SQLUserDBLogDir | Should BeNullOrEmpty
                        $result.SQLBackupDir | Should BeNullOrEmpty
                        $result.FTSvcAccountUsername | Should BeNullOrEmpty
                        $result.RSSvcAccountUsername | Should BeNullOrEmpty
                        $result.ASSvcAccountUsername | Should BeNullOrEmpty
                        $result.ASCollation | Should BeNullOrEmpty
                        $result.ASSysAdminAccounts | Should BeNullOrEmpty
                        $result.ASDataDir | Should BeNullOrEmpty
                        $result.ASLogDir | Should BeNullOrEmpty
                        $result.ASBackupDir | Should BeNullOrEmpty
                        $result.ASTempDir | Should BeNullOrEmpty
                        $result.ASConfigDir | Should BeNullOrEmpty
                        $result.ISSvcAccountUsername | Should BeNullOrEmpty
                    }
                }

                Context "When SQL Server version is $mockSqlMajorVersion and the system is in the desired state for named instance" {
                    BeforeEach {
                        $testParameters = $mockDefaultParameters.Clone()
                        $testParameters.Remove('Features')
                        $testParameters += @{
                            InstanceName = $mockNamedInstance_InstanceName
                            SourceCredential = $null
                            SourcePath = $mockSourcePath
                        }

                        if ($mockSqlMajorVersion -eq 10) {
                            Mock -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber)
                            } -MockWith $mockGetItemProperty_UninstallProducts2008R2 -Verifiable
                        }

                        if ($mockSqlMajorVersion -eq 11) {
                            Mock -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber)
                            } -MockWith $mockGetItemProperty_UninstallProducts2012 -Verifiable
                        }

                        if ($mockSqlMajorVersion -eq 12) {
                            Mock -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -MockWith $mockGetItemProperty_UninstallProducts2014 -Verifiable
                        }

                        Mock -CommandName Get-Service -MockWith $mockGetService_NamedInstance -Verifiable

                        #region Mock Get-CimInstance
                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockNamedInstance_DatabaseServiceName'"
                        } -MockWith $mockGetCimInstance_NamedInstance_DatabaseService -Verifiable

                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockNamedInstance_AgentServiceName'"
                        } -MockWith $mockGetCimInstance_NamedInstance_AgentService -Verifiable

                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockNamedInstance_FullTextServiceName'"
                        } -MockWith $mockGetCimInstance_NamedInstance_FullTextService -Verifiable

                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockNamedInstance_ReportingServiceName'"
                        } -MockWith $mockGetCimInstance_NamedInstance_ReportingService -Verifiable

                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$(($mockNamedInstance_IntegrationServiceName -f $mockSqlMajorVersion))'"
                        } -MockWith $mockGetCimInstance_NamedInstance_IntegrationService -Verifiable

                        Mock -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockNamedInstance_AnalysisServiceName'"
                        } -MockWith $mockGetCimInstance_NamedInstance_AnalysisService -Verifiable

                        # If Get-CimInstance is used in any other way than those mocks with a ParameterFilter, then throw and error
                        Mock -CommandName Get-CimInstance -MockWith {
                            throw "Mock Get-CimInstance was called with unexpected parameters. ClassName=$ClassName, Filter=$Filter"
                        }
                        #endregion Mock Get-CimInstance

                        Mock -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockNamedInstance_InstanceId\ConfigurationState"
                        } -MockWith $mockGetItemProperty_ConfigurationState -Verifiable

                        Mock -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockNamedInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                        } -MockWith $mockGetItemProperty_Setup -Verifiable
                    }

                    It 'Should return the same values as passed as parameters' {
                        $result = Get-TargetResource @testParameters
                        $result.InstanceName | Should Be $testParameters.InstanceName

                        Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockNamedInstance_InstanceId\ConfigurationState"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockNamedInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                        } -Exactly -Times 1 -Scope It

                        if ($mockSqlMajorVersion -eq 13) {
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -Exactly -Times 0 -Scope It
                        } else {
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -Exactly -Times 2 -Scope It
                        }

                        #region Assert Get-CimInstance
                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockNamedInstance_DatabaseServiceName'"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockNamedInstance_AgentServiceName'"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockNamedInstance_FullTextServiceName'"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockNamedInstance_ReportingServiceName'"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$(($mockNamedInstance_IntegrationServiceName -f $mockSqlMajorVersion))'"
                        } -Exactly -Times 1 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                            $ClassName -eq 'Win32_Service' -and
                            $Filter -eq "Name = '$mockNamedInstance_AnalysisServiceName'"
                        } -Exactly -Times 1 -Scope It
                        #endregion Assert Get-CimInstance
                    }

                    It 'Should return correct names of installed features' {
                        $result = Get-TargetResource @testParameters
                        if ($mockSqlMajorVersion -eq 13) {
                            $result.Features | Should Be 'SQLENGINE,REPLICATION,FULLTEXT,RS,AS,IS'
                        } else {
                            $result.Features | Should Be 'SQLENGINE,REPLICATION,FULLTEXT,RS,AS,IS,SSMS,ADV_SSMS'
                        }
                    }

                    It 'Should return the correct values in the hash table' {
                        $result = Get-TargetResource @testParameters
                        $result.SourcePath | Should Be $mockSourcePath
                        $result.SourceFolder | Should Be $mockSourceFolder
                        $result.InstanceName | Should Be $mockNamedInstance_InstanceName
                        $result.InstanceID | Should Be $mockNamedInstance_InstanceName
                        $result.InstallSharedDir | Should Be $mockSqlSharedDirectory
                        $result.InstallSharedWOWDir | Should Be $mockSqlSharedWowDirectory
                        $result.SQLSvcAccountUsername | Should Be $mockSqlServiceAccount
                        $result.AgtSvcAccountUsername | Should Be $mockAgentServiceAccount
                        $result.SqlCollation | Should Be $mockSqlCollation
                        $result.SQLSysAdminAccounts | Should Be $mockSqlSystemAdministrator
                        $result.SecurityMode | Should Be 'Windows'
                        $result.InstallSQLDataDir | Should Be $mockSqlInstallPath
                        $result.SQLUserDBDir | Should Be $mockSqlDefaultDatabaseFilePath
                        $result.SQLUserDBLogDir | Should Be $mockSqlDefaultDatabaseLogPath
                        $result.SQLBackupDir | Should Be $mockSqlBackupPath
                        $result.FTSvcAccountUsername | Should Be $mockSqlServiceAccount
                        $result.RSSvcAccountUsername | Should Be $mockSqlServiceAccount
                        $result.ASSvcAccountUsername | Should Be $mockSqlServiceAccount
                        $result.ASCollation | Should Be $mockSqlAnalysisCollation
                        $result.ASSysAdminAccounts | Should Be $mockSqlAnalysisAdmins
                        $result.ASDataDir | Should Be $mockSqlAnalysisDataDirectory
                        $result.ASLogDir | Should Be $mockSqlAnalysisLogDirectory
                        $result.ASBackupDir | Should Be $mockSqlAnalysisBackupDirectory
                        $result.ASTempDir | Should Be $mockSqlAnalysisTempDirectory
                        $result.ASConfigDir | Should Be $mockSqlAnalysisConfigDirectory
                        $result.ISSvcAccountUsername | Should Be $mockSqlServiceAccount
                    }
                }
            }

            Assert-VerifiableMocks
        }

        Describe "xSQLServerSetup\Test-TargetResource" -Tag 'Test' {
            #region Setting up TestDrive:\

            # Local path to TestDrive:\
            $mockSourcePath = $TestDrive.FullName
            $mockSqlMediaPath = Join-Path -Path $mockSourcePath -ChildPath $mockSourceFolder

            # UNC path to TestDrive:\
            $testDrive_DriveShare = (Split-Path -Path $mockSourcePath -Qualifier) -replace ':','$'
            $mockSourcePathUNC = Join-Path -Path "\\localhost\$testDrive_DriveShare" -ChildPath (Split-Path -Path $mockSourcePath -NoQualifier)
            $mockSqlMediaPathUNC = Join-Path -Path $mockSourcePathUNC -ChildPath $mockSourceFolder

            # Mocking folder structure and mocking setup.exe
            New-Item -Path $mockSqlMediaPath -ItemType Directory
            Set-Content (Join-Path -Path $mockSqlMediaPath -ChildPath 'setup.exe') -Value 'Mock exe file'

            #endregion Setting up TestDrive:\

            BeforeEach {
                # General mocks
                Mock -CommandName GetSQLVersion -MockWith $mockGetSQLVersion -Verifiable
                Mock -CommandName Connect-SQL -MockWith $mockConnectSQL -Verifiable
                Mock -CommandName Connect-SQLAnalysis -MockWith $mockConnectSQLAnalysis -Verifiable
                Mock -CommandName Get-ItemProperty -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' -and
                    ($Name -eq $mockDefaultInstance_InstanceName -or $Name -eq $mockNamedInstance_InstanceName)
                } -MockWith $mockGetItemProperty_SQL -Verifiable

                Mock -CommandName Get-ItemProperty -ParameterFilter {
                    (
                        $Path -eq "HKLM:\SYSTEM\CurrentControlSet\Services\$mockDefaultInstance_AnalysisServiceName" -or
                        $Path -eq "HKLM:\SYSTEM\CurrentControlSet\Services\$mockNamedInstance_AnalysisServiceName"
                    ) -and
                    $Name -eq 'ImagePath'
                } -MockWith $mockGetItemProperty_ServicesAnalysis -Verifiable

                # Mocking SharedDirectory
                Mock -CommandName Get-ItemProperty -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\0D1F366D0FE0E404F8C15EE4F1C15094' -or
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\FEE2E540D20152D4597229B6CFBC0A69'
                } -MockWith $mockGetItemProperty_SharedDirectory -Verifiable

                Mock -CommandName Get-Item -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\0D1F366D0FE0E404F8C15EE4F1C15094' -or
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\FEE2E540D20152D4597229B6CFBC0A69'
                } -MockWith $mockGetItem_SharedDirectory -Verifiable

                # Mocking SharedWowDirectory
                Mock -CommandName Get-ItemProperty -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\C90BFAC020D87EA46811C836AD3C507F' -or
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\A79497A344129F64CA7D69C56F5DD8B4'
                } -MockWith $mockGetItemProperty_SharedWowDirectory -Verifiable

                Mock -CommandName Get-Item -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\C90BFAC020D87EA46811C836AD3C507F' -or
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\A79497A344129F64CA7D69C56F5DD8B4'
                } -MockWith $mockGetItem_SharedWowDirectory -Verifiable
            }

            # For this test we only need to test one SQL Server version
            $mockSqlMajorVersion = 13

            $mockDefaultInstance_InstanceId = "$($mockSqlDatabaseEngineName)$($mockSqlMajorVersion).$($mockDefaultInstance_InstanceName)"

            $mockSqlInstallPath = "C:\Program Files\Microsoft SQL Server\$($mockDefaultInstance_InstanceId)\MSSQL"
            $mockSqlBackupPath = "C:\Program Files\Microsoft SQL Server\$($mockDefaultInstance_InstanceId)\MSSQL\Backup"
            $mockSqlTempDatabasePath = ''
            $mockSqlTempDatabaseLogPath = ''
            $mockSqlDefaultDatabaseFilePath = "C:\Program Files\Microsoft SQL Server\$($mockDefaultInstance_InstanceId)\MSSQL\DATA\"
            $mockSqlDefaultDatabaseLogPath = "C:\Program Files\Microsoft SQL Server\$($mockDefaultInstance_InstanceId)\MSSQL\DATA\"

            Context "When the system is not in the desired state" {
                BeforeEach {
                    $testParameters = $mockDefaultParameters
                    $testParameters += @{
                        InstanceName = $mockDefaultInstance_InstanceName
                        SourceCredential = $null
                        SourcePath = $mockSourcePath
                    }

                    # Mock all SSMS products here to make sure we don't return any when testing SQL Server 2016
                    Mock -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                    } -MockWith $mockGetItemProperty_UninstallProducts -Verifiable

                    Mock -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\ConfigurationState"
                    } -MockWith $mockGetItemProperty_ConfigurationState -Verifiable

                    Mock -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                    } -MockWith $mockGetItemProperty_Setup -Verifiable
                }

                It 'Should return that the desired state is absent when no products are installed' {
                    Mock -CommandName Get-Service -MockWith $mockEmptyHashtable -Verifiable

                    Mock -CommandName Get-CimInstance -MockWith $mockEmptyHashtable -Verifiable

                    $result = Test-TargetResource @testParameters
                    $result| Should Be $false

                    Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 0 -Scope It
                    Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 0 -Scope It
                    Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\ConfigurationState"
                    } -Exactly -Times 0 -Scope It

                    Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                    } -Exactly -Times 0 -Scope It

                    Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                    } -Exactly -Times 6 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 0 -Scope It
                }

                It 'Should return that the desired state is asbent when SSMS product is missing' {
                    Mock -CommandName Get-Service -MockWith $mockGetService_DefaultInstance -Verifiable

                    #region Mock Get-CimInstance
                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_DatabaseServiceName'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_DatabaseService -Verifiable

                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_AgentServiceName'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_AgentService -Verifiable

                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_FullTextServiceName'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_FullTextService -Verifiable

                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_ReportingServiceName'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_ReportingService -Verifiable

                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$(($mockDefaultInstance_IntegrationServiceName -f $mockSqlMajorVersion))'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_IntegrationService -Verifiable

                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_AnalysisServiceName'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_AnalysisService -Verifiable

                    # If Get-CimInstance is used in any other way than those mocks with a ParameterFilter, then throw and error
                    Mock -CommandName Get-CimInstance -MockWith {
                        throw "Mock Get-CimInstance was called with unexpected parameters. ClassName=$ClassName, Filter=$Filter"
                    }
                    #endregion Mock Get-CimInstance

                    # Change the default features for this test.
                    $testParameters.Features = 'SSMS'

                    $result = Test-TargetResource @testParameters
                    $result| Should Be $false

                    Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\ConfigurationState"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                    } -Exactly -Times 6 -Scope It

                    #region Assert Get-CimInstance
                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_DatabaseServiceName'"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_AgentServiceName'"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_FullTextServiceName'"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_ReportingServiceName'"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$(($mockDefaultInstance_IntegrationServiceName -f $mockSqlMajorVersion))'"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_AnalysisServiceName'"
                    } -Exactly -Times 1 -Scope It
                    #endregion Assert Get-CimInstance
                }

                It 'Should return that the desired state is asbent when ADV_SSMS product is missing' {
                    Mock -CommandName Get-Service -MockWith $mockGetService_DefaultInstance -Verifiable

                    #region Mock Get-CimInstance
                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_DatabaseServiceName'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_DatabaseService -Verifiable

                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_AgentServiceName'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_AgentService -Verifiable

                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_FullTextServiceName'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_FullTextService -Verifiable

                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_ReportingServiceName'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_ReportingService -Verifiable

                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$(($mockDefaultInstance_IntegrationServiceName -f $mockSqlMajorVersion))'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_IntegrationService -Verifiable

                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_AnalysisServiceName'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_AnalysisService -Verifiable

                    # If Get-CimInstance is used in any other way than those mocks with a ParameterFilter, then throw and error
                    Mock -CommandName Get-CimInstance -MockWith {
                        throw "Mock Get-CimInstance was called with unexpected parameters. ClassName=$ClassName, Filter=$Filter"
                    }
                    #endregion Mock Get-CimInstance

                    # Change the default features for this test.
                    $testParameters.Features = 'ADV_SSMS'

                    $result = Test-TargetResource @testParameters
                    $result| Should Be $false

                    Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\ConfigurationState"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                    } -Exactly -Times 6 -Scope It

                    #region Assert Get-CimInstance
                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_DatabaseServiceName'"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_AgentServiceName'"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_FullTextServiceName'"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_ReportingServiceName'"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$(($mockDefaultInstance_IntegrationServiceName -f $mockSqlMajorVersion))'"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_AnalysisServiceName'"
                    } -Exactly -Times 1 -Scope It
                    #endregion Assert Get-CimInstance
                }
            }

            Context "When the system is in the desired state" {
                BeforeEach {
                    $testParameters = $mockDefaultParameters
                    $testParameters += @{
                        InstanceName = $mockDefaultInstance_InstanceName
                        SourceCredential = $null
                        SourcePath = $mockSourcePath
                    }

                    Mock -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber)
                    } -MockWith $mockGetItemProperty_UninstallProducts2008R2 -Verifiable

                    Mock -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber)
                    } -MockWith $mockGetItemProperty_UninstallProducts2012 -Verifiable

                    Mock -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                    } -MockWith $mockGetItemProperty_UninstallProducts2014 -Verifiable

                    Mock -CommandName Get-Service -MockWith $mockGetService_DefaultInstance -Verifiable

                    #region Mock Get-CimInstance
                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_DatabaseServiceName'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_DatabaseService -Verifiable

                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_AgentServiceName'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_AgentService -Verifiable

                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_FullTextServiceName'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_FullTextService -Verifiable

                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_ReportingServiceName'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_ReportingService -Verifiable

                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$(($mockDefaultInstance_IntegrationServiceName -f $mockSqlMajorVersion))'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_IntegrationService -Verifiable

                    Mock -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_AnalysisServiceName'"
                    } -MockWith $mockGetCimInstance_DefaultInstance_AnalysisService -Verifiable

                    # If Get-CimInstance is used in any other way than those mocks with a ParameterFilter, then throw and error
                    Mock -CommandName Get-CimInstance -MockWith {
                        throw "Mock Get-CimInstance was called with unexpected parameters. ClassName=$ClassName, Filter=$Filter"
                    }
                    #endregion Mock Get-CimInstance

                    Mock -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\ConfigurationState"
                    } -MockWith $mockGetItemProperty_ConfigurationState -Verifiable

                    Mock -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                    } -MockWith $mockGetItemProperty_Setup -Verifiable
                }

                It 'Should return that the desired state is present' {
                    $result = Test-TargetResource @testParameters
                    $result| Should Be $true

                    Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\ConfigurationState"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockDefaultInstance_InstanceId\Setup" -and $Name -eq 'SqlProgramDir'
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                        $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                    } -Exactly -Times 6 -Scope It

                    #region Assert Get-CimInstance
                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_DatabaseServiceName'"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_AgentServiceName'"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_FullTextServiceName'"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_ReportingServiceName'"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$(($mockDefaultInstance_IntegrationServiceName -f $mockSqlMajorVersion))'"
                    } -Exactly -Times 1 -Scope It

                    Assert-MockCalled -CommandName Get-CimInstance -ParameterFilter {
                        $ClassName -eq 'Win32_Service' -and
                        $Filter -eq "Name = '$mockDefaultInstance_AnalysisServiceName'"
                    } -Exactly -Times 1 -Scope It
                    #endregion Assert Get-CimInstance
                }
            }

            Assert-VerifiableMocks
        }

        Describe "xSQLServerSetup\Set-TargetResource" -Tag 'Set' {
            #region Setting up TestDrive:\

            # Local path to TestDrive:\
            $mockSourcePath = $TestDrive.FullName
            $mockSqlMediaPath = Join-Path -Path $mockSourcePath -ChildPath $mockSourceFolder

            # UNC path to TestDrive:\
            $testDrive_DriveShare = (Split-Path -Path $mockSourcePath -Qualifier) -replace ':','$'
            $mockSourcePathUNC = Join-Path -Path "\\localhost\$testDrive_DriveShare" -ChildPath (Split-Path -Path $mockSourcePath -NoQualifier)
            $mockSqlMediaPathUNC = Join-Path -Path $mockSourcePathUNC -ChildPath $mockSourceFolder

            # Mocking folder structure and mocking setup.exe
            New-Item -Path $mockSqlMediaPath -ItemType Directory
            Set-Content (Join-Path -Path $mockSqlMediaPath -ChildPath 'setup.exe') -Value 'Mock exe file'

            #endregion Setting up TestDrive:\

            BeforeEach {
                # General mocks
                Mock -CommandName GetSQLVersion -MockWith $mockGetSQLVersion -Verifiable
                Mock -CommandName Connect-SQL -MockWith $mockConnectSQL -Verifiable
                Mock -CommandName Connect-SQLAnalysis -MockWith $mockConnectSQLAnalysis -Verifiable
                Mock -CommandName Get-ItemProperty -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' -and
                    ($Name -eq $mockDefaultInstance_InstanceName -or $Name -eq $mockNamedInstance_InstanceName)
                } -MockWith $mockGetItemProperty_SQL -Verifiable

                Mock -CommandName Get-ItemProperty -ParameterFilter {
                    (
                        $Path -eq "HKLM:\SYSTEM\CurrentControlSet\Services\$mockDefaultInstance_AnalysisServiceName" -or
                        $Path -eq "HKLM:\SYSTEM\CurrentControlSet\Services\$mockNamedInstance_AnalysisServiceName"
                    ) -and
                    $Name -eq 'ImagePath'
                } -MockWith $mockGetItemProperty_ServicesAnalysis -Verifiable

                # Mocking SharedDirectory
                Mock -CommandName Get-ItemProperty -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\0D1F366D0FE0E404F8C15EE4F1C15094' -or
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\FEE2E540D20152D4597229B6CFBC0A69'
                } -MockWith $mockGetItemProperty_SharedDirectory -Verifiable

                Mock -CommandName Get-Item -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\0D1F366D0FE0E404F8C15EE4F1C15094' -or
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\FEE2E540D20152D4597229B6CFBC0A69'
                } -MockWith $mockGetItem_SharedDirectory -Verifiable

                # Mocking SharedWowDirectory
                Mock -CommandName Get-ItemProperty -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\C90BFAC020D87EA46811C836AD3C507F' -or
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\A79497A344129F64CA7D69C56F5DD8B4'
                } -MockWith $mockGetItemProperty_SharedWowDirectory -Verifiable

                Mock -CommandName Get-Item -ParameterFilter {
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\C90BFAC020D87EA46811C836AD3C507F' -or
                    $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\A79497A344129F64CA7D69C56F5DD8B4'
                } -MockWith $mockGetItem_SharedWowDirectory -Verifiable

                Mock -CommandName StartWin32Process -MockWith $mockStartWin32Process -Verifiable
                Mock -CommandName WaitForWin32ProcessEnd -Verifiable
                Mock -CommandName Test-TargetResource -MockWith {
                    return $true
                } -Verifiable
            }

            $testProductVersion | ForEach-Object -Process {
                $mockSqlMajorVersion = $_

                $mockDefaultInstance_InstanceId = "$($mockSqlDatabaseEngineName)$($mockSqlMajorVersion).$($mockDefaultInstance_InstanceName)"

                $mockSqlInstallPath = "C:\Program Files\Microsoft SQL Server\$($mockDefaultInstance_InstanceId)\MSSQL"
                $mockSqlBackupPath = "C:\Program Files\Microsoft SQL Server\$($mockDefaultInstance_InstanceId)\MSSQL\Backup"
                $mockSqlTempDatabasePath = ''
                $mockSqlTempDatabaseLogPath = ''
                $mockSqlDefaultDatabaseFilePath = "C:\Program Files\Microsoft SQL Server\$($mockDefaultInstance_InstanceId)\MSSQL\DATA\"
                $mockSqlDefaultDatabaseLogPath = "C:\Program Files\Microsoft SQL Server\$($mockDefaultInstance_InstanceId)\MSSQL\DATA\"

                Context "When SQL Server version is $mockSqlMajorVersion and the system is not in the desired state for a default instance" {
                    BeforeEach {
                        $testParameters = $mockDefaultParameters
                        $testParameters += @{
                            InstanceName = $mockDefaultInstance_InstanceName
                            SourceCredential = $null
                            SourcePath = $mockSourcePath
                        }

                        Mock -CommandName NetUse -Verifiable
                        Mock -CommandName Copy-ItemWithRoboCopy -Verifiable
                        Mock -CommandName Get-TemporaryFolder -MockWith $mockGetTemporaryFolder -Verifiable
                        Mock -CommandName Get-Service -MockWith $mockEmptyHashtable -Verifiable

                        Mock -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                        } -MockWith $mockEmptyHashtable -Verifiable

                        Mock -CommandName Get-CimInstance -MockWith $mockEmptyHashtable -Verifiable
                    }

                    It 'Should set the system in the desired state when feature is SQLENGINE' {
                        $mockStartWin32ProcessExpectedArgument =
                            '/Quiet="True"',
                            '/IAcceptSQLServerLicenseTerms="True"',
                            '/Action="Install"',
                            '/AGTSVCSTARTUPTYPE=Automatic',
                            '/InstanceName="MSSQLSERVER"',
                            '/Features="SQLENGINE,REPLICATION,FULLTEXT,RS,IS,AS"',
                            '/SQLSysAdminAccounts="COMPANY\sqladmin"',
                            '/ASSysAdminAccounts="COMPANY\sqladmin"' -join ' '

                        { Set-TargetResource @testParameters } | Should Not Throw

                        Assert-MockCalled -CommandName NetUse -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Get-TemporaryFolder -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Copy-ItemWithRoboCopy -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' -and
                            ($Name -eq $mockDefaultInstance_InstanceName)
                        } -Exactly -Times 0 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                        } -Exactly -Times 6 -Scope It

                        Assert-MockCalled -CommandName StartWin32Process -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName WaitForWin32ProcessEnd -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Test-TargetResource -Exactly -Times 1 -Scope It
                    }

                    if( $mockSqlMajorVersion -eq 13 ) {
                        It 'Should throw when feature parameter contains ''SSMS'' when installing SQL Server 2016' {
                            $testParameters.Features = 'SSMS'
                            $mockStartWin32ProcessExpectedArgument = ''

                            { Set-TargetResource @testParameters } | Should Throw "'SSMS' is not a valid value for setting 'FEATURES'.  Refer to SQL Help for more information."
                        }

                        It 'Should throw when feature parameter contains ''ADV_SSMS'' when installing SQL Server 2016' {
                            $testParameters.Features = 'ADV_SSMS'
                            $mockStartWin32ProcessExpectedArgument = ''

                            { Set-TargetResource @testParameters } | Should Throw "'ADV_SSMS' is not a valid value for setting 'FEATURES'.  Refer to SQL Help for more information."
                        }
                    } else {
                        It 'Should set the system in the desired state when feature is SSMS' {
                            $testParameters.Features = 'SSMS'

                            $mockStartWin32ProcessExpectedArgument =
                                '/Quiet="True"',
                                '/IAcceptSQLServerLicenseTerms="True"',
                                '/Action="Install"',
                                '/InstanceName="MSSQLSERVER"',
                                '/Features="SSMS"' -join ' '

                            { Set-TargetResource @testParameters } | Should Not Throw

                            Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' -and
                                ($Name -eq $mockDefaultInstance_InstanceName)
                            } -Exactly -Times 0 -Scope It

                            Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -Exactly -Times 6 -Scope It

                            Assert-MockCalled -CommandName StartWin32Process -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName WaitForWin32ProcessEnd -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName Test-TargetResource -Exactly -Times 1 -Scope It
                        }

                        It 'Should set the system in the desired state when feature is ADV_SSMS' {
                            $testParameters.Features = 'ADV_SSMS'

                            $mockStartWin32ProcessExpectedArgument =
                                '/Quiet="True"',
                                '/IAcceptSQLServerLicenseTerms="True"',
                                '/Action="Install"',
                                '/InstanceName="MSSQLSERVER"',
                                '/Features="ADV_SSMS"' -join ' '

                            { Set-TargetResource @testParameters } | Should Not Throw

                            Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' -and
                                ($Name -eq $mockDefaultInstance_InstanceName)
                            } -Exactly -Times 0 -Scope It

                            Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -Exactly -Times 6 -Scope It


                            Assert-MockCalled -CommandName StartWin32Process -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName WaitForWin32ProcessEnd -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName Test-TargetResource -Exactly -Times 1 -Scope It
                        }
                    }
                }

                Context "When using SourceCredential parameter and SQL Server version is $mockSqlMajorVersion and the system is not in the desired state for a default instance" {
                    BeforeEach {
                        $testParameters = $mockDefaultParameters
                        $testParameters += @{
                            InstanceName = $mockDefaultInstance_InstanceName
                            SourceCredential = $mockSetupCredential
                            SourcePath = $mockSourcePathUNC
                        }

                        Mock -CommandName NetUse -Verifiable
                        Mock -CommandName Copy-ItemWithRoboCopy -Verifiable
                        Mock -CommandName Get-TemporaryFolder -MockWith $mockGetTemporaryFolder -Verifiable
                        Mock -CommandName Get-Service -MockWith $mockEmptyHashtable -Verifiable

                        Mock -CommandName Get-CimInstance -MockWith $mockEmptyHashtable -Verifiable
                        Mock -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                        } -MockWith $mockEmptyHashtable -Verifiable
                    }

                    It 'Should set the system in the desired state when feature is SQLENGINE' {
                        $mockStartWin32ProcessExpectedArgument =
                            '/Quiet="True"',
                            '/IAcceptSQLServerLicenseTerms="True"',
                            '/Action="Install"',
                            '/AGTSVCSTARTUPTYPE=Automatic',
                            '/InstanceName="MSSQLSERVER"',
                            '/Features="SQLENGINE,REPLICATION,FULLTEXT,RS,IS,AS"',
                            '/SQLSysAdminAccounts="COMPANY\sqladmin"',
                            '/ASSysAdminAccounts="COMPANY\sqladmin"' -join ' '

                        { Set-TargetResource @testParameters } | Should Not Throw

                        Assert-MockCalled -CommandName NetUse -Exactly -Times 4 -Scope It
                        Assert-MockCalled -CommandName Get-TemporaryFolder -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Copy-ItemWithRoboCopy -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' -and
                            ($Name -eq $mockDefaultInstance_InstanceName)
                        } -Exactly -Times 0 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                        } -Exactly -Times 6 -Scope It


                        Assert-MockCalled -CommandName StartWin32Process -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName WaitForWin32ProcessEnd -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Test-TargetResource -Exactly -Times 1 -Scope It
                    }

                    if( $mockSqlMajorVersion -eq 13 ) {
                        It 'Should throw when feature parameter contains ''SSMS'' when installing SQL Server 2016' {
                            $testParameters.Features = 'SSMS'
                            $mockStartWin32ProcessExpectedArgument = ''

                            { Set-TargetResource @testParameters } | Should Throw "'SSMS' is not a valid value for setting 'FEATURES'.  Refer to SQL Help for more information."
                        }

                        It 'Should throw when feature parameter contains ''ADV_SSMS'' when installing SQL Server 2016' {
                            $testParameters.Features = 'ADV_SSMS'
                            $mockStartWin32ProcessExpectedArgument = ''

                            { Set-TargetResource @testParameters } | Should Throw "'ADV_SSMS' is not a valid value for setting 'FEATURES'.  Refer to SQL Help for more information."
                        }
                    } else {
                        It 'Should set the system in the desired state when feature is SSMS' {
                            $testParameters.Features = 'SSMS'

                            $mockStartWin32ProcessExpectedArgument =
                                '/Quiet="True"',
                                '/IAcceptSQLServerLicenseTerms="True"',
                                '/Action="Install"',
                                '/InstanceName="MSSQLSERVER"',
                                '/Features="SSMS"' -join ' '

                            { Set-TargetResource @testParameters } | Should Not Throw

                            Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' -and
                                ($Name -eq $mockDefaultInstance_InstanceName)
                            } -Exactly -Times 0 -Scope It

                            Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -Exactly -Times 6 -Scope It


                            Assert-MockCalled -CommandName StartWin32Process -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName WaitForWin32ProcessEnd -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName Test-TargetResource -Exactly -Times 1 -Scope It
                        }

                        It 'Should set the system in the desired state when feature is ADV_SSMS' {
                            $testParameters.Features = 'ADV_SSMS'

                            $mockStartWin32ProcessExpectedArgument =
                                '/Quiet="True"',
                                '/IAcceptSQLServerLicenseTerms="True"',
                                '/Action="Install"',
                                '/InstanceName="MSSQLSERVER"',
                                '/Features="ADV_SSMS"' -join ' '

                            { Set-TargetResource @testParameters } | Should Not Throw

                            Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' -and
                                ($Name -eq $mockDefaultInstance_InstanceName)
                            } -Exactly -Times 0 -Scope It

                            Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -Exactly -Times 6 -Scope It

                            Assert-MockCalled -CommandName StartWin32Process -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName WaitForWin32ProcessEnd -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName Test-TargetResource -Exactly -Times 1 -Scope It
                        }
                    }
                }

                $mockNamedInstance_InstanceId = "$($mockSqlDatabaseEngineName)$($mockSqlMajorVersion).$($mockNamedInstance_InstanceName)"

                $mockSqlInstallPath = "C:\Program Files\Microsoft SQL Server\$($mockNamedInstance_InstanceId)\MSSQL"
                $mockSqlBackupPath = "C:\Program Files\Microsoft SQL Server\$($mockNamedInstance_InstanceId)\MSSQL\Backup"
                $mockSqlTempDatabasePath = ''
                $mockSqlTempDatabaseLogPath = ''
                $mockSqlDefaultDatabaseFilePath = "C:\Program Files\Microsoft SQL Server\$($mockNamedInstance_InstanceId)\MSSQL\DATA\"
                $mockSqlDefaultDatabaseLogPath = "C:\Program Files\Microsoft SQL Server\$($mockNamedInstance_InstanceId)\MSSQL\DATA\"

                Context "When SQL Server version is $mockSqlMajorVersion and the system is not in the desired state for a named instance" {
                    BeforeEach {
                        $testParameters = $mockDefaultParameters
                        $testParameters += @{
                            InstanceName = $mockNamedInstance_InstanceName
                            SourceCredential = $null
                            SourcePath = $mockSourcePath
                        }

                        Mock -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                        } -MockWith $mockEmptyHashtable -Verifiable

                        Mock -CommandName Get-Service -MockWith $mockEmptyHashtable -Verifiable
                        Mock -CommandName Get-CimInstance -MockWith $mockEmptyHashtable -Verifiable
                    }

                    It 'Should set the system in the desired state when feature is SQLENGINE' {
                        $mockStartWin32ProcessExpectedArgument =
                            '/Quiet="True"',
                            '/IAcceptSQLServerLicenseTerms="True"',
                            '/Action="Install"',
                            '/AGTSVCSTARTUPTYPE=Automatic',
                            '/InstanceName="TEST"',
                            '/Features="SQLENGINE,REPLICATION,FULLTEXT,RS,IS,AS"',
                            '/SQLSysAdminAccounts="COMPANY\sqladmin"',
                            '/ASSysAdminAccounts="COMPANY\sqladmin"' -join ' '

                        { Set-TargetResource @testParameters } | Should Not Throw

                        Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 0 -Scope It
                        Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' -and
                            ($Name -eq $mockDefaultInstance_InstanceName)
                        } -Exactly -Times 0 -Scope It

                        Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 0 -Scope It

                        Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                            $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                        } -Exactly -Times 6 -Scope It

                        Assert-MockCalled -CommandName StartWin32Process -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName WaitForWin32ProcessEnd -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Test-TargetResource -Exactly -Times 1 -Scope It
                    }

                    if( $mockSqlMajorVersion -eq 13 ) {
                        It 'Should throw when feature parameter contains ''SSMS'' when installing SQL Server 2016' {
                            $testParameters.Features = $($testParameters.Features), 'SSMS' -join ','
                            $mockStartWin32ProcessExpectedArgument = ''

                            { Set-TargetResource @testParameters } | Should Throw "'SSMS' is not a valid value for setting 'FEATURES'.  Refer to SQL Help for more information."
                        }

                        It 'Should throw when feature parameter contains ''ADV_SSMS'' when installing SQL Server 2016' {
                            $testParameters.Features = $($testParameters.Features), 'ADV_SSMS' -join ','
                            $mockStartWin32ProcessExpectedArgument = ''

                            { Set-TargetResource @testParameters } | Should Throw "'ADV_SSMS' is not a valid value for setting 'FEATURES'.  Refer to SQL Help for more information."
                        }
                    } else {
                        It 'Should set the system in the desired state when feature is SSMS' {
                            $testParameters.Features = 'SSMS'

                            $mockStartWin32ProcessExpectedArgument =
                                '/Quiet="True"',
                                '/IAcceptSQLServerLicenseTerms="True"',
                                '/Action="Install"',
                                '/InstanceName="TEST"',
                                '/Features="SSMS"' -join ' '

                            { Set-TargetResource @testParameters } | Should Not Throw

                            Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Connect-SQLAnalysis -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' -and
                                ($Name -eq $mockDefaultInstance_InstanceName)
                            } -Exactly -Times 0 -Scope It

                            Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -Exactly -Times 6 -Scope It

                            Assert-MockCalled -CommandName StartWin32Process -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName WaitForWin32ProcessEnd -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName Test-TargetResource -Exactly -Times 1 -Scope It
                        }

                        It 'Should set the system in the desired state when feature is ADV_SSMS' {
                            $testParameters.Features = 'ADV_SSMS'

                            $mockStartWin32ProcessExpectedArgument =
                                '/Quiet="True"',
                                '/IAcceptSQLServerLicenseTerms="True"',
                                '/Action="Install"',
                                '/InstanceName="TEST"',
                                '/Features="ADV_SSMS"' -join ' '

                            { Set-TargetResource @testParameters } | Should Not Throw

                            Assert-MockCalled -CommandName Connect-SQL -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Get-Service -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' -and
                                ($Name -eq $mockDefaultInstance_InstanceName)
                            } -Exactly -Times 0 -Scope It

                            Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 0 -Scope It
                            Assert-MockCalled -CommandName Get-ItemProperty -ParameterFilter {
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudio2014_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2008R2_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2012_ProductIdentifyingNumber) -or
                                $Path -eq (Join-Path -Path $mockRegistryUninstallProductsPath -ChildPath $mockSqlServerManagementStudioAdvanced2014_ProductIdentifyingNumber)
                            } -Exactly -Times 6 -Scope It

                            Assert-MockCalled -CommandName StartWin32Process -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName WaitForWin32ProcessEnd -Exactly -Times 1 -Scope It
                            Assert-MockCalled -CommandName Test-TargetResource -Exactly -Times 1 -Scope It
                        }
                    }
                }
            }

            Assert-VerifiableMocks
        }

        Describe 'Join-ServiceAccountInfo' -Tag 'Helper' {
            Context 'When called it should return a string with service account information appended to the original argument string' {

                $Params = @{ UsernameArgumentname = 'SQLSVCACCOUNT'; PasswordArgumentName = 'SQLSVCPASSWORD'; ArgumentString = "C:\Install\SQLSource\setup.exe" }

                $mockSetupDomainCredential = New-Object System.Management.Automation.PSCredential( 'Company\SQLServer', (ConvertTo-SecureString 'password' -AsPlainText -Force) )
                $mockSetupMSACredential = New-Object System.Management.Automation.PSCredential( 'Company\SQLServer$', (ConvertTo-SecureString 'password' -AsPlainText -Force) )
                $mockSetupSystemCredential = New-Object System.Management.Automation.PSCredential( 'SYSTEM', (ConvertTo-SecureString 'password' -AsPlainText -Force) )
                $mockSetupLocalServiceCredential = New-Object System.Management.Automation.PSCredential( 'LOCALSERVICE', (ConvertTo-SecureString 'password' -AsPlainText -Force) )
                $mockSetupNetworkServiceCredential = New-Object System.Management.Automation.PSCredential( 'NETWORKSERVICE', (ConvertTo-SecureString 'password' -AsPlainText -Force) )
                $mockSetupNTSystemCredential = New-Object System.Management.Automation.PSCredential( 'NT AUTHORITY\SYSTEM', (ConvertTo-SecureString 'password' -AsPlainText -Force) )
                $mockSetupNTLocalServiceCredential = New-Object System.Management.Automation.PSCredential( 'NT AUTHORITY\LOCALSERVICE', (ConvertTo-SecureString 'password' -AsPlainText -Force) )
                $mockSetupNTNetworkServiceCredential = New-Object System.Management.Automation.PSCredential( 'NT AUTHORITY\NETWORKSERVICE', (ConvertTo-SecureString 'password' -AsPlainText -Force) )

                It 'Should return string with service account information and password appended Domain/Local Account' {
                   Join-ServiceAccountInfo @Params -User $mockSetupDomainCredential | Should BeExactly ('{0} /{1}="{2}" /{3}="{4}"' -f $Params['ArgumentString'], $Params['UsernameArgumentname'], $mockSetupDomainCredential.UserName, $Params['PasswordArgumentname'], $mockSetupDomainCredential.GetNetworkCredential().Password)
                }

                It 'Should return string service account information and no password appended for Managed Service Account' {
                    Join-ServiceAccountInfo @Params -User $mockSetupMSACredential | Should BeExactly ('{0} /{1}="{2}"' -f $Params['ArgumentString'], $Params['UsernameArgumentname'], $mockSetupMSACredential.UserName)
                }

                It 'Should return string service account information and no password appended for NT AUTHORITY\SYSTEM. Test without NT AUTHORITY prepended' {
                    Join-ServiceAccountInfo @Params -User $mockSetupSystemCredential | Should BeExactly ('{0} /{1}="NT AUTHORITY\{2}"' -f $Params['ArgumentString'], $Params['UsernameArgumentname'], $mockSetupSystemCredential.UserName)
                }

                It 'Should return string service account information and no password appended for NT AUTHORITY\LOCALSERVICE. Test without NT AUTHORITY prepended' {
                    Join-ServiceAccountInfo @Params -User $mockSetupLocalServiceCredential | Should BeExactly ('{0} /{1}="NT AUTHORITY\{2}"' -f $Params['ArgumentString'], $Params['UsernameArgumentname'], $mockSetupLocalServiceCredential.UserName)
                }

                It 'Should return string service account information and no password appended for NT AUTHORITY\NETWORKSERVICE. Test without NT AUTHORITY prepended' {
                    Join-ServiceAccountInfo @Params -User $mockSetupNetworkServiceCredential | Should BeExactly ('{0} /{1}="NT AUTHORITY\{2}"' -f $Params['ArgumentString'], $Params['UsernameArgumentname'], $mockSetupNetworkServiceCredential.UserName)
                }

                It 'Should return string service account information and no password appended for NT AUTHORITY\SYSTEM. Test with NT AUTHORITY prepended' {
                    Join-ServiceAccountInfo @Params -User $mockSetupNTSystemCredential | Should BeExactly ('{0} /{1}="{2}"' -f $Params['ArgumentString'], $Params['UsernameArgumentname'], $mockSetupNTSystemCredential.UserName)
                }

                It 'Should return string service account information and no password appended for NT AUTHORITY\LOCALSERVICE. Test with NT AUTHORITY prepended' {
                    Join-ServiceAccountInfo @Params -User $mockSetupNTLocalServiceCredential | Should BeExactly ('{0} /{1}="{2}"' -f $Params['ArgumentString'], $Params['UsernameArgumentname'], $mockSetupNTLocalServiceCredential.UserName)
                }

                It 'Should return string service account information and no password appended for NT AUTHORITY\NETWORKSERVICE. Test with NT AUTHORITY prepended' {
                    Join-ServiceAccountInfo @Params -User $mockSetupNTNetworkServiceCredential | Should BeExactly ('{0} /{1}="{2}"' -f $Params['ArgumentString'], $Params['UsernameArgumentname'], $mockSetupNTNetworkServiceCredential.UserName)
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
