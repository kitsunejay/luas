-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2

    -- Load and initialize the include file.
    include('Mote-Include.lua')

    -- auto-inventory swaps
    include('organizer-lib')
    
end


-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()

    include('Mote-TreasureHunter')

    state.Buff.Hasso = buffactive.Hasso or false
    state.Buff.Seigan = buffactive.Seigan or false
    state.Buff.Sekkanoki = buffactive.Sekkanoki or false
    state.Buff.Sengikori = buffactive.Sengikori or false
    state.Buff['Meikyo Shisui'] = buffactive['Meikyo Shisui'] or false

    --update_offense_mode()    
    determine_haste_group()
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.
function user_setup()
    state.OffenseMode:options('Normal', 'Acc')
    state.HybridMode:options('Normal', 'DT', 'Reraise')
    state.WeaponskillMode:options('Normal', 'Acc', 'Mod')
    state.PhysicalDefenseMode:options('PDT', 'Reraise')
    state.IdleMode:options('Normal', 'DT')
    
	-- Ambuscade Capes
    gear.smertrios_wsd 	={	name="Smertrios's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}} 
    gear.smertrios_tp   ={  name="Smertrios's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10','Phys. dmg. taken-10%',}}

    -- Additional local binds
    send_command('bind ^` input /ja "Hasso" <me>')
    send_command('bind !` input /ja "Seigan" <me>')
    send_command('bind ^= gs c cycle treasuremode')

    select_default_macro_book()
end


-- Called when this job file is unloaded (eg: job change)
function user_unload()
    send_command('unbind ^`')
    send_command('unbind !-')
    send_command('unbind ^=')

end


-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------
    -- Organizer items

    organizer_items = {
        sushi="Sublime Sushi",
        shihei="Shihei",
        remedy="Remedy"
    }

    sets.TreasureHunter = {
        head="White Rarab Cap +1",
        waist="Chaac Belt", 
    }
    
    -- Precast Sets
    -- Precast sets to enhance JAs
    sets.precast.JA.Meditate = {head="Wakido Kabuto +1",hands="Sakonji Kote +1",back=gear.smertrios_wsd}
    sets.precast.JA['Warding Circle'] = {head="Wakido Kabuto +1"}
    sets.precast.JA['Blade Bash'] = {hands="Sakonji Kote +1"}
    sets.precast.JA['Meikyo Shisui'] = {hands="Sakonji Sune-ate"}

       
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {ammo="Knobkierrie",
        head=gear.valorous_head_wsd,neck="Fotia Gorget",ear1="Ishvara Earring",ear2="Moonshade Earring",
        body="Sakonji Domaru +3",hands=gear.valorous_hands_wsd,ring1="Niqmaddu Ring",ring2="Apate Ring",
        back=gear.smertrios_wsd,waist="Fotia Belt",legs="Wakido Haidate +3",feet=gear.valorous_feet_wsd}

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.

    -- Sets to return to when not performing an action.    

    -- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)
    sets.idle.Town = {ammo="Ginsen",
        head="Flamma Zucchetto +2",neck="Moonbeam Nodowa",ear1="Cessance Earring",ear2="Telos Earring",
        body="Sakonji Domaru +3",hands="Wakido Kote +3",ring1="Niqmaddu Ring",ring2="Warp Ring",
        back=gear.smertrios_wsd,waist="Flume Belt",legs="Wakido Haidate +3",feet="Danzo Sune-Ate"}
    
    sets.idle.Field = {ammo="Staunch Tathlum",
        head="Kendatsuba Jinpachi",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Wakido Domaru +3",hands="Wakido Kote +3",ring1="Defending Ring",ring2="Vocane Ring",
        back=gear.smertrios_tp,waist="Flume Belt",legs="Kendatsuba Hakama",feet="Danzo Sune-Ate"}

    sets.idle.Weak = {ammo="Staunch Tathlum",
        head="Kendatsuba Jinpachi",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Wakido Domaru +3",hands="Wakido Kote +3",ring1="Defending Ring",ring2="Vocane Ring",
        back=gear.smertrios_tp,waist="Flume Belt",legs="Kendatsuba Hakama",feet="Flamma Gambieras +2"}
    
    -- Defense sets
    sets.defense.PDT = {ammo="Staunch Tathlum",
        head="Flamma Zucchetto +2",neck="Loricate Torque +1",ear1="Cessance Earring",ear2="Brutal Earring",
        body="Kasuga Domaru +1",hands="Kasuga Domaru +1",ring1="Defending Ring",ring2="Vocane Ring",
        back="Shadow Mantle",waist="Flume Belt",legs="Kendatsuba Hakama",feet="Flamma Gambieras +2"}

    sets.defense.MDT = {ammo="Staunch Tathlum",
        head="Flamma Zucchetto +2",neck="Loricate Torque +1",ear1="Cessance Earring",ear2="Brutal Earring",
        body="Kasuga Domaru +1",hands="Kasuga Domaru +1",ring1="Defending Ring",ring2="Shadow Ring",
        back="Engulfer Cape",waist="Flume Belt",legs="Kendatsuba Hakama",feet="Flamma Gambieras +2"}

    sets.Kiting = {feet="Danzo Sune-ate"}

    sets.Reraise = {head="Twilight Helm",body="Twilight Mail"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion
    
    -- Normal melee group
    -- Delay 450 GK, 25 Save TP => 65 Store TP for a 5-hit (25 Store TP in gear)
    sets.engaged = {ammo="Ginsen",
        head="Flamma Zucchetto +2",neck="Moonbeam Nodowa",ear1="Cessance Earring",ear2="Telos Earring",
        body="Kasuga Domaru +1",hands="Wakido Kote +3",ring1="Niqmaddu Ring",ring2="Flamma Ring",
        back="Takaha Mantle",waist="Ioskeha Belt",legs="Ryuo Hakama",feet="Ryuo Sune-ate +1"}
    sets.engaged.Acc = {ammo="Ginsen",
        head="Flamma Zucchetto +2",neck="Moonbeam Nodowa",ear1="Cessance Earring",ear2="Telos Earring",
        body=gear.valorous_body_tp,hands="Wakido Kote +3",ring1="Niqmaddu Ring",ring2="Flamma Ring",
        back="Takaha Mantle",waist="Ioskeha Belt",legs="Ryuo Hakama",feet="Flamma Gambieras +2"}
    sets.engaged.DT = {ammo="Ginsen",
        head="Kendatsuba Jinpachi",neck="Moonbeam Nodowa",ear1="Cessance Earring",ear2="Telos Earring",
        body="Wakido Domaru +3",hands="Wakido Kote +3",ring1="Vocane Ring",ring2="Defending Ring",
        back="Takaha Mantle",waist="Ioskeha Belt",legs="Kendatsuba Hakama",feet="Ryuo Sune-ate +1"}
    sets.engaged.Acc.DT = {ammo="Ginsen",
        head="Kendatsuba Jinpachi",neck="Moonbeam Nodowa",ear1="Cessance Earring",ear2="Telos Earring",
        body="Wakido Domaru +3",hands="Wakido Kote +3",ring1="Vocane Ring",ring2="Defending Ring",
        back=gear.smertrios_tp,waist="Ioskeha Belt",legs="Kendatsuba Hakama",feet="Flamma Gambieras +2"}

    sets.buff.Sekkanoki = {hands="Kasuga Kote"}
    sets.buff.Sengikori = {feet="Unkai Sune-ate +2"}
    sets.buff['Meikyo Shisui'] = {feet="Sakonji Sune-ate"}
end


-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic target handling to be done.
function job_pretarget(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        -- Change any GK weaponskills to polearm weaponskill if we're using a polearm.
        if player.equipment.main=='Quint Spear' or player.equipment.main=='Quint Spear' then
            if spell.english:startswith("Tachi:") then
                send_command('@input /ws "Penta Thrust" '..spell.target.raw)
                eventArgs.cancel = true
            end
        end
    end
end

-- Run after the default precast() is done.
-- eventArgs is the same one used in job_precast, in case information needs to be persisted.
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type:lower() == 'weaponskill' then
        if state.Buff.Sekkanoki then
            equip(sets.buff.Sekkanoki)
        end
        if state.Buff.Sengikori then
            equip(sets.buff.Sengikori)
        end
        if state.Buff['Meikyo Shisui'] then
            equip(sets.buff['Meikyo Shisui'])
        end
    end
end


-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Effectively lock these items in place.
    if state.HybridMode.value == 'Reraise' or
        (state.DefenseMode.value == 'Physical' and state.PhysicalDefenseMode.value == 'Reraise') then
        equip(sets.Reraise)
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    --update_offense_mode()
    determine_haste_group()
end

-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)

end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

function update_offense_mode()
    if areas.Adoulin:contains(world.area) and buffactive.ionis then
        state.CombatForm:set('Adoulin')
    else
        state.CombatForm:reset()
    end
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'WAR' then
        set_macro_page(1, 11)
    elseif player.sub_job == 'DNC' then
        set_macro_page(2, 11)
    elseif player.sub_job == 'THF' then
        set_macro_page(3, 11)
    elseif player.sub_job == 'NIN' then
        set_macro_page(4, 11)
    else
        set_macro_page(1, 11)
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------
