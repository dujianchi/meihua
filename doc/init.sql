-- "64gua" definition

CREATE TABLE "64gua" (
	id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL UNIQUE,
	full_name TEXT NOT NULL UNIQUE,
	gua_ci TEXT,
	tuan_ci TEXT,
	chu_yao TEXT NOT NULL,
	er_yao TEXT NOT NULL,
	san_yao TEXT NOT NULL,
	si_yao TEXT NOT NULL,
	wu_yao TEXT NOT NULL,
	shang_yao TEXT NOT NULL,
	gua_ci_js TEXT,
	tuan_ci_js TEXT, 
	chu_yao_js TEXT NOT NULL, 
	er_yao_js TEXT NOT NULL, 
	san_yao_js TEXT NOT NULL, 
	si_yao_js TEXT NOT NULL, 
	wu_yao_js TEXT NOT NULL, 
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

REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(1, '乾', '玄黄、大赤色、金玉、宝珠、镜、狮、圆物、木果、贵物、冠、象、马、天鹅、刚物。', NULL, '秋', '夏', '南', '西北', 1, 6);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(2, '兑', '金刃、金器、乐器、泽中之物、白色、有口缺之物、羊。', NULL, '秋', '夏', '东南', '西', 2, 7);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(3, '离', '火、文书、干戈、雉、龟、蟹、槁木、甲胄、螺、蚌、鳖、赤色。', NULL, '夏', '冬', '东', '南', 3, 9);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(4, '震', '竹木、青碧绿色、龙、蛇、萑(huán)苇、竹木乐器、草、蕃鲜之物。', NULL, '春', '秋', '东北', '东', 4, 3);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(5, '巽', '木、蛇、长物、青碧绿色、山木之禽鸟、、香、鸡、直物、竹木之器、工巧之器。', NULL, '春', '秋', '西南', '东南', 5, 4);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(6, '坎', '水、带子带核之物、豕、鱼、弓轮、水具、水中之物、盐、酒、黑色。', NULL, '冬', '农历三、九、十二、六月', '西', '北', 6, 1);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(7, '艮', '土石、黄色、虎、狗、土中之物、瓜果、百禽、鼠、黔喙之属。', NULL, '农历三、九、十二、六月', '春', '西北', '东北', 7, 8);
REPLACE INTO "8gua" (id, name, shu_lei, lei_xiang, gua_qi_wang, gua_qi_shuai, xian_tian_fang_wei, hou_tian_fang_wei, xian_tian_shu, hou_tian_shu) VALUES(8, '坤', '土、方物、五谷、柔物、丝绵、百禽、牛、布帛、舆、金、瓦器、黄色。', NULL, '农历三、九、十二、六月', '春', '北', '西南', 8, 2);
