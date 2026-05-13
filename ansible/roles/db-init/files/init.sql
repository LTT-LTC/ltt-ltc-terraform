-- Single consolidated initialization script for all LTC databases.
-- Canonical setup:
--   - Databases: LTC_Administration, LTC_Customer, LTC_Movie, LTC_Product, LTC_Payment
--   - Business schema: LTC (default project schema for domain tables)
--   - ABP framework tables: dbo (administration database)
SET NOCOUNT ON;
GO

IF DB_ID(N'LTC_Administration') IS NULL CREATE DATABASE [LTC_Administration];
GO
IF DB_ID(N'LTC_Customer') IS NULL CREATE DATABASE [LTC_Customer];
GO
IF DB_ID(N'LTC_Movie') IS NULL CREATE DATABASE [LTC_Movie];
GO
IF DB_ID(N'LTC_Product') IS NULL CREATE DATABASE [LTC_Product];
GO
IF DB_ID(N'LTC_Payment') IS NULL CREATE DATABASE [LTC_Payment];
GO

USE [LTC_Administration];
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'LTC') EXEC(N'CREATE SCHEMA [LTC]');
GO

USE [LTC_Customer];
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'LTC') EXEC(N'CREATE SCHEMA [LTC]');
GO

USE [LTC_Movie];
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'LTC') EXEC(N'CREATE SCHEMA [LTC]');
GO

USE [LTC_Product];
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'LTC') EXEC(N'CREATE SCHEMA [LTC]');
GO

USE [LTC_Payment];
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'LTC') EXEC(N'CREATE SCHEMA [LTC]');
GO

