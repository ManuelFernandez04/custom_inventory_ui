Config = {}
Config.Locale = 'en'
Config.IncludeCash = false -- Include cash in inventory?
Config.IncludeWeapons = true -- Include weapons in inventory?
Config.IncludeAccounts = true -- Include accounts (bank, black money, ...)?
Config.ExcludeAccountsList = {"bank"} -- List of accounts names to exclude from inventory
Config.OpenControl = 289 -- Key for opening inventory. Edit html/js/config.js to change key for closing it.

-- List of item names that will close ui when used
Config.CloseUiItems = {"headbag", "fishingrod", "tunerlaptop", "binoculars", "gps", "joint", "cigarette", "cigar", "fixkit", "rollingpaper", "cocaine", "meth"}

Config.ShopBlipID = 52
Config.LiquorBlipID = 93
Config.YouToolBlipID = 402
Config.MusiMundoBlipID = 78
Config.PrisonShopBlipID = 52
Config.WeedStoreBlipID = 140
Config.WeaponShopBlipID = 110

Config.ShopLength = 14
Config.LiquorLength = 10
Config.YouToolLength = 2
Config.PrisonShopLength = 2

Config.Colormusimundo = 6
Config.Color = 2
Config.WeaponColor = 1

Config.WeaponLiscence = {x = 12.47, y = -1105.5, z = 29.8}
Config.LicensePrice = 75000

Config.Shops = {
    RegularShop = {
        Locations = {
			{x = 373.875,   y = 325.896,  z = 102.566},
			{x = 2557.458,  y = 382.282,  z = 107.622},
			{x = -3038.939, y = 585.954,  z = 6.908},
			{x = -3241.927, y = 1001.462, z = 11.830},
			{x = 547.431,   y = 2671.710, z = 41.156},
			{x = 1961.464,  y = 3740.672, z = 31.343},
			{x = 2678.916,  y = 3280.671, z = 54.241},
            {x = 1729.216,  y = 6414.131, z = 34.037},
            {x = -48.519,   y = -1757.514, z = 28.421},
			{x = 1163.373,  y = -323.801,  z = 68.205},
			{x = -707.501,  y = -914.260,  z = 18.215},
			{x = -1820.523, y = 792.518,   z = 137.118},
            {x = 1698.388,  y = 4924.404,  z = 41.063},
            {x = 25.723,   y = -1346.966, z = 28.497}, 
            {x = 262.3,   y = -773.26, z = 29.90}, 
        },
        Items = {
            {name = 'bread'},
            {name = 'water'},
            {name = 'cigarette'},
            {name = 'sandwich'},
            {name = 'chips'},
            {name = 'clip'},
            {name = 'cocacola'},
            {name = 'energy'},
        }
    },

    RobsLiquor = {
		Locations = {
			{x = -1393.409, y = -606.624,  z = 29.319},
            {x = -560.21, y = 287.05,  z = 81.2},
        },
        Items = {
            {name = 'beer'},
            {name = 'wine'},
            {name = 'vodka'},
            {name = 'tequila'},
            {name = 'whisky'},
            {name = 'grand_cru'}
        }
	},

    MusiMundo = {
		Locations = {
			{x = -656.51, y = -857.72,  z = 23.5},
        },
        Items = {
            {name = 'phone'}
        }
	},

    YouTool = {
        Locations = {
        },
        Items = {
        }
    },

    PrisonShop = {
        Locations = {
            {x = 1728.41, y = 2584.31, z = 45.84},
        },
        Items = {
            {name = 'bread'},
            {name = 'water'},
            {name = 'cigarette'},
            {name = 'sandwich'},
            {name = 'chips'}
        }
    },



    WeaponShop = {
        Locations = {
            { x = 22.09, y = -1107.28, z = 28.80 },
            { x = -330.24, y = 6083.88, z = 30.45 },
        },
        Weapons = {
            {name = "WEAPON_KNIFE", ammo = 1},
            {name = "WEAPON_BAT", ammo = 1},
            {name = "WEAPON_PISTOL", ammo = 45},
            {name = "WEAPON_SNSPISTOL", ammo = 45}
        },
        Ammo = {
        },
        Items = {
        }
    },
}