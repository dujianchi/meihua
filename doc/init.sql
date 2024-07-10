-- "64gua" definition

CREATE TABLE "64gua" (
	id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL UNIQUE,
	full_name TEXT NOT NULL UNIQUE,
	shang TEXT NOT NULL,
	xia TEXT NOT NULL,
	gua_ci TEXT,
	gua_ci_js TEXT,
	chu_yao TEXT NOT NULL,
	chu_yao_js TEXT NOT NULL, 
	er_yao TEXT NOT NULL,
	er_yao_js TEXT NOT NULL, 
	san_yao TEXT NOT NULL,
	san_yao_js TEXT NOT NULL, 
	si_yao TEXT NOT NULL,
	si_yao_js TEXT NOT NULL, 
	wu_yao TEXT NOT NULL,
	wu_yao_js TEXT NOT NULL, 
	shang_yao TEXT NOT NULL,
	shang_yao_js TEXT NOT NULL
);


-- "8gua" definition

CREATE TABLE "8gua" (
	id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	name TEXT UNIQUE,
	shu_lei TEXT,
	lei_xiang TEXT,
	gua_qi_wang TEXT,
	gua_qi_shuai TEXT,
	xian_tian_fang_wei TEXT, 
	hou_tian_fang_wei TEXT, 
	xian_tian_shu INTEGER, 
	hou_tian_shu INTEGER
);


-- config definition

CREATE TABLE config (
	id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	"key" TEXT NOT NULL UNIQUE,
	val TEXT
);


-- history definition

CREATE TABLE history (
	id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	save_date INTEGER,
	lunar_date TEXT,
	shang INTEGER NOT NULL,
	xia INTEGER NOT NULL,
	bian INTEGER NOT NULL,
	title TEXT NOT NULL,
	"describe" TEXT, 
	sync_hash TEXT NOT NULL
);


-- history_sync definition

CREATE TABLE history_sync (
	id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	create_time INTEGER,
	operate INTEGER,
	uploaded INTEGER DEFAULT (0),
	where_param TEXT,
	where_args TEXT,
	"data" TEXT
);

REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(1, '乾', '玄黄、大赤色、金玉、宝珠、镜、狮、圆物、木果、贵物、冠、象、马、天鹅、刚物。', '天时：天、冰、雹、霰。
地理：西北方、京都、大郡、形胜之地、高亢之所。
人物：君、父、大人、老人、长者、官宦、名人、公门人。
人事：刚健武勇、果决、多动少静、高上下屈。
身体：首、骨、肺。
时序：秋、九十月之交、戌亥年月日时、五金年月日时。
动物：马、天鹅、狮、象。
静物：金玉、宝珠、圆物、水果、刚物、冠、镜。
屋舍：公府、楼台、高堂、大厦、驿舍、西北向之居。
家宅：秋占宅兴隆、夏占有祸、冬占冷落、春占吉利。
婚姻：贵官之眷、有声名之家、秋占宜成、冬夏占不利。
饮食：马肉、珍味、多骨、肝肺、干肉、水果、诸物之首、圆物、辛辣之物。
生产：易生、秋占生贵子，夏占有损，坐宜向西北。
求名：有名、宜随朝内任、刑官、武职、掌权、天使、驿官、宜西北方之任。
谋旺：有成、利公门、宜动中有财、夏占不成、冬占多谋少遂。
交易：宜金、玉珍、宝珠、贵货、易成，夏占不利。
求利：有财、金玉之利、公门中得财，秋占大利、夏占损财、冬占无财。
出行：利于出行、宜入京师、利西北之行、夏占不利。
谒见：利见大人、有德行之人、宜见官贵、可见。
疾病：头面之疾、肺疾、筋骨疾、上焦疾、夏占不安。
官讼：健讼、有贵人助、秋占得胜、夏占失理。
坟墓：宜向西北、宜乾山气脉、宜天穴、宜高、秋占出贵、夏占大凶。
方道：西北。
五色：大赤色、玄色。
姓字：带金旁者、商音、行位一四九。
数目：一、四、九。
五味：辛、辣。', '秋', '夏', '南', '西北', 1, 6);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(2, '兑', '金刃、金器、乐器、泽中之物、白色、有口缺之物、羊。', '天时：雨泽、新月、星。
地理：泽、水际、缺池、废井、山崩破裂之地、其地为刚卤。
人物：少女、妾、歌妓、伶人、译人、巫师。
人事：喜悦、口、谗毁、谤说、饮食。
身体：舌、口喉、肺、痰、涎。
时序：秋八月、酉年月日时、二四九月日。
静物：金刀、金类、乐器、废物、缺器。
动物：羊、泽中之物。
屋舍：西向之居、近泽之居、败墙壁宅、户有损。
家宅：不安、防口舌、秋占喜悦、夏占家宅有祸。
饮食：羊肉、泽中之物、宿味、辛辣之味。
婚姻：不成、秋占可成、有喜、主成婚之吉、利婚少女、夏占不利。
生产：不利、恐有损胎或则生女、夏占不利、宜坐向西。
求名：难成、因名有损、利西之任、宜刑官、武职、伶官、译官。
求利：无利、有损、财利、主口舌、秋占有财喜、夏占破财。
出行：不宜远行、防口舌、或损失、宜西行、秋占宜行有利。
交易：难利、防口舌、有争竞、夏占不利、秋占有交易之财。
谋旺：难成、谋中有损、秋占有喜、夏占不遂。
谒见：利行西方、见有咒诅。
疾病：口舌、咽喉之疾、气逆喘疾、饮食不飧。
坟墓：宜西向、防穴中有水、近泽之墓、夏占不宜、或葬废穴。
官讼：争讼不已、曲直未决、因讼有损、防刑、秋占为体得理胜讼。
姓字：商音、带口带金字旁姓氏、行位四二九。
数目：四、二、九。
方道：西方。
五色：白。
五味：辛、辣。', '秋', '夏', '东南', '西', 2, 7);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(3, '离', '火、文书、干戈、雉、龟、蟹、槁木、甲胄、螺、蚌、鳖、赤色。', '天时：日、电、虹、霓、霞。
地理：南方、干亢之地、窖灶、炉冶之所、刚燥厥地、其地面阳。
人物：中女、文人、大腹、目疾人、甲胄之士。
人事：文画之所、聪明才学、相见虚心、书事。
身体：目、心、上焦。
时序：夏五月、午火年月日时、三二七日。
静物：火、书、文、甲胄、干戈、槁衣、干燥之物、赤色之物。
动物：雉、龟、鳖、蟹、螺、蚌。
屋舍：南舍之居、阳明之宅、明窗、虚室。
家宅：安稳、平善、冬占不安、克体主火灾。
饮食：雉肉、煎炒、烧炙之物、干脯之体、热肉。
婚姻：不成、利中女之婚、夏占可成、冬占不利。
生产：易生、产中女、冬占有损、坐宜向南。
求名：有名、宜南方之职、文官之任、宜炉冶亢场之职。
求利：有财宜南方求、有文书之财、冬占有失。
谋旺：可以谋旺、宜文书之事。
交易：可成、宜有文书之交易。
出行：可行、宜向南方、就文书之行、冬占不宜行、不宜行舟。
谒见：可见南方人、冬占不顺、秋见文书考案之士。
官讼：易散、文书动、辞讼明辨。
疾病：目疾、心疾、上焦热病、夏占伏暑、时疫。
坟墓：南向之幕、无树木之所、阳穴。夏占出文人、冬占不利。
姓字：征音、立人旁士姓氏、行位三二七。
数目：三、二、七。
方道：南。
五色：赤、紫、红。
五味：苦。', '夏', '冬', '东', '南', 3, 9);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(4, '震', '竹木、青碧绿色、龙、蛇、萑(huán)苇、竹木乐器、草、蕃鲜之物。', '天时：雷。
地理：东方、树木、闹市、大途、竹林、草木茂盛之所。
人物：长男。
人事：起动、怒、虚惊、鼓动噪、多动少静。
身体：足、肝、发、声音。
时序：春三月、卯年月日时、四三八月日。
静物：木竹、萑苇、乐器（属竹木者）、花草繁鲜之物。
动物：龙、蛇。
屋舍：东向之居、山林之处、楼阁。
家宅：宅中不时有虚惊、春冬吉、秋占不利。
饮食：蹄、肉、山林野味、鲜肉、果酸味、菜蔬。
婚姻：可、有成、声名之家、得长男之婚、秋占不宜婚。
求利：山林竹木之财、动处求财、或山林、竹木茶货之利。
求名：有名、宜东方之任、施号发令之职、掌刑狱之官、竹茶木税课之任、或闹市司货之职。
生产：虚惊、胎动不安、头胎必生男、坐宜东向、秋占必有损。
疾病：足疾、肝经之疾、惊怖不安。
谋旺：可旺、可求、宜动中谋、秋占不遂。
交易：利于成交、秋占难成、动而可成、山林、木竹茶货之利。
官讼：健讼、有虚惊、行移取甚反复。
谒见：可见、在山林之人、利见宜有声名之人。
出行：宜行、利于东方、利山林之人、秋占不宜行、但恐虚惊。
坟墓：利于东向、山林中穴、秋不利。
姓字：角音、带木姓人、行位四八三。
数目：四、八、三。
方道：东。
五味：甘、酸味。
五色：青、绿、碧', '春', '秋', '东北', '东', 4, 3);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(5, '巽', '木、蛇、长物、青碧绿色、山木之禽鸟、、香、鸡、直物、竹木之器、工巧之器。', '天时：风。
地理：东南方之地、草木茂秀之所、花果菜园。
人物：长女、秀士、寡妇之人、山林仙道之人。
人事：柔和、不定、鼓舞、利市三倍、进退不果。
身体：肱、股、气、风疾。
时序：春夏之交、三五八之时月日、辰巳月日时。
静物：木香、绳、直物、长物、竹木、工巧之器。
动物：鸡、百禽、山林中之禽、虫。
屋舍：东南向之居、寺观楼台、山林之居。
家宅：安稳利市、春占吉、秋占不安。
饮食：鸡肉、山林之味、蔬果酸味。
婚姻：可成、宜长女之婚、秋占不利。
生产：易生、头胎产女、秋占损胎、宜向东南坐。
求名：有名、宜文职有风宪之力、宜为风宪、宜茶果竹木税货之职、宜东南之任。
求利：有利三倍、宜山林之利、秋占不利、竹货木货之利。
交易：可成、进退不一、利山林交易、山林木茶之利。
谋旺：可谋旺、有财可成、秋占多谋少遂。
出行：可行、有出入之利、宜向东南行、秋占不利。
谒见：可见、利见山林之人、利见文人秀士。
疾病：股肱之疾、风疾、肠疾、中风、寒邪、气疾。
姓字：角音、草木旁姓氏、行位五三八。
官讼：宜和、恐遭风宪之责。
坟墓：宜东南方向、山林之穴、多树木、秋占不利。
数目：五、三、八。
方道：东南。
五味：酸味。
五色：青、绿、碧、洁白。', '春', '秋', '西南', '东南', 5, 4);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(6, '坎', '水、带子带核之物、豕、鱼、弓轮、水具、水中之物、盐、酒、黑色。', '天时：月、雨、雪、霜、露。
地理：北方、江湖、溪涧、泉井、卑湿之地（沟渎、池沼、凡有水处）。
人物：中男、江湖之人、舟人、资贼。
人事：险陷卑下、外示以柔、内序以利、漂泊不成、随波逐流。
身体：耳、血、肾。
时序：冬十一月、子年月日时、一六月日。
静物：水带子、带核之物、弓轮、矫揉之物、酒器、水具。
屋舍：向北之居、近水、水阁、江楼、花酒长器、宅中混地之处。
饮食：豕肉、酒、冷味、海味、汤、酸味、宿食、鱼、带血、掩藏、有带核之物、水中之物、多骨之物。
家宅：不安、暗昧、防盗。
婚姻：利中男之婚、宜北方之婚、辰戌丑未月婚不可。
生产：难产有险、宜次胎、中男、辰戌丑未月有损、宜北向。
求名：艰难、恐有灾险、宜北方之任、鱼盐河泊之职。
求利：有财失、宜水边财、恐有失陷、宜鱼盐酒货之利、防遗失、防盗。
交易：不利成交、恐防失陷、宜水边交易、宜鱼盐货之交易、或点水人之交易。
谋旺：不宜谋旺、不能成就、秋冬占可谋旺。
出行：不宜远行、宜涉舟、宜北方之行、防盗、恐遇险陷溺之事。
谒见：难见、宜见江湖之人、或有水旁姓氏之人。
疾病：耳痛、心疾、感寒、肾疾、胃冷、水泻、痼冷之病、血病。
官讼：不利、有阴险、有失、因讼、失陷。
坟墓：宜北向之穴、近水傍之墓、不利葬。
姓字：羽音、点水旁之姓氏、行位一六。
数目：一、六。
方道：北方。
五味：咸、酸。
五色：黑。', '冬', '农历三、九、十二、六月', '西', '北', 6, 1);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(7, '艮', '土石、黄色、虎、狗、土中之物、瓜果、百禽、鼠、黔喙之属。', '天时：云、雾、山岚。
地理：山径路、近山城、丘陵、坟墓、东北方。
人物：少男、闲人、山中人。
人事：阻隔、守静、进退不决、反背、止住、不见。
身体：手指、骨、鼻、背。
时序：冬春之月、十二月丑寅年月日时、七五十数月日、土年月日时。
静物：土石、瓜果、黄物、土中之物。
动物：虎、狗、鼠、百兽、黔啄之物。
家宅：安稳、诸事有阻、家人不睦、春占不安。
屋舍：东北方之居、山居近石、近路之宅。
饮食：土中物味、诸兽之肉、墓畔竹笋之属、野味。
婚姻：阻隔难成、成亦迟、利少男之婚、春占不利、宜对乡里婚。
求名：阻隔无名、宜东北方之任、宜土官山城之职。
求利：求财阻隔、宜山林中取财、春占不利、有损失。
生产：难生、有险阻之厄、宜向东北、春占有损。
交易：难成、有山林田土之交易、春占有失。
谋旺：阻隔难成、进退不决。
出行：不宜远行、有阻、宜近陆行。
谒见：不可见、有阻、宜见山林之人。
疾病：手指之疾、脾胃之疾。
官讼：贵人阻滞、官讼未解、牵连不决。
坟墓：东北之穴、山中之穴、春占不利、近路旁有石。
数目：五、七、十。
方道：东北方。
五色：黄。
五味：甘。', '农历三、九、十二、六月', '春', '西北', '东北', 7, 8);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(8, '坤', '土、方物、五谷、柔物、丝绵、百禽、牛、布帛、舆、金、瓦器、黄色。', '天时：云阴、雾气。
地理：田野、乡里、平地、西南方。
人物：老母、后母、农夫、乡人、众人、大腹人。
人事：吝啬、柔顺、懦弱、众多。
身体：腹、脾、胃、肉。
时序：辰戌丑未月、未申年月日时、八五十月日。
静物：方物、柔物、布帛、丝绵、五谷、舆釜、瓦器。
动物：牛、百兽、牝马。
屋舍：西南向、村居、田舍、矮屋、土阶、仓库。
家宅：安稳、多阴气、春占宅舍不安。
饮食：牛肉、土中之物、甘味、野味、五谷之味、芋笋之物、腹脏之物。
婚姻：利于婚姻、宜税产之家、乡村之家、或寡妇之家、春占不利。
生产：易产、春占难产、有损、或不利于母、坐宜西南方。
求名：有名、宜西南方或教官、农官守土之职、春占虚名。
交易：宜利交易、宜田土交易、宜五谷、利贱货、重物、布帛、静中有财、春占不利。
求利：有利、宜土中之利、贱货重物之利、静中得财、春占无财、多中取利。
谋旺：利求谋、乡里求谋、静中求谋、春占少遂、或谋于妇人。
出行：可行、宜西南行、宜往乡里行、宜陆行、春占不宜行。
谒见：可见、利见乡人、宜见亲朋或阴人、春不宜见。
疾病：腹疾、脾胃之疾、饮食停伤、谷食不化。
官讼：理顺、得众情、讼当解散。
坟墓：宜向西南之穴、平阳之地、近田野、宜低葬、春不可葬。
姓字：宫音、带土姓人、行位八五十。
数目：八、五、十。
方道：西南。
五味：甘。
五色：黄、黑。', '农历三、九、十二、六月', '春', '北', '西南', 8, 2);


-- "64gua" definition

CREATE TABLE "64gua" (
	id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL UNIQUE,
	full_name TEXT NOT NULL UNIQUE,
	shang TEXT NOT NULL,
	xia TEXT NOT NULL,
	gua_ci TEXT,
	gua_ci_js TEXT,
	chu_yao TEXT NOT NULL,
	chu_yao_js TEXT NOT NULL, 
	er_yao TEXT NOT NULL,
	er_yao_js TEXT NOT NULL, 
	san_yao TEXT NOT NULL,
	san_yao_js TEXT NOT NULL, 
	si_yao TEXT NOT NULL,
	si_yao_js TEXT NOT NULL, 
	wu_yao TEXT NOT NULL,
	wu_yao_js TEXT NOT NULL, 
	shang_yao TEXT NOT NULL,
	shang_yao_js TEXT NOT NULL
);


-- "8gua" definition

CREATE TABLE "8gua" (
	id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	name TEXT UNIQUE,
	shu_lei TEXT,
	lei_xiang TEXT,
	gua_qi_wang TEXT,
	gua_qi_shuai TEXT,
	xian_tian_fang_wei TEXT, 
	hou_tian_fang_wei TEXT, 
	xian_tian_shu INTEGER, 
	hou_tian_shu INTEGER
);


-- config definition

CREATE TABLE config (
	id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	"key" TEXT NOT NULL UNIQUE,
	val TEXT
);


-- history definition

CREATE TABLE history (
	id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	save_date INTEGER,
	lunar_date TEXT,
	shang INTEGER NOT NULL,
	xia INTEGER NOT NULL,
	bian INTEGER NOT NULL,
	title TEXT NOT NULL,
	"describe" TEXT, 
	sync_hash TEXT NOT NULL
);


-- history_sync definition

CREATE TABLE history_sync (
	id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	create_time INTEGER,
	operate INTEGER,
	uploaded INTEGER DEFAULT (0),
	where_param TEXT,
	where_args TEXT,
	"data" TEXT
);

REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(1, '乾', '玄黄、大赤色、金玉、宝珠、镜、狮、圆物、木果、贵物、冠、象、马、天鹅、刚物。', '天时：天、冰、雹、霰。
地理：西北方、京都、大郡、形胜之地、高亢之所。
人物：君、父、大人、老人、长者、官宦、名人、公门人。
人事：刚健武勇、果决、多动少静、高上下屈。
身体：首、骨、肺。
时序：秋、九十月之交、戌亥年月日时、五金年月日时。
动物：马、天鹅、狮、象。
静物：金玉、宝珠、圆物、水果、刚物、冠、镜。
屋舍：公府、楼台、高堂、大厦、驿舍、西北向之居。
家宅：秋占宅兴隆、夏占有祸、冬占冷落、春占吉利。
婚姻：贵官之眷、有声名之家、秋占宜成、冬夏占不利。
饮食：马肉、珍味、多骨、肝肺、干肉、水果、诸物之首、圆物、辛辣之物。
生产：易生、秋占生贵子，夏占有损，坐宜向西北。
求名：有名、宜随朝内任、刑官、武职、掌权、天使、驿官、宜西北方之任。
谋旺：有成、利公门、宜动中有财、夏占不成、冬占多谋少遂。
交易：宜金、玉珍、宝珠、贵货、易成，夏占不利。
求利：有财、金玉之利、公门中得财，秋占大利、夏占损财、冬占无财。
出行：利于出行、宜入京师、利西北之行、夏占不利。
谒见：利见大人、有德行之人、宜见官贵、可见。
疾病：头面之疾、肺疾、筋骨疾、上焦疾、夏占不安。
官讼：健讼、有贵人助、秋占得胜、夏占失理。
坟墓：宜向西北、宜乾山气脉、宜天穴、宜高、秋占出贵、夏占大凶。
方道：西北。
五色：大赤色、玄色。
姓字：带金旁者、商音、行位一四九。
数目：一、四、九。
五味：辛、辣。', '秋', '夏', '南', '西北', 1, 6);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(2, '兑', '金刃、金器、乐器、泽中之物、白色、有口缺之物、羊。', '天时：雨泽、新月、星。
地理：泽、水际、缺池、废井、山崩破裂之地、其地为刚卤。
人物：少女、妾、歌妓、伶人、译人、巫师。
人事：喜悦、口、谗毁、谤说、饮食。
身体：舌、口喉、肺、痰、涎。
时序：秋八月、酉年月日时、二四九月日。
静物：金刀、金类、乐器、废物、缺器。
动物：羊、泽中之物。
屋舍：西向之居、近泽之居、败墙壁宅、户有损。
家宅：不安、防口舌、秋占喜悦、夏占家宅有祸。
饮食：羊肉、泽中之物、宿味、辛辣之味。
婚姻：不成、秋占可成、有喜、主成婚之吉、利婚少女、夏占不利。
生产：不利、恐有损胎或则生女、夏占不利、宜坐向西。
求名：难成、因名有损、利西之任、宜刑官、武职、伶官、译官。
求利：无利、有损、财利、主口舌、秋占有财喜、夏占破财。
出行：不宜远行、防口舌、或损失、宜西行、秋占宜行有利。
交易：难利、防口舌、有争竞、夏占不利、秋占有交易之财。
谋旺：难成、谋中有损、秋占有喜、夏占不遂。
谒见：利行西方、见有咒诅。
疾病：口舌、咽喉之疾、气逆喘疾、饮食不飧。
坟墓：宜西向、防穴中有水、近泽之墓、夏占不宜、或葬废穴。
官讼：争讼不已、曲直未决、因讼有损、防刑、秋占为体得理胜讼。
姓字：商音、带口带金字旁姓氏、行位四二九。
数目：四、二、九。
方道：西方。
五色：白。
五味：辛、辣。', '秋', '夏', '东南', '西', 2, 7);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(3, '离', '火、文书、干戈、雉、龟、蟹、槁木、甲胄、螺、蚌、鳖、赤色。', '天时：日、电、虹、霓、霞。
地理：南方、干亢之地、窖灶、炉冶之所、刚燥厥地、其地面阳。
人物：中女、文人、大腹、目疾人、甲胄之士。
人事：文画之所、聪明才学、相见虚心、书事。
身体：目、心、上焦。
时序：夏五月、午火年月日时、三二七日。
静物：火、书、文、甲胄、干戈、槁衣、干燥之物、赤色之物。
动物：雉、龟、鳖、蟹、螺、蚌。
屋舍：南舍之居、阳明之宅、明窗、虚室。
家宅：安稳、平善、冬占不安、克体主火灾。
饮食：雉肉、煎炒、烧炙之物、干脯之体、热肉。
婚姻：不成、利中女之婚、夏占可成、冬占不利。
生产：易生、产中女、冬占有损、坐宜向南。
求名：有名、宜南方之职、文官之任、宜炉冶亢场之职。
求利：有财宜南方求、有文书之财、冬占有失。
谋旺：可以谋旺、宜文书之事。
交易：可成、宜有文书之交易。
出行：可行、宜向南方、就文书之行、冬占不宜行、不宜行舟。
谒见：可见南方人、冬占不顺、秋见文书考案之士。
官讼：易散、文书动、辞讼明辨。
疾病：目疾、心疾、上焦热病、夏占伏暑、时疫。
坟墓：南向之幕、无树木之所、阳穴。夏占出文人、冬占不利。
姓字：征音、立人旁士姓氏、行位三二七。
数目：三、二、七。
方道：南。
五色：赤、紫、红。
五味：苦。', '夏', '冬', '东', '南', 3, 9);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(4, '震', '竹木、青碧绿色、龙、蛇、萑(huán)苇、竹木乐器、草、蕃鲜之物。', '天时：雷。
地理：东方、树木、闹市、大途、竹林、草木茂盛之所。
人物：长男。
人事：起动、怒、虚惊、鼓动噪、多动少静。
身体：足、肝、发、声音。
时序：春三月、卯年月日时、四三八月日。
静物：木竹、萑苇、乐器（属竹木者）、花草繁鲜之物。
动物：龙、蛇。
屋舍：东向之居、山林之处、楼阁。
家宅：宅中不时有虚惊、春冬吉、秋占不利。
饮食：蹄、肉、山林野味、鲜肉、果酸味、菜蔬。
婚姻：可、有成、声名之家、得长男之婚、秋占不宜婚。
求利：山林竹木之财、动处求财、或山林、竹木茶货之利。
求名：有名、宜东方之任、施号发令之职、掌刑狱之官、竹茶木税课之任、或闹市司货之职。
生产：虚惊、胎动不安、头胎必生男、坐宜东向、秋占必有损。
疾病：足疾、肝经之疾、惊怖不安。
谋旺：可旺、可求、宜动中谋、秋占不遂。
交易：利于成交、秋占难成、动而可成、山林、木竹茶货之利。
官讼：健讼、有虚惊、行移取甚反复。
谒见：可见、在山林之人、利见宜有声名之人。
出行：宜行、利于东方、利山林之人、秋占不宜行、但恐虚惊。
坟墓：利于东向、山林中穴、秋不利。
姓字：角音、带木姓人、行位四八三。
数目：四、八、三。
方道：东。
五味：甘、酸味。
五色：青、绿、碧', '春', '秋', '东北', '东', 4, 3);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(5, '巽', '木、蛇、长物、青碧绿色、山木之禽鸟、、香、鸡、直物、竹木之器、工巧之器。', '天时：风。
地理：东南方之地、草木茂秀之所、花果菜园。
人物：长女、秀士、寡妇之人、山林仙道之人。
人事：柔和、不定、鼓舞、利市三倍、进退不果。
身体：肱、股、气、风疾。
时序：春夏之交、三五八之时月日、辰巳月日时。
静物：木香、绳、直物、长物、竹木、工巧之器。
动物：鸡、百禽、山林中之禽、虫。
屋舍：东南向之居、寺观楼台、山林之居。
家宅：安稳利市、春占吉、秋占不安。
饮食：鸡肉、山林之味、蔬果酸味。
婚姻：可成、宜长女之婚、秋占不利。
生产：易生、头胎产女、秋占损胎、宜向东南坐。
求名：有名、宜文职有风宪之力、宜为风宪、宜茶果竹木税货之职、宜东南之任。
求利：有利三倍、宜山林之利、秋占不利、竹货木货之利。
交易：可成、进退不一、利山林交易、山林木茶之利。
谋旺：可谋旺、有财可成、秋占多谋少遂。
出行：可行、有出入之利、宜向东南行、秋占不利。
谒见：可见、利见山林之人、利见文人秀士。
疾病：股肱之疾、风疾、肠疾、中风、寒邪、气疾。
姓字：角音、草木旁姓氏、行位五三八。
官讼：宜和、恐遭风宪之责。
坟墓：宜东南方向、山林之穴、多树木、秋占不利。
数目：五、三、八。
方道：东南。
五味：酸味。
五色：青、绿、碧、洁白。', '春', '秋', '西南', '东南', 5, 4);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(6, '坎', '水、带子带核之物、豕、鱼、弓轮、水具、水中之物、盐、酒、黑色。', '天时：月、雨、雪、霜、露。
地理：北方、江湖、溪涧、泉井、卑湿之地（沟渎、池沼、凡有水处）。
人物：中男、江湖之人、舟人、资贼。
人事：险陷卑下、外示以柔、内序以利、漂泊不成、随波逐流。
身体：耳、血、肾。
时序：冬十一月、子年月日时、一六月日。
静物：水带子、带核之物、弓轮、矫揉之物、酒器、水具。
屋舍：向北之居、近水、水阁、江楼、花酒长器、宅中混地之处。
饮食：豕肉、酒、冷味、海味、汤、酸味、宿食、鱼、带血、掩藏、有带核之物、水中之物、多骨之物。
家宅：不安、暗昧、防盗。
婚姻：利中男之婚、宜北方之婚、辰戌丑未月婚不可。
生产：难产有险、宜次胎、中男、辰戌丑未月有损、宜北向。
求名：艰难、恐有灾险、宜北方之任、鱼盐河泊之职。
求利：有财失、宜水边财、恐有失陷、宜鱼盐酒货之利、防遗失、防盗。
交易：不利成交、恐防失陷、宜水边交易、宜鱼盐货之交易、或点水人之交易。
谋旺：不宜谋旺、不能成就、秋冬占可谋旺。
出行：不宜远行、宜涉舟、宜北方之行、防盗、恐遇险陷溺之事。
谒见：难见、宜见江湖之人、或有水旁姓氏之人。
疾病：耳痛、心疾、感寒、肾疾、胃冷、水泻、痼冷之病、血病。
官讼：不利、有阴险、有失、因讼、失陷。
坟墓：宜北向之穴、近水傍之墓、不利葬。
姓字：羽音、点水旁之姓氏、行位一六。
数目：一、六。
方道：北方。
五味：咸、酸。
五色：黑。', '冬', '农历三、九、十二、六月', '西', '北', 6, 1);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(7, '艮', '土石、黄色、虎、狗、土中之物、瓜果、百禽、鼠、黔喙之属。', '天时：云、雾、山岚。
地理：山径路、近山城、丘陵、坟墓、东北方。
人物：少男、闲人、山中人。
人事：阻隔、守静、进退不决、反背、止住、不见。
身体：手指、骨、鼻、背。
时序：冬春之月、十二月丑寅年月日时、七五十数月日、土年月日时。
静物：土石、瓜果、黄物、土中之物。
动物：虎、狗、鼠、百兽、黔啄之物。
家宅：安稳、诸事有阻、家人不睦、春占不安。
屋舍：东北方之居、山居近石、近路之宅。
饮食：土中物味、诸兽之肉、墓畔竹笋之属、野味。
婚姻：阻隔难成、成亦迟、利少男之婚、春占不利、宜对乡里婚。
求名：阻隔无名、宜东北方之任、宜土官山城之职。
求利：求财阻隔、宜山林中取财、春占不利、有损失。
生产：难生、有险阻之厄、宜向东北、春占有损。
交易：难成、有山林田土之交易、春占有失。
谋旺：阻隔难成、进退不决。
出行：不宜远行、有阻、宜近陆行。
谒见：不可见、有阻、宜见山林之人。
疾病：手指之疾、脾胃之疾。
官讼：贵人阻滞、官讼未解、牵连不决。
坟墓：东北之穴、山中之穴、春占不利、近路旁有石。
数目：五、七、十。
方道：东北方。
五色：黄。
五味：甘。', '农历三、九、十二、六月', '春', '西北', '东北', 7, 8);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(8, '坤', '土、方物、五谷、柔物、丝绵、百禽、牛、布帛、舆、金、瓦器、黄色。', '天时：云阴、雾气。
地理：田野、乡里、平地、西南方。
人物：老母、后母、农夫、乡人、众人、大腹人。
人事：吝啬、柔顺、懦弱、众多。
身体：腹、脾、胃、肉。
时序：辰戌丑未月、未申年月日时、八五十月日。
静物：方物、柔物、布帛、丝绵、五谷、舆釜、瓦器。
动物：牛、百兽、牝马。
屋舍：西南向、村居、田舍、矮屋、土阶、仓库。
家宅：安稳、多阴气、春占宅舍不安。
饮食：牛肉、土中之物、甘味、野味、五谷之味、芋笋之物、腹脏之物。
婚姻：利于婚姻、宜税产之家、乡村之家、或寡妇之家、春占不利。
生产：易产、春占难产、有损、或不利于母、坐宜西南方。
求名：有名、宜西南方或教官、农官守土之职、春占虚名。
交易：宜利交易、宜田土交易、宜五谷、利贱货、重物、布帛、静中有财、春占不利。
求利：有利、宜土中之利、贱货重物之利、静中得财、春占无财、多中取利。
谋旺：利求谋、乡里求谋、静中求谋、春占少遂、或谋于妇人。
出行：可行、宜西南行、宜往乡里行、宜陆行、春占不宜行。
谒见：可见、利见乡人、宜见亲朋或阴人、春不宜见。
疾病：腹疾、脾胃之疾、饮食停伤、谷食不化。
官讼：理顺、得众情、讼当解散。
坟墓：宜向西南之穴、平阳之地、近田野、宜低葬、春不可葬。
姓字：宫音、带土姓人、行位八五十。
数目：八、五、十。
方道：西南。
五味：甘。
五色：黄、黑。', '农历三、九、十二、六月', '春', '北', '西南', 8, 2);

REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(1, '乾', '乾為天', '乾', '乾', '乾：元，亨，利，貞。', '象徵天：元始，亨通，和諧，貞正。 ', '初九，潛龍勿用。', '初九，龍尚潜伏在水中，養精蓄銳，暫時還', '九二，見龍在田，利見大人。', '龍已出現在地上，利于出現德高勢隆的大人物。', '九三，君子終日乾乾，夕惕若，厲，无咎。 ', '君子整天自强不息，晚上也不敢有絲毫的懈怠，這樣即使遇到危險也會逢凶化吉。', '九四，或躍在淵，无咎。', '龍或騰躍而起，或退居于淵，均不會有危害。', '九五，飛龍在天，利見大人。', '龍飛上了高空，利于出現德高勢隆的大人物。', '上九，亢龍有悔。', '龍飛到了過高的地方，必將會後悔。');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(2, '坤', '坤為地', '坤', '坤', '坤：元，亨，利，牝馬之貞。 君子有攸往，先迷后得主，利西南得朋，東北喪朋。孜貞，吉。 ', '《坤卦》象徵地：元始，亨通，如果像雌馬那樣柔順，則是吉利的。君子從事某項事業，雖然開始時不知所從，但結果會是有利的。如往西南方，則會得到朋友的幫助。如往東南方，則會失去朋友的幫助。如果保持現狀，也
是吉利的。', '初六，履霜，堅冰至。', '初六，脚踏上了霜，氣候變冷，冰雪即將到來。', '六二，直方大，不習无不利。', '正直、端正、廣大，具備這樣的品質，即使不學習也不會有什麽不利。', '六三，含章可貞，或從王事，无成有終。', '胸懷才華而不顯露，如果輔佐君主，能克盡職守，功成不居。', '六四，括囊，无咎无譽。', '扎緊袋口，不說也不動，這樣雖得不到稱贊，但也免遭禍患。', '六五，黃裳，元吉。', '六五，黃色的衣服，最爲吉祥。', '上六，龍戰于野，其血玄黃。
用六，利永貞。', '陰氣盛極，與陽氣相戰郊外，天地混雜，乾坤莫辨，後果是不堪設想的。
用六這一爻，利於永遠保持中正。');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(3, '屯', '水雷屯', '坎', '震', '屯：元，亨，利，貞，勿用，有攸往，利建侯。', '《屯卦》象徵初生：元始，亨通，和諧，貞正。不要急於發展，適合立君建國。 ', '初九，磐桓，利居貞，利建侯。', '初九，萬事開頭難，在初創時期的困難特別大，難免徘徊不前，但只要能守正不阿，仍然可建功立業。', '六二，屯如邅如，乘馬班如，匪寇婚媾，女子貞不字，十年乃字。', '六二，爲難而團團轉，乘馬旋轉不進，不是盜寇，是來求婚的。女子貞靜自守，不嫁人，要過十年才許嫁。', '六三，即鹿无虞，惟入于林中。君子幾，不如舍。往吝。', '六三，追逐鹿時，由于缺少管山林之人的引導，致使鹿逃入樹林中去。君子此時如仍不願捨棄，輕率地繼續追踪，則必然會發生禍事。', '六四，乘馬班如，求婚媾，往吉无不利。', '六四，四馬前進，步調不一，但如堅定不移地去求婚，則結果必然是吉祥順利的。', '九五，屯其膏，小貞吉，大貞凶。', '九五，只顧自己囤積財富而不注意幫助別人，是很危險的，那樣做，辦小事雖有成功的可能，但辦大事則必然會出現凶險。', '上六，乘馬班如，泣血漣如。', '上六，四馬前進，步調不一，進退兩難，悲傷哭泣，泣血不止。');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(4, '蒙', '山水蒙', '艮', '坎', '蒙：亨。匪我求童蒙，童蒙求我。 初噬告，再三瀆，瀆則不告。利貞。', '《蒙卦》象徵啓蒙：亨通。不是我有求於幼童，而是幼童有求於我，第一次向我請教，我有問必答，如果一而再、再而三地沒有禮貌地亂問，則不予回答。利於守正道。', '初六，發蒙。利用刑人，用說桎梏，以往吝。', '初六，要進行啓蒙教育，貴在樹立典型，以便防止罪惡發生；如不專心求學，而是急功冒進，將來必然會後悔。', '九二，包蒙，吉。納婦吉，子克家。', '九二，周圍都是上進心很强的蒙童，希望獲得知識，這是很吉利的。如果迎娶新媳婦，也是吉祥的。由於渴望接受教育，上進心很强，所以連孩子們已經能够治家了。', '六三，勿用取女，見金夫，不有躬，无攸利。', '六三，不能娶這樣的女子，她的心目中只有美貌的郎君，不能守禮儀，也難以保住自己的節操，娶這樣的女子是沒有什麽好處的。', '六四，困蒙，吝。', '六四，人處于困難的境地，不利於接受啓蒙教育，因而孤陋寡聞，結果是不大好的。', '六五，童蒙，吉。', '六五，蒙童虛心地向老師求教，這是很吉祥的。', '上九，擊蒙，不利為寇，利禦寇。', '上九，啓蒙教育要及早實行，要針對蒙童的可能缺點，先預防矯治。不要等到蒙童的問題徹底暴露再去教育，而要防患於未然，事先進行啓蒙教育。');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(5, '需', '水天需', '坎', '乾', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(6, '讼', '天水讼', '乾', '坎', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(7, '师', '地水师', '坤', '坎', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(8, '比', '水地比', ' 坎', '坤', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(9, '小畜', '风天小畜', '巽', '乾', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(10, '履', '天泽履', '乾', '兑', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(11, '泰', '地天泰', '坤', '乾', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(12, '否', '天地否', '乾', '坤', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(13, '同人', '天火同人', '乾', '离', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(14, '大有', '火天大有', '离', '乾', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(15, '谦', '地山谦', '坤', '艮', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(16, '豫', '雷地豫', '震', '坤', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(17, '随', '泽雷随', '兑', '震', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(18, '蛊', '山风蛊', '艮', '巽', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(19, '临', '地泽临', '坤', '兑', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(20, '观', '风地观', '巽', '坤', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(21, '噬嗑', '火雷噬嗑', '离', '震', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(22, '贲', '山火贲', '艮', '离', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(23, '剥', '山地剥', '艮', '坤', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(24, '复', '地雷复', '坤', '震', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(25, '无妄', '天雷无妄', '乾', '震', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(26, '大畜', '山天大畜', '艮', '乾', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(27, '颐', '山雷颐', '艮', '震', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(28, '大过', '泽风大过', '兑', '巽', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(29, '坎', '坎为水', '坎', '坎', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(30, '离', '离为火', '离', '离', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(31, '咸', '泽山咸', '兑', '艮', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(32, '恒', '雷风恒', '震', '巽', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(33, '遁', '天山遁', '乾', '艮', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(34, '大壮', '雷天大壮', '震', '乾', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(35, '晋', '火地晋', '离', '坤', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(36, '明夷', '地火明夷', '坤', '离', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(37, '家人', '风火家人', '巽', '离', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(38, '睽', '火泽睽', '离', '兑', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(39, '蹇', '水山蹇', '坎', '艮', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(40, '解', '雷水解', '震', '坎', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(41, '损', '山泽损', '艮', '兑', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(42, '益', '风雷益', '巽', '震', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(43, '夬', '泽天夬', '兑', '乾', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(44, '姤', '天风姤', '乾', '巽', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(45, '萃', '泽地萃', '兑', '坤', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(46, '升', '地风升', '坤', '巽', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(47, '困', '泽水困', '兑', '坎', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(48, '井', '水风井', '坎', '巽', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(49, '革', '泽火革', '兑', '离', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(50, '鼎', '火风鼎', '离', '巽', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(51, '震', '震为雷', '震', '震', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(52, '艮', '艮为山', '艮', '艮', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(53, '渐', '风山渐', '巽', '艮', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(54, '归妹', '雷泽归妹', '震', '兑', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(55, '丰', '雷火', '震', '离', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(56, '旅', '火山旅', '离', '艮', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(57, '巽', '巽为风', '巽', '巽', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(58, '兑', '兑为泽', '兑', '兑', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(59, '涣', '风水涣', '巽', '坎', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(60, '节', '水泽节', '坎', '兑', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(61, '中孚', '风泽中孚', '巽', '兑', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(62, '小过', '雷山小过', '震', '艮', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(63, '既济', '水火既济', '坎', '离', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
REPLACE INTO "64gua" (id, name, full_name, shang, xia, gua_ci, gua_ci_js, chu_yao, chu_yao_js, er_yao, er_yao_js, san_yao, san_yao_js, si_yao, si_yao_js, wu_yao, wu_yao_js, shang_yao, shang_yao_js) VALUES(64, '未济', '火水未济', '离', '坎', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');