USE [LTC_Administration];
GO
IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpClaimTypes] (
        [Id] uniqueidentifier NOT NULL,
        [Name] nvarchar(256) NOT NULL,
        [Required] bit NOT NULL,
        [IsStatic] bit NOT NULL,
        [Regex] nvarchar(512) NULL,
        [RegexDescription] nvarchar(128) NULL,
        [Description] nvarchar(256) NULL,
        [ValueType] int NOT NULL,
        [CreationTime] datetime2 NOT NULL,
        [ExtraProperties] nvarchar(max) NOT NULL,
        [ConcurrencyStamp] nvarchar(40) NOT NULL,
        CONSTRAINT [PK_AbpClaimTypes] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpFeatureGroups] (
        [Id] uniqueidentifier NOT NULL,
        [Name] nvarchar(128) NOT NULL,
        [DisplayName] nvarchar(256) NOT NULL,
        [ExtraProperties] nvarchar(max) NULL,
        CONSTRAINT [PK_AbpFeatureGroups] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpFeatures] (
        [Id] uniqueidentifier NOT NULL,
        [GroupName] nvarchar(128) NOT NULL,
        [Name] nvarchar(128) NOT NULL,
        [ParentName] nvarchar(128) NULL,
        [DisplayName] nvarchar(256) NOT NULL,
        [Description] nvarchar(256) NULL,
        [DefaultValue] nvarchar(256) NULL,
        [IsVisibleToClients] bit NOT NULL,
        [IsAvailableToHost] bit NOT NULL,
        [AllowedProviders] nvarchar(256) NULL,
        [ValueType] nvarchar(2048) NULL,
        [ExtraProperties] nvarchar(max) NULL,
        CONSTRAINT [PK_AbpFeatures] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpFeatureValues] (
        [Id] uniqueidentifier NOT NULL,
        [Name] nvarchar(128) NOT NULL,
        [Value] nvarchar(128) NOT NULL,
        [ProviderName] nvarchar(64) NULL,
        [ProviderKey] nvarchar(64) NULL,
        CONSTRAINT [PK_AbpFeatureValues] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpLinkUsers] (
        [Id] uniqueidentifier NOT NULL,
        [SourceUserId] uniqueidentifier NOT NULL,
        [SourceTenantId] uniqueidentifier NULL,
        [TargetUserId] uniqueidentifier NOT NULL,
        [TargetTenantId] uniqueidentifier NULL,
        CONSTRAINT [PK_AbpLinkUsers] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpOrganizationUnits] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [ParentId] uniqueidentifier NULL,
        [Code] nvarchar(95) NOT NULL,
        [DisplayName] nvarchar(128) NOT NULL,
        [EntityVersion] int NOT NULL,
        [ExtraProperties] nvarchar(max) NOT NULL,
        [ConcurrencyStamp] nvarchar(40) NOT NULL,
        [CreationTime] datetime2 NOT NULL,
        [CreatorId] uniqueidentifier NULL,
        [LastModificationTime] datetime2 NULL,
        [LastModifierId] uniqueidentifier NULL,
        [IsDeleted] bit NOT NULL DEFAULT CAST(0 AS bit),
        [DeleterId] uniqueidentifier NULL,
        [DeletionTime] datetime2 NULL,
        CONSTRAINT [PK_AbpOrganizationUnits] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_AbpOrganizationUnits_AbpOrganizationUnits_ParentId] FOREIGN KEY ([ParentId]) REFERENCES [AbpOrganizationUnits] ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpPermissionGrants] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Name] nvarchar(128) NOT NULL,
        [ProviderName] nvarchar(64) NOT NULL,
        [ProviderKey] nvarchar(64) NOT NULL,
        CONSTRAINT [PK_AbpPermissionGrants] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpPermissionGroups] (
        [Id] uniqueidentifier NOT NULL,
        [Name] nvarchar(128) NOT NULL,
        [DisplayName] nvarchar(256) NOT NULL,
        [ExtraProperties] nvarchar(max) NULL,
        CONSTRAINT [PK_AbpPermissionGroups] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpPermissions] (
        [Id] uniqueidentifier NOT NULL,
        [GroupName] nvarchar(128) NULL,
        [Name] nvarchar(128) NOT NULL,
        [ResourceName] nvarchar(256) NULL,
        [ManagementPermissionName] nvarchar(128) NULL,
        [ParentName] nvarchar(128) NULL,
        [DisplayName] nvarchar(256) NOT NULL,
        [IsEnabled] bit NOT NULL,
        [MultiTenancySide] tinyint NOT NULL,
        [Providers] nvarchar(128) NULL,
        [StateCheckers] nvarchar(256) NULL,
        [ExtraProperties] nvarchar(max) NULL,
        CONSTRAINT [PK_AbpPermissions] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpResourcePermissionGrants] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Name] nvarchar(128) NOT NULL,
        [ProviderName] nvarchar(64) NOT NULL,
        [ProviderKey] nvarchar(64) NOT NULL,
        [ResourceName] nvarchar(256) NOT NULL,
        [ResourceKey] nvarchar(256) NOT NULL,
        CONSTRAINT [PK_AbpResourcePermissionGrants] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpRoles] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Name] nvarchar(256) NOT NULL,
        [NormalizedName] nvarchar(256) NOT NULL,
        [IsDefault] bit NOT NULL,
        [IsStatic] bit NOT NULL,
        [IsPublic] bit NOT NULL,
        [EntityVersion] int NOT NULL,
        [CreationTime] datetime2 NOT NULL,
        [ExtraProperties] nvarchar(max) NOT NULL,
        [ConcurrencyStamp] nvarchar(40) NOT NULL,
        CONSTRAINT [PK_AbpRoles] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpSecurityLogs] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [ApplicationName] nvarchar(96) NULL,
        [Identity] nvarchar(96) NULL,
        [Action] nvarchar(96) NULL,
        [UserId] uniqueidentifier NULL,
        [UserName] nvarchar(256) NULL,
        [TenantName] nvarchar(64) NULL,
        [ClientId] nvarchar(64) NULL,
        [CorrelationId] nvarchar(64) NULL,
        [ClientIpAddress] nvarchar(64) NULL,
        [BrowserInfo] nvarchar(512) NULL,
        [CreationTime] datetime2 NOT NULL,
        [ExtraProperties] nvarchar(max) NOT NULL,
        [ConcurrencyStamp] nvarchar(40) NOT NULL,
        CONSTRAINT [PK_AbpSecurityLogs] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpSessions] (
        [Id] uniqueidentifier NOT NULL,
        [SessionId] nvarchar(128) NOT NULL,
        [Device] nvarchar(64) NOT NULL,
        [DeviceInfo] nvarchar(256) NULL,
        [TenantId] uniqueidentifier NULL,
        [UserId] uniqueidentifier NOT NULL,
        [ClientId] nvarchar(64) NULL,
        [IpAddresses] nvarchar(2048) NULL,
        [SignedIn] datetime2 NOT NULL,
        [LastAccessed] datetime2 NULL,
        [ExtraProperties] nvarchar(max) NULL,
        CONSTRAINT [PK_AbpSessions] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpSettingDefinitions] (
        [Id] uniqueidentifier NOT NULL,
        [Name] nvarchar(128) NOT NULL,
        [DisplayName] nvarchar(256) NOT NULL,
        [Description] nvarchar(512) NULL,
        [DefaultValue] nvarchar(2048) NULL,
        [IsVisibleToClients] bit NOT NULL,
        [Providers] nvarchar(1024) NULL,
        [IsInherited] bit NOT NULL,
        [IsEncrypted] bit NOT NULL,
        [ExtraProperties] nvarchar(max) NULL,
        CONSTRAINT [PK_AbpSettingDefinitions] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpSettings] (
        [Id] uniqueidentifier NOT NULL,
        [Name] nvarchar(128) NOT NULL,
        [Value] nvarchar(2048) NOT NULL,
        [ProviderName] nvarchar(64) NULL,
        [ProviderKey] nvarchar(64) NULL,
        CONSTRAINT [PK_AbpSettings] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpTenants] (
        [Id] uniqueidentifier NOT NULL,
        [Name] nvarchar(64) NOT NULL,
        [NormalizedName] nvarchar(64) NOT NULL,
        [EntityVersion] int NOT NULL,
        [ExtraProperties] nvarchar(max) NOT NULL,
        [ConcurrencyStamp] nvarchar(40) NOT NULL,
        [CreationTime] datetime2 NOT NULL,
        [CreatorId] uniqueidentifier NULL,
        [LastModificationTime] datetime2 NULL,
        [LastModifierId] uniqueidentifier NULL,
        [IsDeleted] bit NOT NULL DEFAULT CAST(0 AS bit),
        [DeleterId] uniqueidentifier NULL,
        [DeletionTime] datetime2 NULL,
        CONSTRAINT [PK_AbpTenants] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpUserDelegations] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [SourceUserId] uniqueidentifier NOT NULL,
        [TargetUserId] uniqueidentifier NOT NULL,
        [StartTime] datetime2 NOT NULL,
        [EndTime] datetime2 NOT NULL,
        CONSTRAINT [PK_AbpUserDelegations] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpUsers] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [UserName] nvarchar(256) NOT NULL,
        [NormalizedUserName] nvarchar(256) NOT NULL,
        [Name] nvarchar(64) NULL,
        [Surname] nvarchar(64) NULL,
        [Email] nvarchar(256) NOT NULL,
        [NormalizedEmail] nvarchar(256) NOT NULL,
        [EmailConfirmed] bit NOT NULL DEFAULT CAST(0 AS bit),
        [PasswordHash] nvarchar(256) NULL,
        [SecurityStamp] nvarchar(256) NOT NULL,
        [IsExternal] bit NOT NULL DEFAULT CAST(0 AS bit),
        [PhoneNumber] nvarchar(16) NULL,
        [PhoneNumberConfirmed] bit NOT NULL DEFAULT CAST(0 AS bit),
        [IsActive] bit NOT NULL,
        [TwoFactorEnabled] bit NOT NULL DEFAULT CAST(0 AS bit),
        [LockoutEnd] datetimeoffset NULL,
        [LockoutEnabled] bit NOT NULL DEFAULT CAST(0 AS bit),
        [AccessFailedCount] int NOT NULL DEFAULT 0,
        [ShouldChangePasswordOnNextLogin] bit NOT NULL,
        [EntityVersion] int NOT NULL,
        [LastPasswordChangeTime] datetimeoffset NULL,
        [LastSignInTime] datetimeoffset NULL,
        [ExtraProperties] nvarchar(max) NOT NULL,
        [ConcurrencyStamp] nvarchar(40) NOT NULL,
        [CreationTime] datetime2 NOT NULL,
        [CreatorId] uniqueidentifier NULL,
        [LastModificationTime] datetime2 NULL,
        [LastModifierId] uniqueidentifier NULL,
        [IsDeleted] bit NOT NULL DEFAULT CAST(0 AS bit),
        [DeleterId] uniqueidentifier NULL,
        [DeletionTime] datetime2 NULL,
        CONSTRAINT [PK_AbpUsers] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [CinemaAmenities] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [CinemaId] uniqueidentifier NOT NULL,
        [AmenitiesTypeId] uniqueidentifier NOT NULL,
        [ProductId] uniqueidentifier NULL,
        [Name] nvarchar(max) NOT NULL,
        [Description] nvarchar(max) NULL,
        [Status] nvarchar(max) NOT NULL,
        CONSTRAINT [PK_CinemaAmenities] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [CinemaAmenityTypes] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Name] nvarchar(max) NOT NULL,
        [Icon] nvarchar(max) NULL,
        CONSTRAINT [PK_CinemaAmenityTypes] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [Cinemas] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Name] nvarchar(max) NOT NULL,
        [City] nvarchar(max) NULL,
        [Ward] nvarchar(max) NULL,
        [Address] nvarchar(max) NULL,
        [ManagerUserId] uniqueidentifier NULL,
        [ServiceNumber] nvarchar(max) NULL,
        [Status] nvarchar(max) NULL,
        [CreatedAt] datetime2 NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_Cinemas] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [Employees] (
        [Id] uniqueidentifier NOT NULL,
        [EmployeeId] nvarchar(max) NULL,
        [TenantId] uniqueidentifier NULL,
        [UserId] uniqueidentifier NULL,
        [CinemaId] uniqueidentifier NULL,
        [Scope] nvarchar(max) NULL,
        [Position] nvarchar(max) NULL,
        [HireDate] datetime2 NULL,
        [Status] nvarchar(max) NULL,
        [ManagedByEmployeeId] uniqueidentifier NULL,
        [CreatedByUserId] uniqueidentifier NULL,
        [Name] nvarchar(max) NULL,
        [Code] nvarchar(max) NULL,
        [Email] nvarchar(max) NULL,
        [OtherEmail] nvarchar(max) NULL,
        [PhoneNumber] nvarchar(max) NULL,
        [OrganizationUnitId] uniqueidentifier NULL,
        [PositionId] uniqueidentifier NULL,
        [AvatarFileId] uniqueidentifier NULL,
        [JoinedDate] datetime2 NULL,
        [DateOfBirth] datetime2 NULL,
        [IsFirstLogin] bit NOT NULL,
        [CreationTime] datetime2 NOT NULL,
        [CreatorId] uniqueidentifier NULL,
        [LastModificationTime] datetime2 NULL,
        [LastModifierId] uniqueidentifier NULL,
        [IsDeleted] bit NOT NULL DEFAULT CAST(0 AS bit),
        [DeleterId] uniqueidentifier NULL,
        [DeletionTime] datetime2 NULL,
        CONSTRAINT [PK_Employees] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [GiftCodes] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Code] nvarchar(max) NOT NULL,
        [Description] nvarchar(max) NULL,
        [DiscountType] nvarchar(max) NULL,
        [DiscountValue] decimal(18,2) NOT NULL,
        [MinOrderAmount] decimal(18,2) NULL,
        [UsageLimit] int NULL,
        [UsageCount] int NOT NULL,
        [PerUserLimit] int NULL,
        [StartDate] datetime2 NULL,
        [EndDate] datetime2 NULL,
        [Status] nvarchar(max) NULL,
        CONSTRAINT [PK_GiftCodes] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [MediaFiles] (
        [Id] uniqueidentifier NOT NULL,
        [DisplayName] nvarchar(max) NOT NULL,
        [ResourceType] nvarchar(max) NOT NULL,
        [SecureUrl] nvarchar(max) NOT NULL,
        [PublicId] nvarchar(max) NOT NULL,
        [Type] nvarchar(max) NOT NULL,
        [AssetId] nvarchar(max) NOT NULL,
        [Format] nvarchar(max) NOT NULL,
        [Size] bigint NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [CreationTime] datetime2 NOT NULL,
        [CreatorId] uniqueidentifier NULL,
        [LastModificationTime] datetime2 NULL,
        [LastModifierId] uniqueidentifier NULL,
        [IsDeleted] bit NOT NULL DEFAULT CAST(0 AS bit),
        [DeleterId] uniqueidentifier NULL,
        [DeletionTime] datetime2 NULL,
        CONSTRAINT [PK_MediaFiles] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [PricingRules] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [CinemaId] uniqueidentifier NOT NULL,
        [SeatTypeId] uniqueidentifier NULL,
        [RuleType] nvarchar(max) NULL,
        [Multiplier] decimal(18,2) NOT NULL,
        [StartTime] time NULL,
        [EndTime] time NULL,
        [DayOfWeek] nvarchar(max) NULL,
        [Priority] int NOT NULL,
        [ValidFrom] datetime2 NULL,
        [ValidUntil] datetime2 NULL,
        [IsActive] bit NOT NULL,
        [CreatedAt] datetime2 NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_PricingRules] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [RevenueSnapshots] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [CinemaId] uniqueidentifier NOT NULL,
        [SnapshotDate] datetime2 NOT NULL,
        [Granularity] nvarchar(max) NULL,
        [TotalRevenue] decimal(18,2) NOT NULL,
        [TotalBookings] int NOT NULL,
        [TotalTickets] int NOT NULL,
        [OccupancyRate] decimal(18,2) NOT NULL,
        [CreatedAt] datetime2 NULL,
        CONSTRAINT [PK_RevenueSnapshots] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [Screens] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [CinemaId] uniqueidentifier NOT NULL,
        [ScreenNumber] int NOT NULL,
        [ScreenType] nvarchar(max) NULL,
        [SeatLayout] nvarchar(max) NULL,
        [SeatCount] int NOT NULL,
        [Status] nvarchar(max) NULL,
        [CreatedAt] datetime2 NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_Screens] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [SeatTypes] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Name] nvarchar(max) NOT NULL,
        [Description] nvarchar(max) NULL,
        [NumberOfSeat] int NOT NULL,
        [DisplayDirection] nvarchar(max) NULL,
        [PriceMultiplier] decimal(18,2) NOT NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_SeatTypes] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [Showtimes] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [CinemaId] uniqueidentifier NOT NULL,
        [DistributionId] uniqueidentifier NOT NULL,
        [ScreenId] uniqueidentifier NOT NULL,
        [ShowDate] datetime2 NOT NULL,
        [StartTime] time NOT NULL,
        [EndTime] time NOT NULL,
        [BasePrice] decimal(18,2) NOT NULL,
        [Status] nvarchar(max) NULL,
        [CreatedAt] datetime2 NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_Showtimes] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpOrganizationUnitRoles] (
        [RoleId] uniqueidentifier NOT NULL,
        [OrganizationUnitId] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [CreationTime] datetime2 NOT NULL,
        [CreatorId] uniqueidentifier NULL,
        CONSTRAINT [PK_AbpOrganizationUnitRoles] PRIMARY KEY ([OrganizationUnitId], [RoleId]),
        CONSTRAINT [FK_AbpOrganizationUnitRoles_AbpOrganizationUnits_OrganizationUnitId] FOREIGN KEY ([OrganizationUnitId]) REFERENCES [AbpOrganizationUnits] ([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_AbpOrganizationUnitRoles_AbpRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AbpRoles] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpRoleClaims] (
        [Id] uniqueidentifier NOT NULL,
        [RoleId] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [ClaimType] nvarchar(256) NOT NULL,
        [ClaimValue] nvarchar(1024) NULL,
        CONSTRAINT [PK_AbpRoleClaims] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_AbpRoleClaims_AbpRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AbpRoles] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpTenantConnectionStrings] (
        [TenantId] uniqueidentifier NOT NULL,
        [Name] nvarchar(64) NOT NULL,
        [Value] nvarchar(1024) NOT NULL,
        CONSTRAINT [PK_AbpTenantConnectionStrings] PRIMARY KEY ([TenantId], [Name]),
        CONSTRAINT [FK_AbpTenantConnectionStrings_AbpTenants_TenantId] FOREIGN KEY ([TenantId]) REFERENCES [AbpTenants] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpUserClaims] (
        [Id] uniqueidentifier NOT NULL,
        [UserId] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [ClaimType] nvarchar(256) NOT NULL,
        [ClaimValue] nvarchar(1024) NULL,
        CONSTRAINT [PK_AbpUserClaims] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_AbpUserClaims_AbpUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AbpUsers] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpUserLogins] (
        [UserId] uniqueidentifier NOT NULL,
        [LoginProvider] nvarchar(64) NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [ProviderKey] nvarchar(196) NOT NULL,
        [ProviderDisplayName] nvarchar(128) NULL,
        CONSTRAINT [PK_AbpUserLogins] PRIMARY KEY ([UserId], [LoginProvider]),
        CONSTRAINT [FK_AbpUserLogins_AbpUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AbpUsers] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpUserOrganizationUnits] (
        [UserId] uniqueidentifier NOT NULL,
        [OrganizationUnitId] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [CreationTime] datetime2 NOT NULL,
        [CreatorId] uniqueidentifier NULL,
        CONSTRAINT [PK_AbpUserOrganizationUnits] PRIMARY KEY ([OrganizationUnitId], [UserId]),
        CONSTRAINT [FK_AbpUserOrganizationUnits_AbpOrganizationUnits_OrganizationUnitId] FOREIGN KEY ([OrganizationUnitId]) REFERENCES [AbpOrganizationUnits] ([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_AbpUserOrganizationUnits_AbpUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AbpUsers] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpUserPasskeys] (
        [CredentialId] varbinary(1024) NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [UserId] uniqueidentifier NOT NULL,
        [Data] nvarchar(max) NULL,
        CONSTRAINT [PK_AbpUserPasskeys] PRIMARY KEY ([CredentialId]),
        CONSTRAINT [FK_AbpUserPasskeys_AbpUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AbpUsers] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpUserPasswordHistories] (
        [UserId] uniqueidentifier NOT NULL,
        [Password] nvarchar(256) NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [CreatedAt] datetimeoffset NOT NULL,
        CONSTRAINT [PK_AbpUserPasswordHistories] PRIMARY KEY ([UserId], [Password]),
        CONSTRAINT [FK_AbpUserPasswordHistories_AbpUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AbpUsers] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpUserRoles] (
        [UserId] uniqueidentifier NOT NULL,
        [RoleId] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        CONSTRAINT [PK_AbpUserRoles] PRIMARY KEY ([UserId], [RoleId]),
        CONSTRAINT [FK_AbpUserRoles_AbpRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AbpRoles] ([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_AbpUserRoles_AbpUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AbpUsers] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE TABLE [AbpUserTokens] (
        [UserId] uniqueidentifier NOT NULL,
        [LoginProvider] nvarchar(64) NOT NULL,
        [Name] nvarchar(128) NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Value] nvarchar(max) NULL,
        CONSTRAINT [PK_AbpUserTokens] PRIMARY KEY ([UserId], [LoginProvider], [Name]),
        CONSTRAINT [FK_AbpUserTokens_AbpUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AbpUsers] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE UNIQUE INDEX [IX_AbpFeatureGroups_Name] ON [AbpFeatureGroups] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpFeatures_GroupName] ON [AbpFeatures] ([GroupName]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE UNIQUE INDEX [IX_AbpFeatures_Name] ON [AbpFeatures] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [IX_AbpFeatureValues_Name_ProviderName_ProviderKey] ON [AbpFeatureValues] ([Name], [ProviderName], [ProviderKey]) WHERE [ProviderName] IS NOT NULL AND [ProviderKey] IS NOT NULL');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [IX_AbpLinkUsers_SourceUserId_SourceTenantId_TargetUserId_TargetTenantId] ON [AbpLinkUsers] ([SourceUserId], [SourceTenantId], [TargetUserId], [TargetTenantId]) WHERE [SourceTenantId] IS NOT NULL AND [TargetTenantId] IS NOT NULL');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpOrganizationUnitRoles_RoleId_OrganizationUnitId] ON [AbpOrganizationUnitRoles] ([RoleId], [OrganizationUnitId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpOrganizationUnits_Code] ON [AbpOrganizationUnits] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpOrganizationUnits_ParentId] ON [AbpOrganizationUnits] ([ParentId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [IX_AbpPermissionGrants_TenantId_Name_ProviderName_ProviderKey] ON [AbpPermissionGrants] ([TenantId], [Name], [ProviderName], [ProviderKey]) WHERE [TenantId] IS NOT NULL');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE UNIQUE INDEX [IX_AbpPermissionGroups_Name] ON [AbpPermissionGroups] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpPermissions_GroupName] ON [AbpPermissions] ([GroupName]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [IX_AbpPermissions_ResourceName_Name] ON [AbpPermissions] ([ResourceName], [Name]) WHERE [ResourceName] IS NOT NULL');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [IX_AbpResourcePermissionGrants_TenantId_Name_ResourceName_ResourceKey_ProviderName_ProviderKey] ON [AbpResourcePermissionGrants] ([TenantId], [Name], [ResourceName], [ResourceKey], [ProviderName], [ProviderKey]) WHERE [TenantId] IS NOT NULL');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpRoleClaims_RoleId] ON [AbpRoleClaims] ([RoleId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpRoles_NormalizedName] ON [AbpRoles] ([NormalizedName]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpSecurityLogs_TenantId_Action] ON [AbpSecurityLogs] ([TenantId], [Action]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpSecurityLogs_TenantId_ApplicationName] ON [AbpSecurityLogs] ([TenantId], [ApplicationName]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpSecurityLogs_TenantId_Identity] ON [AbpSecurityLogs] ([TenantId], [Identity]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpSecurityLogs_TenantId_UserId] ON [AbpSecurityLogs] ([TenantId], [UserId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpSessions_Device] ON [AbpSessions] ([Device]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpSessions_SessionId] ON [AbpSessions] ([SessionId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpSessions_TenantId_UserId] ON [AbpSessions] ([TenantId], [UserId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE UNIQUE INDEX [IX_AbpSettingDefinitions_Name] ON [AbpSettingDefinitions] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [IX_AbpSettings_Name_ProviderName_ProviderKey] ON [AbpSettings] ([Name], [ProviderName], [ProviderKey]) WHERE [ProviderName] IS NOT NULL AND [ProviderKey] IS NOT NULL');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpTenants_Name] ON [AbpTenants] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpTenants_NormalizedName] ON [AbpTenants] ([NormalizedName]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpUserClaims_UserId] ON [AbpUserClaims] ([UserId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpUserLogins_LoginProvider_ProviderKey] ON [AbpUserLogins] ([LoginProvider], [ProviderKey]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpUserOrganizationUnits_UserId_OrganizationUnitId] ON [AbpUserOrganizationUnits] ([UserId], [OrganizationUnitId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpUserPasskeys_UserId] ON [AbpUserPasskeys] ([UserId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpUserRoles_RoleId_UserId] ON [AbpUserRoles] ([RoleId], [UserId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpUsers_Email] ON [AbpUsers] ([Email]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpUsers_NormalizedEmail] ON [AbpUsers] ([NormalizedEmail]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpUsers_NormalizedUserName] ON [AbpUsers] ([NormalizedUserName]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpUsers_UserName] ON [AbpUsers] ([UserName]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023359_Initial'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260412023359_Initial', N'10.0.5');
END;

COMMIT;
GO


GO

IF DB_ID(N'LTC_Movie') IS NULL
    CREATE DATABASE [LTC_Movie];
GO
USE [LTC_Movie];
GO

-- NewsAndOffers table for LTC_Administration
USE [LTC_Administration];
GO
IF OBJECT_ID(N'[NewsAndOffers]') IS NULL
BEGIN
    CREATE TABLE [NewsAndOffers] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [CinemaId] uniqueidentifier NULL,
        [Title] nvarchar(256) NOT NULL,
        [Content] nvarchar(max) NOT NULL,
        [StartDate] datetime2 NULL,
        [EndDate] datetime2 NULL,
        [IsActive] bit NOT NULL,
        [PosterUrl] nvarchar(max) NULL,
        [IsDeleted] bit NOT NULL DEFAULT CAST(0 AS bit),
        [CreatedAt] datetime2 NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_NewsAndOffers] PRIMARY KEY ([Id])
    );
END;
GO
IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023342_Initial'
)
BEGIN
    CREATE TABLE [Actors] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Name] nvarchar(max) NOT NULL,
        [Birthday] datetime2 NULL,
        [Bio] nvarchar(max) NULL,
        CONSTRAINT [PK_Actors] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023342_Initial'
)
BEGIN
    CREATE TABLE [Formats] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Name] nvarchar(max) NOT NULL,
        CONSTRAINT [PK_Formats] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023342_Initial'
)
BEGIN
    CREATE TABLE [Genres] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Name] nvarchar(max) NOT NULL,
        CONSTRAINT [PK_Genres] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023342_Initial'
)
BEGIN
    CREATE TABLE [MovieActorRoles] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [MovieActorId] uniqueidentifier NOT NULL,
        [RoleId] uniqueidentifier NOT NULL,
        [CharacterName] nvarchar(max) NULL,
        CONSTRAINT [PK_MovieActorRoles] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023342_Initial'
)
BEGIN
    CREATE TABLE [MovieActors] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [MovieId] uniqueidentifier NOT NULL,
        [ActorId] uniqueidentifier NOT NULL,
        CONSTRAINT [PK_MovieActors] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023342_Initial'
)
BEGIN
    CREATE TABLE [MovieDistributions] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [MovieId] uniqueidentifier NOT NULL,
        [LicenseStartDate] datetime2 NULL,
        [LicenseEndDate] datetime2 NULL,
        [IsExclusive] bit NOT NULL,
        [CreatedAt] datetime2 NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_MovieDistributions] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023342_Initial'
)
BEGIN
    CREATE TABLE [MovieGenres] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [MovieId] uniqueidentifier NOT NULL,
        [GenreId] uniqueidentifier NOT NULL,
        CONSTRAINT [PK_MovieGenres] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023342_Initial'
)
BEGIN
    CREATE TABLE [Movies] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [StudioId] uniqueidentifier NULL,
        [RatingId] uniqueidentifier NULL,
        [Title] nvarchar(max) NOT NULL,
        [OriginalTitle] nvarchar(max) NULL,
        [DurationMins] int NULL,
        [ReleaseDate] datetime2 NULL,
        [PremiereDate] datetime2 NULL,
        [Status] nvarchar(max) NULL,
        [Description] nvarchar(max) NULL,
        [PosterUrl] nvarchar(max) NULL,
        [TrailerUrl] nvarchar(max) NULL,
        [CreatedAt] datetime2 NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_Movies] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023342_Initial'
)
BEGIN
    CREATE TABLE [Ratings] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Code] nvarchar(max) NOT NULL,
        [Name] nvarchar(max) NOT NULL,
        [Description] nvarchar(max) NULL,
        CONSTRAINT [PK_Ratings] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023342_Initial'
)
BEGIN
    CREATE TABLE [Roles] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Name] nvarchar(max) NOT NULL,
        CONSTRAINT [PK_Roles] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023342_Initial'
)
BEGIN
    CREATE TABLE [Studios] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Name] nvarchar(max) NOT NULL,
        [Country] nvarchar(max) NULL,
        CONSTRAINT [PK_Studios] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023342_Initial'
)
BEGIN
    CREATE TABLE [MovieFormats] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [MovieId] uniqueidentifier NOT NULL,
        [FormatId] uniqueidentifier NOT NULL,
        [Language] nvarchar(max) NULL,
        [Subtitle] nvarchar(max) NULL,
        CONSTRAINT [PK_MovieFormats] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_MovieFormats_Formats_FormatId] FOREIGN KEY ([FormatId]) REFERENCES [Formats] ([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_MovieFormats_Movies_MovieId] FOREIGN KEY ([MovieId]) REFERENCES [Movies] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023342_Initial'
)
BEGIN
    CREATE INDEX [IX_MovieFormats_FormatId] ON [MovieFormats] ([FormatId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023342_Initial'
)
BEGIN
    CREATE INDEX [IX_MovieFormats_MovieId] ON [MovieFormats] ([MovieId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023342_Initial'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260412023342_Initial', N'10.0.5');
END;

COMMIT;
GO


GO

IF DB_ID(N'LTC_Customer') IS NULL
    CREATE DATABASE [LTC_Customer];
GO
USE [LTC_Customer];
GO
IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023417_Initial'
)
BEGIN
    CREATE TABLE [BookingItems] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [BookingId] uniqueidentifier NOT NULL,
        [ItemType] nvarchar(max) NULL,
        [ReferenceId] uniqueidentifier NULL,
        [VariantId] uniqueidentifier NULL,
        [Quantity] int NOT NULL,
        [UnitPrice] decimal(18,2) NOT NULL,
        [TotalPrice] decimal(18,2) NOT NULL,
        CONSTRAINT [PK_BookingItems] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023417_Initial'
)
BEGIN
    CREATE TABLE [Bookings] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [UserId] uniqueidentifier NULL,
        [ShowtimeId] uniqueidentifier NOT NULL,
        [SoldByEmployeeId] uniqueidentifier NULL,
        [BookingStatus] nvarchar(max) NULL,
        [PaymentStatus] nvarchar(max) NULL,
        [PaymentMethod] nvarchar(max) NULL,
        [DiscountAmount] decimal(18,2) NOT NULL,
        [TotalPrice] decimal(18,2) NOT NULL,
        [CreatedAt] datetime2 NULL,
        [ExpiredAt] datetime2 NULL,
        CONSTRAINT [PK_Bookings] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023417_Initial'
)
BEGIN
    CREATE TABLE [Customers] (
        [Id] uniqueidentifier NOT NULL,
        [Name] nvarchar(max) NOT NULL,
        [PhoneNumber] nvarchar(max) NULL,
        [TenantId] uniqueidentifier NULL,
        [Gender] nvarchar(max) NULL,
        [DateOfBirth] datetime2 NULL,
        [EmailAddress] nvarchar(max) NULL,
        [ProfileQRUrl] nvarchar(max) NULL,
        [Address] nvarchar(max) NULL,
        [PasswordHash] nvarchar(max) NULL,
        [RefreshToken] nvarchar(max) NULL,
        [RefreshTokenExpiry] datetime2 NULL,
        [EmailVerified] bit NOT NULL,
        [IsLocked] bit NOT NULL,
        CONSTRAINT [PK_Customers] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023417_Initial'
)
BEGIN
    CREATE TABLE [GiftCodeUsages] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [GiftCodeId] uniqueidentifier NOT NULL,
        [CustomerId] uniqueidentifier NULL,
        [BookingId] uniqueidentifier NULL,
        [DiscountAmount] decimal(18,2) NOT NULL,
        [UsedAt] datetime2 NULL,
        CONSTRAINT [PK_GiftCodeUsages] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023417_Initial'
)
BEGIN
    CREATE TABLE [MemberCards] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [CardNumber] nvarchar(max) NOT NULL,
        [CustomerId] uniqueidentifier NOT NULL,
        [MemberTierId] uniqueidentifier NULL,
        [CurrentPoints] int NOT NULL,
        [TotalSpent] decimal(18,2) NOT NULL,
        [IssuedDate] datetime2 NULL,
        [ExpiryDate] datetime2 NULL,
        [Status] nvarchar(max) NULL,
        CONSTRAINT [PK_MemberCards] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023417_Initial'
)
BEGIN
    CREATE TABLE [MemberTiers] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Name] nvarchar(max) NOT NULL,
        [MinPoints] int NOT NULL,
        [DiscountPercentage] decimal(18,2) NOT NULL,
        [PointMultiplier] decimal(18,2) NOT NULL,
        CONSTRAINT [PK_MemberTiers] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023417_Initial'
)
BEGIN
    CREATE TABLE [Notifications] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [CustomerId] uniqueidentifier NOT NULL,
        [Type] nvarchar(max) NULL,
        [Title] nvarchar(max) NULL,
        [Body] nvarchar(max) NULL,
        [Channel] nvarchar(max) NULL,
        [SentAt] datetime2 NULL,
        CONSTRAINT [PK_Notifications] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023417_Initial'
)
BEGIN
    CREATE TABLE [PointTransactions] (
        [Id] uniqueidentifier NOT NULL,
        [MemberCardId] uniqueidentifier NOT NULL,
        [Type] nvarchar(max) NULL,
        [PointNumber] int NOT NULL,
        [CreatedAt] datetime2 NULL,
        CONSTRAINT [PK_PointTransactions] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023417_Initial'
)
BEGIN
    CREATE TABLE [Tickets] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [BookingId] uniqueidentifier NOT NULL,
        [ShowtimeId] uniqueidentifier NOT NULL,
        [SeatCode] nvarchar(max) NULL,
        [SeatTypeId] uniqueidentifier NULL,
        [BookingProp] nvarchar(max) NULL,
        [TotalPrice] decimal(18,2) NOT NULL,
        [QrCode] nvarchar(max) NULL,
        [TicketStatus] nvarchar(max) NULL,
        [CreatedAt] datetime2 NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_Tickets] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023417_Initial'
)
BEGIN
    CREATE TABLE [TransactionHistories] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [CustomerId] uniqueidentifier NOT NULL,
        [BookingId] uniqueidentifier NULL,
        [Type] nvarchar(max) NULL,
        [Amount] decimal(18,2) NOT NULL,
        [Currency] nvarchar(max) NULL,
        [ReferenceId] nvarchar(max) NULL,
        [BalanceBefore] decimal(18,2) NULL,
        [BalanceAfter] decimal(18,2) NULL,
        [OccurredAt] datetime2 NULL,
        CONSTRAINT [PK_TransactionHistories] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023417_Initial'
)
BEGIN
    CREATE TABLE [UserPreferences] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [CustomerId] uniqueidentifier NOT NULL,
        [PreferredGenres] nvarchar(max) NULL,
        [PreferredLanguage] nvarchar(max) NULL,
        [PreferredSeatType] nvarchar(max) NULL,
        [NotificationsEnabled] bit NOT NULL,
        [NotificationChannels] nvarchar(max) NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_UserPreferences] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023417_Initial'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260412023417_Initial', N'10.0.4');
