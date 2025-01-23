SMODS.Atlas {
  key = 'inkblot',
  path = 'inkblot.png',
  px = 71,
  py = 95
}

local mod = SMODS.current_mod
local InkConfig = mod.config

local create_nodes = function()
  local nodes_final = {}
  local options = {}
  local pages = 1
  local valid_ids = {inkblot = 'inkblot'}

  local opt = {
    n = G.UIT.R,
    nodes = {
      create_toggle({
        label = 'Copy Vanilla Jokers',
        ref_table = InkConfig,
        ref_value = 'inkvanilla',
      }),
    }
  }
  
  table.insert(options, opt)
  
  for _, mod in ipairs(SMODS.mod_list) do
    if mod.id and not valid_ids[mod.id] then
      valid_ids[mod.id] = mod.id

      local opt = {
        n = G.UIT.R,
        nodes = {
          create_toggle({
            label = 'Copy from '..mod.id,
            ref_table = InkConfig,
            ref_value = mod.id,
          }),
        }
      }

      table.insert(options, opt)
    end
  end

  for i=1, #SMODS.mod_list do
    if i % 8 == 0 then
      pages = pages + 1
    end
  end

  local start_index = (InkConfig.inkoptions - 1) * 8 + 1
  local end_index = start_index + 7

  for i = start_index, end_index do
    table.insert(nodes_final, options[i])
  end

  local pg = {}
  local add = 0
  for i=1, pages do
    add = add + 1
    table.insert(pg, add)
  end

  local opt = {
    n = G.UIT.R,
    nodes = {
      create_option_cycle({options = pg, opt_callback = 'ink_cycle_update', ref_table = InkConfig, ref_value = 'inkoptions', current_option = InkConfig.inkoptions})
    }
  }
  table.insert(nodes_final, opt)

  return nodes_final
end

SMODS.current_mod.config_tab = function()
  return {
    n = G.UIT.ROOT,
    config = {
      align = "cm",
      padding = 0.05,
      colour = G.C.CLEAR,
    },
    nodes = create_nodes()
  }
end

local refresh_config_tab = function()
  G.FUNCS.openModUI_inkblot()
end

G.FUNCS.ink_cycle_update = function(args)
  args = args or {}
  if args.cycle_config and args.cycle_config.current_option then
    InkConfig.inkoptions = args.cycle_config.current_option
    refresh_config_tab()
  end
end

SMODS.Challenge {
  key = 'inkblot_challenge',
  loc_txt = {
    name = 'The Inkblot Spread'
  },
  jokers = {
    {
      id = 'j_Inkblot_inkblot_joker', eternal = true, edition = 'negative'
    },
    {
      id = 'j_Inkblot_inkblot_joker', eternal = true, edition = 'negative'
    },
    {
      id = 'j_Inkblot_inkblot_joker', eternal = true, edition = 'foil'
    },
    {
      id = 'j_Inkblot_inkblot_joker', eternal = true, edition = 'holo'
    },
    {
      id = 'j_Inkblot_inkblot_joker', eternal = true, edition = 'polychrome'
    },
  },
}

