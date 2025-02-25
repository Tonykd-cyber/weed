# weed
ox inventory 

	['flowerpot'] = {
		label = '花盆',
		weight = 10,
		stack = true,
		close = true,
		description = '种植大麻的花盆',
	},

	['fertilizer'] = {
		label = '肥料',
		weight = 10,
		stack = true,
		close = true,
		description = '大麻所需养分',
	},

	['marijuana_seeds'] = {
		label = '大麻种子',
		weight = 10,
		stack = true,
		close = true,
		description ='大麻叶的来源',
	},
 

	['marijuana_leaf'] = {
		label = '未加工的大麻叶',
		weight = 100,
		stack = true,
		close = true,
		description = '用来加工的大麻叶',
	},
	['weed_bricks'] = {
		label = '大麻砖',
		weight = 150,
		stack = true,
		close = true,
		description = '加工好的大麻砖',
	},

	['pure-water'] = {
		label = '纯净水',
		weight = 10,
		stack = true,
		close = true,
		description = '大麻所需水源',
	},
	['electronic_scale'] = {
		label = '电子秤',
		weight = 200,
		stack = true,
		close = true,
 
		description = '用来秤东西',
	},
	['clear_bags'] = {
		label = '透明小袋子',
		weight = 10,
		stack = true,
		close = true,
		description = '用来装东西的',
		buttons = {
			{
				label = '合成',
				action = function()
					 
					TriggerEvent('weed:clear_bags')
				end
			}
		
		},
	},  
	['weed_powder'] = {
		label = '加工大麻',
		weight = 50,
		stack = true,
		close = true,
		description = '加工好的大麻',
	},
	['rolling_paper'] = {
		label = '卷烟纸',
		weight = 50,
		stack = true,
		close = true,
		description = '卷烟用的',
	},
	['weed_joint'] = {
		label = '大麻烟',
		weight = 10,
		stack = true,
		close = true,
		description = '强身健体好伙伴',
		client = { 
			TriggerEvent('weed:joint')
		},
		
	},