END;

COMMIT;
GO


GO

IF DB_ID(N'LTC_Product') IS NULL
    CREATE DATABASE [LTC_Product];
GO
USE [LTC_Product];
GO
IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023323_Initial'
)
BEGIN
    CREATE TABLE [Combos] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Name] nvarchar(256) NOT NULL,
        [Description] nvarchar(max) NOT NULL,
        [TotalPrice] decimal(18,2) NOT NULL,
        [IsActive] bit NOT NULL,
        [CreatedAt] datetime2 NULL,
        [UpdatedAt] datetime2 NULL,
        [ExtraProperties] nvarchar(max) NOT NULL,
        [ConcurrencyStamp] nvarchar(40) NOT NULL,
        [CreationTime] datetime2 NOT NULL,
        [CreatorId] uniqueidentifier NULL,
        [LastModificationTime] datetime2 NULL,
        [LastModifierId] uniqueidentifier NULL,
        [IsDeleted] bit NOT NULL DEFAULT CAST(0 AS bit),
        [DeleterId] uniqueidentifier NULL,
        [DeletionTime] datetime2 NULL,
        CONSTRAINT [PK_Combos] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023323_Initial'
)
BEGIN
    CREATE TABLE [ProductCategories] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [Name] nvarchar(256) NOT NULL,
        [Description] nvarchar(max) NOT NULL,
        [IsActive] bit NOT NULL,
        [ExtraProperties] nvarchar(max) NOT NULL,
        [ConcurrencyStamp] nvarchar(40) NOT NULL,
        [CreationTime] datetime2 NOT NULL,
        [CreatorId] uniqueidentifier NULL,
        [LastModificationTime] datetime2 NULL,
        [LastModifierId] uniqueidentifier NULL,
        [IsDeleted] bit NOT NULL DEFAULT CAST(0 AS bit),
        [DeleterId] uniqueidentifier NULL,
        [DeletionTime] datetime2 NULL,
        CONSTRAINT [PK_ProductCategories] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023323_Initial'
)
BEGIN
    CREATE TABLE [Products] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [ProductCategoryId] uniqueidentifier NOT NULL,
        [Name] nvarchar(256) NOT NULL,
        [Description] nvarchar(max) NOT NULL,
        [BasePrice] decimal(18,2) NOT NULL,
        [ImageUrl] nvarchar(max) NOT NULL,
        [IsActive] bit NOT NULL,
        [ProductType] nvarchar(max) NOT NULL,
        [CreatedAt] datetime2 NULL,
        [UpdatedAt] datetime2 NULL,
        [ExtraProperties] nvarchar(max) NOT NULL,
        [ConcurrencyStamp] nvarchar(40) NOT NULL,
        [CreationTime] datetime2 NOT NULL,
        [CreatorId] uniqueidentifier NULL,
        [LastModificationTime] datetime2 NULL,
        [LastModifierId] uniqueidentifier NULL,
        [IsDeleted] bit NOT NULL DEFAULT CAST(0 AS bit),
        [DeleterId] uniqueidentifier NULL,
        [DeletionTime] datetime2 NULL,
        CONSTRAINT [PK_Products] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_Products_ProductCategories_ProductCategoryId] FOREIGN KEY ([ProductCategoryId]) REFERENCES [ProductCategories] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023323_Initial'
)
BEGIN
    CREATE TABLE [ComboItems] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [ComboId] uniqueidentifier NOT NULL,
        [ProductId] uniqueidentifier NOT NULL,
        [Quantity] int NOT NULL,
        CONSTRAINT [PK_ComboItems] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_ComboItems_Combos_ComboId] FOREIGN KEY ([ComboId]) REFERENCES [Combos] ([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_ComboItems_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023323_Initial'
)
BEGIN
    CREATE TABLE [ProductVariants] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [ProductId] uniqueidentifier NOT NULL,
        [Name] nvarchar(256) NOT NULL,
        [AdditionalPrice] decimal(18,2) NOT NULL,
        [IsActive] bit NOT NULL,
        CONSTRAINT [PK_ProductVariants] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_ProductVariants_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023323_Initial'
)
BEGIN
    CREATE INDEX [IX_ComboItems_ComboId] ON [ComboItems] ([ComboId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023323_Initial'
)
BEGIN
    CREATE INDEX [IX_ComboItems_ProductId] ON [ComboItems] ([ProductId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023323_Initial'
)
BEGIN
    CREATE INDEX [IX_Products_ProductCategoryId] ON [Products] ([ProductCategoryId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023323_Initial'
)
BEGIN
    CREATE INDEX [IX_ProductVariants_ProductId] ON [ProductVariants] ([ProductId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023323_Initial'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260412023323_Initial', N'10.0.5');
END;

COMMIT;
GO


GO

IF DB_ID(N'LTC_Payment') IS NULL
    CREATE DATABASE [LTC_Payment];
GO
USE [LTC_Payment];
GO
IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE TABLE [AbpAuditLogExcelFiles] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [FileName] nvarchar(256) NULL,
        [CreationTime] datetime2 NOT NULL,
        [CreatorId] uniqueidentifier NULL,
        CONSTRAINT [PK_AbpAuditLogExcelFiles] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE TABLE [AbpAuditLogs] (
        [Id] uniqueidentifier NOT NULL,
        [ApplicationName] nvarchar(96) NULL,
        [UserId] uniqueidentifier NULL,
        [UserName] nvarchar(256) NULL,
        [TenantId] uniqueidentifier NULL,
        [TenantName] nvarchar(64) NULL,
        [ImpersonatorUserId] uniqueidentifier NULL,
        [ImpersonatorUserName] nvarchar(256) NULL,
        [ImpersonatorTenantId] uniqueidentifier NULL,
        [ImpersonatorTenantName] nvarchar(64) NULL,
        [ExecutionTime] datetime2 NOT NULL,
        [ExecutionDuration] int NOT NULL,
        [ClientIpAddress] nvarchar(64) NULL,
        [ClientName] nvarchar(128) NULL,
        [ClientId] nvarchar(64) NULL,
        [CorrelationId] nvarchar(64) NULL,
        [BrowserInfo] nvarchar(512) NULL,
        [HttpMethod] nvarchar(16) NULL,
        [Url] nvarchar(256) NULL,
        [Exceptions] nvarchar(max) NULL,
        [Comments] nvarchar(256) NULL,
        [HttpStatusCode] int NULL,
        [ExtraProperties] nvarchar(max) NOT NULL,
        [ConcurrencyStamp] nvarchar(40) NOT NULL,
        CONSTRAINT [PK_AbpAuditLogs] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE TABLE [PaymentAuditLogs] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [PaymentRequestId] uniqueidentifier NOT NULL,
        [EventType] nvarchar(max) NULL,
        [Direction] nvarchar(max) NULL,
        [Payload] nvarchar(max) NULL,
        [CreatedAt] datetime2 NULL,
        CONSTRAINT [PK_PaymentAuditLogs] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE TABLE [PaymentRequests] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [BookingId] uniqueidentifier NOT NULL,
        [CustomerId] uniqueidentifier NOT NULL,
        [Amount] decimal(18,2) NOT NULL,
        [Currency] nvarchar(max) NULL,
        [PaymentGateway] nvarchar(max) NULL,
        [GatewayOrderId] nvarchar(max) NULL,
        [ReturnUrl] nvarchar(max) NULL,
        [NotifyUrl] nvarchar(max) NULL,
        [ExpiredAt] datetime2 NULL,
        [CreatedAt] datetime2 NULL,
        CONSTRAINT [PK_PaymentRequests] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE TABLE [Payments] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [PaymentRequestId] uniqueidentifier NOT NULL,
        [BookingId] uniqueidentifier NOT NULL,
        [Amount] decimal(18,2) NOT NULL,
        [PaymentMethod] nvarchar(max) NULL,
        [PaymentStatus] nvarchar(max) NULL,
        [PaidTime] datetime2 NULL,
        [GatewayTransactionId] nvarchar(max) NULL,
        [GatewayResponseCode] nvarchar(max) NULL,
        [GatewayRawResponse] nvarchar(max) NULL,
        CONSTRAINT [PK_Payments] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE TABLE [Refunds] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [BookingId] uniqueidentifier NOT NULL,
        [PaymentId] uniqueidentifier NOT NULL,
        [Amount] decimal(18,2) NOT NULL,
        [Reason] nvarchar(max) NULL,
        [Status] nvarchar(max) NULL,
        [RequestedAt] datetime2 NULL,
        [ProcessedAt] datetime2 NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_Refunds] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE TABLE [AbpAuditLogActions] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [AuditLogId] uniqueidentifier NOT NULL,
        [ServiceName] nvarchar(256) NULL,
        [MethodName] nvarchar(128) NULL,
        [Parameters] nvarchar(2000) NULL,
        [ExecutionTime] datetime2 NOT NULL,
        [ExecutionDuration] int NOT NULL,
        [ExtraProperties] nvarchar(max) NULL,
        CONSTRAINT [PK_AbpAuditLogActions] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_AbpAuditLogActions_AbpAuditLogs_AuditLogId] FOREIGN KEY ([AuditLogId]) REFERENCES [AbpAuditLogs] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE TABLE [AbpEntityChanges] (
        [Id] uniqueidentifier NOT NULL,
        [AuditLogId] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [ChangeTime] datetime2 NOT NULL,
        [ChangeType] tinyint NOT NULL,
        [EntityTenantId] uniqueidentifier NULL,
        [EntityId] nvarchar(128) NULL,
        [EntityTypeFullName] nvarchar(512) NOT NULL,
        [ExtraProperties] nvarchar(max) NULL,
        CONSTRAINT [PK_AbpEntityChanges] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_AbpEntityChanges_AbpAuditLogs_AuditLogId] FOREIGN KEY ([AuditLogId]) REFERENCES [AbpAuditLogs] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE TABLE [AbpEntityPropertyChanges] (
        [Id] uniqueidentifier NOT NULL,
        [TenantId] uniqueidentifier NULL,
        [EntityChangeId] uniqueidentifier NOT NULL,
        [NewValue] nvarchar(512) NULL,
        [OriginalValue] nvarchar(512) NULL,
        [PropertyName] nvarchar(128) NOT NULL,
        [PropertyTypeFullName] nvarchar(512) NOT NULL,
        CONSTRAINT [PK_AbpEntityPropertyChanges] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_AbpEntityPropertyChanges_AbpEntityChanges_EntityChangeId] FOREIGN KEY ([EntityChangeId]) REFERENCES [AbpEntityChanges] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpAuditLogActions_AuditLogId] ON [AbpAuditLogActions] ([AuditLogId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpAuditLogActions_TenantId_ServiceName_MethodName_ExecutionTime] ON [AbpAuditLogActions] ([TenantId], [ServiceName], [MethodName], [ExecutionTime]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpAuditLogs_TenantId_ExecutionTime] ON [AbpAuditLogs] ([TenantId], [ExecutionTime]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpAuditLogs_TenantId_UserId_ExecutionTime] ON [AbpAuditLogs] ([TenantId], [UserId], [ExecutionTime]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpEntityChanges_AuditLogId] ON [AbpEntityChanges] ([AuditLogId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpEntityChanges_TenantId_EntityTypeFullName_EntityId] ON [AbpEntityChanges] ([TenantId], [EntityTypeFullName], [EntityId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    CREATE INDEX [IX_AbpEntityPropertyChanges_EntityChangeId] ON [AbpEntityPropertyChanges] ([EntityChangeId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260412023546_Initial'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260412023546_Initial', N'10.0.5');
END;

COMMIT;
GO


GO

/* =========================
   Idempotent Seed Data
   ========================= */

USE [LTC_Administration];
GO
DECLARE @now DATETIME2 = SYSUTCDATETIME();
DECLARE @defaultPasswordHash NVARCHAR(256) = N'AQAAAAIAAYagAAAAEF3agd/zWk1HYpyCY1hd9P/vIjm1Tr94T04UbIJAI28ZJRshwuziQprvPmUn9cY4qQ==';
DECLARE @adminRoleId UNIQUEIDENTIFIER;
DECLARE @adminUserId UNIQUEIDENTIFIER;
DECLARE @managerUserId UNIQUEIDENTIFIER;
DECLARE @staffUserId UNIQUEIDENTIFIER;
DECLARE @normalUserId UNIQUEIDENTIFIER;

SELECT TOP 1 @adminRoleId = [Id]
FROM [AbpRoles]
WHERE [NormalizedName] = N'ADMIN';

IF @adminRoleId IS NULL
BEGIN
    SET @adminRoleId = 'e5797ee5-f86a-d24c-9f67-3a110eecb5bd';

    INSERT INTO [AbpRoles] (
        [Id], [TenantId], [Name], [NormalizedName], [IsDefault], [IsStatic], [IsPublic],
        [EntityVersion], [CreationTime], [ExtraProperties], [ConcurrencyStamp]
    )
    VALUES (
        @adminRoleId, NULL, N'admin', N'ADMIN', 1, 1, 1,
        1, @now, N'{}', CONVERT(NVARCHAR(40), NEWID())
    );
END

SELECT TOP 1 @adminUserId = [Id]
FROM [AbpUsers]
WHERE [NormalizedUserName] = N'ADMIN';

IF @adminUserId IS NULL
BEGIN
    SET @adminUserId = '1cebad4e-76e3-54cd-bdce-3a110eecd9dc';

    INSERT INTO [AbpUsers] (
        [Id], [TenantId], [UserName], [NormalizedUserName], [Name], [Surname],
        [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [IsExternal],
        [PhoneNumberConfirmed], [IsActive], [TwoFactorEnabled], [LockoutEnabled], [AccessFailedCount],
        [ShouldChangePasswordOnNextLogin], [EntityVersion], [ExtraProperties], [ConcurrencyStamp], [CreationTime]
    )
    VALUES (
        @adminUserId, NULL, N'admin', N'ADMIN', N'System', N'Administrator',
        N'admin@abp.io', N'ADMIN@ABP.IO', 1, @defaultPasswordHash, CONVERT(NVARCHAR(256), NEWID()), 0,
        0, 1, 0, 0, 0,
        0, 1, N'{}', CONVERT(NVARCHAR(40), NEWID()), @now
    );
END

IF NOT EXISTS (SELECT 1 FROM [AbpUserRoles] WHERE [UserId] = @adminUserId AND [RoleId] = @adminRoleId)
BEGIN
    INSERT INTO [AbpUserRoles] ([UserId], [RoleId], [TenantId])
    VALUES (@adminUserId, @adminRoleId, NULL);
END

SELECT TOP 1 @managerUserId = [Id]
FROM [AbpUsers]
WHERE [NormalizedUserName] = N'MANAGER';

IF @managerUserId IS NULL
BEGIN
    SET @managerUserId = NEWID();

    INSERT INTO [AbpUsers] (
        [Id], [TenantId], [UserName], [NormalizedUserName], [Name], [Surname],
        [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [IsExternal],
        [PhoneNumberConfirmed], [IsActive], [TwoFactorEnabled], [LockoutEnabled], [AccessFailedCount],
        [ShouldChangePasswordOnNextLogin], [EntityVersion], [ExtraProperties], [ConcurrencyStamp], [CreationTime]
    )
    VALUES (
        @managerUserId, NULL, N'manager', N'MANAGER', N'System', N'Manager',
        N'manager@ltt.com', N'MANAGER@LTT.COM', 1, @defaultPasswordHash, CONVERT(NVARCHAR(256), NEWID()), 0,
        0, 1, 0, 0, 0,
        0, 1, N'{}', CONVERT(NVARCHAR(40), NEWID()), @now
    );
END

SELECT TOP 1 @staffUserId = [Id]
FROM [AbpUsers]
WHERE [NormalizedUserName] = N'STAFF';

IF @staffUserId IS NULL
BEGIN
    SET @staffUserId = NEWID();

    INSERT INTO [AbpUsers] (
        [Id], [TenantId], [UserName], [NormalizedUserName], [Name], [Surname],
        [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [IsExternal],
        [PhoneNumberConfirmed], [IsActive], [TwoFactorEnabled], [LockoutEnabled], [AccessFailedCount],
        [ShouldChangePasswordOnNextLogin], [EntityVersion], [ExtraProperties], [ConcurrencyStamp], [CreationTime]
    )
    VALUES (
        @staffUserId, NULL, N'staff', N'STAFF', N'Staff', N'Staff',
        N'staff@ltt.com', N'STAFF@LTT.COM', 1, @defaultPasswordHash, CONVERT(NVARCHAR(256), NEWID()), 0,
        0, 1, 0, 0, 0,
        0, 1, N'{}', CONVERT(NVARCHAR(40), NEWID()), @now
    );
END

SELECT TOP 1 @normalUserId = [Id]
FROM [AbpUsers]
WHERE [NormalizedUserName] = N'USER';

IF @normalUserId IS NULL
BEGIN
    SET @normalUserId = NEWID();

    INSERT INTO [AbpUsers] (
        [Id], [TenantId], [UserName], [NormalizedUserName], [Name], [Surname],
        [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [IsExternal],
        [PhoneNumberConfirmed], [IsActive], [TwoFactorEnabled], [LockoutEnabled], [AccessFailedCount],
        [ShouldChangePasswordOnNextLogin], [EntityVersion], [ExtraProperties], [ConcurrencyStamp], [CreationTime]
    )
    VALUES (
        @normalUserId, NULL, N'user', N'USER', N'Normal', N'User',
        N'user@ltt.com', N'USER@LTT.COM', 1, @defaultPasswordHash, CONVERT(NVARCHAR(256), NEWID()), 0,
        0, 1, 0, 0, 0,
        0, 1, N'{}', CONVERT(NVARCHAR(40), NEWID()), @now
    );
END
GO

USE [LTC_Movie];
GO
DECLARE @movieIdx INT = 1;
WHILE @movieIdx <= 10
BEGIN
    DECLARE @movieTitle NVARCHAR(128) = N'Sample Movie ' + CAST(@movieIdx AS NVARCHAR(10));

    IF NOT EXISTS (SELECT 1 FROM [Movies] WHERE [Title] = @movieTitle)
    BEGIN
        INSERT INTO [Movies] ([Id], [Title], [DurationMins], [ReleaseDate], [Status], [CreatedAt])
        VALUES (NEWID(), @movieTitle, 120, GETUTCDATE(), N'Released', GETUTCDATE());
    END

    SET @movieIdx = @movieIdx + 1;
END
GO

USE [LTC_Customer];
GO
DECLARE @customerIdx INT = 1;
WHILE @customerIdx <= 10
BEGIN
    DECLARE @customerEmail NVARCHAR(256) = N'customer' + CAST(@customerIdx AS NVARCHAR(10)) + N'@example.com';

    IF NOT EXISTS (SELECT 1 FROM [Customers] WHERE [EmailAddress] = @customerEmail)
    BEGIN
        INSERT INTO [Customers] ([Id], [Name], [PhoneNumber], [EmailAddress], [EmailVerified], [IsLocked], [PasswordHash])
        VALUES (
            NEWID(),
            N'Sample Customer ' + CAST(@customerIdx AS NVARCHAR(10)),
            N'09000000' + CAST(@customerIdx AS NVARCHAR(10)),
            @customerEmail,
            1,
            0,
            N'$2b$12$R9h7cIPz0gi.URNNX3kh2OPST9EWgxAJgXljgJPfbL2WqbE0EAzXm'
        );
    END

    SET @customerIdx = @customerIdx + 1;
END
GO

USE [LTC_Product];
GO
DECLARE @productNow DATETIME2 = SYSUTCDATETIME();
DECLARE @categoryId UNIQUEIDENTIFIER;
DECLARE @productId UNIQUEIDENTIFIER;
DECLARE @comboId UNIQUEIDENTIFIER;

SELECT TOP 1 @categoryId = [Id]
FROM [ProductCategories]
WHERE [Name] = N'Snack';

IF @categoryId IS NULL
BEGIN
    SET @categoryId = NEWID();

    INSERT INTO [ProductCategories] (
        [Id], [TenantId], [Name], [Description], [IsActive],
        [ExtraProperties], [ConcurrencyStamp], [CreationTime]
    )
    VALUES (
        @categoryId, NULL, N'Snack', N'Default snack category', 1,
        N'{}', CONVERT(NVARCHAR(40), NEWID()), @productNow
    );
END

SELECT TOP 1 @productId = [Id]
FROM [Products]
WHERE [Name] = N'Classic Popcorn';

IF @productId IS NULL
BEGIN
    SET @productId = NEWID();

    INSERT INTO [Products] (
        [Id], [TenantId], [ProductCategoryId], [Name], [Description], [BasePrice], [ImageUrl], [IsActive], [ProductType],
        [CreatedAt], [UpdatedAt], [ExtraProperties], [ConcurrencyStamp], [CreationTime]
    )
    VALUES (
        @productId, NULL, @categoryId, N'Classic Popcorn', N'Butter popcorn', 75000, N'https://example.com/popcorn.png', 1, N'Food',
        @productNow, @productNow, N'{}', CONVERT(NVARCHAR(40), NEWID()), @productNow
    );
END

SELECT TOP 1 @comboId = [Id]
FROM [Combos]
WHERE [Name] = N'Combo 1';

IF @comboId IS NULL
BEGIN
    SET @comboId = NEWID();

    INSERT INTO [Combos] (
        [Id], [TenantId], [Name], [Description], [TotalPrice], [IsActive], [CreatedAt], [UpdatedAt],
        [ExtraProperties], [ConcurrencyStamp], [CreationTime]
    )
    VALUES (
        @comboId, NULL, N'Combo 1', N'Popcorn combo', 99000, 1, @productNow, @productNow,
        N'{}', CONVERT(NVARCHAR(40), NEWID()), @productNow
    );
END

IF NOT EXISTS (SELECT 1 FROM [ComboItems] WHERE [ComboId] = @comboId AND [ProductId] = @productId)
BEGIN
    INSERT INTO [ComboItems] ([Id], [ComboId], [ProductId], [Quantity])
    VALUES (NEWID(), @comboId, @productId, 1);
END
GO

-- ============================================================
-- TENANT PROVISIONING
-- Registers the 'LTC' tenant in dbo.AbpTenants (Abp tables stay
-- in dbo) then creates a [LTC] schema in every service database
-- with the full business table structure.
--
-- Architecture:
--   dbo.*   → ABP framework tables + host-level data (unchanged)
--   LTC.*   → Tenant-isolated business tables for the LTC tenant
-- ============================================================

-- ============================================================
-- STEP 1: Register LTC tenant in dbo.AbpTenants (LTC_Administration)
-- ============================================================

USE [LTC_Administration];
GO

DECLARE @LtcTenantId UNIQUEIDENTIFIER = '5B44B9ED-8FCF-4689-8694-1DEE07259757';
IF NOT EXISTS (SELECT 1 FROM [dbo].[AbpTenants] WHERE [Id] = @LtcTenantId)
BEGIN
    INSERT INTO [dbo].[AbpTenants]
        ([Id],[Name],[NormalizedName],[EntityVersion],[ExtraProperties],[ConcurrencyStamp],[CreationTime],[CreatorId],[IsDeleted])
    VALUES
        (@LtcTenantId, N'LTC', N'LTC', 1, N'{}', CONVERT(nvarchar(40),NEWID()), SYSUTCDATETIME(), NULL, 0);
    PRINT 'Tenant LTC registered in dbo.AbpTenants.';
END
ELSE
    PRINT 'Tenant LTC already exists in dbo.AbpTenants.';
GO

-- ============================================================
-- STEP 2: [LTC] schema in LTC_Administration
-- ============================================================

USE [LTC_Administration];
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'LTC') EXEC('CREATE SCHEMA [LTC]');
GO

IF OBJECT_ID('[LTC].[Cinemas]','U') IS NULL CREATE TABLE [LTC].[Cinemas] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(max) NOT NULL, [City] nvarchar(max) NULL, [Ward] nvarchar(max) NULL, [Address] nvarchar(max) NULL, [ManagerUserId] uniqueidentifier NULL, [ServiceNumber] nvarchar(max) NULL, [Status] nvarchar(max) NULL, [CreatedAt] datetime2 NULL, [UpdatedAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[Screens]','U') IS NULL CREATE TABLE [LTC].[Screens] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [CinemaId] uniqueidentifier NOT NULL, [ScreenNumber] int NOT NULL, [ScreenType] nvarchar(max) NULL, [SeatLayout] nvarchar(max) NULL, [SeatCount] int NOT NULL, [Status] nvarchar(max) NULL, [CreatedAt] datetime2 NULL, [UpdatedAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[SeatTypes]','U') IS NULL CREATE TABLE [LTC].[SeatTypes] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(max) NOT NULL, [Description] nvarchar(max) NULL, [NumberOfSeat] int NOT NULL, [DisplayDirection] nvarchar(max) NULL, [PriceMultiplier] decimal(18,2) NOT NULL, [UpdatedAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[Showtimes]','U') IS NULL CREATE TABLE [LTC].[Showtimes] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [CinemaId] uniqueidentifier NOT NULL, [DistributionId] uniqueidentifier NOT NULL, [ScreenId] uniqueidentifier NOT NULL, [ShowDate] datetime2 NOT NULL, [StartTime] time NOT NULL, [EndTime] time NOT NULL, [BasePrice] decimal(18,2) NOT NULL, [Status] nvarchar(max) NULL, [CreatedAt] datetime2 NULL, [UpdatedAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[PricingRules]','U') IS NULL CREATE TABLE [LTC].[PricingRules] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [CinemaId] uniqueidentifier NOT NULL, [SeatTypeId] uniqueidentifier NULL, [RuleType] nvarchar(max) NULL, [Multiplier] decimal(18,2) NOT NULL, [StartTime] time NULL, [EndTime] time NULL, [DayOfWeek] nvarchar(max) NULL, [Priority] int NOT NULL DEFAULT(0), [ValidFrom] datetime2 NULL, [ValidUntil] datetime2 NULL, [IsActive] bit NOT NULL DEFAULT(1), [CreatedAt] datetime2 NULL, [UpdatedAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[Employees]','U') IS NULL CREATE TABLE [LTC].[Employees] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [EmployeeId] nvarchar(max) NULL, [TenantId] uniqueidentifier NULL, [UserId] uniqueidentifier NULL, [CinemaId] uniqueidentifier NULL, [Scope] nvarchar(max) NULL, [Position] nvarchar(max) NULL, [HireDate] datetime2 NULL, [Status] nvarchar(max) NULL, [ManagedByEmployeeId] uniqueidentifier NULL, [CreatedByUserId] uniqueidentifier NULL, [Name] nvarchar(max) NULL, [Code] nvarchar(max) NULL, [Email] nvarchar(max) NULL, [OtherEmail] nvarchar(max) NULL, [PhoneNumber] nvarchar(max) NULL, [OrganizationUnitId] uniqueidentifier NULL, [PositionId] uniqueidentifier NULL, [AvatarFileId] uniqueidentifier NULL, [JoinedDate] datetime2 NULL, [DateOfBirth] datetime2 NULL, [IsFirstLogin] bit NOT NULL DEFAULT(0), [CreationTime] datetime2 NOT NULL, [CreatorId] uniqueidentifier NULL, [LastModificationTime] datetime2 NULL, [LastModifierId] uniqueidentifier NULL, [IsDeleted] bit NOT NULL DEFAULT(0), [DeleterId] uniqueidentifier NULL, [DeletionTime] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[MediaFiles]','U') IS NULL CREATE TABLE [LTC].[MediaFiles] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [DisplayName] nvarchar(max) NOT NULL, [ResourceType] nvarchar(max) NOT NULL, [SecureUrl] nvarchar(max) NOT NULL, [PublicId] nvarchar(max) NOT NULL, [Type] nvarchar(max) NOT NULL, [AssetId] nvarchar(max) NOT NULL, [Format] nvarchar(max) NOT NULL, [Size] bigint NOT NULL, [TenantId] uniqueidentifier NULL, [CreationTime] datetime2 NOT NULL, [CreatorId] uniqueidentifier NULL, [LastModificationTime] datetime2 NULL, [LastModifierId] uniqueidentifier NULL, [IsDeleted] bit NOT NULL DEFAULT(0), [DeleterId] uniqueidentifier NULL, [DeletionTime] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[GiftCodes]','U') IS NULL CREATE TABLE [LTC].[GiftCodes] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Code] nvarchar(max) NOT NULL, [Description] nvarchar(max) NULL, [DiscountType] nvarchar(max) NULL, [DiscountValue] decimal(18,2) NOT NULL, [MinOrderAmount] decimal(18,2) NULL, [UsageLimit] int NULL, [UsageCount] int NOT NULL DEFAULT(0), [PerUserLimit] int NULL, [StartDate] datetime2 NULL, [EndDate] datetime2 NULL, [Status] nvarchar(max) NULL);
GO
IF OBJECT_ID('[LTC].[CinemaAmenityTypes]','U') IS NULL CREATE TABLE [LTC].[CinemaAmenityTypes] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(max) NOT NULL, [Icon] nvarchar(max) NULL);
GO
IF OBJECT_ID('[LTC].[CinemaAmenities]','U') IS NULL CREATE TABLE [LTC].[CinemaAmenities] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [CinemaId] uniqueidentifier NOT NULL, [AmenitiesTypeId] uniqueidentifier NOT NULL);
GO
IF OBJECT_ID('[LTC].[RevenueSnapshots]','U') IS NULL CREATE TABLE [LTC].[RevenueSnapshots] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [CinemaId] uniqueidentifier NOT NULL, [SnapshotDate] datetime2 NOT NULL, [Granularity] nvarchar(max) NULL, [TotalRevenue] decimal(18,2) NOT NULL, [TotalBookings] int NOT NULL, [TotalTickets] int NOT NULL, [OccupancyRate] decimal(18,2) NOT NULL, [CreatedAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[NewsAndOffers]','U') IS NULL CREATE TABLE [LTC].[NewsAndOffers] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [CinemaId] uniqueidentifier NOT NULL, [Title] nvarchar(256) NULL, [Content] nvarchar(max) NULL, [StartDate] datetime2 NULL, [EndDate] datetime2 NULL, [IsActive] bit NOT NULL DEFAULT(1), [PosterUrl] varchar(500) NULL, [IsDeleted] bit NOT NULL DEFAULT(0), [CreatedAt] datetime2 NULL, [UpdatedAt] datetime2 NULL);
GO
-- Reference tables also in Administration
IF OBJECT_ID('[LTC].[Actors]','U') IS NULL CREATE TABLE [LTC].[Actors] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(max) NOT NULL, [Birthday] datetime2 NULL, [Bio] nvarchar(max) NULL);
GO
IF OBJECT_ID('[LTC].[Formats]','U') IS NULL CREATE TABLE [LTC].[Formats] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(max) NOT NULL);
GO
IF OBJECT_ID('[LTC].[Genres]','U') IS NULL CREATE TABLE [LTC].[Genres] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(max) NOT NULL);
GO
IF OBJECT_ID('[LTC].[Studios]','U') IS NULL CREATE TABLE [LTC].[Studios] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(max) NOT NULL, [Country] nvarchar(max) NULL);
GO
IF OBJECT_ID('[LTC].[Ratings]','U') IS NULL CREATE TABLE [LTC].[Ratings] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Code] nvarchar(max) NOT NULL, [Name] nvarchar(max) NOT NULL, [Description] nvarchar(max) NULL);
GO
IF OBJECT_ID('[LTC].[Roles]','U') IS NULL CREATE TABLE [LTC].[Roles] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(max) NOT NULL);
GO
IF OBJECT_ID('[LTC].[Movies]','U') IS NULL CREATE TABLE [LTC].[Movies] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [StudioId] uniqueidentifier NULL, [RatingId] uniqueidentifier NULL, [Title] nvarchar(max) NOT NULL, [OriginalTitle] nvarchar(max) NULL, [DurationMins] int NULL, [ReleaseDate] datetime2 NULL, [PremiereDate] datetime2 NULL, [Status] nvarchar(max) NULL, [Description] nvarchar(max) NULL, [PosterUrl] nvarchar(max) NULL, [TrailerUrl] nvarchar(max) NULL, [CreatedAt] datetime2 NULL, [UpdatedAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[MovieActors]','U') IS NULL CREATE TABLE [LTC].[MovieActors] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [MovieId] uniqueidentifier NOT NULL, [ActorId] uniqueidentifier NOT NULL);
GO
IF OBJECT_ID('[LTC].[MovieActorRoles]','U') IS NULL CREATE TABLE [LTC].[MovieActorRoles] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [MovieActorId] uniqueidentifier NOT NULL, [RoleId] uniqueidentifier NOT NULL, [CharacterName] nvarchar(max) NULL);
GO
IF OBJECT_ID('[LTC].[MovieDistributions]','U') IS NULL CREATE TABLE [LTC].[MovieDistributions] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [MovieId] uniqueidentifier NOT NULL, [LicenseStartDate] datetime2 NULL, [LicenseEndDate] datetime2 NULL, [IsExclusive] bit NOT NULL DEFAULT(0), [CreatedAt] datetime2 NULL, [UpdatedAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[MovieFormats]','U') IS NULL CREATE TABLE [LTC].[MovieFormats] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [MovieId] uniqueidentifier NOT NULL, [FormatId] uniqueidentifier NOT NULL, [Language] nvarchar(max) NULL, [Subtitle] nvarchar(max) NULL);
GO
IF OBJECT_ID('[LTC].[MovieGenres]','U') IS NULL CREATE TABLE [LTC].[MovieGenres] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [MovieId] uniqueidentifier NOT NULL, [GenreId] uniqueidentifier NOT NULL);
GO
PRINT 'LTC_Administration: [LTC] schema provisioned.';
GO

-- ============================================================
-- STEP 3: [LTC] schema in LTC_Customer
-- ============================================================

USE [LTC_Customer];
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'LTC') EXEC('CREATE SCHEMA [LTC]');
GO

IF OBJECT_ID('[LTC].[Customers]','U') IS NULL CREATE TABLE [LTC].[Customers] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [UserId] uniqueidentifier NULL, [PhoneNumber] nvarchar(max) NULL, [Address] nvarchar(max) NULL, [AvatarUrl] nvarchar(max) NULL, [DateOfBirth] datetime2 NULL, [Gender] nvarchar(max) NULL, [RegisteredAt] datetime2 NULL, [UpdatedAt] datetime2 NULL, [Name] nvarchar(max) NOT NULL DEFAULT(''), [EmailAddress] nvarchar(max) NULL, [ProfileQRUrl] nvarchar(max) NULL, [PasswordHash] nvarchar(max) NULL, [RefreshToken] nvarchar(max) NULL, [RefreshTokenExpiry] datetime2 NULL, [EmailVerified] bit NOT NULL DEFAULT(0), [IsLocked] bit NOT NULL DEFAULT(0));
GO
IF OBJECT_ID('[LTC].[Bookings]','U') IS NULL CREATE TABLE [LTC].[Bookings] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [CustomerId] uniqueidentifier NOT NULL, [ShowtimeId] uniqueidentifier NOT NULL, [BookingStatus] nvarchar(max) NULL, [TotalAmount] decimal(18,2) NOT NULL, [PaidAmount] decimal(18,2) NOT NULL DEFAULT(0), [SeatCodes] nvarchar(max) NULL, [SnapshotJson] nvarchar(max) NULL, [CreatedAt] datetime2 NULL, [UpdatedAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[MemberTiers]','U') IS NULL CREATE TABLE [LTC].[MemberTiers] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(max) NOT NULL, [MinPoints] int NOT NULL, [DiscountPercentage] decimal(18,2) NOT NULL, [PointMultiplier] decimal(18,2) NOT NULL);
GO
IF OBJECT_ID('[LTC].[MemberCards]','U') IS NULL CREATE TABLE [LTC].[MemberCards] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [CardNumber] nvarchar(max) NOT NULL, [CustomerId] uniqueidentifier NOT NULL, [MemberTierId] uniqueidentifier NULL, [CurrentPoints] int NOT NULL DEFAULT(0), [TotalSpent] decimal(18,2) NOT NULL DEFAULT(0), [IssuedDate] datetime2 NULL, [ExpiryDate] datetime2 NULL, [Status] nvarchar(max) NULL);
GO
IF OBJECT_ID('[LTC].[PointTransactions]','U') IS NULL CREATE TABLE [LTC].[PointTransactions] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [MemberCardId] uniqueidentifier NOT NULL, [Type] nvarchar(max) NULL, [PointNumber] int NOT NULL, [CreatedAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[Tickets]','U') IS NULL CREATE TABLE [LTC].[Tickets] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [BookingId] uniqueidentifier NOT NULL, [ShowtimeId] uniqueidentifier NOT NULL, [SeatCode] nvarchar(max) NULL, [SeatTypeId] uniqueidentifier NULL, [BookingProp] nvarchar(max) NULL, [TotalPrice] decimal(18,2) NOT NULL, [QrCode] nvarchar(max) NULL, [TicketStatus] nvarchar(max) NULL, [CreatedAt] datetime2 NULL, [UpdatedAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[Notifications]','U') IS NULL CREATE TABLE [LTC].[Notifications] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [CustomerId] uniqueidentifier NOT NULL, [Type] nvarchar(max) NULL, [Title] nvarchar(max) NULL, [Body] nvarchar(max) NULL, [Channel] nvarchar(max) NULL, [SentAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[TransactionHistories]','U') IS NULL CREATE TABLE [LTC].[TransactionHistories] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [CustomerId] uniqueidentifier NOT NULL, [BookingId] uniqueidentifier NULL, [Type] nvarchar(max) NULL, [Amount] decimal(18,2) NOT NULL, [Currency] nvarchar(max) NULL, [ReferenceId] nvarchar(max) NULL, [BalanceBefore] decimal(18,2) NULL, [BalanceAfter] decimal(18,2) NULL, [OccurredAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[UserPreferences]','U') IS NULL CREATE TABLE [LTC].[UserPreferences] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [CustomerId] uniqueidentifier NOT NULL, [PreferredGenres] nvarchar(max) NULL, [PreferredLanguage] nvarchar(max) NULL, [PreferredSeatType] nvarchar(max) NULL, [NotificationsEnabled] bit NOT NULL DEFAULT(1), [NotificationChannels] nvarchar(max) NULL, [UpdatedAt] datetime2 NULL);
GO
PRINT 'LTC_Customer: [LTC] schema provisioned.';
GO

