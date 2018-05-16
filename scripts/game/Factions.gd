extends Node

## default ranks, used in unit type definitions
const ENLISTED = "enlisted"
const OFFICER = "officer"

const RANK_SPECIALIST = [ENLISTED, 2]
const RANK_SQUAD_LEAD = [ENLISTED, 3]
const RANK_SECTION_LEAD = [ENLISTED, 4]

const RANK_PLATOON_LEAD = [OFFICER, 1]
const RANK_COMPANY_LEAD = [OFFICER, 2]

const INFO = {
	north = {
		name = "North",
		short_name = "CNCS",
		full_name = "Confederated Northern City-States",
		adjective = "Northern",
		
		#primary_color = Color("#947241"),   #Frontier Brown
		primary_color = Color("#a2801e"),   #Frontier Tan
		secondary_color = Color("#41689b"), #Northern Lights Blue
		
		ranks = {
			ENLISTED : {
				1: { full = "Private",  short = "Pvt" },
				2: { full = "Corporal", short = "Cpl" },
				3: { full = "Senior Corporal", short = "Sr Cpl" },
				4: { full = "Ranger", short = "Rngr" },
				5: { full = "Senior Ranger", short = "Sr Rngr" },
				6: { full = "Sergeant", short = "Sgt" },
				7: { full = "Senior Sergeant", short = "Sr Sgt" },
				8: { full = "Sergeant Major", short = "Sgt Maj" },
			},
			OFFICER : {
				1: { full = "Lieutenant",  short = "Lt" },
				2: { full = "Captain",  short = "Cpt" },
				3: { full = "Major",  short = "Maj" },
				4: { full = "Colonel",  short = "Col" },
				5: { full = "Brigadier",  short = "Brig" },
				6: { full = "General",  short = "Gen" },
			},
		},
		
		unit_models = [
			"dummy_gear",
			"dummy_vehicle",
			"dummy_infantry",
		],
	},
	south = {
		name = "South",
		short_name = "AST",
		full_name = "Allied Southern Territories",
		adjective = "Southern",
		
		primary_color = Color("#486780"), #Steel Blue
		secondary_color = Color("#e61b23"), #Republic Red
		
		ranks = {
			ENLISTED : {
				1: { full = "Soldat",  short = "Sdt" },
				2: { full = "Sous-Caporal", short = "SCpl" },
				3: { full = "Caporal", short = "Cpl" },
				4: { full = "Sergent", short = "Sgt" },
				5: { full = "Sous-Adjudant", short = "SAdj" },
				6: { full = "Adjudant", short = "Adj" },
				7: { full = "Adjudant-Chef", short = "AdjC" },
				8: { full = "Major", short = "Maj" },
			},
			OFFICER : {
				1: { full = "Sous-Lieutenant",  short = "SLt" },
				2: { full = "Lieutenant",  short = "Lt" },
				3: { full = "Sous-Commandant",  short = "SCmdt" },
				4: { full = "Commandant",  short = "Cmdt" },
				5: { full = "Préfet",  short = "Pré" },
				6: { full = "Général",  short = "Gén" },
			},
		},
		
		unit_models = [
			"dummy_gear",
			"dummy_vehicle",
			"dummy_infantry",
		],
	},
}

static func get_info(faction_id):
	return INFO[faction_id]