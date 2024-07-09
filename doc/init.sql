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