-- ============================================================
-- STEP 4: [LTC] schema in LTC_Movie
-- ============================================================

USE [LTC_Movie];
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'LTC') EXEC('CREATE SCHEMA [LTC]');
GO

IF OBJECT_ID('[LTC].[Actors]','U') IS NULL CREATE TABLE [LTC].[Actors] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(max) NOT NULL, [Birthday] datetime2 NULL, [Bio] nvarchar(max) NULL);
GO
IF OBJECT_ID('[LTC].[Formats]','U') IS NULL CREATE TABLE [LTC].[Formats] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(max) NOT NULL);
GO
IF OBJECT_ID('[LTC].[Genres]','U') IS NULL CREATE TABLE [LTC].[Genres] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(max) NOT NULL);
GO
IF OBJECT_ID('[LTC].[Ratings]','U') IS NULL CREATE TABLE [LTC].[Ratings] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Code] nvarchar(max) NOT NULL, [Name] nvarchar(max) NOT NULL, [Description] nvarchar(max) NULL);
GO
IF OBJECT_ID('[LTC].[Roles]','U') IS NULL CREATE TABLE [LTC].[Roles] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(max) NOT NULL);
GO
IF OBJECT_ID('[LTC].[Studios]','U') IS NULL CREATE TABLE [LTC].[Studios] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(max) NOT NULL, [Country] nvarchar(max) NULL);
GO
IF OBJECT_ID('[LTC].[Movies]','U') IS NULL CREATE TABLE [LTC].[Movies] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [StudioId] uniqueidentifier NULL, [RatingId] uniqueidentifier NULL, [Title] nvarchar(max) NOT NULL, [OriginalTitle] nvarchar(max) NULL, [DurationMins] int NULL, [ReleaseDate] datetime2 NULL, [PremiereDate] datetime2 NULL, [Status] nvarchar(max) NULL, [Description] nvarchar(max) NULL, [PosterUrl] nvarchar(max) NULL, [TrailerUrl] nvarchar(max) NULL, [CreatedAt] datetime2 NULL, [UpdatedAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[MovieActors]','U') IS NULL CREATE TABLE [LTC].[MovieActors] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [MovieId] uniqueidentifier NOT NULL, [ActorId] uniqueidentifier NOT NULL);
GO
IF OBJECT_ID('[LTC].[MovieActorRoles]','U') IS NULL CREATE TABLE [LTC].[MovieActorRoles] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [MovieActorId] uniqueidentifier NOT NULL, [RoleId] uniqueidentifier NOT NULL, [CharacterName] nvarchar(max) NULL);
GO
IF OBJECT_ID('[LTC].[MovieDistributions]','U') IS NULL CREATE TABLE [LTC].[MovieDistributions] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [MovieId] uniqueidentifier NOT NULL, [LicenseStartDate] datetime2 NULL, [LicenseEndDate] datetime2 NULL, [IsExclusive] bit NOT NULL DEFAULT(0), [CreatedAt] datetime2 NULL, [UpdatedAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[MovieFormats]','U') IS NULL CREATE TABLE [LTC].[MovieFormats] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [MovieId] uniqueidentifier NOT NULL, [FormatId] uniqueidentifier NOT NULL, [Language] nvarchar(max) NULL, [Subtitle] nvarchar(max) NULL);
GO
IF OBJECT_ID('[LTC].[MovieGenres]','U') IS NULL CREATE TABLE [LTC].[MovieGenres] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [MovieId] uniqueidentifier NOT NULL, [GenreId] uniqueidentifier NOT NULL);
GO
PRINT 'LTC_Movie: [LTC] schema provisioned.';
GO

