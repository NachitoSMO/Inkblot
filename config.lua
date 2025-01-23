local create_config = function()
    local nodes = {}
    local valid_ids = {inkblot = true}
    nodes['inkvanilla'] = true
    nodes['inkoptions'] = 1
    for _, mod in ipairs(SMODS.mod_list) do
        if mod.id and valid_ids[mod.id] == nil then
            valid_ids[mod.id] = true
            nodes[mod.id] = true
        end
    end
    return nodes
end

return create_config()