--portal to hell
SMODS.Joker {
  key = 'inkblot_joker',
  loc_txt = {
    name = 'Inkblot',
    text = {
      "Mimics a random {C:attention}Joker",
      "every round",
      "{C:inactive}Currently #1#"
    }
  },
  rarity = 1,
  atlas = 'inkblot',
  pos = { x = 0, y = 0 },
  cost = 3,
  perishable_compat = false,
  discovered = false,
  set_ability = function(self, card, initial, delay_sprites)
    if card.plan_set_ability_2 and not card.from_context then
      if not card.ability.extra then
        card.ability.extra = card.ability.plan_extra
      end
      card.plan_set_ability_2(self, card, initial, delay_sprites)
    elseif G.jokers and not G.SETTINGS.paused then
      local function deepcopy(tbl)
        local copy = {}
        for k, v in pairs(tbl) do
          if type(v) == "table" then
            copy[k] = deepcopy(v)
          else
            copy[k] = v
          end
        end
        return copy
      end
      
      local options = {}

      for k, v in pairs(G.P_CENTERS) do
        if v.key ~= 'j_Inkblot_inkblot_joker' and v.set == 'Joker' and v.unlocked and v.name ~= 'Shortcut' and v.name ~= 'Four Fingers'
        and (v.mod and InkConfig[v.mod.id]) or (not v.mod and InkConfig['inkvanilla']) then
          options[k] = v
        end
      end

      local chosen_key = pseudorandom_element(options, pseudoseed('inkblot_joker'))
      if chosen_key then

        for k, v in pairs(card) do
          if k == 'plan_calc_2' or k == 'plan_loc_vars_2' or k == 'plan_set_ability_2' or k == 'calc_dollar_bonus' then
            card[k] = nil
          end
        end

        local et = false
        local rent = false
        local perish = false
        if card.ability and card.ability.eternal then
          et = true
        end
        if card.ability and card.ability.perishable then
          perish = true
        end
        if card.ability and card.ability.rental then
          rent = true
        end


        card.added_to_deck = false
        card:remove_from_deck()
        card.added_to_deck = true
        
        local car = SMODS.create_card({set = 'Joker', key = chosen_key.key, no_edition = true})

        card.ability = nil
        card.ability = deepcopy(car.ability)

        if car.ability.extra and type(car.ability.extra) ~= 'table' then
          card.ability.plan_extra = car.ability.extra
        elseif car.ability.extra then
          card.ability.plan_extra = deepcopy(car.ability.extra)
        end

        card.ability.mim_key = chosen_key.key
        G.jokers:remove_card(car)
        car:remove()
        car = nil

        if G.P_CENTERS[chosen_key.key].calculate then
          card.plan_calc_2 = deepcopy(G.P_CENTERS[chosen_key.key]).calculate
        end

        if G.P_CENTERS[chosen_key.key].loc_vars then
          card.plan_loc_vars_2 = deepcopy(G.P_CENTERS[chosen_key.key]).loc_vars
        end

        if G.P_CENTERS[chosen_key.key].set_ability then
          card.plan_set_ability_2 = deepcopy(G.P_CENTERS[chosen_key.key]).set_ability
        end

        if G.P_CENTERS[chosen_key.key].calc_dollar_bonus then
          card.calc_dollar_bonus = deepcopy(G.P_CENTERS[chosen_key.key]).calc_dollar_bonus
        end

        if G.P_CENTERS[chosen_key.key].blueprint_compat then
          card.blueprint_compat = deepcopy(G.P_CENTERS[chosen_key.key]).blueprint_compat
        end

        local function value_exists(tbl, value)
          for _, v in pairs(tbl) do
              if v == value then
                  return true
              end
          end
          return false
        end
      
        for k, v in pairs(deepcopy(G.P_CENTERS[chosen_key.key])) do
          if not value_exists(card, v) then
            table.insert(card, v)
          end
        end

        if card.ability.name == "Invisible Joker" then 
          card.ability.invis_rounds = 0
        end
        if card.ability.name == 'To Do List' then
          local _poker_hands = {}
          for k, v in pairs(G.GAME.hands) do
              if v.visible then _poker_hands[#_poker_hands+1] = k end
          end
          local old_hand = card.ability.to_do_poker_hand
          card.ability.to_do_poker_hand = nil
  
          while not card.ability.to_do_poker_hand do
            card.ability.to_do_poker_hand = pseudorandom_element(_poker_hands, pseudoseed((card.area and card.area.config.type == 'title') and 'false_to_do' or 'to_do'))
              if card.ability.to_do_poker_hand == old_hand then card.ability.to_do_poker_hand = nil end
          end
        end
        if card.ability.name == 'Caino' then 
          card.ability.caino_xmult = 1
        end
        if card.ability.name == 'Yorick' then 
          card.ability.yorick_discards = card.ability.extra.discards
        end
        if card.ability.name == 'Loyalty Card' then 
          card.ability.burnt_hand = 0
          card.ability.loyalty_remaining = card.ability.extra.every
        end
  
        card.base_cost = card.config.center.cost or 1
  
        card.ability.hands_played_at_create = G.GAME and G.GAME.hands_played or 0

        if et then
          card:set_eternal(true)
        end

        if rent then
          card:set_rental(true)
        end

        if perish then
          card:set_perishable(true)
        end


      end
    end
	end,
  load = function(self, card, card_table, other_card)
    local function deepcopy(tbl)
      local copy = {}
      for k, v in pairs(tbl) do
        if type(v) == "table" then
          copy[k] = deepcopy(v)
        else
          copy[k] = v
        end
      end
      return copy
    end

    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
    func = function()
      if card.ability.mim_key then
      if G.P_CENTERS[card.ability.mim_key].calculate then
        card.plan_calc_2 = deepcopy(G.P_CENTERS[card.ability.mim_key]).calculate
      end

      if G.P_CENTERS[card.ability.mim_key].loc_vars then
        card.plan_loc_vars_2 = deepcopy(G.P_CENTERS[card.ability.mim_key]).loc_vars
      end

      if G.P_CENTERS[card.ability.mim_key].set_ability then
        card.plan_set_ability_2 = deepcopy(G.P_CENTERS[card.ability.mim_key]).set_ability
      end

      if G.P_CENTERS[card.ability.mim_key].calc_dollar_bonus then
        card.calc_dollar_bonus = deepcopy(G.P_CENTERS[card.ability.mim_key]).calc_dollar_bonus
      end

      if G.P_CENTERS[card.ability.mim_key].blueprint_compat then
        card.blueprint_compat = deepcopy(G.P_CENTERS[card.ability.mim_key]).blueprint_compat
      end
        card.ability.extra = card.ability.plan_extra
    end
    return true end}))
  end,
  loc_vars = function(self, info_queue, card)
    if card.ability.mim_key then
      if card.config.center.mod and card.plan_loc_vars_2 and type(card.plan_loc_vars_2) == 'function' and type(card.ability.extra) == 'table' then
        local check = card:plan_loc_vars_2(info_queue, card)
        if check and check.vars then
          specific = check.vars
        end
        info_queue[#info_queue+1] = {type = 'descriptions', set = 'Joker', key = card.ability.mim_key, specific_vars = specific or {}}
      else
        info_queue[#info_queue+1] = {type = 'descriptions', set = 'Joker', key = card.ability.mim_key, specific_vars = card.plantain_info or {}}
      end
      return { vars = {localize{type = 'name_text', set = 'Joker', key = card.ability.mim_key}} }
    else
      return { vars = {"none"}}
    end
  end,
  calculate = function(self, card, context)
    if context.pl_cash_out and not card.getting_sliced and not context.repetition and not context.individual and not context.blueprint then
      card.from_context = true
      card:set_ability(self, card, nil, nil)
      if card.plan_set_ability_2 then
        card.plan_set_ability_2(self, card, nil, nil)
      end
      card.from_context = false
      return card_eval_status_text(card, 'jokers', nil, nil, nil, {message = 'Updated!', colour = G.C.MONEY})
    end
    if card.plan_calc_2 then
      local mim_calc = card.plan_calc_2(self, card, context)
      return mim_calc
    end
  end
}