-- ============================================================
-- STEP 5: [LTC] schema in LTC_Payment
-- ============================================================

USE [LTC_Payment];
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'LTC') EXEC('CREATE SCHEMA [LTC]');
GO

IF OBJECT_ID('[LTC].[PaymentRequests]','U') IS NULL CREATE TABLE [LTC].[PaymentRequests] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [BookingId] uniqueidentifier NOT NULL, [CustomerId] uniqueidentifier NOT NULL, [Amount] decimal(18,2) NOT NULL, [Currency] nvarchar(max) NULL, [PaymentGateway] nvarchar(max) NULL, [GatewayOrderId] nvarchar(max) NULL, [ReturnUrl] nvarchar(max) NULL, [NotifyUrl] nvarchar(max) NULL, [ExpiredAt] datetime2 NULL, [CreatedAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[Payments]','U') IS NULL CREATE TABLE [LTC].[Payments] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [PaymentRequestId] uniqueidentifier NOT NULL, [BookingId] uniqueidentifier NOT NULL, [Amount] decimal(18,2) NOT NULL, [PaymentMethod] nvarchar(max) NULL, [PaymentStatus] nvarchar(max) NULL, [PaidTime] datetime2 NULL, [GatewayTransactionId] nvarchar(max) NULL, [GatewayResponseCode] nvarchar(max) NULL, [GatewayRawResponse] nvarchar(max) NULL);
GO
IF OBJECT_ID('[LTC].[PaymentAuditLogs]','U') IS NULL CREATE TABLE [LTC].[PaymentAuditLogs] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [PaymentRequestId] uniqueidentifier NOT NULL, [EventType] nvarchar(max) NULL, [Direction] nvarchar(max) NULL, [Payload] nvarchar(max) NULL, [CreatedAt] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[Refunds]','U') IS NULL CREATE TABLE [LTC].[Refunds] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [BookingId] uniqueidentifier NOT NULL, [PaymentId] uniqueidentifier NOT NULL, [Amount] decimal(18,2) NOT NULL, [Reason] nvarchar(max) NULL, [Status] nvarchar(max) NULL, [RequestedAt] datetime2 NULL, [ProcessedAt] datetime2 NULL, [UpdatedAt] datetime2 NULL);
GO
PRINT 'LTC_Payment: [LTC] schema provisioned.';
GO

-- ============================================================
-- STEP 6: [LTC] schema in LTC_Product
-- ============================================================

USE [LTC_Product];
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'LTC') EXEC('CREATE SCHEMA [LTC]');
GO

