local sqlite3 = require('sqlite3')

local db = sqlite3:open('test.db')

local sql = [[
	CREATE TABLE sample (
		id INT PRIMARY KEY,
		stuff TEXT
	);

	INSERT INTO sample (id, stuff) VALUES (1, "first"), (2, "second");
]]


db:exec(sql)
local rows = db:rows('SELECT * FROM sample')

assert(rows[1].id == 1)
assert(rows[1].stuff == 'first')
assert(rows[2].id == 2)
assert(rows[2].stuff == 'second')

os.execute('rm test.db')

