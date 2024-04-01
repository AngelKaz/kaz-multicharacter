Config = {
    AdminRank = "Admin", -- Kan skifte char ingame
    CamCoords = { x = 99.61, y = -1130.18, z = 218.52, h = 54.87 }, 

    CharData = {
        Chars = 4, -- Max er 5 lige nu, min 1.
    },

    UserTables = { -- Kolonner personens data skal fjernes fra når de sletter karakteren
        {table = "vrp_users", id = "id"},
        {table = "vrp_user_business", id = "user_id"},
        {table = "vrp_user_data", id = "user_id"},
        {table = "vrp_user_homes", id = "user_id"},
        {table = "vrp_user_identities", id = "user_id"},
        {table = "vrp_user_ids", id = "user_id"},
        {table = "vrp_user_moneys", id = "user_id"},
        {table = "vrp_user_vehicles", id = "user_id"},
    },

    Webhooks = {
        ["Joining"] = "",
        ["Create-Char"] = "",
        ["Delete-Char"] = "",
    },

    licensekey = "12345" -- Sæt din licensekey ind her, ellers vil scriptet ikke virke :)
}