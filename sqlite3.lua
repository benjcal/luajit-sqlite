local ffi = require('ffi')

ffi.cdef[[
	typedef struct sqlite3 sqlite3;
	typedef int (*sqlite3_callback)(void*,int,char**, char**);

	int sqlite3_open(
		const char *filename,   /* Database filename (UTF-8) */
		sqlite3 **ppDb          /* OUT: SQLite db handle */
	);

	int sqlite3_close(sqlite3*);

	int sqlite3_exec(
		sqlite3*,                                  /* An open database */
		const char *sql,                           /* SQL to be evaluated */
		int (*callback)(void*,int,char**,char**),  /* Callback function */
		void *,                                    /* 1st argument to callback */
		char **errmsg                             /* Error msg written here */
	);
]]

local sqlite3 = ffi.load('sqlite3')
local new_db_prt = ffi.typeof('sqlite3*[1]')

M = {}

function M:open(db_name)
	local o = {}

	local db = new_db_prt()

	sqlite3.sqlite3_open(db_name, db)

	o.db = db[0]

	setmetatable(o, self)
	self.__index = self
	return o
end

function M:exec(sql, func)
	local cb = ffi.cast('sqlite3_callback', func)

	sqlite3.sqlite3_exec(self.db, sql, cb, nil, nil)
end

function M:rows(sql)
	local results = {}

	local func = function(_, col_len, col_val, col_name)
		local t = {}

		for i=0, col_len -1 do
			local val = ffi.string(col_val[i])

			if tonumber(val) then
				val = tonumber(val)
			end

			t[ffi.string(col_name[i])] = val
		end

		table.insert(results, t)

		return 0
	end

	local cb = ffi.cast('sqlite3_callback', func)

	sqlite3.sqlite3_exec(self.db, sql, cb, nil, nil)

	return results

end

return M

