return {
	-- qb-metaldetecting items
	['metaldetector'] = {
		label = 'Metal Detector',
		weight = 2500,
		stack = true,
		close = true,
		description = 'Maybe it can find things',
		client = {
			image = 'metaldetector.png',
			event = 'qb-metaldetecting:togglehand'
		}
	},

	['metalscrap'] = {
		label = 'Metal Scrap',
		weight = 100,
		stack = true,
		close = true,
		description = 'You can probably make something nice out of this',
		client = {
			image = 'metalscrap.png'
		}
	},


	['orologiostellare'] = {
		label = 'Orologio Stellare',
		weight = 100,
		stack = true,
		close = true,
		description = 'Un orologio magico che permette di resuscitare',
		client = {
			image = 'orologiostellare.png'
		}
	},

	['fiala_ricordi_vuota'] = {
		label = 'Fiala Ricordi Vuota',
		weight = 100,
		stack = true,
		close = true,
		description = 'Una fiala vuota per raccogliere ricordi',
		client = {
			image = 'fiala_ricordi.png'
		}
	},

	-- Runa System items
	['galeoni'] = {
		label = 'Galeoni',
		weight = 0,
		stack = true,
		close = true,
		description = 'Valuta speciale del sistema runa',
		client = {
			image = 'galeoni.png'
		}
	},

	['runa_hp'] = {
		label = 'Runa HP',
		weight = 100,
		stack = true,
		close = true,
		description = 'Aumenta la salute massima',
		client = {
			image = 'runa_hp.png'
		}
	},

	['runa_hp_1'] = {
		label = 'Runa HP +1',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa HP migliorata che aumenta la salute massima del 10%',
		client = {
			image = 'runa_hp.png'
		}
	},

	['runa_hp_2'] = {
		label = 'Runa HP +2',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa HP avanzata che aumenta la salute massima del 25%',
		client = {
			image = 'runa_hp.png'
		}
	},

	['runa_hp_3'] = {
		label = 'Runa HP +3',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa HP superiore che aumenta la salute massima del 50%',
		client = {
			image = 'runa_hp.png'
		}
	},

	['runa_hp_4'] = {
		label = 'Runa HP +4',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa HP epica che aumenta la salute massima del 75%',
		client = {
			image = 'runa_hp.png'
		}
	},

	['runa_hp_divina'] = {
		label = 'Runa HP Divina +5',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa massimizzata che conferisce immortalità temporanea e rigenerazione istantanea',
		client = {
			image = 'runa_hp.png'
		}
	},

	['runa_danno'] = {
		label = 'Runa Danno',
		weight = 100,
		stack = true,
		close = true,
		description = 'Aumenta il danno delle armi',
		client = {
			image = 'runa_danno.png'
		}
	},

	['runa_danno_1'] = {
		label = 'Runa Danno +1',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Danno migliorata che aumenta il danno del 15%',
		client = {
			image = 'runa_danno.png'
		}
	},

	['runa_danno_2'] = {
		label = 'Runa Danno +2',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Danno avanzata che aumenta il danno del 30%',
		client = {
			image = 'runa_danno.png'
		}
	},

	['runa_danno_3'] = {
		label = 'Runa Danno +3',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Danno superiore che aumenta il danno del 50%',
		client = {
			image = 'runa_danno.png'
		}
	},

	['runa_danno_4'] = {
		label = 'Runa Danno +4',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Danno epica che aumenta il danno del 75%',
		client = {
			image = 'runa_danno.png'
		}
	},

	['runa_danno_divina'] = {
		label = 'Runa Danno Divina +5',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa massimizzata che triplica il danno e aggiunge effetti elementali',
		client = {
			image = 'runa_danno.png'
		}
	},

	['runa_mp'] = {
		label = 'Runa MP',
		weight = 100,
		stack = true,
		close = true,
		description = 'Aumenta i punti mana',
		client = {
			image = 'runa_mp.png'
		}
	},

	['runa_mp_1'] = {
		label = 'Runa MP +1',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa MP migliorata che aumenta il mana massimo del 20%',
		client = {
			image = 'runa_mp.png'
		}
	},

	['runa_mp_2'] = {
		label = 'Runa MP +2',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa MP avanzata che aumenta il mana massimo del 40%',
		client = {
			image = 'runa_mp.png'
		}
	},

	['runa_mp_3'] = {
		label = 'Runa MP +3',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa MP superiore che aumenta il mana massimo del 60%',
		client = {
			image = 'runa_mp.png'
		}
	},

	['runa_mp_4'] = {
		label = 'Runa MP +4',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa MP epica che aumenta il mana massimo dell\'80%',
		client = {
			image = 'runa_mp.png'
		}
	},

	['runa_mp_divina'] = {
		label = 'Runa MP Divina +5',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa massimizzata che garantisce mana infinito e cast istantanei',
		client = {
			image = 'runa_mp.png'
		}
	},

	['runa_cdr'] = {
		label = 'Runa CDR',
		weight = 100,
		stack = true,
		close = true,
		description = 'Riduce il cooldown delle abilità',
		client = {
			image = 'runa_cdr.png'
		}
	},

	['runa_cdr_1'] = {
		label = 'Runa CDR +1',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa CDR migliorata che riduce i cooldown del 10%',
		client = {
			image = 'runa_cdr.png'
		}
	},

	['runa_cdr_2'] = {
		label = 'Runa CDR +2',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa CDR avanzata che riduce i cooldown del 25%',
		client = {
			image = 'runa_cdr.png'
		}
	},

	['runa_cdr_3'] = {
		label = 'Runa CDR +3',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa CDR superiore che riduce i cooldown del 40%',
		client = {
			image = 'runa_cdr.png'
		}
	},

	['runa_cdr_4'] = {
		label = 'Runa CDR +4',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa CDR epica che riduce i cooldown del 60%',
		client = {
			image = 'runa_cdr.png'
		}
	},

	['runa_cdr_divina'] = {
		label = 'Runa CDR Divina +5',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa massimizzata che elimina tutti i cooldown e permette abilità concatenate',
		client = {
			image = 'runa_cdr.png'
		}
	},

	['runa_speed'] = {
		label = 'Runa Speed',
		weight = 100,
		stack = true,
		close = true,
		description = 'Aumenta la velocità di movimento',
		client = {
			image = 'runa_speed.png'
		}
	},

	['runa_speed_1'] = {
		label = 'Runa Speed +1',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Speed migliorata che aumenta la velocità del 10%',
		client = {
			image = 'runa_speed.png'
		}
	},

	['runa_speed_2'] = {
		label = 'Runa Speed +2',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Speed avanzata che aumenta la velocità del 20%',
		client = {
			image = 'runa_speed.png'
		}
	},

	['runa_speed_3'] = {
		label = 'Runa Speed +3',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Speed superiore che aumenta la velocità del 30%',
		client = {
			image = 'runa_speed.png'
		}
	},

	['runa_speed_4'] = {
		label = 'Runa Speed +4',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Speed epica che aumenta la velocità del 40%',
		client = {
			image = 'runa_speed.png'
		}
	},

	['runa_speed_divina'] = {
		label = 'Runa Speed Divina +5',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa massimizzata che conferisce velocità suprema e teletrasporto breve',
		client = {
			image = 'runa_speed.png'
		}
	},

	['pietra_grezza'] = {
		label = 'Pietra Grezza',
		weight = 100,
		stack = true,
		close = true,
		description = 'Pietra utilizzata per craftare rune',
		client = {
			image = 'pietra_grezza.png'
		}
	},


	-- fantasy_peds items
	['sangue'] = {
		label = 'Sangue',
		weight = 250,
		stack = true,
		close = true,
		description = 'Sangue fresco che nutre e disseta solo i vampiri',
		consume = 1,
		client = {
			image = 'sangue.png',
			status = {
				hunger = 30,
				thirst = 20,
			},
			anim = {
				dict = 'mp_player_intdrink',
				clip = 'loop_bottle',
				flag = 49,
			},
			prop = {
				model = `prop_cs_bottle_01`,
				pos = vec3(0.02, 0.02, -0.02),
				rot = vec3(-15.0, 50.0, 0.0),
			},
			usetime = 2500,
			notification = 'Ti sei nutrito di sangue fresco!',
			canUse = function(source, item)
				local playerPed = GetPlayerPed(source)
				local isVampire = false
				local form = LocalPlayer and LocalPlayer.state and LocalPlayer.state.fantasyForm
				if form == 'vampire' then
					isVampire = true
				end
				if not isVampire then
					isVampire = Entity(playerPed) and Entity(playerPed).state and Entity(playerPed).state.isVampire or false
				end
				if not isVampire then
					TriggerClientEvent('ox_lib:notify', source, {
						title = 'Errore',
						description = 'Solo i vampiri possono usare il sangue!',
						type = 'error'
					})
					return false
				end
				return true
			end,
			export = 'fantasy_peds.UseBloodItem'
		}
	},

	['pozione_antilupo'] = {
		label = 'Pozione Anti-Lupo',
		weight = 100,
		stack = true,
		close = true,
		description = 'Pozione magica che previene la trasformazione lycan per una notte',
		consume = 1,
		client = {
			image = 'pozione_antilupo.png',
			anim = {
				dict = 'amb@world_human_drinking@coffee@male@idle_a',
				clip = 'idle_c',
				flag = 49,
			},
			prop = {
				model = `prop_cs_bottle_01`,
				pos = vec3(0.02, 0.02, -0.02),
				rot = vec3(-15.0, 50.0, 0.0),
			},
			usetime = 2500,
			notification = 'Hai bevuto la pozione anti-lupo! Sei protetto fino all\'alba.',
			canUse = function(source, item)
				local playerPed = GetPlayerPed(source)
				local isLycan = false
				local form = LocalPlayer and LocalPlayer.state and LocalPlayer.state.fantasyForm
				if form == 'lycan' then
					isLycan = true
				end
				if not isLycan then
					isLycan = Entity(playerPed) and Entity(playerPed).state and Entity(playerPed).state.isLycan or false
				end
				if not isLycan then
					TriggerClientEvent('ox_lib:notify', source, {
						title = 'Errore',
						description = 'Solo i lycan possono usare questa pozione!',
						type = 'error'
					})
					return false
				end
				return true
			end,
			export = 'fantasy_peds.UseAntiPotion'
		}
	},
}