IF OBJECT_ID('[LTC].[ProductCategories]','U') IS NULL CREATE TABLE [LTC].[ProductCategories] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(256) NOT NULL, [Description] nvarchar(max) NOT NULL DEFAULT(''), [IsActive] bit NOT NULL DEFAULT(1), [ExtraProperties] nvarchar(max) NOT NULL DEFAULT('{}'), [ConcurrencyStamp] nvarchar(40) NOT NULL DEFAULT(''), [CreationTime] datetime2 NOT NULL DEFAULT(GETUTCDATE()), [CreatorId] uniqueidentifier NULL, [LastModificationTime] datetime2 NULL, [LastModifierId] uniqueidentifier NULL, [IsDeleted] bit NOT NULL DEFAULT(0), [DeleterId] uniqueidentifier NULL, [DeletionTime] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[Products]','U') IS NULL CREATE TABLE [LTC].[Products] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [ProductCategoryId] uniqueidentifier NOT NULL, [Name] nvarchar(256) NOT NULL, [Description] nvarchar(max) NOT NULL DEFAULT(''), [BasePrice] decimal(18,2) NOT NULL, [ImageUrl] nvarchar(max) NOT NULL DEFAULT(''), [IsActive] bit NOT NULL DEFAULT(1), [ProductType] nvarchar(max) NOT NULL DEFAULT(''), [CreatedAt] datetime2 NULL, [UpdatedAt] datetime2 NULL, [ExtraProperties] nvarchar(max) NOT NULL DEFAULT('{}'), [ConcurrencyStamp] nvarchar(40) NOT NULL DEFAULT(''), [CreationTime] datetime2 NOT NULL DEFAULT(GETUTCDATE()), [CreatorId] uniqueidentifier NULL, [LastModificationTime] datetime2 NULL, [LastModifierId] uniqueidentifier NULL, [IsDeleted] bit NOT NULL DEFAULT(0), [DeleterId] uniqueidentifier NULL, [DeletionTime] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[ProductVariants]','U') IS NULL CREATE TABLE [LTC].[ProductVariants] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [ProductId] uniqueidentifier NOT NULL, [Name] nvarchar(256) NOT NULL, [AdditionalPrice] decimal(18,2) NOT NULL DEFAULT(0), [IsActive] bit NOT NULL DEFAULT(1));
GO
IF OBJECT_ID('[LTC].[Combos]','U') IS NULL CREATE TABLE [LTC].[Combos] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [Name] nvarchar(256) NOT NULL, [Description] nvarchar(max) NOT NULL DEFAULT(''), [TotalPrice] decimal(18,2) NOT NULL, [IsActive] bit NOT NULL DEFAULT(1), [CreatedAt] datetime2 NULL, [UpdatedAt] datetime2 NULL, [ExtraProperties] nvarchar(max) NOT NULL DEFAULT('{}'), [ConcurrencyStamp] nvarchar(40) NOT NULL DEFAULT(''), [CreationTime] datetime2 NOT NULL DEFAULT(GETUTCDATE()), [CreatorId] uniqueidentifier NULL, [LastModificationTime] datetime2 NULL, [LastModifierId] uniqueidentifier NULL, [IsDeleted] bit NOT NULL DEFAULT(0), [DeleterId] uniqueidentifier NULL, [DeletionTime] datetime2 NULL);
GO
IF OBJECT_ID('[LTC].[ComboItems]','U') IS NULL CREATE TABLE [LTC].[ComboItems] ([Id] uniqueidentifier NOT NULL PRIMARY KEY, [TenantId] uniqueidentifier NULL, [ComboId] uniqueidentifier NOT NULL, [ProductId] uniqueidentifier NOT NULL, [Quantity] int NOT NULL DEFAULT(1));
GO

