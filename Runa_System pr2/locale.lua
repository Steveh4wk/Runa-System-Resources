Locales = {}
local locale = Config.Locale
function _(str, ...)  -- Traduci stringa

	if Locales[locale] ~= nil then

		if Locales[locale][str] ~= nil then
			return string.format(Locales[locale][str], ...)
		else
			return '[' .. locale .. '][' .. str .. ']'
		end

	else
		return 'Locale [' .. locale .. '] does not exist'
	end

end

function _U(str, ...) -- Traduci stringa prima lettera maiuscola
	return tostring(_(str, ...):gsub("^%l", string.upper))
end
