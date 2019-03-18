data:extend(
{
    {
        type="bool-setting",
        name = "timetools-always-day",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "int-setting",
        name = "timetools-maximum-speed",
        setting_type = "runtime-global",
        default_value = 64,
        allowed_values = {2,4,8,16,32,64,128}
    },
    {
        type = "int-setting",
        name = "timetools-clock-update-interval",
        setting_type = "runtime-global",
        default_value = 25,
        allowed_values = {5,10,15,25,50,100}
    },
    {
        type = "int-setting",
        name = "timetools-combinator-interval",
        setting_type = "runtime-global",
        default_value = 10,
        allowed_values = {5,10,15,25,50,100}
    }
}
)