-- Seed default product data for LTC schema
DECLARE @pNow DATETIME2 = SYSUTCDATETIME();
DECLARE @pCatId UNIQUEIDENTIFIER;
DECLARE @pProdId UNIQUEIDENTIFIER;
DECLARE @pComboId UNIQUEIDENTIFIER;

SELECT TOP 1 @pCatId = [Id] FROM [LTC].[ProductCategories] WHERE [Name] = N'Snack';
IF @pCatId IS NULL
BEGIN
    SET @pCatId = NEWID();
    INSERT INTO [LTC].[ProductCategories]([Id],[TenantId],[Name],[Description],[IsActive],[ExtraProperties],[ConcurrencyStamp],[CreationTime])
    VALUES(@pCatId, NULL, N'Snack', N'Default snack category', 1, N'{}', CONVERT(nvarchar(40),NEWID()), @pNow);
END

SELECT TOP 1 @pProdId = [Id] FROM [LTC].[Products] WHERE [Name] = N'Classic Popcorn';
IF @pProdId IS NULL
BEGIN
    SET @pProdId = NEWID();
    INSERT INTO [LTC].[Products]([Id],[TenantId],[ProductCategoryId],[Name],[Description],[BasePrice],[ImageUrl],[IsActive],[ProductType],[CreatedAt],[UpdatedAt],[ExtraProperties],[ConcurrencyStamp],[CreationTime])
    VALUES(@pProdId, NULL, @pCatId, N'Classic Popcorn', N'Butter popcorn', 75000, N'https://example.com/popcorn.png', 1, N'Food', @pNow, @pNow, N'{}', CONVERT(nvarchar(40),NEWID()), @pNow);
END

SELECT TOP 1 @pComboId = [Id] FROM [LTC].[Combos] WHERE [Name] = N'Combo 1';
IF @pComboId IS NULL
BEGIN
    SET @pComboId = NEWID();
    INSERT INTO [LTC].[Combos]([Id],[TenantId],[Name],[Description],[TotalPrice],[IsActive],[CreatedAt],[UpdatedAt],[ExtraProperties],[ConcurrencyStamp],[CreationTime])
    VALUES(@pComboId, NULL, N'Combo 1', N'Popcorn combo', 99000, 1, @pNow, @pNow, N'{}', CONVERT(nvarchar(40),NEWID()), @pNow);
END

IF NOT EXISTS (SELECT 1 FROM [LTC].[ComboItems] WHERE [ComboId] = @pComboId AND [ProductId] = @pProdId)
    INSERT INTO [LTC].[ComboItems]([Id],[ComboId],[ProductId],[Quantity]) VALUES(NEWID(), @pComboId, @pProdId, 1);

PRINT 'LTC_Product: [LTC] schema provisioned with seed data.';
GO

PRINT '=== Tenant LTC fully provisioned across all 5 databases ===';
GO
